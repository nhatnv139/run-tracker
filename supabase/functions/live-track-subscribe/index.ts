// live-track-subscribe: GET ?activity_id=<uuid>
// Streams the live session as Server-Sent Events. Polls the row every 3s and
// emits a `position` event whenever last_ts advances. Caller must be the owner
// or follow the owner (private session check via RLS-friendly query).

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { corsHeaders, handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { getServiceClient } from "@shared/supabase-client";
import { uuid } from "@shared/validation";

const POLL_MS = 3000;
const MAX_LIFETIME_MS = 1000 * 60 * 30; // 30 min cap per connection.

interface LiveRow {
  readonly user_id: string;
  readonly last_lat: number;
  readonly last_lng: number;
  readonly last_ts: string;
  readonly expires_at: string;
}

async function canSubscribe(viewerId: string, ownerId: string): Promise<boolean> {
  if (viewerId === ownerId) return true;
  const svc = getServiceClient();
  const f = await svc
    .from("follows")
    .select("follower_id")
    .eq("follower_id", viewerId)
    .eq("followee_id", ownerId)
    .maybeSingle();
  return !!f.data;
}

export async function liveSubscribeHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "GET") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const url = new URL(req.url);
  const idParam = url.searchParams.get("activity_id");
  const activityId = uuid.safeParse(idParam);
  if (!activityId.success) throw Errors.badRequest("invalid activity_id");

  const svc = getServiceClient();
  const initial = await svc
    .from("live_sessions")
    .select("user_id, last_lat, last_lng, last_ts, expires_at")
    .eq("activity_id", activityId.data)
    .maybeSingle();
  if (initial.error) throw Errors.internal("live_sessions query failed", initial.error.message);
  if (!initial.data) throw Errors.notFound("live session not found");
  const session = initial.data as LiveRow;
  if (!(await canSubscribe(user.id, session.user_id))) {
    throw Errors.forbidden("not allowed to view this session");
  }

  const encoder = new TextEncoder();
  let lastTs = "";
  const start = Date.now();
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      const write = (event: string, data: unknown): void => {
        controller.enqueue(encoder.encode(`event: ${event}\n`));
        controller.enqueue(encoder.encode(`data: ${JSON.stringify(data)}\n\n`));
      };
      write("position", {
        lat: session.last_lat,
        lng: session.last_lng,
        ts: session.last_ts,
      });
      lastTs = session.last_ts;

      const closed = req.signal;
      while (!closed.aborted && Date.now() - start < MAX_LIFETIME_MS) {
        await new Promise((r) => setTimeout(r, POLL_MS));
        if (closed.aborted) break;
        const q = await svc
          .from("live_sessions")
          .select("last_lat, last_lng, last_ts, expires_at")
          .eq("activity_id", activityId.data)
          .maybeSingle();
        if (q.error) {
          write("error", { message: q.error.message });
          continue;
        }
        if (!q.data) {
          write("end", { reason: "session_ended" });
          break;
        }
        const row = q.data as Omit<LiveRow, "user_id">;
        if (new Date(row.expires_at).getTime() < Date.now()) {
          write("end", { reason: "expired" });
          break;
        }
        if (row.last_ts !== lastTs) {
          write("position", { lat: row.last_lat, lng: row.last_lng, ts: row.last_ts });
          lastTs = row.last_ts;
        } else {
          write("ping", { at: new Date().toISOString() });
        }
      }
      controller.close();
    },
  });

  const origin = req.headers.get("origin");
  return new Response(stream, {
    status: 200,
    headers: {
      ...corsHeaders({ origin }),
      "content-type": "text/event-stream; charset=utf-8",
      "cache-control": "no-cache, no-transform",
    },
  });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await liveSubscribeHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
