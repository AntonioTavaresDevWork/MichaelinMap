# CLAUDE.md

> Leia no inÃ­cio de TODA sessÃ£o. Estas sÃ£o as regras inegociÃ¡veis do projeto.
> **LocalizaÃ§Ã£o canÃ´nica:** `.claude/CLAUDE.md` (nÃ£o na raiz).
> **PadrÃµes de implementaÃ§Ã£o detalhados** (hook/RPC/audit/cascata/override por feature): `docs/PATTERNS.md` â€” consultar sob demanda, nÃ£o duplicar aqui.
> *(Template Wise\* v1.2 â€” espelho do ApÃªndice C do Manual. Substituir `MICHAELINMAP` / `MICHAELINMAP` / `MICHAELINMAP` / `[id]`.)*

## Identidade do projeto

- **Nome:** MICHAELINMAP â€” projeto Wise* de Edu Mello / Feedback ComunicaÃ§Ã£o
- **Pasta:** `C:\Users\EMello\SaaS\SaaS_MICHAELINMAP`
- **Supabase:** ID `[id]` Â· URL `https://[id].supabase.co`
- **GitHub:** `AdminFeedpro/MICHAELINMAP` (privado)

## Modelo operacional â€” quem Ã© vocÃª nesta sessÃ£o

Por default, uma sessÃ£o nova aberta nesta pasta Ã© o **orquestrador**, salvo instruÃ§Ã£o explÃ­cita do Edu.

- **Orquestrador CLI (principal)** â€” decide arquitetura, mantÃ©m `docs/STATUS.md`, aplica migrations via MCP. Briefing completo: `docs/prompts/01-orquestrador-cli.md`.
- **Executor CLI (paralelo)** â€” outra sessÃ£o Claude Code reportando ao orquestrador; nÃ£o decide escopo sozinha. Briefing: `docs/prompts/02-executor-cli.md`.
- **Sparring Partner (Claude Web)** â€” instÃ¢ncia no claude.ai para peer review/segunda opiniÃ£o; **NÃƒO toca cÃ³digo**.

> **CoordenaÃ§Ã£o multi-CLI (inegociÃ¡vel):** o orquestrador **NÃƒO roda agentes in-process** (Agent tool). Quando precisar de um agente, escreve um **briefing copiÃ¡vel** que o Edu cola em outro terminal Claude Code â€” tipicamente um **produtor** + um **crÃ­tico adversarial**. O agente lÃª seu `.claude/agents/0X-*.md`, nÃ£o herda MCP nem contexto; embuta os fatos do banco vivo no briefing e **vocÃª** aplica as migrations.

## DocumentaÃ§Ã£o-chave

| Arquivo | PropÃ³sito |
|---|---|
| `docs/MICHAELINMAP_BIBLIA.md` | Fonte da verdade: domÃ­nio, schema, regras de negÃ³cio, roteiro |
| `docs/STATUS.md` | Estado atual, prÃ³xima aÃ§Ã£o, log de sessÃµes |
| `docs/BACKLOG.md` | **Fonte Ãºnica de pendÃªncias** (dÃ­vida tÃ©cnica, UX, TBDs, decisÃµes). Ler no boot junto do STATUS |
| `docs/PATTERNS.md` | PadrÃµes de implementaÃ§Ã£o por feature (referÃªncia sob demanda) |
| `docs/GANTT-MICHAELINMAP.csv` | Roadmap vivo granular (sub-feature) â€” bÃºssola + prestaÃ§Ã£o de contas ao cliente. Atualizado pelo `/finalizar` |
| `docs/prompts/0X-*.md` | Briefings de boot do orquestrador/executor |
| `docs/specs/F-XX-*.md` | Spec funcional + investigation por feature (regras, US, edge cases, DPs) |
| `docs/qa/F-XX-*.md` | RelatÃ³rios de QA / roteiros de smoke por feature |
| `docs/DOMAIN_QUESTIONS.md` | Perguntas de domÃ­nio (moat do produto) |
| `.claude/init.md` | **Leitura obrigatÃ³ria** ao iniciar sessÃ£o â€” checklist de boot |
| `.claude/agents/0X-*.md` | Briefings dos 5 agentes (business, data, frontend, qa, technical-writer) |
| `.claude/skills/MICHAELINMAP-*/` | 5 skills que codificam as convenÃ§Ãµes inegociÃ¡veis |

## Build & Dev Commands

```bash
npm run dev         # Dev server (Vite, hot reload)
npm run build       # tsc -b && vite build  (type-check)
npm run lint        # ESLint (eslint .)
npm run test:run    # Vitest (CI â€” run once) Â· npm run test (watch)
```

