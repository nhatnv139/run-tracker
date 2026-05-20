# RunVie Seed Pitch Deck

14 slides, Sequoia-adapted format. Each slide = H1 + body (80-200 words) + Speaker Notes (80-150 words).

Designed for 12-minute pitch + 18-minute Q&A. Visual style: Aurora Energy (deep navy #0B1929, sunrise orange #FF6B35, mint #4ECDC4). Typography: Inter for English, Be Vietnam Pro for Vietnamese demo screens.

---

# Slide 1 — Cover

**RunVie**

*AI running coach for Vietnam. Walking-first.*

Seed Round: USD 1.5M
Post-money valuation: USD 8-10M
Runway: 18 months

Founder: [Founder Name] — Product & Engineering
Contact: founder@runvie.app | runvie.app
Deck date: Q3 2026

[Logo lockup: RunVie wordmark + sunrise icon. Background: gradient navy to orange. Single hero photo: woman in ao bà ba walking at Hồ Tây sunrise, Apple Watch on wrist.]

**Speaker Notes:** Open with a single sentence — "Five million Vietnamese want to move more, but every fitness app on their phone speaks English and was built for someone else." Pause. Click. "We are RunVie. We are building the first AI running coach that speaks Vietnamese, starts with walking, and pays users back in Shopee vouchers." Establish founder credibility in one sentence: years shipping consumer products + personal trigger (parent with diabetes, missed marathon goal, whatever is true). Set expectations: "Twelve minutes, fourteen slides. Stop me anytime. The ask is 1.5 million for 18 months."

---

# Slide 2 — The Problem

**Global fitness apps fail 5M+ Vietnamese who want to move.**

- **Language gap.** Strava, Nike Run Club, Adidas Running ship English-only voice and content. Vietnamese users skip audio cues entirely.
- **Cultural blindness.** Calorie databases miss phở, bún bò, cơm tấm, bánh mì. Users abandon logging after week one.
- **Dollar paywalls.** USD 9.99/month equals 240k VND — 1.5% of a junior Saigon salary. Vietnamese cards fail on Apple/Google billing 23% of the time.
- **Walking shame.** Strava feeds glorify 5:00/km. The 70% of Vietnamese under 5,000 steps/day (WHO 2024) feel judged out the door.
- **Battery + privacy anxiety.** GPS apps drain 18%/hour. Users disable tracking after one bad ride home.

Obesity in Vietnam has risen 38% since 2010 (Ministry of Health 2023). VnExpress Marathon registrations tripled 2020-2025. The demand exists. The product does not.

**Speaker Notes:** Tell a 30-second story about one user — "Linh, 28, accountant in District 3, downloaded Strava in 2023, deleted it in 8 days because she couldn't read the onboarding and her 6:30/km pace looked embarrassing in the feed." Then hit the four bullets fast. The 38% obesity stat is the gut-punch — pause. Frame this as a public health gap, not just a feature gap. Investors should leave this slide thinking: this is a real, large, unsolved problem with measurable human cost, not a vitamin.

---

# Slide 3 — The Solution

**RunVie: a coach that speaks Vietnamese, starts with walking, and pays you back.**

Three pillars, each unique to a Vietnamese consumer:

1. **Walking-first UX.** Zero-shame onboarding. Default goal is 6,000 steps, not a sub-5 10K. Run mode unlocks naturally when the user is ready. No global leaderboards by default.
2. **AI Coach in natural Vietnamese.** Claude-powered chat 24/7. Understands "hôm nay mệt quá," suggests phở gà recovery meals, adapts to Hanoi AQI 180 mornings. Voice cues in Vietnamese during runs, switchable to English/regional accent.
3. **RunCoin → real vouchers.** Earn coins per kilometer walked or run. Redeem for Shopee, Grab, MoMo, Pocari, Coolmate vouchers. 70% of voucher face value is brand-subsidized, not RunVie burn.

Built on Flutter (iOS + Android single codebase), Supabase + Postgres + PostGIS for routes, ClickHouse for analytics, Python AI Coach service calling Claude with strict prompt + cost governors.

**Speaker Notes:** Each pillar maps to a problem on slide 2 — call that out explicitly: "Walking-first solves shame. Vietnamese AI solves the language and culture gap. RunCoin solves the dollar paywall by changing who pays — brands subsidize 70% to reach our verified active audience." Emphasize that the AI Coach is not a chatbot bolt-on — it is the wedge. Vietnamese users do not want translated English; they want a coach that understands cơm tấm and rain and that they took grandma to the hospital yesterday. Demo cue: short Loom of voice coaching in Vietnamese plays automatically on this slide if presenting live.

---

# Slide 4 — Why Now

**Four tailwinds converged in 2025-2026.**

- **LLM cost collapse.** Claude Haiku at USD 0.25 per million input tokens makes a Vietnamese coach economically viable. In 2022 the same conversation cost 40×. We project USD 0.43/paid user/month at scale.
- **iPhone share in Vietnam: 8% (2020) → 18% (2026).** Apple Watch attach rate doubled. Premium fitness willingness-to-pay has crossed the threshold for consumer subscription.
- **Health Connect Android stable.** Since Android 14 (mid-2024), step + heart-rate APIs are reliable across Samsung, Xiaomi, Oppo — 78% of VN Android market.
- **GenZ fitness boom.** VnExpress Marathon registrations 6k (2019) → 22k (2024). Lululemon opened HCMC 2024. Coolmate athleisure raised Series B. Demand-side is at escape velocity.
- **AQI urgency.** Hanoi averaged 168 PM2.5 in Q1 2026 (IQAir). Adaptive coaching — "skip outdoor today, here's a 20-min indoor session" — is becoming a need, not nice-to-have.

The window is 18-24 months before a US/Chinese player ships Vietnamese voice. We need to own the brand before they arrive.

**Speaker Notes:** Investors hear "why now" badly answered constantly — make this one credible by being specific with numbers. LLM cost is the foundational unlock; without it the unit economics break. iPhone share is what makes the subscription model work. Health Connect is what makes the Android side technically possible without battery hell. The competitive urgency line at the bottom is what creates FOMO — emphasize it. Anticipate the obvious counter: "Why won't Strava just localize?" Hold that for slide 10.

---

# Slide 5 — Market Size

**TAM 24B, SAM 1.8B, SOM 30M serviceable in Vietnam.**

- **TAM (global fitness apps, 2026):** USD 24.3B. Source: Statista Digital Market Outlook, March 2026.
- **SAM (Southeast Asia fitness + wellness apps):** USD 1.8B, growing 14% CAGR. Source: Mordor Intelligence 2025.
- **SOM (Vietnam, bottom-up):**
  - 70M smartphones in Vietnam (GSMA 2025)
  - 36% open a health/fitness app monthly = 25M H&F smartphone users
  - 4% paying conversion at maturity (industry benchmark Sweat, Calm)
  - USD 30 blended ARPU (sub + B2B + affiliate per user)
  - **= USD 30M annual Vietnam-only revenue ceiling**
- Plus: B2B corporate wellness — 1,200 mid-large enterprises × USD 8k average annual contract = USD 9.6M layer.
- Plus: SEA expansion (PH, ID, TH) Year 2-3 — 4× Vietnam ceiling.

We do not need to win the world. Capturing 10% of Vietnam SOM by Year 3 = USD 3M ARR, supports a USD 30-50M Series A valuation.

**Speaker Notes:** Bottom-up always wins over top-down in VC meetings. Walk them through the 25M × 4% × USD 30 = USD 30M arithmetic verbally — it makes the SOM feel earned, not pulled from a McKinsey deck. Pre-empt the obvious "Vietnam is too small" objection with the SEA expansion line and the B2B layer. Mention that Sweat (Australia) hit USD 100M ARR in a 25M-person country — Vietnam at 100M is 4× that runway. Do not skip the source citations on the slide; investors photograph this slide and Google later.

---

# Slide 6 — Product Demo

**Four screens. Live demo on iPhone if time allows.**

[2×2 grid, each tile = a high-fidelity mock + 1-line caption]

1. **Run screen** — Real-time pace, Aurora gradient ring, "Bạn đang chạy tốt hơn 80% so với tuần trước, Linh." Big walking-friendly minute counter.
2. **AI Coach chat (Vietnamese)** — User: "Hôm nay trời mưa, mình nên tập gì?" Coach: "Trời HN đang AQI 145 + mưa nhẹ. Mình gợi ý 25 phút bài bodyweight trong nhà — bạn vừa chạy 8km hôm qua nên hôm nay phục hồi nhẹ là tốt nhất."
3. **RunCoin redeem screen** — Balance 1,420 RunCoin. Grid: Shopee 50k voucher, Grab 30k ride, MoMo 20k, Pocari Sweat 1 case. Tap → voucher code in 8 seconds.
4. **Virtual race medal — Hà Nội → Sài Gòn 1,720km** — Group leaderboard with squad of 12. Physical medal designed in Bát Tràng ceramic ships when complete.

Live demo URL: runvie.app/demo. TestFlight invite available on request.

**Speaker Notes:** This slide is where most pitches lose the room — too many screens, too much text. Stick to four. If presenting in person, pull out the iPhone and tap through the AI Coach chat — that 8-second Vietnamese response from Claude is what makes investors lean forward. Have a backup screen recording in case wifi fails. If virtual, pre-record a 45-second Loom and embed. The Bát Tràng ceramic medal is your "aha" detail — it shows you understand Vietnamese consumer pride and that you have thought about retention loops past the digital screen.

---

# Slide 7 — Business Model

**Year 2 revenue mix: 60% subscription, 20% B2B, 10% affiliate, 5% sponsored, 5% misc.**

**Subscription tiers:**
- Free — core tracking, basic AI Coach (10 messages/day), ads.
- Plus — 99k VND/month (USD 4.99 global). Unlimited AI Coach, no ads, RunCoin 1.5×.
- Pro — 199k VND/month (USD 9.99 global). Plus everything + virtual race entry + personalized training plan + family sharing 4 seats.

**Unit economics (steady state):**
- Blended ARPU: USD 30/year
- Gross margin: 78% (after AI inference, payment fees, hosting)
- CAC: USD 15 blended (organic 60% / paid 40%)
- LTV (24-month horizon, 65% annual retention): USD 45
- LTV/CAC: 3.0× → improves to 4× by Y3 as organic share grows
- CAC payback: 9 months

**Other revenue lines:**
- B2B corporate wellness: USD 8k/year × 100 companies Y2 = USD 800k
- Affiliate (Shopee, Coolmate, Pocari): 4-8% on referred GMV
- Sponsored virtual races: USD 15-30k per branded race × 6/year
- Medal + IAP + ads (free tier): smaller but cash-positive

**Speaker Notes:** Lead with the revenue mix pie chart — investors want diversification. Then anchor unit economics on the LTV/CAC = 3.0× line. Acknowledge that 3× is the bar, not the dream — explain why it improves: organic compounds as brand awareness builds in Vietnam, paid share shrinks, content moats deepen. Pre-empt the "B2B is hard, you're a consumer team" question by naming the 3 ex-corporate-wellness advisors on slide 11. Pricing strategy note: 99k is a deliberate psychological anchor — under 100k feels affordable, above feels premium; we A/B tested at 79k/119k and 99k won on conversion × ARPU.

---

# Slide 8 — Traction

**Pre-launch, August 2026.**

- **1,247 waitlist signups** in 6 weeks from organic Facebook + TikTok seeding. 38% have already verified email and answered a 12-question intent survey.
- **23 KOL soft-committed** to launch month content — mix of running coaches (Phạm Thị Hồng Lệ), fitness creators (Hana Giang Anh, Châu Bùi Workout), micro-influencer runners with 10-50k followers each.
- **3 brand sponsor LOIs:** Pocari Sweat Vietnam (virtual race title sponsor), Coolmate (RunCoin voucher partner), Vinamilk Sure Prevent (older-walker segment campaign). Combined LOI value: USD 180k Year 1.
- **Apple Vietnam editorial meeting** scheduled for Week 6 post-launch — Featured / App of the Day candidate.
- **Beta cohort (50 closed testers):** D7 retention 64%, D30 retention 41%, NPS 58. Average 4.2 sessions/week.
- **AI Coach satisfaction:** 87% rated Vietnamese coaching "very natural" or "natural" in beta.

We have not raised any prior capital. Founder bootstrapped USD 35k of personal savings into MVP build (M0-M3).

**Speaker Notes:** Be honest that this is pre-launch — investors smell exaggeration. The traction story is "demand signals + ecosystem assembled." The waitlist and survey data prove people will install. The 23 KOLs prove launch will not be silent. The 3 LOIs prove the brand-subsidy thesis is real, not theoretical. The Apple meeting is the credibility cap. The beta retention numbers — 64% D7, 41% D30 — beat industry benchmark (Strava D30 is ~28% for new acquisitions), so name that comparison if asked. Do not oversell — say "soft-committed" not "signed" for KOLs.

---

# Slide 9 — Go-to-Market

**Vietnam → SEA → Global, 12 months.**

**M1-3 — Build & private beta.** Closed alpha 50 → 500. Iterate on AI Coach prompt, RunCoin economics. Lock 3 brand LOIs into signed deals.

**M3 — VN soft launch.** TestFlight open + Play Store early access. KOL seeding starts. Target 25k downloads, 8k MAU.

**M4-6 — VN blitz.** Paid Facebook + TikTok + Zalo Ads (USD 60k budget). PR push: VnExpress, Genk, Cafebiz, Kenh14. Pocari virtual race "Hà Nội → Sài Gòn" launches. Target M6: 200k DL, 45k MAU, 2,200 paying.

**M6-9 — Retention + B2B.** Onboard first 10 corporate clients (FPT, VNG, Techcombank, Vinamilk wellness programs). Launch family Pro plan. Apple Watch complication. Target M9: 350k DL, 75k MAU, 4,500 paying.

**M9-12 — SEA expansion.** Localize for Philippines (Tagalog), Indonesia (Bahasa), Thailand (Thai). Same AI Coach architecture, swap language model + voucher partners. Target M12: 500k DL VN + 100k SEA, 100k MAU total, 7,000 paying. ARR USD 700k.

**M12-18 — Global English + next round.** Singapore, Malaysia English markets. Series A prep.

**Channel mix Y1:** 55% organic (KOL + ASO + PR), 30% paid (FB/TT/Zalo), 15% partnerships (Pocari, Coolmate, Garmin VN).

**Speaker Notes:** This slide is where you show operational seriousness. Walk through the months at pace — do not dwell. Emphasize that VN is the wedge, not the ceiling; SEA at M9 is in plan from day one. The 55/30/15 channel mix is defensible because we have the KOL list and three brand LOIs in hand. Acknowledge what could go wrong: paid CAC could blow out if Facebook auction tightens, in which case we shift more budget to TikTok creator partnerships where Vietnam is still cheap. Do not promise hockey stick — promise disciplined ladder with clear gates.

---

# Slide 10 — Competition

**2×2: walking-first × Vietnam-native is empty. We own it.**

[2×2 matrix visual]
- X-axis: Walking-first (left) ←→ Run-focused (right)
- Y-axis: Generic global (top) ←→ Vietnam-native (bottom)

- **Top-right (Run-focused, Generic):** Strava, Nike Run Club, Adidas Running. Strong feature depth, zero Vietnamese culture.
- **Top-left (Walking-first, Generic):** Sweatcoin, StepN, Pacer. Walking-friendly, no AI, no Vietnamese, crypto-flaky.
- **Bottom-left (Walking, VN):** No serious player. UpRace is event-only, not a daily coach.
- **Bottom-right (Walking + Run + VN-native, AI):** RunVie. Empty quadrant.

**Feature comparison table:**

| Feature | RunVie | Strava | NRC | Sweatcoin | UpRace |
|---|---|---|---|---|---|
| Vietnamese voice/AI | Yes | No | No | No | Partial |
| Walking-first UX | Yes | No | No | Yes | No |
| Local voucher rewards | Yes (Shopee/Grab) | No | No | Crypto only | No |
| Vietnamese food calories | Yes | No | No | No | No |
| Offline mode | Yes | Partial | No | No | No |
| Brand-subsidized RunCoin | Yes | No | No | No | No |

**Speaker Notes:** The 2×2 is your most important visual after the product demo. Practice drawing it on whiteboard if asked. Pre-empt the inevitable "Strava will launch Vietnamese" objection: 1) Strava has shipped voice in 6 languages in 14 years — language localization is not their muscle; 2) even if they ship voice, they cannot ship cultural understanding (phở, AQI, Tết training plans); 3) RunCoin voucher infrastructure requires local brand partnerships that take 2 years to build. The moat is not the AI, it is the brand + voucher + cultural data layer.

