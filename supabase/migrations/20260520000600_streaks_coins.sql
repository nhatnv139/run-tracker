-- 20260520000600_streaks_coins.sql
-- Gamification ledgers: streaks + RunCoin balances + transactions.

create table public.streaks (
    user_id                 uuid    primary key references public.profiles (id) on delete cascade,
    current_days            integer not null default 0 check (current_days >= 0),
    longest_days            integer not null default 0 check (longest_days >= 0),
    last_activity_date      date,
    freeze_count            integer not null default 0 check (freeze_count >= 0),
    freeze_used_this_week   integer not null default 0 check (freeze_used_this_week >= 0),
    week_resets_at          timestamptz not null default (date_trunc('week', now()) + interval '7 days'),
    updated_at              timestamptz not null default now()
);

comment on table public.streaks is 'Per-user streak counter; freeze tokens prevent breakage.';

create table public.run_coins (
    user_id          uuid    primary key references public.profiles (id) on delete cascade,
    balance          integer not null default 0,
    lifetime_earned  integer not null default 0 check (lifetime_earned >= 0),
    lifetime_spent   integer not null default 0 check (lifetime_spent  >= 0),
    updated_at       timestamptz not null default now(),
    constraint run_coins_balance_consistency
        check (balance = lifetime_earned - lifetime_spent)
);

comment on table public.run_coins is 'Cached coin balance; source of truth = coin_transactions.';

create type public.coin_reason_enum as enum (
    'km_earn', 'quest', 'referral', 'redeem', 'admin_grant', 'challenge_prize', 'badge_reward'
);

create table public.coin_transactions (
    id              uuid        primary key default gen_random_uuid(),
    user_id         uuid        not null references public.profiles (id) on delete cascade,
    amount          integer     not null check (amount <> 0),
    reason          public.coin_reason_enum not null,
    metadata        jsonb       not null default '{}'::jsonb,
    balance_after   integer     not null,
    created_at      timestamptz not null default now()
);

create index coin_tx_user_created_idx on public.coin_transactions (user_id, created_at desc);
create index coin_tx_reason_idx       on public.coin_transactions (reason);

comment on table public.coin_transactions is 'Append-only ledger; positive = earn, negative = spend.';
