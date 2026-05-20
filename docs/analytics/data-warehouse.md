# Data Warehouse Architecture

Two-tier storage:

1. **ClickHouse (self-hosted, Hanoi DC)** — primary OLAP for product analytics + activity time-series.
2. **Postgres logical replica** — convenient row-store for joins, ad-hoc SQL, compliance audit, Metabase BI.

Tooling: **Metabase** (employee BI), **Hex** (data team notebooks), **dbt-clickhouse** for modeling, **Airbyte** for source ingestion, **Vector** for log shipping.

---

## 1. Sources flowing in

| Source | Cadence | Sink |
|---|---|---|
| PostHog Cloud-like (self-hosted) events | streaming via Kafka | ClickHouse `events_raw` (PostHog native) |
| PostHog nightly Parquet export | nightly 02:00 ICT | S3 → ClickHouse `events_audit` |
| App backend (Postgres OLTP — users, subscriptions, activities) | CDC via Debezium | Kafka → ClickHouse `oltp_*` mirror |
| Sentry events API | hourly pull | ClickHouse `sentry_events` |
| Stripe + StoreKit + Play webhooks | real-time | Postgres `billing` schema → ClickHouse mirror |
| Ad-spend (Meta/TikTok/Google) | daily | Airbyte → ClickHouse `marketing_spend` |
| AI Coach usage logs (LLM gateway) | streaming | Kafka → ClickHouse `ai_usage` |

---

## 2. ClickHouse schema

### 2.1 `events_raw` (PostHog native, do not modify)

PostHog manages this. We expose **`events`** as a `MATERIALIZED VIEW` for our modeling.

### 2.2 `events` (modeled wide table)

```sql
CREATE TABLE analytics.events
(
    event_id          UUID,
    event_name        LowCardinality(String),
    user_id           Nullable(String),      -- null for anonymous
    distinct_id       String,
    session_id        String,
    event_timestamp   DateTime64(3, 'UTC'),
    ingest_timestamp  DateTime DEFAULT now(),

    -- Common props promoted to typed columns for speed
    platform          LowCardinality(String),
    app_version       LowCardinality(String),
    country           LowCardinality(String),
    tier              LowCardinality(Nullable(String)),
    paid_status       LowCardinality(Nullable(String)),
    experiment_variants Map(String, String),

    -- Everything else
    properties        Map(String, String),
    properties_num    Map(String, Float64)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_timestamp)
ORDER BY (user_id, event_timestamp, event_name)
TTL event_timestamp + INTERVAL 13 MONTH
SETTINGS index_granularity = 8192;
```

Partitioning by month + ordering by `(user_id, event_timestamp)` is optimal for the dominant query pattern: "give me events for user X over period Y, joined to activities".

### 2.3 `activity_points` (GPS time-series)

```sql
CREATE TABLE analytics.activity_points
(
    activity_id     String,
    user_id         String,
    point_seq       UInt32,
    point_timestamp DateTime64(3, 'UTC'),
    lat             Float64,
    lon             Float64,
    altitude_m      Float32,
    speed_mps       Float32,
    hr_bpm          Nullable(UInt16),
    cadence_spm     Nullable(UInt16),
    accuracy_m      Float32,
    -- Privacy: lat/lon precision capped at 5 decimal places (~1.1m) at ingest.
    -- After 24 months: lat/lon NULLed, only per-km aggregates retained.

    week_bucket Date MATERIALIZED toMonday(point_timestamp)
)
ENGINE = MergeTree
PARTITION BY toMonday(point_timestamp)   -- weekly partitions
ORDER BY (activity_id, point_seq)
TTL point_timestamp + INTERVAL 24 MONTH;
```

Weekly partitions because activities are clustered in time and we frequently query "last week's runs". Daily partitions would explode part count.

### 2.4 `activities` (one row per saved workout)

```sql
CREATE TABLE analytics.activities
(
    activity_id        String,
    user_id            String,
    activity_type      LowCardinality(String),
    started_at         DateTime,
    duration_s         UInt32,
    moving_duration_s  UInt32,
    distance_m         UInt32,
    elevation_gain_m   Int32,
    calories_kcal      UInt32,
    avg_pace_s_per_km  UInt32,
    avg_hr_bpm         Nullable(UInt16),
    source             LowCardinality(String),
    gps_quality_score  Float32,
    created_at         DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(created_at)
PARTITION BY toYYYYMM(started_at)
ORDER BY (user_id, started_at, activity_id);
```

### 2.5 `users_snapshot`

```sql
CREATE TABLE analytics.users_snapshot
(
    user_id            String,
    snapshot_date      Date,
    paid_status        LowCardinality(String),
    tier               LowCardinality(Nullable(String)),
    current_streak_days UInt16,
    lifetime_workouts  UInt32,
    lifetime_distance_km Float32,
    country            LowCardinality(String),
    is_was_user        UInt8
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(snapshot_date)
ORDER BY (user_id, snapshot_date);
```

Filled daily by dbt model `users_snapshot.sql`.

### 2.6 `ai_usage`

