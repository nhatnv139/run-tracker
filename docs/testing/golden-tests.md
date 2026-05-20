# Golden (visual) test policy

Golden tests pin pixel-accurate renders of critical UI screens so that
unintended visual regressions are caught at PR time.

## What we golden

| Screen | Reason | Path |
|--------|--------|------|
| Home dashboard (steps ring + streak) | Highly visible primary screen | `app/test/golden/home_golden_test.dart` |
| Activity summary modal | Triggered after every run | `app/test/golden/activity_summary_golden_test.dart` |
| Badge unlocked modal | Reward UX, must stay polished | `app/test/golden/badge_modal_golden_test.dart` |
| Paywall (Pro features) | Monetisation surface | `app/test/golden/paywall_golden_test.dart` |
| Wallet / Coin balance | Trust surface for monetisable rewards | `app/test/golden/wallet_golden_test.dart` |
| Onboarding step 1 | First impression | `app/test/golden/onboarding_step1_golden_test.dart` |

## What we do NOT golden

- Lists that vary per user (history, leaderboard).
- Heavy animations (use widget tests instead).
- Map widgets (network tiles vary across runs).

## Process

1. `flutter test --update-goldens` to regenerate.
2. Review the PNG diff in code review just like any other artefact.
3. Goldens live in `app/test/golden/_snapshots/` keyed by device.
4. CI runs on a single deterministic device (Pixel 7, dpr=1.0) to avoid
   font/anti-alias flakes; multi-device golden runs are nightly only.

## Approval

Two reviewers must approve any update to a golden PNG. The PR description
must include a screenshot diff or a callout explaining the change.

## Fonts

Use the `loadAppFonts()` helper so that text rasterisation is identical
across machines. Otherwise CI fails with anti-aliasing diffs.
