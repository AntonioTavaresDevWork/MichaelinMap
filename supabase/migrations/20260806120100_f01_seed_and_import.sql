BEGIN;

-- ========================================================================
-- F-01 — Vocabulary seed and place import
--
-- Version: 1.0
-- Requires: 20260806120000_f01_schema_rls_rpc.sql
--
-- Every block is idempotent through a natural key, so re-running this file
-- inserts nothing twice and never touches the judgment layer (BL-05).
--
-- The 511 place rows and the 145 suggested tag assignments are generated from
-- docs/files/2026-08-05-michaelin-map-master-import.csv. Slugs are produced by
-- the same slugify() that ships in src/lib/utils.ts, so they match the frontend.
-- ========================================================================


-- ------------------------------------------------------------------------
-- BLOCK 01 — Tiers
--
-- Four rows, not five: `fair` is one tier serving two scales, which is what
-- applies_to exists for. Restaurants read destination | experience | fair;
-- bars read cool | fair.
--
-- destination and experience are parallel summits, not first and second place
-- (RN-04). sort_order fixes the display order and asserts nothing else.
-- ------------------------------------------------------------------------

INSERT INTO public.tiers (slug, label, applies_to, sort_order, active) VALUES
  ('destination', 'Destination', ARRAY['restaurant']::text[],        0, true),
  ('experience',  'Experience',  ARRAY['restaurant']::text[],        1, true),
  ('fair',        'Fair',        ARRAY['restaurant','bar']::text[],  2, true),
  ('cool',        'Cool',        ARRAY['bar']::text[],               3, true)
ON CONFLICT (slug) DO NOTHING;


-- ------------------------------------------------------------------------
-- BLOCK 02 — Tags (93 public + 1 admin-only)
-- ------------------------------------------------------------------------

INSERT INTO public.tags (facet, label, slug, is_derived, admin_only, sort_order) VALUES
  ('cuisine', 'BBQ', 'bbq', false, false, 0),
  ('cuisine', 'Tex-Mex', 'tex-mex', false, false, 1),
  ('cuisine', 'Tacos', 'tacos', false, false, 2),
  ('cuisine', 'Interior Mexican', 'interior-mexican', false, false, 3),
  ('cuisine', 'Southern & Comfort', 'southern-comfort', false, false, 4),
  ('cuisine', 'Burgers', 'burgers', false, false, 5),
  ('cuisine', 'Pizza', 'pizza', false, false, 6),
  ('cuisine', 'Italian', 'italian', false, false, 7),
  ('cuisine', 'Steakhouse', 'steakhouse', false, false, 8),
  ('cuisine', 'Seafood', 'seafood', false, false, 9),
  ('cuisine', 'New American', 'new-american', false, false, 10),
  ('cuisine', 'Japanese', 'japanese', false, false, 11),
  ('cuisine', 'Sushi', 'sushi', false, false, 12),
  ('cuisine', 'Ramen', 'ramen', false, false, 13),
  ('cuisine', 'Korean', 'korean', false, false, 14),
  ('cuisine', 'Chinese', 'chinese', false, false, 15),
  ('cuisine', 'Thai', 'thai', false, false, 16),
  ('cuisine', 'Vietnamese', 'vietnamese', false, false, 17),
  ('cuisine', 'Indian', 'indian', false, false, 18),
  ('cuisine', 'Middle Eastern', 'middle-eastern', false, false, 19),
  ('cuisine', 'Mediterranean', 'mediterranean', false, false, 20),
  ('cuisine', 'Ethiopian', 'ethiopian', false, false, 21),
  ('cuisine', 'Caribbean', 'caribbean', false, false, 22),
  ('cuisine', 'Vegetarian-forward', 'vegetarian-forward', false, false, 23),
  ('cuisine', 'Breakfast & Diner', 'breakfast-diner', false, false, 24),
  ('cuisine', 'Bakery & Pastry', 'bakery-pastry', false, false, 25),
  ('cuisine', 'Coffee', 'coffee', false, false, 26),
  ('cuisine', 'Cocktails & Bar Food', 'cocktails-bar-food', false, false, 27),
  ('cuisine', 'British', 'british', false, false, 28),
  ('cuisine', 'French', 'french', false, false, 29),
  ('cuisine', 'Spanish', 'spanish', false, false, 30),
  ('cuisine', 'Portuguese', 'portuguese', false, false, 31),
  ('cuisine', 'Greek', 'greek', false, false, 32),
  ('cuisine', 'Turkish', 'turkish', false, false, 33),
  ('cuisine', 'Brazilian', 'brazilian', false, false, 34),
  ('cuisine', 'Peruvian', 'peruvian', false, false, 35),
  ('cuisine', 'Modern European', 'modern-european', false, false, 36),

  ('format', 'Sit-down restaurant', 'sit-down-restaurant', false, false, 0),
  ('format', 'Food truck', 'food-truck', false, false, 1),
  ('format', 'Counter service', 'counter-service', false, false, 2),
  ('format', 'Bar with real food', 'bar-with-real-food', false, false, 3),
  ('format', 'Café & bakery', 'caf-bakery', false, false, 4),
  ('format', 'Fine dining', 'fine-dining', false, false, 5),
  ('format', 'Trailer park / multi-vendor', 'trailer-park-multi-vendor', false, false, 6),

  ('occasion', 'First date', 'first-date', false, false, 0),
  ('occasion', 'Impress a client', 'impress-a-client', false, false, 1),
  ('occasion', 'Bring your parents', 'bring-your-parents', false, false, 2),
  ('occasion', 'Big group, 8 or more', 'big-group-8-or-more', false, false, 3),
  ('occasion', 'Solo with a book', 'solo-with-a-book', false, false, 4),
  ('occasion', 'Kids in tow', 'kids-in-tow', false, false, 5),
  ('occasion', 'Out-of-towner starter pack', 'out-of-towner-starter-pack', false, false, 6),
  ('occasion', 'Late night', 'late-night', false, false, 7),
  ('occasion', 'Before a show', 'before-a-show', false, false, 8),
  ('occasion', 'Long lunch', 'long-lunch', false, false, 9),
  ('occasion', 'Celebration', 'celebration', false, false, 10),
  ('occasion', 'Cheap and fast', 'cheap-and-fast', false, false, 11),
  ('occasion', 'Night out', 'night-out', false, false, 12),
  ('occasion', 'Vacation', 'vacation', false, false, 13),

  ('vibe', 'Loud', 'loud', false, false, 0),
  ('vibe', 'Quiet enough to talk', 'quiet-enough-to-talk', false, false, 1),
  ('vibe', 'Patio', 'patio', false, false, 2),
  ('vibe', 'Rooftop', 'rooftop', false, false, 3),
  ('vibe', 'Dog-friendly', 'dog-friendly', false, false, 4),
  ('vibe', 'Dark and moody', 'dark-and-moody', false, false, 5),
  ('vibe', 'Bright and airy', 'bright-and-airy', false, false, 6),
  ('vibe', 'Counter seating', 'counter-seating', false, false, 7),
  ('vibe', 'Live music', 'live-music', false, false, 8),
  ('vibe', 'Game on the TV', 'game-on-the-tv', false, false, 9),
  ('vibe', 'Air conditioning that actually works', 'air-conditioning-that-actually-works', false, false, 10),

  -- WHY is_derived on the first four: they were meant to be computed from
  -- opening hours, which left the project with Google Places (ADR-06). They
  -- stay in the vocabulary as curator-assignable, with no automation behind them.
  ('logistics', 'Open late', 'open-late', true, false, 0),
  ('logistics', 'Open Monday', 'open-monday', true, false, 1),
  ('logistics', 'Closes early', 'closes-early', true, false, 2),
  ('logistics', 'Open for breakfast', 'open-for-breakfast', true, false, 3),
  ('logistics', 'Walk-in only', 'walk-in-only', false, false, 4),
  ('logistics', 'Reservations essential', 'reservations-essential', false, false, 5),
  ('logistics', 'Reservations weeks out', 'reservations-weeks-out', false, false, 6),
  ('logistics', 'Cash only', 'cash-only', false, false, 7),
  ('logistics', 'Parking is a problem', 'parking-is-a-problem', false, false, 8),
  ('logistics', 'The line is real', 'the-line-is-real', false, false, 9),
  ('logistics', 'Order at the counter', 'order-at-the-counter', false, false, 10),

  ('dietary', 'Vegetarian options', 'vegetarian-options', false, false, 0),
  ('dietary', 'Vegan options', 'vegan-options', false, false, 1),
  ('dietary', 'Gluten-free options', 'gluten-free-options', false, false, 2),
  ('dietary', 'Genuinely good for vegetarians', 'genuinely-good-for-vegetarians', false, false, 3),

  ('character', 'Hangover triage', 'hangover-triage', false, false, 0),
  ('character', '3am bad decision', '3am-bad-decision', false, false, 1),
  ('character', 'Your vegan friend won''t complain', 'your-vegan-friend-won-t-complain', false, false, 2),
  ('character', 'Tourist bait, but actually good', 'tourist-bait-but-actually-good', false, false, 3),
  ('character', 'Where to break up with someone', 'where-to-break-up-with-someone', false, false, 4),
  ('character', 'Trying to impress, but not that hard', 'trying-to-impress-but-not-that-hard', false, false, 5),
  ('character', 'Worth the charging detour', 'worth-the-charging-detour', false, false, 6),
  ('character', 'Order the weird thing', 'order-the-weird-thing', false, false, 7),
  ('character', 'Somehow always empty and always good', 'somehow-always-empty-and-always-good', false, false, 8),

  -- A negative verdict is what makes the positive one credible. Curation only,
  -- invisible to visitors on every surface (RN-14, BL-08).
  ('character', 'Hype trap', 'hype-trap', false, true, 9)
ON CONFLICT (facet, slug) DO NOTHING;


-- ------------------------------------------------------------------------
-- BLOCK 03 — Field report questions (38)
--
-- No question may ask whether the place was good, or let a rating be derived
-- from the answers. That axis belongs to the curator alone (RN-22).
-- ------------------------------------------------------------------------

INSERT INTO public.questions
  (prompt, input_type, unit_label, options, slider_labels, judgment_prompt, requires_review) VALUES
  ('Temperature of the food on arrival', 'number', '°F', NULL, NULL, NULL, false),
  ('Ambient temperature of the room. Best guess. No phones.', 'number', '°F', NULL, NULL, NULL, false),
  ('Seconds between sitting down and first contact with a human', 'number', 'seconds', NULL, NULL, NULL, false),
  ('Ice cubes in your drink', 'number', 'cubes', NULL, NULL, NULL, false),
  ('Minutes elapsed before you knew what you wanted', 'number', 'minutes', NULL, NULL, NULL, false),
  ('Distance from the establishment to the nearest body of water', 'number', 'feet', NULL, NULL, NULL, false),
  ('Ceiling height, measured in hands', 'number', 'hands', NULL, NULL, NULL, false),
  ('Steps from the front door to your seat', 'number', 'steps', NULL, NULL, NULL, false),
  ('Distance from your table to the nearest other table, in forearms', 'number', 'forearms', NULL, NULL, NULL, false),
  ('Walking minutes from where you parked', 'number', 'minutes', NULL, NULL, NULL, false),
  ('Was the front door heavier than you anticipated?', 'yes_no', NULL, NULL, NULL, NULL, false),
  ('How far was the bathroom?', 'compound', 'steps', NULL, NULL, 'Was it worth it?', false),
  ('Colour of your chair', 'color', NULL, NULL, NULL, 'Is that good or bad?', false),
  ('Dominant wall colour', 'color', NULL, NULL, NULL, NULL, false),
  ('Colour of the napkin', 'color', NULL, NULL, NULL, NULL, false),
  ('Colour of the most prominent sauce', 'color', NULL, NULL, NULL, NULL, false),
  ('Was there a colour present that you would describe as unearned?', 'yes_no', NULL, NULL, NULL, NULL, false),
  ('Patrons observed wearing hats', 'number', 'hats', NULL, NULL, NULL, false),
  ('Dogs visible from your seat', 'number', 'dogs', NULL, NULL, NULL, false),
  ('Televisions', 'number', 'TVs', NULL, NULL, NULL, false),
  ('Plant status', 'single_choice', NULL, '["Alive","Plastic","Both","None detected"]'::jsonb, NULL, NULL, false),
  ('Tables you assessed to be on a first date', 'number', 'tables', NULL, NULL, NULL, false),
  ('Ceiling fans', 'compound', 'fans', NULL, NULL, 'Were they operating in the correct direction?', false),
  ('Napkins used', 'compound', 'napkins', NULL, NULL, 'Was this the correct number?', false),
  ('Chair comfort', 'slider', NULL, NULL, '["Actively hostile","I fell asleep"]'::jsonb, NULL, false),
  ('Lighting', 'slider', NULL, NULL, '["Surgical","Could not read the menu"]'::jsonb, NULL, false),
  ('Commitment to the theme', 'slider', NULL, NULL, '["No theme detected","Total, unbroken"]'::jsonb, NULL, false),
  ('The bread situation', 'slider', NULL, NULL, '["No bread","Bread overwhelmed the meal"]'::jsonb, NULL, false),
  ('Volume', 'slider', NULL, NULL, '["Library","Had to point at the menu"]'::jsonb, NULL, false),
  ('Did anyone sing Happy Birthday?', 'yes_no', NULL, NULL, NULL, NULL, false),
  ('Did water arrive without you asking?', 'yes_no', NULL, NULL, NULL, NULL, false),
  ('Were there crayons?', 'yes_no', NULL, NULL, NULL, NULL, false),
  ('Did you have to ask what something on the menu was?', 'yes_no', NULL, NULL, NULL, NULL, false),
  ('Was there a mirror positioned such that you accidentally watched yourself eat?', 'yes_no', NULL, NULL, NULL, NULL, false),

  -- The four free-text questions. Capped at 40 characters, held as pending,
  -- published only on curator approval (RN-24).
  ('Last song you heard playing', 'text_short', NULL, NULL, NULL, NULL, true),
  ('One object present that should not have been', 'text_short', NULL, NULL, NULL, NULL, true),
  ('What the person nearest you ordered', 'text_short', NULL, NULL, NULL, NULL, true),
  -- The one question whose answers feed back into the curator's own judgment.
  ('The dish you would order again', 'text_short', NULL, NULL, NULL, NULL, true)
ON CONFLICT (prompt) DO NOTHING;


-- ------------------------------------------------------------------------
-- BLOCK 04 — Example code
--
-- Exists so rpc_redeem_code() can be smoke-tested before F-05 builds the real
-- ones. Safe to delete from the admin.
-- ------------------------------------------------------------------------

INSERT INTO public.codes (code, label, message, theme, active) VALUES
  ('DEMO', 'Example code — delete or edit in admin', 'You found it.',
   '{"primary":"#F5C518","mapStyle":"amber"}'::jsonb, true)
ON CONFLICT (code) DO NOTHING;


-- ------------------------------------------------------------------------
-- BLOCK 05 — Places (511)
--
-- Everything lands as `unreviewed`; nothing is visible to the public until the
-- curator promotes it (RN-07). Validation belongs to promotion, not to insert
-- (RN-08), which is why a row with no city or no type is accepted here.
--
-- Three things the generator did to the source data, all recorded rather than
-- silently fixed:
--   * 28 places carried a tier while marked Not visited. The tier is dropped
--     (RN-01 would reject the row) and the place is stamped
--     CONFLICT:TIER+UNVISITED in source_guides for the curator's review queue.
--   * The city Dallas–Fort Worth arrived with an en-dash; normalised (BL-13).
--   * The CSV's Town column becomes `area` wherever it differs from the city —
--     107 rows. It is the real municipality (Lockhart, Dripping Springs) and is
--     derived geography, not judgment, so importing it is reversible and safe.
--
-- ON CONFLICT DO NOTHING on the apple_id key: re-running never overwrites a
-- curated row.
-- ------------------------------------------------------------------------

INSERT INTO public.places
  (name, slug, place_type, tier, starred, visited,
   country, city, area, lat, lng, address, apple_id, source_guides)
