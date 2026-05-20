# RunVie Analytics Dashboards

10 production dashboards in PostHog (and Metabase for finance). Each lists tiles (top-row KPIs + drill-down tiles), refresh cadence, owner, and alert thresholds.

---

## D1 — Daily Active Overview

**Owner:** Growth PM. **Refresh:** 15 min. **Audience:** All-hands.

Top tiles:
- **DAU** (line, 30d)
- **WAU** (line, 12w)
- **MAU** (line, 12m)
- **DAU/MAU stickiness ratio** (target ≥0.25 = stickiness "good"; ≥0.50 = "great")
- **Sessions per DAU** (target 1.6)

Drill-down: split by `platform`, `country`, `tier`.

Alerts: DAU drop >10% DoD → Slack `#growth-alerts`.

---

## D2 — Acquisition

**Owner:** Performance Marketing. **Refresh:** hourly.

- **Installs by source** (`first_utm_source`)
- **CAC by channel** = spend / new `sign_up_succeeded` (joined with Meta/TikTok/Google ad spend ETL into ClickHouse)
- **k-factor** = `invites_sent / new_signups` × `signup_per_invite` → target 0.35 by month 6
- **CTR install → first open** (deferred deeplink health)
- **Cost per activated user** = spend / users who hit `activity_saved` W1

Drill-down: source, campaign, country, device platform.

---

## D3 — Activation

**Owner:** Onboarding PM. **Refresh:** hourly.

- **Onboarding completion rate** (target 70%)
- **First-workout rate W1** (target 50%)
- **Median time-to-first-workout** (target <24h)
- **Permission grant rate** (location when-in-use, motion, notif)
- **Onboarding step-by-step drop-off heatmap**

---

## D4 — Engagement

**Owner:** Product. **Refresh:** hourly.

- **Workouts per active user per week** (target 2.8)
- **Average session length** (target 8 min outside activity, plus avg activity 35 min)
- **Screens per session** (target 6.5)
- **Active days in last 28d distribution** (histogram)
- **Streak holders distribution** (1-7 / 8-30 / 31-90 / 91+)
- **Voice coach attach rate** (% activities with `voice_coach_enabled=true`)

---

## D5 — Retention Cohorts

**Owner:** Growth Analytics. **Refresh:** daily.

- **D1 / D7 / D30 / D90 retention heatmap** (rows = signup week, cols = day offset)
- **Activity-based retention** (returning to do `activity_saved`)
- **Targets:** D1 = 55%, D7 = 35%, D30 = 22%, D90 = 15%
- Split toggle: `signup_source`, `tier`, `country`.

---

## D6 — Revenue

**Owner:** Finance + Monetization PM. **Refresh:** hourly (Metabase from Stripe/StoreKit/Play webhooks → Postgres → Metabase).

- **MRR** (split by tier, period)
- **ARR**
- **Paying conversion** = paying / signups
- **ARPU** = revenue / active user
- **ARPPU** = revenue / paying user
- **LTV** (cohort, 12m projected)
- **Gross churn % monthly** (target <5%)
- **Net revenue retention** (target ≥100%)
- **Vietnam payment mix** (MoMo/ZaloPay/VNPay/App Store/Play)

---

## D7 — AI Coach Health

**Owner:** AI Eng + Product. **Refresh:** 5 min.

- **Messages per active user** (weekly)
- **Cache hit rate** (avg `cache_hit_ratio` from `ai_message_received`) — target ≥85% (prompt caching strategy)
- **Cost per active user per month** — target <$0.30
- **Satisfaction rate** = thumbs_up / (thumbs_up + thumbs_down) — target ≥80%
- **p95 latency** — target <3s streamed first token <800ms
- **Safety block rate** — target <1%
- **Model cost split by `model_used`**

Alerts: cache hit rate drops below 70% → PagerDuty AI on-call.

---

## D8 — Subscription Health

**Owner:** Monetization PM. **Refresh:** hourly.

- **Trial start rate** (paywall view → trial start)
- **Trial → paid conversion** (target 55%)
- **30d / 90d / 180d churn**
- **Cancel reason Pareto chart** (`subscription_canceled.reason_code`)
- **Refund rate** = `refund_requested` / `purchase_succeeded` (target <2%)
- **Renewal rate** by tier × period
- **Recovered cancellers** (re-subscribed within 60d, target 8%)

---

## D9 — Performance & Stability

**Owner:** Mobile Eng. **Refresh:** 5 min. Source = Sentry + PostHog cross-join.

- **Crash-free users %** (target ≥99.5%)
- **Crash-free sessions %** (target ≥99.8%)
- **ANR rate (Android)** (target <0.3%)
- **Cold start p95** (target <2.0s)
- **Activity screen TTI p95** (target <1.5s)
- **GPS lock acquisition p95** (target <8s)
- **API p95 latency by endpoint**
- **Network error rate**

Alerts: crash-free users <99% in any 1h window → PagerDuty Mobile on-call.

---

## D10 — Funnel Performance

**Owner:** Growth PM. **Refresh:** hourly.

Tiles for the top 5 funnels from `funnels.md`:
1. Acquisition → Activation
2. Onboarding completion
3. First-run trial
4. Paywall conversion
5. Trial → paid

Each tile shows: latest conversion %, WoW delta, segmented breakdown by experiment variant.

Drill-down link to PostHog Funnel UI from each tile.

---

## Cross-dashboard governance

- All dashboards live in PostHog Project `runvie-prod`. Read access: all employees. Edit: Data Eng + named owners only.
- Versioned in Git via `posthog-as-code` (exported JSON in `/ops/posthog/dashboards/`).
- Monthly review meeting (last Friday) prunes stale tiles.
