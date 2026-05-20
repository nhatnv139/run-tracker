-- 20260521000400_outbox_pattern.sql
-- Transactional outbox for emitting domain events (badge earned, streak
-- milestones, etc.) to downstream consumers (push, email, analytics).
-- A separate worker drains rows where status='pending'.
--
-- Design notes:
--   * Single-table outbox, status enum, indexed by status+created_at for
--     efficient FIFO draining.
--   * Triggers populate outbox AFTER mutations on user_badges and streaks.
--   * Triggers are idempotent (ON CONFLICT DO NOTHING for streak events
--     to avoid duplicate milestone emissions on repeated recalcs).

create type public.outbox_status_enum as enum ('pending', 'sent', 'failed');

create table public.outbox (
    id          uuid        primary key default gen_random_uuid(),
    user_id     uuid        references public.profiles (id) on delete cascade,
    event_type  text        not null check (char_length(event_type) between 1 and 80),
    payload     jsonb       not null default '{}'::jsonb,
    status      public.outbox_status_enum not null default 'pending',
    attempts    integer     not null default 0 check (attempts >= 0),
    last_error  text,
    created_at  timestamptz not null default now(),
    sent_at     timestamptz,
    -- De-dupe key derived from payload; allows ON CONFLICT for milestone-style events.
    dedupe_key  text
);

create index outbox_pending_idx    on public.outbox (status, created_at) where status = 'pending';
create index outbox_user_idx       on public.outbox (user_id, created_at desc);
create index outbox_event_type_idx on public.outbox (event_type);
create unique index outbox_dedupe_uidx on public.outbox (dedupe_key) where dedupe_key is not null;

comment on table public.outbox is 'Transactional outbox for domain events; drained by a background worker.';

-- ---------------------------------------------------------------
-- RLS: only service_role reads/writes; no end-user access.
-- ---------------------------------------------------------------
alter table public.outbox enable row level security;

create policy outbox_service_only on public.outbox
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- Trigger: after_insert on user_badges -> emit 'badge_earned'.
-- ---------------------------------------------------------------
create or replace function public.emit_badge_earned()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_badge record;
begin
    select code, name_en, name_vi, tier, xp_reward, category
      into v_badge
      from public.badges where id = new.badge_id;

    insert into public.outbox (user_id, event_type, payload, dedupe_key)
    values (
        new.user_id, 'badge_earned',
        jsonb_build_object(
            'badge_id',     new.badge_id,
            'badge_code',   v_badge.code,
            'badge_name',   v_badge.name_en,
            'badge_name_vi',v_badge.name_vi,
            'tier',         v_badge.tier,
            'category',     v_badge.category,
            'xp_reward',    v_badge.xp_reward,
            'activity_id',  new.activity_id,
            'awarded_at',   new.awarded_at
        ),
        -- One badge_earned event per user/badge pair, ever.
        'badge_earned:' || new.user_id::text || ':' || new.badge_id::text
    )
    on conflict (dedupe_key) where dedupe_key is not null do nothing;
    return new;
end;
$$;

create trigger trg_user_badges_outbox
    after insert on public.user_badges
    for each row execute function public.emit_badge_earned();

-- ---------------------------------------------------------------
-- Trigger: after_update on streaks -> emit 'streak_milestone' when
-- current_days crosses a 7-day multiple (7, 14, 21, ...).
-- De-dupe per (user_id, streak_value, ISO-week) to avoid storms.
-- ---------------------------------------------------------------
create or replace function public.emit_streak_milestone()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if new.current_days is null or new.current_days = 0 then
        return new;
    end if;

    if (old.current_days is distinct from new.current_days)
       and (new.current_days % 7 = 0)
       and (new.current_days > coalesce(old.current_days, 0))
    then
        insert into public.outbox (user_id, event_type, payload, dedupe_key)
        values (
            new.user_id, 'streak_milestone',
            jsonb_build_object(
                'current_days',       new.current_days,
                'longest_days',       new.longest_days,
                'last_activity_date', new.last_activity_date,
                'milestone_weeks',    new.current_days / 7
            ),
            'streak_milestone:' || new.user_id::text || ':' || new.current_days::text
        )
        on conflict (dedupe_key) where dedupe_key is not null do nothing;
    end if;
    return new;
end;
$$;

create trigger trg_streaks_outbox
    after update on public.streaks
    for each row execute function public.emit_streak_milestone();

comment on function public.emit_badge_earned()    is 'Outbox emitter: badge_earned on user_badges insert.';
comment on function public.emit_streak_milestone() is 'Outbox emitter: streak_milestone on streaks update when current_days is a multiple of 7.';
