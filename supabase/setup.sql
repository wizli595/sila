-- ============================================
-- SILA DATABASE SETUP
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor > New Query)
-- ============================================

-- 1. User roles
create type user_role as enum ('user', 'admin');

-- 2. Profiles (extends auth.users)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text not null,
  phone text,
  locale text not null default 'ar',
  role user_role not null default 'user',
  created_at timestamptz not null default now()
);

-- 3. Gift types (admin-managed)
create table gift_types (
  id serial primary key,
  name_ar text not null,
  name_fr text not null,
  icon text not null,
  default_price int not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- 4. Gifts
create table gifts (
  id uuid primary key default gen_random_uuid(),
  giver_id uuid references profiles(id) on delete cascade not null,
  gift_type_id int references gift_types(id) not null,
  amount int not null,
  payment_method text not null check (payment_method in ('card', 'cashplus')),
  payment_status text not null default 'pending'
    check (payment_status in ('pending', 'paid', 'delivered', 'thanked')),
  created_at timestamptz not null default now()
);

-- 5. Connections (the thank-you)
create table connections (
  id uuid primary key default gen_random_uuid(),
  gift_id uuid references gifts(id) on delete cascade unique not null,
  recipient_name text,
  photo_url text,
  note_ar text,
  note_fr text,
  delivered_at timestamptz,
  created_at timestamptz not null default now()
);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

-- Helper: check if current user is admin
create or replace function is_admin()
returns boolean as $$
  select exists (
    select 1 from profiles
    where id = auth.uid() and role = 'admin'
  );
$$ language sql security definer stable;

-- PROFILES
alter table profiles enable row level security;

create policy "Users read own profile"
  on profiles for select using (id = auth.uid() or is_admin());

create policy "Users insert own profile"
  on profiles for insert with check (id = auth.uid());

create policy "Users update own profile"
  on profiles for update using (id = auth.uid());

create policy "Admin full access profiles"
  on profiles for all using (is_admin());

-- GIFT TYPES (everyone reads, admin writes)
alter table gift_types enable row level security;

create policy "Anyone reads active gift types"
  on gift_types for select using (is_active = true or is_admin());

create policy "Admin manages gift types"
  on gift_types for all using (is_admin());

-- GIFTS
alter table gifts enable row level security;

create policy "Users read own gifts"
  on gifts for select using (giver_id = auth.uid() or is_admin());

create policy "Users create own gifts"
  on gifts for insert with check (giver_id = auth.uid());

create policy "Admin full access gifts"
  on gifts for all using (is_admin());

-- CONNECTIONS
alter table connections enable row level security;

create policy "Users read own connections"
  on connections for select using (
    gift_id in (select id from gifts where giver_id = auth.uid())
    or is_admin()
  );

create policy "Admin manages connections"
  on connections for all using (is_admin());

-- ============================================
-- STORAGE (thank-you photos)
-- ============================================

insert into storage.buckets (id, name, public)
values ('thank-you-photos', 'thank-you-photos', true);

create policy "Anyone can view photos"
  on storage.objects for select
  using (bucket_id = 'thank-you-photos');

create policy "Admin uploads photos"
  on storage.objects for insert
  with check (bucket_id = 'thank-you-photos' and is_admin());

-- ============================================
-- SEED: starter gift types (prices in centimes MAD)
-- 15000 = 150 MAD, 10000 = 100 MAD, etc.
-- ============================================

insert into gift_types (name_ar, name_fr, icon, default_price) values
  ('سلة غذائية', 'Panier alimentaire', 'food_basket', 15000),
  ('أدوات مدرسية', 'Fournitures scolaires', 'school', 10000),
  ('ملابس دافئة', 'Vêtements chauds', 'clothing', 20000),
  ('أدوية', 'Médicaments', 'medicine', 25000),
  ('ماء نظيف', 'Eau potable', 'water', 5000);
