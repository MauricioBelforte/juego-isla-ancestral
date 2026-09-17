<#
    M116 - Instalador de Isla Ancestral (Windows, user-space)

    Instala el build exportado del juego en %LocalAppData%\IslaAncestral sin
    requerir permisos de administrador.

    Cubre: RF2 (instalador), RF3 (directorio de instalacion), RF5 (shortcuts),
    RF7 (permisos: user-space, sin UAC), RF11 (desinstalacion via
    uninstall_windows.ps1) y RF12 (validacion de instalacion limpia).

    Uso:
      powershell -ExecutionPolicy Bypass -File installer\setup_windows.ps1 -DryRun
      powershell -ExecutionPolicy Bypass -File installer\setup_windows.ps1
      powershell -ExecutionPolicy Bypass -File installer\setup_windows.ps1 -InstallDir "D:\Juegos\IslaAncestral" -NoShortcuts

    Codigos de salida: 0 = OK | 1 = validacion fallida | 2 = error inesperado.
#>
[CmdletBinding()]
param(
    [string]$BuildDir = "",
    [string]$InstallDir = "",
    [switch]$NoShortcuts,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$Script:Errores = 0
$Script:Acciones = 0

$EXE = "isla-ancestral.exe"
$PCK = "isla-ancestral.pck"
$APP = "IslaAncestral"
$APP_NOMBRE = "Isla Ancestral"
$MIN_BYTES = 512MB

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

function Leer-VersionProyecto {
    param([string]$RepoRoot)
    $ruta = Join-Path $RepoRoot "game\isla-ancestral\project.godot"
    if (-not (Test-Path -LiteralPath $ruta)) { return "" }
    foreach ($linea in (Get-Content -LiteralPath $ruta)) {
        if ($linea -match '^config/version="([^"]+)"') { return $Matches[1] }
    }
    return ""
}

function Espacio-Libre {
    param([string]$Ruta)
    try {
        $raiz = [System.IO.Path]::GetPathRoot([System.IO.Path]::GetFullPath($Ruta))
        $unidad = New-Object System.IO.DriveInfo($raiz)
        return [int64]$unidad.AvailableFreeSpace
    } catch {
        return -1
    }
}

Write-Host ""
Write-Host "=== Isla Ancestral - Instalador (M116) ===" -ForegroundColor Cyan
if ($DryRun) { Write-Host "MODO SIMULACION: no se modifica nada." -ForegroundColor Yellow }
Write-Host ""

# ---------------------------------------------------------------- 1. Rutas
$RepoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($BuildDir)) {
    # Coherente con el preset "Windows" de export_presets.cfg (export_path=../build/windows/).
    $BuildDir = Join-Path $RepoRoot "game\build\windows"
}
if ([string]::IsNullOrWhiteSpace($InstallDir)) {
    # No usar $env:LOCALAPPDATA: puede venir nulo segun el host y Join-Path aborta
    # el script entero (detectado en el smoke test). GetFolderPath es fiable.
    $InstallDir = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) $APP
}
$BuildDir = [System.IO.Path]::GetFullPath($BuildDir)
$InstallDir = [System.IO.Path]::GetFullPath($InstallDir)

Escribir-Paso ("Repo:      " + $RepoRoot)
Escribir-Paso ("Build:     " + $BuildDir)
Escribir-Paso ("Instalar:  " + $InstallDir)
Write-Host ""

# --------------------------------------------------- 2. Validacion del build
Write-Host "-- Validacion del build --"
if (-not (Test-Path -LiteralPath $BuildDir -PathType Container)) {
    Escribir-Fallo ("No existe el directorio de build: " + $BuildDir)
    Escribir-Paso "Ejecuta primero el build de M117 (export del preset 'Windows')."
    exit 1
}

