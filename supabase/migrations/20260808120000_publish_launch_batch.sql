BEGIN;

-- ====================================================================
-- Launch batch — the 58 places the guide opened with
--
-- Version: 1.0
-- Requires: 20260806120100_f01_seed_and_import.sql (the 511 places)
-- Backlog items closed here: BL-35
--
-- WHY THIS MIGRATION EXISTS
--
-- The launch batch was published in S05 by an ad-hoc UPDATE and lived only in
-- the live database. Every other write in this project came from a migration,
-- so applying the four existing ones to a fresh Supabase project rebuilt the
-- schema, the vocabulary and all 511 places — and returned them all
-- `unreviewed`. The public guide then renders EMPTY WHILE LOOKING HEALTHY: the
-- city gate counts published places, so it shows no city at all, with no error
-- and no clue that anything is missing.
--
-- Audited in S10, field by field: the published `status` on these 58 rows was
-- the ONLY divergence between the live database and what the migrations
-- reproduce. Everything else — website, price_band, last_visited, the_dish,
-- curator_note, story, tier changes, tag assignments, codes, field reports —
-- was either untouched or already came from a migration. Writing this one down
-- closes the gap.
-- ====================================================================


-- ====================================================================
-- BLOCK 01 — Publish the launch batch
--
-- WHY THIS CRITERION: it is not new judgment. `starred` and `tier` came from
-- Michael's own 19 Apple Maps guides; the import simply had not surfaced them.
-- The batch is every place carrying a star or the `destination` tier — recorded
-- in bible §12 and verified in S10 to reproduce exactly the 58 rows that are
-- published today, with zero difference in either direction.
--
-- WHY IT IS IDEMPOTENT BY END STATE, not by rows affected: run against the live
-- database it updates nothing, because those rows are already published. Run
-- against a rebuild it publishes 58. The gates below assert the end state, so
-- both paths pass.
--
-- WHY `status = 'unreviewed'` IS IN THE PREDICATE: a place the curator later
-- moved to `closed` or `hidden` is a decision, and re-publishing it here would
-- silently undo that decision on every re-run.
--
-- WHY `updated_by` IS NOT SET: it is an FK to auth.users, and on a fresh project
-- that account does not exist yet — 20260806130000 is what seeds the curator,
-- and it deliberately aborts if the auth account is missing. Leaving this null
-- keeps the rebuild order flexible. On the live database nothing is touched
-- anyway, so the existing values stay.
-- ====================================================================

UPDATE public.places
SET status = 'published'
WHERE status = 'unreviewed'
  AND (starred OR tier = 'destination');


-- ====================================================================
-- BLOCK 02 — Validation gates
--
-- No GRANT/REVOKE block: this migration creates no object, so there are no
-- default privileges to correct. See the skill's note on why that block is
-- otherwise always second to last.
-- ====================================================================

DO $GATES$
DECLARE
  v_count    integer;
  v_orphan   integer;
  v_missing  integer;
BEGIN
  -- G1 — the batch is exactly the size the record says it is
  SELECT count(*) INTO v_count FROM public.places WHERE status = 'published';
  IF v_count <> 58 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 58 published places, found %', v_count;
  END IF;

  -- G2 — nothing published that the criterion does not cover. Catches a place
  -- published by hand outside the rule, which would make this file a lie about
  -- what the guide contains.
  SELECT count(*) INTO v_orphan
  FROM public.places
  WHERE status = 'published' AND NOT (starred OR tier = 'destination');
  IF v_orphan <> 0 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: % published place(s) fall outside the launch criterion', v_orphan;
  END IF;

  -- G3 — nothing the criterion covers left behind, unless the curator moved it
  -- somewhere deliberate. `unreviewed` is the only state this migration owns.
  SELECT count(*) INTO v_missing
  FROM public.places
  WHERE (starred OR tier = 'destination') AND status = 'unreviewed';
  IF v_missing <> 0 THEN
    RAISE EXCEPTION 'GATE G3 FAILED: % place(s) match the criterion but stayed unreviewed', v_missing;
  END IF;

  -- G4 — the constraint that would actually bite on a rebuild. A published
  -- place needs a city (RN-09); this asserts the batch cannot violate it.
  SELECT count(*) INTO v_count
  FROM public.places WHERE status = 'published' AND city IS NULL;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: % published place(s) have no city', v_count;
  END IF;

  -- G5 — judgment integrity. This migration touches `status` and nothing else,
  -- so an unvisited place must never have come out of it carrying a tier or a
  -- star (RN-01, RN-02). Guaranteed by constraint; asserted because this is the
  -- migration that makes those rows publicly visible.
  SELECT count(*) INTO v_count
  FROM public.places
  WHERE status = 'published' AND NOT visited;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G5 FAILED: % published place(s) are marked not visited', v_count;
  END IF;

  -- G6 — `unclassified` is not a facet anyone can filter by, so it must not
  -- reach the public guide (RN-10).
  SELECT count(*) INTO v_count
  FROM public.places
  WHERE status = 'published' AND place_type = 'unclassified';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G6 FAILED: % published place(s) have no place type', v_count;
  END IF;

  RAISE NOTICE 'Launch batch gates passed: 6 of 6 (58 published)';
END $GATES$;

COMMIT;
