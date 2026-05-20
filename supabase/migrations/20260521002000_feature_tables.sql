-- 20260521002000_feature_tables.sql
-- ---------------------------------------------------------------------------
-- Feature tables batch migration for RunVie.
--
-- Context:
--   Edge Functions and product features (voucher redemption store, KYC OTP,
--   route library, live tracking sessions, premium subscriptions, AI chat
--   metering, anti-cheat dossier, push notification log, weekly recap, and
--   monthly leaderboards) all reference tables that did not yet exist in the
--   migration sequence. This file adds them in a single batch so the next
--   `supabase db reset` produces a schema that satisfies every Edge Function
--   binding.
--
-- Design decisions:
--   * voucher_partners and voucher_skus are already created additively by
--     supabase/seed/seed_voucher_partners.sql with (uuid id, slug, sku).
--     We reuse those shapes via CREATE TABLE IF NOT EXISTS so a fresh
--     environment that runs migrations *before* seeds still gets a working
--     schema. The original spec ("id text PK 'shopee'") was superseded by
--     the seed migration to keep referential integrity uuid-based.
--   * plan_templates is likewise created in seed_template_plans.sql; we
--     mirror it idempotently here.
--   * AI chat usage is split into two narrow tables (monthly free counter,
--     daily paid counter) per spec; this avoids overloading a single PK.
--   * Hot indexes (user_id, created_at desc) on every event-style table;
--     GIST on geography columns; GIN on jsonb where it is queried.
--   * SECURITY DEFINER RPCs (redeem_voucher, check_kyc_required) pin
--     search_path = public, extensions to defeat search_path attacks.
--   * leaderboard_monthly mirrors the design of the existing weekly MV.
-- ---------------------------------------------------------------------------

-- ===========================================================================
-- 1. voucher_partners  (idempotent; canonical schema lives in seed file)
-- ===========================================================================
create table if not exists public.voucher_partners (
    id          uuid        primary key default gen_random_uuid(),
    name        text        not null unique,
    slug        text        not null unique,
    logo_url    text,
    is_active   boolean     not null default true,
    created_at  timestamptz not null default now()
);

alter table public.voucher_partners enable row level security;

drop policy if exists voucher_partners_select_all on public.voucher_partners;
create policy voucher_partners_select_all on public.voucher_partners
    for select to anon, authenticated using (is_active = true);

drop policy if exists voucher_partners_service_write on public.voucher_partners;
create policy voucher_partners_service_write on public.voucher_partners
    for all to service_role using (true) with check (true);

comment on table public.voucher_partners is
    'Redemption store partners (Shopee, Grab, ...). Public read, service write.';

-- ===========================================================================
-- 2. voucher_skus  (idempotent; canonical schema lives in seed file)
-- ===========================================================================
create table if not exists public.voucher_skus (
    id          uuid        primary key default gen_random_uuid(),
    partner_id  uuid        not null references public.voucher_partners (id) on delete cascade,
    sku         text        not null unique,
    name_vi     text        not null,
    name_en     text        not null,
    value_vnd   integer     not null check (value_vnd > 0),
    coin_cost   integer     not null check (coin_cost > 0),
    stock       integer     not null default 0 check (stock >= 0),
    expires_at  timestamptz,
    is_active   boolean     not null default true,
    image_url   text,
    terms       text,
    created_at  timestamptz not null default now()
);

-- Backfill columns the spec requires but that the seed did not include.
alter table public.voucher_skus
    add column if not exists image_url text,
    add column if not exists terms     text;

create index if not exists voucher_skus_partner_idx on public.voucher_skus (partner_id);
create index if not exists voucher_skus_active_idx
    on public.voucher_skus (is_active) where is_active = true;

alter table public.voucher_skus enable row level security;

drop policy if exists voucher_skus_select_all on public.voucher_skus;
create policy voucher_skus_select_all on public.voucher_skus
    for select to anon, authenticated using (is_active = true);

drop policy if exists voucher_skus_service_write on public.voucher_skus;
create policy voucher_skus_service_write on public.voucher_skus
    for all to service_role using (true) with check (true);

comment on table public.voucher_skus is
    'Redemption store catalog. coin_cost = price; stock decremented atomically by redeem_voucher().';

