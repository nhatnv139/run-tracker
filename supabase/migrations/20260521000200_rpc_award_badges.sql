-- 20260521000200_rpc_award_badges.sql
-- Full badge evaluation engine. Reads badges.criteria_jsonb and supports the
-- following criteria-type strings under criteria_jsonb.type:
--   single_activity, lifetime, streak, composite,
--   rolling_window, seasonal, time_of_day, weather, pace, manual_event
--
-- For backward compatibility we also accept the simpler legacy keys that
-- 20260520000500_badges.sql seeded (distance_m, lifetime_distance_m, streak_days,
-- weather, end_before, end_after, lifetime_elevation_m, etc.) -- a badge with no
-- explicit "type" is treated as a single_activity / lifetime / streak rule based
-- on which key is present.

create or replace function public.award_badges_for_user(
    p_user_id     uuid,
    p_activity_id uuid default null
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    b              record;
    a              record;
    sub            jsonb;
    v_criteria     jsonb;
    v_type         text;
    v_lifetime_m   bigint;
    v_lifetime_el  bigint;
    v_streak       integer;
    v_followers    integer;
    v_match        boolean;
    v_local_hour   integer;
    v_awarded      jsonb := '[]'::jsonb;
    v_count        integer := 0;
begin
    -- Aggregate once.
    select coalesce(sum(distance_m), 0),
           coalesce(sum(elevation_gain_m), 0)
      into v_lifetime_m, v_lifetime_el
      from public.activities where user_id = p_user_id;

    select coalesce(current_days, 0) into v_streak
      from public.streaks where user_id = p_user_id;
    v_streak := coalesce(v_streak, 0);

    select count(*) into v_followers
      from public.follows where followee_id = p_user_id;

    if p_activity_id is not null then
        select id, distance_m, elevation_gain_m, duration_s, started_at, ended_at,
               weather, avg_pace_s_per_km, start_point, end_point, type
          into a
          from public.activities where id = p_activity_id;
    end if;

    for b in select * from public.badges where is_active = true loop
        -- Already earned? skip.
        if exists (select 1 from public.user_badges
                    where user_id = p_user_id and badge_id = b.id) then
            continue;
        end if;

        v_criteria := coalesce(b.criteria_jsonb, '{}'::jsonb);
        v_type     := v_criteria ->> 'type';
        v_match    := false;

        -- Auto-detect legacy type if not specified.
        if v_type is null then
            if v_criteria ? 'lifetime_distance_m' or v_criteria ? 'lifetime_elevation_m' then
                v_type := 'lifetime';
            elsif v_criteria ? 'streak_days' then
                v_type := 'streak';
            elsif v_criteria ? 'weather' or v_criteria ? 'temp_c_min' or v_criteria ? 'temp_c_max' then
                v_type := 'weather';
            elsif v_criteria ? 'end_before' or v_criteria ? 'end_after' or v_criteria ? 'window' then
                v_type := 'time_of_day';
            elsif v_criteria ? 'season' or v_criteria ? 'date' then
                v_type := 'seasonal';
            elsif v_criteria ? 'distance_m' then
                v_type := 'single_activity';
            else
                v_type := 'manual_event';
            end if;
        end if;

        -- Dispatch per type.
        case v_type
        when 'single_activity' then
            if a.id is not null then
                v_match := true;
                if v_criteria ? 'distance_m_gte' then
                    v_match := v_match and a.distance_m >= (v_criteria ->> 'distance_m_gte')::integer;
                end if;
                if v_criteria ? 'distance_m' then
                    v_match := v_match and a.distance_m >= (v_criteria ->> 'distance_m')::integer;
                end if;
                if v_criteria ? 'max_duration_s' then
                    v_match := v_match and a.duration_s <= (v_criteria ->> 'max_duration_s')::integer;
                end if;
                if v_criteria ? 'elevation_gain_m_gte' then
                    v_match := v_match and a.elevation_gain_m >= (v_criteria ->> 'elevation_gain_m_gte')::integer;
                end if;
            end if;

        when 'lifetime' then
            v_match := true;
            if v_criteria ? 'lifetime_km_gte' then
                v_match := v_match and v_lifetime_m >= (v_criteria ->> 'lifetime_km_gte')::bigint * 1000;
            end if;
            if v_criteria ? 'lifetime_distance_m' then
                v_match := v_match and v_lifetime_m >= (v_criteria ->> 'lifetime_distance_m')::bigint;
            end if;
            if v_criteria ? 'lifetime_elevation_m' then
                v_match := v_match and v_lifetime_el >= (v_criteria ->> 'lifetime_elevation_m')::bigint;
            end if;

        when 'streak' then
            if v_criteria ? 'streak_days_gte' then
                v_match := v_streak >= (v_criteria ->> 'streak_days_gte')::integer;
            elsif v_criteria ? 'streak_days' then
                v_match := v_streak >= (v_criteria ->> 'streak_days')::integer;
            end if;

        when 'composite' then
            -- All sub-criteria must match. Sub-criteria use the same dispatch keys.
            v_match := true;
            if jsonb_typeof(v_criteria -> 'all_of') = 'array' then
                for sub in select * from jsonb_array_elements(v_criteria -> 'all_of') loop
                    if sub ? 'lifetime_km_gte'
                        and not (v_lifetime_m >= (sub ->> 'lifetime_km_gte')::bigint * 1000) then
                        v_match := false; exit;
                    end if;
                    if sub ? 'streak_days_gte'
                        and not (v_streak >= (sub ->> 'streak_days_gte')::integer) then
                        v_match := false; exit;
                    end if;
                    if sub ? 'distance_m_gte' and a.id is not null
                        and not (a.distance_m >= (sub ->> 'distance_m_gte')::integer) then
                        v_match := false; exit;
                    end if;
                    if sub ? 'followers_gte'
                        and not (v_followers >= (sub ->> 'followers_gte')::integer) then
                        v_match := false; exit;
                    end if;
                end loop;
            else
                v_match := false;
            end if;

        when 'rolling_window' then
            -- e.g. {"type":"rolling_window","window_days":7,"count_gte":5}
            declare
                v_window int := coalesce((v_criteria ->> 'window_days')::int, 7);
                v_need   int := coalesce((v_criteria ->> 'count_gte')::int, 1);
                v_have   int;
            begin
                select count(*) into v_have
                  from public.activities
                 where user_id = p_user_id
                   and started_at >= now() - make_interval(days => v_window);
                v_match := v_have >= v_need;
            end;

        when 'seasonal' then
            if a.id is not null then
                if v_criteria ? 'date_from' and v_criteria ? 'date_to' then
                    v_match := a.started_at::date between
                               (v_criteria ->> 'date_from')::date
                           and (v_criteria ->> 'date_to')::date;
                elsif v_criteria ->> 'season' = 'tet' then
                    -- Tet Nguyen Dan 2026: Feb 17-19 (matches user-supplied seasonal example).
                    v_match := a.started_at::date between date '2026-02-17' and date '2026-02-19';
                elsif v_criteria ? 'date' then
                    -- "MM-DD" recurring marker (e.g. Jan 1).
                    v_match := to_char(a.started_at, 'MM-DD') = (v_criteria ->> 'date');
                end if;
            end if;

        when 'time_of_day' then
            if a.id is not null then
                v_local_hour := extract(hour from (a.started_at at time zone 'Asia/Ho_Chi_Minh'))::integer;
                if v_criteria ? 'hour_start' and v_criteria ? 'hour_end' then
                    v_match := v_local_hour >= (v_criteria ->> 'hour_start')::int
                           and v_local_hour <  (v_criteria ->> 'hour_end')::int;
                elsif v_criteria ? 'end_before' then
                    v_match := to_char(a.ended_at at time zone 'Asia/Ho_Chi_Minh', 'HH24:MI')
                               < (v_criteria ->> 'end_before');
                elsif v_criteria ? 'end_after' then
                    v_match := to_char(a.ended_at at time zone 'Asia/Ho_Chi_Minh', 'HH24:MI')
                               > (v_criteria ->> 'end_after');
                end if;
            end if;

        when 'weather' then
            if a.id is not null and a.weather is not null then
                if v_criteria ? 'weather' then
                    v_match := lower(coalesce(a.weather ->> 'condition', '')) = lower(v_criteria ->> 'weather');
                end if;
                if v_criteria ? 'temp_c_min' then
                    v_match := v_match or
                               (coalesce((a.weather ->> 'temp_c')::numeric, -100)
                                >= (v_criteria ->> 'temp_c_min')::numeric);
                end if;
                if v_criteria ? 'temp_c_max' then
                    v_match := v_match or
                               (coalesce((a.weather ->> 'temp_c')::numeric, 100)
                                <= (v_criteria ->> 'temp_c_max')::numeric);
                end if;
            end if;

        when 'pace' then
            if a.id is not null and a.avg_pace_s_per_km is not null then
                if v_criteria ? 'pace_max' then
                    v_match := a.avg_pace_s_per_km <= (v_criteria ->> 'pace_max')::int;
                end if;
            end if;

        when 'manual_event' then
            -- These are awarded by service_role explicitly.
            v_match := false;

        else
            v_match := false;
        end case;

        if v_match then
            insert into public.user_badges (user_id, badge_id, activity_id)
            values (p_user_id, b.id, p_activity_id)
            on conflict do nothing;

            -- Notification event for downstream consumers (push, email, analytics).
            -- Guard with EXISTS so tests can run before outbox migration if needed.
            if to_regclass('public.outbox') is not null then
                insert into public.outbox (user_id, event_type, payload)
                values (
                    p_user_id, 'badge_earned',
                    jsonb_build_object(
                        'badge_id',     b.id,
                        'badge_code',   b.code,
                        'badge_name',   b.name_en,
                        'tier',         b.tier,
                        'xp_reward',    b.xp_reward,
                        'activity_id',  p_activity_id
                    )
                );
            end if;

            -- Optional XP -> RunCoin grant (preserved from legacy function).
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

            v_awarded := v_awarded || to_jsonb(b.code);
            v_count   := v_count + 1;
        end if;
    end loop;

    return jsonb_build_object('newly_earned', v_awarded, 'count', v_count);
end;
$$;

comment on function public.award_badges_for_user(uuid, uuid)
    is 'Evaluates badges.criteria_jsonb across all supported types and grants newly-met badges.';

grant execute on function public.award_badges_for_user(uuid, uuid) to authenticated;
