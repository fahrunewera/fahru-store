-- Jalankan seluruh SQL ini di Supabase > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  category text not null default 'Lainnya',
  price integer not null check (price >= 0),
  image_url text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete restrict,
  total integer not null check (total >= 0),
  status text not null default 'menunggu_pembayaran'
    check (status in ('menunggu_pembayaran','diproses','selesai','dibatalkan')),
  created_at timestamptz not null default now()
);
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  quantity integer not null check (quantity > 0),
  unit_price integer not null check (unit_price >= 0)
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles(id,email) values(new.id,new.email);
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

create policy "profiles read own" on public.profiles for select to authenticated using (id=auth.uid());
create policy "products public read active" on public.products for select to anon, authenticated using (active=true or exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));
create policy "admin insert products" on public.products for insert to authenticated with check (exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));
create policy "admin update products" on public.products for update to authenticated using (exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin)) with check (exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));
create policy "users read own orders admin all" on public.orders for select to authenticated using (user_id=auth.uid() or exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));
create policy "users create own orders" on public.orders for insert to authenticated with check (user_id=auth.uid());
create policy "admin update orders" on public.orders for update to authenticated using (exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin)) with check (exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));
create policy "read own order items admin" on public.order_items for select to authenticated using (exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()) or exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));
create policy "insert items into own orders" on public.order_items for insert to authenticated with check (exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()));

-- Setelah mendaftar akun melalui website, jalankan perintah ini di SQL Editor
-- dengan mengganti email menjadi email akun admin milikmu:
-- update public.profiles set is_admin = true where email = 'EMAIL_ADMIN_KAMU';
