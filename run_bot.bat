@echo off
setlocal
chcp 65001 > nul
title Evrensel IDE Auto-Accept Bot

echo ======================================================
echo    Auto-Accept Bot Baslatiliyor...
echo ======================================================

REM Python yolunu ayarla
if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
    set "PATH=%LOCALAPPDATA%\Programs\Python\Python312;%LOCALAPPDATA%\Programs\Python\Python312\Scripts;%PATH%"
)
if exist "C:\Program Files\Python312\python.exe" (
    set "PATH=C:\Program Files\Python312;C:\Program Files\Python312\Scripts;%PATH%"
)

REM Git yolunu ayarla
if exist "C:\Program Files\Git\cmd" (
    set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"
)
if exist "%LOCALAPPDATA%\Programs\Git\cmd" (
    set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;%PATH%"
)

REM Flutter yolunu ayarla
if exist "D:\src\flutter\bin" (
    set "PATH=D:\src\flutter\bin;%PATH%"
)
if exist "C:\src\flutter\bin" (
    set "PATH=C:\src\flutter\bin;%PATH%"
)
if exist "C:\flutter\bin" (
    set "PATH=C:\flutter\bin;%PATH%"
)


python -c "import win32gui, psutil" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [*] Gerekli paketler yukleniyor: pywin32, psutil...
    python -m pip install -r "%~dp0scripts\requirements_bot.txt"
)

echo [*] Bot baslatildi. Durdurmak icin CTRL+C basin.
python "%~dp0scripts\auto_accept_bot.py" %*

pause
