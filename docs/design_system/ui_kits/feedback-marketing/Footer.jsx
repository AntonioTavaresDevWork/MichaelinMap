function Footer() {
  return (
    <footer style={{
      padding: '48px 32px 32px',
      maxWidth: 1200, margin: '0 auto',
      display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 24,
      flexWrap: 'wrap',
      borderTop: '1px solid #29323B',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
        <img src="../../assets/feedback-mark-green.png" alt="" style={{ height: 28 }}/>
        <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 13, color: '#A5AEBC' }}>
          © 2026 Feedback Comunicação · Eduardo Mello
        </div>
      </div>
      <div style={{ display: 'flex', gap: 24 }}>
        <a href="#" style={footerLink}>Portfólio</a>
        <a href="#" style={footerLink}>Casos</a>
        <a href="#" style={footerLink}>LinkedIn</a>
        <a href="#" style={footerLink}>WhatsApp</a>
      </div>
    </footer>
  );
}
const footerLink = { fontFamily: 'Inter, sans-serif', fontSize: 13, color: '#A5AEBC', textDecoration: 'none' };
window.Footer = Footer;
