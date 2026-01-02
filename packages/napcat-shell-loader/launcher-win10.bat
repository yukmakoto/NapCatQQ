@echo off
chcp 65001
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator mode detected.
) else (
    echo Please run this script in administrator mode.
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c cd /d \"%~dp0\" && \"%~f0\" %1' -Verb runAs" 
    exit
)

set "BASE=%~dp0"
set NAPCAT_PATCH_PACKAGE=%BASE%qqnt.json
set NAPCAT_LOAD_PATH=%BASE%loadNapCat.js
set NAPCAT_INJECT_PATH=%BASE%NapCatWinBootHook.dll
set NAPCAT_LAUNCHER_PATH=%BASE%NapCatWinBootMain.exe
set NAPCAT_MAIN_PATH=%BASE%napcat.mjs

if not exist "%NAPCAT_MAIN_PATH%" (
    echo Cannot find "%NAPCAT_MAIN_PATH%".
    echo You are probably running the loader directory. Please run the built package under packages\\napcat-shell\\dist. Build with: pnpm build:shell:dev
    pause
    exit /b
)
:loop_read
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\QQ" /v "UninstallString"') do (
    set "RetString=%%~b"
    goto :napcat_boot
)

:napcat_boot
for %%a in ("%RetString%") do (
    set "pathWithoutUninstall=%%~dpa"
)

set "QQPath=%pathWithoutUninstall%QQ.exe"

if not exist "%QQPath%" (
    echo provided QQ path is invalid
    pause
    exit /b
)
set NAPCAT_MAIN_PATH=%NAPCAT_MAIN_PATH:\=/%
echo (async () =^> {await import("file:///%NAPCAT_MAIN_PATH%")})() > "%NAPCAT_LOAD_PATH%"

"%NAPCAT_LAUNCHER_PATH%" "%QQPath%" "%NAPCAT_INJECT_PATH%" %1

REM "%NAPCAT_LAUNCHER_PATH%" "%QQPath%" "%NAPCAT_INJECT_PATH%" 123456
