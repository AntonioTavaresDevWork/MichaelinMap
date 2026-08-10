BEGIN;

-- ====================================================================
-- ROLLBACK — 20260810130000_suggest_researched_cuisine_117.sql
--
-- Removes the 122 researched cuisine assignments, and ONLY those that are
-- still `source = 'suggested'`.
--
-- ⚠️  IT WILL NOT TOUCH A CONFIRMED TAG, BY DESIGN AND NOT BY WARNING.
--
-- The curator was working the confirmation queue while the migration was
-- applied — curator rows went from 5 to 136 during that session. Any of these
-- 122 pairs he has since confirmed has stopped being a machine suggestion and
-- become judgment (bible §1.1), and no rollback of mine may delete it. The
-- `source = 'suggested'` predicate in the WHERE is what makes that structural
-- rather than a matter of remembering: it is the same device the S10 bulk
-- confirm uses so it cannot overwrite a decision already taken.
--
-- The NOTICE at the end reports how many rows were spared for that reason.
-- If it is not zero, this rollback did not fully undo the migration — and
-- that is the correct outcome, not a failure.
--
-- Join key is (name, whitespace-normalised address), for the reasons recorded
-- in the migration header: the name alone is ambiguous for five two-location
-- brands, and the exact address matches only 42 of 117 because the database
-- kept a double space before the ZIP that the batch CSV normalised away.
-- ====================================================================

DO $ROLLBACK$
DECLARE
  v_alvo      integer;
  v_apagadas  integer;
  v_poupadas  integer;
