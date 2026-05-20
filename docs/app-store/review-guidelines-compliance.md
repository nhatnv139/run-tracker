# RunVie — Apple App Store Review Guidelines Compliance

> Owner: Engineering Lead + Legal Counsel (joint DRI) | Last updated: 2026-05-20
> Reference: Apple App Store Review Guidelines (current as of May 2026)
> Goal: ZERO rejections on submission; full audit trail for re-submissions if required.

---

## Compliance status legend

| Status | Meaning |
|--------|---------|
| Compliant | Verified, evidence on file |
| Needs action | Work in flight, owner assigned |
| Risk | Cannot fully verify, mitigation plan in place |
| N/A | Guideline does not apply to this version |

---

## 1.2 — Safety: User-Generated Content (UGC) Moderation

**Applies because**: RunVie ships a social feed (clubs, leaderboards, run posts, comments).

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| Mechanism for filtering objectionable content before it appears | Compliant | Automated profanity filter using Vietnamese-language dictionary (12,000+ banned terms + variants/leet) + Perspective API for English. Posts flagged with confidence >0.85 enter moderation queue before being public. | Engineering |
| In-app mechanism to report offensive content | Compliant | Long-press any post → "Báo cáo" sheet, 6 categories (spam, harassment, sexual, violence, false info, other). Routed to moderation queue. | Engineering |
| In-app mechanism to block abusive users | Compliant | Profile → "Chặn người dùng" — blocks all content + DMs from that user. Bi-directional. | Engineering |
| Developer commits to act on reports within 24 hours | Compliant | Moderation SLA: <12h response, <24h resolution. Moderation team 2 FTE Vietnamese-speaking, expanding to 4 at scale. | Operations |
| Block users that repeatedly violate | Compliant | 3-strike policy: warning → 7-day suspension → permanent ban. Documented in Community Guidelines. | Product |
| Terms of Service prohibits objectionable content | Compliant | runvie.app/terms section 4 explicitly prohibits hate speech, harassment, NSFW, illegal content, doping/cheating posts. | Legal |
| EULA visible during sign-up | Compliant | Onboarding screen 3/5 requires checkbox accepting ToS + Community Guidelines (links). | Engineering |

**Submission notes to Apple**:
> Our social feed has automated pre-publishing moderation, in-app report + block flows, 24h SLA, and 3-strike enforcement. Documentation: see attached Community Guidelines PDF.

---

## 2.1 — App Completeness (Crashes & Bugs)

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| Crash-free rate >99.7% TestFlight last 7 days | Needs action | Currently 99.4% — Engineering to ship build #150 with 3 fixes before submission. Target: 99.7% W-2. | Engineering |
| Demo account provided for review | Compliant | Reviewer credentials in submission notes: user `apple_reviewer@runvie.app`, password rotated weekly. Account pre-loaded with sample runs, RunCoin balance, and unlocked Premium. | Engineering |
| Server-dependent features functional during review | Compliant | Backend monitored 24/7, status.runvie.app public. Reviewer-IP allowlisted to bypass any geo-fences if applicable. | Ops |
| All advertised features in description work in app | Compliant | QA matrix maps each description feature to a regression test. | QA |
| No placeholder/lorem text in production build | Compliant | Linter rule prevents `lorem`, `TODO`, `FIXME`, `placeholder` strings in shipped strings files. | Engineering |

---

## 2.5.18 — HealthKit Usage Descriptions

