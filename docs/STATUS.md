# Michaelin Map — STATUS

> Atualizado ao final de cada sessão de desenvolvimento.
> Lido no boot, junto de `.claude/CLAUDE.md`, `docs/MICHAELINMAP_BIBLIA.md` e `docs/BACKLOG.md`.

---

## 🗓️ Última atualização

**Data:** 2026-08-07
**Sessão:** S06 — reconciliação documental
**Versão:** `0.1.0`
**Atualizado por:** Claude Code (orquestrador)

> **Nota de registro (S06).** A S05 entregou F-02 e F-03 mas fechou sem atualizar este arquivo:
> o cabeçalho seguia dizendo "F-01 concluída, F-02 a iniciar" enquanto 12 commits de F-02/F-03
> já estavam na `main`. O log da S05 abaixo foi **reconstruído a partir das mensagens de commit
> e da árvore de código**, não escrito ao vivo — é fiel ao que está versionado, mas não registra
> o que tenha sido decidido em conversa e não tenha deixado rastro no repositório.

---

## 📍 Fase atual

**F-00, F-01, F-02 e F-03 concluídas.** O produto tem admin funcional e lado público navegável.
Objetivo imediato: **F-04 — filtros facetados**.

Uma ressalva na F-03: o mapa está integrado, sincronizado com a lista e com os marcadores
posicionados corretamente, mas **não desenha geometria nesta máquina** — `BL-29`, causa
ambiental, provada fora do nosso código. Não bloqueia a F-04.

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

### F-02 — Admin ✅ (S05)

- [x] Lista de lugares com barra de filtros (`places.tsx`, `place-filter-bar.tsx`, `place-filters.ts`)
- [x] Editor de lugar completo (`place-editor.tsx`) + regras de promoção a `published` (`publish-rules.ts`)
- [x] Atribuição de tags com distinção visual de `suggested` × `curator` — RN-15 (`tag-picker.tsx`)
- [x] Overview no lugar do dashboard: distribuição de tiers, progresso de curadoria, filas e desatualizados
- [x] Quick-add mobile com geocoding Nominatim, sem chave — ADR-06 (`quick-add.tsx`, `use-geocode.ts`)
- [x] Hooks `use-places`, `use-tags`, `use-tiers`
- [x] 6 componentes shadcn adicionados: checkbox, dialog, select, switch, tabs, textarea
- [x] **Tela dedicada de fila de revisão cortada** — as três filas viraram cartões no Overview que
      linkam para a lista com o filtro aplicado. Uma tela própria seria uma quarta forma de olhar
      os mesmos registros, com dois lugares para manter em sincronia

### F-03 — Público ⚠️ (S05) — entregue, com o mapa mudo por causa ambiental

- [x] Portão de cidade com cidades em pares e contagem (DP-02); empty state autoral
- [x] Guia da cidade separando "Eat & drink" de "Everything else" (§7); ordem estrela → tier → nome;
      `the_dish` lidera a linha quando existe
- [x] Detalhe do lugar liderando pelo veredito, nunca pelo endereço; direções em botão
- [x] `use-public-guide.ts` — leitura pública via anon key
- [x] Mapa MapLibre sincronizado com a lista nos dois sentidos, **uma única seleção compartilhada**;
      cor do pin codifica julgamento (âmbar+estrela, escuro para destination/experience, claro o resto)
- [x] Tiles do OpenFreeMap — grátis, sem chave, mesma lógica do ADR-06
- [x] Mapa em `lazy` + `Suspense` (`BL-25`): principal 699 kB (204 kB gzip), chunk do mapa carregado
      só ao abrir uma cidade
- [x] Caminho público verificado ponta a ponta com a anon key: 58 publicados, 93 tags (`Hype trap`
      ausente — RN-14), `codes` negando com 42501 (RN-20)
- [x] Corrigido de verdade no caminho: o enquadramento só roda após `load` e com container
      dimensionado — `fitBounds` contra largura zero produzia zoom degenerado
- [ ] ⚠️ **O mapa não desenha geometria nesta máquina** — `BL-29`. Não é o nosso código; ver Blockers

