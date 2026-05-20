# RunVie Events Specification

**Version:** 1.0
**Owner:** Data/Analytics Eng + Growth PM
**Last updated:** 2026-05-20
**Status:** Frozen for P0 rollout

## Conventions

- **Event name:** `snake_case`, verb_object pattern (e.g., `activity_started`, `paywall_viewed`).
- **Property name:** `snake_case` strictly (no camelCase mixing).
- **Types:** `string | int | float | bool | iso8601 | array<T> | enum`.
- **PII rule:** raw email/phone/name NEVER sent. Use `sha256(value + APP_SALT)` and suffix `_hash`.
- **Identity:** anonymous before sign-in via `$device_id`; after sign-in use `posthog.identify(user_id)` and alias the anonymous id.
- **Priority:** P0 = must-have at launch, P1 = within 30 days, P2 = nice-to-have.
- **Global / super properties** auto-attached on every event: `app_version`, `build_number`, `platform`, `os_version`, `device_model`, `locale`, `network_type`, `is_charging`, `session_id`, `app_session_seq`, `experiment_variants` (map of flag -> variant).

Total events specified: **92**.

---

## 1. App Lifecycle (P0) — 7 events

### 1.1 `app_opened`
- **Desc:** App moved from cold/warm start to foreground.
- **Trigger:** `AppLifecycleState.resumed` on cold start or warm resume.
- **Scope:** anonymous OK; user-scoped once identified.
- **Priority:** P0
- **Properties:**
  - `launch_type` enum(cold | warm | hot) — `cold`
  - `cold_start_ms` int — `1842`
  - `from_background_seconds` int | null — `35`
  - `referrer_source` enum(direct | push | deeplink | widget | siri | shortcut) — `push`
  - `last_screen` string | null — `home_feed`

### 1.2 `app_backgrounded`
- **Desc:** App moved to background.
- **Trigger:** `AppLifecycleState.paused`.
- **Priority:** P0
- **Properties:**
  - `session_duration_s` int — `412`
  - `screens_in_session` int — `7`
  - `last_screen` string — `activity_summary`

### 1.3 `app_crashed`
- **Desc:** Hard crash detected on previous launch.
- **Trigger:** Sentry sends `last_run.crashed = true`; we mirror as PostHog event.
- **Priority:** P0
- **Properties:**
  - `sentry_event_id` string — `f3a8...`
  - `crash_type` enum(native | dart | anr) — `dart`
  - `was_in_activity` bool — `true`

### 1.4 `push_received`
- **Desc:** Push payload received by device (foreground or background).
- **Trigger:** FCM/APNs delivery callback (silent + visible).
- **Priority:** P0
- **Properties:**
  - `campaign_id` string — `winter_streak_24`
  - `notification_type` enum(streak | coach | social | promo | system) — `streak`
  - `is_silent` bool — `false`

### 1.5 `push_opened`
- **Desc:** User tapped a notification.
- **Trigger:** Notification tap handler.
- **Priority:** P0
- **Properties:**
  - `campaign_id` string — `winter_streak_24`
  - `notification_type` enum — `coach`
  - `deeplink_target` string — `runvie://coach/chat`
  - `delivered_at` iso8601 — `2026-05-20T07:12:00Z`

### 1.6 `deeplink_opened`
- **Desc:** App opened via universal/custom URL.
- **Trigger:** Deep link router resolves URL.
- **Priority:** P0
- **Properties:**
  - `url_host` string — `runvie.app`
  - `url_path` string — `/race/saigon-marathon-2026`
  - `utm_source` string | null — `tiktok`
  - `utm_medium` string | null — `paid`
  - `utm_campaign` string | null — `launch_vn`

### 1.7 `app_updated`
- **Desc:** First launch after install or app version bump.
- **Trigger:** Compare current `app_version` vs `prefs.last_seen_version`.
- **Priority:** P0
- **Properties:**
  - `previous_version` string | null — `1.4.2`
  - `current_version` string — `1.5.0`
  - `is_fresh_install` bool — `false`

---

## 2. Onboarding (P0) — 6 events

