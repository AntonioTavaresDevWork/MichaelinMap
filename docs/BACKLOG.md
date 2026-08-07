# Backlog — Michaelin Map

> Fonte única de pendências: dívida técnica, cortes de escopo, divergências de material e decisões abertas.
> Ler no boot junto de `docs/STATUS.md`.

---

## 1. Correções técnicas a aplicar na F-01

Achados na auditoria do schema original (`docs/files/2026-08-05-supabase-schema.sql`). Todos já estão documentados na Bíblia §9 e §11 — esta lista é o checklist de execução.

| # | Achado | Severidade | Onde corrigir |
|---|---|---|---|
| BL-01 | `codes` com `SELECT` público (`using active = true`) permite a qualquer visitante listar todos os códigos secretos | 🔴 Alta | Revogar SELECT público; expor só via `rpc_redeem_code()` |
| BL-02 | `field_reports` com `insert with check (true)` permite ao visitante gravar `status = 'published'` direto, furando o review-gate das 4 perguntas de texto livre | 🔴 Alta | Revogar INSERT público; entrar só por `rpc_submit_field_report()` com status derivado |
| BL-03 | `auth.role() = 'authenticated'` dá escrita total a qualquer conta autenticada. Com signup aberto, um estranho vira curador | 🔴 Alta | Tabela `curators` + `is_curator()`; desabilitar signup no painel Supabase |
| BL-04 | `apple_id` sem `UNIQUE`, mas `import-places.ts` faz `upsert(onConflict: 'apple_id')` — quebra em runtime | 🟡 Média | `UNIQUE (apple_id)` |
| BL-05 | Seed não é idempotente: `questions` não tem constraint de unicidade, rodar 2× duplica as 38 perguntas | 🟡 Média | `ON CONFLICT DO NOTHING` com chave natural |
| BL-06 | View `field_report_aggregates` sem `security_invoker` contorna o RLS | 🟡 Média | `with (security_invoker = on)` |
| BL-07 | `place_tags` com `SELECT using (true)` vaza IDs de lugares não publicados e tags admin-only | 🟢 Baixa | Policy com `EXISTS` sobre place publicado + tag não-admin |

---

## 2. Divergências no material de origem

Encontradas ao cruzar PRD × `CLAUDE.md` do produto × `PLAN.md` × `schema.sql` × CSV. Nenhuma bloqueia o build; registradas para não serem redescobertas.

| # | Divergência | Resolução |
|---|---|---|
| BL-08 | `Hype trap` é citado no PRD §6.4 mas não existe nas 93 tags do seed | Criada em `character` com `admin_only = true` na F-01 |
| BL-09 | PRD §9.10 descreve um primitivo `Collection` unificando codes, listas curadas e shortlist — não existe no schema | Shortlist saiu do MVP; `codes.highlighted_places` cobre o caso restante. Reabrir só se a shortlist voltar |
| BL-10 | Trip Builder está no PRD §5 como in-scope v1, mas não aparece em nenhuma das 9 fases do `PLAN.md` | Fora do MVP (§4 abaixo) |
| BL-11 | PRD diz "single-user authentication"; a curadoria é feita por duas pessoas | Allowlist de 2 curadores (Bíblia §11) |
| BL-12 | A tag `Breakfast & brunch` do CSV não existe no vocabulário de 93 — o mais próximo é `Breakfast & Diner` (cuisine) e `Open for breakfast` (logistics) | Mapear no import da F-01 |
| BL-13 | `Dallas–Fort Worth` no CSV usa travessão (en-dash), não hífen | Normalizar no import |

---

## 3. Dívida técnica assumida

| # | Item | Motivo |
|---|---|---|
| BL-14 | As 5 skills em `.claude/skills/` mantêm exemplos do WiseFacilities (`audit_log`, `capacidades`, `is_admin_atual()`) — objetos que não existem aqui | Adaptar aos objetos reais após a F-01, quando o schema existir. Risco atual: um agente inferir tabelas inexistentes |
| BL-15 | `docs/GANTT-MichaelinMap.csv` e `docs/DOMAIN_QUESTIONS.md` estão preenchidos com o conteúdo-exemplo do template e não são mantidos neste projeto | ADR-04. Arquivos preservados mas fora de uso — não ler no boot, não atualizar |
| BL-16 | `docs/files/CLAUDE.md` (vindo do Claude Web) coexiste com `.claude/CLAUDE.md` e diverge dele | `.claude/CLAUDE.md` é o canônico. O de `docs/files/` é material de origem |
| BL-17 | Sem tabela de auditoria — apenas `places.updated_by` + `updated_at` | Proporcional a 2 curadores. Reabrir se a curadoria crescer |
| BL-21 | `npm audit` acusa 2 vulnerabilidades high em `react-router` (GHSA-qwww-vcr4-c8h2, CSRF bypass no **modo RSC**) | **Não se aplica**: SPA sem React Server Components. O "fix" seria downgrade major para 7.11.0. Revisar quando o advisory for atualizado |
| BL-22 | Sem Vitest configurado | Entra quando houver lógica que justifique teste — provavelmente na F-04 (semântica AND/OR do filtro) |
| BL-23 | Sem tema claro/escuro. O `sonner.tsx` do shadcn vinha atrelado a `next-themes` (pacote do Next.js); reescrito para seguir a preferência do SO | Os Codes assumem o controle do tema em runtime na F-05. `next-themes` segue instalado como dependência órfã — remover se nada passar a usá-lo |
| BL-25 | Bundle único de 543 kB (157 kB gzip) — o Vite avisa acima de 500 kB. Sem code-splitting | Aceitável para 2 usuários e um guia não-listado. Revisar se o MapLibre pesar no carregamento inicial da F-03 |

---

## 4. Fora do MVP

Cortado com motivo. Não repropor sem fato novo.

| Item | Motivo do corte |
|---|---|
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
| DP-08 | Os 28 conflitos tier+não-visitado, os 15 sem classificação e os 4 fora do cruzamento tier×tipo | Michael, na fila de revisão do admin (F-02) |

---

## 6. UX e polimento

| # | Item | Quando |
|---|---|---|
| BL-18 | Copy autoral por combinação impossível de filtro — o momento exato em que o visitante iria embora, e o melhor lugar do produto para ter graça | F-04 |
| BL-19 | Acessibilidade: filtros navegáveis por teclado, contraste suficiente em todos os temas de Code, informação do mapa disponível na lista para leitor de tela | F-04 e F-05 |
| BL-20 | Semear as próprias respostas de field report para nada nascer em zero | F-06 |