- Path alias: `@/` â†’ `./src/*` Â· ESLint ignora `.claude/` e `dist/`
- Env: copiar `.env.example` â†’ `.env.local`
- ValidaÃ§Ã£o geral antes de commit: `build` (type-check) + `lint` limpo + QA SQL no banco via Supabase MCP.
- **Smoke fixtures** `smoke_*.json` sÃ£o one-shot e gitignored; se virarem regressÃ£o, mover pra `tests/fixtures/` (sem o prefixo `smoke_`).

## Stack obrigatÃ³ria

- Frontend: React + Vite + TypeScript (SPA â€” **sem SSR**). **Este projeto usa Vite, NÃƒO Next.js** â€” sem App Router, server actions, middleware Next ou API routes. Server-side roda em Supabase Edge Functions (Deno).
- UI: Tailwind CSS + shadcn/ui. `components.json` na raiz define os aliases; respeitar ao rodar `npx shadcn add`. Verificar se componente existe ANTES de criar custom.
- Forms: estado controlado manual via `useState` (sem `react-hook-form`/`zod`). ValidaÃ§Ã£o inline no `onSubmit`.
- NotificaÃ§Ãµes: `sonner` â€” `<Toaster richColors position="top-right" />` em `App.tsx`. Feedback de mutations via `toast.success/error` no `onSuccess/onError` do hook.
- Tabelas: TanStack Table Â· State: React Query + Zustand Â· Routing: React Router DOM Â· Icons: lucide-react
- Backend: Supabase (PostgreSQL 17 + Auth + Storage + Edge Functions)
- Deploy: Vercel

## Arquitetura

```
src/  components/[ui|modulo]  hooks/  lib/supabase/  pages/  types/  utils/
supabase/  migrations/  rollbacks/  functions/
```

- **Multi-tenant:** toda tabela tem `company_id`, RLS filtra por empresa.
- **Fluxo de dados:** Componente â†’ hook customizado â†’ React Query â†’ Supabase client â†’ PostgreSQL (RLS por `company_id`).
- Entrypoints: `main.tsx` (QueryClientProvider) â†’ `App.tsx` (BrowserRouter + Routes) Â· `lib/supabase/client.ts` (singleton, valida env no import) Â· `lib/utils.ts` (`cn()` + `mapRpcError()`).

## ConvenÃ§Ãµes de cÃ³digo

- DB/SQL: `snake_case` Â· RPCs expostas ao client: `rpc_<verbo>_<entidade>` Â· Frontend: `camelCase` Â· Componentes: `PascalCase` Â· Arquivos de componente: `kebab-case.tsx` Â· Hooks: `use-kebab-case.ts`
- Sem `any` â€” usar `unknown` + narrowing
- ComentÃ¡rios de cÃ³digo: WHY, not WHAT (idioma: inglÃªs) Â· Textos de UI em PortuguÃªs BR
- Detalhe e snippets canÃ´nicos: skill `MICHAELINMAP-naming`.

## Formato BR obrigatÃ³rio

- NÃºmeros `1.000,00` (ponto milhar, vÃ­rgula decimal) Â· Datas UI `DD/MM/YYYY` Â· Datas banco ISO 8601 (TIMESTAMPTZ) Â· Moeda prefixo `R$` (2 casas) Â· Textos de UI em PortuguÃªs BR.

## Regras de seguranÃ§a

- Nunca expor chaves no client. `VITE_` sÃ³ pra Supabase URL + anon key. `SERVICE_ROLE_KEY`/`ANTHROPIC_API_KEY` sÃ³ em Edge Functions.
- RLS obrigatÃ³rio em TODAS as tabelas â€” verificar antes de qualquer query. `company_id` em todas; RLS filtra por company.
- AutorizaÃ§Ã£o conforme o **Modelo declarado na BÃ­blia** (Tenant-scoped OU Capability-RBAC). NUNCA hardcodear papel. Snippet canÃ´nico e os dois modelos na skill `MICHAELINMAP-rls-policy`.
- Soft delete (`deleted_at`) em vez de DELETE fÃ­sico (exceto logs imutÃ¡veis).
- Dados pessoais (CPF, email, telefone) **nunca** enviados para LLM. Toda interaÃ§Ã£o com Claude API logada (input, output, tokens, custo, timestamp).

## Migrations & schema

