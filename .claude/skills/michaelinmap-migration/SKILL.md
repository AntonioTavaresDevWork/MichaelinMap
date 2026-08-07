---
name: michaelinmap-migration
description: Convenções de migration SQL no Michaelin Map. BEGIN/COMMIT explícito, blocos numerados, comentários WHY, GATEs inline de validação, bloco de GRANT sempre por último, saneamento manual de schema_migrations após apply via MCP, verificação por checksum em import de massa. Use ao escrever ou aplicar qualquer migration Supabase no projeto.
---

# Padrão de Migration — Michaelin Map

> Referência local aprovada: `supabase/migrations/20260806120000_f01_schema_rls_rpc.sql`
> (schema + RLS + RPCs, 12 GATEs) e `20260806120100_f01_seed_and_import.sql` (seed + import
> de 511 linhas, 18 GATEs). Comentários de SQL em **inglês** (ADR-02).

## Estrutura do arquivo

```
supabase/migrations/YYYYMMDDNNNNNN_<descricao>.sql

BEGIN;

-- ====================================================================
-- F-<NN> — <Título>
--
-- Version: 1.0
-- Requires: <migration anterior, se houver>
-- Backlog items closed here: BL-XX..BL-YY
-- ====================================================================

-- BLOCK 01 — Tables
-- BLOCK 02 — Indexes
-- ...
-- BLOCK NN-1 — Table grants        <- SEMPRE o penúltimo
-- BLOCK NN   — Validation gates    <- SEMPRE o último

COMMIT;
```

## Regras invioláveis

**BEGIN/COMMIT explícitos.** Migration atômica: um GATE que falha derruba tudo e o banco fica
intacto. Isso já pagou — ver "O caso do G6" abaixo.

**Blocos numerados**, cada um com um cabeçalho dizendo o que faz.

**Comentários WHY, não WHAT.** Sintaxe é trivial, intenção não:

```sql
-- WHY ON DELETE RESTRICT: dropping a tier row would silently erase the judgment
-- layer on every place carrying it. Deleting a tier in use must fail loudly.
tier text REFERENCES public.tiers(slug) ON UPDATE CASCADE ON DELETE RESTRICT,
```

**Sem hardcode de UUID.** Resolver por subquery na chave natural:

```sql
INSERT INTO public.curators (user_id, name)
SELECT id, 'Michael' FROM auth.users WHERE email = 'mikemyday@mikecofone.com'
ON CONFLICT (user_id) DO NOTHING;
```

**Idempotência por chave natural.** Todo seed usa `ON CONFLICT … DO NOTHING` sobre uma UNIQUE
real. Se a tabela não tem chave natural, a migration **cria uma** — foi o motivo de
`questions.prompt` ganhar UNIQUE (BL-05).

**Enum novo:** Postgres não permite usar valor novo de enum na mesma transação do `ADD VALUE`.
Separar em migrations distintas. (Este projeto usa CHECK constraint em vez de enum — mais fácil
de evoluir.)

**SAVEPOINT/ROLLBACK TO não é gramática válida dentro de `DO $$ … $$`.** Smoke inline tem de ser
read-only. Para validar mutação, ver "Smoke que precisa reverter" abaixo.

## O bloco de GRANT é sempre o último — lição que custou um apply

**Default privileges do Supabase são aplicadas no momento da criação do objeto.** Um
`REVOKE ALL … FROM anon` colocado antes de um `CREATE VIEW` não protege a view: ela nasce depois,
herdando GRANT completo.

Foi exatamente o que reprovou a primeira aplicação da F-01. O GATE de privilégios acusou
`anon holds 4 write grant(s) in public` — INSERT, UPDATE, DELETE e TRUNCATE na view
`field_report_aggregates`, criada dois blocos depois do REVOKE. A migration inteira voltou
atrás, os blocos foram trocados de ordem e a segunda tentativa passou.

**Regra: criar todos os objetos primeiro; revogar e conceder no penúltimo bloco.**

## GATEs de validação inline

5-20 GATEs antes do COMMIT. Falha dispara EXCEPTION → rollback total → crash visível.

```sql
DO $GATES$
DECLARE v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM public.places;
  IF v_count <> 511 THEN
    RAISE EXCEPTION 'GATE G4 FAILED: expected 511 places, found %', v_count;
  END IF;
  RAISE NOTICE 'F-01 gates passed: 18 of 18';
END $GATES$;
```

**GATEs que valem em qualquer migration que mexa em RLS ou grants** — estes pegam o que revisão
visual não pega:

