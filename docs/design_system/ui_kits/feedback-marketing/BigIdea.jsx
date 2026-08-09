const { useState: useBIState } = React;

function BigIdea() {
  const [sent, setSent] = useState(false);
  const [email, setEmail] = useState('');
  return (
    <section id="contato" style={{
      position: 'relative',
      padding: '96px 32px',
      background: 'linear-gradient(180deg, #0F141B 0%, #0D1319 100%)',
      borderTop: '1px solid #29323B',
      borderBottom: '1px solid #29323B',
    }}>
      <div style={{ maxWidth: 900, margin: '0 auto', textAlign: 'center' }}>
        <div className="fb-eyebrow" style={{ justifyContent: 'center' }}>Próximo projeto</div>
        <h2 style={{
          fontFamily: 'Inter, sans-serif',
          fontSize: 72, lineHeight: '76px', fontWeight: 800, letterSpacing: '-0.03em',
          color: '#F4F6F8', margin: '16px 0 20px',
        }}>
          Você tem uma <span style={{ color: '#ACDE40' }}>grande ideia</span>?
        </h2>
        <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 20, lineHeight: '32px', color: '#A5AEBC', margin: '0 auto 40px', maxWidth: 640 }}>
          Fale direto com o Eduardo. Uma conversa de 30 minutos pra entender o que faz sentido construir primeiro.
        </p>
        {!sent ? (
          <form onSubmit={e => { e.preventDefault(); if (email) setSent(true); }} style={{
            display: 'flex', gap: 10, maxWidth: 480, margin: '0 auto',
          }}>
            <input
              className="fb-input"
              type="email" required
              placeholder="seu@email.com.br"
              value={email}
              onChange={e => setEmail(e.target.value)}
              style={{ flex: 1 }}
            />
            <button type="submit" className="fb-btn fb-btn--primary">
              Agendar conversa
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.25" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 5l7 7-7 7"/></svg>
            </button>
          </form>
        ) : (
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 12,
            padding: '14px 24px', borderRadius: 12,
            background: 'rgba(172,222,64,0.12)', border: '1px solid rgba(172,222,64,0.3)',
            color: '#ACDE40', fontFamily: 'Inter, sans-serif', fontSize: 15, fontWeight: 500,
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M20 6L9 17l-5-5"/>
            </svg>
            Recebido. Eduardo responde em até 24h.
          </div>
        )}
      </div>
    </section>
  );
}

window.BigIdea = BigIdea;
