# MICHAELINMAP â€” STATUS.md
> Atualizado pelo CLI ao final de cada sessÃ£o de desenvolvimento.  
> Compartilhar com Claude Web/Desktop no inÃ­cio de cada conversa.
> *(Template Wise\* v1.2 â€” espelho do ApÃªndice B do Manual.)*

---

## ðŸ—“ï¸ Ãšltima atualizaÃ§Ã£o
**Data:** YYYY-MM-DD  
**SessÃ£o:** [Setup inicial | F-XX â€” Nome]  
**Atualizado por:** [Edu (setup manual) | Claude Code (Technical Writer)]

---

## ðŸ“ Fase atual
**Fase [N] â€” [Nome]**  
Objetivo: [Uma frase]

---

## âœ… ConcluÃ­do

### Infraestrutura (Setup)
- [ ] Schema PostgreSQL aplicado
- [ ] RLS habilitado em todas as tabelas
- [ ] Seed aplicado
- [ ] Repo GitHub criado
- [ ] Vite + React + Tailwind + shadcn/ui inicializados
- [ ] DependÃªncias instaladas
- [ ] `.claude/CLAUDE.md` configurado
- [ ] `init.md` configurado
- [ ] 5 agentes em `.claude/agents/`
- [ ] 5 skills em `.claude/skills/` (MICHAELINMAP-*)
- [ ] Prompts orquestrador/executor em `docs/prompts/`
- [ ] `docs/MICHAELINMAP_BIBLIA.md` salvo no repo
- [ ] `docs/STATUS.md` criado
- [ ] `docs/BACKLOG.md` criado
- [ ] MCP Supabase configurado

### DocumentaÃ§Ã£o
- [ ] PRD (`docs/PRD-MICHAELINMAP.md`)
- [ ] BÃ­blia (`docs/MICHAELINMAP_BIBLIA.md`)

---

## ðŸ”„ Em andamento
Nada em andamento. Setup concluÃ­do. Aguardando inÃ­cio do build.

---

## â­ï¸ PrÃ³xima aÃ§Ã£o
**Feature:** F-00 â€” Infraestrutura base  
**O que fazer:**
1. Criar `src/lib/supabase/client.ts`
2. Criar `src/lib/utils.ts` (cn + mapRpcError + formatadores BR)
3. Criar `src/types/index.ts`
4. Criar guard de autenticaÃ§Ã£o nas rotas (React Router)
5. Criar layout do dashboard (sidebar + header)
6. Criar pÃ¡gina de login

---

## ðŸš« Blockers
Nenhum.

---

## ðŸ“‹ Backlog de decisÃµes pendentes
> Espelha a seÃ§Ã£o 15 da BÃ­blia. Marcar como resolvido nos dois arquivos simultaneamente.
> PendÃªncias tÃ©cnicas/UX detalhadas vivem em `docs/BACKLOG.md`.

- [ ] [DecisÃ£o 1]
- [ ] [DecisÃ£o 2]

---

## ðŸ“ Log de sessÃµes

### YYYY-MM-DD â€” SessÃ£o 01: Brainstorm + FundaÃ§Ã£o
**O que foi feito:**
- Brainstorm completo (Claude Web)
- PRD v1.x produzido e validado
- BÃ­blia v1.x produzida e validada
- Auditoria: business-architect + data-architect (CLI)
- Documentos finais consolidados

**DecisÃµes tomadas:**
- [DecisÃ£o 1]
- [DecisÃ£o 2]

**PrÃ³xima sessÃ£o:** F-00 â€” Infraestrutura base

---

_Para iniciar nova sessÃ£o de dev:_
```
CLI#1 (orquestrador): colar docs/prompts/01-orquestrador-cli.md
CLI#2+ (executores):  colar docs/prompts/02-executor-cli.md
```

> Modelo de autorizacao declarado no scaffold: A (tenant-scoped). Reconciliar na Etapa 2B.