-- ===========================================================================
-- 3. vouchers  (user-owned redemption record)
-- ===========================================================================
do $$ begin
    create type public.voucher_status_enum as enum
        ('reserved', 'sent', 'expired', 'cancelled');
exception when duplicate_object then null; end $$;

create table if not exists public.vouchers (
    id              uuid        primary key default gen_random_uuid(),
    user_id         uuid        not null references public.profiles (id) on delete cascade,
    sku_id          uuid        not null references public.voucher_skus (id) on delete restrict,
    code            text        unique,
    status          public.voucher_status_enum not null default 'reserved',
    redeemed_at     timestamptz,
    expires_at      timestamptz,
    partner_ref     text,
    created_at      timestamptz not null default now()
);

create index if not exists vouchers_user_created_idx
    on public.vouchers (user_id, created_at desc);
create index if not exists vouchers_status_idx
    on public.vouchers (status);
create index if not exists vouchers_sku_idx
    on public.vouchers (sku_id);

alter table public.vouchers enable row level security;

drop policy if exists vouchers_select_self on public.vouchers;
create policy vouchers_select_self on public.vouchers
    for select using (auth.uid() = user_id);

drop policy if exists vouchers_insert_self on public.vouchers;
create policy vouchers_insert_self on public.vouchers
    for insert with check (auth.uid() = user_id);

drop policy if exists vouchers_service_all on public.vouchers;
create policy vouchers_service_all on public.vouchers
    for all to service_role using (true) with check (true);

comment on table public.vouchers is
    'User redemption tickets. status flow: reserved -> sent | expired | cancelled.';

-- ===========================================================================
-- 4. voucher_redemptions  (financial audit log for each redeem)
-- ===========================================================================
create table if not exists public.voucher_redemptions (
    id                  uuid        primary key default gen_random_uuid(),
    user_id             uuid        not null references public.profiles (id) on delete cascade,
    sku_id              uuid        not null references public.voucher_skus (id) on delete restrict,
    voucher_id          uuid        not null references public.vouchers (id) on delete cascade,
    coin_cost           integer     not null check (coin_cost > 0),
    balance_before      integer     not null,
    balance_after       integer     not null,
    partner_status      text,
    partner_response    jsonb       not null default '{}'::jsonb,
    kyc_otp_id          uuid,
    created_at          timestamptz not null default now()
);

create index if not exists voucher_redemptions_user_created_idx
    on public.voucher_redemptions (user_id, created_at desc);
create index if not exists voucher_redemptions_voucher_idx
    on public.voucher_redemptions (voucher_id);
create index if not exists voucher_redemptions_response_gin
    on public.voucher_redemptions using gin (partner_response);

alter table public.voucher_redemptions enable row level security;

drop policy if exists voucher_redemptions_select_self on public.voucher_redemptions;
create policy voucher_redemptions_select_self on public.voucher_redemptions
    for select using (auth.uid() = user_id);

drop policy if exists voucher_redemptions_service_all on public.voucher_redemptions;
create policy voucher_redemptions_service_all on public.voucher_redemptions
    for all to service_role using (true) with check (true);

comment on table public.voucher_redemptions is
    'Append-only audit of each redeem call. Joins to coin_transactions via metadata.';

-- ===========================================================================
-- 5. kyc_otps  (one-time codes for high-value redemptions)
-- ===========================================================================
create table if not exists public.kyc_otps (
    id          uuid        primary key default gen_random_uuid(),
    user_id     uuid        not null references public.profiles (id) on delete cascade,
    phone_hash  text        not null,
    code_hash   text        not null,
    attempts    integer     not null default 0 check (attempts >= 0),
    verified    boolean     not null default false,
    expires_at  timestamptz not null default (now() + interval '10 minutes'),
    created_at  timestamptz not null default now()
);

create index if not exists kyc_otps_user_idx        on public.kyc_otps (user_id, created_at desc);
create index if not exists kyc_otps_phone_idx       on public.kyc_otps (phone_hash);
create index if not exists kyc_otps_expires_idx     on public.kyc_otps (expires_at);
create index if not exists kyc_otps_verified_idx    on public.kyc_otps (user_id, verified, created_at desc);

alter table public.kyc_otps enable row level security;

drop policy if exists kyc_otps_select_self on public.kyc_otps;
create policy kyc_otps_select_self on public.kyc_otps
    for select using (auth.uid() = user_id);

