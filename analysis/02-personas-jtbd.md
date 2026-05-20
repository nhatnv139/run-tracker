# 02 - User Personas & Jobs-To-Be-Done

Phân tích UX cho app chạy bộ + đếm bước + đếm calo, mục tiêu Top App Store Việt Nam (6 tháng đầu).

### 1. SÁU PERSONA CHI TIẾT

| Thuộc tính | Linh (Office Lady) | Anh Hùng (Marathoner) | Bà Mai (Senior) | Minh (Gen Z) | Phương (Mẹ bỉm) | Trung (PT/Coach) |
|---|---|---|---|---|---|---|
| Tuổi | 28 | 35 | 55 | 20 | 32 | 29 |
| Nghề | NV marketing | Kỹ sư phần mềm | Hưu trí/nội trợ | Sinh viên năm 3 | Mẹ bỉm + bán online | Personal Trainer |
| Thu nhập (VND/tháng) | 18–25tr | 40–60tr | 8–12tr | 3–5tr | 10–15tr | 25–40tr |
| Thiết bị | iPhone 13, AirPods | iPhone 15 Pro + Garmin FR255 | iPhone SE/Android tầm trung | Xiaomi/Samsung A | iPhone 12 cũ | iPhone 14 + Apple Watch |
| Mục tiêu | Giảm 5–7kg | PR sub-4h marathon | 6–8k bước/ngày giữ huyết áp | Body đẹp flex IG/TikTok | Lấy lại dáng sau sinh | Theo dõi học viên, làm content |
| Pain points | Lười, sợ nắng, không biết ăn bao calo | App quốc tế thiếu cộng đồng VN | Chữ nhỏ, thao tác phức tạp | App đắt, ghét ads, nhanh chán | Không có 30p liền mạch | Cần report cho học viên |
| Willingness-to-pay | 49–99k/th | 199–299k/th + lifetime | 0đ (con mua hộ) | 0–29k/th | 59k/th gói gia đình | 299k/th |
| Kênh khám phá | TikTok review, Zalo OA | FB chạy bộ (LDR, SRC), Strava | Con cháu cài hộ | TikTok challenge, KOL Gen Z | FB "Mẹ bỉm khỏe đẹp" | IG fitness VN, hội PT |

### 2. JOB STORIES (JTBD)

**Linh:**
- Khi tan làm 6h tối mệt mỏi, tôi muốn app gợi ý bài đi bộ 20p quanh nhà, để bắt đầu mà không phải nghĩ.
- Khi ăn trưa văn phòng, tôi muốn quét nhanh món phở/cơm tấm, để biết còn bao nhiêu calo cho bữa tối.
- Khi cân không giảm, tôi muốn xem biểu đồ tuần, để biết đốt vs ăn bao nhiêu.
- Khi bạn rủ tụ tập, tôi muốn khoe streak 14 ngày lên story, để tự tạo áp lực.

**Anh Hùng:**
- Khi lên giáo án 16 tuần trước race, tôi muốn app tự gen lịch interval/long run.
- Khi chạy long run 30km, tôi muốn pin trụ 4h và auto-pause chuẩn.
- Khi xong workout, tôi muốn sync sang Strava/Garmin Connect.
- Khi tìm bạn chạy HN, tôi muốn lọc pace 5:00/km khu Hồ Tây.

**Bà Mai:**
- Khi đi bộ sáng quanh công viên, tôi muốn app tự đếm bước, để chỉ bỏ điện thoại trong túi.
- Khi đạt 8000 bước, tôi muốn giọng đọc tiếng Việt khích lệ.
- Khi đi khám định kỳ, tôi muốn in báo cáo bước/tuần đưa bác sĩ.

**Minh:**
- Khi rảnh giữa lớp, tôi muốn quest "chạy 1km đổi skin avatar".
- Khi chạy xong, tôi muốn 1 chạm tạo video TikTok có nhạc + bản đồ.
- Khi xếp hạng tuần, tôi muốn so với bạn cùng trường.
- Khi hết data, tôi muốn dùng offline.

**Phương:**
- Khi con ngủ trưa 15p, tôi muốn bài tập tại chỗ đốt calo.
- Khi đẩy xe nôi đi dạo, tôi muốn app tính là vận động hợp lệ.
- Khi cho con bú đêm, tôi muốn log nhanh đã ăn gì.

**Trung:**
- Khi học viên gửi kết quả, tôi muốn dashboard HR/pace 10 người để feedback hàng loạt.
- Khi quay TikTok hướng dẫn, tôi muốn export overlay số liệu đẹp.
- Khi onboarding học viên mới, tôi muốn share template giáo án 1 link.

### 3. USER JOURNEY MAP - LINH

