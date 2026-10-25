**Modelo:** SWE-1.6
**Plataforma:** Devin

# 03-Diseno.md — Módulo 107: Backups

# 1. Arquitectura del sistema de backups

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

# Dependencias (contratos de integración — detalle en `04-Codigo.md` §3)

- **Entrada:** M59 (Guardado) — los saves del juego se respaldan en carpeta separada (`scripts/saving/save_backup.gd` + `BackupManager` in-engine); M06 (Control de Versiones) — el repositorio Git es la fuente primaria de backup (Copia 1); M122 (Crash Reporting) — los saves de crash se incluyen en el backup semanal.
- **Salida:** M133 (Gestión del Proyecto) — los logs de restauración (`10-Plantilla-Log-Restauracion.md`) y el plan de recuperación informan la gestión; M135 (Riesgos) — el plan de recuperación mitiga los riesgos de pérdida de datos.
- **Consumidor:** M133 (Gestión del Proyecto).

# Catálogo de los 15 puntos de la sección 106 del plan maestro (`DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` L2913-2929)

| # | Punto §106 | Cobertura en M107 |
|---|---|---|
| 1 | Backup del repositorio | Copia 1: GitHub (§1); `.github/workflows/backup.yml` |
| 2 | Backup de assets | §4 `assets/` (modelos/texturas/audio originales); Git LFS (§1) |
| 3 | Backup de documentación | §1 Repositorio Git (código + documentación) |
| 4 | Backup de builds | §1 GitHub Releases (builds); §4 `builds/` + `builds_historicos/` |
| 5 | Backup de bases de datos | §3 compresión del directorio del proyecto (incluye `data/`: `backup_categories.json`, `backup_policy.json`) |
| 6 | Backup de saves | `BackupManager` in-engine (`user://backups/`); `save_backup.gd` (integración M59) |
| 7 | Backup de música | §4 `musica/` (proyectos_daw, stems) |
| 8 | Backup de archivos fuente | §1 Repositorio Git (código); §4 `assets_originales/` |
| 9 | Backup externo | §1 Copia 3: Disco Externo; §4 estructura `E:\Backups\juego-isla-ancestral\`; `scripts/backup/backup_local.ps1` |
| 10 | Backup automático | §2 GitHub Actions (diario 2 AM); §7 Task Scheduler (3 AM); `scripts/backup/register_task.ps1` |
| 11 | Pruebas de restauración | §9 procedimiento mensual; `09-Procedimiento-Restauracion.md`; `scripts/backup/restore_backup.ps1` |
| 12 | Política de retención | §2 (limpia > 30 días) + §3 (últimos 10); `08-Politica-Retencion.md`; `backup_policy.json` |
| 13 | Versionado | §4 `backup_YYYYMMDD.tar.gz` / `backup_YYYYMMDD-030000.zip`; retención 30 días / 12 meses / 5 años |
| 14 | Verificación de integridad | `BackupManager.verificar_integridad` (CRC32); `scripts/backup/verify_backups.ps1` (SHA-256 vs `checksums.txt`) |
| 15 | Plan de recuperación | §10 (4 escenarios); `11-Plan-Recuperacion-Desastres.md` |

# Criterios de aceptación verificables

1. `test_backup_m107.gd` (headless): 28 checks, 0 fallos, exit 0.
2. `test_backup_rotate_return.gd` (headless): 4 checks, 0 fallos, exit 0.
3. `test_backup_rotations.gd` (headless): 7 checks, 0 fallos, exit 0.
4. `verify_backups.ps1` verifica SHA-256 contra `checksums.txt` (§8).
5. Restauración de prueba mensual con log en la plantilla `10-Plantilla-Log-Restauracion.md` (§9, Criterio de Éxito).

# 2. Flujo de backup automático

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

# 3. Flujo de backup local

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

# 4. Estructura de almacenamiento

# Google Drive (Cloud)
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

# Disco Exterivo (Local)
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

# 5. Configuración de GitHub Actions

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

# 5.1 Procedimiento GCP/OAuth paso a paso (copia 2 — Drive)

> **Dueño de la ejecución: el fundador.** Los pasos de esta sección requieren **su cuenta de Google**;
> ningún agente puede ejecutarlos. Lo que sí es de este módulo es el **procedimiento**: hasta el
> 2026-10-23 los pasos estaban *enumerados* en `04-Codigo.md` §6 pero **sin instrucciones**, y
> `rclone authorize` —el paso que produce el token— no aparecía **ni una vez** en el repositorio
> (medido: `grep -rn "rclone authorize"` = 0).

Los 3 secrets que consume `.github/workflows/backup.yml` son `GDRIVE_CLIENT_ID`,
`GDRIVE_CLIENT_SECRET` y `GDRIVE_TOKEN`. El workflow tiene un **guard de secrets**: si falta
cualquiera de los tres **no falla** — genera el artefacto `.tar.gz` y salta la subida dejando el
aviso en el resumen. Consecuencia operativa: **un run verde NO prueba que Drive esté configurado**;
hay que leer el `GITHUB_STEP_SUMMARY`.

## Paso 1 — Crear el proyecto en Google Cloud Console

1. Entrar a <https://console.cloud.google.com> con la cuenta dueña del Drive destino.
2. Selector de proyecto (arriba a la izquierda) → **New Project**.
3. Nombre: `isla-ancestral-backups`. Ubicación: la organización que corresponda (o *No organization*).
4. **Create** y esperar. Anotar el **Project ID** (no el nombre visible: es el que aparece en las URLs).

## Paso 2 — Habilitar la Google Drive API

1. Ir a **APIs & Services → Library** (<https://console.cloud.google.com/apis/library>).
2. Buscar `Google Drive API` → **Enable**.
3. Verificar en **APIs & Services → Enabled APIs** que figura habilitada **en el proyecto del paso 1**.
   Habilitarla en otro proyecto es el error más común: la API queda activa y la credencial no la ve.

## Paso 3 — Configurar la pantalla de consentimiento

1. **APIs & Services → OAuth consent screen**
   (<https://console.cloud.google.com/apis/credentials/consent>).
2. **User Type:**
   - `External` si la cuenta es `@gmail.com` (caso normal del fundador).
   - `Internal` si es una cuenta de Google Workspace y el Drive es de la organización.
3. Completar *App name* (`Isla Ancestral Backups`), *User support email* y *Developer contact email*.
4. **Scopes** → *Add or remove scopes* → agregar `https://www.googleapis.com/auth/drive`.
   Es el scope que rclone usa por defecto y el único que permite **listar y borrar** lo que ya existe
   en la carpeta destino (la retención `--min-age 30d` lo necesita). `drive.file` no alcanza: solo ve
   los archivos creados por la propia app.
