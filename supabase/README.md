# RunVie Supabase

Postgres 16 + PostGIS schema for the RunVie app.

## Prerequisites

- Supabase CLI: `npm i -g supabase` (or `brew install supabase/tap/supabase`)
- Docker Desktop (needed by `supabase start`)
- Node 20+ (for the Studio UI)

## First-time setup

```bash
cd D:/dev/run-tracker
supabase init           # only if .supabase/ is missing; safe to skip if config.toml exists
supabase start          # boots local Postgres + Studio + Auth + Storage
```

`supabase start` reads `supabase/config.toml` and applies every migration in
`supabase/migrations/` in filename order.

Default local URLs:

- API:    http://127.0.0.1:54321
- Studio: http://127.0.0.1:54323
- DB:     postgresql://postgres:postgres@127.0.0.1:54322/postgres

## Re-applying migrations

```bash
supabase db reset       # drops the local DB and re-runs every migration + seed
supabase db push        # applies pending migrations to the linked remote project
supabase db diff -f my_change   # creates a new timestamped migration from edits
```

## Linking to a remote Supabase project

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

## Migration order

| #  | File                                  | Purpose                                              |
|----|---------------------------------------|------------------------------------------------------|
| 00 | `20260520000000_init_extensions.sql`  | postgis, pgcrypto, uuid-ossp, citext, pg_trgm        |
| 01 | `20260520000100_profiles.sql`         | profiles + enums (gender/goal/level/units/language)  |
| 02 | `20260520000200_waitlist.sql`         | landing-page waitlist                                |
| 03 | `20260520000300_activities.sql`       | activities + activity_points + activity_splits       |
| 04 | `20260520000400_steps.sql`            | daily_steps roll-up                                  |
| 05 | `20260520000500_badges.sql`           | badges + user_badges (+ 30 seed badges)              |
| 06 | `20260520000600_streaks_coins.sql`    | streaks + run_coins + coin_transactions              |
| 07 | `20260520000700_challenges.sql`       | challenges + challenge_participants                  |
| 08 | `20260520000800_training.sql`         | training_plans + training_workouts                   |
| 09 | `20260520000900_social.sql`           | follows                                              |
| 10 | `20260520001000_devices.sql`          | push-notification device registry                    |
| 11 | `20260520001100_rls_policies.sql`     | RLS on every table                                   |
| 12 | `20260520001200_triggers.sql`         | updated_at + daily_steps roll-up triggers            |
| 13 | `20260520001300_functions.sql`        | RPC: award_coins / recalc_streak / award_badges      |

## RPC functions (call via `supabase.rpc(...)`)

- `award_coins_for_activity(p_activity_id uuid)` -> integer
  Idempotent. Mints 10 RunCoin per full km and writes a `coin_transactions` row.
- `recalc_streak(p_user_id uuid)` -> table(current_days, longest_days)
  Recomputes streak from `activities` history; updates `streaks`.
- `award_badges_for_user(p_user_id uuid, p_activity_id uuid default null)` -> setof text
  Evaluates `badges.criteria_jsonb` rules and grants newly unlocked badges.

## RLS summary

- A user can read/write only their own rows.
- `activities`, `activity_points`, `activity_splits`, `user_badges`, `streaks`,
  `follows` are readable by others when the owner's `profiles.is_public = true`.
- `waitlist` allows `INSERT` from anon/authenticated; `SELECT` is `service_role`-only.
- `badges` catalog is readable by everyone (when `is_active`); only `service_role` writes.

## Notes

- Geometry columns use `geography(POINT, 4326)` (WGS84). For polylines we store
  the encoded string in `activities.polyline`; per-second samples live in
  `activity_points` and have a GIST index.
- All enums live in `public.` schema with the `_enum` suffix.
- Every table with `updated_at` has a `BEFORE UPDATE` trigger via
  `public.set_updated_at()`.
