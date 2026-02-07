@echo off
cd server
start cmd /k "npm start"
cd ..
flutter run -d chrome
pause
