# RunVie Landing

Pre-launch landing page cho RunVie - app chạy bộ và đếm bước AI tiếng Việt.

## Stack

- Next.js 15 (App Router) + TypeScript
- Tailwind CSS 4
- shadcn/ui patterns (Button, Input, Accordion, Radio, Badge, Card)
- Framer Motion cho hero và scroll animations
- Supabase JS client cho waitlist (fallback demo nếu chưa có env)
- next-themes cho dark mode toggle
- sonner cho toast notifications

## Bắt đầu

```bash
npm install
cp .env.example .env.local
# Điền NEXT_PUBLIC_SUPABASE_URL và NEXT_PUBLIC_SUPABASE_ANON_KEY (tuỳ chọn)
npm run dev
```

Mở http://localhost:3000.

Nếu chưa có Supabase, form vẫn chạy được ở chế độ demo (luôn trả về thành công sau 600ms).

## Build production

```bash
npm run build
npm run start
```

## Cấu trúc

```
landing/
  app/
    layout.tsx          # Root layout + metadata + theme provider
    page.tsx            # Trang chủ - compose tất cả section
    globals.css         # Tailwind 4 + design tokens Aurora Energy
    sitemap.ts
    robots.ts
    privacy/page.tsx
    terms/page.tsx
  components/
    nav.tsx
    hero.tsx
    phone-mockup.tsx
    usp.tsx
    features.tsx
    compare.tsx
    pricing.tsx
    faq.tsx
    waitlist.tsx
    footer.tsx
    theme-provider.tsx
    theme-toggle.tsx
    ui/
      button.tsx
      input.tsx
      label.tsx
      radio-group.tsx
      accordion.tsx
      badge.tsx
      card.tsx
  lib/
    utils.ts            # cn() helper
    supabase.ts         # Client + submitWaitlist()
  public/
    favicon.svg
    apple-icon.svg
    og.svg              # OpenGraph image 1200x630
```

## Supabase schema

Tạo bảng `waitlist` trên Supabase:

```sql
create table public.waitlist (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  user_type text not null check (user_type in ('beginner','walker','runner','trainer')),
  source text default 'landing',
  created_at timestamptz default now(),
  unique(email)
);

alter table public.waitlist enable row level security;

create policy "anon insert waitlist" on public.waitlist
  for insert to anon
  with check (true);
```

## Deploy Vercel

```bash
npm i -g vercel
vercel
```

Hoặc dùng dashboard Vercel: Import git repo, chọn folder `landing/`, set environment variables (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_SITE_URL`), deploy.

## Brand Aurora Energy

| Token        | Hex       | Dùng cho                |
| ------------ | --------- | ----------------------- |
| Coral        | `#FF5A36` | Primary CTA, accent     |
| Mint         | `#00D4A8` | Success, secondary      |
| Lavender     | `#7B5CFF` | Tertiary, AI element    |
| BG Light     | `#FAFAF7` | Background sáng         |
| BG Dark      | `#0A0A0A` | Background tối          |

Font: **Be Vietnam Pro** (Google Fonts, `subsets: latin + vietnamese`).

## Lighthouse target

- Performance >= 95
- Accessibility >= 95
- Best Practices >= 95
- SEO = 100

Tối ưu đã áp dụng:
- `next/font` (Be Vietnam Pro) tự host, không request bên ngoài
- Không dùng raster image, chỉ SVG inline và `<svg>` cho mockup, OG, icons
- `optimizePackageImports` cho lucide-react và framer-motion
- `next/image` ready (chưa dùng vì chỉ có SVG)
- Tailwind 4 với CSS variables, không CSS-in-JS runtime
- Compression bật, `poweredByHeader` tắt

## License

MIT (C) 2026 RunVie
