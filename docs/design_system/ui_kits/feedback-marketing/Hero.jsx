function Hero() {
  return (
    <section style={{
      position: 'relative',
      padding: '96px 32px 120px',
      maxWidth: 1200, margin: '0 auto',
      display: 'grid', gridTemplateColumns: '1.15fr 1fr', gap: 64, alignItems: 'center',
    }}>
      <div style={{
        position: 'absolute', inset: 0,
        background: 'radial-gradient(circle at 20% 0%, rgba(172,222,64,0.10), transparent 60%)',
        pointerEvents: 'none',
      }}/>
      <div style={{ position: 'relative' }}>
        <div className="fb-badge" style={{ marginBottom: 24 }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: '#ACDE40' }}/>
          AI-First · Solopreneur
        </div>
        <h1 style={{
          fontFamily: 'Inter, sans-serif',
          fontSize: 64, lineHeight: '68px', letterSpacing: '-0.03em',
          fontWeight: 800, color: '#F4F6F8', margin: '0 0 24px',
        }}>
          Construa seu projeto <span style={{ color: '#ACDE40' }}>do zero ao topo.</span>
        </h1>
        <p style={{
          fontFamily: 'Inter, sans-serif',
          fontSize: 19, lineHeight: '30px', color: '#A5AEBC',
          margin: '0 0 36px', maxWidth: 520,
        }}>
          Agência solopreneur de SaaS, Power BI e Automação. Transformamos a sua grande ideia em produto rodando — do planejamento à operação contínua.
        </p>
        <div style={{ display: 'flex', gap: 12 }}>
          <a href="#contato" className="fb-btn fb-btn--primary" style={{ textDecoration: 'none' }}>
            Fale conosco
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.25" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>
          </a>
          <a href="#portfolio" className="fb-btn fb-btn--ghost" style={{ textDecoration: 'none' }}>Ver portfólio</a>
        </div>
      </div>
      <div style={{ position: 'relative' }}>
        <HeroIllustration/>
      </div>
    </section>
  );
}

function HeroIllustration() {
  return (
    <div style={{
      position: 'relative',
      borderRadius: 24,
      background: 'linear-gradient(135deg, #1A222B 0%, #222B36 100%)',
      border: '1px solid #29323B',
      padding: 28, overflow: 'hidden',
      boxShadow: '0 40px 80px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
        <div style={{ fontFamily: ui-monospace, monospace, fontSize: 11, color: '#6B7588', letterSpacing: '0.08em', textTransform: 'uppercase' }}>projeto · sprint 03</div>
        <div style={{ display: 'flex', gap: 6 }}>
          <span style={dot('#E5484D')}/><span style={dot('#F5A524')}/><span style={dot('#ACDE40')}/>
        </div>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginBottom: 16 }}>
        <MiniCard label="Tarefas" value="48" delta="+12"/>
        <MiniCard label="Concluídas" value="36" delta="75%"/>
      </div>
      <div style={{ background: '#0F141B', borderRadius: 12, padding: 16, border: '1px solid #29323B' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
          <span style={{ fontFamily: 'Inter, sans-serif', fontSize: 12, fontWeight: 600, color: '#F4F6F8' }}>Progresso · 12 semanas</span>
          <span style={{ fontFamily: ui-monospace, monospace, fontSize: 11, color: '#ACDE40' }}>+24%</span>
        </div>
        <svg width="100%" height="80" viewBox="0 0 320 80">
          <defs>
            <linearGradient id="hg" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0" stopColor="#ACDE40" stopOpacity="0.3"/>
              <stop offset="1" stopColor="#ACDE40" stopOpacity="0"/>
            </linearGradient>
          </defs>
          <path d="M0 60 L40 55 L80 48 L120 50 L160 38 L200 30 L240 22 L280 18 L320 10 L320 80 L0 80 Z" fill="url(#hg)"/>
          <path d="M0 60 L40 55 L80 48 L120 50 L160 38 L200 30 L240 22 L280 18 L320 10" fill="none" stroke="#ACDE40" strokeWidth="2"/>
        </svg>
      </div>
      <div style={{ marginTop: 14, display: 'flex', gap: 8 }}>
        <Tag>SaaS</Tag><Tag>Power BI</Tag><Tag>Automação</Tag>
      </div>
    </div>
  );
}

const dot = c => ({ width: 10, height: 10, borderRadius: '50%', background: c });

function MiniCard({ label, value, delta }) {
  return (
    <div style={{ background: '#0F141B', borderRadius: 10, padding: 14, border: '1px solid #29323B' }}>
      <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 11, color: '#A5AEBC', marginBottom: 4 }}>{label}</div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
        <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 28, fontWeight: 800, color: '#F4F6F8', lineHeight: 1 }}>{value}</div>
        <div style={{ fontFamily: ui-monospace, monospace, fontSize: 11, color: '#ACDE40' }}>{delta}</div>
      </div>
    </div>
  );
}

function Tag({ children }) {
  return <span style={{ fontFamily: 'Inter, sans-serif', fontSize: 11, fontWeight: 600, padding: '4px 10px', borderRadius: 999, background: 'rgba(172,222,64,0.12)', color: '#ACDE40' }}>{children}</span>;
}

window.Hero = Hero;
