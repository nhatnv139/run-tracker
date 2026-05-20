-- 20260520001200_triggers.sql
-- Generic updated_at trigger + daily_steps roll-up from activities.

-- ---------------------------------------------------------------
-- Generic updated_at trigger function
-- ---------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at := now();
    return new;
end;
$$;

-- Attach to every table that has updated_at.
create trigger trg_profiles_updated_at
    before update on public.profiles
    for each row execute function public.set_updated_at();

create trigger trg_activities_updated_at
    before update on public.activities
    for each row execute function public.set_updated_at();

create trigger trg_daily_steps_updated_at
    before update on public.daily_steps
    for each row execute function public.set_updated_at();

create trigger trg_streaks_updated_at
    before update on public.streaks
    for each row execute function public.set_updated_at();

create trigger trg_run_coins_updated_at
    before update on public.run_coins
    for each row execute function public.set_updated_at();

create trigger trg_challenges_updated_at
    before update on public.challenges
    for each row execute function public.set_updated_at();

create trigger trg_training_plans_updated_at
    before update on public.training_plans
    for each row execute function public.set_updated_at();

create trigger trg_training_workouts_updated_at
    before update on public.training_workouts
    for each row execute function public.set_updated_at();

create trigger trg_devices_updated_at
    before update on public.devices
    for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------
-- daily_steps roll-up: when an activity is inserted/updated, add its
-- distance/calories/active minutes to the matching daily_steps row.
-- Note: this is "additive only"; deletions are handled by the inverse trigger.
-- ---------------------------------------------------------------
create or replace function public.apply_activity_to_daily_steps()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_date    date    := (new.started_at at time zone 'UTC')::date;
    v_minutes integer := greatest(coalesce(new.duration_s, 0) / 60, 0);
    v_steps   integer := round(coalesce(new.distance_m, 0) / 0.78)::integer; -- ~0.78 m / step
begin
    insert into public.daily_steps (user_id, date, steps, distance_m, calories, active_minutes)
    values (new.user_id, v_date,
            v_steps,
            coalesce(new.distance_m, 0),
            coalesce(new.calories, 0),
            v_minutes)
    on conflict (user_id, date) do update set
        steps          = public.daily_steps.steps          + excluded.steps,
        distance_m     = public.daily_steps.distance_m     + excluded.distance_m,
        calories       = public.daily_steps.calories       + excluded.calories,
        active_minutes = public.daily_steps.active_minutes + excluded.active_minutes,
        updated_at     = now();
    return new;
end;
$$;

create trigger trg_activity_insert_daily_steps
    after insert on public.activities
    for each row execute function public.apply_activity_to_daily_steps();

-- Inverse: reverse the contribution when an activity is deleted.
create or replace function public.revert_activity_from_daily_steps()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_date    date    := (old.started_at at time zone 'UTC')::date;
    v_minutes integer := greatest(coalesce(old.duration_s, 0) / 60, 0);
    v_steps   integer := round(coalesce(old.distance_m, 0) / 0.78)::integer;
begin
    update public.daily_steps
       set steps          = greatest(steps          - v_steps,                       0),
           distance_m     = greatest(distance_m     - coalesce(old.distance_m, 0),   0),
           calories       = greatest(calories       - coalesce(old.calories,   0),   0),
           active_minutes = greatest(active_minutes - v_minutes,                     0),
           updated_at     = now()
     where user_id = old.user_id and date = v_date;
    return old;
end;
$$;

create trigger trg_activity_delete_daily_steps
    after delete on public.activities
    for each row execute function public.revert_activity_from_daily_steps();
