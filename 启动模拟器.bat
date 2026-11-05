@echo off
rem Launch Eglantine with Game/ as working directory so all relative paths resolve.
cd /d "%~dp0Game"
if not exist "%~dp0Game\eglantine.exe" (
  echo eglantine.exe not found in Game folder.
  pause
  exit /b 1
)
start "" "%~dp0Game\eglantine.exe"
