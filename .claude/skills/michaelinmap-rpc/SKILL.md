---
name: michaelinmap-rpc
description: The SECURITY DEFINER RPC pattern in Michaelin Map. Mandatory SET search_path, server-side validation, jsonb {ok,…} return, GRANT to anon when the RPC is the public path declared in bible §11. Use when creating or modifying RPC functions called by the frontend through supabase-js.
---

# RPC Pattern — Michaelin Map

> The examples are the project's two **real** RPCs, in
> `supabase/migrations/20260806120000_f01_schema_rls_rpc.sql` BLOCK 08.

## What this project does NOT have

Before copying a pattern from another Wise* project: here there is **no** `audit_log`, no
`company_id`, no `has_capacidade()`, no `is_superadmin()` and no `perfis`. Auditing is
`places.updated_by` + `updated_at`, and with a single curator account `updated_by` does not even
identify a person (bible §4). Do not invent those tables.

## When an RPC is justified

Only when RLS **cannot handle it alone**. In this project there are exactly two cases, both because
the anonymous visitor needs a capability a policy cannot express safely:

| RPC | Why it cannot be a policy |
|---|---|
| `rpc_redeem_code(p_code)` | The public cannot have SELECT on `codes` (RN-20). A `code = <input>` policy would still expose the table; the RPC answers about **one** code at a time |
| `rpc_submit_field_report(…)` | The answer's status is **derived on the server** from `questions.requires_review` (RN-23). An INSERT policy would let the visitor choose `published` |

If the operation fits in a policy, **do not write an RPC**.

## Anatomy

```sql
CREATE OR REPLACE FUNCTION public.rpc_<verb>_<entity>(p_x <type>)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp      -- mandatory
AS $$
DECLARE
  v_row public.<table>%ROWTYPE;
BEGIN
  -- 1. Validate the shape of the input before any read
  IF p_x IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_input');
  END IF;

  -- 2. Validate state on the server — never trust what came from the client
  -- 3. Derive whatever the caller is not allowed to choose
  -- 4. Execute
  -- 5. Return

  RETURN jsonb_build_object('ok', true, 'status', v_status);
END;
$$;

REVOKE ALL ON FUNCTION public.rpc_<verb>_<entity>(<signature>) FROM public;
GRANT EXECUTE ON FUNCTION public.rpc_<verb>_<entity>(<signature>) TO anon, authenticated;
```

## Granting to `anon` is the norm here — not the mistake

The Wise* template says to revoke from `anon` and add a gate that fails if `anon` can execute.
**In this project that is inverted:** the two RPCs are the public path declared in bible §11 and
they **need** the GRANT to `anon`. The security comes from the validation inside the function, not
from a missing GRANT.

The correct gate here is the opposite — confirm that the public RPCs are still executable:

```sql
SELECT count(*) INTO v_count
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN ('rpc_redeem_code','rpc_submit_field_report')
  AND has_function_privilege('anon', p.oid, 'EXECUTE');
IF v_count <> 2 THEN
  RAISE EXCEPTION 'GATE FAILED: % of 2 RPCs executable by anon', v_count;
END IF;
```

`REVOKE ALL … FROM public` followed by `GRANT … TO anon, authenticated` is the form: it makes the
grant explicit instead of inherited.

## Standardized return

`{"ok": true, …}` / `{"ok": false, "error": "<code>"}`. Always jsonb, even for a trivial operation —
it allows evolving without breaking the contract with the frontend.

**Error codes in English, snake_case**, because the UI is in English (ADR-02):
`invalid_answer`, `place_not_available`, `question_not_available`, `rate_limited`,
`already_answered`. The frontend turns them into copy with `mapRpcError()` in `src/lib/utils.ts`.

Prefer a **return value** over `RAISE EXCEPTION` for an expected business failure: an exception
becomes an HTTP error in supabase-js and forces the frontend to distinguish a network failure from
"that code does not exist". Reserve `RAISE EXCEPTION` for what is genuinely exceptional.

## Do not leak information through the shape of the response

`rpc_redeem_code` returns **exactly** `{"ok": false}` on every failure path — nonexistent code,
inactive, outside the date window, empty input. Any difference between those cases turns the
function into an oracle and hands back the enumeration that removing the public SELECT prevented
(RN-20).

```sql
IF NOT FOUND THEN
  RETURN jsonb_build_object('ok', false);   -- no 'error', no detail
END IF;
```

By contrast: `rpc_submit_field_report` **may** detail the error, because there is no secret to
protect there — the visitor needs to know whether they already answered or hit the rate limit.

## Derive on the server whatever the caller cannot choose

```sql
v_status := CASE WHEN v_question.requires_review THEN 'pending' ELSE 'published' END;
```

The visitor sends the answer, never the status (RN-23). Same logic for truncation: free text is cut
at 40 characters **inside the function**, not trusted to the client (RN-24).

```sql
v_answer := jsonb_set(p_answer, '{value}', to_jsonb(left(btrim(p_answer->>'value'), 40)));
```

## Rate limiting by `session_hash`

`session_hash` exists only to limit, never to identify. Two controls:

- a ceiling per window: 30 answers per hour
- one answer per `(session_hash, place_id, question_id)` — without it a bored visitor skews an
  aggregate single-handedly, and the aggregate is the feature (RN-25)

It is bypassable with a new session, and that is fine: the goal is friction, not identity.

## Inviolable rules

- `SET search_path = public, pg_temp` in every `SECURITY DEFINER` function
- Validate state on the server before any side effect
- Naming `rpc_<verb>_<entity>`
- Business failure → return `{"ok": false, …}`; exceptions only for the exceptional
- A **uniform** failure response whenever distinguishing cases would leak information
- A field the caller cannot choose is derived on the server, always
- Never write to the judgment layer (`tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited`, assignments in `place_tags`) without Edu's explicit authorization

## References

- The real RPCs: `20260806120000_f01_schema_rls_rpc.sql` BLOCK 08
- Smoke test of both RPCs, including truncation and duplicates: the S04 log in `docs/STATUS.md`