5. **Test users** (solo si la app queda en estado *Testing*): agregar la cuenta que va a autorizar.
6. **Estado de publicación — decisión operativa, no un detalle:**
   - En *Testing*, el **refresh token caduca a los 7 días** (política vigente de Google para apps
     *External* no verificadas). Un cron **semanal** se rompe en el segundo ciclo, y el workflow
     **igual reporta verde** (el guard solo mira que los secrets *existan*, no que el token sirva).
     Si se elige *Testing*, hay que **renovar `GDRIVE_TOKEN` cada 7 días**.
   - En *In production* el token no caduca por tiempo, pero el scope `auth/drive` es **restringido** y
     Google puede exigir verificación de la app. Para uso propio (una sola cuenta) el flujo funciona
     igual; la verificación es requisito de publicación pública.
   - **Recomendado:** *In production* con la cuenta del fundador como único usuario, aceptando que la
     app quede sin verificar. Aparece la pantalla "Google no ha verificado esta aplicación" →
     *Advanced* → *Go to … (unsafe)*: es esperado y no es un error del módulo.

## Paso 4 — Crear las credenciales OAuth

1. **APIs & Services → Credentials → Create credentials → OAuth client ID**.
2. **Application type: `Desktop app`.** No `Web application`: rclone usa el flujo de *app instalada*
   (loopback en `127.0.0.1`); una credencial *Web* exige un *Authorized redirect URI* que en este
   flujo no existe y la autorización falla con `redirect_uri_mismatch`.
