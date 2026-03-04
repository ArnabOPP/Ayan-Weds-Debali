import { Navigate, NavLink, Route, Routes } from "react-router-dom";

function EmbeddedView() {
  return (
    <div className="app-shell">
      <header className="app-header">
        <h1>Recovered Framer Site</h1>
        <nav className="app-nav">
          <NavLink to="/" end>
            Embedded
          </NavLink>
          <NavLink to="/recovered">Full Page</NavLink>
          <a href="/City5.html" target="_blank" rel="noreferrer">
            Open standalone
          </a>
        </nav>
      </header>

      <main className="app-main">
        <iframe title="Recovered site" src="/City5.html" />
      </main>
    </div>
  );
}

function RecoveredFullPage() {
  return (
    <div className="full-page-shell">
      <div className="full-page-topbar">
        <NavLink to="/">Back to wrapper</NavLink>
      </div>
      <iframe title="Recovered full page" src="/City5.html" />
    </div>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<EmbeddedView />} />
      <Route path="/recovered" element={<RecoveredFullPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
