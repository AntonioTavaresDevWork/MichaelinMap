BEGIN;

-- ========================================================================
-- F-01 — Schema, RLS, RPCs
--
-- Version: 1.0
-- Source of truth: docs/MICHAELINMAP_BIBLIA.md §9 (schema) and §11 (authz)
-- Backlog items closed here: BL-01..BL-07
--
-- This migration creates the whole database surface. The companion migration
-- 20260806120100_f01_seed_and_import.sql loads the vocabulary and the places.
-- ========================================================================


-- ------------------------------------------------------------------------
-- BLOCK 01 — Tables
-- ------------------------------------------------------------------------

-- WHY tiers first: places.tier is a foreign key into this table. Tiers are
-- editable data rather than a code constant (RN-12) so the curator can rename
-- the public label without a deploy. Code depends on `slug`, never on `label`.
CREATE TABLE public.tiers (
  slug        text PRIMARY KEY,
  label       text NOT NULL,
  -- WHY an array: `fair` applies to both restaurants and bars. This column
  -- guides the admin UI only; the database does not restrict which place type
  -- may carry which tier, because the curator is the authority (Bíblia §9.2).
  applies_to  text[] NOT NULL DEFAULT '{}',
  sort_order  int NOT NULL DEFAULT 0,
  active      boolean NOT NULL DEFAULT true
);

CREATE TABLE public.places (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  slug          text UNIQUE,

  -- Classification
  place_type    text NOT NULL DEFAULT 'unclassified',
  -- WHY ON DELETE RESTRICT: dropping a tier row would silently erase the
  -- judgment layer on every place carrying it. Deleting a tier in use must
  -- fail loudly. Renaming the slug cascades, which is the safe direction.
  tier          text REFERENCES public.tiers(slug) ON UPDATE CASCADE ON DELETE RESTRICT,
  starred       boolean NOT NULL DEFAULT false,
  visited       boolean NOT NULL DEFAULT true,   -- false = Try List
  status        text NOT NULL DEFAULT 'unreviewed',

  -- Geography — three levels, all derived from coordinates with manual override
  country       text,
  city          text,          -- the primary gate
  area          text,          -- null below the density threshold
  lat           numeric(10,7),
  lng           numeric(10,7),
  address       text,
  website       text,

  -- Curator judgment. Price is a verdict, not a derived value (ADR-06).
  price_band    text,
  the_dish      text,
  curator_note  text,
  story         text,
  last_visited  date,

  -- Provenance
  -- WHY UNIQUE: the import upserts on apple_id. Without the constraint the
  -- upsert fails at runtime and re-running the import duplicates rows (BL-04).
  apple_id      text UNIQUE,
  source_guides text[],        -- original Apple guide names, audit only
  source        text NOT NULL DEFAULT 'apple_csv',

  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  updated_by    uuid REFERENCES auth.users(id) ON DELETE SET NULL,

  CONSTRAINT places_type_valid CHECK (place_type IN (
    'restaurant','bar','food_truck','dessert','winery',
    'hotel','grocery','shop','outdoors','unclassified'
  )),
  CONSTRAINT places_status_valid CHECK (status IN (
    'unreviewed','published','closed','hidden'
  )),
  CONSTRAINT places_price_band_valid CHECK (
    price_band IS NULL OR price_band IN ('$','$$','$$$','$$$$')
  ),
  CONSTRAINT places_source_valid CHECK (source IN ('apple_csv','manual')),

  -- The curator's discipline, enforced by the database rather than by the app.
  CONSTRAINT tier_requires_visit  CHECK (tier IS NULL OR visited = true),      -- RN-01
  CONSTRAINT star_requires_visit  CHECK (starred = false OR visited = true),   -- RN-02
  CONSTRAINT published_needs_city CHECK (status <> 'published' OR city IS NOT NULL) -- RN-09
);

