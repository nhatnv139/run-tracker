// live-track-publish: POST { activity_id, lat, lng, ts, speed_mps?, hr? }
// Writes a sample to `live_sessions` (TTL row) so subscribers can replay the
// running session in near real time. Upserts by (activity_id) so the row
// always reflects the latest position; samples are appended to `samples` jsonb.

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { livePublishSchema, parseBody } from "@shared/validation";

const TTL_HOURS = 6;
const MAX_SAMPLES = 720; // 5s cadence * 6h.

interface ExistingSession {
  readonly samples: unknown[] | null;
  readonly user_id: string;
}

export async function livePublishHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const body = await parseBody(req, livePublishSchema);
  const svc = getServiceClient();

  const existingQ = await svc
    .from("live_sessions")
    .select("user_id, samples")
    .eq("activity_id", body.activity_id)
    .maybeSingle();
  const existing = existingQ.data as ExistingSession | null;
  if (existing && existing.user_id !== user.id) {
    throw Errors.forbidden("not owner of this live session");
  }

  const sample = {
    lat: body.lat,
    lng: body.lng,
    ts: body.ts,
    speed_mps: body.speed_mps ?? null,
    hr: body.hr ?? null,
  };
  const samples = existing?.samples ? [...existing.samples, sample] : [sample];
  if (samples.length > MAX_SAMPLES) samples.splice(0, samples.length - MAX_SAMPLES);

  const expiresAt = new Date(Date.now() + TTL_HOURS * 3600 * 1000).toISOString();
  const upsert = await svc
    .from("live_sessions")
    .upsert(
      {
        activity_id: body.activity_id,
        user_id: user.id,
        last_lat: body.lat,
        last_lng: body.lng,
        last_ts: body.ts,
        samples,
        expires_at: expiresAt,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "activity_id" },
    );
  if (upsert.error) throw Errors.internal("live_sessions upsert failed", upsert.error.message);

  return jsonResponse(
    { ok: true, samples_count: samples.length, expires_at: expiresAt },
    { req },
  );
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await livePublishHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
