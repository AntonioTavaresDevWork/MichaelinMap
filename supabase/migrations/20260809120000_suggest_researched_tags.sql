BEGIN;

-- ====================================================================
-- Researched tags for the published food places that had no cuisine
--
-- Version: 1.0
-- Requires: 20260806120100_f01_seed_and_import.sql (the places and the vocabulary)
-- Backlog items advanced here: BL-38
--
-- WHERE THESE CAME FROM
--
-- S10 ran a research pipeline over the 17 published food places carrying no
-- cuisine tag. Every assignment below came back with a source URL and a quoted
-- line from that source; the prompt forbade inference from the place's name and
-- required abstention over guessing. The researcher declined to tag four places
-- rather than fill the gap, which is the behaviour that made the rest usable.
--
-- WHY THEY ENTER AS `suggested`
--
-- Because that is what they are: a machine read a menu, not a person who ate
-- there. Under RN-31 a suggested tag reaches no public surface at all, so this
-- migration changes nothing a visitor sees. It fills an approval queue, and the
-- admin's tag filter plus its bulk-confirm bar (S10) is how that queue gets
-- worked. Confirming is a separate, human act.
--
-- WHAT IS DELIBERATELY NOT HERE
--
-- - `Gina's on Congress` got no tags. Three independent sources report it closed
--   (Yelp, Corner as of April 2026, and KVUE in January 2026 on the parent
--   company's unpaid staff), against one counter-signal: its own site is still
--   live. That is DP-10 and belongs to Michael, not to a migration.
-- - `Cosmo`, `Ranch 616` and `Space Cowboy` got no cuisine. The vocabulary has
--   no slug that fits a pan-global buffet, a self-described South Texas ice
--   house whose own menu says it is neither Tex-Mex nor Southwestern, or a
--   deliberately cross-cultural kitchen. That is DP-11, and inventing a slug
--   here would be worse than the gap.
-- - `The Carillon` did not get `open-monday`. It opens Monday for breakfast and
--   lunch but not for dinner, and in a guide about where to eat, "Open Monday"
--   reads as "you can have dinner there". A tag that is technically true and
--   practically misleading is worse than no tag.
--
-- Four of the seven cuisine assignments below are the least-wrong slug rather
-- than a good one — Nomade is Yucatecan (coastal) filed under `interior-mexican`,
-- Roya is Persian under `middle-eastern`, Verbena is contemporary Mexican with
-- French technique, Ember Kitchen is contemporary Latin under `steakhouse`.
-- They are suggestions precisely so a person can reject them. See DP-11.
-- ====================================================================


-- ====================================================================
-- BLOCK 01 — The assignments
--
-- WHY THE SUBQUERY SHAPE: no hardcoded UUIDs. Places resolve by `slug` (UNIQUE,
-- and stable — 9 namesakes in this dataset are disambiguated by it, while names
-- are not unique by contract), and tags by the compound `(facet, slug)` that
-- their own UNIQUE constraint defines. If either side is missing the row simply
-- does not insert, and gate G1 catches the shortfall.
--
-- WHY ON CONFLICT DO NOTHING: the primary key is (place_id, tag_id), so a re-run
-- is inert. It also means this migration can never overwrite a `source` the
-- curator has already changed to `curator` — confirming is one-way here.
-- ====================================================================

INSERT INTO public.place_tags (place_id, tag_id, source)
SELECT p.id, t.id, 'suggested'
FROM (VALUES
  -- place slug         facet        tag slug
  ('cosmo',            'format',    'sit-down-restaurant'),
  ('cosmo',            'logistics', 'open-monday'),

  ('ember-kitchen',    'cuisine',   'steakhouse'),
  ('ember-kitchen',    'format',    'sit-down-restaurant'),
  ('ember-kitchen',    'logistics', 'open-monday'),

  ('fabrik',           'cuisine',   'vegetarian-forward'),
  ('fabrik',           'format',    'fine-dining'),
  ('fabrik',           'dietary',   'vegan-options'),
  ('fabrik',           'dietary',   'vegetarian-options'),
  ('fabrik',           'dietary',   'genuinely-good-for-vegetarians'),
  ('fabrik',           'logistics', 'reservations-essential'),

  ('haywire',          'cuisine',   'new-american'),
  ('haywire',          'cuisine',   'southern-comfort'),
  ('haywire',          'format',    'sit-down-restaurant'),
  ('haywire',          'logistics', 'open-monday'),

  ('nido',             'cuisine',   'new-american'),
  ('nido',             'format',    'sit-down-restaurant'),
  ('nido',             'logistics', 'open-for-breakfast'),
  ('nido',             'logistics', 'open-monday'),

  ('nomade',           'cuisine',   'seafood'),
  ('nomade',           'cuisine',   'interior-mexican'),
  ('nomade',           'dietary',   'gluten-free-options'),
  ('nomade',           'format',    'sit-down-restaurant'),

  ('ranch-616',        'format',    'sit-down-restaurant'),
  ('ranch-616',        'logistics', 'open-monday'),

  ('rose-gose',        'cuisine',   'modern-european'),
  ('rose-gose',        'format',    'sit-down-restaurant'),
  ('rose-gose',        'logistics', 'open-monday'),

  ('roya',             'cuisine',   'middle-eastern'),
  ('roya',             'format',    'sit-down-restaurant'),
  ('roya',             'logistics', 'open-monday'),

  ('space-cowboy',     'format',    'sit-down-restaurant'),
  ('space-cowboy',     'logistics', 'open-monday'),

  ('the-carillon',     'cuisine',   'new-american'),
  ('the-carillon',     'format',    'fine-dining'),
  ('the-carillon',     'logistics', 'open-for-breakfast'),

  ('the-guest-house',  'cuisine',   'new-american'),
  ('the-guest-house',  'format',    'sit-down-restaurant'),
  ('the-guest-house',  'logistics', 'open-monday'),

  ('the-kitchen',      'cuisine',   'new-american'),
  ('the-kitchen',      'format',    'sit-down-restaurant'),

  ('toshokan',         'cuisine',   'sushi'),
  ('toshokan',         'format',    'fine-dining'),
  ('toshokan',         'logistics', 'reservations-essential'),
  ('toshokan',         'logistics', 'reservations-weeks-out'),

  ('vaudeville',       'cuisine',   'new-american'),
  ('vaudeville',       'format',    'sit-down-restaurant'),
  ('vaudeville',       'logistics', 'closes-early'),
  ('vaudeville',       'logistics', 'open-monday'),

  ('verbena',          'cuisine',   'interior-mexican'),
  ('verbena',          'format',    'sit-down-restaurant'),
  ('verbena',          'logistics', 'open-for-breakfast'),
  ('verbena',          'logistics', 'open-monday')
) AS v(place_slug, facet, tag_slug)
JOIN public.places p ON p.slug = v.place_slug
JOIN public.tags   t ON t.facet = v.facet AND t.slug = v.tag_slug
ON CONFLICT (place_id, tag_id) DO NOTHING;


-- ====================================================================
-- BLOCK 02 — Validation gates
--
-- No GRANT/REVOKE block: this migration creates no object.
-- ====================================================================

DO $GATES$
DECLARE
  v_count   integer;
  v_places  integer;
BEGIN
  -- G1 — every row in the list resolved. A typo in a place slug or a tag slug
  -- would silently insert nothing at all, which is the failure mode this whole
  -- subquery shape is exposed to.
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  WHERE p.slug IN ('cosmo','ember-kitchen','fabrik','haywire','nido','nomade','ranch-616',
                   'rose-gose','roya','space-cowboy','the-carillon','the-guest-house',
                   'the-kitchen','toshokan','vaudeville','verbena');
  IF v_count <> 53 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 53 assignments across the 16 places, found %', v_count;
  END IF;

  -- G2 — the batch touched exactly 16 places, not 15 and not 17.
  SELECT count(DISTINCT pt.place_id) INTO v_places
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  WHERE p.slug IN ('cosmo','ember-kitchen','fabrik','haywire','nido','nomade','ranch-616',
                   'rose-gose','roya','space-cowboy','the-carillon','the-guest-house',
                   'the-kitchen','toshokan','vaudeville','verbena');
  IF v_places <> 16 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: expected 16 places touched, found %', v_places;
  END IF;

  -- G3 — nothing here was written as a curator call. This migration is a
  -- machine's reading of a menu; RN-31 keeps it off every public surface until a
  -- person says otherwise, and that only holds while `source` is honest.
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  WHERE p.slug IN ('cosmo','ember-kitchen','fabrik','haywire','nido','nomade','ranch-616',
                   'rose-gose','roya','space-cowboy','the-carillon','the-guest-house',
                   'the-kitchen','toshokan','vaudeville','verbena')
    AND pt.source <> 'suggested';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G3 FAILED: % assignment(s) in the batch are not suggested', v_count;
  END IF;

  -- G4 — the point of the exercise. Published food places without a cuisine tag
  -- should have gone from 17 to 4: Gina's (DP-10) plus the three the vocabulary
  -- cannot describe (DP-11).
  SELECT count(*) INTO v_count
  FROM public.places p
  WHERE p.status = 'published'
    AND p.place_type IN ('restaurant','bar','food_truck','dessert','winery')
    AND NOT EXISTS (
      SELECT 1 FROM public.place_tags pt
      JOIN public.tags t ON t.id = pt.tag_id
      WHERE pt.place_id = p.id AND t.facet = 'cuisine');
  IF v_count <> 4 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: expected 4 published food places still without a cuisine, found %', v_count;
  END IF;

  -- G5 — judgment integrity. A tag batch must never touch the layer only Michael
  -- writes to. These are all still zero, and this migration must not be what
  -- changes that.
  SELECT count(*) INTO v_count
  FROM public.places
  WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL OR story IS NOT NULL
     OR last_visited IS NOT NULL OR price_band IS NOT NULL;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G5 FAILED: % place(s) carry judgment-layer data this batch must not have written', v_count;
  END IF;

  -- G6 — no admin-only tag reached a place. `Hype trap` is a negative verdict
  -- and is Michael's alone (RN-14); a research pipeline must never assign one.
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.tags t ON t.id = pt.tag_id
  WHERE t.admin_only;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G6 FAILED: % admin-only tag assignment(s) exist', v_count;
  END IF;

  RAISE NOTICE 'Researched tag batch gates passed: 6 of 6 (53 assignments, 16 places)';
END $GATES$;

COMMIT;
