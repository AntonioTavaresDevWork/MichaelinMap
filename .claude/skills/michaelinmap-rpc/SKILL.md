---
name: michaelinmap-rpc
description: Padrão de função RPC SECURITY DEFINER no Michaelin Map. SET search_path obrigatório, validação server-side, retorno jsonb {ok,…}, GRANT a anon quando a RPC é o caminho público declarado na Bíblia §11. Use ao criar ou modificar funções RPC chamadas pelo frontend via supabase-js.
---

# Padrão de RPC — Michaelin Map

> Exemplos são as duas RPCs **reais** do projeto, em
> `supabase/migrations/20260806120000_f01_schema_rls_rpc.sql` BLOCK 08.

## O que este projeto NÃO tem

Antes de copiar padrão de outro projeto Wise*: aqui **não existe** `audit_log`, `company_id`,
`has_capacidade()`, `is_superadmin()` nem `perfis`. A auditoria é `places.updated_by` +
`updated_at`, e com conta única de curador o `updated_by` nem identifica pessoa (Bíblia §4).
Não invente essas tabelas.

## Quando uma RPC se justifica

Só quando o RLS **não dá conta sozinho**. Neste projeto há exatamente dois casos, ambos porque o
visitante anônimo precisa de uma capacidade que uma policy não consegue expressar com segurança:

| RPC | Por que não dá para ser policy |
|---|---|
| `rpc_redeem_code(p_code)` | O público não pode ter SELECT em `codes` (RN-20). Uma policy `code = <input>` ainda exporia a tabela; a RPC responde sobre **um** código por vez |
| `rpc_submit_field_report(…)` | O status da resposta é **derivado no servidor** de `questions.requires_review` (RN-23). Uma policy de INSERT deixaria o visitante escolher `published` |

Se a operação cabe numa policy, **não faça RPC**.

## Anatomia

```sql
CREATE OR REPLACE FUNCTION public.rpc_<verbo>_<entidade>(p_x <tipo>)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp      -- obrigatório
AS $$
DECLARE
  v_row public.<tabela>%ROWTYPE;
BEGIN
  -- 1. Validar a forma do input antes de qualquer leitura
  IF p_x IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_input');
  END IF;

  -- 2. Validar o estado no servidor — nunca confiar no que veio do client
  -- 3. Derivar o que o caller não pode escolher
  -- 4. Executar
  -- 5. Retornar

  RETURN jsonb_build_object('ok', true, 'status', v_status);
END;
$$;

REVOKE ALL ON FUNCTION public.rpc_<verbo>_<entidade>(<assinatura>) FROM public;
GRANT EXECUTE ON FUNCTION public.rpc_<verbo>_<entidade>(<assinatura>) TO anon, authenticated;
```

## GRANT a `anon` é a norma aqui — não o erro

O template Wise* manda revogar de `anon` e ter um GATE que falha se `anon` puder executar.
**Neste projeto isso está invertido:** as duas RPCs são o caminho público declarado na Bíblia
§11 e **precisam** do GRANT a `anon`. A segurança vem da validação dentro da função, não do
GRANT ausente.

O GATE correto aqui é o oposto — confirmar que as RPCs públicas continuam executáveis:

```sql
SELECT count(*) INTO v_count
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN ('rpc_redeem_code','rpc_submit_field_report')
  AND has_function_privilege('anon', p.oid, 'EXECUTE');
IF v_count <> 2 THEN
  RAISE EXCEPTION 'GATE FALHOU: % de 2 RPCs executáveis por anon', v_count;
END IF;
```

`REVOKE ALL … FROM public` seguido de `GRANT … TO anon, authenticated` é a forma: torna a
concessão explícita em vez de herdada.

## Retorno padronizado

`{"ok": true, …}` / `{"ok": false, "error": "<código>"}`. Sempre jsonb, mesmo para operação
trivial — permite evoluir sem quebrar o contrato com o frontend.

**Códigos de erro em inglês, snake_case**, porque a UI é em inglês (ADR-02):
`invalid_answer`, `place_not_available`, `question_not_available`, `rate_limited`,
`already_answered`. O frontend traduz para copy com `mapRpcError()` em `src/lib/utils.ts`.

Preferir **retorno** a `RAISE EXCEPTION` para falha esperada de negócio: exceção vira erro HTTP
no supabase-js e obriga o frontend a distinguir falha de rede de "código não existe". Reservar
`RAISE EXCEPTION` para o que é realmente excepcional.

## Não vazar informação pela forma da resposta

`rpc_redeem_code` devolve **exatamente** `{"ok": false}` em todo caminho de falha — código
inexistente, inativo, fora da janela de datas, input vazio. Qualquer diferença entre esses casos
transforma a função num oráculo e devolve a enumeração que remover o SELECT público evitou
(RN-20).

```sql
IF NOT FOUND THEN
  RETURN jsonb_build_object('ok', false);   -- sem 'error', sem detalhe
END IF;
```

Contraste: `rpc_submit_field_report` **pode** detalhar o erro, porque ali não há segredo a
proteger — o visitante precisa saber se já respondeu ou se caiu no rate limit.

## Derivar no servidor o que o caller não pode escolher

```sql
v_status := CASE WHEN v_question.requires_review THEN 'pending' ELSE 'published' END;
```

O visitante manda a resposta, nunca o status (RN-23). Mesma lógica para o truncamento: texto
livre é cortado em 40 caracteres **na função**, não confiado ao client (RN-24).

```sql
v_answer := jsonb_set(p_answer, '{value}', to_jsonb(left(btrim(p_answer->>'value'), 40)));
```

## Rate limit por `session_hash`

`session_hash` serve só para limitar, nunca para identificar. Dois controles:

- teto por janela: 30 respostas por hora
- uma resposta por `(session_hash, place_id, question_id)` — sem isso, um visitante entediado
  entorta um agregado sozinho, e o agregado é a feature (RN-25)

É contornável com sessão nova, e tudo bem: o objetivo é atrito, não identidade.

## Regras invioláveis

- `SET search_path = public, pg_temp` em toda função `SECURITY DEFINER`
- Validar estado no servidor antes de qualquer side effect
- Naming `rpc_<verbo>_<entidade>`
- Falha de negócio → retorno `{"ok": false, …}`; exceção só para o excepcional
- Resposta de falha **uniforme** quando distinguir casos vaza informação
- Campo que o caller não pode escolher é derivado no servidor, sempre
- Nunca escrever na camada de julgamento (`tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited`, atribuições em `place_tags`) sem autorização explícita do Edu

## Referências

- RPCs reais: `20260806120000_f01_schema_rls_rpc.sql` BLOCK 08
- Smoke com as duas RPCs, incluindo truncamento e duplicata: log da S04 em `docs/STATUS.md`
