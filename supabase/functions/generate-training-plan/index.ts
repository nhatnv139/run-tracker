// generate-training-plan: POST { race_distance, target_pace_s_per_km?, weeks, start_date }
// Calls the AI Coach `/v1/training-plan` endpoint, persists the resulting plan +
// per-day workouts, and returns the plan id. Falls back to a deterministic
// template when the AI service is unavailable so the app remains usable.

import { serve } from "std/http/server.ts";
import { authenticate } from "@shared/auth";
import { handlePreflight } from "@shared/cors";
import { errorResponse, Errors } from "@shared/errors";
import { jsonResponse } from "@shared/json";
import { getServiceClient } from "@shared/supabase-client";
import { parseBody, trainingPlanSchema } from "@shared/validation";

const AI_COACH_URL = Deno.env.get("AI_COACH_URL") ?? "https://ai-coach.runvie.app";
const AI_COACH_KEY = Deno.env.get("AI_COACH_API_KEY") ?? "";

type WorkoutType = "easy" | "long" | "tempo" | "interval" | "rest" | "cross";

interface AiWorkout {
  readonly day_offset: number;
  readonly workout_type: WorkoutType;
  readonly description_en?: string;
  readonly description_vi?: string;
  readonly target_distance_m?: number;
  readonly target_duration_s?: number;
  readonly target_pace_s_per_km?: number;
  readonly target_hr_zone?: number;
}

interface AiPlanResponse {
  readonly workouts: AiWorkout[];
}

function fallbackPlan(weeks: number): AiWorkout[] {
  // Simple Tue/Thu easy, Sat long, Sun rest, rest other days.
  const out: AiWorkout[] = [];
  for (let w = 0; w < weeks; w++) {
    for (let d = 0; d < 7; d++) {
      const offset = w * 7 + d;
      let type: WorkoutType = "rest";
      let targetM: number | undefined;
      if (d === 1 || d === 3) {
        type = "easy";
        targetM = 5000;
      } else if (d === 5) {
        type = "long";
        targetM = 8000 + w * 1000;
      } else if (d === 6) {
        type = "cross";
      }
      out.push({ day_offset: offset, workout_type: type, target_distance_m: targetM });
    }
  }
  return out;
}

async function fetchAiPlan(payload: unknown): Promise<AiWorkout[]> {
  if (!AI_COACH_KEY) {
    console.warn("AI_COACH_API_KEY missing; using fallback plan");
    const parsed = payload as { weeks: number };
    return fallbackPlan(parsed.weeks);
  }
  try {
    const resp = await fetch(`${AI_COACH_URL}/v1/training-plan`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${AI_COACH_KEY}`,
      },
      body: JSON.stringify(payload),
    });
    if (!resp.ok) throw Errors.upstream(`ai coach ${resp.status}`);
    const data = (await resp.json()) as AiPlanResponse;
    if (!data?.workouts || !Array.isArray(data.workouts)) {
      throw Errors.upstream("ai coach returned malformed plan");
    }
    return data.workouts;
  } catch (e) {
    console.error("ai coach failed, using fallback", e instanceof Error ? e.message : e);
    const parsed = payload as { weeks: number };
    return fallbackPlan(parsed.weeks);
  }
}

export async function generateTrainingPlanHandler(req: Request): Promise<Response> {
  const pre = handlePreflight(req);
  if (pre) return pre;
  if (req.method !== "POST") throw Errors.badRequest("method not allowed");

  const user = await authenticate(req);
  const body = await parseBody(req, trainingPlanSchema);

  const start = new Date(`${body.start_date}T00:00:00Z`);
  const end = new Date(start.getTime() + body.weeks * 7 * 24 * 3600 * 1000);
  const endDate = end.toISOString().slice(0, 10);

  const workouts = await fetchAiPlan({
    user_id: user.id,
    race_distance: body.race_distance,
    target_pace_s_per_km: body.target_pace_s_per_km,
    weeks: body.weeks,
    start_date: body.start_date,
  });

  const svc = getServiceClient();
  const planInsert = await svc
    .from("training_plans")
    .insert({
      user_id: user.id,
      race_distance: body.race_distance,
      weeks: body.weeks,
      target_pace_s_per_km: body.target_pace_s_per_km ?? null,
      start_date: body.start_date,
      end_date: endDate,
      source: AI_COACH_KEY ? "ai_generated" : "template",
      status: "active",
    })
    .select("id")
    .single();
  if (planInsert.error || !planInsert.data) {
    throw Errors.internal("training_plans insert failed", planInsert.error?.message);
  }
  const planId = planInsert.data.id as string;

  const workoutRows = workouts.map((w) => ({
    plan_id: planId,
    day_offset: w.day_offset,
    workout_type: w.workout_type,
    description_vi: w.description_vi ?? null,
    description_en: w.description_en ?? null,
    target_distance_m: w.target_distance_m ?? null,
    target_duration_s: w.target_duration_s ?? null,
    target_pace_s_per_km: w.target_pace_s_per_km ?? null,
    target_hr_zone: w.target_hr_zone ?? null,
  }));

  if (workoutRows.length > 0) {
    const wInsert = await svc.from("training_workouts").insert(workoutRows);
    if (wInsert.error) {
      console.error("training_workouts insert failed", wInsert.error.message);
    }
  }

  return jsonResponse({ plan_id: planId, workouts_count: workoutRows.length }, { req, status: 201 });
}

if (import.meta.main) {
  serve(async (req) => {
    try {
      return await generateTrainingPlanHandler(req);
    } catch (e) {
      return errorResponse(e, req);
    }
  });
}
