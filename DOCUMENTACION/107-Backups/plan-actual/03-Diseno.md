**Modelo:** Devin
**Plataforma:** Antigravity

# 03-Diseno.md — Módulo 107: Backups

## 1. Arquitectura del sistema de backups

```
Sistema de Backups (3-2-1 Strategy)
├── Copia 1: GitHub (primario)
│   ├── Repositorio Git (código + documentación)
│   ├── Git LFS (assets grandes)
│   └── GitHub Releases (builds)
├── Copia 2: Cloud Storage (secundario)
│   ├── Google Drive / Dropbox
│   ├── Assets originales
│   ├── Builds compilados
│   ├── Música original
│   └── Proyectos DAW
└── Copia 3: Disco Externo (terciario)
    ├── Backup local programado
    ├── Assets originales
    ├── Builds históricos
    └── Snapshots mensuales
```

## 2. Flujo de backup automático

```
1. Commit en Git (desarrollador)
    ↓
2. Push a GitHub (automático tras commit)
    ↓
3. GitHub Actions trigger (diario a las 2 AM)
    ↓
4. Workflow backup.yml se ejecuta
    ↓
5. Crea archivo backup_YYYYMMDD.tar.gz
    ↓
6. Sube a Google Drive vía rclone
    ↓
7. Limpia backups antiguos (> 30 días)
    ↓
8. Genera reporte de éxito/fracaso
```

## 3. Flujo de backup local

```
1. Task Scheduler (Windows) ejecuta backup_local.ps1 diariamente a las 3 AM
    ↓
2. Script verifica que disco externo esté conectado
    ↓
3. Comprime directorio del proyecto en .zip
    ↓
4. Calcula checksum SHA-256
    ↓
5. Guarda backup y checksum en disco externo
    ↓
6. Limpia backups antiguos (mantiene últimos 10)
    ↓
7. Genera log de ejecución
```

## 4. Estructura de almacenamiento

### Google Drive (Cloud)
```
isla-ancestral-backups/
├── diario/
│   ├── backup_20260816.tar.gz
│   ├── backup_20260815.tar.gz
│   └── ... (últimos 30 días)
├── semanal/
│   ├── backup_20260814.tar.gz
│   └── ... (últimos 12 semanas)
├── mensual/
│   ├── backup_20260701.tar.gz
│   └── ... (últimos 5 años)
├── assets/
│   ├── modelos_originales/
│   ├── texturas_originales/
│   └── audio_original/
├── builds/
│   ├── v0.1.0-alpha/
│   ├── v0.2.0-beta/
│   └── v1.0.0-release/
└── musica/
    ├── proyectos_daw/
    └── stems/
```

### Disco Exterivo (Local)
```
E:\Backups\juego-isla-ancestral\
├── backup_20260816-030000.zip
├── backup_20260815-030000.zip
├── ... (últimos 10 diarios)
├── mensual/
│   ├── snapshot_20260701.zip
│   └── ... (últimos 5 años)
├── assets_originales/
├── builds_historicos/
└── checksums.txt
```

## 5. Configuración de GitHub Actions

**Archivo `.github/workflows/backup.yml`:**
```yaml
name: Backup Externo

on:
  schedule:
    - cron: '0 2 * * *'  # Diario a las 2 AM UTC
  workflow_dispatch:  # Permitir ejecución manual

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Setup rclone
        run: |
          curl https://rclone.org/install.sh | sudo bash
      
      - name: Configurar rclone
        run: |
          rclone config create gdrive drive
          rclone config pass gdrive client_secret ${{ secrets.GDRIVE_CLIENT_SECRET }}
          rclone config pass gdrive client_id ${{ secrets.GDRIVE_CLIENT_ID }}
          rclone config pass gdrive token ${{ secrets.GDRIVE_TOKEN }}
      
      - name: Crear backup
        run: |
          tar -czf backup_$(date +%Y%m%d).tar.gz \
            --exclude='.git' \
            --exclude='*.tmp' \
            --exclude='user://logs' \
            .
      
      - name: Subir a Google Drive
        run: |
          rclone copy backup_$(date +%Y%m%d).tar.gz gdrive:isla-ancestral-backups/diario/
      
      - name: Limpiar backups antiguos
        run: |
          rclone delete gdrive:isla-ancestral-backups/diario/ --min-age 30d
      
      - name: Notificar resultado
        if: always()
        run: |
          if [ $? -eq 0 ]; then
            echo "✅ Backup completado exitosamente"
          else
            echo "❌ Backup falló"
            # Aquí se podría agregar notificación por email/slack
          fi
```

**Secrets de GitHub:**
- `GDRIVE_CLIENT_SECRET`: Client secret de Google Drive API
- `GDRIVE_CLIENT_ID`: Client ID de Google Drive API
- `GDRIVE_TOKEN`: OAuth token de acceso

## 6. Script de backup local

