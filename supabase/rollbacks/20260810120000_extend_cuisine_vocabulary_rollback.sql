BEGIN;

-- ====================================================================
-- ROLLBACK — 20260810120000_extend_cuisine_vocabulary.sql
--
-- Removes the seven cuisine slugs added in S13 and restores the 38-slug
-- ordering that 20260809130000_add_german_cuisine.sql left behind.
--
-- ⚠️  REFUSES TO RUN IF ANY OF THE SEVEN IS IN USE. Deleting a tag that a place
--     carries would delete judgment, and no rollback is allowed to do that. If
--     the guard fires, the assignments must be removed deliberately first — by
--     a human who has looked at them — and this script re-run.
-- ====================================================================

DO $GUARD$
DECLARE
  v_count integer;
  v_used  text;
BEGIN
  SELECT count(*), string_agg(DISTINCT t.slug, ', ')
  INTO v_count, v_used
  FROM public.place_tags pt
  JOIN public.tags t ON t.id = pt.tag_id
  WHERE t.facet = 'cuisine'
    AND t.slug IN ('american','mexican','cajun-creole','georgian','sandwiches','wine-bar','brewery');

  IF v_count > 0 THEN
    RAISE EXCEPTION 'ROLLBACK REFUSED: % assignment(s) exist on slug(s) %. Remove them deliberately first', v_count, v_used;
  END IF;
END $GUARD$;


DELETE FROM public.tags
WHERE facet = 'cuisine'
  AND slug IN ('american','mexican','cajun-creole','georgian','sandwiches','wine-bar','brewery');


-- Restore the 38-slug ordering exactly as it stood after 20260809130000.
UPDATE public.tags t
SET sort_order = v.ord
FROM (VALUES
  ('bbq', 0), ('tex-mex', 1), ('tacos', 2), ('interior-mexican', 3),
  ('southern-comfort', 4), ('burgers', 5), ('pizza', 6), ('italian', 7),
  ('steakhouse', 8), ('seafood', 9), ('new-american', 10), ('japanese', 11),
  ('sushi', 12), ('ramen', 13), ('korean', 14), ('chinese', 15),
  ('thai', 16), ('vietnamese', 17), ('indian', 18), ('middle-eastern', 19),
  ('mediterranean', 20), ('ethiopian', 21), ('caribbean', 22),
  ('vegetarian-forward', 23), ('breakfast-diner', 24), ('bakery-pastry', 25),
  ('coffee', 26), ('cocktails-bar-food', 27), ('british', 28), ('french', 29),
  ('german', 30), ('spanish', 31), ('portuguese', 32), ('greek', 33),
  ('turkish', 34), ('brazilian', 35), ('peruvian', 36), ('modern-european', 37)
) AS v(slug, ord)
WHERE t.facet = 'cuisine'
  AND t.slug = v.slug
  AND t.sort_order IS DISTINCT FROM v.ord;


DO $VERIFY$
DECLARE
  v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM public.tags WHERE facet = 'cuisine';
  IF v_count <> 38 THEN
    RAISE EXCEPTION 'ROLLBACK VERIFY FAILED: expected 38 cuisine tags, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count FROM (
    SELECT sort_order FROM public.tags WHERE facet = 'cuisine'
    GROUP BY sort_order HAVING count(*) > 1
  ) dup;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ROLLBACK VERIFY FAILED: % duplicated sort_order value(s)', v_count;
  END IF;

  RAISE NOTICE 'rollback verified: cuisine back to 38 slugs, contiguous ordering';
END $VERIFY$;

COMMIT;
