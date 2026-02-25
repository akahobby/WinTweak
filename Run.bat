@echo off
setlocal

set "script=%~dp0Win11Debloat.ps1"

echo.
echo Launching Win11Reclaim...
echo (Make sure you ran this .bat as Administrator.)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%script%"
set "exitCode=%ERRORLEVEL%"

echo.
echo Win11Reclaim finished with exit code %exitCode%.
echo Press any key to close this window...
pause >nul

endlocal