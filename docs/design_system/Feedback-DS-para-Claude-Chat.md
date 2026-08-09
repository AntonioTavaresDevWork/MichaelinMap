# Design System Feedback — brief para gerar HTML estático

> **Como usar:** anexe (ou cole) este arquivo inteiro no Claude Web/Chat e diga:
> *"Gere um HTML estático usando ESTE design system. Cole o CSS abaixo dentro de `<style>` e siga as regras. Não invente cores nem fontes fora daqui."*
> Tudo é auto-contido: as fontes vêm por `@import` do Google Fonts dentro do próprio CSS.

---

## Regras inegociáveis (o Claude deve seguir à risca)

1. **Dark-first.** O tema padrão é escuro (o `:root` já é dark). Light só se pedido, via `<html data-theme="light">`.
2. **Accent único = lime `#ACDE40`.** Usado em CTA, destaque, número protagonista, estado ativo. Nunca troque por outro verde. **Success é `#34C759`** (verde distinto — não confundir com o accent).
3. **Anti-slop = anti-gratuito.** Sem gradiente decorativo, sem sombra exagerada, sem emoji como ícone. Ícones = **lucide** (`<script src="https://unpkg.com/lucide@latest"></script>` + `<i data-lucide="nome"></i>` + `lucide.createIcons()`).
4. **Glass só em superfície flutuante** (modal, command palette ⌘K, dropdown, popover, header ao rolar). **Conteúdo — card, tabela, KPI, stat — é sempre SÓLIDO.** Receita de glass no fim.
5. **Neutros = ink** (família `#29323B`), nunca cinza morto genérico. Superfícies em camadas: `--bg-0` (fundo) → `--bg-1` (card) → `--bg-2` (input/card sobre card).
6. **Tipografia Inter** em tudo; **Comfortaa só no logo**. Números grandes como protagonistas (`.fb-stat`).
7. **Formato BR:** `1.000,00` (ponto milhar, vírgula decimal) · `DD/MM/YYYY` · `R$` com 2 casas.
8. **Voz PT-BR:** direta, consultiva, sem floreio. Nunca ALL CAPS. Title case só em headings/botões curtos.

---

## CSS — cole isto dentro de `<style>` (é o design system inteiro)

