# RunVie — App Store Submission Package

> Repository: `D:/dev/run-tracker/docs/app-store/`
> Owner: ASO Lead (DRI) | Last updated: 2026-05-20
> App version: 1.0 (launch) | Target stores: Apple App Store + Google Play | Initial market: Vietnam

---

## Purpose

This package contains everything required to submit RunVie to the Apple App Store and Google Play Store for the Vietnam market, with phase-2 expansion-ready structures for Southeast Asia and global English locales.

---

## Index

| # | File | Purpose | Audience |
|---|------|---------|----------|
| 1 | [metadata-vi.md](./metadata-vi.md) | Vietnamese store listing — title, subtitle, descriptions, what's new, URLs, age rating | App Store Connect submitter, Play Console submitter |
| 2 | [metadata-en.md](./metadata-en.md) | English store listing (en-US default, used for SG/MY/PH/global) | Same |
| 3 | [keywords-research.md](./keywords-research.md) | 50 VN + 50 EN keyword research with volume/difficulty/relevance/priority; top-30 selected for Apple field | ASO Lead, Apple Search Ads manager |
| 4 | [screenshots-brief.md](./screenshots-brief.md) | Designer brief for 8 screenshots × 5 device matrix (iPhone 6.7" / 6.1" / iPad / Android phone / tablet) | Brand / Marketing Design Lead |
| 5 | [preview-video-script.md](./preview-video-script.md) | 30s App Preview video script + storyboard + music brief + cut-downs (15s, 6s) + localization | Motion Design Lead, Music Producer |
| 6 | [editorial-pitch.md](./editorial-pitch.md) | Apple Vietnam editorial pitch (App of the Day, Made in Vietnam, App Store Awards 2026) | CEO, Head of Marketing |
| 7 | [aso-launch-checklist.md](./aso-launch-checklist.md) | 6-week pre-launch checklist (W-6 → D+7) + risk register + KPIs | All leads (joint DRI) |
| 8 | [review-guidelines-compliance.md](./review-guidelines-compliance.md) | Apple App Store Review Guidelines audit (1.2 UGC, 2.5.18 HealthKit, 3.1.1 IAP, 5.1.x privacy, etc.) | Engineering Lead, Legal |

---

## Submission timeline

```
Today (W-6)
    │
    ├── TestFlight beta, 1.000 testers, crash-free target 99.7%
    ▼
W-5 ─── Localization (vi-VN locked, en-US locked, 13 other locales translation kickoff)
    │
W-4 ─── Editorial pitch sent to Apple Vietnam + press kit to VN tier-1 media
    │
W-3 ─── App Store pre-order live, metadata locked, screenshots + preview video uploaded
    │
W-2 ─── PPO A/B test live, final build #150 submitted to App Store + Play Console for review
    │
W-1 ─── Apple Search Ads enabled, paid social warm-up at 20%
    │
D-0 ─── LAUNCH — push email, press embargo lifts 09:00 ICT, influencer activations, livestream
    │
D+1..D+7 ── Monitor crash <0.5%, ship 1.0.1 hotfix if needed, scale ASA if CAC <VND 35k
    │
D+30 ─── First retrospective + v1.1 sprint planning
```

---

## Quick reference: critical metadata

| Field | Value (vi-VN) | Value (en-US) |
|-------|---------------|---------------|
| App name (Apple) | RunVie: Chạy bộ AI Việt | RunVie: AI Run Coach |
| App name (Play) | RunVie: Chạy bộ, Đi bộ & AI Coach tiếng Việt | RunVie: AI Running Coach, Walk & Earn Rewards |
| Subtitle (default A) | AI Coach Việt, đổi km lấy quà | Walk, run, earn real rewards |
| Primary keyword field | `đi bộ,đếm bước,đếm calo,gps,marathon,5k,couch to 5k,fitness,hlv,coach,giảm cân,sức khỏe,vo2,jog,pace` | `walk,step,pedometer,gps,marathon,5k,10k,couch to 5k,calorie,vo2,pace,jog,trail,coach,heart` |
| Primary category | Health & Fitness | Health & Fitness |
| Secondary category | Lifestyle | Lifestyle |
| Age rating (Apple) | 4+ | 4+ |
| Age rating (Play) | Teen | Teen |
| Price | Free + IAP | Free + IAP |
| Premium IAP | 89.000đ/mo · 690.000đ/yr | USD 3.99/mo · USD 29.99/yr |
| Copyright | © 2026 RunVie JSC. All rights reserved. | © 2026 RunVie JSC. All rights reserved. |

---

## Top 10 Vietnamese keywords (priority order)

