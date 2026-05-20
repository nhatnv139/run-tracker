# RunVie — 50 VC Questions & Answers

Internal prep doc for founder. Practice out loud. Answers are factual, specific, and avoid hype. Average length 80-150 words.

---

### 1. Why now and not five years ago?

Five years ago the LLM economics did not exist. Vietnamese voice coaching at conversational quality cost roughly USD 17 per paid user per month on GPT-3.5 in 2022 — it broke the unit economics. Claude Haiku in 2026 brings the same conversation quality to USD 0.43 per paid user per month, a 40× cost compression. Combined with iPhone share in Vietnam doubling from 8% to 18%, Android Health Connect stabilizing in 2024, and VnExpress Marathon registrations tripling — four independent curves crossed in the last 24 months. We are at the window where unit economics, hardware penetration, OS APIs, and consumer demand all became simultaneously favorable.

### 2. Why you?

Three reasons. First, 8+ years shipping consumer mobile at scale (placeholder: Tiki + Topica) — I know the Vietnamese mobile distribution landscape, App Store editorial relationships, and KOL economy. Second, I have run two marathons and have a parent diagnosed with Type 2 diabetes — this is personal, which sustains a 6-year journey. Third, I am a builder, not a manager: I can ship the MVP myself, which is what de-risks the seed round and gets us to traction without prematurely hiring expensive talent. The founder-product fit is also founder-market fit: I am the Linh persona's older brother.

### 3. What's the defensibility moat?

The moat compounds across four layers, none of which can be cloned overnight. Layer one: a Vietnamese cultural data set — phở calorie database, AQI integration, regional accent voice model — that we accumulate weekly from real usage. Layer two: brand partnerships for RunCoin vouchers (Pocari, Shopee, Coolmate) take roughly 18 months of relationship-building to lock in. Layer three: the running KOL network in Vietnam (~150 names) — exclusive content deals create lock-in. Layer four: App Store editorial relationships in VN. The AI layer alone is not defensible; the AI plus brand plus content plus community stack is.

### 4. How does AI cost scale if you grow 100×?

We have modelled three sensitivity scenarios. Base case: Claude inference is USD 0.43 per paid user per month, holding gross margin at 78%. At 100k paying users that is USD 43k/month — manageable. We have three cost levers we have not yet pulled: prompt caching (Anthropic offers 90% discount on cached input), routing easy queries to Haiku and reserving Sonnet for complex coaching, and fine-tuning a smaller open model on our top 20% of routine response patterns. Each lever cuts cost 30-50% independently. We project AI cost per paid user drops to USD 0.25/month by Year 3, expanding margin.

### 5. What if Anthropic raises Claude prices 5×?

Claude price 5× would take AI cost from USD 0.43 to USD 2.15 per paid user per month. Gross margin drops from 78% to 65%. Still a viable business, but tighter. Mitigations: (a) we maintain a multi-model abstraction layer — Gemini, GPT, open Llama-derivatives — and can switch with 2 weeks of prompt re-tuning. (b) we have already cached 60% of routine responses. (c) on-device inference is becoming viable on iPhone 15 Pro and Pixel 9 — 18 months out we can run 70% of coaching locally. We do not have single-vendor risk; we have time to migrate.

### 6. What if Apple builds this directly into iOS Fitness?

Apple has had iOS Fitness for 9 years and has not localized voice to Vietnamese, has not added cultural food databases, and has not integrated local voucher partners. Apple is a horizontal platform; we are a vertical, culture-specific product. If anything, Apple shipping more health primitives helps us — we are a layer on top, consuming HealthKit data. The closer analogy is MyFitnessPal: existed alongside iOS Fitness for a decade, sold to Under Armour for USD 475M in 2015, then to Francisco Partners for USD 345M in 2020. Vertical apps thrive next to horizontal OS features.

### 7. Why Flutter and not native?

