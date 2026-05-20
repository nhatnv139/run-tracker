# RunVie Legal Documents – Index

**Version:** 1.0
**Issue date / Ngày ban hành:** 20 May 2026
**Operator / Đơn vị vận hành:** RunVie Company Limited (Công ty TNHH RunVie), Vietnam.

This directory contains the full legal documentation suite for the RunVie fitness application (iOS, Android, web). All documents are versioned together as **v1.0** and have a common effective date of **20 May 2026**.

---

## 1. Document Index / Mục lục tài liệu

| # | File | Description | Lang | Hosted at |
|---|---|---|---|---|
| 1 | [`privacy-policy.vi.md`](./privacy-policy.vi.md) | Chính sách bảo mật theo Nghị định 13/2023/NĐ-CP và GDPR | VI | `runvie.app/legal/privacy?lang=vi` |
| 2 | [`privacy-policy.en.md`](./privacy-policy.en.md) | Privacy Policy (GDPR + CCPA/CPRA + Decree 13/2023) | EN | `runvie.app/legal/privacy` |
| 3 | [`terms-of-service.vi.md`](./terms-of-service.vi.md) | Điều khoản dịch vụ | VI | `runvie.app/legal/terms?lang=vi` |
| 4 | [`terms-of-service.en.md`](./terms-of-service.en.md) | Terms of Service | EN | `runvie.app/legal/terms` |
| 5 | [`cookie-policy.vi.md`](./cookie-policy.vi.md) | Chính sách Cookie | VI | `runvie.app/legal/cookies?lang=vi` |
| 6 | [`cookie-policy.en.md`](./cookie-policy.en.md) | Cookie Policy | EN | `runvie.app/legal/cookies` |
| 7 | [`data-processing-agreement.md`](./data-processing-agreement.md) | DPA (Art. 28 GDPR) cho khách hàng B2B Corporate Wellness | EN | `runvie.app/legal/dpa` |
| 8 | [`health-disclaimer.vi.md`](./health-disclaimer.vi.md) | Tuyên bố miễn trừ trách nhiệm y tế | VI | `runvie.app/legal/health-disclaimer?lang=vi` |
| 9 | [`health-disclaimer.en.md`](./health-disclaimer.en.md) | Health and Medical Disclaimer | EN | `runvie.app/legal/health-disclaimer` |
| 10 | [`children-policy.md`](./children-policy.md) | Children's Privacy Policy (13+, COPPA, Art. 8 GDPR, Decree 13/2023 Art. 20) | EN + VI | `runvie.app/legal/children` |
| 11 | [`accessibility-statement.md`](./accessibility-statement.md) | Accessibility Statement (WCAG 2.1 AA) | EN + VI | `runvie.app/legal/accessibility` |
| 12 | [`README.md`](./README.md) | Mục lục này | EN + VI | `runvie.app/legal` |

## 2. Versioning / Phiên bản

- **Current version:** v1.0
- **Effective date:** 2026-05-20
- **Prior versions:** None (initial publication).
- **Archive location:** `runvie.app/legal/archive/v1.0/`

Each new version increments the minor or major number, retains the same file paths, and updates the date field at the top of each document. Material changes trigger an in-app notice at least **30 days** before the new version becomes effective.

## 3. Compliance Coverage / Phạm vi tuân thủ

### 3.1. Vietnam

- Nghị định số 13/2023/NĐ-CP về bảo vệ dữ liệu cá nhân
- Luật An toàn thông tin mạng số 86/2015/QH13
- Luật An ninh mạng số 24/2018/QH14
- Luật Bảo vệ quyền lợi người tiêu dùng số 19/2023/QH15
- Luật Giao dịch điện tử số 20/2023/QH15
- Luật Sở hữu trí tuệ số 50/2005/QH11 (sửa đổi 2022)
- Bộ luật Dân sự số 91/2015/QH13
- Luật Khám bệnh, chữa bệnh số 15/2023/QH15
- Luật Người khuyết tật số 51/2010/QH12

### 3.2. European Union / United Kingdom

- Regulation (EU) 2016/679 – General Data Protection Regulation (GDPR), Arts. 6, 7, 8, 9, 13, 15–22, 28, 32–34, 35
- Directive 2002/58/EC – ePrivacy Directive
- Regulation (EU) 2021/914 – Standard Contractual Clauses (Module Two)
- Directive 2011/83/EU – Consumer Rights Directive (14-day withdrawal)
- Directive (EU) 2019/882 – European Accessibility Act
- Digital Services Act – Regulation (EU) 2022/2065 (Art. 28 on minor protection)
- UK GDPR and Data Protection Act 2018
- UK ICO International Data Transfer Addendum (v B1.0)

