---
name: michaelinmap-rls-policy
description: RLS policy patterns in Michaelin Map. The curator allowlist model through is_curator(), with no multi-tenancy and no capabilities. Mandatory verification with simulated JWTs in both directions. Use when writing, reviewing or refactoring Row Level Security policies on any table in the project.
---

# RLS Policy Pattern — Michaelin Map

> The examples are the **real** policies applied in `20260806120000_f01_schema_rls_rpc.sql`.
> Validate against the live database through MCP before writing a new policy.

## Authorization model: curator allowlist

**Not tenant-scoped and not capability-RBAC** (ADR-01). There is no `company_id`, no
`has_capacidade()`, no `is_superadmin()`. There is one guide, one curator and anonymous visitors.

The write predicate is always the same:

```sql
CREATE POLICY <table>_curator_all ON public.<table>
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());
```

Public reading varies per table, and that is the part that demands thought.

```sql
CREATE POLICY <table>_public_select ON public.<table>
  FOR SELECT TO anon, authenticated
  USING (<publication predicate>);
```

## `is_curator()` — why it is SECURITY DEFINER

```sql
CREATE OR REPLACE FUNCTION public.is_curator()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (SELECT 1 FROM public.curators WHERE user_id = auth.uid());
$$;
```

`curators` has no public SELECT policy. A `SECURITY INVOKER` function reading that table from inside
a policy would see **zero rows, always** — and everyone would be denied. Definer rights bypass RLS
for that single query, which is exactly the purpose.

`SET search_path` is mandatory: without it, a malicious schema on the caller's `search_path` can
hijack the function.

## Public reading map (bible §11)

| Table | Public SELECT | Note |
|---|---|---|
| `places` | `status = 'published'` | RN-07 — nothing is born visible |
| `tiers` | `active = true` | |
| `tags` | `active = true AND admin_only = false` | RN-14 — `Hype trap` disappears from the public |
| `place_tags` | double `EXISTS`: published place **AND** active non-admin tag | it used to leak the id of an unpublished place |
| `codes` | **none** | RN-20 — only through `rpc_redeem_code()` |
| `questions` | `active = true` | |
| `field_reports` | `status = 'published'` | INSERT only through the RPC |
| `curators` | **none** | who is on the allowlist is not public data |

The `place_tags` case deserves attention — it is the pattern for every junction table:

```sql
USING (
  EXISTS (SELECT 1 FROM public.places p
          WHERE p.id = place_tags.place_id AND p.status = 'published')
  AND EXISTS (SELECT 1 FROM public.tags t
              WHERE t.id = place_tags.tag_id
                AND t.active = true AND t.admin_only = false)
)
```

A `USING (true)` on a junction table leaks the **existence** of the rows on both sides, even when the
parent tables are protected.

## Table grants are the second lock

RLS is the real gate, but Supabase grants broad access to `anon` by default. Narrow it:

```sql
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
GRANT SELECT ON public.places, public.tiers, … TO anon;
```

⚠️ **This block has to be the last one in the migration.** Default privileges are applied at the
moment an object is created — revoking before creating the view leaves the view fully exposed. That
is how F-01's first apply failed. Details in the `michaelinmap-migration` skill.

## Mandatory verification — simulated JWT, in BOTH directions

Do not accept a policy without this test. Visual inspection does not catch an authorization hole; it
was by testing the negative side that `BL-03` was proven closed.

```sql
BEGIN;
-- positive side: the curator
SELECT set_config('request.jwt.claims',
  json_build_object('sub', (SELECT id FROM auth.users WHERE email = '<curator>'),
                    'role','authenticated')::text, true);
SET LOCAL ROLE authenticated;
SELECT public.is_curator(), (SELECT count(*) FROM public.places);
ROLLBACK;

BEGIN;
-- negative side: authenticated but OUTSIDE the allowlist
SELECT set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
SET LOCAL ROLE authenticated;
SELECT public.is_curator(), (SELECT count(*) FROM public.places);
WITH t AS (UPDATE public.places SET website = 'x' WHERE slug = '<some slug>' RETURNING 1)
SELECT count(*) AS rows_written FROM t;   -- must be 0
ROLLBACK;

BEGIN;
-- anonymous side
SET LOCAL ROLE anon;
SELECT (SELECT count(*) FROM public.places), (SELECT count(*) FROM public.tags);
ROLLBACK;
```

Expected result as of F-01: the curator sees 511 places and writes; authenticated-outside-the-list
and anon see 0 places, 93 tags (not 94) and write 0 rows.

> **Always write to a column outside the judgment layer** in the test (`website` works fine).
> Never use `tier`, `starred`, `the_dish`, `curator_note`, `story` or `last_visited`, even inside a
> rolled-back transaction.

## Inviolable rules

- RLS enabled on **every** table. An inline gate that fails if any table has RLS on and zero policies
- Writing goes through `is_curator()`. **Never** `auth.role() = 'authenticated'` — with signup open, that grants full write access to a stranger (it was the original schema's hole)
- `codes` never gets a public SELECT (RN-20). `field_reports` never gets an INSERT policy (RN-23)
- Every `SECURITY DEFINER` function has `SET search_path`
- GRANT/REVOKE only in a migration, never through the dashboard
- Anonymous **write** access only through a `SECURITY DEFINER` RPC, with the status derived on the server
- Views reading a table under RLS: `WITH (security_invoker = on)`, otherwise the view bypasses RLS

## References

- The real policies: `supabase/migrations/20260806120000_f01_schema_rls_rpc.sql` BLOCK 05
- Grants: same file, BLOCK 07 · Authorization gates: BLOCK 09 (G2 through G7)
- The declared model: bible §11
