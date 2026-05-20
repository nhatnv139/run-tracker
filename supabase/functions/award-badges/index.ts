// award-badges: POST { user_id, activity_id? }
// Delegates to the SQL criteria engine (public.award_badges_for_user) which
// evaluates all supported criteria types (single_activity, lifetime, streak,
// composite, rolling_window, seasonal, time_of_day, weather, pace, manual_event).
// Returns the codes that were newly granted.

import { serve } from "std/http/server.ts";
import { authenticate, assertSameUser, assertServiceRole } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { awardBadgesSchema, parseBody } from "@shared/validation";

export interface AwardBadgesResult {
  readonly user_id: string;
  readonly newly_earned: string[];
  readonly count: number;
}

interface EngineRow {
  readonly newly_earned?: string[];
  readonly count?: number;
}

export async function awardBadgesHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const body = await parseBody(req, awardBadgesSchema);

  // Allow either the owning user or an internal service-role caller.
  const auth = req.headers.get("x-service-key") ?? req.headers.get("X-Service-Key");
  if (auth) {
    assertServiceRole(req);
  } else {
    const user = await authenticate(req);
    assertSameUser(user, body.user_id);
  }

  const svc = getServiceClient();
  const rpc = await svc.rpc("award_badges_for_user", {
    p_user_id: body.user_id,
    p_activity_id: body.activity_id ?? null,
  });
  if (rpc.error) throw Errors.internal("award_badges_for_user failed", rpc.error.message);

  // The new engine returns jsonb { newly_earned, count }; the legacy version
  // returns setof text. Normalise both shapes.
  let earned: string[] = [];
  let count = 0;
  if (Array.isArray(rpc.data)) {
    earned = rpc.data as string[];
    count = earned.length;
  } else if (rpc.data && typeof rpc.data === "object") {
    const row = rpc.data as EngineRow;
    earned = Array.isArray(row.newly_earned) ? row.newly_earned : [];
    count = typeof row.count === "number" ? row.count : earned.length;
  }

  const result: AwardBadgesResult = {
    user_id: body.user_id,
    newly_earned: earned,
    count,
  };
  return jsonResponse(result, { req });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await awardBadgesHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