### 3.3. United States

- California Consumer Privacy Act / California Privacy Rights Act (CCPA/CPRA)
- Children's Online Privacy Protection Act (COPPA)
- ADA Title III (Accessibility)
- Section 508 of the Rehabilitation Act (Accessibility)

### 3.4. App store and platform policies

- Apple App Store Review Guidelines, in particular sections **1.3 Kids Category**, **3.1 Payments**, **5.1 Privacy** (5.1.1, 5.1.2, 5.1.3 Health & HealthKit, 5.1.4 Kids, 5.1.5 Location services).
- Apple Human Interface Guidelines for Accessibility
- Google Play Developer Program Policies (User Data, Health Connect, Families, Subscriptions)
- Google Material Design Accessibility
- Anthropic Acceptable Use Policy (for Claude API integration in AI Coach)

### 3.5. Industry standards

- WCAG 2.1 Level AA
- ISO/IEC 27001 (information security management – target certification 2027)
- SOC 2 Type II (target attestation 2027)

## 4. Document Relationships / Quan hệ giữa các tài liệu

```
User-facing (in-app + web):
  privacy-policy.{vi,en}.md   <--+
  terms-of-service.{vi,en}.md     |
  cookie-policy.{vi,en}.md        +-- All reference each other and the DPO contact
  health-disclaimer.{vi,en}.md    |
  children-policy.md              |
  accessibility-statement.md    --+

B2B-facing:
  data-processing-agreement.md (DPA template for Corporate Wellness clients)
```

## 5. Hosting and Display Requirements / Yêu cầu lưu trữ và hiển thị

### 5.1. Apple App Store metadata

- Privacy Policy URL: `https://runvie.app/legal/privacy`
- Terms of Use URL (EULA): `https://runvie.app/legal/terms`
- App Privacy Nutrition Label generated from `privacy-policy.en.md` data categories.

### 5.2. Google Play Console

- Privacy Policy URL: `https://runvie.app/legal/privacy`
- Data Safety form generated from `privacy-policy.en.md`.
- Health Connect: declare permissions used and link to Privacy Policy.

### 5.3. In-app placement

- **First-launch consent screen:** must link to Privacy Policy, Terms, Health Disclaimer, and (for users in EU) Cookie Policy.
- **Settings → Legal:** must list all documents in both EN and VI.
- **Account deletion flow:** must reference Privacy Policy Section 10 (data-subject rights).

### 5.4. Web display

- Each document hosted at the URLs listed in the table above with `lang` query parameter for switching.
- Add `<link rel="alternate" hreflang="..." href="...">` between language variants.
- Serve over HTTPS with HSTS, X-Content-Type-Options: nosniff, Referrer-Policy: strict-origin-when-cross-origin.
- Provide an RSS or Atom feed at `runvie.app/legal/feed.xml` for material change announcements.

## 6. Translation Policy / Chính sách phiên dịch

- Vietnamese and English are the authoritative languages.
- For users in Vietnam, the **Vietnamese version prevails** in case of discrepancy.
- For users in other jurisdictions, the **English version prevails**.
- Additional language translations (FR, ES, DE, JA, ZH) are planned for v1.1 and will be marked as informational only.

## 7. Internal Owners / Người phụ trách nội bộ

| Document | Internal owner | Review cadence |
|---|---|---|
| Privacy Policy | DPO | Quarterly + on incident |
| Terms of Service | Legal Counsel | Semi-annual |
| Cookie Policy | DPO + Web Lead | Quarterly |
| DPA | Legal Counsel + DPO | Annually |
| Health Disclaimer | Medical Advisor + Legal | Annually |
| Children's Policy | DPO + Trust & Safety Lead | Semi-annual |
| Accessibility Statement | Accessibility Lead | Semi-annual + on major release |
| README | Legal Counsel | On every change to other documents |

## 8. Change Log / Lịch sử thay đổi

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-05-20 | Initial publication. Full GDPR + Decree 13/2023 + CCPA + Apple/Google policy compliance. |

## 9. Primary Contacts / Liên hệ chính

- Data Protection Officer (DPO): **dpo@runvie.app**
- Privacy team: **privacy@runvie.app**
- Legal team: **legal@runvie.app**
- Customer support: **support@runvie.app**
- Trust & Safety: **safety@runvie.app**
- Accessibility: **accessibility@runvie.app**
- Postal address: RunVie Company Limited, [Registered office address], Vietnam

---

*This README is part of the RunVie legal documentation suite v1.0. Source of truth is maintained in this repository; the public hosted versions at `runvie.app/legal/...` are generated from these source files.*
