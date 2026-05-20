-- 20260520000500_badges.sql
-- Badge catalog + per-user unlocks. Seeds 30 core badges across all categories.

create type public.badge_category_enum as enum (
    'distance', 'streak', 'time', 'weather',
    'social',   'seasonal','hidden','pace','quirky'
);
create type public.badge_tier_enum as enum ('bronze', 'silver', 'gold');

create table public.badges (
    id              uuid        primary key default gen_random_uuid(),
    code            text        unique not null check (code ~ '^[a-z0-9_]+$'),
    name_vi         text        not null,
    name_en         text        not null,
    description_vi  text        not null,
    description_en  text        not null,
    category        public.badge_category_enum not null,
    tier            public.badge_tier_enum     not null default 'bronze',
    icon_url        text,
    criteria_jsonb  jsonb       not null default '{}'::jsonb,
    xp_reward       integer     not null default 0 check (xp_reward >= 0),
    is_active       boolean     not null default true,
    created_at      timestamptz not null default now()
);

create index badges_category_idx on public.badges (category);
create index badges_tier_idx     on public.badges (tier);

comment on table public.badges is 'Static-ish catalog of achievable badges; criteria_jsonb is read by award engine.';

create table public.user_badges (
    user_id      uuid not null references public.profiles (id) on delete cascade,
    badge_id     uuid not null references public.badges   (id) on delete cascade,
    awarded_at   timestamptz not null default now(),
    activity_id  uuid references public.activities (id) on delete set null,
    primary key (user_id, badge_id)
);

create index user_badges_awarded_idx  on public.user_badges (user_id, awarded_at desc);
create index user_badges_activity_idx on public.user_badges (activity_id);

comment on table public.user_badges is 'Each row = one badge unlocked by one user.';