$rutaExe = Join-Path $BuildDir $EXE
if (-not (Test-Path -LiteralPath $rutaExe -PathType Leaf)) {
    Escribir-Fallo ("Falta el ejecutable critico: " + $EXE)
    exit 1
}
$tamExe = (Get-Item -LiteralPath $rutaExe).Length
if ($tamExe -le 0) {
    Escribir-Fallo ("El ejecutable esta vacio: " + $EXE)
    exit 1
}
Escribir-Accion ("ejecutable valido (" + [math]::Round($tamExe / 1MB, 2) + " MB)")

$rutaPck = Join-Path $BuildDir $PCK
if (Test-Path -LiteralPath $rutaPck -PathType Leaf) {
    Escribir-Accion ("paquete de assets presente (" + $PCK + ")")
} else {
    # Con binary_format/embed_pck=true el .pck va embebido en el .exe: no es un error.
    Escribir-Aviso ("no hay " + $PCK + " suelto; se asume .pck embebido en el .exe")
}

$version = Leer-VersionProyecto -RepoRoot $RepoRoot
if ([string]::IsNullOrWhiteSpace($version)) {
    Escribir-Aviso "no se pudo leer config/version de project.godot"
} else {
    Escribir-Accion ("version del proyecto: " + $version)
}

# ---------------------------------------------- 3. Requisitos del sistema
Write-Host ""
Write-Host "-- Requisitos del sistema --"
$so = [System.Environment]::OSVersion.Version
if ($so.Major -ge 10) {
    Escribir-Accion ("Windows " + $so.Major + "." + $so.Minor + " compatible")
} else {
    Escribir-Fallo ("Se requiere Windows 10 o superior (detectado " + $so.Major + "." + $so.Minor + ")")
}
# NOTA: no usar $env:PROCESSOR_ARCHITECTURE — puede venir vacio segun el host
# (detectado en el smoke test: abortaba en un sistema x64 valido). Se usan las
# APIs de .NET, que son fiables.
if ([System.Environment]::Is64BitOperatingSystem) {
    $bits = if ([System.Environment]::Is64BitProcess) { "proceso 64-bit" } else { "proceso 32-bit" }
    Escribir-Accion ("sistema x64 compatible (" + $bits + ")")
} else {
    Escribir-Fallo "se requiere un sistema operativo x64"
}

$libre = Espacio-Libre -Ruta $InstallDir
if ($libre -lt 0) {
    Escribir-Aviso "no se pudo determinar el espacio libre"
} elseif ($libre -lt $MIN_BYTES) {
    Escribir-Fallo ("espacio insuficiente: " + [math]::Round($libre / 1MB, 1) + " MB (minimo 512 MB)")
} else {
    Escribir-Accion ("espacio libre suficiente (" + [math]::Round($libre / 1MB, 1) + " MB)")
}

