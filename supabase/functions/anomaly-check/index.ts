// anomaly-check: POST { activity_id }
// Detects GPS spoofing / unrealistic samples. Rules:
//   1. Sustained velocity > 30 km/h (i.e. > 8.33 m/s) for >= 30 s.
//   2. A single "teleport" jump > 500 m between consecutive samples.
// If either is triggered, marks activities.verified = false and writes an
// `anomaly_flags` row with the detection details.

import { serve } from "std/http/server.ts";
import { authenticate, assertSameUser, assertServiceRole } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { anomalyCheckSchema, parseBody } from "@shared/validation";

const MAX_SUSTAINED_MPS = 8.33;
const SUSTAINED_S = 30;
const TELEPORT_M = 500;

interface PointRow {
  readonly sequence: number;
  readonly ts: string;
  readonly point: string; // WKT or GeoJSON depending on settings
  readonly speed_mps: number | null;
}

interface DecodedPoint {
  readonly seq: number;
  readonly t: number;
  readonly lat: number;
  readonly lng: number;
  readonly speed: number | null;
}

function parsePoint(point: string): { lat: number; lng: number } | null {
  // Accept "POINT(lng lat)" or "SRID=4326;POINT(lng lat)" or GeoJSON-like strings.
  const m = /POINT\(([-\d\.]+)\s+([-\d\.]+)\)/.exec(point);
  if (m) return { lng: parseFloat(m[1]), lat: parseFloat(m[2]) };
  try {
    const j = JSON.parse(point) as { coordinates?: [number, number] };
    if (j?.coordinates) return { lng: j.coordinates[0], lat: j.coordinates[1] };
  } catch (_e) {
    // ignore
  }
  return null;
}

function haversine(a: DecodedPoint, b: DecodedPoint): number {
  const R = 6371000;
  const toRad = (d: number): number => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const h = Math.sin(dLat / 2) ** 2 +
    Math.sin(dLng / 2) ** 2 * Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat));
  return 2 * R * Math.asin(Math.min(1, Math.sqrt(h)));
}

export interface AnomalyResult {
  readonly suspicious: boolean;
  readonly reasons: string[];
  readonly teleport_count: number;
  readonly sustained_speed_s: number;
}

export function detectAnomalies(points: DecodedPoint[]): AnomalyResult {
  const reasons: string[] = [];
  let teleports = 0;
  let sustained = 0;
  let currentRun = 0;

  for (let i = 1; i < points.length; i++) {
    const prev = points[i - 1];
    const cur = points[i];
    const dt = Math.max(0.001, (cur.t - prev.t) / 1000);
    const d = haversine(prev, cur);
    const speed = cur.speed ?? d / dt;
    if (d > TELEPORT_M) teleports++;
    if (speed > MAX_SUSTAINED_MPS) {
      currentRun += dt;
      sustained = Math.max(sustained, currentRun);
    } else {
      currentRun = 0;
    }
  }

  if (teleports > 0) reasons.push(`teleport_jumps=${teleports}`);
  if (sustained >= SUSTAINED_S) reasons.push(`sustained_overspeed_s=${Math.round(sustained)}`);
  return {
    suspicious: reasons.length > 0,
    reasons,
    teleport_count: teleports,
    sustained_speed_s: Math.round(sustained),
  };
}

export async function anomalyCheckHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const body = await parseBody(req, anomalyCheckSchema);
  const svc = getServiceClient();

  const actQ = await svc.from("activities").select("user_id").eq("id", body.activity_id).maybeSingle();
  if (actQ.error) throw Errors.internal("activity lookup failed", actQ.error.message);
  if (!actQ.data) throw Errors.notFound("activity not found");
  const ownerId = actQ.data.user_id as string;

  const serviceHeader = req.headers.get("x-service-key") ?? req.headers.get("X-Service-Key");
  if (serviceHeader) {
    assertServiceRole(req);
  } else {
    const user = await authenticate(req);
    assertSameUser(user, ownerId);
  }

  const pointsQ = await svc
    .from("activity_points")
    .select("sequence, ts, point, speed_mps")
    .eq("activity_id", body.activity_id)
    .order("sequence", { ascending: true });
  if (pointsQ.error) throw Errors.internal("points fetch failed", pointsQ.error.message);

  const decoded: DecodedPoint[] = ((pointsQ.data ?? []) as PointRow[]).flatMap((r) => {
    const ll = parsePoint(r.point);
    if (!ll) return [];
    return [{ seq: r.sequence, t: new Date(r.ts).getTime(), lat: ll.lat, lng: ll.lng, speed: r.speed_mps }];
  });

  const result = detectAnomalies(decoded);

  if (result.suspicious) {
    await svc.from("activities").update({ verified: false }).eq("id", body.activity_id);
    await svc.from("anomaly_flags").insert({
      activity_id: body.activity_id,
      user_id: ownerId,
      reasons: result.reasons,
      teleport_count: result.teleport_count,
      sustained_speed_s: result.sustained_speed_s,
    });
  }

  return jsonResponse(result, { req });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await anomalyCheckHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
