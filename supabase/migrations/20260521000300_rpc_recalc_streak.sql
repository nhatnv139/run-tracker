-- 20260521000300_rpc_recalc_streak.sql
-- Re-implementation of recalc_streak with full RunVie business logic:
--   * Returns jsonb (replaces the SETOF-table signature from the bootstrap batch).
--   * Walks distinct activity dates of the last 365 days back from today.
--   * +1 to the streak per consecutive day; if today/yesterday is missing
--     and the user has an unused weekly freeze, consume one freeze and keep
--     the streak; otherwise break.
--   * Weekly freeze: 2 grants per ISO week (Mon 00:00 local UTC).
--     If `week_resets_at` has passed, reset freeze_used_this_week and grant
--     2 fresh tokens (freeze_count = 2).
--   * Updates streaks.current_days, longest_days, last_activity_date,
--     freeze_used_this_week, freeze_count, week_resets_at, updated_at.
--   * Idempotent and safe to call multiple times per day.
--
-- The earlier bootstrap migration (20260520001300_functions.sql) created
-- recalc_streak with `RETURNS TABLE (...)`. PostgreSQL does not allow
-- CREATE OR REPLACE to change the return type, so we DROP first.

drop function if exists public.recalc_streak(uuid);

create or replace function public.recalc_streak(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_today           date := (now() at time zone 'UTC')::date;
    v_yesterday       date := v_today - 1;
    v_cur             integer := 0;
    v_longest_total   integer := 0;
    v_longest_run     integer := 0;
    v_walker          date;
    v_active_today    boolean := false;
    v_broke_today     boolean := false;
    v_freeze_count    integer := 0;
    v_freeze_used     integer := 0;
    v_week_resets_at  timestamptz;
    v_freeze_weekly   constant integer := 2;
    v_last_active     date;
    r                 record;
    v_active_dates    date[];
begin
    -- Pull the current streaks row (or assume defaults if none).
    select coalesce(freeze_count, 0),
           coalesce(freeze_used_this_week, 0),
           week_resets_at,
           last_activity_date
      into v_freeze_count, v_freeze_used, v_week_resets_at, v_last_active
      from public.streaks where user_id = p_user_id;

    if v_week_resets_at is null then
        v_week_resets_at := date_trunc('week', now()) + interval '7 days';
    end if;

    -- Weekly reset: if the reset moment has passed, refill freezes.
    if now() >= v_week_resets_at then
        v_freeze_used    := 0;
        v_freeze_count   := v_freeze_weekly;
        v_week_resets_at := date_trunc('week', now()) + interval '7 days';
    end if;

    -- Collect distinct activity dates from the last 365 days into an array.
    select coalesce(array_agg(d order by d desc), '{}'::date[])
      into v_active_dates
      from (
          select distinct (started_at at time zone 'UTC')::date as d
            from public.activities
           where user_id = p_user_id
             and started_at >= (now() at time zone 'UTC') - interval '365 days'
             and (started_at at time zone 'UTC')::date <= v_today
      ) s;

    v_active_today := v_today = any(v_active_dates);

    -- Compute longest streak (all-time within window) via group-by-gap trick.
    for r in
        with d as (
            select distinct (started_at at time zone 'UTC')::date as adate
              from public.activities
             where user_id = p_user_id
        ),
        grp as (
            select adate,
                   adate - (row_number() over (order by adate))::int as grp_key
              from d
        )
        select count(*)::int as len from grp group by grp_key
    loop
        if r.len > v_longest_total then v_longest_total := r.len; end if;
    end loop;

    -- Walk current streak back from today.
    -- Rule: if today is active, count it; else if yesterday is active, the
    -- streak is still considered "alive" (today not yet done) and we start
    -- counting from yesterday; else if user has a freeze available, consume
    -- one to skip today, then continue from yesterday; else broke_today=true.
    if v_active_today then
        v_walker := v_today;
        v_cur := 0;
    elsif v_yesterday = any(v_active_dates) then
        v_walker := v_yesterday;
        v_cur := 0;
    elsif v_freeze_count > v_freeze_used then
        -- consume freeze for today
        v_freeze_used := v_freeze_used + 1;
        v_walker := v_yesterday;
        v_cur := 0;
    else
        v_broke_today := true;
        v_walker := null;
        v_cur := 0;
    end if;

    -- From v_walker, walk back day-by-day.
    while v_walker is not null loop
        if v_walker = any(v_active_dates) then
            v_cur := v_cur + 1;
            v_walker := v_walker - 1;
        else
            -- Missing day; try to consume a freeze to bridge the gap.
            if v_freeze_count > v_freeze_used then
                v_freeze_used := v_freeze_used + 1;
                v_walker := v_walker - 1;
            else
                exit;
            end if;
        end if;
        -- Hard stop to avoid runaway loops; 365 days is plenty.
        if v_cur > 365 then exit; end if;
    end loop;

    v_longest_run := greatest(v_longest_total, v_cur);

    -- Determine last_activity_date for storage.
    if array_length(v_active_dates, 1) is not null then
        v_last_active := v_active_dates[1];
    end if;

    -- Persist the streak row.
    insert into public.streaks (
        user_id, current_days, longest_days, last_activity_date,
        freeze_count, freeze_used_this_week, week_resets_at, updated_at
    ) values (
        p_user_id, v_cur, v_longest_run, v_last_active,
        v_freeze_count, v_freeze_used, v_week_resets_at, now()
    )
    on conflict (user_id) do update set
        current_days          = excluded.current_days,
        longest_days          = greatest(public.streaks.longest_days, excluded.longest_days),
        last_activity_date    = excluded.last_activity_date,
        freeze_count          = excluded.freeze_count,
        freeze_used_this_week = excluded.freeze_used_this_week,
        week_resets_at        = excluded.week_resets_at,
        updated_at            = now();

    return jsonb_build_object(
        'current_days',     v_cur,
        'longest_days',     v_longest_run,
        'freeze_remaining', greatest(v_freeze_count - v_freeze_used, 0),
        'broke_today',      v_broke_today,
        'last_activity_date', v_last_active
    );
end;
$$;

comment on function public.recalc_streak(uuid)
    is 'Recomputes current and longest streak for a user. Handles weekly freeze tokens (2/week), auto-resets at week boundary, returns jsonb breakdown.';

grant execute on function public.recalc_streak(uuid) to authenticated;