**Archivo `scripts/backup/backup_local.ps1`:**
```powershell
# backup_local.ps1 - Backup local a disco externo
param(
    [string]$SourcePath = "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral",
    [string]$DestinationPath = "E:\Backups\juego-isla-ancestral",
    [int]$RetentionDays = 10
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "$DestinationPath\backup_log_$timestamp.txt"

function Write-Log {
    param([string]$message)
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

try {
    Write-Log "Iniciando backup local..."
    
    # Verificar que disco externo esté conectado
    if (-not (Test-Path $DestinationPath)) {
        throw "Disco externo no encontrado en $DestinationPath"
    }
    Write-Log "✓ Disco externo conectado"
    
    # Verificar espacio disponible
    $sourceSize = (Get-ChildItem $SourcePath -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
    $destinationFree = (Get-PSDrive -Name E).Free / 1GB
    
    if ($destinationFree -lt ($sourceSize * 1.5)) {
        throw "Espacio insuficiente en disco externo (necesario: $($sourceSize * 1.5) GB, disponible: $destinationFree GB)"
    }
    Write-Log "✓ Espacio suficiente (disponible: $destinationFree GB)"
    
    # Crear archivo de backup
    $backupFile = "$DestinationPath\backup_$timestamp.zip"
    Write-Log "Comprimiendo $SourcePath..."
    
    Compress-Archive -Path $SourcePath -DestinationPath $backupFile -Force
    Write-Log "✓ Backup creado: $backupFile"
    
    # Calcular checksum
    Write-Log "Calculando checksum SHA-256..."
    $checksum = (Get-FileHash -Path $backupFile -Algorithm SHA256).Hash
    "$backupFile|$checksum" | Out-File "$DestinationPath\checksums.txt" -Append
    Write-Log "✓ Checksum: $checksum"
    
    # Limpiar backups antiguos
    Write-Log "Limpiando backups antiguos (últimos $RetentionDays días)..."
    Get-ChildItem $DestinationPath -Filter "backup_*.zip" | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } | 
        Remove-Item -Force
    Write-Log "✓ Backups antiguos eliminados"
    
    Write-Log "✅ Backup completado exitosamente"
    
} catch {
    Write-Log "❌ Error: $_"
    exit 1
}
```

## 7. Programación en Windows Task Scheduler

**Configuración:**
- **Nombre:** Isla Ancestral Backup Local
- **Trigger:** Diariamente a las 3:00 AM
- **Acción:** Iniciar programa `powershell.exe`
- **Argumentos:** `-ExecutionPolicy Bypass -File "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\scripts\backup\backup_local.ps1"`
- **Condiciones:**
  - "Iniciar solo si el equipo está conectado a la red de CA"
  - "Iniciar solo si está conectado a la alimentación de CA"
  - "Despertar el equipo para ejecutar esta tarea"

## 8. Script de verificación de integridad

**Archivo `scripts/backup/verify_backups.ps1`:**
```powershell
# verify_backups.ps1 - Verificar integridad de backups
param(
    [string]$BackupDir = "E:\Backups\juego-isla-ancestral"
)

$ErrorActionPreference = "Stop"
$checksumFile = "$BackupDir\checksums.txt"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "$BackupDir\verification_log_$timestamp.txt"

function Write-Log {
    param([string]$message)
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

try {
    Write-Log "Iniciando verificación de integridad..."
    
    if (-not (Test-Path $checksumFile)) {
        throw "Archivo de checksums no encontrado: $checksumFile"
    }
    
    $storedChecksums = Get-Content $checksumFile
    $totalFiles = 0
    $okFiles = 0
    $corruptFiles = 0
    $missingFiles = 0
    
    foreach ($line in $storedChecksums) {
        $totalFiles++
        $parts = $line.Split('|')
        
        if ($parts.Length -ne 2) {
            Write-Log "⚠ Línea inválida: $line"
            continue
        }
        
        $file = $parts[0]
        $stored = $parts[1]
        
        if (-not (Test-Path $file)) {
            Write-Log "✗ $file : NO EXISTE"
            $missingFiles++
            continue
        }
        
        $current = (Get-FileHash -Path $file -Algorithm SHA256).Hash
        
        if ($current -eq $stored) {
            Write-Log "✓ $file : OK"
            $okFiles++
        } else {
            Write-Log "✗ $file : CORRUPTO (esperado: $stored, actual: $current)"
            $corruptFiles++
        }
    }
    
    Write-Log "---"
    Write-Log "Total archivos: $totalFiles"
    Write-Log "OK: $okFiles"
    Write-Log "Corruptos: $corruptFiles"
    Write-Log "Faltantes: $missingFiles"
    
    if ($corruptFiles -gt 0 -or $missingFiles -gt 0) {
        Write-Log "❌ Verificación falló: $corruptFiles corruptos, $missingFiles faltantes"
        exit 1
    } else {
        Write-Log "✅ Verificación completada exitosamente"
    }
    
} catch {
    Write-Log "❌ Error: $_"
    exit 1
}
```

## 9. Procedimiento de prueba de restauración

