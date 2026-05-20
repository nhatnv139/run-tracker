// send-push: POST { user_id, title, body, data? }
// Internal (service-role) function that fans out to every device row for the
// user via the FCM HTTP v1 / APNs endpoints (placeholder URLs).

import { serve } from "std/http/server.ts";
import { assertServiceRole } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { parseBody, sendPushSchema } from "@shared/validation";

const FCM_URL = Deno.env.get("FCM_URL") ?? "https://fcm.googleapis.com/v1/projects/runvie/messages:send";
const FCM_KEY = Deno.env.get("FCM_SERVER_KEY") ?? "";
const APNS_URL = Deno.env.get("APNS_URL") ?? "https://api.push.apple.com/3/device";
const APNS_KEY = Deno.env.get("APNS_KEY") ?? "";

interface DeviceRow {
  readonly id: string;
  readonly platform: "ios" | "android" | "watch_os" | "wear_os" | "web";
  readonly push_token: string | null;
}

interface DispatchResult {
  readonly device_id: string;
  readonly platform: string;
  readonly status: "sent" | "skipped" | "failed";
  readonly error?: string;
}

async function sendFcm(token: string, title: string, body: string, data?: Record<string, string>): Promise<void> {
  if (!FCM_KEY) return;
  const resp = await fetch(FCM_URL, {
    method: "POST",
    headers: { "content-type": "application/json", authorization: `Bearer ${FCM_KEY}` },
    body: JSON.stringify({ message: { token, notification: { title, body }, data: data ?? {} } }),
  });
  if (!resp.ok) throw new Error(`fcm ${resp.status}`);
}

async function sendApns(token: string, title: string, body: string): Promise<void> {
  if (!APNS_KEY) return;
  const resp = await fetch(`${APNS_URL}/${token}`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "apns-topic": "app.runvie.client",
      authorization: `Bearer ${APNS_KEY}`,
    },
    body: JSON.stringify({ aps: { alert: { title, body }, sound: "default" } }),
  });
  if (!resp.ok) throw new Error(`apns ${resp.status}`);
}

export async function sendPushHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");
  assertServiceRole(req);

  const body = await parseBody(req, sendPushSchema);
  const svc = getServiceClient();
  const devicesQ = await svc
    .from("devices")
    .select("id, platform, push_token")
    .eq("user_id", body.user_id);
  if (devicesQ.error) throw Errors.internal("devices fetch failed", devicesQ.error.message);

  const devices = (devicesQ.data ?? []) as DeviceRow[];
  const results: DispatchResult[] = [];
  for (const d of devices) {
    if (!d.push_token) {
      results.push({ device_id: d.id, platform: d.platform, status: "skipped" });
      continue;
    }
    try {
      if (d.platform === "ios" || d.platform === "watch_os") {
        await sendApns(d.push_token, body.title, body.body);
      } else {
        await sendFcm(d.push_token, body.title, body.body, body.data);
      }
      results.push({ device_id: d.id, platform: d.platform, status: "sent" });
    } catch (e) {
      const msg = e instanceof Error ? e.message : "unknown";
      results.push({ device_id: d.id, platform: d.platform, status: "failed", error: msg });
    }
  }

  await svc.from("push_log").insert({
    user_id: body.user_id,
    title: body.title,
    body: body.body,
    data: body.data ?? {},
    results,
  });

  return jsonResponse({ dispatched: results.length, results }, { req });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await sendPushHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
