# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M105: Telemetría de Gameplay — TelemetryDirector (autoload).
#
# Responsabilidad: capturar eventos de comportamiento de jugador (RF1-RF17),
# métricas de tiempo, abandono de puzzles/zonas y dificultad percibida, y
# reenviarlos a M104 (Analytics) para aggregation/batch/offline storage.
#
# Arquitectura (sobre la REAL, NO sobre el plan original DEVIN):
#   - DEVIN usó nombres inexistentes (`ServiceLocator`, `GameState.get_setting`,
#     `AnalyticsService` / `record_event`). Se rechazan y se usan los reales:
#       * ServiceLocator → ServiceRegistry.get_service("analytics")
#       * GameState.get_setting → ConfigFile user://settings/telemetry.cfg
#       * AnalyticsService.record_event → AnalyticsDirector.registrar_evento(tipo, datos)
#   - Autoload registrado como "TelemetryDirector" SIN class_name (ver §9.41 y
#     §9.17 de 07-GUIA-GODOT.md: un autoload con class_name == nombre del
#     autoload colisiona; y Godot 4.7 reservea "Telemetry").
#
# Patrón V0: lógica pura, testable headless (Godot 4.7 --headless).
#   - SIN UI: el prompt de opt-in en primer inicio y la encuesta post-puzzle
#     son responsabilidad de M53 (UI) / M91 (menú de privacidad). Telemetry
#     Director emite señales (`cambio_opt_in`, `solicitar_encuesta`) que la UI
#     consume. La lógica de captura y timestamps es V0.
#   - OFFLINE-FIRST: M104 persiste los lotes; TelemetryDirector no duplica storage
#     (reutiliza AnalyticsDirector.registrar_evento).
#
# Privacy by design:
#   - opt-in EXPLÍCITO y OFF por defecto (GDPR).
#   - No se capturan PII; los datos van anonimizados por M104 (session hash
#     SHA256 rotativo 24h). Los `datos` enviados a M104 solo contienen ids
#     internos de contenido (puzzle_id, zone_id...), nunca usernames.
#   - El opt-out filtra en caliente y pisa la config por build (M91).

extends Node

## ── Señales ─────────────────────────────────────────────────────────

## Emitida al cambiar el estado de opt-in (la UI M91/Startup la consume).
signal cambio_opt_in(habilitado: bool)
## Emitida por cada evento rastreado (para dashboards / M110).
signal evento_rastreado(evento: String, datos: Dictionary)
## Emitida para solicitar la encuesta de dificultad al jugador (UI la consume).
signal solicitar_encuesta(puzzle_id: String)

## ── Constantes ────────────────────────────

## Categoria propia de log vía M103 (GameLogger.Category.ANALYTICS).
const LOG_CAT := "telemetry"

## Eventos de comportamiento clave (RF1-RF17). Se envían a M104 como tipo
## "telemetry" con datos estructurados, para no contaminar la agregación por
## tipo de M104 (que agrupa por "sesion_inicio", "area_visitada", etc.).
const EVT := {
	TUTORIAL_COMPLETED = "tutorial_first_completion",
	RESOURCE_FIRST_COLLECTED = "resource_first_collected",
	HOUSE_FIRST_BUILT = "house_first_built",
	NPC_FIRST_INTERACTION = "npc_first_interaction",
	PUZZLE_FIRST_COMPLETED = "puzzle_first_completed",
	SEAL_FIRST_OBTAINED = "seal_first_obtained",
	TRAVEL_FIRST_COMPLETED = "travel_first_completed",
	ISLAND_FIRST_DISCOVERED = "island_first_discovered",
	MUSEUM_FIRST_VISITED = "museum_first_visited",
	FESTIVAL_FIRST_PARTICIPATED = "festival_first_participated",
	COMMUNITY_PROJECT_FIRST_COMPLETED = "community_project_first_completed",
	PUZZLE_ABANDONED = "puzzle_abandoned",
	DIFFICULTY_PERCEIVED = "difficulty_perceived",
	ZONE_ENTERED = "zone_entered",
		ZONE_EXITED = "zone_exited",
		DIFFICULTY_PERCEIVED = "difficulty_perceived",
	ZONE_IGNORED = "zone_ignored",
	SESSION_STARTED = "session_started",
	SESSION_ENDED = "session_ended",
}

## Keys de métrica (enviadas a M104 como tipo "metrica" con datos estructurado).
const METRIC_TIME_TO_FIRST_DISCOVERY := "time_to_first_discovery"
const METRIC_TIME_TO_FIRST_TRAVEL := "time_to_first_travel"
const METRIC_SESSION_DURATION := "session_duration"

