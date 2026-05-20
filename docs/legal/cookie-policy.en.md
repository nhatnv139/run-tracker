# COOKIE POLICY – RUNVIE

**Version:** 1.0
**Issued on:** 20 May 2026
**Effective date:** 20 May 2026

---

## 1. Introduction

This Cookie Policy explains how RunVie Company Limited ("RunVie", "we", "us", "our") uses cookies and similar technologies on the **runvie.app** website, its sub-domains (marketing, help, blog, billing portal), and webview surfaces embedded inside the RunVie mobile application. This Policy is an integral part of our Privacy Policy.

By accessing runvie.app, you acknowledge the use of cookies described herein, to the extent permitted by applicable law.

## 2. What Are Cookies and Similar Technologies?

A **cookie** is a small text file stored by a website on your browser or device to remember information about your session.

**Similar technologies** we use:

- **localStorage / sessionStorage:** Storing display preferences, language, and theme.
- **IndexedDB:** Caching workout data offline in our PWA.
- **Pixels / web beacons:** 1x1 transparent images used to track email engagement events.
- **In-app device identifiers:** IDFV on iOS, Android ID. We do **not** use IDFA and therefore do not require the iOS App Tracking Transparency prompt — we do not perform cross-app tracking.
- **Edge tokens (Cloudflare).**

## 3. Categories of Cookies We Use

### 3.1. Strictly Necessary Cookies

Cannot be disabled; required for the website to function.

| Name | Purpose | Provider | Duration |
|---|---|---|---|
| `sb-access-token` | Supabase authentication token | Supabase | 1 hour |
| `sb-refresh-token` | Session refresh token | Supabase | 7 days |
| `cf_clearance` | Cloudflare DDoS / WAF verification | Cloudflare | 30 minutes |
| `__Host-csrf` | CSRF protection | RunVie | Session |
| `lang` | Persisted UI language | RunVie | 12 months |
| `cookie_consent` | Stores your cookie choices | RunVie | 12 months |

### 3.2. Analytics Cookies

Activated only when you consent.

| Name | Purpose | Provider | Duration |
|---|---|---|---|
| `ph_*` (PostHog) | Product interaction and funnel measurement | PostHog (EU – Frankfurt) | 12 months |
| `ph_distinct_id` | Anonymous user identifier | PostHog | 12 months |
| `sentry-trace` | Performance trace for error tracking | Sentry (EU – Frankfurt) | Session |

We have configured PostHog with **IP anonymisation**, no full IP retention, and automatic masking of password fields and sensitive inputs.

### 3.3. Functional Cookies

| Name | Purpose | Provider | Duration |
|---|---|---|---|
| `theme` | Light / dark mode preference | RunVie | 12 months |
| `units` | km / mi unit preference | RunVie | 12 months |
| `tz` | Display timezone | RunVie | 12 months |

### 3.4. Marketing Cookies

We **do not currently use** third-party advertising cookies (Google Ads, Meta Pixel, TikTok Pixel). If introduced in the future, we will update this Policy and obtain renewed consent.

### 3.5. Payment Authentication Cookies

| Name | Purpose | Provider | Duration |
|---|---|---|---|
| `momo_*` | MoMo payment session | MoMo | Session |
| `zlp_*` | ZaloPay payment session | ZaloPay | Session |
| `iap_receipt_cache` | Apple / Google IAP receipt cache | RunVie | 24 hours |

## 4. In-App Technologies

Inside the RunVie mobile app we use technologies functionally equivalent to cookies:

- **Secure Keychain (iOS) / EncryptedSharedPreferences (Android):** Securely store authentication tokens.
- **PostHog SDK:** Tracks in-app events with an opt-out toggle at Settings → Privacy → Analytics.
- **Sentry SDK:** Records crashes and errors with an opt-out toggle at Settings → Privacy → Crash Reports.
- **Cloudflare Workers KV:** Remote configuration cache.

## 5. Legal Basis

5.1. For strictly necessary cookies, we rely on **legitimate interests** (Art. 6(1)(f) GDPR) and the operational requirements of the service.

