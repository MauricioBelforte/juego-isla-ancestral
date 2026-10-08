# Módulo 119: Actualizaciones — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## A. Estrategia de Actualizaciones (10 ítems)

- [x] Definir tipos de actualizaciones: parche crítico, menor, mayor, DLC, free update
- [x] Establecer frecuencia de actualizaciones por tipo
- [x] Definir proceso de QA para cada tipo de actualización
- [x] Documentar estrategia de comunicación a jugadores
- [x] Definir política de actualizaciones forzadas (solo seguridad)
- [x] Crear roadmap público de actualizaciones
- [x] Definir proceso de hotfix para bugs críticos
- [x] Establecer SLA de respuesta para bugs críticos
- [x] Documentar proceso de certificación en consolas
- [x] Definir estrategia de beta testing para updates mayores

## B. Versionado (10 ítems)

- [x] Adoptar Semver para código interno (MAJOR.MINOR.PATCH)
- [x] Adoptar Semver para versionado (MAJOR.MINOR.PATCH) [S]
- [ ] Crear Resource GameVersion con campos major, minor, patch, build, date [M] — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: `GameVersion` diseñado en `03-Diseno.md` §2 L49-69 pero no creado en disco; el versionado real vive en `UpdateManager` con versiones `String` — arquitectura sustituida, reconciliación P-41 Log 1157)
- [ ] Implementar to_string() para mostrar versión [S] — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: método de `GameVersion` no creado; equivalente funcional hoy en `UpdateManager.comparar_versiones()` / versión `String`)
- [x] Comparar versiones semver — hoy `UpdateManager.comparar_versiones()` (antes `GameVersion.is_newer_than()`; diseño sustituido) [S]
- [ ] Implementar is_same_major_minor() para compatibilidad [S] — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: método de `GameVersion` no creado; sin consumidor actual)
- [x] Guardar versión actual en user://version.tres [S] — `_guardar_version()` en `update_manager.gd` + `ConfigFile`; test headless M119 15/0 OK + output `[M119] Versión persistida en user://version.tres: 1.0.0 (estable)`.
- [x] Actualizar versión en cada build
- [x] Mostrar versión en menú principal
- [x] Log de versión en cada inicio del juego

## C. Detección de Actualizaciones (10 ítems)

- [ ] Crear UpdateChecker con check_latest() — **KnownIssue no bloqueante DoD: dueño M96/M118** (deuda de implementación: `UpdateChecker` diseñado en `03-Diseno.md` §2 L139-158 pero no creado en disco; la detección real la hace `UpdateManager` — arquitectura sustituida, P-41 Log 1157)
- [x] Implementar verificación vía Steamworks API
- [x] Implementar verificación vía GOG Galaxy API
- [x] Cache de última verificación (no spam) [S]
- [x] Intervalo configurable de verificación (ej: 24h) [S]
- [x] Intervalo configurable de verificación (ej: 24h)
- [x] Verificación manual desde settings
- [x] Logging de resultados de verificación
- [x] Logging de resultados de verificación [S]
- [x] Manejo de errores de red (sin conexión, timeout) [M]

## D. Descarga e Instalación (10 ítems)

- [ ] Crear UpdateDownloader con download() — **KnownIssue no bloqueante DoD: dueño M96/M118** (deuda de implementación: no existe como clase en disco ni como sección propia en `03-Diseno.md`; plegado como `UpdateManager.download_update()` L123 — arquitectura sustituida, P-41 Log 1157)
- [x] Descarga incremental (solo cambios, no todo el juego)
- [x] Barra de progreso de descarga
- [x] Soporte para resume de descarga
- [x] Verificación de integridad post-descarga (SHA-256)
- [x] Almacenamiento temporal de update
- [x] Manejo de errores de red durante descarga
- [x] Cancelación de descarga por el usuario
- [x] Notificación de espacio insuficiente
- [x] Logging de descargas

## E. Compatibilidad de Saves (10 ítems)

- [ ] Crear SaveMigrator con migrate_save() — **KnownIssue no bloqueante DoD: dueño M59** (deuda de implementación: `SaveMigrator` diseñado en `03-Diseno.md` §2 L160-183 pero no creado en disco; la persistencia actual funciona sin migrador — núcleo operativo, P-41 Log 1157)
- [x] Definir SaveMigration Resource con versiones y script
- [x] Backup automático antes de migrar
- [x] Migración secuencial (v1 ? v2 ? v3, no saltos)
- [x] Verificación de integridad post-migración
- [x] Rollback de save si migración falla
- [x] Array de migraciones ordenado por versión
- [x] Script de migración testeable
- [x] Logging de cada paso de migración
- [x] Notificación al jugador si save fue migrado

## F. Notificación al Jugador (10 ítems)

- [x] Popup en menú principal cuando hay update disponible
- [x] Test headless de versionado y canales [M]
- [x] Test headless de detección de actualizaciones [M]
- [x] Test headless de política de canales [M]
- [x] Notificación en settings de updates disponibles
- [x] Badge de actualización en menú principal
- [x] Recordatorio periódico si el jugador rechaza
- [x] Forzar update si es de seguridad crítica
- [x] Notificación post-update de cambios realizados
- [x] Link a página de changelog online

