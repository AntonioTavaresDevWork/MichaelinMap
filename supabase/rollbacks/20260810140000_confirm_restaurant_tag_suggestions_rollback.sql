BEGIN;

-- ====================================================================
-- ROLLBACK — 20260810140000_confirm_restaurant_tag_suggestions.sql
--
-- Puts the 186 pairs that migration confirmed back to `source = 'suggested'`.
--
-- ⚠️  THIS FILE IS THE ONLY RECORD OF WHICH ROWS WERE SUGGESTIONS.
--
-- The migration flipped `source` in bulk, and once that ran the database no
-- longer distinguishes a row it confirmed from one confirmed by hand weeks
-- earlier. There is no query that can reconstruct the difference. These 186
-- pairs were snapshotted from the live database in the seconds before the
-- migration was applied, and enumerating them here is what makes an otherwise
-- irreversible operation reversible. `OP-05` still records that no database
-- backup exists.
--
-- ⚠️  ONE RACE WINDOW, STATED RATHER THAN HIDDEN.
--
-- The curator was actively working the confirmation queue while this ran. If he
-- confirmed one of these pairs by hand between the snapshot and the migration,
-- this rollback would push his own decision back to `suggested`. The window was
-- seconds and the migration's own gate confirmed the affected count, but the
-- risk is not zero. **Read the NOTICE output before trusting a full rollback**,
-- and prefer reverting a named subset if the intent is narrower.
--
-- Join key is (name, whitespace-normalised address, facet, slug) — the database
-- keeps a double space before the ZIP that the research CSV normalised away, so
-- an exact address match would silently miss most rows.
-- ====================================================================

DO $ROLLBACK$
DECLARE
  v_alvo     integer;
  v_revert   integer;
  v_ja_sugg  integer;
