-- pgtap_anti_cheat.sql
-- Synthetic suspicious activity: assert flagged.

begin;

create extension if not exists pgtap;

select plan(6);

do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000D01';
begin
    insert into auth.users (id, instance_id, aud, role, email, encrypted_password,
                            raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
    values (v_user, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
            'cheattest@example.com', '', '{}'::jsonb, '{}'::jsonb, now(), now())
    on conflict (id) do nothing;
    insert into public.profiles (id, username, display_name)
    values (v_user, 'cheat_test_u', 'Cheat Test User')
    on conflict (id) do nothing;

    delete from public.activity_points where activity_id in (
        select id from public.activities where user_id = v_user
    );
    delete from public.activities where user_id = v_user;
end$$;

-- 1. View + function exist.
select has_view('public', 'suspicious_activities');
select has_function('public', 'flag_suspicious', array['uuid']::name[]);

-- 2. Build a clean (verified, normal-speed) walk: max ~1.4 m/s, gentle path.
do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000D01';
    v_aid  uuid;
begin
    insert into public.activities (user_id, type, started_at, ended_at,
                                   duration_s, distance_m, avg_pace_s_per_km,
                                   verified, source)
    values (v_user, 'walk', now() - interval '1 hours', now(),
            3600, 5000, 720, true, 'app')
    returning id into v_aid;

    insert into public.activity_points (activity_id, sequence, ts, point, speed_mps)
    select v_aid, g,
           now() - interval '1 hours' + (g || ' seconds')::interval,
           st_setsrid(st_makepoint(106.0 + g * 0.00001, 10.0 + g * 0.00001), 4326)::geography,
           1.4
      from generate_series(0, 100) as g;
end$$;

-- A clean activity should NOT be flagged.
select is(
    public.flag_suspicious(
        (select id from public.activities where user_id = '00000000-0000-0000-0000-000000000D01' limit 1)
    ),
    false,
    'Normal walk is NOT flagged as suspicious'
);

-- 3. Build a cheaty activity: a "walk" with one point at 25 m/s (~90 km/h).
do $$
declare
    v_user uuid := '00000000-0000-0000-0000-000000000D01';
    v_aid  uuid;
begin
    insert into public.activities (user_id, type, started_at, ended_at,
                                   duration_s, distance_m, avg_pace_s_per_km,
                                   verified, source)
    values (v_user, 'walk', now() - interval '2 hours', now() - interval '1 hours',
            3600, 5000, 720, true, 'app')
    returning id into v_aid;

    insert into public.activity_points (activity_id, sequence, ts, point, speed_mps)
    select v_aid, g,
           now() - interval '2 hours' + (g || ' seconds')::interval,
           st_setsrid(st_makepoint(106.0 + g * 0.0001, 10.0), 4326)::geography,
           case when g = 30 then 25.0 else 1.4 end
      from generate_series(0, 100) as g;
end$$;

select is(
    public.flag_suspicious(
        (select id from public.activities where user_id = '00000000-0000-0000-0000-000000000D01'
         order by started_at desc limit 1)
    ),
    true,
    'Walk with 25 m/s spike is flagged as suspicious'
);

-- 4. After flagging, verified should be false.
select is(
    (select verified from public.activities
      where user_id = '00000000-0000-0000-0000-000000000D01'
      order by started_at desc limit 1),
    false,
    'Flagged activity has verified=false'
);

-- 5. View surfaces the flagged row.
select cmp_ok(
    (select count(*)::int from public.suspicious_activities
      where user_id = '00000000-0000-0000-0000-000000000D01'),
    '>=', 1,
    'suspicious_activities view contains at least one row for the user'
);

-- Cleanup
do $$
begin
    delete from public.activity_points where activity_id in (
        select id from public.activities where user_id = '00000000-0000-0000-0000-000000000D01'
    );
    delete from public.activities where user_id = '00000000-0000-0000-0000-000000000D01';
    delete from public.profiles   where id      = '00000000-0000-0000-0000-000000000D01';
    delete from auth.users        where id      = '00000000-0000-0000-0000-000000000D01';
end$$;

select * from finish();
rollback;
