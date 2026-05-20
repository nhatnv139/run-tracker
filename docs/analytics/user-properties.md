# User Properties Specification

PostHog `identify()` payload for RunVie. All keys `snake_case`. Hashing rule: PII fields use `sha256(value + APP_SALT)`; the salt is rotated annually and stored in backend HSM, never shipped to client.

## Identity (required at identify)

| Key | Type | Example | Notes |
|---|---|---|---|
| `user_id` | string | `usr_8f3a2b9c` | Server-issued ULID. PostHog distinct_id. |
| `email_hash` | string | `sha256("an@x.vn"+SALT)` | Never raw. Used for join with CRM. |
| `phone_hash` | string \| null | `sha256("+8490..."+SALT)` | OTP users only. |
| `provider_id_hash` | string | `sha256(...)` | Apple/Google sub. |

## Profile

| Key | Type | Example | Notes |
|---|---|---|---|
| `age_range` | enum | `25_34` | `under_18`, `18_24`, `25_34`, `35_44`, `45_54`, `55_plus`. NEVER raw birthday. |
| `gender` | enum | `female` | `male`, `female`, `non_binary`, `prefer_not_say`. |
| `level` | enum | `intermediate` | `beginner`, `intermediate`, `advanced`. |
| `primary_goal` | string | `5k_under_30` | From onboarding goal selection. |
| `secondary_goals` | array<string> | `["weight_loss","stress_relief"]` | |
| `country` | string (ISO-3166-1 alpha-2) | `VN` | |
| `city` | string | `Ho Chi Minh City` | Coarse, not precise location. |
| `timezone` | string (IANA) | `Asia/Ho_Chi_Minh` | |
| `language` | string (BCP-47) | `vi-VN` | |
| `units` | enum | `metric` | `metric`, `imperial`. |
| `height_cm_range` | enum | `170_179` | Bucketed. |
| `weight_kg_range` | enum | `60_69` | Bucketed. |

## Cohort & monetization

| Key | Type | Example |
|---|---|---|
| `signup_date` | iso8601 | `2025-11-04T08:21:00Z` |
| `signup_source` | enum | `tiktok_paid` |
| `signup_referral_code` | string \| null | `RUN-AN21` |
| `paid_status` | enum | `paid` (`free`, `trial`, `paid`, `lapsed`) |
| `tier` | enum \| null | `pro` |
| `period` | enum \| null | `annual` |
| `trial_state` | enum | `none` (`none`, `active`, `converted`, `expired`) |
| `trial_started_at` | iso8601 \| null | `2026-04-12T00:00:00Z` |
| `lifetime_value_usd` | float | `78.50` |
| `lifetime_distance_km` | float | `412.8` |
| `lifetime_workouts` | int | `87` |
| `lifetime_active_days` | int | `64` |
| `runcoin_balance` | int | `2840` |
| `runcoin_lifetime_earned` | int | `8420` |
| `runcoin_lifetime_redeemed` | int | `5580` |

## Device (super properties — updated each session)

| Key | Type | Example |
|---|---|---|
| `platform` | enum | `ios` (`ios`, `android`) |
| `os_version` | string | `iOS 18.4` |
| `app_version` | string | `1.5.0` |
| `build_number` | string | `1500` |
| `device_model` | string | `iPhone15,2` |
| `device_locale` | string | `vi-VN` |
| `screen_size_class` | enum | `phone_regular` |
| `is_low_power_mode` | bool | `false` |

## Engagement

| Key | Type | Example |
|---|---|---|
| `last_active_at` | iso8601 | `2026-05-19T18:42:00Z` |
| `last_workout_at` | iso8601 \| null | `2026-05-19T06:30:00Z` |
| `current_streak_days` | int | `12` |
| `longest_streak_days` | int | `48` |
| `total_streak_breaks` | int | `3` |
| `weekly_active_days_avg_4w` | float | `3.8` |
| `is_was_user` | bool | `true` |
| `last_app_version` | string | `1.4.2` |

## Permissions snapshot

| Key | Type | Example |
|---|---|---|
| `has_healthkit` | bool | `true` |
| `has_location_always` | bool | `false` |
| `has_location_when_in_use` | bool | `true` |
| `has_motion` | bool | `true` |
| `has_notif_push` | bool | `true` |
| `has_notif_provisional` | bool | `false` |

## Marketing & attribution

| Key | Type | Example |
|---|---|---|
| `first_utm_source` | string \| null | `tiktok` |
| `first_utm_campaign` | string \| null | `launch_vn` |
| `last_utm_source` | string \| null | `meta` |
| `attributed_install_at` | iso8601 \| null | `2025-11-04T08:18:00Z` |

## Set-once vs set rules

- `signup_date`, `signup_source`, `first_utm_*`, `attributed_install_at` → `$set_once` only.
- Everything else → `$set` (overwrite on change).
- `lifetime_*` counters: server-side computed in nightly batch, pushed via PostHog server-side `identify` (NOT client) to avoid race conditions.

## Group-level properties (PostHog Groups)

We use PostHog Groups for `club` and `device_household` (paired Watch + Phone).

`club` group:
- `club_id`, `club_size`, `club_country`, `club_created_at`, `club_tier`.

## Forbidden keys

Never set: raw `email`, `phone`, `name`, `birthday`, `address`, `gps_home`, `health_diagnosis`. Schema-level lint rule on PostHog ingest pipeline drops events containing these keys and alerts Slack `#data-incidents`.
