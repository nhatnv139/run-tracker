# CHÍNH SÁCH COOKIE – RUNVIE

**Phiên bản:** 1.0
**Ngày ban hành:** 20 tháng 5 năm 2026
**Ngày có hiệu lực:** 20 tháng 5 năm 2026

---

## 1. Giới thiệu

Chính sách Cookie này giải thích cách Công ty TNHH RunVie ("RunVie", "Chúng tôi") sử dụng cookie và các công nghệ tương tự trên website **runvie.app**, các trang con (marketing, hỗ trợ, blog, hệ thống thanh toán) và phần webview tích hợp trong ứng dụng di động RunVie. Chính sách này là một phần không tách rời của Chính sách bảo mật.

Bằng việc truy cập runvie.app, bạn xác nhận đồng ý với việc sử dụng cookie như mô tả tại đây, trong giới hạn pháp luật cho phép.

## 2. Cookie và công nghệ tương tự là gì?

**Cookie** là tệp dữ liệu nhỏ được trang web lưu trên trình duyệt hoặc thiết bị của bạn để ghi nhớ thông tin về phiên truy cập.

**Công nghệ tương tự** mà chúng tôi sử dụng:

- **localStorage / sessionStorage:** Lưu cấu hình hiển thị, ngôn ngữ, theme.
- **IndexedDB:** Lưu cache dữ liệu workout offline trong PWA.
- **Pixel / web beacon:** Ảnh 1x1 pixel để theo dõi sự kiện email.
- **SDK định danh thiết bị (in-app):** IDFV trên iOS, Android ID, không phải IDFA – chúng tôi không yêu cầu App Tracking Transparency vì không sử dụng cross-app tracking.
- **Mã hóa biên (Cloudflare edge tokens).**

## 3. Phân loại cookie chúng tôi sử dụng

### 3.1. Cookie thiết yếu (Strictly Necessary)

Không thể tắt; cần thiết để website hoạt động.

| Tên | Mục đích | Nhà cung cấp | Thời hạn |
|---|---|---|---|
| `sb-access-token` | Token đăng nhập Supabase | Supabase | 1 giờ |
| `sb-refresh-token` | Token làm mới phiên | Supabase | 7 ngày |
| `cf_clearance` | Xác minh DDoS, WAF của Cloudflare | Cloudflare | 30 phút |
| `__Host-csrf` | Chống tấn công CSRF | RunVie | Phiên |
| `lang` | Ghi nhớ ngôn ngữ hiển thị | RunVie | 12 tháng |
| `cookie_consent` | Lưu lựa chọn cookie của bạn | RunVie | 12 tháng |

### 3.2. Cookie phân tích (Analytics)

Chỉ kích hoạt khi bạn đồng ý.

| Tên | Mục đích | Nhà cung cấp | Thời hạn |
|---|---|---|---|
| `ph_*` (PostHog) | Đo lường tương tác sản phẩm, funnel | PostHog (EU – Frankfurt) | 12 tháng |
| `ph_distinct_id` | Định danh ẩn danh cho người dùng | PostHog | 12 tháng |
| `sentry-trace` | Theo dõi giao dịch để tìm lỗi | Sentry (EU – Frankfurt) | Phiên |

Chúng tôi đã cấu hình PostHog với **anonymize IP**, không thu thập địa chỉ IP đầy đủ, không tự động ghi mật khẩu hoặc dữ liệu nhạy cảm (mask all inputs).

### 3.3. Cookie chức năng (Functional)

| Tên | Mục đích | Nhà cung cấp | Thời hạn |
|---|---|---|---|
| `theme` | Lưu chế độ sáng/tối | RunVie | 12 tháng |
| `units` | Lưu đơn vị km/mi | RunVie | 12 tháng |
| `tz` | Múi giờ hiển thị | RunVie | 12 tháng |

### 3.4. Cookie tiếp thị (Marketing)

Chúng tôi **không sử dụng** cookie quảng cáo bên thứ ba (Google Ads, Facebook Pixel, TikTok Pixel). Nếu trong tương lai có triển khai, chúng tôi sẽ cập nhật Chính sách này và xin sự đồng ý lại.

### 3.5. Cookie xác thực thanh toán

| Tên | Mục đích | Nhà cung cấp | Thời hạn |
|---|---|---|---|
| `momo_*` | Phiên thanh toán MoMo | MoMo | Phiên |
| `zlp_*` | Phiên thanh toán ZaloPay | ZaloPay | Phiên |
| `iap_receipt_cache` | Cache biên lai IAP Apple/Google | RunVie | 24 giờ |

