**Modelo:** ox-alpha
**Plataforma:** Cline

# 01-Requerimientos.md — Módulo 105: Telemetría de Gameplay

> **Reescritura 2026-08-29:** el plan original (DEVIN/SWE-1.6) planteaba APIs inexistentes
> en este proyecto (`GameState.get_setting`, `ServiceLocator`, `AnalyticsService.record_event`).
> Este plan-actual replantea los requerimientos sobre la arquitectura REAL:
> autoloads Godot + `ServiceRegistry` + `AnalyticsDirector` (M104) + `GameLogger` (M103).
> El plan-inicial se conserva sin modificar como punto de partida histórico.

## ID del Módulo
- **Código:** M105 (CHECKLIST-GLOBAL: 105-Telemetria-De-Gameplay)
- **Carpeta:** `DOCUMENTACION/105-Telemetria-De-Gameplay/`
- **Dependencia real:** M104 Analytics ✅ (única vía de persistencia/batch de eventos)
- **Dependencias del plan original NO requeridas:** M71 (Progresión), M22 (Historia), M102 (Bug Tracking) — son consumidores potenciales de los datos, no prerequisitos. La integración se hará por hooks cuando esos módulos existan.

## 1. Problema

El juego necesita medir cómo juegan los jugadores (eventos clave, tiempos, abandonos,
dificultad percibida) para detectar problemas de diseño con datos reales, sin afectar
rendimiento y sin recoger datos si el jugador no lo autoriza explícitamente.

## 2. Requisitos Funcionales

| # | Requisito | Implementación real |
|---|---|---|
| RF1 | Primer tutorial completado | `track_tutorial_first_completed()` → evento `tutorial_first_completion` |
| RF2 | Primer recurso recolectado | `track_resource_first_collected(recurso)` |
| RF3 | Primera casa | `track_house_first_built()` |
| RF4 | Primer NPC | `track_npc_first_interaction(npc_id)` |
| RF5 | Primer puzzle | `track_puzzle_first_completed(puzzle_id)` / `complete_puzzle()` |
| RF6 | Primer Sello | `track_seal_first_obtained(sello_id)` |
| RF7 | Primer viaje | `track_travel_first_completed(origen, destino)` |
| RF8 | Primera isla | `track_island_first_discovered(isla_id)` |
| RF9 | Primer museo | `track_museum_first_visited(museo_id)` |
| RF10 | Primer festival | `track_festival_first_participated(festival_id)` |
| RF11 | Primer proyecto comunitario | `track_community_project_first_completed(proyecto_id)` |
| RF12 | Tiempo hasta primer descubrimiento | métrica `time_to_first_discovery` (una vez por sesión) |
| RF13 | Tiempo hasta primer viaje | métrica `time_to_first_travel` |
| RF14 | Puzzle abandonado | `start_puzzle()` + timer → `puzzle_abandoned` si >300s sin completar |
| RF15 | Dificultad percibida | `track_difficulty_perceived(puzzle_id, rating 1-5)` (la UI la dispara) |
| RF16 | Zonas ignoradas | `enter_zone()`/`exit_zone()` → `zone_ignored` si visita <60s acumulados |
| RF17 | Datos para mejorar diseño | eventos type "telemetry"/"metrica" en M104 (agregación/batch/histórico) |

RNF: opt-in OFF por defecto (GDPR), sin PII, sin impacto en gameplay (delegación pasiva),
offline-first (M104 persiste JSON local), test headless sin tocar disco real.


## 3. Criterios de Aceptación

1. Autoload TelemetryDirector registrado (project.godot + ServiceRegistry "telemetry").
2. Opt-in GDPR OFF por defecto, persistente, con propagación de opt-out a M104.
3. Los 17 eventos RF1-RF17 implementados y testeados (test headless 16/16).
4. Métricas de tiempo y detección de abandonos/zonas operativas.
5. Cero errores de script en Godot 4.7.2 --headless; regresión M103/M104 sin fallos.
6. Hooks de integración pendientes documentados en Notas del Agente.

---

## Módulos Relacionados

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M104** — Analytics | Persistencia, batch offline, agregación y anonimización de los eventos |
| **M103** — Logging | GameLogger para trazabilidad (Category.ANALYTICS) |
| **M07** — ServiceRegistry | Registro del servicio "telemetry" |

### Consumidores futuros (no prerequisitos)

| Módulo | Relación |
|--------|----------|
| **M53/M91** — UI | Prompt de opt-in y encuesta de dificultad (señales ya emitidas) |
| **M71/M22** — Progresión/Historia | Deben llamar a los track_* cuando existan |
| **M102** — Bug Tracking | Consumidor de patrones de abandono como señales de bug |
