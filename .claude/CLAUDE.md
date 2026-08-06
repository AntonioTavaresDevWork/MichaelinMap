# CLAUDE.md — Michaelin Map

> Leia no início de TODA sessão. Regras inegociáveis do projeto.
> **Localização canônica:** `.claude/CLAUDE.md`.
> Fonte da verdade do produto: `docs/MICHAELINMAP_BIBLIA.md`.

## Identidade do projeto

- **Nome:** Michaelin Map — guia de lugares curado por uma pessoa
- **Natureza:** projeto pessoal do Edu Mello para o Michael. **Não é SaaS, não será monetizado, não tem cliente.**
- **Pasta:** `C:\Users\EMello\SaaS\MichaelinMap`
- **Supabase:** ID `woapimgpmlgqqvauckdy` · URL `https://woapimgpmlgqqvauckdy.supabase.co`
- **GitHub:** `AdminFeedpro/MichaelinMap` (privado)

> Este projeto usa o framework Wise* em **versão reduzida** (ADR-04 da Bíblia). Sem GANTT, sem
> DOMAIN_QUESTIONS, sem spec por feature, sem pipeline obrigatório de agentes. O PRD original
> em `docs/files/` cumpre o papel de spec. Mantidos: migrations versionadas, STATUS, BACKLOG e Bíblia.

## Idioma — atenção

| Onde | Idioma |
|---|---|
| Conversa com o Edu, Bíblia, STATUS, BACKLOG | **Português BR** |
| UI do produto, tags, perguntas, mensagens, copy | **Inglês** |
| Comentários de código, nomes de variáveis | Inglês |

Formato **en-US** no produto: `1,000.00`, `MM/DD/YYYY`, `$`. Nada de formato brasileiro (ADR-02).

## Documentação-chave

| Arquivo | Propósito |
|---|---|
| `docs/MICHAELINMAP_BIBLIA.md` | Fonte da verdade: domínio, schema, RNs, ADRs, escopo |
| `docs/STATUS.md` | Estado atual, próxima ação, log de sessões |
| `docs/BACKLOG.md` | Fonte única de pendências. Ler no boot junto do STATUS |
| `docs/files/` | Material de origem do Claude Web (PRD, PLAN, schema, seed, CSV). Referência, **não** fonte da verdade |
| `.claude/init.md` | Checklist de boot |
| `docs/prompts/0X-*.md` | Briefings de boot do orquestrador/executor |

**Não usados neste projeto** (ADR-04): `docs/GANTT-MichaelinMap.csv`, `docs/DOMAIN_QUESTIONS.md`, `docs/specs/`, `docs/qa/`.

## Build & Dev

```bash
npm run dev         # Vite dev server
npm run build       # tsc -b && vite build (type-check)
npm run lint        # oxlint
npm run preview     # serve o dist
```

- **Lint é `oxlint`**, não ESLint — é o default do template Vite atual. Config em `.oxlintrc.json`, com `src/components/ui/**` isento de `only-export-components` (arquivos gerados pelo shadcn).
- Path alias: `@/` → `./src/*`. Declarado em `vite.config.ts` e nos `tsconfig*.json` via `paths` **sem `baseUrl`** — TypeScript 6 deprecou `baseUrl`.
- Env: copiar `.env.example` → `.env.local`.
- Vitest ainda não configurado — entra quando houver o que testar.
- Antes de commit: `build` + `lint` limpos + validação SQL no banco via MCP.

## Stack obrigatória

- **React + Vite + TypeScript (SPA, sem SSR).** Não é Next.js — sem App Router, server actions ou API routes.
- UI: Tailwind + shadcn/ui. Verificar se o componente já existe antes de criar custom.
- **Mapa: MapLibre GL** (ADR-05). Não substituir por embed do Google.
- Forms: `useState` controlado, validação inline no `onSubmit`. Sem react-hook-form/zod.
- Notificações: `sonner` — `<Toaster richColors position="top-right" />` no `App.tsx`.
- State: React Query (server) + Zustand (UI, se necessário) · Routing: React Router DOM · Ícones: lucide-react
- Backend: Supabase (PostgreSQL 17 + Auth). Server-side, se necessário, em Edge Functions (Deno).
- Geocoding: Nominatim/OSM (ADR-06). **Sem Google Places API.**
- Deploy: Vercel.

## Arquitetura

```
src/  components/[ui|admin|public|shared]  hooks/  lib/supabase/  pages/  types/  utils/
supabase/  migrations/  rollbacks/
```

