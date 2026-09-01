<#
.SYNOPSIS
    Registro de tarea programada de backups — Módulo M107.

.DESCRIPTION
    Crea (o reemplaza) la tarea programada "Isla Ancestral Backup Local" en
    Windows Task Scheduler: ejecuta backup_local.ps1 diariamente a las 03:00.
    Requiere ejecutarse con permisos de administrador (Register-ScheduledTask).

    Condiciones configuradas (checklist F):
      - Solo con alimentación de CA (StartWhenAvailable como fallback si se perdió el trigger)
      - WakeToRun desactivado (no despertar el equipo)
      - Si la tarea se pierde, ejecutar apenas sea posible (StartWhenAvailable)

.PARAMETER Time
    Hora diaria de ejecución. Predeterminado '03:00'.

.PARAMETER DestinationPath
    Destino de los backups (se pasa al backup_local.ps1).

.PARAMETER Force
    Reemplaza la tarea si ya existe (sin preguntar).

.EXAMPLE
    .\register_task.ps1
    .\register_task.ps1 -Time '03:30' -Force

.NOTES
    Módulo M107 — Backups. Exit codes: 0 = éxito, 1 = error.
#>
[CmdletBinding()]
param(
    [string]$Time = '03:00',
    [string]$DestinationPath = 'D:\Backups\juego-isla-ancestral',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$taskName = 'Isla Ancestral Backup Local'
$scriptPath = Join-Path $PSScriptRoot 'backup_local.ps1'

try {
    if (-not (Test-Path $scriptPath)) { throw "No se encuentra backup_local.ps1 junto a este script." }

    # Requiere admin para Register-ScheduledTask a nivel de equipo
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw 'Este script debe ejecutarse como Administrador (Register-ScheduledTask lo requiere).'
    }

    $existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existing -and -not $Force) {
        throw "La tarea '$taskName' ya existe. Usar -Force para reemplazarla."
    }
    if ($existing) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Tarea anterior '$taskName' eliminada."
    }

    $action = New-ScheduledTaskAction -Execute 'powershell.exe' `
        -Argument ("-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -DestinationPath `"$DestinationPath`"" )
    $trigger = New-ScheduledTaskTrigger -Daily -At $Time
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries `
        -AllowStartIfOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 2) -MultipleInstances IgnoreNew
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -Principal $principal -Description `
        'Backup diario del proyecto Isla Ancestral (Módulo M107). Ejecuta scripts/backup/backup_local.ps1' | Out-Null

    Write-Host '[OK] Tarea registrada:' -ForegroundColor Green
    Write-Host ("  Nombre      : $taskName")
    Write-Host ("  Trigger     : diario a las $Time")
    Write-Host ("  Script      : $scriptPath")
    Write-Host ("  Destino     : $DestinationPath")
    Write-Host ''
    Write-Host 'Verificación manual:  Start-ScheduledTask -TaskName "Isla Ancestral Backup Local"'
    Write-Host 'Prueba de ejecución:  Start-ScheduledTask ... y luego revisar D:\Backups\...\logs\backup.log'
    exit 0
}
catch {
    Write-Host ('ERROR: {0}' -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}
