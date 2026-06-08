-- ============================================================
--  NCL Deals – Supabase Setup
--  Run this entire file in: Supabase > SQL Editor > New Query
-- ============================================================


-- ── 1. DEALS TABLE ──────────────────────────────────────────

create table if not exists deals (
  id          bigint        generated always as identity primary key,
  venue       text          not null,
  area        text          not null check (area in ('Osborne Road','City Centre')),
  category    text          not null check (category in ('Bar / Pub','Club')),
  days        text[]        not null,   -- e.g. {"Mon","Wed","Thu"}
  deal        text          not null,
  time        text          not null,
  tag         text          not null,
  color       text          not null default '#7c3aed',
  verified    boolean       not null default false,
  source      text,
  active      boolean       not null default true,
  created_at  timestamptz   not null default now(),
  updated_at  timestamptz   not null default now()
);

-- Auto-update updated_at on every row change
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists deals_updated_at on deals;
create trigger deals_updated_at
  before update on deals
  for each row execute function set_updated_at();


-- ── 2. VENUE SUBMISSIONS TABLE ───────────────────────────────
--  Venues fill in a public form; admin reviews before publishing

create table if not exists submissions (
  id          bigint        generated always as identity primary key,
  venue       text          not null,
  area        text          not null,
  category    text          not null,
  days        text[]        not null,
  deal        text          not null,
  time        text          not null,
  tag         text,
  contact     text,          -- venue contact email (private)
  status      text          not null default 'pending'
                            check (status in ('pending','approved','rejected')),
  created_at  timestamptz   not null default now()
);


-- ── 3. ROW LEVEL SECURITY ────────────────────────────────────

-- DEALS: anyone can read active deals; only authenticated users can write
alter table deals enable row level security;

create policy "Public can read active deals"
  on deals for select
  using (active = true);

create policy "Authenticated users can insert deals"
  on deals for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update deals"
  on deals for update
  to authenticated
  using (true);

create policy "Authenticated users can delete deals"
  on deals for delete
  to authenticated
  using (true);

-- SUBMISSIONS: anyone can insert; only authenticated users can read/update
alter table submissions enable row level security;

create policy "Anyone can submit a deal"
  on submissions for insert
  with check (true);

create policy "Authenticated users can read submissions"
  on submissions for select
  to authenticated
  using (true);

create policy "Authenticated users can update submissions"
  on submissions for update
  to authenticated
  using (true);


-- ── 4. SEED DATA (real verified Newcastle deals) ─────────────

insert into deals (venue, area, category, days, deal, time, tag, color, verified, source) values
  ('Holy Hobo',       'Osborne Road', 'Bar / Pub', '{"Tue"}',
   'Twosday Tuesday: 2-for-1 on everything all night – every single drink on the menu',
   '3pm – 2am', '2-4-1 All Night', '#7c3aed', true, 'Skiddle / TripAdvisor'),

  ('Bar Blanc',       'Osborne Road', 'Bar / Pub', '{"Tue"}',
   '£2 Tuesdays – cheap drinks all night plus the Big Red Button discount game',
   '5pm – late', '£2 Drinks', '#db2777', true, 'Skiddle / The Tab'),

  ('Bar Blanc',       'Osborne Road', 'Bar / Pub', '{"Thu"}',
   '2-for-1 cocktails all evening',
   '5pm – 7pm', 'Cocktails', '#db2777', true, 'Skiddle'),

  ('Osbornes',        'Osborne Road', 'Bar / Pub', '{"Tue"}',
   '£2 Tuesday on selected pints – busiest student night on the road',
   'From 5pm', '£2 Pints', '#0891b2', true, 'High Life North'),

  ('Spy Bar',         'Osborne Road', 'Bar / Pub', '{"Tue"}',
   'Half-price burgers all day – perfect deal before heading out',
   'All day', 'Food Deal', '#ca8a04', true, 'High Life North'),

  ('Jam Jar',         'Osborne Road', 'Bar / Pub', '{"Mon","Tue","Wed","Sun"}',
   'Big Red Button: win 10%, 25%, half price or a free round – 2 happy hours nightly',
   '9pm–10pm + 4pm–7pm (Tue/Wed)', 'Happy Hour', '#16a34a', true, 'The Tab Newcastle'),

  ('Digital',         'City Centre',  'Club',      '{"Mon"}',
   'Digital Mondays – longest-running student night, 4 rooms of anthems across all genres',
   '10pm – 4am', 'Student Night', '#7c3aed', true, 'Skiddle'),

  ('Digital (Think Tank)', 'City Centre', 'Club',  '{"Fri"}',
   'Feral Fridays – 3x Trebles £7.50, 4x J-Bombs £10, £3 VKs all night',
   '10pm – 4am', 'Feral Friday', '#7c3aed', true, 'Digital website / Fatsoma'),

  ('Tup Tup Palace',  'City Centre',  'Club',      '{"Wed"}',
   'Playground Wednesdays – Newcastle''s rowdiest student night (since 2001), sports society night',
   '10pm – 3am', 'Playground', '#db2777', true, 'Skiddle'),

  ('The Points',      'City Centre',  'Club',      '{"Thu"}',
   'Skint – £1 tickets, £1 Sourz shots, 3x Trebles for £9.50. Newcastle''s biggest student Thursday',
   '10pm – 3am', '£1 Drinks', '#16a34a', true, 'Fatsoma / Skint Instagram'),

  ('Flares',          'City Centre',  'Club',      '{"Wed","Thu","Fri"}',
   'Retro 70s student nights – free entry on student nights, cheap drinks, cheesy anthems',
   '9pm – late', 'Free Entry', '#ca8a04', true, 'Skiddle'),

  ('Soho Rooms',      'City Centre',  'Club',      '{"Fri","Sat"}',
   'Famous Toon Trebs (3x vodka + mixer) – 4 rooms of music, voted best club by The Tab',
   '10pm – 4am', 'Trebles', '#db2777', true, 'Skiddle / The Tab'),

  ('Cosmic Ballroom', 'City Centre',  'Club',      '{"Wed","Thu"}',
   'Weekly student nights – trance, techno and house from top DJs, student-priced entry',
   '10pm – 4am', 'Student Night', '#0891b2', true, 'Skiddle'),

  ('Powerhouse',      'City Centre',  'Club',      '{"Sat"}',
   'PHUK Super Saturdays – 4 floors, 3 rooms, open until 5am, Co2 cannons & lasers',
   '10pm – 5am', 'Open til 5am', '#dc2626', true, 'Skiddle / Collegiate');


-- ── Done! ────────────────────────────────────────────────────
-- After running this:
--   1. Go to Authentication > Users and create your admin account
--   2. Copy your Project URL and anon key from Settings > API
--   3. Paste them into index.html where indicated (SUPABASE_URL, SUPABASE_ANON_KEY)
