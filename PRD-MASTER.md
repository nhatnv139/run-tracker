# PRD MASTER — Run Tracker App (Top App Store VN → Global)

> Tổng hợp từ 10 phân tích nghiệp vụ trong `analysis/`. Tài liệu này là single source of truth cho team build.
> Ngày tạo: 2026-05-20. Owner: chinh.

---

## 1. Executive Summary

**Tầm nhìn:** App chạy bộ + đếm bước + đếm calo người Việt làm chủ, **walking-first run-ready**, AI Coach tiếng Việt, target **top 10 App Store VN Health & Fitness trong 6 tháng**, top global trong năm 2, **1M MAU + $10M ARR năm 2**.

**3 USP cốt lõi:**
1. **AI Coach tiếng Việt tự nhiên** (Claude Sonnet 4.7 + ElevenLabs TTS giọng Bắc/Nam, voice cue mỗi km, chat dinh dưỡng + giáo án).
2. **Walking-first, Run-ready** — 80% user VN không phải runner; UX không "xấu hổ" cho người chỉ đi bộ, nâng cấp dần.
3. **RunCoin → Voucher fiat** Shopee/Grab/Highlands/MoMo (không crypto như StepN, không bot farm).

**Khoảng trống thị trường đánh trúng:** Strava/NRC yếu Á Đông; Sweatcoin walking-first nhưng UX kém; chưa app nào tích hợp AI coach VN + giải phong trào (VnExpress, Techcombank Marathon) + Zalo Mini App + AQI-aware (HN/HCM ô nhiễm).

---

## 2. Target User & Market

**Persona ưu tiên 6 tháng đầu (60-25-15):**
- **60% Linh** — NV văn phòng 25-32t, giảm cân, WTP 99k/mo. Volume + virality TikTok.
- **25% Minh** — Gen Z 18-24t, gamification, ARPU thấp nhưng UGC engine.
- **15% Trung** — PT/Coach, B2B2C, mỗi coach kéo 10-30 học viên trả phí.

Hoãn pha 2: Anh Hùng (marathoner niche, khó dứt Garmin/Strava), Bà Mai (UX khác biệt, ARPU thấp), Phương (mẹ bỉm).

**TAM/SAM:**
- VN: ~5-7tr người ngại tập + 1-2tr runner phong trào.
- SEA expand: Indonesia, Philippines, Thailand.
- Global năm 2: Mỹ + Tây Âu + Đông Á thông qua AI Coach đa ngôn ngữ.

---

## 3. Feature Scope

### MVP — Tháng 1-3 (P0)
| # | Feature | Lý do trong MVP |
|---|---------|----------------|
| 1 | Step Counter (CMPedometer + Health Connect) | Core walking-first |
| 2 | GPS Running/Walking tracker (Kalman + auto-pause) | Core tracking |
| 3 | Calorie calc (Mifflin-St Jeor + MET) | Promise đếm calo |
| 4 | History & Stats + GitHub heatmap | Retention anchor |
| 5 | Voice Coach VN cơ bản (10 phrase template) | USP #1 |
| 6 | 10 badge cốt lõi + streak + freeze 2/tuần | USP #3 base loop |
| 7 | Onboarding 7 bước < 90s | Conversion |
| 8 | HealthKit + Health Connect integration | Ecosystem |
| 9 | Live Activities + Dynamic Island | iOS native UX |
| 10 | Widget steps home screen | Daily touchpoint |

**Target MVP launch:** D7 retention ≥ 20%, 10k download organic 30 ngày, 4.5★, 5% paid conversion via reverse trial 14 ngày.

### V1 — Tháng 4-6 (P1)
- Training Plan adaptive (5K → marathon, Pfitzinger/Daniels templates).
- HR Zones Z1-Z5 + BLE HR strap (Polar/Wahoo).
- AI Coach chat (Claude Sonnet 4.7 + prompt caching 90%).
- Apple Watch native + Wear OS app.
- Strava 2-way sync.
- RunCoin redemption voucher Shopee/Grab/MoMo.
- 50+ badge + virtual race HN-SG 1730km (medal vật lý gốm Bát Tràng).
- Indoor mode + FTMS treadmill.
- Zalo Mini App share.
- Spotify/Apple Music Cadence Sync.

### V2 — Tháng 7-12 (P2)
- Social Feed (kudos, comment, club, story).
- Live tracking family safety + fall detection.
- Form analysis camera (MediaPipe on-device).
- Injury prediction LightGBM (ACWR + HRV + sleep).
- Nutrition photo món Việt (Gemini Flash fine-tune phở/bún/cơm tấm).
- Garmin Connect IQ Monkey C.
- Whoop/Oura/Fitbit recovery integration.
- B2B Corporate Wellness dashboard.
- Vinmec/Hoàn Mỹ checkup data partnership.
- AR coin spawn Phase 2.

---

## 4. Tech Stack Decision

**Mobile:** Native iOS-first (Swift + SwiftUI) tháng 1-6 → Android Kotlin + Compose tháng 7-9 với KMP cho domain layer. Loại Flutter/RN (background GPS không ổn).

