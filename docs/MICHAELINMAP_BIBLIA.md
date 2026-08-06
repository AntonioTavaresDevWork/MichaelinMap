# MICHAELINMAP â€” BÃ­blia do Projeto
**VersÃ£o:** 1.0 | **Data:** YYYY-MM-DD | **Autor:** Edu Mello  
**Status do projeto:** ðŸ”´ PrÃ©-desenvolvimento

> Este documento Ã© a fonte da verdade do MICHAELINMAP.  
> CLI: leia este arquivo no inÃ­cio de cada sessÃ£o via `init.md`.  
> Claude Web/Desktop: Edu compartilha o `STATUS.md` atualizado a cada sessÃ£o.

---

## 1. VisÃ£o Geral

**O que Ã©:** [Uma frase descrevendo o produto]  
**Cliente / Contexto:** [Cliente final ou "produto SaaS prÃ³prio"]  
**Problema que resolve:** [Uma frase â€” o pain point central]  
**Foco do MVP:** [O que o MVP entrega â€” o que NÃƒO Ã©]  
**VisÃ£o de longo prazo:** [SaaS multi-tenant? ExpansÃ£o de mÃ³dulos? IntegraÃ§Ã£o futura?]

---

## 2. Stack Completo

```
Frontend:    React + Vite + TypeScript (SPA, sem SSR) [exceÃ§Ã£o: Next.js sÃ³ com justificativa SSR/SEO]
UI:          Tailwind CSS + shadcn/ui + [TanStack Table se aplicÃ¡vel]
Forms:       Estado controlado manual via useState (sem react-hook-form/zod) â€” validaÃ§Ã£o inline no onSubmit
NotificaÃ§Ãµes: sonner (Toaster richColors) â€” toast no onSuccess/onError dos hooks
State:       React Query (server state) + [Zustand se necessÃ¡rio p/ UI state]
Routing:     React Router DOM
PDF:         [react-pdf | N/A]
Backend/DB:  Supabase (PostgreSQL 17 + Auth + Storage + Edge Functions)
Server-side: Supabase Edge Functions (Deno) â€” sem API routes no frontend
Auth:        Supabase Auth
Storage:     Supabase Storage [especificar buckets se jÃ¡ definidos]
Email:       [Resend | N/A â€” especificar se hÃ¡ alertas]
PWA:         [Sim | NÃ£o]
AutomaÃ§Ãµes:  [Make.com / N8N â€” Fase X | N/A]
Deploy:      Vercel
Dev:         Cursor + Claude Code CLI (multi-terminal: orquestrador + executores)
Design System: skill `feedback-comunicacao-design` (global) Â· tema [dark | light] Â·
             [herda dark+lime da Feedback | identidade prÃ³pria â€” descrever] Â·
             refino visual = fase pÃ³s-MVP funcional (nÃ£o por feature)
```

---

## 3. RepositÃ³rio e Infraestrutura

```
GitHub org:      AdminFeedpro
Repo:            AdminFeedpro/MICHAELINMAP
Pasta local:     C:\Users\EMello\SaaS\SaaS_MICHAELINMAP
Supabase URL:    [PENDENTE â€” apÃ³s criar projeto no Supabase]
Supabase ID:     [PENDENTE]
Deploy:          Vercel [PENDENTE â€” configurar apÃ³s MVP]
```

---

## 4. Modelo de DomÃ­nio

> Diagrama textual das entidades principais e seus relacionamentos.  
> Use â†’ para 1:N e â†â†’ para N:N.

```
[Entidade A] â†â†’ [Entidade B] (N:N via tabela_pivot)
[Entidade A] â†’ [Entidade C] (1:N)

[Entidade principal do sistema]
  â””â”€â”€ [Entidade filha 1]
  â””â”€â”€ [Entidade filha 2]
        â””â”€â”€ [Sub-entidade]
```

---

## 5. Regras de NegÃ³cio

