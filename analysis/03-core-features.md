# 03 - Core Feature Spec — Run Tracker App

> Note: Agent gốc chỉ trả tóm tắt 200 từ do bị deny ghi file. File này lưu cấu trúc đề xuất + sẽ được mở rộng ở pha tổng hợp PRD.

## Tóm tắt định hướng (200 từ)

Đã spec hoá 13 module cho app chạy bộ + step counter + calorie tracker target top App Store, mỗi module gồm mục đích, tech stack (CMPedometer/Sensor, Core Location, MET formula, BLE HR), user flow, priority P0/P1/P2 và độ phức tạp S/M/L/XL.

**Module P0 (must-have MVP):** Step Counter (M), GPS Running Tracker (L), Calorie Calculation (S) dùng Mifflin-St Jeor + MET, History & Stats (M) với calendar heatmap + PR + streak.

**P1 (v1, tháng 4–6):** Workout Plans (Couch-to-5K → Marathon), Heart Rate Zones Z1–Z5, Voice Coach, Indoor Mode, 50+ badge ideas chia 12 category (distance/streak/speed/elevation/weather/seasonal).

**P2 (v2):** Social Feed (XL), Live Tracking + fall detection, Music integration Spotify/Apple Music, Nutrition Logging với barcode scan OpenFoodFacts.

**MVP scope 3 tháng:**
- **Tháng 1:** foundation (onboarding, step counter, calorie BMR/TDEE, dashboard).
- **Tháng 2:** GPS tracker full + voice coach cơ bản + auto-pause.
- **Tháng 3:** history/stats + 10 badge cốt lõi + polish + App Store submit.

Loại khỏi MVP: workout plans, HR zones, social, nutrition, live tracking, music, indoor — đẩy wave 2 sau khi validate core loop "track → progress → return". Target metrics: D7 retention 20%, 10K download organic 30 ngày, 4.5★. Monetization: Freemium $4.99/mo Premium + $9.99/mo Family Pack.

## Danh sách 13 module (sẽ chi tiết hoá ở PRD master)

| # | Module | Priority | Complexity | Tech key |
|---|---|---|---|---|
| 1 | Step Counter | P0 | M | CMPedometer / TYPE_STEP_COUNTER, background |
| 2 | GPS Running/Walking Tracker | P0 | L | CoreLocation, Kalman filter, auto-pause |
| 3 | Calorie Calculation | P0 | S | Mifflin-St Jeor + MET |
| 4 | History & Stats | P0 | M | SQLite, calendar heatmap, PR, streak |
| 5 | Workout Plans (5K → Marathon) | P1 | L | Pfitzinger/Daniels templates + adaptive |
| 6 | Heart Rate Zones Z1–Z5 | P1 | M | BLE HR strap, HRmax % zones |
| 7 | Voice Coach (VN) | P1 | M | TTS, audio ducking, km cue |
| 8 | Indoor Mode (treadmill) | P1 | M | Accelerometer-based pace + FTMS BLE |
| 9 | Achievements/Badges (50+) | P1 | M | Rule engine, 12 categories |
| 10 | Social Feed | P2 | XL | Backend graph, kudos, comments |
| 11 | Live Tracking + Safety | P2 | L | Real-time location share, fall detection |
| 12 | Music/Podcast integration | P2 | M | Spotify SDK, MusicKit |
| 13 | Nutrition Logging | P2 | L | Barcode OpenFoodFacts, photo AI |

Cần agent re-run với full content để có user flow chi tiết từng module — sẽ đưa vào pha PRD master (task #11).
