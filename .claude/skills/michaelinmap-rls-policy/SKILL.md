---
name: michaelinmap-rls-policy
description: Padrões de RLS policy no Michaelin Map. Modelo curator allowlist via is_curator(), sem multi-tenant e sem capabilities. Verificação obrigatória com JWT simulado nos dois sentidos. Use ao escrever, revisar ou refatorar Row Level Security policies em qualquer tabela do projeto.
---

# Padrão de RLS Policy — Michaelin Map

> Exemplos são as policies **reais** aplicadas em `20260806120000_f01_schema_rls_rpc.sql`.
> Validar contra o banco vivo via MCP antes de escrever policy nova.

## Modelo de autorização: curator allowlist

**Não é tenant-scoped e não é capability-RBAC** (ADR-01). Não existe `company_id`, não existe
`has_capacidade()`, não existe `is_superadmin()`. Há um guia, um curador e visitantes anônimos.

O predicado de escrita é sempre o mesmo:

```sql
CREATE POLICY <tabela>_curator_all ON public.<tabela>
  FOR ALL TO authenticated
  USING (public.is_curator())
  WITH CHECK (public.is_curator());
```

A leitura pública varia por tabela e é o que exige pensamento.

```sql
CREATE POLICY <tabela>_public_select ON public.<tabela>
  FOR SELECT TO anon, authenticated
  USING (<predicado de publicação>);
```

## `is_curator()` — por que é SECURITY DEFINER

```sql
CREATE OR REPLACE FUNCTION public.is_curator()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (SELECT 1 FROM public.curators WHERE user_id = auth.uid());
$$;
```

`curators` não tem policy de SELECT público. Uma função `SECURITY INVOKER` lendo essa tabela de
dentro de uma policy enxergaria **zero linhas sempre** — e todo mundo seria negado. Direitos de
definer contornam o RLS nessa única consulta, que é exatamente o propósito.

`SET search_path` é obrigatório: sem ele, um schema malicioso no `search_path` do caller pode
sequestrar a função.

## Mapa de leitura pública (Bíblia §11)

| Tabela | SELECT público | Observação |
|---|---|---|
| `places` | `status = 'published'` | RN-07 — nada nasce visível |
| `tiers` | `active = true` | |
| `tags` | `active = true AND admin_only = false` | RN-14 — `Hype trap` some do público |
| `place_tags` | duplo `EXISTS`: place publicado **E** tag ativa não-admin | vazava id de lugar não publicado |
| `codes` | **nenhum** | RN-20 — só via `rpc_redeem_code()` |
| `questions` | `active = true` | |
| `field_reports` | `status = 'published'` | INSERT só via RPC |
| `curators` | **nenhum** | quem está na allowlist não é dado público |

O caso de `place_tags` merece atenção — é o padrão para toda tabela de junção:

```sql
USING (
  EXISTS (SELECT 1 FROM public.places p
          WHERE p.id = place_tags.place_id AND p.status = 'published')
  AND EXISTS (SELECT 1 FROM public.tags t
              WHERE t.id = place_tags.tag_id
                AND t.active = true AND t.admin_only = false)
)
```

Um `USING (true)` numa tabela de junção vaza a **existência** das linhas dos dois lados, mesmo
que as tabelas-pai estejam protegidas.

## Grants de tabela são a segunda tranca

RLS é o portão real, mas o Supabase concede acesso amplo ao `anon` por default. Estreitar:

```sql
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
GRANT SELECT ON public.places, public.tiers, … TO anon;
```

⚠️ **Este bloco tem de ser o último da migration.** Default privileges são aplicadas no momento
da criação do objeto — revogar antes de criar a view deixa a view com tudo liberado. Foi assim
que a primeira aplicação da F-01 falhou. Detalhe na skill `michaelinmap-migration`.

## Verificação obrigatória — JWT simulado, nos DOIS sentidos

Não aceite policy sem este teste. Inspeção visual não pega furo de autorização; foi testando o
lado negativo que se comprovou o fechamento do `BL-03`.

```sql
BEGIN;
-- lado positivo: o curador
SELECT set_config('request.jwt.claims',
  json_build_object('sub', (SELECT id FROM auth.users WHERE email = '<curador>'),
                    'role','authenticated')::text, true);
SET LOCAL ROLE authenticated;
SELECT public.is_curator(), (SELECT count(*) FROM public.places);
ROLLBACK;

BEGIN;
-- lado negativo: autenticado FORA da allowlist
SELECT set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
SET LOCAL ROLE authenticated;
SELECT public.is_curator(), (SELECT count(*) FROM public.places);
WITH t AS (UPDATE public.places SET website = 'x' WHERE slug = '<algum>' RETURNING 1)
SELECT count(*) AS linhas_escritas FROM t;   -- tem de ser 0
ROLLBACK;

BEGIN;
-- lado anônimo
SET LOCAL ROLE anon;
SELECT (SELECT count(*) FROM public.places), (SELECT count(*) FROM public.tags);
ROLLBACK;
```

Resultado esperado na F-01: curador vê 511 lugares e escreve; autenticado-fora-da-lista e anon
veem 0 lugares, 93 tags (não 94) e escrevem 0 linhas.

> **Escrever sempre em coluna fora da camada de julgamento** no teste (`website` serve).
> Nunca usar `tier`, `starred`, `the_dish`, `curator_note`, `story` ou `last_visited`, mesmo
> dentro de transação revertida.

## Regras invioláveis

- RLS habilitado em **todas** as tabelas. GATE inline que falhe se alguma tabela tiver RLS ligado e zero policies
- Escrita passa por `is_curator()`. **Nunca** `auth.role() = 'authenticated'` — com signup aberto, isso dá escrita total a um estranho (era o furo do schema original)
- `codes` nunca ganha SELECT público (RN-20). `field_reports` nunca ganha policy de INSERT (RN-23)
- Toda função `SECURITY DEFINER` tem `SET search_path`
- GRANT/REVOKE só em migration, nunca via dashboard
- Acesso anônimo de **escrita** só via RPC `SECURITY DEFINER`, com o status derivado no servidor
- Views que leem tabela sob RLS: `WITH (security_invoker = on)`, senão a view contorna o RLS

## Referências

- Policies reais: `supabase/migrations/20260806120000_f01_schema_rls_rpc.sql` BLOCK 05
- Grants: mesmo arquivo, BLOCK 07 · GATEs de autorização: BLOCK 09 (G2 a G7)
- Modelo declarado: Bíblia §11
