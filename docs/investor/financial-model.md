# RunVie Financial Model — 36 Months

All figures USD unless stated. Starting cash: USD 1,500,000 from seed close at M1.

---

## Key Assumptions

### Acquisition
- **Downloads (Y1):** 500k cumulative. Mix 60% organic (ASO + KOL + PR), 40% paid.
- **Downloads (Y2):** 2.5M cumulative (+2.0M new), VN + SEA. Mix 65% organic / 35% paid.
- **Downloads (Y3):** 6.0M cumulative (+3.5M new), VN + SEA + Global English. 70% organic.
- **CAC blended:** USD 15 Y1 → USD 18 Y2 (paid saturation in VN) → USD 20 Y3 (global paid more expensive, but organic share offsets).
- **Paid acquisition channel mix:** Facebook 40%, TikTok 30%, Zalo 15%, Google UAC 10%, partnerships 5%.

### Activation + Engagement
- **Onboarding completion:** 72% (industry benchmark Strava 60%; ours higher due to walking-first lower barrier).
- **D1 retention:** 55% → 62% by Y2 (onboarding optimization).
- **D30 retention (MAU/install):** 15% Y1 → 25% Y2 → 28% Y3.
- **MAU formula:** rolling 30-day actives. Y1 EOY = 100k. Y2 EOY = 1.0M. Y3 EOY = 2.8M.

### Conversion + Monetization
- **Paid conversion (paying users / MAU):** 5% Y1 (blended cold + warm) → 7% Y2 → 7.1% Y3 (saturation; B2B picks up the slack).
- **Tier distribution (paying users):** Plus 60%, Pro 30%, Annual-Plus 10% (annual users at 20% discount).
- **ARPU per paying user/month:**
  - Plus VN: 99k VND ≈ USD 3.96 (FX 25,000)
  - Plus global: USD 4.99
  - Pro VN: 199k VND ≈ USD 7.96
  - Pro global: USD 9.99
  - Blended: USD 5.10/month in Y1 (mostly VN), USD 5.80/month in Y2 (SEA mix), USD 6.40/month in Y3 (global mix).
- **Annual retention paid:** 65% Y1 → 70% Y2 → 72% Y3.
- **LTV:** ARPU × 24 months × retention curve = USD 45 Y1 → USD 62 Y3.

### COGS
- **Hosting (Supabase + ClickHouse + CDN):** USD 0.001/MAU/day = USD 0.03/MAU/month. At 1M MAU = USD 30k/month.
- **AI inference (Claude):**
  - Free user: USD 0.02/month (10 messages cap, mostly Haiku, cached + routed).
  - Paid user: USD 0.43/month average (unlimited but median ~30 messages).
- **Payment processing:** 3.5% (Apple/Google take 15-30%; we model 25% blended on subscription gross).
- **Voucher subsidy:** 30% of voucher face value borne by RunVie, 70% by brand partner. Voucher payout target USD 4/paying user/month → USD 1.20 RunVie cost.

### OpEx — Headcount Ramp
| Month | Headcount | Comment |
|---|---|---|
| M1 | 3 | Founder + 2 contractors |
| M3 | 4 | + Senior Designer |
| M6 | 7 | + Backend Eng, Growth Lead, QA |
| M9 | 9 | + AI Engineer, Customer Success |
| M12 | 12 | + BD Head, Mobile Eng, Marketing Manager |
| M18 | 18 | + 6 (SEA growth + content + data analyst + Android eng + finance + ops) |
| M24 | 28 | + 10 (regional + B2B sales team + community) |
| M36 | 55 | + 27 (global expansion org) |

- **Average fully-loaded cost (VN):** USD 28k/year senior eng, USD 18k/year junior eng, USD 35k/year leadership.
- **Average fully-loaded cost (regional hires SEA M18+):** USD 45-65k/year.

### Other OpEx
- **Tools + SaaS:** USD 2k/month M1-6 → USD 8k/month M12 → USD 25k/month M24.
- **Office (HCMC + HN small spaces):** USD 3k/month M6 → USD 12k/month M24.
- **Legal + accounting + admin:** USD 4k/month M1 → USD 10k/month M24.
- **Marketing spend Y1:** USD 375k (paid acquisition + KOL + PR retainer).
- **Marketing spend Y2:** USD 1.4M (scaled paid + SEA launch + brand campaigns).
- **Marketing spend Y3:** USD 3.5M (global English markets + paid scaling).

---

## 24-Month Summary Table

