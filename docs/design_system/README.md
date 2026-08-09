# Feedback Comunicação — Design System

> Agência solopreneur de **SaaS, Power BI e Automação**. AI-First.
> Fundada e operada por **Eduardo Mello** — `feedback.com.vc`.

Este design system orienta a criação de interfaces, slides, mocks e materiais de marca para a Feedback Comunicação e para os produtos construídos pela agência.

---

## Sources / Fontes

| Fonte | URL / Caminho | Status |
|---|---|---|
| Site institucional (copy, tom, serviços) | https://feedback.com.vc | Fetched via web (texto) |
| Referência visual principal (dashboard dark + accent lime) | https://www.wisepei.com.br | Fetched (texto + 2 imagens) |
| Cor de destaque (lime oficial) | `#ACDE40` | Decisão do Edu — adotada como lime oficial da marca |
| Logos oficiais Feedback (2019) | `assets/feedback-logo-*.png`, `assets/feedback-mark-*.png` | ✓ anexadas pelo usuário |
| Logo WisePEI (referência de construção de logo) | `assets/reference/wisepei-logo.png` | ✓ baixada |
| Hero dashboard WisePEI (referência de UI) | `assets/reference/img-hero-2.png` | ✓ baixada |
| Ilustrações originais do feedback.com.vc (illus-satu, ilus-dua, asset1/3, tick) | `feedback.com.vc/wp-content/uploads/2022/12/*.png` | ✗ CORS-blocked — **preciso que o usuário anexe** |

> **Caveat:** o site público do `feedback.com.vc` é um holding page ("deixamos para atualizar nosso site em outro momento"). Toda a direção visual deste design system é ancorada no produto de referência **WisePEI** (construído pela própria Feedback), combinado com a paleta `#ACDE40` solicitada e o tom de voz do site institucional.

---

## Company / Product Context

**Feedback Comunicação** é uma **agência solopreneur AI-First** que entrega três linhas de trabalho:

1. **SaaS sob medida** — produtos web verticalizados (ex.: WisePEI para educação inclusiva)
2. **Power BI** — dashboards analíticos, modelagem de dados, relatórios executivos
3. **Automação** — workflows, integrações, agentes de IA para operações de negócio

Posicionamento: **"Construa seu projeto do zero ao topo."** — parceira técnica que toma a ideia crua e leva até produto rodando.

Public-facing products mapped so far:
- **WisePEI** — SaaS para gestão de PEIs (Planos Educacionais Individualizados) em escolas, com workflow de aprovação multi-stakeholder, objetivos SMART gerados por IA, registro de progresso, dashboard de coordenação. `wisepei.com.br`

---

## Index

- `README.md` — este arquivo (contexto, content, visuals, iconografia, índice)
- `colors_and_type.css` — variáveis CSS base + semânticas (cores, type, radii, shadows, spacing)
- `SKILL.md` — manifesto cross-compatível com Agent Skills
- `fonts/` — webfonts (ou nota de substituição)
- `assets/` — logos, ícones, imagens
  - `assets/reference/` — material externo usado como referência visual
  - `assets/source/` — assets originais do feedback.com.vc (quando fornecidos)
- `preview/` — HTML cards registradas no Design System tab
- `ui_kits/feedback-marketing/` — UI kit do site institucional (recriação fiel do tom atual + estética dark/lime)
- `ui_kits/wisepei-saas/` — UI kit do produto WisePEI (dashboard dark)

---

## CONTENT FUNDAMENTALS

### Idioma
**Português do Brasil.** Sempre. Não misturar anglicismos desnecessários — "dashboard", "workflow", "SaaS", "AI" são aceitos (já são vocabulário corrente); mas prefira "painel", "fluxo", "produto", "IA" quando caber no ritmo.

### Voz
**Direta, consultiva, confiante, sem floreios.** Fala de gente técnica para gente de negócio. Nunca vende no grito. É a voz de um parceiro sênior que já fez isso antes.

### Pessoa
**"Você" em segundo lugar, "nós" em primeiro.** A Feedback fala de dentro pra fora: "nós construímos", "você colhe". Evitar "eu" mesmo sendo solopreneur — o pronome institucional ancora autoridade.

### Casing
**Title case cirúrgico em headings curtos; sentence case em UI.**
- Headings de marketing: `Construa seu projeto do zero ao topo.` (primeira maiúscula, resto minúsculo — estilo editorial)
- Botões: `Agendar Demonstração`, `Fale Conosco` (title case tradicional)
- UI labels dentro de produto: `Objetivos em andamento`, `PEIs ativos` (sentence case)
- **Nunca ALL CAPS.** Nem em botões. Capsular em caps agride o tom editorial.

