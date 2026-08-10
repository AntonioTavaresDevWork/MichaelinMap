BEGIN;

-- ====================================================================
-- ROLLBACK — 20260810150000_confirm_nonrestaurant_tag_suggestions.sql
--
-- Puts the 23 pairs that migration confirmed back to `source = 'suggested'`.
--
-- ⚠️  THIS FILE IS THE ONLY RECORD OF WHICH ROWS WERE SUGGESTIONS, for the same
-- reason as the 20260810140000 rollback: once `source` is uniformly `curator`,
-- no query can tell a row this migration flipped from one confirmed weeks ago.
-- These pairs were snapshotted from the live database immediately before
-- applying. `OP-05` still records that no database backup exists.
-- ====================================================================

DO $ROLLBACK$
DECLARE
  v_alvo   integer;
  v_revert integer;
BEGIN
  CREATE TEMP TABLE _rb_snap(nome text, endereco text, faceta text, slug text) ON COMMIT DROP;
  INSERT INTO _rb_snap VALUES
  ('Azul Rooftop', '310 E Fifth St, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Caroline', '109 E 7th St, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Edge Rooftop', '110 E 2nd St, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('El Cockfight', '121 E 5th St, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Heydey Social Club', '721 Congress Ave, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Hotel Vegas', '1502 E 6th St, Austin, TX 78702, United States', 'occasion', 'night-out'),
  ('Latchkey', '1308 E 6th St, Austin, TX 78702, United States', 'occasion', 'night-out'),
  ('Limestone Rooftop', '68 East Ave, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Lost And Found Rooftop Bar', '219 E San Antonio St, New Braunfels, TX 78130, United States', 'vibe', 'rooftop'),
  ('Otopia Rooftop Lounge', '1901 San Antonio St, Unit 1100, Austin, TX 78705, United States', 'vibe', 'rooftop'),
  ('P6', '111 E Cesar Chavez St, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Pool Bar - East Austin Hotel', '1108 E 6th St, Austin, TX 78702, United States', 'vibe', 'rooftop'),
  ('REINA', '206 Trinity St, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Shiner''s Saloon', '422 Congress Ave, Unit D, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('Urban Rooftop', '411 W Main St, Round Rock, TX 78681, United States', 'vibe', 'rooftop'),
  ('Whisler''s', '1816 E 6th St, Austin, TX 78702, United States', 'occasion', 'night-out'),
  ('Zanzibar', '304 E Cesar Chavez St, Unit 700, Austin, TX 78701, United States', 'vibe', 'rooftop'),
  ('85°C Bakery Cafe', '6929 Airport Blvd, Unit 197, Austin, TX 78752, United States', 'cuisine', 'bakery-pastry'),
  ('Cutie Pies Bake Shop', '62 Cuna St, Saint Augustine, FL 32084, United States', 'cuisine', 'bakery-pastry'),
  ('Gil''s Broiler & The Manske Roll Bakery', '328 N LBJ Dr, San Marcos, TX 78666, United States', 'cuisine', 'bakery-pastry'),
  ('Rocheli Patisserie', '1212 Chicon St, Unit 102, Austin, TX 78702, United States', 'cuisine', 'bakery-pastry'),
  ('Whipped Bakery & Cafe', '15609 Ronald W Reagan Blvd, Unit B220, Leander, TX 78641, United States', 'cuisine', 'bakery-pastry'),
  ('The Good Lot', '2500 W New Hope Dr, Cedar Park, TX 78613, United States', 'format', 'food-truck');

  CREATE TEMP TABLE _rb_pares ON COMMIT DROP AS
  SELECT pt.place_id, pt.tag_id
  FROM _rb_snap s
  JOIN public.places p
    ON p.name = s.nome
   AND regexp_replace(btrim(p.address), '\s+', ' ', 'g') = s.endereco
  JOIN public.tags t ON t.facet = s.faceta AND t.slug = s.slug
  JOIN public.place_tags pt ON pt.place_id = p.id AND pt.tag_id = t.id;

  SELECT count(*) INTO v_alvo FROM _rb_pares;

  UPDATE public.place_tags pt
  SET source = 'suggested'
  FROM _rb_pares r
  WHERE pt.place_id = r.place_id AND pt.tag_id = r.tag_id AND pt.source = 'curator';
  GET DIAGNOSTICS v_revert = ROW_COUNT;

  RAISE NOTICE 'rollback: % pairs resolved, % reverted to suggested', v_alvo, v_revert;
  IF v_alvo <> 23 THEN
    RAISE NOTICE 'WARNING: expected 23 pairs, resolved %', v_alvo;
  END IF;
END $ROLLBACK$;

COMMIT;