## Tipos que Telemetry envía a M104 (mantiene la agregación de M104 limpia).
const ANALYTICS_TIPO_EVENTO := "telemetry"
const ANALYTICS_TIPO_METRICA := "metrica"

## Umbrales de detección (DEVIN plan; valores conservadores V0).
const PUZZLE_ABANDONO_SEGUNDOS := 300.0  # 5 minutos sin completar.
const ZONA_IGNORADA_SEGUNDOS := 60.0     # 1 minuto sin explorar.

## Persistencia: opt-in del jugador (OFF por defecto, GDPR).
const SETTINGS_PATH_DEFAULT := "user://settings/telemetry.cfg"
const SETTINGS_SECCION := "telemetry"
const SETTINGS_CLAVE := "opt_in"

## ── Estado ────────────────────────────

## Opt-in explícito del jugador (OFF = no capturo nada).
var opt_in: bool = false
## Tiempo de inicio de sesión (ms) para métricas de tiempo.
var _inicio_sesion_ms: int = 0
## Eventos "first" ya registrados (evita duplicados por sesión).
var _tracked: Dictionary = {}
## Timers internos para detección de abandono/zonas.
var _puzzle_check_timer: Timer
var _zone_check_timer: Timer
var _puzzle_inicio: Dictionary = {}     # puzzle_id -> timestamp inicio
var _zona_entrada: Dictionary = {}      # zone_id -> timestamp entrada
var _zona_duracion: Dictionary = {}     # zone_id -> acumulado (visitas <1min)
## Referencia al servicio Analytics (M104). Resuelta lazy; inyectable en tests.
var analytics_service: Node = null
## Path de settings (seteable en tests para aislar user://).
var _settings_path: String = SETTINGS_PATH_DEFAULT
## ─── Lifecycle ────────────────────────────

func _init() -> void:
	name = "TelemetryDirector"  # nombre del nodo; el autoload se define en project.godot.

func _ready() -> void:
	_configurar_timers()
	_cargar_opt_in()
	_registrar_servicio()
	if opt_in:
		_iniciar_sesion()
		GameLogger.info("Telemetry: servicio inicializado (opt-in ON)", GameLogger.Category.ANALYTICS)
	else:
		GameLogger.info("Telemetry: servicio inicializado (opt-in OFF — sin captura)", GameLogger.Category.ANALYTICS)

## ─── Service Registry (M07) ───────────────────

func _registrar_servicio() -> void:
	var reg = get_node_or_null("/root/ServiceRegistry")
	if reg != null and reg.has_method("register"):
		reg.register("telemetry", self)

## Resuelve Analytics (M104) lazy; inyectable para tests.
func _resolve_analytics() -> Node:
	if analytics_service == null:
		analytics_service = get_node_or_null("/root/AnalyticsDirector")
	return analytics_service

## ─── Opt-in / GDPR ────────────────────────────

## Estado de opt-in (persistido). OFF por defecto.
func esta_opt_in() -> bool:
	return opt_in

## Activa/desactiva la telemetría. Si se desactiva: flush + opt-out a M104.
func establecer_opt_in(estado: bool) -> void:
	if estado == opt_in:
		return
	opt_in = estado
	_persistir_opt_in()
	if estado:
		_iniciar_sesion()
	else:
		_finalizar_sesion()
	_emitir_opt_out_a_analytics()
	cambio_opt_in.emit(opt_in)
	GameLogger.info("Telemetry: opt-in = %s" % estado, GameLogger.Category.ANALYTICS)

## Sincroniza el opt-out con M104 para privacy by design.
func _emitir_opt_out_a_analytics() -> void:
	if opt_in:
		return
	var ads := _resolve_analytics()
	if ads != null and ads.has_method("establecer_opt_out"):
		ads.establecer_opt_out(true)

func _cargar_opt_in() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(_settings_path)
	if err == OK:
		opt_in = cfg.get_value(SETTINGS_SECCION, SETTINGS_CLAVE, false) as bool
	else:
		opt_in = false  # Default GDPR.

func _persistir_opt_in() -> void:
	var cfg := ConfigFile.new()
	if FileAccess.file_exists(_settings_path):
		var err := cfg.load(_settings_path)
		if err != OK:
			cfg = ConfigFile.new()
	cfg.set_value(SETTINGS_SECCION, SETTINGS_CLAVE, opt_in)
	DirAccess.make_dir_recursive_absolute(_settings_path.get_base_dir())
	cfg.save(_settings_path)
## ─── Timers (detección de abandono/zonas) ──────

