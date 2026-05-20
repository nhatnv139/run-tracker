-- 20260520000200_waitlist.sql
-- Public waitlist: anyone can insert (handled in RLS migration), only service_role can read.

create type public.waitlist_persona_enum as enum ('newcomer', 'walker', 'runner', 'coach');

create table public.waitlist (
    id          uuid        primary key default gen_random_uuid(),
    email       citext      unique not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    persona     public.waitlist_persona_enum,
    source      text,
    ip_country  text,
    referrer    text,
    created_at  timestamptz not null default now()
);

create index waitlist_persona_idx    on public.waitlist (persona);
create index waitlist_created_at_idx on public.waitlist (created_at desc);

comment on table public.waitlist is 'Pre-launch signups from the landing page.';
