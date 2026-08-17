**Modelo:** SWE-1.6
**Plataforma:** Devin

# 04-Codigo.md — Módulo 107: Backups

## 1. Carácter del Componente

Módulo de **infraestructura de desarrollo** que especifica la política de backups y recuperación de desastres. Implementable inmediatamente (depende solo de herramientas del sistema y configuración de GitHub). No crea código del juego, sino scripts de automatización y documentación.

**06-Plan-Testings.md:** NO aplica (es configuración de backups, no código que requiere tests del juego. Las pruebas de restauración son procedimientos manuales/documentados).

## 2. Archivos involucrados (implementación)

```
.github/workflows/backup.yml              → Workflow de GitHub Actions para backup automático
scripts/backup/backup_local.ps1           → Script de backup local (PowerShell)
scripts/backup/verify_backups.ps1         → Script de verificación de integridad
scripts/backup/restore_test.ps1           → Script de prueba de restauración (opcional)
docs/procedimiento_restauracion.md        → Procedimiento de prueba de restauración
docs/plan_recuperacion_desastres.md       → Plan de recuperación de desastres
docs/politica_retencion.md               → Política de retención de backups
logs/backup_log_*.txt                    → Logs de ejecución de backups
logs/verification_log_*.txt              → Logs de verificación de integridad
logs/restauracion_*.md                   → Logs de pruebas de restauración
E:\Backups\juego-isla-ancestral\          → Directorio de backups en disco externo
Google Drive: isla-ancestral-backups/     → Directorio de backups en cloud
```

## 3. Contratos de integración

### Entrada (desde otros módulos)
- **M59 (Guardado):** Saves del juego se respaldan automáticamente en carpeta separada
- **M122 (Crash Reporting):** Saves de crash se incluyen en backup semanal
- **M06 (Control de Versiones):** Repositorio Git es fuente primaria de backup

### Salida (hacia otros módulos)
- **M133 (Gestión del Proyecto):** Logs de restauración y plan de recuperación informan gestión de riesgos
- **M135 (Riesgos del Proyecto):** Plan de recuperación mitiga riesgos de pérdida de datos

### Configuración
- **GitHub Actions:** Configuración de secrets (GDRIVE_CLIENT_SECRET, GDRIVE_CLIENT_ID, GDRIVE_TOKEN)
- **Windows Task Scheduler:** Programación de backup_local.ps1
- **Google Drive API:** Configuración de OAuth para rclone

## 4. Implementación de backup_local.ps1 (completo)

El script ya está especificado en detalle en 03-Diseno.md (sección 6). Implementación:

```powershell
# scripts/backup/backup_local.ps1
[Ver código completo en 03-Diseno.md, sección 6]
```

**Pendientes de implementación:**
- Adaptar rutas al entorno real del desarrollador
- Configurar Task Scheduler con parámetros correctos
- Probar ejecución manual antes de programar

## 5. Implementación de verify_backups.ps1 (completo)

El script ya está especificado en detalle en 03-Diseno.md (sección 8). Implementación:

```powershell
# scripts/backup/verify_backups.ps1
[Ver código completo en 03-Diseno.md, sección 8]
```

**Pendientes de implementación:**
- Programar ejecución semanal en Task Scheduler
- Configurar notificación de resultados (email/log)
- Integrar con sistema de monitoreo (opcional)

## 6. Configuración de GitHub Actions

**Archivo `.github/workflows/backup.yml`:**
- Ya especificado en 03-Diseno.md (sección 5)
- Requiere configuración de secrets en GitHub
- Requiere configuración de Google Drive API

**Pasos de configuración:**
1. Crear proyecto en Google Cloud Console
2. Habilitar Google Drive API
3. Crear credenciales OAuth (Client ID + Secret)
4. Configurar pantalla de consentimiento
5. Obtener token de acceso OAuth
6. Agregar secrets a GitHub: GDRIVE_CLIENT_ID, GDRIVE_CLIENT_SECRET, GDRIVE_TOKEN
7. Habilitar GitHub Actions en el repositorio
8. Commit del archivo backup.yml

