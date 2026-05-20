-- 20260521000600_leaderboard_mv.sql
-- Weekly leaderboards as a materialized view.
--
-- Partitioning strategy (logical, not table partitions): each row carries
--   (scope, scope_value) where scope is one of 'global', 'country', 'city'.
-- For scope='global' the scope_value is the literal 'global'. For 'country'
-- it is the ISO country string from profiles.country; for 'city' it is the
-- composite 'country|city'. This avoids exploding into one MV per scope.
--
-- Refresh contract:
--   * refresh_leaderboards() executes REFRESH MATERIALIZED VIEW CONCURRENTLY.
--   * Concurrent refresh requires a UNIQUE INDEX -> we add one.
--   * Recommended pg_cron schedule:
--       select cron.schedule('refresh_leaderboards_15m', '*/15 * * * *',
--                            $$ select public.refresh_leaderboards(); $$);
--     (Run by ops, not in this migration, to keep this layer cron-free.)

create materialized view public.leaderboard_weekly as
with iso_week as (
    select date_trunc('week', now()) as week_start,
           date_trunc('week', now()) + interval '7 days' as week_end
),
weekly_activity as (
    select
        a.user_id,
        sum(a.distance_m)         as distance_total,
        sum(a.duration_s)         as time_total,
        count(*)                  as activity_count
    from public.activities a, iso_week w
    where a.started_at >= w.week_start
      and a.started_at <  w.week_end
      -- Note: we do NOT filter on verified here; the bootstrap default is
      -- false so doing so would exclude every activity. Anti-cheat lives
      -- elsewhere (suspicious_activities + flag_suspicious).
    group by a.user_id
),
joined as (
    select
        wa.user_id,
        p.country,
        p.city,
        wa.distance_total,
        wa.time_total,
        wa.activity_count
    from weekly_activity wa
    join public.profiles p on p.id = wa.user_id
    where p.is_public = true
),
all_scopes as (
    -- global
    select 'global'::text as scope, 'global'::text as scope_value,
           user_id, distance_total, time_total, activity_count
      from joined
    union all
    -- country (skip rows without country)
    select 'country'::text, country,
           user_id, distance_total, time_total, activity_count
      from joined where country is not null and country <> ''
    union all
    -- city (composite key country|city)
    select 'city'::text, country || '|' || city,
           user_id, distance_total, time_total, activity_count
      from joined where country is not null and city is not null and city <> ''
)
select
    scope,
    scope_value,
    user_id,
    distance_total,
    time_total,
    activity_count,
    rank() over (
        partition by scope, scope_value
        order by distance_total desc, time_total asc, user_id
    ) as rank
from all_scopes;

-- Unique index is required for CONCURRENTLY refresh.
create unique index leaderboard_weekly_uidx
    on public.leaderboard_weekly (scope, scope_value, user_id);

-- Lookup indexes for typical reads.
create index leaderboard_weekly_scope_rank_idx
    on public.leaderboard_weekly (scope, scope_value, rank);
create index leaderboard_weekly_user_idx
    on public.leaderboard_weekly (user_id);

comment on materialized view public.leaderboard_weekly is
    'Weekly aggregated distance/time/count per user, ranked per scope (global/country/city). Refresh every 15 min.';

-- ---------------------------------------------------------------
-- refresh_leaderboards: callable from pg_cron or a service worker.
-- Uses CONCURRENTLY to avoid blocking readers; falls back to plain
-- REFRESH on first run when the MV is unpopulated.
-- ---------------------------------------------------------------
create or replace function public.refresh_leaderboards()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    begin
        refresh materialized view concurrently public.leaderboard_weekly;
    exception when others then
        -- Concurrent refresh fails on a never-populated MV; do a blocking one.
        refresh materialized view public.leaderboard_weekly;
    end;
end;
$$;

comment on function public.refresh_leaderboards()
    is 'Refresh leaderboard_weekly. Schedule via pg_cron every 15 minutes.';

-- Read access for app users; refresh restricted to service_role.
grant select on public.leaderboard_weekly to authenticated, anon;
grant execute on function public.refresh_leaderboards() to service_role;

-- NOTE for ops: register the cron job in a separate environment-specific
-- migration to keep this file portable:
--   select cron.schedule('refresh_leaderboards_15m', '*/15 * * * *',
--                        $$ select public.refresh_leaderboards(); $$);