if ($Script:Errores -gt 0) {
    Write-Host ""
    Write-Host ("Instalacion abortada: " + $Script:Errores + " error(es).") -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------ 4. Copia de archivos
Write-Host ""
Write-Host "-- Instalacion --"
if (-not (Test-Path -LiteralPath $InstallDir -PathType Container)) {
    if ($DryRun) {
        Escribir-Accion ("crear directorio " + $InstallDir)
    } else {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Escribir-Accion ("directorio creado: " + $InstallDir)
    }
} else {
    Escribir-Accion "directorio de instalacion ya existe (actualizacion/reparacion)"
}

$copiados = 0
foreach ($f in (Get-ChildItem -LiteralPath $BuildDir -File -Recurse)) {
    $rel = $f.FullName.Substring($BuildDir.Length).TrimStart("\")
    $destino = Join-Path $InstallDir $rel
    $padre = Split-Path -Parent $destino
    if ($DryRun) {
        Escribir-Accion ("copiar " + $rel)
    } else {
        if (-not (Test-Path -LiteralPath $padre -PathType Container)) {
            New-Item -ItemType Directory -Path $padre -Force | Out-Null
        }
        Copy-Item -LiteralPath $f.FullName -Destination $destino -Force
    }
    $copiados++
}
Escribir-Accion ($copiados.ToString() + " archivo(s) copiados")

# ------------------------------------------------------------ 5. Shortcuts
$rutaExeInstalado = Join-Path $InstallDir $EXE
if (-not $NoShortcuts) {
    Write-Host ""
    Write-Host "-- Shortcuts --"
    $destinoEscritorio = Join-Path ([Environment]::GetFolderPath("Desktop")) ($APP_NOMBRE + ".lnk")
    $menuInicio = Join-Path ([Environment]::GetFolderPath("Programs")) $APP_NOMBRE
    $destinoMenu = Join-Path $menuInicio ($APP_NOMBRE + ".lnk")

    if ($DryRun) {
        Escribir-Accion ("shortcut escritorio: " + $destinoEscritorio)
        Escribir-Accion ("shortcut menu inicio: " + $destinoMenu)
    } else {
        $shell = New-Object -ComObject WScript.Shell
        foreach ($destino in @($destinoEscritorio, $destinoMenu)) {
            $padre = Split-Path -Parent $destino
            if (-not (Test-Path -LiteralPath $padre -PathType Container)) {
                New-Item -ItemType Directory -Path $padre -Force | Out-Null
            }
            $lnk = $shell.CreateShortcut($destino)
            $lnk.TargetPath = $rutaExeInstalado
            $lnk.WorkingDirectory = $InstallDir
            $lnk.Description = $APP_NOMBRE
            $lnk.Save()
        }
        Escribir-Accion "shortcuts creados (escritorio + menu de inicio)"
    }
} else {
    Escribir-Aviso "shortcuts omitidos (-NoShortcuts)"
}

# ------------------------------------------- 6. Registro (desinstalador)
Write-Host ""
Write-Host "-- Registro de desinstalacion --"
$claveUninstall = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" + $APP
$rutaUninstall = Join-Path $InstallDir "uninstall_windows.ps1"
if ($DryRun) {
    Escribir-Accion ("registrar en " + $claveUninstall)
} else {
    if (-not (Test-Path -LiteralPath $claveUninstall)) {
        New-Item -Path $claveUninstall -Force | Out-Null
    }
    New-ItemProperty -Path $claveUninstall -Name "DisplayName"     -Value $APP_NOMBRE -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $claveUninstall -Name "DisplayVersion"  -Value $version     -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $claveUninstall -Name "InstallLocation" -Value $InstallDir  -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $claveUninstall -Name "DisplayIcon"     -Value $rutaExeInstalado -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $claveUninstall -Name "Publisher"       -Value $APP_NOMBRE -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $claveUninstall -Name "NoModify"        -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $claveUninstall -Name "NoRepair"        -Value 1 -PropertyType DWord -Force | Out-Null
    $cmd = 'powershell.exe -ExecutionPolicy Bypass -File "' + $rutaUninstall + '"'
    New-ItemProperty -Path $claveUninstall -Name "UninstallString" -Value $cmd -PropertyType String -Force | Out-Null
    Escribir-Accion "entrada de desinstalacion registrada en HKCU (sin admin)"
}

# ------------------------------------------------------------ 7. Manifiesto
$rutaManifiesto = Join-Path $InstallDir "install.json"
$manifiesto = [ordered]@{
    app        = $APP_NOMBRE
    version    = $version
    fecha      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    origen     = $BuildDir
    destino    = $InstallDir
    exe        = $EXE
    shortcuts  = (-not $NoShortcuts)
    pck_suelto = (Test-Path -LiteralPath $rutaPck -PathType Leaf)
}
if ($DryRun) {
    Escribir-Accion ("escribir manifiesto " + $rutaManifiesto)
} else {
    ($manifiesto | ConvertTo-Json) | Set-Content -LiteralPath $rutaManifiesto -Encoding UTF8
    Escribir-Accion "manifiesto install.json escrito"
}

# --------------------------------------------------------------- Resumen
Write-Host ""
Write-Host ("Acciones: " + $Script:Acciones + " | Errores: " + $Script:Errores) -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "Simulacion completada: no se modifico el sistema." -ForegroundColor Yellow
} else {
    Write-Host ("Instalacion completada en " + $InstallDir) -ForegroundColor Green
}
exit 0
