# Michaelin Map — STATUS

> Updated at the end of every development session.
> Read at boot, alongside `.claude/CLAUDE.md`, `docs/MICHAELINMAP_BIBLE.md` and `docs/BACKLOG.md`.

---

## 🗓️ Last update

**Date:** 2026-08-09
**Session:** S12 — a pesquisa dos 117 fechada, dez restaurantes fechados, e o erro que o próprio método não pegou
**Version:** `0.1.0` — unchanged. The session produced no product code, schema or feature; docs and research artifacts only
**Updated by:** Claude Code (orchestrator)
**Last commit:** `0aa2402`, the session's substantive one, followed by a one-line commit recording
this hash. **Pushed to `origin/main` at the close of S12**, along with S11's close (`4b207dd`), which
had been sitting local since the previous session. `main` and `origin/main` are level.

---

## 📍 Current phase

**All seven MVP features are closed**, and S10 added the first work after them: a full frontend
redesign and one admin sub-feature. No new product feature is planned.

**The critical path is still human, and in S11 a human walked one step of it.** Of 226 tag
assignments, **5 are now the curator's** — `Breakfast & Diner`, confirmed by Edu across five places
in one click — and the cuisine facet renders publicly for the first time. `place_tags` had carried
zero curator rows since S04, and that zero was the fact every prior session cited as the definition
of the bottleneck. It is gone.

What remains unchanged is the harder half: **none of the 58 published places has `the_dish` or
`curator_note`.** The guide shows verdicts and no voice, and those sentences are Michael's alone.
The 221 tags still pending are ~20 coherent batches thanks to S10's filter, and Edu has taken
`cuisine` specifically — verifying a researched fact is not the same act as tagging in Michael's
place.

**The handover track from S09 continues.** Both the deploy and the database are expected to move to
a company organization; `README.md` documents what travels and what does not.

**`BL-31` shrank in S11.** Edu logged in and worked six admin screens, including the tag filter and
the bulk-confirm bar, end to end. What is still unseen is `/admin/codes`, open since F-05 — and it
is the likely explanation for a divergence recorded below: the `DEMO` code is gone from the database
and no session recorded deleting it.

**S12 finished the research pass and changed what the queue in front of Michael looks like.** All 117
unreviewed Austin restaurants are researched: **91 taggable, 15 with no honest slug, 10 closed, 1
uncertain.** None of it is in the database — the Supabase MCP did not load in S12, so no SQL was
written, by the project's own first rule.

**The finding that outranks the tags: 10 of 117 places are closed and 1 more cannot be established.**
Four closed during 2026 and three of those were Michelin-distinguished, including one that closed
*holding a star*. That is ~9% of a backlog assembled from map albums over years, and it is the
evidence `DP-10` was missing — the same sweep over the **58 published** places is now the highest-value
thing anyone could do to the guide, because those are the ones a visitor can reach.

---

## ✅ Completed

### Session 01 — Scaffold
- [x] GitHub repository created (`AdminFeedpro/MichaelinMap`)
- [x] Supabase project created (`woapimgpmlgqqvauckdy`) — **empty**
- [x] Supabase MCP configured
- [x] `.claude/` structure (CLAUDE.md, init.md, 5 agents, 5 skills)
- [x] `docs/prompts/` (orchestrator + executor)

### Session 02 — Scope and documentary foundation
- [x] Claude Web material analyzed: PRD v1.0, the product's CLAUDE.md, PLAN.md, schema.sql, seed.sql, import-places.ts, master CSV
- [x] CSV validated line by line against the PRD's numbers — all match (511 places, 273 restaurants, 91 bars, 22 stars, 42 unvisited, 28 conflicts, 19 guides, 0 duplicate Apple IDs, 0 missing coordinates)
- [x] Schema audit — 7 findings, 3 of high severity (`BL-01` through `BL-07` in the BACKLOG)
- [x] Scope reassessment: overengineering cuts agreed with Edu
- [x] 5 pending decisions resolved (DP-01 through DP-05)
- [x] 8 ADRs recorded
- [x] `docs/MICHAELINMAP_BIBLE.md` v2.0 written
- [x] `docs/BACKLOG.md` populated (20 items)
- [x] `docs/STATUS.md` corrected — the previous version claimed "setup complete" with an empty database
- [x] Skills renamed `wise-*` → `michaelinmap-*`; BOM removed from the frontmatter (it prevented the parser from reading the descriptions)

### F-00 — Foundation ✅
- [x] Vite 8 + React 19 + TypeScript 6 + Tailwind 4 + shadcn/ui (radix-nova preset)
- [x] 7 dependencies installed: `@supabase/supabase-js`, `@tanstack/react-query`, `react-router-dom`, `zustand`, `sonner`, `lucide-react`, `maplibre-gl`
- [x] 9 shadcn components: button, input, label, card, sonner, separator, skeleton, badge, dropdown-menu
- [x] `src/lib/supabase/client.ts` — singleton that validates env at import
- [x] `src/lib/utils.ts` — `cn()`, `mapRpcError()`, **en-US** formatters, `monthsSince()`, `slugify()` aligned with the import script
- [x] `src/types/index.ts` — 8 interfaces in snake_case mirroring the target schema
- [x] `useSession()` + `ProtectedRoute` for `/admin`
- [x] Public and admin layouts; working login; placeholders on the routes still to come
- [x] `noindex, nofollow` in `index.html` (ADR-07)
- [x] `.env.example` + `.env.local` (publishable key; gitignored)
- [x] **Gate:** `npm run build` and `npm run lint` clean · dev server starts and answers 200 on `/` and `/admin/login`

### Session 03 — Unblocking the environment ✅
- [x] `mcp.json` → `.mcp.json` — the name Claude Code reads and the one `.gitignore` already covered
- [x] `env.local.download` → `.env.local` — the file existed with the name broken by the download
- [x] `git init` + initial commit `b6fef0c` on `main` (68 files)
- [x] Secret sweep of the index: clean. `.mcp.json`, `.env.local` and `.claude/settings.local.json` confirmed ignored
- [x] Node.js 24.19.0 / npm 11.17.0 installed · `npm install` (459 packages)
- [x] **Gate re-run on this machine:** `npm run build` and `npm run lint` clean
- [x] Supabase token validated: project `ACTIVE_HEALTHY`, PostgreSQL 17.6.1, region us-west-2
- [x] Folder path corrected in bible §3 and in `.claude/CLAUDE.md`
- [x] Duplicate `env.example` removed (`BL-24` closed) — `.env.example` is the only canonical one

### F-01 — Schema + data ✅
- [x] `20260806120000_f01_schema_rls_rpc.sql` — 8 tables, 3 judgment constraints, 8 indexes, `updated_at` trigger, `is_curator()`, 14 policies, the `field_report_aggregates` view with `security_invoker`, 2 RPCs. **12 inline gates passed**
- [x] `20260806120100_f01_seed_and_import.sql` — 4 tiers, 94 tags, 38 questions, the `DEMO` code, 511 places, 145 suggested tags. **18 gates passed**
- [x] `BL-01` through `BL-08`, `BL-12` and `BL-13` closed
- [x] Import verified by **checksum against the CSV**: name, slug, type, tier, star, visited, country, city, area, coordinates, address and `source_guides` — the 511 records in the database are identical to the ones generated from the source
- [x] Security smoke test with `SET ROLE anon`: sees 0 places, 93 tags (`Hype trap` hidden), 0 `place_tags`, zero access to `codes` and `curators`
- [x] Functional smoke test of the RPCs: valid/lowercase/nonexistent code, numeric field report → `published`, free text → `pending` truncated at 40 chars, duplicate blocked, answer without `value` rejected
- [x] `20260806130000_f01_seed_curator.sql` — the `Michael` row in `curators`, resolved by a subquery on `auth.users` (no hardcoded UUID). 2 gates
- [x] **Authorization verified end to end with simulated JWTs.** Curator: sees all 511 places, the 94 tags, `codes` and `curators`, and writes. An authenticated account **outside** the allowlist: 0 places, 93 tags, 0 codes, 0 curators, `UPDATE` affects 0 rows. This is exactly the case the original model (`auth.role() = 'authenticated'`) got wrong — `BL-03` closed with evidence
- [x] `schema_migrations` sanitized — versions realigned with the file names
- [x] **Gate:** `npm run build` and `npm run lint` clean

### F-02 — Admin ✅ (S05)

- [x] Place list with a filter bar (`places.tsx`, `place-filter-bar.tsx`, `place-filters.ts`)
- [x] Complete place editor (`place-editor.tsx`) + rules for promotion to `published` (`publish-rules.ts`)
- [x] Tag assignment with a visual distinction between `suggested` and `curator` — RN-15 (`tag-picker.tsx`)
- [x] Overview instead of a dashboard: tier distribution, curation progress, queues and stale entries
- [x] Mobile quick-add with Nominatim geocoding, no key — ADR-06 (`quick-add.tsx`, `use-geocode.ts`)
- [x] Hooks `use-places`, `use-tags`, `use-tiers`
- [x] 6 shadcn components added: checkbox, dialog, select, switch, tabs, textarea
- [x] **Dedicated review-queue screen cut** — the three queues became cards on the Overview that
      link to the list with the filter applied. A screen of its own would be a fourth way of looking
      at the same records, with two places to keep in sync

### F-03 — Public ⚠️ (S05) — delivered, with the map mute for environmental reasons

- [x] City gate with cities as pairs and counts (DP-02); authored empty state
- [x] City guide separating "Eat & drink" from "Everything else" (§7); order star → tier → name;
      `the_dish` leads the row when it exists
- [x] Place detail leading with the verdict, never with the address; directions in a button
- [x] `use-public-guide.ts` — public reading through the anon key
- [x] MapLibre map synchronized with the list in both directions, **one single shared selection**;
      pin color encodes judgment (amber+star, dark for destination/experience, light for the rest)
- [x] OpenFreeMap tiles — free, keyless, the same logic as ADR-06
- [x] Map in `lazy` + `Suspense` (`BL-25`): main bundle 699 kB (204 kB gzip), map chunk loaded
      only when a city opens
- [x] Public path verified end to end with the anon key: 58 published, 93 tags (`Hype trap`
      absent — RN-14), `codes` denying with 42501 (RN-20)
- [x] Genuinely fixed along the way: framing only runs after `load` and with a sized container —
      `fitBounds` against zero width produced a degenerate zoom
- [ ] ⚠️ **The map draws no geometry on this machine** — `BL-29`. It is not our code; see Blockers

### Session 06 — Documentary reconciliation
- [x] `docs/STATUS.md` and `docs/MICHAELINMAP_BIBLE.md` aligned with the real state (F-02 and F-03 on `main`)
- [x] `schema_migrations` re-checked through MCP: **3** live migrations, not 2 as this file claimed
- [x] **Gate re-run:** `npm run build` and `npm run lint` clean

### F-04 — Faceted filters ✅ (S06)

- [x] `src/lib/guide-filters.ts` — a single filter object, **OR within a facet and AND between facets** (RN-16),
      live counts computed against the *other* active facets, serialization into the URL (RN-19)
