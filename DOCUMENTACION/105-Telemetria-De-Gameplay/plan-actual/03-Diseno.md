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

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 6 | Eventos/segundo maximos por sesion | 10 eventos/s | Presupuesto de red local. AUDITORIA 2026-10-23: M40 NO declara budget de red (SIN-DATOS, apilado Beam 277 celda 6) — la cita "coherente con M40 Kafka-cuota" se degrada a juicio de diseno sin fuente. |
| 7 | Payload promedio bytes/evento | 256 bytes | 256 x 10 eventos/s = 2560 bytes/s = 20.48 kbps. Coherente con presupuesto 64 kbps de M77 (32%). |
| 8 | Ventana de retencion de datos | 30 dias x 100 eventos/dia = 3000 eventos | 3000 x 256 bytes = 768 KB. Razonable para disco local. |
| 9 | Muestreo anonimo por tipo de evento | 100% eventos clave, 10% rutinarios | Opt-in explicito, sin PII. Sampling por tipo de evento. |
| 10 | Frecuencia de flush del buffer | 30s o 100 eventos (lo que ocurra primero) | Coherente con no-lag de M58 (no saturar UI). |

## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de peaks de eventos por frame en escritura** [x] - formula con margen para eventos de balancing online (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de esquema de versionado** [x] - formula de compat coherente con M107 (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)
- **Presupuesto de cross-referencing M105-M144** [x] - la tabla de deudas del flag H21 en valores (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose NO vive en 03/05, solo el pointer)

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 4. Peaks de eventos por frame en escritura
- Formula: eventos_por_frame = eventos_por_segundo / fps = 10 / 60 = 0.167 eventos/frame.
- Max eventos por frame: 1 (si 10 eventos/s y 60 fps, 1 de cada 6 frames tiene un evento).
- Coherente con M70 (0.5 ms/frame budget). Un evento de telemetria no excede 0.5 ms.
- Unidad: eventos/frame. Dependencia: M70 (0.5 ms/frame).

### 5. Esquema de versionado
- Formula: version = major.minor.patch (semver). Compatibilidad: major debe coincidir, minor puede incrementar, patch puede incrementar.
- Migracion: si major cambia, migrar todos los eventos. Si minor cambia, agregar campos opcionales. Si patch cambia, sin migracion.
- Coherente con M107 (versionado de esquema de backup).
- Unidad: version semantica. Dependencia: M107.

### 6. Cross-referencing M105-M144 (tabla de deudas H21)
- Formula: metricas_capturadas = 4 (dificultad, tutorial, retencion parcial, contenido parcial) de 9 metricas M144.
- Gap = 9 - 4 = 5 metricas no capturadas (reviews, bugs, rendimiento, economia, onboarding).
- Coherente con H21 (Opcion A para V1: 4/9 en M105, 5 en otros modulos).
- Unidad: metricas. Dependencia: M144 (9 metricas).



## Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25, riel design-docs agnes msg 258 lote 2)

Metodo produce-first: grep + lectura directa, sin ejecutar Godot. Citas archivo:Línea.

### 7. Peaks de eventos por frame (medido)
- TelemetryDirector (533 lineas; autoload TelemetryDirector, project.godot L29) NO tiene limitador por-frame ni buffer propio: registrar_evento delega 100% a AnalyticsDirector.registrar_evento (telemetry_director.gd L342-351). Unicos timers: polling de 1.0s para puzzle abandonado y zonas ignoradas (L282-297).
- El batching real vive en M104: analytics_director.gd batch_interval_min = 30.0 (L36), umbral _acumulador_segundos >= intervalo*60 (L63) -> enviar_lote_datos() (L111) cada 30 MINUTOS, + flush al cerrar la app (L68-71); lote en user://analytics/lote_%s.json (L31); agregado historico aggregated.json (L154); filtrado opt-out M91 previo (L6-7).
- DRIFT vs diseño (este 03 L122: "flush 30s o 100 eventos"): en disco = 30 min + exit. No hay contador de 100 eventos. Los peaks teoricos Beam 312 ###4 (0.167 ev/frame, max 1 cada 6 frames) NO estan instrumentados ni limitados en runtime.
- Unidad: eventos/frame (teoria) / intervalo de batch 1800s (disco). Dependencia: M104, M70.

