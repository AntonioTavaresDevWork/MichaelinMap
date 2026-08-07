# Michaelin Map — Bíblia do Projeto

**Versão:** 2.0.1 | **Data:** 2026-08-06 | **Autor:** Edu Mello
**Status do projeto:** 🟡 Fundação — F-00 concluída e verificada, F-01 a iniciar

> Fonte da verdade do Michaelin Map. O CLI lê este arquivo no boot de toda sessão.
> Deriva do PRD v1.0 produzido no Claude Web (`docs/files/2026-08-05-michaelin-map-prd.md`),
> com o escopo reduzido e as correções técnicas acordadas na Sessão 02.
>
> **Idioma:** este documento e toda a documentação interna estão em PT-BR.
> **O produto — UI, conteúdo, tags, mensagens — é integralmente em inglês.**

## Changelog

| Versão | Data | O que mudou |
|---|---|---|
| 2.0.1 | 2026-08-06 | Correção factual: caminho da pasta local em §3 (S03). Sem mudança de escopo, schema ou regra |
| 2.0 | 2026-08-06 | Bíblia preenchida a partir do PRD. Escopo do MVP fechado (7 features). Cortes: Google Places API, My Maps sync, Trip Builder, novelty interactions exceto Roulette, SEO/indexação. Schema corrigido (8 tabelas). Modelo de autorização definido (curator allowlist). |
| 1.0 | — | Template Wise* vazio |

---

## 1. Visão geral

**O que é:** um guia de lugares — restaurantes, bares, food trucks, lojas, hotéis, parques e atrações — curado por uma única pessoa. Cada entrada carrega um selo de qualidade explícito e um conjunto de tags que descreve não só o que o lugar *é*, mas para que ele *serve*.

**Contexto:** projeto pessoal, sem fins comerciais. O Michael é um amigo do Edu que frequenta muitos lugares e é constantemente procurado por conhecidos pedindo sugestão. O Michaelin Map é o ambiente onde ele compartilha essas experiências com o círculo próximo.

**Problema que resolve:** o Michael acumulou 511 lugares salvos em 19 guias do Apple Maps. Compartilhar isso é quase inútil — um mapa de pins transmite coordenadas e nada mais. O valor não está nos pins, está no julgamento: qual lugar vale a viagem, qual é famoso e decepcionante, qual prato único justifica um restaurante mediano. Nada disso sobrevive ao compartilhamento de um link.

**Foco do MVP:** tornar o julgamento transmissível. Um visitante abre o link, escolhe uma cidade, filtra pelo que precisa e chega a uma decisão.

**O que NÃO é:** não é SaaS, não é multi-tenant, não será monetizado, não terá clientes. Não é Yelp — não há avaliação de terceiros, nota média, comentários ou conta de visitante.

**Visão de longo prazo:** nenhuma. O projeto termina quando o Michael estiver usando e os amigos dele também.

### 1.1 O contexto de demonstração

Uma condição de sucesso declarada no PRD: mostrar o guia para uma pessoa específica deve fazer essa pessoa se sentir mais próxima do Michael. Isso reposiciona o produto — ele é um **artefato de personalidade** cujo conteúdo é julgamento e voz, com a utilidade servindo de veículo. Não é um utilitário que por acaso tem graça.

Consequência para priorização: os **Codes**, o campo **story** e a voz escrita do curador importam mais do que sofisticação incremental de filtro.

---

## 2. Stack

```
Frontend:     React + Vite + TypeScript (SPA, sem SSR)
UI:           Tailwind CSS + shadcn/ui
Mapa:         MapLibre GL  ← ver ADR-05
Forms:        useState controlado, validação inline no onSubmit (sem react-hook-form/zod)
Notificações: sonner — <Toaster richColors position="top-right" /> no App.tsx
State:        React Query (server state) · Zustand se necessário para UI state
Routing:      React Router DOM
Ícones:       lucide-react
Backend/DB:   Supabase (PostgreSQL 17 + Auth)
Server-side:  Supabase Edge Functions (Deno) — apenas se necessário
Geocoding:    Nominatim / OpenStreetMap (grátis, sem chave)  ← ver ADR-06
Deploy:       Vercel
```

