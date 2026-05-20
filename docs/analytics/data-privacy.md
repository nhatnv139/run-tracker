# Data Privacy & Compliance

Applicable regimes: **GDPR** (EU users), **Vietnam Nghị định 13/2023/NĐ-CP on Personal Data Protection** (primary), **Vietnam Luật Bảo vệ dữ liệu cá nhân (2025 draft)**, **Apple ATT**, **Google Play Data Safety**.

The default posture is **opt-in collection** for product analytics in jurisdictions that require it, **conservative defaults** everywhere.

---

## 1. PostHog client configuration

```dart
PostHogConfig('PHC_xxx', host: 'https://ph.runvie.app')
  ..captureApplicationLifecycleEvents = true
  ..captureScreenViews = false           // we tag screens manually
  ..captureDeepLinks = false             // manual handler scrubs UTM
  ..flushAt = 20
  ..flushInterval = 30
  ..maxQueueSize = 1000
  ..sendFeatureFlagEvents = true
  ..personProfiles = PersonProfiles.identifiedOnly  // critical
  ..sessionReplay = SessionReplayConfig(
        maskAllInputs: true,
        maskAllImages: true,
        maskAllText: false,   // we keep non-sensitive labels for replay quality
      )
  ..disableCompression = false
  ..respectDoNotTrack = true;
```

Key settings explained:

- **`personProfiles = identifiedOnly`**: PostHog does NOT create person profiles for anonymous users — drastically reduces stored PII volume and cost. Anonymous events still count for funnels.
- **`captureScreenViews = false`**: we manually whitelist screens via `analytics.screenView(name)`. This prevents auto-captures on health-related screens such as `healthkit_authorization`, `injury_log_detail`, `weight_history`, `period_tracking` (any HealthKit-derived view) and `profile_personal_detail`.
- **IP masking**: enforced server-side at PostHog ingest using `disable_ip = true` for events from Vietnam, EU, UK. Stored IP becomes `null`.
- **GeoIP coarse**: country and region only; city derived geo-IP disabled.

---

## 2. Session replay

- **Default OFF** on first launch.
- Turned ON for 10% sample of users **only** if `analytics_consent.session_replay == true` (separate toggle).
- **Mask rules** at recorder level:
  - `mask-input` on every input
  - `mask-text` class applied to: profile name, email, weight, height, age, HR readings, comments
  - body text in chat (AI Coach) **fully masked**
  - all images masked
- **Forbidden screens** (recorder paused): paywall payment sheet, HealthKit detail, settings → privacy, AI Coach (chat content too sensitive).
- Retention: 30 days then auto-purge.

---

## 3. Consent management

Onboarding step `consent_screen` (after `welcome`, before `goal_selection`) presents three toggles:

| Toggle | Default | Required to use app? |
|---|---|---|
| Product analytics (`analytics_consent.product`) | OFF in EU/UK/CH, ON elsewhere | No |
| Crash reporting (`analytics_consent.crash`) | ON | No, but recommended |
| Session replay (`analytics_consent.session_replay`) | OFF everywhere | No |
| Marketing analytics (`analytics_consent.marketing`) | OFF everywhere | No |

Consent state stored in `consent_log` table (server) with version, granted_at, ip_country, user_agent.

Withdraw: Settings → Privacy → "Manage data collection". Withdrawal takes effect within 60 seconds (next PostHog flush). Withdrawal triggers `posthog.optOut()` and clears local event queue.

---

## 4. PII hashing

- Salt stored in backend HSM (AWS KMS), rotated yearly. Mobile clients call `/auth/identify` endpoint which returns the hashed identifiers; clients never see the salt.
- Hashed fields: `email_hash`, `phone_hash`, `provider_id_hash`, `target_user_id_hash`, `from_user_id_hash`, `transaction_id_hash`.
- Server-side ingest filter (PostHog plugin) drops any event containing raw email/phone regex matches and alerts `#data-incidents`.

---

## 5. Data subject rights (GDPR Art. 15-22 + ND13)

