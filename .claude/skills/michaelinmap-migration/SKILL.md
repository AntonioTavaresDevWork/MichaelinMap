---
name: michaelinmap-migration
description: SQL migration conventions in Michaelin Map. Explicit BEGIN/COMMIT, numbered blocks, WHY comments, inline validation gates, the GRANT block always last, manual sanitizing of schema_migrations after applying through MCP, checksum verification for bulk imports. Use when writing or applying any Supabase migration in the project.
---

# Migration Pattern — Michaelin Map

> Approved local reference: `supabase/migrations/20260806120000_f01_schema_rls_rpc.sql`
> (schema + RLS + RPCs, 12 gates) and `20260806120100_f01_seed_and_import.sql` (seed + import of
> 511 rows, 18 gates). SQL comments in **English** (ADR-02).

## File structure

```
supabase/migrations/YYYYMMDDNNNNNN_<description>.sql

BEGIN;

-- ====================================================================
-- F-<NN> — <Title>
--
-- Version: 1.0
-- Requires: <the previous migration, if any>
-- Backlog items closed here: BL-XX..BL-YY
-- ====================================================================

-- BLOCK 01 — Tables
-- BLOCK 02 — Indexes
-- ...
-- BLOCK NN-1 — Table grants        <- ALWAYS second to last
-- BLOCK NN   — Validation gates    <- ALWAYS last

COMMIT;
```

## Inviolable rules

**Explicit BEGIN/COMMIT.** An atomic migration: a failing gate brings everything down and the
database stays intact. This has already paid for itself — see "The G6 case" below.

**Numbered blocks**, each with a header saying what it does.

**WHY comments, not WHAT.** Syntax is trivial, intent is not:

```sql
-- WHY ON DELETE RESTRICT: dropping a tier row would silently erase the judgment
-- layer on every place carrying it. Deleting a tier in use must fail loudly.
tier text REFERENCES public.tiers(slug) ON UPDATE CASCADE ON DELETE RESTRICT,
```

**No hardcoded UUIDs.** Resolve through a subquery on the natural key:

```sql
INSERT INTO public.curators (user_id, name)
SELECT id, 'Michael' FROM auth.users WHERE email = 'mikemyday@mikecofone.com'
ON CONFLICT (user_id) DO NOTHING;
```

**Idempotency through a natural key.** Every seed uses `ON CONFLICT … DO NOTHING` over a real
UNIQUE. If the table has no natural key, the migration **creates one** — that is why
`questions.prompt` gained a UNIQUE (BL-05).

**A new enum value:** Postgres does not allow using a new enum value in the same transaction as the
`ADD VALUE`. Split into separate migrations. (This project uses CHECK constraints instead of enums —
easier to evolve.)

**SAVEPOINT/ROLLBACK TO is not valid grammar inside `DO $$ … $$`.** An inline smoke test has to be
read-only. To validate a mutation, see "A smoke test that has to roll back" below.

## The GRANT block is always last — a lesson that cost an apply

**Supabase default privileges are applied at the moment an object is created.** A
`REVOKE ALL … FROM anon` placed before a `CREATE VIEW` does not protect that view: it is born
afterwards, inheriting a full GRANT.

That is exactly what failed F-01's first apply. The privilege gate reported
`anon holds 4 write grant(s) in public` — INSERT, UPDATE, DELETE and TRUNCATE on the
`field_report_aggregates` view, created two blocks after the REVOKE. The whole migration rolled
back, the blocks were reordered, and the second attempt passed.

**Rule: create every object first; revoke and grant in the second-to-last block.**

## Inline validation gates

5-20 gates before the COMMIT. A failure raises an EXCEPTION → total rollback → a visible crash.

```sql
DO $GATES$
DECLARE v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM public.places;
  IF v_count <> 511 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: expected 511 places, found %', v_count;
  END IF;
  RAISE NOTICE 'F-01 gates passed: 18 of 18';
END $GATES$;
```

**Gates worth having in any migration touching RLS or grants** — these catch what a visual review
does not:

