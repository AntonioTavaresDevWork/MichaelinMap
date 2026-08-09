# Fase 3 — Telas

> Roda: **executor(es) frontend** — 1 por grupo de rotas (paralelizável). Fase 2 aprovada.
> Aqui o re-skin completo acontece, tela por tela, herdando tokens + componentes das fases 1-2.

---

```
Projeto: WiseSST. Fases 1-2 aprovadas (tema + componentes core no visual Feedback).
Stack: Tailwind v4 + shadcn. Invoque a skill wise-design-system antes de começar.

FASE 3 — Re-skin das telas (visual apenas):
1. PRIMEIRO faça o inventário: liste todas as rotas/telas (src/pages ou src/routes) e me
   devolva a lista + uma ORDEM sugerida de re-skin (mais usadas primeiro). NÃO comece a
   editar antes de eu aprovar a ordem.
2. Re-skine tela por tela (ou por grupo, se eu despachar mais de um executor). Em cada tela:
   - Troque padrões de slop: cards genéricos → fb-card sólido; sombras default → camadas de
     ink; emoji → ícones lucide; gradiente decorativo → remover; cor neutra default → ink.
   - Aplique layout/espaçamento/tipografia do DS: grid 4px, Inter, hierarquia de heading,
     KPIs com número grande (estilo --fb-stat).
   - Glass só onde há superfície flutuante (modal/command palette/dropdown). Conteúdo sólido.
   - Formato BR: 1.000,00 · DD/MM/YYYY · R$.
   - Estados vazios/erro/loading também entram no visual (não deixe placeholder slop).
3. Não toque em lógica de negócio, queries, hooks ou rotas. Se uma tela precisar de mudança
   de dado pra ficar correta visualmente, PARE e sinalize — não improvise.
4. A cada tela (ou lote), rode build + lint e tire screenshot. Reporte em blocos pequenos
   pra eu revisar incrementalmente, não tudo no fim.

Regras: anti-slop = anti-gratuito; glass escopado; sem emoji-ícone; dark-first; BR na UI.

PARE após o inventário (passo 1) pra eu aprovar a ordem. Depois, PARE a cada lote de telas
com screenshots. Aguarde meu OK entre lotes.
```

---

**Saída esperada:** inventário de telas + ordem, depois telas re-skinadas em lotes com screenshots, build/lint limpos a cada lote.

**Gate duplo:** (1) aprova a **ordem** antes de editar; (2) aprova **cada lote** por screenshot. Revisão incremental — você nunca recebe 20 telas de uma vez pra auditar às cegas.

**Dica de paralelização:** se for despachar 2+ executores, divida por grupo de rotas sem sobreposição (ex.: executor A = auth + onboarding; executor B = dashboard + relatórios). O orquestrador integra e resolve conflito de merge.