**Backend:**
- Tháng 0-4: **Supabase** (Postgres + Auth + Storage + Realtime) — tiết kiệm 1 BE engineer.
- Tháng 4-12: tách Go (Fiber) microservices cho hot path; AI Coach service Python gọi Claude API.

**Data:** PostgreSQL + PostGIS (metadata), ClickHouse (time-series 324M rows/ngày), Redis (leaderboard ZSET), Cloudflare R2 (media, rẻ hơn S3 80% egress).

**Real-time:** MQTT EMQX (live tracking), SSE (leaderboard), không Firebase Realtime DB.

**Map:** Mapbox + self-host Tilemaker + OSM khi scale (giảm 80% cost).

**AI:**
- On-device: CoreML MoveNet form analysis (4MB), Voice TTS pre-render 500 phrase.
- Cloud: Claude Sonnet 4.7 với prompt caching 90% (Haiku 4.5 routing 70/30 → cost <$0.5/user/tháng).

**Infra:** GCP asia-southeast1 Singapore + Cloudflare CDN VN PoPs (HN/HCM/ĐN <20ms). Cost ~$8-10k/tháng ở 1M MAU.

**Observability:** PostHog self-hosted + Sentry + Grafana/Prometheus + OTel.

**CI/CD:** GitHub Actions + Fastlane + ArgoCD.

---

## 5. Design Direction

**Brand:** "Aurora Energy" — Coral #FF5A36 + Mint #00D4A8 + Lavender #7B5CFF. Typography minimal (Be Vietnam Pro). Trẻ-viral-TikTok nhưng vẫn premium cho sub 599k/yr.

**IA:** 5-tab Home / Activity / **Run-FAB** / Plan / Profile.

**Key screens:** Home 1-ring đơn + streak fire + suggested workout; Run screen chữ 96pt true black OLED (tiết kiệm 30-40% pin), swipe đổi metric, long-press lock; Post-run với Lottie PR + RPE picker + IG 9:16 share template.

**Stats anchor:** GitHub-style calendar heatmap 365 ô — retention feature số 1.

**Accessibility:** VoiceOver tiếng Việt ("Năm phẩy bốn hai cây số"), Dynamic Type XXXL, WCAG AA ≥ 4.5:1.

**Localization:** Be Vietnam Pro 9 weight, Locale("vi_VN") 1.234,5 km, tone "bạn".

---

## 6. Monetization

**Mô hình:** Freemium 3 tier + reverse trial 14 ngày (không yêu cầu thẻ).

| Tier | VN | Global |
|------|------|--------|
| Free | 0đ (có ads, history 30d) | $0 |
| Plus | 99k/mo — 599k/yr | $4.99/mo — $39.99/yr |
| Pro | 199k/mo — 1.499k/yr | $9.99/mo — $79.99/yr |
| Family (4-6 người) | 999k/yr | $59.99/yr |
| Lifetime (launch FOMO) | 4.999k | $249 |

**Paywall placement:** sau workout đầu + sau milestone 50km tích lũy + contextual feature gate (click AI Coach).

**Revenue mix Năm 2 ($10M ARR):**
- 60% Subscription Plus + Pro ($6M, 200k paid users)
- 20% B2B Corporate Wellness + Health Insurance ($2M)
- 10% Affiliate marketplace giày/race ticket ($1M)
- 5% Sponsored challenges Nike/Pocari ($0.5M)
- 3% One-time medal + IAP coin ($0.3M)
- 2% Ads ($0.2M)

**Payment VN:** Apple/Google IAP in-app (policy), Momo/ZaloPay/VNPay/VietQR cho web checkout (né phí store 15-30%).

**Unit economics target:** LTV $45 blended, CAC <$15, payback 9 tháng.

**AI Coach cost target:** <$0.5/user/tháng nhờ prompt caching 90% + Haiku/Sonnet routing + voice pre-render + batch API.

---

## 7. Growth Strategy

**ASO:**
- Title: "RunVie: Chạy Bộ & Đếm Bước"
- Subtitle: "Đo GPS, Calo, Giảm Cân"
- 8 screenshot kể chuyện hero map → paywall.
- Preview video 30s.
- Localize 15 ngôn ngữ ưu tiên SEA + US + Tây Âu.

**Launch sequence:**
1. Pre-launch 3 tháng: landing page + waitlist + TestFlight 1000 beta.
2. Soft launch Philippines/Indonesia (test paywall).
3. ProductHunt launch.
4. VN blitz: PR (VnExpress/ZNews/Cafebiz) + influencer (Nguyễn Văn Long + 20 runfluencer micro 30% commission) + Zalo OA seed.

**Paid acquisition:** Meta 35% / TikTok 30% / ASA 20% / UAC 15%. CAC VN $1.5-2.5, global $3.5-6. 50+ UGC creative/tháng.

**Retention tactics:**
- Push sequence D1/D3/D7/D14/D30/D60.
- Weekly recap email với chart đẹp.
- Referral 1-bạn-1-tháng (200 RunCoin sau khi referee chạy 5km).
- K-factor target 0.4-0.6.

