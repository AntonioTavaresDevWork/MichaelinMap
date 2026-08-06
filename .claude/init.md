# MICHAELINMAP â€” Init

> *(Template Wise\* v1.2 â€” espelho do ApÃªndice D do Manual.)*

## InstruÃ§Ãµes de inÃ­cio de sessÃ£o

> Este `init.md` Ã© o **checklist de boot** â€” lido como parte do boot acionado por `/orquestrador`
> (ou `/executor`). NÃ£o Ã© o `/init` embutido do Claude Code (que gera CLAUDE.md).

No boot da sessÃ£o (via `/orquestrador`), execute OBRIGATORIAMENTE nesta ordem:

1. Leia `.claude/CLAUDE.md` â€” regras, stack e convenÃ§Ãµes do projeto
2. Leia `docs/MICHAELINMAP_BIBLIA.md` â€” fonte da verdade: domÃ­nio, schema, roteiro, camada de IA
3. Leia `docs/DOMAIN_QUESTIONS.md` â€” Mapa de Perguntas de DomÃ­nio (o moat do produto)
4. Leia `docs/STATUS.md` â€” estado atual, o que foi feito, prÃ³xima aÃ§Ã£o, progresso de IA
5. Leia `docs/BACKLOG.md` â€” pendÃªncias consolidadas (dÃ­vida tÃ©cnica, UX, TBDs, decisÃµes)
6. Leia `src/types/index.ts` â€” tipos TypeScript (se jÃ¡ existir)

ApÃ³s ler, responda com:

- **Resumo do projeto** (2 linhas)
- **Fase atual** e o que estÃ¡ em desenvolvimento
- **Quantas tabelas** existem no banco e quais mÃ³dulos cobrem
- **Camada de IA:** quantas perguntas de domÃ­nio implementadas vs. pendentes, fluxos agÃªnticos ativos
- **Quais agentes de dev** estÃ£o disponÃ­veis e quando despachar cada um (briefing copiÃ¡vel â€” nunca Agent tool)
- **PrÃ³xima aÃ§Ã£o** exata conforme o STATUS.md

## Regra de ouro

Nunca comece a codar sem confirmar com Edu a prÃ³xima aÃ§Ã£o.
Se houver divergÃªncia entre STATUS.md e o estado real do cÃ³digo,
reporte a divergÃªncia ANTES de agir.

## Ao final de cada sessÃ£o

Despache o technical-writer (briefing copiÃ¡vel) para atualizar `docs/STATUS.md` com:

- Data e resumo do que foi feito
- Checkboxes concluÃ­dos na BÃ­blia
- Nova "PrÃ³xima aÃ§Ã£o"
- Progresso da camada de IA (perguntas de domÃ­nio implementadas, fluxos agÃªnticos)
- DecisÃµes tomadas ou blockers encontrados (pendÃªncias novas vÃ£o pro `docs/BACKLOG.md`)
- Hash do Ãºltimo commit
