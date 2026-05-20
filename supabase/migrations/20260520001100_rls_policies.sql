-- 20260520001100_rls_policies.sql
-- Row Level Security: enable on every table + define per-table policies.
-- Rule of thumb: users can read/write their own data; activities are readable by anyone
-- when the owner's profile.is_public = true; waitlist is insert-only for anon.

-- Helper: returns true if profile p_user is publicly visible.
create or replace function public.is_profile_public(p_user uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select coalesce((select is_public from public.profiles where id = p_user), false);
$$;

-- ---------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------
alter table public.profiles enable row level security;

create policy profiles_select_self_or_public on public.profiles
    for select using (
        auth.uid() = id
        or is_public = true
    );

create policy profiles_insert_self on public.profiles
    for insert with check (auth.uid() = id);

create policy profiles_update_self on public.profiles
    for update using (auth.uid() = id) with check (auth.uid() = id);

create policy profiles_delete_self on public.profiles
    for delete using (auth.uid() = id);

-- ---------------------------------------------------------------
-- waitlist: anon can insert, only service_role reads.
-- ---------------------------------------------------------------
alter table public.waitlist enable row level security;

create policy waitlist_insert_anyone on public.waitlist
    for insert to anon, authenticated with check (true);

create policy waitlist_select_service_only on public.waitlist
    for select to service_role using (true);

-- ---------------------------------------------------------------
-- activities
-- ---------------------------------------------------------------
alter table public.activities enable row level security;

create policy activities_select_owner_or_public on public.activities
    for select using (
        auth.uid() = user_id
        or public.is_profile_public(user_id)
    );

create policy activities_insert_self on public.activities
    for insert with check (auth.uid() = user_id);

create policy activities_update_self on public.activities
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy activities_delete_self on public.activities
    for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------
-- activity_points
-- ---------------------------------------------------------------
alter table public.activity_points enable row level security;

create policy activity_points_select on public.activity_points
    for select using (
        exists (
            select 1 from public.activities a
            where a.id = activity_points.activity_id
              and (a.user_id = auth.uid() or public.is_profile_public(a.user_id))
        )
    );

create policy activity_points_write_owner on public.activity_points
    for all using (
        exists (select 1 from public.activities a where a.id = activity_id and a.user_id = auth.uid())
    ) with check (
        exists (select 1 from public.activities a where a.id = activity_id and a.user_id = auth.uid())
    );

-- ---------------------------------------------------------------
-- activity_splits
-- ---------------------------------------------------------------
alter table public.activity_splits enable row level security;

create policy activity_splits_select on public.activity_splits
    for select using (
        exists (
            select 1 from public.activities a
            where a.id = activity_splits.activity_id
              and (a.user_id = auth.uid() or public.is_profile_public(a.user_id))
        )
    );

create policy activity_splits_write_owner on public.activity_splits
    for all using (
        exists (select 1 from public.activities a where a.id = activity_id and a.user_id = auth.uid())
    ) with check (
        exists (select 1 from public.activities a where a.id = activity_id and a.user_id = auth.uid())
    );

-- ---------------------------------------------------------------
-- daily_steps
-- ---------------------------------------------------------------
alter table public.daily_steps enable row level security;

create policy daily_steps_select_owner on public.daily_steps
    for select using (auth.uid() = user_id);

create policy daily_steps_write_owner on public.daily_steps
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------
-- badges: catalog is public-read; write = service_role only.
-- ---------------------------------------------------------------
alter table public.badges enable row level security;

create policy badges_select_all on public.badges
    for select to anon, authenticated using (is_active = true);

create policy badges_service_write on public.badges
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- user_badges: owner reads + public profile reads; only service_role writes.
-- ---------------------------------------------------------------
alter table public.user_badges enable row level security;

create policy user_badges_select on public.user_badges
    for select using (
        auth.uid() = user_id or public.is_profile_public(user_id)
    );

create policy user_badges_service_write on public.user_badges
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- streaks
-- ---------------------------------------------------------------
alter table public.streaks enable row level security;

create policy streaks_select_owner on public.streaks
    for select using (auth.uid() = user_id or public.is_profile_public(user_id));

create policy streaks_service_write on public.streaks
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- run_coins
-- ---------------------------------------------------------------
alter table public.run_coins enable row level security;

create policy run_coins_select_owner on public.run_coins
    for select using (auth.uid() = user_id);

create policy run_coins_service_write on public.run_coins
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- coin_transactions
-- ---------------------------------------------------------------
alter table public.coin_transactions enable row level security;

create policy coin_tx_select_owner on public.coin_transactions
    for select using (auth.uid() = user_id);

create policy coin_tx_service_write on public.coin_transactions
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- challenges + participants
-- ---------------------------------------------------------------
alter table public.challenges enable row level security;

create policy challenges_select_public on public.challenges
    for select using (is_public = true or auth.uid() = created_by);

create policy challenges_service_write on public.challenges
    for all to service_role using (true) with check (true);

alter table public.challenge_participants enable row level security;

create policy cp_select_self_or_public on public.challenge_participants
    for select using (
        auth.uid() = user_id
        or exists (select 1 from public.challenges c where c.id = challenge_id and c.is_public = true)
    );

create policy cp_insert_self on public.challenge_participants
    for insert with check (auth.uid() = user_id);

create policy cp_update_self on public.challenge_participants
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy cp_delete_self on public.challenge_participants
    for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------
-- training_plans + workouts
-- ---------------------------------------------------------------
alter table public.training_plans enable row level security;

create policy tp_select_owner on public.training_plans
    for select using (auth.uid() = user_id);

create policy tp_write_owner on public.training_plans
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table public.training_workouts enable row level security;

create policy tw_select_owner on public.training_workouts
    for select using (
        exists (select 1 from public.training_plans p where p.id = plan_id and p.user_id = auth.uid())
    );

create policy tw_write_owner on public.training_workouts
    for all using (
        exists (select 1 from public.training_plans p where p.id = plan_id and p.user_id = auth.uid())
    ) with check (
        exists (select 1 from public.training_plans p where p.id = plan_id and p.user_id = auth.uid())
    );

-- ---------------------------------------------------------------
-- follows
-- ---------------------------------------------------------------
alter table public.follows enable row level security;

create policy follows_select_visible on public.follows
    for select using (
        auth.uid() in (follower_id, followee_id)
        or public.is_profile_public(follower_id)
        or public.is_profile_public(followee_id)
    );

create policy follows_insert_self on public.follows
    for insert with check (auth.uid() = follower_id);

create policy follows_delete_self on public.follows
    for delete using (auth.uid() = follower_id);

-- ---------------------------------------------------------------
-- devices
-- ---------------------------------------------------------------
alter table public.devices enable row level security;

create policy devices_select_owner on public.devices
    for select using (auth.uid() = user_id);

create policy devices_write_owner on public.devices
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
