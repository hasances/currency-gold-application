# Currency & Gold Application

Eine produktionsreife Flutter-Anwendung zum Verwalten von Währungs- und Goldpreisen mit Cloud-Backend-Unterstützung.

## ✨ Funktionen

- **Currency Tab**: Anzeige und Berechnung von Währungsumrechnungen mit Live-Wechselkursen
- **Gold Tab**: Verwaltung von Goldmünzen und Berechnung von Spot- und Händlerpreisen
- **Chart Tab** (optional): Historische Goldpreisentwicklung (auskommentiert in main.dart)
- **Offline-Modus**: Funktioniert mit gecachten Daten ohne Internetverbindung
- **Smart Caching**: Minimiert API-Calls und schont Limits
- **Production-Ready**: Kann in der Cloud gehostet werden

## 🚀 Quick Start

### Lokale Entwicklung

1. **Server starten**:
   ```bash
   cd server
   npm install
   cp .env.example .env
   # .env bearbeiten und GOLD_API_KEY eintragen
   npm start
   ```

2. **Flutter App starten**:
   ```bash
   flutter pub get
   flutter run
   ```

### Production Deployment

Siehe [DEPLOYMENT.md](DEPLOYMENT.md) für detaillierte Anweisungen zum Cloud-Hosting.

## 📋 Voraussetzungen

- Flutter SDK (^3.10.7)
- Node.js v20.x oder höher
- Gold API Key von [goldapi.io](https://www.goldapi.io/)

## 🔧 Installation

### Backend-Server

1. Navigiere zum Server-Verzeichnis:
   ```bash
   cd server
   ```

2. Installiere die Dependencies:
   ```bash
   npm install
   ```

3. Erstelle eine `.env` Datei mit deinem Gold API Key:
   ```
   GOLD_API_KEY=dein-api-key-hier
   ```

4. Starte den Server:
   ```bash
   npm start
   ```
   Der Server läuft auf `http://localhost:3000`

### Flutter App

1. Passe die API-URL in `lib/config.dart` an (falls nötig):
   ```dart
   static const String apiBaseUrl = 'http://192.168.178.42:3000';
   ```

2. Hole die Flutter Dependencies:
   ```bash
   flutter pub get
   ```

3. Starte die App:
   ```bash
   flutter run
   ```

## Konfiguration

### Environment-basierte Konfiguration

Die App unterstützt separate Dev/Prod Umgebungen:

**Development** (lokaler Server - Standard):
```bash
flutter run
```

**Production** (Cloud Server):
```bash
flutter build apk --dart-define=DEVELOPMENT=false --release
```

Passe die Production URL in `lib/config.dart` an:
```dart
static const String _prodApiBaseUrl = 'https://deine-server-url.com';
```

### API-Endpoints

Zentral verwaltet in `lib/config.dart`:
- `/health` - Server Health Check
- `/rates` - Währungskurse (gecacht 5 Min)
- `/gold` - Goldpreise (gecacht 10 Min)
- `/gold/history?days=X` - Historische Goldpreise

### Server-Features

- 🔒 **Rate Limiting**: 30 Requests/Minute pro IP
- 💾 **Smart Caching**: Reduziert API-Calls um >90%
- 🔄 **Fallback-Strategie**: Alter Cache bei API-Fehlern
- 📊 **Monitoring**: Health-Endpoint für Uptime-Checks
- ⚡ **Performance**: In-Memory Cache für schnelle Responses

## 📦 Abhängigkeiten

### Flutter
- http: ^1.1.0
- shared_preferences: ^2.1.1
- fl_chart: ^0.66.0
- cupertino_icons: ^1.0.8

### Server
- express: ^5.2.1
- cors: ^2.8.6
- dotenv: ^17.2.3
- node-fetch: ^2.7.0

## 🧪 Entwicklung

### Tests ausführen
```bash
flutter test
```

### Code formatieren
```bash
flutter format lib/
```

### Production Build erstellen

**Android**:
```bash
flutter build apk --dart-define=DEVELOPMENT=false --release
```

**iOS**:
```bash
flutter build ios --dart-define=DEVELOPMENT=false --release
```

**Windows**:
```bash
flutter build windows --dart-define=DEVELOPMENT=false --release
```

## 📊 API-Limits & Caching

### Ohne Caching (Alte Version)
- Gold API: 50 Requests/Monat → ~1,7 Requests/Tag
- Problem: Limit schnell erreicht

### Mit Caching (Neue Version)
- Gold Cache: 10 Minuten
- Rate Cache: 5 Minuten
- Mögliche Requests: ~4.320/Monat
- **Ersparnis: 99%+ weniger API-Calls**

## 🌐 Deployment

Für Production-Deployment siehe ausführliche Anleitung in [DEPLOYMENT.md](DEPLOYMENT.md).

Empfohlene Plattformen:
- **Render.com** (Einfachste Option, kostenloser Tier)
- **Railway.app** (Sehr benutzerfreundlich)
- **Fly.io** (Gute Performance)
- **Vercel** (Serverless)

## 🔐 Sicherheit

- ✅ API-Keys in Environment Variables
- ✅ `.env` in `.gitignore`
- ✅ Rate Limiting zum Schutz vor Missbrauch
- ✅ CORS-Unterstützung konfigurierbar
- ✅ Keine sensitiven Daten im Code

## 📁 Projektstruktur

```
currency_gold_application/
├── lib/                    # Flutter App Code
│   ├── config.dart        # Zentrale Konfiguration
│   ├── main.dart          # App Entry Point
│   ├── currency_tab.dart  # Währungs-Tab
│   ├── gold_tab.dart      # Gold-Tab
│   └── chart_tab.dart     # Chart-Tab (optional)
├── server/                # Backend Server
│   ├── server.js         # Express Server mit Caching
│   ├── .env.example      # Environment Template
│   ├── package.json      # Node Dependencies
│   └── vercel.json       # Vercel Config
├── DEPLOYMENT.md         # Deployment Guide
└── README.md            # Diese Datei
```

## 🤝 Support

Bei Fragen oder Problemen:
1. Siehe [DEPLOYMENT.md](DEPLOYMENT.md) für Deployment-Hilfe
2. Prüfe die Server-Logs
3. Teste den `/health` Endpoint

## 📝 Lizenz

Dieses Projekt ist ein privates Projekt.

