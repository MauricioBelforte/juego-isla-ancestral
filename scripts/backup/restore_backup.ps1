<#
.SYNOPSIS
    Restauración de backups — Módulo M107.

.DESCRIPTION
    Restaura un backup .tar.gz creado por backup_local.ps1 en una carpeta destino.
    Verifica el checksum SHA-256 ANTES de extraer (nunca restaura un backup corrupto).
    Si el backup contiene saves del juego (Godot\app_userdata\<proyecto>), los
    restaura en %APPDATA%\Godot\app_userdata\<proyecto>.

.PARAMETER BackupFile
    Ruta del .tar.gz a restaurar (obligatorio).

.PARAMETER DestinationPath
    Carpeta donde extraer el proyecto (default: D:\Restore\juego-isla-ancestral).
    NOTA de seguridad: nunca restaurar sobre la raíz del proyecto en uso.

.PARAMETER RestoreSaves
    Restaura también los saves del juego en %APPDATA% (sobrescribe los actuales
    solo si se pasa -Force).

.PARAMETER Force
    Permite sobrescribir saves existentes al restaurar.

.EXAMPLE
    .\restore_backup.ps1 -BackupFile 'D:\Backups\juego-isla-ancestral\backup_2026-08-31_05-00-00.tar.gz'
    .\restore_backup.ps1 -BackupFile '...tar.gz' -RestoreSaves -Force

.NOTES
    Módulo M107 — Backups. Exit codes: 0 = éxito, 1 = error.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BackupFile,
    [string]$DestinationPath = 'D:\Restore\juego-isla-ancestral',
    [switch]$RestoreSaves,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

try {
    if (-not (Test-Path $BackupFile)) { throw "El backup '$BackupFile' no existe." }
    $BackupFile = (Resolve-Path $BackupFile).Path
    $backupName = Split-Path $BackupFile -Leaf

    # ── Verificación de integridad ANTES de extraer ─────────────────────
    $hash = (Get-FileHash $BackupFile -Algorithm SHA256).Hash
    $shaFile = "$BackupFile.sha256"
    if (Test-Path $shaFile) {
        $registered = (Get-Content $shaFile -Encoding ASCII) -replace '\s+$',''
        if ($registered -notmatch $hash) {
            throw "CHECKSUM NO COINCIDE: el backup '$backupName' está corrupto o fue modificado. Restauración abortada."
        }
        Write-Host '[OK] Checksum verificado contra archivo .sha256.'
    } else {
        $checksumsFile = Join-Path (Split-Path $BackupFile -Parent) 'checksums.txt'
        if (Test-Path $checksumsFile) {
            $line = (Get-Content $checksumsFile -Encoding ASCII) | Where-Object { $_ -match [regex]::Escape($backupName) } | Select-Object -First 1
            if ($line) {
                if ($line -notmatch $hash) {
                    throw "CHECKSUM NO COINCIDE en checksums.txt: '$backupName' corrupto. Restauración abortada."
                }
                Write-Host '[OK] Checksum verificado contra checksums.txt.'
            } else {
                Write-Host "[AVISO] '$backupName' no figura en checksums.txt; se omite la verificación previa." -ForegroundColor Yellow
            }
        } else {
            Write-Host '[AVISO] Sin .sha256 ni checksums.txt; se omite la verificación previa.' -ForegroundColor Yellow
        }
    }

    # ── Extracción del proyecto ────────────────────────────────────────
    if (-not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }
    Write-Host "Extrayendo '$backupName' -> $DestinationPath ..."
    & tar.exe '-xzf' $BackupFile '-C' $DestinationPath
    if ($LASTEXITCODE -ne 0) { throw "tar.exe falló al extraer (código $LASTEXITCODE)." }

    $restoredRoot = Join-Path $DestinationPath 'juego-isla-ancestral'
    if (-not (Test-Path (Join-Path $restoredRoot 'CHECKLIST-GLOBAL.md'))) {
        Write-Host '[AVISO] La raíz extraída no contiene CHECKLIST-GLOBAL.md; verificar estructura.' -ForegroundColor Yellow
    }
    Write-Host '[OK] Proyecto restaurado en: ' -NoNewline
    Write-Host $restoredRoot -ForegroundColor Green

    # ── Saves del juego ────────────────────────────────────────────────
    if ($RestoreSaves) {
        # El backup incluye la carpeta Godot/app_userdata/<proyecto> (sin la ruta APPDATA completa)
        $godotDir = Get-ChildItem $DestinationPath -Directory | Where-Object { $_.Name -eq 'Godot' } | Select-Object -First 1
        if (-not $godotDir) {
            # los saves se guardaron con el nombre de la carpeta del proyecto directamente (base name)
            $projName = 'isla-ancestral'
            $saveCand = Join-Path $DestinationPath $projName
        } else {
            $saveCand = $null
        }
        # Buscar carpeta app_userdata dentro de Godot/
        if ($godotDir) {
            $appUd = Join-Path $godotDir.FullName 'app_userdata'
            if (Test-Path $appUd) {
                Get-ChildItem $appUd -Directory | ForEach-Object {
                    $target = Join-Path $env:APPDATA ('Godot\app_userdata\' + $_.Name)
                    if ((Test-Path $target) -and (-not $Force)) {
                        Write-Host "[AVISO] Saves existentes en $target — usar -Force para sobrescribir." -ForegroundColor Yellow
                    } else {
                        if (Test-Path $target) { Remove-Item $target -Recurse -Force }
                        New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
                        Copy-Item $_.FullName $target -Recurse -Force
                        Write-Host "[OK] Saves restaurados -> $target" -ForegroundColor Green
                    }
                }
            } else {
                Write-Host '[AVISO] El backup no contiene Godot/app_userdata; nada que restaurar.' -ForegroundColor Yellow
            }
        } elseif (Test-Path $saveCand) {
            $target = Join-Path $env:APPDATA ('Godot\app_userdata\' + (Split-Path $saveCand -Leaf))
            if ((Test-Path $target) -and (-not $Force)) {
                Write-Host "[AVISO] Saves existentes en $target — usar -Force para sobrescribir." -ForegroundColor Yellow
            } else {
                if (Test-Path $target) { Remove-Item $target -Recurse -Force }
                New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
                Copy-Item $saveCand $target -Recurse -Force
                Write-Host "[OK] Saves restaurados -> $target" -ForegroundColor Green
            }
        } else {
            Write-Host '[AVISO] No se encontraron saves en el backup.' -ForegroundColor Yellow
        }
    }

    # ── Log de restauración (auditoría M133) ────────────────────────────
    $backupRoot = Split-Path $BackupFile -Parent
    $logsDir = Join-Path $backupRoot 'logs'
    if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }
    $msg = '{0} RESTAURADO {1} -> {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $backupName, $DestinationPath
    Add-Content -Path (Join-Path $logsDir 'restore.log') -Value $msg -Encoding UTF8
    Write-Host ''
    Write-Host 'Restauración completada. Verificar el proyecto antes de reemplazar el original.' -ForegroundColor Cyan
    exit 0
}
catch {
    Write-Host ('ERROR: {0}' -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}

