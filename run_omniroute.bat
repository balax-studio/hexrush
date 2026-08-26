@echo off
setlocal
chcp 65001 > nul
title OmniRoute AI Gateway

echo ======================================================
echo    OmniRoute AI Gateway Baslatiliyor...
echo ======================================================

set "PATH=C:\Program Files\nodejs;%APPDATA%\npm;%PATH%"

echo [*] Port: http://localhost:20128
echo [*] Durdurmak icin CTRL+C basin.
echo.

call "%APPDATA%\npm\omniroute.cmd" serve

if %ERRORLEVEL% NEQ 0 (
    echo [!] OmniRoute baslatilirken bir hata olustu. Hata kodu: %ERRORLEVEL%
)

pause
