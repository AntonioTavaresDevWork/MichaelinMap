---

## HIERARQUIA DOS ELEMENTOS

### Princípio fundamental
A interface deve permitir que o operador identifique em menos de 2 segundos: (1) o estado atual da entidade, (2) o valor ou identificador crítico, (3) a próxima ação necessária. Toda decisão de posicionamento obedece a esta sequência de escaneabilidade.

---

### Estrutura de colunas por tipo de tela

#### Tela de visualização (detalhe de entidade)
A coluna esquerda (33%) concentra informações de contexto, governança e decisão. A coluna direita (67%) concentra dados operacionais, tabelas e ações executivas.

| Coluna esquerda (33%) | Coluna direita (67%) |
|---|---|
| Resumo compacto com KPIs | Tabelas de itens, registros, histórico |
| Status de aprovação, fluxo, decisões | Dados operacionais, quantidades, valores |
| Timeline de eventos, metadados de controle | Análises comparativas, gráficos, empty states |
| Informações de auditoria, responsáveis | Ações em massa, botões de execução |

Regra de implementação: a coluna esquerda deve ser `position: sticky` com `top: 80px` (abaixo do header fixo) para que o operador mantenha contexto enquanto rola a coluna direita.

#### Tela de edição (formulário)
A coluna esquerda (33%) concentra preview de estado, resumo da entidade e simulação de fluxo. A coluna direita (67%) concentra todos os campos editáveis, seções de configuração e controles de governança.

| Coluna esquerda (33%) | Coluna direita (67%) |
|---|---|
| Resumo readonly da entidade (mini KPIs) | Seções de formulário em cards independentes |
| Preview de fluxo de aprovação (atualizado em tempo real) | Campos de identificação, orçamento, vigência |
| Status atual, datas, responsáveis | Toggles de governança, configurações de controle |
| Valores acumulados, saldos, metas | Observações, notas, campos de texto livre |

Regra de implementação: max-width do conteúdo deve ser 960px (60rem) para formulários longos, preservando legibilidade de labels e inputs. Telas de visualização usam max-width 1440px.

#### Tela de listagem (tabela)
Não usa colunas. Layout vertical: toolbar unificada, chips de filtros ativos, tabela premium, paginação ou load more.

| Seção | Posição | Conteúdo |
|---|---|---|
| Toolbar | Topo, sticky | Busca, filtros dropdown, botão de ação primária, configurações de coluna |
| Chips de filtros | Abaixo da toolbar | Pills removíveis indicando filtros ativos |
| Tabela | Corpo principal | Header sortable, linhas com hover/selected/ações inline |
| Paginação | Rodapé da tabela | Load more ou numeração com contador de registros |

---

### Hierarquia dentro de cards

#### Card de resumo (compacto, 20px padding)
Usado para KPIs, dados de cabeçalho, informações de contexto. Densidade alta, pouco respiro.

```
[Header opcional: título + ícone + ação]
─────────────────────────────────────
Label          │ Valor
(caption,      │ (body, 500, mono
secondary)     │  se numérico)
─────────────────────────────────────
Label          │ Valor
[Progress bar opcional, full width]
```

Regras:
- Labels em 11px/500, uppercase, cor secundária, margin-bottom 4px
- Valores em 14px/500, cor primária, fonte mono para numéricos
- Progress bar: 4px height, full width, margin-top 12px
- Separador horizontal opcional entre grupos: 1px, cor de borda

#### Card de tabela (flush, 0 padding)
Usado para listagens dentro de cards. Header e rows com padding próprio.

```
[Header: título (h3) + badge de contagem + ação]
─────────────────────────────────────
│ COL1 │ COL2 │ COL3 │ COL4 │ AÇÕES │  ← header
├──────┼──────┼──────┼──────┼───────┤
│ dado │ dado │  —   │ dado │ 👁 ✏ ✓ ✕│  ← row
│ dado │ dado │  —   │ dado │ 👁 ✏ ✓ ✕│  ← row
```

