# 08 — UX/UI Design Analysis: App Chạy Bộ Top App Store 2026

## 1. Onboarding Flow (7 bước)
1. Welcome carousel 3 slide (Track / Train / Triumph), auto-play 4s, CTA "Bắt đầu".
2. Mục tiêu chính — chip single-choice: Giảm cân / Sức bền / Tốc độ / Đi bộ / Lịch giải.
3. Level — 3 card lớn Beginner (<5km/tuần) / Intermediate (5–20) / Advanced (>20).
4. Personalize — cân, cao, tuổi, giới tính, max HR (220−tuổi auto) qua wheel picker.
5. Notification soft-ask (giải thích value trước, system prompt sau).
6. HealthKit explain page riêng, chỉ 4 scope: workouts r/w, HR, distance, energy.
7. Paywall — annual 599k (best, –58%) / monthly 129k / lifetime 1.490k, có nút "Tiếp tục free" mờ.

Best practice: dot progress, resume state, defer account đến sau buổi chạy đầu (Strava style). Target < 90s, drop-off < 25%.

## 2. Information Architecture
Khuyến nghị **5 tab**: Home / Activity / **Run (FAB giữa, accent)** / Plan / Profile.
4-tab (Nike) gọn nhưng Plan bị chìm. 5-tab với Run-FAB tối ưu conversion "tap to run". Social gộp vào Profile cho phase 1 vì user VN chưa mạnh social.

## 3. Home Screen
```
+--------------------------------+
| Chao Minh, sang tot            |
|       .----------.             |
|      /   72%      \   Hom nay  |
|     |   ring      |   3.2 km   |
|      \           /    312 kcal |
|       '---------'     28 phut  |
|  Streak: 12 ngay               |
|  ---------------------------   |
|  GOI Y HOM NAY                 |
|  +--------------------------+  |
|  | Easy Run  5km  Zone 2    |  |
|  | ~32 phut    Bat dau ->   |  |
|  +--------------------------+  |
|  [Free Run] [Interval] [Walk]  |
|  M T W T F S S                 |
|  o o . o . . .   3/5 buoi      |
+--------------------------------+
```
Chọn **1 ring đơn** (không 3 ring kiểu Apple) để giảm cognitive load cho beginner. Greeting động theo giờ + weather. Fire icon đỏ khi streak nguy hiểm (sau 20h chưa chạy).

## 4. Run Screen
```
+--------------------------------+
|            03:24               |
|                                |
|          5.42                  |   <- 96pt bold
|           km                   |
|   ==========================   |
|   5'42"        152 bpm         |
|   pace         heart           |
|   <- swipe doi metric ->       |
|      +--------------+          |
|      |    PAUSE     |          |
|      +--------------+          |
|         [ Lock ]               |
+--------------------------------+
```
- Chữ chính 96pt Be Vietnam Pro Bold (đọc khi chạy lắc).
- True black #000000 — tiết kiệm 30–40% pin OLED.
- Auto dark kể cả ban ngày.
- Swipe ngang đổi metric, swipe lên xem map full.
- Long-press 1.5s để lock, tránh chạm nhầm.
- PAUSE 88pt circle.
- TTS tiếng Việt mỗi km, haptic notificationSuccess milestone.

## 5. Post-run Summary
```
+--------------------------------+
|  <- Luu             Chia se    |
|         5.42 km                |
|       Chay buoi sang           |
|  +============================+|
|  |    [Static Map snapshot]   ||
|  +============================+|
|  | 5.42 | 31:02|5'42" | 412  | |
|  |  km  | time | pace | kcal | |
|  Splits  |  HR Zones           |
|  PR MOI: 5K nhanh nhat!        |
|  Cam thay the nao?             |
|  [1] [2] [3] [4] [5]           |
|        [ Luu workout ]         |
+--------------------------------+
```
Lottie 3s khi có PR (tap-to-skip). RPE picker feed vào training plan. Auto-generate IG story 9:16 share template. Kudos placeholder.

## 6. Stats & History
- **GitHub-style calendar heatmap** 365 ô (intensity = distance) — retention feature số 1.
- Weekly bar chart với target line.
- Monthly summary card.
- PR list: 1K/5K/10K/HM/FM/longest run/longest streak.

