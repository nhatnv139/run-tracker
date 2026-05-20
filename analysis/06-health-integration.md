# Chiến lược tích hợp Health Ecosystem cho app chạy bộ

## 1. Apple HealthKit (iOS)
Read: steps, distance running, active/basal energy, HR, HRV (SDNN), resting HR, VO2max, sleep stages, mindful minutes, body mass, workout history. Write: HKWorkoutActivityType.running + HKWorkoutRoute, splits, HR samples. Permissions UX: giải thích từng metric, handle từ chối gracefully. 2025–2026: Training Load API (iOS 18+), Vitals baseline, Mental Wellbeing logging.

## 2. Google Health Connect (Android)
Google Fit API đã sunset Q2/2025. Dùng `androidx.health.connect:connect-client`. Records: ExerciseSession, HeartRate, Steps, SleepSession, Vo2Max, RestingHeartRate. User consent qua Health Connect system app.

## 3. Apple Watch
HKWorkoutSession + HKLiveWorkoutBuilder, complications (Smart Stack/modular/circular), Live Activities + Dynamic Island, Smart Stack contextual widget (watchOS 10+), Always-On 1Hz tiết kiệm pin.

## 4. Wear OS
Health Services API (Jetpack) — battery-efficient. Target Galaxy Watch + Pixel Watch. Tiles, Ongoing Activity API. Sync qua Health Connect.

## 5. Garmin Connect IQ
Monkey C app/data field cho realtime metric trên watch + Garmin Health API (server OAuth) pull FIT activity files. Developer review ~2 tuần.

## 6. Polar / Suunto / Coros
Polar AccessLink (OAuth2 REST), Suunto API (OAuth + webhook), Coros chưa có public API — workaround Strava sync hoặc FIT upload.

## 7. Strava
OAuth + webhook 2 chiều. Rủi ro: Strava thu hồi quyền nếu clone segment. Định vị app là "coaching/training plan", Strava là "social feed" — push activity sang Strava, giữ analytics sâu in-app.

## 8. Fitbit / Whoop / Oura
Fitbit Web API (sleep, HRV, SpO2), Whoop API (recovery, strain — cần partnership), Oura v2 (readiness, sleep, temperature). Combine 3 nguồn tạo "Recovery-Aware Training" — moat khác biệt vs Strava/Nike Run Club.

## 9. MyFitnessPal / Lifesum
Sync calories in. MFP API hạn chế chỉ partner lớn; Lifesum dễ tiếp cận. Plan B: dùng HealthKit/Health Connect làm proxy.

## 10. Spotify / Apple Music / YouTube Music
Spotify iOS/Android SDK, Apple MusicKit, YouTube Music chỉ deep-link. Killer feature: Cadence Sync — bài BPM = pace mục tiêu (180 spm easy run).

## 11. BLE Heart Rate strap
GATT Heart Rate Service 0x180D, characteristic 0x2A37. Support: Polar H9/H10, Wahoo TICKR, Garmin HRM-Pro, Coospo H6. Đọc thêm Running Dynamics 0x1814 cho cadence/stride nếu có footpod.

## 12. Treadmill BLE FTMS
Fitness Machine Service 0x1826, Treadmill Data 0x2ACD: speed, incline, distance, time. Support hầu hết NordicTrack, Technogym, Matrix, Elip, Kingsmith VN — indoor run chính xác không cần GPS.

## 13. Privacy & Compliance
HIPAA (Mỹ): chỉ nếu deal provider/insurer. GDPR (EU): consent từng category, export/delete 30 ngày, DPO khi >250 user EU. VN — Luật ANTM + Nghị định 13/2023: dữ liệu sức khỏe là dữ liệu nhạy cảm, consent riêng, replica VNG/Viettel IDC HCM cho data residency.

## 14. Vietnam-specific
Zalo Mini App (75M MAU) share thành tích + mời bạn chạy. VietQR/MoMo/ZaloPay subscription + giải race ảo + charity run. Vinmec/Hoàn Mỹ/Medlatec B2B share checkup (mỡ máu, EKG) đưa vào "Health Profile" — moat không đối thủ global có. Co-marketing Garmin VN, Coros VN.

## 15. iOS Live Activities + Dynamic Island
ActivityKit `Activity<RunAttributes>` — lock screen + Dynamic Island compact (pace) + expanded (full stats). Update push token mỗi 5–10s background. iOS 17+ interactive buttons pause/resume.

## 16. Widgets
iOS WidgetKit: small steps, medium chart, large training plan, Lock Screen streak. Android Glance/AppWidget + Samsung One UI Home + Pixel Launcher.

## Roadmap
- **Tuần 1:** HealthKit, Health Connect, Apple Watch workout, Live Activity, widget steps, BLE HR.
- **Tháng 3:** Wear OS, Strava 2-way, Spotify, FTMS treadmill, Garmin Health API, interactive Live Activity.
- **Tháng 6:** Connect IQ Monkey C, Whoop+Oura+Fitbit recovery, MyFitnessPal, Apple Music cadence, Zalo Mini App.
- **Năm 1:** Polar/Suunto/Coros, Vinmec/Hoàn Mỹ partnership, AI coach cross-source, VietQR, Smart Stack contextual, B2B SDK gym chain VN.

Ưu tiên Pareto: HealthKit + Health Connect + Apple Watch + Strava = 80% giá trị cho 80% user.