5.2. For analytics, functional (non-essential), and marketing cookies, we obtain your **informed consent** under:
- Art. 7 GDPR;
- ePrivacy Directive 2002/58/EC (Art. 5(3));
- Art. 11 of Vietnam's Decree 13/2023/ND-CP;
- CalOPPA and CCPA for California residents.

5.3. You may withdraw consent at any time (see Section 6).

## 6. Managing Cookies

### 6.1. Consent banner

On first visit to runvie.app, a cookie banner is shown with options:
- **Accept all**
- **Strictly necessary only**
- **Customise** (per category)

Your choice is stored in the `cookie_consent` cookie and can be changed at any time at **runvie.app/preferences/cookies**.

### 6.2. Browser settings

You may disable cookies via your browser settings. However, disabling strictly necessary cookies may break the website.

Quick guides:
- **Chrome:** Settings → Privacy and Security → Cookies and other site data.
- **Safari:** Preferences → Privacy → Manage Website Data.
- **Firefox:** Settings → Privacy & Security → Cookies and Site Data.
- **Edge:** Settings → Cookies and site permissions → Cookies.

### 6.3. In-app settings

Open **Settings → Privacy** to disable each tracking category (Analytics, Crash Reports).

### 6.4. Global privacy signals

We honour the Global Privacy Control (GPC) signal as a valid opt-out request for sale or sharing of personal information under the CCPA/CPRA.

## 7. Third-Party Cookies and International Transfers

Some cookies are set by third parties (PostHog, Sentry, Cloudflare). Data may be processed in the EU or the United States. We apply Standard Contractual Clauses (SCCs) for transfers outside the EU/EEA and have notified cross-border transfers under Art. 25 of Decree 13/2023/ND-CP of Vietnam.

## 8. Retention

Session cookies are deleted when you close your browser. Persistent cookies have the durations listed in Section 3. You may manually delete cookies at any time.

## 9. Children

The runvie.app website is not directed to children under 13. We do not knowingly use cookies to identify or track children.

## 10. Updates to this Policy

We may update this Cookie Policy from time to time. New versions will be published at runvie.app/legal/cookies with the updated issuance date. For material changes (e.g., introducing marketing cookies), we will re-display the consent banner.

## 11. Additional Disclosures for Specific Jurisdictions

### 11.1. EU and UK Users

Under the ePrivacy Directive (as transposed in each Member State) and the UK Privacy and Electronic Communications Regulations (PECR), we obtain affirmative opt-in consent before placing any non-essential cookie. Consent is recorded with a timestamp, the version of the banner shown, and the categories accepted. You may inspect or revoke your consent record at any time at runvie.app/preferences/cookies. The right to withdraw consent is as easy as giving it.

### 11.2. California Residents

Under the CCPA/CPRA, you may opt out of the "sale" or "sharing" of personal information through cookies. We do not currently sell personal information for monetary consideration; however, the broad CCPA definition of "sharing" for cross-context behavioural advertising may apply if we later introduce advertising cookies. You may submit an opt-out via the "Do Not Sell or Share My Personal Information" link in our website footer or by transmitting the Global Privacy Control (GPC) signal, which we honour.

### 11.3. Vietnamese Users

Under Decree 13/2023/ND-CP, you have the right to be informed about and to consent to the processing of your personal data via cookies and similar technologies. You may withdraw consent at any time via our preference centre, and we will cease the corresponding processing within 72 hours.

### 11.4. Brazil (LGPD)

For users in Brazil, processing performed via cookies follows the Lei Geral de Proteção de Dados (LGPD). Legal bases mirror those listed in Section 5 of this Policy.

## 12. Do Not Track and Global Privacy Control

We honour browser-level signals where they communicate a clear opt-out preference, in particular the Global Privacy Control (GPC) header. We currently do not respond to legacy "Do Not Track" (DNT) header signals because no industry consensus exists on its interpretation; this position is reviewed annually.

## 13. Contact

- DPO email: **dpo@runvie.app**
- General privacy email: **privacy@runvie.app**
- Preference centre: **runvie.app/preferences/cookies**

---

*This document is published in English. The Vietnamese version prevails for users located in Vietnam in case of any discrepancy.*