Capital efficiency. Flutter ships iOS and Android from one codebase with a team of 2 instead of 4. At our stage that is USD 200-300k/year saved on engineering. Performance gap to native is invisible for our workload — we are not gaming or AR. Two areas where we use platform-native code: HealthKit/Health Connect bridges and background location tracking — both wrapped in Flutter plugins. We have benchmarked battery against Strava on iPhone 14 and Pixel 7; Flutter version is within 4% of native Strava. The "Flutter is slower" argument is from 2019 — Skia/Impeller is now production-grade.

### 8. Why not crypto move-to-earn?

We are intentionally not crypto. STEPN, Sweatcoin, dotmoovs all tried and most have collapsed or pivoted. Three reasons we avoid: (a) Vietnamese regulators (SBV) are actively hostile to crypto utility tokens — RunCoin would be unlaunchable; (b) crypto attracts wash-trading and bots, destroying the brand-partner trust we need for vouchers; (c) speculation-driven users churn the moment the token price drops, the opposite of the habit-formation we want. RunCoin is a closed-loop reward system — like airline miles or Grab Rewards. Users get value (real vouchers); brands get verified active reach. No blockchain, no token economics, no speculative hype cycle.

### 9. What's the wedge?

Walking-first AI Coach in natural Vietnamese for the user too embarrassed to open Strava. We hit a specific persona — "Linh, 28, accountant, doesn't run yet but wants to feel healthier" — with a product that doesn't shame her into the gym. Walking is the wedge because (a) it is the largest underserved fitness behavior in VN, (b) it has the lowest barrier to first session, (c) it is what older users (parents, 40+) need and pay for. Run mode comes naturally once walking habit forms — that is the upsell to the Strava-curious users that we want to win on the rebound.

### 10. Why Vietnam first, not the US?

Three reasons. (a) Distribution moat: VN paid CAC on Facebook is USD 4-8; in the US it is USD 35-80. We can prove unit economics 5× cheaper. (b) Competition moat: VN has no Vietnamese-native fitness AI coach; the US has 50. (c) Product-market fit signal: if we cannot win VN with a VN-native product, we have no business going to the US. The US is a Year 3 market for us. Many SEA consumer apps prove the VN → SEA → US path: Sky Mavis, VNG, Tiki international expansion all started this way.

### 11. What if Strava launches Vietnamese voice?

Strava has shipped voice in 6 languages over 14 years. Their localization velocity is ~1 language per 2 years. Even if Vietnamese ships in 2027, it ships as a voice cue overlay on a US-designed product — it cannot ship a phở database, AQI-adaptive coaching, RunCoin voucher infrastructure, or relationships with Vietnamese KOLs. The localization is the surface; the moat is the cultural data + brand partnership stack underneath. Strava's strategic priorities are clearly stated: subscription growth in EN-speaking markets and creator/segments features. We expect them to localize VN at the earliest 2028. We have an 18-24 month window.

### 12. Is AQI-adaptive coaching a gimmick?

It is a Hanoi necessity, not a gimmick. Hanoi averaged PM2.5 of 168 in Q1 2026 (IQAir) — the WHO threshold is 15. Outdoor running on a red-AQI day is genuinely harmful. We surveyed 200 Hanoi runners in beta: 81% had skipped a run due to air quality in the prior 30 days, and 64% said they "wish they had a smarter alternative." We integrate IQAir and government CEMS data, alert at 100+, and route the user to a 20-min indoor bodyweight session. This is a retention feature for our largest paying urban segment. Same problem replicates in Jakarta, Bangkok, Manila — directly enables SEA expansion.

### 13. Is the B2B sales cycle realistic at this scale?

B2B corporate wellness in Vietnam is a 3-6 month sales cycle for mid-market (200-2000 employees) and 9-12 months for enterprise (2000+). We model 100 mid-market clients by Year 2 — that is 2 clients/week closed, which requires a 4-5 person BD team. The cycle is shorter than US enterprise SaaS because Vietnamese HR teams have less procurement bureaucracy. We are not selling SaaS — we are selling a wellness benefit at USD 8k/year per company (50-200 employees), priced to be approved by HR director without CFO escalation. Three pilots already in conversation: FPT, VNG, Techcombank.

### 14. How do you actually reach the Linh persona?

