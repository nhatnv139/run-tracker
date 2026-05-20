# 05 - AI/ML Features cho Run Tracker (Top App Store 2026)

## 1. AI Personal Coach (LLM Chatbot)
- Claude Sonnet 4.5 (default) + Haiku 4.5 (cheap routing). Mỗi prompt inject user profile (tuổi, VO2max, mục tiêu 5K/10K/HM/Full), 30 ngày activity tóm tắt, HRV trend, weekly load.
- **Sinh giáo án:** function calling tạo JSON `training_plan` 12 tuần kiểu Pfitzinger/Daniels, lưu local + sync cloud.
- **Realtime adjustment:** skip 2 buổi → coach hỏi lý do, reshape plan; overtrain (HRV giảm >7% baseline 3 ngày) → đề xuất rest.
- **Memory layer:** RAG với SQLite-vss/Pinecone lưu chat history + milestone (PR 5K, chấn thương cũ).

## 2. Voice Coach AI
- **TTS:** ElevenLabs Turbo v2.5 cho tiếng Việt nam/nữ, fallback OpenAI Realtime. 3 phong cách: drill sergeant / gentle / funny.
- **Realtime cue:** mỗi 30s; pace lệch >10% → cue chỉnh; Apple Watch haptic cho silent mode; audio ducking với Spotify/Apple Music.
- **Multilingual:** vi-VN, en-US, en-GB, ja-JP. Pre-render 500 phrase template/giọng để giảm latency + cost (~100ms vs 800ms realtime).

## 3. Smart Route Recommendation
- **Data:** OSM (highway, `lit=yes/no`, surface), Strava heatmap, SRTM elevation, OpenWeather + AQI, crowdsourced safety reports.
- **Algo:** OSRM custom profile với cost function multi-objective:
  `cost = α·dist_dev + β·(1-lit) + γ·elev_pen + δ·(1-scenic) + ε·aqi_pen`
- Weights học qua Thompson sampling bandit theo lựa chọn user.

## 4. Form Analysis (MediaPipe Pose, on-device)
- User quay side-view 30s. Xử lý on-device, không upload video.
- **Metrics:** cadence (FFT ankle Y, target 170-180 spm), stride length, vertical oscillation, spine lean (5-10° tối ưu), heel vs midfoot strike, knee drive.
- **Output:** score 0-100 + 3 actionable tips.

## 5. Injury Prediction
- LightGBM weekly batch trên cloud.
- **Features:** ACWR 7d/28d (>1.5 nguy), tăng km tuần >10%, cadence drop >5 spm, sleep <6h trung bình, HRV deviation, previous injury sites, shoe mileage >500km.
- **Output:** risk score + breakdown ("ITB risk do ACWR 1.7"), push notif trước run.

## 6. Calorie ML Personalization
- MET công thức sai 20-30% cá nhân. XGBoost hiệu chỉnh với input: tuổi, giới, cân, HR avg, pace, elevation, nhiệt độ.
- **Federated learning:** model base cohort, personalize layer cuối on-device sau mỗi 10 run. Label từ Apple Watch (chest strap nếu có).

## 7. Nutrition Photo
- GPT-4o-mini hoặc Gemini Flash 2.5 (rẻ). Output JSON `{name, portion, kcal, protein, carb, fat}`.
- **Moat:** fine-tune dataset món Việt (phở, bún bò, cơm tấm) — khác biệt vs Cal AI/FoodAI vốn tập trung Western food. Reference object (thẻ ATM) để estimate portion.

## 8. Anomaly Detection (Anti-cheat)
- GPS spoof check: vận tốc tức thời >30km/h, teleport >500m/sample, accel variance=0, HDOP quá hoàn hảo liên tục.
- **Model:** Isolation Forest trên (speed_max, accel_variance, HR-pace correlation, stride count từ accelerometer vs distance GPS).
- **Action:** tag "unverified", loại khỏi leaderboard global.

## 9. Adaptive Training Plan
- Không PDF cố định. Cron 5h sáng tính lại buổi hôm nay.
- **Signals:** HRV morning vs 7d baseline; sleep <6h → giảm intensity 20%; weather (mưa to / >35°C) → suggest treadmill; Google Calendar → đẩy run sớm/muộn; streak preservation.
- LLM agent gọi tool `reshape_plan(date, new_workout)`.

## 10. Mental Health Combo
- **Post-run meditation:** 3-5 phút guided TTS tự sinh contextual ("Vừa hoàn thành long run 15K...").
- **Mood check-in:** 1-tap emoji + voice note → Whisper → sentiment.
- **Burnout detection:** combo mood ↓ + HRV ↓ + compliance ↓ + sleep ↓ trong 7d → push "Đề xuất 3 ngày off".

## 11. On-device vs Cloud

| Feature | On-device | Cloud | Lý do |
|---|---|---|---|
| Form analysis MediaPipe | X | | Privacy video, offline |
| Voice TTS phrase cache | X | | Latency <100ms |
| Calorie ML personalize layer | X | | Fed learning |
| Anomaly sensor check | X | | Realtime |
| LLM coach chat | | X | Model size, cost |
| Route recommendation | | X | Graph compute |
| Injury prediction batch | | X | Cross-user features |
| Nutrition photo | | X | Vision model lớn |
| Adaptive plan cron | | X | Multi-source data join |

CoreML iOS, TFLite Android, MediaPipe Tasks unified API.

## 12. Cost Analysis (Target <$0.5/user/tháng)

**Free tier (~$0.02):** 20 msg Haiku 4.5 ($0.25/$1.25 per M tokens), prompt cache 80% → $0.002 chat; TTS pre-render $0; on-device $0; route $0.003.

**Paid tier (~$0.43):** 100 msg với smart routing 70/30 Haiku/Sonnet + prompt cache 90% → $0.15; nutrition 30 photo × Gemini Flash $0.005 = $0.15; adaptive plan cron 30 × $0.001 = $0.03; voice dynamic milestone 5 × ElevenLabs $0.02 = $0.10. Tổng $0.43 ✓.

**Optimization keys:**
- Prompt caching aggressive 90% hits trên system prompt + user profile.
- Smart routing Haiku → Sonnet → Opus theo độ khó.
- Batch API cho injury weekly (50% off).
- Self-host OSRM + OSM tiles.
- Pre-render 500 voice templates thay TTS realtime.
- Cap free 20 msg/tháng, upsell Pro $7.99/tháng.

## Kết luận
10 tính năng AI/ML tạo moat thực sự: voice tiếng Việt + form on-device + adaptive plan + nutrition món Việt. Khác biệt vs Strava/Nike Run Club: hyper-personalization với chi phí <$0.5/user nhờ hybrid on-device/cloud, smart routing, prompt caching.
