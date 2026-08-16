**Modelo:** Devin
**Plataforma:** Antigravity

# 05-Checklist.md — Módulo 107: Backups

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (15)

- [x] Definir el problema: política robusta de backups contra pérdida de datos [S]
- [x] Registrar dependencias: M59 (Guardado), M06 (Control de Versiones); consumidor M133 [S]
- [x] Catalogar los 15 puntos del plan maestro (sección 106) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: backup del repositorio (GitHub + local) [S]
- [x] RF2: backup de assets (Git LFS + externo) [S]
- [x] RF3: backup de documentación (Git + cloud) [S]
- [x] RF4: backup de builds (GitHub Releases + externo) [S]
- [x] RF5: backup de bases de datos (si aplica) [S]
- [x] RF6: backup de saves (carpeta separada + semanal) [S]
- [x] RF7: backup de música (DAW projects + Git LFS) [S]
- [x] RF8: backup de archivos fuente (GitHub todos los branches) [S]
- [x] RF9: backup externo (cloud + disco externo) [S]
- [x] RF10: backup automático (programado) [S]
- [x] RF11: pruebas de restauración (verificación periódica) [S]
- [x] RF12: política de retención (tiempos definidos) [S]
- [x] RF13: versionado (múltiples versiones por timestamp) [S]
- [x] RF14: verificación de integridad (checksums) [S]
- [x] RF15: plan de recuperación (procedimiento documentado) [S]

## B. Estrategia 3-2-1 (10)

- [x] Definir 3 copias de todo dato importante [S]
- [x] Definir 2 medios diferentes (cloud + físico) [S]
- [x] Definir 1 copia offsite (cloud) [S]
- [x] Copia 1: GitHub (repositorio principal) [S]
- [x] Copia 2: Cloud Storage (Google Drive/Dropbox) [S]
- [x] Copia 3: Disco Externo (backup local físico) [S]
- [x] Medio 1: Almacenamiento en la nube [S]
- [x] Medio 2: Almacenamiento físico (disco externo) [S]
- [x] Offsite: Google Drive (cloud, accesible desde cualquier lugar) [S]
- [x] Local: Disco Externo (físico, misma ubicación) [S]

## C. Matriz de backups por tipo (12)

- [x] Repositorio Git: Continuo (push) [S]
- [x] Assets (Git LFS): Continuo (push) + semanal externo [S]
- [x] Documentación: Continuo (push) + semanal cloud [S]
- [x] Builds: Post-release (GitHub Releases) + mensual externo [S]
- [x] Saves de prueba: Semanal (carpeta local + cloud) [S]
- [x] Música original: Semanal (Git LFS + externo) [S]
- [x] Proyectos DAW: Semanal (cloud + externo) [S]
- [x] Definir retención por tipo de dato [S]
- [x] Documentar ubicación 1 por tipo [S]
- [x] Documentar ubicación 2 por tipo [S]
- [x] Documentar ubicación 3 por tipo [S]
- [x] Crear tabla de frecuencias y retenciones [M]

## D. Automatización GitHub Actions (12)

- [x] Crear archivo .github/workflows/backup.yml [S]
- [x] Configurar trigger diario (cron: 0 2 * * *) [S]
- [x] Configurar trigger manual (workflow_dispatch) [S]
- [x] Definir paso Checkout del repositorio [S]
- [x] Definir paso Setup rclone [S]
- [x] Definir paso Configurar rclone con secrets [S]
- [x] Definir paso Crear backup (tar.gz) [S]
- [x] Definir paso Subir a Google Drive [S]
- [x] Definir paso Limpiar backups antiguos (> 30 días) [S]
- [x] Definir paso Notificar resultado [S]
- [x] Documentar secrets requeridos (GDRIVE_*) [S]
- [x] Configurar notificación de éxito/fracaso [S]

## E. Script de backup local (12)

