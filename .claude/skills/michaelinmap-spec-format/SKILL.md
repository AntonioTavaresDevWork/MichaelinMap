---
name: michaelinmap-spec-format
description: NÃO USADA no Michaelin Map — o ADR-04 dispensa spec por feature; o PRD em docs/files/ cumpre o papel. Mantida só como referência do template Wise* caso o projeto volte atrás. Não invocar para escrever spec neste projeto.
---

> # ⚠️ Esta skill não vale para o Michaelin Map
>
> **O ADR-04 (Bíblia §15) dispensa spec por feature neste projeto.** Não existe `docs/specs/`,
> não há pipeline de agentes e o PRD original em `docs/files/` cumpre o papel de spec. A Bíblia
> é a fonte da verdade; decisões novas vão para lá, pendências para `docs/BACKLOG.md`.
>
> O conteúdo abaixo é o template Wise* original, **preservado apenas como referência** caso o
> projeto cresça a ponto de justificar spec formal. Ele descreve objetos do WiseFacilities que
> **não existem aqui** (`audit_log`, `capacidades`, multi-tenant). Não seguir.

# Formato de Spec Técnica — Wise* (template não aplicado neste projeto)

## LocalizaÃ§Ã£o

`docs/specs/F-<NUMERO>-<slug>-spec.md`

## EntregÃ¡veis da spec

> Os entregÃ¡veis marcados **[Modelo B]** sÃ³ se aplicam a projetos com substrato Capability-RBAC.
> Em projeto **Modelo A (tenant-scoped)**, declare-os "N/A neste projeto" e nÃ£o force conteÃºdo.
> Os demais sÃ£o universais. (O modelo Ã© declarado na BÃ­blia â€” ver skill `MICHAELINMAP-rls-policy`.)

Toda spec de feature tÃ©cnica entrega:

1. **Schema** â€” tabelas novas, alteraÃ§Ãµes em existentes (ADD COLUMN, FK, indexes)
2. **Seed** â€” dados iniciais (configs, dados de referÃªncia; cargos/capabilities se Modelo B)
3. **AlteraÃ§Ãµes na tabela de auditoria** â€” colunas novas com DEFAULT quando aplicÃ¡vel (schema da tabela de auditoria conforme declarado na BÃ­blia â€” `audit_log` padrÃ£o ou outra)
4. **[Modelo B] CatÃ¡logo de capabilities** â€” capabilities NOW + forward-looking se a feature antecipa F-XX futura
5. **[Modelo B] Matriz cargo Ã— capacidade** â€” quais cargos ganham quais capabilities
6. **FunÃ§Ãµes de autorizaÃ§Ã£o** â€” novas funÃ§Ãµes SQL ou alteraÃ§Ãµes ([Modelo B]: `has_capacidade` etc.; [Modelo A]: helpers de tenant/escopo)
7. **Refactor de funÃ§Ãµes existentes** â€” `is_superadmin`, helpers de sessÃ£o/tenant, etc.
8. **Policies (DROP + CREATE)** â€” todas as RLS afetadas, com snippet canÃ´nico no topo + exceÃ§Ãµes explicitadas
9. **RPCs SECURITY DEFINER** â€” todas com auditoria (na tabela declarada), validaÃ§Ãµes, REVOKE/GRANT
10. **MudanÃ§as de comportamento absorvidas (MC-NN)** â€” quando a feature corrige interpretaÃ§Ã£o anterior (referenciar BÃ­blia Â§X.Y)
11. **Migration plan em fases** â€” Fase 1 (refactor preservando coexistÃªncia) + Fase N (cleanup, drop de legado)
12. **Smoke tests** â€” ST-01 a ST-NN, executÃ¡veis via UI ou SQL, cada um com critÃ©rio de aceite

## Estrutura de cabeÃ§alho

```markdown
# F-<NUMERO> â€” <TÃ­tulo> â€” Spec TÃ©cnica

| Campo | Valor |
|---|---|
| Status | Draft / Aprovada / Em apply / Em produÃ§Ã£o |
| VersÃ£o | 1.0 |
| Investigation | docs/specs/F-<NUMERO>-investigation.md |
| DecisÃ£o arquitetural | ADR-XXX se houver |
| Aprovada por | Edu, <data> |
| Aplicada em | <data ou pendente> |

## SumÃ¡rio executivo
<3-5 linhas: o que a feature faz, por que existe, escopo>

## Â§1 â€” Schema
...

## Â§2 â€” Seed
...

(seguir as 12 seÃ§Ãµes)
```

## Regras

- **Investigation antes de spec.** Toda spec Ã© precedida por `F-<NUMERO>-investigation.md` (estado atual, gaps, riscos). Sem investigation, spec Ã© chute.
- **Smoke tests numerados.** ST-01, ST-02, etc. Cada um: ator + aÃ§Ã£o + resultado esperado. Independentes (nÃ£o dependem de ordem).
- **MudanÃ§as de comportamento explicitadas.** Se a spec corrige policy/RPC que hoje funciona de jeito X e vai funcionar de jeito Y, registrar em Â§10 com justificativa. Sem isso, vira "alteraÃ§Ã£o silenciosa nÃ£o autorizada".
- **DPs blocking resolvidas.** Spec sÃ³ nasce com todas as DPs marcadas BLOCKING no investigation respondidas pelo Edu.

## PrÃ©-handoff para Data Architect

Spec sÃ³ vai pro pipeline depois de aprovada por Edu (via orquestrador). AprovaÃ§Ã£o verifica:

- Todos os entregÃ¡veis aplicÃ¡veis presentes (os marcados [Modelo B] sÃ£o "N/A" em projeto Modelo A)
- Snippet canÃ´nico de RLS conferido (skill `wise-rls-policy`)
- RPCs no padrÃ£o (skill `wise-rpc`)
- Migration plan respeita estratÃ©gia de coexistÃªncia (skill `wise-migration`)

## ReferÃªncias

- Exemplo canÃ´nico de origem: WiseFacilities `docs/specs/F-RBAC-v2-spec.md` (14 seÃ§Ãµes, todas as 12 obrigatÃ³rias cobertas) + `F-RBAC-v2-investigation.md`.
- No projeto novo: apontar aqui a primeira spec aprovada como referÃªncia local.
