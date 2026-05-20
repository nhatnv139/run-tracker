# RunVie Investor Folder — README

This folder is the complete seed funding package for RunVie. Internal use for founder + counsel + close partners. Share with investors selectively per due diligence stage.

---

## File Index

| # | File | Purpose | Primary audience |
|---|---|---|---|
| 1 | `pitch-deck.md` | 14-slide narrative deck (markdown source for Figma/Keynote) | Investors — first meeting |
| 2 | `executive-summary.md` | 2-page summary sent before any call | Investors — cold outreach |
| 3 | `financial-model.md` | 36-month financial projections + assumptions + sensitivity | Investors — second meeting + diligence |
| 4 | `cap-table.md` | Pre-seed through Series A cap table scenarios + term sheet structure | Investors + counsel — diligence + close |
| 5 | `data-room-checklist.md` | Due diligence document inventory + access protocol | Founder ops + counsel |
| 6 | `q-and-a.md` | 50 common VC questions with prepared answers | Founder prep (do not share) |
| 7 | `target-investors.md` | 50 fund + angel target list with intro paths | Founder ops (internal) |
| 8 | `email-templates.md` | 5 email templates (cold, follow-up, post-meeting, close) | Founder ops (internal) |
| 9 | `metrics-kpi-dashboard.md` | KPI definitions + monthly investor update template | Founder + investors — operating cadence |
| 10 | `README.md` | This file — index + 12-week fundraise timeline | All |

**Recommended reading order for a new investor:**
1. `executive-summary.md` (5 min)
2. `pitch-deck.md` (10 min) — or live deck walkthrough
3. `financial-model.md` (20 min)
4. `q-and-a.md` is for founder prep, not shared with investors
5. `cap-table.md` shared after term sheet conversations begin
6. Full data room (per `data-room-checklist.md`) gated by NDA + verbal commitment to diligence

---

## 12-Week Fundraise Timeline

Calendar starts the week the deck is finalized and the founder is ready to take meetings. Target close: end of Week 12.

### Week 1 — Preparation lockdown

- Final deck rev — Figma export to PDF + Keynote + web version at runvie.app/deck
- Financial model peer-reviewed by ex-CFO advisor
- Data room indexed in DocSend (private link)
- Reference list confirmed: 3 advisors + 2 beta testers + 1 brand LOI partner committed to take reference calls
- Personal calendar blocked: 4 hours/day for first 4 weeks, 6 hours/day for closing weeks

### Week 2 — Wave 1 outreach (5 high-conviction VN warm intros)

- Touchstone, Genesia, Do Ventures, 500 Global SEA, Sequoia/Surge
- Goal: 5 first meetings scheduled within 14 days
- Daily metric: 2-3 first meetings booked per week

### Week 3 — First meetings start

- 5 first calls (15-30 min each)
- Immediate post-call follow-up emails with attachments (24-hour rule)
- Second meeting yes/no decisions logged in tracker
- Personal energy check: founder is the bottleneck — sleep + exercise discipline

### Week 4 — Wave 2 outreach (7 SEA + 5 angels)

- East Ventures, Insignia, Wavemaker, Monk's Hill, Openspace, Golden Gate, ThinkZone
- Angel syndicate kickoff: Topica founders, Tiki founders, MoMo founders, Coolmate founder
- Wave 1 second meetings happening in parallel
- Update KPI dashboard: any new data point shared with engaged investors

### Week 5 — Diligence begins for engaged Wave 1 funds

- 2-3 funds in "deep diligence" mode (calls with team, reference calls, customer calls)
- Founder hosts data room walkthroughs (45-min sessions)
- Second-wave first meetings (7 new funds)
- Identify lead investor candidate (the one moving fastest + biggest check)

### Week 6 — Term sheet conversations begin (target)

- Goal: 1-2 verbal term sheet conversations
- Counsel engaged formally — Singapore counsel for SAFE/Series Seed papers
- Compare term sheets against benchmarks (cap, discount, board, protective provisions)
- Wave 3 outreach: Lightspeed + global stretches + remaining angels

### Week 7 — Negotiate lead investor terms

- 1 lead term sheet in hand (target USD 750k-1M from lead)
- Negotiate cap, board seat, information rights, pro-rata
- Use Wave 2 + Wave 3 momentum as leverage for terms
- Reference calls done by lead investor with portfolio CEOs + advisors

### Week 8 — Sign lead term sheet, start syndicate

- Lead term sheet signed (non-binding)
- Announce to Wave 2/3 funds: "we have a lead at USD X cap, USD 750k filled, looking for USD 750k more"
- Co-investors typically commit within 2 weeks of lead being announced
- Begin legal documentation in parallel (counsel both sides)

### Week 9 — Co-investor commitments

- USD 500k-1M syndicate commitments (2-4 co-investors at USD 100k-400k each)
- Angels closed: USD 100k-200k aggregate
- Lawyer drafts: SAFE template OR Series Seed purchase agreement, voting agreement, ROFR/co-sale
- Cap table updated for closing day

### Week 10 — Documentation + closing prep

- All investor docs counter-signed
- Wire instructions sent to all participants
- Closing date set (last business day of Week 11)
- Press release drafted (TechInAsia, e27, VnExpress)

### Week 11 — Closing

- Funds wired
- Cap table finalized in Carta
- Welcome email to investors (Template 5)
- Onboarding to Slack #investors channel
- First investor update scheduled for Week 14 (next month)

### Week 12 — Post-close kickoff

- Press release published (if strategic)
- LinkedIn announcement (founder + lead investor partner co-post)
- Team kickoff: hiring intensifies (Senior Designer, then Backend Eng)
- Update product roadmap to reflect new capital + headcount
- 30/60/90-day post-close plan published to investors

---

## Fundraise tracking spreadsheet (recommended schema)

Maintain in Airtable or Notion. Update daily during active fundraise.

| Field | Type | Notes |
|---|---|---|
| Investor name | Text | Fund or angel name |
| Partner name | Text | Specific partner contact |
| Tier (1/2/3) | Single-select | From `target-investors.md` |
| Status | Single-select | New / Contacted / 1st meeting / Diligence / Term sheet / Committed / Passed |
| First contact date | Date | |
| Last contact date | Date | |
| Next action | Text | Specific next step |
| Next action date | Date | |
| Intro path | Text | Warm / LinkedIn / Cold / Event |
| Check size discussed | Currency | USD |
| Notes | Long text | Running log of each interaction |

---

## Risks acknowledged in this round

1. **Founder concentration:** solo founder. Mitigation: 4 named advisors with signed agreements, plan to hire de facto co-founder role (Growth Lead) at M5.
2. **Pre-launch reliance on beta metrics:** 50 beta testers is a small sample. Mitigation: ramp closed beta to 500 by M3, share full cohort data with engaged investors.
3. **Vietnam-only TAM perception:** USD 30M ceiling is small for global venture. Mitigation: SEA expansion plan documented in `pitch-deck.md` slide 9 and `financial-model.md`.
4. **AI vendor dependency:** Claude is single source. Mitigation: multi-model abstraction layer in code from day one, switching cost is 2-week sprint.
5. **Battery + privacy first-impression:** these are the user complaints that kill GPS apps. Mitigation: benchmarks published, privacy architecture documented in data room.

---

## Final note from founder

The seed round is not the goal. The seed round is the entry ticket to a 6-7 year journey building a category-defining Vietnamese consumer health product. The investors I want are the ones who will pick up the phone at midnight in Year 3 when something is breaking. The financial terms are negotiable; the partnership is not. This is a 7-year decision masquerading as an 8-week transaction.

— [Founder Name]
Q3 2026, HCMC
