# Fase 4 — QA visual (crítico adversarial)

> Roda: **executor crítico** em terminal SEPARADO de quem fez o re-skin. Quem produziu não audita o próprio trabalho.
> Saída: lista de defeitos por severidade → orquestrador corrige → re-screenshot → sign-off.

---

```
Projeto: WiseSST. O re-skin (Fases 1-3) está aplicado. Seu papel agora é CRÍTICO ADVERSARIAL
de QA visual: encontre tudo que ficou fora do Design System Feedback. NÃO corrija — só audite
e reporte. Invoque a skill wise-design-system pra ter os critérios.

FASE 4 — Auditoria visual. Varra todas as telas e a kitchen-sink e cheque:
1. CONTRASTE (WCAG AA): texto sobre ink, lime sobre ink, ink sobre lime, estados muted.
   Liste qualquer par abaixo de 4.5:1 (texto) / 3:1 (UI).
2. GLASS ESCOPADO: faça grep por backdrop-filter / blur. Sinalize QUALQUER uso em conteúdo
   (card, tabela, KPI, stat) — glass só vale em superfície flutuante (modal/palette/dropdown).
3. SLOP RESIDUAL: gradiente decorativo, sombra exagerada, emoji usado como ícone, cinza neutral
   default do shadcn ainda aparecendo, borda/raio inconsistente com os tokens.
4. TIPOGRAFIA: Inter em tudo (Comfortaa só no logo), hierarquia de heading coerente, número
   grande nos KPIs.
5. FORMATO BR: 1.000,00 (ponto milhar, vírgula decimal), DD/MM/YYYY, R$ com 2 casas. Sinalize
   qualquer número/data em formato US.
6. ESTADOS: foco visível (anel lime) em todo interativo, navegação por teclado, hover/active,
   estados vazio/erro/loading no visual (sem placeholder slop).
7. DARK-FIRST + RESPONSIVO: consistência dark, sem vazamento de light, quebra em mobile.

Entregue uma TABELA: [Tela | Achado | Severidade (CRÍTICO/ALTO/MÉDIO/BAIXO) | Correção sugerida].
Ordene por severidade. Não edite nada.
```

---

**Depois da auditoria:** o **orquestrador** aplica as correções por ordem de severidade (CRÍTICO/ALTO primeiro), roda build + lint, e re-tira screenshots das telas tocadas. Quando a lista zerar nos níveis CRÍTICO/ALTO → **sign-off do refino**.

**Por que terminal separado:** o crítico não herda o contexto de quem fez (não "defende" o próprio trabalho). É o mesmo princípio do produtor + crítico adversarial do framework — pega o que o autor não enxerga.

**Fechamento:** ao dar sign-off, registre no `docs/STATUS.md` do WiseSST que o Refino Visual foi concluído, e atualize a versão (SemVer) via `/finalizar`.
