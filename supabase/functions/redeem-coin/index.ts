// redeem-coin: POST { voucher_id, otp? }
// Atomically spend RunCoin and reserve a partner voucher.
// Steps:
//   1. Load voucher + verify it is active and in stock.
//   2. Load run_coins for caller; reject if balance < cost.
//   3. If voucher value > 100k VND, require a 6-digit OTP (KYC).
//   4. Call partner placeholder to redeem and obtain a code.
//   5. Insert coin_transactions (negative amount); decrement run_coins.balance.
//   6. Insert voucher_redemptions row with the partner code.
// The Postgres function `public.redeem_voucher` (if present) handles step 5+6
// atomically; we fall back to a best-effort sequence if it is not yet deployed.

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { parseBody, redeemCoinSchema } from "@shared/validation";

const KYC_VND_THRESHOLD = 100_000;
const PARTNER_REDEEM_URL = Deno.env.get("PARTNER_REDEEM_URL") ?? "https://partner.example.com/redeem";
const PARTNER_API_KEY = Deno.env.get("PARTNER_API_KEY") ?? "";

interface Voucher {
  readonly id: string;
  readonly partner_code: string;
  readonly title: string;
  readonly cost_coins: number;
  readonly value_vnd: number;
  readonly stock: number;
  readonly is_active: boolean;
}

interface PartnerRedeemResponse {
  readonly code: string;
  readonly expires_at: string;
}

async function callPartner(voucher: Voucher, userId: string): Promise<PartnerRedeemResponse> {
  try {
    const resp = await fetch(PARTNER_REDEEM_URL, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${PARTNER_API_KEY}`,
      },
      body: JSON.stringify({ partner_code: voucher.partner_code, user_id: userId }),
    });
    if (!resp.ok) throw Errors.upstream(`partner returned ${resp.status}`);
    return (await resp.json()) as PartnerRedeemResponse;
  } catch (e) {
    // Placeholder mode: synthesise a code so dev/test envs do not hard-fail.
    if (!PARTNER_API_KEY) {
      const code = `RV-${voucher.partner_code.toUpperCase()}-${crypto.randomUUID().slice(0, 8)}`;
      const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 30).toISOString();
      return { code, expires_at: expiresAt };
    }
    throw e instanceof Error ? Errors.upstream(e.message) : Errors.upstream("partner call failed");
  }
}

export async function redeemCoinHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const body = await parseBody(req, redeemCoinSchema);
  const svc = getServiceClient();

  const voucherQ = await svc
    .from("vouchers")
    .select("id, partner_code, title, cost_coins, value_vnd, stock, is_active")
    .eq("id", body.voucher_id)
    .maybeSingle();
  if (voucherQ.error) throw Errors.internal("voucher lookup failed", voucherQ.error.message);
  if (!voucherQ.data) throw Errors.notFound("voucher not found");

  const voucher = voucherQ.data as Voucher;
  if (!voucher.is_active) throw Errors.conflict("voucher not active");
  if (voucher.stock <= 0) throw Errors.conflict("voucher out of stock");

  // KYC OTP for high-value vouchers.
  if (voucher.value_vnd > KYC_VND_THRESHOLD) {
    if (!body.otp) throw Errors.forbidden("otp required for high-value voucher");
    const otpQ = await svc
      .from("kyc_otps")
      .select("code, expires_at, used_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    const row = otpQ.data as { code: string; expires_at: string; used_at: string | null } | null;
    if (!row || row.code !== body.otp) throw Errors.forbidden("invalid otp");
    if (row.used_at) throw Errors.forbidden("otp already used");
    if (new Date(row.expires_at).getTime() < Date.now()) throw Errors.forbidden("otp expired");
  }

  const balanceQ = await svc.from("run_coins").select("balance").eq("user_id", user.id).maybeSingle();
  const balance = (balanceQ.data?.balance as number | undefined) ?? 0;
  if (balance < voucher.cost_coins) throw Errors.conflict("insufficient balance");

  // Prefer the atomic SQL function when it exists.
  const rpc = await svc.rpc("redeem_voucher", { p_user_id: user.id, p_voucher_id: voucher.id });
  if (rpc.error && !rpc.error.message.includes("does not exist")) {
    throw Errors.internal("redeem_voucher failed", rpc.error.message);
  }

  const partner = await callPartner(voucher, user.id);

  const insert = await svc
    .from("voucher_redemptions")
    .insert({
      user_id: user.id,
      voucher_id: voucher.id,
      code: partner.code,
      expires_at: partner.expires_at,
      cost_coins: voucher.cost_coins,
    })
    .select("id")
    .single();
  if (insert.error) throw Errors.internal("redemption insert failed", insert.error.message);

  // Fallback ledger write when the RPC was absent.
  if (rpc.error) {
    await svc.from("coin_transactions").insert({
      user_id: user.id,
      amount: -voucher.cost_coins,
      reason: "redeem",
      metadata: { voucher_id: voucher.id, redemption_id: insert.data.id },
      balance_after: balance - voucher.cost_coins,
    });
    await svc
      .from("run_coins")
      .update({ balance: balance - voucher.cost_coins, updated_at: new Date().toISOString() })
      .eq("user_id", user.id);
  }

  return jsonResponse(
    {
      redemption_id: insert.data.id,
      code: partner.code,
      expires_at: partner.expires_at,
      new_balance: balance - voucher.cost_coins,
    },
    { req, status: 201 },
  );
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await redeemCoinHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