- [x] `src/components/public/guide-filter-panel.tsx` — a zeroed option is **disabled, not hidden** (RN-17);
      collapsible on the phone, always open on the desktop
- [x] The filter feeds list and map from the same state; the map reframes itself when filtering
- [x] A selection that falls out of the results is cleared, so the map does not highlight a pin with no row beside it
- [x] Area only in cities above the density floor (RN-18)
- [x] **Design decision:** a facet with no populated option at all is not rendered. It does not contradict
      RN-17, which governs the *option* inside a facet — it is §8's principle ("degrade silently instead of
      rendering an empty control") applied to the remaining facets. Today six of the seven tag facets are
      empty (`BL-30`); they appear on their own as Michael tags, with no deploy
- [x] Authored empty state for the impossible combination (`BL-18` closed)
- [x] **Verified by a throwaway harness: 27 checks against the live database through the anonymous path**, which
      tests RLS and filtering together. Covers OR/AND, live counts, a zeroed option being disabled, a
      selected option that zeroed out staying clickable, the URL round trip, the area density floor and
      RN-14's defense in depth
- [x] **Gate:** `npm run build` and `npm run lint` clean. Main bundle 699 → 707 kB

### F-05 — Codes + Roulette ✅ (S07)

- [x] **No migration.** F-01 had already delivered `codes` with the six effect fields and
      `rpc_redeem_code()` with `anon` authorized. A 100% frontend feature, zero new npm dependencies,
      zero new shadcn components
- [x] `src/lib/code-effects.ts` — theming through CSS custom properties (every shadcn component in the
      app reads those tokens, so a code repaints the interface without touching a single component);
      `contrastOn()` derives legible text from WCAG luminance; a dark background turns on the `dark`
      class; a map style token → URL, with a fallback for an unknown value
- [x] `src/lib/roulette.ts` — weighted draw (star 6, `destination`/`experience` 3, `cool` 2,
      `fair` 1), over the **filtered** result, with an injectable `random` and a "spin again" that does
      not repeat
- [x] `src/lib/code-context.ts` + `code-provider.tsx` — the code is remembered in `localStorage` but
      **revalidated on the server on every load** (RN-28); `?code=` accepted and removed from the URL on arrival
- [x] `code-entry.tsx` — keyboard listening with no visible field on the desktop, a dialog through a
      long-press on the logo on mobile (PRD §9.7). Silent failure while listening: whoever asked nothing gets no error
- [x] `code-banner.tsx` — a band with the message and the way out; it applies and **removes** the theme,
      mounted in the public layout so the admin never wears a visitor's code
- [x] `guide-map.tsx` — `setStyle` at runtime (the markers are DOM and survive the swap), pins
      repainted by the code, a ring on the highlighted ones without erasing the tier color
- [x] `guide.tsx` — the preset seeds the panel once and never overwrites the URL (RN-27); highlighted
      places rise in the order with a "Picked for you" badge; Roulette next to the count
- [x] `/admin/codes` in place of the placeholder — list, editor with color, map style, pin, date
      window, and the `preset_filter` built **by the visitor's own panel**
- [x] **Verified in the browser** (the Chrome extension connected, unlike S06): a code typed into the
      air → the URL became `?tier=destination&star=1` on its own, the guide darkened, the banner
      appeared, the amber badge entered the row, pins became squares with rings, zeroed options went
      gray and stayed clickable. "Back to normal" undid everything. The style swap confirmed over the
      network: `/styles/liberty` on load, `/styles/dark` at the moment of redemption
- [x] **60 checks in a throwaway harness**, the pure ones and the real anonymous path: a valid code,
      lowercase, with whitespace, nonexistent, empty, switched off, not yet started and expired — plus
      proof that every failure answers identically (RN-20) and that `anon` still cannot list `codes`
- [x] `BL-19` closed on the contrast part; `BL-23` partially resolved
- [x] **Gate:** `npm run build` and `npm run lint` clean. Main bundle 707 → 736 kB (214 kB gzip)
- [ ] ⚠️ **The `/admin/codes` screen was never clicked** — it is behind the curator login and the CLI
      does not have the password. `BL-31`

### F-06 — Field reports ✅ (S08)

- [x] **No migration** — the second feature in a row like that. F-01 had already delivered the RPC, the
      view with `security_invoker`, the 38 questions and the grants. Verified by introspection before
      planning: `anon` executes `rpc_submit_field_report` and has **no** INSERT on `field_reports`,
      so RN-23 is guaranteed at the privilege level, not only by policy
- [x] `src/lib/field-reports.ts` — a draw seeded on `place + browser` (true randomness would swap the
      question under the finger on every render), a weighted draw by `weight` without replacement,
      validation by input type, and formatting of the aggregate mirroring what the view **actually**
      computes (a mean only for `number` and `slider`; everything else reports the mode)
- [x] `src/hooks/use-field-reports.ts` — questions, aggregates, a progress counter, submission
      through the RPC, a stable `session_hash` in `localStorage` with a fallback for a non-secure context
- [x] `src/components/public/field-report-form.tsx` — the 7 input types, one receipt per question.
      Native `range` and `color` cover slider and color: keyboard accessible and with no new dependency
- [x] `src/components/public/field-report-panel.tsx` — the aggregate with deadpan seriousness (mono,
      tabular, `n = 5`), hidden below 5, and the progress counter in place of the emptiness
- [x] `/admin/reports` — a review queue for free text (approve/reject) and the seeding surface.
      "The dish you would order again" highlighted, since it is the only visitor answer that feeds the
      curator's judgment (bible §10)
- [x] **New RN-29:** the follow-up question is a closed choice, never free text — the `judgment`
      publishes immediately when the main question does not require review, so an open field there
      would be a second piece of live, unmoderated free text
- [x] **61 checks in a throwaway harness**, half pure and half through the real anonymous path. The
      ones that matter most: `anon` cannot INSERT directly, free text lands in `pending` and stays
      invisible to the public, a `status` smuggled inside the `answer` changes nothing, and the
      aggregate does **not** open with four answers and does open with the fifth
- [x] **Verified in the browser:** two questions drawn at 24 Diner and three at Aba (the 2-3 varies),
      the follow-up appearing when the answer completes, the receipt, an already-answered question
      disappearing on the next visit, and the aggregate rendering `Yes · n = 5` after the fifth
- [x] **Two defects found by eye, not by assertions** — see the session log
- [x] `BL-32` closed: `placeholder.tsx` deleted with Edu's authorization
- [x] **Gate:** `npm run build` and `npm run lint` clean. Main bundle 736 → 762 kB (221 kB gzip)
- [ ] ⚠️ **The `/admin/reports` screen was never clicked** — same reason as `BL-31`, it is behind the
      curator login. The PostgREST embed of the queue was validated against the database separately

### Session 09 — Handover, and the documentation in English ✅

- [x] `README.md` created — the repository had no human entry point. Setup, scripts, real directory
      structure, stack with what is deliberately absent, the authorization model, the two migration
      rules that already cost a failed apply, known gaps, and troubleshooting for this machine's two
      traps (the network URL and the mute map)
- [x] **A handover checklist**, including the section on repointing the database at a different
      Supabase project — what rebuilds from the four migrations and the three things that do not
- [x] **The curator login was tested and works.** Edu reset the password through the Supabase
      dashboard; `BL-31` narrowed to clicking the two screens
- [x] `BL-35` — no migration publishes a place. Found by sweeping all four migrations
- [x] `OP-05` — database backup outside the repository, with the reasoning that makes it urgent
- [x] `BL-36` — the boot prompt filenames stay in Portuguese, and why
- [x] **ADR-02 amended: the whole repository moved to English.** 19 files, ~3,000 lines
- [x] **The 2 boot prompts and the 5 agents were instantiated, not translated** — they were the raw
      Wise* template and their rules contradicted this project's ADRs
- [x] `docs/MICHAELINMAP_BIBLIA.md` → `docs/MICHAELINMAP_BIBLE.md`, with 16 references in 12 files
- [x] **Gate:** `npm run build` and `npm run lint` clean. No code touched, no migration applied

### Session 10 — Redesign do frontend, e o filtro que destrava a fila ✅

- [x] **`docs/design_system/` (Feedback Comunicação) adicionado como referência**, e instanciado na
      skill `michaelinmap-design-system` — a lei visual do projeto, com as duas divergências
      registradas: a UI continua en-US (ADR-02) e este produto reserva uma segunda cor
- [x] **Duas alternativas de identidade apresentadas antes de escrever código**, com previews em
      dados reais de Austin. Edu escolheu a clara (papel/bege); o ink stack não foi descartado —
      virou a superfície que um Code pinta
- [x] **`src/index.css` reescrito**: era o tema default do shadcn intocado (`oklch(0.145 0 0)`,
      croma zero, light-first). Agora tokens de papel em `:root`, ink stack no `.dark`
- [x] **A regra das duas cores** — lime é a interface falando, âmbar é o julgamento falando e é
      reservado. Nenhum arquivo de `components/ui/` referencia `--verdict*`
- [x] **15 primitivos shadcn e 13 telas migrados**; glass só nas três superfícies que flutuam
- [x] **Varredura de cor**: zero cor da paleta crua do Tailwind em `src/`. `sky` e `emerald` do
      admin viraram tokens `--info` e `--success`; **não existe `--warning`** porque aquele matiz
      pertence ao julgamento
- [x] **Auditoria adversarial com contexto independente reprovou o trabalho** em dois pontos reais,
      ambos corrigidos — ver o log da sessão
- [x] **Filtro por tag no admin + confirmação em lote** (`?tag=cuisine:tacos&tagSource=suggested`),
      17 checks em harness descartável
- [x] **Pipeline de pesquisa para o Opus 5** escrito e rodado sobre os 17 publicados sem cozinha:
      53 sugestões com fonte e citação por tag, **ainda não aplicadas** (`BL-38`)
- [x] **Gate:** `npm run build` e `npm run lint` limpos. Bundle 761 → 768 kB (222 kB gzip)
- [x] **`BL-35` fechado** — o lote de lançamento virou `20260808120000_publish_launch_batch.sql`,
      com 6 gates e rollback escrito. Aplicada afetando zero linhas: o efeito era registrar, não mudar
- [x] **O banco terminou a sessão idêntico a como começou** — 511 lugares, 58 publicados, 173 tags,
      zero do curador. A única escrita foi a migration, e ela foi um no-op contra o estado vivo
- [ ] ⚠️ **Nada do que foi entregue foi visto rodando no admin** — `BL-31`

### Session 11 — A primeira tag do curador, e a escrita que o RLS engolia ✅

- [x] **As 5 primeiras tags de curador da história do projeto.** Edu confirmou `Breakfast & Diner`
      em 24 Diner, Colleen's Kitchen, Geraldine's, June's All Day e Laurel Restaurant. A faceta
      Cuisine passou a renderizar no guia público. `place_tags` tinha zero desde o S04
