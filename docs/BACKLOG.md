# Backlog — Michaelin Map

> Fonte única de pendências: dívida técnica, cortes de escopo, divergências de material e decisões abertas.
> Ler no boot junto de `docs/STATUS.md`.

---

## 1. Correções técnicas da F-01 — ✅ todas fechadas (S04)

Achados na auditoria do schema original (`docs/files/2026-08-05-supabase-schema.sql`), aplicados
na migration `20260806120000_f01_schema_rls_rpc.sql` e verificados pelos GATEs inline.

| # | Achado | Severidade | Como ficou |
|---|---|---|---|
| ✅ BL-01 | `codes` com `SELECT` público permitia a qualquer visitante listar todos os códigos secretos | 🔴 Alta | `codes` não tem nenhuma policy de SELECT, e `anon` não tem nem GRANT na tabela. Só `rpc_redeem_code()`, que responde `{"ok": false}` idêntico em toda falha para não virar oráculo |
| ✅ BL-02 | `field_reports` com `insert with check (true)` deixava o visitante gravar `status = 'published'` direto | 🔴 Alta | Nenhuma policy de INSERT existe na tabela. Só `rpc_submit_field_report()`, que deriva o status de `questions.requires_review`. Default da coluna virou `pending` (fail closed) |
| ✅ BL-03 | `auth.role() = 'authenticated'` dava escrita total a qualquer conta autenticada | 🔴 Alta | Tabela `curators` + `is_curator()` SECURITY DEFINER com `search_path` fixo. Falta desabilitar signup no painel — ver §7 |
| ✅ BL-04 | `apple_id` sem `UNIQUE` quebrava o upsert do import | 🟡 Média | `UNIQUE (apple_id)`, verificado pelo GATE G12 |
| ✅ BL-05 | Seed não idempotente: rodar 2× duplicava as 38 perguntas | 🟡 Média | `UNIQUE (prompt)` em `questions`; todo bloco do seed usa `ON CONFLICT DO NOTHING` por chave natural |
| ✅ BL-06 | View `field_report_aggregates` sem `security_invoker` contornava o RLS | 🟡 Média | `WITH (security_invoker = on)`, verificado pelo GATE G8 |
| ✅ BL-07 | `place_tags` com `SELECT using (true)` vazava IDs de lugares não publicados e tags admin-only | 🟢 Baixa | Policy com duplo `EXISTS` (place publicado **e** tag ativa não-admin). Anon vê 0 de 145 hoje |

---

## 2. Divergências no material de origem

Encontradas ao cruzar PRD × `CLAUDE.md` do produto × `PLAN.md` × `schema.sql` × CSV. Nenhuma bloqueia o build; registradas para não serem redescobertas.

| # | Divergência | Resolução |
|---|---|---|
| ✅ BL-08 | `Hype trap` é citado no PRD §6.4 mas não existe nas 93 tags do seed | Criada em `character` com `admin_only = true` (S04). Anon enxerga 93 tags, não 94 |
| BL-09 | PRD §9.10 descreve um primitivo `Collection` unificando codes, listas curadas e shortlist — não existe no schema | Shortlist saiu do MVP; `codes.highlighted_places` cobre o caso restante. Reabrir só se a shortlist voltar |
| BL-10 | Trip Builder está no PRD §5 como in-scope v1, mas não aparece em nenhuma das 9 fases do `PLAN.md` | Fora do MVP (§4 abaixo) |
| ✅ BL-11 | PRD diz "single-user authentication"; a curadoria é feita por duas pessoas | **O PRD estava certo.** Decidido na S04: uma conta só (a do Michael), que o Edu também usa. A allowlist `curators` continua sendo o mecanismo — só que com uma linha |
| ✅ BL-12 | A tag `Breakfast & brunch` do CSV não existe no vocabulário de 93 | Mapeada para `cuisine/breakfast-diner` no import (S04). 54 lugares, `source = 'suggested'` |
| ✅ BL-13 | `Dallas–Fort Worth` no CSV usa travessão (en-dash), não hífen | Normalizado para hífen no import (S04). GATE G10b garante que nenhum valor de cidade carrega en-dash |

---

## 3. Dívida técnica assumida

