# 🔍 Debug-Guide - Serveranbindung testen

Dieser Guide hilft dir, Verbindungsprobleme zwischen Flutter App und Server zu finden.

## 🎯 Schritt 1: Server-Status prüfen

### A) Läuft der Server überhaupt?

```powershell
# Im server/ Verzeichnis
cd server
npm start
```

**Erwartete Ausgabe:**
```
╔═══════════════════════════════════════════════╗
║   Currency & Gold Server                      ║
║   Running on: http://localhost:3000           ║
║   Cache Duration: 300s (rates), 600s (gold)   ║
║   Rate Limit: 30 req/min                      ║
╚═══════════════════════════════════════════════╝
```

✅ Wenn das erscheint → Server läuft!
❌ Wenn Fehler erscheinen → Siehe unten

### B) Test die Endpoints direkt

**Option 1: Im Browser**

Öffne im Browser:
- Health Check: http://localhost:3000/health
- Währungen: http://localhost:3000/rates
- Gold: http://localhost:3000/gold

**Option 2: PowerShell**

```powershell
# Test 1: Health Check
curl http://localhost:3000/health

# Test 2: Gold Endpoint
curl http://localhost:3000/gold

# Test 3: Rates Endpoint
curl http://localhost:3000/rates
```

**Erwartetes Ergebnis (Health):**
```json
{"status":"ok","timestamp":"2026-02-08T..."}
```

**Erwartetes Ergebnis (Gold):**
```json
{
  "coins": {
    "Gramm": {
      "weight": 1,
      "karat": 24,
      "USD": { "spot": 59.12, "dealer": 61.48 },
      ...
    }
  }
}
```

## 🎯 Schritt 2: Flutter App Config prüfen

### A) Prüfe die Config

Öffne `lib/config.dart` und schaue dir an:

```dart
static const String _devApiBaseUrl = 'http://192.168.178.42:3000';
```

**Problem-Check:**
- ❌ Läuft die App auf einem echten Handy? → Handy muss im gleichen WLAN sein!
- ❌ Ist die IP-Adresse korrekt? → Prüfe PC-IP mit `ipconfig`

**Deine PC-IP finden:**

```powershell
ipconfig
```

Suche nach "IPv4-Adresse" bei deinem WLAN-Adapter, z.B.:
```
IPv4-Adresse. . . . . . . . . . : 192.168.178.42
```

### B) Test vom Handy aus

**Im Handy-Browser öffnen:**
```
http://192.168.178.42:3000/health
```

- ✅ Funktioniert → Server ist erreichbar!
- ❌ Timeout → Firewall oder falsches Netzwerk!

## 🎯 Schritt 3: Flutter Debug-Modus

### A) App im Debug-Modus starten

```powershell
flutter run
```

**Schaue in die Console** - du solltest Output sehen wie:

```
Gold Fetch Fehler: ...
Currency Fetch Fehler: ...
```

### B) Besseres Logging aktivieren

Öffne `lib/gold_tab.dart` und ändere temporär:

```dart
Future<void> fetchGold() async {
  print('🔍 START: Fetching gold from ${Config.goldEndpoint}');
  try {
    final res = await http
        .get(Uri.parse(Config.goldEndpoint))
        .timeout(Config.requestTimeout);
    print('✅ Response Status: ${res.statusCode}');
    print('📦 Response Body: ${res.body.substring(0, 100)}...');
    
    final data = jsonDecode(res.body);
    // ... rest des Codes
  } catch (e) {
    print('❌ ERROR: $e');
    print('📍 Stack Trace: ${StackTrace.current}');
    // ...
  }
}
```

Dann neu starten und Logs lesen!

## 🎯 Schritt 4: Häufige Probleme & Lösungen

### Problem 1: "SocketException: Connection refused"

**Bedeutet:** Server ist nicht erreichbar

**Lösung:**
```powershell
# 1. Server läuft nicht → Starte ihn:
cd server
npm start

# 2. Falsche IP in config.dart → Ändere zu deiner PC-IP

# 3. Firewall blockiert → Windows Firewall:
# Systemsteuerung → Windows Defender Firewall → App zulassen
# → Node.js zulassen für Private Netzwerke
```

### Problem 2: "TimeoutException after 10 seconds"

**Bedeutet:** Server antwortet nicht schnell genug

**Lösung:**
```powershell
# 1. Prüfe Server-Logs (zeigt es "Gold Request empfangen..."?)

# 2. Test direkt im Browser:
# http://localhost:3000/gold
# Wie lange dauert es?

# 3. API-Key gesetzt?
cd server
# Prüfe .env Datei
cat .env
```

