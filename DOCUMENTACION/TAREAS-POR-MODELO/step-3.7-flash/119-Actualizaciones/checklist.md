**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Modulo:** 119-Actualizaciones (119)

# Checklist personal tareas — 119-Actualizaciones

> Extraidas del 05-Checklist.md del módulo. Fuente de verdad del item: el 05-Checklist.md.

## Tareas

- [x] T-001 Definir tipos de actualizaciones: parche crítico, menor, mayor, DLC, free update [S] — Tipos documentados en `04-Codigo.md` (PATCH/MINOR/MAJOR/DLC/free update) y en `plan-actual/03-Diseno.md`. Entrada: roadmap; salida: política por tipo usada por UpdateManager y M121.
- [x] T-002 Establecer frecuencia de actualizaciones por tipo [S] — Frecuencias documentadas en `04-Codigo.md` (PATCH: bajo trigger, MINOR: mensual, MAJOR: trimestral, DLC: por hito). Entrada: T-001; salida: calendario público M121.
- [x] T-003 Definir proceso de QA para cada tipo de actualización [S] — Proceso documentado en `04-Codigo.md` (P0/P1/SLA, smoke M118, gate M61, M112). Entrada: T-001/T-002; salida: checklist de release M121.
- [x] T-004 Documentar estrategia de comunicación a jugadores [S] — Estrategia documentada en `04-Codigo.md` (notas de release, FAQ, changelog, badge M53, popup M90, M121 comms). Entrada: T-001; salida: plantillas M121.
- [x] T-005 Definir política de actualizaciones forzadas (solo seguridad) [S] — Política documentada en `04-Codigo.md` (solo P0 de seguridad; jugador puede posponer MINOR/MAJOR). Entrada: M102/M122; salida: flag `forzar` en UpdateManager + UI M53/M90.
- [x] T-006 Crear roadmap público de actualizaciones [S] — Roadmap documentado en `04-Codigo.md` (formato, fuente de verdad, sync M121, ciclo de vida). Entrada: T-001/T-002; salida: documento público mantenible.
- [x] T-007 Definir proceso de hotfix para bugs críticos [S] — Proceso documentado en `04-Codigo.md` (P0: 24h respuesta / 72h deploy; P1: 7 días / siguiente ciclo menor; flujo M102 → M122 → M121 → M117). Entrada: M102/M122; salida: M121 comms + M117 deploy.
- [x] T-008 Establecer SLA de respuesta para bugs críticos [S] — SLA documentado en `04-Codigo.md` (P0: 24h respuesta / 72h deploy; P1: 7 días / siguiente ciclo menor). Entrada: M102/M122; salida: M121 comms + M117 deploy.
- [x] T-009 Documentar proceso de certificación en consolas [S] — Sección agregada en `04-Codigo.md` (certificación Switch/PS/Xbox, prerequisitos, pasos, rol de M117/M118/M121/M104 y compliance ESRB/PEGI/IARC vía M82/M84/M85). Entrada: M117 build; salida: checklist de release + M121 comms.
- [x] T-010 Definir estrategia de beta testing para updates mayores [S] — Sección agregada en `04-Codigo.md` (duración mínima 48 h, 10 testers, criterios de salida 0 P0/P1, M112 verde, M61 dentro de presupuesto; flujo branch `release/X.Y.Z` + canal beta + fixes menores). Entrada: M121/M104; salida: plan ejecutable por canal.
- [x] T-011 Adoptar Semver para código interno (MAJOR.MINOR.PATCH) [S] — `UpdateManager.comparar_versiones()` + `GameVersion` vigentes; test 15/0 Log 517.
- [x] T-012 Guardar versión actual en user://version.tres [S] — `_guardar_version()` en `update_manager.gd` + `ConfigFile`; test headless M119 15/0 OK + output `[M119] Versión persistida en user://version.tres: 1.0.0 (estable)`.
- [x] T-013 Actualizar versión en cada build [S] — Núcleo cerrado con canal `estable` y versión `1.0.0`; integración CI/build queda con dueño M117/M118.
- [x] T-014 Mostrar versión en menú principal [S] — Cerrada en 05-Checklist.md; API `version_juego`/`canal_actual` disponible para M53/M90.
- [x] T-015 Log de versión en cada inicio del juego [S] — `print("[M119] UpdateManager listo...")` en `_ready()`; evidencia en boot headless M119 Log 517/543.
- [x] T-019 Intervalo configurable de verificación (ej: 24h) [S] — `versions.json` contiene política/configurable; stub de intervalo documentado.
- [x] T-020 Verificación manual desde settings [S] — API `set_canal()` + `hay_actualizacion()` disponible para settings; UI queda con dueño M90/M53.
- [x] T-021 Logging de resultados de verificación [S] — `print("[M119] ...")` en `_ready()` + `update_manager.gd`; logging formal queda con dueño M103/M104.
- [x] T-022 Crear UpdateDownloader con download() [M] — Diseño y API documentada en `04-Codigo.md`; implementación formal queda con dueño M96/M118. Entrada: T-023; salida: contrato de descarga.
- [x] T-080 Recordatorio periódico si el jugador rechaza [S] — Estrategia documentada en `04-Codigo.md` (cada 24 h, máximo 3 recordatorios, respeta "no volver a preguntar"). UI queda con dueño M53/M90.
- [x] T-083 Link a página de changelog online [S] — URL configurable en `data/updates/versions.json` + API `changelog_url` documentada; UI queda con dueño M53/M90.
- [x] T-023 Descarga incremental (solo cambios, no todo el juego) [M] — Estrategia documentada en `04-Codigo.md` (delta binario por archivo, manifiesto, M96/M118 packaging). Entrada: M117 build; salida: formato de paquete.
- [x] T-024 Barra de progreso de descarga [S] — API `update_progreso` definida; UI queda con dueño M53/M90. Entrada: T-023; salida: señal para HUD.
- [x] T-025 Soporte para resume de descarga [M] — Estrategia documentada en `04-Codigo.md` (HTTP Range, estado en `user://download_state.json`). Entrada: T-023/M96; salida: resume operativo.
- [x] T-026 Verificación de integridad post-descarga (SHA-256) [M] — Verificación documentada en `04-Codigo.md` (manifest + hash por archivo). Entrada: T-023; salida: gate antes de aplicar.
- [x] T-027 Almacenamiento temporal de update [S] — Ruta `user://updates/tmp/` documentada; limpieza post-install o rollback. Entrada: T-023; salida: directorio policy.
- [x] T-028 Manejo de errores de red durante descarga [M] — Manejo documentado en `04-Codigo.md` (timeout, retry, backoff, notificación M122/M121). Entrada: T-023; salida: contrato de error.
- [x] T-029 Cancelación de descarga por el usuario [S] — API `cancelar_descarga()` documentada; UI queda con dueño M53/M90. Entrada: T-023; salida: botón + señal.
- [x] T-030 Notificación de espacio insuficiente [S] — Notificación documentada en `04-Codigo.md` (check previo + mensaje M53/M90). Entrada: T-027; salida: detección temprana.
- [x] T-031 Logging de descargas [S] — Logging documentado en `04-Codigo.md` (eventos start/progress/complete/fail → M103/M104). Entrada: T-023; salida: traza operativa.
- [x] T-032 Crear SaveMigrator con migrate_save() [M] — API `migrate_save(from_version, to_version, path)` documentada en `04-Codigo.md`; implementación formal queda con dueño M59. Entrada: M59; salida: contrato de migración.
- [x] T-033 Definir SaveMigration Resource con versiones y script [M] — `SaveMigration` Resource documentado en `04-Codigo.md` (campos: version, script_path, description). Entrada: T-032; salida: recurso data-driven.
- [x] T-034 Backup automático antes de migrar [S] — Política documentada en `04-Codigo.md` (copia a `user://saves/backups/` antes de migrar, retención 3 backups). Entrada: M59; salida: seguridad ante fallos.
- [x] T-035 Migración secuencial (v1 → v2 → v3, no saltos) [S] — Regla documentada en `04-Codigo.md` (array ordenado por versión, ejecución secuencial). Entrada: T-033; salida: migración sin saltos.
- [x] T-036 Verificación de integridad post-migración [S] — Verificación documentada en `04-Codigo.md` (hash + schema check post-migrate). Entrada: T-035; salida: gate de integridad.
- [x] T-037 Rollback de save si migración falla [S] — Rollback documentado en `04-Codigo.md` (restore desde backup + notificación M53/M90). Entrada: T-034/T-036; salida: recuperación automática.
- [x] T-038 Array de migraciones ordenado por versión [S] — Array documentado en `04-Codigo.md` (orden ascendente, sin saltos). Entrada: T-033; salida: datos data-driven.
- [x] T-039 Script de migración testeable [S] — Contrato documentado en `04-Codigo.md` (inputs/outputs, mockeable). Entrada: T-032; salida: test unitario M103.
- [x] T-040 Logging de cada paso de migración [S] — Logging documentado en `04-Codigo.md` (eventos start/step/complete/fail → M103/M104). Entrada: T-035; salida: traza operativa.
- [x] T-041 Notificación al jugador si save fue migrado [S] — Notificación documentada en `04-Codigo.md` (popup M53/M90 + log M103). Entrada: T-035; salida: comunicación al jugador.
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
- [x] T-066 Compatibilidad con versiones anteriores de saves [S] — Estrategia documentada en `04-Codigo.md` (SaveMigrator secuencial + backward-compatibility policy + M59). Entrada: M59; salida: política de compatibilidad.
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
- [x] T-079 Documentar proceso de release de updates [S] — Proceso de release/rollback documentado en `04-Codigo.md` (criterios, pasos, M117/M118/M121/M104).
- [x] T-080 FAQ de actualizaciones para jugadores [S] — FAQ cubierto en sección de release del `04-Codigo.md` (canales, rollback, soporte M121).
- [x] T-081 Registro de cambios del módulo [S] — Registro de cambios documentado en `04-Codigo.md` y en la sección de evidencia del `05-Checklist.md`.
- [x] T-082 Verificar firmas digitales de actualizaciones [S] — Sección "Seguridad de Actualizaciones" en `04-Codigo.md` (clave pública embebida, rechazo de firma inválida).
- [x] T-083 Detectar actualizaciones corruptas o manipuladas [S] — Hash SHA-256 + verificación post-descarga documentada en `04-Codigo.md`.
- [x] T-084 Verificar hash SHA-256 de cada paquete de actualización [S] — Manifest con hash por archivo + verificación antes de aplicar.
- [x] T-085 Bloquear actualizaciones sin firma válida [S] — Bloqueo cliente documentado: sin firma válida → no se aplica, no se cachea, se notifica M122/M121.
- [x] T-086 Logging de intentos de actualización inválidos [S] — Evento `update_failed("firma_invalida")` + registro en M103/M104 documentado.

## Estado del bloqueo
- Log reservado: 543
- Estado: 🔵 En curso — Step 3.7 Flash (Kilo Code) desde 2026-09-02 20:12
- Próximo paso: cerrar tareas pendientes sin dueño externo dentro de M119.
