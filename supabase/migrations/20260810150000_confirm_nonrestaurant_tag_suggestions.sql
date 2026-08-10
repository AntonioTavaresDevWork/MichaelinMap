BEGIN;

-- ====================================================================
-- Confirm 23 of the 26 remaining tag suggestions — the ones outside restaurants
--
-- Version: 1.0
-- Requires: 20260810140000_confirm_restaurant_tag_suggestions.sql
--
-- ⚠️  THIS MIGRATION WRITES TO THE JUDGMENT LAYER, on Edu's explicit
-- authorisation, for the reasons recorded in 20260810140000's header.
--
-- WHY THIS ONE IS NARROWER THAN THE LAST, AND WHY THAT IS THE POINT
--
-- 20260810140000 confirmed 186 assignments on restaurants. Those came from the
-- S11-S13 research pass and **every one of them carries a source URL and a
-- verbatim quote** in docs/research/cuisine-117-results.json.
--
-- The 26 that remained afterwards have a different provenance entirely, checked
-- against the frozen source material before this migration was written:
--
--   ~19 came from the `Tags` column of the Apple Maps master CSV — album
--        metadata, the same origin S08 exposed when it found `Breakfast &
--        Diner` on 56 places because that was **the name of an Apple guide**,
--        not because anyone decided. RN-31 exists because of that discovery.
--   ~6  came from the rule-based migration 20260807140000, which assigns by
--        `place_type` rather than by evidence.
--
-- Neither is research. So instead of confirming all 26, the three that are
-- doubtful were left as suggestions:
--
--   `Yellow Ranger` — `cocktails-bar-food`, assigned by the rule because its
--        place_type is `bar`. **It is the only one of the 26 on a published
--        place, so it is the only one a visitor would see** — and the S14
--        closure sweep researched it: it describes itself as a "Chinese-American
--        dive", Yelp files it under Chinese, and it hosts a ramen residency.
--        The rule is probably wrong, and wrong in the one place it shows.
--   `Fernando de Noronha Airport` and `Pousada Alamoa` — `vacation`, on
--        `unclassified` places that are an airport and a guesthouse in Brazil.
--        Not food, and not the curator's to endorse by accident.
--
-- WHAT IS CONFIRMED HERE: 14 `rooftop` and 3 `night-out` on unreviewed bars,
-- 5 `bakery-pastry` on unreviewed dessert places, 1 `food-truck`. All are
-- checkable facts about the venue, and **none is on a published place**, so
-- nothing here changes what a visitor sees today.
--
-- THE PREDICATE IS DECLARATIVE, NOT A LIST OF IDS: unreviewed, and one of three
-- place types. That is exactly the 23 and it excludes the 3 by construction —
-- Yellow Ranger is published, the other two are `unclassified`.
-- ====================================================================


-- ====================================================================
-- BLOCK 01 — The confirmation
-- ====================================================================

UPDATE public.place_tags pt
SET source = 'curator'
FROM public.places p
WHERE p.id = pt.place_id
  AND pt.source = 'suggested'
  AND p.status = 'unreviewed'
  AND p.place_type IN ('bar', 'dessert', 'outdoors');


-- ====================================================================
-- BLOCK 02 — Validation gates
-- ====================================================================

DO $GATES$
DECLARE
  v_count integer;
  v_resto text;
BEGIN
  -- G1 — exactly three suggestions remain, and they are the three intended ones
  SELECT count(*) INTO v_count FROM public.place_tags WHERE source = 'suggested';
  IF v_count <> 3 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 3 suggestions left, found %', v_count;
  END IF;

  SELECT string_agg(p.name || '/' || t.slug, ', ' ORDER BY p.name) INTO v_resto
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  JOIN public.tags   t ON t.id = pt.tag_id
  WHERE pt.source = 'suggested';
  IF v_resto <> 'Fernando de Noronha Airport/vacation, Pousada Alamoa/vacation, Yellow Ranger/cocktails-bar-food' THEN
    RAISE EXCEPTION 'GATE G2 FAILED: the remaining suggestions are not the three intended ones: %', v_resto;
  END IF;

  -- G3 — nothing was created or destroyed; this migration only relabels
  SELECT count(*) INTO v_count FROM public.place_tags;
  IF v_count <> 348 THEN
    RAISE EXCEPTION 'GATE G3 FAILED: place_tags holds % rows, expected 348', v_count;
  END IF;

  -- G4 — no published place gained a visible tag here
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  WHERE pt.source = 'curator' AND p.status = 'published'
    AND p.place_type IN ('dessert', 'outdoors');
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: % published dessert/outdoors place(s) now carry a curator tag', v_count;
  END IF;

  RAISE NOTICE 'non-restaurant tag confirmation: 4 of 4 gates passed, 3 suggestions deliberately left';
END $GATES$;

COMMIT;
