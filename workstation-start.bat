@echo off
echo Lancement des applications...

:: Ouvre Visual Studio Code
start "" "C:\Users\%USERNAME%\AppData\Local\Programs\Microsoft VS Code\Code.exe"

:: Ouvre Responsively
start "" "C:\Users\%USERNAME%\AppData\Local\Programs\ResponsivelyApp\ResponsivelyApp.exe"

echo Toutes les applications ont été lancées.
pause