**Applies because**: We read and write 22 HealthKit data types.

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| `NSHealthShareUsageDescription` provided | Compliant | Info.plist: "RunVie sử dụng dữ liệu sức khoẻ để theo dõi quá trình chạy bộ, đi bộ và đưa ra gợi ý luyện tập từ AI Coach. Dữ liệu sức khoẻ của bạn không bao giờ được bán cho quảng cáo." | Engineering |
| `NSHealthUpdateUsageDescription` provided | Compliant | Info.plist: "RunVie ghi lại buổi tập, lượng calo tiêu hao và quãng đường để bạn có lịch sử đầy đủ ngay trong app Health của Apple." | Engineering |
| Usage descriptions are specific (not generic) | Compliant | Both strings explicitly state the user-visible benefit + privacy stance. No generic "for app functionality". | Engineering |
| Health data not used for purposes outside HK's permitted use | Compliant | Code audit confirms HK data routes only to (a) UI display, (b) AI Coach on-device processing, (c) HealthKit write-back. Never to ads SDK, marketing analytics, or third-party. | Engineering + Legal |
| Localized usage descriptions in all supported languages | Compliant | InfoPlist.strings localized for vi-VN + en-US. Phase 2 locales pending. | Localization |

---

## 3.1.1 — In-App Purchase (IAP)

**Applies because**: RunVie offers Premium subscription (89.000đ/month, 690.000đ/year).

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| All digital subscriptions sold via StoreKit IAP | Compliant | StoreKit 2 implementation. No external payment links for Premium subscription inside app. | Engineering |
| Auto-renewing subscription terms displayed clearly | Compliant | Paywall screen shows: subscription title, length (1 month / 1 year), full price, free-trial duration, "auto-renews unless cancelled at least 24h before period ends", links to ToS and privacy. | Engineering |
| Subscription restoration mechanism | Compliant | Settings → "Khôi phục giao dịch" button calls `Transaction.currentEntitlements`. | Engineering |
| No "buying" of physical goods via IAP (would violate 3.1.5) | Compliant | RunCoin redemption for physical vouchers is a **reward** earned via app usage, not purchased. Premium subscription does NOT include guaranteed voucher amount. Disclaimer in paywall: "Premium tăng tỉ lệ tích luỹ RunCoin gấp đôi, KHÔNG bán RunCoin trực tiếp." | Product + Legal |
| Voucher redemption (Shopee/Grab/MoMo) handled outside IAP | Compliant | RunCoin → voucher conversion happens server-side via partner APIs. No money changes hands inside the IAP system for this. Vouchers are gifted as a loyalty program, not "sold". | Product + Legal |
| External payment for Premium subscription | Risk | Apple's 3.1.3(a) "Reader" exception does NOT apply. We do NOT promote external payment in app. Web checkout (runvie.app/premium) exists but is never linked from app to comply with 3.1.3(b) anti-steering rules pre-DSA. Vietnam is not yet under DSA exemption. | Legal |
| Family Sharing supported for subscriptions | Compliant | App Store Connect Family Sharing toggle enabled for both monthly and annual SKUs. | Engineering |

---

## 4.0 — Design

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| Original UI, not a copy of another app | Compliant | Aurora design system is custom, designed by [Brand Lead Name]. No template/copy of Strava/Nike Run Club layouts. Side-by-side comparison documented. | Design |
| Consistent design language across all screens | Compliant | Single design system documented in `figma.com/runvie-aurora`. | Design |
| No emoji in app description (style guideline 4.0) | Compliant | Description files audited — zero emoji. | ASO |
| App icon meets HIG (no text, no UI screenshots, original) | Compliant | Icon is Aurora gradient circle with stylized running figure. No text. 1024x1024 master. | Design |
| Splash screen / launch screen present | Compliant | Storyboard-based launch screen, Aurora gradient with wordmark. | Engineering |
| Supports modern iOS conventions (Dynamic Type, dark mode, etc.) | Compliant | See accessibility section in `editorial-pitch.md`. | Engineering |
| No spam/clone behavior | Compliant | RunVie is the first app from this developer account. | Compliance |

---

