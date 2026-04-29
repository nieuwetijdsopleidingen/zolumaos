# store/

ZolumaOS Cloud Software Store — eigen softwareportal voor pakketten en uitbreidingen.

## Submappen

| Map | Inhoud |
|-----|--------|
| `frontend/` | React-applicatie (UI van de store) |
| `backend/` | Node.js/Express API + SQLite database |

## Architectuur

```
Gebruiker → Store UI (React/Electron)
         → Store API (Node.js/Express)
         → Package resolver
              → APT       (Linux pakketten)
              → Flatpak   (sandboxed apps)
              → Wine      (Windows-software via Wine installer)
```

## Starten

```bash
# Backend
cd backend && npm install && npm start   # poort 3001

# Frontend
cd frontend && npm install && npm start  # poort 3000
```
