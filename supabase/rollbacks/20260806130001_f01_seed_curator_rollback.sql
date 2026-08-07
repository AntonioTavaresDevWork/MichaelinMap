BEGIN;

-- ========================================================================
-- ROLLBACK — 20260806130000_f01_seed_curator.sql
--
-- Removes the curator from the allowlist. The auth.users account itself is
-- left alone: it was created by hand in the dashboard and deleting it here
-- would be a side effect nobody asked for.
--
-- ⚠️ This makes the whole database read-only. is_curator() returns false for
-- everyone, so no one can edit anything through the admin until a curator is
-- seeded again. Nothing is lost — the judgment layer stays untouched — but the
-- product is inert until then.
-- ========================================================================

DELETE FROM public.curators
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email = 'mikemyday@mikecofone.com'
);

COMMIT;