| # | Item | Motivo |
|---|---|---|
| ✅ BL-14 | As 5 skills mantinham exemplos do WiseFacilities — objetos que não existem aqui | Reescritas na S04 sobre os objetos reais. `naming` também tinha um risco pior que os exemplos órfãos: prescrevia **formato BR** (`1.234,56`, `DD/MM/YYYY`, `R$`), em contradição direta com o ADR-02. `spec-format` foi marcada como não usada (ADR-04), preservada só como referência |
| BL-15 | `docs/GANTT-MichaelinMap.csv` e `docs/DOMAIN_QUESTIONS.md` estão preenchidos com o conteúdo-exemplo do template e não são mantidos neste projeto | ADR-04. Arquivos preservados mas fora de uso — não ler no boot, não atualizar |
| BL-16 | `docs/files/CLAUDE.md` (vindo do Claude Web) coexiste com `.claude/CLAUDE.md` e diverge dele | `.claude/CLAUDE.md` é o canônico. O de `docs/files/` é material de origem |
| BL-17 | Sem tabela de auditoria — apenas `places.updated_by` + `updated_at` | Com **uma** conta de curador (S04), `updated_by` é constante e não atribui edição a ninguém. `updated_at` continua útil (alimenta a lista de desatualizados da F-02). Reabrir só se surgir uma segunda conta |
| BL-21 | `npm audit` acusa 2 vulnerabilidades high em `react-router` (GHSA-qwww-vcr4-c8h2, CSRF bypass no **modo RSC**) | **Não se aplica**: SPA sem React Server Components. O "fix" seria downgrade major para 7.11.0. Revisar quando o advisory for atualizado |
| BL-22 | Sem Vitest configurado | **A previsão se cumpriu na S06** e de novo na S07: 27 checks do filtro, depois 60 do motor de codes e da Roulette, todos por harness descartável e nenhum versionado. **A técnica da S07 vale registrar:** `npx vite build --ssr harness/x.ts --outDir harness/dist` bunda um arquivo TS resolvendo os aliases `@/`, e o `node harness/dist/x.js` roda o resultado — assim o harness exercita os módulos reais, não uma cópia. Com um `document` de mentira de dez linhas dá até para testar o que escreve CSS var. É o caminho mais curto entre "sem Vitest" e "testado de verdade", e também o esboço pronto da suíte quando ela vier. **Terceira repetição na S08** (61 checks do motor de field reports), e agora com o argumento mais forte a favor de versionar: a F-06 tinha os 61 checks passando e **mesmo assim dois defeitos de interface** — recibo que nunca aparecia e contador que somava duas vezes — só apareceram ao abrir a página. Uma suíte não teria pego esses dois; o que ela pega é a regressão dos 61 na próxima mudança, que hoje ninguém pega |
| BL-30 | **Seis das sete facetas de tag estão dormentes.** `format`, `occasion`, `vibe`, `logistics`, `dietary` e `character` têm zero atribuições nos publicados, então o painel da F-04 não as renderiza | Não é bug: por desenho, faceta sem opção populada não aparece, e elas surgem sozinhas conforme o Michael taggear, sem deploy. Registrado porque é o sintoma visível de que a curadoria (Bíblia §13.1) é o caminho crítico — o filtro está pronto e esperando o dado. **Atualizado na S08:** com a faceta de rating removida (RN-30), o painel hoje oferece estrela, tipo, área e 5 cuisines. Isso torna a taggeação mais urgente, não menos: o painel perdeu um eixo e os que sobram dependem quase todos de tag |
| BL-23 | Sem tema claro/escuro escolhível pelo visitante | **Parcialmente resolvido na F-05 (S07).** Um code agora repinta `--primary`, `--background` e `--foreground` em runtime, e fundo escuro liga a classe `dark`, que é o que faz borda, texto suave e acento acompanharem em vez de ficarem com costura clara. O que **não** existe é um seletor: quem manda no tema é o code, e por isso o `code-effects.ts` pode ser dono exclusivo da classe `dark`. Criar um seletor de tema depois exige decidir quem ganha quando os dois falam. `next-themes` segue instalado como dependência órfã — remover se nada passar a usá-lo |
| BL-25 | Bundle acima do aviso de 500 kB do Vite | **Parcialmente resolvido na S05.** O MapLibre entrou e levou o bundle único a 1.647 kB (450 kB gzip), o que era peso demais até para quem só abre o portão de cidade. O mapa virou `lazy` + `Suspense`: principal 699 kB (204 kB gzip), chunk do mapa carregado só ao abrir uma cidade. **Número do chunk corrigido na S06:** são 1.030 kB (274 kB gzip), não os 947 kB registrados aqui — aquele valor era da época do MapLibre 6; o v5 embute o worker no mesmo arquivo. O principal ainda passa dos 500 kB — próximo candidato é dividir por rota (admin × público), já que o visitante nunca carrega o admin |
| BL-26 | As 4 tags de `logistics` marcadas `is_derived = true` (`Open late`, `Open Monday`, `Closes early`, `Open for breakfast`) seriam calculadas a partir de horário de funcionamento, que saiu com o ADR-06 | Não há automação por trás delas. Ficam no vocabulário como atribuíveis pelo curador. Decidir na F-02 se o admin ainda deve tratá-las de forma diferente, ou se `is_derived` vira campo morto |
| BL-27 | A migration `20260806120100_f01_seed_and_import.sql` (155 kB) foi aplicada por `execute_sql` em blocos, não por `apply_migration` — o payload de 511 linhas era grande demais para uma chamada só | O arquivo em `supabase/migrations/` é o artefato de verdade e o `schema_migrations` foi saneado à mão para refletir isso. Conteúdo do banco conferido contra o CSV por checksum. Se surgir outro import em massa, usar o SQL Editor do painel |
| ⚠️ BL-29 | **O mapa não desenha geometria** nesta máquina. Marcadores aparecem e se posicionam certo; nenhum tile renderiza | **Intermitente: parou na S07, voltou na S08.** Na verificação da S08 (remoção da faceta de rating) o mapa de Austin desenhou os pins posicionados certo e **zero geometria**, fundo liso, nas duas telas. Entre a S07 e a S08 o nosso código do mapa não mudou. **O que a intermitência acrescenta:** a hipótese ambiental fica mais forte, porque causa no código não vai e volta sozinha entre duas sessões sem deploy. Continua sem valer a pena refazer a investigação — o registro abaixo permanece válido e o próximo passo continua sendo do Edu (testar noutra máquina ou rede). **O registro da S07, mantido:** parou de reproduzir — sintoma ausente, não causa explicada. Na verificação visual da F-05 o mapa desenhou geometria completa: rodovias com rótulo (`Express 183 Toll`, `Loop 1`), parques e água, tanto no estilo escuro do code quanto no padrão. Nada no código do mapa mudou além da troca de estilo em runtime que a F-05 acrescentou. **Não sei o que mudou no ambiente** e não fui atrás — a investigação já estava esgotada e o próximo passo registrado era do Edu. Fica aberto com aviso: se voltar a acontecer, o registro abaixo continua valendo e não deve ser refeito. Um detalhe adjacente da mesma sessão pode ou não ser da mesma família: o Chrome recusou `localhost:5173` e `127.0.0.1:5173` com a porta escutando, e só respondeu pelo IP de rede (anotado no `.claude/CLAUDE.md`). **O histórico da investigação original:** **não é o nosso código — provado.** Um mapa MapLibre puro, carregado de CDN numa página em branco, sem uma linha nossa, se comporta idêntico: `sourcedata:openmaptiles:pending` para sempre, nunca `loaded`, zero rendered features, **zero erros**. Reproduz em Chrome, Firefox e Edge. **Descartado com evidência:** WebGL (2.0, GPU AMD via ANGLE), Web Workers (worker de blob responde normalmente), rede da página (`fetch` do TileJSON traz 19 kB e de um tile real traz 116 kB, ambos 200, do próprio contexto da página), style, sprite, fontes, coordenadas, tamanho de canvas, CSS, e as duas versões do MapLibre (6.2 e 5.24). **O que sobra:** algo nesta máquina interfere na rede feita de dentro do *worker* do MapLibre — antivírus, filtro de endpoint ou proxy de sistema são os suspeitos, já que a mesma requisição funciona a partir da página. Próximo passo: testar noutra máquina ou rede. Nada a corrigir no repositório até lá |
| BL-31 | **Duas telas do admin nunca foram vistas rodando: `/admin/codes` (F-05) e `/admin/reports` (F-06).** As duas compilam e passam no lint, mas estão atrás do login do curador e o CLI não tem a senha do Michael | O lado público das duas features foi todo conferido no navegador; isto é o que sobrou. **Da F-06, o risco de runtime que dava para eliminar sem login foi eliminado:** o embed PostgREST da fila (`places(name,slug)`, `questions(prompt,input_type,unit_label)`) foi disparado contra o banco à parte e resolve — relacionamento errado teria estourado ali. O Edu abre e clica: em Codes, criar um code, salvar e resgatar no guia; em Reports, aprovar/rejeitar um texto livre e semear um lugar. **Para a fila ter o que mostrar é preciso existir uma resposta `pending`** — ou seja, alguém responder uma das 4 perguntas de texto livre no guia. Elas são 4 de 38 no sorteio, então pode ser preciso abrir alguns lugares diferentes até uma cair |
| ✅ BL-32 | `src/pages/admin/placeholder.tsx` ficou sem nenhum uso quando a F-05 substituiu a rota `/admin/codes` | Apagado na S08 com autorização do Edu, depois de confirmar por varredura que ninguém importava o `AdminPlaceholder`. Build limpo em seguida |
| BL-33 | O code `DEMO` semeado na F-01 traz `theme.mapStyle = "amber"`, que nunca foi um estilo de mapa | Inofensivo — `mapStyleUrl()` cai no padrão em vez de entregar URL inválida ao MapLibre, e há check cobrindo exatamente isso. Corrigir pelo admin na primeira vez que o Edu abrir a tela, ou deletar o `DEMO` quando existir um code de verdade |
| BL-28 | `get_advisors(security)` acusa 8 WARN de "SECURITY DEFINER executável por anon/authenticated" | **Aceito, não é achado.** São `is_curator()` (as policies RLS precisam executá-la), as duas RPCs públicas por desenho (Bíblia §11), e `rls_auto_enable()` — um *event trigger* da plataforma Supabase que liga RLS em tabela nova no `public`. Como retorna `event_trigger`, não é invocável via PostgREST. Nenhuma delas expõe dado: as três nossas têm `search_path` fixo e filtram na saída. Reavaliar só se surgir RPC nova |