## 4. Công nghệ in-app

Trong ứng dụng di động RunVie, chúng tôi sử dụng các công nghệ tương đương cookie:

- **Secure Keychain (iOS) / EncryptedSharedPreferences (Android):** Lưu token đăng nhập an toàn.
- **PostHog SDK:** Theo dõi sự kiện trong ứng dụng (có cờ opt-out tại Cài đặt → Quyền riêng tư → Phân tích).
- **Sentry SDK:** Ghi nhận sự cố ứng dụng (có cờ opt-out tại Cài đặt → Quyền riêng tư → Báo cáo lỗi).
- **Cloudflare Workers KV:** Cache cấu hình từ xa.

## 5. Cơ sở pháp lý

5.1. Đối với cookie thiết yếu: chúng tôi dựa trên cơ sở **lợi ích hợp pháp** (Art. 6(1)(f) GDPR) và yêu cầu vận hành dịch vụ.

5.2. Đối với cookie phân tích, chức năng (không thiết yếu) và tiếp thị: chúng tôi yêu cầu **sự đồng ý có thông tin (informed consent)** của bạn theo:
- Art. 7 GDPR;
- ePrivacy Directive 2002/58/EC (Điều 5(3));
- Điều 11 Nghị định 13/2023/NĐ-CP.

5.3. Bạn có thể rút lại sự đồng ý bất kỳ lúc nào (xem Mục 6).

## 6. Quản lý cookie

### 6.1. Trong banner đồng ý

Khi truy cập runvie.app lần đầu, một banner Cookie sẽ hiển thị với các tùy chọn:
- **Đồng ý tất cả**
- **Chỉ thiết yếu**
- **Tùy chỉnh** (chọn từng loại)

Lựa chọn của bạn được lưu trong cookie `cookie_consent` và có thể thay đổi bất kỳ lúc nào tại **runvie.app/preferences/cookies**.

### 6.2. Trong cài đặt trình duyệt

Bạn có thể tắt cookie qua cài đặt trình duyệt. Tuy nhiên việc tắt cookie thiết yếu có thể khiến website không hoạt động đúng.

Hướng dẫn nhanh:
- **Chrome:** Settings → Privacy and Security → Cookies and other site data.
- **Safari:** Preferences → Privacy → Manage Website Data.
- **Firefox:** Settings → Privacy & Security → Cookies and Site Data.

### 6.3. Trong ứng dụng

Mở **Cài đặt → Quyền riêng tư** để tắt từng loại tracking (Analytics, Crash Reports).

## 7. Cookie của bên thứ ba và chuyển dữ liệu quốc tế

Một số cookie do bên thứ ba thiết lập (PostHog, Sentry, Cloudflare). Dữ liệu có thể được xử lý tại EU, Hoa Kỳ. Chúng tôi áp dụng SCC (Standard Contractual Clauses) cho việc chuyển dữ liệu ngoài EU/EEA và đã thông báo việc chuyển dữ liệu xuyên biên giới theo Điều 25 Nghị định 13/2023/NĐ-CP.

## 8. Thời gian lưu trữ

Cookie phiên (session cookie) bị xóa khi bạn đóng trình duyệt. Cookie cố định (persistent cookie) có thời hạn cụ thể trong các bảng ở Mục 3. Bạn có thể xóa thủ công bất kỳ lúc nào.

## 9. Trẻ em

Website runvie.app không hướng tới trẻ em dưới 13 tuổi. Chúng tôi không cố ý sử dụng cookie để định danh hoặc theo dõi trẻ em.

## 10. Thay đổi Chính sách

Chúng tôi có thể cập nhật Chính sách Cookie theo thời gian. Phiên bản mới được công bố tại runvie.app/legal/cookies với ngày ban hành mới. Đối với thay đổi quan trọng (ví dụ thêm cookie tiếp thị), chúng tôi sẽ hiển thị lại banner đồng ý.

## 11. Liên hệ

- Email DPO: **dpo@runvie.app**
- Email chung về bảo mật: **privacy@runvie.app**
- Trang quản lý ưu tiên: **runvie.app/preferences/cookies**

---

*Chính sách này được lập bằng tiếng Việt. Bản tiếng Anh chỉ mang tính tham khảo.*