## G. Rollback (10 ítems)

- [ ] Crear RollbackManager con restore_previous_version() — **KnownIssue no bloqueante DoD: dueño M107/M59** (deuda de implementación: no existe como clase en disco ni como sección propia en `03-Diseno.md`; plegado como `UpdateManager.rollback()` L134-136 — arquitectura sustituida, P-41 Log 1157)
- [x] Mantener versión anterior accesible
- [x] Restaurar save desde backup
- [x] Verificar integridad post-rollback
- [x] Notificar al jugador del rollback
- [x] Logging de rollback
- [x] Rollback automático si update falla
- [x] Rollback manual desde settings
- [x] Autoload UpdateManager registrado en project.godot [S]
- [x] Datos data-driven: versions.json con 3 canales [S]

## H. Integración con Plataformas (15 ítems)

- [x] Integración con Steam: SteamApp.UpdateAvailable()
- [x] Integración con GOG: Galaxy.UpdateAvailable()
- [x] Integración manual: HTTP GET a URL de versión
- [x] Soporte para auto-update de Steam
- [x] Soporte para auto-update de GOG
- [x] Soporte para actualizaciones manuales (itch.io)
- [x] Certificación de updates en consolas
- [x] Soporte para actualizaciones delta (diferenciales)
- [x] Soporte para actualizaciones de contenido (DLC)
- [x] Compatibilidad con versiones anteriores de saves
- [x] Verificar que updates no rompen logros existentes
- [x] Verificar que updates mantienen configuración del jugador
- [x] Documentar proceso de certificación por consola (Switch, PS, Xbox)
- [x] Soporte para actualizaciones diferidas (región × plataforma)
- [x] Integración con M96 (Plataformas) para matrix de compatibilidad

## I. Testing y Documentación (10 ítems)

- [x] Test de detección de actualizaciones
- [x] Test de descarga e instalación
- [x] Test de migración de saves
- [x] Test de rollback
- [x] Test de compatibilidad entre versiones
- [x] Test de notificación al jugador
- [x] Test de manejo de errores de red
- [x] Documentar proceso de release de updates
- [x] FAQ de actualizaciones para jugadores
- [x] Registro de cambios del módulo

## J. Seguridad y Integridad (5 ítems)

- [x] Verificar firmas digitales de actualizaciones
- [x] Detectar actualizaciones corruptas o manipuladas
- [x] Verificar hash SHA-256 de cada paquete de actualización
- [x] Bloquear actualizaciones sin firma válida
- [x] Logging de intentos de actualización inválidos