drop policy if exists kyc_otps_service_all on public.kyc_otps;
create policy kyc_otps_service_all on public.kyc_otps
    for all to service_role using (true) with check (true);

comment on table public.kyc_otps is
    'KYC OTP rows. Auto-expire 10 min via expires_at; cleanup by scheduled job.';

-- ===========================================================================
-- 6. routes  (curated/derived user routes)
-- ===========================================================================
create table if not exists public.routes (
    id                  uuid        primary key default gen_random_uuid(),
    user_id             uuid        not null references public.profiles (id) on delete cascade,
    name                text        not null,
    polyline            text        not null,
    distance_m          integer     not null check (distance_m >= 0),
    elevation_gain_m    integer     not null default 0 check (elevation_gain_m >= 0),
    start_point         geography(Point, 4326),
    is_public           boolean     not null default false,
    like_count          integer     not null default 0 check (like_count >= 0),
    created_at          timestamptz not null default now()
);

create index if not exists routes_user_idx          on public.routes (user_id);
create index if not exists routes_public_idx        on public.routes (is_public) where is_public = true;
create index if not exists routes_start_point_gix   on public.routes using gist (start_point);
create index if not exists routes_user_created_idx  on public.routes (user_id, created_at desc);

alter table public.routes enable row level security;

drop policy if exists routes_select_owner_or_public on public.routes;
create policy routes_select_owner_or_public on public.routes
    for select using (auth.uid() = user_id or is_public = true);

drop policy if exists routes_insert_self on public.routes;
create policy routes_insert_self on public.routes
    for insert with check (auth.uid() = user_id);

drop policy if exists routes_update_self on public.routes;
create policy routes_update_self on public.routes
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists routes_delete_self on public.routes;
create policy routes_delete_self on public.routes
    for delete using (auth.uid() = user_id);

comment on table public.routes is
    'Encoded polylines (start/end trimmed 200m for privacy). is_public exposes to community.';

-- ===========================================================================
-- 7. live_sessions  (rolling buffer for in-progress activities)
-- ===========================================================================
create table if not exists public.live_sessions (
    activity_id     uuid        primary key references public.activities (id) on delete cascade,
    user_id         uuid        not null references public.profiles (id) on delete cascade,
    started_at      timestamptz not null default now(),
    last_update_at  timestamptz not null default now(),
    buffer          jsonb       not null default '[]'::jsonb,
    expires_at      timestamptz not null default (now() + interval '6 hours'),
    -- Cap buffer at 720 points (1 sample/sec for 12 min @ window slide).
    constraint live_sessions_buffer_max_720
        check (jsonb_typeof(buffer) = 'array' and jsonb_array_length(buffer) <= 720)
);

create index if not exists live_sessions_user_idx       on public.live_sessions (user_id);
create index if not exists live_sessions_expires_idx    on public.live_sessions (expires_at);

alter table public.live_sessions enable row level security;

drop policy if exists live_sessions_select_self on public.live_sessions;
create policy live_sessions_select_self on public.live_sessions
    for select using (auth.uid() = user_id);

drop policy if exists live_sessions_insert_self on public.live_sessions;
create policy live_sessions_insert_self on public.live_sessions
    for insert with check (auth.uid() = user_id);

drop policy if exists live_sessions_update_self on public.live_sessions;
create policy live_sessions_update_self on public.live_sessions
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists live_sessions_delete_self on public.live_sessions;
create policy live_sessions_delete_self on public.live_sessions
    for delete using (auth.uid() = user_id);

drop policy if exists live_sessions_service_all on public.live_sessions;
create policy live_sessions_service_all on public.live_sessions
    for all to service_role using (true) with check (true);

comment on table public.live_sessions is
    'Ephemeral rolling buffer (<=720 pts) for the active workout. 6h TTL.';

-- ===========================================================================
-- 8. subscriptions  (RunVie+ paid tiers)
-- ===========================================================================
do $$ begin
    create type public.subscription_tier_enum as enum
        ('free', 'plus', 'pro', 'family');
exception when duplicate_object then null; end $$;

do $$ begin
    create type public.subscription_status_enum as enum
        ('trial', 'active', 'grace', 'cancelled', 'expired');
exception when duplicate_object then null; end $$;