- [x] **Bug crítico: uma escrita bloqueada pelo RLS reportava sucesso** (`d9e49cd`). A sessão parou
      de renovar o JWT, o PostgREST tratou a requisição como `anon`, a policy fez as linhas
      **sumirem em vez de levantar erro**, e sem `.select()` o retorno é 204. O código mostrava o
      número que *pediu*. As quatro mutações de tag agora pedem as linhas de volta e contam
- [x] **Seis telas do admin vistas rodando** — `BL-31` encolheu para só `/admin/codes`
- [x] **`german` no vocabulário** (`20260809130000`, 6 gates, rollback escrito). 38 slugs de cuisine.
      Três cozinhas alemãs do Hill Country não tinham slug, e isso é estrutural: New Braunfels e
      Fredericksburg são colônias alemãs. Metade da `DP-11` respondida
- [x] **Pipeline de pesquisa dos 117 restaurantes não revisados** — escopo, prompt e resultados em
      `docs/research/`, 10 de 117 prontos (`BL-41`)
- [x] **Checksum reprovou a transcrição do lote e estava certo.** Três apóstrofos curvos digitados
      retos e um espaço duplo antes do CEP em 76 dos 117 endereços. Os apóstrofos teriam quebrado o
      join por nome na migration
- [x] **Registros desatualizados corrigidos:** bíblia §9.3 e §12, `BL-30`, `BL-38`, `DP-09`, `DP-11`
- [x] **Gate:** `npm run build` e `npm run lint` limpos
- [ ] ⚠️ **`codes` está em 0 e todo registro anterior dizia 1** (`DEMO`). Divergência reportada, não
      corrigida
- [ ] ⚠️ **As 5 tags de curador só existem no banco vivo.** Nenhuma migration as reproduz, por
      princípio — `OP-05` deixou de ser hipotético

### Session 12 — A pesquisa dos 117 fechada, e dez restaurantes que não existem mais ✅

- [x] **Os 117 restaurantes pesquisados** — 10 vieram do S11, os **107 restantes rodados nesta
      sessão**, dez por vez, pelo próprio CLI com WebSearch/WebFetch em vez de um modelo externo
- [x] **91 tagueáveis · 15 sem slug honesto · 10 fechados · 1 incerto.** Evidência em 103 Tier A,
      37 Tier B, 13 Tier C. 28 dos 38 slugs usados
- [x] **Dez fechamentos, quatro deles em 2026 e três com distinção Michelin** — `BL-44`
- [x] **Erro meu, encontrado e corrigido:** `033 El Naranjo` registrado como aberto com confiança
      alta; fechou em 18/07/2026. Corrigido por script que verifica byte a byte todas as outras linhas
- [x] **Método endurecido depois disso:** toda busca seguinte incluiu termos de fechamento, e toda
      linha apoiada em fonte bloqueada passou a declarar isso nas próprias notas
- [x] **Validação por script em cada leva** — 117 objetos, ids em ordem e presentes no CSV, nomes
      byte a byte iguais ao CSV, todo slug no vocabulário, todo slug com evidência. **Reprovou duas
      vezes e nas duas estava certa**
- [x] **`BL-41` fechado.** Novos: `BL-43` (a migration das 91), `BL-44` (os fechamentos),
      `BL-45` (falta `american`), `BL-46` (falta `cajun-creole`), `BL-47` (dois endereços errados)
- [x] **`BL-42`, `DP-10` e `DP-11` reforçados com evidência**, nenhum deles fechado — são do Michael
- [x] **`docs/research/README.md` reescrito como registro final** da pesquisa, não como diário
- [x] **Gate:** `npm run build` e `npm run lint` limpos. Nenhum arquivo em `src/` tocado
- [ ] ⚠️ **O MCP do Supabase não carregou** — banco intocado, nenhuma migration escrita ou aplicada

---

## 🔄 In progress

Nothing running.

---

## ⏭️ Next action

**Apply the 91 researched cuisine suggestions as one migration (`BL-43`) — in a session where the
Supabase MCP actually loads.** It has the shape of `20260809120000_suggest_researched_tags.sql`:
insert `place_tags` with `source = 'suggested'`, resolving places and tags by natural key. Everything
enters invisible to visitors under RN-31. **First check whether `mcp__supabase__*` tools exist in the
session** — they did not in S09 or S12, and without live introspection SQL is off the table.

Four rows need handling before that migration, all from the S11 batch and all listed in
`docs/research/README.md`: **006 Anthem and 009 Bar Toti** must be re-run (both used
`cocktails-bar-food` as a crossed-kitchen fallback — new context: Bar Toti and 034 Este are sister
restaurants sharing 2113 Manor Rd, which explains the crossed menu); **008 Aris** needs its second
evidence row dropped, since it cites an OpenTable page for *Iris*; **012 Bellissima** is the weakest
row of the 117 and deserves one look from a normal browser.

**The ten closures do not ride along in that migration** (`BL-44`). A `status = 'closed'` is a
statement about a real business and ten at once changes what the guide claims — that is Michael's.

**Three vocabulary questions are now Michael's, and all three are better documented than they were:**

1. **`BL-46` — `cajun-creole`.** One self-described Cajun restaurant with nothing to take, and the
   gap surfaced twice. Exactly the case `german` already answered on three instances.
2. **`BL-45` — there is no plain `american`.** Five ordinary American places had no honest slug while
   `new-american` was used 18 times in 117, more than any other slug.
3. **`DP-11` — `interior-mexican`**, now documented from four directions and down to **one**
   defensible instance in 117 places.

**`BL-42` can be closed by example rather than by argument** — S12 produced four correct uses of
`cocktails-bar-food` and one that coexists with a cuisine, against the two known misuses.

**`OP-05` stopped being hypothetical.** Until today the migrations rebuilt everything; as of the 5
curator tags, they do not. Every confirmation from here widens the gap between the repository and the
only irreplaceable thing in the system. Both remaining actions are Edu's and neither is CLI work.

**Two decisions still belong to Michael:**

1. **`DP-10` — is `Gina's on Congress` still open?** Published and starred right now, three
   independent closure signals against one counter-signal. A phone call settles it.
2. **`DP-11`, second half** — `german` was added in S11 as a factual category. What remains is the
   boundary judgment: a missing `latin-american`, and `interior-mexican` becoming a dump for
   "Mexican that is not Tex-Mex". `BL-42` adds a sibling: `cocktails-bar-food` is a format claim
   living in the cuisine facet, and it attracts whatever the vocabulary cannot describe.

**One decision belongs to Edu:** what a Code has the right to repaint (`BL-37`). `--brand-ink` and
`--secondary` sit outside `MANAGED_PROPERTIES`, and a dark code with no `mapStyle` gets a light map
panel. Same question, two symptoms, both one-liners once the principle is settled.

---

**Beyond that, what the product needs is still not code:**

1. **The voice, and only Michael can give it.** None of the 58 published places has `the_dish` or
   `curator_note`. It is two questions from memory per place — "what do I order here?", "why does this
   one matter?" — on 8 to 10 of the strongest. It requires neither opening the admin nor having
   anything at hand. It is the project's smallest task with the largest return, and with the Codes
   ready it is exactly what a code delivers to a person.
2. **Tagging — also only him.** Edu cannot substitute (S08): he has never been to these places. Of the
   145 assignments, zero are the curator's. Under RN-31 none of them appears to a visitor any more, so
   the panel has three facets until curation starts (`BL-30`). **What can be advanced without him** is
   suggesting `cuisine` in bulk as an approval queue — `BL-34`.
3. **Two queues with data waiting on Michael:** the 28 tier conflicts (`DP-08`) and the 145 suggested
   tags (`DP-09`). Both already have a surface on the Overview.
4. **Seeding field reports** (`BL-20`): the surface exists at `/admin/reports`; the values are
   observations and have to be typed by someone who was there.

**On the technical side, what is left is operational, and S09 reordered it:**

1. **Take a database backup** (`OP-05`). This is the only pending item that can cost irreplaceable
   data, and it becomes urgent the moment the database is repointed at another project. Also confirm
   in the dashboard whether this project has automatic backups at all — nobody has checked.
2. ~~Turn the launch batch into a migration~~ — **done in S10** (`BL-35` closed). The 5 migrations
   now reproduce the whole product; only the auth account and anything Michael writes from here on
   fall outside them.
3. **Click `/admin/codes` and `/admin/reports` while logged in** (`BL-31`). The login works now. For
   the reports queue to show anything, a `pending` free-text answer has to exist first.
4. **Disable signup and turn on leaked-password protection** (`OP-01`) — two dashboard toggles.
5. **Deploy** (`OP-04`) — **deferred by Edu's decision:** it will use the company's Vercel account,
   not a personal one, and the database is expected to move to the company's organization as well.
   The repository is ready; the README documents what the move requires.

---

## 🚫 Blockers

**No blockers.** The MVP closed and nothing prevents the product from going live.

🔽 **`BL-29` stopped being a bug and became a limitation of my visual inspection.** Edu reported in S08
that he **sees the map normally in Firefox and on his phone** — that is, the guide works for whoever
uses it, and the mute map belongs to this machine's automated Chrome. The product was never broken.

This **contradicts the S05 record**, which claimed reproduction in Chrome, Firefox and Edge with a
plain MapLibre from a CDN: either the environment changed over those months, or that test did not
isolate what it was thought to. I redid neither, and what is above is Edu's report, not my verification.

**What this means in practice:** when a session needs to genuinely check the map, Edu is the one who
looks — I have no way to. Reopen only if someone reports a mute map in a real browser.

**An adjacent detail, from the same session and possibly the same family:** Chrome refused
`localhost:5173` and `127.0.0.1:5173` with the port demonstrably listening, and answered only on the
network IP. Noted in `.claude/CLAUDE.md` so the next visual check does not lose time.

---

## 📊 Database state

Re-measured through MCP at the close of S11. RLS enabled on all 8 tables.

