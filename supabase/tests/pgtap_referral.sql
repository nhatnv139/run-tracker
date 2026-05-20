-- pgtap_referral.sql
-- Referrer + referee flow; assert coins awarded.

begin;

create extension if not exists pgtap;

select plan(8);

do $$
declare
    v_ref  uuid := '00000000-0000-0000-0000-000000000C01';  -- referrer
    v_ree  uuid := '00000000-0000-0000-0000-000000000C02';  -- referee
begin
    -- Seed both users.
    insert into auth.users (id, instance_id, aud, role, email, encrypted_password,
                            raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
    values
        (v_ref, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'referrer@example.com', '', '{}'::jsonb, '{}'::jsonb, now(), now()),
        (v_ree, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'referee@example.com',  '', '{}'::jsonb, '{}'::jsonb, now(), now())
    on conflict (id) do nothing;

    insert into public.profiles (id, username, display_name)
    values (v_ref, 'ref_test_u',  'Referrer User'),
           (v_ree, 'reee_test_u', 'Referee User')
    on conflict (id) do nothing;

    delete from public.coin_transactions where user_id in (v_ref, v_ree);
    delete from public.run_coins         where user_id in (v_ref, v_ree);
    delete from public.referrals         where referrer_user_id = v_ref or referee_user_id = v_ree;
    delete from public.activities        where user_id = v_ree;

    -- Insert pending referral.
    insert into public.referrals (referrer_user_id, referee_user_id, referee_email, code)
    values (v_ref, v_ree, 'referee@example.com', 'INVITE_TEST_1');
end$$;

-- 1. Tables & function present.
select has_table('public', 'referrals');
select has_function('public', 'process_referral_qualification', array['uuid']::name[]);

-- 2. Below threshold: a 2 km activity should NOT qualify.
do $$
declare
    v_ree uuid := '00000000-0000-0000-0000-000000000C02';
begin
    insert into public.activities (user_id, type, started_at, ended_at, duration_s, distance_m, source)
    values (v_ree, 'run', now() - interval '1 hours', now(), 600, 2000, 'app');
end$$;

select is(
    (public.process_referral_qualification('00000000-0000-0000-0000-000000000C02') ->> 'qualified')::boolean,
    false,
    'Referral not qualified below 5km threshold'
);

-- 3. Add another 4 km to cross threshold; should qualify.
do $$
declare
    v_ree uuid := '00000000-0000-0000-0000-000000000C02';
begin
    insert into public.activities (user_id, type, started_at, ended_at, duration_s, distance_m, source)
    values (v_ree, 'run', now() - interval '30 minutes', now(), 1500, 4000, 'app');
end$$;

select is(
    (public.process_referral_qualification('00000000-0000-0000-0000-000000000C02') ->> 'qualified')::boolean,
    true,
    'Referral qualifies once lifetime distance >= 5km'
);

-- 4. Both sides credited with 200 RunCoin.
select is(
    (select balance from public.run_coins where user_id = '00000000-0000-0000-0000-000000000C01'),
    200,
    'Referrer received 200 RunCoin'
);

select is(
    (select balance from public.run_coins where user_id = '00000000-0000-0000-0000-000000000C02'),
    200,
    'Referee received 200 RunCoin'
);

select is(
    (select count(*)::int from public.coin_transactions
      where reason = 'referral'
        and user_id in ('00000000-0000-0000-0000-000000000C01', '00000000-0000-0000-0000-000000000C02')),
    2,
    'Two referral coin transactions written'
);

-- 5. Idempotent: calling again should NOT double-award (no pending row).
select is(
    (public.process_referral_qualification('00000000-0000-0000-0000-000000000C02') ->> 'qualified')::boolean,
    false,
    'Second call finds no pending referral and returns qualified=false'
);

-- Cleanup
do $$
begin
    delete from public.coin_transactions where user_id in (
        '00000000-0000-0000-0000-000000000C01',
        '00000000-0000-0000-0000-000000000C02'
    );
    delete from public.run_coins where user_id in (
        '00000000-0000-0000-0000-000000000C01',
        '00000000-0000-0000-0000-000000000C02'
    );
    delete from public.referrals where referrer_user_id = '00000000-0000-0000-0000-000000000C01'
                                    or referee_user_id  = '00000000-0000-0000-0000-000000000C02';
    delete from public.activities where user_id = '00000000-0000-0000-0000-000000000C02';
    delete from public.profiles where id in (
        '00000000-0000-0000-0000-000000000C01',
        '00000000-0000-0000-0000-000000000C02'
    );
    delete from auth.users where id in (
        '00000000-0000-0000-0000-000000000C01',
        '00000000-0000-0000-0000-000000000C02'
    );
end$$;

select * from finish();
rollback;
