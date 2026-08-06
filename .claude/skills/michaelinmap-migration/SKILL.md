---
name: michaelinmap-migration
description: ConvenÃ§Ãµes de migration SQL nos projetos Wise*. BEGIN/COMMIT explÃ­cito, blocos numerados, comentÃ¡rios WHY, hot-patch forward-declaration, saneamento manual de schema_migrations apÃ³s apply via Supabase MCP, GATEs internos de validaÃ§Ã£o. Use ao escrever ou aplicar qualquer migration Supabase no projeto.
---

> **Template Wise\*:** ao instanciar num projeto, copie para `.claude/skills/MICHAELINMAP-migration/SKILL.md` e renomeie `name:` para `MICHAELINMAP-migration`.

> âš ï¸ **Exemplos sÃ£o ilustrativos de SINTAXE, nÃ£o de schema.** Os snippets abaixo usam objetos do WiseFacilities (`audit_log`, `cargo_atual_texto()`, `is_admin_atual()`, `capacidades`, `seed_cargos_padrao()`) apenas para demonstrar a mecÃ¢nica (comentÃ¡rio WHY, forward-declaration, GATE, seed sem hardcode de UUID). **Ao instanciar, troque esses objetos pelos reais do seu projeto** â€” senÃ£o um agente pode inferir que tabelas/funÃ§Ãµes inexistentes existem. A estrutura (BEGIN/COMMIT, BLOCKs, GATEs, saneamento de `schema_migrations`) Ã© universal; os objetos dos exemplos, nÃ£o.

# PadrÃ£o de Migration â€” Wise*

## Estrutura do arquivo

```
supabase/migrations/YYYYMMDDHHMMSS_<feature>.sql

BEGIN;

-- ========================================================================
-- F-<NUMERO> â€” <TÃ­tulo da feature>
--
-- VersÃ£o: 1.0
-- Spec: docs/specs/F-<NUMERO>-spec.md
-- Investigation: docs/specs/F-<NUMERO>-investigation.md
-- ========================================================================

-- BLOCK 00 â€” Forward-declarations (se necessÃ¡rio)
-- BLOCK 01 â€” <descriÃ§Ã£o>
-- BLOCK 02 â€” <descriÃ§Ã£o>
-- ...
-- BLOCK N â€” GATEs de validaÃ§Ã£o

COMMIT;
```

## Regras inviolÃ¡veis

**BEGIN/COMMIT explÃ­citos.** Migration atÃ´mica. Se qualquer bloco falhar, rollback total.

**Blocos numerados.** Cada `BLOCK NN` agrupa operaÃ§Ãµes relacionadas (CREATE TABLE, ALTER, CREATE FUNCTION, etc.). Comentado no topo de cada bloco.

**ComentÃ¡rios WHY.** Cada decisÃ£o nÃ£o-Ã³bvia precisa ter um comentÃ¡rio explicando POR QUÃŠ. Sintaxe Ã© trivial; intenÃ§Ã£o nÃ£o. Exemplo:

```sql
-- WHY DEFAULT: padroniza populaÃ§Ã£o server-side. Audits via RPCs continuam
-- populando explicitamente (sobrescreve DEFAULT â€” comportamento esperado).
-- Audits via supabase-js NÃƒO precisam passar o campo.
ALTER TABLE audit_log ADD COLUMN cargo_no_momento text DEFAULT cargo_atual_texto();
```

**Sem hardcode de UUIDs.** Resolver por subquery em `empresas` (ou outra tabela base). Hardcode falha quando o tenant tiver outro id em outra instÃ¢ncia. Exemplo correto:

```sql
DO $SEED_ALL$
DECLARE v_company_id uuid;
BEGIN
  FOR v_company_id IN SELECT id FROM empresas LOOP
    PERFORM seed_cargos_padrao(v_company_id);
  END LOOP;
END $SEED_ALL$;
```

**Enum novo:** Postgres nÃ£o permite usar novo enum value na mesma transaÃ§Ã£o do `ADD VALUE`. Separar em migrations distintas quando necessÃ¡rio.