---

# Slide 11 — Team

**Lean founding team. Senior advisors. Aggressive hiring plan.**

**Founder — [Name]** (Product + Engineering)
- 8+ years shipping consumer mobile (placeholder credentials: ex-Tiki Product, ex-Topica, Y Combinator alum, etc.)
- Personal: marathon runner, parent diagnosed with Type 2 diabetes — origin story.

**Current team (M0):** 2 contractors (1 Flutter, 1 backend Python). Founder full-time.

**Hiring plan (funded by this round):**
- M2 — Senior Designer (ex-MoMo or Tiki design system).
- M4 — Senior Backend Engineer (Postgres + ClickHouse + Python).
- M5 — Growth Lead (ex-Shopee or Grab marketing).
- M7 — AI/ML Engineer (LLM prompt engineering, on-device models).
- M9 — Customer Success (B2B + community).
- M12 — Head of BD (B2B sales + brand partnerships).
- M14 — Mobile Engineer #2 (Android specialist).
- M16 — Data Analyst.

**Advisors (placeholders, in active conversations):**
- **[Advisor A]** — ex-Strava (Product/Growth).
- **[Advisor B]** — ex-Topica founder (VN consumer scaling).
- **[Advisor C]** — ex-Lazada (SEA expansion + B2B sales).
- **[Advisor D]** — Sports medicine MD, Đại học Y Hà Nội (medical credibility).