### Pontuação e ritmo
- Frases curtas. Parágrafos curtos. Ponto final forte.
- Perguntas retóricas no início de seções são bem-vindas: *"Quantos PEIs vão ficar na gaveta esse ano?"*, *"Você tem uma grande ideia?"*
- Listas de benefícios sempre com paralelismo (verbo no imperativo):
  *"Construa. Contribua. Conquiste."*
- Dois-pontos `:` usado para entregar a promessa após o setup — quase nunca reticências.

### Tom por superfície
| Superfície | Tom |
|---|---|
| Site institucional (Feedback) | Editorial, provocativo, confiante |
| Landing de produto (WisePEI) | Empático com a dor, quantitativo, didático |
| UI de produto | Funcional, neutro, direto |
| Slides internos | Assertivo, com bullet points e números grandes |

### Emoji
**Uso parcimonioso.** Aceitável em UI de produto para ancorar blocos críticos (`🎯 Objetivos SMART`, `📊 Registro`, `🚀 Execução` — padrão visto no WisePEI). **Não usar** em site institucional, slides formais ou e-mails. Nunca usar emoji como substituto de ícone de UI (use SVG).

### Exemplos reais
- ✅ `Transforme PEIs de Documentos em Resultados`
- ✅ `Você tem uma grande ideia?`
- ✅ `Do caos à clareza. Do papel ao progresso real.`
- ✅ `70% Redução de tempo administrativo`
- ❌ `🚀 Let's revolutionize your workflow! 🎉` — importação anglófona/emoji-spam
- ❌ `A SOLUÇÃO DEFINITIVA` — caps gritantes
- ❌ `Olá! Tudo bem? Então, a gente queria te contar que...` — enrolação

---

## VISUAL FOUNDATIONS

Sistema ancorado no produto de referência **WisePEI**: base dark com acento lime, cards generosos, tipografia sem graça gráfica desnecessária, números grandes como protagonistas.

### Paleta

**Accent único, não-negociável:** `#ACDE40` (lime oficial da marca — decisão do Edu). Usado em CTAs, highlights, séries principais de gráfico e estado ativo. O chevron `>` da marca é sempre nessa cor quando sobre ink. **Obs:** o mark 2019 (Marca FB 2019 VD) amostrava `#BACD40`; adotamos `#ACDE40` como oficial por decisão do Edu. A rampa lime (`lime-50…900`) ainda gira em torno do valor antigo — pode ser re-derivada em torno de `#ACDE40` para suavidade perfeita, se quiser.

**Background stack (dark-first) — ancorado no ink oficial `#29323B`:**
- `#0F141B` — surface-0 (body)
- `#1A222B` — surface-1 (cards)
- `#222B36` — surface-2 (inputs / cards sobre cards)
- `#29323B` — ink oficial / border de ênfase

**Foreground:**
- `#F4F6F8` — fg-primary
- `#A5AEBC` — fg-secondary
- `#6B7588` — fg-muted

**Semantic (muted, não neon):**
- Success: `#34C759` (verde distinto — não confundir com o lime da marca)
- Warning: `#F5A524`
- Danger:  `#E5484D`
- Info:    `#4C9AFF`

**Chart series (para dashboards estilo Power BI / WisePEI):** `#ACDE40`, `#4C9AFF`, `#F5A524`, `#E5484D`, `#9B8AFB`, `#26C6DA`.

**Light mode:** suportado mas secundário. Base `#FAFBFC`, fg `#0A0E14`, accent mantém `#ACDE40` (escurecer para texto: `#6B8A1F`).

### Tipografia

- **Display / Headings:** `Inter` (600/700/800). Mesma família do corpo, peso alto para hierarquia.
- **Body:** `Inter` (400/500/600). Default em toda a página — títulos e parágrafos.
- **Logo:** `Comfortaa` (400/600/700). **Exclusiva da logomarca** — nunca usar em texto corrido.
- **Mono:** system monospace (SFMono/Menlo) para números técnicos e tokens.

> A logo oficial da Feedback usa **Comfortaa** (curvas arredondadas, proporcional ao chevron da marca). Para toda composição de página — títulos e parágrafos — usamos **Inter**, família única.

Escala (base 16):
- `display`: 64 / 72px — hero
- `h1`: 48 / 56px
- `h2`: 36 / 44px
- `h3`: 24 / 32px
- `h4`: 18 / 28px
- `body-lg`: 18 / 28px
- `body`: 16 / 24px
- `body-sm`: 14 / 20px
- `caption`: 12 / 16px — SEMPRE `letter-spacing: 0.04em` e `text-transform: uppercase` quando usada como eyebrow/label; normal case para captions inline.

