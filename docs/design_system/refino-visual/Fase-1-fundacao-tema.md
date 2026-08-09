# Fase 1 — Fundação de tema

> Roda: **orquestrador** (inline). Saída: tema mapeado + 1 tela de referência re-skinada.
> Cole o bloco abaixo no CLI do WiseSST.

---

```
Projeto: WiseSST. Vamos refinar o frontend (hoje AI-slop) com o Design System da
Feedback. Stack: Tailwind v4 (@tailwindcss/vite, SEM tailwind.config.js, tema em @theme
no src/index.css) + shadcn (CSS-vars, baseColor neutral, lucide).

FASE 0 — Placement (se ainda não feito):
1. Mova o Design System pra .claude/skills/wise-design-system/ (README.md, SKILL.md,
   colors_and_type.css, ui_kits/). Logos → src/assets/brand/. Fontes → public/fonts/.
   preview/ e assets/reference/ → docs/design-system/.
2. Invoque a skill wise-design-system e confirme que leu README.md + colors_and_type.css.

FASE 1 — Fundação de tema (NÃO re-skinar telas em massa ainda):
3. Traga para src/index.css APENAS os primitivos --fb-* (rampa lime, ink, snow, semânticas,
   chart) e a escala de tipo. NÃO importe o colors_and_type.css inteiro: as classes de
   elemento .fb-btn/.fb-card/etc. são do site de marketing e colidem com o shadcn.
4. Remapeie as vars semânticas do shadcn para os primitivos, DARK-FIRST:
     --background:#0F141B  --foreground:#F4F6F8
     --card:#1A222B  --popover:#1A222B
     --primary:#ACDE40  --primary-foreground:#0F141B   (lime oficial / ink sobre lime)
     --secondary:#222B36  --muted:#222B36  --muted-foreground:#A5AEBC
     --accent-foreground:#ACDE40
     --destructive:#E5484D  --border:#29323B  --input:#29323B  --ring:#ACDE40
     --radius:0.75rem
   Replique em :root e .dark; preencha também o bloco light com os valores light do DS.
5. Default do app = .dark no <html>. Inter como --font-sans (carregue de public/fonts);
   Comfortaa SÓ no logo. Confirme que --color-success=#34C759 (verde distinto do lime).
6. Re-skine UMA tela de referência ponta-a-ponta (escolha dashboard OU login e me diga
   qual): superfícies em camadas de ink, números grandes, cards generosos, espaçamento
   do grid 4px do DS. Glass APENAS se houver superfície flutuante (modal/command palette);
   conteúdo sólido.
7. Rode `npm run build` e `npm run lint`. Tire screenshot da tela re-skinada.

Regras inegociáveis (skill wise-design-system): anti-slop = anti-gratuito — sem gradiente
decorativo, sem emoji como ícone (use lucide), sem glass em conteúdo, sem o cinza neutral
default do shadcn (use ink). Formato BR na UI (1.000,00 · DD/MM/YYYY · R$).

PARE no fim da Fase 1 e me mostre o screenshot + o diff do src/index.css. Aguarde meu OK
antes de qualquer outra tela.
```

---

**Saída esperada:** `src/index.css` com tokens mapeados, fontes carregando, 1 tela de referência no visual Feedback (dark + lime + Inter), build/lint limpos, screenshot.

**Gate:** você aprova o "tom" do projeto aqui. Se a tela de referência te agrada, a fundação está certa e as próximas fases herdam quase tudo de graça. Se não, ajusta o mapeamento de tokens **antes** de seguir — é barato agora, caro depois.
