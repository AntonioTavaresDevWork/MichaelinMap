---
name: michaelinmap-rls-policy
description: PadrÃµes de RLS policy nos projetos Wise*. Modelo de autorizaÃ§Ã£o declarado na BÃ­blia (tenant-scoped OU capability-RBAC), is_superadmin sempre no topo, exceÃ§Ãµes documentadas. Use ao escrever, revisar ou refatorar Row Level Security policies em qualquer tabela do projeto.
---

> **Template Wise\*:** ao instanciar num projeto, copie para `.claude/skills/MICHAELINMAP-rls-policy/SKILL.md` e renomeie `name:` para `MICHAELINMAP-rls-policy`. Ajuste o snippet ao **modelo de autorizaÃ§Ã£o declarado na BÃ­blia** do projeto (ver abaixo).

# PadrÃ£o de RLS Policy â€” Wise*

## Modelo de autorizaÃ§Ã£o â€” escolha declarada na BÃ­blia

O modelo de autorizaÃ§Ã£o **nÃ£o Ã© universal** â€” cada projeto declara o seu na BÃ­blia (seÃ§Ã£o 2 / subseÃ§Ã£o "Modelo de AutorizaÃ§Ã£o"). A skill se adapta Ã  escolha. HÃ¡ dois modelos suportados:

| Modelo | Quando usar | Predicado de policy |
| --- | --- | --- |
| **A â€” Tenant-scoped** (default p/ projetos simples) | Isolamento por empresa + 1-3 papÃ©is simples. Sem permissÃµes finas por papel. | `is_superadmin() OR company_id = get_user_company_id()` |
| **B â€” Capability-RBAC** | Hierarquia de papÃ©is com permissÃµes granulares (ex: aprovaÃ§Ã£o multi-etapa, muitos leitores). | `is_superadmin() OR (company_id = get_user_company_id() AND has_capacidade('<cap>'))` |

> **Regra de ouro:** comece em **A**. Migre para **B** sÃ³ quando um papel novo exigir permissÃ£o fina que o tenant-scoped nÃ£o distingue. O caminho Aâ†’B Ã© aditivo; o inverso (arrancar capability que ninguÃ©m usa) Ã© caro. A escolha vale para o projeto inteiro â€” nÃ£o misturar modelos entre tabelas sem ADR.

As seÃ§Ãµes abaixo descrevem o **Modelo B** (o mais rico, herdado do WiseFacilities). Para o **Modelo A**, use apenas `is_superadmin() OR company_id = get_user_company_id()` (mais o filtro de escopo da tabela quando houver, ex: `usuario_id = auth.uid()`), e ignore tudo que menciona `has_capacidade()`/`is_admin_atual()`/catÃ¡logo de capacidades.

## Snippet canÃ´nico (Modelo B â€” capability-RBAC)

A forma padrÃ£o de quase toda policy Ã©:

```sql
CREATE POLICY "<nome>" ON <tabela> FOR <op>
  USING (
    is_superadmin() OR (
      company_id = get_user_company_id()
      AND has_capacidade('<capability>')
    )
  );
```

Para `INSERT`/`UPDATE`, repetir a mesma expressÃ£o em `WITH CHECK`.

> **Modelo A (tenant-scoped):** o snippet equivalente Ã© `is_superadmin() OR company_id = get_user_company_id()`. O nome da funÃ§Ã£o que resolve a empresa do caller pode variar por projeto (`get_user_company_id()`, `auth_company_id()`, etc.) â€” usar o que a BÃ­blia declarar.

## Por que `is_superadmin()` no topo

Superadmin tem `company_id = NULL`. Se o filtro `company_id = get_user_company_id()` vier antes, o acesso Ã© negado mesmo com bypass dentro de `has_capacidade()`. Por isso `is_superadmin()` SEMPRE Ã© o primeiro OR.

`is_admin_atual()` (admin do tenant) tem `company_id` populado, entÃ£o pode ser bypassado DENTRO de `has_capacidade()` â€” nÃ£o precisa ficar no topo.