- Naming `YYYYMMDDNNNNNN_description.sql` Â· toda migration em `BEGIN; â€¦ COMMIT;` Â· aplicar via `mcp__supabase__apply_migration` (sÃ³ o orquestrador).
- **Cuidado:** Postgres nÃ£o permite usar novo enum value na mesma transaÃ§Ã£o do `ADD VALUE`.
- **Saneamento `schema_migrations` pÃ³s-apply Ã© obrigatÃ³rio** (o apply reescreve o `version`) â€” detalhe e GATEs na skill `MICHAELINMAP-migration`.
- **REVOKE/GRANT de 1-2 statements** podem ir via dashboard sem migration formal, mas DEVEM ser registrados em `docs/STATUS.md` + na spec da feature + com data. DDL multi-statement / objetos novos = migration formal sempre.
- **Schema vivo:** introspect via MCP (`list_tables`, `list_migrations`, `execute_sql`). Lista de migrations/tabelas vivas fica em `docs/STATUS.md` â€” nÃ£o duplicar aqui.

## Skills do projeto (invocar via `/skill` ANTES de escrever o artefato)

| Skill | Quando invocar |
|---|---|
| `MICHAELINMAP-migration` | Antes de escrever/aplicar qualquer migration SQL |
| `MICHAELINMAP-rls-policy` | Antes de escrever/revisar RLS policy |
| `MICHAELINMAP-rpc` | Antes de criar/modificar RPC `SECURITY DEFINER` |
| `MICHAELINMAP-naming` | Ao nomear tabela/coluna/RPC/componente/hook/arquivo ou formatar nÃºmero/data/moeda BR |
| `MICHAELINMAP-spec-format` | Ao escrever spec de feature nova (`docs/specs/F-XX-spec.md`) |

## Agentes de dev disponÃ­veis

| Agente | Briefing | Quando usar |
|---|---|---|
| `business-architect` | `.claude/agents/01-*.md` | Regra de negÃ³cio nova ou ambÃ­gua |
| `data-architect` | `.claude/agents/02-*.md` | Qualquer mudanÃ§a de schema |
| `frontend-engineer` | `.claude/agents/03-*.md` | Build de componentes e hooks |
| `qa-security-auditor` | `.claude/agents/04-*.md` | Antes de fechar qualquer feature |
| `technical-writer` | `.claude/agents/05-*.md` | AtualizaÃ§Ã£o de docs e `docs/STATUS.md` |

**Como acionar:** o orquestrador NÃƒO usa o Agent tool in-process (ver "CoordenaÃ§Ã£o multi-CLI" acima). Entrega um **briefing copiÃ¡vel** que manda o CLI ler o `.claude/agents/0X-*.md` e assumir o papel. Pipeline: business â†’ data â†’ frontend â†’ qa â†’ technical-writer; nenhum comeÃ§a sem o anterior aprovado por Edu. ExceÃ§Ã£o: hot-fix cirÃºrgico durante smoke (1-2 arquivos) o orquestrador edita inline pra desbloquear.

## Camada de IA â€” Regras

- ReferÃªncia: seÃ§Ã£o "Camada de InteligÃªncia" da BÃ­blia + `docs/DOMAIN_QUESTIONS.md`.
- Toda chamada a LLM passa por Supabase Edge Function â€” NUNCA client-side direto.
- IA nunca executa aÃ§Ã£o crÃ­tica sozinha â€” humano revisa (limites de autonomia na BÃ­blia).
- Fallback obrigatÃ³rio: se a IA nÃ£o consegue responder com confianÃ§a, redirecionar para aÃ§Ã£o humana.
- Logging: toda chamada salva input, output, modelo, tokens, custo, timestamp.

## Fluxo de trabalho obrigatÃ³rio

1. Boot segue `.claude/init.md` (BÃ­blia + `docs/STATUS.md` + BACKLOG + DOMAIN_QUESTIONS + tipos). **Regra de ouro: nunca codar sem confirmar a prÃ³xima aÃ§Ã£o com Edu.**
2. Schema: data-architect valida/cria migration antes do frontend.
3. Build sem erros + lint limpo (warnings prÃ©-existentes documentados sÃ£o aceitos) antes de qualquer commit.
4. Atualizar `docs/STATUS.md` ao final de cada sessÃ£o.

## Nunca fazer sem aprovaÃ§Ã£o explÃ­cita

- DROP, TRUNCATE, DELETE sem WHERE
- Instalar nova dependÃªncia npm
- Modificar schema fora de migration versionada
- Alterar RLS policies existentes
- Push direto na `main` sem confirmar com Edu
- Alterar limites de autonomia da IA ou nÃ­veis de confianÃ§a mÃ­nimos
- Enviar dados pessoais para APIs externas
