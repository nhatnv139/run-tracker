-- seed_voucher_partners.sql
-- Placeholder voucher partners + SKUs for the RunVie redemption store.
-- These rows are safe to re-apply (ON CONFLICT DO NOTHING on the unique sku).
--
-- Schema (created here additively so the seed is self-contained):
--   voucher_partners(id, name, slug, logo_url, is_active)
--   voucher_skus(id, partner_id, sku, name_vi, name_en, value_vnd,
--                coin_cost, stock, expires_at, is_active)
--
-- The voucher catalog lives outside the main migration sequence on
-- purpose because partner availability varies by region/launch phase.

create table if not exists public.voucher_partners (
    id          uuid        primary key default gen_random_uuid(),
    name        text        not null unique,
    slug        text        not null unique,
    logo_url    text,
    is_active   boolean     not null default true,
    created_at  timestamptz not null default now()
);

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
    created_at  timestamptz not null default now()
);

create index if not exists voucher_skus_partner_idx on public.voucher_skus (partner_id);
create index if not exists voucher_skus_active_idx  on public.voucher_skus (is_active) where is_active = true;

alter table public.voucher_partners enable row level security;
alter table public.voucher_skus     enable row level security;

drop policy if exists voucher_partners_select_all on public.voucher_partners;
create policy voucher_partners_select_all on public.voucher_partners
    for select to anon, authenticated using (is_active = true);

drop policy if exists voucher_partners_service_write on public.voucher_partners;
create policy voucher_partners_service_write on public.voucher_partners
    for all to service_role using (true) with check (true);

drop policy if exists voucher_skus_select_all on public.voucher_skus;
create policy voucher_skus_select_all on public.voucher_skus
    for select to anon, authenticated using (is_active = true);

drop policy if exists voucher_skus_service_write on public.voucher_skus;
create policy voucher_skus_service_write on public.voucher_skus
    for all to service_role using (true) with check (true);

-- ---------------------------------------------------------------
-- Partners
-- ---------------------------------------------------------------
insert into public.voucher_partners (name, slug, logo_url) values
    ('Shopee',    'shopee',    'https://cdn.runvie.app/partners/shopee.png'),
    ('Grab',      'grab',      'https://cdn.runvie.app/partners/grab.png'),
    ('Lazada',    'lazada',    'https://cdn.runvie.app/partners/lazada.png'),
    ('MoMo',      'momo',      'https://cdn.runvie.app/partners/momo.png'),
    ('Highlands', 'highlands', 'https://cdn.runvie.app/partners/highlands.png'),
    ('The Coffee House', 'tch', 'https://cdn.runvie.app/partners/tch.png')
on conflict (name) do nothing;

-- ---------------------------------------------------------------
-- SKUs (one per partner, plus a few extras for higher tiers)
-- coin_cost ~= value_vnd / 1000 as a starting ratio.
-- ---------------------------------------------------------------
insert into public.voucher_skus (partner_id, sku, name_vi, name_en, value_vnd, coin_cost, stock)
select p.id, s.sku, s.name_vi, s.name_en, s.value_vnd, s.coin_cost, s.stock
  from (values
    ('shopee',    'shopee_50k',   'Voucher Shopee 50.000d',       'Shopee 50K Voucher',       50000,  50,  1000),
    ('shopee',    'shopee_100k',  'Voucher Shopee 100.000d',      'Shopee 100K Voucher',     100000, 100,   500),
    ('grab',      'grab_30k',     'Ma giam 30.000d Grab',         'Grab 30K Promo Code',      30000,  30,  1000),
    ('grab',      'grab_50k',     'Ma giam 50.000d Grab',         'Grab 50K Promo Code',      50000,  50,   500),
    ('lazada',    'lazada_75k',   'Voucher Lazada 75.000d',       'Lazada 75K Voucher',       75000,  75,   500),
    ('momo',      'momo_20k',     'Qua tang MoMo 20.000d',        'MoMo 20K Gift',            20000,  20,  2000),
    ('momo',      'momo_50k',     'Qua tang MoMo 50.000d',        'MoMo 50K Gift',            50000,  50,   500),
    ('highlands', 'highlands_freeze', 'Freeze tra trai cay Highlands', 'Highlands Fruit Freeze', 60000, 60, 300),
    ('tch',       'tch_milktea',  'Tra sua The Coffee House',     'TCH Milk Tea',             55000,  55,   300)
  ) as s(slug, sku, name_vi, name_en, value_vnd, coin_cost, stock)
  join public.voucher_partners p on p.slug = s.slug
on conflict (sku) do nothing;