### 2.1 `onboarding_started`
- **Trigger:** First view of welcome screen.
- **Priority:** P0
- **Properties:** `entry_source` enum(install | reset | post_signup) — `install`

### 2.2 `onboarding_step_viewed`
- **Trigger:** Each onboarding screen entry.
- **Priority:** P0
- **Properties:**
  - `step_index` int — `3`
  - `step_name` string — `goal_selection`
  - `time_since_start_s` int — `42`

### 2.3 `onboarding_step_completed`
- **Trigger:** User taps Continue with valid input.
- **Priority:** P0
- **Properties:**
  - `step_index` int — `3`
  - `step_name` string — `goal_selection`
  - `time_on_step_s` int — `12`
  - `payload` json (sanitized) — `{"goal":"5k_under_30"}`

### 2.4 `onboarding_step_skipped`
- **Trigger:** Skip CTA tap on a skippable step.
- **Priority:** P0
- **Properties:** `step_index`, `step_name`

### 2.5 `onboarding_completed`
- **Trigger:** Final step success → home feed.
- **Priority:** P0
- **Properties:**
  - `total_duration_s` int — `186`
  - `steps_completed_count` int — `7`
  - `steps_skipped_count` int — `1`
  - `selected_goal` string — `5k_under_30`
  - `selected_level` enum(beginner | intermediate | advanced) — `beginner`

### 2.6 `onboarding_abandoned`
- **Trigger:** App killed mid-onboarding for ≥24h, fired on next open.
- **Priority:** P0
- **Properties:**
  - `last_step_index` int — `4`
  - `last_step_name` string — `permissions_intro`
  - `time_since_start_s` int — `97`

---

## 3. Auth (P0) — 7 events

### 3.1 `sign_in_started`
- **Trigger:** User taps an auth provider button.
- **Priority:** P0
- **Properties:** `method` enum(apple | google | email | phone_otp) — `apple`

### 3.2 `sign_in_succeeded`
- **Trigger:** Token verified, session persisted.
- **Priority:** P0
- **Properties:**
  - `method` enum — `apple`
  - `is_new_user` bool — `false`
  - `latency_ms` int — `840`

### 3.3 `sign_in_failed`
- **Trigger:** Auth flow returns error.
- **Priority:** P0
- **Properties:**
  - `method` enum — `google`
  - `error_code` string — `auth/network-error`
  - `error_stage` enum(provider | backend | token_validation) — `backend`

### 3.4 `sign_up_succeeded`
- **Trigger:** New user record created in backend.
- **Priority:** P0
- **Properties:**
  - `method` enum — `email`
  - `referral_code` string | null — `RUN-AN21`
  - `signup_source` enum(organic | utm | referral | partner) — `utm`

### 3.5 `sign_out`
- **Trigger:** Explicit logout.
- **Priority:** P0
- **Properties:** `session_duration_days` int — `34`

### 3.6 `account_deleted`
- **Trigger:** User confirms account deletion (GDPR/ND13 right to erasure).
- **Priority:** P0
- **Properties:**
  - `tenure_days` int — `217`
  - `had_active_subscription` bool — `true`
  - `reason_code` string | null — `privacy_concern`

### 3.7 `token_refresh_failed`
- **Trigger:** Silent token refresh fails (forces re-login).
- **Priority:** P0
- **Properties:** `error_code` string — `auth/expired-refresh`

---

## 4. Permissions (P0) — 9 events

### 4.1 `location_permission_requested`
- **Priority:** P0
- **Properties:** `context` enum(onboarding | pre_workout | settings) — `pre_workout`

### 4.2 `location_permission_granted`
- **Priority:** P0
- **Properties:** `precision` enum(always | when_in_use | approximate) — `when_in_use`

### 4.3 `location_permission_denied`
- **Priority:** P0
- **Properties:** `is_permanent` bool — `false`

### 4.4 `motion_permission_requested`
- **Priority:** P0
- **Properties:** `context` enum — `onboarding`

### 4.5 `motion_permission_granted`
- **Priority:** P0
- **Properties:** none

### 4.6 `motion_permission_denied`
- **Priority:** P0
- **Properties:** `is_permanent` bool — `true`