```css
/* =============================================================
   Feedback Comunicação — Design Tokens (dark-first)
   ============================================================= */
@import url('https://fonts.googleapis.com/css2?family=Comfortaa:wght@400;500;600;700&family=Inter:wght@400;500;600;700;800&display=swap');

:root {
  /* Brand lime (oficial = 400) */
  --fb-lime-50:#F5FBEA; --fb-lime-100:#E8F6CB; --fb-lime-200:#D5EEA0; --fb-lime-300:#C0E670;
  --fb-lime-400:#ACDE40; /* ⭐ OFFICIAL BRAND LIME */
  --fb-lime-500:#93C22E; --fb-lime-600:#79A423; --fb-lime-700:#5C8118; --fb-lime-800:#425E12; --fb-lime-900:#293B0C;

  /* Ink (neutros escuros) — ink-3 = wordmark oficial #29323B */
  --fb-ink-0:#0F141B; --fb-ink-1:#1A222B; --fb-ink-2:#222B36; --fb-ink-3:#29323B; --fb-ink-4:#3C4856; --fb-ink-5:#55637A;
  /* Snow (neutros claros) */
  --fb-snow-0:#FFFFFF; --fb-snow-1:#FAFBFC; --fb-snow-2:#F1F3F5; --fb-snow-3:#E4E7EB; --fb-snow-4:#C8CED6; --fb-snow-5:#9AA3B0;
  /* Foreground */
  --fb-fg-dark-1:#F4F6F8; --fb-fg-dark-2:#A5AEBC; --fb-fg-dark-3:#6B7588;
  --fb-fg-light-1:#0A0E14; --fb-fg-light-2:#3D4757; --fb-fg-light-3:#6B7588;
  /* Status */
  --fb-success:#34C759; --fb-warning:#F5A524; --fb-danger:#E5484D; --fb-info:#4C9AFF;
  /* Chart series (Power BI / dashboards) */
  --fb-chart-1:#ACDE40; --fb-chart-2:#4C9AFF; --fb-chart-3:#F5A524; --fb-chart-4:#E5484D; --fb-chart-5:#9B8AFB; --fb-chart-6:#26C6DA;

  /* Semantic (default = DARK) */
  --bg-0:var(--fb-ink-0); --bg-1:var(--fb-ink-1); --bg-2:var(--fb-ink-2);
  --fg-1:var(--fb-fg-dark-1); --fg-2:var(--fb-fg-dark-2); --fg-3:var(--fb-fg-dark-3);
  --border-1:var(--fb-ink-3); --border-2:var(--fb-ink-4);
  --accent:var(--fb-lime-400); --accent-hi:var(--fb-lime-300); --accent-lo:var(--fb-lime-500); --accent-ink:var(--fb-ink-0);
  --link:var(--fb-lime-400); --link-hover:var(--fb-lime-300);

  /* Type */
  --font-display:'Inter',system-ui,-apple-system,sans-serif;
  --font-body:'Inter',system-ui,-apple-system,sans-serif;
  --font-logo:'Comfortaa','Inter',system-ui,sans-serif;
  --font-mono:ui-monospace,SFMono-Regular,'SF Mono',Menlo,monospace;
  --fs-display:64px; --lh-display:72px; --fs-h1:48px; --lh-h1:56px; --fs-h2:36px; --lh-h2:44px;
  --fs-h3:24px; --lh-h3:32px; --fs-h4:18px; --lh-h4:28px; --fs-body-lg:18px; --lh-body-lg:28px;
  --fs-body:16px; --lh-body:24px; --fs-body-sm:14px; --lh-body-sm:20px; --fs-caption:12px; --lh-caption:16px;
  --fw-regular:400; --fw-medium:500; --fw-semi:600; --fw-bold:700; --fw-black:800;
  --tracking-tight:-0.02em; --tracking-snug:-0.01em; --tracking-wide:0.04em;

  /* Spacing (4px grid) */
  --space-1:2px; --space-2:4px; --space-3:8px; --space-4:12px; --space-5:16px; --space-6:24px;
  --space-7:32px; --space-8:48px; --space-9:64px; --space-10:96px; --space-11:128px;
  /* Radii */
  --radius-sm:4px; --radius-md:8px; --radius-lg:12px; --radius-xl:16px; --radius-2xl:24px; --radius-pill:999px;
  /* Shadows */
  --shadow-popover:0 12px 32px rgba(0,0,0,.4), 0 2px 8px rgba(0,0,0,.3);
  --shadow-hero:0 40px 80px rgba(0,0,0,.5), 0 0 0 1px rgba(255,255,255,.04);
  --shadow-focus:0 0 0 2px var(--fb-lime-400), 0 0 0 4px rgba(172,222,64,.25);
  --shadow-glass:inset 0 1px 0 rgba(255,255,255,.12), 0 24px 60px -20px rgba(0,0,0,.75);
  /* Motion + layout */
  --ease-out:cubic-bezier(.16,1,.3,1); --dur-fast:120ms; --dur-base:200ms;
  --container-max:1200px; --header-h:72px;
}

[data-theme="light"] {
  --bg-0:var(--fb-snow-1); --bg-1:var(--fb-snow-0); --bg-2:var(--fb-snow-2);
  --fg-1:var(--fb-fg-light-1); --fg-2:var(--fb-fg-light-2); --fg-3:var(--fb-fg-light-3);
  --border-1:var(--fb-snow-3); --border-2:var(--fb-snow-4);
  --accent-ink:var(--fb-ink-0); --link:var(--fb-lime-700); --link-hover:var(--fb-lime-800);
}

/* ---- Base ---- */
* { box-sizing:border-box; }
body { margin:0; font-family:var(--font-body); font-size:var(--fs-body); line-height:var(--lh-body);
  color:var(--fg-1); background:var(--bg-0); -webkit-font-smoothing:antialiased; }

/* ---- Type helpers ---- */
.fb-display{font-family:var(--font-display);font-size:var(--fs-display);line-height:var(--lh-display);font-weight:var(--fw-black);letter-spacing:var(--tracking-tight);color:var(--fg-1);}
.fb-h1{font-family:var(--font-display);font-size:var(--fs-h1);line-height:var(--lh-h1);font-weight:var(--fw-bold);letter-spacing:var(--tracking-snug);color:var(--fg-1);}
.fb-h2{font-family:var(--font-display);font-size:var(--fs-h2);line-height:var(--lh-h2);font-weight:var(--fw-bold);letter-spacing:var(--tracking-snug);color:var(--fg-1);}
.fb-h3{font-family:var(--font-display);font-size:var(--fs-h3);line-height:var(--lh-h3);font-weight:var(--fw-semi);color:var(--fg-1);}
.fb-h4{font-family:var(--font-display);font-size:var(--fs-h4);line-height:var(--lh-h4);font-weight:var(--fw-semi);color:var(--fg-1);}
.fb-body-lg{font-size:var(--fs-body-lg);line-height:var(--lh-body-lg);color:var(--fg-2);}
.fb-body-sm{font-size:var(--fs-body-sm);line-height:var(--lh-body-sm);color:var(--fg-2);}
.fb-caption{font-size:var(--fs-caption);line-height:var(--lh-caption);color:var(--fg-3);}
.fb-eyebrow{font-size:var(--fs-caption);font-weight:var(--fw-semi);letter-spacing:var(--tracking-wide);text-transform:uppercase;color:var(--accent);}
.fb-mono{font-family:var(--font-mono);font-size:var(--fs-body-sm);}
.fb-stat{font-family:var(--font-display);font-size:72px;line-height:1;font-weight:var(--fw-black);letter-spacing:var(--tracking-tight);color:var(--accent);}
.fb-logo{font-family:var(--font-logo);font-weight:var(--fw-bold);}

/* ---- Elements ---- */
.fb-btn{display:inline-flex;align-items:center;gap:8px;height:44px;padding:0 20px;border-radius:var(--radius-md);font-family:var(--font-body);font-size:var(--fs-body);font-weight:var(--fw-semi);cursor:pointer;border:none;text-decoration:none;white-space:nowrap;transition:transform var(--dur-fast) var(--ease-out),filter var(--dur-fast) var(--ease-out);}
.fb-btn:focus-visible{outline:none;box-shadow:var(--shadow-focus);}
.fb-btn:active{transform:scale(.98);filter:brightness(.92);}
.fb-btn--primary{background:var(--accent);color:var(--accent-ink);}
.fb-btn--primary:hover{filter:brightness(1.08);transform:translateY(-1px);}
.fb-btn--ghost{background:transparent;color:var(--fg-1);border:1px solid var(--border-1);}
.fb-btn--ghost:hover{border-color:var(--border-2);background:var(--bg-1);}
.fb-btn--link{background:transparent;color:var(--fg-1);height:auto;padding:0;}
.fb-btn--link:hover{color:var(--accent);}
.fb-card{background:var(--bg-1);border:1px solid var(--border-1);border-radius:var(--radius-lg);padding:var(--space-6);transition:border-color var(--dur-base) var(--ease-out);}
.fb-card:hover{border-color:var(--border-2);}
.fb-input{height:44px;width:100%;padding:0 14px;background:var(--bg-2);border:1px solid var(--border-1);border-radius:var(--radius-md);color:var(--fg-1);font-family:var(--font-body);font-size:var(--fs-body);transition:border-color var(--dur-fast) var(--ease-out),box-shadow var(--dur-fast) var(--ease-out);}
.fb-input::placeholder{color:var(--fg-3);}
.fb-input:focus{outline:none;border-color:var(--accent);box-shadow:var(--shadow-focus);}
.fb-badge{display:inline-flex;align-items:center;gap:6px;height:24px;padding:0 10px;border-radius:var(--radius-pill);background:rgba(172,222,64,.12);color:var(--accent);font-size:var(--fs-caption);font-weight:var(--fw-semi);letter-spacing:var(--tracking-wide);text-transform:uppercase;}

/* ---- GLASS — SÓ para superfície flutuante (modal, ⌘K, dropdown, header fixo) ---- */
.fb-glass{
  background:rgba(26,33,44,.70);
  -webkit-backdrop-filter:blur(18px) saturate(1.25); backdrop-filter:blur(18px) saturate(1.25);
  border:1px solid rgba(255,255,255,.11); border-radius:var(--radius-xl);
  box-shadow:var(--shadow-glass);
}
```