| Table | Rows | Note |
|---|---|---|
| `places` | 511 | **58 `published`** (launch batch, S05), 453 `unreviewed` |
| `tags` | **95** | 94 public + `Hype trap` admin-only. **38 cuisine** since `german` (S11) |
| `questions` | 38 | 4 with `requires_review` (the free-text ones) |
| `tiers` | 4 | `destination`, `experience`, `fair`, `cool` |
| `place_tags` | **226** | **5 `curator`**, 221 `suggested`. The 5 are `Breakfast & Diner`, confirmed by Edu in S11 — the first curator tags the project has ever had. The 221: 145 from the F-01 import, 28 from S08, 53 from S10's research batch (`DP-09`) |
| `codes` | **0** | ⚠️ **Divergence.** Every prior session recorded 1 (`DEMO`, seeded by F-01 for the RPC smoke test). It is gone and no session log records deleting it. Most likely Edu cleaning up while exploring `/admin/codes`, which `BL-31` says has never been walked through. Not acted on — reported per workflow rule 6. Practical effect: `BL-33` (DEMO's invalid `mapStyle`) is moot, and a redeem test now needs a code created first |
| `curators` | 1 | `Michael` — `mikemyday@mikecofone.com`, account confirmed |
| `field_reports` | 0 | S08 created test rows through the RPC and through SQL and **deleted them all** at the end; the table went back to zero, verified |

Judgment distribution: 22 stars (4.3%), 42 unvisited, 279 with a tier (`fair` 182, `destination` 38, `experience` 30, `cool` 29), 107 with an area, 16 cities.

**Launch batch published in S05**, with Edu's approval: the 58 places with a star or the `destination` tier, across 5 cities (Austin 52, St. Augustine 3, Los Angeles 1, Mountain Home 1, Oxfordshire 1). It was not new judgment — tier and star came from Michael's own guides; the import simply had not revealed them. Verified through the public API with the anon key: an anonymous visitor sees 58, not 511. Reversible with `UPDATE places SET status='unreviewed' WHERE status='published'`.

⚠️ **None of the 58 has `the_dish` or `curator_note`.** The guide is populated but mute: it shows the verdicts, not the voice. Writing those sentences for 8-10 of the strongest is what separates the demo from an organized list — and it is human work, not CLI work.

Live migrations — **7**: the three from F-01, `20260807140000_suggest_cuisine_published` (S08),
`20260808120000_publish_launch_batch` (S10), `20260809120000_suggest_researched_tags` (S10) and
`20260809130000_add_german_cuisine` (S11). `schema_migrations` sanitized after every apply, versions
aligned with the file names — S11's apply was rewritten to `20260809051551`, which would have sorted
*before* its predecessor, and was corrected.

**The migrations no longer reproduce the whole product, and S11 is where that changed.** They rebuild
every place, verdict, vocabulary entry and the 58 published — but the **5 curator tags exist only in
the live database.** They are judgment (§1.1) and no migration will ever carry them, by design: a
migration that wrote curator tags would be an automated routine writing the judgment layer. This is
exactly the future `OP-05` was raised against, and it stopped being hypothetical today. A clone plus
these 7 now gives back a product missing the only five decisions a human has made in it.

---

## 🗺️ Roadmap

| # | Feature | Status | Sessions |
|---|---|---|---|
| F-00 | Foundation | ✅ Complete (S02) | ~0.5 |
| F-01 | Schema + data | ✅ Complete (S04) | ~1 |
| F-02 | Admin | ✅ Complete (S05) | ~1 |
| F-03 | Public (city gate, map, list, detail) | ⚠️ Complete (S05) — map mute due to `BL-29` | ~1 |
| F-04 | Faceted filters | ✅ Complete (S06) | ~0.5 |
| F-05 | Complete Codes + Roulette | ✅ Complete (S07) | ~1 |
| F-06 | Field reports | ✅ Complete (S08) | ~1 |
| — | Frontend redesign + admin tag filter | ✅ Complete (S10) | ~1 |

Total estimate: ~10 sessions — **the seven features closed in 7 CLI sessions**, ahead of the estimate.
The last two were budgeted at ~2 each and came in at ~1, for the same reason: neither needed schema
work, because F-01 had already built the ground. Michael's curation has been running in parallel since
F-02 — see bible §13.1 — and is now the **only** critical path in the project: the code finished ahead
of the content.

---

## 📝 Session log

### 2026-08-09 — S12: A pesquisa dos 117 fechada, e dez restaurantes que não existem mais

**O que foi feito:** os 107 restaurantes que faltavam foram pesquisados, dez por vez, fechando a
pesquisa em 117 de 117. Zero código de produto, zero migration, banco intocado. Dois arquivos
alterados, os dois em `docs/research/`.

**O boot encontrou o que não podia fazer.** O MCP do Supabase não carregou — `.mcp.json` declara o
servidor, mas nenhuma ferramenta `mcp__supabase__*` apareceu na sessão. Mesma coisa do S09. Isso
tirou migration e SQL da mesa pela primeira regra do projeto (*live schema first*) e definiu o que a
sessão podia ser: trabalho de arquivo.

**Quem rodou a pesquisa mudou, e valeu registrar.** O prompt tinha sido escrito para você colar num
modelo de pesquisa externo. Edu autorizou o CLI a rodar aqui mesmo, com busca e fetch. As regras não
mudaram — evidência com URL e citação verbatim, nunca inferir do nome, o endereço manda — e ficou
provado que quem executa não altera o que a pesquisa precisa provar. **O que mudou foi que a
validação passou a ser um script**, e não um olho.

**Esse script reprovou duas vezes e nas duas estava certo.** Ele confere ids em ordem e presentes no
CSV, nomes **byte a byte** contra o CSV, todo slug dentro do vocabulário, todo slug com evidência, e
`no_slug_fits` nunca convivendo com slug. A primeira reprovação foi `Cafe Blue` escrito onde o CSV
tem `Café Blue` — um caractere, e o join por nome na migration teria falhado calado. É a mesma
família dos apóstrofos que o checksum pegou no S11.

**O erro que o método não pegou, e que é o aprendizado da sessão.** Registrei o `033 El Naranjo` como
aberto, `interior-mexican`, confiança alta. **Ele fechou em 18 de julho de 2026** — quinze anos,
quatro veículos cobriram, o restaurante publicou carta de despedida. O que aconteceu: o site deles e
a Texas Highways bloquearam o fetch, a linha se apoiou numa matéria da Resy de maio de 2025 para a
cozinha, e **nenhuma busca de fechamento foi rodada naquele registro**. O prompt trata fechamento
como saída de primeira classe; aquela linha tratou como subproduto da pesquisa de cardápio. Apareceu
por acidente, numa matéria da KUT sobre o Olamaie que listava o El Naranjo entre os fechamentos de
2026. Corrigi com script que verifica que todas as outras 116 linhas ficam idênticas.

**Duas coisas mudaram na hora e ficaram até o fim:** toda busca seguinte incluiu termos de
fechamento explicitamente, e **toda linha apoiada em fonte bloqueada passou a declarar o bloqueio nas
próprias notas** (`012`, `050`, `084`, `097`). Uma linha fraca que se declara fraca convida uma
segunda olhada; foi a ausência disso que deixou o `033` passar.

**O quase-erro simétrico, no mesmo dia.** O `065 Meat & Bread` esteve a um passo de ser registrado
como fechado: a lista de unidades da marca mostra Vancouver, Calgary e **uma** entrada em Austin
chamada só "North Shore", sem o nosso endereço — exatamente a forma que provou o fechamento do Dos
Olivos. Abri a página do North Shore e o endereço dela **é** o nosso, sob um apelido. Virou regra no
`CLAUDE.md`: **uma omissão só é evidência depois que você abre a página que a conteria.** No Dos
Olivos eu abri; ali quase não abri.

**O achado que vale mais que as tags: dez lugares fecharam e um não dá para estabelecer.** Quatro em
2026, e três deles tinham distinção Michelin — o Olamaie fechou **com a estrela na mão**, o Otoko
depois de dez anos de omakase, o PastaBar em fevereiro. O Chapulín e o Vespaio são dois registros do
mesmo evento, restaurantes irmãos na South Congress cujos prédios foram comprados no fim de 2025.
São ~9% de um backlog montado a partir de álbuns de anos, e é a evidência que faltava para a `DP-10`:
**a mesma varredura sobre os 58 publicados passou a ser a coisa de maior valor que alguém pode fazer
no guia**, porque naqueles o visitante chega.

**Dois fechamentos foram resolvidos por um sucessor, não por ausência** — o Stumpy's no lugar do
Shack 512, o Phoebe's Diner assumindo a sala do The Local. Onde os diretórios se contradiziam, um
negócio diferente operando no endereço resolveu na hora e mais nada resolveria. Virou regra também.

**O vocabulário tem três buracos e eles se agrupam, o que é a segunda entrega da sessão.**

1. **Não existe `american` comum** (`BL-45`). Cinco lugares perfeitamente ordinários ficaram sem tag
   honesta — um bar num bangalô dos anos 40, um balcão de rotisserie, dois restaurantes do Lake
   Travis. E pela outra ponta o mesmo fato: **`new-american` foi usado 18 vezes em 117**, mais que
   qualquer outro slug e 60% mais que o segundo. O controle é o `067 Muck & Fuss` — também bar com
   cozinha, e `burgers` encaixa limpo porque a comida dele tem identidade. **A lacuna não é "bar", é
   "americano comum".**
2. **O lado mexicano está tão quebrado quanto** (`DP-11`, agora com evidência de quatro direções).
   `interior-mexican` teria sido *ativamente errado* três vezes — Este é costeiro, Veracruz é do
   Golfo, Ma'CoCo é Baja — salvos só porque outro slug coube. Três registros ficaram sem slug
   nenhum. E o `090 Santa Catarina` **anuncia "interior Mexico" servindo fajita**, que é o mecanismo
   visto por dentro. O slug termina a pesquisa com **uma** instância defensável em 117.
3. **`cajun-creole` é o caso do `german` de novo** (`BL-46`). Recusei `southern-comfort` por
   princípio: o vocabulário já separa `tex-mex` de `interior-mexican`, então ele se importa com
   precisão regional, e dobrar a Louisiana dentro do Sul americano joga fora exatamente essa
   distinção. O `german` foi adicionado por três instâncias e resolveu as três.

**E o `BL-42` pode ser fechado por exemplo em vez de por argumento.** A pesquisa produziu quatro usos
corretos de `cocktails-bar-food` — Murray's, Péché, Sidecar e Tiki Tatsu-Ya, todos drinks-first pela
descrição do próprio lugar — mais o Uchibā, que carrega `japanese` **e** `cocktails-bar-food` e
prova que o slug convive com uma cozinha em vez de substituí-la. Contra os dois usos errados do S11.

**Duas coisas erradas nos nossos próprios dados** (`BL-47`), achadas de raspão: o Mattie's está com
901 W Live Oak quando o endereço é 811, e o The Kimberly diverge entre a W 6th e a W 7th. Inofensivas
hoje porque a migration junta por nome. Junto delas, uma armadilha que não é defeito: o par Ma'coco
tem apóstrofo reto num registro e curvo no outro, e um `grep` por um não acha o outro.

**O que deliberadamente não foi feito:** nenhuma tag aplicada, nenhum `status = 'closed'` escrito,
nenhum slug inventado. As 91 sugestões são uma migration que precisa de MCP; os dez fechamentos são
afirmação sobre negócios reais e mudam o que o guia diz, então são do Michael; e vocabulário é dele
por RN-13.

**Gate:** build e lint limpos. Nenhum arquivo em `src/` tocado, versão mantida em `0.1.0`.

### 2026-08-08 — S10: O redesign do frontend, e o filtro que destrava a fila

**O que foi feito:** o frontend saiu do tema default do shadcn e ganhou um sistema visual; o admin
ganhou o filtro por tag que faltava. Três commits, zero migration, banco intocado.

**O diagnóstico que definiu a sessão.** Edu pediu para tirar o "AI slop" do frontend. O código não
era o problema — a copy estava escrita, as regras respeitadas, a estrutura das telas certa. O que
não existia era sistema visual: `src/index.css` era o tema default do shadcn intocado,
`oklch(0.145 0 0)`, cinza puro, croma zero, light-first. É literalmente o que todo app scaffoldado
nasce sendo. E o sintoma que mais importava: **o veredito era a coisa mais fraca da tela** — o tier
renderizava como pill cinza `secondary`, mais apagado que o nome do tipo do lugar ao lado, num
produto cujo valor inteiro é o julgamento de uma pessoa.

**Duas alternativas foram apresentadas antes de qualquer código**, com previews em dados reais de
Austin. Edu escolheu a clara. O ink stack não foi jogado fora: virou a superfície que um Code pinta,
que antes era o cinza stock do shadcn — ou seja, qualquer código escuro caía fora do design system.

**A regra das duas cores é a única ideia da sessão que não é herdada do design system da Feedback.**
Lime é a interface falando (ação primária, foco, faceta ativa, "Picked for you"); âmbar é o
julgamento falando (a estrela, o prato, o veredito) e é reservado. Nenhum arquivo de
`components/ui/` referencia `--verdict*`, porque um primitivo nunca é um julgamento. O corolário é
que saturação passou a significar alguma coisa.

**Seis defeitos reais apareceram só quando a página foi aberta**, e nenhum deles seria pego por
asserção: input com `bg-transparent` sumia sobre card no chão de papel; a aba ativa lia como
afundada porque `data-active:bg-background` põe a aba no chão da página, mais escuro que o card; o
botão primário **desbotava** no hover, porque `bg-primary/80` compõe o lime contra o fundo; o toast
com `theme="system"` escolhia claro/escuro pelo SO e brigava com a paleta; o scrim do dialog a 10%
praticamente não escurecia nada sobre bege; e o contador de caracteres usava âmbar ao estourar o
limite — o que, sob a regra das duas cores, seria o guia dizendo que estourar o limite é uma
honraria.

**A auditoria adversarial reprovou o trabalho, e estava certa.** Um crítico com contexto
independente atacou a entrega e derrubou dois pontos que eu não tinha visto. O primeiro é
desqualificante: a facet selecionada, que é a interação central do guia, tinha ido de ~16:1 para
**1,07:1** — e o rótulo trocava de matiz com luminância idêntica (1,02:1), o que **some por completo
em deuteranopia**. Eu tinha trocado acessibilidade por estética e ainda piorado removendo o
preenchimento condicional da estrela. O segundo: a estrela, marca mais significativa do produto,
era a de **menor contraste da página** (2,05:1). Ambos corrigidos, mais quatro achados menores que
se confirmaram na conferência à mão — `--muted` byte-idêntico a `--secondary` (todo `hover:bg-muted`
sobre controle `bg-secondary` era no-op), `--input` a 1,27:1 contra a página, `--destructive` a
4,10:1 no ink, e o anel do pin no mapa que eu tinha "melhorado" para derivar de `--primary` e com
isso sumia quando o curador escolhia a mesma cor para accent e pin.

**A lição virou regra no `CLAUDE.md`:** trabalho visual passa por crítico adversarial com contexto
independente, do mesmo jeito que migration crítica. Quem fez não enxerga o que fez.

**Depois do redesign, uma pergunta do Edu mudou o enquadramento do gargalo.** Ele perguntou se dava
para filtrar os lugares mal tagueados no app. A checagem revelou uma assimetria que ninguém tinha
notado: **o visitante tinha filtro facetado completo por cozinha e o curador não tinha filtro por
tag nenhum.** A pessoa que precisa mexer em tag era a única que não conseguia encontrá-las. Por isso
a fila de 173 sugestões nunca andou — não era volume, era que ela é uma lista plana onde aprovar
significa abrir lugar por lugar.

O filtro entregue (`?tag=cuisine:tacos&tagSource=suggested`) transforma isso em ~20 lotes coerentes.
Três decisões valem o registro: a chave é `facet:slug` e não `slug`, porque o UNIQUE da tabela é
`(facet, slug)` e a unicidade global é acidental; o filtro **falha fechado**, então chave que não
resolve devolve lista vazia em vez da lista inteira; e a confirmação em lote é uma sentença só com
`source = 'suggested'` no WHERE além do SET, o que a torna idempotente e incapaz de sobrescrever uma
decisão que o Michael já tomou. **Confirma em lote, rejeita um a um** — porque rejeitar apaga a
linha e confirmar só move o `source`.

**Uma pipeline de pesquisa foi escrita para o Opus 5** e rodada sobre os 17 lugares publicados sem
cozinha. Voltaram 53 sugestões com URL e citação por tag, e o modelo se saiu bem justamente no que
mais preocupava: **recusou-se a preencher lacuna quatro vezes** e sinalizou as próprias inferências.
Dois achados saíram dali e nenhum é uma tag:

1. **`Gina's on Congress`, publicado e com estrela, pode estar fechado** — três sinais independentes
   contra um contrassinal (`DP-10`).
2. **O vocabulário de cuisine não cobre o topo do guia.** Sete dos 17 não têm slug adequado, e
   `interior-mexican` está virando depósito de "mexicano que não é Tex-Mex" — classificação falsa
   com cara de precisa (`DP-11`).

**A recomendação sobre rodar os 453 restantes foi NÃO, e o motivo vale ficar escrito:** os não
revisados não são o guia, são backlog, e o painel público só computa facetas sobre publicados.
Taguear os 453 não mudaria nada visível e levaria a fila para ~700 itens. Se o Michael não trabalhou
173, não vai trabalhar 700. O próximo lote útil são os **39 publicados que já têm cozinha mas estão
sem `format`, `logistics` e `dietary`** — as três facetas que têm 1, 0 e 0 atribuições no banco
inteiro. E mais valioso que qualquer tagging: uma varredura de fechamento sobre os 58 publicados,
porque o Gina's apareceu por acidente e 511 lugares vindos de álbuns acumulados ao longo de anos
dificilmente têm só um fechado.

**Sobre o CSV:** conferido no banco, os 511 lugares estão idênticos ao arquivo que o Edu tem —
todos `apple_csv`, nenhum criado depois do import, e os únicos 58 editados são exatamente os
publicados no S05, onde só o `status` mudou. O CSV dele não envelheceu.

**O que ficou aberto de propósito:** o `H-02` da auditoria (`--brand-ink` e `--secondary` fora do
`MANAGED_PROPERTIES`, então um Code não alcança a facet selecionada, o badge "Picked for you", a nav
do admin nem os campos de formulário) não foi corrigido porque mexe em `code-effects.ts`, que tem o
harness de 60 checks do F-05 em volta, e porque é decisão de produto — a mesma do `mapStyle`. E o
Inter nunca foi aprovado como dependência: perguntei duas vezes, sem resposta, então declarei a
premissa e segui no Geist.

**Uma correção de percurso que vale registrar:** afirmei que `places.source` não existia no banco
depois de um erro de SQL meu. A coluna existe; a consulta é que estava malformada. Corrigido na
hora.

**Commits:** `17558f5` (design system + skill), `6add1e6` (redesign) e `a306b47` (filtro por tag).
Todos locais — `main` está 4 commits à frente do `origin`, contando o fecho do S09 que nunca foi
pusheado.

### 2026-08-08 — S09: Handover, and the documentation in English

**What was done:** no product code. The session started as a status check and turned into preparing
the project to change hands — a README, a documented path for moving the database, and the whole
repository translated to English.

**The boot found something it could not do.** The Supabase MCP server did not load: `.mcp.json`
declares it, but no `mcp__supabase__*` tool was exposed in the session. So **step 6 of the boot never
ran** — everything this entry says about the database comes from the previous STATUS, not from
introspection. That also settled what the session could contain: with no live schema access, writing
SQL was off the table by the project's own first rule.

**Two questions from Edu produced two findings, and neither was the answer to the question asked.**

He asked why the login was asking for a password when there was none in the database. The answer is
that it lives in `auth.users.encrypted_password`, a schema that is Supabase's and not ours — our
tables hold only the allowlist. He had set it himself in S04 and it is recorded nowhere, correctly.
He reset it through the dashboard, and **the login works.** `BL-31` narrowed from "nobody can get in"
to "the two screens still need clicking".

He then asked how hard it would be to sync the guide with Michael's Google My Maps. The estimate is
in the amended `ADR-08`, but the useful part was checking the premise first: **the 511 places come
from Apple Maps**, so a My Maps sync would read an empty source unless Michael keeps one in parallel;
and KML carries name, coordinates and layer but **never** the judgment layer, so a sync brings more
pins, which §1 says is exactly what has no value here. Not reopened. What is worth reconsidering some
day is only the assumption the cut rested on — that quick-add is a complete capture path — because
S08 measured that Michael has not sat down to use any of our tools yet.

**Then the real question: is the repo enough to hand the project to someone else?** It is
surprisingly close — the four migrations rebuild the schema, the vocabulary and all 511 places,
because the seed and the import are themselves migrations. Writing that down turned up two things
nobody had looked for:

1. **No migration publishes a place** (`BL-35`). Verified by sweeping all four: every occurrence of
   `status = 'published'` is a policy, an index or a view — none is a write. The batch of 58 came
   from an ad-hoc `UPDATE` in S05 and lives only in the live database. So a rebuild against an empty
   project returns 511 places with none published, and **the public guide renders empty while looking
   perfectly healthy** — the city gate counts published places, so it shows no city at all, with no
   error and no clue. The criterion is on record (starred or `destination`), so the fix is one
   statement, and it is worth making it a migration.
2. **`20260806130000_f01_seed_curator` aborts on a fresh project** if the auth account does not exist
   first — gate G1 raises on purpose. That is correct behavior, not debt, but it is the kind of thing
   that stops a rebuild halfway if nobody warned you. Documented in the README rather than the
   backlog, because it is an instruction, not a defect.

Both feed `OP-05`, the one pending item that can cost data that exists nowhere else. Today the
migrations reproduce almost the whole database; that stops being true the minute Michael writes his
first sentence.

**`README.md` created**, and it was the only real gap in the handover: the documentation was
excellent and lived entirely in `docs/` and `.claude/`, which a CLI finds at boot and a person does
not. It opens with the judgment-layer rule, because that is what someone needs to understand before
touching anything.

**The decision that took the rest of the session: everything written into this repository moves to
English.** Edu's call, and the reason is a new fact — documentation the next maintainer cannot read
is documentation that does not exist. `ADR-02` was **amended, not replaced**: the original split
(English product, Portuguese internal record) is still recorded as what was true and why. 19 files,
about 3,000 lines. `docs/STATUS.md` was **translated, not rewritten** — every past session still
says what it observed, including the corrections sessions made about themselves.

**Seven of those files were not translated. They were instantiated** — and this is the part worth
reading twice. The 2 boot prompts, the 5 agents and one skill were still the raw Wise* template,
carrying instructions that contradict this project's ADRs:

- **UI in Portuguese BR, `R$`, `DD/MM/YYYY`, and error messages in Portuguese** — the exact opposite
  of ADR-02, in a product that is entirely in English
- **`company_id`, tenant scoping, `is_superadmin()`, capabilities, `audit_log`, LGPD, CPF, Power BI,
  an AI layer** — none of which exist here
- **`deleted_at` soft deletes**, when ADR-03 uses `status`
- **Decisions presented as A/B/C menus**, which is precisely what the orchestrator is forbidden to
  hand Edu
- And the worst one: **a gate that fails any RPC `anon` can execute.** In this project the two public
  RPCs *must* be executable by `anon` — a Data Architect obeying that checklist would have taken the
  public guide down while believing it was hardening it

Nobody was misled only because nobody read them: the seven features were built without the agent
pipeline (ADR-04 makes it optional). That is the lesson, and it went into `CLAUDE.md`: **an
untranslated template is not neutral, it is instruction the repository appears to endorse.** Either
instantiate it or mark it unused the way `michaelinmap-spec-format` is marked.

**Smaller things found and fixed along the way:** the bible's header still read v2.6 while its own
changelog had recorded 2.7 and 2.8; `michaelinmap-spec-format` was full of mojibake inherited from
the template and referenced its sibling skills by their old `wise-*` names; the how-to for the MCP
setup had another machine's absolute path hardcoded in an example; and the README's own documentation
section had to be corrected mid-session, because it still claimed the docs were in Portuguese.

**The STATUS hash was corrected in both directions.** `5aa2b96` was right as F-06's commit and wrong
as the session's close — six commits followed it, and S08 actually ended at `aa3cf73`.

**`docs/MICHAELINMAP_BIBLIA.md` → `docs/MICHAELINMAP_BIBLE.md`**, with 16 references across 12 files
updated, including the comment in `src/types/index.ts` and the F-01 migration header. The boot prompt
filenames stayed in Portuguese on purpose (`BL-36`): the `/orquestrador` and `/executor` slash
commands live outside this repository and point at those paths, so renaming them breaks both
silently.

**An operational lesson that cost a failed commit:** a long commit message passed through a
PowerShell here-string blew up, and git parsed the whole message as pathspecs — nothing was committed
while the files stayed staged, which looks exactly like success. `git commit -F <file>` has no such
failure mode, and that went into `CLAUDE.md`.

**What was not done, explicitly:** no product code, no migration, no database change, and no
verification against the live database — the MCP server never loaded. The Vercel deploy was deferred
by Edu's decision to use the company's account. And the two admin screens still have not been
clicked, though now nothing stands in the way but doing it.

**Gate:** build and lint clean throughout. Bundle unchanged at 761 kB, since no source file was
touched beyond one comment.

### 2026-08-07 — S08: F-06 — Field reports (the MVP closed)

**What was done:** the MVP's last feature. Visitors now answer 2-3 questions per place, the aggregates
open on the fifth answer, free text waits for Michael in a queue, and the curator has somewhere to
seed his own answers.

**For the second session in a row, zero migrations.** The boot checked the live schema before planning
and found everything ready since F-01: the RPC deriving status, truncating at 40 and limiting per
session; the view with `security_invoker` and its `HAVING count(*) >= 5`; the 38 seeded questions. The
finding most worth recording is about privilege level: **`anon` executes the RPC and has no INSERT on
`field_reports`**, so RN-23 does not depend on the policy being right — there is no direct write path
to revoke.

**A new rule came out of something small.** Four questions carry a follow-up (`judgment_prompt` — "Was
it worth it?", "Is that good or bad?") and the `judgment` is published immediately whenever the main
question does not require review. A text field there would be a **second** piece of visitor free text,
live and unmoderated, when RN-24 permits exactly one. It became **RN-29**: the follow-up is a closed
choice, and both labels come from the prompt itself — which either offers them ("good or bad" →
Good/Bad) or is a yes/no question.

**About seeding (BL-20), what was delivered and what was not.** The surface exists: the curator picks a
place, answers the questions in the same UI the visitor sees, and the answers enter published. What the
CLI **did not** do was invent the values. Food temperature at Franklin, ceiling height in hands at
Uchi — I have never been to any of the 58, and the panel reports to one decimal place with the face of
a measurement; an invented number there would be indistinguishable from a measured one. Bible §10 always
said "**the curator** seeds his own answers". Worth knowing that seeding reveals no aggregate at all:
n=5 is per place × question and one person gives one answer — the gain is that the counter is not born
at zero.

**Verification: 61 checks, and then the eye — which found what the 61 could not.**

The harness covered what assertions cover well: the draw being stable for the same seed and changing
from person to person, `anon` being unable to INSERT directly, free text landing in `pending` and
staying invisible to the public, a `status` smuggled inside the `answer` changing nothing, the aggregate
**not** opening with four answers and opening with the fifth.

Then the page was opened in the browser and **two defects appeared that none of the 61 caught**, both
of interface state:

1. **The receipt never appeared.** The panel filters out already-answered questions, and the predicate
   was reactive — answering a question removed it from the list in the same instant, unmounting the card
   before it could show "Logged". Fixed by taking a snapshot of what was already answered **when the
   page opens**: an answered question now stays standing until the end of the visit, and only
   disappears on the next one.
2. **The receipt counted twice** — it said "2 of 5" on the first answer. The submission invalidates the
   count query, which revalidates already including the new answer, and the `+1` added on top. Fixed by
   holding the count from before the answer.

Neither is subtle to see and neither was visible without opening the page. It is the same lesson S05
recorded by another route, now on the frontend side: assertions prove rules, the eye proves interfaces.

**An environment detail worth knowing.** The `session_hash` generated in the browser came out in the
fallback format (`s-<timestamp>-<random>`) instead of a UUID: served over HTTP on the network IP, the
page is not a secure context and `crypto.randomUUID` does not exist. The fallback was there for exactly
that and it worked — in production (HTTPS on Vercel) it will be a UUID. Not a bug, but it explains the
format if anyone looks at the column.

**Test data created and deleted.** The verification wrote to `field_reports` through the RPC and through
SQL — including the five answers needed to genuinely open an aggregate on screen. All deleted at the end
by `session_hash`; the table went back to zero, verified.

**`BL-32` closed:** `placeholder.tsx` had been orphaned since F-05 and was deleted with Edu's
authorization, after confirming nobody imported it.

**What was left unseen, said explicitly again:** `/admin/reports` compiles, passes the linter, and the
PostgREST embed of the queue (`places(...)`, `questions(...)`) was validated against the database
separately — but the screen is behind the curator login and the CLI does not have the password. Same
hole as `BL-31`, now with two screens inside it.

**Record correction:** the S07 log said commit `c782770` was "local, not pushed". This session's boot
checked with `git fetch` and the local `main` is identical to `origin/main` — S07's three commits are on
GitHub. Corrected below.

**Commit for F-06:** `5aa2b96`. The session did not end there — it continued for six more commits,
recorded below; the S08 closing hash is at the end of this entry.

**Still in S08, after F-06: the rating facet left the public filter**, by Edu's decision. He chose the
narrowest of the three scopes I presented — only the facet; the `Destination`, `Experience`, `Fair` and
`Cool` badges stay in the list row and on the place page, and the admin and the database were not
touched.

**The only decision I made on my own was removing the `tier` parameter from the URL along with the
facet.** Leaving the predicate alive with no control on screen would create a filter that narrows the
guide invisibly — exactly the failure RN-27 was written to prevent, and one nobody could undo because
there would be nothing to click. I checked first that no code depended on it: `DEMO` is the only one
that exists and its `preset_filter` is null. An old link with `?tier=` is now ignored, verified on screen.

It became **RN-30**, and bible §6 gained the distinction it was missing: judgment and navigation axis
are not the same thing. The tier is still everything §6 describes; what it stopped being is a facet. The
star becomes the only filterable quality signal — which is how the eight tier-less types always worked
(RN-05), now true for restaurants and bars as well.

**Gate:** build and lint clean. Bundle 762 → 761 kB.

**And `BL-29` closed as a question, at the end of the session.** I had recorded that the map again drew
no geometry on both Austin screens during this verification. Edu answered that he **sees the map in
Firefox and on his phone** — which settles the matter in the direction that mattered most: the product
is right, and the mute map belongs to the Chrome I drive. Downgraded from bug to a limitation of CLI
inspection. Worth recording that this contradicts the S05 test, which claimed reproduction in all three
browsers; I redid neither, and the report is Edu's, not my verification.

**The operational consequence is for future sessions:** I cannot check the map. When a verification
depends on it, Edu is the one who looks.

**Finally, the finding that changes the project most — and it is not technical.** Edu asked which tags
existed to assign and, on seeing the list, said that **he cannot tag: he has never been to any of these
places, the list is Michael's.** I measured the real state right after: of the 145 assignments, **zero**
are the curator's; of the 58 published, 11 have some tag and **none** has `the_dish`; 21 of the 94 tags
have ever been used. The curation this file had been describing as "running in parallel since F-02"
**never started**, and it is not for lack of a tool — it is that it depends on one specific person who
has not yet sat down to do it.

**I went to check and found something worse than the volume:** the public side **did not distinguish** a
suggested tag from a curator tag. `usePlaceTagLabels` and `buildGuideIndex` read `place_tags` without
looking at `source`, and the 5 cuisines showing up in the Austin panel were 100% import guesswork —
`Breakfast & Diner`, with 56 uses, came from the **name of an Apple Maps guide**, not from someone
deciding. It had been that way since F-01; nobody had looked from that angle.

Fixed in this session: **RN-31** — a `suggested` tag appears on no public surface until it is confirmed.
The cost is visible and was accepted with eyes open: the Austin panel fell from five facets to three
(star, type, area) and the cuisine badges disappeared from place pages. Showing less than you know is
better than presenting a guess with the authority of a verdict, in a product whose entire value is one
person's judgment (§1.1).

**The good side effect:** now that a suggestion is invisible to the visitor, suggesting in bulk became
safe — it becomes an approval queue in the admin, not a public assertion. That is `BL-34`.

**And that is what closed the session: 28 new cuisines** (`20260807140000_suggest_cuisine_published`),
taking published food places without a cuisine from 45 down to 17. Two things are recorded about the
criterion:

- **Ten of them are legible from the name itself** and anyone can verify them without knowing Austin:
  `ALC Steaks` → Steakhouse, `Chez L'Amour` → French, `Il Brutto` and `L'Oca d'Oro` → Italian,
  `El Raval` → Spanish (a Barcelona neighborhood). **The other eighteen depend on my knowing the
  restaurant**, which is memory and not observation — it may be out of date, and a place may have
  changed concept. Precisely for that reason all of them entered as `suggested`.
- **Seventeen were deliberately left out**, with the nominal list in the migration's footer. A wrong
  suggestion costs more than a missing one: somebody has to read it and reject it.

**A gate failed the first apply, and the one who was wrong was me.** G3 asserted that no place carries
two cuisines; it failed, pointing at 11. I went to look: they are all from the F-01 import and **all
correct** — `Dean's Italian Steakhouse` is Italian *and* Steakhouse, a café serving breakfast is Coffee
*and* Breakfast & Diner. Two cuisines are not a contradiction; the rule I had written was. The gate was
rewritten to the batch's scope and the migration rolled all the way back before that — the database was
never in an intermediate state.

**Verified after the apply:** the public Austin panel still has three facets, with no cuisine section at
all, with the 28 tags already in the database. It is RN-31 proven in the direction that matters — new
data went in and the visitor did not see it.

**Finally, the repository became Vercel-ready (`OP-04`).** Three things landed, and the first is the one
that matters:

- **`vercel.json` with the SPA rewrite.** Without it, `/city/austin` and `/place/canje` return **404**
  on direct access — and direct access is precisely what a shared link is. A guide that only works if
  you navigate from the home page does not serve what this product exists for.
- **`public/robots.txt`** with `Disallow: /`. The `noindex` in `index.html` already covered ADR-07 for
  anyone rendering the page; this covers crawlers that do not execute JS. Belt and suspenders, zero cost.
- **`engines.node >= 22`** in `package.json`. Without it Vercel picks its own Node version, and Vite 8
  does not run on an old one — it is the classic cause of a first deploy failing.

**What I did not do and will not do alone:** authenticate into the Vercel account. The step by step with
the variables is in the session's conversation; `.env.local` has the values and does not go into the repo.

**Security check before exposing anything:** `get_advisors(security)` reported no RLS failure. The 8
`SECURITY DEFINER` warnings are `BL-28`, already accepted and reassessed. A new warning appeared,
`auth_leaked_password_protection` disabled — it touches the curator account's password, not the visitor,
and is solved with a dashboard toggle alongside `OP-01`.

**S08 closed at `aa3cf73`**, not at `5aa2b96` as this entry used to say — that is F-06's commit, and six
came after it: `0868505` (record), `c899458` (rating facet), `7f1dd41` (`BL-29` downgraded), `aa6e362`
(RN-31), `08791bb` (28 cuisines) and `aa3cf73` (Vercel preparation). All on `main` and on GitHub,
verified with `fetch` in S09. The content of all six was always narrated here; it was only the hash that
pointed to the middle of the session.

### 2026-08-07 — S07: F-05 — Codes and Roulette

**What was done:** the feature the PRD calls the one most directly tied to the product's purpose (§9.7 —
"the curator creates a code for every person he shows the guide to, forever, without involving a
developer"). Delivered whole, without touching the database.

**The finding that defined the session: F-05 needed no migration.** The boot checked the live schema
before planning and found `codes` already carrying `theme`, `pin_style`, `preset_filter`,
`highlighted_places`, a date window and `active`; `rpc_redeem_code()` applied, with `anon` already
authorized to execute it; and the curator policy in place. F-01 had built the entire ground eight months
before anyone stepped on it. Result: zero migrations, zero npm dependencies, zero new shadcn components —
10 new files and 5 touched, all frontend.

**Two behavioral decisions became business rules, because they are not implementation details:**

- **RN-27** — a code's preset seeds the panel **once**, arrives selected, leaves through the normal
  *Clear*, and **never overwrites a filter already in the URL**. Without that, a preset would be a code
  hiding places, which is exactly what RN-21 forbids. A shared link is somebody's explicit choice and
  beats decoration.
- **RN-28** — the code is remembered in `localStorage` (Michael hands a code to a *person*, not to a tab)
  but the effect is **revalidated on the server on every load**. Switching a code off in the admin now
  takes effect on the next visit, instead of being stuck in the browser of someone who already used it.

**A URL detail that became a rule in CLAUDE.md.** `filtersToParams()` builds a fresh `URLSearchParams` on
every click, so a `?code=` parked there would vanish the first time a facet was touched — and reappear on
the next share. Worse than not supporting it. The solution was to rescue and remove the parameter on
arrival; the general rule is that the guide's URL belongs to the filter.

**Contrast solved at the source, not policed afterwards.** `contrastOn()` derives
`--primary-foreground` and `--foreground` from the WCAG luminance of the color the curator picked, so no
code theme can be born illegible, however bad the color. It closes the contrast part of `BL-19` without
auditing component by component. And a dark background turns on the `dark` class, because overriding
`--background` alone would leave borders, muted text and accents at their light values — a dark page
with light seams everywhere.

**Verification: this time there was an eye, not only assertions.** The Chrome extension connected (in S06
it had not, and the record of the time said so in as many words). The code was typed into the air on the
guide page and, in sequence and with no further input: the URL became `?tier=destination&star=1` on its
own, the whole guide darkened, the banner appeared with the message and the way out, the amber "Picked
for you" badge entered Canje's row, the pins became amber squares with rings on the highlighted ones, and
the options that zeroed went gray and stayed clickable (RN-17). "Back to normal" undid everything. The
map style swap was proven over the network: `/styles/liberty` on load, `/styles/dark` at the exact moment
of redemption.

Before that, **60 checks in a throwaway harness** covered what the eye does not see: the real anonymous
path with a code that was valid, lowercase, surrounded by whitespace, nonexistent, empty, switched off,
not yet started and expired — plus proof that every failure answers byte for byte identically, which is
what keeps the RPC from becoming a code oracle (RN-20), and that `anon` still cannot list `codes`.

**`BL-29` stopped reproducing.** The map drew complete geometry in both styles. Nothing changed in our map
code beyond the `setStyle` this feature added. It is recorded as a symptom absent, **not** a cause
explained — I did not chase the why, because the technical investigation had already been exhausted in S05
and the recorded next step was Edu's. If it comes back, the history of what has been ruled out with
evidence is still in `BL-29`.

**What was left unseen, said explicitly:** the `/admin/codes` screen compiles and passes the linter, but it
is behind the curator login and the CLI does not have Michael's password. It is the only piece of the
delivery nobody has seen running (`BL-31`).

**Debt taken on.** The 60-check harness is throwaway again, not a versioned suite — it went to the
scratchpad, outside the repo. `BL-22` gained the technique that made it possible: `vite build --ssr`
bundles a TS harness resolving the `@/` aliases, Node runs the result, and a ten-line fake `document` is
enough to test code that writes CSS variables. It is the ready-made outline of the suite when it comes.

**Version kept at `0.1.0`** by Edu's decision — bump only when the product goes live.

**Commit:** `c782770` — it is on GitHub (S08 verified; this record used to say "local, not pushed").

### 2026-08-07 — S06: Documentary reconciliation

**What was done:** the boot found the STATUS claiming "F-01 complete, F-02 to start" with F-02 and F-03
already committed on `main`. This file and the bible were realigned with reality before any new code.

**Divergences closed:**
- STATUS said phase F-01 / next F-02; reality was four closed features and F-04 as next
- STATUS listed **2** live migrations; MCP shows **3** — `20260806130000_f01_seed_curator` had been
  applied since S04 and never entered this list
- STATUS said F-02 was "blocked by `OP-01` and `OP-02`"; `OP-02` closed in S04 itself and `OP-01` is
  hygiene, not a blocker — S04's negative test had already proven that an account outside the allowlist is
  treated as a visitor
- The bible still said "F-00 and F-01 complete" and did not record OpenFreeMap as the tile source
- `BL-25` in the BACKLOG held the map chunk size from the MapLibre 6 era (947 kB); with v5, which embeds
  the worker in the same file, it is 1,030 kB (274 kB gzip)

**Why S05 closed without updating the STATUS:** I do not know — I was not in it. The S05 log below was
reconstructed from the commit messages, which are detailed enough for that. It is recorded that this is a
reconstruction, not a live account.

**After the reconciliation, F-04 was built in the same session** — see below.

**F-04 — faceted filters.** The decision that defines the feature was taken before writing code, from the
live database: measuring the real vocabulary of the 58 published places, six of the seven tag facets have
**zero** assignments, `price_band` has zero, and only 11 places carry any tag. Building the complete panel
would render five entire sections of gray checkboxes.

Hence the new rule: **a facet with no populated option is not rendered.** It does not contradict RN-17,
which governs the option inside a facet and still holds — it is §8 ("degrade silently instead of rendering
an empty control") applied beyond areas. The effect is that the panel grows on its own as curation
advances, with no deploy, which is the point of tags being data and not code (RN-13).

**Verification.** The Chrome extension was not connected, so there was no visual inspection. Instead of
asserting without looking — the mistake S05 recorded as a lesson — the logic was verified by a throwaway
harness that reads the guide **through the real anonymous path** (PostgREST + anon key, RLS in force) and
runs the filter functions over the result: 27 checks, all passing. It tests RLS and filtering together, and
includes RN-14's adversarial case (inject a `Hype trap` assignment and prove it becomes neither a facet nor
part of the index, even if RLS failed).

One of the checks initially passed through an escape clause — no zeroed option existed in the data, and
RN-17's assertion was never exercised. The case was forced (`cuisine=bbq` in Austin is two `destination`
places, so the other three tiers zero out) and the rule was genuinely verified, including that a selected
option which emptied the list stays clickable — otherwise the visitor cannot undo it.

**What is recorded as debt:** the harness is throwaway, not a versioned suite. The next change to the filter
has no net (`BL-22` updated). And the six dormant facets became `BL-30` — not as a bug, but as the visible
symptom that curation is the critical path.

### 2026-08-06 — S05: F-02 (admin) and F-03 (public)

> Entry reconstructed in S06 from the commit messages `b83ff78..29239c6`. Faithful to what is versioned;
> decisions taken in conversation that left no trace in the repository do not appear here.

**What was done:** two entire features. The admin went from placeholder to a complete curation tool, and the
public side went from zero to navigable — city gate, guide, detail and map. Neither touched the schema: they
are frontend on top of F-01's database.

**F-02 — Admin.** List with filters, place editor, tag assignment with `suggested` visually distinguished
from what came from the curator (RN-15), Overview with live tier distribution (RN-06) and mobile quick-add
with Nominatim geocoding. Six shadcn components landed; no new npm dependency.

**Scope decision: the dedicated review-queue screen was cut.** The three queues — 28 tier conflicts, pending
suggested tags, 15 without a type — became cards on the Overview linking to the list with the filter already
applied. A screen of its own would be a fourth way of looking at the same records, at the cost of keeping two
places in sync. Recorded under "Out of the MVP".

**F-03 — Public.** The city gate displays cities as pairs with counts (DP-02) — a city with one place is not
hidden, it is just honest about being one place. The guide separates "Eat & drink" from "Everything else",
because type is the second gate (§7) and a state park in a restaurant list is noise. The detail leads with the
verdict, never the address; opening hours do not exist because of ADR-06, and the directions button solves it —
the maps app knows, and it also knows whether the place is open now.

**Launch batch published, with Edu's approval:** the 58 places with a star or the `destination` tier went from
`unreviewed` to `published`. It was not new judgment — tier and star came from Michael's own guides and the
import simply had not revealed them. Verified through the public API with the anon key: an anonymous visitor
sees 58, not 511.

**The map: four attempts, one real bug fixed and one environmental cause.**

The investigation is worth recording because three of the four fix commits were dead ends, and the fourth found
a genuine bug:

1. `resize()` on `load` + a `ResizeObserver` — the container is sized after the map is built (a `vh` unit, a
   sticky wrapper, and the map coming from inside a `lazy`). Correct to do, was not the cause.
2. Explicit `config.WORKER_URL` — MapLibre 6 builds the worker URL at runtime through string concatenation,
   something no bundler can see, so Rollup never emitted the file. **It was a real bug**, proven by the map
   going back to requesting fonts (only the worker triggers that). Even so, the tiles did not come.
3. **`fitBounds` only after `load` and with a container of real width** — this is the finding that stays.
   Framing against zero width computes a degenerate zoom, and the map never discovers which tiles it needs; a
   later `resize` fixes the canvas but does not recompute the camera, so the bad view stayed stuck and Austin's
   52 markers appeared piled in a corner. Once fixed, the markers spread out with the real geography. **And the
   framing runs once per set of places (key = ids), which already prepared the path for F-04.**
4. Downgrade `maplibre-gl` 6.2.0 → 5.24.0, approved by Edu. v5 ships a single file with the worker embedded, so
   the workarounds from item 2 went away. It did not fix the rendering.

**The final diagnosis is that there is nothing to fix.** A plain MapLibre map, from a CDN, on a blank page and
without a line of ours, behaves identically in all three browsers. Recorded as `BL-29` with the full list of
what was ruled out with evidence, so the next session does not walk the same path again.

**`BL-25` partially resolved.** MapLibre took the single bundle to 1,647 kB — too much weight for someone who
only opens the city gate. The map became `lazy` + `Suspense`: main bundle 699 kB (204 kB gzip), map chunk loaded
only when a city opens, and the list is already usable while it arrives.

**A lesson worth more than this project:** three of the four map fixes went to the wrong place because the
hypothesis was never tested outside our code. The test that settled the question — plain MapLibre from a CDN on
a blank page — costs five minutes and should have been the first, not the last.

### 2026-08-06 — S04: F-01 — schema, RLS, RPCs and import

**What was done:** the database went from zero tables to the whole schema with the 511 places inside. Two
migrations, both versioned in `supabase/migrations/`, both with a rollback written in `supabase/rollbacks/`.

**Five decisions settled before writing SQL, all approved by Edu:**
- **Import through versioned SQL**, not through `import-places.ts`. The script required a service-role key in the
  environment and the `csv-parse` dependency; SQL generated from the CSV stays auditable in the repo and asks for
  no new key. The slugs come from the same `slugify()` that lives in `src/lib/utils.ts`, so they match the frontend
- **`price_band` was not pre-suggested.** ADR-06 required pre-classifying `cuisine` and `price_band`, but §9.1
  removed `price_band_source` — there is nowhere to mark that a value is a machine guess, and without Google Places
  the only input would be the place's name. A guess would be indistinguishable from Michael's verdict in a
  judgment-layer field. ADR-06 amended in the bible
- **145 tags written as `suggested`**, with explicit authorization (it is the judgment layer). Two sources only: the
  CSV's `Tags` column, which comes from the names of Michael's own guides, and unambiguous cuisine-word matching in
  the place name, restricted to types that serve food
- **`DEMO`** seeded to give `rpc_redeem_code()` something to test against before F-05
- **`curators` is born empty** — `auth.users` has zero accounts

**Two divergences found along the way:**
- **There are 4 tiers, not 5.** STATUS and the bible said 5 because the §6.2 table lists `fair` twice, once per
  scale. Since `slug` is the PK, `fair` is one row with `applies_to = {restaurant, bar}` — which is what the column
  being an array is for. Confirmed by `SEEDED_TIER_SLUGS` in `src/types/index.ts` and by the single `Fair` value in
  the CSV. Corrected in the bible
- **The CSV's `Town` column was being discarded.** It is the real municipality — Lockhart, Dripping Springs, San
  Marcos. It became `area` where it differs from the gate city: 107 of the 511. It is derived geography, not
  judgment, and it goes away with an `UPDATE`

**Gate G6 caught a real bug on the first attempt to apply.** The migration failed because `anon` had 4 leftover
write privileges in `public`. Cause: the `field_report_aggregates` view was created **after** the
`REVOKE ALL ... FROM anon`, so it inherited Supabase's default privileges and was born with INSERT, UPDATE, DELETE
and TRUNCATE granted. The whole migration rolled back, the database stayed intact, the blocks were reordered and the
second attempt passed. It stands as evidence that inline gates pay for themselves.

**Import verification.** Since the 155 kB migration did not fit in one `apply_migration` call, the 511 records went
in through `execute_sql` in four blocks — which introduces the risk of a silent transcription error. Instead of
trusting it, the database's contents were compared against the CSV by md5 checksum field by field: name, slug, type,
tier, star, visited, country, city, area, coordinates, address and `source_guides`. All match. (The first round
reported a divergence in `source_guides`, which was a bug in the verification script — the parser stripped the quotes
before reading the array. The data was always right.)

**Two decisions taken at the end of the session:**
- **One curator account, not two.** Edu accesses through Michael's account. It closes `BL-11` — the PRD, which said
  "single-user authentication", was right from the start. It does not change the schema: `curators` simply has one
  row. Accepted cost: `updated_by` stops saying *who* edited (`BL-17` updated)
- **History reconciled with GitHub.** The remote repo had existed since S01, with two founding commits; S03's
  `git init` had created an orphan history in parallel, with no common ancestor. Resolved with
  `git rebase --onto origin/main b6fef0c main`: the local "initial commit", which only replicated what was already on
  GitHub, was discarded and the following four replayed on top of the real history. A linear result, a final tree
  byte-identical to the one before the rebase, and a push that becomes a fast-forward — no `--force`, no founding
  commit lost. A `backup-pre-rebase` branch kept for safety
- **Record correction:** I had written in this file that "the remote never existed" and that it was "the third S01
  claim that does not hold up". Wrong on both counts — S01 was right. What failed was S03's diagnosis, which treated
  the absence of a local `.git` as the absence of a repository
- **The project moved house on GitHub.** The push to `AdminFeedpro/MichaelinMap` answered "Repository not found"
  even though reading worked. Cause: the credential stored in this machine's Git Credential Manager belongs to the
  **`AntonioTavaresDevWork`** account, which has no access to that repository — GitHub returns 404 instead of 403 so
  as not to confirm that a private repo exists. By Edu's decision I created `AntonioTavaresDevWork/MichaelinMap`
  (private) and pointed the remote there. The 9 commits went up, with the two founding ones (`038d040`, `d98f07c`)
  preserved. The old repository still exists, frozen at those two commits

- **Curator seeded at the end of the session.** The account `mikemyday@mikecofone.com` was created in the dashboard
  by Edu, and the row inserted through a versioned migration. The simulated-JWT test proved both sides of the model:
  a curator writes, and an authenticated-but-not-allowlisted account neither sees nor writes anything beyond what an
  anonymous visitor would see

**Lessons recorded (where to look later):**

| Lesson | Where it ended up |
|---|---|
| The GRANT/REVOKE block is always last in the migration — default privileges apply at the moment an object is created | `.claude/CLAUDE.md` + the `michaelinmap-migration` skill |
| `apply_migration` has a payload limit; a bulk load through a fallback requires a checksum against the source | `.claude/CLAUDE.md` + the `michaelinmap-migration` skill |
| The absence of a local `.git` is not a diagnosis of "the repository does not exist" | `.claude/CLAUDE.md`, workflow |
| Gates for privileges, orphan RLS and `search_path` catch what a visual review does not | the `michaelinmap-migration` skill |
| `execute_sql` returns only the last result; `RAISE EXCEPTION` serves as a report in a smoke test that must roll back | the `michaelinmap-migration` skill |
| RLS verification with simulated JWTs, testing both sides | the `michaelinmap-rls-policy` skill |

**`BL-14` closed along the way.** The five skills carried objects from WiseFacilities that do not exist here. The
most serious finding was not the orphan examples: `michaelinmap-naming` prescribed Brazilian formatting
(`1.234,56`, `DD/MM/YYYY`, `R$`), in direct contradiction with ADR-02 — an agent following the skill would have
produced wrong formatting in an English-language product.

**A useful curiosity:** `docs/S01.md`, which only appeared on this machine through the rebase, already recommended
converting the CSV into an idempotent seed migration instead of running `import-places.ts`, for the same reason we
decided on in this session — not exposing the service-role key. The decision was made without knowing that file
existed.

**Next session:** F-02 — Admin, with no blockers. All that is left is the `git push` and switching off signup, both
operational.

### 2026-08-06 — S03: Unblocking the environment

**What was done:** the working machine was not ready for F-01 and the STATUS did not record that. Four divergences
between the recorded and the real, all closed in this session.

**The divergences:**
- **The repository did not exist.** S01 recorded "GitHub repository created", but there was no `.git` in the local
  folder. Nothing was versioned. Fixed with `git init` + commit `b6fef0c`.
- **The Supabase MCP server did not load.** The config was in `mcp.json`; Claude Code reads `.mcp.json`. The
  `.gitignore` also only covered the dotted version — the file with the access token was exposed and would have
  entered the first commit. The rename solved both.
- **Node.js was not on the PATH.** `winget` reported the package as already installed and, indeed,
  `C:\Program Files\nodejs` existed with the machine PATH pointing at it — the session's shell had simply been
  started before. Without it, neither `npm` nor the MCP server (which runs through `npx`) worked.
- **`.env.local` was missing.** It existed as `env.local.download`, a name broken by the download. The Supabase
  client validates env at import, so nothing would start.

**An important consequence:** the "clean build + lint" gate that S02 recorded as met **was not reproducible** on
this machine — without `node_modules`, neither of them ran. It was re-run from scratch in this session and passed
clean, so F-00 holds. But the earlier record was a claim with no possible verification.

**Decisions taken:**
- Git identity configured local to the repository, not global
- The initial commit documents in its body that the gate could not run at the moment it was created — preferable to
  omitting it
- The database state was **not** re-confirmed: validation through the management API was blocked and not worked
  around. It stays as the first action of the next boot, through MCP

**Next session:** F-01 — Schema + data. Restart the session first, so `.mcp.json` loads.

### 2026-08-06 — S02: Scope and documentary foundation

**What was done:** a full analysis of the Claude Web material; data validation; a security audit of the schema; a
scope reassessment; writing the bible, the BACKLOG and this file.

**Decisions taken:**
- The project is personal, not a SaaS — no multi-tenancy (ADR-01)
- Product in English, internal docs in PT-BR (ADR-02)
- Google Places API cut; pre-classification of `cuisine` and `price_band` done by the CLI in the seed (ADR-06)
- My Maps sync cut (ADR-08)
- Unlisted guide, `noindex` (ADR-07)
- Codes in the complete version; field reports kept at Michael's request
- Roulette brought back — near-zero cost, high personality value
- Wise* framework reduced: no GANTT, DOMAIN_QUESTIONS, per-feature spec or agent pipeline (ADR-04)
- Launch strategy: publish the ~65 places with a star or `destination` first, instead of waiting for all 511

**Also in this session:** F-00 executed and closed. Deviations from the plan, all recorded in CLAUDE.md and the
BACKLOG: the current Vite template uses **oxlint** instead of ESLint; TypeScript 6 deprecated `baseUrl`, so the
`@/` alias uses only `paths`; shadcn's `sonner.tsx` came coupled to `next-themes` and was rewritten.

**Next session:** F-01 — Schema + data.

### 2026-08-05 — S01: Scaffold

Wise* structure instantiated, repository and Supabase project created. No product code, no migrations.
