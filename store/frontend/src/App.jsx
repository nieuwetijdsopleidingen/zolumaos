import { useState, useEffect } from 'react'

function DownloadPage() {
  return (
    <div className="download-page">
      <div className="download-box">
        <span className="download-logo">⬡</span>
        <h1>ZolumaOS Store</h1>
        <p>Deze store is alleen toegankelijk vanuit <strong>ZolumaOS</strong>.</p>
        <p className="download-sub">Nog geen ZolumaOS? Download het gratis en installeer het op je computer.</p>
        <a className="download-btn" href="https://zoluma.org" target="_blank" rel="noreferrer">
          Download ZolumaOS
        </a>
        <span className="download-hint">Gratis · Open source · Werkt op hardware vanaf 2010</span>
      </div>
    </div>
  )
}

const CATEGORIES = [
  { id: '',               label: 'Alles' },
  { id: 'multimedia',     label: 'Multimedia' },
  { id: 'internet',       label: 'Internet' },
  { id: 'kantoor',        label: 'Kantoor' },
  { id: 'design',         label: 'Design' },
  { id: 'productiviteit', label: 'Productiviteit' },
  { id: 'ontwikkeling',   label: 'Ontwikkeling' },
  { id: 'hulpprogrammas', label: "Hulpprogramma's" },
]

const TYPES = [
  { id: '',        label: 'Alle types' },
  { id: 'apt',     label: 'Linux (APT)' },
  { id: 'flatpak', label: 'Flatpak' },
  { id: 'wine',    label: 'Windows (Wine)' },
]

const TYPE_STYLE = {
  apt:     { bg: '#e8f5e9', color: '#2e7d32', label: 'APT' },
  flatpak: { bg: '#e3f2fd', color: '#1565c0', label: 'Flatpak' },
  wine:    { bg: '#fff3e0', color: '#e65100', label: 'Wine' },
}

const ICON_COLORS = [
  '#5b5ea6','#2196f3','#4caf50','#ff9800',
  '#e91e63','#9c27b0','#00bcd4','#f44336','#607d8b','#795548',
]

export default function App() {
  const isZolumaOS = navigator.userAgent.includes('ZolumaOS')

  if (!isZolumaOS) return <DownloadPage />

  const [allPackages,    setAllPackages]    = useState([])
  const [loading,        setLoading]        = useState(true)
  const [search,         setSearch]         = useState('')
  const [activeCategory, setActiveCategory] = useState('')
  const [activeType,     setActiveType]     = useState('')

  useEffect(() => {
    fetch('/packages.json')
      .then(r => r.json())
      .then(data => { setAllPackages(data); setLoading(false) })
      .catch(() => setLoading(false))
  }, [])

  const displayed = allPackages.filter(pkg => {
    if (activeCategory && pkg.category !== activeCategory) return false
    if (activeType     && pkg.type     !== activeType)     return false
    if (search && !pkg.name.toLowerCase().includes(search.toLowerCase()) &&
                  !pkg.description.toLowerCase().includes(search.toLowerCase())) return false
    return true
  })

  return (
    <div className="app">
      <header className="header">
        <div className="header-logo">
          <span className="logo-icon">⬡</span>
          <span className="logo-text">ZolumaOS Store</span>
        </div>
        <input
          className="search"
          type="text"
          placeholder="Zoeken in pakketten..."
          value={search}
          onChange={e => setSearch(e.target.value)}
        />
        <a className="nav-cta" href="https://zoluma.org" target="_blank" rel="noreferrer">
          Download ZolumaOS
        </a>
      </header>

      <div className="hero">
        <p>Alle software hieronder is standaard beschikbaar in ZolumaOS — gratis te installeren via de ingebouwde Store app.</p>
      </div>

      <div className="layout">
        <aside className="sidebar">
          <div className="sidebar-section">
            <div className="sidebar-title">Categorie</div>
            {CATEGORIES.map(c => (
              <button
                key={c.id}
                className={`sidebar-item ${activeCategory === c.id ? 'active' : ''}`}
                onClick={() => setActiveCategory(c.id)}
              >{c.label}</button>
            ))}
          </div>
          <div className="sidebar-section">
            <div className="sidebar-title">Type</div>
            {TYPES.map(t => (
              <button
                key={t.id}
                className={`sidebar-item ${activeType === t.id ? 'active' : ''}`}
                onClick={() => setActiveType(t.id)}
              >{t.label}</button>
            ))}
          </div>
        </aside>

        <main className="main">
          {loading ? (
            <div className="empty">Laden...</div>
          ) : displayed.length === 0 ? (
            <div className="empty">Geen pakketten gevonden.</div>
          ) : (
            <div className="grid">
              {displayed.map((pkg, i) => {
                const ts     = TYPE_STYLE[pkg.type] || {}
                const iconBg = ICON_COLORS[i % ICON_COLORS.length]
                return (
                  <div key={pkg.id} className="card">
                    <div className="card-icon" style={{ background: iconBg }}>
                      {pkg.name.charAt(0)}
                    </div>
                    <div className="card-body">
                      <div className="card-name">{pkg.name}</div>
                      <div className="card-desc">{pkg.description}</div>
                      <div className="card-meta">
                        <span className="badge" style={{ background: ts.bg, color: ts.color }}>
                          {ts.label}
                        </span>
                        <span className="card-size">{pkg.size_mb} MB</span>
                        <span className="card-version">v{pkg.version}</span>
                      </div>
                    </div>
                    <div className="card-action">
                      <span className="available-badge">Beschikbaar</span>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </main>
      </div>

      <footer className="footer">
        <span>© 2026 ZolumaOS · <a href="https://zoluma.org" target="_blank" rel="noreferrer">zoluma.org</a></span>
      </footer>
    </div>
  )
}