### Sessão 06 — Reconciliação documental
- [x] `docs/STATUS.md` e `docs/MICHAELINMAP_BIBLIA.md` alinhados com o estado real (F-02 e F-03 na `main`)
- [x] `schema_migrations` reconferido via MCP: **3** migrations vivas, não 2 como este arquivo dizia
- [x] **Gate reexecutado:** `npm run build` e `npm run lint` limpos

---

## 🔄 Em andamento

Nada em execução. F-03 fechada; só o `BL-29` fica em aberto, e é ambiental.

---

## ⏭️ Próxima ação

**F-04 — Filtros facetados.** Entrega: painel facetado, OR dentro / AND entre facetas (RN-16),
contagem ao vivo com opção zerada **desabilitada, não escondida** (RN-17), filtro de área só em
cidade com ~15+ lugares (RN-18), estado serializado na URL (RN-19) e empty state autoral (`BL-18`).

O terreno já está preparado: a F-03 deixou **uma única seleção compartilhada** entre mapa e lista, e
o mapa reenquadra sozinho quando o conjunto de lugares muda — exatamente o que o filtro vai acionar.

**Duas filas de revisão têm dado esperando o Michael, não o CLI:** os 28 conflitos marcados em
`source_guides` (`DP-08`) e as 145 tags `suggested` do import (`DP-09`). Ambas já têm superfície no
Overview.

**O que mais move o produto e não é código:** nenhum dos 58 publicados tem `the_dish` ou
`curator_note`. O guia mostra os vereditos, mas não a voz.

---

## 🚫 Blockers

**`BL-29` — o mapa não desenha geometria nesta máquina.** Marcadores aparecem e se posicionam
certo; nenhum tile renderiza; zero erros no console.

**Provado que não é o nosso código:** um mapa MapLibre puro, carregado de CDN numa página em branco,
sem uma linha nossa, se comporta idêntico — `sourcedata:openmaptiles` fica `pending` para sempre,
nunca `loaded`. Reproduz em Chrome, Firefox e Edge. Descartados com evidência medida no próprio
navegador: WebGL (2.0, GPU AMD via ANGLE), Web Workers, rede da página (`fetch` do TileJSON traz
19 kB e de um tile real 116 kB, ambos 200), style, sprite, fontes, coordenadas, canvas, CSS e as
duas versões do MapLibre (6.2 e 5.24).

**O que sobra:** algo nesta máquina interfere na rede feita de dentro do *worker* do MapLibre.
Suspeitos: antivírus, filtro de endpoint, proxy de sistema. **Próximo passo é testar noutra máquina
ou rede — ação do Edu, não do CLI. Nada a corrigir no repositório até lá.**

**Não bloqueia a F-04:** o filtro opera sobre a lista e sobre o conjunto de marcadores, que
funcionam. O que falta desenhar é o fundo do mapa.

---

## 📊 Estado do banco

Reconferido via MCP na S06 (`list_tables`, `list_migrations`). RLS ligada nas 8 tabelas.

| Tabela | Linhas | Observação |
|---|---|---|
| `places` | 511 | **58 `published`** (lote de lançamento, S05), 453 `unreviewed` |
| `tags` | 94 | 93 públicas + `Hype trap` admin-only |
| `questions` | 38 | 4 com `requires_review` (as de texto livre) |
| `tiers` | 4 | `destination`, `experience`, `fair`, `cool` |
| `place_tags` | 145 | todas `source = 'suggested'` |
| `codes` | 1 | `DEMO`, para smoke da RPC |
| `curators` | 1 | `Michael` — `mikemyday@mikecofone.com`, conta confirmada |
| `field_reports` | 0 | |

Distribuição de julgamento: estrela 22 (4,3%), não visitados 42, com tier 279 (`fair` 182, `destination` 38, `experience` 30, `cool` 29), com área 107, 16 cidades.

**Lote de lançamento publicado na S05**, com aprovação do Edu: os 58 lugares com estrela ou tier `destination`, em 5 cidades (Austin 52, St. Augustine 3, Los Angeles 1, Mountain Home 1, Oxfordshire 1). Não foi julgamento novo — tier e estrela vieram dos guias do próprio Michael; o import só não os tinha revelado. Verificado pela API pública com a anon key: o visitante anônimo enxerga 58, não 511. Reversível com `UPDATE places SET status='unreviewed' WHERE status='published'`.

