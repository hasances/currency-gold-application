# 🎯 Git & GitHub Setup - Schritt für Schritt

Diese Anleitung zeigt dir, wie du dein Projekt auf GitHub hochlädst und mit Render verbindest.

## Schritt 1: Überprüfe Git Installation

```powershell
git --version
```

Falls Git nicht installiert ist: https://git-scm.com/download/win

## Schritt 2: Git Repository initialisieren

```powershell
# Im Projekt-Hauptverzeichnis
cd "c:\Users\Sena\Documents\flutter_Projekte\MoneyExchanger_Flutter\Curreny_Gold\currency_gold_application"

# Git initialisieren
git init

# Überprüfe Status
git status
```

## Schritt 3: Dateien zum Repository hinzufügen

```powershell
# WICHTIG: Erst .env Datei sichern!
# Die .env wird NICHT committed (ist in .gitignore)

# Alle Dateien hinzufügen
git add .

# Status prüfen (sollte .env NICHT enthalten!)
git status
```

**⚠️ WICHTIG**: Stelle sicher, dass `.env` NICHT in der Liste erscheint!

## Schritt 4: Ersten Commit erstellen

```powershell
# Commit mit aussagekräftiger Message
git commit -m "Initial commit: Currency & Gold Application mit Cloud-Support"
```

## Schritt 5: GitHub Repository erstellen

### Option A: Über GitHub Website

1. Gehe zu https://github.com/
2. Klicke auf **"New Repository"** (grüner Button)
3. Einstellungen:
   ```
   Repository name: currency-gold-application
   Description: Flutter Currency & Gold Tracker with Cloud Backend
   Visibility: Public (oder Private)
   ```
4. **WICHTIG**: Wähle KEINE der Checkboxen:
   - ❌ Add a README file
   - ❌ Add .gitignore
   - ❌ Choose a license
   
   (Du hast diese Dateien bereits!)

5. Klicke auf **"Create repository"**

### Option B: Mit GitHub CLI

```powershell
# GitHub CLI installieren: https://cli.github.com/
gh repo create currency-gold-application --public --source=. --remote=origin
```

## Schritt 6: Lokales Repository mit GitHub verbinden

GitHub zeigt dir nach dem Erstellen diese Befehle. Nutze die zweite Variante:

```powershell
# WICHTIG: Ersetze 'dein-username' mit deinem GitHub Username!
git remote add origin https://github.com/dein-username/currency-gold-application.git

# Branch umbenennen (falls nötig)
git branch -M main

# Zu GitHub pushen
git push -u origin main
```

## Schritt 7: Überprüfe GitHub

1. Gehe zu https://github.com/dein-username/currency-gold-application
2. Du solltest alle Dateien sehen
3. **Überprüfe**: Die `.env` Datei sollte **NICHT** sichtbar sein!

## Schritt 8: Mit Render verbinden

### Variante A: Automatisches Deployment

1. Gehe zu https://render.com/
2. Melde dich an (kann mit GitHub-Account verbunden werden)
3. Klicke auf **"New +"** → **"Web Service"**
4. Klicke auf **"Connect GitHub"** (wenn noch nicht connected)
5. Wähle dein Repository: `currency-gold-application`
6. Render erkennt automatisch die `render.yaml` Konfiguration!
7. Setze die Environment Variable:
   ```
   GOLD_API_KEY = [Dein API Key von goldapi.io]
   ```
8. Klicke auf **"Create Web Service"**

### Variante B: Manuelle Konfiguration

Falls Render die `render.yaml` nicht automatisch erkennt:

1. **New Web Service** → GitHub Repo auswählen
2. Einstellungen:
   ```
   Name: currency-gold-server
   Region: Frankfurt (EU Central)
   Branch: main
   Root Directory: server
   Build Command: npm install
   Start Command: node server.js
   ```
3. Environment Variables:
   ```
   GOLD_API_KEY = [Dein API Key]
   ```
4. **Create Web Service**

## ✅ Deployment läuft!

⏱️ Warte 2-3 Minuten. Render wird:
1. Repository klonen
2. Dependencies installieren
3. Server starten
4. URL bereitstellen

Deine Server-URL: `https://currency-gold-server-xxxx.onrender.com`

## 🔄 Spätere Updates deployen

Wenn du Code änderst:

```powershell
# Änderungen hinzufügen
git add .

# Commit erstellen
git commit -m "Beschreibung deiner Änderung"

# Zu GitHub pushen
git push

# 🎉 Render deployed automatisch!
```

## 🛡️ Sicherheits-Checkliste

Vor dem ersten Push überprüfen:

- [ ] `.env` ist in `.gitignore` (✅ bereits vorhanden)
- [ ] `server/.env` existiert lokal ABER wird nicht committed
- [ ] `node_modules/` wird nicht committed (✅ in .gitignore)
- [ ] Keine API-Keys im Code sichtbar
- [ ] `.env.example` ist committed (✅ als Template)

## 📋 Nützliche Git Befehle

```powershell
# Status prüfen
git status

# Änderungen anzeigen
git diff

# Commit-Historie anzeigen
git log --oneline

# Remote URL prüfen
git remote -v

# Branch anzeigen
git branch

# Zu GitHub pushen
git push
```

## 🆘 Häufige Probleme

### Problem: "fatal: remote origin already exists"

```powershell
# Remote entfernen und neu hinzufügen
git remote remove origin
git remote add origin https://github.com/dein-username/currency-gold-application.git
```

### Problem: ".env ist in Git!"

```powershell
# .env aus Git entfernen (bleibt lokal)
git rm --cached server/.env
git commit -m "Remove .env from git"
git push
```

### Problem: "Everything up-to-date" aber Render deployed nicht

```powershell
# Erzwinge Render Redeploy
git commit --allow-empty -m "Trigger Render redeploy"
git push
```

### Problem: Authentication Failed

**GitHub Personal Access Token** erstellen:
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Wähle Scopes: `repo`, `workflow`
4. Token kopieren
5. Beim Push das Token statt Passwort verwenden

## 📚 Weiter mit

Nach erfolgreichem Deployment:
- Kopiere die Render-URL
- Öffne `lib/config.dart` in Flutter
- Ersetze `_prodApiBaseUrl` mit deiner URL
- Baue Production APK: `flutter build apk --dart-define=DEVELOPMENT=false`

Siehe [QUICKSTART.md](QUICKSTART.md) für Flutter-Konfiguration.

## 🎉 Geschafft!

Dein Projekt ist jetzt:
- ✅ Auf GitHub gesichert
- ✅ Versioniert
- ✅ Auf Render deployed
- ✅ Automatisch bei jedem Push aktualisiert

**Nächster Schritt**: Flutter App mit der Render-URL verbinden! 🚀
