# Experimentation Framework

PostHog Feature Flags + Experiments. Server-side exposure tracked via `$feature_flag_called` event, augmented by client `experiment_variants` super property on every event.

---

## Hypothesis template

> **If we** [change], **for** [user segment], **then** [primary metric] **will** [direction by X%] **because** [reasoned mechanism].
>
> **Guardrails:** [list]. **Counter-metrics:** [list].

Example, fully filled:

> **If we** show the paywall after the user's 2nd saved activity instead of after the 1st, **for** new free users in Vietnam, **then** trial start rate per paywall view **will** increase by ≥10% (relative) **because** users will have experienced more value and be more willing to evaluate Pro features.
>
> **Guardrails:** crash-free users ≥ 99.5%, D7 retention not down >2 pp.
> **Counter-metric:** uplift not driven by reduced paywall views (we check absolute trial_started count).

---

## Sample size calculator

Two-proportion z-test, two-sided α=0.05, power=0.80.

```
n_per_arm = ((z_{1-α/2} + z_{1-β})^2 × (p1(1-p1) + p2(1-p2))) / (p2 - p1)^2
```

Reference table (MDE = relative lift):

| Baseline p1 | MDE 3% | MDE 5% | MDE 10% | MDE 20% |
|---|---|---|---|---|
| 5% | 168,000 | 60,000 | 14,500 | 3,400 |
| 10% | 79,000 | 28,500 | 7,000 | 1,650 |
| 20% | 33,500 | 12,000 | 2,950 | 700 |
| 50% | 8,500 | 3,000 | 750 | 175 |

**Default MDE for RunVie experiments:** 5% relative on the chosen primary metric. Tests below 5,000 weekly exposures use 10% MDE.

Run length floor: 1 full ISO week to absorb weekly seasonality. Maximum: 4 weeks (beyond that, kill or split-decision).

---

## Statistical rules (decision protocol)

- **Significance:** p < 0.05 two-sided OR Bayesian posterior P(B>A) > 95% (PostHog uses Bayesian by default).
- **Peeking:** discouraged. Use sequential testing (PostHog supports) if peeking required.
- **SRM check:** Sample Ratio Mismatch test (chi-square) on exposure split. SRM p < 0.001 → halt and debug.
- **Guardrail breach:** any guardrail regresses with p < 0.05 → halt regardless of primary outcome.
- **Winner ship rule:** primary metric wins AND no guardrail breach AND minimum runtime met.

---

## 20 priority A/B tests (Q1–Q2 backlog)

Each row: experiment id, primary metric, expected baseline, target lift, segment, est. weekly exposures.

| # | Name | Primary metric | Baseline | Target lift | Segment | Weekly exposure |
|---|---|---|---|---|---|---|
| EXP-001 | Paywall placement: post-1st vs post-2nd save | Trial start / paywall view | 14% | +15% | Free new users | 6,000 |
| EXP-002 | Onboarding length: 5 steps vs 7 steps | Onboarding completion | 56% | +10% | All new installs | 8,000 |
| EXP-003 | Voice coach default voice (warm vs energetic) | Voice coach attach rate | 45% | +12% | First activity | 4,000 |
| EXP-004 | RunCoin reward amount: 100 vs 150 per workout | 7d active days | 2.4 | +5% | All active | 25,000 |
| EXP-005 | Push timing: 07:00 vs 18:00 local | push_opened CTR | 9% | +20% | Push-permitted | 30,000 |
| EXP-006 | Social feed sort: chronological vs algorithmic | Sessions/active user | 7.4 | +8% | Social-enabled | 12,000 |
| EXP-007 | Paywall headline: "AI coach" vs "training plan" lead | Trial start | 14% | +10% | Free | 6,000 |
| EXP-008 | Annual discount: 30% vs 40% off | ARPPU | $34 | +8% | Paywall viewers | 6,000 |
| EXP-009 | Onboarding: ask for HealthKit vs skip | Activation W1 | 50% | +5% | iOS new users | 5,000 |
| EXP-010 | Trial length: 7d vs 14d | Trial → paid | 50% | +10% | Trial starters | 2,500 |
| EXP-011 | AI Coach welcome message length: short vs medium | ai_message_sent rate | 32% | +15% | First chat opens | 3,000 |
| EXP-012 | Streak freeze auto-grant after first break | 28d retention | 22% | +6% | Streak holders | 8,000 |
| EXP-013 | Badge celebration: full-screen vs toast | Share rate post-badge | 4% | +20% | Badge earners | 5,000 |
| EXP-014 | Goal selection: visual cards vs list | Onboarding completion | 56% | +5% | New onboarding | 8,000 |
| EXP-015 | Home screen: feed-first vs start-button-first | First activity W1 | 50% | +8% | New users | 8,000 |
| EXP-016 | AI Coach model: Haiku vs Sonnet for plan advice | Thumbs-up rate | 78% | +5% | AI users | 4,000 |
| EXP-017 | Vietnam payment methods order (MoMo top vs App Store top) | Purchase succeeded | 11% | +12% | VN paywall view | 4,000 |
| EXP-018 | Marketplace voucher freshness email weekly digest | Redemption rate | 12% | +25% | Coin holders | 10,000 |
| EXP-019 | Race finisher post-prompt: share vs save medal | Share rate | 18% | +15% | Virtual race finish | 1,500 |
| EXP-020 | Cancellation save-attempt: discount 50% one month vs free month | Cancel-saved rate | 12% | +20% | Cancel intent | 1,000 |

Prioritization formula: **ICE = Impact × Confidence × Ease**. Backlog re-scored monthly; top 4 active at any time (PostHog interaction warning above that count).

---

## Guardrail metric library

All experiments must monitor:
- `crash_free_users_pct` (Sentry → PostHog mirror)
- `D7_retention`
- `activity_saved_per_user_w1`
- `subscription_gross_churn_30d`
- `support_ticket_volume` (Zendesk join)
- `ai_safety_block_rate` (for any AI-touching experiment)

Plus experiment-specific counter-metrics declared in the spec PR.

---

## Experiment lifecycle

1. **Proposal** — PR adds spec to `/docs/experiments/EXP-NNN.md` using hypothesis template.
2. **Review** — Growth PM + Data Eng + product area owner approve.
3. **Setup** — PostHog flag created with target allocation 50/50 (or multi-arm), exposure tracked.
4. **Pre-launch QA** — internal users tagged `is_internal=true`, excluded from analysis.
5. **Run** — minimum 7 days, max 28 days, SRM check daily.
6. **Decision** — ship / kill / iterate. Decision document appended to spec.
7. **Post-mortem** — even on ship: 1-week post-ship monitor.

---

## Anti-patterns (rejected at review)

- HiPPO ships without experiment.
- Stacking multiple changes in one arm without isolating.
- Choosing primary metric after seeing results.
- p-hacking via segment slicing — only pre-declared segments are valid for shipping decisions.
- Skipping guardrails because "this is a quick test."
