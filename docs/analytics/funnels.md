# RunVie Funnels

10 production funnels. Each row gives the expected industry benchmark (running/fitness apps, mixed mobile SaaS) and the RunVie target by end of Q2 launch. "Conversion" = step N+1 / step N unless noted. Window = 7 days unless stated.

---

## Funnel 1 — Acquisition to Activation

| Step | Event | Benchmark conv | RunVie target |
|---|---|---|---|
| 1 | install (store callback) | — | — |
| 2 | `app_opened` (first) | 70% | 80% (deferred deeplink) |
| 3 | `onboarding_completed` | 55% | 70% |
| 4 | first `activity_saved` | 35% | 50% |

End-to-end install → first saved workout: benchmark 13%, target 28%. Window: 7d.

---

## Funnel 2 — Onboarding completion (step-by-step)

7 steps: `welcome` → `goal_selection` → `level_selection` → `permissions_intro` → `location_grant` → `notif_grant` → `personalize_done`.

| Transition | Benchmark | Target |
|---|---|---|
| 1 → 2 | 92% | 95% |
| 2 → 3 | 88% | 92% |
| 3 → 4 | 85% | 90% |
| 4 → 5 | 78% | 85% |
| 5 → 6 | 70% | 80% |
| 6 → 7 | 90% | 95% |

End-to-end onboarding: benchmark 36%, target 56%. Largest drop at location grant.

---

## Funnel 3 — First-run trial (the "moment of value")

| Step | Event | Benchmark | Target |
|---|---|---|---|
| 1 | `activity_start_intent` | — | — |
| 2 | `activity_started` | 90% | 96% |
| 3 | `activity_stopped` | 75% | 85% |
| 4 | `activity_saved` | 88% | 95% |

End-to-end: benchmark 59%, target 78%. Largest drop = users abandoning before stop (GPS failure or quit). Watch `gps_signal_lost`.

---

## Funnel 4 — Paywall conversion

| Step | Event | Benchmark | Target |
|---|---|---|---|
| 1 | `paywall_viewed` | — | — |
| 2 | `plan_selected` | 18% | 28% |
| 3 | `purchase_initiated` | 80% | 90% |
| 4 | `purchase_succeeded` | 75% | 88% |

End-to-end paywall → paid: benchmark 11%, target 22%. Break down by `placement` and `experiment_variant`.

---

## Funnel 5 — Trial to paid

| Step | Event | Benchmark | Target |
|---|---|---|---|
| 1 | `trial_started` | — | — |
| 2 | trial active engagement (≥3 `activity_saved` in trial) | 40% | 55% |
| 3 | first `subscription_renewed` post-trial | 50% | 65% |

End-to-end trial → renewed paid: benchmark 20%, target 36%. Window: 14d (covers 7d trial + first renewal).

---

## Funnel 6 — AI Coach adoption

| Step | Event | Benchmark | Target |
|---|---|---|---|
| 1 | `app_opened` | — | — |
| 2 | `ai_chat_opened` | 25% (W1) | 40% |
| 3 | `ai_message_sent` | 70% | 82% |
| 4 | `ai_message_rated` thumbs_up | 50% | 65% |

End-to-end W1: benchmark 9%, target 21%. Guard: `ai_message_failed` rate <2%, p95 latency <3s.

---

## Funnel 7 — Social activation

| Step | Event | Benchmark | Target |
|---|---|---|---|
| 1 | `activity_saved` | — | — |
| 2 | `activity_shared` | 8% | 18% (Vietnam social-heavy) |
| 3 | `follow_clicked` (first) | 25% | 35% |

End-to-end first-saved → first-follow: benchmark 2%, target 6.3%. Strong viral coefficient input for `k_factor`.

---

## Funnel 8 — RunCoin loop

| Step | Event | Benchmark | Target |
|---|---|---|---|
| 1 | `activity_saved` | — | — |
| 2 | `runcoin_earned` | 100% (auto) | 100% |
| 3 | `marketplace_viewed` (within 7d) | 30% | 50% |
| 4 | `runcoin_redeemed` (lifetime) | 12% | 28% |

End-to-end save → redeem: benchmark 3.6%, target 14%. Loop driver = streak + voucher freshness.

---

## Funnel 9 — Re-engagement

Cohort = users with `last_active_at` ≥7 days ago.

| Step | Event | Benchmark | Target |
|---|---|---|---|
| 1 | re-engagement push sent | — | — |
| 2 | `push_opened` | 6% | 12% (personalized AI coach copy) |
| 3 | `app_opened` (from push) | 95% | 98% |
| 4 | `activity_started` within session | 18% | 30% |

End-to-end resurrected user: benchmark 1.0%, target 3.5% per campaign.

---

## Funnel 10 — Cancellation recovery

NOT a forward conversion funnel; it is a **reason-coded exit funnel** used for save-attempt design.

Steps tracked:
1. `paywall_viewed` from settings (cancel intent UX) — survey shown
2. Reason captured on `subscription_canceled.reason_code`
3. `subscription_canceled` confirmed
4. Re-subscribe within 60 days (`purchase_succeeded` with `is_renewal=false`)

Reason distribution benchmark (running apps):
- `too_expensive` 30%
- `not_using` 25%
- `bug_or_issue` 10%
- `missing_feature` 12%
- `temporary_pause` 8%
- `other` 15%

Win-back target: 8% of cancellers re-subscribe within 60d (industry 4%).

---

## Funnel monitoring rules

- All funnels rebuilt nightly in PostHog with **strict order** flag ON.
- A funnel drop of >5 percentage points week-over-week triggers PagerDuty to Growth on-call.
- Each funnel owned by named PM (see `README.md` ownership table).
- Segmentation toggles always available: `platform`, `country`, `signup_source`, `experiment_variant`, `paid_status`.