**Documento `docs/procedimiento_restauracion.md`:**
```markdown
# Procedimiento de Prueba de Restauración

## Frecuencia
Mensual (primer día de cada mes)

## Pasos

1. **Seleccionar backup aleatorio**
   - Elegir un backup de los últimos 30 días
   - Usar generador de números aleatorios

2. **Preparar entorno de prueba**
   - Crear directorio `C:\Test\juego-isla-ancestral-restauracion`
   - Asegurar espacio suficiente (mínimo 10 GB)

3. **Restaurar desde backup**
   - Descomprimir archivo de backup
   - Verificar estructura de directorios

4. **Verificar repositorio Git**
   - `git status`
   - `git log --oneline -10`
   - Verificar que branches existen

5. **Verificar assets**
   - Abrir proyecto en Godot
   - Verificar que assets se importan correctamente
   - Verificar que no hay faltantes

6. **Verificar documentación**
   - Abrir archivos .md
   - Verificar que son legibles
   - Verificar que no hay corrupción

7. **Verificar builds**
   - Ejecutar build más reciente
   - Verificar que compila
   - Verificar que ejecuta sin errores

8. **Documentar resultado**
   - Crear `logs/restauracion_{timestamp}.md`
   - Registrar éxito/fracaso
   - Registrar cualquier anomalía

## Criterio de Éxito
- Restauración 100% exitosa
- Todos los archivos verifican con checksums
- Proyecto compila y ejecuta correctamente
- Sin errores en Godot Console
```

## 10. Plan de recuperación de desastres

**Documento `docs/plan_recuperacion_desastres.md`:**
```markdown
# Plan de Recuperación de Desastres

## Escenario 1: Pérdida de Máquina Local

### Severidad: Media
### Tiempo Estimado: 2-4 horas

### Pasos:
1. Adquirir nueva máquina o reinstalar sistema
2. Instalar Git, Godot 4.x, herramientas necesarias
3. Clonar repositorio: `git clone https://github.com/MauricioBelforte/juego-isla-ancestral.git`
4. Restaurar Git LFS: `git lfs pull`
5. Descargar builds desde GitHub Releases
6. Recuperar saves de prueba desde Google Drive
7. Verificar compilación y ejecución

### Verificación:
- [ ] Repositorio clonado exitosamente
- [ ] Assets restaurados
- [ ] Proyecto compila
- [ ] Proyecto ejecuta
- [ ] Saves recuperados

## Escenario 2: Corrupción de Repositorio Git

### Severidad: Alta
### Tiempo Estimado: 4-8 horas

### Pasos:
1. Identificar punto de corrupción
2. Recuperar desde backup de Google Drive más reciente
3. Recuperar desde disco externo como respaldo
4. Verificar integridad con checksums
5. Crear nuevo repositorio limpio
6. Restaurar historial desde backup
7. Verificar branches y tags
8. Actualizar remoto si es necesario

### Verificación:
- [ ] Backup recuperado
- [ ] Checksums verifican
- [ ] Historial completo restaurado
- [ ] Branches existen
- [ ] Tags existen

## Escenario 3: Pérdida de GitHub (Catastrófico)

### Severidad: Crítica
### Tiempo Estimado: 8-24 horas

### Pasos:
1. Evaluar situación (GitHub caído o cuenta comprometida)
2. Recuperar desde Google Drive (backup más reciente)
3. Recuperar desde disco externo (respaldo)
4. Crear nuevo repositorio en GitHub o GitLab
5. Restaurar historial completo
6. Configurar Git LFS en nuevo repositorio
7. Actualizar URLs remotas en clones locales
8. Verificar que todos los colaboradores pueden acceder

### Verificación:
- [ ] Código recuperado
- [ ] Historial completo
- [ ] Assets recuperados
- [ ] Colaboradores pueden acceder
- [ ] CI/CD reconfigurado

## Escenario 4: Pérdida de Assets Originales

### Severidad: Alta
### Tiempo Estimado: 4-12 horas

### Pasos:
1. Identificar assets perdidos
2. Recuperar desde Git LFS
3. Recuperar desde Google Drive
4. Recuperar desde disco externo
5. Reimportar en Godot
6. Verificar que no hay faltantes
7. Verificar que no hay corrupción
8. Reconstruir si es necesario

### Verificación:
- [ ] Assets recuperados
- [ ] Godot importa correctamente
- [ ] No hay faltantes
- [ ] No hay corrupción
- [ ] Builds funcionan
```

## 11. Reglas de calidad

### Regla 1: 3-2-1 Rule Obligatoria
- Mínimo 3 copias de todo dato importante
- Al menos 2 medios diferentes (cloud + físico)
- Al menos 1 copia offsite (cloud)

### Regla 2: Automatización
- Backups programados sin intervención manual
- Notificaciones de éxito/fracaso
- Logs de ejecución para auditoría

### Regla 3: Verificación Periódica
- Verificación de integridad semanal
- Prueba de restauración mensual
- Revisión de política trimestral

### Regla 4: Seguridad
- Backups cloud encriptados si contienen datos sensibles
- Discos externos almacenados en lugar seguro
- Control de acceso a backups

### Regla 5: Documentación
- Procedimientos claros y accesibles
- Plan de recuperación actualizado
- Logs de restauración para auditoría
