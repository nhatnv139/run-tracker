-- 20260520000300_activities.sql
-- Core fitness data: activities (run/walk/treadmill/hike), per-second points, per-km splits.

create type public.activity_type_enum   as enum ('run', 'walk', 'treadmill', 'hike');
create type public.activity_source_enum as enum ('app', 'apple_watch', 'garmin', 'strava', 'manual');

create table public.activities (
    id                   uuid        primary key default gen_random_uuid(),
    user_id              uuid        not null references public.profiles (id) on delete cascade,
    type                 public.activity_type_enum   not null,
    started_at           timestamptz not null,
    ended_at             timestamptz not null,
    duration_s           integer     not null check (duration_s >= 0),
    distance_m           integer     not null default 0 check (distance_m >= 0),
    calories             integer              check (calories >= 0),
    avg_pace_s_per_km    integer              check (avg_pace_s_per_km between 60 and 7200),
    avg_hr               smallint             check (avg_hr between 30 and 250),
    max_hr               smallint             check (max_hr between 30 and 250),
    elevation_gain_m     integer     not null default 0,
    elevation_loss_m     integer     not null default 0,
    polyline             text,
    start_point          geography(Point, 4326),
    end_point            geography(Point, 4326),
    is_indoor            boolean     not null default false,
    weather              jsonb,
    source               public.activity_source_enum not null default 'app',
    verified             boolean     not null default false,
    created_at           timestamptz not null default now(),
    updated_at           timestamptz not null default now(),
    constraint activities_time_window check (ended_at >= started_at)
);

create index activities_user_started_idx on public.activities (user_id, started_at desc);
create index activities_started_at_idx   on public.activities (started_at desc);
create index activities_type_idx         on public.activities (type);
create index activities_start_point_gix  on public.activities using gist (start_point);

comment on table public.activities is 'Completed workout sessions; one row per session.';

-- activity_points: high-resolution stream sampled during recording.
create table public.activity_points (
    activity_id  uuid        not null references public.activities (id) on delete cascade,
    sequence     integer     not null,
    ts           timestamptz not null,
    point        geography(Point, 4326) not null,
    elevation_m  double precision,
    speed_mps    double precision check (speed_mps >= 0),
    hr           smallint        check (hr between 30 and 250),
    cadence      smallint        check (cadence between 0 and 300),
    primary key (activity_id, sequence)
);

create index activity_points_point_gix on public.activity_points using gist (point);
create index activity_points_ts_idx    on public.activity_points (activity_id, ts);

comment on table public.activity_points is 'GPS / sensor samples for an activity.';

-- activity_splits: derived per-km summary.
create table public.activity_splits (
    activity_id      uuid    not null references public.activities (id) on delete cascade,
    km_index         integer not null check (km_index >= 1),
    duration_s       integer not null check (duration_s >= 0),
    pace_s_per_km    integer not null check (pace_s_per_km between 60 and 7200),
    hr_avg           smallint        check (hr_avg between 30 and 250),
    elevation_gain   integer not null default 0,
    primary key (activity_id, km_index)
);

comment on table public.activity_splits is 'Per-kilometer summary; computed when activity is finalized.';
