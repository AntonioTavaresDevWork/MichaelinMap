# MICHAELINMAP â€” Mapa de Perguntas de DomÃ­nio

**VersÃ£o:** 1.0 | **Data:** YYYY-MM-DD | **Autor:** Edu Mello
**Status:** Validado no brainstorm | ReferÃªncia para dev + vendas

> Este documento Ã© o **moat do produto**. Cada pergunta abaixo Ã© algo que o gestor
> do segmento-alvo NÃƒO consegue responder hoje â€” e o MICHAELINMAP responde.
> Ã‰ simultaneamente um requisito funcional e uma "bala" de pitch de vendas.
> 
> **Regra:** features existem para responder perguntas, nÃ£o o contrÃ¡rio.
> Se uma feature nÃ£o responde nenhuma pergunta deste mapa, questione se ela deveria existir.

---

## Resumo

**Segmento-alvo:** [ex: HotÃ©is independentes de pequeno/mÃ©dio porte]
**Total de perguntas mapeadas:** [N]
**Perguntas no MVP:** [N]
**Perguntas em fases futuras:** [N]

---

## Perguntas de DomÃ­nio

### DQ-01 â€” [Pergunta em linguagem natural]

> Ex: "Qual o custo por UH ocupada nos Ãºltimos 90 dias incluindo manutenÃ§Ã£o, amenities e energia?"

| Campo                         | Valor                                                                                     |
| ----------------------------- | ----------------------------------------------------------------------------------------- |
| **Categoria**                 | Operacional / Financeiro / Compliance / EstratÃ©gico                                       |
| **Por que nÃ£o responde hoje** | [dados espalhados / nÃ£o coleta / coleta mas nÃ£o cruza / cÃ¡lculo complexo]                 |
| **Dados necessÃ¡rios**         | [tabelas e campos especÃ­ficos do schema]                                                  |
| **Origem dos dados**          | [input manual / sensor-IoT / integraÃ§Ã£o externa / derivado-calculado]                     |
| **Tipo de IA**                | [query-cÃ¡lculo / cruzamento de dados / LLM pontual / agente multi-step / alerta proativo] |
| **Interface de entrega**      | [dashboard widget / chat linguagem natural / WhatsApp / alerta push / relatÃ³rio agendado] |
| **Custo de inferÃªncia**       | Baixo (query) / MÃ©dio (LLM pontual) / Alto (agente multi-step)                            |
| **Impacto**                   | [o que o gestor perde por nÃ£o ter essa resposta â€” custo, risco, tempo, oportunidade]      |
| **Fase**                      | MVP / Fase 2 / Fase 3                                                                     |
| **Feature relacionada**       | F-XX â€” [Nome da feature]                                                                  |

---

### DQ-02 â€” [Pergunta em linguagem natural]

| Campo                         | Valor |
| ----------------------------- | ----- |
| **Categoria**                 |       |
| **Por que nÃ£o responde hoje** |       |
| **Dados necessÃ¡rios**         |       |
| **Origem dos dados**          |       |
| **Tipo de IA**                |       |
| **Interface de entrega**      |       |
| **Custo de inferÃªncia**       |       |
| **Impacto**                   |       |
| **Fase**                      |       |
| **Feature relacionada**       |       |

---

> Repetir para cada pergunta. MÃ­nimo 5 para o MVP. Sem limite mÃ¡ximo.
> Ordenar por prioridade de implementaÃ§Ã£o (MVP primeiro, depois fases futuras).

---

## Matriz de PriorizaÃ§Ã£o (MVP)

| #     | Pergunta (resumo) | Impacto          | Complexidade     | Custo IA         | Prioridade |
| ----- | ----------------- | ---------------- | ---------------- | ---------------- | ---------- |
| DQ-01 | [resumo]          | Alto/MÃ©dio/Baixo | Alto/MÃ©dio/Baixo | Alto/MÃ©dio/Baixo | 1          |
| DQ-02 | [resumo]          |                  |                  |                  | 2          |

> **CritÃ©rio de priorizaÃ§Ã£o:** Impacto alto + Complexidade baixa + Custo IA baixo = prioridade mÃ¡xima.
> A primeira pergunta implementada deve ser a "prova de valor em 30 segundos" â€” a que faz
> o prospect dizer "isso eu preciso" na primeira demonstraÃ§Ã£o.

---

## Perguntas candidatas (fases futuras)

> Perguntas identificadas no brainstorm que nÃ£o entram no MVP mas tÃªm potencial.
> Manter aqui para referÃªncia â€” podem subir de prioridade conforme feedback de clientes.

| #     | Pergunta   | Categoria   | Fase   | Motivo de nÃ£o entrar no MVP                                          |
| ----- | ---------- | ----------- | ------ | -------------------------------------------------------------------- |
| DQ-XX | [pergunta] | [categoria] | Fase 2 | [falta integraÃ§Ã£o / complexidade alta / dados nÃ£o disponÃ­veis ainda] |

---

## Como usar este documento

**No dev (CLI):** consultar ao implementar features de IA. Cada DQ-XX Ã© rastreada no STATUS.md.
**No pitch (vendas):** cada pergunta DQ Ã© uma "bala". Pergunte ao prospect: "VocÃª consegue
me responder isso agora?" â€” se nÃ£o consegue, o produto se vende sozinho.
**Na evoluÃ§Ã£o do produto:** novas perguntas descobertas com clientes entram aqui como candidatas.
Este Ã© um documento vivo â€” cresce com o produto.
