-- 20260521000800_pr_tracking.sql
-- Personal records (PRs) per user. Eight tracked record types.
-- Records are upserted via a trigger after_insert on activities:
--   * fastest_1k / 5k / 10k / half / full: best duration_s if activity
--     distance >= the threshold and (no current PR OR new < current).
--   * longest_run: largest distance_m.
--   * biggest_elevation: largest elevation_gain_m.
--   * longest_streak: snapshot of streaks.longest_days (recorded by the
--     application after recalc_streak, not by this trigger). The PR row's
--     activity_id is nullable for that case.

create type public.pr_type_enum as enum (
    'fastest_1k',
    'fastest_5k',
    'fastest_10k',
    'fastest_half',
    'fastest_full',
    'longest_run',
    'longest_streak',
    'biggest_elevation'
);

create table public.personal_records (
    user_id      uuid        not null references public.profiles (id) on delete cascade,
    record_type  public.pr_type_enum not null,
    value        numeric     not null,            -- duration_s for fastest_*, meters for longest_run / elevation, days for streak
    activity_id  uuid        references public.activities (id) on delete set null,
    achieved_at  timestamptz not null default now(),
    primary key (user_id, record_type)
);

create index personal_records_user_idx     on public.personal_records (user_id);
create index personal_records_activity_idx on public.personal_records (activity_id);

comment on table public.personal_records is
    'One row per (user, record_type); upserted by trigger when a new activity beats the current value.';

-- ---------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------
alter table public.personal_records enable row level security;

create policy personal_records_select on public.personal_records
    for select using (
        auth.uid() = user_id
        or public.is_profile_public(user_id)
    );

create policy personal_records_service_write on public.personal_records
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- Trigger: after_insert on activities -> upsert PRs.
-- Lower-is-better for fastest_*, higher-is-better for longest_* / elevation.
-- ---------------------------------------------------------------
create or replace function public.upsert_personal_records()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_dist     integer := coalesce(new.distance_m, 0);
    v_dur      integer := coalesce(new.duration_s, 0);
    v_elev     integer := coalesce(new.elevation_gain_m, 0);
    v_user     uuid    := new.user_id;
    v_when     timestamptz := coalesce(new.ended_at, new.started_at, now());

    -- Threshold distances in meters.
    c_1k       constant integer := 1000;
    c_5k       constant integer := 5000;
    c_10k      constant integer := 10000;
    c_half     constant integer := 21097;
    c_full     constant integer := 42195;

    -- Pro-rated duration value computed per threshold.
    v_value    numeric;
begin
    -- For each fastest_* threshold: register a PR if v_dist >= threshold.
    -- We pro-rate the duration by avg_pace_s_per_km when present,
    -- otherwise we use total duration * (threshold / actual_distance).
    if v_dist >= c_1k then
        v_value := case
            when new.avg_pace_s_per_km is not null
                 then new.avg_pace_s_per_km::numeric * (c_1k / 1000.0)
            else v_dur::numeric * (c_1k::numeric / v_dist)
        end;
        insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
        values (v_user, 'fastest_1k', v_value, new.id, v_when)
        on conflict (user_id, record_type) do update
            set value       = excluded.value,
                activity_id = excluded.activity_id,
                achieved_at = excluded.achieved_at
            where excluded.value < public.personal_records.value;
    end if;

    if v_dist >= c_5k then
        v_value := case
            when new.avg_pace_s_per_km is not null
                 then new.avg_pace_s_per_km::numeric * (c_5k / 1000.0)
            else v_dur::numeric * (c_5k::numeric / v_dist)
        end;
        insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
        values (v_user, 'fastest_5k', v_value, new.id, v_when)
        on conflict (user_id, record_type) do update
            set value       = excluded.value,
                activity_id = excluded.activity_id,
                achieved_at = excluded.achieved_at
            where excluded.value < public.personal_records.value;
    end if;

    if v_dist >= c_10k then
        v_value := case
            when new.avg_pace_s_per_km is not null
                 then new.avg_pace_s_per_km::numeric * (c_10k / 1000.0)
            else v_dur::numeric * (c_10k::numeric / v_dist)
        end;
        insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
        values (v_user, 'fastest_10k', v_value, new.id, v_when)
        on conflict (user_id, record_type) do update
            set value       = excluded.value,
                activity_id = excluded.activity_id,
                achieved_at = excluded.achieved_at
            where excluded.value < public.personal_records.value;
    end if;

    if v_dist >= c_half then
        v_value := case
            when new.avg_pace_s_per_km is not null
                 then new.avg_pace_s_per_km::numeric * (c_half / 1000.0)
            else v_dur::numeric * (c_half::numeric / v_dist)
        end;
        insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
        values (v_user, 'fastest_half', v_value, new.id, v_when)
        on conflict (user_id, record_type) do update
            set value       = excluded.value,
                activity_id = excluded.activity_id,
                achieved_at = excluded.achieved_at
            where excluded.value < public.personal_records.value;
    end if;

    if v_dist >= c_full then
        v_value := case
            when new.avg_pace_s_per_km is not null
                 then new.avg_pace_s_per_km::numeric * (c_full / 1000.0)
            else v_dur::numeric * (c_full::numeric / v_dist)
        end;
        insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
        values (v_user, 'fastest_full', v_value, new.id, v_when)
        on conflict (user_id, record_type) do update
            set value       = excluded.value,
                activity_id = excluded.activity_id,
                achieved_at = excluded.achieved_at
            where excluded.value < public.personal_records.value;
    end if;

    -- Longest single run.
    insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
    values (v_user, 'longest_run', v_dist, new.id, v_when)
    on conflict (user_id, record_type) do update
        set value       = excluded.value,
            activity_id = excluded.activity_id,
            achieved_at = excluded.achieved_at
        where excluded.value > public.personal_records.value;

    -- Biggest elevation gain.
    insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
    values (v_user, 'biggest_elevation', v_elev, new.id, v_when)
    on conflict (user_id, record_type) do update
        set value       = excluded.value,
            activity_id = excluded.activity_id,
            achieved_at = excluded.achieved_at
        where excluded.value > public.personal_records.value;

    return new;
end;
$$;

create trigger trg_activities_upsert_prs
    after insert on public.activities
    for each row execute function public.upsert_personal_records();

-- ---------------------------------------------------------------
-- Trigger: streak.longest_days update -> upsert longest_streak PR.
-- ---------------------------------------------------------------
create or replace function public.upsert_longest_streak_pr()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if new.longest_days is null or new.longest_days = 0 then
        return new;
    end if;

    insert into public.personal_records (user_id, record_type, value, activity_id, achieved_at)
    values (new.user_id, 'longest_streak', new.longest_days, null, now())
    on conflict (user_id, record_type) do update
        set value       = excluded.value,
            achieved_at = excluded.achieved_at
        where excluded.value > public.personal_records.value;
    return new;
end;
$$;

create trigger trg_streaks_upsert_longest_streak_pr
    after insert or update on public.streaks
    for each row execute function public.upsert_longest_streak_pr();

comment on function public.upsert_personal_records()
    is 'Upserts fastest_*, longest_run, biggest_elevation PRs from a new activity.';
comment on function public.upsert_longest_streak_pr()
    is 'Upserts longest_streak PR from streaks.longest_days.';