1. đi bộ — volume 72, relevance 10
2. đếm bước — volume 80, relevance 10
3. đếm calo — volume 76, relevance 9
4. gps — covers gps chạy bộ, bản đồ chạy bộ
5. marathon — volume 54, relevance 9
6. couch to 5k — long-tail relevance 10
7. hlv — covers huấn luyện viên + hlv chạy bộ
8. giảm cân — highest volume keyword
9. sức khỏe — category-defining
10. vo2 — premium feature signal

Note: "chạy bộ", "ai coach", "việt" are already in title/subtitle — Apple auto-indexes title text, so we do NOT repeat them in the keyword field (would waste characters per ASO best practice).

---

## Top reject risks (ranked)

| Rank | Risk | Mitigation | Owner | File ref |
|------|------|-----------|-------|----------|
| 1 | Apple 1.2 — UGC moderation insufficient | Pre-publishing filter + 12h moderation SLA + report/block flows | Product + Ops | `review-guidelines-compliance.md` §1.2 |
| 2 | Apple 5.1.3 — Medical advice claims in AI Coach | Coach trained to refuse diagnosis, suggest doctor; medical disclaimer in onboarding + description | AI/ML + Medical | `review-guidelines-compliance.md` §5.1.3 |
| 3 | Apple 3.1.1 — RunCoin → voucher classified as IAP-circumvention | Position RunCoin as loyalty reward, not purchase. NO promotion of external payment in app. | Legal | `review-guidelines-compliance.md` §3.1.1 |
| 4 | Apple 5.2.2 — Third-party logos (Shopee/Grab/MoMo) in screenshots | Written authorization from each partner BEFORE submission | BD + Legal | `review-guidelines-compliance.md` §5.2.2 |
| 5 | Apple 2.5.18 — HealthKit usage descriptions too generic | Specific localized descriptions in Info.plist verified | Engineering | `review-guidelines-compliance.md` §2.5.18 |
| 6 | Apple 2.1 — Crash rate above threshold | Build #150 hotfix sprint; target 99.7% crash-free | Engineering | `aso-launch-checklist.md` W-2 |
| 7 | Apple 4.5.4 — Marketing push without opt-in | Push permission timing post-first-run + opt-in default off for marketing | Product | `review-guidelines-compliance.md` §4.5.4 |
| 8 | Apple 2.3.1 — Keyword stuffing | Avoided in description; keyword field stays under 100 chars without irrelevant terms | ASO | `keywords-research.md` |
| 9 | Apple 1.4.1 — Health claims in marketing | No "lose 5kg" claims, factual feature claims only | ASO + Legal | `metadata-vi.md` §5 |
| 10 | Apple 5.1.1 — App Privacy details mismatch actual data flow | Privacy details review session W-3 with Engineering + Legal | Engineering + Legal | `review-guidelines-compliance.md` §5.1.1 |

---

## Version history

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-05-20 | Initial package: 8 deliverables, VN + EN metadata, 50+50 keyword research, screenshot brief, preview video script, editorial pitch, launch checklist, compliance audit | ASO Lead |
| 1.0.1 | _pending_ | Post-launch retrospective adjustments | TBD |
| 1.1 | _pending_ | Phase 2 SEA localization update (th-TH, id-ID, ms-MY, tl-PH) | TBD |

---

## File ownership & maintenance

| File | Primary owner | Update cadence | Lock window |
|------|---------------|----------------|-------------|
| metadata-vi.md | ASO Lead | Monthly (Promotional Text); per-release (What's New) | Locked W-3 to launch |
| metadata-en.md | ASO Lead | Same | Same |
| keywords-research.md | ASO Lead | Quarterly | Reviewed monthly post-launch |
| screenshots-brief.md | Brand Lead | Per major release (v1.1, v1.2, ...) | Final at W-3 |
| preview-video-script.md | Motion Lead | Per major release | Final at W-3 |
| editorial-pitch.md | CEO + Head of Marketing | Per launch / per major release | One-shot per pitch |
| aso-launch-checklist.md | ASO Lead (DRI) | Daily W-2 onwards; weekly post-launch through D+30 | Living doc |
| review-guidelines-compliance.md | Engineering Lead + Legal | Per submission + when Apple updates guidelines | Re-signed at submission |

---

## Related documents (cross-repository)

- `D:/dev/run-tracker/docs/DECISIONS.md` — architecture and product decisions
- `D:/dev/run-tracker/docs/legal/` — privacy policy, terms of service, community guidelines
- `runvie.app/press` — public press kit (published W-3)
- `figma.com/runvie-aurora` — design system Figma (gated)
- `notion.so/runvie-aso-dashboard` — live KPI dashboard (gated)

---

## Contact & escalation

| Need | Contact |
|------|---------|
| ASO questions | aso@runvie.app |
| Apple Editorial follow-up | ceo@runvie.app |
| Press inquiries | press@runvie.app |
| Legal / compliance | legal@runvie.app |
| Engineering escalation | engineering-lead@runvie.app |
| 24/7 launch war room | Slack #launch-war-room |
