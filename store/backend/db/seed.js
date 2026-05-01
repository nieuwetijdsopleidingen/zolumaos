// seed.js — Vult de ZolumaOS Store database met 10 voorbeeldpakketten.
// Uitvoeren: node db/seed.js

const db = require('./database');

const packages = [
    // ── APT-pakketten (Linux native) ──────────────────────────
    {
        name:        'VLC Media Player',
        description: 'Veelzijdige mediaspeler die vrijwel elk formaat afspeelt.',
        version:     '3.0.20',
        type:        'apt',
        category:    'multimedia',
        package_id:  'vlc',
        icon:        'vlc',
        size_mb:     58.4,
    },
    {
        name:        'LibreOffice',
        description: 'Volledig gratis kantoorpakket: tekst, spreadsheet, presentaties.',
        version:     '7.6',
        type:        'apt',
        category:    'kantoor',
        package_id:  'libreoffice',
        icon:        'libreoffice',
        size_mb:     285.0,
    },
    {
        name:        'GIMP',
        description: 'Professionele afbeeldingseditor, gratis alternatief voor Photoshop.',
        version:     '2.10',
        type:        'apt',
        category:    'design',
        package_id:  'gimp',
        icon:        'gimp',
        size_mb:     92.1,
    },

    // ── Flatpak-pakketten (sandboxed) ─────────────────────────
    {
        name:        'Spotify',
        description: 'Muziekstreamingdienst met miljoenen nummers en podcasts.',
        version:     '1.2',
        type:        'flatpak',
        category:    'multimedia',
        package_id:  'com.spotify.Client',
        icon:        'spotify',
        size_mb:     174.3,
    },
    {
        name:        'Firefox',
        description: 'Snelle, veilige en privacyvriendelijke webbrowser.',
        version:     '124.0',
        type:        'flatpak',
        category:    'internet',
        package_id:  'org.mozilla.firefox',
        icon:        'firefox',
        size_mb:     210.5,
    },
    {
        name:        'Obsidian',
        description: 'Krachtige notitie-app met Markdown-ondersteuning en linken.',
        version:     '1.5',
        type:        'flatpak',
        category:    'productiviteit',
        package_id:  'md.obsidian.Obsidian',
        icon:        'obsidian',
        size_mb:     118.7,
    },
    {
        name:        'Inkscape',
        description: 'Vector-tekenprogramma, gratis alternatief voor Adobe Illustrator.',
        version:     '1.3',
        type:        'flatpak',
        category:    'design',
        package_id:  'org.inkscape.Inkscape',
        icon:        'inkscape',
        size_mb:     134.2,
    },

    // ── Zoluma eigen software ─────────────────────────────────
    {
        name:        'Zoluma Office',
        description: 'Zoluma kantoorpakket voor ZolumaOS: Writer, Columns, Slides en Draft. Speciaal gebouwd voor Linux x86.',
        version:     '0.26.0',
        type:        'deb',
        category:    'kantoor',
        package_id:  'https://github.com/nieuwetijdsopleidingen/zoluma-x86/releases/latest/download/zoluma-0.26.0-amd64.deb',
        icon:        'zoluma',
        size_mb:     120.0,
    },

    // ── Wine-apps (Windows-software via Wine) ─────────────────
    {
        name:        'Notepad++',
        description: 'Populaire teksteditor voor Windows, draait via Wine op ZolumaOS.',
        version:     '8.6',
        type:        'wine',
        category:    'ontwikkeling',
        package_id:  'notepadplusplus',
        icon:        'notepadplusplus',
        size_mb:     5.2,
    },
    {
        name:        '7-Zip (Windows)',
        description: 'Krachtige archiveertool voor ZIP, RAR en andere formaten.',
        version:     '23.01',
        type:        'wine',
        category:    'hulpprogrammas',
        package_id:  '7zip',
        icon:        '7zip',
        size_mb:     1.4,
    },
    {
        name:        'WinRAR',
        description: 'Bekende archiveringstool voor Windows, volledig werkend via Wine.',
        version:     '7.0',
        type:        'wine',
        category:    'hulpprogrammas',
        package_id:  'winrar',
        icon:        'winrar',
        size_mb:     3.8,
    },
];

// Verwijder bestaande seed-data en voeg opnieuw in (idempotent)
const insert = db.prepare(`
    INSERT OR REPLACE INTO packages
        (name, description, version, type, category, package_id, icon, size_mb, installed)
    VALUES
        (@name, @description, @version, @type, @category, @package_id, @icon, @size_mb, 0)
`);

const insertAll = db.transaction((pkgs) => {
    db.prepare('DELETE FROM packages').run();
    for (const pkg of pkgs) insert.run(pkg);
});

insertAll(packages);
console.log(`✓ ${packages.length} pakketten in de database geladen.`);