---

## 4. Fora do MVP

Cortado com motivo. Não repropor sem fato novo.

| Item | Motivo do corte |
|---|---|
| Tela dedicada de fila de revisão (F-02) | Cortada na S05. As três filas — 28 conflitos de tier, tags sugeridas pendentes, 15 sem tipo — já são cartões no Overview que linkam para a lista com o filtro aplicado. Uma tela própria seria uma quarta forma de olhar os mesmos registros, com o custo de manter dois lugares em sincronia |
| Google Places API + hidratação dos 511 | ADR-06 — preço é julgamento do curador; horário resolve pelo botão de direções |
| My Maps KML sync + `sync_runs` + teste de sabotagem | ADR-08 — quick-add mobile já é caminho completo de captura |
| SEO: sitemap, JSON-LD, meta dinâmica, pré-render | ADR-07 — o guia é não-listado |
| Trip Builder | Escopo grande, contexto "out-of-towner" é secundário para um guia entre amigos |
| Settle It (bracket head-to-head) | O próprio PRD §4 descartou a decisão em grupo como contexto primário |
| I'm Hungry Now (aberto agora, perto de mim) | Depende de horário de funcionamento, que saiu com o ADR-06 |
| Bad Idea | Baixo valor marginal sobre o filtro de `character` + Roulette |
| Shortlist local | Sem conta e sem servidor, o ganho sobre favoritar no navegador é pequeno |
| Área por polígono geográfico | `area` vira campo manual opcional no admin |
| TanStack Table | Lista simples resolve para 511 linhas e 2 usuários |

