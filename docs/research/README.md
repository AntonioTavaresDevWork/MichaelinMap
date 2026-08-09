# `docs/research/` — the cuisine research pass

Working artifacts of an external research pass that fills the RN-32 gap: every food place should
carry at least one filterable `cuisine` tag, and most unreviewed ones carry none.

This directory is **live working state, not reference material**. `docs/files/` is the frozen origin
material from Claude Web; this is a job in progress and it changes between sessions.

## Files

| File | What it is |
|---|---|
| `cuisine-117-batch.csv` | The scope: 117 places that are `restaurant` + `unreviewed` + `city = 'Austin'` with **no** cuisine tag. `id,name,address` |
| `cuisine-117-prompt.md` | The prompt for the research model. Revision 2 |
| `cuisine-117-results.json` | What has come back so far. **ids 001–010** |

## Do not regenerate the CSV

`id` is the join key between the research output and the database, and it is nothing but the row's
position in this file. Re-running the query that produced it after any place gains a cuisine tag
returns a **smaller set with different ids**, which silently re-points every id in
`cuisine-117-results.json` at the wrong restaurant.

The file is frozen for the duration of the pass. It was verified against the database by checksum
when it was cut:

```
117 rows · 241adf8ea2bf6c2b2e147adc94e39757
```

That hash is over `md5(name || ' — ' || address)` per row, whitespace collapsed, aggregated in hash
order. Order by the hash and not by name — Postgres sorts by collation and Python by code point, so
a text ordering produces different hashes from identical data.

## How to resume

1. Paste `cuisine-117-prompt.md` into the research model.
2. Attach the next ten rows of `cuisine-117-batch.csv`, header included.
3. Append the returned JSON to `cuisine-117-results.json`.
4. Validate before trusting it: ids present in the CSV, names matching, every slug in the live
   vocabulary, no slug without evidence.
5. Once a reasonable block has accumulated, write one migration inserting them as
   `place_tags` with `source = 'suggested'`, resolving places and tags by natural key.

Ten per response is deliberate — see the *Pace* section of the prompt.

## Review of ids 001–010 (S11)

Validated: ids and names match the CSV, all seven slugs used exist in the vocabulary.

Three items are **not** ready to migrate as returned:

- **004 Alpine Haus** — returned `no_slug_fits` against the 37-slug vocabulary. `german` now exists
  (`20260809130000`), so this one is taggable. It needs the slug applied, not re-researched.
- **006 Anthem, 009 Bar Toti** — both got `cocktails-bar-food` as a fallback for a crossed kitchen,
  which is a claim about format, not cuisine. Bar Toti calls itself a bistro. Revision 2 of the
  prompt closes this off; both need re-running.
- **008 Aris** — the second evidence row cites `opentable.com/r/iris-austin`, a different business,
  for a bare category string. The first source already establishes both slugs in one sentence
  (*"a modern Mediterranean steakhouse"*); drop the second row rather than re-researching.

Two more to carry forward:

- **005 Andice General Store** — Tier C only, no official site, and the sources place it in
  Andice/Georgetown 78633 while our record says Florence 76527. Worth an address check.
- **007 APT 115** — `new-american` disagrees with MICHELIN's "Fusion", and a 2024 guide claims the
  food menu is gone while the official site contradicts it. Kept, flagged, `medium`.

## What this pass may not do

Nothing here writes to the judgment layer. Everything it produces enters as `source = 'suggested'`,
invisible to a visitor under RN-31, and becomes visible only when the curator confirms it in the
admin. The pipeline proposes; the confirmation is a human act.
