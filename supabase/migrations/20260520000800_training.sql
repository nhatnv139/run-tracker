-- 20260520000800_training.sql
-- Personalized training plans and per-day workouts.

create type public.race_distance_enum    as enum ('5k', '10k', 'half', 'full');
create type public.plan_source_enum      as enum ('template', 'ai_generated');
create type public.plan_status_enum      as enum ('active', 'paused', 'completed', 'abandoned');
create type public.workout_type_enum     as enum ('easy', 'long', 'tempo', 'interval', 'rest', 'cross');

create table public.training_plans (
    id                  uuid        primary key default gen_random_uuid(),
    user_id             uuid        not null references public.profiles (id) on delete cascade,
    race_distance       public.race_distance_enum not null,
    weeks               integer     not null check (weeks between 1 and 52),
    target_pace_s_per_km integer            check (target_pace_s_per_km between 120 and 1200),
    start_date          date        not null,
    end_date            date        not null,
    source              public.plan_source_enum not null default 'template',
    status              public.plan_status_enum not null default 'active',
    template_id         uuid,
    created_at          timestamptz not null default now(),
    updated_at          timestamptz not null default now(),
    constraint training_plans_date_range check (end_date >= start_date)
);

create index training_plans_user_status_idx on public.training_plans (user_id, status);
create index training_plans_user_start_idx  on public.training_plans (user_id, start_date desc);

comment on table public.training_plans is 'A user can have multiple plans; usually one active.';

create table public.training_workouts (
    id                   uuid        primary key default gen_random_uuid(),
    plan_id              uuid        not null references public.training_plans (id) on delete cascade,
    day_offset           integer     not null check (day_offset >= 0),
    workout_type         public.workout_type_enum not null,
    description_vi       text,
    description_en       text,
    target_distance_m    integer              check (target_distance_m   is null or target_distance_m   >= 0),
    target_duration_s    integer              check (target_duration_s   is null or target_duration_s   >= 0),
    target_pace_s_per_km integer              check (target_pace_s_per_km is null or target_pace_s_per_km between 120 and 1200),
    target_hr_zone       smallint             check (target_hr_zone between 1 and 5),
    completed            boolean     not null default false,
    activity_id          uuid        references public.activities (id) on delete set null,
    created_at           timestamptz not null default now(),
    updated_at           timestamptz not null default now(),
    unique (plan_id, day_offset)
);

create index training_workouts_plan_day_idx     on public.training_workouts (plan_id, day_offset);
create index training_workouts_activity_idx     on public.training_workouts (activity_id) where activity_id is not null;
create index training_workouts_uncompleted_idx  on public.training_workouts (plan_id) where completed = false;

comment on table public.training_workouts is 'One scheduled workout per (plan, day_offset).';
