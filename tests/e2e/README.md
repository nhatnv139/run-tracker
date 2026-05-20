# RunVie E2E tests

Cross-system end-to-end tests that exercise the full stack
(landing -> Supabase -> AI Coach -> mobile API).

## Suites

| File | Tool | Scope |
|------|------|-------|
| `landing_test.spec.ts` | Playwright | Marketing site waitlist form |
| `full_user_journey.py` | Python requests + supabase-py | Sign up -> activity -> badges -> chat -> redeem -> delete |

## Install

```bash
pnpm install
pnpm run install:browsers

pip install -e ".[dev]"
```

## Run

```bash
LANDING_URL=https://staging.runvie.app pnpm test

SUPABASE_URL=... \
SUPABASE_ANON_KEY=... \
SUPABASE_SERVICE_ROLE_KEY=... \
AI_COACH_URL=https://ai.staging.runvie.app \
python full_user_journey.py
```

## Expected pass criteria

- Playwright: form submission visible success state within 5s and a single
  row appears in the `waitlist` Supabase table.
- Python journey: every step returns 2xx, badges list is non-empty, voucher
  code is non-empty, and a post-deletion query against
  `activities`, `user_badges`, `coin_wallets`, `profiles` returns zero rows.
