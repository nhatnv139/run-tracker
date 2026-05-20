// leaderboard: GET ?scope=global|country|city|friends&period=weekly|monthly
// Reads from the per-period materialized view, returns the top 100 plus the
// caller's own rank (which may fall outside the top 100).

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";

type Scope = "global" | "country" | "city" | "friends";
type Period = "weekly" | "monthly";

const TOP_N = 100;

interface BoardRow {
  readonly user_id: string;
  readonly username: string;
  readonly display_name: string;
  readonly avatar_url: string | null;
  readonly distance_m: number;
  readonly rank: number;
}

function parseScope(value: string | null): Scope {
  if (value === "country" || value === "city" || value === "friends") return value;
  return "global";
}

function parsePeriod(value: string | null): Period {
  return value === "monthly" ? "monthly" : "weekly";
}

function viewName(period: Period): string {
  return period === "monthly" ? "leaderboard_monthly" : "leaderboard_weekly";
}

export async function leaderboardHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "GET") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const url = new URL(req.url);
  const scope = parseScope(url.searchParams.get("scope"));
  const period = parsePeriod(url.searchParams.get("period"));

  const svc = getServiceClient();
  const profile = await svc
    .from("profiles")
    .select("country, city")
    .eq("id", user.id)
    .maybeSingle();
  const country = (profile.data?.country as string | null | undefined) ?? null;
  const city = (profile.data?.city as string | null | undefined) ?? null;

  let query = svc
    .from(viewName(period))
    .select("user_id, username, display_name, avatar_url, distance_m, rank, country, city")
    .order("rank", { ascending: true })
    .limit(TOP_N);

  if (scope === "country") {
    if (!country) throw Errors.badRequest("profile country not set");
    query = query.eq("country", country);
  } else if (scope === "city") {
    if (!city) throw Errors.badRequest("profile city not set");
    query = query.eq("city", city);
  } else if (scope === "friends") {
    const followsQ = await svc
      .from("follows")
      .select("followee_id")
      .eq("follower_id", user.id);
    const ids = ((followsQ.data as { followee_id: string }[] | null) ?? []).map((r) => r.followee_id);
    ids.push(user.id);
    query = query.in("user_id", ids);
  }

  const board = await query;
  if (board.error) throw Errors.internal("leaderboard query failed", board.error.message);
  const rows: BoardRow[] = ((board.data ?? []) as BoardRow[]).map((r, i) => ({ ...r, rank: i + 1 }));

  // User's own rank may not be in the top-100 slice; compute separately.
  let myRank: number | null = null;
  let myDistance = 0;
  const inSlice = rows.find((r) => r.user_id === user.id);
  if (inSlice) {
    myRank = inSlice.rank;
    myDistance = inSlice.distance_m;
  } else {
    const meQ = await svc
      .from(viewName(period))
      .select("rank, distance_m")
      .eq("user_id", user.id)
      .maybeSingle();
    if (meQ.data) {
      myRank = meQ.data.rank as number;
      myDistance = meQ.data.distance_m as number;
    }
  }

  return jsonResponse(
    {
      scope,
      period,
      top: rows,
      me: { user_id: user.id, rank: myRank, distance_m: myDistance },
    },
    { req },
  );
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await leaderboardHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
