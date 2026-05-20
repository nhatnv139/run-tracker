-- pgtap_recalc_streak.sql
-- Sequence date inputs, assert correct streak.
-- Run: psql -f supabase/tests/pgtap_recalc_streak.sql
-- Requires the pgtap extension.

begin;

create extension if not exists pgtap;

select plan(8);

-- Test fixture user (uses a deterministic uuid; reset between runs).
do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000A01';
begin
    -- Create auth.users surrogate (since auth.users is the FK target).
    insert into auth.users (id, instance_id, aud, role, email, encrypted_password,
                            raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
    values (v_user, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
            'streaktest@example.com', '', '{}'::jsonb, '{}'::jsonb, now(), now())
    on conflict (id) do nothing;

    insert into public.profiles (id, username, display_name)
    values (v_user, 'streak_test_u', 'Streak Test User')
    on conflict (id) do nothing;

    delete from public.activities where user_id = v_user;
    delete from public.streaks    where user_id = v_user;

    -- Seed 5 consecutive days of activities ending today.
    insert into public.activities (user_id, type, started_at, ended_at, duration_s, distance_m, verified, source)
    select v_user, 'run',
           (current_date - i)::timestamptz + interval '6 hours',
           (current_date - i)::timestamptz + interval '7 hours',
           3600, 5000, true, 'app'
      from generate_series(0, 4) as i;
end$$;

-- 1. Function exists and returns jsonb.
select has_function('public', 'recalc_streak', array['uuid']::name[]);
select function_returns('public', 'recalc_streak', array['uuid']::name[], 'jsonb');

-- 2. Compute streak.
select is(
    (public.recalc_streak('00000000-0000-0000-0000-000000000A01') ->> 'current_days')::int,
    5,
    'Five consecutive days of activity = current_days = 5'
);

select is(
    (select current_days from public.streaks where user_id = '00000000-0000-0000-0000-000000000A01'),
    5,
    'streaks.current_days persisted'
);

select cmp_ok(
    (public.recalc_streak('00000000-0000-0000-0000-000000000A01') ->> 'longest_days')::int,
    '>=', 5,
    'longest_days >= 5'
);

-- 3. Gap with freeze: delete yesterday's activity, give the user 2 freezes,
--    expect streak to stay alive at 4 (today + 3 more) using one freeze.
do $$
begin
    delete from public.activities
     where user_id = '00000000-0000-0000-0000-000000000A01'
       and started_at::date = current_date - 1;

    update public.streaks
       set freeze_count          = 2,
           freeze_used_this_week = 0,
           week_resets_at        = now() + interval '7 days'
     where user_id = '00000000-0000-0000-0000-000000000A01';
end$$;

select cmp_ok(
    (public.recalc_streak('00000000-0000-0000-0000-000000000A01') ->> 'current_days')::int,
    '>=', 4,
    'Streak with a single-day gap survives via freeze (current_days >= 4)'
);

-- 4. Broke today: no freezes, gap of 2 days from today (delete today AND yesterday).
do $$
begin
    delete from public.activities
     where user_id = '00000000-0000-0000-0000-000000000A01'
       and started_at::date in (current_date, current_date - 1);

    update public.streaks
       set freeze_count          = 0,
           freeze_used_this_week = 0,
           week_resets_at        = now() + interval '7 days'
     where user_id = '00000000-0000-0000-0000-000000000A01';
end$$;

select is(
    (public.recalc_streak('00000000-0000-0000-0000-000000000A01') ->> 'broke_today')::boolean,
    true,
    'broke_today flag = true when today + yesterday missing and no freezes'
);

-- 5. broke_today resets current_days to 0.
select is(
    (public.recalc_streak('00000000-0000-0000-0000-000000000A01') ->> 'current_days')::int,
    0,
    'current_days = 0 when streak is broken with no freezes'
);

-- Cleanup
do $$
begin
    delete from public.activities where user_id = '00000000-0000-0000-0000-000000000A01';
    delete from public.streaks    where user_id = '00000000-0000-0000-0000-000000000A01';
    delete from public.profiles   where id      = '00000000-0000-0000-0000-000000000A01';
    delete from auth.users        where id      = '00000000-0000-0000-0000-000000000A01';
end$$;

select * from finish();
rollback;