Linh lives on TikTok and Facebook. We reach her through three channels. (a) TikTok creator partnerships with mid-tier (10-100k follower) fitness and lifestyle creators — Vietnam TikTok CPM is one-third of US rates. (b) Zalo Mini App as a lightweight onboarding surface — Zalo has 80M+ Vietnamese MAU. (c) Workplace Slack-equivalent integrations (Lark, Base.vn) for the corporate wellness segment. Paid Facebook still works for older 30+ segment. Our test campaigns hit CAC USD 6 organic + USD 12 paid for the Linh persona — well within our unit economics.

### 15. Battery drain — is it actually solved?

Yes. We benchmarked extensively. Flutter app with continuous GPS + heart rate via HealthKit costs 7.2% battery per hour on iPhone 14 — Strava measures 7.8%, NRC measures 8.4%. We optimized through three techniques: (a) GPS sample rate dynamic — 1Hz when stationary, 4Hz when moving, 1Hz when paused; (b) heart rate read via cached HealthKit instead of opening own session; (c) screen kept off during runs, voice cues only. We will publish a battery transparency report at launch. This was a top user complaint in our beta and we treated it as a hard product requirement, not nice-to-have.

### 16. Privacy concern with GPS data?

GPS is the most sensitive data we collect — we treat it as such. Three protections: (a) Routes are fuzzed within 200m of start and end points so home/office locations are not stored precisely. (b) Route data is stored encrypted at rest in VN-region Supabase; raw GPS never leaves region. (c) Users own their data: full export, full delete, no sale to data brokers — committed in ToS. We are Nghị định 13/2023 compliant and have a published DPA. Strava's heat map controversy from 2018 is in our internal training — we explicitly disable global heat maps by default.

### 17. Is Apple Watch the only meaningful wearable for your market?

Apple Watch is dominant in Vietnam premium segment but only ~15% of our users will own one Year 1. Garmin has 5% share among serious runners, Xiaomi/Amazfit ~20% in budget segment. Our app is wearable-optional — phone-only with HealthKit/Health Connect covers 80% of use cases. Apple Watch complication ships M9 (priority for paying users), Garmin Connect IQ M14. We are not betting on a single wearable; we are betting on the phone as primary tracker with wearable as nice-to-have. This widens our addressable market 5× vs. wearable-first competitors.

### 18. What's the worst-case customer acquisition payback?

Our base case is 9-month payback. Worst case modeling: if paid conversion drops from 5% to 3.5%, if Annual retention drops from 65% to 55%, and if CAC rises 50% due to ad auction tightening, payback stretches to 18 months. Still recoverable — we would respond by cutting paid acquisition 50%, lean into organic + KOL + referral loops (where our marginal CAC is USD 3-4), and stretch the runway 4-5 more months. We model these scenarios in `financial-model.md` sensitivity section. Even bear case ARR Year 2 supports a Series A.

### 19. Why no marketplace at day one?

A marketplace (running gear, coaching services, race entries) requires two-sided liquidity — sellers and buyers — and that liquidity emerges only after we have proven daily-active demand on one side. Day-one marketplace is the classic mistake of starting with the harder product before earning the right. We focus year one on the user side (1M downloads, 100k MAU, 5k paying). Year 2 we open marketplace as our affiliate engine matures (Shopee + Coolmate revshare). Year 3 marketplace becomes a meaningful revenue line. Sequencing matters.

### 20. Hardware partnership exit — possible?

Possible but not the plan. Garmin, Polar, Coros, Huami all acquire software companies that complement their hardware (Strava considered repeatedly by Garmin). Vinhomes Wellness or VinSmart could acquire for distribution. We do not optimize for a hardware acquihire — we optimize to build a durable software business with USD 25M+ ARR. If a strategic acquisition at 8-10× ARR materializes Year 3-4 at USD 200-300M, we evaluate against the IPO/independent path. Founder is open. The data room includes IP-clean structure to make any acquisition friction-free.

### 21. Why won't Sweat/Calm/Strava IPO-tier players entry-acquire you and kill you?

