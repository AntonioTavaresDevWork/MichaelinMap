function Sidebar({ active = 'Relatórios' }) {
  const items = [
    { label: 'PEIs', icon: 'M3 5h18v14H3zM3 10h18' },
    { label: 'Tarefas', icon: 'M4 6h16M4 12h16M4 18h10' },
    { label: 'Atividades', icon: 'M5 12h4l3-8 4 16 3-8h4' },
    { label: 'Relatórios', icon: 'M4 20V10M10 20V4M16 20v-8' },
    { label: 'Configurações', icon: 'M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09a1.65 1.65 0 00-1-1.51 1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 110-4h.09a1.65 1.65 0 001.51-1 1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06a1.65 1.65 0 001.82.33h0a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82v0a1.65 1.65 0 001.51 1H21a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z' },
  ];
  return (
    <aside style={{
      width: 220, flexShrink: 0,
      background: '#1A222B', borderRight: '1px solid #29323B',
      padding: '20px 12px', display: 'flex', flexDirection: 'column', gap: 4,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '4px 12px 20px' }}>
        <div style={{ width: 28, height: 28, borderRadius: 6, background: '#ACDE40', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#29323B', fontWeight: 800, fontSize: 16, fontFamily: 'Inter, sans-serif' }}>W</div>
        <div style={{ fontFamily: 'Inter, sans-serif', fontWeight: 700, fontSize: 15, color: '#F4F6F8' }}>WisePEI</div>
      </div>
      {items.map(it => {
        const isActive = it.label === active;
        return (
          <button key={it.label} style={{
            display: 'flex', alignItems: 'center', gap: 10,
            padding: '9px 12px', border: 'none', cursor: 'pointer',
            background: isActive ? 'rgba(172,222,64,0.12)' : 'transparent',
            color: isActive ? '#ACDE40' : '#A5AEBC',
            fontFamily: 'Inter, sans-serif', fontSize: 13, fontWeight: isActive ? 600 : 500,
            borderRadius: 8, textAlign: 'left',
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
              <path d={it.icon}/>
            </svg>
            {it.label}
          </button>
        );
      })}
    </aside>
  );
}
window.Sidebar = Sidebar;