VALUES
  ('1886 Cafe & Bakery', '1886-cafe-bakery', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2680142, -97.7416384, '604 Brazos St, Austin, TX  78701, United States', 'I1A3C4FF3BF3EF473', ARRAY['Breakfast___Brunch']::text[]),
  ('24 Diner', '24-diner', 'restaurant', 'fair', true, true, 'United States', 'Austin', NULL, 30.2720673, -97.754154, '600 N Lamar Blvd, Unit 200, Austin, TX 78703, United States', 'I8F59AE0FB7BEFAF8', ARRAY['Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('400 Rabbits', '400-rabbits', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.1989561, -97.8690489, '5701 W Slaughter Ln, Austin, TX  78749, United States', 'I5D9DAEDB62E9A277', ARRAY['Fun_Locations']::text[]),
  ('54th Street', '54th-street', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'San Marcos', 29.8666358, -97.9408398, '1303 Interstate 35 Frontage Rd, San Marcos, TX 78666, United States', 'IA94CED78BEEED7DC', ARRAY['Fair_Restaurants_']::text[]),
  ('54th Street', '54th-street-2', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.1726599, -97.7833951, '127 E Ralph Ablanedo Dr, Austin, TX  78745, United States', 'IC72CBAE82D1997C', ARRAY['Fair_Restaurants_']::text[]),
  ('85°C Bakery Cafe', '85-c-bakery-cafe', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.4793629, -97.7998696, '11301 Lakeline Blvd, Unit 140, Austin, TX 78717, United States', 'I331A439B6EDFE607', ARRAY['Breakfast___Brunch']::text[]),
  ('85°C Bakery Cafe', '85-c-bakery-cafe-2', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.3366266, -97.7177048, '6929 Airport Blvd, Unit 197, Austin, TX  78752, United States', 'IC95B85167D3925ED', ARRAY['Dessert']::text[]),
  ('Aba', 'aba', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2532705, -97.7479215, '1011 S Congress Ave Building 2, Ste 180, Austin, TX 78704, United States', 'IFC9173A009E2A2FE', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('Alamo Drafthouse Cinema', 'alamo-drafthouse-cinema', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.255759, -97.763697, '1120 S Lamar Blvd, Austin, TX  78704, United States', 'IEA91D2C56FDB8A5D', ARRAY['Fun_Locations']::text[]),
  ('ALC Steaks', 'alc-steaks', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2775273, -97.7507759, '1205 N Lamar Blvd, Austin, TX 78703, United States', 'I76F168F64358705D', ARRAY['Designation']::text[]),
  ('Allday', 'allday', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.3069985, -97.7299351, '4300 Speedway, Unit 103, Austin, TX  78751, United States', 'IE4F14F25885511E7', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Alpine Haus Restaurant', 'alpine-haus-restaurant', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7019441, -98.1223861, '251 S Seguin Ave, New Braunfels, TX  78130, United States', 'I7AEB47704CE3E8D9', ARRAY['Fair_Restaurants_']::text[]),
  ('An Nyeong K Tofu & Bbq', 'an-nyeong-k-tofu-bbq', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.3216449, -97.7390042, '5011 Burnet Rd, Austin, TX  78756, United States', 'IA6E1401A448A8031', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Andice General Store', 'andice-general-store', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Florence', 30.7825906, -97.8526521, '6500 FM-970, Florence, TX  76527, United States', 'IA5D6192034F1D967', ARRAY['Fair_Restaurants_']::text[]),
  ('Angel’s Icehouse', 'angel-s-icehouse', 'bar', 'fair', false, true, 'United States', 'Austin', 'Spicewood', 30.3643145, -98.0708463, '21815 State Highway 71, Spicewood, TX 78669, United States', 'ID09849EB19D8F88F', ARRAY['Fair_Bars']::text[]),
  ('Animal World & Snake Farm Zoo', 'animal-world-snake-farm-zoo', 'outdoors', NULL, false, true, 'United States', 'Austin', 'New Braunfels', 29.6558918, -98.1870192, '5640 S Interstate 35, New Braunfels, TX 78132, United States', 'I2B62800CBFCDEBFD', ARRAY['Fun_Locations']::text[]),
  ('Ani’s Day & Night', 'ani-s-day-night', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.221016, -97.695625, '7107 E Riverside Dr, Austin, TX  78741, United States', 'I509CA94CFB020120', ARRAY['Breakfast___Brunch']::text[]),
  ('Another Broken Egg Cafe', 'another-broken-egg-cafe', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.3263421, -97.7077901, '6406 N IH-35 Service Rd, Ste 1600, Austin, TX  78752, United States', 'I79BB549D818FD1E', ARRAY['Breakfast___Brunch']::text[]),
  ('Anthem', 'anthem', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2606754, -97.7379348, '91 Rainey St, Unit 120, Austin, TX 78701, United States', 'I568A6FC5FE2DE4C3', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('APT 115', 'apt-115', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2617627, -97.7195725, '2025 E 7th St, Unit 115, Austin, TX  78702, United States', 'I65FB0B48036C6BC6', ARRAY['Experience_Spots']::text[]),
  ('Aris', 'aris', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2721376, -97.756176, '1111 W 6th St, Austin, TX  78703, United States', 'I4383150CCF7D2C8E', ARRAY['Experience_Spots']::text[]),
  ('Arlo Grey', 'arlo-grey', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2628112, -97.74392, '111 E Cesar Chavez St, Austin, TX  78701, United States', 'I384615E3EFF490AC', ARRAY['Designation']::text[]),
  ('Asado''s Taqueria', 'asado-s-taqueria', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.3437643, -97.7388543, '6726 Burnet Rd, Austin, TX  78757, United States', 'IAC75ADE08897F23D', ARRAY['Food_Trucks']::text[]),
  ('Austhentico', 'austhentico', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2657208, -97.7440041, '308 Congress Ave, Austin, TX  78701, United States', 'I5885474B6E6BB97B', ARRAY['Food_Trucks']::text[]),
  ('Austin Beerworks', 'austin-beerworks', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.3794652, -97.7298549, '3001 Industrial Terrace, Austin, TX 78758, United States', 'I2770C81A64573C36', ARRAY['Fair_Bars']::text[]),
  ('Austin Galleries', 'austin-galleries', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.3432168, -97.7798544, '5804 Lookout Mountain Dr, Austin, TX  78731, United States', 'I3FB0B56C9F304CF2', ARRAY['Fun_Locations']::text[]),
  ('Austin Nature & Science Center', 'austin-nature-science-center', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2720968, -97.7749792, '2389 Stratford Dr, Austin, TX 78746, United States', 'I7C4C9C5A9BA5927', ARRAY['Fun_Locations']::text[]),
  ('Austin Paintball', 'austin-paintball', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Dripping Springs', 30.1962811, -98.0149126, '4150 East Hwy 290, Dripping Springs, TX 78620, United States', 'I94EFEAE178D7CDCC', ARRAY['Fun_Locations']::text[]),
  ('Austin Proper Hotel', 'austin-proper-hotel', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.266141, -97.750097, '600 W 2nd St, Austin, TX 78701, United States', 'I71E128F0495790FA', ARRAY['Cool_Bars']::text[]),
  ('Austin Rowing Club', 'austin-rowing-club', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2605592, -97.7418315, '74 Trinity St, Austin, TX  78701, United States', 'IDAF45E2B4E769625', ARRAY['Fun_Locations']::text[]),
  ('Azul Rooftop', 'azul-rooftop', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.26662, -97.740375, '310 E Fifth St, Austin, TX  78701, United States', 'I575C8F9BE6D61D30', ARRAY['Rooftop']::text[]),
  ('Baguette et Chocolat', 'baguette-et-chocolat', 'restaurant', NULL, false, true, 'United States', 'Austin', 'Bee Cave', 30.3071516, -97.927258, '12101 FM 2244, Unit 6, Bee Cave, TX 78738, United States', 'I3881FF4BBF8A36D3', ARRAY['Breakfast___Brunch']::text[]),
  ('Balcones Canyonlands', 'balcones-canyonlands', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Marble Falls', 30.5746765, -98.026886, '24518 FM 1431, Marble Falls, TX 78654, United States', 'I87B9CC34148E5B6C', ARRAY['Fun_Locations']::text[]),
  ('Banger’s', 'banger-s', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2589538, -97.7385428, '79 Rainey St, Austin, TX  78701, United States', 'I14238ADEF0C70BBB', ARRAY['Fair_Bars']::text[]),
  ('Bar Peached', 'bar-peached', 'bar', NULL, false, false, 'United States', 'Austin', NULL, 30.2735413, -97.7600116, '1315 W 6th St, Austin, TX  78703, United States', 'I434219F15520571C', ARRAY['Fair_Bars','Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Bar Toti', 'bar-toti', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.283915, -97.719536, '2113 Manor Rd, Austin, TX  78722, United States', 'I62DBEBFD8F40EAFD', ARRAY['Fair_Restaurants_']::text[]),
  ('Bartlett''s', 'bartlett-s', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3567308, -97.7312154, '2408 W Anderson Ln, Austin, TX 78757, United States', 'I852FC1C6B5B33CBA', ARRAY['Fair_Restaurants_']::text[]),
  ('Barton Springs Pool', 'barton-springs-pool', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2637516, -97.7706707, '2131 William Barton Dr, Austin, TX 78746, United States', 'I8281EDAE093A6E36', ARRAY['Fun_Locations']::text[]),
  ('Batch - Craft Beer and Kolaches', 'batch-craft-beer-and-kolaches', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2872027, -97.7031648, '3220 Manor Rd, Austin, TX  78723, United States', 'IFE8D1A09E9C369F0', ARRAY['Fair_Restaurants_']::text[]),
  ('Beerburg Brewing', 'beerburg-brewing', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2343597, -98.0037941, '13476 Fitzhugh Rd, Austin, TX  78736, United States', 'IAEE6338306653E31', ARRAY['Fair_Bars']::text[]),
  ('Bellissima', 'bellissima', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.4200642, -97.8467757, '8300 N FM 620, Bldg K Unit 200, Austin, TX  78726, United States', 'IDFA963CCAD4DBDB2', ARRAY['Fair_Restaurants_']::text[]),
  ('Biscuits + Groovy', 'biscuits-groovy', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2610087, -97.75756, '1210 Barton Springs Rd, Austin, TX  78704, United States', 'ICF22F7E881222786', ARRAY['Food_Trucks']::text[]),
  ('Bitelo Brazilian SteakHouse', 'bitelo-brazilian-steakhouse', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Cedar Park', 30.4816147, -97.8293718, '1850 S Lakeline Blvd, Ste 200, Cedar Park, TX  78613, United States', 'ICA390F504AE1FE00', ARRAY['Fair_Restaurants_']::text[]),
  ('BLK Vinyl', 'blk-vinyl', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2585952, -97.714088, '2505 E 6th St, Unit F, Austin, TX 78702, United States', 'I9A30D20694FE9EC5', ARRAY['Fun_Locations']::text[]),
  ('Blue Dahlia Bistro', 'blue-dahlia-bistro', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'San Marcos', 29.8833051, -97.9411117, '107 E Hopkins St, San Marcos, TX  78666, United States', 'I5F6B778CC08D1B5C', ARRAY['Fair_Restaurants_']::text[]),
  ('Blue Room', 'blue-room', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2654625, -97.7466998, '200 Lavaca St, Austin, TX  78701, United States', 'I468ABDAD0100B340', ARRAY['Cool_Bars']::text[]),
  ('BOA Steakhouse', 'boa-steakhouse', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2690982, -97.7455407, '300 W 6th St, Austin, TX  78701, United States', 'IAEE4D8762EB01CA3', ARRAY['Designation']::text[]),
  ('Bob Wentz Park', 'bob-wentz-park', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.4144042, -97.899462, '7144 Comanche Trail, Austin, TX 78732, United States', 'I62ECDD985C4BCECF', ARRAY['Fun_Locations']::text[]),
  ('Bread Boat', 'bread-boat', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2625836, -97.7207957, '1912 E 7th St, Austin, TX 78702, United States', 'IE0B97989EF07B5C4', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Briscuits', 'briscuits', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.231485, -97.7877013, '4204 Menchaca Rd, Austin, TX  78704, United States', 'IF6FEB28458CEC445', ARRAY['Food_Trucks']::text[]),
  ('Bufalina', 'bufalina', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2551598, -97.7196887, '2215 E Cesar Chavez St, Austin, TX 78702, United States', 'IB35782D0DCE47EBE', ARRAY['Fair_Restaurants_']::text[]),
  ('Bufalina Due', 'bufalina-due', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3410745, -97.738401, '6555 Burnet Rd, Austin, TX  78757, United States', 'I4AF587865E898F1F', ARRAY['Fair_Restaurants_']::text[]),
  ('BussinBuns', 'bussinbuns', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2815356, -97.7028652, '1805 Airport Blvd, Austin, TX  78702, United States', 'I1A282776B8EC39BA', ARRAY['Food_Trucks']::text[]),
  ('Butler Metro Park', 'butler-metro-park', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2618843, -97.7543197, '1000 Barton Springs Rd, Austin, TX  78704, United States', 'IF0AE3A68EE1F7E69', ARRAY['Fun_Locations']::text[]),
  ('Cabana Club', 'cabana-club', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2543385, -97.6977753, '5012 E 7th St, Austin, TX  78702, United States', 'I96E405EDBF3E0F20', ARRAY['Breakfast___Brunch']::text[]),
  ('Café Blue', 'caf-blue', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Bee Cave', 30.3094516, -97.9399666, '12800 Hill Country Blvd, Unit G-115, Bee Cave, TX 78738, United States', 'I86B492B720B540F1', ARRAY['Fair_Restaurants_']::text[]),
  ('Canje', 'canje', 'restaurant', 'destination', true, true, 'United States', 'Austin', NULL, 30.2616137, -97.7215407, '1914 E 6th St, Unit C, Austin, TX  78702, United States', 'ID5CAE77B056BE09E', ARRAY['Designation','Michael_s_Top_Faves']::text[]),
  ('Captain Pete''s Boathouse', 'captain-pete-s-boathouse', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Point Venture', 30.3791187, -97.9937505, '18200 Lakepoint Cove, Point Venture, TX 78645, United States', 'IBDA3392077C588EA', ARRAY['Fair_Restaurants_']::text[]),
  ('Caroline', 'caroline', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2687702, -97.7423695, '109 E 7th St, Austin, TX  78701, United States', 'I6E7D0476970FCE4B', ARRAY['Rooftop']::text[]),
  ('Carpenters Hall', 'carpenters-hall', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2620719, -97.7588339, '400 Josephine St, Austin, TX  78704, United States', 'I1197382032621322', ARRAY['Breakfast___Brunch']::text[]),
  ('Casa Bianca', 'casa-bianca', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.258774, -97.7288302, '1510 E Cesar Chavez St, Austin, TX  78702, United States', 'I2B852504B5AA719', ARRAY['Fair_Restaurants_']::text[]),
  ('Casa De Luz', 'casa-de-luz', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2644, -97.761597, '1701 Toomey Rd, Austin, TX  78704, United States', 'I7B46C93EEA7CED14', ARRAY['Fair_Restaurants_']::text[]),
  ('Chapulín Cantina', 'chapul-n-cantina', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2472811, -97.7508485, '1610 S Congress Ave, Austin, TX  78704, United States', 'I5B087EDC731C5089', ARRAY['Fair_Restaurants_']::text[]),
  ('Chess Club', 'chess-club', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2672557, -97.736757, '617 Red River St, Austin, TX  78701, United States', 'IE9B6540417B3910', ARRAY['Fair_Bars']::text[]),
  ('Chez Zee American Bistro', 'chez-zee-american-bistro', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3367335, -97.7579221, '5406 Balcones Dr, Austin, TX  78731, United States', 'IEBD2FA8F8870A154', ARRAY['Fair_Restaurants_']::text[]),
  ('Cidercade', 'cidercade', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2524767, -97.7410127, '600 E Riverside Dr, Austin, TX 78704, United States', 'IFE4A91327CB1B55D', ARRAY['Fun_Locations']::text[]),
  ('Cipollina', 'cipollina', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2805364, -97.7585115, '1213 West Lynn, Austin, TX 78703, United States', 'IAC2005A56A5867F5', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('CJ’s Tacos', 'cj-s-tacos', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2080599, -97.7212377, '5804 Burleson Rd, Austin, TX 78744, United States', 'ICB4837FEC5A675BC', ARRAY['Food_Trucks']::text[]),
  ('Clay Pit', 'clay-pit', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2789456, -97.7424463, '1601 Guadalupe St, Austin, TX  78701, United States', 'I3AD96F11B582A2B4', ARRAY['Designation']::text[]),
  ('Codependent', 'codependent', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2674305, -97.7507224, '301 West Ave, Ste 110, Austin, TX  78701, United States', 'IBAEB0E5A8CD437B6', ARRAY['Cool_Bars']::text[]),
  ('Cody''s Restaurant Bar & Patio', 'cody-s-restaurant-bar-patio', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'San Marcos', 29.828241, -97.987457, '690 Centerpoint Rd, Unit 209, San Marcos, TX 78666, United States', 'ID275DEF7BD24E53A', ARRAY['Fair_Restaurants_']::text[]),
  ('Colleen''s Kitchen', 'colleen-s-kitchen', 'restaurant', 'fair', true, true, 'United States', 'Austin', NULL, 30.2983298, -97.704638, '1911 Aldrich St, Unit 100, Austin, TX 78723, United States', 'IB038C71B9C8B026D', ARRAY['Breakfast___Brunch','Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('Comadre Panaderia', 'comadre-panaderia', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2752571, -97.7133934, '1204 Cedar Ave, Austin, TX  78702, United States', 'I53682185C8509FEC', ARRAY['Breakfast___Brunch']::text[]),
  ('Comedor', 'comedor', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2676899, -97.7441436, '501 Colorado St, Austin, TX  78701, United States', 'I6EFBC8C3A6E5A6D7', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('Commodore Perry Estate, Auberge Collection', 'commodore-perry-estate-auberge-collection', 'hotel', NULL, false, true, 'United States', 'Austin', NULL, 30.3006842, -97.722201, '4100 Red River St, Austin, TX 78751, United States', 'I2576DC2D52EA5400', ARRAY['Hotels']::text[]),
  ('Commons Ford Ranch Metropolitan Park', 'commons-ford-ranch-metropolitan-park', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.3393685, -97.8928614, '614 N Commons Ford Rd, Austin, TX 78733, United States', 'ICA4B5A790BCE58D0', ARRAY['Fun_Locations']::text[]),
  ('Corinne Austin', 'corinne-austin', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2627011, -97.7415763, '304 E Cesar Chavez St, Austin, TX  78701, United States', 'IAFA7681800010C79', ARRAY['Fair_Restaurants_']::text[]),
  ('Cosmic', 'cosmic', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2267999, -97.7625379, '121 Pickle Rd, Ste 111, Austin, TX 78704, United States', 'IE02F63E157324283', ARRAY['Breakfast___Brunch']::text[]),
  ('Cosmic Saltillo', 'cosmic-saltillo', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2623281, -97.7301707, '1300 E 4th St, Austin, TX  78702, United States', 'IC1DBA5D57997A385', ARRAY['Fair_Bars']::text[]),
  ('Cousin Louie''s Italian American', 'cousin-louie-s-italian-american', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2052555, -97.9771103, '165 Hargraves Dr, Ste T100, Austin, TX  78737, United States', 'I91CC79E73AF120EE', ARRAY['Fair_Restaurants_']::text[]),
  ('Cowboys & Cadillacs', 'cowboys-cadillacs', 'bar', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7020905, -98.1259501, '125 N Castell Ave, New Braunfels, TX  78130, United States', 'I8F3E9FC7321A9112', ARRAY['Fair_Bars']::text[]),
  ('Craft Omakase', 'craft-omakase', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.3126655, -97.7386115, '4400 N Lamar Blvd, Unit 102, Austin, TX  78756, United States', 'I37CC5572B6372D26', ARRAY['Experience_Spots','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Creekhouse', 'creekhouse', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Wimberley', 29.9960361, -98.0975729, '14015 Ranch Rd 12, Wimberley, TX 78676, United States', 'I63A101E0BCC3E28C', ARRAY['Fair_Restaurants_']::text[]),
  ('Crêpe Crazy', 'cr-pe-crazy', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2416163, -97.7847409, '3103 S Lamar Blvd, Austin, TX 78704, United States', 'IB580267F3CC1BE63', ARRAY['Breakfast___Brunch']::text[]),
  ('Cuantos Tacos', 'cuantos-tacos', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2728001, -97.7282386, '1108 E 12th St, Austin, TX  78702, United States', 'ICF8C3BA499032B0F', ARRAY['Food_Trucks']::text[]),
  ('Dai Due', 'dai-due', 'grocery', 'destination', false, true, 'United States', 'Austin', NULL, 30.2848806, -97.7168107, '2406 Manor Rd, Austin, TX  78722, United States', 'I2D6AF7D758FAA45D', ARRAY['Designation','Grocery']::text[]),
  ('Daisy Lounge', 'daisy-lounge', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2000625, -97.8680016, '5701 W Slaughter Ln, Ste D, Austin, TX  78749, United States', 'I5BF441DF6606444A', ARRAY['Cool_Bars']::text[]),
  ('David Doughie’s Bagelry', 'david-doughie-s-bagelry', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2627485, -97.7143523, '2427 Webberville Rd, Austin, TX  78702, United States', 'IB18EF45EB2487A6F', ARRAY['Breakfast___Brunch']::text[]),
  ('Day Maker Half Day Cafe', 'day-maker-half-day-cafe', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2651533, -97.7814975, '1101 S Mopac Frontage Rd, Austin, TX  78746, United States', 'I8B4C4B22867541B7', ARRAY['Breakfast___Brunch']::text[]),
  ('daydreamer', 'daydreamer', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2622805, -97.7235523, '1708 E 6th St, Austin, TX  78702, United States', 'IEABD3B82C264926D', ARRAY['Cool_Bars']::text[]),
  ('Days pizza', 'days-pizza', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.1847592, -97.7924625, '7800 South 1st St, Austin, TX  78745, United States', 'I5047BBD1A963A285', ARRAY['Food_Trucks']::text[]),
  ('Dean''s Italian Steakhouse', 'dean-s-italian-steakhouse', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2640915, -97.7430616, '110 E 2nd St, Austin, TX  78701, United States', 'IEA7CCD812AE21B63', ARRAY['Designation']::text[]),
  ('DeSano Pizzeria Napoletana', 'desano-pizzeria-napoletana', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2662671, -97.7459196, '301 Lavaca St, Unit 200, Austin, TX 78701, United States', 'I8A67604555A72099', ARRAY['Fair_Restaurants_']::text[]),
  ('Devil May Care', 'devil-may-care', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.269625, -97.747498, '500 W 6th St, Austin, TX  78701, United States', 'I7B55BE39F55453A7', ARRAY['Fair_Bars']::text[]),
  ('Dia''s Market', 'dia-s-market', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.3373853, -97.7204237, '812 Justin Ln, Austin, TX  78757, United States', 'IA8CD62BD201A9131', ARRAY['Grocery']::text[]),
  ('Discada', 'discada', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2579562, -97.7263109, '1700 E Cesar Chavez St, Austin, TX  78702, United States', 'IDED3E9709DF0737E', ARRAY['Food_Trucks']::text[]),
  ('Distant Relatives', 'distant-relatives', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2087618, -97.7294719, '3901 Promontory Point Dr, Austin, TX  78744, United States', 'I97A0725018E4A240', ARRAY['Food_Trucks']::text[]),
  ('District Kitchen + Cocktails', 'district-kitchen-cocktails', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3606931, -97.741558, '7858 Shoal Creek Blvd, Unit B, Austin, TX  78757, United States', 'I8D1815AE37AE0DF6', ARRAY['Fair_Restaurants_']::text[]),
  ('District Kitchen+Cocktails', 'district-kitchen-cocktails-2', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2015057, -97.8796476, '5900 W Slaughter Ln, Unit D500, Austin, TX  78749, United States', 'I503C1967C50A7851', ARRAY['Fair_Restaurants_']::text[]),
  ('DK Sushi South & Seoul Korean Restaurant', 'dk-sushi-south-seoul-korean-restaurant', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2002633, -97.7862304, '6400 S 1st St, Ste C, Austin, TX  78745, United States', 'IB51D1632193F000F', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Dos Olivos Market', 'dos-olivos-market', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2053137, -97.9816298, '12680 W US Highway 290, Austin, TX  78737, United States', 'I9EBF4ADC98E195CD', ARRAY['Fair_Restaurants_']::text[]),
  ('Dos Olivos Market', 'dos-olivos-market-2', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Buda', 30.0775708, -97.8454131, '306 S Main St, Unit 104, Buda, TX 78610, United States', 'I25EEFE59D206E2CF', ARRAY['Fair_Restaurants_']::text[]),
  ('Dovetail Pizza', 'dovetail-pizza', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2468132, -97.7563679, '1816 S 1st St, Austin, TX  78704, United States', 'I3C1402B9E50B99A9', ARRAY['Fair_Restaurants_']::text[]),
  ('DrinkWell', 'drinkwell', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.317223, -97.720627, '207 E 53rd St, Austin, TX  78751, United States', 'I52B7B52D34DAC1F1', ARRAY['Fair_Bars']::text[]),
  ('Dumont''s Down Low', 'dumont-s-down-low', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2668959, -97.7454244, '214 W 4th St, Ste B, Austin, TX  78701, United States', 'ID5C09500B399F31D', ARRAY['Cool_Bars']::text[]),
  ('Easy Tiger', 'easy-tiger', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.240091, -97.7884269, '3508 S Lamar Blvd, Unit 300, Austin, TX  78704, United States', 'ICDE71AE587CBC56', ARRAY['Breakfast___Brunch']::text[]),
  ('Easy Tiger', 'easy-tiger-2', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.3273042, -97.7072295, '6406 N Interstate 35 Frontage Rd, Unit 1100, Austin, TX 78752, United States', 'I6DF2460ECABACB7A', ARRAY['Fair_Bars']::text[]),
  ('Eden Cocktail Room', 'eden-cocktail-room', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2676411, -97.7408268, '214 E 6th St, Austin, TX  78701, United States', 'IE0A7CD0B063FC1D7', ARRAY['Cool_Bars']::text[]),
  ('Edge Rooftop', 'edge-rooftop', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2645462, -97.7434251, '110 E 2nd St, Austin, TX  78701, United States', 'IF67B5636A7A8A2D6', ARRAY['Fair_Bars','Fair_Restaurants_','Rooftop']::text[]),
  ('El Alma', 'el-alma', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2601184, -97.7556586, '1025 Barton Springs Rd, Austin, TX  78704, United States', 'I728D7134A7827FDA', ARRAY['Breakfast___Brunch','Fair_Restaurants_']::text[]),
  ('El Chile Café Y Cantina', 'el-chile-caf-y-cantina', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2840204, -97.7217332, '1900 Manor Rd, Austin, TX  78722, United States', 'IB8B7B6AC438747EB', ARRAY['Fair_Restaurants_']::text[]),
  ('El Cockfight', 'el-cockfight', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2665686, -97.7421749, '121 E 5th St, Austin, TX  78701, United States', 'I52298D9104A676C7', ARRAY['Rooftop']::text[]),
  ('El Gaucho Winery', 'el-gaucho-winery', 'winery', NULL, false, true, 'United States', 'Austin', 'Spicewood', 30.3776864, -98.0501921, '21301 Kathy Ln, Spicewood, TX  78669, United States', 'IE43BF3A2E97E17E1', ARRAY['Wineries']::text[]),
  ('El Naranjo', 'el-naranjo', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2441829, -97.7809589, '2717 S Lamar Blvd, Unit 1085, Austin, TX 78704, United States', 'I667963F1B76E5591', ARRAY['Fair_Restaurants_']::text[]),
  ('El Raval', 'el-raval', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2523399, -97.7644891, '1500 S Lamar Blvd, Unit 150, Austin, TX 78704, United States', 'I72712544858EBD0D', ARRAY['Designation']::text[]),
  ('Elephant Room', 'elephant-room', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.265632, -97.7433748, '315 Congress Ave, Austin, TX  78701, United States', 'I1AFFCF685D3C99AE', ARRAY['Fun_Locations']::text[]),
  ('Ember Kitchen', 'ember-kitchen', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2668848, -97.752783, '800 W Cesar Chavez St, Unit PP110, Austin, TX 78701, United States', 'ICA3734CA9AC4D1A6', ARRAY['Designation']::text[]),
  ('Emerald Tavern Games and Cafe', 'emerald-tavern-games-and-cafe', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.3714821, -97.724542, '9012 Research Blvd, Unit C1, Austin, TX 78758, United States', 'I707DE7AF826A7A3', ARRAY['Fun_Locations']::text[]),
  ('Emmer & Rye', 'emmer-rye', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2574169, -97.7390618, '51 Rainey St, Unit 110, Austin, TX 78701, United States', 'I797F9CA6BF115F4C', ARRAY['Designation']::text[]),
  ('Equipment Room', 'equipment-room', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.252706, -97.7477229, '1101 Music Ln, Austin, TX  78704, United States', 'IE49027D2751385CA', ARRAY['Cool_Bars']::text[]),
  ('Este', 'este', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2839984, -97.7195545, '2113 Manor Rd, Austin, TX  78722, United States', 'I13DFEB1C6CDE3396', ARRAY['Fair_Restaurants_']::text[]),
  ('Ezov', 'ezov', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2534496, -97.7135143, '2708 E Cesar Chavez St, Austin, TX  78702, United States', 'I32D29F09541EACA3', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('Fabrik', 'fabrik', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.279275, -97.7229734, '1701 E Martin Luther King Jr Blvd, Ste 102, Austin, TX 78702, United States', 'IF933ED8DB4852985', ARRAY['Designation']::text[]),
  ('Fair Lane Cocktails & Coffee', 'fair-lane-cocktails-coffee', 'restaurant', NULL, false, true, 'United States', 'Austin', 'Dripping Springs', 30.2099656, -98.0885389, '29035 Ranch Road 12, Dripping Springs, TX  78620, United States', 'IB6AF77827DA61823', ARRAY['Breakfast___Brunch']::text[]),
  ('Favorite Pizza', 'favorite-pizza', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2702038, -97.7508121, '801 W 6th St, Austin, TX  78703, United States', 'IC508B15FF4FBF9C', ARRAY['Fair_Restaurants_']::text[]),
  ('Feral Pizza', 'feral-pizza', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3140474, -97.7190572, '500 E 51st St, Austin, TX  78751, United States', 'IFCE56BF44B5C0CEF', ARRAY['Fair_Restaurants_']::text[]),
  ('Finley''s', 'finley-s', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Round Rock', 30.5076732, -97.6829054, '410 W Main St, Round Rock, TX  78664, United States', 'I4E6996B3EAC21C9A', ARRAY['Fair_Restaurants_']::text[]),
  ('Firehouse Lounge', 'firehouse-lounge', 'bar', NULL, false, false, 'United States', 'Austin', NULL, 30.2681766, -97.7410475, '605 Brazos St, Austin, TX  78701, United States', 'I20BB96BC9CF277C3', ARRAY['Cool_Bars','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('First Light Books', 'first-light-books', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.3069791, -97.729769, '4300 Speedway, Austin, TX  78751, United States', 'IBC01B77B2643B5FA', ARRAY['Fun_Locations']::text[]),
  ('First Watch', 'first-watch', 'restaurant', NULL, false, true, 'United States', 'Austin', 'Cedar Park', 30.525176, -97.813857, '1320 E Whitestone Blvd, Ste 600, Cedar Park, TX  78613, United States', 'I3D65732C69869FAF', ARRAY['Breakfast___Brunch']::text[]),
  ('Fixe Southern House', 'fixe-southern-house', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2688316, -97.7481585, '500 W 5th St, Austin, TX 78701, United States', 'I70B5BC510B84898B', ARRAY['Designation']::text[]),
  ('Flo''s Wine Bar & Bottle Shop', 'flo-s-wine-bar-bottle-shop', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.3132509, -97.7668815, '3111 W 35th St, Austin, TX  78703, United States', 'IB0A1596FF90DB9E8', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Folklore Spa', 'folklore-spa', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Dripping Springs', 30.1814967, -98.1470262, '3509 Creek Rd, Dripping Springs, TX  78620, United States', 'I39FFA66282E673E', ARRAY['Fun_Locations','Hotels']::text[]),
  ('Fonda San Miguel', 'fonda-san-miguel', 'unclassified', NULL, false, false, 'United States', 'Austin', NULL, 30.3254954, -97.7434811, '2330 W North Loop Blvd, Austin, TX  78756, United States', 'I56DDA3514FC2F444', ARRAY['Try_List']::text[]),
  ('Foreign & Domestic', 'foreign-domestic', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3170812, -97.7196156, '306 E 53rd St, Austin, TX  78751, United States', 'IA826743FF9A35DF5', ARRAY['Fair_Restaurants_']::text[]),
  ('Form + Function Massage', 'form-function-massage', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2654714, -97.7331476, '900 E 6th St, Unit 103, Austin, TX 78702, United States', 'I2A21240E4FD052C0', ARRAY['Fun_Locations']::text[]),
  ('Franklin Barbecue', 'franklin-barbecue', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2700843, -97.7312786, '900 E 11th St, Austin, TX 78702, United States', 'IAA409CDF9D3555A9', ARRAY['Designation']::text[]),
  ('Freda''s Seafood Grille', 'freda-s-seafood-grille', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.463987, -97.803847, '10903 Pecan Park Blvd, Austin, TX  78750, United States', 'I6BAD4F2AA7417390', ARRAY['Fair_Restaurants_']::text[]),
  ('Freddo ATX', 'freddo-atx', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2391733, -97.7535465, '2336 S Congress Ave, Austin, TX  78704, United States', 'IDE9FE47B94EAC15E', ARRAY['Fair_Bars']::text[]),
  ('Friedhelm''s Bavarian Inn', 'friedhelm-s-bavarian-inn', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Fredericksburg', 30.2849561, -98.8868988, '905 W Main St, Fredericksburg, TX  78624, United States', 'IF763FDCDB7E2A00', ARRAY['Fair_Restaurants_']::text[]),
  ('Frontyard Brewing', 'frontyard-brewing', 'bar', 'fair', false, true, 'United States', 'Austin', 'Spicewood', 30.3581871, -98.0560622, '4514 Bob Wire Rd, Spicewood, TX  78669, United States', 'IAD551F7F4DDA51E9', ARRAY['Fair_Bars']::text[]),
  ('Fukumoto', 'fukumoto', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2647597, -97.7319568, '514 Medina St, Austin, TX  78702, United States', 'ID8A444C55D6B7659', ARRAY['Fair_Restaurants_']::text[]),
  ('Garage', 'garage', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2678726, -97.7441783, '503 Colorado St, Austin, TX  78701, United States', 'IA8EAD4BDE0425EC', ARRAY['Fair_Bars']::text[]),
  ('Garrison', 'garrison', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2619965, -97.7380364, '101 Red River St, Austin, TX  78701, United States', 'I5AF3D328595B78E0', ARRAY['Experience_Spots','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Gelato Paradiso', 'gelato-paradiso', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.2496885, -97.7501357, '1400 S Congress Ave, Suite B160, Austin, TX 78704, United States', 'I594952DD0155BE5E', ARRAY['Dessert']::text[]),
  ('Geraldine''s', 'geraldine-s', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2600314, -97.7392416, '605 Davis St, Austin, TX  78701, United States', 'I34A688EB96B3F4BF', ARRAY['Breakfast___Brunch','Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('Gil''s Broiler & The Manske Roll Bakery', 'gil-s-broiler-the-manske-roll-bakery', 'dessert', NULL, false, true, 'United States', 'Austin', 'San Marcos', 29.8850089, -97.9402587, '328 N LBJ Dr, San Marcos, TX 78666, United States', 'IC1BC5C372D19DFF8', ARRAY['Dessert']::text[]),
  ('Gina''s on Congress', 'gina-s-on-congress', 'restaurant', 'fair', true, true, 'United States', 'Austin', NULL, 30.2658621, -97.7439022, '314 Congress Ave, Austin, TX  78701, United States', 'IC551BACADCF551FA', ARRAY['Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('Grata’s Pizzeria', 'grata-s-pizzeria', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2453705, -97.7804454, '2700 S Lamar Blvd, Austin, TX  78704, United States', 'I4A74800A1DAA8060', ARRAY['Fair_Restaurants_']::text[]),
  ('Green Gate Farms', 'green-gate-farms', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.2859667, -97.6347323, '8310 Canoga Ave, Austin, TX  78724, United States', 'I6855400C968AA52F', ARRAY['Grocery']::text[]),
  ('Grizzelda''s', 'grizzelda-s', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2521352, -97.7082883, '105 Tillery St, Austin, TX  78702, United States', 'IE0886F4BA92D7788', ARRAY['Fair_Restaurants_']::text[]),
  ('Group Therapy', 'group-therapy', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2671872, -97.7464516, '400 Lavaca St, Austin, TX 78701, United States', 'IB6C33456E95FC033', ARRAY['Breakfast___Brunch']::text[]),
  ('Gràcia Mediterranean', 'gr-cia-mediterranean', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.319075, -97.739501, '4800 Burnet Rd, Ste 450, Austin, TX  78756, United States', 'IB1493E28346897BB', ARRAY['Fair_Restaurants_']::text[]),
  ('Guadalupe Brewing Company & Pizza Kitchen', 'guadalupe-brewing-company-pizza-kitchen', 'bar', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.6845536, -98.1636866, '1586 Wald Rd, New Braunfels, TX 78132, United States', 'IC068DE7FDC60CB41', ARRAY['Fair_Bars']::text[]),
  ('Gusto Italian Kitchen', 'gusto-italian-kitchen', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.318356, -97.740044, '4800 Burnet Rd, Austin, TX  78756, United States', 'I6FE21DB68E5715A2', ARRAY['Fair_Restaurants_']::text[]),
  ('Hattie B''s Hot Chicken', 'hattie-b-s-hot-chicken', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2457705, -97.7782563, '2529 S Lamar Blvd, Austin, TX  78704, United States', 'I2785FAEFC37F30EC', ARRAY['Fair_Restaurants_']::text[]),
  ('Haywire', 'haywire', 'restaurant', 'destination', true, true, 'United States', 'Austin', NULL, 30.4004691, -97.7227718, '11501 Rock Rose Ave, Unit 100, Austin, TX  78758, United States', 'IDE74E6260E0C1152', ARRAY['Designation','Michael_s_Top_Faves']::text[]),
  ('Here Nor There', 'here-nor-there', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2683524, -97.7413943, '612 Brazos St, Austin, TX  78701, United States', 'I831B26DC83A9FACB', ARRAY['Cool_Bars']::text[]),
  ('Hestia', 'hestia', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2667207, -97.7499696, '607 W 3rd St, Unit 105, Austin, TX  78701, United States', 'I1D115A5889AC3794', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('Heydey Social Club', 'heydey-social-club', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2697391, -97.7419381, '721 Congress Ave, Austin, TX  78701, United States', 'IB6ACE3C309107BC0', ARRAY['Rooftop']::text[]),
  ('Hillside Farmacy', 'hillside-farmacy', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2682378, -97.7268818, '1209 E 11th St, Austin, TX  78702, United States', 'I96048C4AF9EDDE9A', ARRAY['Breakfast___Brunch']::text[]),
  ('Holiday', 'holiday', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2536988, -97.6975879, '5020 E 7th St, Austin, TX  78702, United States', 'I6FDB2FA41B58B18A', ARRAY['Cool_Bars']::text[]),
  ('Holla Mode', 'holla-mode', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.2640397, -97.763712, '1800 Barton Springs Rd, Austin, TX  78704, United States', 'IDB6B82BAA82CFAA9', ARRAY['Dessert']::text[]),
  ('Hopfields', 'hopfields', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2985615, -97.7409416, '3110 Guadalupe St, Unit 400, Austin, TX 78705, United States', 'I7939278E1DE13CD6', ARRAY['Fair_Restaurants_']::text[]),
  ('Hotel Saint Cecilia', 'hotel-saint-cecilia', 'hotel', NULL, false, true, 'United States', 'Austin', NULL, 30.2520782, -97.7472702, '112 Academy Dr, Austin, TX  78704, United States', 'IA940825AF50DD077', ARRAY['Hotels']::text[]),
  ('Hotel Vegas', 'hotel-vegas', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2633821, -97.7272791, '1502 E 6th St, Austin, TX  78702, United States', 'IBE3F42D63CF6F6D9', ARRAY['Night_Out']::text[]),
  ('Houndstooth', 'houndstooth', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2814318, -97.7096218, '2823 E Martin Luther King Jr Blvd, Unit 101, Austin, TX 78702, United States', 'IC781428B11E37399', ARRAY['Breakfast___Brunch']::text[]),
  ('Huisache Grill', 'huisache-grill', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.700242, -98.1260277, '303 W San Antonio St, New Braunfels, TX  78130, United States', 'I56C235536F4EB791', ARRAY['Fair_Restaurants_']::text[]),
  ('Il Brutto', 'il-brutto', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2628502, -97.7263546, '1601 E 6th St, Austin, TX  78702, United States', 'I2B7AC9E87D165182', ARRAY['Designation']::text[]),
  ('Inferno''s Pizza', 'inferno-s-pizza', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7355869, -98.1026317, '1198 Gruene Rd, New Braunfels, TX  78130, United States', 'I8A107845D357F0E6', ARRAY['Fair_Restaurants_']::text[]),
  ('Inks Lake State Park', 'inks-lake-state-park', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Burnet', 30.7404295, -98.3654237, '3630 Park Road 4 West, Burnet, TX 78611, United States', 'I30B1A80246DD0A89', ARRAY['Fun_Locations']::text[]),
  ('Intero', 'intero', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2537153, -97.7143818, '2612 E Cesar Chavez St, Austin, TX  78702, United States', 'IF92BF6232B095C9F', ARRAY['Fair_Restaurants_']::text[]),
  ('InterStellar BBQ', 'interstellar-bbq', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.4614615, -97.8151779, '12233 Ranch Rd 620 N, Ste 105, Austin, TX 78750, United States', 'I7948F5B22027B0B4', ARRAY['Fair_Restaurants_']::text[]),
  ('Jack Allen''s Kitchen', 'jack-allen-s-kitchen', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Cedar Park', 30.5267284, -97.8133982, '1345 E Whitestone Blvd, Cedar Park, TX  78613, United States', 'I6E89C4A552AE90A7', ARRAY['Fair_Restaurants_']::text[]),
  ('Jack Allen''s Kitchen', 'jack-allen-s-kitchen-2', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.243576, -97.8826261, '7720 Highway 71 West, Austin, TX 78735, United States', 'IB0977F7B0DC42D26', ARRAY['Fair_Restaurants_']::text[]),
  ('Jacoby''s Restaurant & Mercantile', 'jacoby-s-restaurant-mercantile', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2515058, -97.7073496, '3235 E Cesar Chavez St, Austin, TX  78702, United States', 'I80B5FCE8737238DA', ARRAY['Fair_Restaurants_']::text[]),
  ('JD''s Supermarket', 'jd-s-supermarket', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.2904822, -97.6293756, '6506 Decker Ln, Austin, TX  78724, United States', 'IBCED30BA4314BAA0', ARRAY['Grocery']::text[]),
  ('Jeffrey''s', 'jeffrey-s', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2803712, -97.7591542, '1204 West Lynn St, Austin, TX 78703, United States', 'I51CEAC4609E9645B', ARRAY['Experience_Spots']::text[]),
  ('Jester King', 'jester-king', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.230642, -97.999222, '13187 Fitzhugh Rd, Austin, TX  78736, United States', 'IBDF0770A3AD6771C', ARRAY['Fair_Bars']::text[]),
  ('June''s All Day', 'june-s-all-day', 'restaurant', 'fair', true, true, 'United States', 'Austin', NULL, 30.24625, -97.7511388, '1722 S Congress Ave, Austin, TX  78704, United States', 'IE2BFCE17517A5D0A', ARRAY['Breakfast___Brunch','Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('Juniper', 'juniper', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2546977, -97.7172357, '2400 E Cesar Chavez St, Unit 304, Austin, TX  78702, United States', 'IF8F69B938B9D21F8', ARRAY['Designation']::text[]),
  ('Jupiter Supper Club', 'jupiter-supper-club', 'unclassified', NULL, false, false, 'United States', 'Austin', NULL, 30.2697086, -97.7425653, '718 Congress Ave, Austin, TX  78701, United States', 'I2A49B8B6BD69EE37', ARRAY['Try_List']::text[]),
  ('Justine''s', 'justine-s', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2531615, -97.7005909, '4710 E Fifth St, Austin, TX  78702, United States', 'IBE2106DF260EF789', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('K BBQ', 'k-bbq', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3364355, -97.717241, '6929 Airport Blvd, Unit 176, Austin, TX 78752, United States', 'I187569F541884230', ARRAY['Fair_Restaurants_']::text[]),
  ('Kelly''s Irish', 'kelly-s-irish', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2413608, -97.7589548, '519 W Oltorf St, Austin, TX  78704, United States', 'IAA57C93AE4B8EEE4', ARRAY['Fair_Bars','Fair_Restaurants_']::text[]),
  ('Kemuri Tatsu-Ya', 'kemuri-tatsu-ya', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.253855, -97.712921, '2713 E 2nd St, Austin, TX 78702, United States', 'I8EA20959C5AFF780', ARRAY['Designation']::text[]),
  ('KG BBQ', 'kg-bbq', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2867658, -97.7051587, '3108 Manor Rd, Austin, TX 78723, United States', 'IBA8B54753821C69B', ARRAY['Food_Trucks']::text[]),
  ('Kinfolk Lounge & Library', 'kinfolk-lounge-library', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2638668, -97.7379646, '303 Red River St, Austin, TX  78701, United States', 'IC5C270EE83E63BCB', ARRAY['Cool_Bars']::text[]),
  ('Kitty Cohen''s', 'kitty-cohen-s', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2617949, -97.7164382, '2211 Webberville Rd, Austin, TX  78702, United States', 'ID0DAFAC82194F68F', ARRAY['Fair_Bars']::text[]),
  ('Knotty Deck and Bar', 'knotty-deck-and-bar', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.3917979, -97.750302, '9721 Arboretum Blvd, Austin, TX  78759, United States', 'I98283C6990DE0CE8', ARRAY['Designation','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Krause Springs', 'krause-springs', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Spicewood', 30.4792142, -98.1444901, '424 County Road 404, Spicewood, TX 78669, United States', 'IDEEE65B3886B0B89', ARRAY['Fun_Locations']::text[]),
  ('Krause''s Cafe', 'krause-s-cafe', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7013569, -98.1249918, '148 S Castell Ave, New Braunfels, TX  78130, United States', 'I78968798E0FC520', ARRAY['Fair_Restaurants_']::text[]),
  ('la Barbecue', 'la-barbecue', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2544845, -97.7176005, '2401 E Cesar Chavez, Austin, TX 78702, United States', 'ID27477247784E9FB', ARRAY['Designation']::text[]),
  ('La Santa Barbacha', 'la-santa-barbacha', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2857204, -97.7115119, '2806 Manor Rd, Austin, TX  78722, United States', 'I7AADD9D9ECD67225', ARRAY['Food_Trucks']::text[]),
  ('La Volta Pizza Club', 'la-volta-pizza-club', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.274933, -97.7517232, '900 W 10th St, Austin, TX  78703, United States', 'I95C63F3EC4E16CA3', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('La Wagyeria', 'la-wagyeria', 'unclassified', NULL, false, false, 'United States', 'Austin', NULL, 30.2164242, -97.7618657, '440D E St Elmo Rd, Bldg D, Austin, TX  78745, United States', 'ICD1DAFD3C0DF6B1D', ARRAY['Try_List']::text[]),
  ('Laika', 'laika', 'dessert', NULL, false, true, 'United States', 'Austin', 'New Braunfels', 29.6885875, -98.1199548, '1430 Unicorn Ave, Unit 105, New Braunfels, TX  78130, United States', 'I2D3B2160B1D238E0', ARRAY['Dessert']::text[]),
  ('Lake Austin Spa Resort', 'lake-austin-spa-resort', 'hotel', NULL, false, true, 'United States', 'Austin', NULL, 30.3270826, -97.9257023, '1705 S Quinlan Park Rd, Austin, TX  78732, United States', 'I71296831605EF988', ARRAY['Hotels']::text[]),
  ('Lakeway Resort And Spa', 'lakeway-resort-and-spa', 'hotel', NULL, false, true, 'United States', 'Austin', 'Lakeway', 30.3746858, -97.9867369, '101 Lakeway Dr, Lakeway, TX 78734, United States', 'I46D3039364B902D1', ARRAY['Hotels']::text[]),
  ('Lala’s', 'lala-s', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.1910742, -97.8320664, '3008 Davis Ln, Austin, TX  78745, United States', 'I9F7D17BF77EC8A7C', ARRAY['Fair_Bars']::text[]),
  ('Lamberts', 'lamberts', 'restaurant', 'fair', true, true, 'United States', 'Austin', NULL, 30.2652304, -97.7478781, '401 W 2nd St, Austin, TX 78701, United States', 'I652813FBA871BFF6', ARRAY['Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('Las Perlas', 'las-perlas', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2677457, -97.7386819, '405 E 7th St, Austin, TX  78701, United States', 'I39DD8EC7C7FDB5DE', ARRAY['Fair_Bars']::text[]),
  ('Latchkey', 'latchkey', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2639277, -97.7286994, '1308 E 6th St, Austin, TX  78702, United States', 'IFEE4AFCD402FBA5F', ARRAY['Night_Out']::text[]),
  ('Launderette', 'launderette', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2518757, -97.7227664, '2115 Holly St, Austin, TX  78702, United States', 'I51B463BA69F4601A', ARRAY['Designation']::text[]),
  ('Laurel Restaurant', 'laurel-restaurant', 'restaurant', NULL, true, true, 'United States', 'Austin', 'West Lake Hills', 30.3008876, -97.8293279, '320 S Capital of Texas Hwy Bldg B, West Lake Hills, TX  78746, United States', 'I2C14D9F398CD939A', ARRAY['Breakfast___Brunch','Michael_s_Top_Faves']::text[]),
  ('Lenoir', 'lenoir', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2468501, -97.7558863, '1807 S 1st St, Austin, TX  78704, United States', 'IF4BFD4B65E7A8B20', ARRAY['Designation','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Leona Botanical Cafe & Bar', 'leona-botanical-cafe-bar', 'restaurant', NULL, false, true, 'United States', 'Austin', 'Sunset Valley', 30.2177583, -97.8261449, '6405 Brodie Ln, Sunset Valley, TX  78745, United States', 'IF505AABA9302C949', ARRAY['Breakfast___Brunch']::text[]),
  ('Lick Honest Ice Creams', 'lick-honest-ice-creams', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.2555022, -97.7625551, '1100 S Lamar Blvd, Austin, TX 78704, United States', 'I66D37E754CC0DF82', ARRAY['Dessert']::text[]),
  ('Limestone Rooftop', 'limestone-rooftop', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2583305, -97.7381301, '68 East Ave, Austin, TX  78701, United States', 'I32D05470DCD3F15', ARRAY['Rooftop']::text[]),
  ('Lin Asian Bar + Dim Sum Restaurant', 'lin-asian-bar-dim-sum-restaurant', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2729064, -97.7579807, '1203 W 6th St, Austin, TX  78703, United States', 'I912B679ED066F6B9', ARRAY['Fair_Restaurants_']::text[]),
  ('Ling Kitchen', 'ling-kitchen', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.3593411, -97.7159092, '8423 Research Blvd, Austin, TX  78758, United States', 'IB218669445110A1F', ARRAY['Experience_Spots']::text[]),
  ('Ling Wu Asian Restaurant at Lantana Place', 'ling-wu-asian-restaurant-at-lantana-place', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2560309, -97.8690077, '7415 Southwest Pkwy Bldg 3-400, Austin, TX  78735, United States', 'I274CF8074F4A85CA', ARRAY['Fair_Restaurants_']::text[]),
  ('Ling Wu Asian Restaurant at The Grove', 'ling-wu-asian-restaurant-at-the-grove', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3179107, -97.7532675, '2625 Perseverance Dr, Austin, TX 78731, United States', 'IFA3C85A766C2626F', ARRAY['Fair_Restaurants_']::text[]),
  ('Little Arthur’s', 'little-arthur-s', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2621556, -97.7235962, '1708 E 6th St, Austin, TX  78702, United States', 'I29F705E2055827F2', ARRAY['Food_Trucks']::text[]),
  ('Little Trouble', 'little-trouble', 'bar', 'experience', false, true, 'United States', 'Austin', 'Lockhart', 29.8850121, -97.672306, '101 E San Antonio St, Lockhart, TX  78644, United States', 'I2C77EF1B323CD64B', ARRAY['Cool_Bars','Experience_Spots']::text[]),
  ('Llama Queen', 'llama-queen', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2521398, -97.7029073, '4620 E Cesar Chavez St, Unit 1, Austin, TX  78702, United States', 'IC880C5798C44D211', ARRAY['Fair_Bars']::text[]),
  ('Local Foods', 'local-foods', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2656981, -97.748565, '454 W 2nd St, Austin, TX  78701, United States', 'I7FEF1024773DAAE', ARRAY['Breakfast___Brunch','Fair_Restaurants_']::text[]),
  ('Local Pastures', 'local-pastures', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.3232556, -97.7275466, '5501 N Lamar Blvd, Unit B110, Austin, TX  78751, United States', 'I1816A7EA28BE394E', ARRAY['Grocery']::text[]),
  ('Lonesome Dove', 'lonesome-dove', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2682319, -97.7440202, '123 W 6th St, Austin, TX  78701, United States', 'IE9B21A2C47C93681', ARRAY['Designation']::text[]),
  ('Long Center', 'long-center', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2600971, -97.7512066, '701 W Riverside Dr, Austin, TX 78704, United States', 'I6C3D01A6954135D', ARRAY['Fun_Locations']::text[]),
  ('Longhorn Cavern State Park', 'longhorn-cavern-state-park', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Burnet', 30.6844569, -98.3509145, '6211 Park Road 4 South, Burnet, TX 78611, United States', 'I736B4BC12A50057B', ARRAY['Fun_Locations']::text[]),
  ('Loro', 'loro', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2477734, -97.7714058, '2115 S Lamar Blvd, Austin, TX 78704, United States', 'IF9F6BE65BD22273C', ARRAY['Fair_Restaurants_']::text[]),
  ('Lost And Found Rooftop Bar', 'lost-and-found-rooftop-bar', 'bar', NULL, false, true, 'United States', 'Austin', 'New Braunfels', 29.7042587, -98.1236823, '219 E San Antonio St, New Braunfels, TX  78130, United States', 'IF341B8771637AB69', ARRAY['Rooftop']::text[]),
  ('Lou''s', 'lou-s', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2571981, -97.724416, '1900 E Cesar Chavez St, Austin, TX  78702, United States', 'IE3D6CE94FA5CCB8F', ARRAY['Fair_Restaurants_']::text[]),
  ('Love Supreme', 'love-supreme', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2851599, -97.7116755, '2805 Manor Rd, Austin, TX  78722, United States', 'IB04E9514EA44E67', ARRAY['Fair_Restaurants_']::text[]),
  ('Lucchese', 'lucchese', 'shop', NULL, false, true, 'United States', 'Austin', NULL, 30.2485894, -97.7502749, '1508 S Congress Ave, Austin, TX  78704, United States', 'I3A6184EBC3C27690', ARRAY['Stores']::text[]),
  ('Luck Reunion', 'luck-reunion', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Spicewood', 30.3939849, -98.054894, '1100 Bee Creek Rd, Spicewood, TX 78669, United States', 'I42F7457B7730EA38', ARRAY['Fun_Locations']::text[]),
  ('Lucky Rabbit', 'lucky-rabbit', 'bar', 'fair', false, true, 'United States', 'Austin', 'Jonestown', 30.4944233, -97.9251383, '18626 FM-1431, Jonestown, TX  78645, United States', 'I62A8205E3F4456BB', ARRAY['Fair_Bars']::text[]),
  ('Lucky Robot', 'lucky-robot', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2508562, -97.7490058, '1303 S Congress Ave, Austin, TX  78704, United States', 'I2103870D6C52461E', ARRAY['Fair_Restaurants_']::text[]),
  ('Lulu’s', 'lulu-s', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.166972, -97.8282361, '10402 Menchaca Rd, Bldg C, Austin, TX 78748, United States', 'I75288D0C51ED6434', ARRAY['Fair_Bars']::text[]),
  ('Lustre Pearl South', 'lustre-pearl-south', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.1672384, -97.8275657, '10400 Menchaca Rd, Austin, TX 78748, United States', 'I97CBCC5B75F76B75', ARRAY['Fair_Bars']::text[]),
  ('Lutie''s', 'lutie-s', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.3003897, -97.7222836, '4100 Red River St, Austin, TX 78751, United States', 'I398EE9655F292790', ARRAY['Designation']::text[]),
  ('L’Oca d’Oro', 'l-oca-d-oro', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2971978, -97.7045547, '1900 Simond Ave, Unit 100, Austin, TX 78723, United States', 'I74530EF94C8A1F6F', ARRAY['Designation']::text[]),
  ('Ma''coco', 'ma-coco', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2623096, -97.7266841, '501 Comal St, Austin, TX 78702, United States', 'IBF539BE23404957A', ARRAY['Fair_Restaurants_']::text[]),
  ('Manchaca Sports Bar', 'manchaca-sports-bar', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.166691, -97.827712, '10402 Menchaca Rd 1, Austin, TX  78748, United States', 'IE6F8CFBBC5E477D0', ARRAY['Fair_Bars']::text[]),
  ('Manny''s', 'manny-s', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2676515, -97.7459204, '301 W 5th St, Austin, TX  78701, United States', 'I7975742B7493B27D', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Manuels', 'manuels', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.396698, -97.7493437, '10201 Jollyville Rd, Austin, TX 78759, United States', 'I12E35AD6FA429DDC', ARRAY['Fair_Restaurants_']::text[]),
  ('Marlow', 'marlow', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2662884, -97.7358559, '700 E 6th St, Austin, TX  78701, United States', 'IA78A544C6843D988', ARRAY['Fair_Bars']::text[]),
  ('Mary Moore Searight Metro Park', 'mary-moore-searight-metro-park', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.160269, -97.807533, '907 W Slaughter Ln, Austin, TX  78748, United States', 'I46401CE2C5125622', ARRAY['Fun_Locations']::text[]),
  ('Mattie''s', 'mattie-s', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2449292, -97.7622861, '901 W Live Oak St, Austin, TX  78704, United States', 'I33E9B4BAAB4D9E42', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Maywald Christmas Light Display', 'maywald-christmas-light-display', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2340382, -97.9404008, '10505 Twilight Vista, Austin, TX  78736, United States', 'IB5DE7F1AEEA53C73', ARRAY['Fun_Locations']::text[]),
  ('Ma’CoCo', 'ma-coco-2', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Buda', 30.0782971, -97.845003, '302 S Main St, Ste 101, Buda, TX  78610, United States', 'I47B01E8269F00EB0', ARRAY['Fair_Restaurants_']::text[]),
  ('McAdoo''s Seafood Company', 'mcadoo-s-seafood-company', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7027501, -98.1263745, '196 N Castell Ave, New Braunfels, TX  78130, United States', 'I30CC5293BA5CC9D4', ARRAY['Fair_Restaurants_']::text[]),
  ('McKinney Falls State Park', 'mckinney-falls-state-park', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.1835039, -97.7221761, '5808 McKinney Falls Pkwy, Austin, TX 78744, United States', 'I16A0B0F52E9D2F0D', ARRAY['Fun_Locations']::text[]),
  ('Mean Eyed Cat', 'mean-eyed-cat', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2745031, -97.7649916, '1621 W 5th St, Austin, TX  78703, United States', 'IADA5FD98D0E0A3EB', ARRAY['Fair_Bars']::text[]),
  ('Meat & Bread', 'meat-bread', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2671083, -97.7497816, '360 Nueces St, Unit 20, Austin, TX 78701, United States', 'I4292D99A98C7378A', ARRAY['Fair_Restaurants_']::text[]),
  ('Midnight Cowboy', 'midnight-cowboy', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2670049, -97.740057, '313 E 6th St, Austin, TX  78701, United States', 'I2ADDAAAF4CC0D7E3', ARRAY['Cool_Bars']::text[]),
  ('Milky Way Shakes', 'milky-way-shakes', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2551101, -97.7182335, '2324 E Cesar Chavez, Austin, TX 78702, United States', 'I9E8ADEE986A1EB82', ARRAY['Food_Trucks']::text[]),
  ('Millie’s On Main', 'millie-s-on-main', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Elgin', 30.3498508, -97.3716624, '212 N Main St, Elgin, TX  78621, United States', 'I698173364D51F14F', ARRAY['Fair_Restaurants_']::text[]),
  ('Milonga Room', 'milonga-room', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2641461, -97.7304068, '1201 E 6th St, Austin, TX  78702, United States', 'ID858C8059A999DA5', ARRAY['Cool_Bars']::text[]),
  ('Miracle on 5th Street', 'miracle-on-5th-street', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2676843, -97.7462812, '307 W 5th St, Austin, TX  78701, United States', 'I21954FBF9D9C5F6C', ARRAY['Fair_Bars']::text[]),
  ('Moderna Bar & Pizzeria', 'moderna-bar-pizzeria', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2762554, -97.7658625, '1717 W 6th St 140-R, Austin, TX 78703, United States', 'IFB362860A563C5A1', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Moon Valley Nurseries', 'moon-valley-nurseries', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Dripping Springs', 30.1967275, -98.0283985, '3969 East Highway 290, Dripping Springs, TX  78620, United States', 'I29AB8E249AF1B68C', ARRAY['Fun_Locations']::text[]),
  ('Moonshine Comfort & Cocktails', 'moonshine-comfort-cocktails', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.4970162, -97.7759385, '10525 W Parmer Ln, Austin, TX  78717, United States', 'IAFC990D56424F233', ARRAY['Fair_Bars']::text[]),
  ('More Home Slice Pizza', 'more-home-slice-pizza', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2490212, -97.7495938, '1421 S Congress Ave, Austin, TX  78704, United States', 'I9218FA7A26160671', ARRAY['Fair_Restaurants_']::text[]),
  ('MorninGlory', 'morninglory', 'restaurant', NULL, false, true, 'United States', 'Austin', 'Lakeway', 30.3424309, -97.9707309, '2121 Lohmans Crossing Rd, Lakeway, TX 78734, United States', 'IB005CA12A7457F7F', ARRAY['Breakfast___Brunch']::text[]),
  ('Mort Subite', 'mort-subite', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2657034, -97.7439382, '308 Congress Ave, Austin, TX  78701, United States', 'I64627D6F54CCD955', ARRAY['Fair_Bars']::text[]),
  ('Mount Bonnell', 'mount-bonnell', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.3212161, -97.773359, '3800 Mount Bonnell Rd, Austin, TX  78731, United States', 'I83ADFC4DE5AAF9C1', ARRAY['Fun_Locations']::text[]),
  ('Mozart''s Coffee Roasters', 'mozart-s-coffee-roasters', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2952207, -97.7844143, '3825 Lake Austin Blvd, Austin, TX 78703, United States', 'IB9591BD6B32855CF', ARRAY['Breakfast___Brunch']::text[]),
  ('Muck & Fuss', 'muck-fuss', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7044276, -98.1234922, '295 E San Antonio St, Unit 101, New Braunfels, TX 78130, United States', 'I325D24186EE71B2A', ARRAY['Fair_Restaurants_']::text[]),
  ('Muleshoe Bend Recreation Area', 'muleshoe-bend-recreation-area', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Spicewood', 30.4874153, -98.0988443, '2820 County Road 414, Spicewood, TX 78669, United States', 'ICA43D0E97B7E18DE', ARRAY['Fun_Locations']::text[]),
  ('Murray''s Tavern', 'murray-s-tavern', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2627339, -97.7154215, '2316 Webberville Rd, Austin, TX  78702, United States', 'IB8BF34D4F07BA113', ARRAY['Fair_Restaurants_']::text[]),
  ('MUTTS Canine Cantina', 'mutts-canine-cantina', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.4730791, -97.7934587, '9825 N Lake Creek Pkwy, Austin, TX  78717, United States', 'IBBD0A1363B7EA998', ARRAY['Fun_Locations']::text[]),
  ('Natural Grocers', 'natural-grocers', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.3153699, -97.7348051, '4615 N Lamar Blvd, Ste 304, Austin, TX  78751, United States', 'I9722D78E6873BF36', ARRAY['Grocery']::text[]),
  ('Neighborhood Sushi', 'neighborhood-sushi', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2465372, -97.7510923, '1716 S Congress Ave, Austin, TX  78704, United States', 'I4515EF526B7BB12A', ARRAY['Designation']::text[]),
  ('New Braunfels Tortilleria', 'new-braunfels-tortilleria', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.6888924, -98.138132, '1681 Spur St, New Braunfels, TX  78130, United States', 'IEE5F2695AA18785C', ARRAY['Fair_Restaurants_']::text[]),
  ('Nido', 'nido', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2640584, -97.7567157, '1211 W Riverside Dr, Austin, TX  78704, United States', 'I39D668F609509C6A', ARRAY['Designation']::text[]),
  ('Nightcap', 'nightcap', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.273747, -97.7604569, '1401 W 6th St, Austin, TX  78703, United States', 'I751004A7B8421D27', ARRAY['Experience_Spots']::text[]),
  ('Nixta Taqueria', 'nixta-taqueria', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2749769, -97.7132745, '2512 E 12th St, Austin, TX  78702, United States', 'I876A5C1F0A632EFB', ARRAY['Fair_Restaurants_']::text[]),
  ('No 28', 'no-28', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Bastrop', 30.1107886, -97.3202884, '1006 Main St, Bastrop, TX  78602, United States', 'I79CA15441FF7371B', ARRAY['Fair_Restaurants_']::text[]),
  ('Nom Burgers', 'nom-burgers', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2553348, -97.7183589, '2324 E Cesar Chavez St, Austin, TX  78702, United States', 'I57E2F5DABB9B0F0D', ARRAY['Food_Trucks']::text[]),
  ('Nomade', 'nomade', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2497137, -97.7553107, '1506 S 1st St, Austin, TX  78704, United States', 'I3474B9AA256CF23A', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('North Street', 'north-street', 'restaurant', NULL, false, false, 'United States', 'Austin', 'San Marcos', 29.8831927, -97.945438, '216 North St, San Marcos, TX  78666, United States', 'IFF7AB4D97DE39747', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Numero28', 'numero28', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2656769, -97.7484464, '452 W 2nd St, Austin, TX  78701, United States', 'I515FAB7410BDC239', ARRAY['Fair_Restaurants_']::text[]),
  ('Oak Hill Social', 'oak-hill-social', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2348485, -97.9115808, '8600 Highway 290 W, Austin, TX  78736, United States', 'I6394413406B9447C', ARRAY['Fair_Bars']::text[]),
  ('Oasthouse Kitchen + Bar', 'oasthouse-kitchen-bar', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2000088, -97.8680295, 'Bldg D 5701 W Slaughter Ln, Austin, TX 78749, United States', 'IA44753530EF7AE8B', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Odd Duck', 'odd-duck', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2546699, -97.7620125, '1201 S Lamar Blvd, Austin, TX 78704, United States', 'I4F9E8CBEF61773D2', ARRAY['Experience_Spots']::text[]),
  ('Oh K-Dog', 'oh-k-dog', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.33693, -97.7166694, '6929 Airport Blvd, Unit 133, Austin, TX 78752, United States', 'I6E2B0D2BA863C2E4', ARRAY['Fair_Restaurants_']::text[]),
  ('Olamaie', 'olamaie', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2798863, -97.7436788, '1610 San Antonio St, Austin, TX 78701, United States', 'I8F476358AA39915A', ARRAY['Experience_Spots']::text[]),
  ('Old Gregg Brewing Company', 'old-gregg-brewing-company', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Pflugerville', 30.4020358, -97.6338347, '1900 E Howard Ln, Building H, Pflugerville, TX 78660, United States', 'I37284ACE115D1F73', ARRAY['Fair_Restaurants_']::text[]),
  ('Onera Wimberley', 'onera-wimberley', 'hotel', NULL, false, true, 'United States', 'Austin', 'Wimberley', 30.0031674, -98.0735657, '801 Buttercup Ln, Wimberley, TX  78676, United States', 'I3ADA11009D3E7252', ARRAY['Hotels']::text[]),
  ('Opa Coffee & Wine Bar', 'opa-coffee-wine-bar', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2489656, -97.7695119, '2050 S Lamar Blvd, Austin, TX  78704, United States', 'I585194C094C1F500', ARRAY['Fair_Restaurants_']::text[]),
  ('Originator Studios', 'originator-studios', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2617824, -97.7148753, '718 Northwestern Ave, Austin, TX  78702, United States', 'I2FB8726D097A6C95', ARRAY['Fun_Locations']::text[]),
  ('Oseyo', 'oseyo', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2583159, -97.7276427, '1628 E Cesar Chavez St, Austin, TX  78702, United States', 'I78BBDCEB2037CF0E', ARRAY['Experience_Spots','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Otoko', 'otoko', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2477367, -97.7499728, '1603 S Congress Ave, Austin, TX  78704, United States', 'IED8CC7DB65C2B3DE', ARRAY['Experience_Spots','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Otopia Rooftop Lounge', 'otopia-rooftop-lounge', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2824093, -97.742873, '1901 San Antonio St, Unit 1100, Austin, TX  78705, United States', 'I12D1D9CD037FD323', ARRAY['Rooftop']::text[]),
  ('Ovenbird', 'ovenbird', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.19524, -97.7774, '6501 S Congress Ave, Unit 211, Austin, TX 78745, United States', 'IE0FAD376F87A69B6', ARRAY['Breakfast___Brunch']::text[]),
  ('P6', 'p6', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2627887, -97.7439651, '111 E Cesar Chavez St, Austin, TX  78701, United States', 'IEF56AAA6E8AEAE7F', ARRAY['Rooftop']::text[]),
  ('Palmer Events Center', 'palmer-events-center', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2601709, -97.7533202, '900 Barton Springs Rd, Austin, TX  78704, United States', 'I34A31827DB721CB8', ARRAY['Fun_Locations']::text[]),
  ('Paperboy', 'paperboy', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2534283, -97.7626257, '1401 S Lamar Blvd, Austin, TX  78704, United States', 'ICF8CD83D775D47E6', ARRAY['Breakfast___Brunch']::text[]),
  ('Paperboy', 'paperboy-2', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.268414, -97.727646, '1203 E 11th St, Austin, TX 78702, United States', 'IE73EB264A221E29', ARRAY['Breakfast___Brunch']::text[]),
  ('papercut', 'papercut', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2644632, -97.7333459, '908 E 5th St, Unit 107, Austin, TX  78702, United States', 'IF3D39325D015B86D', ARRAY['Cool_Bars']::text[]),
  ('Paris Baguette', 'paris-baguette', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.3258325, -97.7156465, '110 Jacob Fontaine Ln, Austin, TX  78752, United States', 'I6137F256A981FFA6', ARRAY['Breakfast___Brunch','Dessert']::text[]),
  ('Parish Barbecue', 'parish-barbecue', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.3443359, -97.6468881, '3220 Manor Rd, Austin, TX  78723, United States', 'IEF7C4BCD277A4305', ARRAY['Food_Trucks']::text[]),
  ('Parker Jazz Club', 'parker-jazz-club', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.266337, -97.7446463, '117 W 4th St, Unit 107B, Austin, TX  78701, United States', 'I1025F65DCD63AA78', ARRAY['Fun_Locations']::text[]),
  ('Parlor Bar', 'parlor-bar', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2831474, -97.7455039, '1900 Rio Grande St, Austin, TX  78705, United States', 'IDBA17531D7D00EA2', ARRAY['Cool_Bars']::text[]),
  ('PastaBar', 'pastabar', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2646505, -97.7319288, '1017 E 6th St, Austin, TX  78702, United States', 'IBD5CD2545C8ADC85', ARRAY['Experience_Spots']::text[]),
  ('Patio Dolcetto', 'patio-dolcetto', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'San Marcos', 29.8767924, -97.936812, '322 Cheatham St, San Marcos, TX  78666, United States', 'I6E46C33812203039', ARRAY['Fair_Restaurants_']::text[]),
  ('Patrizi''s', 'patrizi-s', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.283931, -97.7172578, '2307 Manor Rd, Austin, TX 78722, United States', 'I3E8A8203A395EA8C', ARRAY['Food_Trucks']::text[]),
  ('Pavement', 'pavement', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2589375, -97.7585846, '611 S Lamar Blvd, Austin, TX  78704, United States', 'I6446EC6B63CAE132', ARRAY['Fun_Locations']::text[]),
  ('Pease Park', 'pease-park', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2814883, -97.7517636, '1100 Kingsbury St, Austin, TX 78701, United States', 'I15E6E2D4CCC17649', ARRAY['Fun_Locations']::text[]),
  ('Pedernales Farmers Market', 'pedernales-farmers-market', 'grocery', NULL, false, true, 'United States', 'Austin', 'Spicewood', 30.3870828, -98.0856892, '23526 SH-71, Spicewood, TX  78669, United States', 'IA840787697E4E840', ARRAY['Grocery']::text[]),
  ('Pedroso''s Pizza', 'pedroso-s-pizza', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3445612, -97.73622, '2207 Justin Ln, Unit D, Austin, TX  78757, United States', 'ICA041C0DA9EB0825', ARRAY['Fair_Restaurants_']::text[]),
  ('Phoebe''s Diner', 'phoebe-s-diner', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2416484, -97.7593041, '533 W Oltorf St, Austin, TX  78704, United States', 'I587434300820A9E', ARRAY['Breakfast___Brunch']::text[]),
  ('Phoebe''s Diner', 'phoebe-s-diner-2', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2739813, -97.7449778, '408 W 11th St, Austin, TX 78701, United States', 'I5EE5B1558F8B79C4', ARRAY['Fair_Restaurants_']::text[]),
  ('Phoenicia Bakery', 'phoenicia-bakery', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.2434296, -97.7831565, '2912 S Lamar Blvd, Austin, TX  78704, United States', 'I99858ECE6BA6DB76', ARRAY['Grocery']::text[]),
  ('Pickle Pub', 'pickle-pub', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.1648633, -97.8313662, '10630 Menchaca Rd, Bldg B, Austin, TX  78748, United States', 'ID246B6647F5A82AF', ARRAY['Fun_Locations']::text[]),
  ('Pieous', 'pieous', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2050159, -97.9791695, '166 Hargraves Dr Bldg H, Austin, TX 78737, United States', 'I83D18D8364503869', ARRAY['Fair_Restaurants_']::text[]),
  ('Pins Mechanical Co.', 'pins-mechanical-co', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2181213, -97.7645069, '4323 S Congress Ave, Austin, TX  78745, United States', 'I65DF4C80205DC9B6', ARRAY['Fun_Locations']::text[]),
  ('Plaza Colombian Coffee Bar', 'plaza-colombian-coffee-bar', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2246981, -97.7635605, '3842 S Congress Ave, Austin, TX  78704, United States', 'ICA59F545AD28A8E3', ARRAY['Breakfast___Brunch']::text[]),
  ('Pluto''s Wine Bar', 'pluto-s-wine-bar', 'winery', NULL, false, true, 'United States', 'Austin', 'Bastrop', 30.1101503, -97.3202978, '924 Main St, Bastrop, TX 78602, United States', 'IAEF6AA27A302FA1C', ARRAY['Wineries']::text[]),
  ('Poeta', 'poeta', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2646672, -97.7307363, '1108 E 6th St, Austin, TX  78702, United States', 'I1C439D41E4B0599B', ARRAY['Fair_Restaurants_']::text[]),
  ('Pool Bar - East Austin Hotel', 'pool-bar-east-austin-hotel', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2646672, -97.7307363, '1108 E 6th St, Austin, TX  78702, United States', 'I7D8AD6CEFBDCC05C', ARRAY['Rooftop']::text[]),
  ('Pool Burger', 'pool-burger', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.277777, -97.7726698, '2315 Lake Austin Blvd, Austin, TX  78703, United States', 'IBD667047EB3602CC', ARRAY['Fair_Restaurants_']::text[]),
  ('PopStroke', 'popstroke', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.407189, -97.6531686, '13000 Harris Ridge Blvd, Austin, TX  78660, United States', 'I55358D37BDEADCD', ARRAY['Fun_Locations']::text[]),
  ('Posse East', 'posse-east', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2913832, -97.7346995, '2900 Duval St, Austin, TX  78705, United States', 'IF9A4033E5C7D63FE', ARRAY['Fair_Bars']::text[]),
  ('Powder Room', 'powder-room', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2676065, -97.7459204, '301 W 5th St, Austin, TX  78701, United States', 'I96CC5D195AD102D1', ARRAY['Cool_Bars']::text[]),
  ('Proud Mary Coffee', 'proud-mary-coffee', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.248306, -97.769348, '2043 S Lamar Blvd, Austin, TX  78704, United States', 'IDCB9A29307710F6', ARRAY['Breakfast___Brunch']::text[]),
  ('Prélude', 'pr-lude', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2736411, -97.7490619, '707 W 10th St, Austin, TX  78701, United States', 'IDDFA328C3505AD20', ARRAY['Cool_Bars']::text[]),
  ('Pueblo Viejo', 'pueblo-viejo', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2578347, -97.7057719, '641 Tillery St, Austin, TX  78702, United States', 'I8118712B5CAEBAB5', ARRAY['Food_Trucks']::text[]),
  ('Péché', 'p-ch', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2668006, -97.74525, '208 W 4th St, Austin, TX  78701, United States', 'I4D598E8BE0F1DDA9', ARRAY['Experience_Spots']::text[]),
  ('Qi Austin', 'qi-austin', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2705716, -97.7521473, '835 W 6th St, Unit 114, Austin, TX  78703, United States', 'I494A528E6494FAC', ARRAY['Experience_Spots']::text[]),
  ('Quince Lakehouse', 'quince-lakehouse', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2953125, -97.7843333, '3825 Lake Austin Blvd, Unit 201, Austin, TX  78703, United States', 'I2ED1A3F1AA1CCE6D', ARRAY['Breakfast___Brunch','Try_List']::text[]),
  ('Radio/East', 'radio-east', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2079276, -97.7155254, '3504 Montopolis Dr, Austin, TX  78744, United States', 'I161B27341EBE7526', ARRAY['Breakfast___Brunch']::text[]),
  ('Radius Butcher & Grocery', 'radius-butcher-grocery', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.2626591, -97.7209742, '1912 E 7th St, Austin, TX  78702, United States', 'I662BEF4E92F870E7', ARRAY['Grocery']::text[]),
  ('Ranch 616', 'ranch-616', 'restaurant', 'fair', true, true, 'United States', 'Austin', NULL, 30.2704503, -97.748361, '616 Nueces St, Austin, TX  78701, United States', 'I401EFF5C06ABAA61', ARRAY['Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('Rebel Cheese', 'rebel-cheese', 'grocery', 'fair', false, true, 'United States', 'Austin', NULL, 30.3014844, -97.7030919, '2200 Aldrich St, Unit 120, Austin, TX 78723, United States', 'IA21BBF3F6E4ABF5F', ARRAY['Fair_Restaurants_','Grocery']::text[]),
  ('Red Ash', 'red-ash', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2656744, -97.7447391, '303 Colorado St, Austin, TX 78701, United States', 'I894F3A2C7A0B42DF', ARRAY['Experience_Spots']::text[]),
  ('Red Horn Coffee House & Brewing Co', 'red-horn-coffee-house-brewing-co', 'restaurant', NULL, false, true, 'United States', 'Austin', 'Cedar Park', 30.5338073, -97.7808416, '13010 W Parmer Ln, Unit 800, Cedar Park, TX 78613, United States', 'I499797CF0D74DF92', ARRAY['Breakfast___Brunch']::text[]),
  ('REINA', 'reina', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2639694, -97.7407748, '206 Trinity St, Austin, TX  78701, United States', 'I19566E580440C831', ARRAY['Rooftop']::text[]),
  ('Restaurant Francois', 'restaurant-francois', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2661022, -97.7475314, '401 W 3rd St, Ste 100, Austin, TX 78701, United States', 'IB6E780FA90BE88C5', ARRAY['Experience_Spots','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Rocco''s', 'rocco-s', 'unclassified', NULL, false, false, 'United States', 'Austin', NULL, 30.3111976, -97.7150656, '5001 Airport Blvd, Austin, TX 78751, United States', 'IEA7F22AFABE397BB', ARRAY['Try_List']::text[]),
  ('Rocheli Patisserie', 'rocheli-patisserie', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.2743674, -97.7201636, '1212 Chicon St, Unit 102, Austin, TX 78702, United States', 'IDE7CEA22D9C81472', ARRAY['Dessert']::text[]),
  ('Room 725', 'room-725', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.262242, -97.7385503, '101 Red River St, Austin, TX  78701, United States', 'ID592CFA276E48A4', ARRAY['Cool_Bars']::text[]),
  ('Root Cellar Cafe', 'root-cellar-cafe', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'San Marcos', 29.8835415, -97.940374, '215 N LBJ Dr, San Marcos, TX  78666, United States', 'IB3A9CC3A996AAA2A', ARRAY['Fair_Restaurants_']::text[]),
  ('Rosati''s Pizza', 'rosati-s-pizza', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Cedar Park', 30.5178864, -97.8378955, '800 Whitestone Blvd, Unit B-1, Cedar Park, TX 78613, United States', 'I6CED262075428A1B', ARRAY['Fair_Restaurants_']::text[]),
  ('Rose Gose', 'rose-gose', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.3131676, -97.714794, '5201 Airport Blvd, Austin, TX  78751, United States', 'I2A04A2F77E595043', ARRAY['Designation']::text[]),
  ('Rosie''s Wine Bar', 'rosie-s-wine-bar', 'winery', NULL, false, true, 'United States', 'Austin', NULL, 30.2728376, -97.7569274, '1130 W 6th St, Austin, TX  78703, United States', 'I459C698C7D6BE2F', ARRAY['Wineries']::text[]),
  ('Roya', 'roya', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.3606235, -97.7414379, '7858 Shoal Creek Blvd, Ste C, Austin, TX  78757, United States', 'IF4E4A88093CF7D56', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('Rules & Regs', 'rules-regs', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2619554, -97.7380663, '101 Red River St, Austin, TX  78701, United States', 'I271984D7AD4C9379', ARRAY['Cool_Bars']::text[]),
  ('Sabor Venezolano', 'sabor-venezolano', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2243875, -97.770482, '4111 S 1st St, Austin, TX  78745, United States', 'I704C01991723DAB0', ARRAY['Food_Trucks']::text[]),
  ('Sammataro', 'sammataro', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2756164, -97.7071465, '2907 E 12th St, Austin, TX  78702, United States', 'I85E01FA3BA9D3671', ARRAY['Food_Trucks']::text[]),
  ('Sammie''s', 'sammie-s', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2702085, -97.7510658, '807 W 6th St, Austin, TX 78703, United States', 'I2C658B5DD684E69E', ARRAY['Designation']::text[]),
  ('San Gines', 'san-gines', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2486467, -97.770258, '2072 S Lamar Blvd, Austin, TX  78704, United States', 'I8C77E092844BB1BD', ARRAY['Breakfast___Brunch']::text[]),
  ('Santa Catarina', 'santa-catarina', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.285557, -97.7100285, '2901 Manor Rd, Unit 100, Austin, TX  78722, United States', 'IA891057C47B2524', ARRAY['Fair_Restaurants_']::text[]),
  ('Sawyer & Co.', 'sawyer-co', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.251427, -97.701832, '4827 E Cesar Chavez St, Austin, TX  78702, United States', 'I1805A2B78BE2CB49', ARRAY['Breakfast___Brunch']::text[]),
  ('Sazan', 'sazan', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3366438, -97.7165705, '6929 Airport Blvd, Unit 146, Austin, TX 78752, United States', 'IE14BFB1736FEF1DE', ARRAY['Fair_Restaurants_']::text[]),
  ('Scout Vintage', 'scout-vintage', 'shop', NULL, false, true, 'United States', 'Austin', NULL, 30.2602568, -97.7189546, '2121 E 6th St, Austin, TX  78702, United States', 'I2EC05E41DB845B3B', ARRAY['Stores']::text[]),
  ('Second Bar + Kitchen', 'second-bar-kitchen', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2646113, -97.7307303, '1110 E 6th St, Austin, TX  78702, United States', 'I17672241238CA5D7', ARRAY['Breakfast___Brunch']::text[]),
  ('Secret Beach', 'secret-beach', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2476022, -97.700135, '400 Grove Blvd, Austin, TX  78741, United States', 'ID3A89387D20CCE75', ARRAY['Fun_Locations']::text[]),
  ('Serenade', 'serenade', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2654316, -97.7467145, '200 Lavaca St, Austin, TX  78701, United States', 'IE60C871B7481FA2C', ARRAY['Breakfast___Brunch','Try_List']::text[]),
  ('Seven Grand', 'seven-grand', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2677934, -97.738545, '405 E 7th St, Austin, TX  78701, United States', 'I8DB344E0E6057F68', ARRAY['Fair_Bars']::text[]),
  ('Shack 512', 'shack-512', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Volente', 30.4627776, -97.913788, '8714 Lime Creek Rd, Volente, TX 78641, United States', 'IAE9BD52B2CF30BDE', ARRAY['Fair_Restaurants_']::text[]),
  ('Shiner''s Saloon', 'shiner-s-saloon', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2670446, -97.7435049, '422 Congress Ave, Unit D, Austin, TX 78701, United States', 'I1A57804450F1B6C9', ARRAY['Rooftop']::text[]),
  ('Shore Raw Bar & Grill', 'shore-raw-bar-grill', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2496407, -97.8950801, '8665 W Highway 71, Unit 100, Austin, TX 78735, United States', 'ICCE9DD10F96F1223', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Sidecar at Prince Solms Inn', 'sidecar-at-prince-solms-inn', 'restaurant', 'experience', false, true, 'United States', 'Austin', 'New Braunfels', 29.7045847, -98.1234522, '295 E San Antonio St, New Braunfels, TX 78130, United States', 'I59D9BF3477079C30', ARRAY['Experience_Spots']::text[]),
  ('Simona''s', 'simona-s', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2375597, -97.7552255, '2510 S Congress Ave, Austin, TX  78704, United States', 'I371CC460E315D7F7', ARRAY['Breakfast___Brunch']::text[]),
  ('Sip Pho', 'sip-pho', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2953829, -97.7423143, '512 W 29th St, Austin, TX  78705, United States', 'I32985A199FADF481', ARRAY['Fair_Restaurants_']::text[]),
  ('Slab BBQ & Beer', 'slab-bbq-beer', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.371311, -97.724571, '9012 Research Blvd, Unit C4, Austin, TX 78758, United States', 'I34E40D6F8CD06A2', ARRAY['Fair_Restaurants_']::text[]),
  ('Small Victory', 'small-victory', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2689051, -97.7415297, '108 E 7th St, Austin, TX  78701, United States', 'ID99C95B3F5B24D3B', ARRAY['Cool_Bars']::text[]),
  ('Sour Duck Market', 'sour-duck-market', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2798818, -97.7216807, '1814 E Martin Luther King Jr Blvd, Austin, TX  78702, United States', 'ID803DCCBB9CFFE4', ARRAY['Fair_Restaurants_']::text[]),
  ('Space Cowboy', 'space-cowboy', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2620558, -97.7213454, '1917 E 7th St, Austin, TX  78702, United States', 'ID6F9EDD426EC2AC7', ARRAY['Designation']::text[]),
  ('Space Kat BBQ', 'space-kat-bbq', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.262906, -97.7140809, '2431 Webberville Rd, Austin, TX 78702, United States', 'I4AC573B52FDBE83E', ARRAY['Food_Trucks']::text[]),
  ('Spare Birdie', 'spare-birdie', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Cedar Park', 30.5288216, -97.8209138, '1400 Discovery Blvd, Cedar Park, TX  78613, United States', 'I5474AAC4B92A8CDB', ARRAY['Fun_Locations']::text[]),
  ('Spicy Boys Fried Chicken', 'spicy-boys-fried-chicken', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2621677, -97.7242311, '1701 E 6th St, Austin, TX  78702, United States', 'I3CA2AA7037FC29CB', ARRAY['Food_Trucks']::text[]),
  ('Spread & Co.', 'spread-co', 'grocery', 'fair', false, true, 'United States', 'Austin', NULL, 30.284933, -97.716884, '2406 Manor Rd, Austin, TX  78722, United States', 'I3A0B4C2FC819A96B', ARRAY['Breakfast___Brunch','Fair_Restaurants_','Grocery']::text[]),
  ('Spud Ranch', 'spud-ranch', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7098835, -98.1192252, '118 Common St, New Braunfels, TX 78130, United States', 'IA4D4DC94671F3B67', ARRAY['Fair_Restaurants_']::text[]),
  ('St. Edward''s University', 'st-edward-s-university', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2296212, -97.7550387, '3001 South Congress, Austin, TX 78704, United States', 'ID633E93DA26CCB2E', ARRAY['Fun_Locations']::text[]),
  ('STAG Provisions for Men', 'stag-provisions-for-men', 'shop', NULL, false, true, 'United States', 'Austin', NULL, 30.2489262, -97.7496185, '1423 S Congress Ave, Austin, TX  78704, United States', 'I22209697240B8383', ARRAY['Stores']::text[]),
  ('Steiner Ranch Steakhouse', 'steiner-ranch-steakhouse', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.390152, -97.8717251, '5424 Steiner Ranch Blvd, Austin, TX 78732, United States', 'I15B8F7368317250B', ARRAY['Fair_Restaurants_']::text[]),
  ('Stiles Switch BBQ', 'stiles-switch-bbq', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.334503, -97.7213638, '6610 N Lamar Blvd, Austin, TX 78752, United States', 'IB02EC60F61FD2A32', ARRAY['Fair_Restaurants_']::text[]),
  ('Suerte', 'suerte', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2621145, -97.7233207, '1800 E 6th St, Austin, TX 78702, United States', 'IF9F4C91B84DEC0E8', ARRAY['Designation']::text[]),
  ('Summer on Music Lane', 'summer-on-music-lane', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2526588, -97.747727, '1101 Music Ln, Austin, TX  78704, United States', 'IAA7C3E9782A61FFC', ARRAY['Fair_Restaurants_']::text[]),
  ('Sundancer Grill', 'sundancer-grill', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Lakeway', 30.381415, -97.959654, '16410 Stewart Rd, Lakeway, TX 78734, United States', 'I6016C9546B9925C4', ARRAY['Fair_Restaurants_']::text[]),
  ('Sunday Bookshop', 'sunday-bookshop', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Dripping Springs', 30.1995724, -98.0873969, '28101 Ranch Road 12, Dripping Springs, TX  78620, United States', 'I29ED4D11FD9A6660', ARRAY['Fun_Locations']::text[]),
  ('Sushi Warriors', 'sushi-warriors', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3148207, -97.733109, '4600 W Guadalupe St, Unit B5, Austin, TX  78751, United States', 'IA18B5AA5F0EA9956', ARRAY['Fair_Restaurants_']::text[]),
  ('Sway', 'sway', 'restaurant', 'destination', false, true, 'United States', 'Austin', 'West Lake Hills', 30.2764276, -97.804091, '3437 Bee Caves Road, West Lake Hills, TX 78746, United States', 'IE16162F1DB4155D3', ARRAY['Designation']::text[]),
  ('Sweet Memes', 'sweet-memes', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.2263335, -97.7618695, '3801 S Congress Ave, Unit 109, Austin, TX  78704, United States', 'I8B5173C8D5288043', ARRAY['Dessert']::text[]),
  ('Taco Flats', 'taco-flats', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2800427, -97.7594798, '1110 West Lynn St, Austin, TX  78703, United States', 'I18BC19106CE467BF', ARRAY['Fair_Restaurants_']::text[]),
  ('Tavern On Castell', 'tavern-on-castell', 'bar', 'cool', false, true, 'United States', 'Austin', 'New Braunfels', 29.700779, -98.1243421, '208 S Castell Ave, New Braunfels, TX  78130, United States', 'I32C95BF4B21B2150', ARRAY['Cool_Bars']::text[]),
  ('Taverna', 'taverna', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2650867, -97.7463485, '258 W 2nd St, Austin, TX  78701, United States', 'I2929CC0801339EFD', ARRAY['Fair_Restaurants_']::text[]),
  ('Techo Mezcaleria & Agave Bar', 'techo-mezcaleria-agave-bar', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2840296, -97.718946, '2201 Manor Rd, Austin, TX  78722, United States', 'IDCB4ADBF92E341BC', ARRAY['Fair_Bars']::text[]),
  ('Teddy''s', 'teddy-s', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.284418, -97.7193752, '2200 Manor Rd, Austin, TX  78722, United States', 'IE1741EBAD291090A', ARRAY['Fair_Bars']::text[]),
  ('TenTen', 'tenten', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2692511, -97.7475719, '501 W 6th St, Austin, TX  78701, United States', 'IECCB2D34F780A49', ARRAY['Experience_Spots']::text[]),
  ('Terry Black''s BBQ', 'terry-black-s-bbq', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2597712, -97.7547826, '1003 Barton Springs Rd, Austin, TX  78704, United States', 'I4E0FCE12CF3F918B', ARRAY['Fair_Restaurants_']::text[]),
  ('Texas Keeper Cider', 'texas-keeper-cider', 'bar', 'fair', false, true, 'United States', 'Austin', 'Manchaca', 30.1266184, -97.8194324, '12521 Twin Creeks Rd, Manchaca, TX 78652, United States', 'I823B3AB4CB50C69A', ARRAY['Fair_Bars']::text[]),
  ('Texas Paintball', 'texas-paintball', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Jonestown', 30.5035519, -97.910344, '18300 Medina Vista Ln, Jonestown, TX  78645, United States', 'I1C17D5AB5F74D93B', ARRAY['Fun_Locations']::text[]),
  ('The Alley', 'the-alley', 'unclassified', NULL, false, true, 'United States', 'Austin', 'Sunset Valley', 30.2327385, -97.8205025, '5400 Brodie Ln, Ste 1010, Sunset Valley, TX  78745, United States', 'I4DF59C658E6DC5ED', ARRAY['Other']::text[]),
  ('The Austin Club', 'the-austin-club', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2709416, -97.7408389, '110 E 9th St, Austin, TX  78701, United States', 'ICBC65EB0E559E0A4', ARRAY['Fun_Locations']::text[]),
  ('The Beez Kneez', 'the-beez-kneez', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2702738, -97.7484756, '610 Nueces St, Ste 100, Austin, TX  78701, United States', 'ID2C95A7B60116625', ARRAY['Fair_Bars']::text[]),
  ('The Betty', 'the-betty', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.269454, -97.7498866, '510 Rio Grande St, Austin, TX  78701, United States', 'I8C85E59F5DC464D5', ARRAY['Cool_Bars']::text[]),
  ('The Carillon', 'the-carillon', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.281654, -97.740105, '1900 University Ave, Austin, TX 78705, United States', 'I6A23BFF57AD84925', ARRAY['Designation']::text[]),
  ('The Concourse Project', 'the-concourse-project', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.1805895, -97.6863325, 'Building 1 8509 Burleson Rd, Unit 100, Austin, TX 78719, United States', 'I4C2EC0245AF1FC95', ARRAY['Fun_Locations']::text[]),
  ('The Copperhead Club', 'the-copperhead-club', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2401665, -97.7262808, '2120 E Riverside Dr, Austin, TX  78741, United States', 'IE18D116B59B2346E', ARRAY['Fair_Bars']::text[]),
  ('The Cornucopia', 'the-cornucopia', 'grocery', NULL, false, true, 'United States', 'Austin', 'San Marcos', 29.88617, -97.92493, '1104 Thorpe Ln, Unit J, San Marcos, TX 78666, United States', 'IC3B205660CE73638', ARRAY['Grocery']::text[]),
  ('The Cut', 'the-cut', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2645243, -97.7365411, '401 Sabine St, Austin, TX  78701, United States', 'IA0CB8DF0E635C414', ARRAY['Fun_Locations']::text[]),
  ('The Driskill', 'the-driskill', 'hotel', NULL, false, true, 'United States', 'Austin', NULL, 30.2679755, -97.7416555, '604 Brazos St, Austin, TX  78701, United States', 'I18E19B7BEF8E2462', ARRAY['Hotels']::text[]),
  ('The Driskill Bar', 'the-driskill-bar', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2684265, -97.7416062, '117 E 7th St, Austin, TX  78701, United States', 'I14A5CD18F2B53D2D', ARRAY['Cool_Bars']::text[]),
  ('The Eleanor', 'the-eleanor', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2677065, -97.7462686, '307 W 5th St, Unit A, Austin, TX 78701, United States', 'I90492C69A63707E6', ARRAY['Fair_Bars']::text[]),
  ('The Escape Game', 'the-escape-game', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2647571, -97.7376513, '405 Red River St, Austin, TX  78701, United States', 'I8B8B73CEFC2E333C', ARRAY['Fun_Locations']::text[]),
  ('The Flower Shop', 'the-flower-shop', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2651339, -97.728603, '1300 E 7th St, Austin, TX  78702, United States', 'I8A794F078E406B0F', ARRAY['Fun_Locations']::text[]),
  ('The Front Page', 'the-front-page', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2673238, -97.6938629, 'Building 1 1023 Springdale Rd, Suite  F, Austin, TX 78721, United States', 'I90A84E2392738F89', ARRAY['Breakfast___Brunch']::text[]),
  ('The Good Lot', 'the-good-lot', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Cedar Park', 30.5235786, -97.8648532, '2500 W New Hope Dr, Cedar Park, TX  78613, United States', 'ID2829497BD9AA63E', ARRAY['Food_Trucks','Fun_Locations']::text[]),
  ('The Gramercy', 'the-gramercy', 'bar', 'cool', false, true, 'United States', 'Austin', 'Lakeway', 30.3472873, -97.9663646, '1516 Ranch Road 620 S, Unit 200, Lakeway, TX  78734, United States', 'IEFC9A87DAAC99713', ARRAY['Cool_Bars']::text[]),
  ('The Grove Wine Bar & Kitchen', 'the-grove-wine-bar-kitchen', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2960731, -97.8322096, '6317 RM-2244, Ste 380, Austin, TX  78746, United States', 'I4B090E867D343844', ARRAY['Fair_Restaurants_','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('The Grove Wine Bar & Kitchen', 'the-grove-wine-bar-kitchen-2', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.333902, -97.967751, '3001 Ranch Road 620 S, Austin, TX 78738, United States', 'I7677AA89E622F902', ARRAY['Fair_Restaurants_']::text[]),
  ('The Guest House', 'the-guest-house', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2653458, -97.7491567, '110 San Antonio St, Unit 140, Austin, TX  78701, United States', 'I91A40F8387BB823E', ARRAY['Designation']::text[]),
  ('The Hive', 'the-hive', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.1652941, -97.8294852, '10542 Menchaca Rd, Austin, TX  78748, United States', 'I3546B9640A53BA78', ARRAY['Breakfast___Brunch']::text[]),
  ('The Kimberly', 'the-kimberly', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.269187, -97.7442405, '200 W 7th St, Ste 100, Austin, TX 78701, United States', 'I8A5E171E6DBCC147', ARRAY['Experience_Spots']::text[]),
  ('The Kitchen', 'the-kitchen', 'restaurant', 'experience', true, true, 'United States', 'Austin', NULL, 30.2694434, -97.7471022, '400 W 6th St, Unit 125, Austin, TX  78701, United States', 'I177FE60C1C61BCFF', ARRAY['Experience_Spots','Michael_s_Top_Faves']::text[]),
  ('The Little Darlin''', 'the-little-darlin', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.1944773, -97.7768378, '6507 Circle S Rd, Austin, TX  78745, United States', 'I9E2AB775E3BE4C65', ARRAY['Fun_Locations']::text[]),
  ('The Local', 'the-local', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.1849897, -97.8472209, '9901 Brodie Ln, Unit 120, Austin, TX  78748, United States', 'I9E5FC84EE98670CB', ARRAY['Fair_Restaurants_']::text[]),
  ('The Long Goodbye', 'the-long-goodbye', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2857202, -97.7113937, '2808 Manor Rd, Austin, TX  78722, United States', 'I91810B3D2C6C36FC', ARRAY['Fair_Bars']::text[]),
  ('The Natural Gardener', 'the-natural-gardener', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2570979, -97.8905493, '8648 Old Bee Caves Rd, Austin, TX  78735, United States', 'I73CE377548147861', ARRAY['Fun_Locations']::text[]),
  ('The Peacock', 'the-peacock', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.266249, -97.7501378, '600 W 2nd St, Ground Floor, Austin, TX 78701, United States', 'I2192B4B907C889B8', ARRAY['Breakfast___Brunch','Experience_Spots']::text[]),
  ('The Picnic', 'the-picnic', 'food_truck', NULL, false, true, 'United States', 'Austin', NULL, 30.2635338, -97.7628762, '1720 Barton Springs Rd, Austin, TX  78704, United States', 'I156C76AEF156AF17', ARRAY['Food_Trucks']::text[]),
  ('The Roosevelt Room', 'the-roosevelt-room', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2677065, -97.7462686, '307 W 5th St, Unit B, Austin, TX  78701, United States', 'ID2685C8B93D4C73D', ARRAY['Cool_Bars']::text[]),
  ('The Rose Room', 'the-rose-room', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.401358, -97.7229167, '11500 Rock Rose Ave, Austin, TX  78758, United States', 'IC2302B931EF85142', ARRAY['Fun_Locations']::text[]),
  ('The RSRV', 'the-rsrv', 'winery', NULL, false, true, 'United States', 'Austin', NULL, 30.2568952, -97.7035562, '3415 E 7th St, Austin, TX  78702, United States', 'I4098E5005737177C', ARRAY['Wineries']::text[]),
  ('The Stay Put', 'the-stay-put', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2582849, -97.7387353, '73 Rainey St, Austin, TX  78701, United States', 'I246195A84AE5D8F0', ARRAY['Fair_Bars']::text[]),
  ('The UMLAUF Sculpture Garden + Museum', 'the-umlauf-sculpture-garden-museum', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2632466, -97.7661324, '605 Azie Morton Rd, Austin, TX  78704, United States', 'I2DAC753482623D99', ARRAY['Fun_Locations']::text[]),
  ('The Well', 'the-well', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2656303, -97.748334, '440 W 2nd St, Austin, TX  78701, United States', 'I17922ED5F02B0D36', ARRAY['Breakfast___Brunch']::text[]),
  ('The Wheel', 'the-wheel', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2801516, -97.7208499, '1902-B E MLK Blvd, Austin, TX 78702, United States', 'I23304C4A58A03F18', ARRAY['Fair_Bars']::text[]),
  ('The World of Tennis', 'the-world-of-tennis', 'outdoors', NULL, false, true, 'United States', 'Austin', 'Lakeway', 30.351686, -97.9980844, '100 World of Tennis Sq, Lakeway, TX  78738, United States', 'I24349E648962BAAF', ARRAY['Fun_Locations']::text[]),
  ('Tiger Lilly', 'tiger-lilly', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.266837, -97.745021, '400 Colorado St, Austin, TX  78701, United States', 'I3E703A9BFDA9853A', ARRAY['Fun_Locations']::text[]),
  ('Tiki Tatsu-Ya', 'tiki-tatsu-ya', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2538354, -97.7633082, '1300 S Lamar Blvd, Austin, TX  78704, United States', 'IEFC77BB0C3D8738', ARRAY['Fair_Restaurants_']::text[]),
  ('Tin Top Burger Shop', 'tin-top-burger-shop', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'New Braunfels', 29.7085658, -98.1185425, '283 S Union Ave, Unit 101, New Braunfels, TX  78130, United States', 'I864101D4A81AA7D5', ARRAY['Fair_Restaurants_']::text[]),
  ('Tiniest Bar In Texas', 'tiniest-bar-in-texas', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2695701, -97.7531068, '817 W 5th St, Austin, TX  78703, United States', 'I648ADD9F87A03603', ARRAY['Fair_Bars']::text[]),
  ('Tiny Grocer / Hyde Park', 'tiny-grocer-hyde-park', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.3068877, -97.7299869, '4300 Speedway, Ste 101, Austin, TX  78751, United States', 'IFB4D25018ED676', ARRAY['Grocery']::text[]),
  ('Tiny Minotaur', 'tiny-minotaur', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2532195, -97.7140706, '2701 E Cesar Chavez St, Austin, TX  78702, United States', 'I4392F88A98C44F0F', ARRAY['Fun_Locations']::text[]),
  ('Tiny''s Milk & Cookies', 'tiny-s-milk-cookies', 'dessert', NULL, false, true, 'United States', 'Austin', NULL, 30.306582, -97.7503985, '1515 W 35th St, Unit C, Austin, TX 78703, United States', 'I67A302A3F293C536', ARRAY['Dessert']::text[]),
  ('Toasty Badger', 'toasty-badger', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.24107, -97.7528939, '2206 S Congress Ave, Austin, TX  78704, United States', 'I5F16AEF04894474E', ARRAY['Breakfast___Brunch']::text[]),
  ('Topgolf Swing Suite - Austin', 'topgolf-swing-suite-austin', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.265107, -97.7385981, '500 E 4th St, Austin, TX  78701, United States', 'I1EDAF7348A8D8F59', ARRAY['Fun_Locations']::text[]),
  ('Toshokan', 'toshokan', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2635212, -97.734704, '807 E 4th St, Austin, TX  78702, United States', 'IFD434C9854ED714D', ARRAY['Designation']::text[]),
  ('Trona', 'trona', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2738286, -97.7203095, '1812 E 12th St, Austin, TX  78702, United States', 'I9F29D6F92791B3D2', ARRAY['Cool_Bars']::text[]),
  ('Truluck''s Ocean''s Finest Seafood & Crab', 'truluck-s-ocean-s-finest-seafood-crab', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2659617, -97.7452755, '300 Colorado St, Austin, TX  78701, United States', 'IC5DB178375FD7DFE', ARRAY['Experience_Spots']::text[]),
  ('Tsuke Edomae', 'tsuke-edomae', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2987316, -97.7077246, '4600 Mueller Blvd, Ste 1035, Austin, TX 78723, United States', 'I94D7BFAB269E1C24', ARRAY['Experience_Spots']::text[]),
  ('Tumble 22', 'tumble-22', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.3479586, -97.7353299, '7211 Burnet Rd, Austin, TX  78757, United States', 'I6B87DC3E45DD1A1F', ARRAY['Fair_Restaurants_']::text[]),
  ('Tumlinson''s Smoky Top BBQ', 'tumlinson-s-smoky-top-bbq', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Llano', 30.7597785, -98.6628807, '1009 E Hwy St, Unit 29, Llano, TX 78643, United States', 'IB4621F1A9105D8F4', ARRAY['Fair_Restaurants_']::text[]),
  ('Two Hands', 'two-hands', 'restaurant', NULL, false, true, 'United States', 'Austin', NULL, 30.2534975, -97.7479202, '1011 S Congress Ave, Unit 170, Austin, TX 78704, United States', 'I82E626442476F8EE', ARRAY['Breakfast___Brunch']::text[]),
  ('Uchi', 'uchi', 'restaurant', 'experience', false, true, 'United States', 'Austin', NULL, 30.2575409, -97.7597957, '801 S Lamar Blvd, Austin, TX 78704, United States', 'I2E8A9418A5077CA5', ARRAY['Experience_Spots']::text[]),
  ('Uchibā Austin', 'uchib-austin', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.2658229, -97.7501889, '601 W 2nd St, Austin, TX 78701, United States', 'IFAFE34227A96997D', ARRAY['Experience_Spots','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Urban Rooftop', 'urban-rooftop', 'bar', NULL, false, true, 'United States', 'Austin', 'Round Rock', 30.5064591, -97.6823026, '411 W Main St, Round Rock, TX 78681, United States', 'I31A8BABE9D757927', ARRAY['Rooftop']::text[]),
  ('Uroko', 'uroko', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2675926, -97.6939273, '1023 Springdale Rd Bldg 1, Unit 1, Austin, TX  78721, United States', 'I786A029EE52A5E36', ARRAY['Fair_Restaurants_']::text[]),
  ('VanHorn''s', 'vanhorn-s', 'unclassified', NULL, false, false, 'United States', 'Austin', NULL, 30.2650218, -97.7459441, '238 W 2nd St, Austin, TX 78701, United States', 'ID449A96199E4055F', ARRAY['Try_List']::text[]),
  ('Vaudeville', 'vaudeville', 'restaurant', 'destination', false, true, 'United States', 'Austin', 'Fredericksburg', 30.2734579, -98.8696414, '230 E Main St, Fredericksburg, TX  78624, United States', 'IE5394A1439DA4E3C', ARRAY['Designation']::text[]),
  ('Veracruz Fonda & Bar', 'veracruz-fonda-bar', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2981527, -97.7052194, '1905 Aldrich St, Unit 125, Austin, TX 78723, United States', 'I92DF04E8224A0EAA', ARRAY['Fair_Restaurants_']::text[]),
  ('Verbena', 'verbena', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2701018, -97.7489977, '612 W 6th St, Austin, TX  78701, United States', 'I556ECEDBD45CF0FE', ARRAY['Designation']::text[]),
  ('VERDAD True Modern Mexican', 'verdad-true-modern-mexican', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.318198, -97.753541, '2701 Perseverance Dr, Austin, TX  78731, United States', 'IBF3E0431415CFDF3', ARRAY['Fair_Restaurants_']::text[]),
  ('Vespaio', 'vespaio', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2473254, -97.7508395, '1610 S Congress Ave, Austin, TX  78704, United States', 'I11299A1C0D91A46', ARRAY['Fair_Restaurants_']::text[]),
  ('Vic & Al''s', 'vic-al-s', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.284946, -97.716934, '2406 Manor Rd, Unit D, Austin, TX 78722, United States', 'IB2B5A5F104F43D8C', ARRAY['Fair_Restaurants_']::text[]),
  ('Vigilante Gastropub and Games', 'vigilante-gastropub-and-games', 'outdoors', 'fair', false, true, 'United States', 'Austin', NULL, 30.3393495, -97.7183505, '7010 Easy Wind Dr, Unit 150, Austin, TX  78752, United States', 'I81EFD35B8E164C8', ARRAY['Fair_Restaurants_','Fun_Locations']::text[]),
  ('Vinaigrette', 'vinaigrette', 'restaurant', 'fair', false, true, 'United States', 'Austin', NULL, 30.2412867, -97.75204, '2201 College Ave, Austin, TX  78704, United States', 'IB59695E04A17CAA1', ARRAY['Fair_Restaurants_']::text[]),
  ('Vince Young Steakhouse', 'vince-young-steakhouse', 'restaurant', 'destination', false, true, 'United States', 'Austin', NULL, 30.2647543, -97.7411732, '301 San Jacinto Blvd, Austin, TX 78701, United States', 'I15C96E0399760272', ARRAY['Designation']::text[]),
  ('Watertrade', 'watertrade', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2477216, -97.7499188, '1603 S Congress Ave, Austin, TX  78704, United States', 'I47864DED024B859E', ARRAY['Cool_Bars']::text[]),
  ('Westlake Wine Bar', 'westlake-wine-bar', 'winery', NULL, false, true, 'United States', 'Austin', NULL, 30.3352363, -97.8052819, '3801 N Capital of Texas Hwy, Unit A-180, Austin, TX 78746, United States', 'I9A3FD5A959007184', ARRAY['Wineries']::text[]),
  ('Wheatsville Food Co-op', 'wheatsville-food-co-op', 'grocery', NULL, false, true, 'United States', 'Austin', NULL, 30.2975567, -97.7410719, '3101 Guadalupe St, Austin, TX  78705, United States', 'I1AB1B6EE7F784A35', ARRAY['Grocery']::text[]),
  ('Whipped Bakery & Cafe', 'whipped-bakery-cafe', 'dessert', NULL, false, true, 'United States', 'Austin', 'Leander', 30.5634296, -97.8015697, '15609 Ronald W Reagan Blvd, Unit B220, Leander, TX  78641, United States', 'I41417A12D9F2C67B', ARRAY['Dessert']::text[]),
  ('Whisler''s', 'whisler-s', 'bar', 'cool', false, true, 'United States', 'Austin', NULL, 30.2620048, -97.7226645, '1816 E 6th St, Austin, TX  78702, United States', 'I8DA01279493D2E6A', ARRAY['Cool_Bars','Night_Out']::text[]),
  ('Winston’s', 'winston-s', 'restaurant', 'fair', false, true, 'United States', 'Austin', 'Spicewood', 30.3377805, -98.0275504, '4900 Bee Creek Rd, Spicewood, TX  78669, United States', 'I7A0DB3361CFE7E0B', ARRAY['Fair_Restaurants_']::text[]),
  ('WXYZ Bar', 'wxyz-bar', 'bar', 'fair', false, true, 'United States', 'Austin', NULL, 30.2210277, -97.8326408, '6731 Legado Ln, Austin, TX  78749, United States', 'I6D6B70A280F5FFA1', ARRAY['Fair_Bars']::text[]),
  ('Yamas', 'yamas', 'restaurant', NULL, false, false, 'United States', 'Austin', NULL, 30.3353843, -97.7591451, '5308 Balcones Dr, Austin, TX  78731, United States', 'I7A4B7AFCEEC5436D', ARRAY['Designation','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Yellow Ranger', 'yellow-ranger', 'bar', 'cool', true, true, 'United States', 'Austin', NULL, 30.3167792, -97.7141192, '5420 Airport Blvd, Austin, TX  78751, United States', 'I812024AA1999701', ARRAY['Cool_Bars','Fair_Bars','Michael_s_Top_Faves']::text[]),
  ('Zanzibar', 'zanzibar', 'bar', NULL, false, true, 'United States', 'Austin', NULL, 30.2627011, -97.7415763, '304 E Cesar Chavez St, Unit 700, Austin, TX  78701, United States', 'IA346EF020EB29299', ARRAY['Rooftop']::text[]),
  ('Zhi Tea', 'zhi-tea', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.267159, -97.692993, '1023 Springdale Rd, Austin, TX  78721, United States', 'I4B7200F7643DC94A', ARRAY['Fun_Locations']::text[]),
  ('Zilker Metropolitan Park', 'zilker-metropolitan-park', 'outdoors', NULL, false, true, 'United States', 'Austin', NULL, 30.2661099, -97.7709389, '2100 Barton Springs Rd, Austin, TX 78704, United States', 'I72764CDFBAAD7344', ARRAY['Fun_Locations']::text[]),
  ('Asado Life', 'asado-life', 'restaurant', 'fair', false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.880081, -81.3213694, '173 Shipyard Way, Saint Augustine, FL  32084, United States', 'IB1B4725194161BBE', ARRAY['Fair_Restaurants_']::text[]),
  ('Bar Harbor Cheesecake Company', 'bar-harbor-cheesecake-company', 'dessert', NULL, false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8973157, -81.31493, '6 Cordova St, Saint Augustine, FL  32084, United States', 'I5F25928A14CA441D', ARRAY['Dessert']::text[]),
  ('Cap''s On The Water', 'cap-s-on-the-water', 'restaurant', 'destination', false, true, 'United States', 'St. Augustine', NULL, 29.9550182, -81.3127005, '4325 Myrtle Street, St. Augustine, FL 32084, United States', 'I57C3A1C41580E6E5', ARRAY['Designation']::text[]),
  ('Castillo Craft Bar + Kitchen', 'castillo-craft-bar-kitchen', 'restaurant', 'destination', false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.89963, -81.315628, '6 W Castillo Dr, Saint Augustine, FL 32084, United States', 'IF09EF8D1BEBD4659', ARRAY['Designation']::text[]),
  ('Chez L''Amour', 'chez-l-amour', 'restaurant', 'destination', false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.9009791, -81.3151962, '45 San Marco Ave, Saint Augustine, FL  32084, United States', 'ICACE5DEAFC1937BD', ARRAY['Designation']::text[]),
  ('Cookiebird Ice Cream Bar', 'cookiebird-ice-cream-bar', 'dessert', NULL, false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.9056545, -81.3184779, '138 San Marco Ave, Saint Augustine, FL  32084, United States', 'I58BBB2578C150E2A', ARRAY['Dessert']::text[]),
  ('Cutie Pies Bake Shop', 'cutie-pies-bake-shop', 'dessert', NULL, false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8958756, -81.3142508, '62 Cuna St, Saint Augustine, FL  32084, United States', 'IDD3342E6D48BD860', ARRAY['Dessert']::text[]),
  ('Grilled Cheese Gallery', 'grilled-cheese-gallery', 'restaurant', 'fair', false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8928504, -81.3118033, '16 Cathedral Pl, Saint Augustine, FL 32084, United States', 'IE704D202275D3849', ARRAY['Fair_Restaurants_']::text[]),
  ('Kilwins', 'kilwins', 'dessert', NULL, false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8935284, -81.3130091, '140 St George St, Saint Augustine, FL  32084, United States', 'I4B644CBABB7724A4', ARRAY['Dessert']::text[]),
  ('La Nouvelle', 'la-nouvelle', 'restaurant', 'fair', false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8887717, -81.3159545, '102 Bridge St, Saint Augustine, FL 32084, United States', 'IF0DF9A0D99B55FA8', ARRAY['Fair_Restaurants_']::text[]),
  ('Llama Restaurant', 'llama-restaurant', 'restaurant', 'experience', false, true, 'United States', 'St. Augustine', NULL, 29.8904012, -81.2963301, '415 Anastasia Blvd, St. Augustine, FL 32080, United States', 'I530586DBFD9508E1', ARRAY['Experience_Spots']::text[]),
  ('Lotus Noodle Bar', 'lotus-noodle-bar', 'restaurant', 'fair', false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.9002033, -81.3191645, '56 Grove Ave, Saint Augustine, FL  32084, United States', 'I8B0FF5936F52AA7C', ARRAY['Fair_Restaurants_']::text[]),
  ('Maracuya by Llama', 'maracuya-by-llama', 'restaurant', NULL, false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8906288, -81.3306501, '260 W King St, Saint Augustine, FL  32084, United States', 'I909C80F549C9E21A', ARRAY['Breakfast___Brunch']::text[]),
  ('Mayday Ice Cream', 'mayday-ice-cream', 'dessert', NULL, false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8946539, -81.3133717, '100 St George St, Unit J, Saint Augustine, FL 32084, United States', 'I993DAAA7A910DC2E', ARRAY['Dessert']::text[]),
  ('River & Fort', 'river-fort', 'restaurant', 'fair', false, true, 'United States', 'St. Augustine', 'Saint Augustine', 29.8957594, -81.3115203, '12 Avenida Menendez, Saint Augustine, FL  32084, United States', 'IC28C1E64FE110ACF', ARRAY['Fair_Restaurants_']::text[]),
  ('14 Prime', '14-prime', 'unclassified', NULL, false, false, 'United States', 'Jacksonville', NULL, 30.2441619, -81.5208336, '7510 Gate Pkwy, Jacksonville, FL  32256, United States', 'I38E6A839EE696146', ARRAY['Try_List']::text[]),
  ('Black Pearl', 'black-pearl', 'restaurant', NULL, false, false, 'United States', 'Jacksonville', 'Ponte Vedra Beach', 30.1898106, -81.3817789, '880 SR-A1A N, Ponte Vedra Beach, FL 32082, United States', 'I326D76B69B90C6D7', ARRAY['Designation','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Cataluna', 'cataluna', 'restaurant', NULL, false, false, 'United States', 'Jacksonville', NULL, 30.2190802, -81.5871154, '8206 Philips Hwy, Unit 38, Jacksonville, FL  32256, United States', 'I3D1FE1643E660238', ARRAY['Designation','Try_List','CONFLICT:TIER+UNVISITED']::text[]),
  ('Coop 303', 'coop-303', 'restaurant', 'fair', false, true, 'United States', 'Jacksonville', 'Atlantic Beach', 30.3249897, -81.3972974, '303 Atlantic Blvd, Atlantic Beach, FL 32233, United States', 'I951B60152D8F377', ARRAY['Fair_Restaurants_']::text[]),
  ('Lynda''s at the Ocean Club', 'lynda-s-at-the-ocean-club', 'restaurant', 'fair', false, true, 'United States', 'Jacksonville', 'Ponte Vedra Beach', 29.9688989, -81.3097531, '3175 S Ponte Vedra Blvd, Ponte Vedra Beach, FL  32082, United States', 'I14F59C6A023C392D', ARRAY['Fair_Restaurants_']::text[]),
  ('O-Ku', 'o-ku', 'restaurant', 'fair', false, true, 'United States', 'Jacksonville', 'Jacksonville Beach', 30.2932986, -81.3906309, '502 First St N, Jacksonville Beach, FL  32250, United States', 'IDE7CA0758B2439A7', ARRAY['Fair_Restaurants_']::text[]),
  ('Sugar Factory', 'sugar-factory', 'unclassified', NULL, false, false, 'United States', 'Jacksonville', NULL, 30.2529912, -81.5295346, '4910 Big Island Dr, Jacksonville, FL 32246, United States', 'I8D360BAEF0C5A3B2', ARRAY['Try_List']::text[]),
  ('The Local', 'the-local-2', 'restaurant', NULL, false, true, 'United States', 'Jacksonville', 'Neptune Beach', 30.3242605, -81.3975166, '301 Atlantic Blvd, Neptune Beach, FL  32266, United States', 'I3E27E6456E01B16D', ARRAY['Breakfast___Brunch']::text[]),
  ('Felix', 'felix', 'restaurant', 'fair', false, true, 'United States', 'Los Angeles', 'Venice', 33.9922588, -118.4719008, '1023 Abbot Kinney Blvd, Venice, CA 90291, United States', 'I4796AB2217D8FEFF', ARRAY['Fair_Restaurants_']::text[]),
  ('Scopa Italian Roots', 'scopa-italian-roots', 'restaurant', 'fair', false, true, 'United States', 'Los Angeles', 'Venice', 33.9883355, -118.4514631, '2905 Washington Blvd, Venice, CA 90292, United States', 'I20FBB23975602136', ARRAY['Fair_Restaurants_']::text[]),
  ('UOVO', 'uovo', 'restaurant', 'fair', true, true, 'United States', 'Los Angeles', 'Marina del Rey', 33.9807838, -118.4415817, '4635 Admiralty Way, Unit 105, Marina del Rey, CA 90292, United States', 'IE65AB725F6BB603C', ARRAY['Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('Verse', 'verse', 'unclassified', NULL, false, false, 'United States', 'Los Angeles', 'Toluca Lake', 34.1462998, -118.3630514, '4212 Lankershim Blvd, Toluca Lake, CA 91602, United States', 'ICA06A8928DEE5AC', ARRAY['Try_List']::text[]),
  ('Atomic Burger', 'atomic-burger', 'restaurant', 'fair', false, true, 'United Kingdom', 'Oxfordshire', 'Oxford', 51.7485612, -1.2398618, '92 Cowley Road, Oxford, OX4 1JE, England', 'I2E02CC1B1715D310', ARRAY['Fair_Restaurants_']::text[]),
  ('Cosmo', 'cosmo', 'restaurant', 'fair', true, true, 'United Kingdom', 'Oxfordshire', 'Oxford', 51.7543829, -1.2591738, '8 Magdalen Street, Oxford, OX1 3AD, England', 'IE6E896B1B3A4AF2D', ARRAY['Fair_Restaurants_','Michael_s_Top_Faves']::text[]),
  ('Piccolino', 'piccolino', 'restaurant', 'fair', false, true, 'United Kingdom', 'Oxfordshire', 'Henley-on-Thames', 51.5376561, -0.9057516, '20 Market Place, Henley-On-Thames, RG9 2AH, England', 'I98A9296B4A5FD77A', ARRAY['Fair_Restaurants_']::text[]),
  ('Amazonico', 'amazonico', 'restaurant', 'experience', false, true, 'United Kingdom', 'London', NULL, 51.5095749, -0.144687, '10 Berkeley Square, London, W1J 6BR, England', 'I1C87C738C0F4B30E', ARRAY['Experience_Spots']::text[]),
  ('Field of Dinosaurs', 'field-of-dinosaurs', 'outdoors', NULL, false, true, 'United States', 'Dallas-Fort Worth', 'Cleburne', 32.3061957, -97.5485086, '8444 W US Highway 67, Cleburne, TX  76033, United States', 'I1DDBC3EA2D3C9D47', ARRAY['Fun_Locations']::text[]),
  ('Kafi BBQ', 'kafi-bbq', 'unclassified', NULL, false, false, 'United States', 'Dallas-Fort Worth', 'Irving', 32.9196781, -96.9570601, '8140 N MacArthur Blvd, Unit 100, Irving, TX  75063, United States', 'I18DA2290D6BFE156', ARRAY['Try_List']::text[]),
  ('Omni Theater', 'omni-theater', 'outdoors', NULL, false, true, 'United States', 'Dallas-Fort Worth', 'Fort Worth', 32.7439309, -97.369218, '1600 Gendy St, Fort Worth, TX  76107, United States', 'IE246C39DDE346ED6', ARRAY['Fun_Locations']::text[]),
  ('Fernando de Noronha Airport', 'fernando-de-noronha-airport', 'unclassified', NULL, false, true, 'Brazil', 'Fernando de Noronha', NULL, -3.8564744, -32.4284219, 'Aeroporto de Fernando de Noronha, Rodiva BR-360, 4 Km, Fernando de Noronha - PE, 53990-000, Brasil', 'I65BE5A3A19140D92', ARRAY['Vacation']::text[]),
  ('Pousada Alamoa', 'pousada-alamoa', 'unclassified', NULL, false, true, 'Brazil', 'Fernando de Noronha', NULL, -3.847331, -32.412542, 'Rua Alameda Harmônia, 4, Fernando De Noronha - PE, 53990-000, Brazil', 'IC6CE731272A23DAA', ARRAY['Vacation']::text[]),
  ('Water Street Waffle Company', 'water-street-waffle-company', 'restaurant', NULL, false, true, 'United States', 'Belton', NULL, 31.0554975, -97.4637058, '107 Water St, Belton, TX  76513, United States', 'ID384B23FF9699C39', ARRAY['Breakfast___Brunch']::text[]),
  ('Uncommon Coffee', 'uncommon-coffee', 'restaurant', NULL, false, true, 'United States', 'Essex Junction', NULL, 44.5079905, -73.0808445, '19 Essex Way, Essex Junction, VT  05452, United States', 'I1FBB81F7F58171AD', ARRAY['Breakfast___Brunch']::text[]),
  ('Garvens Store', 'garvens-store', 'outdoors', NULL, true, true, 'United States', 'Mountain Home', NULL, 30.0677523, -99.6933317, '27304 N. US-83, Mountain Home, TX 78058, United States', 'IB18C281197D91D0B', ARRAY['Fun_Locations','Michael_s_Top_Faves']::text[]),
  ('Roewe Outfitters', 'roewe-outfitters', 'outdoors', NULL, false, true, 'United States', 'Rochester', NULL, 33.3155345, -99.8062903, '179 County Road 113, Rochester, TX  79544, United States', 'I3D52E04DC88188C2', ARRAY['Fun_Locations']::text[]),
  ('Cesarina', 'cesarina', 'unclassified', NULL, false, false, 'United States', 'San Diego', NULL, 32.7433292, -117.2345924, '4161 Voltaire St, San Diego, CA 92107, United States', 'IC917B7967FDFB3DA', ARRAY['Try_List']::text[]),
  ('The Magnolia Pancake Haus', 'the-magnolia-pancake-haus', 'restaurant', NULL, false, true, 'United States', 'Schertz', NULL, 29.6020856, -98.2734668, '17730 I-35 N, Schertz, TX 78154, United States', 'I3DDD3877CC2FF469', ARRAY['Breakfast___Brunch']::text[]),
  ('Mashiko Japanese Restaurant', 'mashiko-japanese-restaurant', 'unclassified', NULL, false, false, 'United States', 'Seattle', NULL, 47.5603632, -122.3869796, '4725 California Ave SW, Seattle, WA  98116, United States', 'I8585FBFAB8F0554B', ARRAY['Try_List']::text[]),
  ('Pivovar', 'pivovar', 'unclassified', NULL, false, false, 'United States', 'Waco', NULL, 31.5522638, -97.1315678, '320 S Eighth St, Waco, TX  76701, United States', 'IB641FB787CEC4C9', ARRAY['Try_List']::text[]),
  ('The Brasserie at Hotel 1928', 'the-brasserie-at-hotel-1928', 'restaurant', 'fair', false, true, 'United States', 'Waco', NULL, 31.5560758, -97.1348156, '701 Washington Ave, Waco, TX  76701, United States', 'ID073E3942AE58BBB', ARRAY['Fair_Restaurants_']::text[])
ON CONFLICT (apple_id) DO NOTHING;


-- ------------------------------------------------------------------------
-- BLOCK 06 — Suggested tag assignments (145)
--
-- Authorised explicitly by Edu for this import. Everything written here is
-- marked `suggested`, never `curator`, so the admin can tell a machine guess
-- from a verdict (RN-15) and one predicate reverts the lot:
--   DELETE FROM place_tags WHERE source = 'suggested';
--
-- Two sources, no inference beyond them:
--   * the CSV's Tags column, which came from Michael's own guide names
--   * unambiguous cuisine words in the place name, on food-serving types only
--
-- price_band is deliberately NOT pre-filled. It is a verdict (ADR-06) and the
-- schema has no column to mark a machine guess as provisional, so a guess
-- there would be indistinguishable from the curator's own call.
-- ------------------------------------------------------------------------

INSERT INTO public.place_tags (place_id, tag_id, source)
SELECT p.id, t.id, 'suggested'
FROM (VALUES
  ('1886-cafe-bakery', 'cuisine', 'breakfast-diner'),
  ('1886-cafe-bakery', 'cuisine', 'bakery-pastry'),
  ('24-diner', 'cuisine', 'breakfast-diner'),
  ('85-c-bakery-cafe', 'cuisine', 'breakfast-diner'),
  ('85-c-bakery-cafe', 'cuisine', 'bakery-pastry'),
  ('85-c-bakery-cafe-2', 'cuisine', 'bakery-pastry'),
  ('an-nyeong-k-tofu-bbq', 'cuisine', 'korean'),
  ('ani-s-day-night', 'cuisine', 'breakfast-diner'),
  ('another-broken-egg-cafe', 'cuisine', 'breakfast-diner'),
  ('asado-s-taqueria', 'cuisine', 'tacos'),
  ('azul-rooftop', 'vibe', 'rooftop'),
  ('baguette-et-chocolat', 'cuisine', 'breakfast-diner'),
  ('bitelo-brazilian-steakhouse', 'cuisine', 'steakhouse'),
  ('bitelo-brazilian-steakhouse', 'cuisine', 'brazilian'),
  ('boa-steakhouse', 'cuisine', 'steakhouse'),
  ('cabana-club', 'cuisine', 'breakfast-diner'),
  ('caroline', 'vibe', 'rooftop'),
  ('carpenters-hall', 'cuisine', 'breakfast-diner'),
  ('cj-s-tacos', 'cuisine', 'tacos'),
  ('colleen-s-kitchen', 'cuisine', 'breakfast-diner'),
  ('comadre-panaderia', 'cuisine', 'breakfast-diner'),
  ('cosmic', 'cuisine', 'breakfast-diner'),
  ('cousin-louie-s-italian-american', 'cuisine', 'italian'),
  ('cr-pe-crazy', 'cuisine', 'breakfast-diner'),
  ('cuantos-tacos', 'cuisine', 'tacos'),
  ('david-doughie-s-bagelry', 'cuisine', 'breakfast-diner'),
  ('day-maker-half-day-cafe', 'cuisine', 'breakfast-diner'),
  ('days-pizza', 'cuisine', 'pizza'),
  ('dean-s-italian-steakhouse', 'cuisine', 'steakhouse'),
  ('dean-s-italian-steakhouse', 'cuisine', 'italian'),
  ('desano-pizzeria-napoletana', 'cuisine', 'pizza'),
  ('dk-sushi-south-seoul-korean-restaurant', 'cuisine', 'sushi'),
  ('dk-sushi-south-seoul-korean-restaurant', 'cuisine', 'korean'),
  ('dovetail-pizza', 'cuisine', 'pizza'),
  ('easy-tiger', 'cuisine', 'breakfast-diner'),
  ('edge-rooftop', 'vibe', 'rooftop'),
  ('el-alma', 'cuisine', 'breakfast-diner'),
  ('el-cockfight', 'vibe', 'rooftop'),
  ('fair-lane-cocktails-coffee', 'cuisine', 'breakfast-diner'),
  ('fair-lane-cocktails-coffee', 'cuisine', 'coffee'),
  ('favorite-pizza', 'cuisine', 'pizza'),
  ('feral-pizza', 'cuisine', 'pizza'),
  ('first-watch', 'cuisine', 'breakfast-diner'),
  ('franklin-barbecue', 'cuisine', 'bbq'),
  ('freda-s-seafood-grille', 'cuisine', 'seafood'),
  ('geraldine-s', 'cuisine', 'breakfast-diner'),
  ('gil-s-broiler-the-manske-roll-bakery', 'cuisine', 'bakery-pastry'),
  ('grata-s-pizzeria', 'cuisine', 'pizza'),
  ('group-therapy', 'cuisine', 'breakfast-diner'),
  ('gr-cia-mediterranean', 'cuisine', 'mediterranean'),
  ('guadalupe-brewing-company-pizza-kitchen', 'cuisine', 'pizza'),
  ('gusto-italian-kitchen', 'cuisine', 'italian'),
  ('heydey-social-club', 'vibe', 'rooftop'),
  ('hillside-farmacy', 'cuisine', 'breakfast-diner'),
  ('hotel-vegas', 'occasion', 'night-out'),
  ('houndstooth', 'cuisine', 'breakfast-diner'),
  ('inferno-s-pizza', 'cuisine', 'pizza'),
  ('interstellar-bbq', 'cuisine', 'bbq'),
  ('june-s-all-day', 'cuisine', 'breakfast-diner'),
  ('k-bbq', 'cuisine', 'korean'),
  ('kg-bbq', 'cuisine', 'bbq'),
  ('la-barbecue', 'cuisine', 'bbq'),
  ('la-volta-pizza-club', 'cuisine', 'pizza'),
  ('latchkey', 'occasion', 'night-out'),
  ('laurel-restaurant', 'cuisine', 'breakfast-diner'),
  ('leona-botanical-cafe-bar', 'cuisine', 'breakfast-diner'),
  ('limestone-rooftop', 'vibe', 'rooftop'),
  ('lin-asian-bar-dim-sum-restaurant', 'cuisine', 'chinese'),
  ('local-foods', 'cuisine', 'breakfast-diner'),
  ('lost-and-found-rooftop-bar', 'vibe', 'rooftop'),
  ('mcadoo-s-seafood-company', 'cuisine', 'seafood'),
  ('moderna-bar-pizzeria', 'cuisine', 'pizza'),
  ('more-home-slice-pizza', 'cuisine', 'pizza'),
  ('morninglory', 'cuisine', 'breakfast-diner'),
  ('mozart-s-coffee-roasters', 'cuisine', 'breakfast-diner'),
  ('mozart-s-coffee-roasters', 'cuisine', 'coffee'),
  ('neighborhood-sushi', 'cuisine', 'sushi'),
  ('nixta-taqueria', 'cuisine', 'tacos'),
  ('nom-burgers', 'cuisine', 'burgers'),
  ('opa-coffee-wine-bar', 'cuisine', 'coffee'),
  ('otopia-rooftop-lounge', 'vibe', 'rooftop'),
  ('ovenbird', 'cuisine', 'breakfast-diner'),
  ('p6', 'vibe', 'rooftop'),
  ('paperboy', 'cuisine', 'breakfast-diner'),
  ('paperboy-2', 'cuisine', 'breakfast-diner'),
  ('paris-baguette', 'cuisine', 'breakfast-diner'),
  ('parish-barbecue', 'cuisine', 'bbq'),
  ('pedroso-s-pizza', 'cuisine', 'pizza'),
  ('phoebe-s-diner', 'cuisine', 'breakfast-diner'),
  ('phoebe-s-diner-2', 'cuisine', 'breakfast-diner'),
  ('plaza-colombian-coffee-bar', 'cuisine', 'breakfast-diner'),
  ('plaza-colombian-coffee-bar', 'cuisine', 'coffee'),
  ('pool-bar-east-austin-hotel', 'vibe', 'rooftop'),
  ('pool-burger', 'cuisine', 'burgers'),
  ('proud-mary-coffee', 'cuisine', 'breakfast-diner'),
  ('proud-mary-coffee', 'cuisine', 'coffee'),
  ('quince-lakehouse', 'cuisine', 'breakfast-diner'),
  ('radio-east', 'cuisine', 'breakfast-diner'),
  ('red-horn-coffee-house-brewing-co', 'cuisine', 'breakfast-diner'),
  ('red-horn-coffee-house-brewing-co', 'cuisine', 'coffee'),
  ('reina', 'vibe', 'rooftop'),
  ('rocheli-patisserie', 'cuisine', 'bakery-pastry'),
  ('rosati-s-pizza', 'cuisine', 'pizza'),
  ('san-gines', 'cuisine', 'breakfast-diner'),
  ('sawyer-co', 'cuisine', 'breakfast-diner'),
  ('second-bar-kitchen', 'cuisine', 'breakfast-diner'),
  ('serenade', 'cuisine', 'breakfast-diner'),
  ('shiner-s-saloon', 'vibe', 'rooftop'),
  ('simona-s', 'cuisine', 'breakfast-diner'),
  ('sip-pho', 'cuisine', 'vietnamese'),
  ('slab-bbq-beer', 'cuisine', 'bbq'),
  ('space-kat-bbq', 'cuisine', 'bbq'),
  ('spread-co', 'cuisine', 'breakfast-diner'),
  ('steiner-ranch-steakhouse', 'cuisine', 'steakhouse'),
  ('stiles-switch-bbq', 'cuisine', 'bbq'),
  ('sushi-warriors', 'cuisine', 'sushi'),
  ('taco-flats', 'cuisine', 'tacos'),
  ('terry-black-s-bbq', 'cuisine', 'bbq'),
  ('the-front-page', 'cuisine', 'breakfast-diner'),
  ('the-good-lot', 'format', 'food-truck'),
  ('the-hive', 'cuisine', 'breakfast-diner'),
  ('the-peacock', 'cuisine', 'breakfast-diner'),
  ('the-well', 'cuisine', 'breakfast-diner'),
  ('tin-top-burger-shop', 'cuisine', 'burgers'),
  ('toasty-badger', 'cuisine', 'breakfast-diner'),
  ('truluck-s-ocean-s-finest-seafood-crab', 'cuisine', 'seafood'),
  ('tumlinson-s-smoky-top-bbq', 'cuisine', 'bbq'),
  ('two-hands', 'cuisine', 'breakfast-diner'),
  ('urban-rooftop', 'vibe', 'rooftop'),
  ('vince-young-steakhouse', 'cuisine', 'steakhouse'),
  ('whipped-bakery-cafe', 'cuisine', 'bakery-pastry'),
  ('whisler-s', 'occasion', 'night-out'),
  ('zanzibar', 'vibe', 'rooftop'),
  ('cutie-pies-bake-shop', 'cuisine', 'bakery-pastry'),
  ('maracuya-by-llama', 'cuisine', 'breakfast-diner'),
  ('the-local-2', 'cuisine', 'breakfast-diner'),
  ('scopa-italian-roots', 'cuisine', 'italian'),
  ('atomic-burger', 'cuisine', 'burgers'),
  ('fernando-de-noronha-airport', 'occasion', 'vacation'),
  ('pousada-alamoa', 'occasion', 'vacation'),
  ('water-street-waffle-company', 'cuisine', 'breakfast-diner'),
  ('uncommon-coffee', 'cuisine', 'breakfast-diner'),
  ('uncommon-coffee', 'cuisine', 'coffee'),
  ('the-magnolia-pancake-haus', 'cuisine', 'breakfast-diner'),
  ('the-brasserie-at-hotel-1928', 'cuisine', 'french')
) AS v(place_slug, facet, tag_slug)
JOIN public.places p ON p.slug = v.place_slug
JOIN public.tags   t ON t.facet = v.facet AND t.slug = v.tag_slug
ON CONFLICT (place_id, tag_id) DO NOTHING;


-- ------------------------------------------------------------------------
-- BLOCK 07 — Validation gates
-- ------------------------------------------------------------------------

DO $GATES$
DECLARE
  v_count integer;
BEGIN
  -- G1: four tiers
  SELECT count(*) INTO v_count FROM public.tiers;
  IF v_count <> 4 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 4 tiers, found %', v_count;
  END IF;

  -- G2: 93 public tags + Hype trap
  SELECT count(*) INTO v_count FROM public.tags;
  IF v_count <> 94 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: expected 94 tags, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count FROM public.tags WHERE admin_only = true;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'GATE G2b FAILED: expected 1 admin-only tag, found %', v_count;
  END IF;

  -- G3: 38 questions, exactly 4 of them review-gated (RN-24)
  SELECT count(*) INTO v_count FROM public.questions;
  IF v_count <> 38 THEN
    RAISE EXCEPTION 'GATE G3 FAILED: expected 38 questions, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count FROM public.questions WHERE requires_review = true;
  IF v_count <> 4 THEN
    RAISE EXCEPTION 'GATE G3b FAILED: expected 4 review-gated questions, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count
  FROM public.questions WHERE input_type = 'text_short' AND requires_review = false;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G3c FAILED: % free-text question(s) would publish unreviewed', v_count;
  END IF;

  -- G4: all 511 places
  SELECT count(*) INTO v_count FROM public.places;
  IF v_count <> 511 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: expected 511 places, found %', v_count;
  END IF;

  -- G5: nothing is visible to the public yet (RN-07)
  SELECT count(*) INTO v_count FROM public.places WHERE status <> 'unreviewed';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G5 FAILED: % place(s) did not land as unreviewed', v_count;
  END IF;

  -- G6: the honours survived the import intact
  SELECT count(*) INTO v_count FROM public.places WHERE starred = true;
  IF v_count <> 22 THEN
    RAISE EXCEPTION 'GATE G6 FAILED: expected 22 starred places, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count FROM public.places WHERE visited = false;
  IF v_count <> 42 THEN
    RAISE EXCEPTION 'GATE G6b FAILED: expected 42 unvisited places, found %', v_count;
  END IF;

  -- G7: tier counts after the 28 conflicts were dropped
  SELECT count(*) INTO v_count FROM public.places WHERE tier IS NOT NULL;
  IF v_count <> 279 THEN
    RAISE EXCEPTION 'GATE G7 FAILED: expected 279 tiered places, found %', v_count;
  END IF;

  -- G8: the 28 conflicts are flagged and reviewable (DP-08)
  SELECT count(*) INTO v_count
  FROM public.places WHERE 'CONFLICT:TIER+UNVISITED' = ANY (source_guides);
  IF v_count <> 28 THEN
    RAISE EXCEPTION 'GATE G8 FAILED: expected 28 flagged conflicts, found %', v_count;
  END IF;

  -- G9: every place kept its Apple id, or the import is no longer idempotent
  SELECT count(*) INTO v_count FROM public.places WHERE apple_id IS NULL;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G9 FAILED: % place(s) without apple_id', v_count;
  END IF;

  -- G10: sixteen cities, en-dash normalised (BL-13)
  SELECT count(DISTINCT city) INTO v_count FROM public.places;
  IF v_count <> 16 THEN
    RAISE EXCEPTION 'GATE G10 FAILED: expected 16 distinct cities, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count FROM public.places WHERE city LIKE '%' || U&'\2013' || '%';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G10b FAILED: % city value(s) still carry an en-dash', v_count;
  END IF;

  -- G11: every suggested assignment resolved, and none of them claims to be
  -- the curator's own work
  SELECT count(*) INTO v_count FROM public.place_tags;
  IF v_count <> 145 THEN
    RAISE EXCEPTION 'GATE G11 FAILED: expected 145 tag assignments, found %', v_count;
  END IF;

  SELECT count(*) INTO v_count FROM public.place_tags WHERE source <> 'suggested';
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G11b FAILED: % assignment(s) are not marked suggested', v_count;
  END IF;

  -- G12: no machine wrote into the judgment layer
  SELECT count(*) INTO v_count
  FROM public.places
  WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL
     OR story IS NOT NULL OR last_visited IS NOT NULL OR price_band IS NOT NULL;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'GATE G12 FAILED: % place(s) arrived with judgment fields set', v_count;
  END IF;

  RAISE NOTICE 'F-01 seed gates passed: 18 of 18';
END $GATES$;

COMMIT;
