# PRIVACY POLICY – RUNVIE APP

**Version:** 1.0
**Issued on:** 20 May 2026
**Effective date:** 20 May 2026
**Data Controller:** RunVie Company Limited ("RunVie", "we", "us", "our")
**Address:** [Registered office address, Vietnam]
**Business Registration Number:** [Business Registration Number]

---

## 1. Introduction

RunVie is a personal health and fitness application offering running tracking, walking, step counting, calorie tracking, heart rate monitoring, sleep insights, an AI Coach, and related social features. We understand that health and location data are sensitive categories of personal data, and we are committed to protecting the privacy of our users in accordance with applicable laws.

This Privacy Policy ("Policy") applies to all users who access, register for, or use the RunVie application on iOS, Android, and the runvie.app website. By installing and using the application, you acknowledge that you have read, understood, and agreed to the terms of this Policy.

## 2. Definitions

- **Personal Data:** Any information relating to an identified or identifiable natural person (the "data subject"), as defined under Art. 4(1) GDPR and Decree 13/2023/ND-CP of Vietnam.
- **Special Category Data / Sensitive Personal Data:** Including data concerning health, location, biometric and physical characteristics, as defined under Art. 9 GDPR and Clause 4 Art. 2 of Decree 13/2023/ND-CP.
- **Data Subject:** The natural person whom the Personal Data refers to.
- **Processing:** Any operation performed on personal data, including collection, recording, organisation, structuring, storage, adaptation, retrieval, consultation, use, disclosure, dissemination, alignment, restriction, erasure or destruction.
- **Data Controller:** RunVie is the data controller of users' personal data.
- **DPO (Data Protection Officer):** The privacy officer designated by RunVie under Art. 37 GDPR and Art. 28 of Decree 13/2023/ND-CP.

## 3. Scope and Applicable Law

3.1. This Policy applies to all users who register, sign in, or use the RunVie application, regardless of nationality or country of residence.

3.2. Users located in Vietnam are protected under Decree 13/2023/ND-CP on Personal Data Protection, Law on Cyber Information Security 86/2015/QH13, Law on Protection of Consumer Rights 19/2023/QH15, Law on Electronic Transactions 20/2023/QH15.

3.3. Users in the European Union / European Economic Area are additionally protected under Regulation (EU) 2016/679 (the General Data Protection Regulation – GDPR).

3.4. Users in California, USA are protected under the California Consumer Privacy Act / California Privacy Rights Act (CCPA/CPRA).

3.5. Users in the United Kingdom are protected under the UK GDPR and the Data Protection Act 2018.

## 4. Data We Collect

### 4.1. Mandatory Data (required to deliver core services)

- Email address and password (hashed) or Apple ID / Google ID identifier for federated sign-in.
- Display name.
- Age (or date of birth), biological sex, height, weight – required to calculate calories, target heart rate zones, and estimated VO2max.

### 4.2. Optional Data (collected only with your permission)

- **GPS location data:** Latitude/longitude coordinates, altitude, speed, route polyline when you record a workout.
- **Health data from HealthKit (iOS) / Health Connect (Android):** Heart rate, steps, calories burned, sleep data, VO2max, cadence, distance, workout history.
- **Profile photos and workout share photos.**
- **Contacts:** Accessed only when you actively search for friends via contacts.
- **Third-party integrations:** Strava (workout sync), Spotify / Apple Music (music playback while running).
- **Live Location:** When you enable real-time location sharing with family members.

### 4.3. Automatically Collected Data

- Device type, operating system, app version, device identifier (IDFV on iOS, Android ID).
- IP address and country-level geolocation (not precise location).
- Access timestamps, used features, in-app events (analytics events).
- Push notification token (APNs / FCM).
- Crash logs and stack traces via Sentry.
- In-app purchase receipts (Apple receipt / Google purchase token).

### 4.4. AI Coach Conversation Data

When you use the AI Coach, your message content is sent to the Claude model (Anthropic) for processing and response. **We do not use AI Coach conversations to train AI models**, as per our Data Processing Agreement with Anthropic.

## 5. Purposes of Processing

5.1. **Delivering core services:** Recording workouts, calculating distance, calories, heart rate, average pace, elevation, and route mapping.

5.2. **Personalising the experience:** Recommending training plans, weekly goals, and recovery suggestions based on sleep and heart rate data.

5.3. **Operating social features:** Displaying leaderboards, friend connections (follow), kudos, comments, and workout sharing.

5.4. **Providing AI Coach:** Analysing your recent training data to produce personalised advice via Anthropic's Claude model.

