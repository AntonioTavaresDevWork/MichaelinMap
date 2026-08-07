# Michaelin Map — STATUS

> Atualizado ao final de cada sessão de desenvolvimento.
> Lido no boot, junto de `.claude/CLAUDE.md`, `docs/MICHAELINMAP_BIBLIA.md` e `docs/BACKLOG.md`.

---

## 🗓️ Última atualização

**Data:** 2026-08-06
**Sessão:** S04 — F-01: schema, RLS, RPCs e import
**Versão:** `0.1.0` (primeira versão do projeto — a F-00 era scaffold sem banco)
**Atualizado por:** Claude Code (orquestrador)

---

## 📍 Fase atual

**F-01 concluída. O banco existe e tem os 511 lugares.**
Objetivo imediato: F-02 (admin) — bloqueada pelas duas pendências de painel (`OP-01`, `OP-02`).

---

## ✅ Concluído

### Sessão 01 — Scaffold
- [x] Repositório GitHub criado (`AdminFeedpro/MichaelinMap`)
- [x] Projeto Supabase criado (`woapimgpmlgqqvauckdy`) — **vazio**
- [x] MCP Supabase configurado
- [x] Estrutura `.claude/` (CLAUDE.md, init.md, 5 agentes, 5 skills)
- [x] `docs/prompts/` (orquestrador + executor)

### Sessão 02 — Escopo e fundação documental
- [x] Material do Claude Web analisado: PRD v1.0, CLAUDE.md do produto, PLAN.md, schema.sql, seed.sql, import-places.ts, CSV master
- [x] CSV validado linha a linha contra os números do PRD — batem todos (511 lugares, 273 restaurantes, 91 bares, 22 estrelas, 42 não visitados, 28 conflitos, 19 guias, 0 Apple IDs duplicados, 0 coordenadas faltando)
- [x] Auditoria do schema — 7 achados, 3 de severidade alta (`BL-01` a `BL-07` no BACKLOG)
- [x] Reavaliação de escopo: cortes de overengineering acordados com Edu
- [x] 5 decisões pendentes resolvidas (DP-01 a DP-05)
- [x] 8 ADRs registrados
- [x] `docs/MICHAELINMAP_BIBLIA.md` v2.0 escrita
- [x] `docs/BACKLOG.md` populado (20 itens)
- [x] `docs/STATUS.md` corrigido — a versão anterior afirmava "Setup concluído" com o banco vazio
- [x] Skills renomeadas `wise-*` → `michaelinmap-*`; BOM removido do frontmatter (impedia o parser de ler as descrições)

### F-00 — Fundação ✅
- [x] Vite 8 + React 19 + TypeScript 6 + Tailwind 4 + shadcn/ui (preset radix-nova)
- [x] 7 dependências instaladas: `@supabase/supabase-js`, `@tanstack/react-query`, `react-router-dom`, `zustand`, `sonner`, `lucide-react`, `maplibre-gl`
- [x] 9 componentes shadcn: button, input, label, card, sonner, separator, skeleton, badge, dropdown-menu
- [x] `src/lib/supabase/client.ts` — singleton que valida env no import
- [x] `src/lib/utils.ts` — `cn()`, `mapRpcError()`, formatadores **en-US**, `monthsSince()`, `slugify()` alinhado ao script de import
- [x] `src/types/index.ts` — 8 interfaces em snake_case espelhando o schema-alvo
- [x] `useSession()` + `ProtectedRoute` para `/admin`
- [x] Layouts público e admin; login funcional; placeholders nas rotas por vir
- [x] `noindex, nofollow` no `index.html` (ADR-07)
- [x] `.env.example` + `.env.local` (publishable key; gitignored)
- [x] **Gate:** `npm run build` e `npm run lint` limpos · dev server sobe e responde 200 em `/` e `/admin/login`

