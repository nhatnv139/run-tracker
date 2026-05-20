-- seed_template_plans.sql
-- Catalog of training plan templates available in content/training-plans/.
-- The actual workout JSON lives on disk; this metadata row points the
-- application at the file and exposes searchable fields.
--
-- Schema (created here additively):
--   plan_templates(id, code, name_vi, name_en, race_distance, weeks,
--                  sessions_per_week, level, file_path, description_vi,
--                  description_en, is_active, created_at)

create table if not exists public.plan_templates (
    id                uuid        primary key default gen_random_uuid(),
    code              text        not null unique,
    name_vi           text        not null,
    name_en           text        not null,
    race_distance     text        not null check (race_distance in ('5k', '10k', 'half', 'full', 'c25k', 'walking')),
    weeks             integer     not null check (weeks between 1 and 52),
    sessions_per_week integer     not null check (sessions_per_week between 1 and 14),
    level             public.level_enum not null,
    file_path         text        not null,
    description_vi    text,
    description_en    text,
    is_active         boolean     not null default true,
    created_at        timestamptz not null default now()
);

create index if not exists plan_templates_race_idx  on public.plan_templates (race_distance);
create index if not exists plan_templates_level_idx on public.plan_templates (level);

alter table public.plan_templates enable row level security;

drop policy if exists plan_templates_select_all on public.plan_templates;
create policy plan_templates_select_all on public.plan_templates
    for select to anon, authenticated using (is_active = true);

drop policy if exists plan_templates_service_write on public.plan_templates;
create policy plan_templates_service_write on public.plan_templates
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- Rows
-- One per file in content/training-plans/.
-- ---------------------------------------------------------------
insert into public.plan_templates
    (code, name_vi, name_en, race_distance, weeks, sessions_per_week, level, file_path,
     description_vi, description_en)
values
    ('c25k-9weeks',
     'Couch to 5K - 9 tuan',
     'Couch to 5K - 9 weeks',
     'c25k', 9, 3, 'beginner',
     'content/training-plans/c25k-9weeks.json',
     'Lich tap di kem chay xen ke giup nguoi moi hoan thanh 5km trong 9 tuan.',
     'Walk-run mix for absolute beginners to finish 5 km in 9 weeks.'),

    ('5k-improver-8weeks',
     '5K duoi 30 phut - 8 tuan',
     '5K Sub-30 Improver - 8 Weeks',
     '5k', 8, 4, 'intermediate',
     'content/training-plans/5k-improver-8weeks.json',
     'Cai thien thanh tich 5K xuong duoi 30 phut trong 8 tuan.',
     'Drop your 5K time below 30 minutes in 8 weeks.'),

    ('10k-12weeks',
     '10K - 12 tuan',
     '10K - 12 weeks',
     '10k', 12, 4, 'intermediate',
     'content/training-plans/10k-12weeks.json',
     'Chuong trinh 12 tuan chuan bi cho cu ly 10km.',
     '12-week build for a 10 km goal race.'),

    ('half-marathon-16weeks',
     'Ban marathon - 16 tuan',
     'Half Marathon - 16 weeks',
     'half', 16, 4, 'advanced',
     'content/training-plans/half-marathon-16weeks.json',
     'Lich tap 16 tuan cho cu ly 21.1 km, gom long run va tempo.',
     '16-week plan for a 21.1 km half marathon with tempo and long runs.'),

    ('full-marathon-18weeks',
     'Marathon - 18 tuan',
     'Full Marathon - 18 weeks',
     'full', 18, 5, 'advanced',
     'content/training-plans/full-marathon-18weeks.json',
     '18 tuan chuan bi marathon 42.195 km, peak week 60+ km.',
     '18-week marathon program for 42.195 km; peak weeks 60+ km.'),

    ('walking-3-tieres',
     'Di bo - 3 muc',
     'Walking - 3 tiers',
     'walking', 12, 5, 'beginner',
     'content/training-plans/walking-3-tieres.json',
     'Chuong trinh di bo 3 cap do cho nguoi muon bat dau van dong.',
     'Three-tier walking program for users starting an active routine.')
on conflict (code) do nothing;