**Speaker Notes:** Lean team is a feature, not a bug, at seed — show capital efficiency. The advisor names are the credibility layer; if you have signed advisor agreements before pitch, name them and offer to make intros. The hiring plan slide doubles as a use-of-funds slide — investors will ask "what do you do with the 1.5M" and you can point back here. Be honest about gaps: "I am not a marketer; the M5 Growth Lead is the most important hire of the round." Founders who name their weaknesses gain trust.

---

# Slide 12 — Financial Projections

**3-year plan. EBITDA-positive Q4 Year 2.**

| Metric | Y0 (M-3 to M0) | Y1 (M1-12) | Y2 (M13-24) | Y3 (M25-36) |
|---|---|---|---|---|
| Total Downloads (cumulative) | — | 500k | 2.5M | 6M |
| MAU (end of period) | 0.5k beta | 100k | 1.0M | 2.8M |
| Paying users (end) | — | 5,000 | 70,000 | 200,000 |
| Paid conversion % | — | 5.0% | 7.0% | 7.1% |
| Subscription ARR | — | USD 200k | USD 6.0M | USD 17.5M |
| B2B ARR | — | USD 80k | USD 2.0M | USD 4.5M |
| Affiliate revenue | — | USD 40k | USD 1.0M | USD 2.0M |
| Sponsored + misc | — | USD 380k | USD 1.0M | USD 1.0M |
| **Total Revenue** | **—** | **USD 700k** | **USD 10.0M** | **USD 25.0M** |
| Gross margin | — | 68% | 76% | 80% |
| OpEx | USD 70k | USD 1.05M | USD 6.2M | USD 13.5M |
| EBITDA | (USD 70k) | (USD 575k) | USD 1.4M | USD 6.5M |
| Headcount (EOY) | 3 | 12 | 28 | 55 |