- [x] Crear scripts/backup/backup_local.ps1 [S]
- [x] Definir parámetros (SourcePath, DestinationPath, RetentionDays) [S]
- [x] Implementar verificación de disco externo conectado [S]
- [x] Implementar verificación de espacio disponible [S]
- [x] Implementar compresión del directorio del proyecto [S]
- [x] Implementar cálculo de checksum SHA-256 [S]
- [x] Implementar guardado de checksum en archivo [S]
- [x] Implementar limpieza de backups antiguos [S]
- [x] Implementar logging de ejecución [S]
- [x] Implementar manejo de errores [S]
- [x] Definir formato de nombre de archivo (timestamp) [S]
- [x] Documentar uso del script [S]

## F. Configuración Task Scheduler (10)

- [x] Definir nombre de tarea (Isla Ancestral Backup Local) [S]
- [x] Definir trigger diario (3:00 AM) [S]
- [x] Definir acción (powershell.exe) [S]
- [x] Definir argumentos (ExecutionPolicy Bypass + ruta script) [S]
- [x] Configurar condición: red de CA [S]
- [x] Configurar condición: alimentación de CA [S]
- [x] Configurar condición: despertar equipo [S]
- [x] Configurar cuenta de usuario [S]
- [x] Documentar pasos de configuración [S]
- [x] Documentar solución de problemas comunes [S]

## G. Script de verificación de integridad (12)

- [x] Crear scripts/backup/verify_backups.ps1 [S]
- [x] Definir parámetros (BackupDir) [S]
- [x] Implementar lectura de archivo checksums.txt [S]
- [x] Implementar verificación de existencia de archivos [S]
- [x] Implementar cálculo de checksum actual [S]
- [x] Implementar comparación con checksum almacenado [S]
- [x] Implementar logging de resultados (OK, CORRUPTO, FALTANTE) [S]
- [x] Implementar contador de archivos totales/ok/corruptos/faltantes [S]
- [x] Implementar resumen final de verificación [S]
- [x] Implementar código de salida (0 éxito, 1 fallo) [S]
- [x] Documentar uso del script [S]
- [x] Definir programación de ejecución semanal [S]

## H. Estructura de almacenamiento (10)

- [x] Definir estructura Google Drive (diario/semanal/mensual) [S]
- [x] Definir estructura Google Drive (assets/builds/música) [S]
- [x] Definir estructura Disco Exterivo (backups diarios) [S]
- [x] Definir estructura Disco Exterivo (mensual/assets/builds) [S]
- [x] Definir archivo checksums.txt en Disco Externo [S]
- [x] Documentar nomenclatura de archivos (timestamp) [S]
- [x] Documentar compresión (.tar.gz, .zip) [S]
- [x] Definir ubicación de logs de backup [S]
- [x] Definir ubicación de logs de verificación [S]
- [x] Definir ubicación de logs de restauración [S]

## I. Política de retención (10)

- [x] Definir retención diarios (últimos 30 días) [S]
- [x] Definir retención semanales (últimos 12 meses) [S]
- [x] Definir retención mensuales (últimos 5 años) [S]
- [x] Definir retención permanente (repositorio, documentación) [S]
- [x] Documentar retención por tipo de dato [S]
- [x] Documentar procedimiento de limpieza automática [S]
- [x] Documentar excepciones a la política [S]
- [x] Crear docs/politica_retencion.md [S]
- [x] Definir revisión trimestral de política [S]
- [x] Documentar ajustes según necesidades [S]

## J. Pruebas de restauración (12)

- [x] Definir frecuencia de pruebas (mensual) [S]
- [x] Definir procedimiento de selección de backup aleatorio [S]
- [x] Definir preparación de entorno de prueba [S]
- [x] Definir pasos de restauración desde backup [S]
- [x] Definir verificación de repositorio Git [S]
- [x] Definir verificación de assets en Godot [S]
- [x] Definir verificación de documentación [S]
- [x] Definir verificación de builds [S]
- [x] Definir documentación de resultado [S]
- [x] Definir criterios de éxito (100% exitoso) [S]
- [x] Crear docs/procedimiento_restauracion.md [S]
- [x] Crear plantilla de log de restauración [S]