## TrÃªs funÃ§Ãµes do substrato â€” quando usar cada

| FunÃ§Ã£o                                       | Quando usar                                                                                                                         |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `has_capacidade(cap text)`                   | 99% dos casos. Checa capability do caller (`auth.uid()` implÃ­cito). Embute short-circuit pra admin do tenant.                       |
| `is_admin_atual()`                           | Quando a policy precisa distinguir admin (full access dentro do tenant) de operaÃ§Ã£o com escopo (ex: `responsavel_id = auth.uid()`). |
| `usuario_tem_capacidade(uid uuid, cap text)` | Raro. Quando a policy/trigger checa capability de um usuÃ¡rio ARBITRÃRIO, nÃ£o do caller.                                             |

## ExceÃ§Ãµes legÃ­timas ao snippet canÃ´nico (documentar TODAS na spec)

PadrÃµes de exceÃ§Ã£o consolidados no WiseFacilities (spec F-RBAC-v2 Â§8.3) â€” reutilizar quando o caso bater:

| PadrÃ£o                              | Forma                                                                                     |
| ----------------------------------- | ------------------------------------------------------------------------------------------ |
| SELECT com toggle de arquivados     | Adiciona `AND (deleted_at IS NULL OR has_capacidade('ver_arquivados'))`                   |
| UPDATE escopado por responsÃ¡vel     | `is_admin_atual() OR (has_capacidade('<cap>') AND responsavel_id = auth.uid())`           |
| INSERT restrito (Admin-only)        | SÃ³ `has_capacidade('<cap>')`, sem `is_admin_atual()`                                      |
| INSERT de tenant raiz (`empresas`)  | Sem filtro `company_id` (cria a prÃ³pria empresa)                                          |
| Self-edit em `perfis`               | `... AND (id = auth.uid() OR has_capacidade('gerir_usuarios'))`                           |
| Log write-once (ex: movimentaÃ§Ãµes)  | `auth.uid() = usuario_id`, sem UPDATE/DELETE                                              |
| Tabela filha sem `company_id`       | Cross-table check via subquery na tabela pai                                              |

## Regras inviolÃ¡veis (ambos os modelos)

- `is_superadmin()` SEMPRE primeiro OR de policies multi-tenant
- RLS habilitado em TODAS as tabelas; toda policy filtra por `company_id` (exceto superadmin)
- NUNCA hardcode de papel (`papel = 'X'`) â€” no Modelo B usar `has_capacidade()`; no Modelo A o escopo vem do prÃ³prio tenant + colunas da linha (ex: `usuario_id = auth.uid()`)
- GRANT/REVOKE sÃ³ via migration (dashboard Ã© sobrescrito por apply subsequente; exceÃ§Ã£o de 1-2 statements registrada â€” ver skill `wise-migration`)
- Visibilidade ampliada exclui rascunho privado do criador explicitamente no filtro
- **Acesso anon** Ã© negado por default; exceÃ§Ã£o sÃ³ com **ADR** explÃ­cito (ex: portal pÃºblico via RPC SECURITY DEFINER) registrado na BÃ­blia

### EspecÃ­fico do Modelo B

- AutorizaÃ§Ã£o via `has_capacidade()` â€” capability-driven cobre "e semelhantes" sem manutenÃ§Ã£o
- Toda mudanÃ§a em `has_capacidade()` precisa migration, NUNCA via dashboard
- Capabilities forward-looking ficam no catÃ¡logo com matriz zerada â€” a feature futura popula

## ReferÃªncias

- Origem do padrÃ£o: WiseFacilities `docs/specs/F-RBAC-v2-spec.md` Â§8.1 (snippet) e Â§8.3 (exceÃ§Ãµes); migration `20260522120000_f_rbac_v2.sql` BLOCK 09.
- No projeto novo: apontar aqui a spec local de RBAC quando existir.