```sql
-- privilégio de escrita sobrando para anon
SELECT count(*) INTO v_count FROM information_schema.role_table_grants
WHERE grantee = 'anon' AND table_schema = 'public'
  AND privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE');

-- tabela com RLS ligado e zero policies (trancada por acidente)
SELECT count(*) INTO v_count FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relrowsecurity = true
  AND NOT EXISTS (SELECT 1 FROM pg_policy p WHERE p.polrelid = c.oid);

-- SECURITY DEFINER sem search_path fixo
SELECT count(*) INTO v_count FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.prosecdef = true
  AND (p.proconfig IS NULL OR NOT EXISTS (
    SELECT 1 FROM unnest(p.proconfig) cfg WHERE cfg LIKE 'search_path=%'));

-- view que lê tabela sob RLS precisa de security_invoker
SELECT (c.reloptions @> ARRAY['security_invoker=on']) INTO v_bool
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relname = '<view>';
```

E um GATE de integridade do julgamento, em qualquer migration que toque `places`:

```sql
SELECT count(*) INTO v_count FROM public.places
WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL OR story IS NOT NULL
   OR last_visited IS NOT NULL OR price_band IS NOT NULL;
-- numa migration de import, tem de ser 0
```

## Aplicação via Supabase MCP

`mcp__supabase__apply_migration` **reescreve o `version`** com o timestamp dele. Saneamento
manual obrigatório depois:

```sql
DELETE FROM supabase_migrations.schema_migrations WHERE version = '<TIMESTAMP_REESCRITO>';
INSERT INTO supabase_migrations.schema_migrations (version, name, statements)
VALUES ('<TIMESTAMP_DO_ARQUIVO>', '<nome_sem_extensao>',
        ARRAY['-- see supabase/migrations/<arquivo>.sql']);
```

Validar depois: entrada nova existe, divergente sumiu, `version` cai cronologicamente entre
predecessor e sucessor.

**Quem aplica: sempre o orquestrador (CLI#1).** Executor escreve, nunca aplica.

### Limite de payload

`apply_migration` **não engole arquivo grande** — 155 kB (511 linhas de INSERT) não passou.
Opções, em ordem de preferência:

1. Quebrar em migrations menores, se o conteúdo permitir
2. SQL Editor do painel: cola o arquivo inteiro, BEGIN/COMMIT funciona nativamente
3. `execute_sql` em blocos, com o arquivo completo versionado no repo como artefato de verdade
   e `schema_migrations` preenchido à mão

**Se usar 2 ou 3 para carga de massa, verificação por checksum contra a fonte é obrigatória.**
Transcrição em blocos corrompe em silêncio — um endereço trocado não dispara erro nenhum.

```sql
-- no banco: hash por linha, agregado em ordem de hash (independe de collation)
WITH r AS (SELECT md5(col1||'|'||coalesce(col2,'')||'|'||…) AS h FROM public.<tabela>)
SELECT md5(string_agg(h, '' ORDER BY h)) FROM r;
```

O mesmo cálculo roda num script local sobre a fonte e os dois md5 têm de bater. Detalhes:

- **Ordenar por hash, não por chave textual.** `ORDER BY` no Postgres usa a collation do banco;
  `sort()` do JS usa code point. Ordens diferentes → hashes diferentes com dados idênticos
- **`numeric(p,s)::text` sempre traz `s` casas.** No script, `Number(v).toFixed(s)`
- Se der divergência, comparar por **grupo de campos** para localizar antes de suspeitar do dado.
  Na F-01 a primeira divergência era bug do script de verificação, não do banco

## Smoke que precisa reverter

`execute_sql` do MCP devolve **só o resultado do último statement**. Para um smoke que muta e
precisa voltar atrás, um `DO` block que termina em `RAISE EXCEPTION` com os resultados na
mensagem resolve as duas coisas: devolve tudo e reverte.

```sql
DO $SMOKE$
DECLARE r1 jsonb; r2 jsonb;
BEGIN
  UPDATE public.places SET status = 'published' WHERE slug = '<x>';
  PERFORM set_config('role', 'anon', true);
  r1 := public.rpc_submit_field_report(…);
  PERFORM set_config('role', 'postgres', true);
  RAISE EXCEPTION E'SMOKE (rolled back)\nr1 -> %\nr2 -> %', r1, r2;
END $SMOKE$;
```

O erro que volta **é** o relatório, e nada persiste.

## Rollback

Toda migration tem arquivo em `supabase/rollbacks/` (**não** em `migrations/`, senão
`supabase db push` aplica). Nome: `<timestamp+1>_<descricao>_rollback.sql`.

Rollback de dados que possam ter sido curados leva aviso e consulta de verificação no topo:

```sql
-- ⚠️ Só seguro antes de o curador ter trabalhado. Verificar primeiro:
--   SELECT count(*) FROM place_tags WHERE source = 'curator';
--   SELECT count(*) FROM places WHERE the_dish IS NOT NULL OR curator_note IS NOT NULL;
DELETE FROM public.place_tags WHERE source = 'suggested';   -- só palpite de máquina
```

## Antes de escrever qualquer SQL

**Schema vivo primeiro.** `list_tables` + `list_migrations` via MCP. Convenção não substitui
introspecção — coluna "óbvia" pode não existir. Este projeto usa `status`, não `deleted_at`
(ADR-03), e não tem `company_id` (ADR-01).
