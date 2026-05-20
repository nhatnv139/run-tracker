-- 20260521000100_rpc_award_coins.sql
-- Re-implementation of award_coins_for_activity with full RunVie business logic:
--   * Level-aware coin rate (decay for stronger runners).
--   * Daily cap of 50 km_earn coins per UTC day.
--   * Bonuses: PR detected (+50 flat), weekend (+20%), sunrise <06:00 local (+10%).
--   * Idempotent per activity_id.
--   * Returns rich jsonb breakdown.
--
-- NOTE: This migration depends on get_user_level() and personal_records introduced in
-- later migrations of this batch. Postgres resolves function references at call-time,
-- so creating the function here is safe as long as the whole batch is applied together.

create or replace function public.award_coins_for_activity(p_activity_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_user_id     uuid;
    v_distance    integer;
    v_type        public.activity_type_enum;
    v_started     timestamptz;
    v_level       text;
    v_rate        integer;
    v_base        integer;
    v_bonus       integer := 0;
    v_total       integer;
    v_cap         constant integer := 50;
    v_today_sum   integer;
    v_remaining   integer;
    v_new_balance integer;
    v_is_pr       boolean := false;
    v_dow         integer;
    v_local_hour  integer;
    v_existing    uuid;
begin
    select user_id, distance_m, type, started_at
      into v_user_id, v_distance, v_type, v_started
      from public.activities
     where id = p_activity_id;

    if v_user_id is null then
        raise exception 'Activity % not found', p_activity_id;
    end if;

    -- Idempotency: bail out if this activity has already been credited.
    select id into v_existing
      from public.coin_transactions
     where user_id = v_user_id
       and reason  = 'km_earn'
       and metadata ->> 'activity_id' = p_activity_id::text
     limit 1;

    if v_existing is not null then
        select balance into v_new_balance from public.run_coins where user_id = v_user_id;
        return jsonb_build_object(
            'coins_earned', 0,
            'breakdown',    jsonb_build_object('base', 0, 'bonus', 0, 'reason', 'already_awarded'),
            'new_balance',  coalesce(v_new_balance, 0)
        );
    end if;

    -- Coin rate decays as runners become stronger. Tries get_user_level() if present,
    -- otherwise falls back to profiles.level.
    begin
        select public.get_user_level(v_user_id) into v_level;
    exception when undefined_function then
        select level::text into v_level from public.profiles where id = v_user_id;
    end;

    v_rate := case coalesce(v_level, 'beginner')
                when 'beginner'     then 10
                when 'intermediate' then 8
                when 'advanced'     then 6
                when 'elite'        then 5
                else 10
              end;

    -- Base = floor(km) * rate.
    v_base := floor(v_distance / 1000.0)::integer * v_rate;
    if v_base <= 0 then
        return jsonb_build_object(
            'coins_earned', 0,
            'breakdown',    jsonb_build_object('base', 0, 'bonus', 0, 'reason', 'sub_km'),
            'new_balance',  coalesce((select balance from public.run_coins where user_id = v_user_id), 0)
        );
    end if;

    -- PR bonus: did this activity write any personal_records row?
    begin
        if exists (
            select 1 from public.personal_records
             where user_id = v_user_id and activity_id = p_activity_id
        ) then
            v_is_pr := true;
            v_bonus := v_bonus + 50;
        end if;
    exception when undefined_table then
        v_is_pr := false;
    end;

    -- Weekend bonus: Saturday (6) or Sunday (0) in UTC. +20% of base.
    v_dow := extract(dow from v_started)::integer;
    if v_dow = 0 or v_dow = 6 then
        v_bonus := v_bonus + floor(v_base * 0.20)::integer;
    end if;

    -- Sunrise bonus: start hour in Asia/Ho_Chi_Minh before 06:00. +10% of base.
    v_local_hour := extract(hour from (v_started at time zone 'Asia/Ho_Chi_Minh'))::integer;
    if v_local_hour < 6 then
        v_bonus := v_bonus + floor(v_base * 0.10)::integer;
    end if;

    -- Apply daily cap (base only; bonuses are uncapped to keep incentives strong).
    select coalesce(sum(amount), 0)
      into v_today_sum
      from public.coin_transactions
     where user_id = v_user_id
       and reason  = 'km_earn'
       and (created_at at time zone 'UTC')::date = (now() at time zone 'UTC')::date;

    v_remaining := greatest(v_cap - v_today_sum, 0);
    if v_base > v_remaining then
        v_base := v_remaining;
    end if;

    v_total := v_base + v_bonus;
    if v_total <= 0 then
        return jsonb_build_object(
            'coins_earned', 0,
            'breakdown',    jsonb_build_object('base', 0, 'bonus', 0, 'reason', 'daily_cap_reached'),
            'new_balance',  coalesce((select balance from public.run_coins where user_id = v_user_id), 0)
        );
    end if;

    -- Update cached balance.
    insert into public.run_coins (user_id, balance, lifetime_earned)
    values (v_user_id, v_total, v_total)
    on conflict (user_id) do update set
        balance         = public.run_coins.balance         + excluded.balance,
        lifetime_earned = public.run_coins.lifetime_earned + excluded.lifetime_earned,
        updated_at      = now()
    returning balance into v_new_balance;

    -- One ledger row carrying base+bonus together; the breakdown lives in metadata.
    insert into public.coin_transactions (user_id, amount, reason, metadata, balance_after)
    values (
        v_user_id, v_total, 'km_earn',
        jsonb_build_object(
            'activity_id', p_activity_id,
            'distance_m',  v_distance,
            'rate',        v_rate,
            'level',       coalesce(v_level, 'beginner'),
            'base',        v_base,
            'bonus',       v_bonus,
            'is_pr',       v_is_pr,
            'weekend',     (v_dow = 0 or v_dow = 6),
            'sunrise',     (v_local_hour < 6),
            'cap_applied', (v_today_sum + v_base >= v_cap)
        ),
        v_new_balance
    );

    return jsonb_build_object(
        'coins_earned', v_total,
        'breakdown',    jsonb_build_object(
                            'base',    v_base,
                            'bonus',   v_bonus,
                            'rate',    v_rate,
                            'level',   coalesce(v_level, 'beginner'),
                            'is_pr',   v_is_pr,
                            'weekend', (v_dow = 0 or v_dow = 6),
                            'sunrise', (v_local_hour < 6)
                        ),
        'new_balance',  v_new_balance
    );
end;
$$;

comment on function public.award_coins_for_activity(uuid)
    is 'Awards RunCoin for an activity. Level-aware rate, 50/day cap, PR/weekend/sunrise bonuses, idempotent.';

grant execute on function public.award_coins_for_activity(uuid) to authenticated;