## 7. Configuración de Windows Task Scheduler

**Pasos:**
1. Abrir Task Scheduler (taskschd.msc)
2. Crear tarea básica
3. Nombre: "Isla Ancestral Backup Local"
4. Trigger: Diariamente a las 3:00 AM
5. Acción: Iniciar programa powershell.exe
6. Argumentos: `-ExecutionPolicy Bypass -File "ruta\backup_local.ps1"`
7. Condiciones:
   - "Iniciar solo si el equipo está conectado a la red de CA"
   - "Iniciar solo si está conectado a la alimentación de CA"
   - "Despertar el equipo para ejecutar esta tarea"
8. Configurar cuenta de usuario (con permisos suficientes)

## 8. Documentación a crear

### docs/procedimiento_restauracion.md
- Procedimiento de prueba de restauración mensual
- Pasos detallados
- Criterios de éxito
- Plantilla de log de restauración

### docs/plan_recuperacion_desastres.md
- Plan de recuperación para 4 escenarios
- Pasos detallados por escenario
- Tiempos estimados
- Criterios de verificación

### docs/politica_retencion.md
- Política de retención por tipo de dato
- Tabla de frecuencias
- Procedimiento de limpieza automática
- Excepciones y casos especiales

## 9. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear archivo .github/workflows/backup.yml | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/backup/backup_local.ps1 | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/backup/verify_backups.ps1 | **IMPLEMENTACIÓN INMEDIATA** |
| Configurar Google Drive API y OAuth | **IMPLEMENTACIÓN INMEDIATA** |
| Configurar secrets en GitHub | **IMPLEMENTACIÓN INMEDIATA** |
| Configurar Windows Task Scheduler | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/procedimiento_restauracion.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/plan_recuperacion_desastres.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/politica_retencion.md | **IMPLEMENTACIÓN INMEDIATA** |
| Primera prueba de restauración | M133 (Gestión del Proyecto) |
| Integración con M59 (saves) | M59 (Guardado) |
| Integración con M122 (crash saves) | M122 (Crash Reporting) |

## 10. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** Devin
**Fecha:** 2026-08-16 18:30:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 15 puntos de la sección 106 del plan maestro.
- Diseñé estrategia 3-2-1 de backups (GitHub + Cloud + Disco Externo).
- Especifiqué automatización con GitHub Actions (backup diario a las 2 AM).
- Diseñé script de backup local PowerShell con compresión y checksums.
- Diseñé script de verificación de integridad con SHA-256.
- Definí política de retención (30 días diarios, 12 meses semanales, 5 años mensuales).
- Especifiqué procedimiento de prueba de restauración mensual.
- Creé plan de recuperación de desastres para 4 escenarios.
- Documenté integración con M59 (Guardado), M122 (Crash Reporting), M133 (Gestión del Proyecto).

### Lo que NO pude hacer (honestidad obligatoria)
- Crear los archivos físicos (backup.yml, scripts .ps1, docs .md) — requiere implementación real.
- Configurar Google Drive API y OAuth — requiere acceso a cuenta de Google.
- Configurar secrets en GitHub — requiere acceso al repositorio.
- Configurar Windows Task Scheduler — requiere acceso a la máquina.
- Ejecutar primera prueba de restauración — requiere implementación previa.

### Recomendaciones para el próximo agente (implementador)
- Configurar Google Drive API antes de implementar el workflow de GitHub Actions.
- Probar los scripts de backup manualmente antes de programarlos en Task Scheduler.
- Verificar que el disco externo tenga suficiente espacio antes de programar backups automáticos.
- Documentar cualquier adaptación de rutas en los scripts (el desarrollador puede tener rutas diferentes).
- Realizar la primera prueba de restauración inmediatamente después de configurar el sistema.
- Revisar la política de retención trimestralmente y ajustar según necesidades.
- Mantener el plan de recuperación actualizado según cambios en el proyecto.
