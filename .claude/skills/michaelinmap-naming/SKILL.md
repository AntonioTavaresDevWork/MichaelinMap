---
name: michaelinmap-naming
description: Convenções de nomes no Michaelin Map. DB snake_case, frontend camelCase, componentes PascalCase, arquivos kebab-case, formato en-US de número/data/moeda. Use ao nomear tabela, coluna, RPC, componente, hook, arquivo, ou ao formatar valores numéricos/datas/moeda na UI.
---

# Convenções de Nomes — Michaelin Map

> Exemplos são objetos **reais** deste banco. Se um nome citado aqui não existir mais,
> valide contra o schema vivo via MCP antes de usar.

## Tabela resumo

| Camada | Convenção | Exemplos reais |
|---|---|---|
| Tabelas DB | `snake_case` (plural) | `places`, `tags`, `place_tags`, `field_reports`, `curators` |
| Colunas DB | `snake_case` | `place_type`, `apple_id`, `source_guides`, `admin_only`, `requires_review` |
| Funções/RPCs SQL | `snake_case`, prefixo `rpc_` quando exposta ao client | `rpc_redeem_code`, `rpc_submit_field_report`, `is_curator`, `touch_updated_at` |
| Variáveis frontend TS | `camelCase` | `placeId`, `selectedTags`, `cityGate` |
| Componentes React | `PascalCase` | `PlaceCard`, `FilterPanel`, `ProtectedRoute` |
| Hooks | `camelCase` com prefixo `use` | `useSession`, `usePlaces`, `useFilterState` |
| Arquivos (todos) | `kebab-case` | `place-card.tsx`, `use-session.ts`, `admin-layout.tsx` |
| Tipos TS | `PascalCase` | `Place`, `Tag`, `FieldReport`, `PlaceType` |
| Constantes | `UPPER_SNAKE_CASE` | `SEEDED_TIER_SLUGS` |

> ⚠️ Arquivo de componente é **kebab-case** (`place-card.tsx`), NÃO `PlaceCard.tsx`. Erro comum.

## Conversão DB ↔ Frontend

O cliente Supabase JS **não** converte snake_case → camelCase. A conversão, quando existir,
acontece **na fronteira de acesso a dados** — no hook — e não espalhada pelos componentes.

**Regra prática deste projeto:** tipo populado por `select('*')` direto, sem mapeamento
explícito, é nomeado em `snake_case`, igual ao banco. É o que `src/types/index.ts` faz:

```typescript
export interface Place {
  place_type: PlaceType   // não placeType — vem cru do select('*')
  apple_id: string | null
  source_guides: string[] | null
}
```

Declarar `placeType` quando o banco devolve `place_type` resulta em `undefined` em runtime,
silenciosamente.

## Formato en-US — números, datas, moeda

**ADR-02: o produto é em inglês e usa formato en-US.** O guia é de Austin e o público é
anglófono. Nada de formato brasileiro na UI.

| Tipo | Formato | Exemplo |
|---|---|---|
| Número | Vírgula milhar, ponto decimal | `1,234,567.89` |
| Data UI | `MM/DD/YYYY` | `08/06/2026` |
| Data + hora UI | `MM/DD/YYYY h:mm a` | `08/06/2026 2:30 PM` |
| Data DB | ISO 8601 TIMESTAMPTZ | `2026-08-06T17:30:00Z` |
| Moeda | `$` prefixo, 2 decimais | `$1,234.56` |
| Faixa de preço | `$` a `$$$$` | `$$` |

Use `Intl.NumberFormat('en-US', …)` e `Intl.DateTimeFormat('en-US', …)`. Os formatadores já
existem em `src/lib/utils.ts` — usar os de lá antes de escrever outro.

> **Idioma por superfície:** UI, tags, perguntas, mensagens de erro e copy em **inglês**.
> Conversa com o Edu, Bíblia, STATUS e BACKLOG em **PT-BR**. Comentário de código e nome de
> variável em **inglês**.

## Prefixos semânticos

| Prefixo | Uso | Exemplo neste projeto |
|---|---|---|
| `rpc_` | Função SQL exposta ao client via `supabase.rpc()` | `rpc_redeem_code` |
| `is_` | Função booleana | `is_curator` |
| `touch_` | Trigger function que carimba timestamp | `touch_updated_at` |
| `use` | Hook React | `useSession` |

Prefixos do template Wise* que **não se aplicam aqui**: `has_` (não há capabilities),
`get_user_company_id` e afins (não há multi-tenant — ADR-01).

## Vocabulário do domínio — usar os termos certos

Confundir estes termos gera bug e confunde o Michael:

| Termo | O que é | O que NÃO é |
|---|---|---|
| **tier** | `destination`, `experience`, `fair`, `cool`. Dado editável, não constante | Não é a estrela |
| **starred** | Honraria que **cruza** os tiers, 22 de 511 | Não é um tier a mais (RN-03) |
| **visited** | `false` = Try List | Não é `status` |
| **status** | `unreviewed \| published \| closed \| hidden` | Não é soft delete por `deleted_at` (ADR-03) |
| **facet** | Agrupamento de tags: `cuisine`, `vibe`, `character`… | Não é a tag |
| **area** | Município ou bairro dentro da cidade-portão | Não é a cidade |

## Anti-padrões — não fazer

- ❌ Formato brasileiro na UI: `1.234,56`, `22/05/2026`, `R$` — viola o ADR-02
- ❌ Misturar idiomas num identificador: `lugarName` (escolher `placeName`)
- ❌ Camelizar sigla inteira: `bbqTag` ✅, `bBQTag` ❌
- ❌ Plural inconsistente: tabela DB sempre plural (`places`), componente singular (`PlaceCard`)
- ❌ Formatação manual: `value.toFixed(2)` para moeda — use `Intl.NumberFormat`
- ❌ Inventar `company_id` ou qualquer coluna de tenant — não existe (ADR-01)
