# Pre-launch bug bash (24h)

Run this script during the 24 hours before each public release.

## Participants

- 2 engineers (1 mobile, 1 backend).
- 1 designer.
- 1 product manager (organiser).
- Optional: 2-3 friendly external testers.

## Setup

1. Distribute a clean build to TestFlight + Play Store internal track.
2. Reset all participant accounts and pre-load 100 mock activities via
   `supabase/seed/bug_bash.sql`.
3. Pin the bug-bash Notion doc with the matrix below.

## Test matrix

For each combination, exercise the listed flow. Mark pass / fail / blocked.

| # | Device | OS | Network | Locale | Flow |
|---|--------|------|---------|--------|------|
| 1 | iPhone 15 | iOS 18 | Wi-Fi | vi-VN | Sign up -> 7-step onboarding -> first run |
| 2 | iPhone 13 mini | iOS 17 | LTE -> airplane mode | en-US | Run 5km -> badge -> share card |
| 3 | Pixel 8 | Android 14 | Wi-Fi | vi-VN | AI Coach: 10 message session, rate, retry |
| 4 | Pixel 6a | Android 13 | 4G (throttled to 1Mbps) | en-US | Sync 3 offline activities |
| 5 | Galaxy A54 | Android 13 | Wi-Fi | vi-VN | Redeem Shopee voucher, copy code |
| 6 | iPad (any) | iPadOS 17 | Wi-Fi | en-US | Layout / orientation smoke |
| 7 | Pixel 8 | Android 14 | Wi-Fi | vi-VN | Paywall flow + trial start + restore |
| 8 | iPhone SE | iOS 16 | LTE | vi-VN | Step counter + streak across midnight |

## Reporting bugs

- File in GitHub issues with label `bug-bash`.
- Severity:
  - **S1** crash, data loss, billing wrong -> blocker.
  - **S2** broken core flow -> must-fix before launch.
  - **S3** visual / minor UX -> next release.
- Attach device logs (`flutter logs`) and reproduction steps.

## Exit criteria

- Zero S1 / S2 open.
- All matrix rows green or explicitly waived by PM.
- Coverage targets still hit on `main`.
- All nightly CI runs green for the previous 48 hours.
