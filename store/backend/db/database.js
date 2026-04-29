const Database = require('better-sqlite3');
const path     = require('path');
const fs       = require('fs');

const DB_DIR  = path.join(__dirname);
const DB_PATH = path.join(DB_DIR, 'store.db');

fs.mkdirSync(DB_DIR, { recursive: true });

const db = new Database(DB_PATH);

// Tabel aanmaken als die nog niet bestaat
db.exec(`
    CREATE TABLE IF NOT EXISTS packages (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        description TEXT    NOT NULL DEFAULT '',
        version     TEXT    NOT NULL DEFAULT 'latest',
        type        TEXT    NOT NULL CHECK(type IN ('apt','flatpak','wine')),
        category    TEXT    NOT NULL DEFAULT 'overig',
        package_id  TEXT    NOT NULL,
        icon        TEXT    NOT NULL DEFAULT 'package',
        size_mb     REAL    NOT NULL DEFAULT 0,
        installed   INTEGER NOT NULL DEFAULT 0
    );
`);

module.exports = db;