**Fora da stack, por decisão:** Google Places API (ADR-06), TanStack Table (lista simples resolve), SSR/pré-render (ADR-07).

---

## 3. Repositório e infraestrutura

```
GitHub:        AdminFeedpro/MichaelinMap (privado)
Pasta local:   C:\Users\tomme\OneDrive\Documents\Projects\Michaelin Map
Supabase ID:   woapimgpmlgqqvauckdy
Supabase URL:  https://woapimgpmlgqqvauckdy.supabase.co
Deploy:        Vercel — a configurar após a F-03
Indexação:     noindex (não-listado) — ver ADR-07
```

---

## 4. Usuários

| Papel | Quem | Acesso |
|---|---|---|
| **Visitante** | Amigos e conhecidos do Michael | Somente leitura, sem conta, sem login. Recebe o link (e frequentemente um Code) diretamente do Michael |
| **Curador** | Michael (dono do julgamento) e Edu (apoio na curadoria e no dev) | Login no admin. Duas contas, allowlist explícita. Não há signup |

Não existe terceiro papel. Sem contribuidores, sem moderadores, sem submissões públicas — com a exceção estrita e não-avaliativa dos field reports (§10).

---

## 5. Modelo de domínio

```
tiers ──< places >── place_tags >── tags
                │
                └──< field_reports >── questions

curators (allowlist de escrita)
codes (transformações de interface, independentes de places, com destaques opcionais)
```

- `places` é a entidade central. Tudo orbita nela.
- `tiers` é vocabulário editável, não constante de código (RN-12).
- `codes` referencia places apenas por um array de destaques — sem FK rígida.

---

## 6. O modelo de julgamento

O coração do produto. Não foi desenhado — foi **engenharia reversa dos 19 guias do Michael**, que já codificavam um sistema consistente.

### 6.1 A evidência

Entre 511 lugares, os três guias de restaurante — Designation (43), Experience Spots (36), Fair Restaurants (156) — têm sobreposição **exatamente zero**. Exclusividade mútua perfeita em 235 lugares não é acidente: é uma escala.

Michael's Top Faves (22) cruza os três tiers (8/9/2) e tem sobreposição zero com a Try List. Logo, não é um quarto tier — é uma honraria aplicada *por cima* de um tier, nunca concedida a um lugar não visitado.

Cool Bars (31) e Fair Bars (46) compartilham exatamente um lugar: uma segunda escala, paralela, de dois níveis, para bares.

### 6.2 O modelo

| Camada | Campo | Valores | Regra |
|---|---|---|---|
| **Tier** | `places.tier` | Restaurantes: `destination`, `experience`, `fair` · Bares: `cool`, `fair` | No máximo um. Null para tipos não avaliados e não visitados |
| **Estrela** | `places.starred` | boolean | Cruza os tiers. 22 de 511 (4%). A honraria escassa do topo |
| **Status de visita** | `places.visited` | boolean | `false` = Try List. Não pode ter tier nem estrela |

`destination` e `experience` **não são 1º e 2º lugar** — são dois topos paralelos acima de `fair` (DP-01 resolvida: "não faz diferença"). A interface os exibe em ordem fixa, mas a copy nunca afirma superioridade de um sobre o outro.

Ambas as restrições são garantidas por constraint de banco, não por lógica de aplicação. A disciplina do curador vira garantia do schema.

### 6.3 Escassez

`destination` e `starred` precisam permanecer escassos, ou a escala não significa nada. O admin exibe a distribuição ao vivo para que a inflação seja visível. Meta: estrela abaixo de 5% dos lugares publicados.

### 6.4 Veredito negativo

