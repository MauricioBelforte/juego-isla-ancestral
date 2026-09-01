<#
.SYNOPSIS
    Backup local del proyecto Isla Ancestral — Módulo M107 (estrategia 3-2-1).

.DESCRIPTION
    Crea un archivo .tar.gz del proyecto (excluyendo contenido regenerable),
    calcula su checksum SHA-256, aplica la política de retención y registra
    un log de ejecución en el destino. Si existen saves del juego en
    %APPDATA%\Godot\app_userdata\<proyecto>, se incluyen dentro del backup
    bajo su nombre de carpeta original.

    Exclusiones predeterminadas (regenerables / re-descargables):
      - game/isla-ancestral/.godot   (caché de import de Godot)
      - tools/mcp/.venv              (entorno virtual Python)
      - tools/mcp/blender-mcp        (repo de terceros clonado, ~2.8 GB)
      - build                        (salidas de build regenerables)
      - *.pyc / __pycache__          (bytecode Python)
      - isla-ancestral/shader_cache  (caché de shaders del motor en user://)

    NOTA TÉCNICA: bsdtar (tar.exe nativo de Windows) exige que TODAS las
    opciones (--exclude) vayan ANTES de los operandos (-C dir base). Si un
    --exclude va después del operando, se IGNORA silenciosamente y aparecen
    errores "Couldn't visit directory: No such file or directory".

.PARAMETER SourcePath
    Raíz del proyecto. Predeterminado: dos niveles arriba de este script.

.PARAMETER DestinationPath
    Carpeta de destino del backup. Predeterminado: D:\Backups\juego-isla-ancestral
    (esta máquina no tiene disco externo E:; D: actúa como medio físico local).

.PARAMETER Kind
    'diario'  -> backup_<timestamp>.tar.gz en la raíz del destino, retención 10.
    'mensual' -> snapshot_<AAAA-MM>.tar.gz en <destino>\mensual, retención 60 (5 años).

.PARAMETER RetentionCount
    Sobrescribe la retención predeterminada del Kind elegido.

.PARAMETER NoSaves
    Excluye los saves del juego del backup.

.EXAMPLE
    .\backup_local.ps1
    .\backup_local.ps1 -Kind mensual
    .\backup_local.ps1 -DestinationPath 'E:\Backups\isla' -RetentionCount 5

.NOTES
    Módulo M107 — Backups. Exit codes: 0 = éxito, 1 = error.
#>
[CmdletBinding()]
param(
    [string]$SourcePath = '',
    [string]$DestinationPath = 'D:\Backups\juego-isla-ancestral',
    [ValidateSet('diario', 'mensual')]
    [string]$Kind = 'diario',
    [int]$RetentionCount = 0,
    [switch]$NoSaves
)

$ErrorActionPreference = 'Stop'
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$script:LogsDir = $null

function Write-Log {
    param([string]$Message)
    Write-Host ('{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Kind, $Message)
}

function Get-ProjectSavesDir {
    # Detecta la carpeta de saves (user://) leyendo config/name de project.godot
    param([string]$Root)
    $pg = Join-Path $Root 'game\isla-ancestral\project.godot'
    if (-not (Test-Path $pg)) { return $null }
    $name = $null
    foreach ($line in (Get-Content $pg -Encoding UTF8)) {
        if ($line -match '^\s*config/name\s*=\s*"(.+)"') { $name = $Matches[1]; break }
    }
    if (-not $name) { return $null }
    $dir = Join-Path $env:APPDATA ("Godot\app_userdata\" + $name)
    if (Test-Path $dir) { return $dir }
    return $null
}

function Remove-OldChecksumEntry {
    param([string]$ChecksumsFile, [string]$FileName)
    if (Test-Path $ChecksumsFile) {
        (Get-Content $ChecksumsFile) | Where-Object { $_ -notmatch [regex]::Escape($FileName) } |
            Set-Content -Path $ChecksumsFile -Encoding ASCII
    }
}

try {
    # ── Resolución de rutas ─────────────────────────────────────────────
    if ([string]::IsNullOrWhiteSpace($SourcePath)) {
        $SourcePath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    }
    $SourcePath = (Resolve-Path $SourcePath).Path
    $srcBase = Split-Path $SourcePath -Leaf
    $srcParent = Split-Path $SourcePath -Parent

    # Sanity: es realmente la raíz del proyecto
    if (-not (Test-Path (Join-Path $SourcePath 'CHECKLIST-GLOBAL.md')) -or
        -not (Test-Path (Join-Path $SourcePath 'game\isla-ancestral\project.godot'))) {
        throw "'$SourcePath' no parece la raíz del proyecto (faltan CHECKLIST-GLOBAL.md / project.godot)."
    }

    if ($RetentionCount -le 0) {
        $RetentionCount = if ($Kind -eq 'diario') { 10 } else { 60 }
    }

    # ── Verificación de unidad de destino (checklist E: 'disco conectado') ──
    $destQualifier = Split-Path $DestinationPath -Qualifier
    if (-not $destQualifier -or -not (Test-Path $destQualifier)) {
        throw "La unidad de destino '$destQualifier' no está disponible (disco desconectado)."
    }
    $drive = [System.IO.DriveInfo]::new($destQualifier)
    if ($drive.AvailableFreeSpace -lt 5GB) {
        throw ("Espacio insuficiente en {0}: {1:N1} GB libres (se requieren 5 GB)." -f $destQualifier, ($drive.AvailableFreeSpace / 1GB))
    }
    if (-not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }
    if ($Kind -eq 'mensual') {
        $monthlyDir = Join-Path $DestinationPath 'mensual'
        if (-not (Test-Path $monthlyDir)) { New-Item -ItemType Directory -Path $monthlyDir -Force | Out-Null }
        $DestinationPath = $monthlyDir
    }

    $script:LogsDir = Join-Path $DestinationPath 'logs'
    if (-not (Test-Path $script:LogsDir)) { New-Item -ItemType Directory -Path $script:LogsDir -Force | Out-Null }
    $logsDir = $script:LogsDir

    if (-not (Get-Command tar.exe -ErrorAction SilentlyContinue)) {
        throw 'tar.exe no está disponible en el sistema (requerido para compresión).'
    }

    # ── Saves del juego ────────────────────────────────────────────────
    $savesDir = $null
    if (-not $NoSaves) {
        $savesDir = Get-ProjectSavesDir -Root $SourcePath
        if ($savesDir) { Write-Log "Saves detectados: $savesDir" }
    }

    # ── Nombre de archivo con timestamp ────────────────────────────────
    $stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $fileName = if ($Kind -eq 'diario') { "backup_$stamp.tar.gz" } else { ('snapshot_{0:yyyy-MM}.tar.gz' -f (Get-Date)) }
    $outFile = Join-Path $DestinationPath $fileName

    # ── Compresión con exclusiones ─────────────────────────────────────
    Write-Log "Comprimiendo '$srcBase' -> $fileName (esto puede tardar unos minutos)..."
    # bsdtar: TODAS las opciones (--exclude) ANTES de los operandos (-C dir base).
    # Si van después del operando se ignoran y aparecen errores "Couldn't visit directory".
    $excludes = @(
        "$srcBase/game/isla-ancestral/.godot"
        "$srcBase/tools/mcp/.venv"
        "$srcBase/tools/mcp/blender-mcp"
        "$srcBase/build"
        '*.pyc'
        'isla-ancestral/shader_cache'   # caché de shaders del motor en user:// (regenerable)
    )
    $tarArgs = @('-czf', $outFile)
    foreach ($ex in $excludes) { $tarArgs += @('--exclude', $ex) }
    $tarArgs += @('-C', $srcParent, $srcBase)
    if ($savesDir) {
        $savesBase = Split-Path $savesDir -Leaf
        $savesParent = Split-Path $savesDir -Parent
        $tarArgs += @('-C', $savesParent, $savesBase)
    }
    & tar.exe @tarArgs
    if ($LASTEXITCODE -ne 0) { throw "tar.exe falló con código $LASTEXITCODE." }

    $sizeMB = [math]::Round((Get-Item $outFile).Length / 1MB, 1)
    Write-Log ("Backup creado: {0} ({1:N1} MB)" -f $fileName, $sizeMB)

    # ── Checksum SHA-256 ───────────────────────────────────────────────
    Write-Log 'Calculando checksum SHA-256...'
    $hash = (Get-FileHash $outFile -Algorithm SHA256).Hash
    $shaFile = "$outFile.sha256"
    "$hash  $fileName" | Set-Content -Path $shaFile -Encoding ASCII

    # checksums.txt central (junto a los backups de ese Kind)
    $checksumsFile = Join-Path $DestinationPath 'checksums.txt'
    if (Test-Path $checksumsFile) {
        $existing = Get-Content $checksumsFile | Where-Object { $_ -notmatch [regex]::Escape($fileName) }
        $existing + "$hash  $fileName" | Set-Content -Path $checksumsFile -Encoding ASCII
    } else {
        "$hash  $fileName" | Set-Content -Path $checksumsFile -Encoding ASCII
    }
    Write-Log "Checksum registrado en $checksumsFile"

    # ── Retención ──────────────────────────────────────────────────────
    $pattern = if ($Kind -eq 'diario') { 'backup_*.tar.gz' } else { 'snapshot_*.tar.gz' }
    $old = Get-ChildItem $DestinationPath -Filter $pattern -File |
        Sort-Object LastWriteTime -Descending | Select-Object -Skip $RetentionCount
    foreach ($f in $old) {
        Remove-Item $f.FullName -Force
        Remove-Item "$($f.FullName).sha256" -Force -ErrorAction SilentlyContinue
        Remove-OldChecksumEntry -ChecksumsFile $checksumsFile -FileName $f.Name
        Write-Log "Retención: eliminado backup antiguo $($f.Name)"
    }

    # Rotación de logs (mantener últimos 30)
    Get-ChildItem $logsDir -Filter '*.log' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -Skip 30 |
        Remove-Item -Force -ErrorAction SilentlyContinue

    $sw.Stop()
    $summary = ('OK {0} {1} {2:N1}MB {3:N0}s' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $fileName, $sizeMB, $sw.Elapsed.TotalSeconds)
    Add-Content -Path (Join-Path $logsDir 'backup.log') -Value $summary -Encoding UTF8
    Write-Log ("Backup $Kind completado en {0:N0}s." -f $sw.Elapsed.TotalSeconds)
}
catch {
    $sw.Stop()
    $msg = 'ERROR {0} {1:N0}s {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $sw.Elapsed.TotalSeconds, $_.Exception.Message
    Write-Host $msg -ForegroundColor Red
    try {
        if ($script:LogsDir) { Add-Content -Path (Join-Path $script:LogsDir 'backup.log') -Value $msg -Encoding UTF8 }
    } catch { }
    exit 1
}
exit 0