### Problem 3: "Connection timed out" (vom Handy)

**Bedeutet:** Handy kann Server nicht erreichen

**Checkliste:**
- [ ] Handy im gleichen WLAN wie PC?
- [ ] PC-Firewall erlaubt Port 3000?
- [ ] Korrekte IP-Adresse in `config.dart`?

**Firewall Rule erstellen:**

```powershell
# Als Administrator ausführen
netsh advfirewall firewall add rule name="Node.js Server" dir=in action=allow protocol=TCP localport=3000
```

### Problem 4: Unendliches Laden, keine Fehlermeldung

**Mögliche Ursachen:**

1. **Development Mode vs Production Mode**

```dart
// Prüfe in config.dart:
static const bool isDevelopment = bool.fromEnvironment('DEVELOPMENT', defaultValue: true);

// Sollte TRUE sein für lokale Tests!
```

Falls FALSE, nutzt die App die Production URL!

2. **Cache Problem**

Lösche App-Daten komplett:
```powershell
flutter clean
flutter pub get
flutter run
```

3. **HTTP vs HTTPS Problem**

Android blockiert HTTP in Production. Füge hinzu in:

`android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

## 🎯 Schritt 5: Vollständiger Test-Flow

```powershell
# 1. Server starten
cd server
npm start

# Neues Terminal öffnen:

# 2. Test Endpoints
curl http://localhost:3000/health
curl http://localhost:3000/gold

# 3. PC-IP finden
ipconfig
# Notiere IPv4-Adresse, z.B. 192.168.178.42

# 4. In lib/config.dart prüfen/ändern
# static const String _devApiBaseUrl = 'http://192.168.178.42:3000';

# 5. Flutter App starten
flutter run

# 6. In Flutter Console schauen:
# Siehst du Fehler? "Gold Fetch Fehler: ..."?

# 7. Vom Handy-Browser testen
# http://192.168.178.42:3000/health
# Geht das?
```

## 🎯 Schritt 6: Network Inspector nutzen

### In Flutter verwenden

Füge Logging temporär hinzu:

```dart
// Am Anfang von gold_tab.dart
import 'dart:developer' as developer;

// In fetchGold():
developer.log('Requesting: ${Config.goldEndpoint}', name: 'GoldTab');
```

Dann in VS Code:
1. **Debug Console** öffnen
2. Filter auf "GoldTab" setzen
3. Requests anschauen

## 🎯 Schritt 7: Server-Logs live anschauen

```powershell
# Server mit mehr Logging starten
cd server
npm start
```

Während die App lädt, solltest du sehen:

```
Gold Request empfangen...
Fetching fresh gold data...
GoldAPI Response: { price: 2456.78, ... }
Goldpreis gespeichert: 2026-02-08
```

Falls NICHTS erscheint → App erreicht Server NICHT!

## 🔧 Quick Fix: Test-Server Script

Erstelle `server/test-local.js`:

```javascript
const http = require('http');

http.get('http://localhost:3000/health', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log('✅ Server erreichbar!');
    console.log('Response:', data);
  });
}).on('error', (err) => {
  console.log('❌ Server NICHT erreichbar!');
  console.log('Fehler:', err.message);
});
```

Test:
```powershell
node server/test-local.js
```

## 📊 Checkliste Zusammenfassung

- [ ] Server läuft (`npm start` im server/ Ordner)
- [ ] Health-Endpoint antwortet (Browser: `http://localhost:3000/health`)
- [ ] Gold-Endpoint antwortet (Browser: `http://localhost:3000/gold`)
- [ ] PC-IP-Adresse ist korrekt in `lib/config.dart`
- [ ] Handy ist im gleichen WLAN wie PC
- [ ] Firewall erlaubt Port 3000
- [ ] `android:usesCleartextTraffic="true"` in AndroidManifest.xml
- [ ] GOLD_API_KEY ist in `server/.env` gesetzt
- [ ] App läuft im Development Mode (`isDevelopment = true`)
- [ ] Flutter Console zeigt Logs/Fehler

## 🆘 Immer noch Probleme?

**Erstelle einen Issue-Report:**

```powershell
# 1. Server-Status
curl http://localhost:3000/health

# 2. PC-IP
ipconfig | findstr IPv4

# 3. Flutter Config
cat lib/config.dart | findstr apiBaseUrl

# 4. Server läuft?
netstat -ano | findstr :3000

# 5. Flutter Logs
flutter run > debug.log 2>&1
```

Sende mir diese Infos und ich kann gezielter helfen! 🚀
