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
  impact_ar text,  -- concrete outcome ("feeds a family for a week")
  impact_fr text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- App config (min_version for force-update, etc.)
create table app_config (
  key text primary key,
  value text not null
);

alter table app_config enable row level security;

create policy "Anyone reads config"
  on app_config for select using (true);

create policy "Admin manages config"
  on app_config for all using (is_admin());

insert into app_config (key, value) values ('min_version', '1.0.0');

-- 4. Gifts
create table gifts (
  id uuid primary key default gen_random_uuid(),
  giver_id uuid references profiles(id) on delete cascade not null,
  gift_type_id int references gift_types(id) not null,
  amount int not null,
  payment_method text not null check (payment_method in ('card', 'cashplus')),
  payment_status text not null default 'pending'
    check (payment_status in ('pending', 'paid', 'delivered', 'thanked')),
  is_anonymous boolean not null default false,
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
-- AUTH HELPERS
-- ============================================

-- Create the profile automatically on sign-up (works even when
-- email confirmation is enabled — the client has no session yet)
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, locale)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''), 'ar')
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- Self-service account deletion (app re-authenticates first).
-- Cascades wipe the profile, gifts, and connections.
create or replace function delete_user()
returns void as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$ language plpgsql security definer;

revoke execute on function delete_user() from public, anon;
grant execute on function delete_user() to authenticated;

-- ============================================
-- REALTIME (inbox live updates)
-- ============================================

alter publication supabase_realtime add table connections;

-- ============================================
-- SEED: starter gift types (prices in centimes MAD)
-- 15000 = 150 MAD, 10000 = 100 MAD, etc.
-- ============================================

insert into gift_types (name_ar, name_fr, icon, default_price, impact_ar, impact_fr) values
  ('سلة غذائية', 'Panier alimentaire', 'food_basket', 15000,
   'تكفي عائلة لأسبوع كامل', 'Nourrit une famille pendant une semaine'),
  ('أدوات مدرسية', 'Fournitures scolaires', 'school', 10000,
   'تجهّز تلميذاً لموسم دراسي', 'Équipe un élève pour la rentrée'),
  ('ملابس دافئة', 'Vêtements chauds', 'clothing', 20000,
   'تدفئ طفلاً طوال الشتاء', 'Habille un enfant pour tout l''hiver'),
  ('أدوية', 'Médicaments', 'medicine', 25000,
   'علاج شهر كامل لمريض', 'Un mois de traitement pour un patient'),
  ('ماء نظيف', 'Eau potable', 'water', 5000,
   'ماء نظيف لعائلة لأسبوع', 'De l''eau potable pour une famille pendant une semaine');
