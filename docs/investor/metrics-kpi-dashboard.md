# RunVie — KPI Dashboard Specification

Single source of truth for founder + investor monthly updates. Built in Mixpanel + ClickHouse + Notion. Snapshot the 5th of every month for investor letter; live for internal team daily.

---

## 1. North Star Metric

### Weekly Active Streaks (WAS)

**Definition:** Number of users who logged a workout (walking, running, or other tracked session) on at least 3 distinct days within the trailing 7-day window.

**Why this and not DAU or MAU:**
- DAU rewards passive opens; WAS rewards habit formation.
- 3-of-7 day threshold matches sports medicine consensus on minimum activity for cardiovascular benefit.
- Compounds with retention: if WAS goes up, MAU and paid conversion follow with 30-60 day lag.

**Targets:**
- M3 (closed beta): 35 WAS users (out of 500 testers)
- M6 (soft launch): 4,500 WAS
- M12 (Y1 EOY): 22,000 WAS
- M18: 80,000 WAS
- M24: 220,000 WAS

**Tracking:** ClickHouse query nightly, dashboard refresh by 8am VN time.

---

## 2. Acquisition Metrics

| Metric | Definition | Y1 Target | Tracking |
|---|---|---|---|
| **Installs (total)** | App Store + Play Store + Huawei first opens | 500k cum | App Store Connect, Play Console |
| **Organic install %** | Installs not attributed to paid campaign | 55%+ | AppsFlyer |
| **Paid install %** | Attributed to FB / TT / Zalo / Google UAC | 30% | AppsFlyer + ad platforms |
| **Partnership install %** | Brand co-marketing, KOL deals | 15% | Custom UTM + AppsFlyer |
| **CAC blended** | Total marketing spend / total new acquired users | USD 15 | Internal finance + AppsFlyer |
| **CAC by channel** | Spend / new installs from each paid channel | FB 12, TT 15, Zalo 8, GUAC 18 | AppsFlyer |
| **K-factor (referral)** | Avg invites sent × invite acceptance rate per user | 0.4 (Y1), 0.7 (Y2) | Mixpanel referral funnel |
| **Branded search rank** | Position in "ung dung chay bo" + "AI coach chay" VN App Store | top 3 by M9 | AppFollow ASO |

---

## 3. Activation Metrics

| Metric | Definition | Target |
|---|---|---|
| **Onboarding completion %** | Reached home screen with profile set + permissions granted | 72%+ |
| **First workout %** | Started any workout within 24h of install | 58% |
| **AI Coach first message %** | Sent first message to coach within 7 days | 42% |
| **D1 retention %** | Returned on day 1 | 55% (Y1), 62% (Y2) |
| **HealthKit / Health Connect grant rate** | Granted required permissions on first try | 78% |
| **RunCoin first earn %** | Earned at least 1 RunCoin within 7 days | 65% |

---

## 4. Engagement Metrics

| Metric | Definition | Target |
|---|---|---|
| **DAU** | Daily active users (any session) | 12-15% of MAU |
| **MAU** | 30-day rolling actives | 100k Y1 EOY |
| **DAU/MAU ratio** | Daily stickiness | 14%+ Y1, 18% Y2 |
| **Sessions per active user / week** | Avg workout count per active week | 2.8 |
| **Workouts per active user / week** | Same, filtered to logged workouts only | 2.3 |
| **AI Coach messages per active user / week** | Engagement with coach feature | 4.5 (Plus), 8 (Pro) |
| **Avg workout duration (min)** | Total minutes / total workouts | 28 min (walking blended) |
| **Avg km per active user / week** | Distance covered | 6.8 km |

---

## 5. Revenue Metrics

| Metric | Definition | Y1 Target | Y2 Target |
|---|---|---|---|
| **MRR (Monthly Recurring Revenue)** | Sum of all active subscription MRR | USD 26k @ M12 | USD 392k @ M24 |
| **ARR** | MRR × 12 | USD 700k @ M12 | USD 10M @ M24 |
| **Paying users** | Active Plus + Pro subscribers | 5,000 | 70,000 |
| **Paying conversion %** | Paying / MAU | 5.0% | 7.0% |
| **ARPU (paying user, monthly)** | MRR / paying users | USD 5.10 | USD 5.80 |
| **ARPU (all user, monthly)** | Total revenue / MAU | USD 0.58 | USD 0.83 |
| **LTV (24-mo horizon)** | ARPU × retention curve | USD 45 | USD 55 |
| **LTV / CAC** | Efficiency ratio | 3.0× | 3.5× |
| **B2B contracts signed** | Cumulative enterprise wellness deals | 10 | 100 |
| **B2B ARR** | Annualized B2B contract value | USD 80k | USD 2.0M |
| **Affiliate GMV (Shopee, Coolmate)** | RunVie-referred merchant GMV | USD 600k | USD 12M |
| **Affiliate revenue (4-8% of GMV)** | Take rate × GMV | USD 40k | USD 1.0M |
| **Sponsored revenue** | Brand-paid virtual races + campaigns | USD 380k | USD 1.0M |

