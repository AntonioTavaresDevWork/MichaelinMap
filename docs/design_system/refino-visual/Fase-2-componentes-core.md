# Fase 2 — Componentes core

> Roda: **executor frontend** (1 terminal). Só comece com a Fase 1 aprovada por você.
> Como os componentes shadcn leem CSS-vars, muito já vem da Fase 1 — aqui afinamos variantes.

---

```
Projeto: WiseSST. Fase 1 (fundação de tema) já aprovada — src/index.css com tokens do
Design System Feedback, dark-first, lime #ACDE40. Stack: Tailwind v4 + shadcn (CVA).
Invoque a skill wise-design-system antes de começar.

FASE 2 — Componentes core (visual apenas, sem mexer em lógica de negócio):
1. Liste os componentes em src/components/ui/ e me diga quais existem.
2. Afine as variantes CVA pra casar com o DS:
   - Button: variante primary = bg lime (--primary) com texto ink (--primary-foreground);
     ghost = borda --border + hover --secondary; altura base h-11 (44px); focus-visible com
     anel duplo lime (espelhe --shadow-focus do DS: 0 0 0 2px lime, 0 0 0 4px rgba(172,222,64,.25)).
   - Card: padding generoso (24px), borda --border, hover sobe a borda; SÓLIDO (sem glass).
   - Input: h-11, bg --input, foco com borda lime + anel.
   - Badge: bg rgba(172,222,64,.12), texto lime, pill, caption uppercase.
   - Tabs / Switch / Select: estado ativo = lime; trilhos em ink.
3. Superfícies FLUTUANTES recebem glass escopado (Dialog, Sheet, DropdownMenu, Popover,
   Command/⌘K, ContextMenu): backdrop-filter blur(18px) saturate(1.25), bg rgba(26,33,44,.70),
   borda 1px rgba(255,255,255,.11), brilho no topo (inset 0 1px 0 rgba(255,255,255,.12)),
   sombra de elevação (0 24px 60px -20px rgba(0,0,0,.75)). Texto com contraste preservado.
4. Tabela (TanStack + shadcn): header em --muted-foreground, hover de linha sutil, números
   alinhados à direita em formato BR (1.000,00). SÓLIDA.
5. Sidebar/nav: superfície ink-1, item ativo com acento lime.
6. Crie/atualize uma página "kitchen-sink" (ex.: src/pages/_ds-preview.tsx) renderizando TODOS
   os componentes afinados, pra revisão isolada. Rode build + lint. Screenshot da kitchen-sink.

Regras: anti-slop = anti-gratuito. Glass só em superfície flutuante — NUNCA em card/tabela/KPI.
Sem emoji como ícone (lucide). Não altere props/handlers nem lógica; se um ajuste visual exigir
mudança de dado/hook, PARE e me sinalize.

PARE no fim e me mostre a kitchen-sink + a lista de componentes alterados. Aguarde meu OK.
```

---

**Saída esperada:** camada `components/ui/` no visual Feedback, página kitchen-sink pra revisão, build/lint limpos.

**Gate:** valide cada componente isolado na kitchen-sink antes de partir pras telas. Aqui você pega inconsistência de variante (um botão ghost errado) sem precisar caçar em 20 telas depois.
