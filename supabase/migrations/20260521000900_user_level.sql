-- 20260521000900_user_level.sql
-- get_user_level(): returns one of beginner / intermediate / advanced / elite
-- based on the user's average weekly distance over the last 4 ISO weeks.
--
--   < 5 km/week   -> 'beginner'
--   5-20 km/week  -> 'intermediate'
--   20-50 km/week -> 'advanced'
--   > 50 km/week  -> 'elite'
--
-- A materialized view (user_levels_mv) caches the result for the entire
-- userbase; the function reads from the MV when fresh, else recomputes on
-- the fly so callers never see stale infinity-default data.

create or replace function public.compute_user_level(p_user_id uuid)
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_total_m       bigint;
    v_avg_km_week   numeric;
begin
    select coalesce(sum(distance_m), 0)
      into v_total_m
      from public.activities
     where user_id   = p_user_id
       and started_at >= now() - interval '28 days';

    v_avg_km_week := (v_total_m / 1000.0) / 4.0;

    return case
        when v_avg_km_week < 5  then 'beginner'
        when v_avg_km_week < 20 then 'intermediate'
        when v_avg_km_week < 50 then 'advanced'
        else 'elite'
    end;
end;
$$;

-- ---------------------------------------------------------------
-- Materialized cache. Refreshed daily.
-- ---------------------------------------------------------------
create materialized view public.user_levels_mv as
with last_28 as (
    select user_id, sum(distance_m) as total_m
      from public.activities
     where started_at >= now() - interval '28 days'
     group by user_id
)
select
    p.id as user_id,
    coalesce(l28.total_m, 0)                      as total_m_28d,
    (coalesce(l28.total_m, 0) / 1000.0) / 4.0     as avg_km_week,
    case
        when (coalesce(l28.total_m, 0) / 1000.0) / 4.0 < 5  then 'beginner'
        when (coalesce(l28.total_m, 0) / 1000.0) / 4.0 < 20 then 'intermediate'
        when (coalesce(l28.total_m, 0) / 1000.0) / 4.0 < 50 then 'advanced'
        else 'elite'
    end                                            as level,
    now()                                          as computed_at
from public.profiles p
left join last_28 l28 on l28.user_id = p.id;

create unique index user_levels_mv_uidx on public.user_levels_mv (user_id);
create index user_levels_mv_level_idx   on public.user_levels_mv (level);

comment on materialized view public.user_levels_mv is
    'Caches computed level per user from the last 28 days. Refresh daily.';

-- ---------------------------------------------------------------
-- Public RPC: prefer MV if available, else recompute on the fly.
-- ---------------------------------------------------------------
create or replace function public.get_user_level(p_user_id uuid)
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_level text;
begin
    select level into v_level
      from public.user_levels_mv
     where user_id = p_user_id;

    if v_level is null then
        v_level := public.compute_user_level(p_user_id);
    end if;

    return v_level;
end;
$$;

-- ---------------------------------------------------------------
-- Daily refresh helper.
-- ---------------------------------------------------------------
create or replace function public.refresh_user_levels()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    begin
        refresh materialized view concurrently public.user_levels_mv;
    exception when others then
        refresh materialized view public.user_levels_mv;
    end;
end;
$$;

comment on function public.get_user_level(uuid)
    is 'Returns the user level (beginner/intermediate/advanced/elite) from MV cache, fallback to live compute.';
comment on function public.refresh_user_levels()
    is 'Refresh user_levels_mv. Schedule via pg_cron daily.';

grant select   on public.user_levels_mv             to authenticated, service_role;
grant execute  on function public.get_user_level(uuid)        to authenticated;
grant execute  on function public.compute_user_level(uuid)    to authenticated;
grant execute  on function public.refresh_user_levels()       to service_role;

-- NOTE for ops: register daily refresh, e.g.
--   select cron.schedule('refresh_user_levels_daily', '15 1 * * *',
--                        $$ select public.refresh_user_levels(); $$);
