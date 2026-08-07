# Michaelin Map — STATUS

> Atualizado ao final de cada sessão de desenvolvimento.
> Lido no boot, junto de `.claude/CLAUDE.md`, `docs/MICHAELINMAP_BIBLIA.md` e `docs/BACKLOG.md`.

---

## 🗓️ Última atualização

**Data:** 2026-08-07
**Sessão:** S08 — F-06 (Field reports)
**Versão:** `0.1.0` — mantida por decisão do Edu; bump só quando o produto for ao ar
**Atualizado por:** Claude Code (orquestrador)

---

## 📍 Fase atual

**As sete features do MVP estão fechadas.** Admin, lado público, filtro facetado, Codes, Roulette e
Field reports. Não há próxima feature planejada.

**O caminho crítico agora é inteiramente humano** e não é código: nenhum dos 58 lugares publicados
tem `the_dish` ou `curator_note`, e as 145 atribuições de tag continuam todas `suggested`. O guia
mostra os vereditos, não a voz.

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

### F-04 — Filtros facetados ✅ (S06)

- [x] `src/lib/guide-filters.ts` — objeto de filtro único, **OR dentro da faceta e AND entre facetas** (RN-16),
      contagem ao vivo calculada contra as *outras* facetas ativas, serialização na URL (RN-19)
- [x] `src/components/public/guide-filter-panel.tsx` — opção zerada **desabilitada, não escondida** (RN-17);
      recolhível no telefone, sempre aberto no desktop