### 4.7 `healthkit_authorized`
- **Trigger:** HealthKit/Health Connect dialog returns.
- **Priority:** P0
- **Properties:**
  - `platform` enum(ios | android) — `ios`
  - `categories_read` array<string> — `["heart_rate","workout","sleep"]`
  - `categories_write` array<string> — `["workout","distance_walking_running"]`
  - `all_granted` bool — `true`

### 4.8 `notification_permission_requested`
- **Priority:** P0
- **Properties:** `context` enum — `post_first_workout`

### 4.9 `notification_permission_granted`
- **Priority:** P0
- **Properties:**
  - `channel` enum(push | in_app | email) — `push`
  - `provisional` bool — `false`

---

## 5. Activity Tracking (P0) — 12 events

### 5.1 `activity_start_intent`
- **Desc:** User taps the Start button (before any sensor armed).
- **Priority:** P0
- **Properties:** `activity_type` enum(run | walk | cycle | treadmill_run | indoor_walk) — `run`

### 5.2 `activity_started`
- **Trigger:** GPS/treadmill stream armed and timer running.
- **Priority:** P0
- **Properties:**
  - `activity_type` enum — `run`
  - `source` enum(gps | treadmill | indoor_pod | watch) — `gps`
  - `auto_pause_enabled` bool — `true`
  - `voice_coach_enabled` bool — `true`
  - `audio_provider` enum(spotify | apple_music | youtube_music | none) — `spotify`
  - `gps_accuracy_m` float — `5.4`
  - `weather_temp_c` float | null — `28.5`

### 5.3 `activity_paused`
- **Priority:** P0
- **Properties:**
  - `pause_type` enum(manual | auto) — `auto`
  - `duration_so_far_s` int — `1245`
  - `distance_so_far_m` int — `4120`

### 5.4 `activity_resumed`
- **Priority:** P0
- **Properties:**
  - `pause_duration_s` int — `27`
  - `resume_type` enum(manual | auto) — `auto`

### 5.5 `activity_stopped`
- **Desc:** User taps Finish; pre-save summary shown.
- **Priority:** P0
- **Properties:**
  - `activity_type` enum — `run`
  - `distance_m` int — `5128`
  - `duration_s` int — `1812`
  - `moving_duration_s` int — `1742`
  - `avg_pace_s_per_km` int — `354`
  - `avg_hr_bpm` int | null — `156`
  - `calories_kcal` int — `412`
  - `elevation_gain_m` int — `38`
  - `gps_quality_score` float — `0.92`
  - `auto_pause_count` int — `2`
  - `manual_pause_count` int — `0`

### 5.6 `activity_saved`
- **Priority:** P0
- **Properties:** all of `activity_stopped` PLUS `activity_id` string — `act_8f3a2b`, `title_set` bool, `note_set` bool, `photo_count` int

### 5.7 `activity_discarded`
- **Priority:** P0
- **Properties:**
  - `reason` enum(too_short | accidental | error | user_choice) — `too_short`
  - `distance_m` int — `82`
  - `duration_s` int — `14`

### 5.8 `gps_signal_lost`
- **Priority:** P0
- **Properties:**
  - `duration_s` int — `12`
  - `recovered` bool — `true`
  - `interpolated_distance_m` int — `28`

### 5.9 `auto_pause_triggered`
- **Priority:** P0
- **Properties:** `idle_seconds_before` int — `8`

### 5.10 `lap_recorded`
- **Trigger:** Auto-lap (every 1 km / 1 mi) or manual lap tap.
- **Priority:** P1
- **Properties:**
  - `lap_index` int — `3`
  - `lap_type` enum(auto | manual) — `auto`
  - `lap_distance_m` int — `1000`
  - `lap_duration_s` int — `352`

### 5.11 `voice_coach_announcement_played`
- **Priority:** P1
- **Properties:**
  - `announcement_type` enum(distance | pace | hr_zone | encourage | warning) — `pace`
  - `coach_voice_id` string — `vn_male_warm`

### 5.12 `activity_edit_saved`
- **Trigger:** User edits title/note/type post-save.
- **Priority:** P1
- **Properties:** `activity_id`, `fields_changed` array<string> — `["title","activity_type"]`