A taxonomia mantém **Hype trap** para lugares famosos, lotados e decepcionantes. Veredito negativo é o que torna o positivo crível. Por decisão do curador, é **admin-only** — visível na curadoria, invisível ao público (RN-14).

---

## 7. Tipos de lugar

O guia não é só restaurante. Cerca de noventa entradas não-gastronômicas convivem com as demais.

| Tipo | `place_type` | n | Tem tier |
|---|---|---|---|
| Restaurant | `restaurant` | 273 | Sim — 3 tiers |
| Bar | `bar` | 91 | Sim — 2 tiers |
| Outdoors & attraction | `outdoors` | 65 | Não |
| Food truck | `food_truck` | 23 | Não |
| Dessert | `dessert` | 16 | Não |
| Grocery | `grocery` | 14 | Não |
| Hotel | `hotel` | 6 | Não |
| Winery | `winery` | 5 | Não |
| Shop | `shop` | 3 | Não |
| Unclassified | `unclassified` | 15 | — |

**O tipo de lugar é o segundo portão**, junto com a cidade. "Onde eu como" e "o que eu faço" são sessões diferentes; misturar um parque estadual no resultado de um filtro de restaurante é ruído. Tipos sem tier ainda carregam a estrela, que passa a ser o sinal de qualidade deles.

---

## 8. Geografia

Três níveis, todos derivados de coordenada com possibilidade de override manual.

| Nível | Campo | Cardinalidade | Papel |
|---|---|---|---|
| País | `country` | Exatamente 1 | Agrupamento apenas |
| Cidade / metrô | `city` | Exatamente 1 | **O portão primário** |
| Bairro / área | `area` | 0 ou 1 | Null abaixo do limiar de densidade |

**Cidade é portão, não filtro.** Ninguém navega todos os lugares do planeta. O visitante escolhe a cidade primeiro e todas as outras facetas operam dentro dela.

**Áreas só existem onde a densidade justifica** — cerca de 15 entradas. Austin ganha bairros; Oxfordshire, com 3 lugares, não exibe controle de área nenhum. A hierarquia degrada em silêncio em vez de renderizar controle vazio.

**Cidades atuais:** Austin 466, St. Augustine 15, Jacksonville 8, Los Angeles 4, Oxfordshire 3, Dallas–Fort Worth 3, Fernando de Noronha 2, Waco 2, mais oito singletons (London, Belton, Essex Junction, Mountain Home, Rochester, San Diego, Schertz, Seattle).

**Singletons aparecem como pares** (DP-02 resolvida), com a contagem visível. Nenhuma cidade é privilegiada na interface.

---

## 9. Schema do banco

Oito tabelas. O SQL detalhado vive em `supabase/migrations/`; esta seção é a referência rápida e **documenta as correções feitas sobre o schema original** do PRD.

### 9.1 `places`

| Coluna | Tipo | Obs |
|---|---|---|
| `id` | uuid PK | default `gen_random_uuid()` |
| `name` | text NOT NULL | |
| `slug` | text UNIQUE | gerado; desambiguado com sufixo quando há homônimo |
| `place_type` | text NOT NULL | default `unclassified`; CHECK na lista da §7 |
| `tier` | text | **FK → `tiers(slug)`** |
| `starred` | boolean NOT NULL | default false |
| `visited` | boolean NOT NULL | default true; `false` = Try List |
| `status` | text NOT NULL | default `unreviewed`; CHECK `unreviewed \| published \| closed \| hidden` |
| `country` / `city` / `area` | text | §8 |
| `lat` / `lng` | numeric(10,7) | |
| `address` | text | |
| `website` | text | manual, opcional |
| `price_band` | text | `$` a `$$$$` — **julgamento do curador**, não derivado |
| `the_dish` | text | ⚠️ camada de julgamento |
| `curator_note` | text | ⚠️ camada de julgamento |
| `story` | text | ⚠️ camada de julgamento — "por que isso importa pra mim" |
| `last_visited` | date | ⚠️ camada de julgamento |
| `apple_id` | text **UNIQUE** | correção: era sem UNIQUE e o import quebrava |
| `source_guides` | text[] | nomes dos guias Apple originais, auditoria |
| `source` | text | `apple_csv \| manual` |
| `created_at` / `updated_at` | timestamptz | `updated_at` via trigger |
| `updated_by` | uuid | FK → `auth.users`; quem editou por último |