### Sessão 03 — Destravamento de ambiente ✅
- [x] `mcp.json` → `.mcp.json` — nome que o Claude Code lê e que o `.gitignore` já cobria
- [x] `env.local.download` → `.env.local` — o arquivo existia com o nome quebrado pelo download
- [x] `git init` + commit inicial `b6fef0c` na `main` (68 arquivos)
- [x] Varredura de secrets no índice: limpo. `.mcp.json`, `.env.local` e `.claude/settings.local.json` confirmados ignorados
- [x] Node.js 24.19.0 / npm 11.17.0 instalados · `npm install` (459 pacotes)
- [x] **Gate reexecutado nesta máquina:** `npm run build` e `npm run lint` limpos
- [x] Token do Supabase validado: projeto `ACTIVE_HEALTHY`, PostgreSQL 17.6.1, região us-west-2
- [x] Caminho da pasta corrigido na Bíblia §3 e no `.claude/CLAUDE.md`
- [x] `env.example` duplicado removido (`BL-24` fechado) — `.env.example` é o único canônico

### F-01 — Schema + dados ✅
- [x] `20260806120000_f01_schema_rls_rpc.sql` — 8 tabelas, 3 constraints de julgamento, 8 índices, trigger `updated_at`, `is_curator()`, 14 policies, view `field_report_aggregates` com `security_invoker`, 2 RPCs. **12 GATEs inline passaram**
- [x] `20260806120100_f01_seed_and_import.sql` — 4 tiers, 94 tags, 38 perguntas, code `DEMO`, 511 lugares, 145 tags sugeridas. **18 GATEs passaram**
- [x] `BL-01` a `BL-08`, `BL-12` e `BL-13` fechados
- [x] Import verificado por **checksum contra o CSV**: nome, slug, tipo, tier, estrela, visitado, país, cidade, área, coordenadas, endereço e `source_guides` — os 511 registros do banco são idênticos ao gerado da fonte
- [x] Smoke de segurança com `SET ROLE anon`: vê 0 lugares, 93 tags (`Hype trap` oculto), 0 `place_tags`, zero acesso a `codes` e `curators`
- [x] Smoke funcional das RPCs: code válido/minúsculo/inexistente, field report numérico → `published`, texto livre → `pending` truncado em 40 chars, duplicata bloqueada, resposta sem `value` rejeitada
- [x] `20260806130000_f01_seed_curator.sql` — a linha do `Michael` em `curators`, resolvida por subquery em `auth.users` (sem UUID hardcoded). 2 GATEs
- [x] **Autorização verificada ponta a ponta com JWT simulado.** Curador: vê os 511 lugares, as 94 tags, `codes` e `curators`, e escreve. Conta autenticada **fora** da allowlist: 0 lugares, 93 tags, 0 codes, 0 curators, `UPDATE` afeta 0 linhas. É exatamente o caso que o modelo original (`auth.role() = 'authenticated'`) errava — `BL-03` fechado com evidência
- [x] `schema_migrations` saneado — versões realinhadas com os nomes de arquivo
- [x] **Gate:** `npm run build` e `npm run lint` limpos

---

## 🔄 Em andamento

Nada em execução. F-01 fechada e verificada.

---

## ⏭️ Próxima ação

**F-02 — Admin.** Nada mais bloqueia a escrita: a conta do curador existe e foi verificada.

Duas pendências operacionais menores, nenhuma bloqueante (`OP-01` e `OP-03` no BACKLOG): desabilitar o signup no painel e rodar o `git push`.

Depois disso, a F-02 entrega: login dos 2 curadores, lista com filtros, editor de lugar, atribuição de tags, quick-add mobile, fila de revisão, distribuição de tiers e lista de desatualizados.

**Duas filas de revisão já têm dado esperando:** os 28 conflitos marcados em `source_guides` (`DP-08`) e as 145 tags `suggested` do import (`DP-09`).

---

## 🚫 Blockers

Nenhum. A conta de curador existe e a autorização foi verificada — a F-02 pode começar e ser testada.

Nenhum. O `OP-03` fechou no fim da sessão — ver log.

---

## 📊 Estado do banco

Lido via MCP no fim da S04.

| Tabela | Linhas | Observação |
|---|---|---|
| `places` | 511 | 100% `unreviewed` — nada visível ao público (RN-07) |
| `tags` | 94 | 93 públicas + `Hype trap` admin-only |
| `questions` | 38 | 4 com `requires_review` (as de texto livre) |
| `tiers` | 4 | `destination`, `experience`, `fair`, `cool` |
| `place_tags` | 145 | todas `source = 'suggested'` |
| `codes` | 1 | `DEMO`, para smoke da RPC |
| `curators` | 1 | `Michael` — `mikemyday@mikecofone.com`, conta confirmada |
| `field_reports` | 0 | |