> Esta seÃ§Ã£o Ã© a referÃªncia que o CLI consulta quando hÃ¡ dÃºvida de comportamento.  
> Numere as regras. Seja explÃ­cito â€” "o sistema deve X quando Y acontecer".

### 5.1 [Ãrea de regras â€” ex: PrecificaÃ§Ã£o]
- **RN-01:** [Regra completa, sem ambiguidade]
- **RN-02:** [Regra completa, sem ambiguidade]
- **RN-03 [PENDENTE]:** [Regra que ainda precisa ser definida com o cliente]

### 5.2 [Ãrea de regras â€” ex: Status / Fluxo de trabalho]
- **RN-10:** [Regra completa]

### 5.3 [Ãrea de regras â€” ex: Acesso e permissÃµes]
- **RN-20:** [Regra completa]

> âš ï¸ Adicionar seÃ§Ãµes conforme o domÃ­nio do projeto. NÃ£o deixar regras implÃ­citas.

---

## 6. Fluxo de Status Principal

> Se o sistema tem uma entidade central com ciclo de vida (orÃ§amento, pedido, tarefa, etc.),
> descrever o fluxo aqui. Caso contrÃ¡rio, remover esta seÃ§Ã£o.

```
[status_inicial] â†’ [status_2] â†’ [status_3] â†’ [status_final]

Terminais (de qualquer ponto): [cancelado] | [recusado]
```

### Regras de transiÃ§Ã£o
| De | Para | CondiÃ§Ã£o | Quem pode |
|---|---|---|---|
| [status A] | [status B] | [condiÃ§Ã£o ou "livre"] | [admin / rep / sistema] |

### Regras de ediÃ§Ã£o por status
| Status | EdiÃ§Ã£o permitida? | Comportamento |
|---|---|---|
| [status inicial] | âœ… Livre | Sem log |
| [status intermediÃ¡rio] | âœ… Com log | Registra diff em `[tabela_log]` |
| [status avanÃ§ado] | ðŸ”’ Bloqueada | Exige novo registro (clone/versÃ£o) |

---

## 7. Schema do Banco de Dados

> Listar todas as tabelas com colunas principais. NÃ£o precisa ser SQL completo aqui â€”
> o SQL detalhado fica em `supabase/migrations/`. Esta seÃ§Ã£o Ã© para referÃªncia rÃ¡pida.

### Tabelas principais

#### `[nome_tabela]`
| Coluna | Tipo | ObrigatÃ³rio | DescriÃ§Ã£o |
|---|---|---|---|
| `id` | uuid | âœ… | PK, default gen_random_uuid() |
| `[coluna]` | [tipo] | âœ…/âŒ | [descriÃ§Ã£o] |
| `created_at` | timestamptz | âœ… | default now() |
| `updated_at` | timestamptz | âœ… | atualizado por trigger |
| `deleted_at` | timestamptz | âŒ | soft delete â€” NULL = ativo |

> Repetir para cada tabela. Agrupar por mÃ³dulo.

### Views

| View | PropÃ³sito |
|---|---|
| `v_[nome]` | [o que ela calcula/agrega] |

### Enums

| Enum | Valores |
|---|---|
| `[nome_enum]` | `valor_1`, `valor_2`, `valor_3` |

### Ãndices obrigatÃ³rios

```sql
-- Descrever Ã­ndices alÃ©m dos PKs â€” campos de busca frequente, filtros, JOINs
CREATE INDEX idx_[tabela]_[campo] ON [tabela]([campo]);
```

### Modelo de AutorizaÃ§Ã£o *(declaraÃ§Ã£o obrigatÃ³ria â€” as skills RLS/RPC se adaptam a ela)*

