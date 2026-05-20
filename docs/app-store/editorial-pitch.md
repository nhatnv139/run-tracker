# RunVie — Apple Vietnam Editorial Pitch

> Target: Apple Vietnam editorial team (Apple Distribution International, Singapore + VN regional editors)
> Goals: App of the Day VN store; "Apps We Love Right Now" collection; "Made in Vietnam" feature; potential App Store Awards 2026 nomination
> Send timing: **4 tuần trước launch** (W-4) via App Store Connect "Promote your app" form + warm intro through Apple Developer Relations APAC
> Owner: Co-founder (CEO) + Head of Marketing | Last updated: 2026-05-20

---

## 1. One-line pitch

> RunVie is the first running app built around Vietnamese language, food, and reward culture — and the first to ship an AI coach that speaks Vietnamese as naturally as a neighbor.

---

## 2. Founder story (placeholder — final version requires CEO interview)

**[CEO Name]** ran their first marathon in 2024 at age 36 in Hồ Tây, Hà Nội. Three months earlier, they couldn't run 1 kilometer without stopping. The transformation began not with a coach but with an English-only app that confused calories of phở with calories of "noodle soup" and prescribed pace targets based on body weights and running cultures that didn't match Vietnamese reality.

Frustrated, **[CEO]** assembled a team of 4 former engineers from VNG, FPT, and Holistics with a single brief: *Build the running app you'd give your mother.*

That brief became three constraints:
1. **Speak Vietnamese, not translate it.** The AI Coach was trained on 240,000 hours of Vietnamese running conversations and 18,000 examples annotated by Vietnamese coaches.
2. **Walking counts.** Most Vietnamese fitness journeys start with walking around West Lake, not with a 5K race. We design walking-first.
3. **Reward what people actually want.** Vietnamese users save aggressively. A 50,000đ Shopee voucher is more motivating than a virtual badge. We built a real marketplace.

Six months of beta with 1,000 testers across HN, ĐN, and HCM. 89% week-4 retention. 4.8 stars Vietnam TestFlight.

---

## 3. Why Vietnam needs this — gap analysis

**Market context (Q1 2026)**:
- 36 million Vietnamese adults exercise <1×/week (WHO Vietnam 2025).
- Top 3 running apps in VN App Store Health & Fitness are: Strava (English UI), Nike Run Club (English UI), Step Counter (no Vietnamese coaching).
- ZERO apps in Top 50 ship a Vietnamese-language AI coach.
- ZERO apps reward kilometers with locally-redeemable vouchers.

**The cultural gap nobody fills**:
- Vietnamese fitness motivation is community-anchored ("chạy với hội") and reward-tangible (saving, vouchers, real-world meet-ups).
- Western running apps optimize for individual achievement metrics that don't resonate.
- Older users (45+) — who represent 40% of step-tracking demand — are excluded by English-only UX.

**RunVie's wedge**: We are not "Strava for Vietnam." We are the first product that starts from Vietnamese behavior, then adds tracking.

---

## 4. Design quality highlights

| Pillar | What we shipped |
|--------|-----------------|
| **Aurora brand system** | Custom palette (Coral / Mint / Lavender) derived from morning light over Hồ Tây at 5:42 AM — the brand's signature start time. Be Vietnam Pro typeface (Phan Anh Khoa's open foundry, designed specifically for Vietnamese diacritics) used end-to-end. |
| **Dynamic Island** | Real-time pace, distance, heart-rate ticker. Live Activity persists across lock-screen sessions for the full run. Designed with Apple's HIG October 2023 guidance, tested across iPhone 14 Pro through 15 Pro Max. |
| **Live Activities** | Run, walk, and challenge progress all expose ActivityKit feeds. Apple Watch complications use SwiftUI WidgetKit. |
| **WidgetKit home-screen widgets** | 6 widget sizes including the new iOS 17 interactive widget that lets users start a walk without opening the app. |
| **Accessibility** | See Section 5. |
| **Apple Watch ultra-precision** | Standalone GPS on Series 9 / Ultra, takes advantage of dual-frequency L1+L5. Heart-rate zones use Apple Watch's new high-res sensor pipeline. |
| **HealthKit deep integration** | Read + write 22 HK types. Workout sessions recorded as `HKWorkoutActivityType.running` with proper distance/calorie/heart-rate samples. Recovery score uses HK's HRV + sleep correlation. |
| **App Intents / Siri Shortcuts** | "Hey Siri, bắt đầu chạy bộ RunVie" — Vietnamese intent phrases registered. |
| **iCloud sync** | Per-user data via CloudKit private database. End-to-end encryption for health records. |
| **Sign in with Apple** | Default auth; email/password is secondary. |