3. Nombre: `rclone-isla-ancestral` → **Create**.
4. Copiar **Client ID** y **Client secret**. El secret se puede volver a consultar; si se pierde, se
   crea otra credencial.

## Paso 5 — Obtener el token OAuth (el paso que faltaba)

Se hace **en una máquina con navegador** (la del fundador), no en CI:

```bash
rclone authorize "drive" "<CLIENT_ID>" "<CLIENT_SECRET>"
```

1. rclone levanta un servidor local y abre el navegador; iniciar sesión con la cuenta del paso 3.
2. Aceptar el scope. Google redirige a `127.0.0.1` y rclone imprime un **JSON de una línea**:

   ```json
   {"access_token":"ya29...","token_type":"Bearer","refresh_token":"1//0g...","expiry":"2026-10-23T22:10:00.000000000-03:00"}
   ```

3. **Ese JSON completo es el valor de `GDRIVE_TOKEN`.** No el `access_token` suelto: sin
   `refresh_token` el workflow funciona **una hora** y después falla con `invalid_grant`. El `expiry`
   es informativo — rclone renueva solo con el refresh token.
4. No pegar el JSON en ningún archivo del repo, ni en un log, ni en un mensaje de canal: va **solo** al
   secret de GitHub (paso 6).

## Paso 6 — Cargar los 3 secrets en GitHub

Repo → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Valor |
|---|---|
| `GDRIVE_CLIENT_ID` | Client ID del paso 4 |
| `GDRIVE_CLIENT_SECRET` | Client secret del paso 4 |
| `GDRIVE_TOKEN` | JSON completo del paso 5, en **una sola línea** |

Los secrets de *repository* alcanzan: el workflow `Backup Externo` no declara `environment:`.

## Paso 7 — Verificar de punta a punta

1. **Actions → Backup Externo → Run workflow** (el `workflow_dispatch` existe para esto).
2. El step **"Detectar secrets de Google Drive"** debe imprimir `Secrets de Google Drive detectados.`
   Si imprime el `::warning::`, falta al menos uno de los 3.
3. El resumen del run debe decir `- Subido a Google Drive: isla-ancestral-backups/diario/`. Si dice
   `⚠️ Subida a Drive **saltada**`, la copia 2 **no** se hizo aunque el run esté verde.
4. Comprobar en Drive que existen `backup_<AAAAMMDD>.tar.gz` **y** su `.sha256` en
   `isla-ancestral-backups/diario/`.

## Notas de operación

- **Cadencia:** el cron es **semanal** (lunes 2 AM UTC) desde el GO del fundador del 2026-10-23
  (PAQ-6/H26, cuidar la cuota compartida de artifacts). La retención en Drive sigue siendo de
  **30 días** (`rclone delete --min-age 30d`), así que con cadencia semanal se conservan ~4 copias.
- **Referencia rota conocida:** el comentario del workflow cita `docs/backup_gdrive_setup.md`, que
  **no existe en el repositorio** (medido 2026-10-23: `git ls-files -- "*gdrive*"` = 0 archivos).
  La fuente autoritativa del procedimiento es **esta §5.1**.
- Esta sección documenta la **copia 2** (offsite). La **copia 3** (disco externo físico) es
  `backup_local.ps1` vía Task Scheduler — ver §6 y §7.

# 6. Script de backup local

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

# 7. Programación en Windows Task Scheduler

**Configuración:**
- **Nombre:** Isla Ancestral Backup Local
- **Trigger:** Diariamente a las 3:00 AM
- **Acción:** Iniciar programa `powershell.exe`
- **Argumentos:** `-ExecutionPolicy Bypass -File "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\scripts\backup\backup_local.ps1"`
- **Condiciones:**
  - "Iniciar solo si el equipo está conectado a la red de CA"
  - "Iniciar solo si está conectado a la alimentación de CA"
  - "Despertar el equipo para ejecutar esta tarea"

