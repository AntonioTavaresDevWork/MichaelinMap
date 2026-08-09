const { useState } = React;

function Header() {
  const [open, setOpen] = useState(false);
  return (
    <header style={{
      position: 'sticky', top: 0, zIndex: 10,
      height: 72, padding: '0 32px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      background: 'rgba(10,14,20,0.72)',
      backdropFilter: 'blur(12px)',
      borderBottom: '1px solid #29323B',
    }}>
      <a href="#" style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' }}>
        <img src="../../assets/feedback-logo-white.png" alt="Feedback" style={{ height: 28, display: 'block' }}/>
      </a>
      <nav style={{ display: 'flex', gap: 32, alignItems: 'center' }}>
        <a href="#servicos" style={navLink}>Serviços</a>
        <a href="#casos" style={navLink}>Casos</a>
        <a href="#sobre" style={navLink}>Sobre</a>
        <a href="#contato" className="fb-btn fb-btn--primary" style={{ textDecoration: 'none', height: 40, padding: '0 16px', fontSize: 14 }}>Fale conosco</a>
      </nav>
    </header>
  );
}

const navLink = {
  fontFamily: 'Inter, sans-serif',
  fontSize: 14,
  fontWeight: 500,
  color: '#A5AEBC',
  textDecoration: 'none',
  transition: 'color 150ms',
};

window.Header = Header;
