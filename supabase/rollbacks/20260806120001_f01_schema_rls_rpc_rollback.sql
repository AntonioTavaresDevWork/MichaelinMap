BEGIN;

-- ========================================================================
-- ROLLBACK — 20260806120000_f01_schema_rls_rpc.sql
--
-- Drops the entire F-01 database surface. Everything the curator has typed
-- lives in these tables, so this is only safe while the schema is still empty
-- or the data is disposable.
--
-- Run 20260806120101_f01_seed_and_import_rollback.sql first if you only want
-- the data gone.
-- ========================================================================

DROP VIEW IF EXISTS public.field_report_aggregates;

DROP FUNCTION IF EXISTS public.rpc_submit_field_report(uuid, uuid, jsonb, text, text);
DROP FUNCTION IF EXISTS public.rpc_redeem_code(text);

DROP TRIGGER IF EXISTS places_touch_updated_at ON public.places;

-- Order matters: dependants before their references.
DROP TABLE IF EXISTS public.field_reports;
DROP TABLE IF EXISTS public.questions;
DROP TABLE IF EXISTS public.codes;
DROP TABLE IF EXISTS public.place_tags;
DROP TABLE IF EXISTS public.tags;
DROP TABLE IF EXISTS public.places;
DROP TABLE IF EXISTS public.tiers;
DROP TABLE IF EXISTS public.curators;

-- is_curator() is dropped after the policies that call it are gone with their tables.
DROP FUNCTION IF EXISTS public.is_curator();
DROP FUNCTION IF EXISTS public.touch_updated_at();

COMMIT;