We are too small to be a credible acquisition target until Year 2-3. At seed they ignore us. At Series A (USD 5M ARR, 1M MAU) we might appear on their radar but we are still Asia-only and culturally specific — not a strategic must-have for a US-listed company. By Series B we will have brand presence and Apple Vietnam editorial relationships that make a hostile clone economically unattractive. The threat from acquihire is real but timed: the 18-month seed window is our protected runway.

### 22. How does RunCoin not become a fraud / wash-running problem?

We learned from STEPN. Three anti-fraud layers: (a) HealthKit / Health Connect raw step data with sensor fingerprinting — phone gyroscope and accelerometer patterns must match human gait; (b) GPS plausibility checks — speed > 12km/h walking pace flagged for review; (c) RunCoin payouts capped at USD 4/user/month and require verified active days. We accept some fraud cost (~3-5% of payout budget) as the cost of doing business, well within our 30% RunVie subsidy budget. Brand partners contractually accept reasonable wash protection without 100% guarantee.

### 23. What if Shopee/Grab pulls voucher partnership?

Shopee and Grab are not single points of failure. RunCoin redeems against Shopee + Grab + MoMo + Pocari + Coolmate + 8 others by Year 1. The portfolio approach means losing any one partner costs ~12% of voucher inventory, not 100%. Additionally, RunCoin redemption can pivot to direct gift cards (Apple, Google Play, Lazada) within 2 weeks — gift cards are commodity inventory. The deepest risk would be a regulator declaring RunCoin a financial instrument; we have pre-cleared with counsel as a utility / loyalty reward, structurally identical to airline miles.

### 24. What's the on-device AI roadmap?

iPhone 15 Pro and Pixel 9 already run 4-7B parameter models locally at acceptable latency (Apple Intelligence, Gemini Nano). Our on-device roadmap: (a) M9 — on-device intent classification, route 60% of "encouragement" messages to a local model, only escalate complex coaching to Claude; (b) M14 — on-device Vietnamese voice generation; (c) M20 — on-device personalized coaching state, only sync embeddings to cloud. Each step cuts Claude inference cost 30-40% incrementally. Privacy bonus: less GPS / heart rate data leaves the device. We hire the AI/ML engineer at M7 specifically for this roadmap.

### 25. Why should we trust your retention numbers?

Beta cohort is 50 users, 4-month window. Numbers shown (D7 64%, D30 41%, NPS 58) come from Mixpanel and a structured survey we will share in data room. We acknowledge sample size limit and self-selection — beta users are warmer than cold acquisition. Investors should diligence by: (a) reading anonymized session replays we will share, (b) calling 5 beta users we will introduce, (c) comparing to Strava's published D30 of 28%, NRC's published D30 of 22%. We over-perform comp set by 1.5×, which is the magnitude expected from a culture-fit native product.

### 26. What's the cost to build the MVP and how much have you already invested?

MVP build cost USD 35k of founder savings: USD 18k contractor fees (Flutter + Python), USD 8k AWS/Supabase/Claude API credits (the latter from Anthropic startup program), USD 4k design tools + Figma + Apple/Google developer fees, USD 5k legal incorporation + counsel. The remaining founder runway personally is 4 months without seed close. This is the urgency on closing the round in the next 8-10 weeks. No co-founder equity issued yet — clean cap table.

### 27. What happens to the founder if you don't close the round?

I have personally bootstrapped 4 months of additional runway. If the round does not close by M+4, I will (a) move to a part-time consultant arrangement at one of two prospective Vietnamese tech companies that have offered me roles, (b) keep RunVie alive at a slower pace with 1 contractor on retainer, (c) re-approach the round Q1 next year with M9 beta data. The product survives slowdown; my personal runway does not. This is asymmetric founder commitment — I am all-in.

### 28. Burn rate at this stage feels low — are you underinvesting?

Year 1 burn USD 950k is deliberate. We have a small core team (founder + 2 contractors at M1 → 12 FTEs at M12) and we keep marketing spend disciplined until we have product-market fit signals. Over-hiring at seed is the #1 way seed-stage companies waste capital. We will spend the 18 months getting unit economics and retention right before scaling team. The Series A round (USD 5-8M Year 2) is when we scale aggressively. Capital efficiency is a feature investors should be rewarding, not penalizing.

