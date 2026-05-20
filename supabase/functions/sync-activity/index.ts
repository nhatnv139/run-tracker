// sync-activity: POST a finalized activity payload from the app.
// Inserts activities + activity_points (downsampled) + activity_splits,
// then triggers award_coins_for_activity, award_badges_for_user, recalc_streak.

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import {
  parseBody,
  type PointSample,
  type Split,
  syncActivitySchema,
  type SyncActivityPayload,
} from "@shared/validation";

const MAX_POINTS = 200;

/** Reservoir-style stride downsample preserving first and last. */
export function downsamplePoints(points: PointSample[], max = MAX_POINTS): PointSample[] {
  if (points.length <= max) return points;
  const out: PointSample[] = [];
  const stride = (points.length - 1) / (max - 1);
  for (let i = 0; i < max; i++) {
    const idx = Math.min(points.length - 1, Math.round(i * stride));
    out.push(points[idx]);
  }
  return out;
}

/** Build PostGIS-friendly WKT for a lat/lng pair. */
export function pointWkt(lat: number, lng: number): string {
  return `SRID=4326;POINT(${lng} ${lat})`;
}

export interface SyncResult {
  readonly activity_id: string;
  readonly coins_earned: number;
  readonly earned_badges: string[];
  readonly streak: { current_days: number; longest_days: number };
}

export async function syncActivityHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const body: SyncActivityPayload = await parseBody(req, syncActivitySchema);
  if (new Date(body.ended_at).getTime() < new Date(body.started_at).getTime()) {
    throw Errors.badRequest("ended_at must be >= started_at");
  }

  const svc = getServiceClient();
  const startWkt = body.start_point
    ? pointWkt(body.start_point.lat, body.start_point.lng)
    : null;
  const endWkt = body.end_point ? pointWkt(body.end_point.lat, body.end_point.lng) : null;

  const insert = await svc
    .from("activities")
    .insert({
      user_id: user.id,
      type: body.type,
      source: body.source,
      started_at: body.started_at,
      ended_at: body.ended_at,
      duration_s: body.duration_s,
      distance_m: body.distance_m,
      calories: body.calories ?? null,
      avg_pace_s_per_km: body.avg_pace_s_per_km ?? null,
      avg_hr: body.avg_hr ?? null,
      max_hr: body.max_hr ?? null,
      elevation_gain_m: body.elevation_gain_m,
      elevation_loss_m: body.elevation_loss_m,
      polyline: body.polyline ?? null,
      start_point: startWkt,
      end_point: endWkt,
      is_indoor: body.is_indoor,
      weather: body.weather ?? null,
      verified: true,
    })
    .select("id")
    .single();

  if (insert.error || !insert.data) {
    throw Errors.internal("failed to insert activity", insert.error?.message);
  }
  const activityId = insert.data.id as string;

  // Downsample + insert points.
  const samples: PointSample[] = downsamplePoints(body.points, MAX_POINTS);
  if (samples.length > 0) {
    const rows = samples.map((p) => ({
      activity_id: activityId,
      sequence: p.sequence,
      ts: p.ts,
      point: pointWkt(p.lat, p.lng),
      elevation_m: p.elevation_m ?? null,
      speed_mps: p.speed_mps ?? null,
      hr: p.hr ?? null,
      cadence: p.cadence ?? null,
    }));
    const { error } = await svc.from("activity_points").insert(rows);
    if (error) console.error("activity_points insert failed", error.message);
  }

  // Insert splits.
  if (body.splits.length > 0) {
    const splitRows = body.splits.map((s: Split) => ({
      activity_id: activityId,
      km_index: s.km_index,
      duration_s: s.duration_s,
      pace_s_per_km: s.pace_s_per_km,
      hr_avg: s.hr_avg ?? null,
      elevation_gain: s.elevation_gain ?? 0,
    }));
    const { error } = await svc.from("activity_splits").insert(splitRows);
    if (error) console.error("activity_splits insert failed", error.message);
  }

  // Downstream RPCs.
  const coinsRpc = await svc.rpc("award_coins_for_activity", { p_activity_id: activityId });
  const coinsEarned = typeof coinsRpc.data === "number" ? coinsRpc.data : 0;

  const streakRpc = await svc.rpc("recalc_streak", { p_user_id: user.id });
  const streakRow = Array.isArray(streakRpc.data) && streakRpc.data.length > 0
    ? (streakRpc.data[0] as { current_days: number; longest_days: number })
    : { current_days: 0, longest_days: 0 };

  const badgesRpc = await svc.rpc("award_badges_for_user", {
    p_user_id: user.id,
    p_activity_id: activityId,
  });
  const earnedBadges: string[] = Array.isArray(badgesRpc.data)
    ? (badgesRpc.data as string[])
    : [];

  const result: SyncResult = {
    activity_id: activityId,
    coins_earned: coinsEarned,
    earned_badges: earnedBadges,
    streak: streakRow,
  };
  return jsonResponse(result, { req, status: 201 });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await syncActivityHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