⚠️ **Nenhum dos 58 tem `the_dish` ou `curator_note`.** O guia está populado mas mudo: mostra os vereditos, não a voz. Escrever essas frases em 8-10 dos mais fortes é o que separa a demo de uma lista organizada — e é trabalho humano, não de CLI.

Migrations vivas — **3**, não 2 como este arquivo dizia até a S06: `20260806120000_f01_schema_rls_rpc`,
`20260806120100_f01_seed_and_import`, `20260806130000_f01_seed_curator`.

A F-02 e a F-03 **não alteraram o schema** — são frontend sobre o banco da F-01. O `place_tags`
continua com as 145 linhas `suggested` do import: a curadoria ainda não começou a escrever.

---

## 🗺️ Roteiro

| # | Feature | Status | Sessões |
|---|---|---|---|
| F-00 | Fundação | ✅ Concluída (S02) | ~0,5 |
| F-01 | Schema + dados | ✅ Concluída (S04) | ~1 |
| F-02 | Admin | ✅ Concluída (S05) | ~1 |
| F-03 | Público (city gate, mapa, lista, detalhe) | ⚠️ Concluída (S05) — mapa mudo por `BL-29` | ~1 |
| F-04 | Filtros facetados | ⬜ **Próxima** | ~1 |
| F-05 | Codes completo + Roulette | ⬜ | ~2 |
| F-06 | Field reports | ⬜ | ~1,5 |

Total estimado: ~10 sessões — **quatro das sete features fechadas em 5 sessões de CLI**, à frente
da estimativa. A curadoria do Michael roda em paralelo a partir da F-02 — ver Bíblia §13.1 — e
segue sendo o caminho crítico real do projeto.

---

## 📝 Log de sessões

### 2026-08-07 — S06: Reconciliação documental

**O que foi feito:** o boot encontrou o STATUS afirmando "F-01 concluída, F-02 a iniciar" com F-02 e
F-03 já commitadas na `main`. Este arquivo e a Bíblia foram realinhados com o real antes de qualquer
código novo.

**Divergências fechadas:**
- STATUS dizia fase F-01/próxima F-02; o real são quatro features fechadas e F-04 como próxima
- STATUS listava **2** migrations vivas; o MCP mostra **3** — a `20260806130000_f01_seed_curator`
  estava aplicada desde a S04 e nunca entrou nesta lista
- STATUS dizia que a F-02 estava "bloqueada por `OP-01` e `OP-02`"; o `OP-02` fechou na própria S04
  e o `OP-01` é higiene, não bloqueio — o teste negativo da S04 já provou que conta fora da
  allowlist é tratada como visitante
- Bíblia seguia em "F-00 e F-01 concluídas" e não registrava o OpenFreeMap como fonte de tiles
- `BL-25` no BACKLOG guardava o tamanho do chunk do mapa da época do MapLibre 6 (947 kB); com o v5,
  que embute o worker no mesmo arquivo, são 1.030 kB (274 kB gzip)

**Por que a S05 fechou sem atualizar o STATUS:** não sei — não estive nela. O log da S05 abaixo foi
reconstruído das mensagens de commit, que são detalhadas o bastante para isso. Fica o registro de
que é reconstrução, não relato ao vivo.

**Gate reexecutado nesta máquina:** `npm run build` e `npm run lint` limpos.

### 2026-08-06 — S05: F-02 (admin) e F-03 (público)

> Entrada reconstruída na S06 a partir das mensagens de commit `b83ff78..29239c6`. Fiel ao que está
> versionado; decisões tomadas em conversa que não deixaram rastro no repositório não aparecem aqui.

**O que foi feito:** duas features inteiras. O admin saiu de placeholder para ferramenta de curadoria
completa, e o lado público saiu do zero para navegável — portão de cidade, guia, detalhe e mapa.
Nenhuma das duas tocou o schema: são frontend sobre o banco da F-01.