-- Faceted, controlled vocabulary. Free-text tag creation is disabled by design (RN-13).
CREATE TABLE public.tags (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facet       text NOT NULL,
  label       text NOT NULL,
  slug        text NOT NULL,
  is_derived  boolean NOT NULL DEFAULT false,
  -- WHY admin_only: a negative verdict is what makes the positive credible,
  -- but `Hype trap` stays out of every public surface (RN-14).
  admin_only  boolean NOT NULL DEFAULT false,
  sort_order  int NOT NULL DEFAULT 0,
  active      boolean NOT NULL DEFAULT true,

  CONSTRAINT tags_facet_valid CHECK (facet IN (
    'cuisine','format','occasion','vibe','logistics','dietary','character'
  )),
  CONSTRAINT tags_facet_slug_unique UNIQUE (facet, slug)
);

CREATE TABLE public.place_tags (
  place_id   uuid NOT NULL REFERENCES public.places(id) ON DELETE CASCADE,
  tag_id     uuid NOT NULL REFERENCES public.tags(id)   ON DELETE CASCADE,
  -- WHY source: the import pre-classifies cuisine from the place name. The
  -- curator must be able to tell machine guesses from his own calls (RN-15),
  -- and to revert every guess with a single predicate.
  source     text NOT NULL DEFAULT 'curator',
  created_at timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (place_id, tag_id),
  CONSTRAINT place_tags_source_valid CHECK (source IN ('curator','suggested'))
);

-- Write allowlist. Two rows, ever. Signup is disabled on the Supabase project.
CREATE TABLE public.curators (
  user_id    uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name       text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Runtime interface transformations. Codes never remove content (RN-21).
CREATE TABLE public.codes (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code               text NOT NULL UNIQUE,   -- stored uppercase
  label              text,                   -- admin-facing description
  message            text,                   -- banner copy
  theme              jsonb,
  pin_style          jsonb,
  preset_filter      jsonb,
  -- WHY a bare uuid[] and not a join table: a code highlights places, it does
  -- not own them. A dangling id degrades to "not highlighted", which is fine.
  highlighted_places uuid[],
  starts_at          timestamptz,
  ends_at            timestamptz,
  active             boolean NOT NULL DEFAULT true,
  created_at         timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT codes_is_uppercase CHECK (code = upper(code)),
  CONSTRAINT codes_window_ordered CHECK (
    starts_at IS NULL OR ends_at IS NULL OR starts_at < ends_at
  )
);

CREATE TABLE public.questions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- WHY UNIQUE: the prompt is the only natural key these rows have. Without it
  -- re-running the seed duplicates all 38 questions (BL-05).
  prompt          text NOT NULL UNIQUE,
  input_type      text NOT NULL,
  unit_label      text,
  options         jsonb,
  slider_labels   jsonb,
  judgment_prompt text,
  -- WHY: drives the server-derived report status. The visitor never picks it (RN-23).
  requires_review boolean NOT NULL DEFAULT false,
  weight          int NOT NULL DEFAULT 1,
  active          boolean NOT NULL DEFAULT true,

  CONSTRAINT questions_input_type_valid CHECK (input_type IN (
    'number','color','slider','single_choice','yes_no','compound','text_short'
  ))
);

CREATE TABLE public.field_reports (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id     uuid NOT NULL REFERENCES public.places(id)    ON DELETE CASCADE,
  question_id  uuid NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  answer       jsonb NOT NULL,
  judgment     text,
  -- WHY default 'pending' and not 'published': fail closed. The RPC always sets
  -- the status explicitly; anything reaching this table by another path stays
  -- invisible until a curator looks at it.
  status       text NOT NULL DEFAULT 'pending',
  session_hash text,          -- rate limiting only, never identifying
  submitted_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT field_reports_status_valid CHECK (status IN ('published','pending','rejected')),
  CONSTRAINT field_reports_answer_has_value CHECK (answer ? 'value')
);


-- ------------------------------------------------------------------------
-- BLOCK 02 — Indexes (Bíblia §9.7)
-- ------------------------------------------------------------------------

