# Refino Visual — Playbook (aplicar o Design System num projeto Wise*)

> Projeto-alvo: **WiseSST** · Data: 2026-08-01
> Stack assumida: **Tailwind v4** (`@tailwindcss/vite`, sem `config.js`, tema em `@theme` no `src/index.css`) + **shadcn/ui** (CSS-vars, baseColor neutral, ícones lucide).
> Para reusar em outro projeto Wise*, troque o nome e confirme a stack no topo de cada fase.

## A ideia

Re-skin **completo** do frontend (hoje AI-slop), mas **sequenciado em fases** com um **gate de aprovação seu entre cada uma**. Fundação primeiro evita re-trabalhar tela que você mexeu antes do tema assentar.

Cada arquivo `Fase-N-*.md` contém um **bloco copiável** (dentro de ```` ``` ````). O fluxo é: abre o arquivo → copia o bloco → cola no CLI certo → o agente para no fim da fase e te mostra screenshot → você aprova → próxima fase.

## Pré-requisito — Fase 0 (placement)

Antes da Fase 1, reorganize o que você copiou (não deixe a pasta inteira na raiz):

```
WiseSST/
├─ .claude/skills/wise-design-system/   ← README.md, SKILL.md, colors_and_type.css, ui_kits/
├─ docs/design-system/                   ← preview/, assets/reference/
├─ src/assets/brand/                      ← logos .svg/.png
└─ public/fonts/                          ← Inter + Comfortaa
```

Isso pode ir junto no início da Fase 1 (o briefing já cobre). O ponto crítico: o `SKILL.md` em `.claude/skills/` faz o Claude Code CLI **descobrir e invocar a skill sozinho** — é o que torna o DS lei do projeto.

## Quem roda o quê (modelo orquestrador/executor)

| Fase | Quem | Por quê |
|---|---|---|
| **1 — Fundação** | Orquestrador (inline) | Cirúrgico, mexe em 1-2 arquivos de tema. Decisão de arquitetura visual. |
| **2 — Componentes core** | Executor frontend (1 terminal) | Trabalho de volume na camada shadcn; orquestrador integra. |
| **3 — Telas** | Executor(es) frontend, 1 por grupo de rotas | Paralelizável; orquestrador revisa antes do merge. |
| **4 — QA visual** | Executor **crítico adversarial** (terminal separado) | Quem fez não audita o próprio trabalho. Ataca antes de fechar. |

## Regra de ouro entre fases

**Pare e mostre screenshot. Não avance sem o seu "ok".** Cada briefing termina com `PARE e aguarde aprovação` — mantenha isso. É o gate anti-slop: você bate o olho no resultado real antes de espalhar.

## O checklist anti-slop (vale em todas as fases)

- **Anti-slop = anti-gratuito.** Sem gradiente decorativo, sem sombra exagerada, sem emoji como ícone (use lucide).
- **Glass só em superfície flutuante** (modal, command palette, dropdown, header scrollado). Conteúdo (card, tabela, KPI) é **sempre sólido**.
- **Paleta neutra = ink** (`#29323B` e família), nunca o cinza morto do baseColor neutral do shadcn.
- **Tipografia Inter**, números grandes como protagonistas, cards generosos.
- **Formato BR na UI:** `1.000,00` · `DD/MM/YYYY` · `R$`.
- **Dark-first.** App default = `.dark` no `<html>`.

## Ordem dos arquivos

1. `Fase-1-fundacao-tema.md` ← comece aqui
2. `Fase-2-componentes-core.md`
3. `Fase-3-telas.md`
4. `Fase-4-qa-visual.md`
