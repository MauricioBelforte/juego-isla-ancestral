<#
    M116 - Pre-flight de requisitos del sistema (RF12)

    Inno Setup NO puede consultar la RAM total ni la version de DirectX desde
    Pascal Script (no admite structs para llamadas externas). Este script cubre
    esos dos chequeos con CIM/.NET y complementa a system_requirements.iss.

    Uso:
      powershell -ExecutionPolicy Bypass -File installer\verificar_requisitos.ps1
      powershell -ExecutionPolicy Bypass -File installer\verificar_requisitos.ps1 -Json

    Codigos de salida: 0 = cumple | 1 = no cumple.
#>
[CmdletBinding()]
param(
    [switch]$Json
)

$ErrorActionPreference = "Continue"

$RAM_MINIMA_MB   = 8192
$DISCO_MINIMO_MB = 5120
$DIRECTX_MINIMO  = 11

$resultados = New-Object System.Collections.ArrayList

function Agregar {
    param([string]$Nombre, [bool]$Ok, [string]$Detalle)
    [void]$resultados.Add([ordered]@{ requisito = $Nombre; cumple = $Ok; detalle = $Detalle })
}

# ------------------------------------------------------------------- SO
$so = [System.Environment]::OSVersion.Version
Agregar "Windows 10 o superior" ($so.Major -ge 10) ("Windows " + $so.Major + "." + $so.Minor + " build " + $so.Build)

# ------------------------------------------------------------- 64 bits
$es64 = [System.Environment]::Is64BitOperatingSystem
Agregar "Sistema operativo de 64 bits" $es64 ("Is64BitOperatingSystem=" + $es64)

# ------------------------------------------------------------------ RAM
$ramMb = -1
try {
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
    if ($cs -and $cs.TotalPhysicalMemory) { $ramMb = [int]($cs.TotalPhysicalMemory / 1MB) }
} catch {
    try {
        $total = (Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction Stop | Measure-Object -Property Capacity -Sum).Sum
        if ($total) { $ramMb = [int]($total / 1MB) }
    } catch { $ramMb = -1 }
}
if ($ramMb -lt 0) {
    # No se pudo medir: no se marca como fallo (evita falsos negativos).
    Agregar "RAM >= $RAM_MINIMA_MB MB" $true "no se pudo medir la RAM (no se bloquea)"
} else {
    Agregar "RAM >= $RAM_MINIMA_MB MB" ($ramMb -ge $RAM_MINIMA_MB) ($ramMb.ToString() + " MB detectados")
}

# ------------------------------------------------------------------ GPU
$gpus = @()
try { $gpus = @(Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop) } catch { $gpus = @() }
if ($gpus.Count -eq 0) {
    Agregar "GPU detectable" $true "no se pudo enumerar la GPU (no se bloquea)"
} else {
    $nombres = ($gpus | ForEach-Object { $_.Name }) -join "; "
    Agregar "GPU detectable" $true $nombres
}

# --------------------------------------------------------------- DirectX
$dx = -1
try {
    $clave = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DirectX" -ErrorAction Stop
    if ($clave.Version) {
        # Formato tipico: "4.09.00.0904" -> la parte tras 4.xx es la version mayor
        $partes = ($clave.Version -split "\.")
        if ($partes.Count -ge 2) { $dx = [int]$partes[1] }
    }
} catch { $dx = -1 }
if ($dx -lt 0) {
    Agregar "DirectX >= $DIRECTX_MINIMO (aprox.)" $true "no se pudo leer del registro (no se bloquea)"
} else {
    Agregar "DirectX >= $DIRECTX_MINIMO (aprox.)" ($dx -ge $DIRECTX_MINIMO) ("DirectX " + $dx + " detectado")
}

# ---------------------------------------------------------------- Disco
$unidad = New-Object System.IO.DriveInfo([System.IO.Path]::GetPathRoot($env:SystemDrive + "\"))
$libreMb = [int]($unidad.AvailableFreeSpace / 1MB)
Agregar "Disco >= $DISCO_MINIMO_MB MB libres" ($libreMb -ge $DISCO_MINIMO_MB) ($libreMb.ToString() + " MB libres en " + $unidad.Name)

# -------------------------------------------------------------- Informe
$fallos = @($resultados | Where-Object { -not $_.cumple })

if ($Json) {
    ([ordered]@{ cumple = ($fallos.Count -eq 0); resultados = $resultados } | ConvertTo-Json -Depth 4)
} else {
    Write-Host ""
    Write-Host "=== Requisitos del sistema - Isla Ancestral ===" -ForegroundColor Cyan
    foreach ($r in $resultados) {
        $marca = if ($r.cumple) { "[OK]   " } else { "[FALLA]" }
        $color = if ($r.cumple) { "Gray" } else { "Red" }
        Write-Host ("  " + $marca + " " + $r.requisito.PadRight(38) + " " + $r.detalle) -ForegroundColor $color
    }
    Write-Host ""
    if ($fallos.Count -eq 0) {
        Write-Host "El equipo cumple los requisitos." -ForegroundColor Green
    } else {
        Write-Host ("No cumple " + $fallos.Count + " requisito(s).") -ForegroundColor Red
    }
}

if ($fallos.Count -gt 0) { exit 1 }
exit 0