CREATE INDEX places_city_idx   ON public.places(city) WHERE status = 'published';
CREATE INDEX places_type_idx   ON public.places(place_type);
CREATE INDEX places_tier_idx   ON public.places(tier);
CREATE INDEX places_status_idx ON public.places(status);
CREATE INDEX places_geo_idx    ON public.places(lat, lng);

-- WHY: the filter panel resolves tag -> places, the reverse of the primary key.
CREATE INDEX place_tags_tag_idx ON public.place_tags(tag_id);

CREATE INDEX field_reports_place_idx   ON public.field_reports(place_id) WHERE status = 'published';
CREATE INDEX field_reports_session_idx ON public.field_reports(session_hash, submitted_at);


-- ------------------------------------------------------------------------
-- BLOCK 03 — updated_at trigger
-- ------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER places_touch_updated_at
  BEFORE UPDATE ON public.places
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();


-- ------------------------------------------------------------------------
-- BLOCK 04 — Authorization primitive
--
-- Curator allowlist (ADR-01). Not tenant-scoped, not RBAC.
-- ------------------------------------------------------------------------

-- WHY SECURITY DEFINER: `curators` has no public SELECT policy, so an invoker
-- reading it from inside a policy would always see zero rows. Definer rights
-- bypass RLS on that one lookup, which is the whole point of the function.
CREATE OR REPLACE FUNCTION public.is_curator()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (SELECT 1 FROM public.curators WHERE user_id = auth.uid());
$$;

REVOKE ALL ON FUNCTION public.is_curator() FROM public;
GRANT EXECUTE ON FUNCTION public.is_curator() TO anon, authenticated;


-- ------------------------------------------------------------------------
-- BLOCK 05 — Row Level Security (Bíblia §11)
--
-- Replaces the original `auth.role() = 'authenticated'` model, under which any
-- authenticated account had full write access (BL-03).
-- ------------------------------------------------------------------------

ALTER TABLE public.tiers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.places        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.place_tags    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curators      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.codes         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.field_reports ENABLE ROW LEVEL SECURITY;

-- places — public reads published only (RN-07)
CREATE POLICY places_public_select ON public.places
  FOR SELECT TO anon, authenticated
  USING (status = 'published');

CREATE POLICY places_curator_all ON public.places
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());

-- tiers
CREATE POLICY tiers_public_select ON public.tiers
  FOR SELECT TO anon, authenticated
  USING (active = true);

CREATE POLICY tiers_curator_all ON public.tiers
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());

-- tags — admin-only tags are invisible to the public on every surface (RN-14)
CREATE POLICY tags_public_select ON public.tags
  FOR SELECT TO anon, authenticated
  USING (active = true AND admin_only = false);

CREATE POLICY tags_curator_all ON public.tags
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());

-- place_tags — the original `using (true)` leaked the ids of unpublished
-- places and the existence of admin-only tags (BL-07).
CREATE POLICY place_tags_public_select ON public.place_tags
  FOR SELECT TO anon, authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.places p
      WHERE p.id = place_tags.place_id AND p.status = 'published'
    )
    AND EXISTS (
      SELECT 1 FROM public.tags t
      WHERE t.id = place_tags.tag_id AND t.active = true AND t.admin_only = false
    )
  );

CREATE POLICY place_tags_curator_all ON public.place_tags
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());

-- curators — no public read. Membership of the allowlist is not public data.
CREATE POLICY curators_curator_all ON public.curators
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());

-- codes — no public SELECT at all. The original `using (active = true)` let any
-- visitor list every secret code (BL-01, RN-20). Redemption goes through the
-- RPC, which answers about one code at a time.
CREATE POLICY codes_curator_all ON public.codes
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());

-- questions
CREATE POLICY questions_public_select ON public.questions
  FOR SELECT TO anon, authenticated
  USING (active = true);

CREATE POLICY questions_curator_all ON public.questions
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());