# 8. Script de verificación de integridad

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

# 9. Procedimiento de prueba de restauración

**Documento `docs/procedimiento_restauracion.md`:**
```markdown
# Procedimiento de Prueba de Restauración

# Frecuencia
Mensual (primer día de cada mes)

# Pasos

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

# Criterio de Éxito
- Restauración 100% exitosa
- Todos los archivos verifican con checksums
- Proyecto compila y ejecuta correctamente
- Sin errores en Godot Console
```

# 10. Plan de recuperación de desastres

**Documento `docs/plan_recuperacion_desastres.md`:**
```markdown
# Plan de Recuperación de Desastres

# Escenario 1: Pérdida de Máquina Local

# Severidad: Media
# Tiempo Estimado: 2-4 horas

# Pasos:
1. Adquirir nueva máquina o reinstalar sistema
2. Instalar Git, Godot 4.x, herramientas necesarias
3. Clonar repositorio: `git clone https://github.com/MauricioBelforte/juego-isla-ancestral.git`
4. Restaurar Git LFS: `git lfs pull`
5. Descargar builds desde GitHub Releases
6. Recuperar saves de prueba desde Google Drive
7. Verificar compilación y ejecución

# Verificación:
- [ ] Repositorio clonado exitosamente
- [ ] Assets restaurados
- [ ] Proyecto compila
- [ ] Proyecto ejecuta
- [ ] Saves recuperados

# Escenario 2: Corrupción de Repositorio Git

# Severidad: Alta
# Tiempo Estimado: 4-8 horas

# Pasos:
1. Identificar punto de corrupción
2. Recuperar desde backup de Google Drive más reciente
3. Recuperar desde disco externo como respaldo
4. Verificar integridad con checksums
5. Crear nuevo repositorio limpio
6. Restaurar historial desde backup
7. Verificar branches y tags
8. Actualizar remoto si es necesario

# Verificación:
- [ ] Backup recuperado
- [ ] Checksums verifican
- [ ] Historial completo restaurado
- [ ] Branches existen
- [ ] Tags existen

# Escenario 3: Pérdida de GitHub (Catastrófico)

# Severidad: Crítica
# Tiempo Estimado: 8-24 horas

# Pasos:
1. Evaluar situación (GitHub caído o cuenta comprometida)
2. Recuperar desde Google Drive (backup más reciente)
3. Recuperar desde disco externo (respaldo)
4. Crear nuevo repositorio en GitHub o GitLab
5. Restaurar historial completo
6. Configurar Git LFS en nuevo repositorio
7. Actualizar URLs remotas en clones locales
8. Verificar que todos los colaboradores pueden acceder

# Verificación:
- [ ] Código recuperado
- [ ] Historial completo
- [ ] Assets recuperados
- [ ] Colaboradores pueden acceder
- [ ] CI/CD reconfigurado

# Escenario 4: Pérdida de Assets Originales

# Severidad: Alta
# Tiempo Estimado: 4-12 horas

# Pasos:
1. Identificar assets perdidos
2. Recuperar desde Git LFS
3. Recuperar desde Google Drive
4. Recuperar desde disco externo
5. Reimportar en Godot
6. Verificar que no hay faltantes
7. Verificar que no hay corrupción
8. Reconstruir si es necesario