**Constraints:**
- `tier_requires_visit` — lugar não visitado não pode ter tier
- `star_requires_visit` — lugar não visitado não pode ter estrela
- `published_needs_city` — lugar publicado precisa de cidade

**Removidos do schema original** (sem fonte de dados após o corte do Google Places): `google_place_id`, `phone`, `hours`, `geo_source`, `price_band_source`, `mymaps_feature_id`, `first_synced_at`, `last_seen_in_sync`.

### 9.2 `tiers` — nova

Tier vira dado editável para atender DP-03 ("permitir renomear os tiers").

| Coluna | Tipo | Obs |
|---|---|---|
| `slug` | text PK | estável; o código só depende disto |
| `label` | text NOT NULL | rótulo público, editável no admin |
| `applies_to` | text[] NOT NULL | tipos de lugar que o admin sugere para este tier |
| `sort_order` | int NOT NULL | ordem de exibição |
| `active` | boolean NOT NULL | |

Seed: `destination`, `experience`, `fair` (restaurant) · `cool`, `fair` (bar).

`applies_to` **orienta o admin, não restringe o banco** — o curador é a autoridade. Isso acomoda os 4 lugares fora do padrão nos dados atuais (§12).

### 9.3 `tags` / `place_tags`

Vocabulário facetado e controlado. Criação de tag por texto livre é desabilitada por design.

`tags`: `id`, `facet` (`cuisine | format | occasion | vibe | logistics | dietary | character`), `label`, `slug`, `is_derived`, **`admin_only`** (novo — RN-14), `sort_order`, `active`. UNIQUE `(facet, slug)`.

`place_tags`: `place_id`, `tag_id` (PK composta), **`source`** (novo — `curator | suggested`), `created_at`.

`source = 'suggested'` marca as tags de `cuisine` e `price_band` que o CLI pré-classifica no import (ADR-06). O curador vê o que veio da máquina e o que veio dele.

Seed: 93 tags (37 cuisine, 14 occasion, 11 vibe, 11 logistics, 9 character, 7 format, 4 dietary) + `Hype trap` em `character` com `admin_only = true`.

### 9.4 `curators`

`user_id` uuid PK → `auth.users` · `name` text · `created_at`.

Duas linhas: Michael e Edu. Signup desabilitado no projeto Supabase.

### 9.5 `codes`

Sem alteração estrutural: `id`, `code` (UNIQUE, maiúsculo), `label`, `message`, `theme` jsonb, `pin_style` jsonb, `preset_filter` jsonb, `highlighted_places` uuid[], `starts_at`, `ends_at`, `active`, `created_at`.

**Correção de RLS:** a tabela perde o SELECT público. Ver §11 e RN-20.

### 9.6 `questions` / `field_reports`

`questions`: `id`, `prompt`, `input_type` (`number | color | slider | single_choice | yes_no | compound | text_short`), `unit_label`, `options` jsonb, `slider_labels` jsonb, `judgment_prompt`, `requires_review`, `weight`, `active`. Seed: 38 perguntas.

`field_reports`: `id`, `place_id`, `question_id`, `answer` jsonb, `judgment`, `status` (`published | pending | rejected`), `session_hash`, `submitted_at`.

**Correção de RLS:** INSERT direto pelo público é revogado; entra só pela RPC `rpc_submit_field_report` (RN-21).

View `field_report_aggregates` — agrega respostas publicadas, oculta abaixo de n=5. **Correção:** criada com `security_invoker = on`, senão a view contorna o RLS.

