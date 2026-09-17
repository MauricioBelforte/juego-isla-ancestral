@echo off
REM ===========================================================================
REM  M116 - Build automation: export Godot -> manifiesto -> firma -> Inno Setup
REM
REM  Encadena el build release (M117), el manifiesto de integridad que consume
REM  installer\repair.iss, la firma (RF8) y la compilacion del instalador.
REM
REM  Uso (desde la raiz del repo):
REM    scripts\build_installer.bat
REM    scripts\build_installer.bat --sin-firma
REM
REM  Codigos de salida: 0 = OK | 1 = error de build | 2 = error de instalador.
REM ===========================================================================
setlocal EnableExtensions

set "REPO=%~dp0.."
set "PROYECTO=%REPO%\game\isla-ancestral"
set "BUILD=%REPO%\game\build\windows"
set "SALIDA=%REPO%\game\build\installer"
set "GODOT=godot"
set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
set "FIRMAR=1"

if /I "%~1"=="--sin-firma" set "FIRMAR=0"

echo === M116 - Build del instalador ===

if not exist "%BUILD%" mkdir "%BUILD%"
if not exist "%SALIDA%" mkdir "%SALIDA%"

echo [1/5] Export release de Godot (preset "Windows")
where %GODOT% >nul 2>&1
if errorlevel 1 (
  echo [ERROR] No se encontro "godot" en PATH. Anade el ejecutable de Godot 4.x.
  exit /b 1
)
"%GODOT%" --headless --path "%PROYECTO%" --export-release "Windows" "%BUILD%\isla-ancestral.exe"
if errorlevel 1 (
  echo [ERROR] El export de Godot fallo.
  exit /b 1
)
if not exist "%BUILD%\isla-ancestral.exe" (
  echo [ERROR] El export no genero isla-ancestral.exe.
  exit /b 1
)

echo [2/5] Manifiesto de integridad (install_manifest.txt)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop'; $b='%BUILD%'; $l=@(); Get-ChildItem -LiteralPath $b -File -Recurse | ForEach-Object { $l += ($_.FullName.Substring($b.Length).TrimStart('\') + '|' + $_.Length) }; Set-Content -LiteralPath (Join-Path $b 'install_manifest.txt') -Value $l -Encoding ASCII; Write-Host ('  ' + $l.Count + ' archivo(s) en el manifiesto')"
if errorlevel 1 (
  echo [ERROR] No se pudo generar el manifiesto.
  exit /b 1
)

if "%FIRMAR%"=="1" (
  echo [3/5] Firma del ejecutable
  call "%~dp0..\installer\code_signing.bat" "%BUILD%\isla-ancestral.exe"
  if errorlevel 1 (
    echo [AVISO] Firma omitida o fallida; se continua sin firmar.
  )
) else (
  echo [3/5] Firma omitida (--sin-firma)
)

echo [4/5] Compilacion del instalador (Inno Setup)
if not exist "%ISCC%" (
  echo [ERROR] No se encontro ISCC.exe en "%ISCC%".
  echo         Instala Inno Setup 6: https://jrsoftware.org/isdl.php
  exit /b 2
)
"%ISCC%" "%~dp0..\installer\IslaAncestral.iss"
if errorlevel 1 (
  echo [ERROR] La compilacion del instalador fallo.
  exit /b 2
)

if "%FIRMAR%"=="1" (
  echo [5/5] Firma del instalador
  call "%~dp0..\installer\code_signing.bat" "%SALIDA%\IslaAncestral-Setup.exe"
)

echo.
echo === Build completado ===
echo Instalador: %SALIDA%
exit /b 0
