function ChartCard({ title, children, height = 240 }) {
  return (
    <div style={{ background: '#1A222B', border: '1px solid #29323B', borderRadius: 12, padding: 16 }}>
      <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 13, fontWeight: 600, color: '#F4F6F8', marginBottom: 16 }}>{title}</div>
      <div style={{ height }}>{children}</div>
    </div>
  );
}

function PEIStatusDonut() {
  // Ativos 49%, Em Revisão 17%, Arquivados 23%, Rascunhos 11%
  const segs = [
    { label: 'Ativos', pct: 49, color: '#ACDE40' },
    { label: 'Em Revisão', pct: 17, color: '#4C9AFF' },
    { label: 'Arquivados', pct: 23, color: '#F5A524' },
    { label: 'Rascunhos', pct: 11, color: '#E5484D' },
  ];
  const R = 62, C = 2 * Math.PI * R;
  let offset = 0;
  return (
    <ChartCard title="PEIs por Status">
      <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
        <svg width="170" height="170" viewBox="0 0 170 170">
          <g transform="translate(85 85) rotate(-90)">
            {segs.map(s => {
              const len = (s.pct / 100) * C;
              const circle = (
                <circle key={s.label} r={R} cx="0" cy="0" fill="none" stroke={s.color} strokeWidth="20"
                        strokeDasharray={`${len} ${C}`} strokeDashoffset={-offset}/>
              );
              offset += len;
              return circle;
            })}
          </g>
        </svg>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, fontFamily: 'Inter, sans-serif', fontSize: 12 }}>
          {segs.map(s => (
            <div key={s.label} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ width: 10, height: 10, background: s.color, borderRadius: 2 }}/>
              <span style={{ color: '#A5AEBC' }}>{s.label}</span>
              <span style={{ color: '#F4F6F8', marginLeft: 'auto', fontFamily: ui-monospace, monospace }}>{s.pct}%</span>
            </div>
          ))}
        </div>
      </div>
    </ChartCard>
  );
}

function ProgressoBarras() {
  const rows = [
    { label: 'Cognitiva', v: 82 },
    { label: 'Social', v: 70 },
    { label: 'Motora', v: 58 },
    { label: 'Comunicação', v: 74 },
    { label: 'Autonomia', v: 65 },
  ];
  return (
    <ChartCard title="Progresso de Objetivos por Área">
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, paddingTop: 4 }}>
        {rows.map(r => (
          <div key={r.label}>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontFamily: 'Inter, sans-serif', fontSize: 11, color: '#A5AEBC', marginBottom: 4 }}>
              <span>{r.label}</span>
              <span style={{ fontFamily: ui-monospace, monospace, color: '#F4F6F8' }}>{r.v}</span>
            </div>
            <div style={{ height: 8, background: '#222B36', borderRadius: 4 }}>
              <div style={{ height: '100%', width: r.v + '%', background: '#ACDE40', borderRadius: 4 }}/>
            </div>
          </div>
        ))}
      </div>
    </ChartCard>
  );
}

function AtividadesChart() {
  const pts = [[0,130],[50,118],[100,92],[150,100],[200,68],[250,54],[300,46],[350,30]];
  const labels = ['Mar','Abr','Mai','Jun','Jul','Ago','Set','Out'];
  const d = pts.map((p,i) => (i===0?'M':'L')+p[0]+' '+p[1]).join(' ');
  return (
    <ChartCard title="Atividades ao Longo do Tempo">
      <svg viewBox="0 0 380 180" width="100%" height="180">
        <defs>
          <linearGradient id="af" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0" stopColor="#ACDE40" stopOpacity="0.28"/>
            <stop offset="1" stopColor="#ACDE40" stopOpacity="0"/>
          </linearGradient>
        </defs>
        {[40,80,120,160].map(y => (
          <line key={y} x1="20" x2="370" y1={y} y2={y} stroke="#29323B" strokeDasharray="2 3"/>
        ))}
        <path d={d + ' L350 160 L0 160 Z'} transform="translate(20,0)" fill="url(#af)"/>
        <path d={d} transform="translate(20,0)" fill="none" stroke="#ACDE40" strokeWidth="2"/>
        {pts.map((p,i) => (
          <circle key={i} cx={p[0]+20} cy={p[1]} r="3" fill="#ACDE40" stroke="#0F141B" strokeWidth="1.5"/>
        ))}
        {labels.map((l,i) => (
          <text key={l} x={pts[i][0]+20} y="175" textAnchor="middle" fontFamily="Inter, sans-serif" fontSize="10" fill="#55637A">{l}</text>
        ))}
      </svg>
    </ChartCard>
  );
}

function NeedsPie() {
  const segs = [
    { label: 'TEA', pct: 35, color: '#ACDE40' },
    { label: 'TDAH', pct: 25, color: '#4C9AFF' },
    { label: 'Dislexia', pct: 20, color: '#F5A524' },
    { label: 'Def. Visual', pct: 10, color: '#9B8AFB' },
    { label: 'Def. Auditiva', pct: 5, color: '#26C6DA' },
    { label: 'Outros', pct: 5, color: '#E5484D' },
  ];
  const R = 72, CX = 90, CY = 90;
  let startAngle = -Math.PI / 2;
  const paths = segs.map(s => {
    const end = startAngle + (s.pct / 100) * Math.PI * 2;
    const large = end - startAngle > Math.PI ? 1 : 0;
    const x1 = CX + R * Math.cos(startAngle), y1 = CY + R * Math.sin(startAngle);
    const x2 = CX + R * Math.cos(end), y2 = CY + R * Math.sin(end);
    const d = `M${CX} ${CY} L${x1} ${y1} A${R} ${R} 0 ${large} 1 ${x2} ${y2} Z`;
    startAngle = end;
    return { d, color: s.color };
  });
  return (
    <ChartCard title="Distribuição de Necessidades Especiais">
      <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
        <svg width="180" height="180" viewBox="0 0 180 180">
          {paths.map((p,i) => <path key={i} d={p.d} fill={p.color} stroke="#1A222B" strokeWidth="1"/>)}
        </svg>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6, fontFamily: 'Inter, sans-serif', fontSize: 11 }}>
          {segs.map(s => (
            <div key={s.label} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <span style={{ width: 8, height: 8, background: s.color, borderRadius: 2 }}/>
              <span style={{ color: '#A5AEBC', minWidth: 84 }}>{s.label}</span>
              <span style={{ color: '#F4F6F8', fontFamily: ui-monospace, monospace }}>{s.pct}%</span>
            </div>
          ))}
        </div>
      </div>
    </ChartCard>
  );
}

window.PEIStatusDonut = PEIStatusDonut;
window.ProgressoBarras = ProgressoBarras;
window.AtividadesChart = AtividadesChart;
window.NeedsPie = NeedsPie;