Distribuição de julgamento: estrela 22 (4,3%), não visitados 42, com tier 279 (`fair` 182, `destination` 38, `experience` 30, `cool` 29), com área 107, 16 cidades.

Migrations: `20260806120000_f01_schema_rls_rpc`, `20260806120100_f01_seed_and_import`.

---

## 🗺️ Roteiro

| # | Feature | Status | Sessões |
|---|---|---|---|
| F-00 | Fundação | ✅ Concluída (S02) | ~0,5 |
| F-01 | Schema + dados | ✅ Concluída (S04) | ~1 |
| F-02 | Admin | ⬜ Próxima | ~2 |
| F-03 | Público (city gate, mapa, lista, detalhe) | ⬜ | ~2 |
| F-04 | Filtros facetados | ⬜ | ~1 |
| F-05 | Codes completo + Roulette | ⬜ | ~2 |
| F-06 | Field reports | ⬜ | ~1,5 |

Total estimado: ~10 sessões. A curadoria do Michael roda em paralelo a partir da F-02 — ver Bíblia §13.1.

---

## 📝 Log de sessões

### 2026-08-06 — S04: F-01 — schema, RLS, RPCs e import

**O que foi feito:** o banco saiu de zero tabelas para o schema inteiro com os 511 lugares dentro. Duas migrations, ambas versionadas em `supabase/migrations/`, ambas com rollback escrito em `supabase/rollbacks/`.

**Cinco decisões cravadas antes de escrever SQL, todas aprovadas pelo Edu:**
- **Import por SQL versionado**, não pelo `import-places.ts`. O script exigia service-role key no ambiente e a dependência `csv-parse`; o SQL gerado a partir do CSV fica auditável no repo e não pede chave nova. Os slugs saem da mesma função `slugify()` que está em `src/lib/utils.ts`, então batem com o frontend
- **`price_band` não foi pré-sugerido.** O ADR-06 mandava pré-classificar `cuisine` e `price_band`, mas a §9.1 removeu `price_band_source` — não existe onde marcar que o valor é chute de máquina, e sem Google Places a única entrada seria o nome do lugar. Um palpite ficaria indistinguível do veredito do Michael num campo da camada de julgamento. ADR-06 emendado na Bíblia
- **145 tags gravadas como `suggested`**, com autorização explícita (é camada de julgamento). Duas fontes só: a coluna `Tags` do CSV, que vem dos nomes dos guias do próprio Michael, e casamento inequívoco de palavra de cozinha no nome do lugar, restrito a tipos que servem comida
- **`DEMO`** semeado para dar o que testar em `rpc_redeem_code()` antes da F-05
- **`curators` nasce vazia** — `auth.users` tem zero contas

**Duas divergências encontradas no meio do caminho:**
- **São 4 tiers, não 5.** STATUS e Bíblia diziam 5 porque a tabela da §6.2 lista `fair` duas vezes, uma por escala. Como `slug` é PK, `fair` é uma linha com `applies_to = {restaurant, bar}` — que é para isso que a coluna é array. Confirmado por `SEEDED_TIER_SLUGS` no `src/types/index.ts` e pelo valor único `Fair` no CSV. Corrigido na Bíblia
- **A coluna `Town` do CSV estava sendo descartada.** É o município real — Lockhart, Dripping Springs, San Marcos. Virou `area` onde difere da cidade-portão: 107 dos 511. É geografia derivada, não julgamento, e some com um `UPDATE`

**O gate G6 pegou um bug real na primeira tentativa de aplicar.** A migration falhou porque `anon` tinha 4 privilégios de escrita sobrando em `public`. Causa: a view `field_report_aggregates` era criada **depois** do `REVOKE ALL ... FROM anon`, então herdava as default privileges do Supabase e nascia com INSERT, UPDATE, DELETE e TRUNCATE liberados. A migration inteira voltou atrás, o banco ficou intacto, os blocos foram reordenados e a segunda tentativa passou. Vale como evidência de que os GATEs inline pagam por si.

