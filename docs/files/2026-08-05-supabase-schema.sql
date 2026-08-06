-- ============================================================
-- MICHAELIN MAP — SUPABASE SCHEMA
-- Run this in the Supabase SQL Editor BEFORE prompting Lovable.
-- ============================================================

create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- PLACES
-- ------------------------------------------------------------
create table places (
  id                  uuid primary key default uuid_generate_v4(),
  name                text not null,
  slug                text unique,

  -- Classification
  place_type          text not null default 'unclassified',
    -- restaurant | bar | food_truck | dessert | winery | hotel
    -- | grocery | shop | outdoors | unclassified
  tier                text,
    -- Restaurants: destination | experience | fair
    -- Bars:        cool | fair
    -- Null for non-rated types and unvisited places
  starred             boolean not null default false,
  visited             boolean not null default true,   -- false = Try List
  status              text not null default 'unreviewed',
    -- unreviewed | published | closed | hidden

  -- Geography (three levels)
  country             text,
  city                text,          -- the gate value
  area                text,          -- null below density threshold
  geo_source          text default 'derived',   -- derived | override
  lat                 numeric(10,7),
  lng                 numeric(10,7),
  address             text,

  -- Hydrated from Google Places
  google_place_id     text unique,
  phone               text,
  website             text,
  hours               jsonb,
  price_band          text,          -- $ | $$ | $$$ | $$$$
  price_band_source   text default 'derived',

  -- Curator judgment — NEVER written by sync
  the_dish            text,
  curator_note        text,
  story               text,          -- "why it matters to me"
  last_visited        date,

  -- Provenance
  apple_id            text,
  source_guides       text[],        -- original Apple guide names, audit only
  source              text default 'apple_csv',  -- apple_csv | mymaps_sync | manual
  mymaps_feature_id   text,
  first_synced_at     timestamptz,
  last_seen_in_sync   timestamptz,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),

  -- A place he hasn't visited cannot be rated or starred
  constraint tier_requires_visit   check (tier is null or visited = true),
  constraint star_requires_visit   check (starred = false or visited = true),
  -- "One dish only" equivalent: if the_dish drives the display, keep it honest
  constraint published_needs_city  check (status <> 'published' or city is not null)
);

create index places_city_idx       on places(city) where status = 'published';
create index places_type_idx       on places(place_type);
create index places_tier_idx       on places(tier);
create index places_status_idx     on places(status);
create index places_geo_idx        on places(lat, lng);

-- ------------------------------------------------------------
-- TAGS — faceted, controlled vocabulary, no free-text creation
-- ------------------------------------------------------------
create table tags (
  id           uuid primary key default uuid_generate_v4(),
  facet        text not null,
    -- cuisine | format | occasion | vibe | logistics | dietary | character
  label        text not null,
  slug         text not null,
  is_derived   boolean not null default false,  -- blocks manual assignment
  sort_order   int not null default 0,
  active       boolean not null default true,
  unique (facet, slug)
);

create table place_tags (
  place_id uuid not null references places(id) on delete cascade,
  tag_id   uuid not null references tags(id)   on delete cascade,
  primary key (place_id, tag_id)
);

-- ------------------------------------------------------------
-- CODES — curator-created interface transformations
-- ------------------------------------------------------------
create table codes (
  id                 uuid primary key default uuid_generate_v4(),
  code               text not null unique,   -- stored uppercase
  label              text,                   -- admin-facing description
  message            text,                   -- banner copy
  theme              jsonb,                  -- colors + map style overrides
  pin_style          jsonb,
  preset_filter      jsonb,
  highlighted_places uuid[],
  starts_at          timestamptz,
  ends_at            timestamptz,
  active             boolean not null default true,
  created_at         timestamptz not null default now()
);

-- ------------------------------------------------------------
-- FIELD REPORTS — constrained-input visitor questions
-- ------------------------------------------------------------
create table questions (
  id               uuid primary key default uuid_generate_v4(),
  prompt           text not null,
  input_type       text not null,
    -- number | color | slider | single_choice | yes_no | compound | text_short
  unit_label       text,
  options          jsonb,
  slider_labels    jsonb,
  judgment_prompt  text,
  requires_review  boolean not null default false,
  weight           int not null default 1,
  active           boolean not null default true
);

create table field_reports (
  id            uuid primary key default uuid_generate_v4(),
  place_id      uuid not null references places(id) on delete cascade,
  question_id   uuid not null references questions(id) on delete cascade,
  answer        jsonb not null,
  judgment      text,          -- good | bad | neutral
  status        text not null default 'published',  -- published | pending | rejected
  session_hash  text,          -- rate limiting only, not identifying
  submitted_at  timestamptz not null default now()
);

create index field_reports_place_idx on field_reports(place_id) where status = 'published';

-- ------------------------------------------------------------
-- SYNC AUDIT
-- ------------------------------------------------------------
create table sync_runs (
  id              uuid primary key default uuid_generate_v4(),
  started_at      timestamptz not null default now(),
  finished_at     timestamptz,
  status          text,        -- success | partial | failed
  features_found  int,
  new_places      int,
  missing_places  int,
  error_detail    text
);

-- ------------------------------------------------------------
-- ROW LEVEL SECURITY
-- Public reads published data. Only authenticated curator writes.
-- ------------------------------------------------------------
alter table places        enable row level security;
alter table tags          enable row level security;
alter table place_tags    enable row level security;
alter table codes         enable row level security;
alter table questions     enable row level security;
alter table field_reports enable row level security;
alter table sync_runs     enable row level security;

create policy "public reads published places" on places
  for select using (status = 'published');
create policy "curator full access places" on places
  for all using (auth.role() = 'authenticated');

create policy "public reads active tags" on tags
  for select using (active = true);
create policy "curator full access tags" on tags
  for all using (auth.role() = 'authenticated');

create policy "public reads place_tags" on place_tags
  for select using (true);
create policy "curator full access place_tags" on place_tags
  for all using (auth.role() = 'authenticated');

create policy "public reads active codes" on codes
  for select using (active = true);
create policy "curator full access codes" on codes
  for all using (auth.role() = 'authenticated');

create policy "public reads active questions" on questions
  for select using (active = true);
create policy "curator full access questions" on questions
  for all using (auth.role() = 'authenticated');

-- Visitors may submit reports and read published ones only.
create policy "public reads published reports" on field_reports
  for select using (status = 'published');
create policy "public submits reports" on field_reports
  for insert with check (true);
create policy "curator full access reports" on field_reports
  for all using (auth.role() = 'authenticated');

create policy "curator only sync runs" on sync_runs
  for all using (auth.role() = 'authenticated');

-- ------------------------------------------------------------
-- AGGREGATE VIEW — hides sparse data below 5 responses
-- ------------------------------------------------------------
create view field_report_aggregates as
select
  fr.place_id,
  fr.question_id,
  q.prompt,
  q.input_type,
  q.unit_label,
  count(*) as n,
  avg((fr.answer->>'value')::numeric)
    filter (where q.input_type in ('number','slider')) as mean_value,
  mode() within group (order by fr.answer->>'value')   as modal_value
from field_reports fr
join questions q on q.id = fr.question_id
where fr.status = 'published'
group by fr.place_id, fr.question_id, q.prompt, q.input_type, q.unit_label
having count(*) >= 5;

-- ------------------------------------------------------------
-- updated_at trigger
-- ------------------------------------------------------------
create or replace function touch_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

create trigger places_touch before update on places
  for each row execute function touch_updated_at();
