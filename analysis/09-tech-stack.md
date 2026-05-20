# 09 — Tech Stack & System Architecture (Run Tracker)

**Target năm 1**: 1M MAU, top App Store Health & Fitness (VN + SEA)

## 1. Mobile Framework

| Framework | Background GPS | HealthKit | Battery | Đánh giá |
|---|---|---|---|---|
| **Native Swift + Kotlin** | A+ | A+ | Tối ưu | Top tier |
| Flutter | B (plugin bug) | C | Trung bình | Không khuyên |
| React Native | C- (BG unreliable) | C | -15% native | KHÔNG |
| Kotlin Multiplatform | A (logic share, UI native) | A | Tốt | Tốt khi scale |

**Khuyến nghị**: **Native iOS-first (Swift + SwiftUI)** 6 tháng đầu. iOS chiếm 70% revenue Health & Fitness. HealthKit/CMPedometer/CoreLocation background hoạt động chuẩn nhất khi native, tránh bug "app bị kill khi lock màn hình" kinh điển của RN/Flutter. Tháng 7-9 mới làm Android native (Kotlin + Jetpack Compose) với KMP cho domain layer chung (GPX parser, distance calc, pace).

## 2. Background Tracking iOS

- **Active workout**: `CLLocationManager` với `allowsBackgroundLocationUpdates=true`, `desiredAccuracy=.bestForNavigation`, `activityType=.fitness`. Background mode `location`.
- **Passive steps**: `CMPedometer.queryPedometerData` qua `BGAppRefreshTask` 15 phút/lần — pin tiết kiệm vì M-coprocessor đếm native.
- **Significant Location Change**: gợi ý "có phải bạn đang chạy?" khi user quên start.
- **Region monitoring**: geofence điểm xuất phát quen.
- **Battery target**: <8%/giờ. Adaptive accuracy: 1Hz khi >6km/h, 0.2Hz đứng yên, tắt khi auto-pause.
- **BG time limit**: mode `location` không bị 30s/180s limit, nhưng phải có update đều; dừng >15 phút → local notification + stop để tránh iOS kill.

## 3. GPS Accuracy

- **Kalman filter 2D** (position+velocity), Q≈4 m²/s², R = `horizontalAccuracy`. Loại bỏ điểm accuracy>50m hoặc speed delta>8 m/s.
- **Map matching**: Valhalla self-hosted với OSM (rẻ hơn Mapbox Map Matching API ~10x), chỉ chạy post-workout.
- **Smoothing**: Douglas-Peucker epsilon=2m, giảm 60% storage polyline.
- **Auto-pause**: speed<0.5 m/s liên tục 8s + accel magnitude<0.05g. Auto-resume: speed>1.5 m/s, 3s.

## 4. Sensor Fusion

- Accelerometer 100Hz (cadence FFT 5s, fallback step khi mất GPS).
- Gyroscope (loại nhiễu khi quay đầu).
- Barometer (elevation chính xác ~5x GPS, EMA alpha=0.1).
- **Fall detection**: |accel|>3g + stillness>10s + HR spike → SOS countdown 30s.
- Extended Kalman Filter fusion ở Background QoS.

## 5. Local Storage

- **Core Data + SQLite** (không Realm — migration khó). NSPersistentCloudKitContainer cho iCloud sync free.
- Schema: Activity, LocationPoint, LapSplit, HeartRateSample, Route, User, Goal.
- **Offline-first**: lưu local trước, queue sync (Combine + NWPathMonitor). Conflict: server-wins profile, client-wins activity (immutable).
- Encryption: NSFileProtectionCompleteUntilFirstUserAuthentication + SQLCipher.

## 6. Backend

**Khuyến nghị**:
- **Tháng 0-4 (MVP, <50k MAU)**: **Supabase** (Postgres + Auth + Storage + Realtime) — tiết kiệm 1 backend engineer.
- **Tháng 4-12**: tách dần sang **Go (Fiber)** microservices cho hot path. Giữ Supabase cho auth + storage.
- Services: auth-svc, activity-svc, social-svc, notification-svc, analytics-svc, ai-coach-svc (Python — gọi Claude API).

Go thắng Node (CPU-bound, GC pause), FastAPI (concurrency yếu), Elixir (hire khó VN).

## 7. Database

- **PostgreSQL 16 + PostGIS**: user, social graph, activity metadata, geo queries.
- **Redis 7**: session, leaderboard ZSET, rate limit, hot feed cache.
- **ClickHouse**: time-series location/sensor (compression 10-20x, query 1B rows <100ms).
- **S3 / Cloudflare R2** (R2 rẻ hơn 80% egress): GPX export, avatar, video form snippet, map PNG.

## 8. Real-time

- **Live tracking**: **MQTT (EMQX cluster)** — pub/sub tiết kiệm bandwidth vs WebSocket raw. Topic `live/{userId}/{workoutId}`, publish 5s/lần.
- **Leaderboard**: Redis Pub/Sub → **SSE** (HTTP/2, đơn giản hơn WebSocket, auto-reconnect).
- **Feed**: poll ETag — không cần realtime.
- Tránh Firebase Realtime DB (lock-in, cost mờ).

## 9. Map

- **Mapbox**: free 50k MAU loads, sau đó $0.60/1k. Self-host vector tile qua Tilemaker + OSM giảm 80% chi phí khi scale.
- Apple Maps native cho summary screen iOS (không tốn quota).
- Không Google Maps ($7/1k, terms khắt khe fitness).

