---
name: michaelinmap-naming
description: ConvenÃ§Ãµes de nomes nos projetos Wise*. DB snake_case, frontend camelCase, componentes PascalCase, arquivos kebab-case, formato BR de nÃºmero/data/moeda. Use ao nomear tabela, coluna, RPC, componente, hook, arquivo, ou ao formatar valores numÃ©ricos/datas/moeda na UI.
---

> **Template Wise\*:** ao instanciar num projeto, copie para `.claude/skills/MICHAELINMAP-naming/SKILL.md` e renomeie `name:` para `MICHAELINMAP-naming`.

# ConvenÃ§Ãµes de Nomes â€” Wise*

## Tabela resumo

| Camada                | ConvenÃ§Ã£o                                    | Exemplos                                                     |
| --------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| Tabelas DB            | `snake_case` (plural)                        | `contratos`, `itens_catalogo`, `solicitacao_itens`           |
| Colunas DB            | `snake_case`                                 | `company_id`, `created_at`, `deleted_at`, `cargo_no_momento` |
| FunÃ§Ãµes/RPCs SQL      | `snake_case` com prefixo `rpc_` ou semÃ¢ntico | `rpc_ajustar_estoque`, `has_capacidade`, `cargo_atual_texto` |
| VariÃ¡veis frontend TS | `camelCase`                                  | `contratoId`, `itensCatalogo`, `cargoAtual`                  |
| Componentes React     | `PascalCase`                                 | `ContratoForm`, `ItemList`, `RequisicaoCard`                 |
| Hooks                 | `camelCase` com prefixo `use`                | `useContrato`, `useEstoqueAtual`, `useAuditLog`              |
| Arquivos (todos)      | `kebab-case`                                 | `contrato-form.tsx`, `use-contrato.ts`, `audit-helpers.ts`   |
| Tipos TS              | `PascalCase`                                 | `Contrato`, `ItemCatalogo`, `AuditLogEntry`                  |
| Constantes            | `UPPER_SNAKE_CASE`                           | `MAX_RETRIES`, `SLA_HORAS_APROVACAO`                         |

> âš ï¸ Arquivo de componente Ã© **kebab-case** (`contrato-form.tsx`), NÃƒO `ContratoForm.tsx`. Erro comum.

## ConversÃ£o DB â†” Frontend

O cliente Supabase TS nÃ£o converte automaticamente. Use mapeadores explÃ­citos ou nomeie as variÃ¡veis TS no padrÃ£o DB (`snake_case`) quando vier de query direta. Exemplo:

```typescript
// DB devolve snake_case
const { data } = await supabase.from('contratos').select('id, company_id, created_at');

// Mapear pra camelCase no domÃ­nio
type Contrato = {
  id: string;
  companyId: string;   // mapeado de company_id
  createdAt: string;   // mapeado de created_at
};
```

**Regra prÃ¡tica:** tipo populado por `select('*')` direto sem mapeamento explÃ­cito â†’ nomear os campos em `snake_case` (igual ao banco). Declarar `metaMensal` quando o banco retorna `meta_mensal` resulta em `undefined` em runtime.

## Formato BR â€” nÃºmeros, datas, moeda

| Tipo           | Formato BR                    | Exemplo                |
| -------------- | ----------------------------- | ---------------------- |
| NÃºmero         | Ponto milhar, vÃ­rgula decimal | `1.234.567,89`         |
| Data UI        | `DD/MM/YYYY`                  | `22/05/2026`           |
| Data + hora UI | `DD/MM/YYYY HH:mm`            | `22/05/2026 14:30`     |
| Data DB        | ISO 8601 TIMESTAMPTZ          | `2026-05-22T17:30:00Z` |
| Moeda          | `R$` prefixo, 2 decimais      | `R$ 1.234,56`          |
| Porcentagem    | VÃ­rgula decimal, sufixo `%`   | `12,5%`                |

Use `Intl.NumberFormat('pt-BR', ...)` e `Intl.DateTimeFormat('pt-BR', ...)` no frontend. NÃ£o inventar formatador manual.

## Prefixos semÃ¢nticos comuns

| Prefixo    | Uso                                                                             |
| ---------- | ------------------------------------------------------------------------------- |
| `rpc_`     | FunÃ§Ã£o SQL exposta ao frontend via supabase.rpc()                               |
| `is_`      | FunÃ§Ã£o booleana (`is_admin_atual`, `is_superadmin`)                             |
| `has_`     | FunÃ§Ã£o booleana de posse/permissÃ£o (`has_capacidade`)                           |
| `get_`     | FunÃ§Ã£o que retorna valor nÃ£o-booleano (`get_user_company_id`)                   |
| `validar_` | Trigger function de validaÃ§Ã£o (`validar_responsavel_almoxarifado`)              |
| `enforce_` | Trigger function de constraint complexo (`enforce_archive_admin_only`)          |
| `vw_`      | View SQL (`vw_fila_aprovacao`)                                                  |
| `mat_vw_`  | Materialized view                                                               |
| `fn_`      | FunÃ§Ã£o utilitÃ¡ria de cÃ¡lculo (`fn_horas_uteis_decorridas`)                      |

## Anti-padrÃµes â€” nÃ£o fazer

- âŒ Misturar idiomas: `clienteName` (escolher: `clienteNome` ou `clientName`)
- âŒ Camelizar siglas inteiras: `cnpjValido` âœ…, `cNPJValido` âŒ
- âŒ Plural inconsistente: tabelas DB sempre plural (`contratos`), componentes singular (`ContratoForm`)
- âŒ Format manual: `valor.toFixed(2).replace('.', ',')` âŒ â€” use `Intl.NumberFormat`
