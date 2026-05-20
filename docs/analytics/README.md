# RunVie Analytics — Index & Rollout Plan

This folder is the single source of truth for product analytics, instrumentation, and data warehousing at RunVie. Everything ships through PRs reviewed by Data Engineering + the named domain owner.

---

## Documents

| # | File | Purpose | Primary owner |
|---|---|---|---|
| 1 | [events-spec.md](./events-spec.md) | Canonical event taxonomy (92 events across 13 groups) | Data Eng + Growth PM |
| 2 | [user-properties.md](./user-properties.md) | PostHog `identify` schema, person properties, set-once rules | Data Eng |
| 3 | [funnels.md](./funnels.md) | 10 production funnels with benchmarks + targets | Growth PM |
| 4 | [dashboards.md](./dashboards.md) | 10 production dashboards in PostHog/Metabase | Growth PM |
| 5 | [north-star.md](./north-star.md) | North Star = Weekly Active Streaks (WAS), input ladder | CEO + Growth PM |
| 6 | [experimentation.md](./experimentation.md) | A/B framework, 20-test queue, decision protocol | Growth PM + Data Eng |
| 7 | [data-privacy.md](./data-privacy.md) | PostHog privacy config, ND13/GDPR/ATT compliance | Legal + Data Eng |
| 8 | [instrumentation-flutter.md](./instrumentation-flutter.md) | Flutter SDK wrapper, typed events, offline queue | Mobile Eng |
| 9 | [data-warehouse.md](./data-warehouse.md) | ClickHouse + Postgres schemas, dbt models, reverse-ETL | Data Eng |
| 10 | README.md (this file) | Index + rollout sequencing + ownership | Head of Data |

---

## Stack

- **PostHog self-hosted** (Hanoi DC): product analytics, feature flags, A/B experiments, session replay.
- **Sentry** (EU SaaS): crash and performance monitoring.
- **ClickHouse self-hosted**: primary OLAP for activity time-series + modeled events.
- **Postgres**: OLTP for app + logical mirror for BI/compliance.
- **Metabase**: employee BI.
- **Hex**: data team notebooks.
- **dbt-clickhouse**: data modeling.
- **Airbyte**: source ingestion.

---

## Rollout sequencing

The 92 events do not ship at once. Sequencing keeps the project shippable and the data clean.

### Phase 0 — Pre-launch foundation (Week -2 to 0)

- [ ] PostHog project provisioned, salt seeded into KMS.
- [ ] Sentry project provisioned, DSN per platform.
- [ ] ClickHouse cluster + Postgres mirror live.
- [ ] `AnalyticsService` wrapper merged with empty method stubs and CI lint enforced.
- [ ] `events-spec.md` and `user-properties.md` frozen at v1.0.
- [ ] dbt project initialized, staging models for `events_raw`.

### Phase 1 — P0 events (Week 0–2, launch-blocking)

Ship all 64 P0 events. Order within phase:

1. **Identity + lifecycle first** — `app_opened`, `app_backgrounded`, `app_crashed`, `app_updated`, all `sign_in_*`/`sign_up_*`, `account_deleted`. Validates that distinct_id ↔ user_id aliasing works end-to-end.
2. **Onboarding** — 6 events.
3. **Permissions** — 9 events. Critical to debug funnel drop-offs.
4. **Activity tracking** — the 10 P0 events. The product core.
5. **Workout post-action** — 5 events.
6. **Gamification** — 9 events.
7. **AI Coach** — 7 P0 events. Cost monitoring depends on `ai_message_received.cost_usd` from day one.
8. **Subscription** — 11 events. Last to ship because it depends on StoreKit / Play / payment provider sandbox completion.

Gate to release: every P0 event passes the QA matrix (correct payload, no PII, fires once, offline queue intact).

### Phase 2 — P1 events (Week 3–6)

Ship the 23 P1 events:
- Training Plan (7), Social (7), Feature Usage (7), and the 2 P1 activity-tracking events (`lap_recorded`, `voice_coach_announcement_played`, `activity_edit_saved`), `ai_conversation_cleared`.
- Each event gated by the corresponding product feature reaching public release.

### Phase 3 — P2 events (Week 7+)

The 5 Settings events. Low priority — useful for personalization but not retention-critical.

### Continuous

- Dashboards 1–6 live by end of Phase 1. Dashboards 7–10 by end of Phase 2.
- North Star (WAS) reported manually in Phase 0 from raw `activities` table; automated dbt model live by Week 2.
- A/B experimentation queue starts EXP-001 in Week 4, after we have enough exposure volume.

---

## Ownership matrix

| Area | DRI | Reviewer |
|---|---|---|
| Event taxonomy | Data Eng lead | Growth PM |
| User properties | Data Eng lead | Growth PM |
| Funnels | Growth PM | Head of Product |
| Dashboards | Growth PM (D1–D6, D10), AI Eng (D7), Monetization PM (D8), Mobile Eng (D9) | Head of Data |
| North Star | CEO + Growth PM | Board (quarterly review) |
| Experiments | Growth PM | Data Eng + product area owner |
| Privacy / compliance | Legal | DPO + CTO |
| Flutter SDK | Mobile Eng lead | Data Eng lead |
| Warehouse | Data Eng lead | CTO |
| Documentation upkeep | Head of Data | All listed DRIs |

---

## Change-management protocol

1. Open PR against this folder.
2. Use the **EventChange template** (`.github/PULL_REQUEST_TEMPLATE/event-change.md`) for taxonomy changes — requires backward-compat impact analysis.
3. CI runs spec lint + Flutter codegen + dbt parse.
4. Two approvers required: Data Eng + the area DRI.
5. After merge: codegen runs, generated Dart enums + dbt sources update automatically.
6. Release notes posted in `#data-announcements` every Friday.

---

## On-call

- **Data Eng on-call** (PagerDuty): ingest pipeline failures, dbt run failures, ClickHouse downtime.
- **Mobile Eng on-call**: client SDK failures, offline queue overflow.
- **AI Eng on-call**: AI Coach cost spike, cache hit rate drop.
- **Growth on-call**: funnel regression alerts.

Runbooks: `/ops/runbooks/analytics-*.md`.

---

## Glossary

- **DAU/WAU/MAU** — distinct users with `app_opened` in 1/7/30 days.
- **WAS** — Weekly Active Streaks; user with ≥3 active days in last 7. **The North Star.**
- **Activation** — first `activity_saved` within 7 days of signup.
- **Stickiness** — DAU/MAU ratio.
- **k-factor** — viral coefficient = invites_sent_per_user × signup_conversion_per_invite.
- **MDE** — Minimum Detectable Effect, default 5% relative for our A/B tests.
- **SRM** — Sample Ratio Mismatch (sanity check for A/B exposure split).