do $$ begin
    create type public.subscription_platform_enum as enum
        ('apple', 'google', 'web');
exception when duplicate_object then null; end $$;

create table if not exists public.subscriptions (
    id                          uuid        primary key default gen_random_uuid(),
    user_id                     uuid        not null unique references public.profiles (id) on delete cascade,
    tier                        public.subscription_tier_enum     not null default 'free',
    status                      public.subscription_status_enum   not null default 'expired',
    platform                    public.subscription_platform_enum not null default 'web',
    product_id                  text,
    original_transaction_id     text,
    trial_start                 timestamptz,
    trial_end                   timestamptz,
    current_period_start        timestamptz,
    current_period_end          timestamptz,
    cancelled_at                timestamptz,
    created_at                  timestamptz not null default now(),
    updated_at                  timestamptz not null default now()
);

create index if not exists subscriptions_status_idx
    on public.subscriptions (status);
create index if not exists subscriptions_tier_idx
    on public.subscriptions (tier);
create index if not exists subscriptions_period_end_idx
    on public.subscriptions (current_period_end);
create index if not exists subscriptions_orig_tx_idx
    on public.subscriptions (original_transaction_id)
    where original_transaction_id is not null;

alter table public.subscriptions enable row level security;

drop policy if exists subscriptions_select_self on public.subscriptions;
create policy subscriptions_select_self on public.subscriptions
    for select using (auth.uid() = user_id);

drop policy if exists subscriptions_service_all on public.subscriptions;
create policy subscriptions_service_all on public.subscriptions
    for all to service_role using (true) with check (true);

comment on table public.subscriptions is
    'One row per user. Source of truth = store webhooks (Apple/Google) handled by Edge Function.';

-- ===========================================================================
-- 9. ai_chat_usage_monthly + ai_chat_usage_daily  (free vs paid counters)
-- ===========================================================================
create table if not exists public.ai_chat_usage_monthly (
    user_id         uuid        not null references public.profiles (id) on delete cascade,
    period          text        not null,  -- 'YYYY-MM'
    msg_count       integer     not null default 0 check (msg_count >= 0),
    total_cost_usd  numeric(10,4) not null default 0 check (total_cost_usd >= 0),
    updated_at      timestamptz not null default now(),
    primary key (user_id, period)
);

create index if not exists ai_chat_usage_monthly_period_idx
    on public.ai_chat_usage_monthly (period);

create table if not exists public.ai_chat_usage_daily (
    user_id         uuid        not null references public.profiles (id) on delete cascade,
    period_date     date        not null,
    msg_count       integer     not null default 0 check (msg_count >= 0),
    total_cost_usd  numeric(10,4) not null default 0 check (total_cost_usd >= 0),
    updated_at      timestamptz not null default now(),
    primary key (user_id, period_date)
);

create index if not exists ai_chat_usage_daily_period_date_idx
    on public.ai_chat_usage_daily (period_date);

alter table public.ai_chat_usage_monthly enable row level security;
alter table public.ai_chat_usage_daily   enable row level security;

drop policy if exists ai_chat_usage_monthly_select_self on public.ai_chat_usage_monthly;
create policy ai_chat_usage_monthly_select_self on public.ai_chat_usage_monthly
    for select using (auth.uid() = user_id);

drop policy if exists ai_chat_usage_monthly_service_all on public.ai_chat_usage_monthly;
create policy ai_chat_usage_monthly_service_all on public.ai_chat_usage_monthly
    for all to service_role using (true) with check (true);

drop policy if exists ai_chat_usage_daily_select_self on public.ai_chat_usage_daily;
create policy ai_chat_usage_daily_select_self on public.ai_chat_usage_daily
    for select using (auth.uid() = user_id);

drop policy if exists ai_chat_usage_daily_service_all on public.ai_chat_usage_daily;
create policy ai_chat_usage_daily_service_all on public.ai_chat_usage_daily
    for all to service_role using (true) with check (true);

comment on table public.ai_chat_usage_monthly is
    'Monthly counters for the free tier (e.g., 30 msgs/month). period = YYYY-MM.';
comment on table public.ai_chat_usage_daily is
    'Daily counters for paid tiers; protects against runaway cost.';

-- ===========================================================================
-- 10. anomaly_flags  (anti-cheat dossier)
-- ===========================================================================
do $$ begin
    create type public.anomaly_severity_enum as enum ('low', 'medium', 'high');
