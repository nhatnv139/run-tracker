-- 20260521001000_referral.sql
-- Referral program: when a referee completes their first 5K run, both
-- the referee and the referrer receive a 200 RunCoin reward.
--
-- Schema:
--   referrals
--     id, referrer_user_id, referee_user_id (nullable until signup),
--     referee_email (captured at invite time),
--     status (pending | qualified | expired),
--     created_at, referee_first_activity_at, qualified_at
--
-- RPC:
--   process_referral_qualification(p_user_id uuid) -> jsonb
--     Called by the application after a user finishes an activity. If the
--     activity contributes to crossing the 5km threshold and a pending
--     referral exists for that user, mark it qualified and emit two
--     coin_transactions of 200 each (referral reason) and a single outbox
--     row 'referral_qualified'.

create type public.referral_status_enum as enum ('pending', 'qualified', 'expired');

create table public.referrals (
    id                       uuid        primary key default gen_random_uuid(),
    referrer_user_id         uuid        not null references public.profiles (id) on delete cascade,
    referee_user_id          uuid        references public.profiles (id) on delete set null,
    referee_email            citext,
    code                     text        unique not null,
    status                   public.referral_status_enum not null default 'pending',
    created_at               timestamptz not null default now(),
    referee_first_activity_at timestamptz,
    qualified_at             timestamptz,
    expires_at               timestamptz not null default (now() + interval '90 days'),
    -- Either the referee is identified (user_id) OR an email is captured.
    constraint referrals_target_known
        check (referee_user_id is not null or referee_email is not null),
    -- A referrer cannot self-refer.
    constraint referrals_no_self
        check (referee_user_id is null or referee_user_id <> referrer_user_id)
);

create unique index referrals_referee_user_uidx
    on public.referrals (referee_user_id)
    where referee_user_id is not null;
create index referrals_referrer_idx on public.referrals (referrer_user_id, created_at desc);
create index referrals_status_idx   on public.referrals (status);
create index referrals_code_idx     on public.referrals (code);

comment on table public.referrals is 'Tracks referral invites and qualification status.';

-- ---------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------
alter table public.referrals enable row level security;

create policy referrals_select_participant on public.referrals
    for select using (
        auth.uid() = referrer_user_id
        or auth.uid() = referee_user_id
    );

create policy referrals_insert_self on public.referrals
    for insert with check (auth.uid() = referrer_user_id);

create policy referrals_service_write on public.referrals
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- RPC: process_referral_qualification
--   Called after every completed activity by the application layer.
--   If the user has >= 5km lifetime distance AND a pending referral
--   row, qualify it and award 200 RunCoin to both sides.
-- ---------------------------------------------------------------
create or replace function public.process_referral_qualification(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_lifetime_m bigint;
    v_referral   record;
    v_reward     constant integer := 200;
    v_balance_a  integer;
    v_balance_b  integer;
begin
    -- Find a pending referral for this referee.
    select * into v_referral
      from public.referrals
     where referee_user_id = p_user_id
       and status = 'pending'
     limit 1;

    if v_referral.id is null then
        return jsonb_build_object('qualified', false, 'reason', 'no_pending_referral');
    end if;

    -- Expiry check.
    if v_referral.expires_at < now() then
        update public.referrals
           set status = 'expired'
         where id = v_referral.id;
        return jsonb_build_object('qualified', false, 'reason', 'expired');
    end if;

    -- Need >= 5 km lifetime.
    select coalesce(sum(distance_m), 0)
      into v_lifetime_m
      from public.activities
     where user_id = p_user_id;

    if v_lifetime_m < 5000 then
        return jsonb_build_object(
            'qualified', false,
            'reason', 'below_threshold',
            'lifetime_m', v_lifetime_m
        );
    end if;

    -- Qualify the referral.
    update public.referrals
       set status                    = 'qualified',
           qualified_at              = now(),
           referee_first_activity_at = coalesce(referee_first_activity_at, now())
     where id = v_referral.id;

    -- Award referrer.
    insert into public.run_coins (user_id, balance, lifetime_earned)
    values (v_referral.referrer_user_id, v_reward, v_reward)
    on conflict (user_id) do update set
        balance         = public.run_coins.balance         + excluded.balance,
        lifetime_earned = public.run_coins.lifetime_earned + excluded.lifetime_earned,
        updated_at      = now()
    returning balance into v_balance_a;

    insert into public.coin_transactions (user_id, amount, reason, metadata, balance_after)
    values (
        v_referral.referrer_user_id, v_reward, 'referral',
        jsonb_build_object(
            'referral_id', v_referral.id,
            'role',        'referrer',
            'referee',     p_user_id
        ),
        v_balance_a
    );

    -- Award referee.
    insert into public.run_coins (user_id, balance, lifetime_earned)
    values (p_user_id, v_reward, v_reward)
    on conflict (user_id) do update set
        balance         = public.run_coins.balance         + excluded.balance,
        lifetime_earned = public.run_coins.lifetime_earned + excluded.lifetime_earned,
        updated_at      = now()
    returning balance into v_balance_b;

    insert into public.coin_transactions (user_id, amount, reason, metadata, balance_after)
    values (
        p_user_id, v_reward, 'referral',
        jsonb_build_object(
            'referral_id', v_referral.id,
            'role',        'referee',
            'referrer',    v_referral.referrer_user_id
        ),
        v_balance_b
    );

    -- Emit outbox event (if outbox table present).
    if to_regclass('public.outbox') is not null then
        insert into public.outbox (user_id, event_type, payload, dedupe_key)
        values (
            v_referral.referrer_user_id, 'referral_qualified',
            jsonb_build_object(
                'referral_id', v_referral.id,
                'referrer',    v_referral.referrer_user_id,
                'referee',     p_user_id,
                'reward_each', v_reward
            ),
            'referral_qualified:' || v_referral.id::text
        )
        on conflict (dedupe_key) where dedupe_key is not null do nothing;
    end if;

    return jsonb_build_object(
        'qualified',              true,
        'referral_id',            v_referral.id,
        'referrer_user_id',       v_referral.referrer_user_id,
        'referee_user_id',        p_user_id,
        'reward_each',            v_reward,
        'referrer_new_balance',   v_balance_a,
        'referee_new_balance',    v_balance_b
    );
end;
$$;

comment on function public.process_referral_qualification(uuid)
    is 'If a pending referral exists for p_user_id and lifetime distance >= 5km, qualify it and award 200 RunCoin to both sides.';

grant execute on function public.process_referral_qualification(uuid) to authenticated;
