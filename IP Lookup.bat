@echo off
chcp 65001
title Ip Lookup Tool
color 4

:menu
cls
echo ███╗   ███╗██╗   ██╗██╗  ████████╗██╗    ████████╗ ██████╗  ██████╗ ██╗     
echo ████╗ ████║██║   ██║██║  ╚══██╔══╝██║    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     
echo ██╔████╔██║██║   ██║██║     ██║   ██║       ██║   ██║   ██║██║   ██║██║     
echo ██║╚██╔╝██║██║   ██║██║     ██║   ██║       ██║   ██║   ██║██║   ██║██║     
echo ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║       ██║   ╚██████╔╝╚██████╔╝███████╗
echo ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝

echo =================================================
echo 1) Exit
echo 2) Ip Geo Lookup
echo 3) Back To Main Menu
echo ================================================
set /p choice=Enter your choice:

if "%choice%"=="1" goto end
if "%choice%"=="2" goto ip_geo_lookup
if "%choice%"=="3" goto menu
goto menu

:ip_geo_lookup
cls
echo ███████╗███╗   ██╗████████╗███████╗██████╗     ██╗██████╗ 
echo ██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗    ██║██╔══██╗
echo █████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝    ██║██████╔╝
echo ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗    ██║██╔═══╝ 
echo ███████╗██║ ╚████║   ██║   ███████╗██║  ██║    ██║██║     
echo ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚═╝╚═╝
echo. ================================================
echo Enter An IP address to lookup (or type back to return to the main menu):
set /p ip=

if "%ip%"=="back" goto menu

:: Check if IP is within the private address ranges
call :is_private_ip %ip%
if %is_private%==1 (
    echo The IP address %ip% is a private address, no geolocation data available.
    pause
    goto ip_geo_lookup
)

:: Fetch the IP geolocation data using curl
curl -s "https://ipinfo.io/%ip%/json" -o geolocation.json

:: Check if the file was created and has content
if exist geolocation.json (
    for /f "delims=" %%a in (geolocation.json) do set output=%%a
    if not defined output (
        echo No geolocation data found for %ip%.
    ) else (
        for /f "tokens=2 delims=:, " %%i in ('findstr "bogon" geolocation.json') do set bogon=%%i
        if "%bogon%"=="true" (
            echo The IP address %ip% is a bogon IP (private or reserved).
        ) else (
            echo ============================================
            echo IP Geolocation for %ip%:
            type geolocation.json
            echo ============================================
        )
    )
) else (
    echo Failed to fetch geolocation data for %ip%.
)

:: Cleanup and return to IP lookup
del geolocation.json
pause
goto ip_geo_lookup

:end
exit

:is_private_ip
:: This subroutine checks if the IP is within the private address ranges
:: Private IP ranges:
:: 10.0.0.0 - 10.255.255.255
:: 172.16.0.0 - 172.31.255.255
:: 192.168.0.0 - 192.168.255.255

setlocal enabledelayedexpansion
set ip=%1
set is_private=0

:: Check for 10.x.x.x range
for /f "tokens=1,2,3,4 delims=." %%a in ("%ip%") do (
    if %%a==10 (
        set is_private=1
    )
)

:: Check for 172.16.x.x - 172.31.x.x range
for /f "tokens=1,2,3,4 delims=." %%a in ("%ip%") do (
    if %%a==172 (
        if %%b geq 16 if %%b leq 31 (
            set is_private=1
        )
    )
)

:: Check for 192.168.x.x range
for /f "tokens=1,2,3,4 delims=." %%a in ("%ip%") do (
    if %%a==192 if %%b==168 (
        set is_private=1
    )
)

endlocal & set is_private=%is_private%
exit /b