Regras:
- Header: 11px/500, uppercase, tracking 0.05em, cor secundária, padding 12px 16px
- Row: padding 12px 16px, altura mínima 48px, hover com transição 150ms
- Células vazias: "—" em cor terciária, itálico, 12px
- Valores monetários: fonte mono, alinhados à direita
- Códigos: fonte mono, alinhados à esquerda
- Ações: 4 ícones máximo, 16px, gap 4px, botão ghost

#### Card de aprovações (default, 24px padding)
Usado para fluxos de decisão, status de aprovação, justificativas.

```
[Header: título (h3) + contagem]
─────────────────────────────────────
┌─────────────────────────────────┐
│▓ Nome do aprovador — Status     │  ← border-left 3px
│  metadata (data, perfil)          │     cor do status
│  [justificativa se rejeitado]    │     background 5%
└─────────────────────────────────┘
┌─────────────────────────────────┐
│▓ Nome do aprovador — Status     │
│  metadata                        │
└─────────────────────────────────┘
```

Regras:
- Sub-cards internos com border-left 3px na cor do status
- Background do sub-card: cor do status com 5% opacidade
- Ícone de status 20px (check, x, clock) à esquerda do título
- Justificativa de rejeição: 13px/400, itálico, cor do status com 80% opacidade
- Metadata: 12px/400, cor secundária

#### Card de formulário (compact/default, 20-24px padding)
Usado para seções de edição. Header com título e ícone de seção.

```
[Header: título (h3) + ícone 16px]
─────────────────────────────────────
Label*                             │
[Input                           ] │
                                   │
Label*         │ Label            │
[Input      ]  │ [Input          ] │
                                   │
[Helper text com ícone de info]    │
```