| Campo | Valor |
|---|---|
| **Modelo** | [ **A â€” Tenant-scoped** (`company_id = <fn_company>()` + `is_superadmin()`) \| **B â€” Capability-RBAC** (substrato cargo Ã— capacidade, `has_capacidade()`) ] |
| **FunÃ§Ã£o que resolve a empresa do caller** | [ `get_user_company_id()` \| `auth_company_id()` \| outra ] |
| **Tabela de auditoria** | [ `audit_log` (padrÃ£o framework) \| `sync_log` \| outra â€” descrever schema ] |
| **Acesso anon (pÃºblico)** | [ Negado em tudo \| ExceÃ§Ã£o via ADR-XXX: portal pÃºblico por token em RPC `SECURITY DEFINER` ] |

> Comece no **Modelo A**, salvo necessidade clara de permissÃµes finas por papel. Migrar Aâ†’B Ã© aditivo; o inverso Ã© caro. Default do framework para auditoria Ã© `audit_log`, mas o projeto pode usar tabela prÃ³pria. Qualquer acesso anon intencional exige um ADR registrado aqui.

### RLS â€” checklist por tabela

| Tabela | RLS on | SELECT | INSERT | UPDATE | DELETE/Soft |
|---|---|---|---|---|---|
| `[tabela]` | âœ… | [escopo] | [escopo] | [escopo] | soft delete |

---

## 8. Hierarquia / FÃ³rmulas de CÃ¡lculo

> Preencher apenas se o sistema tem cÃ¡lculos complexos (preÃ§os, scores, mÃ©tricas).  
> Caso contrÃ¡rio, remover esta seÃ§Ã£o.

```
[FÃ³rmula principal em pseudocÃ³digo]

PrecedÃªncia de regras (mais especÃ­fica â†’ mais genÃ©rica):
  1. [regra mais especÃ­fica]
  2. [...]
  N. [fallback]
```

---

## 9. NumeraÃ§Ã£o de Documentos

> Preencher apenas se o sistema gera documentos numerados (orÃ§amentos, pedidos, etc.).

```
[Tipo]:  [PREFIXO]-{CAMPO}-{DDMMAA}-{SEQ4}
         Ex: [PREFIXO]-CLIENTE-250325-0001
```

RestriÃ§Ãµes:
- `[entidade].short_name` tem constraint `UNIQUE` â€” evita colisÃ£o na numeraÃ§Ã£o
- FunÃ§Ã£o `generate_[tipo]_number()` trata caracteres especiais e espaÃ§os

---

## 10. IntegraÃ§Ãµes Externas

| ServiÃ§o | Finalidade | Fase | Status |
|---|---|---|---|
| [ServiÃ§o] | [Para que serve] | [1/2/3] | [PENDENTE / configurado] |
| Resend | Alertas por email | 1 | [PENDENTE] |
| Make.com | [AutomaÃ§Ã£o X] | 2 | Fase futura |

---

## 11. VariÃ¡veis de Ambiente

```env
# Client (Vite expÃµe apenas VITE_)
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=

# Server-side APENAS (Edge Functions secrets â€” nunca no client)
SUPABASE_SERVICE_ROLE_KEY=
RESEND_API_KEY=
ANTHROPIC_API_KEY=
[OUTRA_VAR]=
```

> âš ï¸ Nunca commitar valores reais. Usar `.env.local` (no .gitignore).

---

## 12. Estrutura de Pastas