5.5. **Processing payments and subscriptions:** Managing IAP orders via Apple/Google and web payments via MoMo, ZaloPay.

5.6. **Customer support and communications:** Sending transactional notifications, app updates, and responding to support requests.

5.7. **Security and fraud prevention:** Detecting GPS spoofing, bots, and service abuse.

5.8. **Product analytics:** Measuring product performance, retention, and UX optimisation via PostHog with pseudonymised data.

5.9. **Legal compliance:** Responding to lawful requests from competent authorities.

5.10. **Marketing:** Only sending marketing emails and push notifications where you have given explicit opt-in consent; you may withdraw consent at any time.

## 6. Legal Basis for Processing

Pursuant to Art. 6 GDPR and Arts. 11–17 of Decree 13/2023/ND-CP, RunVie processes personal data on the following legal grounds:

- **Consent of the data subject (Art. 6(1)(a) GDPR; Art. 9 GDPR for sensitive data):** For location data, sensitive health data, and marketing.
- **Performance of a contract (Art. 6(1)(b) GDPR):** Providing the app services under our Terms of Service.
- **Legitimate interest (Art. 6(1)(f) GDPR):** System security, fraud prevention, and product improvement.
- **Legal obligation (Art. 6(1)(c) GDPR):** Storing electronic invoices, responding to tax authority requests.
- **Vital interests (Art. 6(1)(d) GDPR):** Emergency location sharing with family.

For sensitive health data, we rely on **explicit consent** under Art. 9(2)(a) GDPR.

## 7. Sharing Data with Third Parties

We do **not sell** your personal data. We share data only in the following circumstances:

| Partner | Purpose | Processing Location | Safeguards |
|---|---|---|---|
| Supabase (PostgreSQL, Auth, Storage) | Primary data storage | Google Cloud Singapore | SOC 2 Type II, DPA signed |
| Anthropic (Claude API) | AI Coach conversation processing | USA | DPA, no training on customer data |
| Apple (HealthKit, IAP, Sign in with Apple, APNs) | Health sync, payments, login, notifications | USA / EU | Apple Privacy compliant |
| Google (Health Connect, Play Billing, FCM) | Health sync, payments, notifications | USA / EU | Google Play Policy compliant |
| Strava | Two-way workout sync (when connected) | USA | OAuth 2.0, limited scope |
| Spotify / Apple Music | In-workout music playback | USA / EU | OAuth, playback access only |
| Sentry | Error and crash tracking | Germany (EU) | GDPR-compliant, PII scrubbing |
| PostHog | Product analytics | EU (Frankfurt) | Anonymised IP, opt-out available |
| Cloudflare | CDN, WAF, DDoS protection | Global edge | DPA, edge encryption |
| MoMo / ZaloPay | Web payment gateway | Vietnam | Circular 09/2020 of the State Bank of Vietnam |

In response to lawful requests from competent authorities (police, courts, prosecutors) we will provide data only after verifying the legal basis of the request.

## 8. Data Storage and Security

8.1. **Encryption in transit:** All data exchanged between your device and our servers is encrypted via TLS 1.3.

8.2. **Encryption at rest:** Sensitive data (passwords, tokens, health data) is encrypted at the database layer using AES-256. Passwords are hashed using Argon2id.

8.3. **Infrastructure:** Primary servers are hosted on Google Cloud Platform region asia-southeast1 (Singapore). Encrypted backups are stored on a rolling schedule.

8.4. **Access control:** We apply the principle of least privilege, enforce mandatory two-factor authentication (2FA) for staff, and maintain audit logs of all data access.

8.5. **Periodic assessments:** Annual penetration testing and Data Protection Impact Assessments (DPIA) where required under Art. 35 GDPR and Art. 25 of Decree 13/2023.

## 9. Data Retention

| Data category | Retention period |
|---|---|
| Account information | Lifetime of the active account + 90 days after deletion request |
| Workout, GPS, health data | Lifetime of the active account; deletable at any time |
| AI Coach conversation logs | 90 days, then deleted or anonymised |
| Error logs (Sentry) | 30 days |
| Invoices and payment receipts | 10 years per Accounting Law 88/2015 of Vietnam |
| Access logs | 12 months per Law on Cyber Information Security |

After expiration, data will be securely deleted or irreversibly anonymised.

## 10. Data Subject Rights

Under Art. 9 of Decree 13/2023/ND-CP and Chapter III of the GDPR, you have the following rights:

