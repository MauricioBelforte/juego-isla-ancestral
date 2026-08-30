**Modelo:** ox-alpha
**Plataforma:** Cline

# 03-Diseno.md — Modulo 105: Telemetria de Gameplay

> **Reescritura 2026-08-29 sobre arquitectura REAL.** El diseno original de DEVIN
> (GameplayTelemetry + ServiceLocator + GameState + AnalyticsService + storage propio)
> se reemplaza por el diseno implementado. El plan-inicial queda intacto como
> referencia historica.

## 1. Arquitectura

```
Autoload TelemetryDirector (scripts/telemetry/telemetry_director.gd)
|  autoload en project.godot, SIN class_name (guia Godot 9.41/9.17)
|-- Servicio: ServiceRegistry "telemetry" (M07)
|-- Logging: GameLogger Category.ANALYTICS (M103)
|-- Salida UNICA: AnalyticsDirector.registrar_evento(tipo, datos) (M104)
|     tipo "telemetry" (eventos) y "metrica" (agregados)
|-- Persistencia propia: SOLO opt-in (ConfigFile user://settings/telemetry.cfg)
|-- Senales para UI externa: cambio_opt_in, evento_rastreado, solicitar_encuesta
`-- Timers internos: puzzle_check (abandono >300s), zone_check (visitas <60s)
```

## 2. Estado interno

- `opt_in: bool` (OFF por defecto, GDPR). Persistido en ConfigFile.
- `_inicio_sesion_ms: int` — base de las metricas de tiempo (Time.get_ticks_msec).
- `_tracked: Dictionary` — deduplicacion de eventos first y metricas por sesion.
- `_puzzle_inicio`, `_zona_entrada`, `_zona_duracion` — seguimiento para RF14/RF16.
- `analytics_service: Node` — referencia inyectable a M104 (stub en tests).

## 3. API publica (hooks para otros modulos)

- Opt-in: `esta_opt_in()`, `establecer_opt_in(bool)` (persiste + inicia/cierra sesion + propaga opt-out a M104).
- Eventos first: `track_tutorial_first_completed()`, `track_resource_first_collected(recurso)`, `track_house_first_built()`, `track_npc_first_interaction(npc_id)`, `track_puzzle_first_completed(puzzle_id)`, `track_seal_first_obtained(sello_id)`, `track_travel_first_completed(origen, destino)`, `track_island_first_discovered(isla_id)`, `track_museum_first_visited(museo_id)`, `track_festival_first_participated(festival_id)`, `track_community_project_first_completed(proyecto_id)`.
- Puzzles: `start_puzzle(id)`, `complete_puzzle(id)` (abandono automatico >300s).
- Zonas: `enter_zone(id)`, `exit_zone(id)` (zone_ignored si acumulado <60s).
- Dificultad: `track_difficulty_perceived(puzzle_id, rating 1-5)`.
- Generico: `enviar_evento(evento, datos)` (NO envia si opt_in off).

## 4. Flujo

```
[Bootstrap] _ready: timers + cargar opt-in + registrar servicio
     opt_in ON  -> _iniciar_sesion (session_started + gameplay_session_start a M104)
     opt_in OFF -> sin captura (log info)
[Gameplay] sistemas llaman track_*/start_puzzle/enter_zone
     -> enviar_evento: filtro opt_in + ms_desde_sesion + delega a M104
     -> M104: buffer -> batch JSON offline + aggregated.json
[UI futura M53/M91] consume cambio_opt_in / solicitar_encuesta
```

## 5. Privacidad

- Opt-in explicito OFF por defecto; opt-out en caliente (corta captura) y propagado a M104.
- Sin PII: solo ids internos de contenido; el hash de sesion lo gestiona M104 (SHA256 rotativo 24h).
- Sin storage duplicado de eventos (evita superficie de datos extra).

## 6. Testing

- Test headless `scripts/telemetry/test_telemetry.gd` (extends SceneTree, mismo harness que M103/M104): 16/16 checks con stub de analytics inyectado y settings_path temporal (no toca user:// real).
- Regresion: M103 14/14, M104 18/18, 0 errores de script (Godot 4.7.2 --headless).