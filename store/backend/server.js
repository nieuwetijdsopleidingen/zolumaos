const express = require('express');
const cors    = require('cors');
const path    = require('path');
const db      = require('./db/database');

const app  = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// GET /packages — alle beschikbare pakketten (optioneel filteren op type/categorie)
app.get('/packages', (req, res) => {
    const { type, category, search } = req.query;
    let sql    = 'SELECT * FROM packages WHERE 1=1';
    const args = [];

    if (type)     { sql += ' AND type = ?';             args.push(type); }
    if (category) { sql += ' AND category = ?';         args.push(category); }
    if (search)   { sql += ' AND name LIKE ?';          args.push(`%${search}%`); }

    sql += ' ORDER BY name ASC';

    try {
        const rows = db.prepare(sql).all(...args);
        res.json({ success: true, count: rows.length, packages: rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// GET /packages/:id — details van één pakket
app.get('/packages/:id', (req, res) => {
    const pkg = db.prepare('SELECT * FROM packages WHERE id = ?').get(req.params.id);
    if (!pkg) return res.status(404).json({ success: false, error: 'Pakket niet gevonden.' });
    res.json({ success: true, package: pkg });
});

// POST /install/:id — installeer een pakket
app.post('/install/:id', (req, res) => {
    const pkg = db.prepare('SELECT * FROM packages WHERE id = ?').get(req.params.id);
    if (!pkg) return res.status(404).json({ success: false, error: 'Pakket niet gevonden.' });

    // Markeer als geïnstalleerd in de database
    db.prepare('UPDATE packages SET installed = 1 WHERE id = ?').run(pkg.id);

    // Geef het installatie-commando terug dat de client kan uitvoeren
    const command = buildInstallCommand(pkg);
    res.json({
        success: true,
        message: `${pkg.name} wordt geïnstalleerd.`,
        command,
        package: { ...pkg, installed: 1 },
    });
});

// DELETE /install/:id — verwijder een pakket
app.delete('/install/:id', (req, res) => {
    const pkg = db.prepare('SELECT * FROM packages WHERE id = ?').get(req.params.id);
    if (!pkg) return res.status(404).json({ success: false, error: 'Pakket niet gevonden.' });

    db.prepare('UPDATE packages SET installed = 0 WHERE id = ?').run(pkg.id);
    res.json({ success: true, message: `${pkg.name} verwijderd.` });
});

// GET /installed — alle geïnstalleerde pakketten
app.get('/installed', (req, res) => {
    const rows = db.prepare('SELECT * FROM packages WHERE installed = 1 ORDER BY name').all();
    res.json({ success: true, count: rows.length, packages: rows });
});

function buildInstallCommand(pkg) {
    switch (pkg.type) {
        case 'apt':     return `sudo apt-get install -y ${pkg.package_id}`;
        case 'flatpak': return `flatpak install -y flathub ${pkg.package_id}`;
        case 'wine':    return `wine-install ${pkg.package_id}`;
        default:        return `echo "Onbekend pakkettype: ${pkg.type}"`;
    }
}

app.listen(PORT, () => {
    console.log(`ZolumaOS Store API draait op http://localhost:${PORT}`);
});