## 7. Empty States
- Home first-time: illustration runner + "Sẵn sàng cho km đầu tiên?" + CTA "Bắt đầu chạy" (không ring rỗng).
- Activity: "Chưa có hoạt động."
- Plan: card quiz 3 câu → tạo plan.

## 8. Notifications
| Loại | Time | Copy VN |
|---|---|---|
| Morning | 6h (cá nhân hoá) | "Trời mát 24°C, hoàn hảo để chạy 5K" |
| Streak warning | 20h | "Streak 12 ngày sắp đứt — chỉ cần 1km" |
| Friend kudos | Realtime | "Lan vừa khen workout của bạn" |
| Weather | 1h trước run | "Sắp mưa lúc 17h, dời lịch?" |
| Weekly recap | CN 19h | "Tuần này: 24km, +3km" |
| Plan reminder | 30' trước | "Workout: Tempo 6km lúc 17h" |

Quiet 22h–5h, cap 2/ngày, toggle riêng.

## 9. Accessibility
VoiceOver label VN ("Năm phẩy bốn hai cây số"). Dynamic Type XXXL. Color blind: pattern + icon cho HR zones. One-hand: CTA 1/3 dưới, FAB thumb zone. Reduced motion: tắt Lottie. WCAG AA ≥ 4.5:1.

## 10. Dark Mode + True Black
Theme System / Light / Dark / **Pure Black** (Run screen). Bg #000, surface #0A0A0A. Tiết kiệm 30–40% pin OLED.

## 11. Haptic
Start `.impactMedium`, Pause `.impactLight`, Stop `.notificationSuccess`, Km milestone success + ring sound, Achievement CHHapticPattern 3 pulse rising, Tap `.selectionChanged`, Lock `.impactRigid` ×2.

## 12. Animation
Ring fill easeOutCubic 0.8s + spring khi 100%. Count-up mỗi 0.01km. Lottie 6 file (PR, streak 7/30/100, distance, level up). Tab transition fade+scale 0.98→1.0. Map path stroke 1.5s.

## 13. Localization VN
- **Be Vietnam Pro** (Google Fonts OFL, 9 weight, diacritics đẹp). Fallback SF Pro.
- Số: Locale("vi_VN") — 1.234,5 km.
- Đơn vị: km/kcal/m, optional mile.
- Time 24h, Date "T2, 20/05".
- Tone "bạn", microcopy ngắn, emoji vừa phải.

## 14. Design System Tokens
**Color "Aurora Energy"**:
- `accent/primary` #FF5A36 Coral
- `accent/secondary` #00D4A8 Mint
- `accent/tertiary` #7B5CFF Lavender
- `bg/base` #FAFAF7, `bg/elevated` #FFF, `bg/dark` #0A0A0A
- `text/primary` #1A1A1F, `text/secondary` #6B6B73
- HR Z1–Z5: #4ADE80 / #FACC15 / #FB923C / #EF4444 / #B91C1C

**Typography** (Be Vietnam Pro): display/xl 96/100, display/l 56/60, heading/l 32/38, heading/m 24/30, body/l 17/24, body/m 15/22, caption 13/18, mono SF Mono 17.

**Spacing 4pt grid**: 4/8/12/16/24/32/48/64. **Radius**: 8/16/24/999. **Shadow** 2 level only.

## 15. Brand Direction
- **A. Aurora** — Energetic Gen Z. Coral+Mint+Lavender, Memphis illust, animation nhiều. 18–28.
- **B. Pace** — Premium Minimal. Đen/kem/đồng #B8845C, typography làm chính. 28–45.
- **C. Cùng Chạy** — Friendly Community. Xanh ấm + cam đất, route VN, group challenge.

**Khuyến nghị: A "Aurora" + typography kiểu B.** Lý do: VN 2026 thiếu fitness brand mạnh, Aurora đủ trẻ viral TikTok nhưng palette giữ premium cho sub 599k/năm. Typography minimal tránh trông cheap. Phase 2 layer thêm community insight của C.