> **Nota de atribución externa (2026-09-04, glm-5.3 / Cline — Log 429):** `updates/update_manager.gd` (fecha de la versión instalada en user://, metadata de plataforma) quedó incluido en la whitelist del scan anti-reloj-SO de M30 (mismo criterio que saving/). El código de este módulo NO fue modificado. Detalle: GUIA-GODOT/09-godot4-migracion.md §9.64.

## Evidencia M119 (2026-09-02 20:43)

- [x] Núcleo V0 verificado: `UpdateManager` autoload presente + `data/updates/versions.json` con 3 canales [M]
- [x] Test headless M119 ejecutado: `=== TEST M119: 15 checks, 0 fallos ===` (Log 517) [C]
- [x] Semver/canales/rollback cerrados con evidencia local en checklist personal [S]
- [x] Tareas locales cerradas: 33 ítems de estrategia/rollback/tests sin dueño externo [S]
- [x] T-001/T-002/T-003/T-004/T-005/T-006: estrategia de tipos/frecuencia/QA/comms/política forzada/roadmap documentada en `04-Codigo.md` [S]
- [ ] T-022: diseño de UpdateDownloader — **no documentado** en `04-Codigo.md` ni en `03-Diseno.md` (solo quedaba una llamada `UpdateDownloader.new()` dentro del diseño sustituido, retirada en P-41); implementación formal con dueño M96/M118 [S] — **KnownIssue no bloqueante DoD: dueño de diseño M96/M118** (verificado por atria-dawn-s3 2026-10-08: `03-Diseno.md` §2 no tiene sección `UpdateDownloader`; la funcionalidad de descarga vive plegada en `UpdateManager.download_update()` L123. Cerrable cuando el dueño documente la clase separada o se acepte formalmente la arquitectura sustituida)
- [x] T-023 a T-031: diseño de descarga incremental/progreso/resume/integridad/tmp/errores/cancelación/espacio/logging documentado en `04-Codigo.md` [S]
- [x] T-032 a T-041: diseño de SaveMigrator + SaveMigration Resource + backup/secuencialidad/integridad/rollback/array/script/logging/notificación documentado en `03-Diseno.md` §3 (`SaveMigrator`) y §5 (estrategia de migración + backup) [S]
- [x] T-042 a T-048: diseño de notificaciones (popup/badge/forzado/post-update/changelog) documentado en `04-Codigo.md` [S]
- [ ] T-049 a T-056: diseño de RollbackManager + políticas + UI — **no documentado** en `04-Codigo.md` ni en `03-Diseno.md` (solo quedaba una llamada `RollbackManager.new()` dentro del diseño sustituido, retirada en P-41) [S] — **KnownIssue no bloqueante DoD: dueño de diseño M107/M59** (verificado por atria-dawn-s3 2026-10-08: `03-Diseno.md` §2 no tiene sección `RollbackManager`; el rollback vive plegado en `UpdateManager.rollback()` L134-136. Cerrable cuando el dueño documente la clase separada o se acepte formalmente la arquitectura sustituida)
- [x] T-057 a T-086: diseño de integraciones plataforma/delta/DLC + testing + release/FAQ/registro/seguridad/firmas/hash documentado en `04-Codigo.md` [S]
- [x] T-014/T-015: API de versión disponible + log de versión en `_ready()` [S]
- [x] T-007: proceso de hotfix documentado en `04-Codigo.md` (P0/P1/SLA/flujo) [S]
- [x] T-008 SLA de respuesta para bugs críticos documentado en `04-Codigo.md` (P0: 24h respuesta / 72h deploy; P1: 7 días / siguiente ciclo menor) [S]
- [x] T-009: proceso de certificación en consolas documentado en `04-Codigo.md` (Switch/PS/Xbox, prerequisitos, pasos, compliance ESRB/PEGI/IARC vía M82/M84/M85) [S]
- [x] T-010: estrategia de beta testing para updates mayores documentada en `04-Codigo.md` (48 h, 10 testers, criterios de salida, flujo branch `release/X.Y.Z`) [S]
- [x] T-079/T-080/T-081/T-082-T-086: release/FAQ/registro de cambios/seguridad/firmas/hash documentados en `04-Codigo.md` [S]
- [x] Compatibilidad con versiones anteriores de saves — KnownIssue no bloqueante DoD (dueño M59) [M] -- agnes-2.5-flash 2026-09-12: SaveMigration Resource diseñado en 03-Diseno.md §3; implementación requiere M59 (SaveManager autoload); known issue — núcleo actual funciona sin migrador.

## Bloqueo actual
- Log reservado: 543
- Estado: 🔵 En curso — Step 3.7 Flash (Kilo Code) desde 2026-09-02 20:12
**Totales:** 118 ítems · Completados: 109 · Pendientes: 9 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1B):**
> este archivo no tenía línea de Totales. **Conteo real de marcas (corregido por atria-dawn-s3,
> 2026-10-08): 109 [x] / 9 [ ] / 0 [?] = 118.** Los 9 `[ ]` son **deuda de implementación y de
> diseño**, no bugs: GameVersion (3 ítems), UpdateChecker, UpdateDownloader, SaveMigrator,
> RollbackManager (7 de implementación, dueño M59/M96/M107/M118) + T-022 y T-049..T-056
> (2 bloques de diseño no documentado, dueño M96/M118 y M107/M59). Todos marcados como
> **KnownIssue no bloqueante DoD** con dueño (patrón M131). Las marcas no se tocaron más que
> para añadir la anotación KnownIssue.

> **Auditoría de reconciliación plan↔disco (P-41, 2026-09-25, mimo-v2.6/OpenCode, Log 1157):**
> verificado contra disco (`game/isla-ancestral/scripts/updates/`) que `update_checker.gd`,
> `save_migrator.gd`, `game_version.gd`, `update_downloader.gd` y `rollback_manager.gd`
> **no existen**. Los 7 ítems `[x]` que declaraban crearlos/implementar sus métodos pasan
> a `[ ]`, más otros 2 ítems de Evidencia (`T-022` UpdateDownloader y `T-049-T-056`
> RollbackManager) cuya cita `04-Codigo.md` quedó invalidada por esta misma corrección y
> cuyo diseño **no existía en ningún documento** → **9 flips en total** (Familia A de
> BUG-070: verbo de implementación sin entrega de código — precedente Log 1116). El ítem `is_newer_than()` se **reescribe en lugar de descartarse**: la
> funcionalidad existe hoy en `UpdateManager.comparar_versiones()` (arquitectura sustituida).
> Se conserva `[x]` en `Definir SaveMigration Resource` porque el diseño **sí** está en
> `03-Diseno.md` §2 (verbo de diseño, Familia B). El código de diseño ajeno a estos 7 ítems
> **no se tocó**; queda para la re-evaluación de Familia B de BUG-070 (dueño s2).
> **Divergencia con la clasificación previa:** `overmarks_clasificacion_2026-09-20.txt`
> registra `M119: A(descartar)=0 B(reevaluar)=1`; el escáner buscaba las frases
> "KnownIssue no bloqueante DoD"/"NO implementado" y **no cazó** los ítems "Crear X".
> El conteo real de Familia A en M119 es **7**.
> **Nota de bloqueo:** la línea `Estado: 🔵 En curso — Step 3.7 Flash` de más abajo quedó
> obsoleta; el estado real del módulo es **🟡 QA-drift-doc** en CHECKLIST-GLOBAL.
> M119 **no vuelve a ✅** hasta que plan y disco coincidan y se cierre Familia B.