**Partnerships:**
- VnExpress Marathon official tracker (BIB sync auto-finisher).
- Decathlon, Coolmate, California Fitness (affiliate).
- Bảo Việt/Generali (health insurance revshare).
- Vinmec/Hoàn Mỹ (checkup data partnership Năm 2).

**App Store Awards prep:** từ Q1 năm 1, angle "Vietnam's first AI running coach".

---

## 8. Roadmap 12 tháng

| Tháng | Milestone |
|-------|-----------|
| **M1** | Foundation: onboarding, step counter, calorie BMR/TDEE, dashboard. Hire iOS lead + designer. |
| **M2** | GPS tracker full + voice coach 10 phrase + auto-pause. TestFlight 200 user. |
| **M3** | History/heatmap + 10 badge + polish. **App Store submit + VN soft launch**. |
| **M4** | Training Plan adaptive + AI Coach chat. Reverse trial paywall. |
| **M5** | Apple Watch + Strava 2-way + Spotify Cadence. RunCoin redemption Shopee/MoMo. |
| **M6** | Virtual race HN-SG + medal Bát Tràng. **VN blitz launch**. Target: 100k download. |
| **M7** | Android KMP launch. Wear OS. Indoor mode FTMS. |
| **M8** | Form analysis camera + injury prediction. |
| **M9** | Social Feed + Club. **Soft launch SEA (PH/ID/TH)**. |
| **M10** | B2B Corporate Wellness dashboard. Partnership FPT/Viettel. |
| **M11** | Nutrition photo món Việt + AR coin Phase 2. |
| **M12** | **Global launch (US/EU)** + App Store Awards submission. Target: 500k download VN, 1M MAU global, $3M ARR. |

---

## 9. Success Metrics

| Metric | M3 | M6 | M12 | M24 |
|--------|-----|-----|-----|------|
| Download | 10k | 100k | 500k VN | 5M global |
| MAU | 3k | 30k | 200k | 1M |
| DAU/MAU | 30% | 40% | 50% | 55% |
| D7 retention | 20% | 30% | 40% | 45% |
| D30 retention | 8% | 15% | 25% | 30% |
| Paid conversion | 3% | 5% | 6% | 8% |
| Paying users | 100 | 1.5k | 12k | 200k |
| ARR | $5k | $80k | $700k | $10M |
| App Store rank H&F VN | top 50 | top 20 | **top 10** | top 5 |

---

## 10. Rủi ro & Mitigation

| Rủi ro | Mức | Mitigation |
|--------|-----|------------|
| iOS background GPS bị kill | Cao | Test 5 đời iPhone thật + adaptive accuracy + local notif fallback |
| AI Coach cost vượt $0.5/user | Cao | Prompt caching 90% + Haiku routing + voice pre-render + cap free 20 msg |
| Strava thu hồi quyền sync | Trung | Định vị "coaching", không clone segment; chuẩn bị fallback GPX import |
| Paywall quá sớm → churn VN | Cao | Reverse trial 14 ngày, soft paywall sau workout đầu |
| Cheat/farm RunCoin → voucher | Cao | Sensor fusion mismatch + mock location detect + KYC OTP >100k redeem |
| Compliance VN Nghị định 13/2023 | Cao | Replica data VNG/Viettel IDC HCM + DPO + consent từng category |
| Tốc độ ship chậm 6 tháng đầu | Cao | Supabase MVP + Native iOS only + KMP share logic + feature flag |

---

## 11. Team & Budget (đề xuất)

**Tháng 1-3 (3 người, ~$20k/tháng burn):**
- 1 iOS Senior Engineer (founder/CTO).
- 1 Product Designer (UX + brand Aurora).
- 1 Product/Growth (founder/CEO + ASO + content).

**Tháng 4-6 (6 người):** +1 Backend Go, +1 AI/ML, +1 Marketing.

**Tháng 7-12 (12 người):** +1 Android, +1 Apple Watch, +1 BE, +1 Designer, +2 Growth/Content.

**Burn năm 1:** ~$400-500k. **Funding target:** seed $1-1.5M (đủ 18 tháng + paid acquisition + B2B sales).

---

## 12. Quyết định cần xác nhận từ founder

1. **Tên app:** RunVie? Or khác? Cần check trademark + .com + ASO.
2. **iOS-first hay dual-platform**: đề xuất iOS-first 6 tháng — confirm?
3. **MVP scope cắt P1/P2:** confirm danh sách 10 tính năng MVP ở §3?
4. **Pricing tier:** 99k/599k và 199k/1499k — confirm?
5. **Brand Aurora vs Pace vs Cùng Chạy:** confirm "Aurora Energy"?
6. **Funding path:** bootstrap → seed M6 hay raise sớm M1?

---

## File reference

Toàn bộ phân tích chi tiết trong `analysis/`:
- `01-market-competitor.md`
- `02-personas-jtbd.md`
- `03-core-features.md`
- `04-gamification-social.md`
- `05-ai-ml-features.md`
- `06-health-integration.md`
- `07-monetization.md`
- `08-ux-ui-design.md`
- `09-tech-stack.md`
- `10-growth-aso.md`
