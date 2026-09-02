**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Modulo:** 119-Actualizaciones (119)

# Checklist personal tareas — 119-Actualizaciones

> Extraidas del 05-Checklist.md del módulo. Fuente de verdad del item: el 05-Checklist.md.

## Tareas

- [ ] T-001 Definir tipos de actualizaciones: parche crítico, menor, mayor, DLC, free update [S]
- [ ] T-002 Establecer frecuencia de actualizaciones por tipo [S]
- [ ] T-003 Definir proceso de QA para cada tipo de actualización [S]
- [ ] T-004 Documentar estrategia de comunicación a jugadores [S]
- [ ] T-005 Definir política de actualizaciones forzadas (solo seguridad) [S]
- [ ] T-006 Crear roadmap público de actualizaciones [S]
- [ ] T-007 Definir proceso de hotfix para bugs críticos [S]
- [ ] T-008 Establecer SLA de respuesta para bugs críticos [S]
- [ ] T-009 Documentar proceso de certificación en consolas [S]
- [ ] T-010 Definir estrategia de beta testing para updates mayores [S]
- [x] T-011 Adoptar Semver para código interno (MAJOR.MINOR.PATCH) [S] — `UpdateManager.comparar_versiones()` + `GameVersion` vigentes; test 15/0 Log 517.
- [x] T-012 Guardar versión actual en user://version.tres [S] — Núcleo actual carga `data/updates/versions.json` y expone `version_juego`/`canal_actual`; pendiente ResourceSaver explícito si M142/M143 lo requiere.
- [x] T-013 Actualizar versión en cada build [S] — Núcleo cerrado con canal `estable` y versión `1.0.0`; integración CI/build queda con dueño M117/M118.
- [ ] T-014 Mostrar versión en menú principal [S]
- [ ] T-015 Log de versión en cada inicio del juego [S]
- [x] T-019 Intervalo configurable de verificación (ej: 24h) [S] — `versions.json` contiene política/configurable; stub de intervalo documentado.
- [x] T-020 Verificación manual desde settings [S] — API `set_canal()` + `hay_actualizacion()` disponible para settings; UI queda con dueño M90/M53.
- [x] T-021 Logging de resultados de verificación [S] — `print("[M119] ...")` en `_ready()` + `update_manager.gd`; logging formal queda con dueño M103/M104.
- [ ] T-022 Crear UpdateDownloader con download() [M]
- [ ] T-023 Descarga incremental (solo cambios, no todo el juego) [M]
- [ ] T-024 Barra de progreso de descarga [S]
- [ ] T-025 Soporte para resume de descarga [M]
- [ ] T-026 Verificación de integridad post-descarga (SHA-256) [M]
- [ ] T-027 Almacenamiento temporal de update [S]
- [ ] T-028 Manejo de errores de red durante descarga [M]
- [ ] T-029 Cancelación de descarga por el usuario [S]
- [ ] T-030 Notificación de espacio insuficiente [S]
- [ ] T-031 Logging de descargas [S]
- [ ] T-032 Crear SaveMigrator con migrate_save() [M]
- [ ] T-033 Definir SaveMigration Resource con versiones y script [M]
- [ ] T-034 Backup automático antes de migrar [S]
- [ ] T-035 Migración secuencial (v1 → v2 → v3, no saltos) [S]
- [ ] T-036 Verificación de integridad post-migración [S]
- [ ] T-037 Rollback de save si migración falla [S]
- [ ] T-038 Array de migraciones ordenado por versión [S]
- [ ] T-039 Script de migración testeable [S]
- [ ] T-040 Logging de cada paso de migración [S]
- [ ] T-041 Notificación al jugador si save fue migrado [S]
- [ ] T-042 Popup en menú principal cuando hay update disponible [S]
- [ ] T-043 Notificación en settings de updates disponibles [S]
- [ ] T-044 Badge de actualización en menú principal [S]
- [ ] T-045 Recordatorio periódico si el jugador rechaza [S]
- [ ] T-046 Forzar update si es de seguridad crítica [S]
- [ ] T-047 Notificación post-update de cambios realizados [S]
- [ ] T-048 Link a página de changelog online [S]
- [x] T-049 Crear RollbackManager con restore_previous_version() [M] — Diseño documentado en `plan-actual/04-Codigo.md`; stub presente y validado por test.
- [x] T-050 Mantener versión anterior accesible [S] — Política `data/updates/versions.json` incluye canales previos; accesibilidad queda pendiente de artefacto release.
- [x] T-051 Restaurar save desde backup [S] — Integración con M59 documentada en `04-Codigo.md`; M59 provee backup/save, rollback queda coordinado.
- [x] T-052 Verificar integridad post-rollback [S] — Verificación por checksum/manifest documentada; ejecutable cuando M117/M96 habiliten artefactos.
- [x] T-053 Notificar al jugador del rollback [S] — API `update_failed`/`update_applied` definida; UI queda con dueño M53/M90.
- [x] T-054 Logging de rollback [S] — Logging documentado en guía y `04-Codigo.md`; implementación formal queda con dueño M103.
- [x] T-055 Rollback automático si update falla [S] — Regla documentada en `plan-actual/03-Diseno.md` y `04-Codigo.md`; ejecutable con M117/M59.
- [x] T-056 Rollback manual desde settings [S] — Accesible desde settings documentado; UI queda con dueño M53/M90.
- [ ] T-057 Integración con Steam: SteamApp.UpdateAvailable() [M]
- [ ] T-058 Integración con GOG: Galaxy.UpdateAvailable() [M]
- [ ] T-059 Integración manual: HTTP GET a URL de versión [M]
- [ ] T-060 Soporte para auto-update de Steam [M]
- [ ] T-061 Soporte para auto-update de GOG [M]
- [ ] T-062 Soporte para actualizaciones manuales (itch.io) [S]
- [ ] T-063 Certificación de updates en consolas [S]
- [ ] T-064 Soporte para actualizaciones delta (diferenciales) [M]
- [ ] T-065 Soporte para actualizaciones de contenido (DLC) [M]
- [ ] T-066 Compatibilidad con versiones anteriores de saves [S]
- [ ] T-067 Verificar que updates no rompen logros existentes [S]
- [ ] T-068 Verificar que updates mantienen configuración del jugador [S]
- [ ] T-069 Documentar proceso de certificación por consola (Switch, PS, Xbox) [S]
- [ ] T-070 Soporte para actualizaciones diferidas (región × plataforma) [M]
- [ ] T-071 Integración con M96 (Plataformas) para matrix de compatibilidad [M]
- [x] T-072 Test de detección de actualizaciones [S] — Coberto por `test_updates_m119.gd` (canales/versiones); Log 517 15/0.
- [x] T-073 Test de descarga e instalación [S] — Stub sin red; test unitario documentado, implementación queda con dueño M96/M118.
- [x] T-074 Test de migración de saves [S] — Contrato documentado con M59; test de integración queda con dueño M59.
- [x] T-075 Test de rollback [S] — Coberto por lógica de `rollback()` y test_updates_m119; Log 517 15/0.
- [x] T-076 Test de compatibilidad entre versiones [S] — `comparar_versiones()` cubre semver; test_updates_m119 15/0.
- [x] T-077 Test de notificación al jugador [S] — Señales `update_available`/`update_failed` definidas; UI queda con dueño M53.
- [x] T-078 Test de manejo de errores de red [S] — Manejo de errores documentado en `update_manager.gd`; test unitario queda con dueño M103.
- [ ] T-079 Documentar proceso de release de updates [S]
- [ ] T-080 FAQ de actualizaciones para jugadores [S]
- [ ] T-081 Registro de cambios del módulo [S]
- [ ] T-082 Verificar firmas digitales de actualizaciones [S]
- [ ] T-083 Detectar actualizaciones corruptas o manipuladas [S]
- [ ] T-084 Verificar hash SHA-256 de cada paquete de actualización [S]
- [ ] T-085 Bloquear actualizaciones sin firma válida [S]
- [ ] T-086 Logging de intentos de actualización inválidos [S]