---

## 6. Workout Post-Action (P0) — 5 events

### 6.1 `activity_shared`
- **Priority:** P0
- **Properties:**
  - `activity_id` string
  - `channel` enum(zalo | tiktok | instagram | facebook | x | link_copy | system_share) — `tiktok`
  - `media_type` enum(image | video | link) — `video`

### 6.2 `activity_kudos_given`
- **Priority:** P0
- **Properties:** `activity_id`, `target_user_id_hash` string

### 6.3 `activity_kudos_received`
- **Trigger:** Server-side webhook → SDK on next open.
- **Priority:** P0
- **Properties:** `activity_id`, `from_user_id_hash`

### 6.4 `activity_commented`
- **Priority:** P0
- **Properties:** `activity_id`, `comment_length` int — `48`, `is_reply` bool — `false`

### 6.5 `activity_summary_viewed`
- **Trigger:** Detail screen opened post-save.
- **Priority:** P0
- **Properties:** `activity_id`, `source` enum(post_save | feed | profile | notification) — `post_save`

---

## 7. AI Coach (P0) — 8 events

### 7.1 `ai_chat_opened`
- **Priority:** P0
- **Properties:** `entry_point` enum(home_card | tab_bar | post_workout | push | deeplink) — `post_workout`

### 7.2 `ai_message_sent`
- **Priority:** P0
- **Properties:**
  - `intent` enum(plan_advice | recovery | nutrition | gear | injury | small_talk | other) — `plan_advice`
  - `model_used` string — `claude-haiku-4-5`
  - `input_length_chars` int — `124`
  - `is_quick_reply` bool — `false`
  - `conversation_id` string — `conv_a1f2`

### 7.3 `ai_message_received`
- **Priority:** P0
- **Properties:**
  - `conversation_id` string
  - `latency_ms` int — `1842`
  - `tokens_input` int — `412`
  - `tokens_output` int — `186`
  - `cached_tokens` int — `380`
  - `cache_hit_ratio` float — `0.92`
  - `cost_usd` float — `0.00214`
  - `model_used` string — `claude-haiku-4-5`
  - `streamed` bool — `true`
  - `tool_calls_count` int — `1`

### 7.4 `ai_quick_reply_clicked`
- **Priority:** P0
- **Properties:** `quick_reply_id` string — `qr_log_workout`, `position_index` int — `2`

### 7.5 `ai_message_rated`
- **Priority:** P0
- **Properties:**
  - `conversation_id` string
  - `message_id` string
  - `rating` enum(thumbs_up | thumbs_down) — `thumbs_up`
  - `reason_codes` array<string> | null — `["off_topic"]`
  - `free_text_provided` bool — `false`

### 7.6 `ai_message_failed`
- **Priority:** P0
- **Properties:** `error_code` string — `model_timeout`, `retry_count` int — `1`

### 7.7 `ai_safety_block_triggered`
- **Priority:** P0
- **Properties:** `block_category` enum(injury_risk | medical_advice | self_harm | unsafe_pace) — `medical_advice`

### 7.8 `ai_conversation_cleared`
- **Priority:** P1
- **Properties:** `conversation_id`, `message_count` int — `14`

---

## 8. Training Plan (P1) — 7 events

### 8.1 `plan_generation_started`
- **Properties:**
  - `race_distance` enum(5k | 10k | half | full | custom) — `half`
  - `weeks` int — `12`
  - `weekly_volume_km_target` float — `35.0`
  - `experience_level` enum — `intermediate`

### 8.2 `plan_generated`
- **Properties:** `plan_id`, `weeks`, `workouts_count` int — `48`, `generation_latency_ms` int

### 8.3 `plan_started`
- **Properties:** `plan_id`, `start_date` iso8601

### 8.4 `plan_workout_completed`
- **Properties:** `plan_id`, `workout_index` int, `workout_type` enum(easy | tempo | interval | long | recovery | race) — `tempo`, `adherence_pct` float — `0.94`

### 8.5 `plan_workout_skipped`
- **Properties:** `plan_id`, `workout_index`, `reason` enum(injury | busy | weather | unmotivated | other) — `busy`

