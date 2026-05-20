# CI test strategy

Tests are partitioned by trigger to keep PR feedback fast while still
covering long-running scenarios on a regular cadence.

## On every pull request

Run anything under ~5 minutes:

- Flutter `dart analyze` + `flutter test` (unit + widget) - `flutter.yml`
- AI Coach `pytest -m "not slow"` + `ruff` + `mypy` - `ai-coach.yml`
- Edge Functions `deno test --filter unit` - `supabase.yml`
- Landing Vitest + ESLint - `landing.yml`
- Contract tests `pnpm --filter ./tests/contracts test` - `pr-checks.yml`
- Security `npm audit --omit=dev` + `pip-audit` - `security.yml`

## On push to `main`

Re-run the PR matrix plus:

- Flutter integration tests on an Android emulator (one device matrix).
- pgTAP database tests (`supabase test db`).
- Build artefacts (web landing, Docker AI Coach image) pushed to staging.

## Nightly (02:00 UTC)

- `.github/workflows/e2e.yml`
  - Playwright `landing_test.spec.ts` against staging.
  - Python `full_user_journey.py` against staging.
- Security suite (`tests/security/`) against staging.
- Flutter integration tests on iOS simulator (extra device).
- Coverage trend report posted to `#qa`.

## Weekly (Sunday 03:00 UTC)

- `.github/workflows/load.yml`
  - All three k6 scenarios in `tests/load/`.
- Long-running soak (24h) of `sync_activity_load.js` at 50% target rate
  triggered manually before each release candidate.

## On release tag

- All of the above plus:
  - Smoke tests against production immediately after deploy.
  - Bug-bash template (see `bug-bash-template.md`) printed in the release
    checklist for manual QA.

## Required vs. optional checks

Required to merge (branch protection):

- Unit + widget tests, contract tests, lint, type-check.

Optional but reported:

- Coverage, E2E, security suite. They appear as commit-status checks but
  do not block PR merging unless promoted by the engineering lead.
