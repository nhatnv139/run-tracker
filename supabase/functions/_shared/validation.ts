// Shared zod schemas for RunVie Edge Functions.

import { z } from "zod";
import { Errors } from "@shared/errors";

export const uuid = z.string().uuid();
export const isoDateTime = z.string().datetime({ offset: true });
export const isoDate = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "expected YYYY-MM-DD");

export const activityTypeSchema = z.enum(["run", "walk", "treadmill", "hike"]);
export const activitySourceSchema = z.enum([
  "app",
  "apple_watch",
  "garmin",
  "strava",
  "manual",
]);
export const racedistanceSchema = z.enum(["5k", "10k", "half", "full"]);
export const devicePlatformSchema = z.enum(["ios", "android", "watch_os", "wear_os", "web"]);

export const pointSampleSchema = z.object({
  sequence: z.number().int().min(0),
  ts: isoDateTime,
  lat: z.number().gte(-90).lte(90),
  lng: z.number().gte(-180).lte(180),
  elevation_m: z.number().optional().nullable(),
  speed_mps: z.number().nonnegative().optional().nullable(),
  hr: z.number().int().gte(30).lte(250).optional().nullable(),
  cadence: z.number().int().gte(0).lte(300).optional().nullable(),
});
export type PointSample = z.infer<typeof pointSampleSchema>;

export const splitSchema = z.object({
  km_index: z.number().int().min(1),
  duration_s: z.number().int().nonnegative(),
  pace_s_per_km: z.number().int().gte(60).lte(7200),
  hr_avg: z.number().int().gte(30).lte(250).optional().nullable(),
  elevation_gain: z.number().int().nonnegative().default(0),
});
export type Split = z.infer<typeof splitSchema>;

export const syncActivitySchema = z.object({
  type: activityTypeSchema,
  source: activitySourceSchema.default("app"),
  started_at: isoDateTime,
  ended_at: isoDateTime,
  duration_s: z.number().int().nonnegative(),
  distance_m: z.number().int().nonnegative(),
  calories: z.number().int().nonnegative().optional().nullable(),
  avg_pace_s_per_km: z.number().int().gte(60).lte(7200).optional().nullable(),
  avg_hr: z.number().int().gte(30).lte(250).optional().nullable(),
  max_hr: z.number().int().gte(30).lte(250).optional().nullable(),
  elevation_gain_m: z.number().int().nonnegative().default(0),
  elevation_loss_m: z.number().int().nonnegative().default(0),
  polyline: z.string().optional().nullable(),
  is_indoor: z.boolean().default(false),
  weather: z.record(z.unknown()).optional().nullable(),
  start_point: z.object({ lat: z.number(), lng: z.number() }).optional().nullable(),
  end_point: z.object({ lat: z.number(), lng: z.number() }).optional().nullable(),
  points: z.array(pointSampleSchema).max(20000).default([]),
  splits: z.array(splitSchema).max(200).default([]),
});
export type SyncActivityPayload = z.infer<typeof syncActivitySchema>;

export const awardBadgesSchema = z.object({
  user_id: uuid,
  activity_id: uuid.optional().nullable(),
});

export const redeemCoinSchema = z.object({
  voucher_id: uuid,
  otp: z.string().length(6).optional(),
});

export const recalcStreakSchema = z.object({
  user_id: uuid.optional(),
});

export const trainingPlanSchema = z.object({
  race_distance: racedistanceSchema,
  target_pace_s_per_km: z.number().int().gte(120).lte(1200).optional(),
  weeks: z.number().int().min(1).max(52),
  start_date: isoDate,
});

export const aiChatSchema = z.object({
  message: z.string().min(1).max(4000),
  history: z
    .array(
      z.object({
        role: z.enum(["user", "assistant", "system"]),
        content: z.string().min(1).max(8000),
      }),
    )
    .max(40)
    .default([]),
});

export const uploadRouteSchema = z.object({
  name: z.string().min(1).max(120),
  polyline: z.string().min(8),
  distance_m: z.number().int().nonnegative(),
  start_city: z.string().max(80).optional(),
  is_public: z.boolean().default(true),
});

export const livePublishSchema = z.object({
  activity_id: uuid,
  lat: z.number().gte(-90).lte(90),
  lng: z.number().gte(-180).lte(180),
  ts: isoDateTime,
  speed_mps: z.number().nonnegative().optional(),
  hr: z.number().int().gte(30).lte(250).optional(),
});

export const anomalyCheckSchema = z.object({
  activity_id: uuid,
});

export const deviceRegisterSchema = z.object({
  platform: devicePlatformSchema,
  push_token: z.string().min(8).max(512),
  app_version: z.string().max(40).optional(),
  os_version: z.string().max(40).optional(),
});

export const sendPushSchema = z.object({
  user_id: uuid,
  title: z.string().min(1).max(120),
  body: z.string().min(1).max(400),
  data: z.record(z.string()).optional(),
});

export const deleteAccountSchema = z.object({
  confirm: z.literal(true),
});

/** Parse JSON body + validate against schema; throws AppError on failure. */
export async function parseBody<T>(req: Request, schema: z.ZodType<T>): Promise<T> {
  let raw: unknown;
  try {
    raw = await req.json();
  } catch (_e) {
    throw Errors.badRequest("invalid json body");
  }
  const result = schema.safeParse(raw);
  if (!result.success) {
    throw Errors.badRequest("validation failed", result.error.flatten());
  }
  return result.data;
}
