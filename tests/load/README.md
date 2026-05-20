# RunVie load tests

[k6](https://k6.io) scenarios for the three highest-traffic critical paths.

## Scenarios

| Script | Target | SLO |
|--------|--------|-----|
| `ai_chat_load.js` | Ramp 10 -> 500 concurrent users sending chat prompts | p95 < 3000ms, failure rate < 1% |
| `sync_activity_load.js` | 1000 activities/min sustained for 10 minutes | p99 < 500ms, failure rate < 0.5% |
| `leaderboard_load.js` | 10,000 req/min for 5 minutes (cached read) | p95 < 100ms, failure rate < 0.1% |

## Install

Install k6 from <https://k6.io/docs/get-started/installation/>.
Optional Node tooling for npm scripts: `pnpm install`.

## Run

```bash
AI_COACH_URL=https://ai.staging.runvie.app \
LOAD_BEARER_TOKEN=$(./scripts/mint-load-token.sh) \
pnpm run load:chat

SUPABASE_URL=https://staging.supabase.co \
SUPABASE_ANON_KEY=... \
LOAD_USER_TOKEN=... \
pnpm run load:sync

SUPABASE_URL=https://staging.supabase.co \
SUPABASE_ANON_KEY=... \
pnpm run load:leaderboard
```

## Expected pass criteria

A run passes when k6 prints `checks` at 100% and **all** `thresholds`
listed in the per-script `options.thresholds` block are green. The CI
workflow `.github/workflows/load.yml` fails on any non-zero exit code
from `k6 run`.

## Notes

- Use a dedicated staging Supabase project. Never run against production.
- The AI Coach test sends synthetic prompts; configure the proxy to use a
  cheap model when `x-load-test: 1` header is present if cost is a concern.
- Leaderboard load assumes a warm cache; pre-warm by curling each
  scope=weekly|monthly|all_time URL three times before starting.