## 4.5.4 — Push Notifications

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| Push notifications NOT required for app functionality | Compliant | App fully usable with notifications disabled. | Engineering |
| User can opt-out per notification type in app settings | Compliant | Settings → "Thông báo" → 6 toggles: training reminders, RunCoin updates, club activity, voucher expiry, weekly report, system updates. | Engineering |
| No marketing push without explicit opt-in | Compliant | Promotional notifications (e.g., "Voucher mới Shopee!") are off by default. User opts in via "Khuyến mãi đối tác" toggle. | Engineering |
| No spammy push frequency | Compliant | Hard cap: max 3 transactional + 1 marketing push per user per day. Marketing windows: 09:00-21:00 ICT only. | Engineering |
| Push permissions request justified | Compliant | Permission prompt timed AFTER first run completed, contextual: "Bật thông báo để nhận gợi ý luyện tập từ AI Coach và cập nhật RunCoin." | Product |
| Push notifications must not contain advertising/promotion of third-party | Compliant | Only first-party content. Voucher-availability pushes refer to partner brand neutrally ("Voucher mới đã có") without ad copy. | Product |

---

## 5.1.1 — Data Collection and Storage (Privacy)

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| Privacy Policy URL provided and accurate | Compliant | runvie.app/privacy, version 1.0 published 2026-05-15. | Legal |
| App Privacy details in App Store Connect filled accurately | Needs action | Engineering + Legal joint review session scheduled W-3. Categories: Health & Fitness (linked to identity), Identifiers (used for analytics), Usage Data (used for analytics + product), Location (used for app functionality). | Engineering + Legal |
| Tracking permission via ATT prompt if needed | Compliant | NO third-party tracking. We do not request ATT prompt. App Privacy filed as "Data Not Used to Track You". | Engineering |
| Data collection minimization | Compliant | Onboarding asks only required fields (name, year of birth, weight, height). All optional fields clearly marked. | Product |
| User can delete account and all data in-app | Compliant | Settings → "Xoá tài khoản" → confirmation → hard delete within 30 days, soft-deleted immediately. SLA documented in privacy policy. | Engineering |
| User can export data in-app | Compliant | Settings → "Xuất dữ liệu" → ZIP file with JSON profile, GPX runs, PDF report. Email link. | Engineering |
| Health data retention policy stated | Compliant | Privacy policy section 6: health data retained while account active + 30 days post-deletion. | Legal |

---

## 5.1.2 — Data Use and Sharing (HealthKit specific)

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| HealthKit data NEVER used for advertising | Compliant | Code audit: no ads SDK (no AdMob, Meta SDK, etc.) integrated. App is ad-free in v1.0. | Engineering |
| HealthKit data NEVER used for data brokering | Compliant | Privacy policy explicit. Audited annually. | Legal |
| HealthKit data not shared with third parties without explicit user consent | Compliant | Only third-party that receives health data is: HealthKit itself (write back to Apple Health). No partner BD agreement involves health data. | Engineering + BD |
| HealthKit usage purpose disclosed in app | Compliant | First-run HealthKit prompt explains: "Để AI Coach hiểu nhịp tim, recovery, và đưa ra lời khuyên chính xác." | Engineering |

---

## 5.1.3 — Health, Fitness, and Medical Data

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| Medical disclaimer present | Compliant | Onboarding screen 5/5: "RunVie không thay thế tư vấn y khoa. Hỏi bác sĩ trước khi bắt đầu chế độ tập luyện mới." User must tap "Tôi hiểu" to proceed. | Product + Legal |
| App description includes medical disclaimer | Compliant | Last line of full description (vi + en) contains disclaimer. | ASO |
| Inaccurate data risks user health — accuracy validated | Compliant | Distance calibrated against Apple's reference data ± 1% accuracy. Calorie estimates use ACSM-standard formulas + Vietnamese-specific nutritionist review. | Engineering + Medical |
| No diagnostic claims | Compliant | AI Coach is trained NOT to diagnose. Refusal prompts when user asks about specific medical conditions (e.g., "Đầu gối đau" → coach suggests "nên gặp bác sĩ" + offers low-impact alternative, never prescribes treatment). | AI/ML |
| Emergency services not the responsibility of the app | Compliant | Run tracking is for recreational fitness. We do not advertise as a safety/emergency service. | Legal |

---

## 5.2.2 — Misleading Content / Trademark Misuse

