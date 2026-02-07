# Currency & Gold Server

Backend API Server für die Currency & Gold Flutter Application.

## Features

- 💰 **Gold Preise** - Live-Daten von GoldAPI.io
- 💱 **Währungskurse** - Live-Daten von Frankfurter.app
- 📊 **Historische Daten** - Gold-Preisentwicklung
- ⚡ **Smart Caching** - 99% weniger API-Calls
- 🛡️ **Rate Limiting** - Schutz vor Missbrauch
- 🔄 **Fallback-Strategie** - Works offline mit altem Cache

## Quick Start

```bash
npm install
cp .env.example .env
# .env bearbeiten und GOLD_API_KEY eintragen
npm start
```

Server läuft auf http://localhost:3000

## Endpoints

- `GET /health` - Server Status
- `GET /rates` - Währungskurse (cached 5 Min)
- `GET /gold` - Goldpreise (cached 10 Min)
- `GET /gold/history?days=X` - Historische Daten

## Environment Variables

- `GOLD_API_KEY` - API Key von goldapi.io (Required)
- `PORT` - Server Port (Default: 3000)
- `NODE_ENV` - Environment (production/development)

## Development

```bash
npm run dev   # Mit nodemon (auto-reload)
npm test      # Test lokalen Server
```

## Deployment

Siehe [../DEPLOYMENT.md](../DEPLOYMENT.md) für Cloud-Hosting Optionen.

## API Usage Limits

Mit Caching (10 Min):
- Free Tier (50 calls/month) → ~700 App-Nutzer
- Basic Tier (500 calls/month) → ~7.000 App-Nutzer

## Technologie

- **Runtime**: Node.js 20+
- **Framework**: Express.js
- **APIs**: GoldAPI.io, Frankfurter.app
- **Storage**: JSON File (gold_history.json)