| Month | New DL | MAU | Paying | MRR | Total Rev (mo) | COGS | OpEx | Marketing | Net Burn | Cash EOM |
|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 1k | 0.4k | 0 | 0 | 0 | 0.2k | 22k | 8k | -30k | 1,470k |
| M2 | 3k | 1.5k | 0 | 0 | 0 | 0.4k | 25k | 12k | -37k | 1,433k |
| M3 | 8k | 4k | 50 | 0.3k | 0.4k | 0.8k | 32k | 18k | -50k | 1,383k |
| M4 | 18k | 10k | 250 | 1.3k | 1.8k | 1.5k | 38k | 28k | -65k | 1,318k |
| M5 | 30k | 22k | 700 | 3.6k | 4.5k | 2.5k | 42k | 35k | -75k | 1,243k |
| M6 | 50k | 45k | 1.6k | 8.2k | 11k | 5.5k | 58k | 55k | -107k | 1,136k |
| M7 | 55k | 60k | 2.4k | 12k | 18k | 7.5k | 62k | 50k | -101k | 1,035k |
| M8 | 60k | 70k | 3.1k | 16k | 25k | 9.5k | 68k | 48k | -100k | 935k |
| M9 | 60k | 80k | 3.7k | 19k | 32k | 11k | 78k | 45k | -102k | 833k |
| M10 | 55k | 88k | 4.2k | 21k | 38k | 12.5k | 82k | 42k | -98k | 735k |
| M11 | 55k | 95k | 4.7k | 24k | 45k | 14k | 85k | 40k | -94k | 641k |
| M12 | 105k | 100k | 5.0k | 26k | 58k | 16k | 95k | 38k | -91k | 550k |
| **Y1 EOY** | **500k DL cum** | **100k** | **5.0k** | **26k** | **ARR 700k** | | | | **-950k Y1** | **550k** |
| M13 | 60k | 130k | 7.5k | 41k | 75k | 19k | 110k | 80k | -134k | 416k |
| M14 | 80k | 175k | 11k | 60k | 110k | 26k | 125k | 95k | -136k | 280k |
| M15 | 100k | 230k | 15k | 82k | 150k | 35k | 140k | 110k | -135k | 145k |
| M16 | 120k | 295k | 20k | 110k | 195k | 45k | 155k | 125k | -130k | 15k |
| | | | | | | | | | | **Series A bridge or extension typically here** |
| M17 | 140k | 370k | 26k | 145k | 245k | 56k | 175k | 140k | -126k | -111k (bridge) |
| M18 | 160k | 460k | 34k | 190k | 305k | 70k | 195k | 155k | -115k | -226k (bridge) |
| M19 | 175k | 555k | 42k | 235k | 365k | 85k | 215k | 165k | -100k | -326k |
| M20 | 190k | 660k | 50k | 280k | 425k | 100k | 235k | 175k | -85k | -411k |
| M21 | 205k | 770k | 59k | 330k | 490k | 115k | 255k | 185k | -65k | -476k |
| M22 | 215k | 870k | 66k | 370k | 550k | 130k | 275k | 195k | -50k | -526k |
| M23 | 220k | 940k | 68k | 380k | 590k | 138k | 285k | 200k | -33k | -559k |
| M24 | 225k | 1,000k | 70k | 392k | 833k | 145k | 295k | 205k | +188k | -371k |
| **Y2 EOY** | **2.5M cum** | **1.0M** | **70k** | **392k** | **ARR 10.0M** | | | | **+1.4M EBITDA Y2** | |

### Realistic narrative

- Months 1-6: pure burn, pre-launch and soft launch.
- Months 6-12: revenue ramps, MRR crosses USD 26k by M12 (USD 700k run-rate ARR + B2B contracts + sponsorship lump-sums recognized).
- Months 13-16: VN scaling + SEA expansion eats marketing budget. **Cash goes critical M16.**
- Months 17-18: standard seed practice = open Series A conversations at M14, target close M18-19. Bridge note from existing seed investors common if Series A slips by 2-3 months.
- Months 19-24: Series A USD 5-8M closes M19-20; cash replenished; EBITDA positive Q4 Y2 on operating basis (excludes growth marketing as "investment").

### Y3 Annual Summary
- **Revenue:** USD 25M (60% sub, 18% B2B, 8% affiliate, 4% sponsored, 10% misc — mix shifts as B2B compounds).
- **Gross margin:** 80%.
- **OpEx:** USD 13.5M (55 headcount × ~USD 110k blended fully-loaded global avg + USD 3.5M marketing + USD 1.5M other).
- **EBITDA:** USD 6.5M positive.
- **Free cash flow:** USD 4.5M after capex + working capital.

---

## Milestones for Investor Tracking

| Milestone | Target Month | Trigger |
|---|---|---|
| Public VN launch (App Store + Play Store) | M6 | 200k downloads, 45k MAU |
| First USD 100k MRR run-rate | M9 | 4,500 paying users + B2B pilots |
| EBITDA approach (gross profit covers fixed OpEx) | M14 | 11k paying users |
| Series A open | M14 | Started conversations |
| Series A close | M18-20 | USD 5-8M raise, USD 30-50M post |
| EBITDA-positive month (operating) | M24 | Run-rate USD 10M ARR + disciplined OpEx |

---

## Sensitivity Analysis (Y2 EOY ARR)

| Scenario | Paid Conversion | Annual Retention | CAC | Y2 ARR |
|---|---|---|---|---|
| **Bear** | 3.5% | 55% | USD 22 | USD 5.8M |
| **Base** | 7.0% | 70% | USD 18 | USD 10.0M |
| **Bull** | 9.0% | 78% | USD 14 | USD 14.5M |

Even bear case (USD 5.8M ARR) supports a USD 25-35M Series A at 5-6× ARR multiple — round still happens, just at a tighter valuation and tighter terms.

---

## Cost Stress Tests

- **If Claude prices rise 3×:** AI cost per paid user goes from USD 0.43/mo to USD 1.29/mo. Gross margin drops 3 points to 75%. Mitigation: route 40% of free-tier traffic to cached/templated responses, fine-tune smaller open model for routine "encouragement" replies, keep Claude for complex coaching.
- **If FB/TT auction tightens 50%:** CAC blended goes from USD 18 to USD 23. Payback extends from 9 → 12 months. Mitigation: shift to TikTok creator partnerships at fixed CPM, lean harder on KOL revshare deals, double down on referral loops (RunCoin for invited friends).
- **If voucher partners pull subsidy from 70% → 50%:** RunVie cost per paying user/month rises from USD 1.20 → USD 2.00. Gross margin drops 2 points. Mitigation: cap RunCoin payouts at USD 3/user/mo (currently USD 4), introduce coin sinks (virtual race entries, premium medals).