| Requirement | Status | Evidence / Notes | Owner |
|-------------|--------|------------------|-------|
| App does not impersonate another brand | Compliant | RunVie wordmark trademark application filed Vietnam IP Office 2025-11-10, application #4-2025-12345. | Legal |
| Screenshots do not show third-party logos without authorization | Risk | Marketplace screenshot shows Shopee/Grab/MoMo logos. Written authorization from each partner obtained before submission. If any partner declines, replace logo with monochrome wordmark + "Coming soon". | BD + Legal |
| No false claims in metadata | Compliant | Avoided "best", "#1", "fastest". All factual claims (e.g., "800+ Vietnamese dishes") are accurate. | ASO |
| App description matches actual app behavior | Compliant | QA cross-checks each metadata claim against actual feature. Sign-off matrix complete. | QA |
| No mentions of other platforms / device names (e.g., "for Android") | Compliant | Description is platform-neutral wherever possible. Apple-specific features called out ("Live Activities", "Dynamic Island"). | ASO |

---

## Additional applicable guidelines

### 1.4 — Physical Harm
- Voice coach prompts during runs not to interrupt road safety. Coach provides hands-free audio only, never requires interaction while running. Status: **Compliant**.

### 1.4.1 — Medical advice claims
- We do NOT claim weight loss, disease prevention, or improvement of any medical condition in marketing. Status: **Compliant**.

### 2.3.1 — Accurate metadata
- No keyword stuffing. Description matches features 1:1. Status: **Compliant**.

### 2.3.7 — Metadata names
- No "free", "best", "top-rated" in app name/subtitle. Status: **Compliant**.

### 2.3.10 — Third-party promotion
- We mention Shopee/Grab/MoMo in description as partners. Written authorization obtained from each. Status: **Compliant** (pending final BD docs).

### 4.2 — Minimum functionality
- App offers substantial functionality: GPS tracking, AI coaching, social, marketplace. Clearly not a "thin wrapper". Status: **Compliant**.

### 4.2.6 — Apps created from a commercialized template
- RunVie is built from scratch by RunVie engineering team, not a template. Status: **Compliant**.

### 5.1.4 — Kids
- Age 4+ rating chosen (despite social feed) because moderation is strict and content is fitness-only. Sign-up requires age 13+ per ToS. NOT in Kids Category. Status: **Compliant**.

### 5.3.4 — Sweepstakes / contests
- Seasonal challenges (Tet 100km, Independence Day 79K) are skill-based contests, not random chance. Official rules published at runvie.app/contests. Status: **Compliant**.

---

## Pre-submission checklist (final pass)

- [ ] All "Needs action" items resolved to Compliant
- [ ] All "Risk" items have documented mitigation
- [ ] App Privacy details in App Store Connect submitted
- [ ] Demo reviewer account credentials in App Review notes
- [ ] Build signed with production certificate, not enterprise
- [ ] No private API usage (scan with private-api-checker tool)
- [ ] No competitor SDK that could trigger 5.6
- [ ] All third-party logos in screenshots have written authorization on file
- [ ] Vietnamese voice prompts checked by native QA for offensive misinterpretation
- [ ] Test on minimum supported iOS version (iOS 16.0)
- [ ] Test in Airplane Mode (graceful offline experience)
- [ ] Test sign-in flows: Apple ID, email/password, edge cases

---

## Sign-off

| Guideline section | Reviewer | Date | Notes |
|-------------------|----------|------|-------|
| 1.2 UGC | [Product Lead] | | |
| 2.1 Crashes | [Engineering Lead] | | |
| 2.5.18 HealthKit | [Engineering Lead] | | |
| 3.1.1 IAP | [Engineering Lead] + [Legal] | | |
| 4.0 Design | [Brand Lead] | | |
| 4.5.4 Push | [Product Lead] | | |
| 5.1.1 Privacy | [Legal] | | |
| 5.1.2 HK data | [Legal] | | |
| 5.1.3 Medical | [Medical Advisor] + [Legal] | | |
| 5.2.2 Misleading | [ASO Lead] + [Legal] | | |

**Final approval before submission**: [CEO signature]
