**Modelo:** SWE-1.6
**Plataforma:** Devin

# 02-Analisis.md — Módulo 107: Backups

## 1. Análisis de los puntos del plan maestro (sección 106)

| # | Punto | Resolución |
|---|---|---|
| 1 | Backup del repositorio | ✅ GitHub (remoto) + clon local en máquina de desarrollo |
| 2 | Backup de assets | ✅ Assets en Git LFS + copia en almacenamiento externo |
| 3 | Backup de documentación | ✅ Documentación en Git (repositorio) + copia en cloud |
| 4 | Backup de builds | ✅ Builds almacenados en GitHub Releases + copia en disco externo |
| 5 | Backup de bases de datos | ✅ Si aplica backend/analytics: backup cloud automatizado |
| 6 | Backup de saves | ✅ Saves de prueba/crash en carpeta separada con backup semanal |
| 7 | Backup de música | ✅ Proyectos DAW originales en almacenamiento externo + Git LFS |
| 8 | Backup de archivos fuente | ✅ Código fuente en GitHub (todos los branches) |
| 9 | Backup externo | ✅ Almacenamiento cloud (Google Drive/Dropbox) + disco externo |
| 10 | Backup automático | ✅ GitHub Actions para backups + script local programado |
| 11 | Pruebas de restauración | ✅ Restauración mensual de backup aleatorio para verificar |
| 12 | Política de retención | ✅ 30 días para diarios, 12 meses para semanales, 5 años para mensuales |
| 13 | Versionado | ✅ Múltiples versiones por timestamp en backups externos |
| 14 | Verificación de integridad | ✅ Checksums (SHA-256) para verificar archivos corruptos |
| 15 | Plan de recuperación | ✅ Documentación paso a paso para recuperar de desastre |

## 2. Alternativas consideradas

| Solución | Pros | Contras | Decisión |
|---|---|---|---|---|
| Solo GitHub | Gratis, integrado | Single point of failure, sin historial profundo | ❌ Insuficiente |
| GitHub + Disco Exterivo | Redundancia 2x | Manual, requiere conexión física | ⚠️ Parcial |
| GitHub + Cloud + Disco Externo | Redundancia 3x (3-2-1 rule) | Más complejo, costo cloud | ✅ ELEGIDO |
| Servicio de backup profesional | Automatizado, robusto | Costo elevado para proyecto indie | ❌ Descartado |

**Decisión final:** Estrategia 3-2-1: 3 copias, 2 medios diferentes, 1 offsite. GitHub (1) + Cloud (2) + Disco Externo (3).

## 3. Estrategia 3-2-1

**3 copias de todo dato importante:**
1. **GitHub** (repositorio principal + Git LFS)
2. **Cloud Storage** (Google Drive/Dropbox - backup externo)
3. **Disco Exterivo** (backup local físico)

**2 medios diferentes:**
- **Medio 1:** Almacenamiento en la nube (GitHub + Google Drive)
- **Medio 2:** Almacenamiento físico (disco externo)

**1 copia offsite:**
- **Offsite:** Google Drive (cloud, accesible desde cualquier lugar)
- **Local:** Disco externo (físico, en la misma ubicación)

## 4. Matriz de backups por tipo de dato

| Tipo de dato | Frecuencia | Ubicación 1 | Ubicación 2 | Ubicación 3 | Retención |
|---|---|---|---|---|---|
| Repositorio Git | Continuo (push) | GitHub | N/A | N/A | Permanente |
| Assets (Git LFS) | Continuo (push) | GitHub LFS | Google Drive | Disco Externo | 5 años |
| Documentación | Continuo (push) | GitHub | Google Drive | N/A | Permanente |
| Builds | Post-release | GitHub Releases | Google Drive | Disco Externo | 5 años |
| Saves de prueba | Semanal | Carpeta local | Google Drive | N/A | 30 días |
| Música original | Semanal | Git LFS | Google Drive | Disco Externo | 5 años |
| Proyectos DAW | Semanal | N/A | Google Drive | Disco Externo | 5 años |

## 5. Automatización con GitHub Actions

**Workflow `.github/workflows/backup.yml`:**
```yaml
name: Backup Externo

on:
  schedule:
    - cron: '0 2 * * *'  # Diario a las 2 AM
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Clonar repositorio
        uses: actions/checkout@v3
      
      - name: Crear archivo de backup
        run: |
          tar -czf backup_$(date +%Y%m%d).tar.gz .
      
      - name: Subir a Google Drive (vía rclone o API)
        run: |
          # Configuración de rclone para Google Drive
          rclone copy backup_$(date +%Y%m%d).tar.gz gdrive:isla-ancestral-backups/
      
      - name: Limpiar backups antiguos
        run: |
          # Mantener solo últimos 30 días
          rclone delete gdrive:isla-ancestral-backups/ --min-age 30d
```