---

## 5. Decisões abertas

| # | Item | Quem decide |
|---|---|---|
| DP-06 | O Michael quer aparecer no guia — rosto, perfil de gosto, página "about"? | Michael. Afeta copy e tom, não bloqueia build |
| DP-07 | Notas de voz por lugar — alto valor de personalidade, escopo moderado | Michael. Candidata a fase futura |
| DP-08 | Os 28 conflitos tier+não-visitado, os 15 sem classificação e os 4 fora do cruzamento tier×tipo | Michael, na fila de revisão do admin (F-02). Os 28 já estão marcados no banco: `'CONFLICT:TIER+UNVISITED' = ANY (source_guides)` |
| DP-09 | As 145 tags `source = 'suggested'` gravadas no import precisam de confirmação ou rejeição | Michael, na F-02. O admin tem de distinguir visualmente de tag do curador (RN-15). Reverter tudo é `DELETE FROM place_tags WHERE source = 'suggested'` |

---

## 6. UX e polimento

| # | Item | Quando |
|---|---|---|
| ✅ BL-18 | Copy autoral por combinação impossível de filtro — o momento exato em que o visitante iria embora, e o melhor lugar do produto para ter graça | Feito na F-04 (S06). "Nothing is all of those things. Michael has opinions, not miracles…" — a piada também ensina a semântica AND (RN-16), que é a única coisa que um painel facetado nunca torna óbvia sozinho |
| BL-19 | Acessibilidade: filtros navegáveis por teclado, contraste suficiente em todos os temas de Code, informação do mapa disponível na lista para leitor de tela | **O contraste fechou na F-05 (S07)** e fechou na origem: `contrastOn()` deriva `--primary-foreground` e `--foreground` da luminância WCAG da cor que o curador escolheu, então nenhum tema de code pode nascer ilegível — não há o que policiar componente a componente. Verificado (`#F5C518` → texto quase preto; `#101014` → texto quase branco). **Continuam abertos:** navegação dos filtros por teclado e a informação do mapa disponível na lista para leitor de tela |
| BL-20 | Semear as próprias respostas de field report para nada nascer em zero | **Ferramenta entregue na F-06 (S08), semeadura pendente do Michael.** `/admin/reports` tem a aba onde o curador escolhe um lugar, responde as perguntas na mesma UI do visitante e arquiva tudo de uma vez; as respostas entram publicadas e ficam identificáveis por `session_hash = 'curator'` (desfazer é `delete from field_reports where session_hash = 'curator'`). **Os valores não foram gerados pelo CLI de propósito** — são observações, e um pé-direito inventado seria indistinguível de um medido num painel que reporta com uma casa decimal. Duas coisas a saber antes de usar: semear **não** revela agregado nenhum (o n=5 é por lugar × pergunta e uma pessoa dá uma resposta só; o ganho é o contador não nascer em zero), e não há por que semear as 38 — o sorteio mostra 2-3 por visita |

