BEGIN;

-- ====================================================================
-- ROLLBACK of 20260809130000_add_german_cuisine.sql
--
-- ⚠️ Only safe while no place carries the slug. Check first:
--     SELECT count(*) FROM public.place_tags pt
--     JOIN public.tags t ON t.id = pt.tag_id
--     WHERE t.facet = 'cuisine' AND t.slug = 'german';
--
-- If that is not 0, STOP. Dropping the tag would cascade the assignments away,
-- and a curator-confirmed assignment is judgment (§1.1) — it does not come back
-- from a re-run. Gate R1 below refuses rather than trusting the reader.
-- ====================================================================

DO $GUARD$
DECLARE v_count integer;
BEGIN
  SELECT count(*) INTO v_count
  FROM public.place_tags pt
  JOIN public.tags t ON t.id = pt.tag_id
  WHERE t.facet = 'cuisine' AND t.slug = 'german';

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE R1 FAILED: german carries % assignment(s). Remove them deliberately first.', v_count;
  END IF;
END $GUARD$;

DELETE FROM public.tags WHERE facet = 'cuisine' AND slug = 'german';

-- Close the slot again. Guarded on the slug being gone, so a second run is a
-- no-op instead of walking the tail down a second time.
UPDATE public.tags
SET sort_order = sort_order - 1
WHERE facet = 'cuisine'
  AND sort_order >= 31
  AND NOT EXISTS (
    SELECT 1 FROM public.tags
    WHERE facet = 'cuisine' AND slug = 'german'
  );

DO $GATES$
DECLARE v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM public.tags WHERE facet = 'cuisine';
  IF v_count <> 37 THEN
    RAISE EXCEPTION 'GATE R2 FAILED: expected 37 cuisine tags after rollback, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count FROM (
    SELECT sort_order FROM public.tags WHERE facet = 'cuisine'
    GROUP BY sort_order HAVING count(*) > 1
  ) dup;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE R3 FAILED: % duplicated sort_order value(s) in cuisine', v_count;
  END IF;

  RAISE NOTICE 'german rollback gates passed: 3 of 3';
END $GATES$;

COMMIT;