**Verificação do import.** Como a migration de 155 kB não coube numa chamada de `apply_migration`, os 511 registros entraram por `execute_sql` em quatro blocos — o que introduz risco de erro silencioso de transcrição. Em vez de confiar, o conteúdo do banco foi comparado com o CSV por checksum md5 campo a campo: nome, slug, tipo, tier, estrela, visitado, país, cidade, área, coordenadas, endereço e `source_guides`. Todos batem. (A primeira rodada acusou divergência em `source_guides`, que era bug do script de verificação — o parser removia as aspas antes de ler o array. Os dados sempre estiveram certos.)

**Duas decisões tomadas no fim da sessão:**
- **Uma conta de curador, não duas.** O Edu acessa pela conta do Michael. Fecha `BL-11` — o PRD, que dizia "single-user authentication", estava certo desde o começo. Não muda schema: `curators` só passa a ter uma linha. Custo aceito: `updated_by` deixa de dizer *quem* editou (`BL-17` atualizado)
- **História reconciliada com o GitHub.** O repo remoto existia desde a S01, com dois commits de fundação; o `git init` da S03 tinha criado um histórico órfão em paralelo, sem ancestral comum. Resolvido por `git rebase --onto origin/main b6fef0c main`: o "commit inicial" local, que só replicava o que já estava no GitHub, foi descartado e os quatro seguintes replicados sobre a história real. Resultado linear, árvore final byte-idêntica à de antes do rebase, push vira fast-forward — nada de `--force`, nenhum commit da fundação perdido. Branch `backup-pre-rebase` guardada por segurança
- **Correção de registro:** eu havia escrito neste arquivo que "o remote nunca existiu" e que era "a terceira afirmação da S01 que não se sustenta". Errado nas duas contas — a S01 estava certa. O que falhou foi o diagnóstico da S03, que tratou a ausência de `.git` local como ausência de repositório
- **O projeto mudou de casa no GitHub.** O push para `AdminFeedpro/MichaelinMap` respondia "Repository not found" mesmo com a leitura funcionando. Causa: a credencial armazenada no Git Credential Manager desta máquina é da conta **`AntonioTavaresDevWork`**, que não tem acesso àquele repositório — o GitHub devolve 404 em vez de 403 para não confirmar a existência de repo privado. Por decisão do Edu, criei `AntonioTavaresDevWork/MichaelinMap` (privado) e apontei o remote para lá. Subiram os 9 commits, com os dois da fundação (`038d040`, `d98f07c`) preservados. O repositório antigo continua existindo, parado naqueles dois commits

- **Curador semeado no fim da sessão.** Conta `mikemyday@mikecofone.com` criada no painel pelo Edu, linha inserida por migration versionada. O teste com JWT simulado provou os dois lados do modelo: curador escreve, autenticado-fora-da-allowlist não vê nem escreve nada além do que um visitante anônimo veria

**Aprendizados registrados (onde procurar depois):**

| Aprendizado | Onde ficou |
|---|---|
| Bloco de GRANT/REVOKE é sempre o último da migration — default privileges valem no momento da criação do objeto | `.claude/CLAUDE.md` + skill `michaelinmap-migration` |
| `apply_migration` tem limite de payload; carga de massa por fallback exige checksum contra a fonte | `.claude/CLAUDE.md` + skill `michaelinmap-migration` |
| Ausência de `.git` local não é diagnóstico de "repositório não existe" | `.claude/CLAUDE.md`, fluxo de trabalho |
| GATEs de privilégio, RLS órfã e `search_path` pegam o que revisão visual não pega | skill `michaelinmap-migration` |
| `execute_sql` devolve só o último resultado; `RAISE EXCEPTION` serve de relatório em smoke que precisa reverter | skill `michaelinmap-migration` |
| Verificação de RLS com JWT simulado, testando os dois lados | skill `michaelinmap-rls-policy` |

**`BL-14` fechado no caminho.** As cinco skills traziam objetos do WiseFacilities que não existem
aqui. O achado mais grave não eram os exemplos órfãos: a `michaelinmap-naming` prescrevia formato
brasileiro (`1.234,56`, `DD/MM/YYYY`, `R$`), em contradição direta com o ADR-02 — um agente
seguindo a skill produziria formatação errada num produto em inglês.

