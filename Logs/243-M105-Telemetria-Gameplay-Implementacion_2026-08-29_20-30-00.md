# Log 243: Implementacion M105 Telemetria de Gameplay

**Fecha:** 2026-08-29
**Hora:** 20:30
**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

## Resumen
Se implementó el módulo M105 (Telemetría de Gameplay), infraestructura transversal V0, reescribiendo el plan original de DEVIN (SWE-1.6) sobre la arquitectura REAL del proyecto (el plan usaba APIs inexistentes: ServiceLocator, GameState.get_setting, AnalyticsService.record_event). Verificado headless Godot 4.7.2 con test propio 16/16 y regresión M103 (14/14) + M104 (18/18), 0 fallos.

## Cambios Realizados
- **Creado** `scripts/telemetry/telemetry_director.gd` — autoload TelemetryDirector (sin class_name, ver guía Godot §9.41/§9.17): opt-in explícito OFF por defecto (GDPR) persistido en ConfigFile, 17 eventos definidos (11 "first" + abandono + dificultad + zonas + sesión), métricas time_to_first_discovery/travel y session_duration, detección de abandono de puzzle (>300s) y zonas ignoradas (<60s) vía Timers, sincronización de opt-out con M104.
- **Creado** `scripts/telemetry/test_telemetry.gd` — test headless 16 checks con stub de Analytics inyectado (extends Node, fuera del árbol) y settings aislados en user://telemetry_test/ (limpiados al final).
- **Modificado** `project.godot` — autoload TelemetryDirector agregado.
- **Integración M104:** todo evento viaja por AnalyticsDirector.registrar_evento(tipo, datos) con tipos "telemetry"/"metrica" (no contamina la agregación de M104).
- Correcciones durante verificación: typo get_ticks_mseg→msec, constante PUZZLE_ABANDONADO→PUZZLE_ABANDONED, track_difficulty_perceived sin clave "evento", indent de línea return.
- Actualizados: CHECKLIST-GLOBAL, ESTADO-PARALELO, guía 08, 05-Checklist del módulo, plan-actual.

## Hallazgo relevante (para guía Godot)
Plan original de módulo escrito por otro modelo con APIs inventadas: verificar SIEMPRE los nombres reales (grep en scripts/core y project.godot) antes de implementar. Documentado en Notas del Agente.

## Archivos Modificados/Creados
- game/isla-ancestral/scripts/telemetry/telemetry_director.gd (nuevo)
- game/isla-ancestral/scripts/telemetry/test_telemetry.gd (nuevo)
- game/isla-ancestral/project.godot (autoload)
- DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/05-Checklist.md
- CHECKLIST-GLOBAL.md, Mensajes entre modelos/ESTADO-PARALELO.md, DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md