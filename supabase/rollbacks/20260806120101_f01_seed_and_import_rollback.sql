BEGIN;

-- ========================================================================
-- ROLLBACK — 20260806120100_f01_seed_and_import.sql
--
-- Removes the imported data but leaves the schema standing.
--
-- ⚠️ Only safe before the curator has started working. Once he has assigned
-- tags, written the_dish or set a tier, this deletes his judgment along with
-- the import — and that is the one thing in the system that cannot be
-- reconstructed. Check for curator-sourced rows first:
--
--   SELECT count(*) FROM place_tags WHERE source = 'curator';
--   SELECT count(*) FROM places
--   WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL OR story IS NOT NULL;
--
-- If either returns non-zero, stop and roll back by hand.
-- ========================================================================

-- Machine guesses only. Curator assignments are left alone on purpose.
DELETE FROM public.place_tags WHERE source = 'suggested';

DELETE FROM public.places WHERE source = 'apple_csv';

DELETE FROM public.codes WHERE code = 'DEMO';

DELETE FROM public.questions;

DELETE FROM public.tags;

-- Tiers last: places reference them with ON DELETE RESTRICT, so any surviving
-- place still carrying a tier will make this fail loudly rather than silently
-- strip the judgment layer.
DELETE FROM public.tiers;

COMMIT;