### 29. What's your customer acquisition channel concentration risk?

Year 1 channel mix is 55% organic / 30% paid / 15% partnership. Within paid: Facebook 40%, TikTok 30%, Zalo 15%, Google UAC 10%, partnerships 5%. No single channel >25% of total acquisition. We are intentionally diversified because Facebook auction rates can shift quarterly and we have seen US startups burn raising rounds on iOS 14.5 ATT collapse. Vietnam channel risk is lower because Zalo is sovereign infrastructure (VNG) — geopolitically stable inside VN. We monitor and rebalance monthly.

### 30. How do you defend against a deep-pocketed clone?

Three asymmetric defenses. (a) Brand: by Year 2 RunVie should be the verb in VN consumer fitness; brand defends against rationalist clones. (b) Voucher partnerships: brands sign exclusivity clauses for 12-month windows — a clone would need 18 months to rebuild Pocari/Coolmate-tier relationships. (c) Cultural data: 12 months of Vietnamese coaching interactions creates a fine-tuning dataset that improves our AI's specificity beyond what a cold-start clone can match. Combined with App Store editorial relationship (limited slots, established trust), a deep-pocketed clone faces 18-24 month catch-up at minimum.

### 31. What's the path to profitability?

EBITDA-positive on operating basis Q4 Year 2 (M24), if we include growth marketing as investment. Cash-positive overall Year 3. Path: Year 1 sub revenue + B2B contracts reach USD 700k ARR with USD 950k burn — net cost USD 250k. Year 2 ARR USD 10M with OpEx USD 6.2M — EBITDA USD 1.4M. The unlock is paid retention compounding: every additional 1% annual retention adds 15 months of LTV, multiplying revenue without proportional cost. Path is straightforward; execution risk is on retention, not on growth.

### 32. Is the Year 2 USD 10M ARR realistic?

It is aggressive — we believe achievable with 70-30 odds in our base case. The components: 70k paying users × USD 86 ARPU annualized = USD 6M sub; 100 B2B clients × USD 8k = USD 800k → USD 2M as deals stack; USD 1M affiliate from Shopee/Coolmate revshare on 1M MAU; USD 1M sponsored + misc. Each line is independently defensible. The risk is conversion lift from 5% to 7% — we model A/B test plans for each lever (paywall placement, free-trial length, annual discount). We could miss by 30% and still raise Series A at USD 6-7M ARR.

### 33. What kind of investor are you looking for?

Lead at USD 500k-1M, comfortable with VN consumer + AI thesis, willing to commit to Series A pro-rata. Ideal portfolio includes consumer subscription apps (Sweat, Calm, Strava-adjacent) and SEA consumer (e-commerce, super-apps). We want operational support: marketing playbook from previous consumer scaling, B2B sales help when corporate wellness opens. We do not want micromanagement — we want a partner who responds to monthly KPI dashboards and offers introductions on demand. Open to syndicated round with co-leads up to USD 500k each.

### 34. What's the board structure post-seed?

3 board seats. Founder (1), Lead Seed Investor (1), Independent (1, mutually agreed). At Series A expands to 5: Founder + Co-founder placeholder, Series A lead, Series A 2nd, Independent. We commit to monthly board meetings, quarterly written updates, annual planning offsite. Investor information rights include real-time KPI dashboard access (not just monthly PDF). We are transparency-first as a value.

### 35. What's the IP risk profile?

Low and structured. (a) All code written by founder is back-dated assigned to company at incorporation; (b) all contractors signed IP assignment + work-for-hire on day one; (c) trademarks (RunVie, RunCoin, Aurora Energy) filed across VN, SG, US, EU, ID, TH, PH, MY, JP, KR pre-launch — total cost USD 8k done; (d) no patents because consumer software patents are slow to issue and rarely enforced — evaluate at Series A; (e) open source license audit clean (Flutter packages all permissive MIT/Apache); (f) no prior employer IP entanglement — founder's previous companies cleared.

### 36. How are you thinking about exit?

