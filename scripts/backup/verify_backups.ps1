<#
.SYNOPSIS
    Verificación de integridad de backups — Módulo M107.

.DESCRIPTION
    Lee checksums.txt del directorio de backups y verifica que cada archivo:
      1) exista (FALTANTE si no),
      2) su SHA-256 actual coincida con el registrado (CORRUPTO si no).
    Reporta contadores (total / OK / CORRUPTO / FALTANTE), deja log en
    <destino>\logs\verify.log y sale con código 1 si hay fallos.

.PARAMETER BackupDir
    Carpeta de backups. Predeterminado: D:\Backups\juego-isla-ancestral

.PARAMETER Latest
    Verificar solo los N backups más recientes (0 = todos).

.EXAMPLE
    .\verify_backups.ps1
    .\verify_backups.ps1 -Latest 5

.NOTES
    Módulo M107 — Backups. Exit codes: 0 = todo OK, 1 = CORRUPTO/FALTANTE, 2 = error de ejecución.
#>
[CmdletBinding()]
param(
    [string]$BackupDir = 'D:\Backups\juego-isla-ancestral',
    [int]$Latest = 0
)

$ErrorActionPreference = 'Stop'

function Get-ChecksumsFile {
    param([string]$Dir)
    $f = Join-Path $Dir 'checksums.txt'
    if (Test-Path $f) { return $f }
    $f2 = Join-Path (Split-Path $Dir -Parent) 'checksums.txt'
    if (Test-Path $f2) { return $f2 }
    return $null
}

try {
    if (-not (Test-Path $BackupDir)) {
        throw "El directorio de backups '$BackupDir' no existe."
    }
    $checksumsFile = Get-ChecksumsFile -Dir $BackupDir
    if (-not $checksumsFile) {
        throw "No se encontró checksums.txt en '$BackupDir' (¿se ejecutó backup_local.ps1 alguna vez?)."
    }

    $entries = @()
    foreach ($line in (Get-Content $checksumsFile -Encoding ASCII)) {
        if ($line -match '^([A-Fa-f0-9]{64})\s+(.+?)\s*$') {
            $entries += [pscustomobject]@{ Hash = $Matches[1]; File = $Matches[2] }
        }
    }
    if ($entries.Count -eq 0) { throw 'checksums.txt no contiene entradas válidas.' }

    # Subcarpetas relativas al dir de checksums (mensuales viven en mensual/)
    $baseDir = Split-Path $checksumsFile -Parent
    if ($Latest -gt 0) {
        $entries = $entries | Sort-Object File -Descending | Select-Object -First $Latest
    }

    $total = 0; $ok = 0; $corruptos = 0; $faltantes = 0
    foreach ($e in $entries) {
        $total++
        $candidates = @(
            (Join-Path $baseDir $e.File),
            (Join-Path (Join-Path $baseDir 'mensual') $e.File)
        )
        $path = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        if (-not $path) {
            $faltantes++
            Write-Host ('[FALTANTE ] {0}' -f $e.File) -ForegroundColor Yellow
            continue
        }
        $actual = (Get-FileHash $path -Algorithm SHA256).Hash
        if ($actual -eq $e.Hash) {
            $ok++
            Write-Host ('[OK       ] {0}' -f $e.File) -ForegroundColor Green
        } else {
            $corruptos++
            Write-Host ('[CORRUPTO ] {0}' -f $e.File) -ForegroundColor Red
        }
    }

    $resumen = ('{0} Verificación: {1} archivos, {2} OK, {3} corruptos, {4} faltantes' -f `
        (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $total, $ok, $corruptos, $faltantes)
    Write-Host ''
    Write-Host $resumen

    $logsDir = Join-Path $BackupDir 'logs'
    if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }
    Add-Content -Path (Join-Path $logsDir 'verify.log') -Value $resumen -Encoding UTF8

    if ($corruptos -gt 0 -or $faltantes -gt 0) { exit 1 }
    exit 0
}
catch {
    Write-Host ('ERROR: {0}' -f $_.Exception.Message) -ForegroundColor Red
    exit 2
}
