BEGIN;

-- ====================================================================
-- Rollback for 20260807140000_suggest_cuisine_published
--
-- ⚠️ Read before running.
--
-- This removes ONLY the 28 cuisine suggestions that migration added, and
-- only while they are still `suggested`. Two things it deliberately does
-- not do:
--
--   It does not touch the 145 assignments the F-01 import created. A blanket
--   `DELETE FROM place_tags WHERE source = 'suggested'` would take those with
--   it, and they are a separate batch with a separate history.
--
--   It does not touch anything the curator has confirmed. Confirming a
--   suggestion in the admin flips `source` to 'curator', and the predicate
--   below skips those rows — approving a guess makes it his, and rolling
--   back a machine batch must never delete his work.
--
-- Check what you would lose first:
--   SELECT count(*) FROM public.place_tags WHERE source = 'curator';
--   SELECT p.name, t.label FROM public.place_tags pt
--     JOIN public.places p ON p.id = pt.place_id
--     JOIN public.tags   t ON t.id = pt.tag_id
--    WHERE pt.source = 'curator' AND t.facet = 'cuisine';
-- ====================================================================

DELETE FROM public.place_tags pt
USING public.places p, public.tags t
WHERE pt.place_id = p.id
  AND pt.tag_id   = t.id
  AND pt.source   = 'suggested'
  AND t.facet     = 'cuisine'
  AND (p.slug, t.slug) IN (
    ('alc-steaks',                 'steakhouse'),
    ('chez-l-amour',               'french'),
    ('fixe-southern-house',        'southern-comfort'),
    ('il-brutto',                  'italian'),
    ('l-oca-d-oro',                'italian'),
    ('uovo',                       'italian'),
    ('el-raval',                   'spanish'),
    ('castillo-craft-bar-kitchen', 'cocktails-bar-food'),
    ('yellow-ranger',              'cocktails-bar-food'),
    ('cap-s-on-the-water',         'seafood'),
    ('aba',                        'mediterranean'),
    ('canje',                      'caribbean'),
    ('clay-pit',                   'indian'),
    ('comedor',                    'interior-mexican'),
    ('suerte',                     'interior-mexican'),
    ('ezov',                       'middle-eastern'),
    ('justine-s',                  'french'),
    ('kemuri-tatsu-ya',            'japanese'),
    ('sway',                       'thai'),
    ('lamberts',                   'bbq'),
    ('juniper',                    'italian'),
    ('sammie-s',                   'italian'),
    ('lonesome-dove',              'steakhouse'),
    ('arlo-grey',                  'new-american'),
    ('emmer-rye',                  'new-american'),
    ('hestia',                     'new-american'),
    ('launderette',                'new-american'),
    ('lutie-s',                    'new-american')
  );

DO $GATES$
DECLARE v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM public.place_tags WHERE source = 'suggested';
  RAISE NOTICE 'Rollback done. % suggested assignments remain (the F-01 import batch).', v_count;
END $GATES$;

COMMIT;
