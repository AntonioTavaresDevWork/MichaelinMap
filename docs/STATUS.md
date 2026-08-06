# Michaelin Map — STATUS

> Atualizado ao final de cada sessão de desenvolvimento.
> Lido no boot, junto de `.claude/CLAUDE.md`, `docs/MICHAELINMAP_BIBLIA.md` e `docs/BACKLOG.md`.

---

## 🗓️ Última atualização

**Data:** 2026-08-06
**Sessão:** S02 — Escopo e fundação documental
**Atualizado por:** Claude Code (orquestrador)

---

## 📍 Fase atual

**Fundação — escopo fechado, build não iniciado.**
Objetivo imediato: F-00 (scaffold) e F-01 (schema + dados).

---

## ✅ Concluído

### Sessão 01 — Scaffold
- [x] Repositório GitHub criado (`AdminFeedpro/MichaelinMap`)
- [x] Projeto Supabase criado (`woapimgpmlgqqvauckdy`) — **vazio**
- [x] MCP Supabase configurado
- [x] Estrutura `.claude/` (CLAUDE.md, init.md, 5 agentes, 5 skills)
- [x] `docs/prompts/` (orquestrador + executor)

### Sessão 02 — Escopo e fundação documental
- [x] Material do Claude Web analisado: PRD v1.0, CLAUDE.md do produto, PLAN.md, schema.sql, seed.sql, import-places.ts, CSV master
- [x] CSV validado linha a linha contra os números do PRD — batem todos (511 lugares, 273 restaurantes, 91 bares, 22 estrelas, 42 não visitados, 28 conflitos, 19 guias, 0 Apple IDs duplicados, 0 coordenadas faltando)
- [x] Auditoria do schema — 7 achados, 3 de severidade alta (`BL-01` a `BL-07` no BACKLOG)
- [x] Reavaliação de escopo: cortes de overengineering acordados com Edu
- [x] 5 decisões pendentes resolvidas (DP-01 a DP-05)
- [x] 8 ADRs registrados
- [x] `docs/MICHAELINMAP_BIBLIA.md` v2.0 escrita
- [x] `docs/BACKLOG.md` populado (20 itens)
- [x] `docs/STATUS.md` corrigido — a versão anterior afirmava "Setup concluído" com o banco vazio
- [x] Skills renomeadas `wise-*` → `michaelinmap-*`; BOM removido do frontmatter (impedia o parser de ler as descrições)

### F-00 — Fundação ✅
- [x] Vite 8 + React 19 + TypeScript 6 + Tailwind 4 + shadcn/ui (preset radix-nova)
- [x] 7 dependências instaladas: `@supabase/supabase-js`, `@tanstack/react-query`, `react-router-dom`, `zustand`, `sonner`, `lucide-react`, `maplibre-gl`
- [x] 9 componentes shadcn: button, input, label, card, sonner, separator, skeleton, badge, dropdown-menu
- [x] `src/lib/supabase/client.ts` — singleton que valida env no import
- [x] `src/lib/utils.ts` — `cn()`, `mapRpcError()`, formatadores **en-US**, `monthsSince()`, `slugify()` alinhado ao script de import
- [x] `src/types/index.ts` — 8 interfaces em snake_case espelhando o schema-alvo
- [x] `useSession()` + `ProtectedRoute` para `/admin`
- [x] Layouts público e admin; login funcional; placeholders nas rotas por vir
- [x] `noindex, nofollow` no `index.html` (ADR-07)
- [x] `.env.example` + `.env.local` (publishable key; gitignored)
- [x] **Gate:** `npm run build` e `npm run lint` limpos · dev server sobe e responde 200 em `/` e `/admin/login`

---

## 🔄 Em andamento

Nada em execução. F-00 fechada; aguardando início da F-01.

---

## ⏭️ Próxima ação

**F-01 — Schema + dados**

