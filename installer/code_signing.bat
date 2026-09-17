@echo off
REM ===========================================================================
REM  M116 - Firma digital (code signing) del ejecutable y del instalador - RF8
REM
REM  Requiere: Windows SDK (signtool.exe) y un certificado .pfx emitido por una
REM  autoridad de confianza (DigiCert, Sectigo, ...). Sin certificado, el
REM  instalador funciona pero Windows SmartScreen avisara al usuario.
REM
REM  Uso:
REM    set CERT_PFX=C:\ruta\certificado.pfx
REM    set CERT_PASSWORD=secreto
REM    installer\code_signing.bat --todos
REM    installer\code_signing.bat ruta\a\un.exe
REM
REM  Codigos de salida: 0 = OK | 1 = falta configuracion | 2 = signtool fallo.
REM ===========================================================================
setlocal EnableExtensions

set "TIMESTAMP_URL=http://timestamp.digicert.com"
set "TIMESTAMP_URL_FB=http://timestamp.sectigo.com"

if "%~1"=="" goto :uso

if not defined CERT_PFX (
  echo [ERROR] Falta la variable CERT_PFX ^(ruta al certificado .pfx^).
  exit /b 1
)
if not exist "%CERT_PFX%" (
  echo [ERROR] No existe el certificado: %CERT_PFX%
  exit /b 1
)

where signtool >nul 2>&1
if errorlevel 1 (
  echo [ERROR] signtool.exe no esta en PATH. Instala el Windows SDK.
  exit /b 1
)

if /I "%~1"=="--todos" (
  call :firmar "..\game\build\windows\isla-ancestral.exe"
  if errorlevel 1 exit /b 2
  call :firmar "..\game\build\installer\IslaAncestral-Setup.exe"
  if errorlevel 1 exit /b 2
  echo [OK] Firma completada.
  exit /b 0
)

call :firmar "%~1"
if errorlevel 1 exit /b 2
echo [OK] Firma completada.
exit /b 0

:firmar
if not exist "%~1" (
  echo [AVISO] No existe el archivo a firmar: %~1
  exit /b 0
)
echo [INFO] Firmando %~1
signtool sign /f "%CERT_PFX%" /p "%CERT_PASSWORD%" /fd SHA256 ^
  /tr "%TIMESTAMP_URL%" /td SHA256 "%~1"
if errorlevel 1 (
  echo [AVISO] Timestamp con DigiCert fallo; se reintenta con Sectigo...
  signtool sign /f "%CERT_PFX%" /p "%CERT_PASSWORD%" /fd SHA256 ^
    /tr "%TIMESTAMP_URL_FB%" /td SHA256 "%~1"
  if errorlevel 1 (
    echo [ERROR] signtool fallo al firmar %~1
    exit /b 1
  )
)
signtool verify /pa "%~1" >nul 2>&1
if errorlevel 1 (
  echo [AVISO] La verificacion de firma no paso ^(normal sin cadena de confianza^).
)
exit /b 0

:uso
echo Uso: code_signing.bat ^<archivo.exe^> ^| --todos
echo Requiere las variables de entorno CERT_PFX y CERT_PASSWORD.
exit /b 1
