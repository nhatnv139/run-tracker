-- 20260520000700_challenges.sql
-- Solo / team / corporate / charity / sponsored challenges.

create type public.challenge_type_enum      as enum ('solo', 'team', 'corporate', 'charity', 'sponsored');
create type public.challenge_goal_type_enum as enum ('distance', 'duration', 'elevation', 'streak');

create table public.challenges (
    id                uuid        primary key default gen_random_uuid(),
    name_vi           text        not null,
    name_en           text        not null,
    description_vi    text,
    description_en    text,
    type              public.challenge_type_enum      not null,
    start_at          timestamptz not null,
    end_at            timestamptz not null,
    goal_type         public.challenge_goal_type_enum not null,
    goal_value        integer     not null check (goal_value > 0),
    sponsor_brand     text,
    prize_jsonb       jsonb       not null default '{}'::jsonb,
    max_participants  integer              check (max_participants is null or max_participants > 0),
    is_public         boolean     not null default true,
    cover_url         text,
    created_by        uuid        references public.profiles (id) on delete set null,
    created_at        timestamptz not null default now(),
    updated_at        timestamptz not null default now(),
    constraint challenges_time_window check (end_at > start_at)
);

create index challenges_active_idx     on public.challenges (start_at, end_at);
create index challenges_type_idx       on public.challenges (type);
create index challenges_is_public_idx  on public.challenges (is_public) where is_public = true;

comment on table public.challenges is 'Time-bounded challenges; participants tracked separately.';

create table public.challenge_participants (
    challenge_id  uuid        not null references public.challenges (id) on delete cascade,
    user_id       uuid        not null references public.profiles   (id) on delete cascade,
    joined_at     timestamptz not null default now(),
    progress      integer     not null default 0 check (progress >= 0),
    completed_at  timestamptz,
    rank          integer,
    primary key (challenge_id, user_id)
);

create index cp_user_idx                 on public.challenge_participants (user_id);
create index cp_challenge_progress_idx   on public.challenge_participants (challenge_id, progress desc);
create index cp_challenge_completed_idx  on public.challenge_participants (challenge_id, completed_at);

comment on table public.challenge_participants is 'Per-user progress in a challenge.';
