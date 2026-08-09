# WisePEI SaaS — UI Kit

Recriação hi-fi do dashboard **WisePEI** (produto construído pela Feedback para educação inclusiva).

**Fonte:** https://www.wisepei.com.br — landing pública + screenshot de referência em `assets/reference/img-hero-2.png`.

> **Caveat:** não temos acesso ao código-fonte do WisePEI. Esta recriação é guiada pela landing page, pelo screenshot do dashboard no hero, e pelo sistema visual que estabelecemos (dark + lime oficial `#ACDE40`). Componentes como tabelas de aprovação ou timeline do aluno são inferências do copy da landing — verificar com a build real.

## Componentes

- `Sidebar.jsx` — navegação lateral fixa com seções
- `Topbar.jsx` — breadcrumb + filtro de período + avatar
- `StatCards.jsx` — 4 KPIs no topo do dashboard
- `PEIStatusDonut.jsx` — donut "PEIs por Status"
- `ProgressoBarras.jsx` — barras horizontais por área de habilidade
- `AtividadesChart.jsx` — linha de atividades ao longo do tempo
- `NeedsPie.jsx` — pie de distribuição de necessidades especiais

## Abrir

`index.html` — monta a "Visão Geral" do painel de coordenação.