### 9.7 Índices

```sql
places(city) where status = 'published'
places(place_type) · places(tier) · places(status) · places(lat, lng)
field_reports(place_id) where status = 'published'
field_reports(session_hash, submitted_at)   -- rate limit
place_tags(tag_id)                          -- filtro reverso
```

---

## 10. Field reports

Visitantes que estiveram em um lugar respondem 2 ou 3 perguntas sorteadas que **não carregam nenhuma informação sobre qualidade** — temperatura da comida em Fahrenheit, cor da cadeira, distância até o corpo d'água mais próximo, pé-direito medido em mãos.

**O absurdo é estrutural, não decorativo.** Comentário convencional achataria o tier do curador em "mais uma opinião". Perguntas em um eixo ortogonal não competem com o julgamento dele. Participação sem diluição.

- Entradas são **restritas** — número, cor, slider, escolha, sim/não, composta. Isso também elimina a carga de moderação.
- **4 das 38 perguntas** aceitam texto livre porque o espaço de resposta é ilimitado. Limitadas a 40 caracteres, entram como `pending` e só vão ao ar com aprovação do curador.
- **O agregado é a feature**, renderizado com seriedade científica impassível e oculto abaixo de 5 respostas. O curador semeia as próprias respostas para nada nascer em zero.
- Uma pergunta — *the dish you would order again* — é o único ponto em que a resposta do visitante informa o julgamento do curador, e aparece destacada no admin.

---

## 11. Modelo de autorização

| Campo | Valor |
|---|---|
| **Modelo** | **Curator allowlist** — nem tenant-scoped nem RBAC. Ver ADR-01 |
| **Função que resolve o caller** | `is_curator()` — `exists (select 1 from curators where user_id = auth.uid())`, STABLE SECURITY DEFINER |
| **Auditoria** | Sem tabela de audit. `places.updated_by` + `updated_at` cobrem a necessidade real |
| **Acesso anônimo** | Leitura de conteúdo publicado + escrita de field report **exclusivamente via RPC** |

### RLS por tabela

| Tabela | SELECT público | Escrita |
|---|---|---|
| `places` | `status = 'published'` | curador |
| `tiers` | `active = true` | curador |
| `tags` | `active AND NOT admin_only` | curador |
| `place_tags` | só de place publicado e tag não-admin (via EXISTS) | curador |
| `codes` | **nenhum** — só via `rpc_redeem_code()` | curador |
| `questions` | `active = true` | curador |
| `field_reports` | `status = 'published'` | INSERT só via `rpc_submit_field_report()`; resto curador |
| `curators` | nenhum | curador |

### RPCs expostas ao client

| RPC | O que faz |
|---|---|
| `rpc_redeem_code(p_code text)` | Recebe um código, devolve o efeito se existir, estiver ativo e dentro da janela de datas. Retorna vazio caso contrário. Impede a enumeração de códigos |
| `rpc_submit_field_report(...)` | Valida que o lugar está publicado e a pergunta ativa; **deriva o status a partir de `questions.requires_review`** (o visitante não escolhe); trunca texto em 40 caracteres; aplica rate limit por `session_hash` |

---

## 12. Estado atual dos dados

511 lugares únicos, extraídos de 19 guias do Apple Maps. Números validados linha a linha contra o CSV master.

Tiers: destination 43, experience 36, fair 198, cool 30. Estrela 22. Não visitados 42. Apple IDs duplicados: zero. Coordenadas faltando: zero. Nomes homônimos: 9 (desambiguados por slug).

**Três questões que exigem decisão do curador, não conserto silencioso do dev:**

