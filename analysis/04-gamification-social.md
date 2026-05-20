# 04 — Gamification & Social Design cho Run Tracker VN

**Mục tiêu**: Top 10 App Store VN (Health & Fitness), Retention D30 > 25%, DAU/MAU > 50%.
**Benchmark**: Strava (social), Nike Run Club (coaching + brand), Zombies Run! (narrative), Pokemon Go (AR + walking), Duolingo (streak psychology).

## 1. Core Loop Gamification
Daily loop 60–90s: check 3 daily quest (1 dễ, 1 vừa, 1 stretch), claim XP, mở loot box mỗi 5 level, lướt feed bạn bè.
XP & Level: 1km = 100 XP, +20% quest bonus, +50% PR bonus, cap 1500 XP/ngày. Level 1–100, mỗi 10 level mở avatar tier mới.
Streak + Freeze (Duolingo-inspired): 2 freeze tự động/tuần, mua thêm bằng RunCoin (cap 5/tháng). Milestone 7/14/30/100/365 ngày = badge + XP combo x1.2 → x2.0. Combo: chạy ≥3 ngày liên tiếp trong tuần → x1.5 XP cuối tuần.

## 2. Achievements (80–100 badge, 3 tier mỗi badge = 240 mảnh)
- Distance milestones (20): 5/10/21.1/42.2/50/100/500/1000/5000/10000 km lifetime + single-run.
- Streak (10): 7/30/100/365/500/1000 ngày, Comeback King (rebuild sau gãy >30 ngày).
- Time-of-day (8): Sunrise (<6h ×30), Night Owl (>22h ×20), Midnight (00–02h), Lunch Break Hero.
- Weather (6): Rain Warrior (OpenWeather verify), Heat Survivor (>35°C), Cold Crusher (<15°C).
- Social (10): Referred 5/10/50, 100 kudos given, founded club, top city.
- Seasonal VN (12): Tết Run mùng 1–3, Quốc Khánh 2/9, Giỗ Tổ, Trung Thu Night Run, Black Friday 5K, VnExpress/Techcombank/Longbien Marathon finisher.
- Hidden (8): chạy đúng 3.14 km, 4.20 km, vòng tròn khép kín, leo 10 cầu vượt.
- Pace (10): Sub-25 5K, Sub-50 10K, negative split, hill crusher 300m gain.
- Quirky (6): chạy 7 quận, qua 5 cầu, vòng Hồ Tây ~17km, bờ kè SG full.

## 3. Leaderboard
Scope: Global / Quốc gia / Thành phố / Quận / Bạn bè / Club. Tab tuần/tháng/năm/all-time. Metric: distance, time, elevation, runs, Effort Score composite. Reset thứ 2 06:00 VN, top 3 nhận badge + 100 RunCoin.
Anti-cheat: max pace cap <2:30/km flag, GPS-accelerometer-step mismatch check, teleport >100m invalid, elevation/grade sanity, outlier >100km/run hoặc >500km/tuần manual review, trust score + shadow-ban, hardware fingerprint giảm trust nếu 2 acc cùng device.

## 4. Challenges
- Solo auto-suggest theo level: "Run 50km/tháng", "21 ngày streak", "Sub-30 5K trong 8 tuần".
- Team 3–10 người: cộng dồn 1000km, leaderboard nội bộ, chat.
- Corporate wellness B2B: dashboard HR, prize fund — target FPT, Viettel, fintech, ngân hàng.
- Charity run: brand sponsor trả 1.000đ/km cho Operation Smile, Saigon Children's Charity — Vinamilk/Techcombank/Sun Group là sponsor; user free, brand trả CPA.
- Mini: weekend warrior, commute challenge.

## 5. Virtual Races
- VN Touring: HN–SG 1730km (3–6 tháng), Đường HCM 1180km, vòng Phú Quốc 150km. Landmark Vinh/Huế/ĐN/NT mở badge + story văn hóa.
- World: Everest 8848m gain, Sahara crossing.
- Physical medal: sản xuất $8–12, bán $25–35. Logistics GHTK/J&T. 10k user × 30% complete × $25 = $75k/race. Design VN: gốm Bát Tràng miền Bắc, đồng đúc Huế miền Trung → collectible.

