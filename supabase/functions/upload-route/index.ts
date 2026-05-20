// upload-route: POST { name, polyline, distance_m, start_city?, is_public? }
// Stores a polyline-encoded route in the `routes` table for community discovery.
// Privacy: trim the first and last 200 m off the polyline before persisting.

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { parseBody, uploadRouteSchema } from "@shared/validation";

const PRIVACY_TRIM_M = 200;

interface LatLng {
  readonly lat: number;
  readonly lng: number;
}

/** Google polyline algorithm: decode an encoded string to an array of points. */
export function decodePolyline(encoded: string): LatLng[] {
  const out: LatLng[] = [];
  let index = 0;
  let lat = 0;
  let lng = 0;
  while (index < encoded.length) {
    let result = 0;
    let shift = 0;
    let b: number;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dlat = (result & 1) !== 0 ? ~(result >> 1) : result >> 1;
    lat += dlat;
    result = 0;
    shift = 0;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dlng = (result & 1) !== 0 ? ~(result >> 1) : result >> 1;
    lng += dlng;
    out.push({ lat: lat / 1e5, lng: lng / 1e5 });
  }
  return out;
}

export function encodePolyline(points: LatLng[]): string {
  let lat = 0;
  let lng = 0;
  let out = "";
  const enc = (v: number): string => {
    let n = v < 0 ? ~(v << 1) : v << 1;
    let s = "";
    while (n >= 0x20) {
      s += String.fromCharCode((0x20 | (n & 0x1f)) + 63);
      n >>= 5;
    }
    s += String.fromCharCode(n + 63);
    return s;
  };
  for (const p of points) {
    const ilat = Math.round(p.lat * 1e5);
    const ilng = Math.round(p.lng * 1e5);
    out += enc(ilat - lat);
    out += enc(ilng - lng);
    lat = ilat;
    lng = ilng;
  }
  return out;
}

function haversineMeters(a: LatLng, b: LatLng): number {
  const R = 6371000;
  const toRad = (d: number): number => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h = Math.sin(dLat / 2) ** 2 + Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
  return 2 * R * Math.asin(Math.min(1, Math.sqrt(h)));
}

/** Drop samples until the cumulative distance from each end exceeds the trim. */
export function trimEnds(points: LatLng[], trimM = PRIVACY_TRIM_M): LatLng[] {
  if (points.length < 4) return points;
  let head = 0;
  let acc = 0;
  while (head < points.length - 1 && acc < trimM) {
    acc += haversineMeters(points[head], points[head + 1]);
    head++;
  }
  let tail = points.length - 1;
  acc = 0;
  while (tail > head && acc < trimM) {
    acc += haversineMeters(points[tail], points[tail - 1]);
    tail--;
  }
  return points.slice(head, tail + 1);
}

export async function uploadRouteHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const body = await parseBody(req, uploadRouteSchema);

  const decoded = decodePolyline(body.polyline);
  if (decoded.length < 4) throw Errors.badRequest("polyline too short");
  const trimmed = trimEnds(decoded);
  if (trimmed.length < 2) throw Errors.badRequest("polyline too short after privacy trim");

  const svc = getServiceClient();
  const insert = await svc
    .from("routes")
    .insert({
      user_id: user.id,
      name: body.name,
      polyline: encodePolyline(trimmed),
      distance_m: body.distance_m,
      start_city: body.start_city ?? null,
      is_public: body.is_public,
      point_count: trimmed.length,
    })
    .select("id")
    .single();
  if (insert.error || !insert.data) {
    throw Errors.internal("route insert failed", insert.error?.message);
  }
  return jsonResponse(
    { route_id: insert.data.id, point_count: trimmed.length },
    { req, status: 201 },
  );
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await uploadRouteHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