### 8.6 `plan_paused`
- **Properties:** `plan_id`, `pause_reason` string

### 8.7 `plan_completed`
- **Properties:** `plan_id`, `completion_rate_pct` float — `0.86`, `total_workouts_done` int — `41`

---

## 9. Gamification (P0) — 9 events

### 9.1 `badge_earned`
- **Priority:** P0
- **Properties:**
  - `badge_code` string — `first_10k`
  - `category` enum(distance | streak | speed | social | event | seasonal) — `distance`
  - `tier` enum(bronze | silver | gold | platinum) — `silver`
  - `is_first_time` bool — `true`

### 9.2 `streak_milestone`
- **Priority:** P0
- **Properties:** `days` int — `30`, `streak_type` enum(daily_workout | weekly_3x | active_minutes) — `weekly_3x`

### 9.3 `streak_broken`
- **Priority:** P0
- **Properties:** `days_at_break` int — `22`, `had_freeze_used` bool — `false`

### 9.4 `level_up`
- **Priority:** P0
- **Properties:** `new_level` int — `7`, `previous_level` int — `6`, `xp_total` int — `12450`

### 9.5 `runcoin_earned`
- **Priority:** P0
- **Properties:**
  - `amount` int — `150`
  - `reason` enum(activity | streak | badge | quest | referral | promo) — `activity`
  - `activity_id` string | null — `act_8f3a2b`
  - `balance_after` int — `2840`

### 9.6 `runcoin_redeemed`
- **Priority:** P0
- **Properties:**
  - `voucher_brand` string — `nike_vn`
  - `voucher_category` enum(apparel | nutrition | gear | service | charity) — `apparel`
  - `cost_runcoin` int — `1500`
  - `value_vnd` int — `150000`
  - `balance_after` int — `1340`

### 9.7 `marketplace_viewed`
- **Priority:** P0
- **Properties:** `entry_point` enum(home | profile | reward_push) — `home`

### 9.8 `virtual_race_joined`
- **Priority:** P0
- **Properties:** `race_id`, `distance_km` float — `21.1`, `entry_fee_runcoin` int — `500`

### 9.9 `virtual_race_completed`
- **Priority:** P0
- **Properties:** `race_id`, `finish_time_s` int — `8420`, `rank_global` int — `1247`, `rank_country` int — `89`

---

## 10. Subscription (P0) — 11 events

### 10.1 `paywall_viewed`
- **Priority:** P0
- **Properties:**
  - `placement` enum(onboarding | post_workout | feature_gate | milestone | settings | push) — `feature_gate`
  - `feature_gated` string | null — `ai_coach_unlimited`
  - `offer_id` string — `annual_30off`
  - `experiment_variant` string | null — `paywall_v3_compact`

### 10.2 `paywall_dismissed`
- **Priority:** P0
- **Properties:** `placement`, `dismiss_method` enum(close | swipe | back | timeout) — `close`, `time_on_screen_s` int — `12`

### 10.3 `plan_selected`
- **Priority:** P0
- **Properties:**
  - `tier` enum(pro | elite) — `pro`
  - `period` enum(monthly | annual | lifetime) — `annual`
  - `price_local` float — `999000`
  - `currency` string — `VND`

### 10.4 `trial_started`
- **Priority:** P0
- **Properties:** `tier`, `period`, `trial_length_days` int — `7`

### 10.5 `purchase_initiated`
- **Priority:** P0
- **Properties:** `tier`, `period`, `payment_method` enum(app_store | play_store | momo | zalopay | vnpay) — `app_store`

### 10.6 `purchase_succeeded`
- **Priority:** P0
- **Properties:**
  - `tier` enum — `pro`
  - `period` enum — `annual`
  - `price_local` float — `999000`
  - `price_usd` float — `39.50`
  - `currency` string — `VND`
  - `payment_method` enum — `app_store`
  - `is_trial_conversion` bool — `true`
  - `is_renewal` bool — `false`
  - `transaction_id_hash` string — `sha256(...)`

### 10.7 `purchase_failed`
- **Priority:** P0
- **Properties:** `error_code` string — `payment/declined`, `payment_method`, `stage` enum(init | provider | server_validation) — `provider`

