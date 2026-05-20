# Test pyramid

We follow a standard 70 / 20 / 10 split.

| Layer | Share | Where |
|-------|-------|-------|
| Unit | 70% | `app/test/`, `ai-coach/tests/unit/`, `supabase/tests/unit/` |
| Integration | 20% | `app/integration_test/`, `ai-coach/tests/integration/`, `supabase/tests/integration/` |
| End-to-end | 10% | `tests/e2e/`, `tests/load/`, `tests/security/` |

## Rationale

- Unit tests are cheap and run on every commit. They cover the bulk of pure
  logic (formatters, calculators, model serialisation, repository contracts).
- Integration tests exercise real combinations (Riverpod tree + mocked
  Supabase, FastAPI app + in-memory cache, Edge Function + Postgres) and
  catch wiring regressions that unit tests miss.
- E2E tests stitch together multiple services. They are flakier and slower,
  so we cap their share and only run them nightly or on demand.

## Per-package targets

| Package | Unit | Integration | E2E |
|---------|------|-------------|-----|
| Flutter app | ~75% | ~20% | ~5% |
| AI Coach (FastAPI) | ~70% | ~25% | ~5% |
| Edge Functions | ~65% | ~25% | ~10% |
| SQL / migrations | n/a (pgTAP) | n/a | n/a |

## Anti-patterns to avoid

- E2E tests that re-verify pure-logic assertions a unit test already covers.
- Integration tests that hit the real internet (always use a staging env).
- Unit tests with sleeps; use fake clocks.
