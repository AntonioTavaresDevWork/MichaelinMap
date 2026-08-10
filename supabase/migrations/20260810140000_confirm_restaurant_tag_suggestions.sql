BEGIN;

-- ====================================================================
-- Confirm every pending tag suggestion on restaurants
--
-- Version: 1.0
-- Requires: 20260810130000_suggest_researched_cuisine_117.sql
--
-- ⚠️  THIS MIGRATION WRITES TO THE JUDGMENT LAYER.
--
-- `place_tags` assignments are named in §1.1 of the bible as part of the only
-- irreplaceable data in the system, and CLAUDE.md forbids an automated routine
-- from touching them without explicit authorisation from Edu. **That
-- authorisation was given explicitly, twice, in S14.** This header records the
-- reasoning because a future reader will otherwise find a bulk write to the
-- protected layer with no explanation.
--
-- WHAT IT DOES: flips every `place_tags` row from `source = 'suggested'` to
-- `source = 'curator'` where the place is a restaurant. 186 pairs across 145
-- restaurants — 136 on unreviewed places, **50 on published ones**, which under
-- RN-31 become visible to visitors the moment this commits.
--
-- THE OBJECTION THAT WAS RAISED, AND THE FACT THAT ANSWERED IT
--
-- The concern put to Edu was that bulk-confirming asserts human judgment over
-- 145 restaurants, and that `source` is the only thing distinguishing a machine
-- guess from a curator's decision — information this migration destroys, since
-- nothing records which rows were which afterwards.
--
-- Edu's answer was a fact not previously written down anywhere: **no approval
-- in this project has ever been made by someone who actually visited these
-- places.** The 136 rows already carrying `source = 'curator'` before this
-- migration were confirmed on the same basis as these. So in this project
-- `curator` has never meant "I ate here" — it means "reviewed and accepted",
-- and the distinction being lost is narrower than it appeared. S08's record
-- that "Edu cannot tag, he has never been to these places" describes the
-- constraint on *inventing* a tag, not on accepting a researched one.
--
-- WHAT MAKES THIS REVERSIBLE, WHICH IT WOULD NOT OTHERWISE BE
--
-- A plain UPDATE here is irreversible: once `source` is uniformly `curator`,
-- nothing in the database says which rows used to be suggestions. So the exact
-- 186 pairs were snapshotted immediately before applying, and the rollback
-- enumerates them by natural key. Without that snapshot this migration could
-- not be undone at all, and `OP-05` still records that no database backup
-- exists.
--
-- WHY IT IS A MIGRATION AND NOT AN AD-HOC UPDATE: because `BL-35` exists. The
-- launch batch of 58 published places was an ad-hoc UPDATE in S05 that lived
-- only in the live database, and a rebuild from the migrations silently
-- returned a guide that rendered empty while looking healthy. Every write that
-- matters gets versioned.
-- ====================================================================


-- ====================================================================
-- BLOCK 01 — The confirmation
--
-- `source = 'suggested'` in the WHERE is what makes this idempotent: rerunning
-- it matches nothing, because everything it touched is already `curator`.
-- ====================================================================

UPDATE public.place_tags pt
SET source = 'curator'
FROM public.places p
WHERE p.id = pt.place_id
  AND p.place_type = 'restaurant'
  AND pt.source = 'suggested';


-- ====================================================================
-- BLOCK 02 — Validation gates
-- ====================================================================

DO $GATES$
DECLARE
  v_count integer;
BEGIN
  -- G1 — no restaurant carries a pending suggestion any more
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  WHERE p.place_type = 'restaurant' AND pt.source = 'suggested';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: % restaurant suggestion(s) still pending', v_count;
  END IF;

  -- G2 — nothing outside restaurants was touched. Non-restaurant places keep
  -- their suggestions; this migration was scoped to restaurants on purpose.
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.places p ON p.id = pt.place_id
  WHERE p.place_type <> 'restaurant' AND pt.source = 'suggested';
  IF v_count = 0 THEN
    RAISE NOTICE 'note: no non-restaurant suggestions remain either, which is possible but worth an eye';
  END IF;

  -- G3 — every row in the table still has a legal source
  SELECT count(*) INTO v_count FROM public.place_tags
  WHERE source NOT IN ('curator', 'suggested');
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G3 FAILED: % row(s) with an invalid source', v_count;
  END IF;

  -- G4 — no assignment was created or destroyed; this migration only relabels
  SELECT count(*) INTO v_count FROM public.place_tags;
  IF v_count <> 348 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: place_tags holds % rows, expected 348. This migration must not create or delete an assignment', v_count;
  END IF;

  RAISE NOTICE 'restaurant tag confirmation: 4 of 4 gates passed';
END $GATES$;

COMMIT;
