# Michaelin Map — Init

## Boot checklist

> Read as part of the boot triggered by `/orquestrador` (or `/executor`).
> This is not Claude Code's built-in `/init`.

Execute in this order:

1. `.claude/CLAUDE.md` — rules, stack, conventions and language
2. `docs/MICHAELINMAP_BIBLIA.md` — domain, judgment model, schema, business rules, ADRs, scope
3. `docs/STATUS.md` — current state, next action, session log
4. `docs/BACKLOG.md` — pending items, scope cuts, open decisions
5. `src/types/index.ts` — types (from F-00 onward)
6. Database state through MCP (`list_tables`, `list_migrations`) — the bible describes the target, MCP shows the real thing

After reading, answer with:

- **Current phase** and the feature in focus
- **Database state** (live tables and migrations) and any divergence from the bible
- **Next action**, exactly as the STATUS records it
- **Blockers** and BACKLOG items touching the feature in focus

## Golden rule

Never start writing code without confirming the next action with Edu.
If the STATUS diverges from the real state of the code or the database, report it **before** acting.

## Before proposing something outside the scope

Consult the ADRs (bible §15) and the BACKLOG's "Out of the MVP" section. Several paths have already been
evaluated and cut with a reason — Google Places, My Maps sync, SEO, Trip Builder, multi-tenancy.
Do not repropose without a new fact.

## At the end of every session

Update `docs/STATUS.md`: date, what was done, decisions, the new next action, the hash of the last commit.
Anything newly pending goes to `docs/BACKLOG.md` — never scatter pending items through the STATUS.
