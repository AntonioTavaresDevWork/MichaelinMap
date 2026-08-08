---
name: michaelinmap-spec-format
description: NOT USED in Michaelin Map — ADR-04 dispenses with per-feature specs; the PRD in docs/files/ fills that role. Kept only as a reference to the Wise* template in case the project ever reverses that. Do not invoke it to write a spec in this project.
---

> # ⚠️ This skill does not apply to Michaelin Map
>
> **ADR-04 (bible §15) dispenses with per-feature specs in this project.** There is no `docs/specs/`,
> there is no agent pipeline, and the original PRD in `docs/files/` fills the role of a spec. The
> bible is the source of truth; new decisions go there, pending items go to `docs/BACKLOG.md`.
>
> The content below is the original Wise* template, **preserved only as a reference** in case the
> project ever grows enough to justify a formal spec. It describes WiseFacilities objects that **do
> not exist here** (`audit_log`, `capacidades`, multi-tenancy). Do not follow it.
>
> Two housekeeping notes from S09: the body below was full of mojibake (`LocalizaÃ§Ã£o`,
> `EntregÃ¡veis`) inherited from the template's original encoding, repaired while translating; and
> the references to sibling skills used the old `wise-*` names, corrected to `michaelinmap-*`.

# Technical Spec Format — Wise* (a template not applied in this project)

## Location

`docs/specs/F-<NUMBER>-<slug>-spec.md`

## Spec deliverables

> The deliverables marked **[Model B]** only apply to projects built on a Capability-RBAC substrate.
> In a **Model A (tenant-scoped)** project, declare them "N/A in this project" and do not force
> content. The rest are universal. (The model is declared in the bible — see the
> `michaelinmap-rls-policy` skill.)

Every technical feature spec delivers:

1. **Schema** — new tables, changes to existing ones (ADD COLUMN, FK, indexes)
2. **Seed** — initial data (configs, reference data; roles/capabilities if Model B)
3. **Changes to the audit table** — new columns with a DEFAULT where applicable (the audit table's schema is whatever the bible declares — the standard `audit_log` or another)
4. **[Model B] Capability catalog** — capabilities NOW plus forward-looking ones if the feature anticipates a future F-XX
5. **[Model B] Role × capability matrix** — which roles gain which capabilities
6. **Authorization functions** — new SQL functions or changes ([Model B]: `has_capacidade` and the like; [Model A]: tenant/scope helpers)
7. **Refactoring of existing functions** — `is_superadmin`, session/tenant helpers, and so on
8. **Policies (DROP + CREATE)** — every affected RLS policy, with the canonical snippet at the top plus explicit exceptions
9. **SECURITY DEFINER RPCs** — all of them with auditing (in the declared table), validations, REVOKE/GRANT
10. **Absorbed behavior changes (MC-NN)** — when the feature corrects a previous interpretation (referencing bible §X.Y)
11. **A phased migration plan** — Phase 1 (refactor while preserving coexistence) + Phase N (cleanup, dropping legacy)
12. **Smoke tests** — ST-01 through ST-NN, executable through the UI or SQL, each with an acceptance criterion

## Header structure

```markdown
# F-<NUMBER> — <Title> — Technical Spec

| Field | Value |
|---|---|
| Status | Draft / Approved / Applying / In production |
| Version | 1.0 |
| Investigation | docs/specs/F-<NUMBER>-investigation.md |
| Architectural decision | ADR-XXX if there is one |
| Approved by | Edu, <date> |
| Applied on | <date or pending> |

## Executive summary
<3-5 lines: what the feature does, why it exists, its scope>

## §1 — Schema
...

## §2 — Seed
...

(follow all 12 sections)
```

## Rules

- **Investigation before spec.** Every spec is preceded by `F-<NUMBER>-investigation.md` (current state, gaps, risks). Without an investigation, a spec is guesswork.
- **Numbered smoke tests.** ST-01, ST-02, and so on. Each one: actor + action + expected result. Independent (they do not depend on order).
- **Behavior changes made explicit.** If the spec corrects a policy or RPC that today works one way and will work another, record it in §10 with a justification. Without that, it becomes "an unauthorized silent change".
- **Blocking DPs resolved.** A spec is only born once every DP marked BLOCKING in the investigation has been answered by Edu.

## Pre-handoff to the Data Architect

A spec only enters the pipeline after Edu approves it (through the orchestrator). Approval verifies:

- Every applicable deliverable is present (the ones marked [Model B] are "N/A" in a Model A project)
- The canonical RLS snippet has been checked (the `michaelinmap-rls-policy` skill)
- The RPCs follow the pattern (the `michaelinmap-rpc` skill)
- The migration plan respects the coexistence strategy (the `michaelinmap-migration` skill)

## References

- Canonical example of origin: WiseFacilities `docs/specs/F-RBAC-v2-spec.md` (14 sections, all 12 mandatory ones covered) + `F-RBAC-v2-investigation.md`.
- In a new project: point here to the first approved spec as the local reference.
