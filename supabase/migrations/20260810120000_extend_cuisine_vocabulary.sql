BEGIN;

-- ====================================================================
-- Cuisine vocabulary — add the seven slugs that close RN-32's coverage gap
--
-- Version: 1.0
-- Requires: 20260809130000_add_german_cuisine.sql
-- Backlog items touched here: BL-45, BL-46 (both answered), DP-11 (partially),
--                             BL-43 (unblocked)
--
-- ⚠️  NOT YET APPLIED. Written in S13 with no Supabase MCP in the session, so
--     it was never validated against the live schema — the project's first rule
--     ("live schema first") could not be honoured. It is modelled on
--     20260809130000_add_german_cuisine.sql, which WAS applied successfully
--     against this database, so the shape is borrowed from a verified
--     precedent rather than from convention. **Introspect before applying**,
--     and expect gate G2 to be the one that catches a wrong assumption.
--
-- WHY SEVEN AND WHY THESE
--
-- The S12/S13 research pass covered all 117 unreviewed Austin-area restaurants
-- with evidence per tag. 106 are open. Under the 38-slug vocabulary, **17 of
-- those 106 could not be given a single honest cuisine tag** — not because the
-- researcher failed to identify them, but because nothing in the list described
-- them. RN-32 says every food place should carry at least one filterable
-- cuisine tag; 17 permanent holes is that rule failing in the data.
--
-- The seven were chosen as the smallest set that closes the gap completely,
-- ranked by how many places each unlocks:
--
--   american      4 places  Finley's, Lou's, Millie's On Main, Sundancer Grill
--   mexican       2 places  Ma'CoCo, VERDAD
--   cajun-creole  1 place   Vic & Al's
--   georgian      1 place   Bread Boat
--   sandwiches    1 place   Meat & Bread
--   wine-bar      1 place   Flo's Wine Bar & Bottle Shop
--   brewery       1 place   Old Gregg Brewing Company
--
-- The remaining 6 of the 17 needed no new slug — they were re-tagged onto
-- existing ones by relaxing from "most precise" to "true but broad", which is
-- recorded row by row in docs/research/cuisine-117-results.json.
--
-- WHY `american` MATTERS MOST, and it is not the count. The vocabulary had no
-- plain American entry: only `new-american`, a chef-driven category, and
-- `southern-comfort`. So every ordinary American restaurant either fell through
-- or was pushed into `new-american` — which ended the pass used **18 times in
-- 117 places**, more than any other slug and 60% more than the next. One slug
-- was doing duty for a whole cuisine while the places it did not fit vanished.
--
-- WHY `cajun-creole` IS NOT `southern-comfort`. The vocabulary already
-- separates `tex-mex` from `interior-mexican`, so it plainly cares about
-- regional precision. Folding Louisiana into the American South throws away
-- exactly the distinction it keeps elsewhere.
--
-- WHY THREE OF THESE ARE FORMATS, NOT CUISINES. `wine-bar`, `brewery` and
-- `sandwiches` describe what kind of place it is rather than what country the
-- food comes from. That is a deliberate, approved departure: those three
-- businesses have no cuisine to name, and a visitor filtering the facet would
-- still expect to find them. It also means the cuisine facet now mixes two
-- kinds of claim — the same objection BL-42 raises about `cocktails-bar-food`,
-- knowingly extended rather than accidentally repeated.
--
-- WHAT WAS DELIBERATELY NOT ADDED: `northern-michigan`, which would have been
-- exact for Millie's On Main (whitefish, Yooper pasties) and rests on a single
-- instance in 117 places. It goes to `american` instead, with the specific
-- truth preserved in the research record. `latin-american` is untouched — DP-11
-- records it as a boundary judgment that stays Michael's.
--
-- WHY THIS MIGRATION WRITES NO ASSIGNMENT: it proposes vocabulary, never
-- judgment. Tagging the 17 places is a separate act, on evidence, as
-- `source = 'suggested'`. Gate G5 enforces that.
--
-- There is no GRANT block: no object is created here, so nothing is born with
-- Supabase default privileges. Gate G6 confirms that assumption held.
-- ====================================================================


