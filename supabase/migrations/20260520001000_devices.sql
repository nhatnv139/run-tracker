-- 20260520001000_devices.sql
-- Push notification + telemetry device registry.

create type public.device_platform_enum as enum ('ios', 'android', 'watch_os', 'wear_os', 'web');

create table public.devices (
    id           uuid        primary key default gen_random_uuid(),
    user_id      uuid        not null references public.profiles (id) on delete cascade,
    platform     public.device_platform_enum not null,
    push_token   text,
    app_version  text,
    os_version   text,
    last_seen    timestamptz not null default now(),
    created_at   timestamptz not null default now(),
    updated_at   timestamptz not null default now(),
    unique (user_id, push_token)
);

create index devices_user_idx       on public.devices (user_id);
create index devices_last_seen_idx  on public.devices (last_seen desc);
create index devices_platform_idx   on public.devices (platform);

comment on table public.devices is 'Devices registered for a user; push_token used by FCM/APNs.';
