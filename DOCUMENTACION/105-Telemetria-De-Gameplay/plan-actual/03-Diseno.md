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
- `_sesion_cerrada: bool` — cierre idempotente (iter. 8): evita duplicar `session_ended`/`session_duration` si el cierre se dispara dos veces (opt-out + cierre de ventana).

## 3. API publica (hooks para otros modulos)

- Opt-in: `esta_opt_in()`, `establecer_opt_in(bool)` (persiste + inicia/cierra sesion + propaga opt-out a M104).
- Eventos first: `track_tutorial_first_completed()`, `track_resource_first_collected(recurso)`, `track_house_first_built()`, `track_npc_first_interaction(npc_id)`, `track_puzzle_first_completed(puzzle_id)`, `track_seal_first_obtained(sello_id)`, `track_travel_first_completed(origen, destino)`, `track_island_first_discovered(isla_id)`, `track_museum_first_visited(museo_id)`, `track_festival_first_participated(festival_id)`, `track_community_project_first_completed(proyecto_id)`.
- Puzzles: `start_puzzle(id)`, `complete_puzzle(id)` (abandono automatico >300s).
- Zonas: `enter_zone(id)`, `exit_zone(id)` (zone_ignored si acumulado <60s).
- Dificultad: `track_difficulty_perceived(puzzle_id, rating 1-5)`.
- Generico: `enviar_evento(evento, datos)` (NO envia si opt_in off).
- Capitulos (iter. 8): `track_chapter_completed(capitulo_id)` — emite el evento `chapter_completed` (constante `EVT.CHAPTER_COMPLETED`). A diferencia de los `*_first_*`, NO se deduplica por sesion: una vez por cada capitulo. El hook de emision pertenece a M22 (sistema de capitulos, aun sin implementar).
- Cierre (iter. 8): `_notification(NOTIFICATION_WM_CLOSE_REQUEST | NOTIFICATION_EXIT_TREE)` -> `_finalizar_sesion()` (idempotente). El cierre ya NO depende solo de `establecer_opt_in(false)`.

## 4. Flujo

```
[Bootstrap] _ready: timers + cargar opt-in + registrar servicio
     opt_in ON  -> _iniciar_sesion (session_started + gameplay_session_start a M104)
     opt_in OFF -> sin captura (log info)
[Gameplay] sistemas llaman track_*/start_puzzle/enter_zone
     -> enviar_evento: filtro opt_in + ms_desde_sesion + delega a M104
     -> M104: buffer -> batch JSON offline + aggregated.json
[UI futura M53/M91] consume cambio_opt_in / solicitar_encuesta
[Cierre] WM_CLOSE_REQUEST / EXIT_TREE -> _finalizar_sesion (idempotente):
     session_ended + session_duration (antes se perdian al cerrar la app)
```

## 5. Privacidad

- Opt-in explicito OFF por defecto; opt-out en caliente (corta captura) y propagado a M104.
- Sin PII: solo ids internos de contenido; el hash de sesion lo gestiona M104 (SHA256 rotativo 24h).
- Sin storage duplicado de eventos (evita superficie de datos extra).

## 6. Testing

- Test headless `scripts/telemetry/test_telemetry.gd` (extends SceneTree, mismo harness que M103/M104): 16/16 checks con stub de analytics inyectado y settings_path temporal (no toca user:// real).
- Regresion: M103 14/14, M104 18/18, 0 errores de script (Godot 4.7.2 --headless).
- iter. 8 (cierre de sesion + `chapter_completed`): `scripts/telemetry/test_telemetria_iter8.gd` 17/17 (guardian de bloques + piso MEDIDO 17). Hermanas iter. 5/6/7 (10/11/27) y base (16) sin regresion.

## 7. Analisis de datos (iter. 8)

M105 es un **sumidero de solo-escritura**: emite eventos (`tipo "telemetry"`) y
metricas (`tipo "metrica"`) a M104 y NO procesa datos. Esta seccion define el
DISENO del analisis que consume esa salida (post-release, con volumen real de
juego). El procesamiento NO vive en M105; se documenta aqui para cerrar los
huecos de diseno que quedaban `[?]` y para fijar el contrato con M102.

**Entradas disponibles** (ya emitidas por M105, §3):

| Senal emitida por M105 | Analisis derivado | Salida |
|---|---|---|
| `puzzle_abandoned` (+ `tiempo_seg`) | Puzzles con alta tasa de abandono | Insight de balance -> ajuste de dificultad/curva |
| `zone_ignored` (+ `tiempo_acumulado_seg`) | Zonas ignoradas por los jugadores | Insight de nivel -> rediseno/routing |
| 11 eventos `*_first_*` ausentes | Eventos clave NO alcanzados | Insight de progresion -> punto de friccion |
| `time_to_first_*` + `session_duration` | Tiempos anormales (cola larga / pico) | Candidato a bug de rendimiento |
| `chapter_completed` (por capitulo) | Capitulos donde muchos jugadores se atascan | Insight de historia -> ajuste de ritmo |
| patron nuevo vs baseline historico | Bugs emergentes | Issue en M102 |

**Reglas de deteccion** (umbrales a calibrar con datos reales; V0 conservador):

- **Balance:** un puzzle es candidato si `abandonos / intentos > umbral` (p. ej. 40 %).
- **Zonas ignoradas:** una zona es candidata si `zone_ignored / zone_entered > umbral`.
- **Eventos no alcanzados:** un evento `*_first_*` es candidato si su tasa de emision
  cae por debajo del baseline tras un volumen minimo de sesiones.
- **Tiempos anormales (posible bug de rendimiento):** un `time_to_first_*` o
  `session_duration` es candidato si supera `media + k*desviacion` (p. ej. k = 3)
  de forma sostenida en la ventana.
- **Atasco en capitulos:** un capitulo es candidato si su tasa de `chapter_completed`
  cae respecto a la del capitulo anterior.
- **Bugs emergentes:** un patron de eventos es candidato a bug si aparece en la
  ventana actual y NO en el baseline historico.

**Contrato con M102 (generacion de issues):** el analisis NO genera issues por si
mismo; produce `patron detectado -> issue`. La integracion M105 -> M102 tiene a
M102 como consumidor pasivo de los patrones; la generacion automatica queda
diferida hasta que existan (a) el diseno del patron (esta seccion) y (b) datos
reales acumulados.

**Dueno y estado:** diseno = M105 (esta seccion). Ejecucion = post-release con
volumen real (KnownIssue no bloqueante de DoD). M105 ya expone todo lo necesario
para consumir los datos cuando existan.