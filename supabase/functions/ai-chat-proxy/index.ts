// ai-chat-proxy: POST { message, history }
// Streams Server-Sent Events from the AI Coach `/v1/chat/stream` endpoint to the
// caller. Injects user context (profile, recent activities) into the system
// prompt and applies a per-user rate limit (free: 20/month, paid: 100/day).

import { serve } from "std/http/server.ts";
import { authenticate, type AuthedUser } from "@shared/auth";
import { corsHeaders, handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { getServiceClient } from "@shared/supabase-client";
import { aiChatSchema, parseBody } from "@shared/validation";

const AI_COACH_URL = Deno.env.get("AI_COACH_URL") ?? "https://ai-coach.runvie.app";
const AI_COACH_KEY = Deno.env.get("AI_COACH_API_KEY") ?? "";

interface UserContext {
  readonly display_name: string;
  readonly level: string;
  readonly goal: string | null;
  readonly recent_km: number;
  readonly current_streak: number;
}

async function loadContext(user: AuthedUser): Promise<UserContext> {
  const svc = getServiceClient();
  const [profile, recent, streak] = await Promise.all([
    svc.from("profiles").select("display_name, level, goal").eq("id", user.id).maybeSingle(),
    svc
      .from("activities")
      .select("distance_m")
      .eq("user_id", user.id)
      .gte("started_at", new Date(Date.now() - 7 * 24 * 3600 * 1000).toISOString()),
    svc.from("streaks").select("current_days").eq("user_id", user.id).maybeSingle(),
  ]);
  const totalM = ((recent.data as { distance_m: number }[] | null) ?? []).reduce(
    (s, r) => s + (r.distance_m ?? 0),
    0,
  );
  return {
    display_name: (profile.data?.display_name as string | undefined) ?? "runner",
    level: (profile.data?.level as string | undefined) ?? "beginner",
    goal: (profile.data?.goal as string | null | undefined) ?? null,
    recent_km: Math.round(totalM / 100) / 10,
    current_streak: (streak.data?.current_days as number | undefined) ?? 0,
  };
}

interface RateLimitDecision {
  readonly allowed: boolean;
  readonly remaining: number;
  readonly resets_at: string;
}

async function checkRateLimit(userId: string): Promise<RateLimitDecision> {
  const svc = getServiceClient();
  const tierQ = await svc.from("subscriptions").select("tier").eq("user_id", userId).maybeSingle();
  const tier = (tierQ.data?.tier as string | undefined) ?? "free";
  const now = new Date();
  let windowStart: Date;
  let limit: number;
  if (tier === "free") {
    windowStart = new Date(now.getFullYear(), now.getMonth(), 1);
    limit = 20;
  } else {
    windowStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    limit = 100;
  }
  const usage = await svc
    .from("ai_chat_usage")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .gte("created_at", windowStart.toISOString());
  const used = usage.count ?? 0;
  const resetsAt = tier === "free"
    ? new Date(now.getFullYear(), now.getMonth() + 1, 1)
    : new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
  return { allowed: used < limit, remaining: Math.max(0, limit - used - 1), resets_at: resetsAt.toISOString() };
}

export async function aiChatProxyHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const body = await parseBody(req, aiChatSchema);

  const decision = await checkRateLimit(user.id);
  if (!decision.allowed) {
    throw Errors.rateLimited("ai chat quota exhausted", { resets_at: decision.resets_at });
  }

  const context = await loadContext(user);
  const system = [
    "You are RunVie's AI running coach. Be concise, encouraging, and safety-aware.",
    `User: ${context.display_name} (${context.level}).`,
    context.goal ? `Goal: ${context.goal}.` : "",
    `Last 7 days: ${context.recent_km} km. Current streak: ${context.current_streak} day(s).`,
  ].filter(Boolean).join(" ");

  if (!AI_COACH_KEY) throw Errors.internal("ai coach not configured");

  const upstream = await fetch(`${AI_COACH_URL}/v1/chat/stream`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${AI_COACH_KEY}`,
      accept: "text/event-stream",
    },
    body: JSON.stringify({
      user_id: user.id,
      system,
      history: body.history,
      message: body.message,
    }),
  });
  if (!upstream.ok || !upstream.body) {
    throw Errors.upstream(`ai coach ${upstream.status}`);
  }

  // Log usage (fire-and-forget).
  void getServiceClient().from("ai_chat_usage").insert({
    user_id: user.id,
    prompt_chars: body.message.length,
  });

  const origin = req.headers.get("origin");
  return new Response(upstream.body, {
    status: 200,
    headers: {
      ...corsHeaders({ origin }),
      "content-type": "text/event-stream; charset=utf-8",
      "cache-control": "no-cache, no-transform",
      "x-ratelimit-remaining": String(decision.remaining),
      "x-ratelimit-reset": decision.resets_at,
    },
  });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await aiChatProxyHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