# Verificación:
- [ ] Assets recuperados
- [ ] Godot importa correctamente
- [ ] No hay faltantes
- [ ] No hay corrupción
- [ ] Builds funcionan
```

# 11. Reglas de calidad

# Regla 1: 3-2-1 Rule Obligatoria
- Mínimo 3 copias de todo dato importante
- Al menos 2 medios diferentes (cloud + físico)
- Al menos 1 copia offsite (cloud)

# Regla 2: Automatización
- Backups programados sin intervención manual
- Notificaciones de éxito/fracaso
- Logs de ejecución para auditoría

# Regla 3: Verificación Periódica
- Verificación de integridad semanal
- Prueba de restauración mensual
- Revisión de política trimestral

# Regla 4: Seguridad
- Backups cloud encriptados si contienen datos sensibles
- Discos externos almacenados en lugar seguro
- Control de acceso a backups

# Regla 5: Documentación
- Procedimientos claros y accesibles
- Plan de recuperación actualizado
- Logs de restauración para auditoría


# Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 11 | % de delta de backup incremental vs full | 5-15% | Tipico para backups incrementales. Proyeccion: 5% x 100 MB = 5 MB/dia, 35 MB/semana, 150 MB/mes. |
| 12 | Tiempo estimado de restauracion full+incremental | 3-6h (full 2-4h + incremental 1-2h) | Coherente con SLA <48h de M144. |


# Decisiones de diseno aplicadas (Reflection-Beam-1.0, 2026-10-23, GO del fundador)

# H22 — max_copias = POR CATEGORIA + CRC32/SHA-256 documentados

**Decision 1: max_copias = POR CATEGORIA (renombrado a max_copias_por_categoria)**
- backup_policy.json: retencion.max_copias -> retencion.max_copias_por_categoria = 5.
- max_copias_por_categoria = 5 por categoria x 7 categorias = 35 copias max. Total storage: 35 x tamano_medio. Coherente con retencion por categoria (retencion_dias por categoria).
- backup_categories.json: retencion global (diarios 30, semanales 52, mensuales 60) sigue vigente como politica de retencion por TIPO de backup, no por categoria.

**Decision 2: CRC32 (rapido, diario) + SHA-256 (fuerte, mensual) — mantener ambos**
- backup_policy.json: verificacion.checksum_habilitado = true, integrity_check_al_restaurar = true (AUDITORIA 2026-10-23: el JSON NO tiene campo "algoritmo" — CRC32 vive en el codigo, BackupManager.verificar_integridad, tabla #14 de este doc).
- verify_backups.ps1: SHA-256 (integridad fuerte, mensual).
- Razon: CRC32 para verificacion rapida diaria (bajo costo CPU), SHA-256 para integridad fuerte mensual (mayor seguridad). Documentado para evitar confusion en auditorias futuras.

# Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de retencion por capas** [x] - formula coherente con Policies del fundador si decide max_copias_por_categoria (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose vive en la seccion 'Presupuestos numericos II - formulas concretas' de este 03; los mensajes 252/257/260/265/267 son el origen de la asignacion (correccion de cita rota: Hy3 347, aplicada por director))
- **Presupuesto de verificacion de integridad** [x] - formula de algoritmos duales si mantiene ambos (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose vive en la seccion 'Presupuestos numericos II - formulas concretas' de este 03; los mensajes 252/257/260/265/267 son el origen de la asignacion (correccion de cita rota: Hy3 347, aplicada por director))

# Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

# 7. Retencion por capas
- Formula: retencion_total = diarios (30) + semanales (52) + mensuales (60) + permanentes (2) = 144 slots max. CONCILIACION (Hy3 343, director 21:40): la politica VIGENTE de retencion la define backup_categories.json (por categoria, 365/90/...); esta suma 30/52/60/2 = 144 es la meta de capacidad V2 del diseño, no la politica vigente. NOTA: son SLOTS POR CATEGORIA (diario/semanal/mensual/permanente), no duraciones en dias. NOTA 2026-10-23: el schedule GFS 30/52/60 es INTENTO DE DISENO — backup_categories.json (7 categorias: repositorio/assets/documentacion/builds/saves/musica/fuente) implementa retencion_dias por categoria (365/90/180/365/90/180/180), no el schedule 30/52/60. Conciliar o adoptar una sola politica.
- max_copias_por_categoria = 5 por categoria x 7 categorias = 35 copias max por tipo.
- Coherente con H22 (max_copias por categoria).
- Unidad: slots de backup. Dependencia: H22, M144 (SLA <48h).

# 8. Verificacion de integridad (algoritmos duales)
- Formula: CRC32 (verificacion rapida, diaria, O(n) con bajo costo CPU) + SHA-256 (integridad fuerte, mensual, O(n) con mayor costo CPU).
- CRC32 para verificacion diaria (velocidad), SHA-256 para integridad mensual (seguridad).
- Coherente con H22 (documentado en 03-Diseno.md).
- Unidad: algoritmo. Dependencia: H22.

# Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-8 (H22)**: max_copias = **POR-CATEGORIA (5x7=35)** y se MANTIENEN ambos algoritmos (CRC32 rapido diario / SHA-256 fuerte mensual). Tu flip de bloque 3 ya lo citó (5x7=35; CRC32 diario + SHA-256 mensual); solo se agrega la nota de GO del fundador. Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".



# Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25, riel design-docs agnes msg 258 lote 2)

Metodo produce-first: grep + lectura directa, sin ejecutar Godot. Citas archivo:Línea.

# 9. Retencion por capas (medida)
- data/backup/backup_categories.json (84 lineas): 7 categorias con retencion_dias 365/90/180/365/90/180/180 (L10/19/29/38/47/56/65) y frecuencias continuo x4 (repositorio RF1, assets RF2, documentacion RF3, fuente RF8), post_release x1 (builds RF4), semanal x2 (saves RF6, musica RF7); LFS en assets (L20).
- Politica GFS L68-73: diarios 30, semanales 52, mensuales 60, permanentes [repositorio, documentacion] — coincide con la suma Beam 314 ###7 (30+52+60+2 = 144 slots) como META DE CAPACIDAD; la politica vigente por categoria son los retencion_dias (doble politica ya documentada en este 03 L689).
- max_copias_por_categoria = 5 (backup_policy.json L5) x 7 categorias = 35 — verificado en code: BackupManager._max_copias() lee config.retencion.max_copias con default 5 (backup_manager.gd L48-49; autoload BackupManager, project.godot L119).
- DRIFTS medidos: (a) _limpiar_existentes_cat hardcodea max_dias = 30 (backup_manager.gd L315) en vez de leer retencion_dias por categoria (365/90/180) — la limpieza ignora la politica del JSON; (b) _limpiar_excedentes de raiz usa el maximo GLOBAL (L302-312) mientras _limpiar_existentes_cat usa el por-categoria (L314-335) — asimetria; (c) las frecuencias continuo/semanal/post_release NO estan automatizadas en runtime: BackupManager es bajo demanda (7 wrappers de categoria L65-84); el ejecutor externo es scripts/backup/backup_local.ps1 (raiz del repo, fuera de game/).
- Unidad: slots/dias. Dependencia: H22, M144 (SLA <48h).

# 10. Verificacion de integridad dual (medida)
- CRC32 en runtime: backup_manager.gd verificar_integridad L213-224 — formato "checksum\npayload", Validador.crc32_hex (L224); invocada al restaurar (integrity_check_al_restaurar = true, backup_policy.json L10 + backup_manager.gd L254).
- SHA-256 fuera de runtime: scripts/backup/verify_backups.ps1 L78 (Get-FileHash -Algorithm SHA256), checksums.txt con hashes hex-64 (regex L53), busca tambien en subcarpeta mensual/ (L70), log en <destino>/logs/verify.log (L93-95), exit codes 0 OK / 1 CORRUPTO-FALTANTE / 2 error (L97-103). Existe ademas restore_backup.ps1 (mismo directorio).
- backup_categories.json L74-78 declara verificacion {checksum_habilitado: true, algoritmo: "CRC32", integrity_check_al_restaurar: true}; backup_policy.json (11 lineas) NO tiene campo "algoritmo" — la correccion del Lote B (director msg 235, H22) es PRECISE: el JSON sin campo es el policy; el categories SÍ lo tiene (CRC32).
- Dual CONFIRMADO en disco (CRC32 rapido runtime + SHA-256 fuerte CLI) — coherente con Beam 314 ###8 y PAQ-8 (GO fundador 23oct 20:25).
- Cadencia: la verificacion SHA-256 "mensual" es MANUAL — 0 hits de scheduler/cron/Task en el repo y quality.yml no cablea verify_backups.ps1 (solo test_backup_m107.gd L358-362). El "mensual" es proceso, no automatizacion.
- Unidad: algoritmo. Dependencia: H22.