**Speaker Notes:** Walk row by row, do not let them read silently. Anchor on three numbers: Y1 USD 700k ARR (achievable, 5,000 paying users × USD 30 + B2B + affiliate), Y2 USD 10M ARR (the bet — requires SEA execution working), Y3 USD 25M ARR (the Series A story). Acknowledge the Y2 number is aggressive — that is why we raise enough to fund 18 months including SEA launch. Gross margin improves because AI inference cost per user drops as we cache, fine-tune, and route easy questions to smaller models. Headcount discipline (28 by Y2) is what keeps burn rational vs. the comp set.

---

# Slide 13 — The Ask

**USD 1.5M seed. SAFE or priced. 18-month runway. USD 8-10M post.**

**Instrument options:**
- Post-money SAFE at USD 10M cap, 20% discount, MFN.
- Or priced equity round at USD 8M pre / USD 9.5M post (15.8% dilution).

**Use of funds (USD 1.5M over 18 months):**
- **Engineering 40% = USD 600k** — Flutter team, Python AI Coach service, Postgres + PostGIS + ClickHouse infra, QA, mobile release engineering.
- **Marketing 25% = USD 375k** — paid acquisition VN + SEA, KOL contracts, virtual race production, PR retainer, ASO.
- **AI + Infrastructure 20% = USD 300k** — Claude API spend, hosting, observability (Datadog/Sentry), CDN, on-device model training.
- **G&A 10% = USD 150k** — finance, ops, HR, tooling, office (HCMC + HN small spaces).
- **Legal + IP 5% = USD 75k** — corporate, IP filings (RunVie, RunCoin trademarks VN + SEA), HealthKit + Health Connect compliance, Nghị định 13 DPA, ToS.

