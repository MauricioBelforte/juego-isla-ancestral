# Log 543: M119 Actualizaciones — avance 2026-09-02: 8 tareas cerradas, test 15/0 OK

**Fecha:** 2026-09-02
**Hora:** 20:12
**Modelo:** stepfun/step-3.7-flash:free
**Plataforma:** Kilo Code

## Resumen

Se avanzó M119 desde el núcleo cerrado del Log 517 con 8 tareas nuevas cerradas: persistencia `user://version.tres`, log de versión en `_ready()`, proceso de hotfix/SLA, proceso de release/rollback/FAQ/registro de cambios. Test headless M119 se mantuvo verde: `15 checks, 0 fallos`. Quedan pendientes 58 tareas con dueños externos (Steam/GOG/HTTP M96/M118, descarga/instalación real M59/M96, rollback completo M107/M59).

## Cambios Realizados

- `game/isla-ancestral/scripts/updates/update_manager.gd`: agregada `_guardar_version()` con `ConfigFile` para persistir `user://version.tres` (canal, versión, fecha).
- `DOCUMENTACION/119-Actualizaciones/plan-actual/04-Codigo.md`: agregadas secciones de proceso de hotfix/SLA y proceso de release/rollback/FAQ.
- `DOCUMENTACION/119-Actualizaciones/plan-actual/05-Checklist.md`: cerradas T-022, T-014, T-015, T-007, T-008, T-079, T-080, T-081 con evidencia.
- `DOCUMENTACION/TAREAS-POR-MODELO/step-3.7-flash/119-Actualizaciones/checklist.md`: sincronizadas T-012/T-014/T-015/T-022/T-007/T-008/T-079/T-080/T-081.
- `CHECKLIST-GLOBAL.md`: M119 pasa a 🔵 En curso 86/111.
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`: actualizada fila M119.
- `Mensajes entre modelos/ESTADO-PARALELO.md`: actualizado estado M119.

## Verificación

- Test headless M119: `15 checks, 0 fallos` post-cambio.
- Output relevante: `[M119] Versión persistida en user://version.tres: 1.0.0 (estable)`.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/updates/update_manager.gd`
- `DOCUMENTACION/119-Actualizaciones/plan-actual/04-Codigo.md`
- `DOCUMENTACION/119-Actualizaciones/plan-actual/05-Checklist.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/step-3.7-flash/119-Actualizaciones/checklist.md`
- `CHECKLIST-GLOBAL.md`
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`
- `Mensajes entre modelos/ESTADO-PARALELO.md`

## Bloqueo / Próximos pasos

- Pendientes 58 con dueños externos (M96/M118/M59/M107).
- Próximo paso factible sin dueño: cerrar T-082-T-086 (firmas/hash/bloqueo) o continuar con M117/M122.