## 10. Push

- **APNs HTTP/2** (JWT ES256) + **FCM** Android.
- Smart timing: gradient boosting học giờ user mở app, schedule ±30 phút.
- Silent push wake app sync khi Apple Watch xong workout.

## 11. Analytics & Monitoring

- **PostHog self-hosted**: product analytics + feature flags + A/B test + session replay (1 tool thay 3, control data PDPL VN).
- **Sentry**: crash + perf trace.
- **Grafana + Prometheus + Loki**.
- **OpenTelemetry** distributed tracing.

## 12. CI/CD

- **GitHub Actions** mono-repo trung tâm.
- **Fastlane** TestFlight, screenshots, match cert sync.
- **Xcode Cloud** release build (Apple-signed).
- Backend: GHA → GHCR → ArgoCD → GKE. Trunk-based, feature flag mọi thứ risky.

## 13. App Size & Startup

- IPA <40MB. On-demand resources cho map tiles, coach voice pack.
- Cold start <1.8s iPhone 12: lazy Core Data, defer analytics init đến `applicationDidBecomeActive`, async HealthKit auth.
- SwiftUI cho UI mới, UIKit cho map-heavy.

## 14. AI Inference

- **On-device CoreML**: form analysis (MoveNet quantized 4MB, 30fps). Không upload video → privacy.
- **Server-side**: AI Coach chat qua **Claude Sonnet 4.7** API với prompt caching (giảm 90% cost). Stream SSE.
- Embeddings: sentence-transformers self-host cho route similarity.

## 15. Scalability — Capacity Planning

- 1M MAU, 30% DAU=300k, 40% log workout/ngày = **120k activities/ngày**.
- 45 phút × 60 GPS pts = 2700 rows/activity → **324M rows/ngày** ClickHouse, ~4GB/ngày compressed.
- Năm 1: ~1.5TB ClickHouse, ~200GB Postgres, ~800GB S3.
- **Cost**: AWS ~$8-12k/tháng; **GCP rẻ hơn ~15%** → **GCP asia-southeast1 (Singapore)**.

## 16. Security & Compliance

- Auth: Sign in with Apple + Google + Email OTP. JWT RS256 15min + refresh 30 ngày rotating.
- Biometric: FaceID/TouchID qua LocalAuthentication.
- **E2E** live location share: X25519 ECDH + ChaCha20-Poly1305.
- GDPR + Nghị định 13/2023 VN: data export ZIP (GPX+JSON), hard-delete 30 ngày.
- Secrets Manager. Pentest quý/lần, HackerOne sau 100k MAU.

## 17. VN-Specific Infra

- **Cloudflare CDN** chính (PoP HN, HCM, ĐN, <20ms). Backup **BizflyCloud**.
- Cloudflare Workers cho image resize, signed URL.
- **GCP asia-southeast1 Singapore** chính, asia-northeast1 Tokyo DR. VN→SG: 25-40ms.
- Payment: VNPay + Momo + Apple IAP subscription.

## 18. System Architecture (ASCII)

```
                              +-------------------------+
                              |   iOS App (Swift)       |
                              |   - Core Data offline   |
                              |   - CoreML form AI      |
                              |   - HealthKit / GPS BG  |
                              +-----------+-------------+
                                          |
                          HTTPS / MQTT / SSE  (TLS 1.3)
                                          |
                  +-----------------------v------------------------+
                  |  Cloudflare CDN (VN PoPs) + WAF + Workers      |
                  +-----------------------+------------------------+
                                          |
                  +-----------------------v------------------------+
                  |   API Gateway (Kong on GKE asia-southeast1)    |
                  +--+--------+--------+---------+---------+-------+
                     |        |        |         |         |
                +----v---+ +--v----+ +-v------+ +v-------+ +v---------+
                |Auth svc| |Activity| |Social  | |Notif   | |AI Coach  |
                |  (Go)  | | (Go)   | | (Go)   | | (Go)   | |(Py+Claude)|
                +----+---+ +--+-----+ +---+----+ +---+----+ +----+-----+
                     |        |           |         |           |
       +-------------v--------v-----------v---------v-----------v---+
       |               Message Bus (NATS JetStream)                  |
       +-----+---------------------+--------------------+------------+
             |                     |                    |
       +-----v-----+         +-----v------+        +----v-----+
       | Postgres  |         | ClickHouse |        |  Redis   |
       | (PostGIS) |         |(timeseries)|        |(LB/cache)|
       +-----+-----+         +-----+------+        +----+-----+
             |                     |                    |
             +---------+-----------+--------+-----------+
                       |                    |
                  +----v----+         +-----v------+
                  | S3 / R2 |         |   EMQX     |
                  | (media) |         |(MQTT live) |
                  +---------+         +------------+

   Observability: Sentry | PostHog | Grafana+Prom+Loki | OTel
   CI/CD:         GitHub Actions | Fastlane | ArgoCD
```

## 19. Rủi ro & Mitigations

- iOS BG kill: test 5 đời iPhone thật, CI chạy simulation 1h.
- GPS drift đô thị (HN/HCM): fallback CMPedometer + dead-reckoning.
- Cost runaway: GCP budget alert $500/ngày, autoscaling cap.
- App Store reject: HealthKit privacy explainer, không request quyền thừa.
