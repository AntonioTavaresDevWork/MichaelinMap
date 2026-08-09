-- ====================================================================
-- ROLLBACK — 20260808120000_publish_launch_batch.sql
--
-- ⚠️ This unpublishes the guide. Running it takes the public side from 58
-- places to zero, and the city gate then renders empty — no cities, no error.
-- That is the correct behaviour, not a bug, but it is not subtle to a visitor.
--
-- ⚠️ Only safe before the curator has worked on these rows. Check first:
--   SELECT count(*) FROM places
--    WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL OR story IS NOT NULL;
--   SELECT count(*) FROM place_tags WHERE source = 'curator';
--
-- If either is above zero, the curator has invested in places this reverts to
-- `unreviewed`. The judgment itself survives — this only moves `status` — but
-- the work becomes invisible to visitors until something republishes it.
--
-- WHY THE PREDICATE IS NARROW: it reverts only what the migration could have
-- published. A place the curator later moved to `closed` or `hidden` is a
-- decision of his and is left alone.
-- ====================================================================

BEGIN;

UPDATE public.places
SET status = 'unreviewed'
WHERE status = 'published'
  AND (starred OR tier = 'destination');

DO $VERIFY$
DECLARE v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM public.places WHERE status = 'published';
  RAISE NOTICE 'Rollback done: % place(s) still published', v_count;
END $VERIFY$;

COMMIT;

-- Remove the migration from the ledger as well, or a later `supabase db push`
-- will consider it applied and skip it.
DELETE FROM supabase_migrations.schema_migrations WHERE version = '20260808120000';
