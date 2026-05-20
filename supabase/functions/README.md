# RunVie Edge Functions

Deno-based Supabase Edge Functions backing the RunVie mobile + web clients.
All functions share helpers in `_shared/`:

- `auth.ts` — `authenticate(req)`, `assertSameUser`, `assertServiceRole`
- `cors.ts` — `corsHeaders`, `handlePreflight`
- `errors.ts` — `AppError`, `Errors.*`, `errorResponse`
- `json.ts` — `jsonResponse`
- `supabase-client.ts` — `getServiceClient`, `getUserClient`,
  `__setServiceClientForTesting`
- `validation.ts` — shared zod schemas + `parseBody`

## Local development

```sh
# format & lint
deno task fmt
deno task lint

# type-check every function
deno task check

# run unit tests (mocks the supabase client)
deno task test
```

## Deploy

```sh
# one function
supabase functions deploy <name>
# or via the project task
deno task deploy:<name>

# everything
deno task deploy:all
```

## Function catalogue (15)

| # | Function | Method | Auth | Purpose |
|---|----------|--------|------|---------|
| 1 | `sync-activity` | POST | user JWT | Persist a finished activity (+ points, splits) and trigger coins/badges/streak |
| 2 | `award-badges` | POST | user JWT or service | Run the SQL criteria engine and grant newly-met badges |
| 3 | `redeem-coin` | POST | user JWT | Spend RunCoin for a partner voucher; KYC OTP > 100k VND |
| 4 | `recalc-streak` | POST | user JWT or service | Recompute current + longest streak |
| 5 | `generate-training-plan` | POST | user JWT | Call AI Coach `/v1/training-plan`, persist plan + workouts |
| 6 | `ai-chat-proxy` | POST | user JWT | Stream SSE from AI Coach; injects context; rate-limited per tier |
| 7 | `leaderboard` | GET | user JWT | Top-100 + caller's rank for scope/period |
| 8 | `upload-route` | POST | user JWT | Save a polyline-encoded route (auto-trim 200 m at each end) |
| 9 | `live-track-publish` | POST | user JWT | Push a live-tracking sample (5 s cadence) |
| 10 | `live-track-subscribe` | GET (SSE) | user JWT | Stream the live session to family/friends |
| 11 | `anomaly-check` | POST | user JWT or service | Flag GPS spoofing (velocity / teleport) |
| 12 | `device-register` | POST | user JWT | Upsert push token + device metadata |
| 13 | `send-push` | POST | service-role only | Fan-out FCM/APNs notifications |
| 14 | `weekly-recap` | GET (cron) / POST | service-role | Sunday 19:00 ICT recap + push |
| 15 | `delete-account` | POST | user JWT | GDPR / PDPA hard delete (cascades) |

## Curl examples

Replace `${SUPABASE_URL}` with your project URL and `${USER_JWT}` with a valid
user access token. Service-only endpoints require `x-service-key`.

```sh
# 1. sync-activity
curl -X POST "${SUPABASE_URL}/functions/v1/sync-activity" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{
    "type":"run","source":"app",
    "started_at":"2026-05-21T05:00:00+07:00",
    "ended_at":"2026-05-21T05:30:00+07:00",
    "duration_s":1800,"distance_m":5000,
    "points":[],"splits":[]
  }'

# 2. award-badges
curl -X POST "${SUPABASE_URL}/functions/v1/award-badges" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"user_id":"<uuid>","activity_id":"<uuid>"}'

# 3. redeem-coin
curl -X POST "${SUPABASE_URL}/functions/v1/redeem-coin" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"voucher_id":"<uuid>","otp":"123456"}'

# 4. recalc-streak
curl -X POST "${SUPABASE_URL}/functions/v1/recalc-streak" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{}'

# 5. generate-training-plan
curl -X POST "${SUPABASE_URL}/functions/v1/generate-training-plan" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"race_distance":"10k","weeks":8,"start_date":"2026-06-01"}'

# 6. ai-chat-proxy (streams SSE; pipe to stdout)
curl -N -X POST "${SUPABASE_URL}/functions/v1/ai-chat-proxy" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"message":"Plan an easy 5k tomorrow","history":[]}'

# 7. leaderboard
curl -G "${SUPABASE_URL}/functions/v1/leaderboard" \
  -H "authorization: Bearer ${USER_JWT}" \
  --data-urlencode "scope=country" --data-urlencode "period=weekly"

# 8. upload-route
curl -X POST "${SUPABASE_URL}/functions/v1/upload-route" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"name":"West Lake loop","polyline":"_p~iF~ps|U_ulLnnqC","distance_m":7200}'

# 9. live-track-publish
curl -X POST "${SUPABASE_URL}/functions/v1/live-track-publish" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"activity_id":"<uuid>","lat":21.03,"lng":105.85,"ts":"2026-05-21T05:01:00+07:00"}'

# 10. live-track-subscribe (SSE)
curl -N "${SUPABASE_URL}/functions/v1/live-track-subscribe?activity_id=<uuid>" \
  -H "authorization: Bearer ${USER_JWT}"

# 11. anomaly-check
curl -X POST "${SUPABASE_URL}/functions/v1/anomaly-check" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"activity_id":"<uuid>"}'

# 12. device-register
curl -X POST "${SUPABASE_URL}/functions/v1/device-register" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"platform":"ios","push_token":"<apns-token>","app_version":"1.0.0"}'

# 13. send-push (service-only)
curl -X POST "${SUPABASE_URL}/functions/v1/send-push" \
  -H "x-service-key: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "content-type: application/json" \
  -d '{"user_id":"<uuid>","title":"Hello","body":"Time to run"}'

# 14. weekly-recap (cron, service-only)
curl "${SUPABASE_URL}/functions/v1/weekly-recap" \
  -H "x-service-key: ${SUPABASE_SERVICE_ROLE_KEY}"

# 15. delete-account
curl -X POST "${SUPABASE_URL}/functions/v1/delete-account" \
  -H "authorization: Bearer ${USER_JWT}" \
  -H "content-type: application/json" \
  -d '{"confirm":true}'
```

## Error envelope

All non-2xx responses share this shape:

```json
{ "error": "bad_request", "message": "validation failed", "details": { } }
```

Codes: `unauthorized | forbidden | bad_request | not_found | conflict |
rate_limited | upstream_error | internal_error`.

## Environment

Required env vars per function (set via `supabase secrets set`):

- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` — all
- `AI_COACH_URL`, `AI_COACH_API_KEY` — `generate-training-plan`, `ai-chat-proxy`
- `PARTNER_REDEEM_URL`, `PARTNER_API_KEY` — `redeem-coin`
- `FCM_URL`, `FCM_SERVER_KEY`, `APNS_URL`, `APNS_KEY` — `send-push`

## Cron

Schedule `weekly-recap` via Supabase Scheduled Functions:

```sql
select cron.schedule(
  'weekly-recap',
  '0 12 * * 0',                                     -- 19:00 ICT == 12:00 UTC, Sunday
  $$ select net.http_get(
       url := current_setting('app.functions_url') || '/weekly-recap',
       headers := jsonb_build_object('x-service-key', current_setting('app.service_role'))
     ); $$
);
```