**F-02 — Admin.** Lista com filtros, editor de lugar, atribuição de tags com `suggested` distinguido
visualmente do que veio do curador (RN-15), Overview com distribuição de tiers ao vivo (RN-06) e
quick-add mobile com geocoding Nominatim. Seis componentes shadcn entraram; nenhuma dependência npm
nova.

**Decisão de escopo: a tela dedicada de fila de revisão foi cortada.** As três filas — 28 conflitos
de tier, tags sugeridas pendentes, 15 sem tipo — viraram cartões no Overview que linkam para a lista
com o filtro já aplicado. Uma tela própria seria uma quarta forma de olhar os mesmos registros, com
o custo de manter dois lugares em sincronia. Registrado em "Fora do MVP".

**F-03 — Público.** O portão de cidade exibe cidades como pares com contagem (DP-02) — cidade de um
lugar não é escondida, só é honesta sobre ser um lugar. O guia separa "Eat & drink" de "Everything
else", porque o tipo é o segundo portão (§7) e parque estadual em lista de restaurante é ruído. O
detalhe lidera pelo veredito, nunca pelo endereço; horário de funcionamento não existe por causa do
ADR-06, e o botão de direções resolve — o app de mapas sabe, e sabe também se está aberto agora.

**Lote de lançamento publicado, com aprovação do Edu:** os 58 lugares com estrela ou tier
`destination` passaram de `unreviewed` a `published`. Não foi julgamento novo — tier e estrela vieram
dos guias do próprio Michael e o import só não os tinha revelado. Verificado pela API pública com a
anon key: o anônimo enxerga 58, não 511.

**O mapa: quatro tentativas, um bug real corrigido e uma causa ambiental.**

A investigação vale registro porque três dos quatro commits de fix foram becos, e o quarto encontrou
um bug de verdade:

1. `resize()` no `load` + `ResizeObserver` — o container é dimensionado depois que o mapa é
   construído (unidade `vh`, wrapper sticky, e o mapa vem de dentro de um `lazy`). Correto de fazer,
   não era a causa.
2. `config.WORKER_URL` explícito — o MapLibre 6 monta a URL do worker em runtime por concatenação de
   string, coisa que nenhum bundler enxerga, então o Rollup nunca emitia o arquivo. **Era um bug
   real**, provado por o mapa voltar a requisitar as fontes (só o worker dispara isso). Ainda assim
   os tiles não vieram.
3. **`fitBounds` só depois de `load` e com container de largura real** — este é o achado que fica.
   Enquadrar contra largura zero calcula um zoom degenerado, e o mapa nunca descobre de quais tiles
   precisa; o `resize` posterior conserta o canvas mas não recalcula a câmera, então a visão ruim
   ficava presa e os 52 marcadores de Austin apareciam amontoados num canto. Corrigido, os
   marcadores passaram a se distribuir com a geografia real. **E o enquadramento roda uma vez por
   conjunto de lugares (chave = ids), o que já deixa pronto o caminho da F-04.**
4. Downgrade `maplibre-gl` 6.2.0 → 5.24.0, aprovado pelo Edu. O v5 entrega arquivo único com o
   worker embutido, então as gambiarras do item 2 saíram. Não resolveu a renderização.

**O diagnóstico final é que não há o que corrigir.** Um mapa MapLibre puro, de CDN, em página em
branco e sem uma linha nossa, se comporta idêntico nos três navegadores. Registrado como `BL-29`
com a lista inteira do que foi descartado com evidência, para a próxima sessão não refazer o mesmo
caminho.

**`BL-25` parcialmente resolvido.** O MapLibre levou o bundle único a 1.647 kB — peso demais para
quem só abre o portão de cidade. O mapa virou `lazy` + `Suspense`: principal 699 kB (204 kB gzip),
chunk do mapa carregado só ao abrir uma cidade, e a lista já é utilizável enquanto ele chega.

**Aprendizado que vale além deste projeto:** três dos quatro fixes do mapa foram para o lugar errado
porque a hipótese nunca foi testada fora do nosso código. O teste que encerrou a questão — MapLibre
puro de CDN em página em branco — custa cinco minutos e deveria ter sido o primeiro, não o último.

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
