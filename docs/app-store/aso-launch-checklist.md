# RunVie — ASO & Launch Checklist (6-Week Runway)

> Owner: ASO Lead (DRI) + Head of Marketing + Engineering Lead
> Last updated: 2026-05-20 | Cadence: Daily standup W-2 onwards
> Launch date placeholder: **D-0**, working backwards

---

## Status legend

| Symbol | Meaning |
|--------|---------|
| [ ] | Not started |
| [~] | In progress |
| [x] | Done |
| [!] | Blocked, needs escalation |

---

## W-6 — Foundation Week

**Theme**: TestFlight beta, soft launch infrastructure.

| Owner | Task | Status |
|-------|------|--------|
| Engineering | Submit Build 1.0.0 (build #100) to TestFlight | [ ] |
| Engineering | Crash-free rate target: 99.7% on TestFlight before public beta | [ ] |
| QA | Smoke test 18 device matrix (iPhone 12 → 15 Pro Max, iPad mini → 12.9") | [ ] |
| Marketing | Recruit 1.000 beta testers via landing page waitlist + 50 Vietnamese running club partnerships | [ ] |
| Marketing | Onboarding email sequence for beta users (5 emails, 7-day cadence) | [ ] |
| Brand | Aurora brand system frozen — no color/font changes after W-6 | [ ] |
| Legal | Privacy Policy v1.0 published at runvie.app/privacy | [ ] |
| Legal | Terms of Service v1.0 published at runvie.app/terms | [ ] |
| Legal | Health disclaimer + age 13+ requirement language reviewed by counsel | [ ] |
| Data | Analytics SDK integration verified — Amplitude + Apple App Analytics + Firebase | [ ] |
| Data | Funnel events instrumented: install → onboarding → first run → first redeem | [ ] |
| Ops | App Store Connect account 2FA enabled for all 5 admins | [ ] |
| Ops | Google Play Console developer account verified, identity check completed | [ ] |

**Exit criteria**: 1.000 TestFlight invitees confirmed; crash-free >99.7%; legal pages live.

---

## W-5 — Localization Week

**Theme**: 15-language expansion infrastructure, even if Phase 1 launches VN-only.

| Owner | Task | Status |
|-------|------|--------|
| Localization | Vietnamese (vi-VN) — final QA by native linguist (DRI: Phạm Quỳnh) | [ ] |
| Localization | English (en-US) — copy editor pass | [ ] |
| Localization | Translation kickoff for: th-TH, id-ID, ms-MY, tl-PH, zh-Hant-TW, zh-Hans-CN, ja, ko, fr, de, es, pt-BR, ar, hi | [ ] |
| Localization | RTL layout test for Arabic | [ ] |
| Localization | Be Vietnam Pro font fallback for non-Latin scripts validated | [ ] |
| ASO | Store metadata localized vi-VN + en-US | [x] (this package) |
| ASO | Screenshots vi-VN + en-US production complete | [ ] |
| Engineering | Locale-aware date, currency, distance unit (km vs miles) | [ ] |
| Engineering | AI Coach language detection — fallback English if user device locale not vi/en | [ ] |
| Content | Calorie database VN dishes verified by nutritionist | [ ] |
| Content | Voucher partner logos legal clearance — Shopee, Grab, MoMo, GrabFood, Highlands, TCH | [ ] |

**Exit criteria**: vi-VN + en-US shipped complete; 13 other locales translation contract signed.

---

## W-4 — Editorial & Press Week

**Theme**: Land Apple App of the Day + tier-1 Vietnamese press embargo.

| Owner | Task | Status |
|-------|------|--------|
| CEO + ASO | Apple Vietnam editorial pitch sent via App Store Connect "Promote your app" | [ ] |
| CEO | Warm intro through Apple Developer Relations APAC contact | [ ] |
| Marketing | TestFlight reviewer code generated for Apple editorial team (5 codes) | [ ] |
| Press | Embargoed press kit sent to VnExpress, Tuổi Trẻ, Thanh Niên, GenK, VnReview | [ ] |
| Press | Embargo date set: launch day 09:00 ICT | [ ] |
| Influencer | Brief sent to 12 Vietnamese running/fitness creators (3 tier-1, 9 tier-2) | [ ] |
| Influencer | Creator gifting box: branded RunVie tee + Bát Tràng medal sample + Premium 1-year code | [ ] |
| Content | Press release draft v1 (Vietnamese + English) reviewed by PR agency | [ ] |
| Content | Founder interview Q&A doc prepared for media | [ ] |
| Brand | Hi-res asset pack on press.runvie.app — logo SVG/PNG, screenshots, founder photos | [ ] |
| Ops | Crisis comms playbook — server outage, data breach, negative press templates | [ ] |

**Exit criteria**: Apple editorial pitch acknowledged (reply within 7 days expected); 6+ Vietnamese press confirmed coverage.

---

## W-3 — Pre-Order & Marketing Warm-Up

**Theme**: App Store pre-order, paid acquisition pacing started low.

| Owner | Task | Status |
|-------|------|--------|
| ASO | App Store pre-order enabled (Apple supports pre-orders for free apps) | [ ] |
| ASO | Pre-order landing page hero CTA goes live on runvie.app | [ ] |
| ASO | Final metadata locked in App Store Connect — title, subtitle, description, keywords | [ ] |
| ASO | Final 8 screenshots + 30s preview video uploaded | [ ] |
| ASO | Privacy questions filled in App Store Connect — IDFA, location, health data | [ ] |
| ASO | App Privacy Report nutrition labels reviewed by privacy counsel | [ ] |
| Marketing | Meta + TikTok paid social warm-up campaign 10% of launch budget — measure CPM benchmark | [ ] |
| Marketing | Apple Search Ads (ASA) account set up, payment method verified | [ ] |
| Marketing | Influencer content production in flight (12 creators) | [ ] |
| Marketing | Email waitlist segmented by region (HN/HCMC/ĐN/other) for launch-day blast | [ ] |
| Engineering | App size optimized <120MB initial download, on-demand resources for heavier assets | [ ] |
| Engineering | Push notification provider stress-tested for 100k concurrent | [ ] |
| Support | Support email queue runvie.app/support live with SLA <12h | [ ] |
| Support | FAQ page seeded with 40 expected questions | [ ] |

**Exit criteria**: pre-order live; ASA account approved; all marketing materials final-final.

---

## W-2 — Paid Acquisition Warm-Up

**Theme**: Conversion rate optimization, ad creative final approval.

| Owner | Task | Status |
|-------|------|--------|
| ASO | Run Product Page Optimization (PPO) in App Store Connect — 4 variants of hero screenshot + 3 subtitle versions | [ ] |
| Marketing | TikTok Spark Ads from 12 influencers contracted into ad inventory | [ ] |
| Marketing | Meta CAPI events verified end-to-end install attribution | [ ] |
| Marketing | Google Ads UAC campaign drafted, ready to enable D-0 | [ ] |
| Marketing | YouTube Shorts ad cut from 30s preview video | [ ] |
| Engineering | Final build 1.0.0 (#150) submitted to App Store + Play Console for review | [ ] |
| Engineering | Review submission notes prepared: TestFlight reviewer credentials, demo account, feature walkthrough video | [ ] |
| Engineering | Backup build 1.0.1 ready with critical bug fixes if review delayed | [ ] |
| Data | Cohort dashboard live — Mixpanel + Amplitude installed, sample dashboards built | [ ] |
| Data | A/B testing infrastructure (Optimizely/in-house) tested on 5% of beta traffic | [ ] |
| Brand | Launch-day social asset pack — IG/TikTok/Facebook/LinkedIn — exported | [ ] |

**Exit criteria**: App in "Waiting for Review" or "In Review"; ads ready to enable; PPO variants live.

---

## W-1 — Final Sprint

**Theme**: Apple Search Ads campaigns live, budget pacing dialed in.

| Owner | Task | Status |
|-------|------|--------|
| ASO | Apple Search Ads campaigns enabled — keyword bid on top 15 from `keywords-research.md` | [ ] |
| ASO | ASA budget VND 60,000,000 (~ USD 2,400) week 1 cap | [ ] |
| ASO | Bid strategy: max CPT VND 8,000 for primary keywords, VND 4,000 for secondary | [ ] |
| ASO | Search Match enabled, monitor for cost spikes | [ ] |
| Marketing | TikTok Ads Manager campaigns launched at 20% target spend, scaling to 100% D-0 | [ ] |
| Marketing | Meta Ads campaigns same pattern | [ ] |
| Marketing | Influencer posts scheduled for D-0 0900-1200 ICT window | [ ] |
| Marketing | Push email waitlist scheduled D-0 06:00 ICT | [ ] |
| Marketing | TikTok creator activations confirmed — 12 creators posting D-0 to D+3 | [ ] |
| Support | On-call rotation defined for D-0 to D+7, 24/7 coverage | [ ] |
| Engineering | Last-mile fixes only — no new features in W-1 | [ ] |
| Engineering | Backend load test: 50,000 concurrent users sustained for 1 hour with <500ms p95 | [ ] |
| Ops | War room booked D-0 in office, also virtual via Slack #launch-war-room | [ ] |
| Ops | Status page status.runvie.app online | [ ] |
| Legal | Final review: privacy, terms, refund policy, IAP receipt validation | [ ] |

**Exit criteria**: App approved by Apple + Google; campaigns paid-ready; war room staffed.

---

## D-0 — Launch Day

**Theme**: Coordinate, monitor, respond.

### Hour-by-hour (Vietnam time ICT)

| Time | Activity |
|------|----------|
| 06:00 | Push email blast to 50,000 waitlist (subject: "Cảm ơn 6 tháng đồng hành — RunVie chính thức ra mắt") |
| 06:30 | Engineering checks: status page green, error rate baseline |
| 07:00 | Marketing: post to Facebook, Zalo OA, TikTok, IG, LinkedIn |
| 09:00 | Press embargo lifts. PR agency monitors coverage. |
| 09:00 | TikTok creator activations begin (12 creators across the day) |
| 09:00 | Apple App of the Day window — if approved, app appears in Today tab |
| 11:00 | Founder hosts livestream on Facebook + TikTok 30 min |
| 12:00 | Lunch-time push notification to early adopters: "Đã có 5.000 người tải. Đến lượt bạn." |
| 14:00 | Engineering ops check: server load, crash rate <0.5%, error rate <0.5% |
| 16:00 | Mid-day metrics review with leadership — installs, conversion, ASA spend pacing |
| 18:00 | Evening creator push (3 tier-1 influencers post 18:00-19:00) |
| 20:00 | Community livestream Q&A with founder + first 5 beta testers |
| 22:00 | End-of-day metrics roll-up; flag any urgent issues for D+1 |

### D-0 Targets

| KPI | Target |
|-----|--------|
| Installs day 1 | 30,000 |
| Conversion rate (impression → install) | >5% |
| Crash-free rate | >99.5% |
| Average rating after first 100 ratings | >4.5 |
| RunCoin first redemption | <2 hours after launch |
| Apple App of the Day | LANDED |
| Press coverage | 6+ tier-1 outlets live |

---

## D+1 to D+7 — Recovery & Acceleration Week

| Day | Focus |
|-----|-------|
| D+1 | Monitor crash rate <0.5%. If higher, ship 1.0.1 hotfix. |
| D+2 | Review prompt placement A/B test — when to ask for App Store rating. Target: ask after 3rd run completion, not before. |
| D+3 | Influencer batch 2 (9 tier-2 creators) posts. |
| D+4 | Engineering: Submit 1.0.1 with W-0 bug fixes + onboarding improvements based on funnel data. |
| D+5 | Marketing: scale ASA spend +50% if CAC <VND 35,000. |
| D+6 | Customer support audit: response time, ticket categories, common complaints. |
| D+7 | Week 1 retrospective — 90-minute meeting with full team. Lock priorities for v1.1 sprint. |

### D+7 Success Criteria

| KPI | Target |
|-----|--------|
| Total installs week 1 | 150,000 |
| Week 1 retention (D7) | >35% |
| App Store rating | >4.6 (min 500 ratings) |
| Avg session length | >8 min |
| AI Coach engagement | >40% of installs have 1+ chat |
| RunCoin redemption | >2,000 vouchers redeemed |
| Crash-free rate (all sessions) | >99.5% |
| ASA CAC | <VND 35,000 |
| Press coverage | 12+ outlets |

---

## Risk register (assign owner, mitigation)

| Risk | Likelihood | Impact | Owner | Mitigation |
|------|-----------|--------|-------|-----------|
| Apple rejects for HealthKit usage description | Medium | High | Engineering | Pre-submission review against guideline 5.1.2 |
| Apple rejects social feed moderation | Medium | High | Product | Default moderation queue, automated profanity filter VN dictionary, report flow in UI |
| Server outage launch day | Low | Critical | Engineering | Multi-region failover, 5x baseline capacity provisioned |
| Voucher partner pulls out 48h before launch | Low | Medium | BD | Backup partner pre-signed contingency |
| Negative viral review (TikTok takedown) | Medium | Medium | PR | Crisis comms playbook, founder personal response within 4h |
| Apple Editorial declines | Medium | Medium | Marketing | Plan B: paid acquisition push, organic press, ASA |
| App Search Ads cost spike >2× target | Medium | Medium | Marketing | Daily budget caps; pause keyword if CPT >VND 12,000 |
| Bát Tràng medal supply chain delay | Medium | Low | Ops | Stock 3-month buffer pre-launch |
| Vietnamese AI Coach hallucination | Medium | High | AI/ML | Output filter regex + moderation queue + user report mechanism |

---

## Sign-off

| Role | Name | Signed |
|------|------|--------|
| CEO | [Name] | [ ] |
| Head of Marketing | [Name] | [ ] |
| Head of Engineering | [Name] | [ ] |
| ASO Lead | [Name] | [ ] |
| Legal | [Name] | [ ] |
| Compliance | [Name] | [ ] |

Document version: v1.0 · 2026-05-20
Next review: Daily until launch, weekly post-launch through D+30.
