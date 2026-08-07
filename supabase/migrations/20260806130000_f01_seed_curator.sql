BEGIN;

-- ========================================================================
-- F-01 — Curator allowlist seed
--
-- Version: 1.0
-- Requires: 20260806120000_f01_schema_rls_rpc.sql
--
-- One row. The guide belongs to Michael; Edu works from the same account
-- (Bíblia §4). Until this row exists, is_curator() is false for everyone and
-- nothing in the database is writable — the schema is inert without it.
--
-- The account itself is created by hand in the Supabase dashboard, with
-- "Auto Confirm User" on. Signup is disabled on the project, so there is no
-- other way in.
-- ========================================================================

-- WHY a subquery on auth.users instead of the literal uuid: a hardcoded id is
-- a latent bug the moment this runs against a rebuilt project. Resolving by
-- email keeps the migration honest about what it depends on.
INSERT INTO public.curators (user_id, name)
SELECT id, 'Michael'
FROM auth.users
WHERE email = 'mikemyday@mikecofone.com'
ON CONFLICT (user_id) DO NOTHING;

DO $GATES$
DECLARE
  v_count integer;
BEGIN
  -- G1: exactly one curator. Zero means the account was missing and the
  -- INSERT silently matched nothing, which would leave the admin unusable.
  SELECT count(*) INTO v_count FROM public.curators;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'GATE G1 FAILED: expected 1 curator, found %', v_count;
  END IF;

  -- G2: the row points at a real, confirmed account. An unconfirmed user
  -- cannot sign in with a password, so the allowlist would be decorative.
  SELECT count(*) INTO v_count
  FROM public.curators c
  JOIN auth.users u ON u.id = c.user_id
  WHERE u.email_confirmed_at IS NOT NULL;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'GATE G2 FAILED: curator account is not confirmed';
  END IF;

  RAISE NOTICE 'F-01 curator gates passed: 2 of 2';
END $GATES$;

COMMIT;
