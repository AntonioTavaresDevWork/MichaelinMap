function ServicesGrid() {
  const services = [
    { title: 'SaaS sob medida', desc: 'Produtos web verticalizados, do MVP à operação. Arquitetura moderna, UX cuidada, iteração rápida.', tag: 'Produto' },
    { title: 'Power BI', desc: 'Modelagem de dados, dashboards executivos e relatórios que realmente são usados para decisão.', tag: 'Dados' },
    { title: 'Automação', desc: 'Workflows, integrações e agentes de IA que eliminam tarefa repetitiva e liberam tempo do time.', tag: 'IA' },
  ];
  return (
    <section id="servicos" style={{ padding: '96px 32px', maxWidth: 1200, margin: '0 auto' }}>
      <div style={{ maxWidth: 640, marginBottom: 56 }}>
        <div className="fb-eyebrow">Serviços</div>
        <h2 style={{ fontFamily: 'Inter, sans-serif', fontSize: 44, lineHeight: '52px', fontWeight: 700, color: '#F4F6F8', letterSpacing: '-0.02em', margin: '12px 0 16px' }}>
          Três frentes. Um parceiro.
        </h2>
        <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 18, lineHeight: '28px', color: '#A5AEBC', margin: 0 }}>
          Entregamos o ciclo inteiro sem terceirizar o que importa — código, dados e decisão estratégica ficam em uma mão só.
        </p>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 20 }}>
        {services.map((s, i) => (
          <div key={s.title} className="fb-card" style={{ padding: 28 }}>
            <div style={{ fontFamily: ui-monospace, monospace, fontSize: 11, color: '#6B7588', marginBottom: 20 }}>
              {String(i + 1).padStart(2, '0')} / 03
            </div>
            <h3 style={{ fontFamily: 'Inter, sans-serif', fontSize: 22, fontWeight: 700, color: '#F4F6F8', margin: '0 0 10px', letterSpacing: '-0.01em' }}>
              {s.title}
            </h3>
            <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 14, lineHeight: '22px', color: '#A5AEBC', margin: '0 0 20px' }}>{s.desc}</p>
            <span style={{ fontFamily: 'Inter, sans-serif', fontSize: 11, fontWeight: 600, padding: '4px 10px', borderRadius: 999, background: 'rgba(172,222,64,0.12)', color: '#ACDE40', letterSpacing: '0.04em', textTransform: 'uppercase' }}>{s.tag}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

window.ServicesGrid = ServicesGrid;
