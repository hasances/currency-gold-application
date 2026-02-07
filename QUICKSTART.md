# 🚀 Quick Start Guide - Cloud Deployment

Diese Anleitung zeigt dir in **10 Minuten**, wie du die App produktionsreif machst.

## Schritt 0: Git & GitHub Setup (5 Minuten) ⭐ NEU

**WICHTIG**: Für Render.com brauchst du dein Projekt auf GitHub!

📖 **Folge dieser Anleitung**: [GIT_SETUP.md](GIT_SETUP.md)

**Zusammenfassung**:
```powershell
# 1. Git initialisieren
git init
git add .
git commit -m "Initial commit: Currency & Gold App"

# 2. Auf GitHub pushen (Ersetze 'dein-username')
git remote add origin https://github.com/dein-username/currency-gold-application.git
git push -u origin main
```

➡️ **Weiter mit Schritt 1, sobald dein Projekt auf GitHub ist!**

## Schritt 1: Gold API Key bekommen (2 Minuten)

1. Gehe zu https://www.goldapi.io/
2. Registriere dich (kostenlos)
3. Kopiere deinen API-Key

## Schritt 2: Server auf Render deployen (3 Minuten)

### Variante A: Über Render Dashboard (Einfachste)

1. Gehe zu https://render.com/ und melde dich an
2. Klicke auf **"New +"** → **"Web Service"**
3. Verbinde dein GitHub/GitLab Repository
4. Einstellungen:
   ```
   Name: currency-gold-server
   Region: Frankfurt (EU Central)
   Branch: main
   Root Directory: server
   Runtime: Node
   Build Command: npm install
   Start Command: node server.js
   ```
5. Klicke auf **"Advanced"** und füge Environment Variable hinzu:
   ```
   Key: GOLD_API_KEY
   Value: [Dein API Key von Schritt 1]
   ```
6. Wähle **Free Plan**
7. Klicke auf **"Create Web Service"**

⏱️ Deployment dauert ~2 Minuten. Du erhältst eine URL wie:
```
https://currency-gold-server.onrender.com
```

### Variante B: Über render.yaml (Automatisch)

1. Gehe zu https://dashboard.render.com/select-repo
2. Wähle dein Repository
3. Render erkennt automatisch die `render.yaml`
4. Setze nur die Environment Variable `GOLD_API_KEY`
5. Deploy!

## Schritt 3: Flutter App konfigurieren (1 Minute)

### Option 1: Config-Datei bearbeiten (Empfohlen für Development)

Öffne `lib/config.dart` und ersetze die Production URL:

```dart
static const String _prodApiBaseUrl = 'https://deine-render-url.onrender.com';
```

### Option 2: Build-Zeit Parameter (Empfohlen für CI/CD)

Keine Datei-Änderung nötig! Nutze Command-Line:

```bash
flutter build apk \
  --dart-define=DEVELOPMENT=false \
  --dart-define=PROD_API_URL=https://deine-render-url.onrender.com \
  --release
```

## Schritt 4: App bauen & testen

### Android APK
```bash
flutter build apk --dart-define=DEVELOPMENT=false --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Testen
1. Installiere die APK auf deinem Handy
2. Öffne die App (Internet erforderlich für erste Daten)
3. Teste ohne Internet - sollte cached Daten zeigen

## ✅ Fertig!

Deine App ist jetzt:
- ✅ Überall erreichbar (nicht nur im WLAN)
- ✅ Optimiert für API-Limits (99% weniger Calls)
- ✅ Offline-fähig (mit Caching)
- ✅ Kostenlos hosted (Render Free Tier)

## 💡 Pro-Tipps

### Render "schläft" nach 15 Minuten?

**Problem**: Free Tier schläft bei Inaktivität. Erster Request dauert 30-60s.

**Lösung 1** - Uptime Monitor (Empfohlen):
1. Gehe zu https://uptimerobot.com/ (kostenlos)
2. Erstelle Monitor:
   - URL: `https://deine-url.onrender.com/health`
   - Interval: 5 Minuten
3. Render bleibt wach! 🎉

**Lösung 2** - Upgrade auf Paid Plan:
- $7/Monat für Always-On Server

### API-Limits sparen

Mit dem aktuellen Caching-Setup:
- Gold Cache: 10 Minuten
- 50 API-Calls/Monat reichen für **~700 App-Nutzer**!

Noch besser? Erhöhe in `server.js`:
```javascript
const GOLD_CACHE_DURATION_MS = 30 * 60 * 1000; // 30 Minuten
```

### Monitoring

Prüfe Server-Status:
```bash
curl https://deine-url.onrender.com/health
```

Sollte antworten:
```json
{"status":"ok","timestamp":"2026-02-07T..."}
```

## 🔄 Updates deployen

1. Ändere Code lokal
2. Commit & Push zu GitHub
3. Render deployed automatisch!

## 🆘 Troubleshooting

### App zeigt keine Daten

```bash
# Test 1: Server erreichbar?
curl https://deine-url.onrender.com/health

# Test 2: Gold Endpoint funktioniert?
curl https://deine-url.onrender.com/gold

# Test 3: Rates Endpoint?
curl https://deine-url.onrender.com/rates
```

### Server Logs checken

1. Gehe zu Render Dashboard
2. Klicke auf deinen Service
3. Tab "Logs" öffnen
4. Suche nach Fehler-Messages

### Noch Fragen?

Siehe ausführliche Dokumentation: [DEPLOYMENT.md](../DEPLOYMENT.md)
