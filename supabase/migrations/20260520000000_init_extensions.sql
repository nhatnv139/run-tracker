-- 20260520000000_init_extensions.sql
-- Enable required Postgres extensions for RunVie.
-- PostGIS provides geography(POINT,4326) used by activities and activity_points.
-- pgcrypto / uuid-ossp provide gen_random_uuid() and uuid_generate_v4().

create extension if not exists "pgcrypto"      with schema extensions;
create extension if not exists "uuid-ossp"     with schema extensions;
create extension if not exists "postgis"       with schema extensions;
create extension if not exists "citext"        with schema extensions;
create extension if not exists "pg_trgm"       with schema extensions;

-- Make extension functions resolvable without schema-qualification.
alter database postgres set search_path to "$user", public, extensions;

comment on extension postgis  is 'PostGIS geometry/geography types for GPS tracking.';
comment on extension pgcrypto is 'gen_random_uuid() and crypto helpers.';
