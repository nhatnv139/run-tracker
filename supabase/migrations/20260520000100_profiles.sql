-- 20260520000100_profiles.sql
-- profiles table extends auth.users with RunVie-specific fields.

create type public.gender_enum   as enum ('male', 'female', 'other');
create type public.goal_enum     as enum ('weight_loss', 'endurance', 'speed', 'walk', 'race');
create type public.level_enum    as enum ('beginner', 'intermediate', 'advanced');
create type public.units_enum    as enum ('metric', 'imperial');
create type public.language_enum as enum ('vi', 'en', 'es', 'fr', 'ja', 'ko', 'zh', 'th', 'id');

create table public.profiles (
    id            uuid        primary key references auth.users (id) on delete cascade,
    username      citext      unique not null
                              check (char_length(username) between 3 and 30
                                     and username ~ '^[a-z0-9_\.]+$'),
    display_name  text        not null check (char_length(display_name) between 1 and 60),
    avatar_url    text,
    bio           text        check (char_length(bio) <= 280),
    height_cm     smallint    check (height_cm between 80 and 250),
    weight_kg     numeric(5,2) check (weight_kg between 20 and 300),
    dob           date        check (dob > '1900-01-01' and dob < current_date),
    gender        public.gender_enum,
    goal          public.goal_enum,
    level         public.level_enum   not null default 'beginner',
    units         public.units_enum   not null default 'metric',
    language      public.language_enum not null default 'vi',
    max_hr        smallint    check (max_hr between 80 and 230),
    country       text,
    city          text,
    is_public     boolean     not null default true,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);

create index profiles_username_trgm_idx on public.profiles using gin (username extensions.gin_trgm_ops);
create index profiles_country_city_idx  on public.profiles (country, city);

comment on table public.profiles is 'RunVie user profile; 1:1 with auth.users.';
comment on column public.profiles.is_public is 'When true, activities are readable by anyone (subject to RLS).';
