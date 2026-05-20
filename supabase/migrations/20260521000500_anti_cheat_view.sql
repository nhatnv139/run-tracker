-- 20260521000500_anti_cheat_view.sql
-- Anti-cheat heuristics:
--   * suspicious_activities VIEW aggregates per-activity statistics from
--     activity_points (max speed) plus polyline straightness ratio
--     (great-circle distance / cumulative distance).
--   * flag_suspicious(p_activity_id) runs the heuristic and sets
--     activities.verified = false when triggered.
--
-- Heuristic thresholds (conservative; tune later):
--   * max instantaneous speed > 8 m/s for a 'walk'  -> suspicious
--   * max instantaneous speed > 12 m/s for a 'run'  -> suspicious (~43 km/h)
--   * straightness_ratio > 0.985 AND distance_m > 3000 -> suspicious
--     (means the run was a near-perfect straight line over 3 km, often
--      indicating a vehicle/teleport).
--   * avg_pace_s_per_km < 150 (faster than 2:30/km) -> suspicious
--     (faster than world-record marathon pace; safe lower bound).

create or replace view public.suspicious_activities as
with point_stats as (
    select
        ap.activity_id,
        max(ap.speed_mps)                                         as max_speed_mps,
        avg(ap.speed_mps)                                         as avg_speed_mps,
        count(*)                                                  as point_count,
        st_distance(
            (array_agg(ap.point order by ap.sequence asc))[1],
            (array_agg(ap.point order by ap.sequence desc))[1]
        )                                                         as great_circle_m
    from public.activity_points ap
    group by ap.activity_id
),
combined as (
    select
        a.id                          as activity_id,
        a.user_id,
        a.type,
        a.distance_m,
        a.duration_s,
        a.avg_pace_s_per_km,
        a.verified,
        ps.max_speed_mps,
        ps.avg_speed_mps,
        ps.point_count,
        ps.great_circle_m,
        case
            when a.distance_m > 0 then ps.great_circle_m / a.distance_m::numeric
            else null
        end                           as straightness_ratio
    from public.activities a
    left join point_stats ps on ps.activity_id = a.id
)
select
    c.activity_id,
    c.user_id,
    c.type,
    c.distance_m,
    c.duration_s,
    c.avg_pace_s_per_km,
    c.max_speed_mps,
    c.avg_speed_mps,
    c.straightness_ratio,
    c.verified,
    -- Per-reason booleans for downstream auditing.
    (c.type = 'walk' and c.max_speed_mps > 8)                                          as flag_walk_too_fast,
    (c.type in ('run', 'treadmill', 'hike') and c.max_speed_mps > 12)                  as flag_run_too_fast,
    (c.distance_m > 3000 and c.straightness_ratio > 0.985)                             as flag_too_straight,
    (c.avg_pace_s_per_km is not null and c.avg_pace_s_per_km < 150)                    as flag_pace_too_fast,
    (
        (c.type = 'walk' and c.max_speed_mps > 8)
        or (c.type in ('run', 'treadmill', 'hike') and c.max_speed_mps > 12)
        or (c.distance_m > 3000 and c.straightness_ratio > 0.985)
        or (c.avg_pace_s_per_km is not null and c.avg_pace_s_per_km < 150)
    )                                                                                  as is_suspicious
from combined c
where
    (c.type = 'walk' and c.max_speed_mps > 8)
    or (c.type in ('run', 'treadmill', 'hike') and c.max_speed_mps > 12)
    or (c.distance_m > 3000 and c.straightness_ratio > 0.985)
    or (c.avg_pace_s_per_km is not null and c.avg_pace_s_per_km < 150);

comment on view public.suspicious_activities is 'Activities flagged by anti-cheat heuristics; consume in audit dashboards.';

-- ---------------------------------------------------------------
-- flag_suspicious: returns true and clears verified flag if the activity
-- trips any heuristic; otherwise returns false.
-- ---------------------------------------------------------------
create or replace function public.flag_suspicious(p_activity_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
    v_suspicious boolean := false;
    v_max_speed  double precision;
    v_distance   integer;
    v_type       public.activity_type_enum;
    v_pace       integer;
    v_straight   numeric;
    v_first      geography;
    v_last       geography;
    v_great_circle double precision;
begin
    select a.distance_m, a.type, a.avg_pace_s_per_km
      into v_distance, v_type, v_pace
      from public.activities a where a.id = p_activity_id;

    if v_distance is null then
        return false;
    end if;

    select max(speed_mps) into v_max_speed
      from public.activity_points where activity_id = p_activity_id;

    -- Compute straightness ratio inline (only if we have GPS samples).
    select (array_agg(point order by sequence asc))[1],
           (array_agg(point order by sequence desc))[1]
      into v_first, v_last
      from public.activity_points
     where activity_id = p_activity_id;

    if v_first is not null and v_last is not null and v_distance > 0 then
        v_great_circle := st_distance(v_first, v_last);
        v_straight := v_great_circle / v_distance::numeric;
    end if;

    if v_type = 'walk' and v_max_speed > 8 then
        v_suspicious := true;
    elsif v_type in ('run', 'treadmill', 'hike') and v_max_speed > 12 then
        v_suspicious := true;
    elsif v_distance > 3000 and coalesce(v_straight, 0) > 0.985 then
        v_suspicious := true;
    elsif v_pace is not null and v_pace < 150 then
        v_suspicious := true;
    end if;

    if v_suspicious then
        update public.activities
           set verified   = false,
               updated_at = now()
         where id = p_activity_id;
    end if;

    return v_suspicious;
end;
$$;

comment on function public.flag_suspicious(uuid)
    is 'Runs anti-cheat heuristics; clears activities.verified when triggered.';

grant execute on function public.flag_suspicious(uuid) to authenticated, service_role;
grant select on public.suspicious_activities to service_role;