```
GIAI ĐOẠN     | TOUCHPOINT                  | HÀNH ĐỘNG                 | EMOTION         | PAIN POINT
--------------|-----------------------------|---------------------------|-----------------|--------------------------
Discover      | TikTok reel KOL giảm 5kg    | Xem hết 30s, lưu video    | Tò mò, hoài     | Đã thử nhiều app
              |                             |                           | nghi            | thất vọng
Install       | App Store search            | Đọc review, screenshot    | Phân vân        | 320MB nặng với 3G,
              |                             |                           |                 | review tiếng Anh khó tin
Onboarding    | Splash + 5 câu hỏi          | Nhập tuổi/cân/mục tiêu    | Hào hứng        | Hỏi quá nhiều, sợ lộ
              |                             |                           |                 | data, bắt đăng ký
First run     | Notification 6h "Chạy nào"  | Đi bộ 15p trước cửa nhà   | Phấn khích      | Sợ chạy tối 1 mình, GPS
              |                             |                           |                 | sai trong hẻm, drain pin
Habit forming | Daily reminder + streak     | Vào app 5/7 ngày, log     | Tự hào xen      | Quên log, mất streak
(tuần 1-3)    | badge                       | calo bữa trưa             | nghi ngờ        | thấy bỏ cuộc
Subscribe     | Paywall ngày 7: meal plan   | Suy nghĩ 2 ngày, mua gói  | Do dự rồi cam   | 99k = 3 trà sữa, sợ
              | VN                          | 3 tháng 199k              | kết             | auto-renew khó huỷ
Refer         | Pop-up "Mời bạn 1 tháng     | Share link Zalo 2 bạn     | Hãnh diện       | Ngại làm phiền, sợ bị
              | free"                       | thân                      |                 | nghĩ MLM
```

### 4. TOP 10 MOTIVATION & 10 BARRIER

**Motivation:** (1) Áp lực hình thể trước cưới/Tết/biển hè; (2) Social proof KOL Việt > chuyên gia ngoại; (3) Streak + badge tạo cảm giác tiếc công; (4) Gia đình quan tâm sức khỏe hậu Covid; (5) So sánh bảng xếp hạng bạn bè Zalo/FB; (6) Trial 7-14 ngày thấy kết quả rõ; (7) Nội dung tiếng Việt (giọng đọc, meal phở/bún); (8) Phần thưởng voucher Highlands/Grab; (9) Cộng đồng CLB phường/công ty tạo cam kết xã hội; (10) UI đẹp share story được.

**Barrier:** (1) Nắng nóng 35-40°C + ô nhiễm HN/TPHCM; (2) Sợ tốn 4G khi GPS liên tục; (3) Sợ tụt pin (máy 2-3 năm); (4) Lo riêng tư lộ vị trí nhà/cty; (5) Ngại chạy ngoài đường (nữ, người lớn tuổi); (6) Vỉa hè không an toàn, xe máy, chó thả; (7) Paywall sớm bị phản cảm, quen free; (8) Onboarding dài bỏ ngang câu 4-5; (9) Tiếng Anh pace/cadence/VO2max khó hiểu; (10) Auto-renew bị coi là "lừa".

### 5. KHÁC BIỆT VN vs GLOBAL

| Khía cạnh | Việt Nam | Global |
|---|---|---|
| GPS | Ngại bật, sợ lộ + tốn pin/data | Tự nhiên bật |
| Chia sẻ | Zalo nhóm thân + TikTok > FB public | Strava feed, IG Stories |
| Thanh toán | Momo, ZaloPay; thích trả 1 lần | Credit card auto-renew |
| Pricing | Nhạy cảm, so với trà sữa, thích sale 50-70% | $9.99/th bình thường |
| Ngôn ngữ | Bắt buộc tiếng Việt thuần, TTS Bắc/Nam | English native |
| Wearable | Ít smartwatch, chủ yếu phone trong túi | Apple Watch/Garmin phổ biến |
| Cộng đồng | Group Zalo/FB đóng, người quen thật | Strava public, Reddit |
| Nội dung | Reel 15-30s, KOL local | Podcast dài, blog chuyên sâu |
| Timing | Sáng 5-6h hoặc tối 6-8h tránh nắng | Linh hoạt cả ngày |
| Niềm tin | Testimonial người Việt, ảnh before/after | Stats science-backed |

### 6. TARGET 6 THÁNG ĐẦU

**Ưu tiên #1 - Linh (Office Lady 25-32 giảm cân) - 60% nguồn lực:** Quy mô 5-7tr người, sẵn sàng trả, viral TikTok/IG, feedback vòng tuần. Acquisition: TikTok ads + KOC nữ 50-200k follower + Zalo OA.

**Ưu tiên #2 - Minh (Gen Z 18-24 gamification) - 25%:** Viral coefficient cao, free + ads + UGC TikTok làm content engine cho persona #1.

**Ưu tiên #3 - Trung (PT/Coach) - 15%:** B2B2C, mỗi coach kéo 10-30 học viên trả phí, LTV cao. Gói Coach Pro 299k cho gross margin.

**Hoãn tháng 7+:** Anh Hùng (niche, khó dứt Strava/Garmin), Bà Mai (UX khác biệt, ARPU thấp), Phương (cần feature vận động ngắn riêng).

**Lý do chiến lược:** Top App Store cần volume nhanh - Linh + Minh tạo virality, Trung tạo doanh thu để mua ads vòng sau. Đạt top 10 Health & Fitness rồi mở rộng.