1. **28 conflitos** — lugares com tier *e* Try List, ou seja, avaliados sem terem sido visitados. O import derruba o tier e sinaliza; cada um precisa que o Michael confirme que esteve lá ou concorde que o tier era aspiracional.
2. **15 sem classificação** — treze são exclusivos da Try List, salvos sem categoria; dois são de Fernando de Noronha, um deles um aeroporto e provavelmente não uma recomendação.
3. **4 fora do cruzamento tier × tipo** — Grocery com `fair` (2) e `destination` (1), Bar com `experience` (1), Outdoors com `fair` (1). Não são bloqueados pelo banco (§9.2), mas o admin sinaliza.

**As 93 tags nascem vazias.** A coluna `Tags` do CSV traz apenas 5 valores distintos (Breakfast & brunch 54, Rooftop 14, Night out 3, Vacation 2, Food truck 1), derivados dos nomes dos guias. Taggear 511 lugares é o gargalo real do projeto — ver §13.1.

---

## 13. Escopo do MVP

Sete features. Ordem de dependência estrita: cada uma só começa com a anterior em build limpo.

| # | Feature | Entrega | Sessões |
|---|---|---|---|
| **F-00** | Fundação | Vite + TS + Tailwind + shadcn/ui, client Supabase, tipos, roteamento, layout | ~0,5 |
| **F-01** | Schema + dados | Migration do schema corrigido, seed (93 tags, 38 perguntas, 5 tiers), import dos 511 com `cuisine` e `price_band` pré-sugeridos | ~1 |
| **F-02** | Admin | Login (2 curadores), lista com filtros, editor de lugar, atribuição de tags, quick-add mobile, fila de revisão, distribuição de tiers, lista de desatualizados | ~2 |
| **F-03** | Público | Portão de cidade, mapa MapLibre, lista sincronizada, detalhe do lugar | ~2 |
| **F-04** | Filtros | Painel facetado, OR dentro / AND entre facetas, contagem ao vivo, opção zerada desabilitada, estado na URL, empty state autoral | ~1 |
| **F-05** | Codes + Roulette | Codes completo (tema, estilo de mapa, pins, filtro pré-aplicado, destaques, type-anywhere no desktop, long-press no mobile) + Roulette | ~2 |
| **F-06** | Field reports | 7 tipos de input, sorteio de 2-3 perguntas, agregado com n≥5, texto livre em fila, rate limit | ~1,5 |

Total estimado: **~10 sessões de CLI.**

### 13.1 A curadoria roda em paralelo

A partir da F-02, o Michael começa a taggear. Isso não é fase de dev — é trabalho humano contínuo, e é o caminho crítico do projeto.

**Estratégia de lançamento:** não esperar os 511. Os 22 com estrela mais os 43 `destination` já formam um guia excelente — são justamente os que os amigos perguntam. Publicar esses ~65 primeiro; o resto entra conforme for taggeado.

### 13.2 Fora do MVP

Registrados em `docs/BACKLOG.md`, com o motivo de cada corte: Google Places API e hidratação, My Maps KML sync, Trip Builder, Settle It, I'm Hungry Now, Bad Idea, shortlist local, SEO e indexação, área por polígono geográfico.

---

## 14. Regras de negócio

### 14.1 Julgamento

- **RN-01** — Um lugar não visitado (`visited = false`) não pode ter tier. Garantido por constraint.
- **RN-02** — Um lugar não visitado não pode ter estrela. Garantido por constraint.
- **RN-03** — A estrela cruza os tiers; não é um tier a mais.
- **RN-04** — `destination` e `experience` são topos paralelos, não posições 1 e 2. Nenhum texto do produto afirma superioridade entre eles.
- **RN-05** — Tipos sem tier (outdoors, food truck, dessert, grocery, hotel, winery, shop) usam a estrela como único sinal de qualidade.
- **RN-06** — O admin exibe a distribuição de tiers e estrelas ao vivo. Meta: estrela abaixo de 5% dos publicados.

### 14.2 Publicação e descoberta

