-- 20260521000700_search_indexes.sql
-- Additional indexes to accelerate common query paths.
-- All indexes use IF NOT EXISTS so re-running is safe even if an earlier
-- migration already created an overlapping one.

-- activities: lookups by (user, type, started_at desc) are the bread-and-butter
-- query of the user history feed. The bootstrap migration only has
-- (user_id, started_at desc); adding `type` shrinks the scan for filtered feeds.
create index if not exists activities_user_type_started_idx
    on public.activities (user_id, type, started_at desc);

-- coin_transactions: dashboard "earned this month" queries scan positive
-- amounts only; partial index keeps it small and hot.
create index if not exists coin_tx_user_earned_idx
    on public.coin_transactions (user_id, created_at desc)
    where amount > 0;

-- badges.criteria_jsonb: the award engine probes this jsonb. A GIN index
-- enables ? / @> operators to use the index.
create index if not exists badges_criteria_gin_idx
    on public.badges using gin (criteria_jsonb jsonb_path_ops);

-- daily_steps already has a (user_id, date desc) index; add ascending composite
-- for streak walks and range scans Mon..Sun.
create index if not exists daily_steps_user_date_asc_idx
    on public.daily_steps (user_id, date);

-- profiles.username trigram index for substring search.
-- The bootstrap migration created this in the `extensions` schema namespace;
-- add a defensive duplicate in case the extension lives in `public`.
do $$
begin
    if not exists (
        select 1 from pg_indexes
        where schemaname = 'public' and indexname = 'profiles_username_trgm_idx'
    ) then
        execute 'create index profiles_username_trgm_idx on public.profiles using gin (username gin_trgm_ops)';
    end if;
end$$;

-- follows: existing indexes cover both directions; add a small one to count
-- followers cheaply.
create index if not exists follows_followee_count_idx
    on public.follows (followee_id);

-- challenge_participants: typical query is "leaderboard inside a challenge".
create index if not exists cp_challenge_rank_idx
    on public.challenge_participants (challenge_id, rank)
    where rank is not null;

-- activity_points: time-ordered scan during anti-cheat / replay.
create index if not exists activity_points_seq_idx
    on public.activity_points (activity_id, sequence);

comment on index public.activities_user_type_started_idx is
    'Speeds up filtered history feed: WHERE user_id = ? AND type = ? ORDER BY started_at DESC.';
comment on index public.coin_tx_user_earned_idx is
    'Partial index on positive coin_transactions for "earned" dashboards.';
comment on index public.badges_criteria_gin_idx is
    'GIN on criteria_jsonb so the award engine can probe with @> / ?.';
