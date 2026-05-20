// recalc-streak: POST { user_id? }
// Recomputes the user's current and longest streaks by delegating to the
// public.recalc_streak RPC. Caller must be the user (or service role).

import { serve } from "std/http/server.ts";
import { authenticate, assertSameUser, assertServiceRole } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { parseBody, recalcStreakSchema } from "@shared/validation";

export interface RecalcStreakResult {
  readonly user_id: string;
  readonly current_days: number;
  readonly longest_days: number;
}

export async function recalcStreakHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const body = await parseBody(req, recalcStreakSchema);
  const serviceHeader = req.headers.get("x-service-key") ?? req.headers.get("X-Service-Key");
  let userId: string;
  if (serviceHeader) {
    assertServiceRole(req);
    if (!body.user_id) throw Errors.badRequest("user_id required for service call");
    userId = body.user_id;
  } else {
    const user = await authenticate(req);
    userId = body.user_id ?? user.id;
    assertSameUser(user, userId);
  }

  const svc = getServiceClient();
  const rpc = await svc.rpc("recalc_streak", { p_user_id: userId });
  if (rpc.error) throw Errors.internal("recalc_streak failed", rpc.error.message);

  const row = Array.isArray(rpc.data) && rpc.data.length > 0
    ? (rpc.data[0] as { current_days: number; longest_days: number })
    : { current_days: 0, longest_days: 0 };

  const result: RecalcStreakResult = {
    user_id: userId,
    current_days: row.current_days,
    longest_days: row.longest_days,
  };
  return jsonResponse(result, { req });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await recalcStreakHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