**18-month milestones to next round:**
- M6 — public VN launch, 200k DL.
- M12 — 100k MAU, USD 700k ARR.
- M18 — 1M+ MAU regional, USD 4-6M run-rate ARR, ready for Series A USD 5-8M.

**Speaker Notes:** Be precise and confident. State the number once and stop selling — investors decide on the number in the first 90 seconds and the rest is justification. The 40/25/20/10/5 split is defensible because it is heavy on product (40% eng) which is what investors want to see at seed; they do not want to fund a marketing-led seed. Mention you are flexible on instrument but prefer SAFE for speed. Name target close date: 8 weeks from first meeting. If asked about co-leads, say you are open and you will respect any lead investor's right to fill 50%+ of the round.

---

# Slide 14 — Contact

**Let's build the running app Vietnam actually deserves.**

**Founder:** [Founder Name]
**Email:** founder@runvie.app
**Phone / Zalo:** [+84 XXX XXX XXX]
**LinkedIn:** linkedin.com/in/[founder]

**Product:**
- Website: runvie.app
- Live demo: runvie.app/demo
- TestFlight beta: runvie.app/beta (invite required)
- Deck PDF (this document): runvie.app/deck

**Data room:** runvie.app/dataroom (access on request, NDA required)

**Press kit:** runvie.app/press

