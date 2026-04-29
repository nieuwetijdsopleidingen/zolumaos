# store/frontend/

React-applicatie voor de ZolumaOS Software Store UI.

Toont beschikbare pakketten per categorie (Linux, Flatpak, Windows-apps via Wine),
zoekfunctie, installatiestatus en voortgangsindicatie.

## Starten

```bash
npm install
npm start    # ontwikkelserver op poort 3000
npm run build  # productie-build
```

## Verbinding met backend
Stel de backend-URL in via `.env`:
```
REACT_APP_API_URL=http://localhost:3001
```