-- ====================================================================
-- BLOCK 01 — The seven slugs
--
-- Inserted first with provisional sort_order values above the existing range,
-- so nothing collides before BLOCK 02 rewrites the whole ordering. Flags are
-- explicit rather than left to column defaults, because RN-14 turns on
-- admin_only and a silent default is a poor place for that to live:
-- `active = true`, `admin_only = false`, `is_derived = false`.
-- ====================================================================

INSERT INTO public.tags (facet, label, slug, is_derived, admin_only, sort_order, active) VALUES
  ('cuisine', 'American',     'american',     false, false, 100, true),
  ('cuisine', 'Mexican',      'mexican',      false, false, 101, true),
  ('cuisine', 'Cajun-Creole', 'cajun-creole', false, false, 102, true),
  ('cuisine', 'Georgian',     'georgian',     false, false, 103, true),
  ('cuisine', 'Sandwiches',   'sandwiches',   false, false, 104, true),
  ('cuisine', 'Wine Bar',     'wine-bar',     false, false, 105, true),
  ('cuisine', 'Brewery',      'brewery',      false, false, 106, true)
ON CONFLICT (facet, slug) DO NOTHING;


-- ====================================================================
-- BLOCK 02 — Rewrite the whole cuisine ordering, deterministically
--
-- WHY NOT SEVEN INCREMENTAL SHIFTS: 20260809130000 inserted one slug by
-- shifting the tail with a NOT EXISTS guard, which is safe for one. Seven
-- cascading shifts would be seven chances to double-shift, and the guard trick
-- does not compose. Declaring the final order once is idempotent by end state:
-- run it twice and the second run changes nothing.
--
-- WHY THIS ORDER: every pairwise ordering of the existing 38 is preserved
-- exactly — this migration inserts, it does not rearrange. Gate G3 asserts that
-- against three sentinel pairs.
-- ====================================================================

UPDATE public.tags t
SET sort_order = v.ord
FROM (VALUES
  ('bbq', 0), ('tex-mex', 1), ('tacos', 2), ('interior-mexican', 3),
  ('mexican', 4), ('southern-comfort', 5), ('cajun-creole', 6), ('american', 7),
  ('burgers', 8), ('sandwiches', 9), ('pizza', 10), ('italian', 11),
  ('steakhouse', 12), ('seafood', 13), ('new-american', 14), ('japanese', 15),
  ('sushi', 16), ('ramen', 17), ('korean', 18), ('chinese', 19),
  ('thai', 20), ('vietnamese', 21), ('indian', 22), ('middle-eastern', 23),
  ('mediterranean', 24), ('ethiopian', 25), ('caribbean', 26),
  ('vegetarian-forward', 27), ('breakfast-diner', 28), ('bakery-pastry', 29),
  ('coffee', 30), ('cocktails-bar-food', 31), ('wine-bar', 32), ('brewery', 33),
  ('british', 34), ('french', 35), ('german', 36), ('georgian', 37),
  ('spanish', 38), ('portuguese', 39), ('greek', 40), ('turkish', 41),
  ('brazilian', 42), ('peruvian', 43), ('modern-european', 44)
) AS v(slug, ord)
WHERE t.facet = 'cuisine'
  AND t.slug = v.slug
  AND t.sort_order IS DISTINCT FROM v.ord;


-- ====================================================================
-- BLOCK 03 — Validation gates
-- ====================================================================

DO $GATES$
DECLARE
  v_count  integer;
  v_a      integer;
  v_b      integer;
  v_c      integer;
  v_missing text;