| Right | How fulfilled | SLA |
|---|---|---|
| Access (data export) | Settings → Privacy → "Download my data". Server compiles ZIP from Postgres + ClickHouse + PostHog person export. | 30 days (ND13 = 72h for emergency, 15d standard; we exceed) |
| Rectification | Profile edit screen; backend overwrites with `$set` on PostHog. | Real-time |
| Erasure (right to delete) | Settings → Account → Delete. Triggers `account_deleted` event then async pipeline: hard-delete Postgres rows; PostHog `delete_person` API; ClickHouse `ALTER TABLE ... DELETE WHERE user_id = ...`; S3 backups quarantined and purged within 90 days. | 30 days hard-delete; 90 days backup purge |
| Restriction / Object | Settings → Privacy → consent toggles. | Real-time |
| Portability | Same as Access — ZIP includes JSON + GPX/TCX. | 30 days |
| Withdraw consent | Settings → Privacy. | Real-time |

---

## 6. Data retention

| Data class | Storage | Retention | Justification |
|---|---|---|---|
| Raw events (PostHog) | PostHog ClickHouse | **13 months** | Year-over-year analysis + 1 month margin |
| Identified person profiles | PostHog Postgres | **24 months** after last activity | Cohort and LTV analysis |
| Session replays | PostHog | **30 days** | Bug reproduction only |
| Sentry crashes | Sentry SaaS | **90 days** | Stability triage |
| ClickHouse activity points (GPS) | Self-hosted CH | **24 months raw, then downsampled** to per-km aggregates kept indefinitely (anonymized at 24m) | Personal training history |
| Reverse-ETL audit mirror (Postgres) | Self-hosted | **36 months** | Compliance audit |
| Consent log | Postgres | **For account lifetime + 5 years** | Legal proof of consent |
| Deleted-user tombstone | Postgres | **5 years** (user_id_hash only) | Prevent re-creation / chargeback dispute |

Retention enforcement: cron job `purge_expired_data` runs daily, dry-run weekly review.

---

## 7. Cross-border transfer

- Primary data residency: **Vietnam (Hanoi region)** for ND13 compliance. AWS ap-southeast-2 → ap-southeast-1 → self-hosted Hanoi DC.
- PostHog: self-hosted in our Hanoi DC.
- Sentry: SaaS EU region with EU SCCs; explicit user notice in Privacy Policy.
- Cross-border DPA (`Đánh giá tác động chuyển dữ liệu xuyên biên giới`) filed with MPS as required by ND13 Art. 25.

---

## 8. Children's data

- Minimum age 13 (16 in EU). Onboarding asks `age_range`; if `under_18` selected, we require self-attestation that user is ≥13/16 and disable social discovery and marketing analytics.

---

## 9. Reverse-ETL compliance mirror

PostHog → S3 nightly Parquet export → ClickHouse `events_audit` table → Postgres `compliance_audit` schema.

Purpose:
- Subject access requests (SAR) can be answered from a single Postgres query without depending on PostHog SaaS availability.
- Auditor read-only access via Metabase (no access to PostHog UI).

Schema:

```sql
CREATE TABLE compliance_audit.event_archive (
  event_id        UUID PRIMARY KEY,
  user_id         TEXT,                -- nullable for anonymous
  distinct_id     TEXT NOT NULL,
  event_name      TEXT NOT NULL,
  event_timestamp TIMESTAMPTZ NOT NULL,
  properties      JSONB NOT NULL,      -- already hash-redacted
  ingest_date     DATE NOT NULL,
  retention_until DATE NOT NULL
);
CREATE INDEX ON compliance_audit.event_archive (user_id, event_timestamp DESC);
CREATE INDEX ON compliance_audit.event_archive (retention_until);
```

Daily job `compliance_audit.cleanup_expired()` deletes rows past `retention_until`.

---

## 10. Apple ATT & Play Data Safety

- ATT prompt **only** if `analytics_consent.marketing = true`. If declined → no IDFA, no SKAdNetwork conversion value beyond install.
- Play Data Safety form mirrors this matrix in the in-app Privacy page (we keep a single source of truth in `/docs/legal/data-safety.json`, generated by the same lint that validates this spec).

---

## 11. Incident response

- Data breach (suspected or confirmed): notify DPO + CTO within 1 hour. ND13 requires MPS notification within 72 hours.
- Runbook: `/docs/legal/incident-response.md`.
- Tabletop exercise quarterly.

---

## 12. Lint & enforcement

Automated checks in CI:
- Event spec lint: rejects events with PII-shaped keys (`/email/`, `/phone/`, `/birthday/`, `/^address/`, `/raw_/`).
- Client SDK lint: forbids calling `posthog.identify` with values matching email regex (compile-time fail in Flutter `analyzer_plugin`).
- Quarterly data-flow review with Legal.
