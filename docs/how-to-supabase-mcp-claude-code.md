# Como Configurar o Supabase MCP no Claude Code CLI

> Criado em: 2026-03-30
> Referencia: setup replicavel para qualquer projeto Wise*

---

## Contexto

O Supabase MCP (Model Context Protocol) permite que o Claude Code interaja diretamente com o banco Supabase — executar SQL, listar tabelas, aplicar migrations e consultar logs — sem precisar copiar e colar queries manualmente.

Pontos importantes antes de comecar:

- A configuracao e **por projeto** (arquivo `.mcp.json` na raiz do repositorio)
- O access token e **por conta** (mesmo token funciona para todos os projetos Supabase)
- O token NAO e project-specific — ele da acesso a conta inteira

---

## Pre-requisitos

| Requisito | Detalhe |
|---|---|
| Claude Code CLI | Instalado e funcionando |
| Conta Supabase | Com access token gerado |
| Node.js / npm | Instalado e no PATH |

Para gerar o access token: [https://supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens)

Tokens de acesso comecam com `sbp_`.

---

## Passo a Passo

### Passo 1 — Criar o `.mcp.json` na raiz do projeto

Escolha uma das duas opcoes abaixo.

---

**Opcao A — Portavel (recomendada)**

Usa `npx` diretamente. Funciona em qualquer maquina sem depender de caminho de cache especifico.

```json
{
  "mcpServers": {
    "supabase": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase",
        "--access-token",
        "YOUR_SUPABASE_ACCESS_TOKEN"
      ],
      "env": {}
    }
  }
}
```

---

**Opcao B — Caminho direto no node (startup mais rapido)**

Aponta diretamente para o modulo em cache do npx. Mais rapido porque pula a resolucao do npx, mas o caminho e especifico da maquina — nao funciona em outras maquinas sem ajuste.

```json
{
  "mcpServers": {
    "supabase": {
      "type": "stdio",
      "command": "node",
      "args": [
        "C:/Users/EMello/AppData/Local/npm-cache/_npx/53c4795544aaa350/node_modules/@supabase/mcp-server-supabase/dist/transports/stdio.js",
        "--access-token",
        "YOUR_SUPABASE_ACCESS_TOKEN"
      ],
      "env": {}
    }
  }
}
```

> Se o caminho nao existir, rode `npx @supabase/mcp-server-supabase` uma vez para popular o cache, depois verifique o caminho gerado em `AppData/Local/npm-cache/_npx/`.

---

### Passo 2 — Criar ou atualizar `.claude/settings.local.json`

Adicione as duas chaves abaixo. Se o arquivo ja existir, apenas inclua as chaves que estiverem faltando.

```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["supabase"]
}
```

---

### Passo 3 — Reiniciar o Claude Code

Feche e reabra o Claude Code dentro do diretorio do projeto. As ferramentas do Supabase MCP devem aparecer automaticamente na sessao.

---

## Verificacao

Apos reiniciar, confirme que o MCP esta ativo de uma das formas abaixo:

- Peca ao Claude para rodar uma query simples: `SELECT 1`
- Use o comando `/mcp` dentro do Claude Code para verificar o status dos servidores registrados

---

## Troubleshooting

### 1. Ferramentas do MCP nao aparecem

Verifique se o access token esta sendo passado como argumento de CLI (`--access-token`), NAO como variavel de ambiente (`env`). Esta foi a causa numero 1 de falha durante o setup inicial deste projeto.

Errado:
```json
"env": { "SUPABASE_ACCESS_TOKEN": "sbp_..." }
```

Correto:
```json
"args": ["--access-token", "sbp_..."]
```

---

### 2. Caminho do cache nao encontrado (Opcao B)

Execute `npx @supabase/mcp-server-supabase` uma vez no terminal para popular o cache, ou troque para a Opcao A (npx portavel).

---

### 3. Permission denied no Windows

- Tente rodar o terminal como administrador
- Verifique se `node` e `npx` estao no PATH: `node --version` e `npx --version` devem responder sem erro

---

### 4. Formato incorreto do token

Tokens validos comecam com `sbp_`. Gere um novo em: [https://supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens)

---

## Notas Importantes

- **Token e por conta, nao por projeto** — o mesmo `sbp_...` funciona para todos os seus projetos Supabase
- **Configuracao e por projeto** — voce precisa criar o `.mcp.json` em cada repositorio separadamente
- **O `.mcp.json` contem um token secreto** — adicione ao `.gitignore` se ainda nao estiver la:
  ```
  .mcp.json
  ```
- **Ferramentas MCP disponiveis** (apos setup correto):
  - `execute_sql` — executa queries SQL diretamente
  - `list_tables` — lista tabelas do schema
  - `apply_migration` — aplica migration no banco
  - `list_migrations` — lista historico de migrations
  - `get_logs` — consulta logs do Supabase
  - Entre outras
