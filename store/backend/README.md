# store/backend/

Node.js/Express REST API voor de ZolumaOS Software Store.

## Endpoints

| Methode | Route | Omschrijving |
|---------|-------|--------------|
| GET | `/packages` | Alle beschikbare pakketten |
| GET | `/packages/:id` | Details van één pakket |
| POST | `/install/:id` | Installeer een pakket (APT / Flatpak / Wine) |
| GET | `/installed` | Lijst geïnstalleerde pakketten |

## Starten

```bash
npm install
npm start        # productie (poort 3001)
npm run dev      # ontwikkeling met nodemon
```

## Database
SQLite via `better-sqlite3`. Databasebestand: `db/store.db`.  
Seed-data: `db/seed.js` — bevat 10 voorbeeldpakketten.
