# RunVie AI Coach

FastAPI backend powering the RunVie AI Coach: chat coaching, training plan generation, and post-run summaries. Built on Claude Sonnet 4.7 + Haiku 4.5 with aggressive prompt caching and smart model routing.

## Architecture

```
client
  │
  ▼
FastAPI (uvicorn, async)
  ├── /v1/chat            non-streaming
  ├── /v1/chat/stream     SSE
  ├── /v1/training-plan   JSON (always Sonnet)
  ├── /v1/post-run        JSON (Haiku)
  ├── /health
  └── /metrics
  │
  ├─ ClaudeClient  ──► Anthropic API
  │     • prompt caching (system + profile blocks)
  │     • streaming + retries (tenacity)
  │     • cost computed per call
  │
  ├─ Router  smart Haiku/Sonnet dispatch
  ├─ ChatHistoryCache (Redis, rotating 20-msg window, 24h TTL)
  ├─ CostAggregator (Redis daily/monthly per user + global)
  ├─ RateLimiter (Redis sliding window: 20/mo free, 100/day paid)
  └─ Auth (Supabase JWT RS256 via JWKS)
```

## Model routing

| Intent          | Model      | Why                                   |
|-----------------|------------|---------------------------------------|
| greeting        | Haiku 4.5  | Trivial — Haiku is fine               |
| factual short Q | Haiku 4.5  | Sub-15-word factual question          |
| nutrition Q     | Haiku 4.5  | Common knowledge, short answer        |
| injury          | Sonnet 4.7 | Safety + nuance                       |
| training depth  | Sonnet 4.7 | Methodology requires depth            |
| complex plan    | Sonnet 4.7 | Long-form structured output           |
| unknown/default | Sonnet 4.7 | Quality-first default                 |

The classifier is a fast heuristic (no API call) in `src/router.py`.

## Prompt caching

Two `cache_control: ephemeral` breakpoints per request:

1. **System persona** (`system_coach.md`, ~3000 tokens) — changes never.
2. **User profile block** — changes only when the user updates their profile.

Recent chat history is sent uncached. Target cache hit rate in steady state: **>=90%**.

## Run locally

```bash
# 1. Install (uv or pip)
pip install -e ".[dev]"

# 2. Configure
cp .env.example .env
# edit .env — set ANTHROPIC_API_KEY

# 3. Start Redis (optional, app degrades gracefully)
docker run --rm -p 6379:6379 redis:7-alpine

# 4. Run
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

# Open: http://localhost:8000/docs
```

## Run with Docker

```bash
docker compose up --build
```

## Tests + lint

```bash
pytest                  # unit tests
ruff check src tests    # lint
ruff format --check .   # format
mypy src                # type-check
```

## Example requests

### Chat (non-streaming)

```bash
curl -X POST http://localhost:8000/v1/chat \
  -H "Content-Type: application/json" \
  -H "X-User-Id: user-123" \
  -d '{
    "user_profile": {
      "id": "user-123", "name": "Linh", "age": 28, "gender": "female",
      "weight_kg": 52, "height_cm": 160, "goal": "race_10k", "level": "intermediate",
      "max_hr": 188, "vo2max": 42, "weekly_km": 25,
      "recent_prs": {"5k": "26:30"}, "injuries": []
    },
    "history": [],
    "message": "Sáng mai chạy interval 6x800 nên ăn gì trước?",
    "language": "vi"
  }'
```

### Chat (SSE stream)

```bash
curl -N -X POST http://localhost:8000/v1/chat/stream \
  -H "Content-Type: application/json" \
  -H "X-User-Id: user-123" \
  -d @chat-payload.json
```

Browser side:
```js
const res = await fetch("/v1/chat/stream", { method: "POST", body: JSON.stringify(payload) });
const reader = res.body.getReader();
// Or use a proper SSE library since EventSource doesn't support POST.
```

### Training plan

```bash
curl -X POST http://localhost:8000/v1/training-plan \
  -H "Content-Type: application/json" \
  -H "X-User-Id: user-123" \
  -d '{
    "user_profile": { "id": "user-123", "name": "Linh", "age": 28, "gender": "female",
      "weight_kg": 52, "height_cm": 160, "goal": "race_half", "level": "intermediate",
      "weekly_km": 25, "recent_prs": {"10k": "55:00"}, "injuries": [] },
    "race_distance": "half",
    "weeks": 12,
    "target_pace_s_per_km": 330,
    "start_date": "2026-06-01",
    "language": "vi"
  }'
```

### Post-run summary

```bash
curl -X POST http://localhost:8000/v1/post-run \
  -H "Content-Type: application/json" \
  -H "X-User-Id: user-123" \
  -d '{
    "activity": {
      "distance_m": 10000, "duration_s": 3000, "pace_s_per_km": 300,
      "hr_avg": 155, "elevation_gain_m": 45,
      "splits": [
        {"km": 1, "duration_s": 305, "hr_avg": 145},
        {"km": 2, "duration_s": 302, "hr_avg": 150}
      ]
    },
    "user_profile": { "id":"user-123","name":"Linh","age":28,"gender":"female",
      "weight_kg":52,"height_cm":160,"goal":"race_10k","level":"intermediate",
      "weekly_km":25,"recent_prs":{},"injuries":[] },
    "language": "vi"
  }'
```

## Cost projection

Assumptions: 8 chat msgs/day paid user, ~3000-token cached system prompt, 90% cache hit, 60% Haiku routing.

| Tier | Msgs/month | Avg cost/msg | Monthly $/user |
|------|------------|--------------|----------------|
| Free | 20         | $0.001       | $0.02          |
| Paid | ~240       | $0.0018      | $0.43          |

Track real numbers via `GET /metrics`.

## Deployment

- **Fly.io**: `fly launch` then `fly secrets set ANTHROPIC_API_KEY=... REDIS_URL=...`; use Fly Redis or Upstash.
- **Railway**: connect repo, add Redis plugin, set env vars in dashboard.
- **GCP Cloud Run**: `gcloud run deploy ai-coach --source . --region asia-southeast1`; use Memorystore for Redis.

For all deploys, set `AUTH_REQUIRED=true`, `APP_ENV=production`, configure `SUPABASE_URL`/`SUPABASE_JWKS_URL`, and provide a real `SENTRY_DSN`.

## Configuration reference

See `.env.example` for the full list of environment variables.