---

## 6. Retention Metrics

| Metric | Definition | Target |
|---|---|---|
| **D1 retention** | Active on Day 1 from install | 55% Y1, 62% Y2 |
| **D7 retention** | Active on Day 7 | 38% Y1, 45% Y2 |
| **D30 retention** | Active on Day 30 | 15% Y1, 25% Y2 |
| **D90 retention** | Active on Day 90 | 8% Y1, 15% Y2 |
| **Paid annual retention** | Active paying user at month 12 / paying at month 1 | 65% Y1, 70% Y2 |
| **Reactivation rate** | Churned users who returned within 90 days | 12% |
| **Voluntary churn %** | Cancellations per month / paying users | 3.5%/mo Y1, 2.5%/mo Y2 |
| **Involuntary churn % (failed payment)** | Card decline rate | 2%/mo (regional FX issues) |

**Cohort visualization:** Monthly cohort retention curves (D1, D7, D30, D90, D180, D365) — published in every investor update.

---

## 7. Efficiency Metrics

| Metric | Definition | Target |
|---|---|---|
| **CAC payback (months)** | CAC / monthly contribution margin per paying user | 9 mo Y1, 7 mo Y2 |
| **Magic Number** | (Net new ARR × 4) / S&M spend | 0.7 Y1 → 1.2 Y2 |
| **Burn Multiple** | Net burn / net new ARR | 1.4 Y1 → 0.6 Y2 |
| **Months of runway** | Cash / monthly net burn | 18 at M1, 6 at M16 (Series A trigger) |
| **Revenue per employee** | ARR / headcount | USD 58k Y1, USD 357k Y2 |
| **Gross margin %** | (Revenue - COGS) / Revenue | 68% Y1, 76% Y2 |

---

## 8. Health Metrics (Product Quality)

| Metric | Definition | Target |
|---|---|---|
| **NPS** | Net Promoter Score (0-10 scale) | 50+ Y1, 60+ Y2 |
| **App Store rating (VN)** | Apple App Store stars | 4.6+ |
| **Play Store rating (VN)** | Google Play stars | 4.5+ |
| **Crash-free rate** | Sessions without crash | 99.5%+ |
| **AI Coach satisfaction (internal)** | 4-dim coaching quality, 5-pt scale | 4.0/5 |
| **Voice cue accuracy** | % of VN voice cues semantically + grammatically correct | 98%+ |
| **Customer support ticket resolution time (median)** | First response time to user emails | < 6 hours |
| **AI cost per active user / month** | Claude inference / active users | USD 0.12 blended (Y1), USD 0.08 (Y2) |
| **AI cost per paid user / month** | Claude inference / paid users | USD 0.43 (Y1), USD 0.30 (Y2) |
| **Battery drain per hour of tracking (iOS)** | Measured on iPhone 14 reference device | 7.2%/hr (lower than Strava 7.8%) |

---

## 9. Investor Monthly Update Template

Standard format, published 5th of every month.

```
RunVie — Monthly Update [Month YYYY]

TL;DR
- One headline win
- One headline challenge
- One ask of investors

North Star
- WAS this month: X (vs target Y, MoM growth Z%)

Acquisition
- New installs: X (organic %, paid %, partnership %)
- CAC blended: USD X
- Top performing channel: [channel]

Engagement
- MAU: X (MoM growth Y%)
- DAU/MAU ratio: X%
- Sessions per active user / week: X

Revenue
- MRR: USD X (MoM growth Y%)
- ARR run-rate: USD X
- Paying users: X (conversion %, churn %)

Cash
- Cash on hand: USD X
- Burn this month: USD X
- Runway: X months

Product
- Major releases this month
- Key beta feedback

Hiring
- New hires this month
- Open roles + recruiting status

Risks + Asks
- Top 1-2 risks I am thinking about
- Specific ask from investors (intro, advice, etc.)
```

---

## 10. Tooling Stack

| Tool | Purpose | Cost/month |
|---|---|---|
| Mixpanel | Product analytics, funnels, cohorts | USD 200 → 1,200 |
| ClickHouse Cloud | Analytics database, raw event store | USD 500 → 3,000 |
| AppsFlyer | Attribution, paid campaign measurement | USD 800 → 2,500 |
| AppFollow | ASO + competitor monitoring | USD 200 |
| Datadog | Infrastructure monitoring, APM | USD 400 → 1,500 |
| Sentry | Error tracking, crash reporting | USD 80 |
| Notion | Internal dashboards, investor portal | USD 50 |
| Carta | Cap table + ESOP management | USD 400 |
| Stripe + Apple/Google Console | Payment + subscription metrics | included in payment fees |

**Total tooling cost:** USD 2,630 → USD 9,000 over 24 months. Budgeted in financial model G&A line.