- **Não é multi-tenant** (ADR-01). Não existe `company_id`. Autorização é allowlist de curador.
- Fluxo: componente → hook customizado → React Query → Supabase client → PostgreSQL (RLS).
- Entrypoints: `main.tsx` (QueryClientProvider) → `App.tsx` (BrowserRouter) · `lib/supabase/client.ts` (singleton, valida env no import) · `lib/utils.ts` (`cn()` + `mapRpcError()`).

## Convenções de código

- DB/SQL: `snake_case` · RPCs expostas ao client: `rpc_<verbo>_<entidade>` · Frontend: `camelCase` · Componentes: `PascalCase` · Arquivos de componente: `kebab-case.tsx` · Hooks: `use-kebab-case.ts`
- Sem `any` — usar `unknown` + narrowing
- Comentários: WHY, not WHAT
- Mapeamento snake_case → camelCase acontece **na fronteira de acesso a dados**, não espalhado. Tipo populado por `select('*')` direto fica em snake_case.
- Um único objeto de estado de filtro, compartilhado por mapa e lista. Nunca dois. Serializa na URL.

## Segurança

- Nunca expor chave no client. `VITE_` só para URL do Supabase e anon key.
- **RLS obrigatório em todas as tabelas.** Modelo: curator allowlist via `is_curator()` — ver Bíblia §11.
- **`codes` nunca tem SELECT público** (RN-20). Validação só por `rpc_redeem_code()`.
- **`field_reports` nunca tem INSERT público direto** (RN-23). Só por `rpc_submit_field_report()`, que deriva o status no servidor.
- Signup desabilitado no Supabase. Escrita só para quem está em `curators`.
- Soft delete via `status`, não `deleted_at` (ADR-03).

## A camada de julgamento — regra máxima

`tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited` e as atribuições em `place_tags` são o **único dado insubstituível do sistema**. Nenhuma rotina automática escreve neles sem autorização explícita do Edu. Em qualquer trade-off, protege-se o julgamento.

## Migrations & schema

- Naming `YYYYMMDDNNNNNN_description.sql` · toda migration em `BEGIN; … COMMIT;` · aplicar via `mcp__supabase__apply_migration` (só o orquestrador).
- Postgres não permite usar novo valor de enum na mesma transação do `ADD VALUE`.
- Saneamento de `schema_migrations` pós-apply é obrigatório — detalhe na skill `michaelinmap-migration`.
- **Schema vivo primeiro:** validar tabelas/colunas via MCP (`list_tables`, `execute_sql`) antes de propor SQL. Convenção não substitui introspecção.
- SAVEPOINT/ROLLBACK TO não é gramática válida dentro de `DO $$ … $$`. Smoke inline deve ser read-only.

## Skills do projeto

| Skill | Quando invocar |
|---|---|
| `michaelinmap-migration` | Antes de escrever/aplicar migration SQL |
| `michaelinmap-rls-policy` | Antes de escrever/revisar RLS policy |
| `michaelinmap-rpc` | Antes de criar/modificar RPC `SECURITY DEFINER` |
| `michaelinmap-naming` | Ao nomear tabela/coluna/RPC/componente/hook/arquivo |

> ⚠️ As skills ainda trazem exemplos do WiseFacilities (`audit_log`, `capacidades`, `is_admin_atual()`) — objetos que **não existem aqui**. Adaptar após a F-01 (BL-14). Até lá, tratar os snippets como ilustração de sintaxe, nunca de schema.

## Fluxo de trabalho

1. Boot segue `.claude/init.md`. **Regra de ouro: nunca codar sem confirmar a próxima ação com o Edu.**
2. Apresentar plano antes de qualquer mutação. Aguardar OK explícito.
3. Decisão técnica é do CLI — recomendar UMA opção com justificativa enxuta, nunca um menu A/B/C. O Edu valida direção, não tecnicidade.
4. Build sem erros + lint limpo antes de commit.
5. Atualizar `docs/STATUS.md` ao final da sessão; pendência nova vai para `docs/BACKLOG.md`.
6. Divergência entre STATUS e estado real do código: **reportar antes de agir.**

## Sessões paralelas

Uma sessão nova nesta pasta é o **orquestrador** por padrão. Se o Edu abrir um executor em outro terminal, ele recebe briefing cirúrgico com os fatos do banco vivo embutidos (o executor não herda MCP nem contexto), escreve artefatos e **não** aplica migrations nem faz commit. Leitura paraleliza; mutação serializa — um terminal por vez na mesma área.

## Nunca fazer sem aprovação explícita

- DROP, TRUNCATE, DELETE sem WHERE
- Instalar nova dependência npm
- Modificar schema fora de migration versionada
- Alterar RLS existente
- Push direto na `main` sem confirmar
- Escrever em campo da camada de julgamento por rotina automática
- Reabrir decisão registrada como ADR na Bíblia §15 sem fato novo
