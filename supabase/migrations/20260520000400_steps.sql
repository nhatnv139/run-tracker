-- 20260520000400_steps.sql
-- Daily step aggregates per user (from phone pedometer + activities).

create table public.daily_steps (
    user_id          uuid    not null references public.profiles (id) on delete cascade,
    date             date    not null,
    steps            integer not null default 0 check (steps >= 0),
    distance_m       integer not null default 0 check (distance_m >= 0),
    calories         integer not null default 0 check (calories >= 0),
    active_minutes   integer not null default 0 check (active_minutes >= 0),
    updated_at       timestamptz not null default now(),
    primary key (user_id, date)
);

create index daily_steps_user_date_idx on public.daily_steps (user_id, date desc);

comment on table public.daily_steps is 'One row per user per day; aggregated from device + activities.';