- [x] Filtro alimenta lista e mapa a partir do mesmo estado; o mapa reenquadra sozinho ao filtrar
- [x] Seleção que sai do resultado é limpa, para o mapa não destacar pin sem linha ao lado
- [x] Área só em cidade acima do piso de densidade (RN-18)
- [x] **Decisão de desenho:** faceta sem nenhuma opção populada não é renderizada. Não contraria a RN-17,
      que governa a *opção* dentro da faceta — é o princípio da §8 ("degradar em silêncio em vez de
      renderizar controle vazio") aplicado às demais facetas. Hoje seis das sete facetas de tag estão
      vazias (`BL-30`); elas aparecem sozinhas conforme o Michael taggear, sem deploy
- [x] Empty state autoral da combinação impossível (`BL-18` fechado)
- [x] **Verificado por harness descartável: 27 checks contra o banco vivo pelo caminho anônimo**, o que
      testa RLS e filtro juntos. Cobre OR/AND, contagem ao vivo, opção zerada desabilitada, opção
      selecionada que zerou continuar clicável, round-trip da URL, piso de densidade da área e a
      defesa em profundidade da RN-14
- [x] **Gate:** `npm run build` e `npm run lint` limpos. Bundle principal 699 → 707 kB

### F-05 — Codes + Roulette ✅ (S07)

- [x] **Nenhuma migration.** A F-01 já havia entregue `codes` com os seis campos de efeito e a
      `rpc_redeem_code()` com `anon` autorizado. Feature 100% frontend, zero dependência npm nova,
      zero componente shadcn novo
- [x] `src/lib/code-effects.ts` — tema por CSS custom properties (todo shadcn do app lê esses
      tokens, então um code repinta a interface sem tocar em componente nenhum); `contrastOn()`
      deriva o texto legível por luminância WCAG; fundo escuro liga a classe `dark`; token de estilo
      de mapa → URL, com fallback para valor desconhecido
- [x] `src/lib/roulette.ts` — sorteio ponderado (estrela 6, `destination`/`experience` 3, `cool` 2,
      `fair` 1), sobre o resultado **filtrado**, com `random` injetável e "spin again" que não repete
- [x] `src/lib/code-context.ts` + `code-provider.tsx` — code lembrado em `localStorage` mas
      **revalidado no servidor a cada carga** (RN-28); `?code=` aceito e retirado da URL na chegada
- [x] `code-entry.tsx` — escuta de teclado sem campo visível no desktop, dialog por long-press da
      logo no celular (PRD §9.7). Falha silenciosa na escuta: quem não perguntou nada não recebe erro
- [x] `code-banner.tsx` — faixa com a mensagem e a saída; aplica e **remove** o tema, montado no
      layout público para o admin nunca vestir o code de um visitante
- [x] `guide-map.tsx` — `setStyle` em runtime (os marcadores são DOM, sobrevivem à troca), pins
      repintados pelo code, anel nos destacados sem apagar a cor do tier
- [x] `guide.tsx` — preset semeia o painel uma vez e nunca sobrescreve a URL (RN-27); destacados
      sobem na ordem com selo "Picked for you"; Roulette ao lado da contagem
- [x] `/admin/codes` no lugar do placeholder — lista, editor com cor, estilo de mapa, pin, janela de
      datas, e o `preset_filter` montado **pelo próprio painel do visitante**
- [x] **Verificado no navegador** (a extensão do Chrome conectou, ao contrário da S06): code digitado
      no ar → URL virou `?tier=destination&star=1` sozinha, guia escureceu, banner apareceu, selo
      âmbar entrou na linha, pins viraram quadrados com anel, opções zeradas ficaram cinza e
      clicáveis. "Back to normal" desfez tudo. Troca de estilo confirmada por rede: `/styles/liberty`
      na carga, `/styles/dark` no instante do resgate
- [x] **60 checks num harness descartável**, os puros e o caminho anônimo real: code válido,
      minúsculo, com espaço, inexistente, vazio, desligado, ainda não começado e expirado — mais a
      prova de que toda falha responde idêntica (RN-20) e de que `anon` segue sem listar `codes`
- [x] `BL-19` fechado na parte de contraste; `BL-23` parcialmente resolvido
- [x] **Gate:** `npm run build` e `npm run lint` limpos. Bundle principal 707 → 736 kB (214 kB gzip)
- [ ] ⚠️ **A tela `/admin/codes` não foi clicada** — está atrás do login do curador e o CLI não tem
      a senha. `BL-31`

### F-06 — Field reports ✅ (S08)

- [x] **Nenhuma migration** — segunda feature seguida assim. A F-01 já tinha entregue a RPC, a view
      com `security_invoker`, as 38 perguntas e os grants. Verificado por introspecção antes de
      planejar: `anon` executa `rpc_submit_field_report` e **não** tem INSERT em `field_reports`,
      então a RN-23 está garantida no privilégio, não só na policy
- [x] `src/lib/field-reports.ts` — sorteio semeado em `lugar + navegador` (aleatório de verdade
      trocaria a pergunta debaixo do dedo a cada render), sorteio ponderado por `weight` sem
      reposição, validação por tipo de input, formatação do agregado espelhando o que a view
      **de fato** calcula (média só para `number` e `slider`; o resto reporta a moda)
- [x] `src/hooks/use-field-reports.ts` — perguntas, agregados, contador de progresso, submissão
      pela RPC, `session_hash` estável em `localStorage` com fallback para contexto não-seguro
- [x] `src/components/public/field-report-form.tsx` — os 7 tipos de input, um recibo por pergunta.
      `range` e `color` nativos cobrem slider e cor: acessíveis por teclado e sem dependência nova
- [x] `src/components/public/field-report-panel.tsx` — agregado com seriedade impassível (mono,
      tabular, `n = 5`), oculto abaixo de 5, e o contador de progresso no lugar do vazio
- [x] `/admin/reports` — fila de revisão do texto livre (aprovar/rejeitar) e a superfície de
      semeadura. "The dish you would order again" destacado, que é a única resposta de visitante
      que alimenta o julgamento do curador (Bíblia §10)
- [x] **RN-29 nova:** a pergunta de acompanhamento é escolha fechada, nunca texto livre — o
      `judgment` publica na hora quando a pergunta principal não exige revisão, então um campo
      aberto ali seria um segundo texto livre ao vivo e sem moderação
- [x] **61 checks num harness descartável**, metade pura e metade pelo caminho anônimo real. Os que
      mais valem: `anon` não consegue INSERT direto, texto livre cai em `pending` e fica invisível
      ao público, um `status` contrabandeado dentro do `answer` não muda nada, e o agregado **não**
      abre com quatro respostas e abre com a quinta
- [x] **Verificado no navegador:** duas perguntas sorteadas em 24 Diner e três em Aba (o 2-3 varia),
      acompanhamento aparecendo ao completar a resposta, recibo, pergunta já respondida some na
      visita seguinte, e o agregado renderizando `Yes · n = 5` depois da quinta
- [x] **Dois defeitos encontrados pelo olho, não pelas asserções** — ver o log da sessão
- [x] `BL-32` fechado: `placeholder.tsx` apagado com autorização do Edu
- [x] **Gate:** `npm run build` e `npm run lint` limpos. Bundle principal 736 → 762 kB (221 kB gzip)
- [ ] ⚠️ **A tela `/admin/reports` não foi clicada** — mesmo motivo do `BL-31`, está atrás do login
      do curador. O embed PostgREST da fila foi validado contra o banco à parte

---

## 🔄 Em andamento

Nada em execução.

---

## ⏭️ Próxima ação

**Não há próxima feature.** O MVP acabou. O que o produto precisa agora não é código:

1. **A voz, e só o Michael pode dar.** Nenhum dos 58 publicados tem `the_dish` ou `curator_note`.
   São duas perguntas de memória por lugar — "o que eu peço aqui?", "por que este importa?" — em 8 a
   10 dos mais fortes. Não precisa abrir o admin nem ter nada na mão. É a menor tarefa do projeto
   com o maior retorno, e com os Codes prontos é exatamente isso que um code entrega a uma pessoa.
2. **Taggear — também só ele.** O Edu não pode substituir (S08): nunca esteve nos lugares. Das 145
   atribuições, zero são do curador. Com a RN-31, nenhuma delas aparece mais ao visitante, então o
   painel tem três facetas até a curadoria começar (`BL-30`). **O que dá para adiantar sem ele** é
   sugerir `cuisine` em massa como fila de aprovação — `BL-34`.
3. **Duas filas com dado esperando o Michael:** os 28 conflitos de tier (`DP-08`) e as 145 tags
   sugeridas (`DP-09`). Ambas já têm superfície no Overview.
4. **Semear field reports** (`BL-20`): a superfície existe em `/admin/reports`; os valores são
   observações e têm de ser digitados por quem esteve no lugar.

**Do lado técnico, o que sobra é operacional:** clicar `/admin/codes` e `/admin/reports` logado
(`BL-31`), desabilitar o signup (`OP-01`) e configurar o deploy na Vercel, que nunca foi feito.

---

## 🚫 Blockers

**Nenhum blocker.** O MVP fechou e nada impede o produto de ir ao ar.

🔽 **`BL-29` deixou de ser bug e virou limitação da minha inspeção visual.** O Edu relatou na S08
que **vê o mapa normalmente no Firefox e no celular** — ou seja, o guia funciona para quem o usa, e
o mapa mudo é do Chrome automatizado desta máquina. O produto nunca esteve quebrado.

Isso **contradiz o registro da S05**, que dizia ter reproduzido em Chrome, Firefox e Edge com um
MapLibre puro de CDN: ou o ambiente mudou nesses meses, ou aquele teste não isolava o que se
pensava. Não refiz nenhum dos dois, e o que está acima é relato do Edu, não verificação minha.

**O que fica na prática:** quando uma sessão precisar conferir o mapa de verdade, quem olha é o Edu
— eu não tenho como. Só reabrir se alguém relatar mapa mudo num navegador de uso real.

**Um detalhe adjacente, da mesma sessão e possivelmente da mesma família:** o Chrome recusou
`localhost:5173` e `127.0.0.1:5173` com a porta comprovadamente escutando, e só respondeu pelo IP
de rede. Anotado no `.claude/CLAUDE.md` para a próxima verificação visual não perder tempo.

---

## 📊 Estado do banco

Reconferido via MCP na S06 (`list_tables`, `list_migrations`). RLS ligada nas 8 tabelas.

| Tabela | Linhas | Observação |
|---|---|---|
| `places` | 511 | **58 `published`** (lote de lançamento, S05), 453 `unreviewed` |
| `tags` | 94 | 93 públicas + `Hype trap` admin-only |
| `questions` | 38 | 4 com `requires_review` (as de texto livre) |
| `tiers` | 4 | `destination`, `experience`, `fair`, `cool` |
| `place_tags` | **173** | todas `source = 'suggested'` — 145 do import da F-01, 28 do lote de cuisine da S08. **Zero do curador** |
| `codes` | 1 | `DEMO`, para smoke da RPC. A S07 criou 4 codes de teste e **apagou os quatro** ao fim |
| `curators` | 1 | `Michael` — `mikemyday@mikecofone.com`, conta confirmada |
| `field_reports` | 0 | A S08 criou linhas de teste pela RPC e por SQL e **apagou todas** ao fim; a tabela voltou a zero, conferido |

Distribuição de julgamento: estrela 22 (4,3%), não visitados 42, com tier 279 (`fair` 182, `destination` 38, `experience` 30, `cool` 29), com área 107, 16 cidades.

**Lote de lançamento publicado na S05**, com aprovação do Edu: os 58 lugares com estrela ou tier `destination`, em 5 cidades (Austin 52, St. Augustine 3, Los Angeles 1, Mountain Home 1, Oxfordshire 1). Não foi julgamento novo — tier e estrela vieram dos guias do próprio Michael; o import só não os tinha revelado. Verificado pela API pública com a anon key: o visitante anônimo enxerga 58, não 511. Reversível com `UPDATE places SET status='unreviewed' WHERE status='published'`.

⚠️ **Nenhum dos 58 tem `the_dish` ou `curator_note`.** O guia está populado mas mudo: mostra os vereditos, não a voz. Escrever essas frases em 8-10 dos mais fortes é o que separa a demo de uma lista organizada — e é trabalho humano, não de CLI.

Migrations vivas — **4**: `20260806120000_f01_schema_rls_rpc`, `20260806120100_f01_seed_and_import`,
`20260806130000_f01_seed_curator` e `20260807140000_suggest_cuisine_published` (S08).
`schema_migrations` saneado após o apply, versões alinhadas com os nomes de arquivo.

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
| F-04 | Filtros facetados | ✅ Concluída (S06) | ~0,5 |
| F-05 | Codes completo + Roulette | ✅ Concluída (S07) | ~1 |
| F-06 | Field reports | ✅ Concluída (S08) | ~1 |

Total estimado: ~10 sessões — **as sete features fecharam em 7 sessões de CLI**, à frente da
estimativa. As duas últimas estavam orçadas em ~2 cada e saíram em ~1, pelo mesmo motivo: nenhuma
das duas precisou de schema, porque a F-01 já tinha construído o terreno. A curadoria do Michael
roda em paralelo desde a F-02 — ver Bíblia §13.1 — e agora é o **único** caminho crítico do
projeto: o código terminou à frente do conteúdo.

---

## 📝 Log de sessões

### 2026-08-07 — S08: F-06 — Field reports (o MVP fechou)

**O que foi feito:** a última feature do MVP. Visitantes agora respondem 2-3 perguntas por lugar,
os agregados abrem na quinta resposta, o texto livre espera o Michael numa fila, e o curador tem
onde semear as próprias respostas.

**Pela segunda sessão seguida, zero migration.** O boot conferiu o schema vivo antes de planejar e
encontrou tudo pronto desde a F-01: a RPC derivando status, truncando em 40 e limitando por sessão;
a view com `security_invoker` e o `HAVING count(*) >= 5`; as 38 perguntas semeadas. O achado que
mais vale registrar é do nível de privilégio: **`anon` executa a RPC e não tem INSERT em
`field_reports`**, então a RN-23 não depende de a policy estar certa — não existe caminho de escrita
direta para revogar.

**Uma regra nova saiu de uma coisa pequena.** Quatro perguntas carregam um acompanhamento
(`judgment_prompt` — "Was it worth it?", "Is that good or bad?") e o `judgment` é publicado na hora
sempre que a pergunta principal não exige revisão. Um campo de texto ali seria um **segundo** texto
livre do visitante, ao vivo e sem moderação, quando a RN-24 permite exatamente um. Virou **RN-29**:
o acompanhamento é escolha fechada, e os dois rótulos saem do próprio enunciado — que ou os oferece
("good or bad" → Good/Bad) ou é sim/não.

**Sobre semear (BL-20), o que foi entregue e o que não foi.** A superfície existe: o curador escolhe
um lugar, responde as perguntas na mesma UI do visitante, e as respostas entram publicadas. O que o
CLI **não** fez foi inventar os valores. Temperatura da comida no Franklin, pé-direito em mãos no
Uchi — eu nunca estive em nenhum dos 58, e o painel reporta com uma casa decimal e cara de medição;
um número inventado ali seria indistinguível de um medido. A Bíblia §10 sempre disse "**o curador**
semeia as próprias respostas". Vale saber que semear não revela agregado nenhum: o n=5 é por lugar ×
pergunta e uma pessoa dá uma resposta só — o ganho é o contador não nascer em zero.

**Verificação: 61 checks, e depois o olho — que achou o que os 61 não achavam.**

O harness cobriu o que asserção cobre bem: o sorteio ser estável para a mesma semente e mudar de
pessoa para pessoa, `anon` não conseguir INSERT direto, texto livre cair em `pending` e ficar
invisível ao público, um `status` contrabandeado dentro do `answer` não mudar nada, o agregado **não**
abrir com quatro respostas e abrir com a quinta.

Aí a página foi aberta no navegador e apareceram **dois defeitos que nenhum dos 61 pegava**, os dois
de estado de interface:

1. **O recibo nunca aparecia.** O painel filtra as perguntas já respondidas, e o predicado era
   reativo — responder uma pergunta a removia da lista no mesmo instante, desmontando o cartão antes
   de ele mostrar "Logged". Corrigido tirando um retrato do que já estava respondido **na abertura da
   página**: uma pergunta respondida agora fica de pé até o fim da visita, e só some na próxima.
2. **O recibo contava duas vezes** — dizia "2 of 5" na primeira resposta. A submissão invalida a
   query de contagem, que revalida já incluindo a resposta nova, e o `+1` somava em cima. Corrigido
   guardando a contagem de antes da resposta.

Nenhum dos dois é sutil de ver e nenhum era visível sem abrir a página. É a mesma lição que a S05
registrou por outro caminho, agora do lado do frontend: asserção prova regra, olho prova interface.

**Um detalhe do ambiente que vale saber.** O `session_hash` gerado no navegador saiu no formato de
fallback (`s-<timestamp>-<random>`) em vez de UUID: servido por HTTP no IP de rede, a página não é
um contexto seguro e `crypto.randomUUID` não existe. O fallback estava lá para isso e funcionou —
em produção (HTTPS na Vercel) será UUID. Não é bug, mas explica o formato se alguém olhar a coluna.

**Dado de teste criado e apagado.** A verificação escreveu em `field_reports` pela RPC e por SQL —
inclusive as cinco respostas necessárias para abrir um agregado de verdade na tela. Tudo apagado ao
fim por `session_hash`; a tabela voltou a zero, conferido.

**`BL-32` fechado:** `placeholder.tsx` estava órfão desde a F-05 e foi apagado com autorização do
Edu, depois de confirmar que ninguém o importava.

**O que ficou sem olhar, de novo dito explicitamente:** `/admin/reports` compila, passa no lint e o
embed PostgREST da fila (`places(...)`, `questions(...)`) foi validado contra o banco à parte — mas
a tela está atrás do login do curador e o CLI não tem a senha. Mesmo buraco do `BL-31`, agora com
duas telas dentro.

**Correção de registro:** o log da S07 dizia que o commit `c782770` era "local, não empurrado". O
boot desta sessão conferiu com `git fetch` e a `main` local está idêntica à `origin/main` — os três
commits da S07 estão no GitHub. Corrigido abaixo.

**Commit:** `5aa2b96`.

**Ainda na S08, depois da F-06: a faceta de rating saiu do filtro público**, por decisão do Edu. Ele
escolheu o alcance mais estreito dos três que apresentei — só a faceta; os selos `Destination`,
`Experience`, `Fair` e `Cool` continuam na linha da lista e na página do lugar, o admin e o banco
não foram tocados.

**A única decisão que tomei por conta foi tirar o parâmetro `tier` da URL junto com a faceta.**
Deixar o predicado vivo sem controle na tela criaria um filtro que estreita o guia de forma
invisível — a falha exata que a RN-27 foi escrita para impedir, e que ninguém conseguiria desfazer
porque não haveria o que clicar. Conferi antes que nenhum code dependia disso: o `DEMO` é o único
que existe e tem `preset_filter` null. Link antigo com `?tier=` agora é ignorado, verificado na tela.

Virou **RN-30**, e a Bíblia §6 ganhou a distinção que faltava: julgamento e eixo de navegação não são
a mesma coisa. O tier segue sendo tudo o que a §6 descreve; o que ele deixou de ser é uma faceta.
A estrela passa a ser o único sinal de qualidade filtrável — que é como os oito tipos sem tier
sempre funcionaram (RN-05), agora valendo também para restaurante e bar.

**Gate:** build e lint limpos. Bundle 762 → 761 kB.

**E o `BL-29` fechou como pergunta, ao fim da sessão.** Eu havia registrado que o mapa voltara a não
desenhar geometria nas duas telas de Austin desta verificação. O Edu respondeu que **vê o mapa no
Firefox e no celular** — o que encerra o assunto na direção que mais importava: o produto está
certo, e o mapa mudo é do Chrome que eu dirijo. Rebaixado de bug a limitação da inspeção pelo CLI.
Vale registrar que isso contradiz o teste da S05, que dizia ter reproduzido nos três navegadores;
não refiz nenhum dos dois, e o relato é do Edu, não verificação minha.

**A consequência operacional é para as próximas sessões:** eu não consigo conferir o mapa. Quando
uma verificação depender dele, quem olha é o Edu.

**Por último, o achado que mais muda o projeto — e não é técnico.** O Edu perguntou quais tags
existiam para atribuir e, ao ver a lista, disse que **não tem como taggear: ele nunca esteve em
nenhum desses lugares, a lista é do Michael.** Medi o estado real na sequência: das 145 atribuições,
**zero** são do curador; dos 58 publicados, 11 têm alguma tag e **nenhum** tem `the_dish`; 21 das 94
tags foram usadas alguma vez. A curadoria que este arquivo vinha descrevendo como "rodando em
paralelo desde a F-02" **nunca começou**, e não é falta de ferramenta — é que depende de uma pessoa
específica que ainda não sentou para fazer.

**Fui checar e achei uma coisa pior que o volume:** o lado público **não distinguia** tag sugerida
de tag do curador. `usePlaceTagLabels` e `buildGuideIndex` liam `place_tags` sem olhar `source`, e
as 5 cuisines que apareciam no painel de Austin eram 100% palpite do import — `Breakfast & Diner`,
com 56 usos, veio do **nome de um guia do Apple Maps**, não de alguém decidindo. Estava assim desde
a F-01; ninguém tinha olhado por esse ângulo.

Corrigido nesta sessão: **RN-31** — tag `suggested` não aparece em superfície pública nenhuma até
ser confirmada. O custo é visível e foi aceito de olho aberto: o painel de Austin caiu de cinco
facetas para três (estrela, tipo, área) e os selos de cuisine sumiram das páginas de lugar. Mostrar
menos do que se sabe é melhor que apresentar chute com a autoridade de veredito, num produto cujo
valor inteiro é o julgamento de uma pessoa (§1.1).

**O efeito colateral bom:** agora que sugestão é invisível ao visitante, sugerir em massa virou
seguro — vira fila de aprovação no admin, não afirmação pública. É o `BL-34`.

**E foi o que fechou a sessão: 28 cuisines novas** (`20260807140000_suggest_cuisine_published`),
levando os publicados de comida sem cuisine de 45 para 17. Duas coisas ficam registradas sobre o
critério:

- **Dez delas são legíveis do próprio nome** e qualquer um confere sem conhecer Austin: `ALC Steaks`
  → Steakhouse, `Chez L'Amour` → French, `Il Brutto` e `L'Oca d'Oro` → Italian, `El Raval` → Spanish
  (bairro de Barcelona). **As outras dezoito dependem de eu conhecer o restaurante**, o que é
  memória e não observação — pode estar desatualizada, e um lugar pode ter mudado de conceito.
  Justamente por isso todas entraram como `suggested`.
- **Dezessete ficaram de fora de propósito**, com a lista nominal no rodapé da migration. Sugestão
  errada custa mais que sugestão ausente: alguém tem de ler e rejeitar.

**Um GATE reprovou o primeiro apply, e o errado era eu.** O G3 afirmava que nenhum lugar carrega
duas cuisines; falhou apontando 11. Fui olhar: são todos do import da F-01 e **todos corretos** —
`Dean's Italian Steakhouse` é Italian *e* Steakhouse, cafeteria que serve café da manhã é Coffee *e*
Breakfast & Diner. Duas cuisines não são contradição; a regra que eu tinha escrito é que era. O
gate foi reescrito para o escopo do lote e a migration voltou atrás inteira antes disso — o banco
nunca ficou num estado intermediário.

**Verificado depois do apply:** o painel público de Austin continua com três facetas, sem nenhuma
seção de cuisine, com as 28 tags já no banco. É a RN-31 provada no sentido que importa — dado novo
entrou e o visitante não viu.

**Por fim, o repositório ficou pronto para a Vercel (`OP-04`).** Três coisas entraram, e a primeira
é a que importa:

- **`vercel.json` com rewrite de SPA.** Sem ele, `/city/austin` e `/place/canje` devolvem **404** em
  acesso direto — e acesso direto é precisamente o que um link compartilhado é. Um guia que só
  funciona se você navegar a partir da home não serve para o que este produto existe.
- **`public/robots.txt`** com `Disallow: /`. O `noindex` do `index.html` já cobria o ADR-07 para
  quem renderiza a página; isto cobre crawler que não executa JS. Cinto e suspensório, custo zero.
- **`engines.node >= 22`** no `package.json`. Sem isso o Vercel escolhe a versão de Node dele, e o
  Vite 8 não roda em Node antigo — é a causa clássica de primeiro deploy falhando.

**O que eu não fiz e não vou fazer sozinho:** autenticar na conta da Vercel. O passo a passo com as
variáveis está na conversa da sessão; o `.env.local` tem os valores e não vai para o repo.

**Checagem de segurança antes de expor:** `get_advisors(security)` não acusou nenhuma falha de RLS.
Os 8 avisos de `SECURITY DEFINER` são o `BL-28`, já aceito e reavaliado. Apareceu um aviso novo,
`auth_leaked_password_protection` desligado — toca a senha da conta do curador, não o visitante, e
resolve-se com um toggle no painel junto do `OP-01`.

### 2026-08-07 — S07: F-05 — Codes e Roulette

**O que foi feito:** a feature que o PRD chama de mais diretamente ligada ao propósito do produto
(§9.7 — "o curador cria um code para cada pessoa a quem mostra o guia, para sempre, sem envolver
desenvolvedor"). Entregue inteira, sem tocar o banco.

**O achado que definiu a sessão: a F-05 não precisava de migration.** O boot conferiu o schema vivo
antes de planejar e encontrou `codes` já com `theme`, `pin_style`, `preset_filter`,
`highlighted_places`, janela de datas e `active`; a `rpc_redeem_code()` aplicada, com `anon` já
autorizado a executá-la; e a policy de curador no lugar. A F-01 tinha construído o terreno inteiro
oito meses antes de alguém pisar nele. Resultado: zero migration, zero dependência npm, zero
componente shadcn novo — 10 arquivos novos e 5 tocados, tudo frontend.

**Duas decisões de comportamento viraram RN, porque não são detalhe de implementação:**

- **RN-27** — o preset de um code semeia o painel **uma vez**, entra selecionado, sai pelo *Clear*
  normal, e **nunca sobrescreve filtro já presente na URL**. Sem isso, um preset seria um code
  escondendo lugares, que é exatamente o que a RN-21 proíbe. Link compartilhado é escolha explícita
  de alguém e vence a decoração.
- **RN-28** — o code é lembrado em `localStorage` (o Michael entrega um code a uma *pessoa*, não a
  uma aba) mas o efeito é **revalidado no servidor a cada carga**. Desligar um code no admin passa a
  valer na próxima visita, em vez de ficar preso no navegador de quem já o usou.

**Um detalhe de URL que virou regra no CLAUDE.md.** `filtersToParams()` monta um `URLSearchParams`
do zero a cada clique, então um `?code=` estacionado ali sumiria no primeiro toque em faceta — e
reapareceria no próximo compartilhamento. Pior do que não suportar. A solução foi resgatar e retirar
o parâmetro na chegada; a regra geral é que a URL do guia pertence ao filtro.

**Contraste resolvido na origem, não policiado depois.** `contrastOn()` deriva
`--primary-foreground` e `--foreground` da luminância WCAG da cor que o curador escolheu, então
nenhum tema de code pode nascer ilegível, por pior que seja a cor. Fecha a parte de contraste do
`BL-19` sem precisar auditar componente por componente. E fundo escuro liga a classe `dark`, porque
sobrescrever só `--background` deixaria borda, texto suave e acento nos valores claros — página
escura com costura clara em toda parte.

**Verificação: desta vez houve olho, não só asserção.** A extensão do Chrome conectou (na S06 não
conectara, e o registro da época dizia isso com todas as letras). O code foi digitado no ar na
página do guia e, em sequência e sem mais nenhum toque: a URL virou `?tier=destination&star=1`
sozinha, o guia inteiro escureceu, o banner apareceu com a mensagem e a saída, o selo âmbar "Picked
for you" entrou na linha do Canje, os pins viraram quadrados âmbar com anel nos destacados, e as
opções que zeraram ficaram cinza e ainda clicáveis (RN-17). "Back to normal" desfez tudo. A troca de
estilo de mapa ficou provada por rede: `/styles/liberty` na carga, `/styles/dark` no instante exato
do resgate.

Antes disso, **60 checks num harness descartável** cobriram o que o olho não vê: o caminho anônimo
real com code válido, minúsculo, com espaço em volta, inexistente, vazio, desligado, ainda não
começado e expirado — mais a prova de que toda falha responde byte a byte igual, que é o que impede
a RPC de virar oráculo de códigos (RN-20), e de que `anon` continua sem conseguir listar `codes`.

**O `BL-29` deixou de reproduzir.** O mapa desenhou geometria completa nos dois estilos. Nada mudou
no nosso código do mapa além do `setStyle` que esta feature acrescentou. Está registrado como
sintoma ausente, **não** como causa explicada — não fui atrás do porquê, porque a investigação
técnica já tinha sido esgotada na S05 e o próximo passo registrado era do Edu. Se voltar, o
histórico do que já foi descartado com evidência continua no `BL-29`.

**O que ficou sem olhar, dito explicitamente:** a tela `/admin/codes` compila e passa no lint, mas
está atrás do login do curador e o CLI não tem a senha do Michael. É o único pedaço da entrega que
ninguém viu rodando (`BL-31`).

**Dívida assumida.** O harness dos 60 checks é descartável de novo, não suíte versionada — foi para
o scratchpad, fora do repo. O `BL-22` ganhou a técnica que o tornou possível: `vite build --ssr`
bunda um harness TS resolvendo os aliases `@/`, o Node roda o resultado, e um `document` de mentira
de dez linhas basta para testar o que escreve CSS var. É o esboço pronto da suíte quando ela vier.

**Versão mantida em `0.1.0`** por decisão do Edu — bump só quando o produto for ao ar.

**Commit:** `c782770` — está no GitHub (a S08 conferiu; este registro dizia "local, não empurrado").

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

**Depois da reconciliação, a F-04 foi construída na mesma sessão** — ver abaixo.

**F-04 — filtros facetados.** A decisão que define a feature foi tomada antes de escrever código, a
partir do banco vivo: medindo o vocabulário real dos 58 publicados, seis das sete facetas de tag têm
**zero** atribuições, `price_band` tem zero, e só 11 lugares carregam alguma tag. Construir o painel
completo renderizaria cinco seções inteiras de checkbox cinza.

Daí a regra nova: **faceta sem nenhuma opção populada não é renderizada.** Ela não contraria a RN-17,
que governa a opção dentro da faceta e continua valendo — é a §8 ("degradar em silêncio em vez de
renderizar controle vazio") aplicada além da área. O efeito é que o painel cresce sozinho conforme a
curadoria avança, sem deploy, que é o ponto de tags serem dado e não código (RN-13).

**Verificação.** A extensão do Chrome não estava conectada, então não houve inspeção visual. Em vez
de afirmar sem olhar — o erro que a S05 registrou como aprendizado — a lógica foi verificada por um
harness descartável que lê o guia **pelo caminho anônimo real** (PostgREST + anon key, RLS em vigor) e
roda as funções de filtro sobre o resultado: 27 checks, todos passando. Testa RLS e filtro juntos, e
inclui o caso adversarial da RN-14 (injetar uma atribuição de `Hype trap` e provar que ela não vira
faceta nem entra no índice, mesmo se o RLS falhasse).

Um dos checks passou inicialmente por cláusula de escape — nenhuma opção zerada existia nos dados, e
a asserção da RN-17 não chegou a ser exercida. Forçado o caso (`cuisine=bbq` em Austin são dois
`destination`, então os outros três tiers zeram) e a regra foi verificada de verdade, incluindo que a
opção selecionada que esvaziou a lista continue clicável — senão o visitante não consegue desfazer.

**O que fica registrado como dívida:** o harness é descartável, não suíte versionada. A próxima
mudança no filtro não tem rede (`BL-22` atualizado). E as seis facetas dormentes viraram `BL-30` —
não como bug, mas como o sintoma visível de que a curadoria é o caminho crítico.

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