---

## Cheatsheet — que classe usar

| Precisa de… | Use |
|---|---|
| Título hero / número gigante | `.fb-display` · `.fb-stat` |
| Headings | `.fb-h1` … `.fb-h4` |
| Rótulo pequeno acima de título | `.fb-eyebrow` |
| Card de conteúdo (sólido) | `.fb-card` |
| Botão CTA | `.fb-btn fb-btn--primary` |
| Botão secundário | `.fb-btn fb-btn--ghost` |
| Campo de texto | `.fb-input` |
| Tag/pill de status | `.fb-badge` |
| Modal / command palette / dropdown | `.fb-glass` (+ conteúdo interno sólido) |
| Cor de série de gráfico | `var(--fb-chart-1..6)` |

**Cores diretas quando precisar:** accent `var(--accent)` · texto `var(--fg-1/2/3)` · superfície `var(--bg-0/1/2)` · borda `var(--border-1)` · sucesso `var(--fb-success)` · erro `var(--fb-danger)`.

---

## Esqueleto HTML mínimo (o Claude pode partir daqui)

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Feedback</title>
  <style>/* … COLE O CSS DO DESIGN SYSTEM AQUI … */</style>
  <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body>
  <!-- conteúdo: use .fb-card, .fb-h1, .fb-stat, .fb-btn … -->
  <script>lucide.createIcons();</script>
</body>
</html>
```

---

## DO / DON'T (resumo pra colar junto)

**DO:** dark-first · accent lime só em destaque · números grandes · cards sólidos em camadas de ink · ícones lucide · glass só em superfície flutuante · formato BR · Inter.

**DON'T:** gradiente decorativo · glass em card/tabela/KPI · emoji como ícone · cinza genérico no lugar de ink · ALL CAPS · success igual ao lime · fonte fora de Inter/Comfortaa.
