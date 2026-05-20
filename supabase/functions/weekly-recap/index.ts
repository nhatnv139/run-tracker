// weekly-recap: GET (cron Sun 19:00 ICT) | POST { user_id? }
// Iterates over active users, computes the last-7-day recap, persists it, and
// pings the send-push function. When invoked with a user_id, only that user is
// processed (handy for backfills and tests).

import { serve } from "std/http/server.ts";
import { assertServiceRole } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";

interface RecapNumbers {
  readonly distance_m: number;
  readonly duration_s: number;
  readonly sessions: number;
  readonly elevation_gain_m: number;
}

interface Recap extends RecapNumbers {
  readonly user_id: string;
  readonly week_start: string;
  readonly week_end: string;
}

function isoWeekRange(now: Date): { start: Date; end: Date } {
  const end = new Date(now);
  const start = new Date(now.getTime() - 7 * 24 * 3600 * 1000);
  return { start, end };
}

async function computeRecap(userId: string, start: Date, end: Date): Promise<RecapNumbers> {
  const svc = getServiceClient();
  const q = await svc
    .from("activities")
    .select("distance_m, duration_s, elevation_gain_m")
    .eq("user_id", userId)
    .gte("started_at", start.toISOString())
    .lt("started_at", end.toISOString());
  if (q.error) throw Errors.internal("activities query failed", q.error.message);
  const rows = (q.data ?? []) as { distance_m: number; duration_s: number; elevation_gain_m: number }[];
  return {
    distance_m: rows.reduce((s, r) => s + (r.distance_m ?? 0), 0),
    duration_s: rows.reduce((s, r) => s + (r.duration_s ?? 0), 0),
    elevation_gain_m: rows.reduce((s, r) => s + (r.elevation_gain_m ?? 0), 0),
    sessions: rows.length,
  };
}

async function processUser(userId: string, start: Date, end: Date): Promise<Recap | null> {
  const numbers = await computeRecap(userId, start, end);
  if (numbers.sessions === 0) return null;
  const svc = getServiceClient();
  await svc.from("weekly_recaps").insert({
    user_id: userId,
    week_start: start.toISOString().slice(0, 10),
    week_end: end.toISOString().slice(0, 10),
    distance_m: numbers.distance_m,
    duration_s: numbers.duration_s,
    sessions: numbers.sessions,
    elevation_gain_m: numbers.elevation_gain_m,
  });

  const km = (numbers.distance_m / 1000).toFixed(1);
  const title = "RunVie weekly recap";
  const body = `${numbers.sessions} sessions, ${km} km this week. Keep it up!`;

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (supabaseUrl && serviceKey) {
    await fetch(`${supabaseUrl}/functions/v1/send-push`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-service-key": serviceKey,
        authorization: `Bearer ${serviceKey}`,
      },
      body: JSON.stringify({ user_id: userId, title, body }),
    }).catch((e) => console.error("send-push failed", e instanceof Error ? e.message : e));
  }

  return {
    user_id: userId,
    week_start: start.toISOString().slice(0, 10),
    week_end: end.toISOString().slice(0, 10),
    ...numbers,
  };
}

export async function weeklyRecapHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  assertServiceRole(req);

  const { start, end } = isoWeekRange(new Date());
  let userIds: string[];
  if (req.method === "POST") {
    const raw = (await req.json().catch(() => ({}))) as { user_id?: string };
    if (raw.user_id) {
      userIds = [raw.user_id];
    } else {
      userIds = [];
    }
  } else if (req.method !== "GET") {
    throw Errors.badRequest("method not allowed");
  } else {
    userIds = [];
  }

  if (userIds.length === 0) {
    const svc = getServiceClient();
    const active = await svc
      .from("activities")
      .select("user_id")
      .gte("started_at", start.toISOString())
      .lt("started_at", end.toISOString());
    if (active.error) throw Errors.internal("active users query failed", active.error.message);
    const set = new Set<string>();
    for (const r of (active.data ?? []) as { user_id: string }[]) set.add(r.user_id);
    userIds = [...set];
  }

  const recaps: Recap[] = [];
  for (const id of userIds) {
    try {
      const r = await processUser(id, start, end);
      if (r) recaps.push(r);
    } catch (e) {
      console.error("weekly recap failed", id, e instanceof Error ? e.message : e);
    }
  }

  return jsonResponse({ processed: recaps.length, recaps }, { req });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await weeklyRecapHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