```
[nome-projeto]/
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ components/
â”‚   â”‚   â”œâ”€â”€ [modulo]/                 # arquivos kebab-case
â”‚   â”‚   â”‚   â”œâ”€â”€ [modulo]-table.tsx
â”‚   â”‚   â”‚   â”œâ”€â”€ [modulo]-form.tsx
â”‚   â”‚   â”‚   â””â”€â”€ [modulo]-modal.tsx
â”‚   â”‚   â”œâ”€â”€ shared/                   # reutilizados entre features
â”‚   â”‚   â””â”€â”€ ui/                       # shadcn/ui
â”‚   â”œâ”€â”€ hooks/
â”‚   â”‚   â””â”€â”€ use-[modulo].ts           # centralizados, nÃ£o colocalizados
â”‚   â”œâ”€â”€ pages/                        # rotas (React Router DOM)
â”‚   â”‚   â””â”€â”€ [modulo]/
â”‚   â”‚       â”œâ”€â”€ index.tsx
â”‚   â”‚       â”œâ”€â”€ novo.tsx
â”‚   â”‚       â””â”€â”€ [id].tsx
â”‚   â”œâ”€â”€ lib/
â”‚   â”‚   â”œâ”€â”€ supabase/
â”‚   â”‚   â”‚   â””â”€â”€ client.ts             # singleton, valida env no import
â”‚   â”‚   â””â”€â”€ utils.ts                  # cn() + mapRpcError + formatadores BR
â”‚   â””â”€â”€ types/
â”‚       â””â”€â”€ index.ts                  # TODAS as interfaces centralizadas
â”œâ”€â”€ supabase/
â”‚   â”œâ”€â”€ migrations/
â”‚   â”œâ”€â”€ rollbacks/                    # rollback manual por migration crÃ­tica
â”‚   â””â”€â”€ functions/                    # Edge Functions (Deno)
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ MICHAELINMAP_BIBLIA.md      â† este arquivo
â”‚   â”œâ”€â”€ DOMAIN_QUESTIONS.md          â† Mapa de Perguntas de DomÃ­nio
â”‚   â”œâ”€â”€ STATUS.md
â”‚   â”œâ”€â”€ BACKLOG.md                   # fonte Ãºnica de pendÃªncias
â”‚   â”œâ”€â”€ PATTERNS.md                  # padrÃµes por feature (criado durante o dev)
â”‚   â”œâ”€â”€ prompts/
â”‚   â”‚   â”œâ”€â”€ 01-orquestrador-cli.md
â”‚   â”‚   â””â”€â”€ 02-executor-cli.md
â”‚   â”œâ”€â”€ specs/                       # F-XX-{investigation|spec}.md
â”‚   â””â”€â”€ qa/                          # F-XX-{audit|smoke}-report.md
â”œâ”€â”€ .claude/
â”‚   â”œâ”€â”€ CLAUDE.md
â”‚   â”œâ”€â”€ init.md
â”‚   â”œâ”€â”€ agents/
â”‚   â”‚   â”œâ”€â”€ 01-business-architect.md
â”‚   â”‚   â”œâ”€â”€ 02-data-architect.md
â”‚   â”‚   â”œâ”€â”€ 03-frontend-engineer.md
â”‚   â”‚   â”œâ”€â”€ 04-qa-security-auditor.md
â”‚   â”‚   â””â”€â”€ 05-technical-writer.md
â”‚   â””â”€â”€ skills/                      # MICHAELINMAP-{migration,rls-policy,rpc,naming,spec-format}
â””â”€â”€ public/
```

---

## 13. Roteiro de Build â€” Fase 1

> SequÃªncia exata de features a implementar. O CLI segue esta ordem.  
> Cada feature sÃ³ comeÃ§a apÃ³s a anterior estar com build OK + lint limpo.

### ðŸ—ï¸ Setup (prÃ©-features)
- [ ] Schema PostgreSQL aplicado (migration via MCP + saneamento `schema_migrations`)
- [ ] RLS habilitado em todas as tabelas
- [ ] Seed inicial (dados de configuraÃ§Ã£o base)
- [ ] Repo GitHub criado: `AdminFeedpro/MICHAELINMAP`
- [ ] Vite + React + TypeScript + Tailwind + shadcn/ui inicializados
- [ ] DependÃªncias instaladas: `@supabase/supabase-js @tanstack/react-table @tanstack/react-query zustand react-router-dom sonner lucide-react`
- [ ] `src/types/index.ts` criado (espelhando todas as tabelas)
- [ ] Guard de autenticaÃ§Ã£o nas rotas (React Router)
- [ ] Layout do dashboard (sidebar + header)
- [ ] `.claude/CLAUDE.md` configurado
- [ ] `init.md` configurado
- [ ] Agentes em `.claude/agents/` + skills em `.claude/skills/`
- [ ] Prompts orquestrador/executor em `docs/prompts/`
- [ ] `docs/MICHAELINMAP_BIBLIA.md` salvo no repo
- [ ] `docs/STATUS.md` criado (vazio)
- [ ] `docs/BACKLOG.md` criado (vazio)