```sql
-- leftover write privileges for anon
SELECT count(*) INTO v_count FROM information_schema.role_table_grants
WHERE grantee = 'anon' AND table_schema = 'public'
  AND privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE');

-- a table with RLS on and zero policies (locked by accident)
SELECT count(*) INTO v_count FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relrowsecurity = true
  AND NOT EXISTS (SELECT 1 FROM pg_policy p WHERE p.polrelid = c.oid);

-- SECURITY DEFINER without a fixed search_path
SELECT count(*) INTO v_count FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.prosecdef = true
  AND (p.proconfig IS NULL OR NOT EXISTS (
    SELECT 1 FROM unnest(p.proconfig) cfg WHERE cfg LIKE 'search_path=%'));

-- a view reading a table under RLS needs security_invoker
SELECT (c.reloptions @> ARRAY['security_invoker=on']) INTO v_bool
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relname = '<view>';
```

Plus a judgment-integrity gate, in any migration touching `places`:

```sql
SELECT count(*) INTO v_count FROM public.places
WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL OR story IS NOT NULL
   OR last_visited IS NOT NULL OR price_band IS NOT NULL;
-- in an import migration, this has to be 0
```

## Applying through the Supabase MCP server

`mcp__supabase__apply_migration` **rewrites the `version`** with its own timestamp. Manual
sanitizing afterwards is mandatory:

```sql
DELETE FROM supabase_migrations.schema_migrations WHERE version = '<REWRITTEN_TIMESTAMP>';
INSERT INTO supabase_migrations.schema_migrations (version, name, statements)
VALUES ('<TIMESTAMP_FROM_THE_FILENAME>', '<name_without_extension>',
        ARRAY['-- see supabase/migrations/<file>.sql']);
```

Validate afterwards: the new entry exists, the divergent one is gone, and `version` falls
chronologically between its predecessor and successor.

**Who applies: always the orchestrator (CLI#1).** The executor writes, never applies.

### Payload limit

`apply_migration` **will not swallow a large file** — 155 kB (511 INSERT rows) did not go through.
Options, in order of preference:

1. Split into smaller migrations, if the content allows it
2. The dashboard SQL Editor: paste the whole file, BEGIN/COMMIT works natively
3. `execute_sql` in blocks, with the complete file versioned in the repo as the real artifact and
   `schema_migrations` filled in by hand

**If you use option 2 or 3 for a bulk load, checksum verification against the source is mandatory.**
Transcription in blocks corrupts silently — a swapped address raises no error at all.

```sql
-- in the database: hash per row, aggregated in hash order (collation-independent)
WITH r AS (SELECT md5(col1||'|'||coalesce(col2,'')||'|'||…) AS h FROM public.<table>)
SELECT md5(string_agg(h, '' ORDER BY h)) FROM r;
```

The same computation runs in a local script over the source and the two md5s have to match. Details:

- **Order by the hash, not by a text key.** `ORDER BY` in Postgres uses the database's collation;
  JS `sort()` uses code points. Different orders → different hashes with identical data
- **`numeric(p,s)::text` always brings `s` decimal places.** In the script, `Number(v).toFixed(s)`
- If there is a divergence, compare **by group of fields** to localize it before suspecting the data.
  In F-01 the first divergence was a bug in the verification script, not in the database

## A smoke test that has to roll back

The MCP's `execute_sql` returns **only the result of the last statement**. For a smoke test that
mutates and needs to roll back, a `DO` block ending in `RAISE EXCEPTION` with the results in the
message solves both problems at once: it returns everything and it reverts.

```sql
DO $SMOKE$
DECLARE r1 jsonb; r2 jsonb;
BEGIN
  UPDATE public.places SET status = 'published' WHERE slug = '<x>';
  PERFORM set_config('role', 'anon', true);
  r1 := public.rpc_submit_field_report(…);
  PERFORM set_config('role', 'postgres', true);
  RAISE EXCEPTION E'SMOKE (rolled back)\nr1 -> %\nr2 -> %', r1, r2;
END $SMOKE$;
```

The error that comes back **is** the report, and nothing persists.

## Rollback

Every migration has a file in `supabase/rollbacks/` (**not** in `migrations/`, or `supabase db push`
will apply it). Name: `<timestamp+1>_<description>_rollback.sql`.

A rollback of data that may have been curated carries a warning and a verification query at the top:

```sql
-- ⚠️ Only safe before the curator has worked. Check first:
--   SELECT count(*) FROM place_tags WHERE source = 'curator';
--   SELECT count(*) FROM places WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL;
DELETE FROM public.place_tags WHERE source = 'suggested';   -- machine guesses only
```

## Before writing any SQL

**Live schema first.** `list_tables` + `list_migrations` through MCP. Convention is not a substitute
for introspection — an "obvious" column may not exist. This project uses `status`, not `deleted_at`
(ADR-03), and has no `company_id` (ADR-01).