- **RN-07** — Todo lugar importado ou criado nasce `unreviewed`. Só `published` é visível ao público.
- **RN-08** — Validação se aplica na promoção a `published`, nunca na inserção. Importar exigindo validação completa é impossível.
- **RN-09** — Um lugar publicado precisa de cidade. Garantido por constraint.
- **RN-10** — Todo lugar publicado precisa ser alcançável por ao menos uma faceta literal — cuisine, city, place type ou price. Lugar acessível apenas por tag de `character` é bug.
- **RN-11** — Interações de novidade (Roulette) são atalhos aditivos. Nada é alcançável exclusivamente por elas.

### 14.3 Vocabulário

- **RN-12** — Tiers são dados, não constantes. O código depende de `tiers.slug`; o rótulo público (`label`) é editável no admin sem deploy.
- **RN-13** — Tags têm vocabulário controlado. Criação por texto livre é desabilitada.
- **RN-14** — Tag com `admin_only = true` nunca aparece ao público, em nenhuma superfície: nem no filtro, nem no detalhe, nem no resultado de busca. `Hype trap` é o caso atual.
- **RN-15** — Tag com `source = 'suggested'` é sugestão da máquina pendente de revisão. O admin as distingue visualmente das atribuídas pelo curador.

### 14.4 Filtro

- **RN-16** — OR dentro de uma faceta, AND entre facetas. Tacos + BBQ mostra os dois; somar East Austin restringe a tacos e BBQ em East Austin.
- **RN-17** — Toda opção de filtro exibe contagem de resultado ao vivo. Opção que retornaria zero fica **desabilitada, não escondida**.
- **RN-18** — O filtro de área só aparece em cidades com ~15 lugares ou mais.
- **RN-19** — O estado do filtro serializa na URL. Qualquer visão é compartilhável.

### 14.5 Codes

- **RN-20** — Códigos nunca são listáveis. O público não tem SELECT em `codes`; a validação passa pela RPC, que responde por código específico.
- **RN-21** — Codes nunca removem conteúdo. Eles reestilizam, reordenam, destacam e adicionam mensagem. Nunca escondem um lugar de quem não tem o código.

### 14.6 Field reports

- **RN-22** — Nenhuma pergunta pode indagar se o lugar era bom, nem permitir que uma nota seja derivada. Esse eixo pertence só ao curador.
- **RN-23** — O status da resposta é derivado de `questions.requires_review` pelo servidor. O visitante não escolhe se sua resposta vai ao ar.
- **RN-24** — Texto livre é limitado a 40 caracteres, entra como `pending` e só publica com aprovação. Nenhum outro input de texto ilimitado existe no produto.
- **RN-25** — Agregados ficam ocultos abaixo de 5 respostas.

---

## 15. Decisões de arquitetura (ADR)

Registro das exceções deliberadas ao framework Wise* e das escolhas que não devem ser reabertas sem motivo novo.

**ADR-01 — Sem multi-tenant.** O framework exige `company_id` e RLS por empresa em toda tabela. Aqui há um único guia, dois curadores e nenhum cliente. Autorização é allowlist de curador. *Motivo: forçar tenancy seria cerimônia sem função.*

**ADR-02 — Produto em inglês, formato en-US.** O framework exige UI em PT-BR e formato brasileiro. O guia é de Austin, os usuários são anglófonos, e as 93 tags e 38 perguntas já estão escritas em inglês. Documentação interna e conversas seguem em PT-BR. *Motivo: o produto não é brasileiro.*

**ADR-03 — `status` no lugar de `deleted_at`.** O framework exige soft delete por `deleted_at`. Aqui `status` (`unreviewed | published | closed | hidden`) é mais expressivo e já cobre o caso. *Motivo: um lugar que fechou é diferente de um lugar escondido, e nenhum dos dois é "deletado".*

**ADR-04 — Sem GANTT, sem DOMAIN_QUESTIONS, sem spec por feature, sem pipeline de agentes.** O framework Wise* pressupõe SaaS com cliente e prestação de contas. Este projeto é pessoal, o PRD já cumpre o papel de spec, e o custo do processo superaria o do código. Mantidos: migrations versionadas, `STATUS.md`, `BACKLOG.md` e esta Bíblia. *Motivo: proporcionalidade.*

