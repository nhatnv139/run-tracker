# Test data management

## Principles

1. **Factories over fixtures.** Prefer a builder/factory that returns
   sensible defaults and accepts overrides for the field under test.
2. **Hermetic by default.** Tests must not depend on global state, on
   real network calls, or on the order they are executed in.
3. **One source of truth per shape.** Each domain object has exactly one
   factory module (e.g. `factories/activity.dart`).
4. **Avoid sleeping.** Use fake clocks (`Clock.fixed`) and pump-and-settle
   in Flutter or `freezegun` in Python.

## Where things live

| Layer | Location | Pattern |
|-------|----------|---------|
| Flutter | `app/test/factories/` | `freezed` builders returning domain models. |
| AI Coach | `ai-coach/tests/factories/` | `pydantic_factories` (or `factory-boy`). |
| Edge Functions | `supabase/tests/factories/` | TypeScript builder functions. |
| Postgres seeds | `supabase/seed/` | Idempotent SQL scripts (truncate + insert). |

## Naming

- `makeXxx()` for a single instance.
- `makeXxxList(n)` for collections.
- Random fields use a seeded `Faker` instance so tests are reproducible.

## Cleanup

- Integration tests run inside a transaction that is rolled back at the
  end of the test (Postgres) or against an in-memory database (Drift /
  SQLite for Flutter).
- E2E tests sign up disposable users (`sec+<uuid>@runvie.test`) and call
  `/functions/v1/delete-account` at the end.

## PII

Never seed real PII. All generated emails use the `@runvie.test` domain.
Phone numbers use the documentation block (`+84-555-...`). Display names
are pulled from a curated allow-list.

## Big binary fixtures

Stored under `tests/_fixtures/` with Git LFS. Each file documents its
provenance in a sibling `.LICENSE` text file. Maximum 1MB per fixture.
