# North Star Metric — RunVie

## TL;DR

**Chosen North Star: Weekly Active Streaks (WAS)** = count of users who completed `activity_saved` on at least **3 distinct calendar days within the trailing 7-day window**, measured weekly.

It is the single number every team optimizes against. All other metrics are inputs or guardrails.

---

## Why a North Star

A North Star Metric (NSM) is the leading indicator of long-term customer value. For RunVie the NSM must:

1. Reflect the **core habit** (running consistently).
2. Be **observable weekly** for fast iteration.
3. Correlate with **retention and revenue** (so growing it pays back).
4. Resist gaming (cannot be juiced by marketing alone).
5. Align all teams (Acquisition, Product, AI, Monetization).

---

## Candidates evaluated

### Candidate 1: Weekly Active Streaks (WAS)
> Users with ≥3 calendar days of `activity_saved` in the last 7 days.

- **Pros:** Captures habit formation, threshold (3x/week) matches published running-adherence research, easy to communicate, correlates strongly with churn resistance (in similar apps, 3x/week users churn ~5× less than 1x/week).
- **Cons:** Slightly lagging (need a week of data); excludes power users doing 5x/week from feeling "extra credit" (but that is fine — we don't reward over-training).

### Candidate 2: Weekly Workout Minutes (WWM) per user
> Sum of `activity_stopped.moving_duration_s` per user per ISO week.

- **Pros:** Continuous signal, rewards intensity.
- **Cons:** Skewed by ultra users; a single 3-hour long run inflates the metric without indicating habit; encourages over-training and could trigger the AI safety system.

### Candidate 3: Active Days in Last 28 days (ADL28)
> Distinct days with any `activity_saved` in trailing 28d.

- **Pros:** Smooth, less noisy than weekly. Reflects cumulative engagement.
- **Cons:** Too lagging for weekly experiment iteration; doesn't distinguish habit vs sporadic engagement; harder for ops teams to act on.

---

## Tradeoff matrix

| Criterion (weight) | WAS | WWM | ADL28 |
|---|---|---|---|
| Habit signal (25%) | 5 | 3 | 4 |
| Retention correlation (25%) | 5 | 3 | 4 |
| Revenue correlation (20%) | 4 | 4 | 4 |
| Iteration speed (10%) | 5 | 5 | 2 |
| Gaming resistance (10%) | 5 | 2 | 4 |
| Communicability (10%) | 5 | 3 | 3 |
| **Weighted score** | **4.80** | **3.30** | **3.75** |

**Recommendation: WAS.**

---

## Operational definition (locked)

- **User in WAS for ISO week N** iff:
  - User has `paid_status != 'lapsed'` (we don't count zombie accounts), AND
  - count(distinct `date_trunc('day', activity_saved.timestamp)`) in [N-monday, N-sunday] >= 3, AND
  - `activity_saved.duration_s >= 600` (10 min minimum to filter accidental saves).

- **WAS = count(distinct user_id satisfying above)** per ISO week.
- Reported as absolute number AND as % of MAU (the "WAS rate").

---

## Input metrics ladder

Growth = product of conversion at each layer. To grow WAS we grow:

```
WAS_t = (Acquisition × Activation × Frequency × Retention)_t
```

| Layer | Definition | Driver team | Target Q2 |
|---|---|---|---|
| **Acquisition** | New users per week with `sign_up_succeeded` | Growth / Marketing | 8,000 / week |
| **Activation** | % of new users completing `activity_saved` within W1 | Onboarding PM | 50% |
| **Frequency** | Average active days per week among active users | Product + AI Coach | 3.2 |
| **Retention W4** | % of WAS users still WAS 4 weeks later | Retention PM | 55% |

Multiplicative model: 8,000 × 0.50 × (3.2 → cross-threshold 3x/week ratio ~62%) × 0.55 = ~1,365 *new sustained WAS users per week*. Steady-state WAS grows by this minus churn outflow.

---

## Guardrails (do not regress while moving WAS)

- `crash_free_users` ≥ 99.5%
- `ai_safety_block_triggered` rate < 1%
- Median `activity_stopped.duration_s` should not balloon >25% above prior 30d average (anti-over-training)
- Subscription gross churn < 5% monthly
- `account_deleted` rate < 0.2% monthly

Any experiment that moves WAS positively but violates a guardrail is **rejected** at experiment review.

---

## Reporting cadence

- WAS reported every Monday 09:00 ICT in `#growth-northstar` Slack channel.
- Dashboard tile pinned to D1 (Daily Active Overview).
- WAS shown alongside: 4-week trailing trend, WAS rate (% of MAU), and contribution breakdown by `country`, `tier`, `signup_source`.

---

## Long-term aspiration

If the team consistently achieves WAS rate ≥ 35% of MAU, we move to a **WAS-paid** variant (WAS users on a paid plan), tying the habit metric directly to revenue.
