BEGIN;

-- ====================================================================
-- Cuisine suggestions for the published places that had none
--
-- Version: 1.0
-- Requires: 20260806120100_f01_seed_and_import
-- Backlog items advanced here: BL-30, BL-34
--
-- WHY this exists: of the 58 published places, 45 of the food ones carried
-- no cuisine tag at all, so the public filter had almost nothing to offer.
-- The import (F-01) only matched cuisine words appearing literally in a
-- place's name, which misses every restaurant named after a person, a
-- street or a word in another language.
--
-- WHY it is safe to write these: every row lands as source = 'suggested',
-- and RN-31 keeps suggested assignments out of every public surface until
-- the curator confirms them. So this is a review queue in the admin, not a
-- claim shown to a visitor. Nothing here is visible to anyone until Michael
-- says so, and undoing the lot is one DELETE (see the rollback file).
--
-- WHY only 28 of 45: the remaining 17 could not be classified from the name
-- or from public knowledge of the restaurant with enough confidence to be
-- worth the curator's time rejecting. A wrong suggestion costs more than a
-- missing one — it has to be read and dismissed. The 17 are listed at the
-- bottom of this file for whoever picks this up next.
--
-- The judgment layer is not touched: no tier, star, dish, note, story or
-- last_visited is written or read here, and no existing assignment is
-- modified. Gates G2 and G5 below enforce that.
-- ====================================================================

-- BLOCK 01 — Cuisine suggestions
--
-- Resolved by natural key (places.slug, tags.slug) rather than by UUID, so
-- the statement stays readable and cannot silently attach a tag to the
-- wrong row after a restore. A slug that fails to resolve drops out of the
-- join silently, which is exactly what gate G1 is here to catch.

INSERT INTO public.place_tags (place_id, tag_id, source)
SELECT p.id, t.id, 'suggested'
FROM (VALUES
  -- Legible from the name alone; anyone can check these without knowing Austin.
  ('alc-steaks',                 'steakhouse'),         -- "Steaks"
  ('chez-l-amour',               'french'),             -- "Chez"
  ('fixe-southern-house',        'southern-comfort'),   -- "Southern House"
  ('il-brutto',                  'italian'),            -- Italian name
  ('l-oca-d-oro',                'italian'),            -- Italian name
  ('uovo',                       'italian'),            -- "uovo" = egg
  ('el-raval',                   'spanish'),            -- a Barcelona district
  ('castillo-craft-bar-kitchen', 'cocktails-bar-food'), -- "Craft Bar + Kitchen"
  ('yellow-ranger',              'cocktails-bar-food'), -- the row is a bar
  ('cap-s-on-the-water',         'seafood'),            -- on the water, St. Augustine

  -- Require knowing the specific restaurant. Higher risk: a concept can
  -- change or close, and this is recall, not observation. Left as suggestions
  -- precisely because the curator is the one who can confirm them.
  ('aba',             'mediterranean'),
  ('canje',           'caribbean'),
  ('clay-pit',        'indian'),
  ('comedor',         'interior-mexican'),
  ('suerte',          'interior-mexican'),
  ('ezov',            'middle-eastern'),
  ('justine-s',       'french'),
  ('kemuri-tatsu-ya', 'japanese'),
  ('sway',            'thai'),
  ('lamberts',        'bbq'),
  ('juniper',         'italian'),
  ('sammie-s',        'italian'),
  ('lonesome-dove',   'steakhouse'),
  ('arlo-grey',       'new-american'),
  ('emmer-rye',       'new-american'),
  ('hestia',          'new-american'),
  ('launderette',     'new-american'),
  ('lutie-s',         'new-american')
) AS v(place_slug, tag_slug)
JOIN public.places p ON p.slug = v.place_slug
JOIN public.tags   t ON t.slug = v.tag_slug AND t.facet = 'cuisine'
ON CONFLICT (place_id, tag_id) DO NOTHING;

-- BLOCK 02 — Validation gates

DO $GATES$
DECLARE
  v_count integer;
  v_names text;
