# Voice TTS Pre-render Plan

Mục tiêu: pre-render khoảng 500 phrase ưu tiên cao qua ElevenLabs, đóng gói thành 8 file MP3 bundle theo category. Giúp giảm độ trễ phát âm xuống ~50ms thay vì 800-1500ms streaming TTS.

## Tổng quan kinh tế

- 500 phrase trung bình 12 từ * 5 ký tự = 60 ký tự mỗi phrase
- 500 phrase * 60 ký tự = 30,000 ký tự
- 2 giọng (1 nữ ấm, 1 nam mạnh mẽ) = 60,000 ký tự
- ElevenLabs Multilingual v2: ~$0.0001 mỗi ký tự (Starter plan)
- Tổng: 60,000 * $0.0001 = ~$6 chi phí render thực tế
- Cộng overhead (re-render, fix mistake, A/B test 2 lần) = ~$30 one-time

Lưu ý: trong PRD-MASTER tính chi phí $30 đã chấp nhận buffer 5x cho re-render và thử nghiệm chất lượng.

## 8 Bundle files

| Bundle | Source file | Phrase count | Use case |
|--------|-------------|--------------|----------|
| bundle-milestone-vi.mp3 | vi-milestone.json | 40 vi phrase (4 style x 10) | Mỗi km |
| bundle-milestone-en.mp3 | en-milestone.json | 40 en phrase | English users |
| bundle-pace-vi.mp3 | vi-pace-warning.json | 30 vi | Pace too fast/slow/on |
| bundle-motivation-vi.mp3 | vi-motivation.json | 60 vi | 25/50/75 progress |
| bundle-startstop-vi.mp3 | vi-start-stop.json | 30 vi | Start/pause/resume/finish |
| bundle-hr-vi.mp3 | vi-heart-rate-zone.json | 20 vi | HR zone transitions |
| bundle-weather-vi.mp3 | vi-weather.json | 15 vi | Weather/AQI alerts |
| bundle-streak-vi.mp3 | vi-streak.json | 20 vi | Streak milestones |

Tổng: ~255 phrase Việt + 40 Anh = 295 base. Phần còn lại cho variants với placeholder fill khi runtime:
- 100 phrase variants milestone (10 mức km: 1, 2, 3, 5, 7, 10, 15, 20, 21, 25)
- 50 phrase variants pace (4 mức pace target * 12 variants)
- 50 phrase variants HR/weather extreme

Khoảng 495-500 phrase pre-rendered.

## Giọng đọc

- **Voice A**: Vietnamese female warm, ID `vi_female_warm`. Dùng cho gentle, milestone, motivation, weather.
- **Voice B**: Vietnamese male confident, ID `vi_male_drill`. Dùng cho drill, HR Z5, pace warning fast.
- **Voice C** (optional): English neutral, ID `en_neutral`. Dùng cho en-milestone bundle.

User chọn voice trong settings, mặc định Voice A.

## Quy trình render

1. Đọc tất cả JSON trong `content/voice-scripts/vi-*.json`.
2. Với mỗi template, thay placeholder `{km}` `{pace}` `{hr}` `{temp}` `{aqi}` bằng các giá trị thực:
   - `{km}` -> các giá trị 1, 2, 3, 5, 7, 10, 15, 20, 21, 25, 30, 42
   - `{pace}` -> các giá trị "năm phút ba mươi", "sáu phút mười", "bảy phút"
   - `{hr}` -> các giá trị "một trăm bốn mươi", "một trăm sáu mươi"
   - `{temp}` -> "ba mươi hai", "ba mươi lăm", "mười tám"
   - `{aqi}` -> "một trăm năm mươi", "hai trăm"
3. Gọi ElevenLabs API stream, lưu MP3 từng đoạn vào `voice-cache/{voice_id}/{phrase_hash}.mp3`.
4. Concat thành 8 bundle dùng `ffmpeg -f concat -safe 0 -i list.txt -c copy output.mp3`.
5. Sinh manifest JSON `voice-manifest.json` chứa mapping phrase_id -> byte offset trong bundle.
6. Upload bundle lên Supabase Storage `voice/` public bucket, set Cache-Control 1 năm.

## Runtime selection

1. App load voice-manifest.json lúc start.
2. Khi cần phát phrase: lookup phrase_id + filled placeholder -> bundle URL + byte range.
3. Nếu pre-rendered: dùng range request `Range: bytes=offset-end`, play ngay.
4. Nếu không có (rare placeholder combo): fallback streaming TTS qua Edge Function.

## Cập nhật

- Mỗi quý refresh các phrase mới (seasonal badges, holiday alerts).
- Nếu thay voice ID: re-render full bundle, bump manifest version.
- Khuyến cáo giới hạn pre-render dưới 600 phrase để bundle dưới 30 MB.

## Ưu tiên render

Render theo thứ tự P0 -> P2:

**P0 (luôn dùng, render đầu tiên):**
- vi-milestone neutral 10 phrase * 12 km variants = 120
- vi-start-stop tất cả 30 phrase
- vi-pace-warning gentle 10 phrase * 4 pace = 40

**P1 (dùng thường xuyên):**
- vi-motivation 50/75 progress
- vi-heart-rate-zone 20
- vi-streak 20

**P2 (dùng đôi khi):**
- vi-weather 15
- vi-milestone drill + funny 20 phrase
- en-milestone 40

Khi budget không đủ render hết, ưu tiên P0 + P1 = ~250 phrase = ~$15.