BEGIN
  CREATE TEMP TABLE _rb_lote(nome text, endereco text, slug text) ON COMMIT DROP;
  INSERT INTO _rb_lote VALUES
  ('54th Street', '1303 Interstate 35 Frontage Rd, San Marcos, TX 78666, United States', 'burgers'),
  ('54th Street', '127 E Ralph Ablanedo Dr, Austin, TX 78745, United States', 'burgers'),
  ('54th Street', '127 E Ralph Ablanedo Dr, Austin, TX 78745, United States', 'southern-comfort'),
  ('Allday', '4300 Speedway, Unit 103, Austin, TX 78751, United States', 'pizza'),
  ('Alpine Haus Restaurant', '251 S Seguin Ave, New Braunfels, TX 78130, United States', 'german'),
  ('Andice General Store', '6500 FM-970, Florence, TX 76527, United States', 'burgers'),
  ('Anthem', '91 Rainey St, Unit 120, Austin, TX 78701, United States', 'new-american'),
  ('APT 115', '2025 E 7th St, Unit 115, Austin, TX 78702, United States', 'new-american'),
  ('Aris', '1111 W 6th St, Austin, TX 78703, United States', 'steakhouse'),
  ('Aris', '1111 W 6th St, Austin, TX 78703, United States', 'mediterranean'),
  ('Bar Toti', '2113 Manor Rd, Austin, TX 78722, United States', 'modern-european'),
  ('Bartlett''s', '2408 W Anderson Ln, Austin, TX 78757, United States', 'steakhouse'),
  ('Bartlett''s', '2408 W Anderson Ln, Austin, TX 78757, United States', 'burgers'),
  ('Batch - Craft Beer and Kolaches', '3220 Manor Rd, Austin, TX 78723, United States', 'bakery-pastry'),
  ('Bellissima', '8300 N FM 620, Bldg K Unit 200, Austin, TX 78726, United States', 'italian'),
  ('Blue Dahlia Bistro', '107 E Hopkins St, San Marcos, TX 78666, United States', 'modern-european'),
  ('Bread Boat', '1912 E 7th St, Austin, TX 78702, United States', 'georgian'),
  ('Bufalina', '2215 E Cesar Chavez St, Austin, TX 78702, United States', 'pizza'),
  ('Bufalina', '2215 E Cesar Chavez St, Austin, TX 78702, United States', 'italian'),
  ('Bufalina Due', '6555 Burnet Rd, Austin, TX 78757, United States', 'pizza'),
  ('Bufalina Due', '6555 Burnet Rd, Austin, TX 78757, United States', 'italian'),
  ('Café Blue', '12800 Hill Country Blvd, Unit G-115, Bee Cave, TX 78738, United States', 'seafood'),
  ('Captain Pete''s Boathouse', '18200 Lakepoint Cove, Point Venture, TX 78645, United States', 'seafood'),
  ('Casa Bianca', '1510 E Cesar Chavez St, Austin, TX 78702, United States', 'italian'),
  ('Casa De Luz', '1701 Toomey Rd, Austin, TX 78704, United States', 'vegetarian-forward'),
  ('Chez Zee American Bistro', '5406 Balcones Dr, Austin, TX 78731, United States', 'new-american'),
  ('Cipollina', '1213 West Lynn, Austin, TX 78703, United States', 'italian'),
  ('Cody''s Restaurant Bar & Patio', '690 Centerpoint Rd, Unit 209, San Marcos, TX 78666, United States', 'new-american'),
  ('Corinne Austin', '304 E Cesar Chavez St, Austin, TX 78701, United States', 'new-american'),
  ('Craft Omakase', '4400 N Lamar Blvd, Unit 102, Austin, TX 78756, United States', 'sushi'),
  ('Creekhouse', '14015 Ranch Rd 12, Wimberley, TX 78676, United States', 'new-american'),
  ('District Kitchen + Cocktails', '7858 Shoal Creek Blvd, Unit B, Austin, TX 78757, United States', 'new-american'),
  ('District Kitchen+Cocktails', '5900 W Slaughter Ln, Unit D500, Austin, TX 78749, United States', 'new-american'),
  ('Dos Olivos Market', '306 S Main St, Unit 104, Buda, TX 78610, United States', 'spanish'),
  ('El Chile Café Y Cantina', '1900 Manor Rd, Austin, TX 78722, United States', 'tex-mex'),
  ('Este', '2113 Manor Rd, Austin, TX 78722, United States', 'seafood'),
  ('Finley''s', '410 W Main St, Round Rock, TX 78664, United States', 'american'),
  ('Flo''s Wine Bar & Bottle Shop', '3111 W 35th St, Austin, TX 78703, United States', 'wine-bar'),
  ('Foreign & Domestic', '306 E 53rd St, Austin, TX 78751, United States', 'new-american'),
  ('Friedhelm''s Bavarian Inn', '905 W Main St, Fredericksburg, TX 78624, United States', 'german'),
  ('Fukumoto', '514 Medina St, Austin, TX 78702, United States', 'sushi'),
  ('Fukumoto', '514 Medina St, Austin, TX 78702, United States', 'japanese'),
  ('Garrison', '101 Red River St, Austin, TX 78701, United States', 'steakhouse'),
  ('Garrison', '101 Red River St, Austin, TX 78701, United States', 'new-american'),
  ('Hattie B''s Hot Chicken', '2529 S Lamar Blvd, Austin, TX 78704, United States', 'southern-comfort'),
  ('Hopfields', '3110 Guadalupe St, Unit 400, Austin, TX 78705, United States', 'french'),
  ('Huisache Grill', '303 W San Antonio St, New Braunfels, TX 78130, United States', 'new-american'),
  ('Intero', '2612 E Cesar Chavez St, Austin, TX 78702, United States', 'italian'),
  ('Jack Allen''s Kitchen', '1345 E Whitestone Blvd, Cedar Park, TX 78613, United States', 'southern-comfort'),
  ('Jack Allen''s Kitchen', '7720 Highway 71 West, Austin, TX 78735, United States', 'southern-comfort'),
  ('Jacoby''s Restaurant & Mercantile', '3235 E Cesar Chavez St, Austin, TX 78702, United States', 'southern-comfort'),
  ('Jeffrey''s', '1204 West Lynn St, Austin, TX 78703, United States', 'steakhouse'),
  ('Jeffrey''s', '1204 West Lynn St, Austin, TX 78703, United States', 'french'),
  ('Knotty Deck and Bar', '9721 Arboretum Blvd, Austin, TX 78759, United States', 'new-american'),
  ('Krause''s Cafe', '148 S Castell Ave, New Braunfels, TX 78130, United States', 'german'),
  ('Lenoir', '1807 S 1st St, Austin, TX 78704, United States', 'new-american'),
  ('Ling Kitchen', '8423 Research Blvd, Austin, TX 78758, United States', 'chinese'),
  ('Ling Wu Asian Restaurant at Lantana Place', '7415 Southwest Pkwy Bldg 3-400, Austin, TX 78735, United States', 'chinese'),
  ('Ling Wu Asian Restaurant at The Grove', '2625 Perseverance Dr, Austin, TX 78731, United States', 'chinese'),
  ('Loro', '2115 S Lamar Blvd, Austin, TX 78704, United States', 'bbq'),
  ('Lou''s', '1900 E Cesar Chavez St, Austin, TX 78702, United States', 'american'),
  ('Love Supreme', '2805 Manor Rd, Austin, TX 78722, United States', 'pizza'),
  ('Lucky Robot', '1303 S Congress Ave, Austin, TX 78704, United States', 'sushi'),
  ('Lucky Robot', '1303 S Congress Ave, Austin, TX 78704, United States', 'japanese'),
  ('Ma’CoCo', '302 S Main St, Ste 101, Buda, TX 78610, United States', 'mexican'),
  ('Manny''s', '301 W 5th St, Austin, TX 78701, United States', 'caribbean'),
  ('Manuels', '10201 Jollyville Rd, Austin, TX 78759, United States', 'interior-mexican'),
  ('Mattie''s', '901 W Live Oak St, Austin, TX 78704, United States', 'new-american'),
  ('Meat & Bread', '360 Nueces St, Unit 20, Austin, TX 78701, United States', 'sandwiches'),
  ('Millie’s On Main', '212 N Main St, Elgin, TX 78621, United States', 'american'),
  ('Muck & Fuss', '295 E San Antonio St, Unit 101, New Braunfels, TX 78130, United States', 'burgers'),
  ('Murray''s Tavern', '2316 Webberville Rd, Austin, TX 78702, United States', 'cocktails-bar-food'),
  ('New Braunfels Tortilleria', '1681 Spur St, New Braunfels, TX 78130, United States', 'tacos'),
  ('Nightcap', '1401 W 6th St, Austin, TX 78703, United States', 'new-american'),
  ('No 28', '1006 Main St, Bastrop, TX 78602, United States', 'pizza'),
  ('No 28', '1006 Main St, Bastrop, TX 78602, United States', 'italian'),
  ('North Street', '216 North St, San Marcos, TX 78666, United States', 'indian'),
  ('Numero28', '452 W 2nd St, Austin, TX 78701, United States', 'pizza'),
  ('Numero28', '452 W 2nd St, Austin, TX 78701, United States', 'italian'),
  ('Oasthouse Kitchen + Bar', 'Bldg D 5701 W Slaughter Ln, Austin, TX 78749, United States', 'modern-european'),
  ('Odd Duck', '1201 S Lamar Blvd, Austin, TX 78704, United States', 'new-american'),
  ('Oh K-Dog', '6929 Airport Blvd, Unit 133, Austin, TX 78752, United States', 'korean'),
  ('Old Gregg Brewing Company', '1900 E Howard Ln, Building H, Pflugerville, TX 78660, United States', 'brewery'),
  ('Oseyo', '1628 E Cesar Chavez St, Austin, TX 78702, United States', 'korean'),
  ('Patio Dolcetto', '322 Cheatham St, San Marcos, TX 78666, United States', 'pizza'),
  ('Péché', '208 W 4th St, Austin, TX 78701, United States', 'french'),
  ('Péché', '208 W 4th St, Austin, TX 78701, United States', 'cocktails-bar-food'),
  ('Pieous', '166 Hargraves Dr Bldg H, Austin, TX 78737, United States', 'pizza'),
  ('Poeta', '1108 E 6th St, Austin, TX 78702, United States', 'italian'),
  ('Qi Austin', '835 W 6th St, Unit 114, Austin, TX 78703, United States', 'chinese'),
  ('Red Ash', '303 Colorado St, Austin, TX 78701, United States', 'italian'),
  ('Restaurant Francois', '401 W 3rd St, Ste 100, Austin, TX 78701, United States', 'french'),
  ('Root Cellar Cafe', '215 N LBJ Dr, San Marcos, TX 78666, United States', 'breakfast-diner'),
  ('Santa Catarina', '2901 Manor Rd, Unit 100, Austin, TX 78722, United States', 'tex-mex'),
  ('Sazan', '6929 Airport Blvd, Unit 146, Austin, TX 78752, United States', 'ramen'),
  ('Shore Raw Bar & Grill', '8665 W Highway 71, Unit 100, Austin, TX 78735, United States', 'seafood'),
  ('Sidecar at Prince Solms Inn', '295 E San Antonio St, New Braunfels, TX 78130, United States', 'cocktails-bar-food'),
  ('Sour Duck Market', '1814 E Martin Luther King Jr Blvd, Austin, TX 78702, United States', 'bakery-pastry'),
  ('Spud Ranch', '118 Common St, New Braunfels, TX 78130, United States', 'southern-comfort'),
  ('Summer on Music Lane', '1101 Music Ln, Austin, TX 78704, United States', 'new-american'),
  ('Sundancer Grill', '16410 Stewart Rd, Lakeway, TX 78734, United States', 'american'),
  ('Taverna', '258 W 2nd St, Austin, TX 78701, United States', 'italian'),
  ('TenTen', '501 W 6th St, Austin, TX 78701, United States', 'japanese'),
  ('TenTen', '501 W 6th St, Austin, TX 78701, United States', 'sushi'),
  ('The Grove Wine Bar & Kitchen', '6317 RM-2244, Ste 380, Austin, TX 78746, United States', 'new-american'),
  ('The Grove Wine Bar & Kitchen', '3001 Ranch Road 620 S, Austin, TX 78738, United States', 'new-american'),
  ('The Kimberly', '200 W 7th St, Ste 100, Austin, TX 78701, United States', 'new-american'),
  ('Tiki Tatsu-Ya', '1300 S Lamar Blvd, Austin, TX 78704, United States', 'cocktails-bar-food'),
  ('Tsuke Edomae', '4600 Mueller Blvd, Ste 1035, Austin, TX 78723, United States', 'sushi'),
  ('Tumble 22', '7211 Burnet Rd, Austin, TX 78757, United States', 'southern-comfort'),
  ('Uchi', '801 S Lamar Blvd, Austin, TX 78704, United States', 'japanese'),
  ('Uchi', '801 S Lamar Blvd, Austin, TX 78704, United States', 'sushi'),
  ('Uchibā Austin', '601 W 2nd St, Austin, TX 78701, United States', 'japanese'),
  ('Uchibā Austin', '601 W 2nd St, Austin, TX 78701, United States', 'cocktails-bar-food'),
  ('Uroko', '1023 Springdale Rd Bldg 1, Unit 1, Austin, TX 78721, United States', 'sushi'),
  ('Veracruz Fonda & Bar', '1905 Aldrich St, Unit 125, Austin, TX 78723, United States', 'tacos'),
  ('VERDAD True Modern Mexican', '2701 Perseverance Dr, Austin, TX 78731, United States', 'mexican'),
  ('Vic & Al''s', '2406 Manor Rd, Unit D, Austin, TX 78722, United States', 'cajun-creole'),
  ('Vinaigrette', '2201 College Ave, Austin, TX 78704, United States', 'vegetarian-forward'),
  ('Winston’s', '4900 Bee Creek Rd, Spicewood, TX 78669, United States', 'pizza'),
  ('Winston’s', '4900 Bee Creek Rd, Spicewood, TX 78669, United States', 'coffee'),
  ('Yamas', '5308 Balcones Dr, Austin, TX 78731, United States', 'greek');

  CREATE TEMP TABLE _rb_alvo ON COMMIT DROP AS
  SELECT p.id AS place_id, t.id AS tag_id
  FROM _rb_lote l
  JOIN public.places p
    ON p.name = l.nome
   AND regexp_replace(btrim(p.address), '\s+', ' ', 'g') = l.endereco
  JOIN public.tags t
    ON t.facet = 'cuisine' AND t.slug = l.slug;

  SELECT count(*) INTO v_alvo FROM _rb_alvo;

  SELECT count(*) INTO v_poupadas
  FROM _rb_alvo a
  JOIN public.place_tags pt
    ON pt.place_id = a.place_id AND pt.tag_id = a.tag_id
  WHERE pt.source = 'curator';

  DELETE FROM public.place_tags pt
  USING _rb_alvo a
  WHERE pt.place_id = a.place_id
    AND pt.tag_id  = a.tag_id
    AND pt.source  = 'suggested';
  GET DIAGNOSTICS v_apagadas = ROW_COUNT;

  RAISE NOTICE 'rollback: % pairs targeted, % deleted, % spared because the curator confirmed them',
    v_alvo, v_apagadas, v_poupadas;

  IF v_poupadas > 0 THEN
    RAISE NOTICE 'NOT a failure: those % row(s) are judgment now and were left alone', v_poupadas;
  END IF;
END $ROLLBACK$;

COMMIT;