BEGIN
  -- G1 — every pair resolved. A typo in either slug would drop the row
  -- silently, leaving a suggestion the curator never gets to see.
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.tags t ON t.id = pt.tag_id AND t.facet = 'cuisine'
  WHERE pt.source = 'suggested'
    AND pt.place_id IN (
      SELECT id FROM public.places WHERE slug IN (
        'alc-steaks','chez-l-amour','fixe-southern-house','il-brutto','l-oca-d-oro',
        'uovo','el-raval','castillo-craft-bar-kitchen','yellow-ranger','cap-s-on-the-water',
        'aba','canje','clay-pit','comedor','suerte','ezov','justine-s','kemuri-tatsu-ya',
        'sway','lamberts','juniper','sammie-s','lonesome-dove','arlo-grey','emmer-rye',
        'hestia','launderette','lutie-s'));

  IF v_count <> 28 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 28 cuisine suggestions, found %', v_count;
  END IF;

  -- G2 — the curator's own work is untouched. It was 0 before this ran and
  -- has to still be 0: this migration may only ever add machine guesses.
  SELECT count(*) INTO v_count
  FROM public.place_tags WHERE source = 'curator';

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: curator assignments changed, found % (expected 0)', v_count;
  END IF;

  -- G3 — none of the 28 places in THIS batch ends up with two cuisines. They
  -- all had zero before, so each must now hold exactly one; more would mean
  -- the batch listed a place twice.
  --
  -- WHY this is scoped to the batch and not global: the first draft asserted
  -- that no place anywhere carries two cuisines, and it failed on apply —
  -- eleven rows from the F-01 import already did. Looking at them showed the
  -- assumption was wrong, not the data: "Dean's Italian Steakhouse" really is
  -- Italian and Steakhouse, and a coffee shop serving breakfast really is
  -- both. Two cuisines is not a contradiction. The gate was.
  SELECT count(*) INTO v_count FROM (
    SELECT pt.place_id
    FROM public.place_tags pt
    JOIN public.tags   t ON t.id = pt.tag_id AND t.facet = 'cuisine'
    JOIN public.places p ON p.id = pt.place_id
    WHERE p.slug IN (
      'alc-steaks','chez-l-amour','fixe-southern-house','il-brutto','l-oca-d-oro',
      'uovo','el-raval','castillo-craft-bar-kitchen','yellow-ranger','cap-s-on-the-water',
      'aba','canje','clay-pit','comedor','suerte','ezov','justine-s','kemuri-tatsu-ya',
      'sway','lamberts','juniper','sammie-s','lonesome-dove','arlo-grey','emmer-rye',
      'hestia','launderette','lutie-s')
    GROUP BY pt.place_id HAVING count(*) > 1
  ) d;

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G3 FAILED: % place(s) in this batch carry more than one cuisine', v_count;
  END IF;

  -- G4 — nothing was suggested onto an unpublished place. The point of this
  -- batch is the public filter; anything else is noise in the review queue.
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  WHERE pt.source = 'suggested' AND p.status <> 'published'
    AND pt.created_at > now() - interval '1 minute';

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: % suggestion(s) landed on unpublished places', v_count;
  END IF;

  -- G5 — the judgment layer is where it was. This migration has no business
  -- writing a verdict, and the count of places carrying one must not move.
  SELECT count(*) INTO v_count FROM public.places
  WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL OR story IS NOT NULL
     OR last_visited IS NOT NULL;

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G5 FAILED: judgment columns hold % row(s), expected 0', v_count;
  END IF;

  -- G6 — every suggested tag is a real, active, non-admin tag. A suggestion
  -- pointing at `Hype trap` would put a negative verdict in the queue as
  -- though a machine had reached it (RN-14).
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.tags t ON t.id = pt.tag_id
  WHERE pt.source = 'suggested' AND (t.admin_only OR NOT t.active);

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G6 FAILED: % suggestion(s) point at an admin-only or inactive tag', v_count;
  END IF;

  -- G7 — report the shape of the review queue the curator now has.
  SELECT count(*) INTO v_count FROM public.place_tags WHERE source = 'suggested';
  SELECT string_agg(DISTINCT t.label, ', ' ORDER BY t.label) INTO v_names
  FROM public.place_tags pt
  JOIN public.tags t ON t.id = pt.tag_id AND t.facet = 'cuisine'
  WHERE pt.source = 'suggested';

  RAISE NOTICE 'Gates passed: 7 of 7. % suggested assignments now pending review.', v_count;
  RAISE NOTICE 'Cuisines in the queue: %', v_names;
END $GATES$;

COMMIT;

-- ====================================================================
-- Deliberately NOT suggested — 17 published food places left without a
-- cuisine, because the name gives nothing away and public knowledge of the
-- place was not solid enough to be worth a rejection:
--
--   Cosmo (Oxford)      — pan-Asian buffet; no tag in the vocabulary fits
--   Ember Kitchen       — name says nothing about a cuisine
--   Fabrik              — tasting menu, concept unclear from outside
--   Gina's on Congress  — named after a person
--   Haywire             — Texas-themed; could be Southern or Steakhouse
--   Nido                — name says nothing
--   Nomade              — name says nothing
--   Ranch 616           — Hill Country / Gulf Coast, no clean tag
--   Rose Gose           — "gose" is a beer style; likely not a cuisine row
--   Roya                — possibly Persian or Afghan, not confident
--   Space Cowboy        — name says nothing
--   The Carillon        — hotel dining room, concept unclear
--   The Guest House     — name says nothing
--   The Kitchen         — too generic to guess
--   Toshokan            — Japanese name, but it reads as a cocktail bar
--   Vaudeville          — bistro plus gallery plus bakery, no single tag
--   Verbena             — name says nothing
--
-- These are the ones only the curator can settle. Nothing about them is
-- broken; they simply have no cuisine yet.
-- ====================================================================