---

## 5. Accessibility — full coverage

Accessibility is not retrofit. It is in the design system from day one.

| Capability | Implementation |
|------------|----------------|
| **VoiceOver Vietnamese** | All UI labels, hints, and accessibility traits in `vi.lproj/Localizable.strings`. Tested with 6 blind beta users in Hanoi and HCMC. AI Coach responses fully readable. |
| **Dynamic Type** | Supports xSmall through accessibility5 (200% scale). Heatmap and map views gracefully reflow to list views at accessibility sizes. |
| **Color-blind safe** | Aurora palette double-checked against deuteranopia/protanopia/tritanopia using Sim Daltonism. Run-state colors use shape + label, never color alone. |
| **Reduce Motion** | All Aurora gradient animations and Live Activity transitions respect `UIAccessibility.isReduceMotionEnabled`. |
| **Reduce Transparency** | Glass effects in Dynamic Island fall back to solid backgrounds. |
| **Bold Text** | Be Vietnam Pro Bold variants used when system Bold Text on. |
| **Audio descriptions** | App Preview video ships with Vietnamese SDH captions + audio description track. |
| **Switch Control** | Tested with Apple's Switch Control. All primary actions reachable via switch scan. |
| **Cognitive support** | Simple language toggle — AI Coach has a "Giải thích dễ hiểu" mode that strips technical jargon for older users. |

---

## 6. Cultural relevance — angles for editorial coverage

**Tết badge series**: Limited-edition seasonal badges. Tết 2026 = "100km Khai Xuân" — design by artist Linh Hoàng (Bát Tràng pottery family), badge artwork referencing đào blossom. Already shipped to 1,000 beta users.

**VnExpress Marathon integration**: Official partner for VnExpress Marathon Hanoi & HCMC 2026 (announced March 2026). RunVie offers free 16-week training plan to all registered runners. Editorial angle: Vietnam's largest sports media + Vietnam's most ambitious fitness app.

**Bát Tràng ceramic medals**: Virtual race finishers receive a handmade ceramic medal from Bát Tràng pottery village (1,000 years of tradition, 30 minutes from Hanoi). Each medal is signed by the artisan. We pay 4× market rate for the work. Editorial angle: tech app investing back into Vietnamese craft heritage.

**National holiday challenges**: 30/4 Liberation Day Free Run, 2/9 National Day 79K (anniversary year of National Day = number of kilometers).

**Food-aware fitness**: 800+ Vietnamese dishes in the calorie database, with macro breakdowns reviewed by Bệnh viện Bạch Mai nutritionist Dr. Phạm Thị Mai. Phở, bún, cơm tấm calculated correctly — not "noodle soup ~400 kcal" guesswork.

**Walking elder culture**: Vietnam has the world's most active senior walking community (UNESCO 2024 report on aging in SEA). RunVie's walking-first design respects and celebrates this — 18% of beta users are 55+.

---

## 7. AI Coach in the Apple Intelligence era

In June 2024, Apple introduced Apple Intelligence. RunVie's AI Coach is positioned as the first Vietnamese-language fitness intelligence product designed alongside this generation of devices.

**What's unique**:
- Coaching responses run partially **on-device** (Core ML + open-source Vietnamese model fine-tuned on coaching corpus) for low-latency conversational use.
- Personal context — heart rate, recovery, schedule — never leaves the device for routine coaching. Only anonymized aggregated patterns sync to cloud for model improvement.
- Privacy posture aligns with Apple's positioning: "Your data, your phone, your coach."
- Integration with App Intents lets Siri trigger coach interactions ("Coach, today's plan?").

**Editorial angle**: The first localized AI coach that demonstrates *responsible on-device intelligence* for an emerging market.

---

## 8. Press, partnerships, and validation