-- field_reports — read published, no public INSERT policy of any kind. The
-- original `with check (true)` let a visitor write status = 'published'
-- directly and walk straight past the review gate (BL-02, RN-23).
CREATE POLICY field_reports_public_select ON public.field_reports
  FOR SELECT TO anon, authenticated
  USING (status = 'published');

CREATE POLICY field_reports_curator_all ON public.field_reports
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());


-- ------------------------------------------------------------------------
-- BLOCK 06 — Aggregate view
-- ------------------------------------------------------------------------

-- WHY security_invoker: without it the view runs as its owner and quietly
-- bypasses RLS on field_reports, exposing pending and rejected answers (BL-06).
CREATE VIEW public.field_report_aggregates
WITH (security_invoker = on) AS
SELECT
  fr.place_id,
  fr.question_id,
  q.prompt,
  q.input_type,
  q.unit_label,
  count(*) AS n,
  avg((fr.answer->>'value')::numeric)
    FILTER (WHERE q.input_type IN ('number','slider')) AS mean_value,
  mode() WITHIN GROUP (ORDER BY fr.answer->>'value') AS modal_value
FROM public.field_reports fr
JOIN public.questions q ON q.id = fr.question_id
WHERE fr.status = 'published'
GROUP BY fr.place_id, fr.question_id, q.prompt, q.input_type, q.unit_label
-- An aggregate of four answers is an anecdote, not a measurement (RN-25).
HAVING count(*) >= 5;


-- ------------------------------------------------------------------------
-- BLOCK 07 — Table grants
--
-- RLS is the real gate; these grants are the second lock. Supabase grants the
-- anon role broadly by default, so `anon` is stripped back to reads on the
-- objects the public is ever meant to touch.
--
-- WHY this block runs last: `ALL TABLES` covers views too, and default
-- privileges are applied at creation time. Revoking before the view exists
-- leaves anon holding INSERT, UPDATE, DELETE and TRUNCATE on it.
-- ------------------------------------------------------------------------

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;

GRANT SELECT ON
  public.places, public.tiers, public.tags, public.place_tags,
  public.questions, public.field_reports, public.field_report_aggregates
TO anon;

-- No grant to anon on `codes` or `curators` — reachable only via RPC, or not at all.

GRANT SELECT, INSERT, UPDATE, DELETE ON
  public.places, public.tiers, public.tags, public.place_tags,
  public.questions, public.field_reports, public.codes, public.curators
TO authenticated;

GRANT SELECT ON public.field_report_aggregates TO authenticated;


-- ------------------------------------------------------------------------
-- BLOCK 08 — RPCs exposed to the client (Bíblia §11)
-- ------------------------------------------------------------------------

-- Redeem a code. Returns the effect if the code exists, is active and is inside
-- its date window; otherwise returns the same shapeless miss.
--
-- WHY an identical response on every failure path: any difference between
-- "no such code" and "expired code" turns this function into an oracle and
-- hands back the enumeration that removing public SELECT was meant to stop.
CREATE OR REPLACE FUNCTION public.rpc_redeem_code(p_code text)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_code public.codes%ROWTYPE;
BEGIN
  IF p_code IS NULL OR btrim(p_code) = '' THEN
    RETURN jsonb_build_object('ok', false);
  END IF;

  SELECT * INTO v_code
  FROM public.codes
  WHERE code = upper(btrim(p_code))
    AND active = true
    AND (starts_at IS NULL OR starts_at <= now())
    AND (ends_at   IS NULL OR ends_at   >= now());

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false);
  END IF;

  RETURN jsonb_build_object(
    'ok',                 true,
    'code',               v_code.code,
    'label',              v_code.label,
    'message',            v_code.message,
    'theme',              v_code.theme,
    'pin_style',          v_code.pin_style,
    'preset_filter',      v_code.preset_filter,
    'highlighted_places', to_jsonb(coalesce(v_code.highlighted_places, ARRAY[]::uuid[]))
  );
END;
$$;

