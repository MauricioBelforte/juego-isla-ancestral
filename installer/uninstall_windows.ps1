<#
    M116 - Desinstalador de Isla Ancestral (Windows, user-space)

    Elimina una instalacion hecha por setup_windows.ps1: shortcuts, directorio de
    instalacion y la entrada de desinstalacion en el registro (HKCU).

    Por defecto CONSERVA los datos del usuario (savegames y configuracion), que
    viven en %APPDATA%\Godot\app_userdata\, no en el directorio de instalacion.
    Usa -PurgeUserData para eliminarlos tambien (opt-in explicito).

    Cubre: RF4 (desinstalador), RF11 (desinstalacion completa).

    Uso:
      powershell -ExecutionPolicy Bypass -File installer\uninstall_windows.ps1 -DryRun
      powershell -ExecutionPolicy Bypass -File installer\uninstall_windows.ps1 -Force
      powershell -ExecutionPolicy Bypass -File installer\uninstall_windows.ps1 -Force -PurgeUserData

    Codigos de salida: 0 = OK | 1 = cancelado por el usuario | 2 = error inesperado.
#>
[CmdletBinding()]
param(
    [string]$InstallDir = "",
    [switch]$KeepUserData,
    [switch]$PurgeUserData,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$Script:Errores = 0
$Script:Acciones = 0

$APP = "IslaAncestral"
$APP_NOMBRE = "Isla Ancestral"
$PROYECTO = "isla-ancestral"

function Escribir-Paso { param([string]$Texto) Write-Host ("  " + $Texto) }

function Escribir-Accion {
    param([string]$Texto)
    $Script:Acciones++
    $prefijo = if ($DryRun) { "[DRY-RUN] " } else { "[OK]      " }
    Write-Host ("  " + $prefijo + $Texto)
}

function Escribir-Aviso { param([string]$Texto) Write-Host ("  [AVISO]   " + $Texto) -ForegroundColor Yellow }

function Escribir-Fallo {
    param([string]$Texto)
    $Script:Errores++
    Write-Host ("  [ERROR]   " + $Texto) -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Isla Ancestral - Desinstalador (M116) ===" -ForegroundColor Cyan
if ($DryRun) { Write-Host "MODO SIMULACION: no se modifica nada." -ForegroundColor Yellow }
Write-Host ""

if ([string]::IsNullOrWhiteSpace($InstallDir)) {
    # No usar $env:LOCALAPPDATA: puede venir nulo segun el host y Join-Path aborta
    # el script entero (detectado en el smoke test). GetFolderPath es fiable.
    $InstallDir = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) $APP
}
$InstallDir = [System.IO.Path]::GetFullPath($InstallDir)
$datosUsuario = Join-Path ([Environment]::GetFolderPath("ApplicationData")) ("Godot\app_userdata\" + $PROYECTO)

Escribir-Paso ("Instalacion: " + $InstallDir)
Escribir-Paso ("Datos:       " + $datosUsuario)
Write-Host ""

# ----------------------------------------------------------- Confirmacion
if (-not $Force -and -not $DryRun) {
    $respuesta = Read-Host ("Se eliminara la instalacion en " + $InstallDir + ". Continuar? (s/N)")
    if ($respuesta -notmatch '^[sSyY]$') {
        Write-Host "Desinstalacion cancelada por el usuario." -ForegroundColor Yellow
        exit 1
    }
}

# ------------------------------------------------------------- Shortcuts
Write-Host "-- Shortcuts --"
$destinoEscritorio = Join-Path ([Environment]::GetFolderPath("Desktop")) ($APP_NOMBRE + ".lnk")
$menuInicio = Join-Path ([Environment]::GetFolderPath("Programs")) $APP_NOMBRE
$destinoMenu = Join-Path $menuInicio ($APP_NOMBRE + ".lnk")

foreach ($lnk in @($destinoEscritorio, $destinoMenu)) {
    if (Test-Path -LiteralPath $lnk) {
        if ($DryRun) {
            Escribir-Accion ("eliminar shortcut " + $lnk)
        } else {
            Remove-Item -LiteralPath $lnk -Force
            Escribir-Accion ("shortcut eliminado: " + (Split-Path -Leaf $lnk))
        }
    }
}
if (Test-Path -LiteralPath $menuInicio -PathType Container) {
    $resto = @(Get-ChildItem -LiteralPath $menuInicio -Force)
    if ($resto.Count -eq 0) {
        if ($DryRun) {
            Escribir-Accion ("eliminar carpeta de menu " + $menuInicio)
        } else {
            Remove-Item -LiteralPath $menuInicio -Force -Recurse
            Escribir-Accion "carpeta de menu de inicio eliminada"
        }
    }
}

# -------------------------------------------------- Registro (HKCU)
Write-Host ""
Write-Host "-- Registro --"
$claveUninstall = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" + $APP
if (Test-Path -LiteralPath $claveUninstall) {
    if ($DryRun) {
        Escribir-Accion ("eliminar clave " + $claveUninstall)
    } else {
        Remove-Item -LiteralPath $claveUninstall -Force -Recurse
        Escribir-Accion "entrada de desinstalacion eliminada del registro"
    }
} else {
    Escribir-Aviso "no habia entrada de desinstalacion en el registro"
}

# ------------------------------------------------------- Directorio
Write-Host ""
Write-Host "-- Archivos del juego --"
if (Test-Path -LiteralPath $InstallDir -PathType Container) {
    if ($DryRun) {
        $n = @(Get-ChildItem -LiteralPath $InstallDir -Recurse -Force).Count
        Escribir-Accion ("eliminar " + $InstallDir + " (" + $n + " elemento(s))")
    } else {
        Remove-Item -LiteralPath $InstallDir -Force -Recurse
        Escribir-Accion "directorio de instalacion eliminado"
    }
} else {
    Escribir-Aviso ("no existe el directorio de instalacion: " + $InstallDir)
}

# --------------------------------------------------- Datos del usuario
Write-Host ""
Write-Host "-- Datos del usuario --"
if ($PurgeUserData) {
    if (Test-Path -LiteralPath $datosUsuario -PathType Container) {
        if ($DryRun) {
            Escribir-Accion ("eliminar datos de usuario " + $datosUsuario)
        } else {
            Remove-Item -LiteralPath $datosUsuario -Force -Recurse
            Escribir-Accion "savegames y configuracion eliminados (-PurgeUserData)"
        }
    } else {
        Escribir-Aviso "no hay datos de usuario que eliminar"
    }
} else {
    Escribir-Accion ("conservados: " + $datosUsuario)
    Escribir-Paso "usa -PurgeUserData si quieres eliminarlos"
}

# --------------------------------------------------------------- Resumen
Write-Host ""
Write-Host ("Acciones: " + $Script:Acciones + " | Errores: " + $Script:Errores) -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "Simulacion completada: no se modifico el sistema." -ForegroundColor Yellow
} else {
    Write-Host "Desinstalacion completada." -ForegroundColor Green
}
exit 0
