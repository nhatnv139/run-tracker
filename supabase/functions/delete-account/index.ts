// delete-account: POST { confirm: true }
// GDPR / Vietnam PDPA compliance hard delete. Removes the auth.users row, which
// cascades through every owning table (profiles, activities, badges, streaks,
// etc.) via FK on delete cascade. Best-effort cleanup of side-tables that hold
// orphaned references (push tokens, voucher redemption codes).

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { deleteAccountSchema, parseBody } from "@shared/validation";

const ORPHAN_TABLES: readonly string[] = [
  "ai_chat_usage",
  "anomaly_flags",
  "voucher_redemptions",
  "push_log",
  "live_sessions",
  "routes",
];

export async function deleteAccountHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  await parseBody(req, deleteAccountSchema);

  const svc = getServiceClient();

  // Best-effort cleanup. We ignore missing-table errors so dev envs (which may
  // be missing optional feature tables) still complete the deletion.
  for (const table of ORPHAN_TABLES) {
    const del = await svc.from(table).delete().eq("user_id", user.id);
    if (del.error && !del.error.message.includes("does not exist")) {
      console.error("orphan delete failed", table, del.error.message);
    }
  }

  // Auth admin delete cascades through profiles (FK references auth.users).
  const adminDelete = await svc.auth.admin.deleteUser(user.id);
  if (adminDelete.error) {
    throw Errors.internal("auth admin deleteUser failed", adminDelete.error.message);
  }

  return jsonResponse({ ok: true, deleted_user_id: user.id }, { req });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await deleteAccountHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