REVOKE ALL ON FUNCTION public.rpc_redeem_code(text) FROM public;
GRANT EXECUTE ON FUNCTION public.rpc_redeem_code(text) TO anon, authenticated;


-- Submit one field report. The only write path the public has.
--
-- Everything that decides whether the answer goes live is computed here, from
-- the question row — never taken from the caller.
CREATE OR REPLACE FUNCTION public.rpc_submit_field_report(
  p_place_id     uuid,
  p_question_id  uuid,
  p_answer       jsonb,
  p_judgment     text DEFAULT NULL,
  p_session_hash text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_question public.questions%ROWTYPE;
  v_answer   jsonb;
  v_status   text;
  v_recent   int;
BEGIN
  IF p_answer IS NULL OR NOT (p_answer ? 'value') THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_answer');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.places
    WHERE id = p_place_id AND status = 'published'
  ) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'place_not_available');
  END IF;

  SELECT * INTO v_question
  FROM public.questions
  WHERE id = p_question_id AND active = true;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', 'question_not_available');
  END IF;

  -- Rate limit. Cheap to defeat with a fresh session, which is fine: the point
  -- is to stop one bored visitor from bending an aggregate on their own.
  IF p_session_hash IS NOT NULL THEN
    SELECT count(*) INTO v_recent
    FROM public.field_reports
    WHERE session_hash = p_session_hash
      AND submitted_at > now() - interval '1 hour';

    IF v_recent >= 30 THEN
      RETURN jsonb_build_object('ok', false, 'error', 'rate_limited');
    END IF;

    IF EXISTS (
      SELECT 1 FROM public.field_reports
      WHERE session_hash = p_session_hash
        AND place_id = p_place_id
        AND question_id = p_question_id
    ) THEN
      RETURN jsonb_build_object('ok', false, 'error', 'already_answered');
    END IF;
  END IF;

  -- Free text is the one unbounded input in the product, so it is capped here
  -- rather than trusted from the client (RN-24).
  IF v_question.input_type = 'text_short' THEN
    v_answer := jsonb_set(
      p_answer, '{value}',
      to_jsonb(left(btrim(p_answer->>'value'), 40))
    );
  ELSE
    v_answer := p_answer;
  END IF;

  -- The visitor does not choose whether their answer goes live (RN-23).
  v_status := CASE WHEN v_question.requires_review THEN 'pending' ELSE 'published' END;

  INSERT INTO public.field_reports
    (place_id, question_id, answer, judgment, status, session_hash)
  VALUES
    (p_place_id, p_question_id, v_answer, left(btrim(p_judgment), 40), v_status, p_session_hash);

  RETURN jsonb_build_object('ok', true, 'status', v_status);
END;
$$;

REVOKE ALL ON FUNCTION public.rpc_submit_field_report(uuid, uuid, jsonb, text, text) FROM public;
GRANT EXECUTE ON FUNCTION public.rpc_submit_field_report(uuid, uuid, jsonb, text, text) TO anon, authenticated;


-- ------------------------------------------------------------------------
-- BLOCK 09 — Validation gates
--
-- Read-only. A failure raises, which rolls the whole migration back.
-- ------------------------------------------------------------------------

DO $GATES$
DECLARE
  v_count integer;
  v_bool  boolean;