Tracking geral: `-0.01em` em headings grandes (display/h1/h2), `0` em body.

### Espaçamento

Escala de 4px. Tokens: `2 / 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96 / 128`. Sem valores órfãos fora dessa grade.

Seções em marketing: padding vertical `96px` desktop / `64px` mobile. Cards: padding interno `24px` ou `32px`.

### Radii

- `4` — input, tag pequena
- `8` — botão, badge
- `12` — card padrão
- `16` — card elevado / hero
- `24` — cards de feature em marketing
- `999` — pill / avatar

Valor de marca: **rounded-square em logomarca e ícones principais (radius ≈ 20% do lado)**. É o "jeito WisePEI" e deve ser replicado.

### Shadows / Elevação

Dark mode: elevação por cor de superfície (surface-0 → surface-1 → surface-2), **não** por sombra. Sombras apenas em:
- Floating menu / popover: `0 12px 32px rgba(0,0,0,0.4), 0 2px 8px rgba(0,0,0,0.3)`
- Hero mockup: `0 40px 80px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04)`

Light mode: sombras mais usuais.
- Card: `0 1px 2px rgba(10,14,20,0.06), 0 4px 12px rgba(10,14,20,0.04)`
- Hover: sobe levemente a sombra + `translateY(-2px)`.

### Borders

- Hairline padrão: `1px solid #252F3D` (dark) / `1px solid #E4E7EB` (light)
- Border de ênfase (estado ativo): `1px solid #ACDE40` + glow sutil `box-shadow: 0 0 0 3px rgba(172,222,64,0.15)`
- Nunca border > 1px exceto no divisor de seção marketing (barra sólida de 4px lime, raro)

### Backgrounds / Texturas

- Hero de marketing: base dark sólida + **noise overlay** muito sutil (2% opacity) para quebrar flatness digital
- **Gradient radial** lime muito baixo (`radial-gradient(circle at 30% 0%, rgba(172,222,64,0.08), transparent 60%)`) atrás de seções hero — assina a marca sem gritar
- **Evitar**: gradientes roxo-azul AI-genéricos, blobs coloridos, mesh gradients, glass pesado/decorativo em conteúdo (glass escopado em superfície flutuante é permitido — ver seção *Glass / Transparência*)
- Ilustrações: a Feedback atual usa ilustrações chapadas vetoriais (`illus-satu.png`, `ilus-dua-1.png`). Em produto (WisePEI), imagens são screenshots de UI em frames dark. **Mantemos os dois registros** — ilustrações em marketing institucional, screenshots em marketing de produto.

### Animação

Discreta e funcional. Nada de bounces exagerados.
- Curva padrão: `cubic-bezier(0.16, 1, 0.3, 1)` (ease-out-expo) — duração `200ms` para UI, `400ms` para entrada de seção.
- Fades e micro-translações (`translateY(8px)` max).
- Counter animation em números de impacto (`0 → 70` ao scrollar) — assinatura visual.
- **Proibido:** loops infinitos de glow, partículas, parallax agressivo.

### Estados de interação

- **Hover button primário:** brightness(1.1) + pequena subida (`translateY(-1px)`). Nunca mudar de cor.
- **Hover link:** underline aparece (`text-decoration: underline` com `text-underline-offset: 3px`).
- **Hover card:** border muda para `#3A4757` + sombra leve.
- **Active/press:** `transform: scale(0.98)` + brightness(0.92). Duração 80ms.
- **Focus-visible:** ring lime `0 0 0 2px #ACDE40, 0 0 0 4px rgba(172,222,64,0.25)`. Nunca esconder focus.
- **Disabled:** opacity 0.4, cursor not-allowed, sem hover.

### Cards

Padrão único: background `surface-1`, border `1px solid #252F3D`, radius `12`, padding `24`. Hover opcional (ver acima). **Sem** colored-left-border (evitar trope AI-slop).

### Glass / Transparência

**Princípio:** glass é **hierarquia espacial, não decoração**. Vidro só em superfície que *flutua* acima do conteúdo. Conteúdo primário (cards, tabelas, KPIs) é **sólido** — nunca frosted. E **anti-slop = anti-gratuito**: a técnica não é o inimigo, o efeito sem propósito é. Glass pesado/decorativo = slop; glass leve, escopado e legível (estilo Apple/Liquid Glass) = correto.

**Permitido — superfícies que flutuam:**
- Header fixo de marketing quando scrollado: `backdrop-filter: blur(12px)` + `background: rgba(10,14,20,0.72)`
- Modal / overlay: dim do conteúdo (`background: rgba(0,0,0,0.6)`) + `backdrop-filter: blur(4px)`; o painel do modal pode usar glass leve
- **Command palette (⌘K), toolbar flutuante, dropdown, popover, menu de contexto** — tudo que paira sobre o conteúdo

