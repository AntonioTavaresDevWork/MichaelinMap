# Michaelin Map — Init

## Checklist de boot

> Lido como parte do boot acionado por `/orquestrador` (ou `/executor`).
> Não é o `/init` embutido do Claude Code.

Execute nesta ordem:

1. `.claude/CLAUDE.md` — regras, stack, convenções e idioma
2. `docs/MICHAELINMAP_BIBLIA.md` — domínio, modelo de julgamento, schema, RNs, ADRs, escopo
3. `docs/STATUS.md` — estado atual, próxima ação, log de sessões
4. `docs/BACKLOG.md` — pendências, cortes de escopo, decisões abertas
5. `src/types/index.ts` — tipos (a partir da F-00)
6. Estado do banco via MCP (`list_tables`, `list_migrations`) — a Bíblia descreve o alvo, o MCP mostra o real

Depois de ler, responda com:

- **Fase atual** e feature em foco
- **Estado do banco** (tabelas e migrations vivas) e divergência em relação à Bíblia, se houver
- **Próxima ação** exata conforme o STATUS
- **Blockers** e itens do BACKLOG que tocam a feature em foco

## Regra de ouro

Nunca comece a codar sem confirmar a próxima ação com o Edu.
Se houver divergência entre o STATUS e o estado real do código ou do banco, reporte **antes** de agir.

## Antes de propor algo que não está no escopo

Consulte os ADRs (Bíblia §15) e a seção "Fora do MVP" do BACKLOG. Vários caminhos já foram
avaliados e cortados com motivo — Google Places, My Maps sync, SEO, Trip Builder, multi-tenant.
Não repropor sem fato novo.

## Ao final de cada sessão

Atualizar `docs/STATUS.md`: data, o que foi feito, decisões, nova próxima ação, hash do último commit.
Pendência nova vai para `docs/BACKLOG.md` — nunca espalhar pendência pelo STATUS.
