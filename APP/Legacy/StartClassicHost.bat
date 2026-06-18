@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

:: Задаем заголовок для легаси
title WEB SERVER (Legacy Mode)

cls
echo ==================================================
echo         ЗАПУСК ЛЕГАСИ ВЕРСИИ (ДЛЯ СТАРЫХ ПК)      
echo ==================================================
echo.

:: Запуск легаси PowerShell скрипта
powershell -NoProfile -NoLogo -ExecutionPolicy Bypass -File "server_classic.ps1"

echo.
echo ==================================================
echo [INFO] Сервер остановлен.
echo ==================================================
pause