exception when duplicate_object then null; end $$;

do $$ begin
    create type public.anomaly_action_enum as enum
        ('flag', 'remove', 'shadow_ban');
exception when duplicate_object then null; end $$;

create table if not exists public.anomaly_flags (
    id              uuid        primary key default gen_random_uuid(),
    activity_id     uuid        references public.activities (id) on delete cascade,
    user_id         uuid        not null references public.profiles (id) on delete cascade,
    reason          text        not null,
    details         jsonb       not null default '{}'::jsonb,
    severity        public.anomaly_severity_enum not null default 'low',
    action_taken    public.anomaly_action_enum   not null default 'flag',
    created_at      timestamptz not null default now()
);

create index if not exists anomaly_flags_user_created_idx
    on public.anomaly_flags (user_id, created_at desc);
create index if not exists anomaly_flags_activity_idx
    on public.anomaly_flags (activity_id);
create index if not exists anomaly_flags_severity_idx
    on public.anomaly_flags (severity);
create index if not exists anomaly_flags_details_gin
    on public.anomaly_flags using gin (details);

alter table public.anomaly_flags enable row level security;

drop policy if exists anomaly_flags_service_all on public.anomaly_flags;
create policy anomaly_flags_service_all on public.anomaly_flags
    for all to service_role using (true) with check (true);

comment on table public.anomaly_flags is
    'Anti-cheat findings. Service-role only. Users never see their own flags.';

-- ===========================================================================
-- 11. push_log  (delivery + click log)
-- ===========================================================================
do $$ begin
    create type public.push_status_enum as enum
        ('queued', 'sent', 'failed', 'clicked');
exception when duplicate_object then null; end $$;

create table if not exists public.push_log (
    id          uuid        primary key default gen_random_uuid(),
    user_id     uuid        not null references public.profiles (id) on delete cascade,
    device_id   uuid        references public.devices (id) on delete set null,
    platform    text,
    payload     jsonb       not null default '{}'::jsonb,
    status      public.push_status_enum not null default 'queued',
    error       text,
    sent_at     timestamptz,
    clicked_at  timestamptz,
    created_at  timestamptz not null default now()
);

create index if not exists push_log_user_sent_idx
    on public.push_log (user_id, sent_at desc);
create index if not exists push_log_status_idx
    on public.push_log (status);
create index if not exists push_log_device_idx
    on public.push_log (device_id);
create index if not exists push_log_payload_gin
    on public.push_log using gin (payload);

alter table public.push_log enable row level security;

drop policy if exists push_log_service_all on public.push_log;
create policy push_log_service_all on public.push_log
    for all to service_role using (true) with check (true);

comment on table public.push_log is
    'Per-send log for FCM/APNs deliveries. Service-role only.';

-- ===========================================================================
-- 12. weekly_recaps
-- ===========================================================================
create table if not exists public.weekly_recaps (
    id                          uuid        primary key default gen_random_uuid(),
    user_id                     uuid        not null references public.profiles (id) on delete cascade,
    week_start                  date        not null,
    distance_total_m            integer     not null default 0 check (distance_total_m >= 0),
    time_total_s                integer     not null default 0 check (time_total_s >= 0),
    activity_count              integer     not null default 0 check (activity_count >= 0),
    longest_run_m               integer     not null default 0 check (longest_run_m >= 0),
    badges_earned               text[]      not null default '{}',
    delta_vs_last_week_pct      numeric(7,2),
    summary_vi                  text,
    created_at                  timestamptz not null default now(),
    unique (user_id, week_start)
);

create index if not exists weekly_recaps_user_week_idx
    on public.weekly_recaps (user_id, week_start desc);
create index if not exists weekly_recaps_week_idx
    on public.weekly_recaps (week_start desc);

alter table public.weekly_recaps enable row level security;

drop policy if exists weekly_recaps_select_self on public.weekly_recaps;
create policy weekly_recaps_select_self on public.weekly_recaps
    for select using (auth.uid() = user_id);

drop policy if exists weekly_recaps_service_all on public.weekly_recaps;
create policy weekly_recaps_service_all on public.weekly_recaps
    for all to service_role using (true) with check (true);

comment on table public.weekly_recaps is
    'Monday-morning recap card generated by scheduled job.';