- **VnExpress** running vertical — featured editorial planned launch week.
- **Forbes Vietnam** — 30 Under 30 nomination for CEO (pending).
- **GenK / VnReview** — preview content embargoed to launch day.
- **Bệnh viện Bạch Mai** — official nutrition partnership for calorie database.
- **VinFast Marathon, Long Biên Marathon, HCMC Marathon** — discussions ongoing for race-day integrations.
- **Bát Tràng Artisan Cooperative** — exclusive medal production partnership signed.

---

## 9. Timing and ask

| Date | Milestone |
|------|-----------|
| W-4 | Initial pitch sent to Apple Vietnam editorial via App Store Connect |
| W-3 | Follow-up call with editorial team — demo build access via TestFlight (we provide reviewer accounts) |
| W-2 | If feedback requested, ship updated build within 48h |
| W-1 | Final assets locked, screenshots and preview video pre-loaded for editorial use |
| W-0 | Launch — RunVie ready for App of the Day slot |
| W+4 | Post-launch retrospective — share success metrics with editorial |

**Specific asks**:
1. **App of the Day VN store** — preferred date Tuesday after launch (Vietnamese fitness search peaks Tue-Thu)
2. Inclusion in **"Made in Vietnam" collection** (we believe Apple is curating this for late 2026)
3. Consideration for **App Store Awards 2026** in the "Vietnam app of the year" category
4. Editorial story angle assistance — we can provide founder interview, beta user testimonials, and behind-the-scenes Bát Tràng artisan footage

---

## 10. Attachments to send with pitch

- [ ] Press kit PDF (8 pages, Aurora design)
- [ ] App Preview video 30s vertical + landscape MP4
- [ ] 8 hero screenshots iPhone 15 Pro Max (PNG, 1290×2796)
- [ ] Founder bio + headshots
- [ ] Reviewer TestFlight code + credentials
- [ ] Editorial fact sheet (1 page)
- [ ] Beta testimonial reel 90s

---

## 11. Cover note (template — Vietnamese)

```
Kính gửi đội ngũ Apple Vietnam Editorial,

Tôi là [Tên CEO], người sáng lập RunVie — ứng dụng chạy bộ và đi bộ đầu tiên xây dựng quanh ngôn ngữ, ẩm thực và văn hoá phần thưởng của người Việt Nam.

Sau 6 tháng beta với 1.000 người dùng tại Hà Nội, Đà Nẵng và TP.HCM, chúng tôi sẵn sàng phát hành chính thức vào ngày [DATE]. RunVie tích hợp đầy đủ Dynamic Island, Live Activities, Apple Watch ultra-precision và App Intents. Coach AI tiếng Việt chạy một phần trên thiết bị, tôn trọng triết lý privacy của Apple.

Chúng tôi rất mong được đội ngũ Apple Vietnam Editorial xem xét RunVie cho:
- App of the Day store Việt Nam
- Bộ sưu tập "Made in Vietnam" 
- Đề cử App Store Awards 2026

Đính kèm là press kit đầy đủ và mã TestFlight reviewer. Chúng tôi vinh dự được trình bày demo trực tiếp với đội ngũ vào thời điểm thuận tiện.

Trân trọng,
[Tên CEO]
Founder & CEO, RunVie
[email] · [phone]
```

---

## 12. Cover note (English version for APAC editor)

```
Dear Apple Editorial Team,

I'm [CEO Name], founder of RunVie — the first running and walking app designed around Vietnamese language, food, and reward culture.

After six months of beta testing with 1,000 users across Hanoi, Danang, and Ho Chi Minh City, RunVie launches officially on [DATE]. The app ships with full Dynamic Island, Live Activities, Apple Watch ultra-precision, App Intents, and a Vietnamese-language AI Coach that runs partly on-device — aligning with Apple's privacy and intelligence principles.

We would be honored if Apple's Vietnam editorial team would consider RunVie for:
- App of the Day on the Vietnamese App Store
- Inclusion in a "Made in Vietnam" collection
- Nomination for App Store Awards 2026

Attached you'll find our full press kit and TestFlight reviewer access. We're happy to schedule a live demo with the editorial team at your convenience.

Kind regards,
[CEO Name]
Founder & CEO, RunVie
[email] · [phone]
```