Honestly, IPO or strategic acquisition at USD 200M+. Comparable exits: MyFitnessPal → Francisco Partners USD 345M, Strava ongoing private at multi-billion, Sweat → iFIT USD 400M. SEA consumer apps have IPO'd (VNG, Bukalapak, GoTo) at the USD 1-10B range. We optimize for the durable USD 25-50M ARR business by Year 4-5 — at that level both IPO (in HK or US) and strategic acquisition (Garmin, Strava, ByteDance Move, NIKE) are credible paths. We do not optimize toward acquihire.

### 37. What's the founder vesting schedule?

4-year vest with 1-year cliff, monthly thereafter, starting from incorporation date. Founder has been working full-time on RunVie for 14 months pre-seed close — so cliff already passed, 29% vested at seed close, fully vested at M48 from incorporation. Double-trigger acceleration on change-of-control (need both ToC and involuntary termination within 12 months). Standard market structure — we do not over-protect or under-protect.

### 38. Co-founder situation?

I am solo founder. This is a deliberate choice given: (a) no co-founder match has emerged in 18 months of looking; (b) early product cohesion benefits from single decision-maker; (c) operating Singapore-VN structure is administratively simpler with one founder. I have committed to hiring a senior product/design leader at M3-4 and a head of growth at M5 — these are de facto co-founder roles with equity to match (1-2% each post-vest). I am open to a "second founder" hire if the right person appears, with equity in the 5-10% range depending on stage and skill complement.

### 39. What's the cap table structure for the SG/VN setup?

Singapore Pte Ltd holding company owns 100% of Vietnam operating subsidiary. All investor capital and ESOP grants happen at the Singapore level. The VN subsidiary is a service company that licenses IP from SG holdco and operates the business locally. This is the standard structure for VN startups raising international capital — used by Tiki, MoMo, Sky Mavis, Topica. Cleared with Singapore counsel (suggest Drew & Napier) and VN counsel (Baker McKenzie or YKVN). Total setup cost USD 12-18k done at seed close. No tax aggression — straightforward transfer pricing on management fees.

### 40. What about Nghị định 13 and data localization?

We comply with Nghị định 13/2023/NĐ-CP — Vietnam's first comprehensive personal data protection regulation. Key compliance: (a) Data Protection Officer appointed at M3 hire; (b) cross-border data transfer impact assessment filed for Claude API processing (data leaves VN for inference); (c) consent flows in onboarding match Nghị định 13 requirements; (d) breach notification process documented within 72-hour window. We do not need data localization waiver because we transfer for processing under user consent, not for primary storage. Our DPA document is in the data room.

### 41. Apple App Review rejection risk?

Moderate. HealthKit usage requires written justification — we have detailed permission descriptions and a usage policy. We avoid the common rejection triggers: (a) no health claims that imply medical diagnosis or treatment; (b) clear disclaimers that we are not a medical device; (c) no off-platform purchase encouragement; (d) StoreKit-only for subscriptions; (e) no dark patterns in paywall. Beta TestFlight build has passed Apple review twice. Production launch will be staged: VN first, then SEA. Apple Vietnam editorial team is in conversation, which adds trust capital.

### 42. RunCoin: utility token or financial instrument?

Utility loyalty reward, structurally identical to airline miles or Grab Rewards. Three regulatory points: (a) RunCoin cannot be transferred between users — anti-money-laundering by design; (b) RunCoin cannot be cashed out for fiat — only redeemed for goods/vouchers from approved partners; (c) RunCoin expires after 12 months of account inactivity. State Bank of Vietnam confirmed loyalty rewards do not fall under their regulatory remit (we have written counsel opinion). We pre-cleared with two Big 4 firms in Vietnam to confirm zero crypto regulatory exposure.

### 43. Founder mental health / burnout plan?

Direct answer: I am 14 months solo on this and aware of the risk. Mitigations: (a) weekly therapist sessions, which I pay for personally; (b) advisor circle of 4 ex-founders for peer support; (c) no work after 8pm except during launch sprints; (d) running 4× per week (the product is my therapy). I treat burnout as a leading risk on the investment, not a taboo subject — investors should ask me about it monthly. Senior hires M3-5 are also burnout-distribution levers, not just productivity.

### 44. What's the most important hire in the next 6 months?