## Forward-declaration (hot-patch)

Se um bloco precisa de funÃ§Ã£o que sÃ³ Ã© criada em bloco posterior (ex: policies das tabelas novas usando `is_admin_atual()` criada depois), criar BLOCK 00 com stub:

```sql
-- BLOCK 00 â€” Forward-declaration de is_admin_atual()
-- Stub temporÃ¡rio. CREATE OR REPLACE no BLOCK 06 substitui pela versÃ£o real.
CREATE OR REPLACE FUNCTION is_admin_atual() RETURNS boolean AS $$
  SELECT false;  -- stub
$$ LANGUAGE sql STABLE;
```

## GATEs de validaÃ§Ã£o inline

No fim da migration (antes do COMMIT), 5-15 GATEs que validam estado esperado. PadrÃ£o:

```sql
DO $GATES$
DECLARE
  v_count integer;
BEGIN
  -- GATE G1: linhas seedadas
  SELECT COUNT(*) INTO v_count FROM capacidades;
  IF v_count <> <N_ESPERADO> THEN
    RAISE EXCEPTION 'GATE G1 FALHOU: capacidades tem % linhas, esperado <N_ESPERADO>', v_count;
  END IF;

  -- ... mais GATEs ...

  RAISE NOTICE 'F-XX GATE PASSOU: todas as N verificaÃ§Ãµes OK';
END $GATES$;
```

GATE FALHOU dispara EXCEPTION â†’ BEGIN/COMMIT roda rollback â†’ banco fica intacto. Crash visÃ­vel.

> âš ï¸ **SAVEPOINT/ROLLBACK TO nÃ£o Ã© gramÃ¡tica vÃ¡lida dentro de `DO $$ ... $$`.** Smokes inline devem ser read-only puros. Se exigir mutaÃ§Ã£o real pra validar, mover pra smoke query pÃ³s-apply (comentÃ¡rio no fim do arquivo).

## AplicaÃ§Ã£o via Supabase MCP

`mcp__supabase__apply_migration` **reescreve o timestamp** em `schema_migrations`. Saneamento manual obrigatÃ³rio apÃ³s apply:

```sql
DELETE FROM supabase_migrations.schema_migrations
WHERE version = '<TIMESTAMP_REESCRITO>';

INSERT INTO supabase_migrations.schema_migrations (version, name, statements)
VALUES ('<TIMESTAMP_DO_ARQUIVO>', '<nome_sem_extensao>', ARRAY[<STATEMENTS>]);
```

Validar pÃ³s-saneamento: entrada nova existe; entrada divergente removida; `version` cai cronologicamente entre predecessor e sucessor; banco funcional.

**Quem aplica:** SEMPRE o orquestrador (CLI#1). Executor escreve, nunca aplica.

## AplicaÃ§Ã£o via Dashboard SQL Editor

Quando MCP/CLI falha (arquivo grande, etc.): copiar arquivo inteiro â†’ SQL Editor â†’ Run. BEGIN/COMMIT funciona nativamente. Saneamento de `schema_migrations` Ã© manual (mesma sequÃªncia DELETE+INSERT acima).

**ExceÃ§Ã£o dashboard:** REVOKE/GRANT de 1-2 statements podem ir via dashboard sem migration formal, mas DEVEM ser registrados em `docs/STATUS.md` + na spec da feature + com data. DDL multi-statement / objetos novos = migration formal sempre.

## Rollback

Cada migration crÃ­tica tem arquivo rollback em `supabase/rollbacks/` (NÃƒO em `supabase/migrations/`, senÃ£o `supabase db push` aplica). Nomenclatura: `<timestamp+1>_<feature>_rollback.sql`. ConteÃºdo: reverte exatamente o que a migration aplicou.

## ReferÃªncias

- Exemplo canÃ´nico de origem: `WiseFacilities â€” supabase/migrations/20260522120000_f_rbac_v2.sql` (49 policies + 5 RPCs + 3 triggers + GATEs) e seu rollback estruturado.
- No projeto novo: apontar aqui a primeira migration grande aprovada como referÃªncia local.