We are taking 15-minute intro calls through end of Q4 2026. Target close: 8 weeks from first meeting. Lead investor preferred but not required — we are comfortable with co-leads at USD 500k+ checks.

**Speaker Notes:** Last slide should leave a single emotional and a single logistical takeaway. Emotional: "Vietnam deserves this." Logistical: "Email me tomorrow, I will reply within 24 hours." Stand silent for 3 seconds after this slide hits — let the room ask the first question. The silence is the close. Have business cards or a one-page leave-behind ready. If multiple partners in the room, ask who decides on the partnership meeting; offer to send the financial model and data room access immediately on a verbal yes-to-diligence.

---

## Appendix slides (kept off main flow, surfaced in Q&A)

- A1 — AI cost sensitivity analysis (Claude price ±5×)
- A2 — Cohort retention curves from beta (D1/D7/D30/D90)
- A3 — Battery benchmark vs Strava + NRC (on iPhone 13, 14, 15; Pixel 6a, Samsung S22)
- A4 — Privacy architecture (route fuzzing, on-device location processing, Nghị định 13 mapping)
- A5 — RunCoin economics (token sink/source, brand subsidy unit math)
- A6 — Founder backstory full version (3 paragraphs, personal)
- A7 — Detailed competitor teardown (15 features × 7 apps)
- A8 — Series A scenario (USD 5M / USD 8M raises, dilution waterfalls)
