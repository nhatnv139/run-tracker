# RunVie Brand Kit

> Hệ thống nhận diện cho **RunVie** — ứng dụng theo dõi chạy bộ dành cho người Việt.
> Concept: **Aurora Energy** — năng lượng rạng đông, bình minh sau cú chạy đầu ngày.

---

## 1. Brand Essence

| Trục | Định nghĩa |
| --- | --- |
| **Personality** | Bạn đồng hành (companion), không phải huấn luyện viên la hét. |
| **Promise** | "Mỗi bước chạy đều có ý nghĩa." |
| **Feel** | Ấm áp, sáng, có nhịp — như ánh bình minh trên đường chạy ven hồ. |
| **Audience** | Người Việt 22-40 tuổi, chạy 3-5 buổi/tuần, đa phần đô thị. |

---

## 2. Voice & Tone

**Ngôn ngữ chính: tiếng Việt, xưng "bạn".**

### Nguyên tắc viết
- Ngắn, đi thẳng vào ý — câu dưới 18 từ là tốt.
- Động viên *nhẹ*, không hét. KHÔNG dùng dấu chấm than liên tiếp, KHÔNG viết HOA cả từ.
- Khen cụ thể, dùng số liệu thật. ("Bạn vừa chạy nhanh hơn 12s/km so với tuần trước.")
- Khi user fail target: thừa nhận → bình thường hóa → đề xuất bước nhỏ. Không xin lỗi giùm họ.
- Số liệu pace, tốc độ, nhịp tim luôn ở mono font, dính đơn vị: `5:32 /km`, `142 bpm`.

### Do / Don't ngôn ngữ

| Do | Don't |
| --- | --- |
| "Tuần này bạn đã chạy 18 km. Tăng 6% so với tuần trước." | "WOW! BẠN QUÁ ĐỈNH!!! 18KM LÀ TUYỆT VỜI!!!" |
| "Hôm nay nghỉ cũng được — cơ thể cần phục hồi." | "Đừng lười! Phải chạy mới khỏe!" |
| "Mục tiêu 5K sub-25, còn 3 buổi tập nữa." | "Cố lên chiến binh! Hôm nay là ngày của bạn!" |
| "Giày của bạn đã chạy 420 km, cân nhắc đổi đôi mới." | "Giày sắp hỏng rồi nha bạn ơiii 😱😱" |

---

## 3. Logo

### File reference

| File | Khi nào dùng |
| --- | --- |
| `logo/logo-mark.svg` | Avatar, splash, social profile (square). |
| `logo/logo-wordmark.svg` | Header website, marketing — nền sáng có màu. |
| `logo/logo-mono-light.svg` | Trên nền tối hoặc ảnh tối. |
| `logo/logo-mono-dark.svg` | Trên nền sáng cần đơn sắc (in ấn 1 màu, watermark). |
| `favicon/favicon.svg` | Browser tab. |
| `app-icon/icon-1024.svg` | iOS / Android app icon master. |

### Clear-space
Khoảng trắng tối thiểu xung quanh logo = **chiều cao chữ "R"** của wordmark. Không có gì (text, ảnh, viền) được lấn vào vùng này.

### Minimum size
- **Wordmark**: 96 px chiều rộng trên screen, 24 mm khi in.
- **Mark riêng**: 24 px trên screen, 8 mm khi in.
- Dưới 16 px (favicon), dùng file `favicon.svg` đã được tối ưu nét.

### Logo Do / Don't

| Do | Don't |
| --- | --- |
| Dùng nguyên file SVG gốc | Re-draw hoặc thay font wordmark |
| Đặt trên nền có contrast ≥ 4.5:1 | Đặt lên ảnh rối, không có overlay |
| Dùng `logo-mono-*` khi không thể giữ gradient | Đổi màu gradient sang bảng khác |
| Giữ tỷ lệ khi resize | Bóp méo / stretch / nghiêng |
| Để clear-space đầy đủ | Crop sát viền tròn mark |

---

## 4. Color System

### Brand core
| Vai trò | Hex | Token |
| --- | --- | --- |
| Primary — Coral | `#FF5A36` | `brand.primary` |
| Secondary — Mint | `#00D4A8` | `brand.secondary` |
| Tertiary — Lavender | `#7B5CFF` | `brand.tertiary` |

### Neutrals
`#FAFAF7` canvas · `#FFFFFF` surface · `#1A1A1F` ink · `#6B6B73` muted · `#0A0A0A` deep ink.