```sql
CREATE TABLE analytics.ai_usage
(
    request_id        UUID,
    user_id           String,
    conversation_id   String,
    request_ts        DateTime64(3),
    model_used        LowCardinality(String),
    intent            LowCardinality(String),
    tokens_input      UInt32,
    tokens_output     UInt32,
    cached_tokens     UInt32,
    cost_usd          Float32,
    latency_ms        UInt32,
    streamed          UInt8,
    tool_calls_count  UInt8,
    safety_blocked    UInt8
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(request_ts)
ORDER BY (user_id, request_ts)
TTL request_ts + INTERVAL 13 MONTH;
```

---

## 3. dbt models

```
models/
  staging/
    stg_events.sql            -- 1:1 PostHog raw → typed columns
    stg_activities.sql
    stg_subscriptions.sql
  intermediate/
    int_user_session.sql      -- sessionize events
    int_funnel_steps.sql      -- one row per (user_id, funnel_id, step_index, ts)
  marts/
    mart_dau_wau_mau.sql
    mart_was_weekly.sql       -- WAS computation
    mart_retention_cohort.sql
    mart_revenue_mrr.sql
    mart_funnel_conversion.sql
    mart_ai_health.sql
  exposures/
    exp_metabase_overview.yml
```

Tests: `not_null`, `unique`, `relationships`, plus dbt-expectations for ranges (e.g., `gps_quality_score` 0-1, `distance_m` ≤ 200,000).

Run: hourly for staging, every 4h for marts.

---

## 4. Postgres logical mirror

Purpose: ad-hoc SQL by engineers without ClickHouse expertise + compliance audit (per `data-privacy.md` §9).

Schema mirrors ClickHouse marts, but:
- Decimal types preserved.
- Indexed for ad-hoc point lookup.
- Row-level retention enforced by `pg_partman`.

ETL: nightly **CDC reverse** via dbt-snowplow-style query → COPY into Postgres staging → swap.

---

## 5. Reverse-ETL pipeline (PostHog → S3 → ClickHouse audit)

```
PostHog -> nightly Parquet export -> s3://runvie-analytics/posthog/dt=YYYY-MM-DD/
   |
   v
ClickHouse `s3()` table function pulls + INSERT into analytics.events_audit
   |
   v
Postgres compliance_audit.event_archive synced from events_audit
```

Job runner: Airflow DAG `posthog_audit_etl`, schedule `30 03 * * *` ICT, 5-step DAG with retries=3.

Validation: row-count parity check between PostHog UI count and `events_audit` count for the day; alert on >0.1% drift.

---

## 6. BI access (Metabase / Hex)

- Metabase reads from **Postgres mirror** (employees, finance, ops).
- Hex reads from **ClickHouse** directly (data team only).
- Row-level security via Metabase sandboxes: marketing employees see only marketing schemas; support sees user-scoped lookups by `user_id_hash`.
- Audit log of all queries kept 90 days.

---

## 7. Cost & sizing assumptions

Year-1 estimates at 100k MAU:
- Events: ~50 events/DAU × 30k DAU × 30d = 45M events/month, ~12 GB compressed on ClickHouse.
- Activity points: 30k DAU × 0.5 workouts/day × 1,800 points = 27M points/day, ~10 GB/day raw, ~2 GB compressed. Weekly partitions = 7× = 14 GB/week.
- AI usage: ~5 messages/active user/week × 30k WAU = 150k req/week, negligible storage.
- Total ClickHouse storage Y1: ~3 TB compressed. Single-node m6i.4xlarge with 4 TB gp3 EBS is sufficient. Add replica for HA before Y2.

---

## 8. Backup & DR

- ClickHouse: daily `BACKUP TO S3` to `s3://runvie-backup/clickhouse/`. RPO 24h, RTO 4h.
- Postgres: WAL streaming to standby + nightly base backup. RPO 5 min, RTO 30 min.
- Quarterly restore drill.

---

## 9. Query examples

```sql
-- WAS for last week
SELECT count(DISTINCT user_id) AS was_users
FROM (
  SELECT user_id, count(DISTINCT toDate(started_at)) AS d
  FROM analytics.activities
  WHERE started_at BETWEEN toMonday(now()) - 7 AND toMonday(now())
    AND duration_s >= 600
  GROUP BY user_id
  HAVING d >= 3
);

-- D7 retention for last completed signup cohort
WITH signups AS (
  SELECT user_id, toDate(min(event_timestamp)) AS signup_d
  FROM analytics.events
  WHERE event_name = 'sign_up_succeeded'
  GROUP BY user_id
)
SELECT signup_d,
       count() AS cohort_size,
       countIf(returned.user_id IS NOT NULL) AS d7_returned,
       d7_returned / cohort_size AS d7_retention
FROM signups
LEFT JOIN (
  SELECT DISTINCT user_id, toDate(event_timestamp) AS d
  FROM analytics.events
  WHERE event_name = 'app_opened'
) returned
  ON returned.user_id = signups.user_id
 AND returned.d = signups.signup_d + 7
GROUP BY signup_d
ORDER BY signup_d DESC LIMIT 12;
```

---

## 10. Schema change governance

- All schema changes via PR with dbt model update + migration file + reviewer from Data Eng.
- Breaking change requires version bump + 30-day deprecation notice in `#data-announcements`.
- Backward-compatible additive changes (new column, new event property) ship freely.