-- ---------------------------------------------------------------
-- Seed: 30 core badges.
-- ---------------------------------------------------------------
insert into public.badges (code, name_vi, name_en, description_vi, description_en, category, tier, criteria_jsonb, xp_reward) values
-- distance (6)
('first_km',         'Km dau tien',          'First Kilometer',     'Hoan thanh 1 km dau tien.',            'Complete your first 1 km.',           'distance','bronze','{"distance_m":1000}',                10),
('five_k_finisher',  'Hoan thanh 5K',        '5K Finisher',         'Hoan thanh quang duong 5 km.',         'Finish a 5K.',                        'distance','bronze','{"distance_m":5000}',                25),
('ten_k_finisher',   'Hoan thanh 10K',       '10K Finisher',        'Hoan thanh quang duong 10 km.',        'Finish a 10K.',                       'distance','silver','{"distance_m":10000}',               50),
('half_marathon',    'Ban marathon',         'Half Marathon',       'Hoan thanh 21.1 km.',                  'Finish a half marathon.',             'distance','gold',  '{"distance_m":21097}',               150),
('full_marathon',    'Marathon',             'Full Marathon',       'Hoan thanh 42.2 km.',                  'Finish a full marathon.',             'distance','gold',  '{"distance_m":42195}',               400),
('century_club',     'Cau lac bo 100 km',    'Century Club',        'Tich luy 100 km.',                     'Accumulate 100 km lifetime.',         'distance','silver','{"lifetime_distance_m":100000}',     100),
-- streak (4)
('streak_3',         'Chuoi 3 ngay',         '3-Day Streak',        '3 ngay lien tiep co hoat dong.',       '3 consecutive active days.',          'streak',  'bronze','{"streak_days":3}',                  20),
('streak_7',         'Chuoi 1 tuan',         '7-Day Streak',        '7 ngay lien tiep co hoat dong.',       '7 consecutive active days.',          'streak',  'silver','{"streak_days":7}',                  60),
('streak_30',        'Chuoi 30 ngay',        '30-Day Streak',       '30 ngay lien tiep co hoat dong.',      '30 consecutive active days.',         'streak',  'gold',  '{"streak_days":30}',                 250),
('streak_100',       'Chuoi 100 ngay',       '100-Day Streak',      '100 ngay lien tiep co hoat dong.',     '100 consecutive active days.',        'streak',  'gold',  '{"streak_days":100}',                800),
-- time (4)
('early_bird',       'Chim som',             'Early Bird',          'Chay xong truoc 6:00 sang.',           'Finish a run before 6 AM.',           'time',    'bronze','{"end_before":"06:00"}',             15),
('night_owl',        'Cu dem',               'Night Owl',           'Chay xong sau 22:00.',                 'Finish a run after 10 PM.',           'time',    'bronze','{"end_after":"22:00"}',              15),
('lunch_runner',     'Chay gio trua',        'Lunch Runner',        '5 buoi chay khoang 11:00-13:00.',      '5 runs between 11:00 and 13:00.',     'time',    'silver','{"window":"11-13","count":5}',       40),
('weekend_warrior',  'Chien binh cuoi tuan', 'Weekend Warrior',     '10 buoi chay vao cuoi tuan.',          '10 runs on weekends.',                'time',    'silver','{"weekend_runs":10}',                50),
-- weather (3)
('rain_runner',      'Chay duoi mua',        'Rain Runner',         'Chay khi troi mua.',                   'Run while it is raining.',            'weather', 'silver','{"weather":"rain"}',                 30),
('heatwave_hero',    'Anh hung nong',        'Heatwave Hero',       'Chay khi nhiet do >= 35 C.',           'Run when temperature >= 35 C.',       'weather', 'gold',  '{"temp_c_min":35}',                 100),
('cold_crusher',     'Diet ret',             'Cold Crusher',        'Chay khi nhiet do <= 10 C.',           'Run when temperature <= 10 C.',       'weather', 'gold',  '{"temp_c_max":10}',                 100),
-- social (3)
('first_follow',     'Theo doi dau tien',    'First Follow',        'Theo doi nguoi dung dau tien.',        'Follow your first user.',             'social',  'bronze','{"follows":1}',                      10),
('squad_of_five',    'Nhom 5 nguoi',         'Squad of Five',       'Co 5 nguoi theo doi.',                 'Reach 5 followers.',                  'social',  'silver','{"followers":5}',                    40),
('challenge_winner', 'Quan quan thach dau',  'Challenge Champion',  'Ve nhat mot thach dau.',               'Win a challenge.',                    'social',  'gold',  '{"challenge_rank":1}',              200),
-- seasonal (2)
('tet_run',          'Chay Tet',             'Lunar New Year Run',  'Chay trong dip Tet Nguyen Dan.',       'Run during Lunar New Year.',          'seasonal','silver','{"season":"tet"}',                   60),
('new_year_day',     'Chay nam moi',         'New Year Day Run',    'Chay vao ngay 1 thang 1.',             'Run on January 1.',                   'seasonal','silver','{"date":"01-01"}',                   60),
-- hidden (2)
('insomniac',        'Khong ngu',            'Insomniac',           'Chay khoang 2:00-4:00 sang.',          'Run between 2 AM and 4 AM.',          'hidden',  'gold',  '{"window":"02-04"}',                150),
('lucky_seven',      '7 km luc 7:07',        'Lucky Seven',         'Chay 7 km bat dau luc 7:07.',          'Run 7 km starting at 7:07.',          'hidden',  'gold',  '{"distance_m":7000,"start_time":"07:07"}', 150),
-- pace (3)
('sub_30_5k',        '5K duoi 30 phut',      'Sub-30 5K',           'Hoan thanh 5K duoi 30 phut.',          'Finish 5K under 30 minutes.',         'pace',    'silver','{"distance_m":5000,"max_duration_s":1800}',  60),
('sub_60_10k',       '10K duoi 60 phut',     'Sub-60 10K',          'Hoan thanh 10K duoi 60 phut.',         'Finish 10K under 60 minutes.',        'pace',    'gold',  '{"distance_m":10000,"max_duration_s":3600}', 120),
('negative_split',   'Tang toc nua sau',     'Negative Split',      'Nua sau nhanh hon nua dau.',           'Run a negative split.',               'pace',    'silver','{"negative_split":true}',            45),
-- quirky (3)
('round_trip',       'Khep vong',            'Round Trip',          'Bat dau va ket thuc cung mot diem.',   'Start and end at the same point.',    'quirky',  'bronze','{"loop":true}',                      15),
('shape_shifter',    'Ve hinh',              'Shape Shifter',       'Ve duoc mot hinh GPS nhan biet duoc.', 'Draw a recognizable GPS shape.',      'quirky',  'gold',  '{"shape_detected":true}',           120),
('elevation_2k',     'Leo 2000m',            '2000m Climb',         'Tich luy 2000 m leo doc.',             'Accumulate 2000 m of elevation gain.','quirky',  'gold',  '{"lifetime_elevation_m":2000}',     100);
