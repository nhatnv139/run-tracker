# Coverage targets

| Component | Target line coverage | Tool | Notes |
|-----------|---------------------|------|-------|
| Flutter app (`app/lib`) | 70% | `flutter test --coverage` + lcov | Excludes generated `*.g.dart`, `*.freezed.dart`, fixtures. |
| AI Coach (FastAPI) | 80% | `pytest --cov=src` | Excludes prompt template files. |
| Edge Functions | 75% | `deno test --coverage` | Per-function; new functions blocked from merge below 60%. |
| SQL / migrations | 100% pgTAP | `supabase test db` | Every RLS policy and trigger must have a pgTAP assertion. |
| Landing site | 60% statement | Vitest | Mainly snapshot + form behaviour. |

## Enforcement

- `flutter.yml` uploads lcov to Codecov; PR fails when the diff coverage
  drops more than 2 points or absolute coverage falls below the target.
- `ai-coach.yml` runs `pytest --cov --cov-fail-under=80`.
- `supabase.yml` runs `deno test --coverage` and the pgTAP suite. SQL
  coverage is enforced by the test count, not lcov.
- Nightly job posts a coverage trend chart to `#qa` in Slack.

## What "covered" means

- Lines executed by automated tests, not lines reached by manual QA.
- Type-checking failures are not coverage; they are a separate quality gate.
- Coverage of generated code does not count toward the percentage.

## When to lower a target

Coverage targets only drop with sign-off from the engineering lead and a
linked issue tracking the technical debt. Otherwise targets only move up.
