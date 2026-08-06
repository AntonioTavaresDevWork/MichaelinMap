---
name: michaelinmap-rpc
description: PadrÃ£o de funÃ§Ã£o RPC SECURITY DEFINER nos projetos Wise*. SET search_path obrigatÃ³rio, validaÃ§Ãµes server-side, auditoria na tabela declarada pelo projeto, REVOKE pÃºblico + GRANT seletivo (com exceÃ§Ã£o de portal pÃºblico via ADR), retorno padronizado JSON. AutorizaÃ§Ã£o e auditoria adaptam ao modelo declarado na BÃ­blia. Use ao criar ou modificar funÃ§Ãµes RPC chamadas pelo frontend via supabase-js.
---

> **Template Wise\*:** ao instanciar num projeto, copie para `.claude/skills/MICHAELINMAP-rpc/SKILL.md` e renomeie `name:` para `MICHAELINMAP-rpc`.

# PadrÃ£o de RPC â€” Wise*

## Anatomia mÃ­nima

```sql
CREATE OR REPLACE FUNCTION rpc_<acao>(
  p_param1 <tipo>,
  p_param2 <tipo>
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_company_id uuid;
  v_result jsonb;
BEGIN
  -- 1. Resolver company_id do caller
  SELECT company_id INTO v_company_id
  FROM perfis WHERE id = auth.uid();

  IF v_company_id IS NULL AND NOT is_superadmin() THEN
    RAISE EXCEPTION 'UsuÃ¡rio sem company_id vÃ¡lido';
  END IF;

  -- 2. Validar permissÃ£o
  IF NOT (is_admin_atual() OR has_capacidade('<capability>')) THEN
    RAISE EXCEPTION 'PermissÃ£o negada: requer capability <capability>';
  END IF;

  -- 3. Validar inputs (negÃ³cio) â€” V1..VN numeradas
  --    Para operaÃ§Ãµes decisÃ³rias: SELECT ... FOR UPDATE no inÃ­cio (race-safe)
  -- ...

  -- 4. Executar a operaÃ§Ã£o principal
  -- ...

  -- 5. Registrar no audit_log
  INSERT INTO audit_log (
    company_id, tabela, registro_id, acao,
    campo_alterado, valor_anterior, valor_novo,
    usuario_id, cargo_no_momento
  ) VALUES (
    v_company_id, '<tabela>', <id>, '<acao>',
    NULL, NULL, to_jsonb(<dados>)::text,
    auth.uid(), cargo_atual_texto()
  );

  -- 6. Retornar resultado estruturado
  RETURN jsonb_build_object(
    'success', true,
    'data', v_result
  );
END;
$$;

REVOKE ALL ON FUNCTION rpc_<acao> FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION rpc_<acao> TO authenticated;
```

## Dois pontos que dependem do modelo declarado na BÃ­blia

A anatomia acima reflete o **Modelo B** (capability-RBAC) do WiseFacilities. Dois elementos se adaptam Ã  escolha do projeto (ver skill `MICHAELINMAP-rls-policy` â†’ "Modelo de autorizaÃ§Ã£o"):

1. **AutorizaÃ§Ã£o do caller:**
   - Modelo B â†’ `IF NOT (is_admin_atual() OR has_capacidade('<cap>'))`.
   - Modelo A (tenant-scoped) â†’ validar sÃ³ o tenant (`v_company_id` resolvido + escopo da operaÃ§Ã£o); sem `has_capacidade()`.

2. **Destino da auditoria:** o framework usa `audit_log` por default, mas **o projeto declara sua tabela de auditoria na BÃ­blia**. Se o projeto jÃ¡ tem outra (ex: `sync_log` com `dados_antes`/`dados_depois`/`device_info`), a RPC grava nela, no schema real â€” nÃ£o force `audit_log`/`cargo_no_momento`/`varchar(20)`. O princÃ­pio (toda mutaÃ§Ã£o auditada server-side) Ã© universal; o schema da tabela, nÃ£o.

## Regras inviolÃ¡veis (ambos os modelos)

**`SET search_path = public, pg_temp` obrigatÃ³rio.** Sem isso, atacante pode criar schema malicioso que sequestra a funÃ§Ã£o. PadrÃ£o de seguranÃ§a da Supabase.

**ValidaÃ§Ã£o de permissÃ£o ANTES de qualquer side effect.** RAISE EXCEPTION cedo. NÃ£o fazer trabalho que vai ser desfeito. (Modelo B valida capability; Modelo A valida tenant + escopo.)

**Naming:** RPCs novas usam `rpc_<verbo>_<entidade>`. RPCs legadas sem prefixo (em projeto prÃ©-existente) sÃ£o aceitas â€” nÃ£o renomear o que jÃ¡ estÃ¡ em uso pelo frontend.

**Race-safety em RPCs decisÃ³rias:** `SELECT ... FOR UPDATE` no inÃ­cio para travar a linha decisÃ³ria (duas abas decidindo simultaneamente â†’ `40001`).

**Auditoria sempre populada**, na tabela declarada pelo projeto (ver acima). No `audit_log` padrÃ£o: `cargo_no_momento` server-side, `acao` em `varchar(20)`, flags em `valor_novo text` via `jsonb_build_object(...)::text`.

**Mensagens de erro em PT-BR** via `RAISE EXCEPTION ... USING ERRCODE = '<cÃ³digo>'` â€” frontend traduz com `mapRpcError`. ERRCODEs comuns: `22023`, `42501`, `P0002`, `23505`, `40001`, `P0001`.

**REVOKE FROM PUBLIC, anon + GRANT TO authenticated por default.** AtenÃ§Ã£o (liÃ§Ã£o WF S39): `REVOKE ... FROM PUBLIC` sozinho **nÃ£o** tira o EXECUTE do role `anon` â€” o Supabase concede EXECUTE direto a `anon`/`authenticated` em funÃ§Ãµes novas via *default privileges*. Revogar de `PUBLIC, anon` explicitamente. Sempre via migration â€” nunca via dashboard. **Inclua um GATE inline** que falha o apply se `anon` ainda puder executar:

> **ExceÃ§Ã£o declarada (ADR):** RPCs de acesso pÃºblico intencional (ex: portal sem login via token, `SECURITY DEFINER`) **mantÃªm** o GRANT a `anon` â€” desde que coberto por um ADR na BÃ­blia. Nesse caso o GATE de anon NÃƒO se aplica Ã quela funÃ§Ã£o; a seguranÃ§a vem da validaÃ§Ã£o do token dentro da RPC.

```sql
IF has_function_privilege('anon', 'rpc_<acao>(<assinatura>)', 'EXECUTE') THEN
  RAISE EXCEPTION 'GATE FALHOU: anon ainda executa rpc_<acao>';
END IF;
```

(dentro do BEGIN/COMMIT â†’ rollback automÃ¡tico se vazar).

**Retorno em jsonb estruturado.** Mesmo pra ops simples. Permite evoluir sem quebrar contrato com o frontend. ConvenÃ§Ã£o: `{success: bool, data: {...}, error: text|null}`.

## ReferÃªncias

- Origem do padrÃ£o: WiseFacilities, migration `20260522120000_f_rbac_v2.sql` BLOCK 10 (5 RPCs canÃ´nicas: `rpc_ajustar_estoque`, `rpc_decidir_autorizacao_fora_tr`, `rpc_definir_minimos_em_massa`, `rpc_marcar_contagem_fisica`, `rpc_reatribuir_unidades_almoxarifado`).
- No projeto novo: apontar aqui as primeiras RPCs aprovadas como referÃªncia local.
