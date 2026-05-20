-- 20260520000900_social.sql
-- Social graph: directed follows (follower -> followee).

create table public.follows (
    follower_id  uuid        not null references public.profiles (id) on delete cascade,
    followee_id  uuid        not null references public.profiles (id) on delete cascade,
    created_at   timestamptz not null default now(),
    primary key (follower_id, followee_id),
    constraint follows_no_self check (follower_id <> followee_id)
);

create index follows_followee_idx on public.follows (followee_id, created_at desc);
create index follows_follower_idx on public.follows (follower_id, created_at desc);

comment on table public.follows is 'follower_id follows followee_id.';