Regras:
- Label: 12px/500, cor secundária, margin-bottom 6px
- Obrigatório: asterisco em âmbar (#F59E0B), 12px, após o label
- Input: 14px/400, cor primária, padding 10px 12px
- Focus: ring 2px na cor de acento com 20% opacidade
- Helper: ícone info 14px + texto 12px/400, cor terciária, margin-top 8px
- Grid interno: 2 colunas para campos relacionados, 1 coluna full-width para campos principais

#### Card de empty state (default, 24px padding)
Usado quando não há dados para exibir. Deve sempre oferecer próximo passo.

```
         [Ícone 32px, cor terciária]

    "Título do estado vazio" (h3)

"Descrição explicando por que está vazio
 e o que fazer para preencher." (body,
 cor secundária, max-width 400px)

         [Botão de ação primária]
```

Regras:
- Ícone: 32px, stroke 1.5, cor terciária, centralizado
- Título: 14px/600, cor primária, margin-top 16px, centralizado
- Descrição: 14px/400, cor secundária, margin-top 8px, centralizado, max-width 400px
- CTA: margin-top 24px, centralizado, botão primário ou terciário
- Nunca usar ícone genérico de sistema (documento, caixa) sem contexto

#### Card de timeline (default, 24px padding)
Usado para histórico de eventos, auditoria, log de ações.

```
[Header: título (h3)]
─────────────────────────────────────
  ● Evento 1
  │ "Criado em 01/01/2026"
  │ "por Usuário Responsável"
  │
  ● Evento 2
  │ "Última atualização"
  │
  ○ Evento futuro/pendente
    "Etapa iniciará em 01/02/2026"
```

Regras:
- Linha vertical: 1px, cor de borda, posicionada à esquerda dos pontos
- Pontos completados: 8px, cor de acento
- Pontos pendentes/futuros: 8px, cor terciária
- Título do evento: 14px/500, cor primária
- Data: 12px/400, cor secundária, acima do título
- Descrição: 12px/400, cor terciária, abaixo do título
- Gap entre eventos: 16px

---

### Posicionamento de elementos de governança

#### Toggles de controle
Toggles que alteram fluxo de aprovação, visibilidade ou comportamento do sistema devem ser tratados como elementos de governança, não como simples inputs.

```
┌─────────────────────────────────────┐
│▓ Label do toggle          [ON/OFF]  │  ← border-left 3px quando ON
│  ⓘ (tooltip explicativo)            │
└─────────────────────────────────────┘
```

Regras:
- Card interno próprio: background surface-0, border 1px, padding 16px
- Border-left 3px na cor do contexto quando ativo (azul para aprovação, âmbar para exceção, verde para status)
- Label: 14px/600, cor primária
- Ícone info 14px com tooltip contendo explicação completa (nunca texto expandido abaixo do toggle)
- Toggle customizado: track arredondado, thumb com sombra, transição 200ms
- Cor do track quando ON: cor do contexto. Quando OFF: cor de borda
- Preview de consequência: na coluna lateral (em telas de edição), mostrar como o fluxo muda quando toggle é alterado

#### Badges de status
Sempre posicionados ao lado do título da entidade, nunca abaixo. Nunca contêm ícones internos.

```
Título da Entidade          [STATUS]
(24px/700)                  (pill, 11px/500,
                            uppercase, tracking 0.02em)
```

Regras:
- Forma: pill (radius 9999px)
- Padding: 4px 10px
- Fonte: 11px/500, uppercase, tracking 0.02em
- Background: cor do status com 10% opacidade
- Border: 1px solid cor do status com 20% opacidade
- Texto: cor do status com 100% opacidade
- Posição: margin-left 12px do título, alinhado verticalmente ao centro

#### Barra de ações
Sempre visível, nunca escondida em menu. Em formulários longos: fixed bottom com backdrop blur. Em formulários curtos: inline após último card.

```
[Formulário longo — fixed bottom]
┌─────────────────────────────────────────────────────────────────┐
│ [Última alteração: há X minutos]      [Cancelar] [Salvar]      │
│ (12px, cor secundária)                (secundário) (primário)   │
└─────────────────────────────────────────────────────────────────┘
```

Regras:
- Altura: 64px
- Background: cor de surface com 90% opacidade + backdrop blur 12px
- Border-top: 1px, cor de borda
- Z-index: 50 (acima de todo conteúdo, abaixo de modais)
- Botão primário (Salvar) sempre à direita, com ícone Save
- Botão secundário (Cancelar) sempre à esquerda do primário
- Feedback de estado: "Salvando..." (spinner), "Salvo" (check), "Erro" (alert)
- Em mobile (< 768px): botões empilhados, primário acima, full-width

---

### Posicionamento de metadados e dados secundários

Metadados (datas, autores, versões, IDs técnicos) devem ser visualmente subordinados ao conteúdo principal. Nunca competir com dados operacionais.

```
[Conteúdo principal]
Título da Entidade (20px/700, cor primária)

[Metadados — abaixo ou à direita, nunca misturados]
Criado em 01/01/2026 por Usuário (12px/400, cor secundária)
Última atualização: 01/02/2026 (12px/400, cor secundária)
ID técnico: ENT-2026-0001 (12px/400, cor terciária, mono)
```

Regras:
- Sempre em fonte menor (12px) e cor secundária ou terciária
- Nunca mesma fonte, tamanho ou peso que o conteúdo principal
- IDs técnicos: fonte mono, cor terciária
- Datas: formato localizado, cor secundária
- Agrupados visualmente (margin-top 16px do conteúdo, separador opcional)
- Em cards de resumo: alinhados em grid de 2 colunas, label acima do valor

---

### Posicionamento de filtros e busca

#### Toolbar unificada
Todos os controles de filtragem devem estar em uma única barra, visualmente integrada.

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 [Buscar por...          ] [Status ▼] [Período ▼] [Buscar] ⚙ │
│   (input 240px)             (filtros 160px)        (primário)  │
└─────────────────────────────────────────────────────────────────┘
```

Regras:
- Input de busca: com ícone de lupa integrado, placeholder descritivo, 240px
- Filtros: estilo botão terciário/ghost, com chevron, 160px cada
- Botão buscar: primário, pequeno, à direita dos filtros
- Configurações de coluna: ícone ghost, à extrema direita
- Background: card compacto (padding 16px), mesma cor de surface
- Chips de filtros ativos: abaixo da toolbar, pills removíveis, gap 8px

---

## DO'S E DON'TS

### Layout e estrutura

| ✅ DO | ❌ DON'T |
|---|---|
| Usar colunas 33/67 para telas de detalhe e edição | Empilhar todos os elementos em coluna única monolítica |
| Manter coluna de contexto (esquerda) sticky em 80px do topo | Deixar coluna de contexto rolar com o conteúdo |
| Limitar formulários a max-width 960px | Usar largura total do viewport para formulários |
| Usar max-width 1440px para telas de visualização | Limitar visualizações densas a 960px |
| Separar seções de formulário em cards independentes | Agrupar todos os campos em um único card vertical |
| Usar grid interno de 2 colunas para campos relacionados | Quebrar grid sem lógica de proporção ou prioridade |

### Cards e superfícies

| ✅ DO | ❌ DON'T |
|---|---|
| Variar padding entre cards compactos (20px) e default (24px) | Usar mesmo padding para todos os cards |
| Usar cards flush (0 padding) para tabelas dentro de cards | Adicionar padding extra em tabelas aninhadas |
| Aplicar border-left 3px em sub-cards de aprovação/toggle | Usar background colorido completo para destacar estado |
| Manter background de cards em surface-1, body em surface-0 | Usar branco puro (#FFFFFF) ou preto puro (#000000) |
| Usar separadores de 1px entre seções dentro de cards | Deixar seções sem separação visual |

### Tipografia

| ✅ DO | ❌ DON'T |
|---|---|
| Usar fonte mono para códigos, valores monetários, IDs | Usar fonte sans-serif para todos os dados numéricos |
| Alinhar valores monetários à direita | Alinhar valores monetários à esquerda |
| Usar 11px/500 uppercase tracking 0.02em para badges | Usar 14px/400 sentence case para badges |
| Usar 12px/400 cor secundária para metadados | Usar 14px/500 cor primária para metadados |
| Usar 12px/500 cor secundária para labels de campo | Usar 14px/400 cor primária para labels de campo |
| Usar "—" em cor terciária itálico para campos vazios | Deixar campos vazios em branco ou com traço genérico |
| Aplicar tracking -0.01em em headings grandes | Usar tracking padrão em headings display |

### Cores e contraste

| ✅ DO | ❌ DON'T |
|---|---|
| Usar âmbar (#F59E0B) para indicar obrigatório (*) | Usar vermelho de erro (#EF4444) para indicar obrigatório |
| Usar vermelho tomate (#EF4444) para erros e rejeições | Usar vermelho puro (#FF0000) ou rosa choque |
| Usar verde esmeralda (#10B981) para sucesso e ativo | Usar verde neon ou verde saturado genérico |
| Usar azul elegante (#3B82F6) para ações e foco | Usar azul royal (#0000FF) ou azul saturado |
| Aplicar opacidade reduzida (10% bg, 20% border) para badges | Usar badges com background sólido saturado |
| Usar cor terciária (#5A5F70) para placeholders e desabilitados | Usar cor secundária para elementos inativos |

### Status e badges

| ✅ DO | ❌ DON'T |
|---|---|
| Posicionar badge ao lado do título, alinhado verticalmente | Posicionar badge abaixo do título |
| Usar badges sem ícones internos (apenas texto) | Adicionar ícones dentro de badges |
| Usar forma pill (radius 9999px) para badges | Usar retângulos ou formas irregulares para badges |
| Aplicar uppercase e tracking em badges de status | Usar sentence case ou lowercase em badges |

### Tabelas

| ✅ DO | ❌ DON'T |
|---|---|
| Usar header em 11px/500 uppercase tracking 0.05em | Usar header em 14px/400 sentence case |
| Aplicar hover em rows com transição 150ms | Mudar cor de row instantaneamente ou sem transição |
| Destacar row selecionada com border-left 3px + bg 5% | Usar background colorido completo para seleção |
| Limitar ações inline a 4 ícones máximo | Adicionar 5+ ícones de ação por row |
| Usar ícones 16px em botão ghost para ações | Usar ícones 24px ou botões sólidos para ações inline |
| Mostrar tooltip em hover de ícone de ação | Deixar ícones de ação sem identificação |

### Inputs e formulários

| ✅ DO | ❌ DON'T |
|---|---|
| Usar prefixo monetário fixo ("R$") como adorno à esquerda | Incluir "R$" como parte do valor editável |
| Aplicar ring 2px na cor de acento com 20% opacidade no focus | Usar border grossa ou glow exagerado no focus |
| Usar placeholder em cor terciária itálico | Usar placeholder em cor primária ou sem itálico |
| Adicionar ícone de calendário à direita em date pickers | Deixar date pickers sem indicador visual |
| Usar contador de caracteres (0/2000) abaixo de textareas | Deixar textareas sem limite visual |
| Validar inline em tempo real (erro, aviso, sucesso) | Validar apenas no submit do formulário |

### Toggles

| ✅ DO | ❌ DON'T |
|---|---|
| Usar toggle customizado com cor por estado | Usar toggle HTML nativo sem customização |
| Aplicar border-left 3px na cor do contexto quando ON | Deixar toggle ON com mesma aparência de OFF |
| Usar ícone info 14px com tooltip para explicação | Expandir texto explicativo abaixo de cada toggle |
| Atualizar preview de fluxo na coluna lateral em tempo real | Deixar consequência do toggle invisível até salvar |
| Usar track na cor do contexto (azul, âmbar, verde) quando ON | Usar cinza genérico para todos os estados ON |

### Empty states

| ✅ DO | ❌ DON'T |
|---|---|
| Sempre incluir ícone, título, descrição e CTA | Deixar empty state como texto plano sem estrutura |
| Usar ícones lineares 32px em cor terciária | Usar ícones filled genéricos de sistema |
| Oferecer próximo passo claro (botão primário ou link) | Deixar empty state sem ação possível |
| Centralizar conteúdo vertical e horizontalmente | Alinhar empty state ao topo ou à esquerda |

### Ações e botões

| ✅ DO | ❌ DON'T |
|---|---|
| Posicionar ação primária (Salvar) à direita, secundária (Cancelar) à esquerda | Inverter ordem ou esconder ação secundária |
| Usar botão primário com cor de acento para Salvar | Usar botão preto/cinza como primário |
| Incluir ícone Save no botão Salvar | Deixar botão Salvar sem ícone |
| Usar barra de ações fixed com backdrop blur em formulários longos | Deixar botões apenas no final de formulários longos |
| Mostrar feedback de estado no botão (Salvando..., Salvo, Erro) | Deixar botão sem feedback durante operação |

### Metadados

| ✅ DO | ❌ DON'T |
|---|---|
| Agrupar metadados visualmente abaixo do conteúdo principal | Misturar metadados com dados operacionais |
| Usar fonte menor (12px) e cor secundária/terciária | Usar mesma fonte, tamanho e cor que conteúdo principal |
| Usar fonte mono para IDs técnicos | Usar fonte sans-serif para IDs e códigos |
| Incluir separador opcional entre conteúdo e metadados | Deixar metadados grudados no conteúdo sem espaçamento |

### Animação e interação

| ✅ DO | ❌ DON'T |
|---|---|
| Usar transição 150ms em propriedades de cor | Usar transição em transform, scale ou position |
| Aplicar hover sutil em cards (elevação ou border) | Usar hover agressivo com scale ou glow |
| Usar focus-visible ring para acessibilidade | Esconder focus ou usar outline padrão do navegador |
| Manter animações funcionais e discretas | Usar bounce, pulse, shake ou animações decorativas |

### Responsividade

| ✅ DO | ❌ DON'T |
|---|---|
| Colapsar sidebar para 72px (ícones apenas) em < 1024px | Esconder sidebar completamente em tablet |
| Empilhar colunas em coluna única em < 1280px | Manter colunas lado a lado em telas pequenas |
| Reduzir padding para 16px em < 768px | Manter padding 32px em mobile |
| Transformar ações inline em menu dropdown em < 480px | Manter 4 ícones de ação por row em mobile |
| Usar botões full-width empilhados em mobile | Manter botões lado a lado em mobile |
