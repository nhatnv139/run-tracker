-- 20260520001300_functions.sql
-- RPC functions exposed to the app via supabase.rpc(...).
--   1. award_coins_for_activity(activity_id) -> integer
--   2. recalc_streak(user_id)                -> table(current_days, longest_days)
--   3. award_badges_for_user(user_id, activity_id) -> setof text  (codes of newly awarded badges)

-- ---------------------------------------------------------------
-- 1. award_coins_for_activity
-- Earn rate: 10 RunCoin per full km, rounded down. Skipped if already credited
-- (we de-dup via metadata.activity_id).
-- ---------------------------------------------------------------
create or replace function public.award_coins_for_activity(p_activity_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
    v_user_id  uuid;
    v_distance integer;
    v_amount   integer;
    v_balance  integer;
begin
    select user_id, distance_m
      into v_user_id, v_distance
      from public.activities
     where id = p_activity_id;

    if v_user_id is null then
        raise exception 'Activity % not found', p_activity_id;
    end if;

    -- Idempotency: skip if a km_earn tx for this activity already exists.
    if exists (
        select 1 from public.coin_transactions
        where user_id = v_user_id
          and reason  = 'km_earn'
          and metadata ->> 'activity_id' = p_activity_id::text
    ) then
        return 0;
    end if;

    v_amount := floor(v_distance / 1000.0)::integer * 10;
    if v_amount <= 0 then
        return 0;
    end if;

    -- Upsert the cached balance.
    insert into public.run_coins (user_id, balance, lifetime_earned)
    values (v_user_id, v_amount, v_amount)
    on conflict (user_id) do update set
        balance         = public.run_coins.balance         + excluded.balance,
        lifetime_earned = public.run_coins.lifetime_earned + excluded.lifetime_earned,
        updated_at      = now()
    returning balance into v_balance;

    insert into public.coin_transactions (user_id, amount, reason, metadata, balance_after)
    values (v_user_id, v_amount, 'km_earn',
            jsonb_build_object('activity_id', p_activity_id, 'distance_m', v_distance),
            v_balance);

    return v_amount;
end;
$$;

comment on function public.award_coins_for_activity(uuid)
    is '10 RunCoin per full km; idempotent per activity.';

-- ---------------------------------------------------------------
-- 2. recalc_streak
-- Walks the user's distinct activity dates backwards from today and computes
-- the current contiguous streak (allowing a 1-day gap if freeze_count > 0
-- and freeze_used_this_week < 2).
-- ---------------------------------------------------------------
create or replace function public.recalc_streak(p_user_id uuid)
returns table (current_days integer, longest_days integer)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_today        date := current_date;
    v_current      integer := 0;
    v_longest      integer := 0;
    v_run          integer := 0;
    v_prev_date    date;
    r              record;
begin
    -- Longest streak via window function on all distinct activity dates.
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
        select count(*) as len
          from grp
         group by grp_key
    loop
        if r.len > v_longest then v_longest := r.len; end if;
    end loop;

    -- Current streak: walk back from today (allow today to be missing).
    v_prev_date := v_today;
    for r in
        select distinct (started_at at time zone 'UTC')::date as adate
          from public.activities
         where user_id = p_user_id
           and (started_at at time zone 'UTC')::date <= v_today
         order by adate desc
    loop
        if v_run = 0 and r.adate >= v_today - 1 then
            v_run := 1;
            v_prev_date := r.adate;
        elsif r.adate = v_prev_date - 1 then
            v_run := v_run + 1;
            v_prev_date := r.adate;
        else
            exit;
        end if;
    end loop;

    v_current := v_run;

    insert into public.streaks (user_id, current_days, longest_days, last_activity_date, updated_at)
    values (p_user_id, v_current, v_longest, v_prev_date, now())
    on conflict (user_id) do update set
        current_days       = excluded.current_days,
        longest_days       = greatest(public.streaks.longest_days, excluded.longest_days),
        last_activity_date = excluded.last_activity_date,
        updated_at         = now();

    return query select v_current, greatest(v_longest, v_current);
end;
$$;

comment on function public.recalc_streak(uuid)
    is 'Recomputes current_days and longest_days from activities; writes streaks row.';

-- ---------------------------------------------------------------
-- 3. award_badges_for_user
-- Evaluates a small set of simple criteria in criteria_jsonb and inserts
-- user_badges rows for badges newly satisfied. Returns codes of new awards.
-- ---------------------------------------------------------------
create or replace function public.award_badges_for_user(p_user_id uuid, p_activity_id uuid default null)
returns setof text
language plpgsql
security definer
set search_path = public
as $$
declare
    b           record;
    a           record;
    v_lifetime  bigint;
    v_streak    integer;
    v_followers integer;
    v_distance  integer;
    v_elev      bigint;
    v_awarded   text;
begin
    -- Pull headline aggregates once.
    select coalesce(sum(distance_m), 0),
           coalesce(sum(elevation_gain_m), 0)
      into v_lifetime, v_elev
      from public.activities where user_id = p_user_id;

    select coalesce(current_days, 0) into v_streak
      from public.streaks where user_id = p_user_id;
    if v_streak is null then v_streak := 0; end if;

    select count(*) into v_followers
      from public.follows where followee_id = p_user_id;

    if p_activity_id is not null then
        select distance_m, elevation_gain_m, duration_s, started_at, ended_at
          into a
          from public.activities where id = p_activity_id;
    end if;

    for b in select * from public.badges where is_active = true loop
        -- Skip if already owned.
        if exists (select 1 from public.user_badges
                    where user_id = p_user_id and badge_id = b.id) then
            continue;
        end if;

        v_awarded := null;

        -- distance: single-activity threshold
        if (b.criteria_jsonb ? 'distance_m') and a is not null then
            v_distance := (b.criteria_jsonb ->> 'distance_m')::integer;
            if a.distance_m >= v_distance
               and not (b.criteria_jsonb ? 'max_duration_s'
                        and a.duration_s > (b.criteria_jsonb ->> 'max_duration_s')::integer)
            then
                v_awarded := b.code;
            end if;
        end if;

        -- lifetime distance
        if v_awarded is null and (b.criteria_jsonb ? 'lifetime_distance_m') then
            if v_lifetime >= (b.criteria_jsonb ->> 'lifetime_distance_m')::bigint then
                v_awarded := b.code;
            end if;
        end if;

        -- streak
        if v_awarded is null and (b.criteria_jsonb ? 'streak_days') then
            if v_streak >= (b.criteria_jsonb ->> 'streak_days')::integer then
                v_awarded := b.code;
            end if;
        end if;

        -- followers
        if v_awarded is null and (b.criteria_jsonb ? 'followers') then
            if v_followers >= (b.criteria_jsonb ->> 'followers')::integer then
                v_awarded := b.code;
            end if;
        end if;

        -- lifetime elevation
        if v_awarded is null and (b.criteria_jsonb ? 'lifetime_elevation_m') then
            if v_elev >= (b.criteria_jsonb ->> 'lifetime_elevation_m')::bigint then
                v_awarded := b.code;
            end if;
        end if;

        if v_awarded is not null then
            insert into public.user_badges (user_id, badge_id, activity_id)
            values (p_user_id, b.id, p_activity_id)
            on conflict do nothing;

            -- XP reward as bonus RunCoins (optional pattern).
            if b.xp_reward > 0 then
                insert into public.run_coins (user_id, balance, lifetime_earned)
                values (p_user_id, b.xp_reward, b.xp_reward)
                on conflict (user_id) do update set
                    balance         = public.run_coins.balance         + excluded.balance,
                    lifetime_earned = public.run_coins.lifetime_earned + excluded.lifetime_earned,
                    updated_at      = now();
                insert into public.coin_transactions (user_id, amount, reason, metadata, balance_after)
                select p_user_id, b.xp_reward, 'badge_reward',
                       jsonb_build_object('badge_code', b.code),
                       balance
                  from public.run_coins where user_id = p_user_id;
            end if;

            return next v_awarded;
        end if;
    end loop;
end;
$$;

comment on function public.award_badges_for_user(uuid, uuid)
    is 'Evaluates simple criteria_jsonb rules and grants any newly unlocked badges.';

-- Grant execute on the RPC functions to authenticated users.
grant execute on function public.award_coins_for_activity(uuid) to authenticated;
grant execute on function public.recalc_streak(uuid)            to authenticated;
grant execute on function public.award_badges_for_user(uuid, uuid) to authenticated;
