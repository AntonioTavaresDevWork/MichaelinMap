function Topbar() {
  const tabs = ['Visão Geral', 'Alunos', 'Objetivos', 'Atividades', 'Equipe'];
  const { useState } = React;
  const [active, setActive] = useState('Visão Geral');
  return (
    <div style={{ padding: '18px 28px 0', borderBottom: '1px solid #29323B', background: '#0F141B' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
        <div>
          <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 11, color: '#55637A', letterSpacing: '0.08em', textTransform: 'uppercase' }}>Coordenação · EMEF São Francisco</div>
          <h1 style={{ fontFamily: 'Inter, sans-serif', fontSize: 22, fontWeight: 700, color: '#F4F6F8', margin: '4px 0 0', letterSpacing: '-0.01em' }}>Relatórios</h1>
        </div>
        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <button style={{
            display: 'inline-flex', alignItems: 'center', gap: 8,
            height: 34, padding: '0 12px', background: '#1A222B',
            border: '1px solid #29323B', borderRadius: 8, color: '#F4F6F8',
            fontFamily: 'Inter, sans-serif', fontSize: 13, cursor: 'pointer',
          }}>
            Último mês
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.25" strokeLinecap="round" strokeLinejoin="round"><path d="M6 9l6 6 6-6"/></svg>
          </button>
          <div style={{ width: 34, height: 34, borderRadius: '50%', background: '#ACDE40', color: '#29323B', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'Inter, sans-serif', fontWeight: 700, fontSize: 13 }}>EM</div>
        </div>
      </div>
      <div style={{ display: 'flex', gap: 4 }}>
        {tabs.map(t => (
          <button key={t} onClick={() => setActive(t)} style={{
            padding: '10px 16px', border: 'none', background: 'transparent',
            color: t === active ? '#F4F6F8' : '#55637A',
            fontFamily: 'Inter, sans-serif', fontSize: 13, fontWeight: t === active ? 600 : 500,
            cursor: 'pointer', position: 'relative',
            borderBottom: t === active ? '2px solid #ACDE40' : '2px solid transparent',
            marginBottom: -1,
          }}>{t}</button>
        ))}
      </div>
    </div>
  );
}
window.Topbar = Topbar;