### [ðŸ·ï¸ MÃ“DULO 1 â€” NOME DO MÃ“DULO]

#### F-01 â€” [Nome da feature]
- [ ] [Checklist item 1]
- [ ] [Checklist item 2]
- [ ] Build OK + Lint limpo

#### F-02 â€” [Nome da feature]
- [ ] [Checklist item 1]
- [ ] Build OK + Lint limpo

> Continuar numerando features em sequÃªncia lÃ³gica de dependÃªncia.
> Regra: feature X sÃ³ comeÃ§a se feature X-1 estÃ¡ completa.

---

## 14. Fases Futuras (referÃªncia â€” nÃ£o buildar agora)

### Refino Visual *(apÃ³s o MVP funcional)*
- Aplicar o design system completo (skill `feedback-comunicacao-design`): UI funcional â†’ kit polido, estÃ©tica da marca (tema da seÃ§Ã£o 2), refino de layout/microinteraÃ§Ãµes.
- Derivar o kit do produto `MICHAELINMAP-saas`. A conversa profunda de design rola no inÃ­cio desta fase (telas reais na frente). Funcional-primeiro: sÃ³ depois do nÃºcleo do MVP rodar.

### Fase 2
- [Feature / mÃ³dulo planejado]
- [Feature / mÃ³dulo planejado]

### Fase 3
- [Feature / mÃ³dulo planejado]
- [EvoluÃ§Ã£o para SaaS multi-tenant â€” se aplicÃ¡vel]

---

## 15. DecisÃµes Pendentes

> Itens que precisam de resposta do cliente ou decisÃ£o antes de avanÃ§ar.

- [ ] [DecisÃ£o pendente 1 â€” ex: markups reais por tier]
- [ ] [DecisÃ£o pendente 2 â€” ex: validade padrÃ£o de documentos em dias]
- [ ] [DecisÃ£o pendente 3]

---

## 16. Camada de InteligÃªncia (IA)

> Esta seÃ§Ã£o define COMO a IA participa do produto. ReferÃªncia principal: `docs/DOMAIN_QUESTIONS.md`.
> Se o projeto nÃ£o tem camada de IA, remover esta seÃ§Ã£o.

### 16.1 Resumo da camada

**Tipo de IA no produto:** [query inteligente | agentes | LLM conversacional | alertas | combinaÃ§Ã£o]
**Canais de interaÃ§Ã£o:** [dashboard widgets | chat in-app | WhatsApp/Telegram | alertas push | relatÃ³rios agendados]
**Custo estimado de inferÃªncia (mensal por cliente):** [baixo < R$50 | mÃ©dio R$50-200 | alto > R$200]

### 16.2 Perguntas de DomÃ­nio atendidas pelo MVP

> Listar apenas as perguntas que o MVP responde. ReferÃªncia cruzada com `docs/DOMAIN_QUESTIONS.md`.

| # | Pergunta | Tipo de IA | Interface | Dados necessÃ¡rios |
|---|---|---|---|---|
| DQ-01 | [pergunta] | [query/cÃ¡lculo/LLM/agente] | [widget/chat/alerta] | [tabelas e campos] |
| DQ-02 | [pergunta] | [tipo] | [interface] | [dados] |

### 16.3 Fluxos agÃªnticos

> Descrever cada fluxo onde um agente executa tarefas no lugar do usuÃ¡rio.
> Se o MVP nÃ£o tem fluxos agÃªnticos (apenas queries/cÃ¡lculos), marcar "Fase futura" e listar candidatos.