### HR Zones
| Zone | Hex | Ý nghĩa |
| --- | --- | --- |
| Z1 | `#4ADE80` | Recovery |
| Z2 | `#FACC15` | Aerobic |
| Z3 | `#FB923C` | Tempo |
| Z4 | `#EF4444` | Threshold |
| Z5 | `#B91C1C` | Max |

### Gradient Aurora
Hero gradient: `#FF5A36 → #7B5CFF → #00D4A8`, dùng cho hero, achievement card, milestone burst.
Mark gradient: `#FF5A36 → #00D4A8`, dùng cho logo & app icon.

### Color usage rules
1. **60 / 30 / 10**: 60% neutral, 30% primary (coral), 10% accent (mint/lavender).
2. **Một CTA chính / màn hình.** Coral chỉ dành cho hành động quan trọng nhất.
3. **Mint = success / recovery / completed.** Không dùng mint cho destructive.
4. **Lavender = focus / data / insight.** Charts secondary line, AI feature.
5. **HR zone colors** chỉ dùng trong biểu đồ nhịp tim. Không dùng làm UI ngẫu nhiên.
6. **Đỏ Z4/Z5** không được trùng vai trò với `feedback.danger` — danger dùng `#EF4444` riêng cho lỗi UI, zone dùng cho dữ liệu.
7. Mọi tổ hợp text/bg phải đạt WCAG AA (≥ 4.5:1 cho body, ≥ 3:1 cho large text).

---

## 5. Typography

**Font chính: Be Vietnam Pro** — chứa đầy đủ dấu tiếng Việt, optical size cân bằng giữa hiển thị màn hình và in.

| Style | Size / LH | Dùng cho |
| --- | --- | --- |
| Display XL — 64/68 ExtraBold | Hero landing |
| Display L — 48/54 ExtraBold | Stat lớn (tổng km tuần) |
| Heading L — 32/40 Bold | Tiêu đề màn hình |
| Heading M — 24/32 Bold | Section, card title |
| Heading S — 20/28 SemiBold | Sub-section |
| Body L — 18/28 Regular | Motivational copy |
| Body M — 16/24 Regular | UI body mặc định |
| Body S — 14/20 Regular | Helper, caption phụ |
| Caption — 12/16 Medium | Tag, badge |
| Mono — 14/20 Medium (JetBrains Mono) | Pace, time, splits |

### Pairing rules
- Heading luôn ExtraBold (800) hoặc Bold (700). Không dùng weight nhẹ hơn 600 cho heading.
- Body luôn Regular (400). Tăng SemiBold (600) cho emphasis trong câu thay vì italic.
- KHÔNG dùng italic cho tiếng Việt — dấu thanh đọc khó.
- Số liệu luôn `font-variant-numeric: tabular-nums` để cột thẳng hàng.

---

## 6. Spacing, Radius, Shadow, Motion

- **Spacing**: 4pt grid (`tokens/spacing.json`). Padding card mặc định = `lg` (24px). Page gutter mobile = `md` (16px), desktop = `2xl` (48px).
- **Radius**: button & chip = `full`, card = `lg` (20px), modal = `xl` (32px).
- **Shadow**: Resting `sm`, hover `md`, modal `lg`. Glow `glowCoral` chỉ dùng cho CTA hero.
- **Motion**: Mọi transition UI ≤ 400ms. Dùng `easing.standard` cho fade, `easing.spring` cho pop. Achievement celebrate được phép `celebrateBurst` 600ms.

---

## 7. Imagery & Iconography (định hướng)

- **Ảnh**: real people, ánh sáng vàng đầu ngày / cuối ngày, không stock cười toe toét. Người Việt là chính.
- **Icon**: stroke 1.75px, line-join round, corner radius 2px, kích thước 24×24 cơ bản.
- **Illustration**: vector geometric, dùng đúng 3 màu brand + 1 neutral. Không gradient nhiều màu rối.

---

## 8. File Structure

```
brand/
├── README.md                    # File này
├── logo/
│   ├── logo-mark.svg            # Mark gradient 256×256
│   ├── logo-wordmark.svg        # Wordmark + mark 640×160
│   ├── logo-mono-light.svg      # Trắng cho dark bg
│   └── logo-mono-dark.svg       # Đen cho light bg
├── favicon/
│   └── favicon.svg              # 32×32
├── app-icon/
│   └── icon-1024.svg            # iOS master 1024×1024
└── tokens/
    ├── colors.json
    ├── typography.json
    ├── spacing.json
    ├── radius.json
    ├── shadow.json
    └── motion.json
```

---

## 9. Versioning

Brand kit version **1.0.0** — 2026-05-20. Mọi thay đổi token (đổi hex, thêm scale) phải bump minor; thay đổi logo / wordmark phải bump major và migration guide kèm theo.
