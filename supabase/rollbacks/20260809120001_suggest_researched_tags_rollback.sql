-- ====================================================================
-- ROLLBACK — 20260809120000_suggest_researched_tags.sql
--
-- Surgical: it deletes only the 52 assignments this batch created, and only
-- while they are still `suggested`. It touches neither the 145 from the F-01
-- import nor the 28 from 20260807140000.
--
-- WHY `source = 'suggested'` IS IN THE PREDICATE: confirming a suggestion turns
-- it into `curator`, and that is Michael's call. A row he has confirmed is no
-- longer this batch's to remove — this rollback skips it on purpose. If you
-- genuinely want to undo a confirmation, that is a decision, not a rollback.
--
-- Check what you would be dropping before running:
--   SELECT p.name, t.facet, t.slug, pt.source
--     FROM place_tags pt
--     JOIN places p ON p.id = pt.place_id
--     JOIN tags   t ON t.id = pt.tag_id
--    WHERE p.slug IN ('cosmo','ember-kitchen','fabrik','haywire','nido','nomade',
--                     'ranch-616','rose-gose','roya','space-cowboy','the-carillon',
--                     'the-guest-house','the-kitchen','toshokan','vaudeville','verbena')
--    ORDER BY p.name, t.facet;
-- ====================================================================

BEGIN;

DELETE FROM public.place_tags pt
USING public.places p, public.tags t
WHERE pt.place_id = p.id
  AND pt.tag_id   = t.id
  AND pt.source   = 'suggested'
  AND (p.slug, t.facet, t.slug) IN (
    ('cosmo','format','sit-down-restaurant'),
    ('cosmo','logistics','open-monday'),
    ('ember-kitchen','cuisine','steakhouse'),
    ('ember-kitchen','format','sit-down-restaurant'),
    ('ember-kitchen','logistics','open-monday'),
    ('fabrik','cuisine','vegetarian-forward'),
    ('fabrik','format','fine-dining'),
    ('fabrik','dietary','vegan-options'),
    ('fabrik','dietary','vegetarian-options'),
    ('fabrik','dietary','genuinely-good-for-vegetarians'),
    ('fabrik','logistics','reservations-essential'),
    ('haywire','cuisine','new-american'),
    ('haywire','cuisine','southern-comfort'),
    ('haywire','format','sit-down-restaurant'),
    ('haywire','logistics','open-monday'),
    ('nido','cuisine','new-american'),
    ('nido','format','sit-down-restaurant'),
    ('nido','logistics','open-for-breakfast'),
    ('nido','logistics','open-monday'),
    ('nomade','cuisine','seafood'),
    ('nomade','cuisine','interior-mexican'),
    ('nomade','dietary','gluten-free-options'),
    ('nomade','format','sit-down-restaurant'),
    ('ranch-616','format','sit-down-restaurant'),
    ('ranch-616','logistics','open-monday'),
    ('rose-gose','cuisine','modern-european'),
    ('rose-gose','format','sit-down-restaurant'),
    ('rose-gose','logistics','open-monday'),
    ('roya','cuisine','middle-eastern'),
    ('roya','format','sit-down-restaurant'),
    ('roya','logistics','open-monday'),
    ('space-cowboy','format','sit-down-restaurant'),
    ('space-cowboy','logistics','open-monday'),
    ('the-carillon','cuisine','new-american'),
    ('the-carillon','format','fine-dining'),
    ('the-carillon','logistics','open-for-breakfast'),
    ('the-guest-house','cuisine','new-american'),
    ('the-guest-house','format','sit-down-restaurant'),
    ('the-guest-house','logistics','open-monday'),
    ('the-kitchen','cuisine','new-american'),
    ('the-kitchen','format','sit-down-restaurant'),
    ('toshokan','cuisine','sushi'),
    ('toshokan','format','fine-dining'),
    ('toshokan','logistics','reservations-essential'),
    ('toshokan','logistics','reservations-weeks-out'),
    ('vaudeville','cuisine','new-american'),
    ('vaudeville','format','sit-down-restaurant'),
    ('vaudeville','logistics','closes-early'),
    ('vaudeville','logistics','open-monday'),
    ('verbena','cuisine','interior-mexican'),
    ('verbena','format','sit-down-restaurant'),
    ('verbena','logistics','open-for-breakfast'),
    ('verbena','logistics','open-monday')
  );

DO $VERIFY$
DECLARE v_total integer; v_kept integer;
BEGIN
  SELECT count(*) INTO v_total FROM public.place_tags;
  SELECT count(*) INTO v_kept  FROM public.place_tags WHERE source = 'curator';
  RAISE NOTICE 'Rollback done: % assignments remain, % of them curator-confirmed', v_total, v_kept;
END $VERIFY$;

COMMIT;

DELETE FROM supabase_migrations.schema_migrations WHERE version = '20260809120000';