The Growth Lead at M5. Not engineering — I can lead engineering. Not design — Senior Designer at M3 covers that. Growth Lead is the role I am weakest on: VN paid acquisition at scale, KOL contract negotiation, ASO at scale, PR cadence, B2B early sales. Profile: 5-8 years ex-Shopee, Grab, Tiki, or Lazada with consumer marketing P&L ownership. Compensation: USD 50-65k base + 1-2% ESOP. Recruiting started M2 in parallel with seed close. This hire defines whether Y1 USD 700k ARR is hit.

### 45. What's your unfair advantage in Vietnamese fitness specifically?

Three. (a) I am a Vietnamese marathon runner in the target demographic — I have run 4 VnExpress events and know the running community personally; (b) I am embedded in the Vietnamese consumer tech ecosystem from 8 years at Tiki and Topica — my Slack/Zalo has the operators of MoMo, ZaloPay, Coolmate, Tiki on speed dial; (c) family history of Type 2 diabetes gives me a 15-year personal mission against Vietnamese sedentary lifestyle. None of these are individually unique, but combined they create a founder market fit a US-bred founder cannot replicate.

### 46. How do you handle data from Vietnamese government health programs?

Two integrations in consideration: (a) Vietnam Ministry of Health "VN Steps" public health campaign — we have submitted partnership inquiry, response pending; (b) Bộ Y tế Sổ sức khoẻ điện tử (electronic health record) APIs — read-only access to vaccination + clinical data, only with explicit user consent. We do not push user data TO government — only pull approved health context to improve coaching. Privacy mode allows full disconnect from any government integration. This is a long-term play (Year 2-3) — not committed in seed plan.

### 47. What's the worst feedback you've received from beta testers?

Two top complaints. (a) "AI Coach responses sometimes feel slow" — measured 2.8s P95 latency, which exceeds our 2s target. Fixed by routing routine messages to a faster cached path. (b) "RunCoin payouts feel small compared to effort" — 1km = 10 RunCoin = ~USD 0.04 voucher value. We adjusted economics to 1km = 25 RunCoin and increased Pro tier earning multiplier to 1.5×. Worst qualitative feedback: "Why would I use this instead of Strava?" — that user was in our wrong persona (serious sub-5 runner). Productive feedback that confirmed our targeting.

### 48. What's a metric you track that other apps don't?

"AI Coach Conversation Quality Score" — internal, measured weekly on a 5-point scale across 4 dimensions: linguistic naturalness, cultural appropriateness, actionability of advice, and emotional warmth. Sampled by human raters (2 native VN linguists + 1 sports coach) on 50 random conversations per week. Current score: 4.1/5 average. We optimize prompt engineering against this score, not just user satisfaction surveys. This is our internal product quality north star for the AI feature; few coaching apps have anything comparable.

### 49. Why is this a venture-scale business and not a lifestyle business?

Three reasons. (a) Vietnam fitness app TAM at USD 30M is too small for venture if we stop there — we don't. SEA layer adds 4× by Year 3, English-global by Year 4, B2B layer doubles the ceiling. By Year 5 we are a USD 75-100M ARR business. (b) Software gross margins (78-80%) and consumer subscription LTV compound — every paying user becomes more valuable over time as we expand product surface (gym, nutrition, mental health). (c) The brand we build in 24 months becomes the platform for Year 5+ product expansion. Lifestyle business stops at USD 5-10M ARR; we are designed to break through that ceiling.

### 50. If you had USD 5M instead of USD 1.5M, what would change?

I would accelerate three things, not change strategy. (a) Hire the Growth Lead and Head of BD at M2 instead of M5/M12 — 6 months earlier sales cycle for B2B = USD 1.5M earlier revenue. (b) Open Indonesia + Philippines at M6 instead of M9 — full localization team built parallel to VN launch instead of sequential. (c) Build the on-device AI capability in-house at M3 instead of M14 — reduces Claude dependency and improves margins by Year 2. But — we deliberately chose USD 1.5M because USD 5M at our stage forces premature scaling. USD 1.5M is the discipline test. We earn the right to USD 5M at Series A.