#### AG-01 â€” [Nome do fluxo agÃªntico]
- **Trigger:** [O que dispara â€” mensagem do usuÃ¡rio, evento do sistema, agendamento]
- **Steps:** [SequÃªncia de aÃ§Ãµes que o agente executa]
- **Output:** [O que o usuÃ¡rio recebe â€” resposta, aÃ§Ã£o executada, relatÃ³rio]
- **Autonomia:** [Executa sozinho | Pede confirmaÃ§Ã£o antes de agir]
- **Fallback:** [O que acontece se a IA nÃ£o tem confianÃ§a â€” escala para humano? mostra incerteza?]
- **Dados acessados:** [Tabelas, APIs, fontes externas]

### 16.4 Limites e governanÃ§a da IA

- **AÃ§Ãµes que a IA NUNCA faz sozinha:** [ex: deletar registros, alterar preÃ§os, enviar comunicaÃ§Ãµes externas]
- **NÃ­vel de confianÃ§a mÃ­nimo para aÃ§Ã£o autÃ´noma:** [ex: 90% para classificaÃ§Ã£o, 95% para aÃ§Ã£o financeira]
- **Logging:** toda interaÃ§Ã£o com a IA Ã© logada em `[tabela_ai_logs]` com: prompt, resposta, confianÃ§a, aÃ§Ã£o tomada
- **LGPD:** dados pessoais nunca sÃ£o enviados para APIs externas sem consentimento. [detalhar tratamento]

### 16.5 Infraestrutura de IA

```
Provider LLM:       [Anthropic Claude | OpenAI | ambos com fallback]
Modelo padrÃ£o:      [claude-sonnet-4-5-20250514 | gpt-4o-mini | outro]
Modelo complexo:    [claude-opus-4-5-20250402 | gpt-4o | outro â€” para tarefas de alta complexidade]
OrquestraÃ§Ã£o:       [Supabase Edge Functions (padrÃ£o) | Make.com | n8n]
Mensageria:         [WhatsApp Business API | Telegram Bot | N/A â€” especificar fase]
MemÃ³ria/Contexto:   [Supabase (tabela ai_context) | Redis | outro]
Limite de tokens:   [budget mensal por cliente | por interaÃ§Ã£o | ilimitado no tier X]
```

---

## 17. Como o CLI deve usar este documento

1. **InÃ­cio de sessÃ£o:** ler `MICHAELINMAP_BIBLIA.md` + `STATUS.md` + `DOMAIN_QUESTIONS.md`
2. **Antes de codar:** verificar qual feature estÃ¡ em andamento no `STATUS.md`
3. **Durante o build:** seguir a sequÃªncia do Roteiro (seÃ§Ã£o 13)
4. **Ao implementar camada de IA:** consultar seÃ§Ã£o 16 + `DOMAIN_QUESTIONS.md`
5. **Ao finalizar uma feature:** atualizar `STATUS.md` (seÃ§Ã£o concluÃ­da + prÃ³xima aÃ§Ã£o)
6. **DÃºvida de regra de negÃ³cio:** consultar seÃ§Ã£o 5 deste arquivo
7. **DÃºvida de schema:** consultar seÃ§Ã£o 7 deste arquivo
8. **DÃºvida sobre IA/agentes do produto:** consultar seÃ§Ã£o 16 deste arquivo
9. **Ao invocar agente de dev:** especificar o arquivo explicitamente (ex: `Use o agente em .claude/agents/02-data-architect.md`)
10. **NUNCA** pular para uma feature de mÃ³dulo posterior sem completar as anteriores

---

## 18. Como o Claude Web/Desktop usa este documento

Edu compartilha o `STATUS.md` atualizado no inÃ­cio de cada conversa no Claude Web/Desktop.
O Claude Web/Desktop usa este arquivo + o STATUS para:
- Entender o estado atual do projeto
- Planejar as prÃ³ximas features (incluindo features de IA â€” seÃ§Ã£o 16)
- Produzir specs, schemas e documentos para o CLI executar
- Resolver dÃºvidas de arquitetura, regras de negÃ³cio e design da camada de IA
