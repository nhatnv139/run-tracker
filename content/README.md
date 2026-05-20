# RunVie Seed Content

Thư mục này chứa toàn bộ seed content để khởi tạo data nền tảng cho RunVie ở launch ngày 1.

## Cấu trúc

```
content/
  training-plans/    JSON template cho 6 chương trình tập luyện
  voice-scripts/     8 JSON file phrase tiếng Việt và 1 file tiếng Anh cho TTS coach
  badges/            badges-seed.json - 60 badge cho launch
  README.md
```

## 1. Training plans

6 file JSON tương ứng 6 plan template. Schema mỗi file:

```json
{
  "code": "c25k-9weeks",
  "name_vi": "...",
  "name_en": "...",
  "race_distance": "5k|10k|half|full",
  "weeks": 9,
  "sessions_per_week": 3,
  "level": "beginner|intermediate|advanced",
  "description_vi": "...",
  "description_en": "...",
  "tips_vi": ["..."],
  "workouts": [
    {
      "week_index": 1,
      "day_index": 0,
      "type": "easy|long|tempo|interval|rest|cross",
      "distance_m": 5000,
      "duration_s": 1800,
      "pace_target_s_per_km": 360,
      "hr_zone": 2,
      "description_vi": "...",
      "description_en": "...",
      "notes_vi": "..."
    }
  ]
}
```

### Import vào Supabase

Plan template không lưu trong bảng `training_plans` (bảng đó là per-user). Có 2 cách:

**Cách A: Embed template vào Edge Function**

Copy JSON vào `supabase/functions/training-plan-instantiate/templates/`. Khi user chọn plan, Edge Function load JSON đúng `code`, tính `start_date` -> `end_date`, insert 1 row `training_plans` và N row `training_workouts` với `day_offset = week_index * 7 + day_index`.

**Cách B: Lưu template trong bảng `training_plan_templates`**

Tạo migration mới:

```sql
create table public.training_plan_templates (
    id              uuid primary key default gen_random_uuid(),
    code            text unique not null,
    race_distance   public.race_distance_enum not null,
    weeks           integer not null,
    metadata_jsonb  jsonb not null,
    created_at      timestamptz default now()
);
```

Sau đó seed bằng script Node:

```bash
node scripts/seed-training-templates.mjs
```

Mỗi file JSON parse rồi `INSERT ... ON CONFLICT (code) DO UPDATE`.

## 2. Voice coach scripts

8 file JSON. Mỗi file là một array các phrase group:

```json
[
  {
    "id": "milestone_km_neutral",
    "trigger": "every_km",
    "category": "milestone",
    "style": "neutral|gentle|drill|funny",
    "lang": "vi-VN",
    "templates": [
      "Hoàn thành {km} km. Pace hiện tại {pace}.",
      "..."
    ]
  }
]
```

### Placeholder runtime

App sẽ thay các placeholder sau khi phát voice:

| Placeholder | Source | Example |
|-------------|--------|---------|
| `{km}` | distance milestone | "5" |
| `{km_plus_one}` | next km | "6" |
| `{pace}` | current pace | "sáu phút" |
| `{target_pace}` | plan target | "năm phút ba mươi" |
| `{hr}` | heart rate bpm | "một trăm năm mươi" |
| `{temp}` | temperature C | "ba mươi hai" |
| `{aqi}` | air quality index | "một trăm năm mươi" |
| `{distance}` | total distance km | "10" |
| `{duration}` | total time | "năm mươi phút" |

App chuyển số sang chữ tiếng Việt trước khi gửi cho TTS.

### Pre-render

Xem `voice-scripts/PRE-RENDER.md` cho chi tiết kế hoạch pre-render 500 phrase qua ElevenLabs và đóng gói thành 8 MP3 bundle.

## 3. Badges

File `badges/badges-seed.json` chứa 60 badge. Schema khớp với bảng `public.badges` trong migration `20260520000500_badges.sql`:

```json
{
  "code": "first_run",
  "name_vi": "Buổi chạy đầu tiên",
  "name_en": "First Run",
  "description_vi": "...",
  "description_en": "...",
  "category": "distance|streak|time|weather|social|seasonal|hidden|pace|quirky",
  "tier": "bronze|silver|gold",
  "criteria": { "type": "single_activity", "distance_m_gte": 1000 },
  "xp_reward": 100,
  "icon_hint": "shoe_print_coral"
}
```

### Import SQL

Migration `20260520000500_badges.sql` đã seed 30 badge tối thiểu (không dấu). File JSON này chứa 60 badge đầy đủ có dấu tiếng Việt - cần import thêm.

Script seed Node:

```js
import data from '../content/badges/badges-seed.json' assert { type: 'json' };
import { createClient } from '@supabase/supabase-js';

const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE);
for (const b of data) {
  await sb.from('badges').upsert({
    code: b.code,
    name_vi: b.name_vi,
    name_en: b.name_en,
    description_vi: b.description_vi,
    description_en: b.description_en,
    category: b.category,
    tier: b.tier,
    criteria_jsonb: b.criteria,
    xp_reward: b.xp_reward
  }, { onConflict: 'code' });
}
```

Hoặc sinh SQL trực tiếp:

```bash
node scripts/badges-to-sql.mjs > supabase/migrations/20260601000000_badges_seed_v2.sql
```

### Criteria evaluator

Field `criteria` là JSON evaluable bởi rule engine. Các `type` hỗ trợ:

- `single_activity`: kiểm tra 1 activity vừa hoàn thành. Hỗ trợ field `distance_m_gte`, `distance_m_between`, `duration_s_lte`, `start_time_before/after/between`, `end_time_after/between`, `weather`, `temp_c_gte/lte/between`, `humidity_lt`, `elevation_gain_m_gte`, `loop_closure_m_lte`, `negative_split_s_per_km_gte`, `districts_crossed_gte`, `date`.
- `lifetime`: tổng tích lũy. `distance_m_gte`.
- `rolling_window`: tổng trong N ngày gần nhất. `window_days`, `distance_m_gte`.
- `streak`: streak hiện tại. `days_gte`.
- `composite`: đếm activities khớp filter. `count_gte`, `filter` (object con).
- `manual_event`: sự kiện bên ngoài bắn từ Edge Function (referral count, club created, race finisher).

Rule engine ở `supabase/functions/badge-evaluator/index.ts` (chưa tạo, để task sau).

## 4. Style guide content tiếng Việt

- Dùng "bạn", không "anh/chị/em".
- Câu ngắn 6-12 từ, dễ phát TTS.
- Tránh từ Hán-Việt phức tạp ("phục hồi" OK, "tâm bệnh lý" né).
- Drill: mạnh mẽ, có chấm than ("Đẩy lên!").
- Gentle: ấm áp, không nịnh ("Bạn làm tốt lắm").
- Funny: nhẹ nhàng, gần gũi với văn hóa VN ("Phở chiều đang chờ").

## 5. Validation

Trước khi commit, chạy:

```bash
node -e "['c25k-9weeks','5k-improver-8weeks','10k-12weeks','half-marathon-16weeks','full-marathon-18weeks','walking-3-tieres'].forEach(c => JSON.parse(require('fs').readFileSync(\`content/training-plans/\${c}.json\`)))"
```

Kiểm tra tất cả JSON parse hợp lệ. Tương tự cho `voice-scripts/` và `badges/`.