BEGIN
  -- G1 — all seven slugs exist, exactly once each
  SELECT count(*) INTO v_count
  FROM public.tags
  WHERE facet = 'cuisine'
    AND slug IN ('american','mexican','cajun-creole','georgian','sandwiches','wine-bar','brewery');
  IF v_count <> 7 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 7 new cuisine tags, found %', v_count;
  END IF;

  -- G2 — the vocabulary is exactly 45. This is the gate that catches a wrong
  -- assumption about the live schema, since this migration was written blind.
  SELECT count(*) INTO v_count FROM public.tags WHERE facet = 'cuisine';
  IF v_count <> 45 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: expected 45 cuisine tags, found %. If this is 46+, the live vocabulary already held a slug this migration did not know about, and BLOCK 02 left it unordered', v_count;
  END IF;

  -- G2b — every cuisine tag was covered by BLOCK 02's list
  SELECT string_agg(slug, ', ') INTO v_missing
  FROM public.tags
  WHERE facet = 'cuisine' AND (sort_order IS NULL OR sort_order > 44);
  IF v_missing IS NOT NULL THEN
    RAISE EXCEPTION 'GATE G2b FAILED: cuisine slug(s) outside the declared ordering: %', v_missing;
  END IF;

  -- G3 — insertion, not rearrangement: existing pairwise order preserved
  SELECT sort_order INTO v_a FROM public.tags WHERE facet='cuisine' AND slug='bbq';
  SELECT sort_order INTO v_b FROM public.tags WHERE facet='cuisine' AND slug='southern-comfort';
  SELECT sort_order INTO v_c FROM public.tags WHERE facet='cuisine' AND slug='burgers';
  IF NOT (v_a < v_b AND v_b < v_c) THEN
    RAISE EXCEPTION 'GATE G3a FAILED: bbq < southern-comfort < burgers violated (% / % / %)', v_a, v_b, v_c;
  END IF;

  SELECT sort_order INTO v_a FROM public.tags WHERE facet='cuisine' AND slug='seafood';
  SELECT sort_order INTO v_b FROM public.tags WHERE facet='cuisine' AND slug='new-american';
  SELECT sort_order INTO v_c FROM public.tags WHERE facet='cuisine' AND slug='japanese';
  IF NOT (v_a < v_b AND v_b < v_c) THEN
    RAISE EXCEPTION 'GATE G3b FAILED: seafood < new-american < japanese violated (% / % / %)', v_a, v_b, v_c;
  END IF;

  SELECT sort_order INTO v_a FROM public.tags WHERE facet='cuisine' AND slug='french';
  SELECT sort_order INTO v_b FROM public.tags WHERE facet='cuisine' AND slug='german';
  SELECT sort_order INTO v_c FROM public.tags WHERE facet='cuisine' AND slug='spanish';
  IF NOT (v_a < v_b AND v_b < v_c) THEN
    RAISE EXCEPTION 'GATE G3c FAILED: french < german < spanish violated (% / % / %)', v_a, v_b, v_c;
  END IF;

  -- G4 — no two cuisine tags share a sort_order
  SELECT count(*) INTO v_count FROM (
    SELECT sort_order FROM public.tags WHERE facet = 'cuisine'
    GROUP BY sort_order HAVING count(*) > 1
  ) dup;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: % duplicated sort_order value(s) in cuisine', v_count;
  END IF;

  -- G5 — judgment integrity: vocabulary only, no place was tagged here
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.tags t ON t.id = pt.tag_id
  WHERE t.facet = 'cuisine'
    AND t.slug IN ('american','mexican','cajun-creole','georgian','sandwiches','wine-bar','brewery');
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G5 FAILED: the new slugs already carry % assignment(s); this migration must write none', v_count;
  END IF;

  -- G6a — all seven are visible, assignable and computed by nothing
  SELECT count(*) INTO v_count
  FROM public.tags
  WHERE facet = 'cuisine'
    AND slug IN ('american','mexican','cajun-creole','georgian','sandwiches','wine-bar','brewery')
    AND active = true AND admin_only = false AND is_derived = false;
  IF v_count <> 7 THEN
    RAISE EXCEPTION 'GATE G6a FAILED: only % of 7 new slugs are active/public/non-derived', v_count;
  END IF;

  -- G6b — anon gained no write grant in public
  SELECT count(*) INTO v_count
  FROM information_schema.role_table_grants
  WHERE grantee = 'anon' AND table_schema = 'public'
    AND privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE');
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G6b FAILED: anon holds % write grant(s) in public', v_count;
  END IF;

  RAISE NOTICE 'cuisine vocabulary extension gates passed: 8 of 8 (45 slugs)';
END $GATES$;

COMMIT;
