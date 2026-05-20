# ACCESSIBILITY STATEMENT – RUNVIE
## Tuyên bố về Khả năng Tiếp cận

**Version:** 1.0
**Effective date / Ngày có hiệu lực:** 20 May 2026

---

## 1. Our Commitment / Cam kết

**EN.** RunVie is committed to making its mobile applications and website accessible to people of all abilities. We strive to conform to the **Web Content Accessibility Guidelines (WCAG) 2.1 Level AA** published by the W3C, the **EN 301 549** European harmonised standard, and **Section 508** of the US Rehabilitation Act. We follow Apple's Human Interface Guidelines for Accessibility and Google's Material Design accessibility patterns.

**VI.** RunVie cam kết làm cho ứng dụng và website của mình dễ tiếp cận với người dùng thuộc mọi khả năng. Chúng tôi hướng đến tuân thủ **Web Content Accessibility Guidelines (WCAG) 2.1 cấp AA** của W3C, tiêu chuẩn châu Âu **EN 301 549**, và Mục 508 của Luật Phục hồi chức năng Hoa Kỳ. Chúng tôi áp dụng Hướng dẫn về Khả năng tiếp cận của Apple Human Interface và mẫu thiết kế Material Design của Google.

## 2. Standards / Tiêu chuẩn

We target conformance with the following:

| Standard | Level | Scope |
|---|---|---|
| WCAG 2.1 | AA | Website (runvie.app) and in-app webviews |
| WCAG 2.1 | AA (mobile equivalent) | iOS and Android apps |
| Apple Accessibility | Best practices | iOS app |
| Android Accessibility | Best practices | Android app |
| EN 301 549 v3.2.1 | All applicable | Public-sector EU procurement readiness |

## 3. Features Implemented / Tính năng đã triển khai

### 3.1. Visual

- **Dynamic Type / Font Scaling.** Honour user-selected text size on iOS (UIContentSizeCategory) and Android (`android:textSize="sp"` and `fontScale`). Maximum recommended scale 200% with reflowing layouts.
- **High-contrast mode.** Automatically increases contrast ratios to a minimum of **7:1** for primary text on adjusted backgrounds when "Increase Contrast" (iOS) or "High Contrast Text" (Android) is enabled. Default ratio always meets WCAG AA minimum **4.5:1** for body text and **3:1** for large text.
- **Dark mode and light mode** with manual override and system-respect.
- **Reduce Motion.** Disables parallax, decorative animations, and chart auto-pans when "Reduce Motion" is enabled.
- **Reduce Transparency.** Replaces blurs with solid backgrounds where requested.
- **Color independence.** No information conveyed by colour alone; icons and labels accompany every chart segment and status indicator.
- **Resizable maps.** Workout maps support pinch-zoom up to 500% with persistent location markers.

### 3.2. Screen reader support / Hỗ trợ đọc màn hình

- **VoiceOver (iOS) and TalkBack (Android)** fully supported. Every interactive element has a descriptive label, value, and hint.
- **Workout statistics** announced as semantically structured groups (e.g., "Distance, 5.2 kilometres" rather than "5.2 km").
- **Live regions** for live workout updates (pace, heart rate change).
- **Chart audio descriptions:** weekly distance charts include a textual summary read by screen readers.
- **Custom focus order** to ensure logical navigation in complex screens (start workout, AI Coach chat).

### 3.3. Motor / Vận động

- **Minimum touch target size: 44 x 44 pt (iOS), 48 x 48 dp (Android).**
- **Voice Control / Switch Control** compatible.
- **One-handed operation** mode places primary action buttons within thumb reach.
- **Adjustable gesture timing.** Long-press durations can be extended in Settings → Accessibility → Touch.

### 3.4. Auditory / Thính giác

- **Captions for all spoken AI Coach audio**. AI Coach voice playback (when enabled) is paired with synchronised text.
- **Vibration alerts** as alternatives to audio cues (split notifications, GPS lock).
- **Visual workout cues** mirror every haptic and audio cue.

### 3.5. Cognitive / Nhận thức

- **Plain language** in onboarding, settings, and AI Coach default replies.
- **Predictable navigation.** Tab bar position and labels remain consistent.
- **Reduced complexity mode** simplifies dashboards to essential metrics.
- **Pause / Resume** any guided workout without losing progress.
- **No flashing content** exceeding 3 flashes per second (WCAG 2.3.1).

### 3.6. Speech / AI Coach

- **AI Coach text-only mode** for users who prefer not to use voice.
- **AI Coach voice supports** clear synthetic voices via Apple/Google TTS, with adjustable speed.
- **Speech-to-text input** uses platform dictation; no additional permissions beyond system speech.

## 4. Conformance Status / Tình trạng tuân thủ

**Current status (May 2026):** Partially conformant with WCAG 2.1 AA. Most content meets AA criteria; the following areas are under improvement and tracked in our public roadmap:

- Detailed audio descriptions for animated AI Coach avatar (target Q3 2026).
- Full keyboard navigation for the webview-based billing portal (target Q3 2026).
- Extended language support for VoiceOver labels (currently EN, VI; FR, ES, DE targeted Q4 2026).

## 5. Testing Approach / Cách tiếp cận kiểm thử

- **Automated testing** with Apple Accessibility Inspector and Android Accessibility Scanner in CI pipelines.
- **Manual testing** with screen readers (VoiceOver, TalkBack) on every major release.
- **User research** with members of accessibility communities, including the Vietnam Blind Association and EU accessibility consultants.
- **Annual third-party audit** against WCAG 2.1 AA published at runvie.app/legal/accessibility-audit.

## 6. Feedback Channels / Kênh phản hồi

We welcome reports of accessibility barriers. Please contact:

- Email: **accessibility@runvie.app**
- In-app: Settings → Help → Report an accessibility issue
- Postal: RunVie Company Limited, [Registered office address], Vietnam

We aim to acknowledge reports within **5 business days** and provide a remediation plan within **30 days**.

## 7. Enforcement / Khiếu nại

- **EU users:** You may file a complaint with your national supervisory authority for the EU Accessibility Act (Directive (EU) 2019/882) once it enters into force (28 June 2025).
- **US users:** Complaints related to ADA Title III may be filed with the US Department of Justice.
- **Vietnam users:** Vui lòng tham chiếu Luật Người khuyết tật số 51/2010/QH12 và liên hệ với cơ quan có thẩm quyền nếu thấy quyền của mình bị ảnh hưởng.

## 8. Technologies Used / Công nghệ sử dụng

This statement applies to RunVie iOS, Android applications, and the runvie.app website. Underlying technologies include React Native, SwiftUI components, Jetpack Compose, and HTML5 with ARIA roles and attributes.

## 9. Approval and Review / Phê duyệt và Rà soát

This Accessibility Statement was last reviewed and approved by the RunVie Product Accessibility Committee on **20 May 2026**. It is reviewed at least annually and updated whenever significant accessibility-impacting changes are released.

## 10. Contact / Liên hệ

- Accessibility lead: **accessibility@runvie.app**
- Customer support: **support@runvie.app**
- DPO: **dpo@runvie.app**