1. Migration do schema corrigido: 8 tabelas (`places`, `tiers`, `tags`, `place_tags`, `curators`, `codes`, `questions`, `field_reports`), constraints, índices
2. RLS conforme Bíblia §11 + função `is_curator()`
3. RPCs `rpc_redeem_code()` e `rpc_submit_field_report()`
4. View `field_report_aggregates` com `security_invoker = on`
5. Seed: 5 tiers, 93 tags + `Hype trap` (admin-only), 38 perguntas — idempotente
6. Import dos 511 lugares como `unreviewed`, com `cuisine` e `price_band` pré-sugeridos (`place_tags.source = 'suggested'`)
7. Saneamento de `schema_migrations` pós-apply

**Gate de saída:** 511 linhas em `places`, 93+1 em `tags`, 38 em `questions`, 5 em `tiers`. Reaplicar o seed não duplica nada. Nenhum lugar visível pelo anon key (tudo `unreviewed`).

Checklist de correções a aplicar: `BL-01` a `BL-07` no BACKLOG.

---

## 🚫 Blockers

Nenhum bloqueante.

**Atenção operacional:** signup precisa ser desabilitado no painel Supabase antes da F-02, e as duas contas de curador (Michael e Edu) precisam existir em `auth.users` para popular a tabela `curators`. Registrar aqui quando feito.

---

## 📊 Estado do banco

**Vazio.** 0 tabelas, 0 migrations. Confirmado via MCP em 2026-08-06.

---

## 🗺️ Roteiro

| # | Feature | Status | Sessões |
|---|---|---|---|
| F-00 | Fundação | ✅ Concluída (S02) | ~0,5 |
| F-01 | Schema + dados | ⬜ Próxima | ~1 |
| F-02 | Admin | ⬜ | ~2 |
| F-03 | Público (city gate, mapa, lista, detalhe) | ⬜ | ~2 |
| F-04 | Filtros facetados | ⬜ | ~1 |
| F-05 | Codes completo + Roulette | ⬜ | ~2 |
| F-06 | Field reports | ⬜ | ~1,5 |

Total estimado: ~10 sessões. A curadoria do Michael roda em paralelo a partir da F-02 — ver Bíblia §13.1.

---

## 📝 Log de sessões

### 2026-08-06 — S02: Escopo e fundação documental

**O que foi feito:** análise integral do material do Claude Web; validação dos dados; auditoria de segurança do schema; reavaliação de escopo; redação da Bíblia, do BACKLOG e deste arquivo.

**Decisões tomadas:**
- Projeto é pessoal, não SaaS — sem multi-tenant (ADR-01)
- Produto em inglês, docs internos em PT-BR (ADR-02)
- Google Places API cortada; pré-classificação de `cuisine` e `price_band` feita pelo CLI no seed (ADR-06)
- My Maps sync cortado (ADR-08)
- Guia não-listado, `noindex` (ADR-07)
- Codes na versão completa; field reports mantidos por pedido do Michael
- Roulette reincluída — custo próximo de zero, alto valor de personalidade
- Framework Wise* reduzido: sem GANTT, DOMAIN_QUESTIONS, spec por feature ou pipeline de agentes (ADR-04)
- Estratégia de lançamento: publicar os ~65 lugares com estrela ou `destination` primeiro, em vez de esperar os 511

**Também nesta sessão:** F-00 executada e fechada. Desvios em relação ao previsto, todos registrados no CLAUDE.md e no BACKLOG: o template Vite atual usa **oxlint** no lugar do ESLint; TypeScript 6 deprecou `baseUrl`, então o alias `@/` usa só `paths`; o `sonner.tsx` do shadcn vinha atrelado a `next-themes` e foi reescrito.

**Próxima sessão:** F-01 — Schema + dados.

### 2026-08-05 — S01: Scaffold

Estrutura Wise* instanciada, repositório e projeto Supabase criados. Nenhum código de produto, nenhuma migration.