func _configurar_timers() -> void:
	_puzzle_check_timer = Timer.new()
	_puzzle_check_timer.name = "puzzle_check_timer"
	_puzzle_check_timer.wait_time = 1.0
	_puzzle_check_timer.autostart = false
	_puzzle_check_timer.one_shot = false
	_puzzle_check_timer.timeout.connect(_on_puzzle_check)
	add_child(_puzzle_check_timer)

	_zone_check_timer = Timer.new()
	_zone_check_timer.name = "zone_check_timer"
	_zone_check_timer.wait_time = 1.0
	_zone_check_timer.autostart = false
	_zone_check_timer.one_shot = false
	_zone_check_timer.timeout.connect(_on_zone_check)
	add_child(_zone_check_timer)

## ─── Sesión ────────────────────────────

func _iniciar_sesion() -> void:
	_inicio_sesion_ms = Time.get_ticks_msec()
	_tracked.clear()
	_zona_entrada.clear()
	_zona_duracion.clear()
	_puzzle_inicio.clear()
	enviar_evento("session_started", {})
	var ads := _resolve_analytics()
	if ads != null and ads.has_method("registrar_evento"):
		ads.registrar_evento(ANALYTICS_TIPO_EVENTO, {"evento": "gameplay_session_start"})

func _finalizar_sesion() -> void:
	var dur := _duracion_sesion_seg()
	enviar_evento("session_ended", {"duracion_seg": dur})
	_registrar_metrica(METRIC_SESSION_DURATION, dur)

func _duracion_sesion_seg() -> int:
	if not opt_in or _inicio_sesion_ms == 0:
		return 0
	return int((Time.get_ticks_msec() - _inicio_sesion_ms) / 1000.0)

## ─── Envío a M104 (única vía de salida) ──────────────

## Registra un evento de comportamiento. Delegado 100% a M104.
func enviar_evento(evento: String, datos: Dictionary = {}) -> void:
	if not opt_in:
		return
	var datos_env := datos.duplicate(true)
	datos_env["evento"] = evento
	datos_env["ms_desde_sesion"] = _ticks_desde_sesion()
	var ads := _resolve_analytics()
	if ads != null and ads.has_method("registrar_evento"):
		ads.registrar_evento(ANALYTICS_TIPO_EVENTO, datos_env)
	evento_rastreado.emit(evento, datos_env)

## Registra una métrica agregada (time_to_first_*, session_duration).
func _registrar_metrica(metrica: String, valor) -> void:
	if not opt_in:
		return
	var ads := _resolve_analytics()
	if ads != null and ads.has_method("registrar_evento"):
		ads.registrar_evento(ANALYTICS_TIPO_METRICA, {
			"metrica": metrica,
			"valor": valor,
			"ms_desde_sesion": _ticks_desde_sesion(),
		})

func _ticks_desde_sesion() -> int:
				return Time.get_ticks_msec() - _inicio_sesion_ms
## ─── Trackers "first" (RF1-RF11) ──────────────

func _track_first(key: StringName, evento: String, datos: Dictionary = {}) -> bool:
	if not opt_in:
		return false
	if _tracked.has(key):
		return false
	_tracked[key] = true
	enviar_evento(evento, datos)
	return true

func track_tutorial_first_completed() -> void:
	if _track_first(&"tutorial", EVT.TUTORIAL_COMPLETED):
		_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)

func track_resource_first_collected(recurso: String) -> void:
	if _track_first(&"recurso", EVT.RESOURCE_FIRST_COLLECTED, {"recurso": recurso}):
		_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)

func track_house_first_built() -> void:
	if _track_first(&"casa", EVT.HOUSE_FIRST_BUILT):
		_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)

func track_npc_first_interaction(npc_id: String) -> void:
	if _track_first(&"npc", EVT.NPC_FIRST_INTERACTION, {"npc_id": npc_id}):
		_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)

func track_puzzle_first_completed(puzzle_id: String) -> void:
	if _track_first(&"puzzle", EVT.PUZZLE_FIRST_COMPLETED, {"puzzle_id": puzzle_id}):
		_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)

func track_seal_first_obtained(sello_id: String) -> void:
	if _track_first(&"sello", EVT.SEAL_FIRST_OBTAINED, {"sello_id": sello_id}):
		_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)

func track_travel_first_completed(origen: String, destino: String) -> void:
	_track_first(&"viaje", EVT.TRAVEL_FIRST_COMPLETED, {"origen": origen, "destino": destino})
	_registrar_metrica_hasta(&"travel", METRIC_TIME_TO_FIRST_TRAVEL)

