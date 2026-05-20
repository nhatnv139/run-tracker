# RunVie — Screenshots Designer Brief

> Owner: Brand / Marketing Design Lead | Last updated: 2026-05-20
> Delivery deadline: 2 tuần trước submission TestFlight (W-6)

---

## 0. Global specifications

### Brand system — Aurora Energy

| Token | Value |
|-------|-------|
| Coral | #FF6B6B |
| Mint | #4ECDC4 |
| Lavender | #A78BFA |
| Ink (text) | #1A1A2E |
| Cloud (light bg) | #F8F9FF |
| Aurora gradient | linear-gradient(135deg, #FF6B6B 0%, #A78BFA 50%, #4ECDC4 100%) |
| Font headline | Be Vietnam Pro Bold 96–120pt |
| Font subhead | Be Vietnam Pro Semibold 48pt |
| Font body | Be Vietnam Pro Regular 32pt |

### Layout grid

```
┌──────────────────────────┐
│   30% — Headline zone    │  background = Aurora gradient blur, dark overlay 20%
│   (text + tagline)       │  text = white, drop-shadow 0 4px 12px rgba(0,0,0,.15)
├──────────────────────────┤
│                          │
│   70% — Device zone      │  device mockup ánh sáng từ trên-trái 45°
│   (phone/tablet mockup)  │  shadow 0 24px 60px rgba(26,26,46,.25)
│                          │
└──────────────────────────┘
```

### Device sizes (deliverable matrix)

| Device | Resolution | Quantity per screenshot |
|--------|-----------|-----------------------|
| iPhone 6.7" (15 Pro Max) | 1290 × 2796 | 8 |
| iPhone 6.1" (15 Pro) | 1179 × 2556 | 8 |
| iPad Pro 12.9" (M2) | 2048 × 2732 | 8 (landscape + portrait) |
| Android phone | 1080 × 1920 minimum, 1440 × 3120 preferred | 8 |
| Android tablet | 1920 × 1200 (10") | 8 |

Total: **8 frames × 5 device variants = 40 final assets** (PNG, sRGB, no transparency).

### File naming convention

```
runvie-{store}-{device}-{order}-{slug}.png
e.g. runvie-apple-iphone67-01-hero.png
e.g. runvie-play-androidphone-05-runcoin.png
```

---

## 1. Screenshot 1 — Hero (Run Active)

**Goal**: 1-second emotional hook. "App này hiểu mình."

| Element | Spec |
|---------|------|
| Headline | `Chạy bộ thông minh với AI Coach Việt` (4 dòng max, font 110pt) |
| Subhead | `Mỗi bước chân là một câu chuyện` (48pt, opacity 80%) |
| Device | iPhone 15 Pro Max màu Titan Đen |
| In-app content | Run active screen, distance `5.42` km font 96pt số to nhất màn hình, pace `5'42"/km`, time `30:48`, heart rate `156 bpm` |
| Map | Route Hồ Tây Hà Nội (loop 5.5km), polyline Aurora gradient, GPS dot pulsing Coral |
| Stats card bottom | Calo `412 kcal`, RunCoin earned `+5 RC` |
| Background | Aurora gradient diagonal 135°, blur 40 |
| CTA | None (hero screenshot, không CTA) |

**Notes**:
- Battery icon 88%, signal full.
- Time hiện trên status bar `06:42` (sáng sớm — emotional cue).
- Tránh lat/long GPS thật → dùng fake route polyline tự vẽ.

---

## 2. Screenshot 2 — AI Coach tiếng Việt

**Goal**: Chứng minh USP1 nghe nói được tiếng Việt tự nhiên.

| Element | Spec |
|---------|------|
| Headline | `Coach tiếng Việt 24/7` (110pt) |
| Subhead | `Hỏi gì cũng trả lời, hiểu cả từ lóng` (44pt) |
| Device | iPhone 15 Pro Max màu Titan Trắng |
| In-app content | Chat bubble UI |
| User bubble 1 (Lavender) | `Hôm nay chạy 5km mà pace 6'30, có chậm quá không bạn?` |
| AI bubble 1 (Mint) | `Pace 6'30 với người bắt đầu là rất ổn rồi. Tuần trước bạn còn 6'58. Cứ giữ nhịp này, tuần sau mình thử pace 6'15 nhé?` |
| User bubble 2 | `Đầu gối hơi đau, mai có nên nghỉ không?` |
| AI bubble 2 | `Mai nên đi bộ nhẹ 20 phút thay vì chạy. Recovery score của bạn đang 62/100 — cơ thể cần thêm 1 ngày phục hồi.` |
| Bottom input | Microphone icon + textfield `Hỏi coach...` |

**Notes**:
- Avatar AI Coach: hình tròn gradient Aurora, không dùng emoji.
- Timestamp `Hôm nay, 19:42`.

---

## 3. Screenshot 3 — Walking First

**Goal**: USP2 "đi bộ cũng tính". Đối tượng 45+ và phụ huynh.

| Element | Spec |
|---------|------|
| Headline | `Đi bộ cũng tính — Mỗi bước đều đáng` (110pt) |
| Subhead | `Bắt đầu từ 1.000 bước/ngày` (44pt) |
| Device | iPhone 15 Pro Max |
| In-app content | Daily Steps screen |
| Big ring | Step counter `8.247 / 10.000`, ring fill 82% Mint → Coral gradient |
| Below ring | `Hôm nay`, weekly bar chart 7 cột |
| Hero photo (overlay góc dưới phải) | Ảnh thực tế người ~ 55 tuổi đi bộ công viên Thống Nhất HN, áo polo trắng, sáng sớm |
| Stats row | `4.2 km`, `312 kcal`, `+8 RC` |
| Achievement toast | `Bạn vừa đạt 8.000 bước — tuần thứ 3 liên tiếp!` |

**Photo direction**: avoid stock, dùng ảnh shoot riêng. Người đi bộ NHÌN xuống điện thoại đang cầm = action shot, không pose.

---

## 4. Screenshot 4 — Calo món Việt

**Goal**: Tính năng nội địa duy nhất — competitor không có.

| Element | Spec |
|---------|------|
| Headline | `Đếm calo món Việt chính xác` (110pt) |
| Subhead | `800+ món Việt trong database` (44pt) |
| Device | iPhone 15 Pro Max |
| In-app content | Food log screen |
| Hero food card top | Tô phở bò 2D illustration (KHÔNG dùng ảnh thật để không lệ thuộc license), label `Phở bò tái chín`, `415 kcal`, `Đã ghi 07:12` |
| Food list | `Bún chả 580 kcal`, `Cơm tấm sườn 720 kcal`, `Cà phê sữa đá 142 kcal`, `Bánh mì pate 365 kcal` |
| Bottom summary | Doughnut chart: Protein 28%, Carb 52%, Fat 20%. Total `1.823 / 2.100 kcal` |
| Add button | `+ Thêm bữa ăn` Coral pill button |

**Notes**:
- Tô phở minh hoạ vector, không ảnh chụp (tránh licensing). Style: flat illustration 2D, mint-coral palette.
- Calo numbers phải khớp DECISIONS.md database (nếu có) hoặc consult nutritionist trước final.

---

## 5. Screenshot 5 — RunCoin Marketplace

**Goal**: USP3 reward thật — viral moment.

| Element | Spec |
|---------|------|
| Headline | `Đổi km thành voucher thực` (110pt) |
| Subhead | `Shopee, Grab, MoMo, Highlands...` (44pt) |
| Device | iPhone 15 Pro Max |
| In-app content | Marketplace grid 2 cột |
| Card 1 | Logo Shopee, `Voucher 50K`, `300 RC`, badge `Hot` Coral |
| Card 2 | Logo Grab, `GrabBike 30K`, `180 RC` |
| Card 3 | Logo MoMo, `Hoàn tiền 20K`, `120 RC` |
| Card 4 | Logo Highlands, `Phin sữa đá`, `200 RC`, badge `Mới` Mint |
| Card 5 | Logo GrabFood, `Voucher 40K`, `240 RC` |
| Card 6 | Logo The Coffee House, `Trà đào 50K`, `200 RC` |
| Top bar | User balance `Số dư: 847 RC`, icon Coin Aurora |
| Bottom CTA | `Đổi ngay` button full-width Aurora gradient |

**Notes**:
- Logo đối tác MUST có legal clearance trước khi xuất bản. Phase 1 placeholder dùng wordmark monochrome nếu chưa có chính thức.
- KHÔNG promise voucher rate cố định trong screenshot (Apple 2.3.1 misleading).

---

## 6. Screenshot 6 — Year Heatmap

**Goal**: Retention proof — show committed runners stay 365 days.

| Element | Spec |
|---------|------|
| Headline | `Năm 365 ngày liền mạch` (110pt) |
| Subhead | `Mỗi ô vuông là một buổi tập` (44pt) |
| Device | iPhone 15 Pro Max |
| In-app content | Year Heatmap screen |
| Grid | 52 tuần × 7 ngày, ô 18pt, gap 4pt, scroll horizontal |
| Color scale | 5 mức: empty `#F0F0F5`, low Mint 30%, mid Mint 60%, high Coral 80%, peak Aurora gradient |
| Stats top | `Streak hiện tại: 47 ngày`, `Streak dài nhất: 89 ngày`, `Tổng buổi tập năm 2026: 184` |
| Highlighted week | Tuần hiện tại có viền Coral 2pt |
| Tap state hover bubble | Ngày 12/5: `5.42 km · 5'42" · 412 kcal` |

**Inspiration**: GitHub contribution graph nhưng warm palette Aurora.

---

## 7. Screenshot 7 — Virtual Race

**Goal**: Emotional aspiration — medal vật lý, gốm Bát Tràng.

| Element | Spec |
|---------|------|
| Headline | `Chạy ảo, huy chương thật` (110pt) |
| Subhead | `Hà Nội → Sài Gòn 1.730km` (44pt) |
| Device | iPhone 15 Pro Max |
| In-app content | Virtual Race progress screen |
| Map | Bản đồ Việt Nam đường cong từ HN xuống SG, dấu chấm progress ở vị trí Quảng Ngãi (1.018km/1.730km = 59%) |
| Progress bar | 59% Aurora gradient |
| Cities passed | Mini avatars các thành phố: Hà Nội ✓, Nam Định ✓, Vinh ✓, Huế ✓, Đà Nẵng ✓, Quảng Ngãi 🏃 (current) |
| Reward preview card | Render 3D medal gốm Bát Tràng hình tròn, có chữ `HN → SG · 2026` chạm tay, được hold bởi bàn tay người (overlay góc) |
| ETA | `Còn 712km · ước tính 9 tuần` |

**Notes**:
- Render medal 3D giao designer làm Blender, MUST có ảnh thực tế prototype gốm Bát Tràng trước khi screenshot final.
- KHÔNG promise delivery date cụ thể trong screenshot.

---

## 8. Screenshot 8 — Community

**Goal**: Social proof — không cô đơn khi chạy.

| Element | Spec |
|---------|------|
| Headline | `Cộng đồng chạy bộ Việt` (110pt) |
| Subhead | `1.000+ câu lạc bộ đang hoạt động` (44pt) |
| Device | iPhone 15 Pro Max |
| In-app content | Club feed |
| Top section — Leaderboard tuần | Top 3 user (Mai 47.2km, Hùng 42.8km, Linh 38.5km), avatar + km tuần |
| Mid — Feed post 1 | User `Trang_Run`, ảnh selfie sau chạy Hồ Tây HN, caption `Sáng nay 8K liền tù tì, đầu năm chưa bao giờ thấy khoẻ thế này`, 47 likes, 12 comments |
| Mid — Feed post 2 | User `KhoaMarathon`, ảnh medal HCM Marathon, caption `Sub 4 finally! Cảm ơn anh em RunVie HCM Crew`, 128 likes |
| Bottom CTA | `Tạo câu lạc bộ` Coral button |

**Notes**:
- Avatar phải đa dạng giới tính + độ tuổi (không chỉ nam 25-30).
- Caption phải tự nhiên, không viết kiểu marketing slogan.
- Tất cả user/photo trong screenshot là FAKE/MODEL — phải có release form ký trước.

---

## 9. iPad-specific adaptations

iPad screenshot dùng landscape orientation, 2 column:
- Left 40%: headline + tagline + secondary bullets
- Right 60%: device mockup

Nội dung 8 frame giữ nguyên, chỉ đổi layout.

---

## 10. Android (Google Play) adaptations

- Material 3 design tokens — dùng Aurora gradient cho FAB và top app bar.
- Headline font size giảm 10% vì viewport ngắn hơn.
- Navigation bottom bar 5 tab (Today, Train, Coach, Reward, Profile) thay vì iOS tab bar.

---

## 11. Localization variants

| Locale | Đổi gì |
|--------|--------|
| en-US | Replace headline + UI strings sang English |
| vi-VN | Default (như trên) |
| th-TH | Phase 2 — translate + thay route map Bangkok loop |
| id-ID | Phase 2 — translate + thay route Jakarta |

---

## 12. Quality checklist (designer sign-off)

- [ ] Status bar mỗi screenshot: thời gian `06:42` (sáng) hoặc `19:42` (tối), wifi full, battery >85%
- [ ] KHÔNG có notification badge thật của app khác
- [ ] KHÔNG có Apple Pay, Live Activity của ứng dụng khác trong status
- [ ] Tất cả số liệu nội dung CONSISTENT giữa 8 frame (cùng 1 nhân vật `Mai 34 tuổi HN`)
- [ ] Font Be Vietnam Pro rendering tốt với dấu (kiểm tra `ờ ữ ặ ằ ẵ`)
- [ ] Color contrast WCAG AA (>4.5:1) cho headline trên gradient
- [ ] Export sRGB, 72 DPI, PNG-24, dưới 8MB mỗi file
- [ ] Test preview trên iPhone thật 6.7" thực sự hiển thị đúng (không bị cropping nội dung headline)

---

## 13. Approval pipeline

```
Designer brief → wireframe (1 ngày) → mockup v1 (3 ngày) → 
  Brand + Legal review (1 ngày) → mockup v2 (1 ngày) → 
  ASO Lead final approval → Export 5 device variants → 
  Upload App Store Connect & Play Console
```

Total runway: **7 ngày** từ kickoff đến upload.
