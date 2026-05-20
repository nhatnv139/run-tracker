# Architecture Decision Records (ADR)

Quyết định lớn được ghi lại để không lặp lại tranh luận.

---

## ADR-001 — Flutter thay Native iOS-first

**Ngày:** 2026-05-20
**Status:** Accepted

**Context:** PRD ban đầu chọn Native iOS Swift làm framework 6 tháng đầu vì Health & Fitness category iOS sinh 70% revenue và background GPS chỉ ổn định khi gọi native.

**Vấn đề:** User phát triển trên Windows 11, chưa có Mac. Native iOS yêu cầu Xcode (macOS only).

**Lựa chọn:**
- A. Native iOS — chờ user mua Mac hoặc thuê cloud Mac (Codemagic/MacStadium).
- B. **Flutter 3.27** cross-platform — chọn.
- C. React Native — loại (BG GPS unreliable, performance kém).
- D. PWA-first — loại (không HealthKit, không pedometer background tốt).

**Quyết định:** Flutter 3.27 + `geolocator` + `flutter_background_service` + `pedometer` plugins.

**Tradeoff chấp nhận:**
- Background GPS workable nhưng cần tune kỹ (foreground service Android, location BG mode iOS).
- iOS build cần Codemagic/Xcode Cloud từ Windows (~$30-100/tháng).
- 1 codebase iOS + Android tiết kiệm 40% thời gian dev.

**Revisit khi:** Đạt PMF (M6), có doanh thu trang trải Mac + iOS engineer → migrate sang Native iOS nếu battery/performance issue rõ ràng.

---

## ADR-002 — Supabase MVP thay vì self-host

**Ngày:** 2026-05-20
**Status:** Accepted

**Context:** Cần backend nhanh cho MVP 3 tháng.

**Quyết định:** Supabase (managed Postgres + Auth + Storage + Realtime + Edge Functions) cho M0-M4.

**Tradeoff:**
- Tốc độ ship cao, không cần BE engineer riêng.
- Vendor lock-in (mitigated: data ở Postgres standard, có thể export).
- Cost ~$25/tháng đến 100k MAU sau đó scale up tự nhiên.

**Migrate khi:** >100k MAU hoặc cần custom logic phức tạp → tách Go Fiber microservices, giữ Supabase chỉ cho Auth.

---

## ADR-003 — Brand Aurora Energy

**Ngày:** 2026-05-20
**Status:** Accepted

**Lựa chọn:** A "Aurora Energy" (Coral + Mint + Lavender) thay vì B "Pace Premium Minimal" hay C "Cùng Chạy Community".

**Lý do:** VN 2026 thiếu fitness brand mạnh; Aurora đủ trẻ viral TikTok nhưng palette giữ premium feel cho sub 599k/yr. Typography minimal tránh trông cheap.

---

## ADR-004 — RunCoin closed-loop voucher, KHÔNG crypto

**Ngày:** 2026-05-20
**Status:** Accepted

**Context:** Move-to-Earn có thể tạo growth lớn nhưng StepN sụp đổ (token -99%).

**Quyết định:** RunCoin closed-loop, đổi voucher Shopee/Grab/MoMo/Highlands. Brand sponsor trả CPA. Không listing exchange, không token.

**Lợi:** No speculation, no Ponzi risk, regulatory safe, brand có lý do trả tiền CPA (~70% face value).

---

## ADR-005 — Claude Sonnet 4.7 + Haiku 4.5 routing cho AI Coach

**Ngày:** 2026-05-20
**Status:** Accepted

**Context:** Cần giữ AI cost <$0.5/user/tháng cho profit margin.

**Quyết định:**
- Haiku 4.5 cho greeting/factual/classify.
- Sonnet 4.7 cho training plan, complex coaching chat.
- Prompt caching aggressive 90% hit (system prompt + user profile).
- Voice TTS pre-render 500 phrase qua ElevenLabs (one-time $30 thay vì realtime $0.10/req).

**Projection:** Free $0.02/user, Paid $0.43/user, đạt target <$0.5.

---

## ADR-006 — GCP Singapore + Cloudflare CDN VN

**Ngày:** 2026-05-20
**Status:** Accepted

**Lựa chọn:** GCP asia-southeast1 (Singapore) chính + Cloudflare CDN cho PoP HN/HCM/ĐN <20ms.

**Lý do:** Latency VN→SG 25-40ms (so với US 200ms+). GCP rẻ hơn AWS ~15%. Cloudflare miễn phí cho ingress + R2 storage rẻ hơn S3 80% egress.

**Compliance:** Nghị định 13/2023 yêu cầu data residency → replica VNG/Viettel IDC HCM cho user data nhạy cảm khi >100k MAU.
