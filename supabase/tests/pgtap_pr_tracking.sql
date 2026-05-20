-- pgtap_pr_tracking.sql
-- Insert activities with increasing speed; assert PR upserted.

begin;

create extension if not exists pgtap;

select plan(7);

do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000B01';
begin
    insert into auth.users (id, instance_id, aud, role, email, encrypted_password,
                            raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
    values (v_user, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
            'prtest@example.com', '', '{}'::jsonb, '{}'::jsonb, now(), now())
    on conflict (id) do nothing;
    insert into public.profiles (id, username, display_name)
    values (v_user, 'pr_test_u', 'PR Test User')
    on conflict (id) do nothing;

    delete from public.activities       where user_id = v_user;
    delete from public.personal_records where user_id = v_user;
end$$;

-- 1. Table + function exist.
select has_table('public', 'personal_records');
select has_function('public', 'upsert_personal_records');

-- 2. First 5K at 30:00 -> PR fastest_5k value ~1800.
do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000B01';
begin
    insert into public.activities (user_id, type, started_at, ended_at, duration_s,
                                   distance_m, avg_pace_s_per_km, source)
    values (v_user, 'run',
            now() - interval '2 days', now() - interval '2 days' + interval '30 minutes',
            1800, 5000, 360, 'app');
end$$;

select cmp_ok(
    (select value::int from public.personal_records
      where user_id = '00000000-0000-0000-0000-000000000B01'
        and record_type = 'fastest_5k'),
    '<=', 1900,
    'fastest_5k PR set near 1800 seconds after a 30:00 5K'
);

-- 3. Second 5K at 25:00 -> PR should improve (beat previous).
do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000B01';
begin
    insert into public.activities (user_id, type, started_at, ended_at, duration_s,
                                   distance_m, avg_pace_s_per_km, source)
    values (v_user, 'run',
            now() - interval '1 days', now() - interval '1 days' + interval '25 minutes',
            1500, 5000, 300, 'app');
end$$;

select cmp_ok(
    (select value::int from public.personal_records
      where user_id = '00000000-0000-0000-0000-000000000B01'
        and record_type = 'fastest_5k'),
    '<=', 1600,
    'fastest_5k PR beaten by 25:00 attempt (<=1600s)'
);

-- 4. Slower 5K at 35:00 -> PR should NOT regress.
-- Capture current PR value, do a slower run, then compare.
create temporary table _pr_before as
    select value::int as v from public.personal_records
     where user_id = '00000000-0000-0000-0000-000000000B01'
       and record_type = 'fastest_5k';

do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000B01';
begin
    insert into public.activities (user_id, type, started_at, ended_at, duration_s,
                                   distance_m, avg_pace_s_per_km, source)
    values (v_user, 'run',
            now() - interval '6 hours', now() - interval '6 hours' + interval '35 minutes',
            2100, 5000, 420, 'app');
end$$;

select ok(
    (select value::int from public.personal_records
      where user_id = '00000000-0000-0000-0000-000000000B01'
        and record_type = 'fastest_5k')
    <= (select v from _pr_before),
    'fastest_5k PR did not regress after a slower attempt'
);

-- 5. longest_run PR is the largest distance.
do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000B01';
begin
    insert into public.activities (user_id, type, started_at, ended_at, duration_s,
                                   distance_m, avg_pace_s_per_km, source)
    values (v_user, 'run',
            now() - interval '3 hours', now() - interval '1 hours',
            7200, 12000, 600, 'app');
end$$;

select is(
    (select value::int from public.personal_records
      where user_id = '00000000-0000-0000-0000-000000000B01'
        and record_type = 'longest_run'),
    12000,
    'longest_run PR = 12 km after that activity'
);

-- 6. biggest_elevation PR
do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000B01';
begin
    insert into public.activities (user_id, type, started_at, ended_at, duration_s,
                                   distance_m, elevation_gain_m, source)
    values (v_user, 'hike',
            now() - interval '1 hours', now(),
            3600, 4000, 500, 'app');
end$$;

select is(
    (select value::int from public.personal_records
      where user_id = '00000000-0000-0000-0000-000000000B01'
        and record_type = 'biggest_elevation'),
    500,
    'biggest_elevation PR = 500m'
);

-- Cleanup
do $$
begin
    delete from public.activities       where user_id = '00000000-0000-0000-0000-000000000B01';
    delete from public.personal_records where user_id = '00000000-0000-0000-0000-000000000B01';
    delete from public.profiles         where id      = '00000000-0000-0000-0000-000000000B01';
    delete from auth.users              where id      = '00000000-0000-0000-0000-000000000B01';
end$$;

select * from finish();
rollback;