### 8. Esquema de versionado (medido)
- 0 hits de "schema_version" ni "const VERSION" en scripts/telemetry/ y scripts/analytics/ (grep repo-wide; los unicos VERSION/schema_version son de otros modulos: coleccionables_manager VERSION=1 L27, combate VERSION_SAVE=1, buzon VERSION=1, diario schema_version=1, balance schema_version 1->2). M105 NO versiona el payload de eventos.
- El versionado semver del diseño Beam 312 ###5 vive hoy en M119 (data/updates/versions.json: estable 1.0.0 / beta 1.1.0-beta.1 / dev 1.1.0-dev.3) y en schema_version=2 de data/logros/logros.json (M72) — no en telemetria.
- Consecuencia: la regla "compatibilidad: major debe coincidir" NO TIENE OBJETO hoy (no hay esquema de eventos versionado que migrar; el payload lo ensambla M104 sin version). Deuda: si M105 crece (nuevos eventos con campos), definir schema_version del payload ANTES de que haya 2 generaciones de datos.
- Unidad: version semantica (ausente en M105/M104). Dependencia: M107 (versionado de esquema de backup — analogia del diseño).

### 9. Cross-referencing M105-M144 (medido)
- Tabla canonica: DOCUMENTACION/144-Despues-Del-Lanzamiento/plan-actual/03-Diseno.md L6-17 — 9 metricas; fuente M105 en 7/9 (rendimiento compartida M122; reviews=M100, bugs=M102/M122).
- Cobertura medida de TelemetryDirector: 19 eventos EVT (telemetry_director.gd L101-121) + 6 metricas time_to_first_* + session_duration (L124-129) + bridge EventBus (telemetry_bridge.gd).
  - Plenas: tutorial (tutorial_first_completion L102); dificultad (difficulty_perceived L116 + puzzle_abandoned L111 + PUZZLE_ABANDONO_SEGUNDOS=300 L136); contenido (zone_ignored/entered/exited L117-119 + chapter_completed L121 + island_first_discovered L110 + museum/festival/community_project L107-113).
  - Con insumos: onboarding (5 metricas time_to_first_* L124-128 + tutorial; "conversion 30 min" derivable de tutorial_first_completion + session_duration); retencion (session_started/ended L119-120 + METRIC session_duration L129; D1/D7/D30 requiere agregacion longitudinal — M104 aggregated.json L154 la provee).
  - Economia: NO capturada — telemetry_bridge.gd L54-56: "purchase_done ... 0 emisores en produccion -> cablearlas seria una arista MUERTA". La unica fila mapeada de la tabla ENTRADAS es quest.prereq_met -> track_seal_first_obtained (L57-65; emisor real story_manager.gd:187, M22). Las 13 track_* tenian 0 llamadores de produccion antes del bridge (L9-14); bridge_cobertura() L196-204 es auditable.
  - Rendimiento: la tabla M144 lo comparte M105/M122; M105 no emite FPS/crash (0 hits) — queda en M122.
- Refina el flag H21 (decia 4/9 con onboarding en el gap): onboarding SÍ tiene insumos directos (5 time_to_first + tutorial_first_completion); economia se mantiene en el gap MEDIDA (0 emisores de purchase_done en producción, no solo "no capturada"). Gap real medido: reviews (M100), bugs (M102/M122), rendimiento (M122), economia (0 emisores).
- DRIFT CI (encolado): scripts/telemetry/ tiene 6 suites (test_telemetry, iter5, iter6, iter7, iter8, test_telemetry_bridge_m105) pero quality.yml L487-490 solo cablea 4 (test_telemetry + iter5/6/7, con pisos CHECKS_MINIMOS 16/10/11/27, L480-486). test_telemetria_iter8.gd y test_telemetry_bridge_m105.gd SIN cablear.
- Unidad: metricas/cobertura de bridge. Dependencia: M144, M104, M22.