func track_island_first_discovered(isla_id: String) -> void:
	if _track_first(&"isla", EVT.ISLAND_FIRST_DISCOVERED, {"isla_id": isla_id}):
		_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)

func track_museum_first_visited(museo_id: String) -> void:
	_track_first(&"museo", EVT.MUSEUM_FIRST_VISITED, {"museo_id": museo_id})

func track_festival_first_participated(festival_id: String) -> void:
	_track_first(&"festival", EVT.FESTIVAL_FIRST_PARTICIPATED, {"festival_id": festival_id})

func track_community_project_first_completed(proyecto_id: String) -> void:
	_track_first(&"proyecto", EVT.COMMUNITY_PROJECT_FIRST_COMPLETED, {"proyecto_id": proyecto_id})

## Registro de dificultad percibida (rating 1-5). La UI post-puzzle (M53) la dispara.
func track_difficulty_perceived(puzzle_id: String, rating: int) -> void:
	if not opt_in:
		return
	var datos := {"puzzle_id": puzzle_id, "rating": rating, "ms_desde_sesion": _ticks_desde_sesion()}
	var ads := _resolve_analytics()
	if ads != null and ads.has_method("registrar_evento"):
		ads.registrar_evento(ANALYTICS_TIPO_EVENTO, datos)
	evento_rastreado.emit(EVT.DIFFICULTY_PERCEIVED, datos)

## Registra la métrica time_to_first_X la primera vez que ocurre X.
func _registrar_metrica_hasta(key: StringName, metrica: String) -> void:
	var mkey := "__metrica__" + str(key)
	if _tracked.has(mkey):
		return
	_tracked[mkey] = true
	_registrar_metrica(metrica, _ticks_desde_sesion())

## ─── Puzzles abandonados (RF14) ──────────────

func start_puzzle(puzzle_id: String) -> void:
	if not opt_in:
		return
	_puzzle_inicio[puzzle_id] = Time.get_ticks_msec()
	if _puzzle_check_timer.is_stopped():
		_puzzle_check_timer.start()
	GameLogger.debug("Telemetry: puzzle iniciado %s" % puzzle_id, GameLogger.Category.ANALYTICS)

func complete_puzzle(puzzle_id: String) -> void:
	if not opt_in:
		return
	var inicio = _puzzle_inicio.get(puzzle_id, -1)
	if inicio != -1:
		var tiempo_seg := int((Time.get_ticks_msec() - inicio) / 1000.0)
		enviar_evento(EVT.PUZZLE_FIRST_COMPLETED, {"puzzle_id": puzzle_id, "tiempo_seg": tiempo_seg})
	_puzzle_inicio.erase(puzzle_id)
	if _puzzle_inicio.is_empty():
		_puzzle_check_timer.stop()

func _on_puzzle_check() -> void:
	var ahora := Time.get_ticks_msec()
	for id in _puzzle_inicio.keys():
		var inicio: int = _puzzle_inicio[id]
		var transcurrido_seg := (ahora - inicio) / 1000.0
		if transcurrido_seg >= PUZZLE_ABANDONO_SEGUNDOS:
			enviar_evento(EVT.PUZZLE_ABANDONADO, {"puzzle_id": id, "tiempo_seg": int(transcurrido_seg)})
			_puzzle_inicio.erase(id)

## ─── Zonas ignoradas (RF16) ──────────────

func enter_zone(zone_id: String) -> void:
	if not opt_in:
		return
	_zona_entrada[zone_id] = Time.get_ticks_msec()
	if _zone_check_timer.is_stopped():
		_zone_check_timer.start()
	enviar_evento(EVT.ZONE_ENTERED, {"zone_id": zone_id})

func exit_zone(zone_id: String) -> void:
	if not opt_in:
		return
	var inicio = _zona_entrada.get(zone_id, -1)
	_zona_entrada.erase(zone_id)
	if inicio != -1:
		var tiempo_seg := int((Time.get_ticks_msec() - inicio) / 1000.0)
		enviar_evento(EVT.ZONE_EXITED, {"zone_id": zone_id, "tiempo_seg": tiempo_seg})
		_zona_duracion[zone_id] = _zona_duracion.get(zone_id, 0) + tiempo_seg
	if _zona_entrada.is_empty():
		_zone_check_timer.stop()

func _on_zone_check() -> void:
	# Zonas visitadas < 1 minuto → "ignorada".
	for id in _zona_duracion.keys():
		var acumulado: int = _zona_duracion[id]
		if acumulado < int(ZONA_IGNORADA_SEGUNDOS):
			enviar_evento("zone_ignored", {"zone_id": id, "tiempo_acumulado_seg": acumulado})