### 10.8 `subscription_renewed`
- **Priority:** P0
- **Properties:** `tier`, `period`, `price_usd` float, `renewal_number` int — `2`

### 10.9 `subscription_canceled`
- **Priority:** P0
- **Properties:**
  - `tier`, `period`
  - `reason_code` string | null — `too_expensive`
  - `reason_free_text` bool — `false`
  - `days_active` int — `184`
  - `canceled_in_trial` bool — `false`

### 10.10 `subscription_expired`
- **Priority:** P0
- **Properties:** `tier`, `period`, `grace_period_days_used` int — `3`

### 10.11 `refund_requested`
- **Priority:** P0
- **Properties:** `tier`, `period`, `days_since_purchase` int — `5`, `reason_code` string

---

## 11. Social (P1) — 7 events

### 11.1 `profile_viewed` — `target_user_id_hash`, `is_self` bool, `source` enum(feed | search | leaderboard | activity)
### 11.2 `follow_clicked` — `target_user_id_hash`, `source` enum
### 11.3 `unfollow_clicked` — `target_user_id_hash`, `tenure_days` int
### 11.4 `club_joined` — `club_id`, `club_size` int, `join_source` enum(invite | discover | qr | link)
### 11.5 `club_left` — `club_id`, `days_in_club` int
### 11.6 `challenge_joined` — `challenge_id`, `challenge_type` enum(distance | duration | elevation | streak), `entry_cost_runcoin` int | null
### 11.7 `leaderboard_viewed` — `scope` enum(global | country | club | friends | weekly), `filter_period` enum(week | month | all_time)

All P1, all user-scoped.

---

## 12. Feature Usage (P1) — 7 events

### 12.1 `music_connected` — `provider` enum(spotify | apple_music | youtube_music)
### 12.2 `music_disconnected` — `provider`, `tenure_days` int
### 12.3 `watch_connected` — `model` string — `apple_watch_se_2`, `os_version` string
### 12.4 `heart_rate_strap_paired` — `model` string — `polar_h10`, `pairing_method` enum(ble | ant)
### 12.5 `strava_sync_enabled` — `sync_direction` enum(import | export | both)
### 12.6 `route_recommendation_accepted` — `route_id`, `distance_km` float, `surface` enum(road | trail | mixed)
### 12.7 `form_analysis_recorded` — `analysis_id`, `cadence_spm` int — `178`, `vertical_oscillation_cm` float — `8.4`, `score` int — `82`

---

## 13. Settings (P2) — 5 events

### 13.1 `language_changed` — `from_locale` string, `to_locale` string
### 13.2 `units_changed` — `unit_system` enum(metric | imperial)
### 13.3 `theme_changed` — `theme` enum(system | light | dark)
### 13.4 `notification_preference_changed` — `channel` enum, `category` enum(streak | coach | social | promo), `enabled` bool
### 13.5 `privacy_setting_changed` — `setting_key` string, `new_value` string

---

## Event Count Summary

| Group | Count | Priority mix |
|---|---|---|
| App lifecycle | 7 | P0 |
| Onboarding | 6 | P0 |
| Auth | 7 | P0 |
| Permissions | 9 | P0 |
| Activity tracking | 12 | P0 (10) + P1 (2) + P1 (1) |
| Workout post-action | 5 | P0 |
| AI Coach | 8 | P0 (7) + P1 (1) |
| Training plan | 7 | P1 |
| Gamification | 9 | P0 |
| Subscription | 11 | P0 |
| Social | 7 | P1 |
| Feature usage | 7 | P1 |
| Settings | 5 | P2 |
| **Total** | **92** | **P0 = 64, P1 = 23, P2 = 5** |

---

## Naming registry (forbidden duplicates)

To prevent taxonomy drift, the following near-synonyms are **banned**: `run_started`, `workout_began`, `session_start` (use `activity_started`); `purchase_complete` (use `purchase_succeeded`); `coach_message` (split into `ai_message_sent` / `ai_message_received`).

All new events MUST land in this spec via PR review by Data Eng + Growth PM before instrumentation.