**ADR-05 — MapLibre GL, não Google Maps.** Escolhido originalmente porque troca estilo de mapa em runtime, do que os Codes dependem. Mantido também por não cobrar por render. *Não substituir por embed do Google.*

**ADR-06 — Sem Google Places API.** O original hidratava os 511 lugares contra o Places para obter horário, telefone e faixa de preço. Cortado: horário resolve com o botão de direções, e **faixa de preço é julgamento do Michael, não do Google**. A pré-classificação de `cuisine` e `price_band` é feita pelo CLI na geração do seed, marcada como `suggested`. Geocoding do quick-add usa Nominatim/OSM. *Motivo: elimina uma API paga, uma chave, um script de hidratação e um NFR inteiro, sem perda relevante.*

**ADR-07 — Não-listado (`noindex`).** O guia é público e sem senha, mas não é indexado por buscador. *Motivo: os field reports dependem de quem responde ter estado no lugar; os Codes pressupõem distribuição pessoal; e a decisão é reversível em minutos numa direção e lenta e incompleta na outra.* Reavaliar só se o Michael pedir. Consequência: nenhum trabalho de SEO no MVP.

**ADR-08 — Sem My Maps sync.** O original sincronizava um mapa do Google via KML. O quick-add mobile já é caminho completo de captura — o próprio PRD admite isso. *Motivo: era a feature de maior complexidade e menor valor marginal.* Some junto a tabela `sync_runs` e o gate de teste de sabotagem.

---

## 16. Decisões pendentes

| # | Decisão | Status | Bloqueia |
|---|---|---|---|
| DP-01 | `destination` acima de `experience`? | ✅ Resolvida — não faz diferença, topos paralelos (RN-04) | — |
| DP-02 | Cidades singleton: pares, agrupadas ou suprimidas? | ✅ Resolvida — exibir como pares | — |
| DP-03 | Nomes públicos dos tiers | ✅ Resolvida — editáveis no admin (RN-12) | — |
| DP-04 | `Hype trap` público ou admin? | ✅ Resolvida — admin-only (RN-14) | — |
| DP-05 | Link indexável? | ✅ Resolvida — não-listado (ADR-07) | — |
| DP-06 | O Michael quer aparecer — rosto, perfil de gosto, página "about"? | 🔴 Aberta | Copy e tom. Não bloqueia build |
| DP-07 | Notas de voz por lugar | 🔴 Aberta | Fora do MVP; candidata a fase futura |
| DP-08 | Os 28 conflitos, 15 sem classificação e 4 fora do cruzamento | 🔴 Aberta — depende do Michael | Publicação desses lugares específicos |

---

## 17. Como o CLI usa este documento

1. **Boot da sessão:** ler `.claude/CLAUDE.md` → esta Bíblia → `docs/STATUS.md` → `docs/BACKLOG.md`.
2. **Antes de codar:** confirmar com o Edu qual feature está em foco. Nunca começar sem confirmação.
3. **Dúvida de comportamento:** §14 (regras de negócio).
4. **Dúvida de schema:** §9 — e confirmar contra o banco vivo via MCP antes de escrever SQL.
5. **Dúvida sobre por que algo não está no projeto:** §15 (ADRs) antes de propor de novo.
6. **Ao fechar feature:** atualizar `STATUS.md`; pendência nova vai para `BACKLOG.md`.
7. **O PRD original** (`docs/files/`) é material de origem, não fonte da verdade. Onde divergir desta Bíblia, esta Bíblia vence.

> **A camada de julgamento — `tier`, `starred`, `the_dish`, `curator_note`, `story`, `last_visited` e as atribuições de tag — é o único dado insubstituível do sistema.** Qualquer rotina automática que escreva nesses campos precisa de autorização explícita.