BEGIN
  -- G1: all eight tables exist
  SELECT count(*) INTO v_count
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN ('tiers','places','tags','place_tags',
                       'curators','codes','questions','field_reports');
  IF v_count <> 8 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 8 tables, found %', v_count;
  END IF;

  -- G2: RLS is enabled on every one of them
  SELECT count(*) INTO v_count
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname IN ('tiers','places','tags','place_tags',
                      'curators','codes','questions','field_reports')
    AND c.relrowsecurity = true;
  IF v_count <> 8 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: RLS enabled on % of 8 tables', v_count;
  END IF;

  -- G3: no table is left with RLS on and zero policies (locked out by accident)
  SELECT count(*) INTO v_count
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relrowsecurity = true
    AND NOT EXISTS (SELECT 1 FROM pg_policy p WHERE p.polrelid = c.oid);
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G3 FAILED: % table(s) have RLS on and no policy', v_count;
  END IF;

  -- G4: codes has no SELECT policy reachable by anon (BL-01, RN-20)
  SELECT count(*) INTO v_count
  FROM pg_policy p
  JOIN pg_class c ON c.oid = p.polrelid
  WHERE c.relname = 'codes'
    AND p.polcmd IN ('r','*')
    AND 'anon' = ANY (SELECT rolname FROM pg_roles WHERE oid = ANY (p.polroles));
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: codes exposes % SELECT policy to anon', v_count;
  END IF;

  -- G5: field_reports has no INSERT policy at all (BL-02, RN-23)
  SELECT count(*) INTO v_count
  FROM pg_policy p
  JOIN pg_class c ON c.oid = p.polrelid
  WHERE c.relname = 'field_reports' AND p.polcmd = 'a';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G5 FAILED: field_reports has % INSERT policy', v_count;
  END IF;

  -- G6: anon holds no write privilege anywhere in public
  SELECT count(*) INTO v_count
  FROM information_schema.role_table_grants
  WHERE grantee = 'anon'
    AND table_schema = 'public'
    AND privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE');
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G6 FAILED: anon holds % write grant(s) in public', v_count;
  END IF;

  -- G7: anon cannot read codes or curators even with RLS aside
  SELECT count(*) INTO v_count
  FROM information_schema.role_table_grants
  WHERE grantee = 'anon'
    AND table_schema = 'public'
    AND table_name IN ('codes','curators');
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G7 FAILED: anon holds % grant(s) on codes/curators', v_count;
  END IF;

  -- G8: the aggregate view runs with invoker rights (BL-06)
  SELECT (c.reloptions @> ARRAY['security_invoker=on']) INTO v_bool
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public' AND c.relname = 'field_report_aggregates';
  IF v_bool IS NOT TRUE THEN
    RAISE EXCEPTION 'GATE G8 FAILED: field_report_aggregates is not security_invoker';
  END IF;

  -- G9: every SECURITY DEFINER function pins its search_path
  SELECT count(*) INTO v_count
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND p.prosecdef = true
    AND (p.proconfig IS NULL OR NOT EXISTS (
      SELECT 1 FROM unnest(p.proconfig) cfg WHERE cfg LIKE 'search_path=%'
    ));
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G9 FAILED: % SECURITY DEFINER function(s) without search_path', v_count;
  END IF;

  -- G10: the three judgment constraints are in place (RN-01, RN-02, RN-09)
  SELECT count(*) INTO v_count
  FROM pg_constraint
  WHERE conrelid = 'public.places'::regclass
    AND conname IN ('tier_requires_visit','star_requires_visit','published_needs_city');
  IF v_count <> 3 THEN
    RAISE EXCEPTION 'GATE G10 FAILED: expected 3 judgment constraints, found %', v_count;
  END IF;

  -- G11: both client-facing RPCs exist and are executable by anon
  SELECT count(*) INTO v_count
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND p.proname IN ('rpc_redeem_code','rpc_submit_field_report')
    AND has_function_privilege('anon', p.oid, 'EXECUTE');
  IF v_count <> 2 THEN
    RAISE EXCEPTION 'GATE G11 FAILED: % of 2 RPCs executable by anon', v_count;
  END IF;

  -- G12: apple_id is unique, or the import upsert breaks at runtime (BL-04)
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.places'::regclass AND contype = 'u'
      AND conkey = ARRAY[(SELECT attnum FROM pg_attribute
                          WHERE attrelid = 'public.places'::regclass
                            AND attname = 'apple_id')]
  ) THEN
    RAISE EXCEPTION 'GATE G12 FAILED: places.apple_id has no UNIQUE constraint';
  END IF;

  RAISE NOTICE 'F-01 schema gates passed: 12 of 12';
END $GATES$;

COMMIT;
