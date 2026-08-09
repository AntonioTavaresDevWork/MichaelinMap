function StatCards() {
  const stats = [
    { label: 'PEIs Ativos', value: '5', delta: '+2 vs. mês anterior', icon: 'M3 5h18v14H3zM3 10h18' },
    { label: 'Objetivos em Andamento', value: '6', delta: '81% de progresso médio', icon: 'M12 2v20M2 12h20' },
    { label: 'Atividades Realizadas', value: '5', delta: '+12% vs. período anterior', icon: 'M5 13l4 4L19 7' },
    { label: 'Profissionais Ativos', value: '12', delta: '100% de participação', icon: 'M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2M12 7a4 4 0 11-8 0 4 4 0 018 0zM22 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75' },
  ];
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12 }}>
      {stats.map(s => (
        <div key={s.label} style={{ background: '#1A222B', border: '1px solid #29323B', borderRadius: 12, padding: 16 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 12, color: '#A5AEBC', fontWeight: 500 }}>{s.label}</div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#55637A" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d={s.icon}/></svg>
          </div>
          <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 32, fontWeight: 800, color: '#F4F6F8', lineHeight: 1, letterSpacing: '-0.02em' }}>{s.value}</div>
          <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 11, color: '#55637A', marginTop: 6 }}>{s.delta}</div>
        </div>
      ))}
    </div>
  );
}
window.StatCards = StatCards;
