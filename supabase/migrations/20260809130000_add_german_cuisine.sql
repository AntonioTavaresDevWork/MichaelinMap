BEGIN;

-- ====================================================================
-- Cuisine vocabulary — add `german`
--
-- Version: 1.0
-- Requires: 20260809120000_suggest_researched_tags.sql
-- Backlog items touched here: DP-11 (partially answered), BL-41
--
-- WHY this slug and not another: the research pass over the 117 unreviewed
-- Austin-area restaurants hit three places in its first ten that the 37-slug
-- vocabulary cannot describe — Alpine Haus and Krause's Cafe (New Braunfels)
-- and Friedhelm's Bavarian Inn (Fredericksburg). That is not a coincidence in
-- the data: New Braunfels and Fredericksburg are German settlements, and the
-- Hill Country carries the cuisine to this day. `modern-european` would be
-- factually wrong for a schnitzel-and-sauerbraten kitchen, and RN-32 prefers a
-- visible gap to a tag that reads precise and is not.
--
-- WHY this migration writes no assignment: it proposes vocabulary, never
-- judgment. Tagging the three places is a separate act, on evidence, as
-- `source = 'suggested'`. Gate G5 enforces that.
--
-- There is no GRANT block: no object is created here, so nothing is born with
-- Supabase default privileges. Gate G6 confirms that assumption held.
-- ====================================================================


-- ====================================================================
-- BLOCK 01 — Open a slot inside the European run
--
-- `sort_order` drives the order the facet renders in for the visitor, and the
-- cuisine list is grouped by region on purpose. Appending at 37 would leave
-- German stranded after `modern-european`, which reads as an afterthought
-- rather than as part of Europe. So the tail shifts by one instead.
--
-- WHY the NOT EXISTS guard: this UPDATE is the one statement here that is not
-- naturally idempotent — running it twice would shift the tail twice and walk
-- German out of position. Keying it to the slug's absence makes the whole
-- migration safe to re-run. There is no UNIQUE on `sort_order`, so the shift
-- cannot collide mid-statement.
-- ====================================================================

UPDATE public.tags
SET sort_order = sort_order + 1
WHERE facet = 'cuisine'
  AND sort_order >= 30
  AND NOT EXISTS (
    SELECT 1 FROM public.tags
    WHERE facet = 'cuisine' AND slug = 'german'
  );


-- ====================================================================
-- BLOCK 02 — The slug
--
-- `active = true`, `admin_only = false`, `is_derived = false`: a visitor may
-- filter by it, a curator may assign it, and nothing computes it. Explicit
-- rather than left to the column defaults, because RN-14 turns on admin_only
-- and a silent default is a poor place for that to live.
-- ====================================================================

INSERT INTO public.tags (facet, label, slug, is_derived, admin_only, sort_order, active)
VALUES ('cuisine', 'German', 'german', false, false, 30, true)
ON CONFLICT (facet, slug) DO NOTHING;


-- ====================================================================
-- BLOCK 03 — Validation gates
-- ====================================================================

DO $GATES$
DECLARE
  v_count   integer;
  v_german  integer;
  v_french  integer;
  v_spanish integer;
  v_flags   integer;
BEGIN
  -- G1 — the slug exists, exactly once
  SELECT count(*) INTO v_count
  FROM public.tags WHERE facet = 'cuisine' AND slug = 'german';
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 1 german cuisine tag, found %', v_count;
  END IF;

  -- G2 — the vocabulary grew by exactly one
  SELECT count(*) INTO v_count FROM public.tags WHERE facet = 'cuisine';
  IF v_count <> 38 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: expected 38 cuisine tags, found %', v_count;
  END IF;

  -- G3 — it landed inside Europe, not appended to the end
  SELECT sort_order INTO v_french  FROM public.tags WHERE facet='cuisine' AND slug='french';
  SELECT sort_order INTO v_german  FROM public.tags WHERE facet='cuisine' AND slug='german';
  SELECT sort_order INTO v_spanish FROM public.tags WHERE facet='cuisine' AND slug='spanish';
  IF NOT (v_french < v_german AND v_german < v_spanish) THEN
    RAISE EXCEPTION 'GATE G3 FAILED: expected french < german < spanish, found % / % / %',
      v_french, v_german, v_spanish;
  END IF;

  -- G4 — the shift did not collide two tags onto one position
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
  WHERE t.facet = 'cuisine' AND t.slug = 'german';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G5 FAILED: german already carries % assignment(s); this migration must write none', v_count;
  END IF;

  -- G6 — the new row is visible and assignable, and anon gained no write grant
  SELECT count(*) INTO v_flags
  FROM public.tags
  WHERE facet = 'cuisine' AND slug = 'german'
    AND active = true AND admin_only = false AND is_derived = false;
  IF v_flags <> 1 THEN
    RAISE EXCEPTION 'GATE G6a FAILED: german is not active/public/non-derived';
  END IF;

  SELECT count(*) INTO v_count
  FROM information_schema.role_table_grants
  WHERE grantee = 'anon' AND table_schema = 'public'
    AND privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE');
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G6b FAILED: anon holds % write grant(s) in public', v_count;
  END IF;

  RAISE NOTICE 'german cuisine gates passed: 6 of 6';
END $GATES$;

COMMIT;
