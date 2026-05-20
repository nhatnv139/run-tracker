// device-register: POST { platform, push_token, app_version?, os_version? }
// Upserts a row in `devices` keyed by (user_id, push_token). Updates last_seen
// on every call so we can prune stale tokens nightly.

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { deviceRegisterSchema, parseBody } from "@shared/validation";

export async function deviceRegisterHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const body = await parseBody(req, deviceRegisterSchema);
  const svc = getServiceClient();
  const now = new Date().toISOString();

  const upsert = await svc
    .from("devices")
    .upsert(
      {
        user_id: user.id,
        platform: body.platform,
        push_token: body.push_token,
        app_version: body.app_version ?? null,
        os_version: body.os_version ?? null,
        last_seen: now,
        updated_at: now,
      },
      { onConflict: "user_id,push_token" },
    )
    .select("id")
    .single();
  if (upsert.error || !upsert.data) {
    throw Errors.internal("devices upsert failed", upsert.error?.message);
  }
  return jsonResponse({ device_id: upsert.data.id, last_seen: now }, { req, status: 201 });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await deviceRegisterHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