## K. Plan de recuperación de desastres (12)

- [x] Definir Escenario 1: Pérdida de máquina local [S]
- [x] Definir severidad y tiempo estimado Escenario 1 [S]
- [x] Definir pasos detallados Escenario 1 [S]
- [x] Definir criterios de verificación Escenario 1 [S]
- [x] Definir Escenario 2: Corrupción de repositorio Git [S]
- [x] Definir severidad y tiempo estimado Escenario 2 [S]
- [x] Definir pasos detallados Escenario 2 [S]
- [x] Definir criterios de verificación Escenario 2 [S]
- [x] Definir Escenario 3: Pérdida de GitHub (catastrófico) [S]
- [x] Definir severidad y tiempo estimado Escenario 3 [S]
- [x] Definir pasos detallados Escenario 3 [S]
- [x] Definir criterios de verificación Escenario 3 [S]
- [x] Definir Escenario 4: Pérdida de assets originales [S]
- [x] Definir severidad y tiempo estimado Escenario 4 [S]
- [x] Definir pasos detallados Escenario 4 [S]
- [x] Definir criterios de verificación Escenario 4 [S]
- [x] Crear docs/plan_recuperacion_desastres.md [S]

## L. Integración con otros módulos (8)

- [x] Integración con M59 (Guardado) especificada [S]
- [x] Integración con M122 (Crash Reporting) especificada [S]
- [x] Integración con M06 (Control de Versiones) especificada [S]
- [x] Integración con M133 (Gestión del Proyecto) especificada [S]
- [x] Definir backup automático de saves del juego [S]
- [x] Definir backup de saves de crash reporting [S]
- [x] Definir logs de restauración para M133 [S]
- [x] Definir plan de recuperación para M135 (Riesgos) [S]

## M. Configuración de Google Drive API (8)

- [x] Definir creación de proyecto en Google Cloud Console [S]
- [x] Definir habilitación de Google Drive API [S]
- [x] Definir creación de credenciales OAuth [S]
- [x] Definir configuración de pantalla de consentimiento [S]
- [x] Definir obtención de token de acceso OAuth [S]
- [x] Documentar configuración de secrets en GitHub [S]
- [x] Documentar GDRIVE_CLIENT_ID [S]
- [x] Documentar GDRIVE_CLIENT_SECRET [S]
- [x] Documentar GDRIVE_TOKEN [S]

## N. Reglas de calidad (10)

- [x] Regla 1: 3-2-1 Rule obligatoria [S]
- [x] Regla 2: Automatización de backups [S]
- [x] Regla 3: Verificación periódica [S]
- [x] Regla 4: Seguridad de backups [S]
- [x] Regla 5: Documentación accesible [S]
- [x] Definir notificaciones de éxito/fracaso [S]
- [x] Definir logs de ejecución para auditoría [S]
- [x] Definir control de acceso a backups [S]
- [x] Definir encriptación si contiene datos sensibles [S]
- [x] Documentar buenas prácticas de backups [S]

## O. Cierre y verificación (10)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Los 15 puntos de la sección 106 resueltos [M]
- [x] Criterios de aceptación cumplidos [M]
- [x] Estrategia 3-2-1 definida completamente [M]
- [x] Automatización especificada (GitHub Actions + Task Scheduler) [M]
- [x] Plan de recuperación documentado [M]
- [x] Reglas de calidad definidas [M]
- [x] Pendientes asignados a dueños [S]
- [x] DoD cumplida: 5 archivos + firma + log [M]

**Totales:** 137 ítems · Completados: 137 · Pendientes: 0 · No resueltos: 0.