10.1. **Right to be informed** about the processing of your personal data.

10.2. **Right to consent or withhold consent;** the right to withdraw consent at any time.

10.3. **Right of access (Art. 15 GDPR):** View and obtain a copy of your data. You may download a full export via "Profile → Export Data" in the app.

10.4. **Right to rectification (Art. 16 GDPR)** of inaccurate data.

10.5. **Right to erasure (Art. 17 GDPR – "Right to be forgotten"):** Request deletion of your account and all related data via "Settings → Delete Account"; we will complete deletion within 30 days.

10.6. **Right to restriction of processing (Art. 18 GDPR).**

10.7. **Right to data portability (Art. 20 GDPR):** Export data in structured, machine-readable JSON / GPX / FIT formats.

10.8. **Right to object (Art. 21 GDPR),** including objection to direct marketing.

10.9. **Right to lodge a complaint** with your local supervisory authority. EU users may contact their national Data Protection Authority. Vietnamese users may contact the Authority of Information Security (Ministry of Information and Communications).

### 10.10. California Residents – Additional Rights

Under the CCPA/CPRA, California residents have the right to:

- Know what categories of personal information are collected, sold, or disclosed;
- Request deletion of personal information;
- Opt out of the sale or sharing of personal information (we do not sell);
- Non-discrimination for exercising privacy rights;
- Limit the use of sensitive personal information.

Send requests to **privacy@runvie.app** with the subject "CCPA Request".

**Submission:** Send requests via **privacy@runvie.app** or directly in the app. We acknowledge within 72 hours and complete fulfilment within 30 days (or one month under GDPR Art. 12(3)).

## 11. Cookies and Similar Technologies

The runvie.app website and in-app webviews use cookies and similar technologies for analytics, session authentication, and security. See our **Cookie Policy** at runvie.app/legal/cookies for details.

## 12. Children's Privacy

12.1. RunVie is not intended for users under 13 years of age. We apply a minimum age of 13 in line with Apple App Store and Google Play requirements, the US Children's Online Privacy Protection Act (COPPA), and Art. 8 GDPR (which allows EU member states to set the age of digital consent between 13 and 16; users below the local threshold require parental consent).

12.2. If we discover that a user is under 13, we will suspend the account and erase the related data within 14 days.

12.3. For users aged 13–18, we recommend use under the supervision of a parent or legal guardian. The Family Sharing feature provides parental oversight controls.

## 13. International Data Transfers

13.1. Some of our processors are located in the United States, the European Union, or other countries outside Vietnam. Cross-border transfers are conducted under:

- Art. 25 of Decree 13/2023/ND-CP – the cross-border transfer dossier has been prepared and notified to the Authority of Information Security.
- European Commission Standard Contractual Clauses (SCCs) for transfers outside the EU/EEA.
- For transfers from the UK, the International Data Transfer Addendum issued by the ICO.
- Your explicit consent given at registration.

13.2. You may request a copy of the safeguards applied to these transfers by emailing the DPO.

## 14. Data Breach Notification

In the event of a personal data breach, we will:

14.1. Notify the competent supervisory authority (Authority of Information Security – Ministry of Information and Communications of Vietnam; for EU users, the lead supervisory authority) within **72 hours** under Art. 23 of Decree 13/2023/ND-CP and Art. 33 GDPR.

14.2. Notify affected data subjects directly via email and in-app notice where the breach is likely to result in a high risk to the rights and freedoms of natural persons (Art. 34 GDPR).

14.3. Publish an incident report at status.runvie.app once remediation is complete.

## 15. Contact the Data Protection Officer (DPO)

- DPO email: **dpo@runvie.app**
- General privacy email: **privacy@runvie.app**
- EU Representative (per Art. 27 GDPR): to be appointed and disclosed prior to formal EU launch.
- UK Representative (per UK GDPR Art. 27): to be appointed if applicable.
- Postal address: RunVie Company Limited, [Registered office address].

## 16. Changes to this Policy

16.1. We may update this Policy from time to time. New versions will be published at runvie.app/legal/privacy and announced in the app at least **30 days** before becoming effective in case of material changes.

16.2. For changes involving new purposes or new processors, we will seek your renewed consent where required.

16.3. Continued use of the app after the new Policy takes effect constitutes acceptance of the updated terms.

## 17. Effective Date

This Policy is effective from **20 May 2026**. Previous versions are archived at runvie.app/legal/archive for transparency.

---

*This document is published in English. The Vietnamese version prevails for users located in Vietnam in case of any discrepancy.*