-- ===========================================================================
-- 13. leaderboard_monthly  (materialized view, mirrors weekly)
-- ===========================================================================
do $$ begin
    if not exists (
        select 1 from pg_matviews
         where schemaname = 'public' and matviewname = 'leaderboard_monthly'
    ) then
        execute $mv$
        create materialized view public.leaderboard_monthly as
        with iso_month as (
            select date_trunc('month', now()) as month_start,
                   date_trunc('month', now()) + interval '1 month' as month_end
        ),
        monthly_activity as (
            select
                a.user_id,
                sum(a.distance_m)         as distance_total,
                sum(a.duration_s)         as time_total,
                count(*)                  as activity_count
            from public.activities a, iso_month m
            where a.started_at >= m.month_start
              and a.started_at <  m.month_end
            group by a.user_id
        ),
        joined as (
            select
                ma.user_id,
                p.country,
                p.city,
                ma.distance_total,
                ma.time_total,
                ma.activity_count
            from monthly_activity ma
            join public.profiles p on p.id = ma.user_id
            where p.is_public = true
        ),
        all_scopes as (
            select 'global'::text as scope, 'global'::text as scope_value,
                   user_id, distance_total, time_total, activity_count
              from joined
            union all
            select 'country'::text, country,
                   user_id, distance_total, time_total, activity_count
              from joined where country is not null and country <> ''
            union all
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
        $mv$;
    end if;
end $$;

create unique index if not exists leaderboard_monthly_uidx
    on public.leaderboard_monthly (scope, scope_value, user_id);
create index if not exists leaderboard_monthly_scope_rank_idx
    on public.leaderboard_monthly (scope, scope_value, rank);
create index if not exists leaderboard_monthly_user_idx
    on public.leaderboard_monthly (user_id);

comment on materialized view public.leaderboard_monthly is
    'Monthly aggregated distance/time/count per user, ranked per scope. Refresh hourly.';

create or replace function public.refresh_leaderboard_monthly()
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    begin
        refresh materialized view concurrently public.leaderboard_monthly;
    exception when others then
        refresh materialized view public.leaderboard_monthly;
    end;
end;
$$;

comment on function public.refresh_leaderboard_monthly()
    is 'Refresh leaderboard_monthly. Schedule via pg_cron hourly.';

grant select on public.leaderboard_monthly to authenticated, anon;
grant execute on function public.refresh_leaderboard_monthly() to service_role;

-- ===========================================================================
-- 14. plan_templates  (idempotent verification; canonical in seed file)
-- ===========================================================================
create table if not exists public.plan_templates (
    id                uuid        primary key default gen_random_uuid(),
    code              text        not null unique,
    name_vi           text        not null,
    name_en           text        not null,
    race_distance     text        not null check (race_distance in ('5k', '10k', 'half', 'full', 'c25k', 'walking')),
    weeks             integer     not null check (weeks between 1 and 52),
    sessions_per_week integer     not null check (sessions_per_week between 1 and 14),
    level             public.level_enum not null,
    file_path         text        not null,
    description_vi    text,
    description_en    text,
    is_active         boolean     not null default true,
    created_at        timestamptz not null default now()
);

create index if not exists plan_templates_race_idx  on public.plan_templates (race_distance);
create index if not exists plan_templates_level_idx on public.plan_templates (level);

alter table public.plan_templates enable row level security;

drop policy if exists plan_templates_select_all on public.plan_templates;
create policy plan_templates_select_all on public.plan_templates
    for select to anon, authenticated using (is_active = true);

drop policy if exists plan_templates_service_write on public.plan_templates;
create policy plan_templates_service_write on public.plan_templates
    for all to service_role using (true) with check (true);

-- ===========================================================================
-- RPC: redeem_voucher
-- Atomic transaction: lock SKU row, check stock + balance, decrement,
-- create voucher + coin_transactions ledger row + redemption audit.
-- Returns { voucher_id, code, balance_after }.
-- ===========================================================================
create or replace function public.redeem_voucher(
    p_user_id uuid,
    p_sku_id  uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_sku           public.voucher_skus%rowtype;
    v_balance       integer;
    v_lifetime_spent integer;
    v_lifetime_earn integer;
    v_balance_after integer;
    v_voucher_id    uuid;
    v_code          text;
begin
    if p_user_id is null or p_sku_id is null then
        raise exception 'redeem_voucher: user_id and sku_id required'
            using errcode = '22023';
    end if;

    -- 1. Lock the SKU row to serialize concurrent redeems.
    select * into v_sku
      from public.voucher_skus
     where id = p_sku_id
     for update;

    if not found then
        raise exception 'voucher SKU % not found', p_sku_id
            using errcode = 'P0002';
    end if;

    if not v_sku.is_active then
        raise exception 'voucher SKU % is inactive', p_sku_id
            using errcode = 'P0001';
    end if;

    if v_sku.stock <= 0 then
        raise exception 'voucher SKU % is out of stock', p_sku_id
            using errcode = 'P0001';
    end if;

    -- 2. Lock the user's coin row.
    select balance, lifetime_earned, lifetime_spent
      into v_balance, v_lifetime_earn, v_lifetime_spent
      from public.run_coins
     where user_id = p_user_id
     for update;

    if not found then
        raise exception 'user % has no run_coins row', p_user_id
            using errcode = 'P0002';
    end if;

    if v_balance < v_sku.coin_cost then
        raise exception 'insufficient balance: have %, need %', v_balance, v_sku.coin_cost
            using errcode = 'P0001';
    end if;

    v_balance_after := v_balance - v_sku.coin_cost;

    -- 3. Decrement stock.
    update public.voucher_skus
       set stock = stock - 1
     where id = p_sku_id;

    -- 4. Insert voucher (status=reserved; code populated by partner webhook).
    v_code := encode(gen_random_bytes(8), 'hex');
    insert into public.vouchers (user_id, sku_id, code, status, expires_at)
    values (p_user_id, p_sku_id, v_code, 'reserved',
            coalesce(v_sku.expires_at, now() + interval '30 days'))
    returning id into v_voucher_id;

    -- 5. Append coin ledger row + update cached balance.
    insert into public.coin_transactions
        (user_id, amount, reason, metadata, balance_after)
    values (p_user_id, -v_sku.coin_cost, 'redeem',
            jsonb_build_object('sku_id', p_sku_id, 'voucher_id', v_voucher_id),
            v_balance_after);

    update public.run_coins
       set balance        = v_balance_after,
           lifetime_spent = v_lifetime_spent + v_sku.coin_cost,
           updated_at     = now()
     where user_id = p_user_id;

    -- 6. Audit row.
    insert into public.voucher_redemptions
        (user_id, sku_id, voucher_id, coin_cost, balance_before, balance_after,
         partner_status, partner_response)
    values (p_user_id, p_sku_id, v_voucher_id, v_sku.coin_cost,
            v_balance, v_balance_after, 'pending', '{}'::jsonb);

    return jsonb_build_object(
        'voucher_id',    v_voucher_id,
        'code',          v_code,
        'balance_after', v_balance_after
    );
end;
$$;

comment on function public.redeem_voucher(uuid, uuid) is
    'Atomic voucher redemption: locks SKU + run_coins rows, debits coins, inserts voucher and audit.';

revoke all on function public.redeem_voucher(uuid, uuid) from public;
grant execute on function public.redeem_voucher(uuid, uuid) to authenticated, service_role;

-- ===========================================================================
-- RPC: check_kyc_required
-- Returns true if value_vnd > 100_000 AND user has no verified KYC OTP in
-- the last 30 days.
-- ===========================================================================
create or replace function public.check_kyc_required(
    p_user_id   uuid,
    p_value_vnd integer
)
returns boolean
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
    v_recent_verified boolean;
begin
    if p_value_vnd is null or p_value_vnd <= 100000 then
        return false;
    end if;

    select exists (
        select 1
          from public.kyc_otps
         where user_id = p_user_id
           and verified = true
           and created_at >= now() - interval '30 days'
    ) into v_recent_verified;

    return not v_recent_verified;
end;
$$;

comment on function public.check_kyc_required(uuid, integer) is
    'Returns true when a redemption requires fresh KYC (value > 100k VND, no verified OTP in 30d).';

revoke all on function public.check_kyc_required(uuid, integer) from public;
grant execute on function public.check_kyc_required(uuid, integer) to authenticated, service_role;

-- ===========================================================================
-- End of 20260521002000_feature_tables.sql
-- ===========================================================================
