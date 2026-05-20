# RunVie — Run Tracker App

App chạy bộ + đếm bước + AI Coach tiếng Việt. Target top 10 App Store VN Health & Fitness, $10M ARR năm 2.

## 3 USP cốt lõi

1. **AI Coach tiếng Việt** tự nhiên — Claude Sonnet 4.7 + ElevenLabs TTS giọng Bắc/Nam.
2. **Walking-first, Run-ready** — 80% user VN không phải runner; UX không "xấu hổ" cho người chỉ đi bộ.
3. **RunCoin đổi voucher fiat** Shopee/Grab/MoMo — không crypto.

## Cấu trúc repo

```
run-tracker/
├── PRD-MASTER.md         Single source of truth (roadmap 12 tháng)
├── analysis/             10 phân tích nghiệp vụ
├── landing/              Next.js 16 pre-launch + waitlist (Vercel)
├── brand/                Logo SVG, design tokens Aurora Energy
├── supabase/             Postgres + PostGIS schema, RLS, triggers
├── ai-coach/             FastAPI service, Claude routing, cost <$0.5/user
├── app/                  Flutter 3.27 mobile app (iOS + Android)
├── content/              Training plans, voice scripts VN, badges seed
└── docs/                 Misc docs
```

## Tech Stack

| Layer | Choice |
|-------|--------|
| Mobile | Flutter 3.27 (Riverpod + go_router + Supabase + geolocator) |
| Backend MVP | Supabase (Auth + Postgres + Storage + Realtime) |
| Backend Scale | Go Fiber microservices từ M4 |
| AI Coach | Python FastAPI + Claude Sonnet 4.7 / Haiku 4.5 routing |
| DB | Postgres 16 + PostGIS, ClickHouse time-series, Redis |
| Map | Mapbox (self-host tile khi scale) |
| Infra | GCP asia-southeast1 + Cloudflare CDN VN |
| Analytics | PostHog self-hosted + Sentry |
| Mobile CI | Codemagic / Xcode Cloud (iOS build từ Windows) |

## Brand Aurora Energy

- Coral `#FF5A36` / Mint `#00D4A8` / Lavender `#7B5CFF`
- Font: Be Vietnam Pro
- Voice: "bạn", motivational nhẹ, không hét

## Setup từng module

### Landing
```bash
cd landing
cp .env.example .env.local
npm install
npm run dev
```

### Supabase
```bash
cd supabase
supabase start
supabase db reset
```

### AI Coach
```bash
cd ai-coach
cp .env.example .env
uv sync  # hoặc pip install -e .
uvicorn src.main:app --reload
```

### Flutter app
```bash
cd app
cp .env.example .env
flutter pub get
flutter run  # cần thiết bị/emulator
```

## Roadmap (rút gọn)

| Phase | Tháng | Milestone |
|-------|-------|-----------|
| **Foundation** | M1-3 | Landing live, MVP submit App Store VN |
| **Launch** | M4-6 | AI Coach, Strava sync, RunCoin redemption, **VN blitz** |
| **Expansion** | M7-9 | Android, Wear OS, form analysis, **soft launch SEA** |
| **Global** | M10-12 | B2B Corporate, **Global launch US/EU**, target $3M ARR |

Xem `PRD-MASTER.md` cho chi tiết.

## Target metrics

| Metric | M3 | M6 | M12 |
|--------|-----|-----|-----|
| Download | 10k | 100k | 500k VN |
| MAU | 3k | 30k | 200k |
| D30 retention | 8% | 15% | 25% |
| Paying users | 100 | 1.5k | 12k |
| App Store rank H&F VN | top 50 | top 20 | **top 10** |

## License

Proprietary. © 2026 RunVie.