**Proibido:** glass em conteúdo primário — cards de grid, tabelas, KPIs, stat cards. Esses são superfície sólida em camadas (ver Cards). Glass aqui fica AI-genérico.

**Execução (o que separa glass de slop):**
- Blur sutil/médio (`12–24px`), nunca pesado; `saturate(1.2–1.3)` opcional pra dar vida
- Fundo translúcido escuro (`rgba(26,33,44,0.66–0.72)`), não branco leitoso
- **Borda fina** `1px solid rgba(255,255,255,0.10–0.12)` + **brilho no topo** `inset 0 1px 0 rgba(255,255,255,0.12)` — a "borda do vidro"
- Sombra de elevação pra firmar que flutua: `0 24px 60px -20px rgba(0,0,0,0.7)`
- **Contraste de texto preservado** — sempre legível; nunca corpo de texto direto sobre blur agitado
- Performance: poucas camadas de `backdrop-filter`

### Imagery vibe

Cool-tone, alto contraste, UI-forward. Screenshots de produto em frames de notebook/desktop escuros. Ilustrações vetoriais chapadas (estilo flat 2D, paleta reduzida) para pontos emocionais no site institucional.

### Layout rules

- Grid de 12 colunas, gutter 24px, max-width 1200px para marketing
- Em app: sidebar fixa 240px + content flex, padding 32px
- Header sempre fixo no topo (64-72px) com blur quando scrollado
- CTAs principais no canto superior direito do header + no hero + no fim da página

---

## ICONOGRAPHY

**Biblioteca principal:** **Lucide** (via CDN). Stroke 1.5px, outline. Leve, consistente, é o que o WisePEI usa e combina com a estética dark+lime.

> Substituição flagrada: não encontrei sprite/icon-font próprio da Feedback no holding page. Lucide é a substituição padrão até material oficial aparecer. **Se o usuário preferir Phosphor ou Heroicons**, é troca de 1 linha no CDN — me avisar.

### Regras de uso

- Tamanho padrão `20px` em UI, `24px` em destaque, `16px` em linha com texto pequeno.
- Cor herda `currentColor`. Nunca pintar ícone em accent lime — reserve lime para elementos primários.
- Stroke uniforme 1.5 em todos os ícones da mesma surface (não misturar filled + outline).
- Em cards de estatística (`70%`, `92%`), **não usar ícone** — o número já é o protagonista.

### Emoji como ícone

Evitar em UI. Caso excepcional (como os `🎯 📊 🚀` do WisePEI), usar apenas em **blocos de heading de seção** dentro de produto, nunca em botões, labels, listas.

### Unicode

OK para setas (`→`, `↗`, `·`), separadores (`•`), e flags tipográficas. Não usar para estados.

### Logos / marca

- `assets/feedback-logo.svg` — logomarca nova (proposta) baseada no registro "rounded-square + glyph branco" do WisePEI, adaptada para a Feedback
- `assets/feedback-mark.svg` — apenas o símbolo (sem palavra)
- `assets/reference/wisepei-logo.png` — referência externa

**Protected area:** padding mínimo = 25% da altura do logo ao redor. Logo nunca abaixo de 24px de altura. Sobre fundo escuro usar versão branca; sobre fundo claro, versão preta; sobre accent lime, versão preta.

---

## Próximos passos para o usuário

**Caveats conhecidos:**
1. **Ilustrações originais da home** (`illus-satu`, `ilus-dua-1`, `asset1`, `asset3` no WordPress) não puderam ser baixadas (CORS). Use o `assets/placeholder-illustration.svg` por ora — quando você anexar os PNGs originais, eu substituo.
2. **Tipografia** (Manrope + Inter + JetBrains Mono) é uma proposta nova; o site atual roda stack WordPress default. Se quiser manter Inter-only ou outra escolha, me avisa.
3. **Logos oficiais** já estão integradas (`assets/feedback-logo-*.png`, `feedback-mark-*.png`). Versões SVG vetoriais seriam ideais para escala ilimitada — se tiver, envia.
4. **Cor oficial lime** da marca é `#ACDE40` (decisão do Edu; o mark 2019 amostrava `#BACD40`). A escala completa está em `colors_and_type.css`.
5. **WisePEI UI kit** foi construído a partir da landing page pública e do screenshot do hero — não tive acesso ao código-fonte. Tabelas/telas internas (aprovação, timeline do aluno, avaliação inicial) não foram recriadas.

**Para iterar:** a aba Design System tem todos os cards. Marque "changes-requested" em qualquer card e descreva o que mudar — eu ajusto cirurgicamente.