---

## 7. Pendências operacionais no painel Supabase

Não são código. Precisam de alguém logado num painel. Nenhuma bloqueia código — o MVP fechou na S08.

| # | Item | Estado |
|---|---|---|
| OP-01 | Desabilitar signup no projeto Supabase | ⬜ Pendente, mas **não é buraco de segurança**: o teste negativo da S04 mostrou que conta autenticada fora da allowlist é tratada como visitante — 0 lugares, 0 codes, escrita bloqueada. É higiene, para não acumular conta órfã |
| ✅ OP-02 | Criar a conta do Michael e inserir a linha em `curators` | Feito na S04. `mikemyday@mikecofone.com`, confirmada, semeada por `20260806130000_f01_seed_curator.sql` com `name = 'Michael'`. Verificado ponta a ponta com JWT simulado |
| OP-04 | **Deploy na Vercel — nunca foi configurado.** A Bíblia §3 previa "a configurar após a F-03" e ficou para trás | ⬜ Pendente. Com o MVP fechado, é o que separa o guia de existir só nesta máquina — e sem ele os Codes não têm onde ser entregues a ninguém. Lembrar do `noindex` (ADR-07), que já está no `index.html`, e de levar as duas variáveis `VITE_` para o painel da Vercel |
| ✅ OP-03 | Versionar fora desta máquina | Feito na S04, mas não onde estava previsto. A credencial do Git nesta máquina é da conta `AntonioTavaresDevWork`, que não enxerga `AdminFeedpro/MichaelinMap` — daí o push responder "Repository not found". Por decisão do Edu, o projeto passou a morar em `AntonioTavaresDevWork/MichaelinMap` (privado), com os 9 commits e o histórico da fundação preservado |