## 6. Script local de backup

**Script `backup_local.ps1` (PowerShell):**
```powershell
# Backup local a disco externo
$source = "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
$destination = "E:\Backups\juego-isla-ancestral"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = "$destination\backup_$timestamp.zip"

# Crear backup comprimido
Compress-Archive -Path $source -DestinationPath $backupFile

# Calcular checksum
$checksum = (Get-FileHash -Path $backupFile -Algorithm SHA256).Hash
"$backupFile|$checksum" | Out-File "$destination\checksums.txt" -Append

# Limpiar backups antiguos (mantener últimos 10)
Get-ChildItem $destination -Filter "backup_*.zip" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -Skip 10 | 
    Remove-Item
```

**Programación en Windows Task Scheduler:**
- Ejecutar `backup_local.ps1` diariamente a las 3 AM
- Requiere que el disco externo esté conectado

## 7. Política de retención

**Diarios (últimos 30 días):**
- Repositorio: permanente (GitHub)
- Assets: últimos 30 días en Google Drive, permanente en Git LFS
- Saves de prueba: últimos 30 días

**Semanales (últimos 12 meses):**
- Builds: últimos 12 meses en GitHub Releases
- Música original: últimos 12 meses en Google Drive

**Mensuales (últimos 5 años):**
- Builds históricos: versión anual de cada mes
- Assets históricos: snapshot anual en disco externo
- Música original: snapshot anual en disco externo

**Permanentes:**
- Repositorio Git (todo el historial)
- Documentación (todo el historial)

## 8. Verificación de integridad

**Checksums SHA-256:**
- Cada backup tiene un checksum calculado
- Checksums almacenados en archivo `checksums.txt`
- Verificación semanal: calcular checksums y comparar con almacenados

**Script de verificación `verify_backups.ps1`:**
```powershell
$backupDir = "E:\Backups\juego-isla-ancestral"
$checksumFile = "$backupDir\checksums.txt"

# Leer checksums almacenados
$storedChecksums = Get-Content $checksumFile

# Verificar cada backup
foreach ($line in $storedChecksums) {
    $parts = $line.Split('|')
    $file = $parts[0]
    $stored = $parts[1]
    
    if (Test-Path $file) {
        $current = (Get-FileHash -Path $file -Algorithm SHA256).Hash
        if ($current -eq $stored) {
            Write-Host "✓ $file: OK"
        } else {
            Write-Host "✗ $file: CORRUPTO (esperado: $stored, actual: $current)"
        }
    } else {
        Write-Host "✗ $file: NO EXISTE"
    }
}
```

## 9. Pruebas de restauración

**Procedimiento mensual:**
1. Seleccionar un backup aleatorio de los últimos 30 días
2. Restaurar en directorio de prueba
3. Verificar:
   - Repositorio Git se puede clonar y compilar
   - Assets se pueden cargar en Godot
   - Documentación es legible
   - Builds se pueden ejecutar
4. Documentar resultado en `logs/restauracion_{timestamp}.md`

**Criterio de éxito:**
- Restauración 100% exitosa sin errores
- Todos los archivos verifican con checksums
- Proyecto compila y ejecuta correctamente

## 10. Plan de recuperación de desastres

**Escenario 1: Pérdida de máquina local**
1. Clonar repositorio desde GitHub
2. Descargar assets desde Git LFS
3. Descargar builds desde GitHub Releases
4. Recuperar saves de prueba desde Google Drive
5. Tiempo estimado: 2-4 horas

**Escenario 2: Corrupción de repositorio Git**
1. Recuperar desde backup de Google Drive
2. Recuperar desde disco externo
3. Verificar integridad con checksums
4. Restaurar en GitHub con nuevo historial
5. Tiempo estimado: 4-8 horas

**Escenario 3: Pérdida de GitHub (catastrófico)**
1. Recuperar desde Google Drive
2. Recuperar desde disco externo
3. Crear nuevo repositorio en GitHub/GitLab
4. Restaurar historial completo
5. Tiempo estimado: 8-24 horas

**Escenario 4: Pérdida de assets originales**
1. Recuperar desde Git LFS
2. Recuperar desde Google Drive
3. Recuperar desde disco externo
4. Reimportar en Godot
5. Tiempo estimado: 4-12 horas

## 11. Integración con otros módulos

### M59 (Guardado)
- Los saves del juego se respaldan automáticamente en carpeta separada
- Saves de crash reporting (M122) se incluyen en backup semanal

### M06 (Control de Versiones)
- El repositorio Git es la fuente primaria de backup del código
- Branches feature/hotfix también se respaldan automáticamente

### M133 (Gestión del Proyecto)
- El plan de recuperación es parte del plan de gestión de riesgos
- Las pruebas de restauración se documentan en logs del proyecto