## 6. Move-to-Earn — KHÔNG crypto
Bài học StepN: token -99%, Ponzi, regulation VN bất ổn, audience phổ thông không hiểu wallet.
Thay bằng RunCoin closed-loop: 1km = 5–10 coin, cap 50/ngày, decay theo level chống whale farm. Đổi voucher Shopee 50k (500 coin), Grab food 30k (300), Lazada 100k (1000), Highlands, TCH, Lock&Lock, gym California; đổi premium subscription, training plan, vé giải thật. Unit economics: voucher cost ~70% face value brand subsidize, app margin 30% hoặc loss leader retention. Lợi: no speculation, no bot spam, regulatory safe, brand có lý do trả tiền CPA.

## 7. Social Feed
Strava-inspired nhưng nhẹ: Kudos 1-tap, Comment 200 ký tự với sticker VN ("Cố lên!", "Đỉnh!", "Số dzách"). Follow asymmetric. Club theo địa điểm/công ty/pace group có chat + event + leaderboard riêng. Story 24h auto-expire với sticker pace. Privacy: hide 200m start/end, friend-only mode. Anti-toxic: no dislike, comment cần follow/cùng club, report + auto-mute keyword.

## 8. Pet/Avatar — RunPet
Pokemon-style emotional hook. Hatch egg đầu (chó/mèo/rồng VN) sau 10km. Evolution 50/200/500/1000km. Pet "đói" nếu nghỉ >3 ngày — visual sad không penalize XP, chỉ emotion pull. Pet đi cùng lúc chạy, react theo pace. Mỗi pet skill bonus nhỏ +5% XP weather run. Variant: 12 con giáp VN, Tết unlock pet năm đó cho user active.

## 9. AR Features (Phase 2)
Coin spawn GPS-based trên route. Monster encounter 1–2km/lần, mini-battle = chạy nhanh 30s sub-target → loot. Landmark AR Hồ Gươm, Bến Thành unlock card sưu tầm. Safety first: AR chỉ trigger khi dừng/đi bộ, cảnh báo nhìn đường, tắt được. Moat lớn vs Strava nhưng tốn dev resource.

## 10. Viral Loop
Share template 8 mẫu (route + distance + pace + pet) watermark, one-tap Zalo/IG Story/TikTok/FB.
Refer-a-friend: cả 2 nhận 200 RunCoin khi referee chạy 5km đầu — chứng minh real user.
Group invite: rủ 3 bạn join challenge → unlock skin giới hạn.
TikTok: hashtag #ChayCungApp, monthly contest.
K-factor target 0.4–0.6 trong 6 tháng đầu.

## 11. Anti-cheat & Abuse Prevention
Sensor fusion (GPS + accelerometer + step + barometer) mismatch flag. Mock location detection Android, jailbreak iOS. Velocity profile: pace xe máy/ô tô constant >25km/h liên tục = invalid. Device-account ratio limit. Manual review top leaderboard mỗi tuần trước trao thưởng. Report user. Trust score progressive. KYC nhẹ (OTP) cho redemption voucher >100k.

## 12. VN-Specific
- Tết: lì xì RunCoin mùng 1, "Chạy đầu năm lấy hên" badge rồng vàng, partnership Vietcombank/MoMo voucher.
- Quốc Khánh 2/9: race ảo 2.9 / 29 / 79 km.
- Partner giải phong trào: tích hợp BIB VnExpress Marathon, Techcombank HCMC, Longbien, Mekong Delta — verified finisher tự động.
- Hiking: Fansipan, Tà Xùa, Bà Đen elevation challenge.
- Voice coach tiếng Việt HN+SG accent, pace "phút/km".

## So sánh Benchmark
- Strava: social tốt, gamification yếu (chỉ segment + KOM) → ta thắng quest/pet/AR.
- Nike Run Club: coaching đỉnh, social yếu, không streak → học audio coach + streak Duolingo.
- Zombies Run!: narrative niche → dùng narrative cho virtual race landmark.
- Pokemon Go: AR + walking mass-market → áp dụng coin/monster nhưng bỏ raid (nguy hiểm đường chạy).
- Duolingo: streak + freeze + heart đẩy D30 ~37% → copy 1:1, weapon mạnh nhất.

Retention projection: D1 65% (onboarding + first run + pet hatch), D7 40% (streak + quest), D30 28–32% (badge + virtual race + social graph) — đạt target >25%.
