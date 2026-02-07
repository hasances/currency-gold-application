# Deployment Guide

Dieser Guide erklärt, wie du den Server in der Cloud hostest, damit die App ohne lokales WLAN funktioniert.

## 🚀 Schnellstart - Deployment Optionen

### Option 1: Render.com (Empfohlen - Einfach & Kostenlos)

1. **Account erstellen**: https://render.com/
2. **New Web Service** erstellen
3. Repository verbinden (GitHub/GitLab)
4. Einstellungen:
   ```
   Name: currency-gold-server
   Root Directory: server
   Build Command: npm install
   Start Command: node server.js
   ```
5. **Environment Variables** hinzufügen:
   ```
   GOLD_API_KEY=dein-api-key-hier
   PORT=3000
   ```
6. **Deploy** klicken
7. Du erhältst eine URL wie: `https://currency-gold-server.onrender.com`

### Option 2: Railway.app (Sehr einfach)

1. **Account erstellen**: https://railway.app/
2. **New Project** → **Deploy from GitHub repo**
3. Repository auswählen
4. Railway erkennt automatisch Node.js
5. **Variables** Tab öffnen:
   ```
   GOLD_API_KEY=dein-api-key-hier
   ```
6. Automatisches Deployment startet
7. URL wird generiert: `https://xxx.railway.app`

### Option 3: Fly.io (Für Fortgeschrittene)

1. **Installation**: `npm install -g flyctl`
2. **Login**: `flyctl auth login`
3. Im `server/` Verzeichnis:
   ```bash
   flyctl launch
   flyctl secrets set GOLD_API_KEY=dein-api-key-hier
   flyctl deploy
   ```

### Option 4: Vercel (Serverless)

1. **Account erstellen**: https://vercel.com/
2. Vercel CLI installieren: `npm i -g vercel`
3. Im `server/` Verzeichnis:
   ```bash
   vercel
   ```
4. Environment Variables in Vercel Dashboard setzen
5. Die `vercel.json` ist bereits konfiguriert

## 📱 Flutter App Konfiguration

Nach dem Deployment:

1. Öffne `lib/config.dart`
2. Ersetze die Production URL:
   ```dart
   static const String _prodApiBaseUrl = 'https://deine-server-url.com';
   ```

3. **Development Build** (lokaler Server):
   ```bash
   flutter run
   ```

4. **Production Build** (Cloud Server):
   ```bash
   # Android APK
   flutter build apk --dart-define=DEVELOPMENT=false --release
   
   # iOS
   flutter build ios --dart-define=DEVELOPMENT=false --release
   
   # Windows
   flutter build windows --dart-define=DEVELOPMENT=false --release
   ```

## 🔒 Sicherheit

### API-Key Verwaltung

**WICHTIG**: Teile niemals deinen GOLD_API_KEY öffentlich!

- ✅ Verwende immer Environment Variables
- ✅ `.env` ist in `.gitignore` enthalten
- ✅ Nutze `.env.example` als Template
- ❌ Committe niemals `.env` zu Git

### Rate Limiting

Der Server hat eingebautes Rate Limiting:
- 30 Requests pro Minute pro IP
- Bei Überschreitung: HTTP 429 Response

### CORS

Der Server akzeptiert Requests von allen Origins. Für Production kannst du das einschränken:

```javascript
app.use(cors({
  origin: ['https://deine-app-domain.com']
}));
```

## 📊 Monitoring

### Health Check

Der Server bietet einen Health-Endpoint:
```
GET /health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2026-02-07T12:00:00.000Z"
}
```

### Logs überprüfen

**Render.com**:
- Dashboard → Service → Logs Tab

**Railway.app**:
- Project → Deployments → Logs

**Fly.io**:
```bash
flyctl logs
```

## 🔄 Caching-Strategie

### Server-seitig

- **Währungen**: 5 Minuten Cache
- **Gold**: 10 Minuten Cache
- **Fallback**: Bei API-Fehler wird alter Cache verwendet

### Client-seitig (Flutter)

- `shared_preferences` speichert letzte Daten
- App funktioniert offline mit gecachten Daten
- Auto-Refresh alle 5 Minuten

## 💰 Kosten & Limits

### Gold API (goldapi.io)

- Free Tier: 50 Requests pro Monat
- Mit Caching (10 Min): ~4.320 Requests/Monat möglich
- **Empfehlung**: Paid Plan ab $10/Monat für Production

### Währungs-API (frankfurter.app)

- Komplett kostenlos
- Keine Rate-Limits
- Open Source

### Hosting

| Platform | Free Tier | Limits |
|----------|-----------|--------|
| Render | 750h/Monat | Sleep nach 15 Min Inaktivität |
| Railway | $5 Guthaben | Danach $0.000463/GB-hour |
| Fly.io | 3 VMs | 256MB RAM |
| Vercel | Unlimited | Serverless Functions |

## 🔧 Troubleshooting

### Problem: Server schläft (Render Free Tier)

**Lösung**: Erster Request dauert 30-60s (Cold Start)

**Alternative**: Uptime-Monitor verwenden (z.B. UptimeRobot) um Server wach zu halten

### Problem: API-Limit erreicht

**Symptome**: Fallback-Daten werden verwendet

**Lösung**:
1. Cache-Dauer erhöhen in `server.js`:
   ```javascript
   const GOLD_CACHE_DURATION_MS = 30 * 60 * 1000; // 30 Minuten
   ```
2. Paid Gold API Plan
3. Alternative Gold-API verwenden

### Problem: Flutter kann Server nicht erreichen

**Checks**:
```bash
# Test 1: Health Check
curl https://deine-server-url.com/health

# Test 2: Rates Endpoint
curl https://deine-server-url.com/rates

# Test 3: Gold Endpoint
curl https://deine-server-url.com/gold
```

**Flutter Config prüfen**:
- Development Build nutzt lokale IP
- Production Build braucht `--dart-define=DEVELOPMENT=false`

## 🚦 Deployment Checklist

Vor dem Release:

- [ ] Server auf Cloud-Plattform deployed
- [ ] Environment Variables gesetzt
- [ ] Health-Endpoint erreichbar (`/health`)
- [ ] Production URL in `lib/config.dart` eingetragen
- [ ] App mit `--dart-define=DEVELOPMENT=false` gebaut
- [ ] API-Limits überprüft
- [ ] Monitoring eingerichtet (optional)
- [ ] Backup-Strategie für `gold_history.json` (optional)

## 📚 Weiterführende Ressourcen

- [Render Docs](https://render.com/docs)
- [Railway Docs](https://docs.railway.app/)
- [Fly.io Docs](https://fly.io/docs/)
- [Flutter Build & Release](https://docs.flutter.dev/deployment)
- [Gold API Docs](https://www.goldapi.io/documentation)