BEGIN
  CREATE TEMP TABLE _rb_snap(nome text, endereco text, faceta text, slug text) ON COMMIT DROP;
  INSERT INTO _rb_snap VALUES
  ('1886 Cafe & Bakery', '604 Brazos St, Austin, TX 78701, United States', 'cuisine', 'bakery-pastry'),
  ('54th Street', '127 E Ralph Ablanedo Dr, Austin, TX 78745, United States', 'cuisine', 'burgers'),
  ('54th Street', '1303 Interstate 35 Frontage Rd, San Marcos, TX 78666, United States', 'cuisine', 'burgers'),
  ('54th Street', '127 E Ralph Ablanedo Dr, Austin, TX 78745, United States', 'cuisine', 'southern-comfort'),
  ('85°C Bakery Cafe', '11301 Lakeline Blvd, Unit 140, Austin, TX 78717, United States', 'cuisine', 'bakery-pastry'),
  ('Aba', '1011 S Congress Ave Building 2, Ste 180, Austin, TX 78704, United States', 'cuisine', 'mediterranean'),
  ('Allday', '4300 Speedway, Unit 103, Austin, TX 78751, United States', 'cuisine', 'pizza'),
  ('Alpine Haus Restaurant', '251 S Seguin Ave, New Braunfels, TX 78130, United States', 'cuisine', 'german'),
  ('Andice General Store', '6500 FM-970, Florence, TX 76527, United States', 'cuisine', 'burgers'),
  ('Anthem', '91 Rainey St, Unit 120, Austin, TX 78701, United States', 'cuisine', 'new-american'),
  ('APT 115', '2025 E 7th St, Unit 115, Austin, TX 78702, United States', 'cuisine', 'new-american'),
  ('Aris', '1111 W 6th St, Austin, TX 78703, United States', 'cuisine', 'mediterranean'),
  ('Aris', '1111 W 6th St, Austin, TX 78703, United States', 'cuisine', 'steakhouse'),
  ('Bar Toti', '2113 Manor Rd, Austin, TX 78722, United States', 'cuisine', 'modern-european'),
  ('Bartlett''s', '2408 W Anderson Ln, Austin, TX 78757, United States', 'cuisine', 'burgers'),
  ('Bartlett''s', '2408 W Anderson Ln, Austin, TX 78757, United States', 'cuisine', 'steakhouse'),
  ('Batch - Craft Beer and Kolaches', '3220 Manor Rd, Austin, TX 78723, United States', 'cuisine', 'bakery-pastry'),
  ('Bellissima', '8300 N FM 620, Bldg K Unit 200, Austin, TX 78726, United States', 'cuisine', 'italian'),
  ('Bitelo Brazilian SteakHouse', '1850 S Lakeline Blvd, Ste 200, Cedar Park, TX 78613, United States', 'cuisine', 'brazilian'),
  ('Blue Dahlia Bistro', '107 E Hopkins St, San Marcos, TX 78666, United States', 'cuisine', 'modern-european'),
  ('Bread Boat', '1912 E 7th St, Austin, TX 78702, United States', 'cuisine', 'georgian'),
  ('Bufalina', '2215 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'italian'),
  ('Bufalina', '2215 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'pizza'),
  ('Bufalina Due', '6555 Burnet Rd, Austin, TX 78757, United States', 'cuisine', 'italian'),
  ('Bufalina Due', '6555 Burnet Rd, Austin, TX 78757, United States', 'cuisine', 'pizza'),
  ('Café Blue', '12800 Hill Country Blvd, Unit G-115, Bee Cave, TX 78738, United States', 'cuisine', 'seafood'),
  ('Canje', '1914 E 6th St, Unit C, Austin, TX 78702, United States', 'cuisine', 'caribbean'),
  ('Captain Pete''s Boathouse', '18200 Lakepoint Cove, Point Venture, TX 78645, United States', 'cuisine', 'seafood'),
  ('Casa Bianca', '1510 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'italian'),
  ('Casa De Luz', '1701 Toomey Rd, Austin, TX 78704, United States', 'cuisine', 'vegetarian-forward'),
  ('Castillo Craft Bar + Kitchen', '6 W Castillo Dr, Saint Augustine, FL 32084, United States', 'cuisine', 'cocktails-bar-food'),
  ('Chez L''Amour', '45 San Marco Ave, Saint Augustine, FL 32084, United States', 'cuisine', 'french'),
  ('Chez Zee American Bistro', '5406 Balcones Dr, Austin, TX 78731, United States', 'cuisine', 'new-american'),
  ('Cipollina', '1213 West Lynn, Austin, TX 78703, United States', 'cuisine', 'italian'),
  ('Clay Pit', '1601 Guadalupe St, Austin, TX 78701, United States', 'cuisine', 'indian'),
  ('Cody''s Restaurant Bar & Patio', '690 Centerpoint Rd, Unit 209, San Marcos, TX 78666, United States', 'cuisine', 'new-american'),
  ('Corinne Austin', '304 E Cesar Chavez St, Austin, TX 78701, United States', 'cuisine', 'new-american'),
  ('Cosmo', '8 Magdalen Street, Oxford, OX1 3AD, England', 'format', 'sit-down-restaurant'),
  ('Cosmo', '8 Magdalen Street, Oxford, OX1 3AD, England', 'logistics', 'open-monday'),
  ('Craft Omakase', '4400 N Lamar Blvd, Unit 102, Austin, TX 78756, United States', 'cuisine', 'sushi'),
  ('Creekhouse', '14015 Ranch Rd 12, Wimberley, TX 78676, United States', 'cuisine', 'new-american'),
  ('District Kitchen + Cocktails', '7858 Shoal Creek Blvd, Unit B, Austin, TX 78757, United States', 'cuisine', 'new-american'),
  ('District Kitchen+Cocktails', '5900 W Slaughter Ln, Unit D500, Austin, TX 78749, United States', 'cuisine', 'new-american'),
  ('Dos Olivos Market', '306 S Main St, Unit 104, Buda, TX 78610, United States', 'cuisine', 'spanish'),
  ('El Chile Café Y Cantina', '1900 Manor Rd, Austin, TX 78722, United States', 'cuisine', 'tex-mex'),
  ('El Raval', '1500 S Lamar Blvd, Unit 150, Austin, TX 78704, United States', 'cuisine', 'spanish'),
  ('Ember Kitchen', '800 W Cesar Chavez St, Unit PP110, Austin, TX 78701, United States', 'format', 'sit-down-restaurant'),
  ('Ember Kitchen', '800 W Cesar Chavez St, Unit PP110, Austin, TX 78701, United States', 'logistics', 'open-monday'),
  ('Este', '2113 Manor Rd, Austin, TX 78722, United States', 'cuisine', 'seafood'),
  ('Ezov', '2708 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'middle-eastern'),
  ('Fabrik', '1701 E Martin Luther King Jr Blvd, Ste 102, Austin, TX 78702, United States', 'cuisine', 'vegetarian-forward'),
  ('Fabrik', '1701 E Martin Luther King Jr Blvd, Ste 102, Austin, TX 78702, United States', 'dietary', 'genuinely-good-for-vegetarians'),
  ('Fabrik', '1701 E Martin Luther King Jr Blvd, Ste 102, Austin, TX 78702, United States', 'dietary', 'vegan-options'),
  ('Fabrik', '1701 E Martin Luther King Jr Blvd, Ste 102, Austin, TX 78702, United States', 'dietary', 'vegetarian-options'),
  ('Fabrik', '1701 E Martin Luther King Jr Blvd, Ste 102, Austin, TX 78702, United States', 'format', 'fine-dining'),
  ('Fabrik', '1701 E Martin Luther King Jr Blvd, Ste 102, Austin, TX 78702, United States', 'logistics', 'reservations-essential'),
  ('Fair Lane Cocktails & Coffee', '29035 Ranch Road 12, Dripping Springs, TX 78620, United States', 'cuisine', 'coffee'),
  ('Finley''s', '410 W Main St, Round Rock, TX 78664, United States', 'cuisine', 'american'),
  ('Flo''s Wine Bar & Bottle Shop', '3111 W 35th St, Austin, TX 78703, United States', 'cuisine', 'wine-bar'),
  ('Foreign & Domestic', '306 E 53rd St, Austin, TX 78751, United States', 'cuisine', 'new-american'),
  ('Friedhelm''s Bavarian Inn', '905 W Main St, Fredericksburg, TX 78624, United States', 'cuisine', 'german'),
  ('Fukumoto', '514 Medina St, Austin, TX 78702, United States', 'cuisine', 'japanese'),
  ('Fukumoto', '514 Medina St, Austin, TX 78702, United States', 'cuisine', 'sushi'),
  ('Garrison', '101 Red River St, Austin, TX 78701, United States', 'cuisine', 'new-american'),
  ('Garrison', '101 Red River St, Austin, TX 78701, United States', 'cuisine', 'steakhouse'),
  ('Gràcia Mediterranean', '4800 Burnet Rd, Ste 450, Austin, TX 78756, United States', 'cuisine', 'mediterranean'),
  ('Hattie B''s Hot Chicken', '2529 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'southern-comfort'),
  ('Haywire', '11501 Rock Rose Ave, Unit 100, Austin, TX 78758, United States', 'format', 'sit-down-restaurant'),
  ('Haywire', '11501 Rock Rose Ave, Unit 100, Austin, TX 78758, United States', 'logistics', 'open-monday'),
  ('Hopfields', '3110 Guadalupe St, Unit 400, Austin, TX 78705, United States', 'cuisine', 'french'),
  ('Huisache Grill', '303 W San Antonio St, New Braunfels, TX 78130, United States', 'cuisine', 'new-american'),
  ('Intero', '2612 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'italian'),
  ('Jack Allen''s Kitchen', '1345 E Whitestone Blvd, Cedar Park, TX 78613, United States', 'cuisine', 'southern-comfort'),
  ('Jack Allen''s Kitchen', '7720 Highway 71 West, Austin, TX 78735, United States', 'cuisine', 'southern-comfort'),
  ('Jacoby''s Restaurant & Mercantile', '3235 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'southern-comfort'),
  ('Jeffrey''s', '1204 West Lynn St, Austin, TX 78703, United States', 'cuisine', 'french'),
  ('Jeffrey''s', '1204 West Lynn St, Austin, TX 78703, United States', 'cuisine', 'steakhouse'),
  ('Justine''s', '4710 E Fifth St, Austin, TX 78702, United States', 'cuisine', 'french'),
  ('Knotty Deck and Bar', '9721 Arboretum Blvd, Austin, TX 78759, United States', 'cuisine', 'new-american'),
  ('Krause''s Cafe', '148 S Castell Ave, New Braunfels, TX 78130, United States', 'cuisine', 'german'),
  ('Lenoir', '1807 S 1st St, Austin, TX 78704, United States', 'cuisine', 'new-american'),
  ('Lin Asian Bar + Dim Sum Restaurant', '1203 W 6th St, Austin, TX 78703, United States', 'cuisine', 'chinese'),
  ('Ling Kitchen', '8423 Research Blvd, Austin, TX 78758, United States', 'cuisine', 'chinese'),
  ('Ling Wu Asian Restaurant at Lantana Place', '7415 Southwest Pkwy Bldg 3-400, Austin, TX 78735, United States', 'cuisine', 'chinese'),
  ('Ling Wu Asian Restaurant at The Grove', '2625 Perseverance Dr, Austin, TX 78731, United States', 'cuisine', 'chinese'),
  ('Loro', '2115 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'bbq'),
  ('Lou''s', '1900 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'american'),
  ('Love Supreme', '2805 Manor Rd, Austin, TX 78722, United States', 'cuisine', 'pizza'),
  ('Lucky Robot', '1303 S Congress Ave, Austin, TX 78704, United States', 'cuisine', 'japanese'),
  ('Lucky Robot', '1303 S Congress Ave, Austin, TX 78704, United States', 'cuisine', 'sushi'),
  ('Ma’CoCo', '302 S Main St, Ste 101, Buda, TX 78610, United States', 'cuisine', 'mexican'),
  ('Manny''s', '301 W 5th St, Austin, TX 78701, United States', 'cuisine', 'caribbean'),
  ('Manuels', '10201 Jollyville Rd, Austin, TX 78759, United States', 'cuisine', 'interior-mexican'),
  ('Mattie''s', '901 W Live Oak St, Austin, TX 78704, United States', 'cuisine', 'new-american'),
  ('Meat & Bread', '360 Nueces St, Unit 20, Austin, TX 78701, United States', 'cuisine', 'sandwiches'),
  ('Millie’s On Main', '212 N Main St, Elgin, TX 78621, United States', 'cuisine', 'american'),
  ('Mozart''s Coffee Roasters', '3825 Lake Austin Blvd, Austin, TX 78703, United States', 'cuisine', 'coffee'),
  ('Muck & Fuss', '295 E San Antonio St, Unit 101, New Braunfels, TX 78130, United States', 'cuisine', 'burgers'),
  ('Murray''s Tavern', '2316 Webberville Rd, Austin, TX 78702, United States', 'cuisine', 'cocktails-bar-food'),
  ('New Braunfels Tortilleria', '1681 Spur St, New Braunfels, TX 78130, United States', 'cuisine', 'tacos'),
  ('Nido', '1211 W Riverside Dr, Austin, TX 78704, United States', 'format', 'sit-down-restaurant'),
  ('Nido', '1211 W Riverside Dr, Austin, TX 78704, United States', 'logistics', 'open-for-breakfast'),
  ('Nido', '1211 W Riverside Dr, Austin, TX 78704, United States', 'logistics', 'open-monday'),
  ('Nightcap', '1401 W 6th St, Austin, TX 78703, United States', 'cuisine', 'new-american'),
  ('No 28', '1006 Main St, Bastrop, TX 78602, United States', 'cuisine', 'italian'),
  ('No 28', '1006 Main St, Bastrop, TX 78602, United States', 'cuisine', 'pizza'),
  ('Nomade', '1506 S 1st St, Austin, TX 78704, United States', 'dietary', 'gluten-free-options'),
  ('Nomade', '1506 S 1st St, Austin, TX 78704, United States', 'format', 'sit-down-restaurant'),
  ('North Street', '216 North St, San Marcos, TX 78666, United States', 'cuisine', 'indian'),
  ('Numero28', '452 W 2nd St, Austin, TX 78701, United States', 'cuisine', 'italian'),
  ('Numero28', '452 W 2nd St, Austin, TX 78701, United States', 'cuisine', 'pizza'),
  ('Oasthouse Kitchen + Bar', 'Bldg D 5701 W Slaughter Ln, Austin, TX 78749, United States', 'cuisine', 'modern-european'),
  ('Odd Duck', '1201 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'new-american'),
  ('Oh K-Dog', '6929 Airport Blvd, Unit 133, Austin, TX 78752, United States', 'cuisine', 'korean'),
  ('Old Gregg Brewing Company', '1900 E Howard Ln, Building H, Pflugerville, TX 78660, United States', 'cuisine', 'brewery'),
  ('Opa Coffee & Wine Bar', '2050 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'coffee'),
  ('Oseyo', '1628 E Cesar Chavez St, Austin, TX 78702, United States', 'cuisine', 'korean'),
  ('Patio Dolcetto', '322 Cheatham St, San Marcos, TX 78666, United States', 'cuisine', 'pizza'),
  ('Péché', '208 W 4th St, Austin, TX 78701, United States', 'cuisine', 'cocktails-bar-food'),
  ('Péché', '208 W 4th St, Austin, TX 78701, United States', 'cuisine', 'french'),
  ('Pieous', '166 Hargraves Dr Bldg H, Austin, TX 78737, United States', 'cuisine', 'pizza'),
  ('Plaza Colombian Coffee Bar', '3842 S Congress Ave, Austin, TX 78704, United States', 'cuisine', 'coffee'),
  ('Poeta', '1108 E 6th St, Austin, TX 78702, United States', 'cuisine', 'italian'),
  ('Proud Mary Coffee', '2043 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'coffee'),
  ('Qi Austin', '835 W 6th St, Unit 114, Austin, TX 78703, United States', 'cuisine', 'chinese'),
  ('Ranch 616', '616 Nueces St, Austin, TX 78701, United States', 'format', 'sit-down-restaurant'),
  ('Ranch 616', '616 Nueces St, Austin, TX 78701, United States', 'logistics', 'open-monday'),
  ('Red Ash', '303 Colorado St, Austin, TX 78701, United States', 'cuisine', 'italian'),
  ('Red Horn Coffee House & Brewing Co', '13010 W Parmer Ln, Unit 800, Cedar Park, TX 78613, United States', 'cuisine', 'coffee'),
  ('Restaurant Francois', '401 W 3rd St, Ste 100, Austin, TX 78701, United States', 'cuisine', 'french'),
  ('Root Cellar Cafe', '215 N LBJ Dr, San Marcos, TX 78666, United States', 'cuisine', 'breakfast-diner'),
  ('Rose Gose', '5201 Airport Blvd, Austin, TX 78751, United States', 'cuisine', 'modern-european'),
  ('Rose Gose', '5201 Airport Blvd, Austin, TX 78751, United States', 'format', 'sit-down-restaurant'),
  ('Rose Gose', '5201 Airport Blvd, Austin, TX 78751, United States', 'logistics', 'open-monday'),
  ('Roya', '7858 Shoal Creek Blvd, Ste C, Austin, TX 78757, United States', 'cuisine', 'middle-eastern'),
  ('Roya', '7858 Shoal Creek Blvd, Ste C, Austin, TX 78757, United States', 'format', 'sit-down-restaurant'),
  ('Roya', '7858 Shoal Creek Blvd, Ste C, Austin, TX 78757, United States', 'logistics', 'open-monday'),
  ('Santa Catarina', '2901 Manor Rd, Unit 100, Austin, TX 78722, United States', 'cuisine', 'tex-mex'),
  ('Sazan', '6929 Airport Blvd, Unit 146, Austin, TX 78752, United States', 'cuisine', 'ramen'),
  ('Shore Raw Bar & Grill', '8665 W Highway 71, Unit 100, Austin, TX 78735, United States', 'cuisine', 'seafood'),
  ('Sidecar at Prince Solms Inn', '295 E San Antonio St, New Braunfels, TX 78130, United States', 'cuisine', 'cocktails-bar-food'),
  ('Sip Pho', '512 W 29th St, Austin, TX 78705, United States', 'cuisine', 'vietnamese'),
  ('Sour Duck Market', '1814 E Martin Luther King Jr Blvd, Austin, TX 78702, United States', 'cuisine', 'bakery-pastry'),
  ('Space Cowboy', '1917 E 7th St, Austin, TX 78702, United States', 'format', 'sit-down-restaurant'),
  ('Space Cowboy', '1917 E 7th St, Austin, TX 78702, United States', 'logistics', 'open-monday'),
  ('Spud Ranch', '118 Common St, New Braunfels, TX 78130, United States', 'cuisine', 'southern-comfort'),
  ('Summer on Music Lane', '1101 Music Ln, Austin, TX 78704, United States', 'cuisine', 'new-american'),
  ('Sundancer Grill', '16410 Stewart Rd, Lakeway, TX 78734, United States', 'cuisine', 'american'),
  ('Sway', '3437 Bee Caves Road, West Lake Hills, TX 78746, United States', 'cuisine', 'thai'),
  ('Taverna', '258 W 2nd St, Austin, TX 78701, United States', 'cuisine', 'italian'),
  ('TenTen', '501 W 6th St, Austin, TX 78701, United States', 'cuisine', 'japanese'),
  ('TenTen', '501 W 6th St, Austin, TX 78701, United States', 'cuisine', 'sushi'),
  ('The Brasserie at Hotel 1928', '701 Washington Ave, Waco, TX 76701, United States', 'cuisine', 'french'),
  ('The Carillon', '1900 University Ave, Austin, TX 78705, United States', 'format', 'fine-dining'),
  ('The Carillon', '1900 University Ave, Austin, TX 78705, United States', 'logistics', 'open-for-breakfast'),
  ('The Grove Wine Bar & Kitchen', '6317 RM-2244, Ste 380, Austin, TX 78746, United States', 'cuisine', 'new-american'),
  ('The Grove Wine Bar & Kitchen', '3001 Ranch Road 620 S, Austin, TX 78738, United States', 'cuisine', 'new-american'),
  ('The Guest House', '110 San Antonio St, Unit 140, Austin, TX 78701, United States', 'format', 'sit-down-restaurant'),
  ('The Guest House', '110 San Antonio St, Unit 140, Austin, TX 78701, United States', 'logistics', 'open-monday'),
  ('The Kimberly', '200 W 7th St, Ste 100, Austin, TX 78701, United States', 'cuisine', 'new-american'),
  ('The Kitchen', '400 W 6th St, Unit 125, Austin, TX 78701, United States', 'format', 'sit-down-restaurant'),
  ('Tiki Tatsu-Ya', '1300 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'cocktails-bar-food'),
  ('Toshokan', '807 E 4th St, Austin, TX 78702, United States', 'format', 'fine-dining'),
  ('Toshokan', '807 E 4th St, Austin, TX 78702, United States', 'logistics', 'reservations-essential'),
  ('Toshokan', '807 E 4th St, Austin, TX 78702, United States', 'logistics', 'reservations-weeks-out'),
  ('Tsuke Edomae', '4600 Mueller Blvd, Ste 1035, Austin, TX 78723, United States', 'cuisine', 'sushi'),
  ('Tumble 22', '7211 Burnet Rd, Austin, TX 78757, United States', 'cuisine', 'southern-comfort'),
  ('Uchi', '801 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'japanese'),
  ('Uchi', '801 S Lamar Blvd, Austin, TX 78704, United States', 'cuisine', 'sushi'),
  ('Uchibā Austin', '601 W 2nd St, Austin, TX 78701, United States', 'cuisine', 'cocktails-bar-food'),
  ('Uchibā Austin', '601 W 2nd St, Austin, TX 78701, United States', 'cuisine', 'japanese'),
  ('Uncommon Coffee', '19 Essex Way, Essex Junction, VT 05452, United States', 'cuisine', 'coffee'),
  ('Uroko', '1023 Springdale Rd Bldg 1, Unit 1, Austin, TX 78721, United States', 'cuisine', 'sushi'),
  ('Vaudeville', '230 E Main St, Fredericksburg, TX 78624, United States', 'format', 'sit-down-restaurant'),
  ('Vaudeville', '230 E Main St, Fredericksburg, TX 78624, United States', 'logistics', 'closes-early'),
  ('Vaudeville', '230 E Main St, Fredericksburg, TX 78624, United States', 'logistics', 'open-monday'),
  ('Veracruz Fonda & Bar', '1905 Aldrich St, Unit 125, Austin, TX 78723, United States', 'cuisine', 'tacos'),
  ('Verbena', '612 W 6th St, Austin, TX 78701, United States', 'format', 'sit-down-restaurant'),
  ('Verbena', '612 W 6th St, Austin, TX 78701, United States', 'logistics', 'open-for-breakfast'),
  ('Verbena', '612 W 6th St, Austin, TX 78701, United States', 'logistics', 'open-monday'),
  ('VERDAD True Modern Mexican', '2701 Perseverance Dr, Austin, TX 78731, United States', 'cuisine', 'mexican'),
  ('Vic & Al''s', '2406 Manor Rd, Unit D, Austin, TX 78722, United States', 'cuisine', 'cajun-creole'),
  ('Vinaigrette', '2201 College Ave, Austin, TX 78704, United States', 'cuisine', 'vegetarian-forward'),
  ('Winston’s', '4900 Bee Creek Rd, Spicewood, TX 78669, United States', 'cuisine', 'coffee'),
  ('Winston’s', '4900 Bee Creek Rd, Spicewood, TX 78669, United States', 'cuisine', 'pizza'),
  ('Yamas', '5308 Balcones Dr, Austin, TX 78731, United States', 'cuisine', 'greek');

  CREATE TEMP TABLE _rb_pares ON COMMIT DROP AS
  SELECT pt.place_id, pt.tag_id, pt.source
  FROM _rb_snap s
  JOIN public.places p
    ON p.name = s.nome
   AND regexp_replace(btrim(p.address), '\s+', ' ', 'g') = s.endereco
  JOIN public.tags t
    ON t.facet = s.faceta AND t.slug = s.slug
  JOIN public.place_tags pt
    ON pt.place_id = p.id AND pt.tag_id = t.id;

  SELECT count(*) INTO v_alvo FROM _rb_pares;
  SELECT count(*) INTO v_ja_sugg FROM _rb_pares WHERE source = 'suggested';

  UPDATE public.place_tags pt
  SET source = 'suggested'
  FROM _rb_pares r
  WHERE pt.place_id = r.place_id
    AND pt.tag_id   = r.tag_id
    AND pt.source   = 'curator';
  GET DIAGNOSTICS v_revert = ROW_COUNT;

  RAISE NOTICE 'rollback: % snapshotted pairs found, % reverted to suggested, % were already suggested',
    v_alvo, v_revert, v_ja_sugg;

  IF v_alvo <> 186 THEN
    RAISE NOTICE 'WARNING: expected 186 pairs, resolved %. Some place or tag was renamed or deleted since the snapshot', v_alvo;
  END IF;
END $ROLLBACK$;

COMMIT;