**Curiosidade útil:** o `docs/S01.md`, que só apareceu nesta máquina via rebase, já recomendava
converter o CSV em migration de seed idempotente em vez de rodar o `import-places.ts`, pelo mesmo
motivo que decidimos nesta sessão — não expor a service-role key. A decisão foi tomada sem
conhecer esse arquivo.

**Próxima sessão:** F-02 — Admin, sem bloqueio. Sobram só o `git push` e o desligamento do signup, ambos operacionais.

### 2026-08-06 — S03: Destravamento de ambiente

**O que foi feito:** a máquina de trabalho não estava pronta para a F-01 e o STATUS não registrava isso. Quatro divergências entre o registrado e o real, todas fechadas nesta sessão.

**As divergências:**
- **Repositório não existia.** A S01 registrou "repositório GitHub criado", mas não havia `.git` na pasta local. Nada estava versionado. Corrigido com `git init` + commit `b6fef0c`.
- **MCP do Supabase não carregava.** A config estava em `mcp.json`; o Claude Code lê `.mcp.json`. O `.gitignore` também só cobria a versão com ponto — o arquivo com o access token estava exposto e teria entrado no primeiro commit. O rename resolveu as duas coisas.
- **Node.js não estava no PATH.** O `winget` reportou o pacote como já instalado e, de fato, `C:\Program Files\nodejs` existia com o PATH de máquina apontando pra lá — o shell da sessão é que havia sido iniciado antes. Sem isso, nem `npm` nem o MCP (que roda via `npx`) funcionavam.
- **`.env.local` ausente.** Existia como `env.local.download`, nome quebrado no download. O client Supabase valida env no import, então nada subia.

**Consequência importante:** o gate "build + lint limpos" que a S02 registrou como cumprido **não era reproduzível** nesta máquina — sem `node_modules`, nenhum dos dois rodava. Foi reexecutado do zero nesta sessão e passou limpo, então a F-00 se sustenta. Mas o registro anterior era uma afirmação sem verificação possível.

**Decisões tomadas:**
- Identidade git configurada local ao repositório, não global
- O commit inicial documenta no corpo que o gate não pôde rodar no momento em que foi criado — preferível a omitir
- Estado do banco **não** foi reconfirmado: a validação por API de gestão foi bloqueada e não foi contornada. Fica como primeira ação do próximo boot, via MCP

**Próxima sessão:** F-01 — Schema + dados. Reiniciar a sessão primeiro, para o `.mcp.json` carregar.

### 2026-08-06 — S02: Escopo e fundação documental

**O que foi feito:** análise integral do material do Claude Web; validação dos dados; auditoria de segurança do schema; reavaliação de escopo; redação da Bíblia, do BACKLOG e deste arquivo.

**Decisões tomadas:**
- Projeto é pessoal, não SaaS — sem multi-tenant (ADR-01)
- Produto em inglês, docs internos em PT-BR (ADR-02)
- Google Places API cortada; pré-classificação de `cuisine` e `price_band` feita pelo CLI no seed (ADR-06)
- My Maps sync cortado (ADR-08)
- Guia não-listado, `noindex` (ADR-07)
- Codes na versão completa; field reports mantidos por pedido do Michael
- Roulette reincluída — custo próximo de zero, alto valor de personalidade
- Framework Wise* reduzido: sem GANTT, DOMAIN_QUESTIONS, spec por feature ou pipeline de agentes (ADR-04)
- Estratégia de lançamento: publicar os ~65 lugares com estrela ou `destination` primeiro, em vez de esperar os 511

**Também nesta sessão:** F-00 executada e fechada. Desvios em relação ao previsto, todos registrados no CLAUDE.md e no BACKLOG: o template Vite atual usa **oxlint** no lugar do ESLint; TypeScript 6 deprecou `baseUrl`, então o alias `@/` usa só `paths`; o `sonner.tsx` do shadcn vinha atrelado a `next-themes` e foi reescrito.

**Próxima sessão:** F-01 — Schema + dados.

### 2026-08-05 — S01: Scaffold

Estrutura Wise* instanciada, repositório e projeto Supabase criados. Nenhum código de produto, nenhuma migration.
