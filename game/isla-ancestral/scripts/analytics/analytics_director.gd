# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M104: Analytics — AnalyticsDirector (autoload).
# Flujo: captura RF1-RF7 → cola en memoria → filtrado por opt-out (M91) →
# agregación local JSON (sin datos personales) → batch a user://analytics/.
# Privacidad: session_id = SHA256(seed + fecha) rota cada 24h; sin nombres,
# sin coordenadas exactas, sin hardware identificable.
# Integración: M103 GameLogger (categoría ANALYTICS) para trazas propias.
# Godot 4.7: sin red en v1 (modo offline/agregado local); envío a servidor
# queda como extensión futura (M76/M77).

extends Node

## Señal cuando un evento se registra (para dashboards en desarrollo)
signal evento_registrado(tipo: String, datos: Dictionary)

## Tipos de evento RF1-RF7
const EV_SESION_INICIO := "sesion_inicio"
const EV_SESION_FIN := "sesion_fin"
const EV_AREA_VISITADA := "area_visitada"
const EV_FEATURE_USADA := "feature_usada"
const EV_ERROR := "error"
const EV_PAUSA := "pausa_reanudacion"
const EV_CONFIG_CAMBIO := "config_cambio"

## Rutas de almacenamiento local
const DIR_ANALYTICS := "user://analytics"
const ARCHIVO_AGREGADO := "user://analytics/aggregated.json"
const ARCHIVO_LOTE := "user://analytics/lote_%s.json"
const ARCHIVO_OPT_OUT := "user://analytics/opt_out.cfg"

## Configuración (se sobreescribe desde data/analytics/config.tres)
var opt_out: bool = false
var batch_interval_min: float = 30.0
var max_buffer: int = 500

## Estado interno
var _buffer: Array[Dictionary] = []
var _agregados: Dictionary = {}  # tipo -> contador
var _session_hash: String = ""
var _session_dia: String = ""
var _inicio_sesion_ms: int = 0
var _acumulador_segundos: float = 0.0

func _ready() -> void:
	_cargar_config()
	_cargar_opt_out()
	DirAccess.make_dir_recursive_absolute(DIR_ANALYTICS)
	_inicio_sesion_ms = Time.get_ticks_msec()
	_refrescar_session_hash()
	var reg = get_node_or_null("/root/ServiceRegistry")
	if reg != null and reg.has_method("register"):
		reg.register("analytics", self)
	registrar_evento(EV_SESION_INICIO, {"origen": "ready"})
	info_propia("AnalyticsDirector inicializado")

func _process(delta: float) -> void:
	# Batch timer: sin trabajo en hot path salvo acumular.
	if _buffer.size() > 0:
		_acumulador_segundos += delta
		if _acumulador_segundos >= batch_interval_min * 60.0:
			enviar_lote_datos()
			_acumulador_segundos = 0.0

func _notification(what: int) -> void:
	# Flush al cerrar la app (sesion_fin + lote final).
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		registrar_evento(EV_SESION_FIN, {"duracion_seg": _duracion_sesion()})
		enviar_lote_datos()

## ── API pública (diseño 04-Codigo §2) ──────────────────
## Registra un evento de analytics en el buffer local.
func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
	if opt_out:
		return  # Filtrado inmediato (privacidad por diseño)
	_refrescar_session_hash()
	var ev := {
		"tipo": tipo,
		"session": _session_hash,
		"ts": Time.get_datetime_string_from_system(),
		"datos": datos,
	}
	_buffer.append(ev)
	_agregados[tipo] = int(_agregados.get(tipo, 0)) + 1
	# Política de descarte: si el buffer supera max_buffer, descarta los más viejos.
	while _buffer.size() > max_buffer:
		_buffer.pop_front()
	_log_propio(tipo)
	evento_registrado.emit(tipo, datos)

func esta_opt_out() -> bool:
	return opt_out

## Activa o desactiva el reporte de analytics (persistente en user://).
func establecer_opt_out(estado: bool) -> void:
	opt_out = estado
	var f := FileAccess.open(ARCHIVO_OPT_OUT, FileAccess.WRITE)
	if f != null:
		f.store_8(1 if estado else 0)
		f.close()
	if estado:
		_buffer.clear()  # Descarta lo pendiente si el usuario opted-out

## Estadísticas agregadas desde el último envío o inicio.
func obtener_estadisticas_agregadas() -> Dictionary:
	return _agregados.duplicate()

## Vuelca buffer + agregados a un archivo JSON local (modo offline).
func enviar_lote_datos() -> void:
	if opt_out:
		return
	var payload := {
		"generado": Time.get_datetime_string_from_system(),
		"session": _session_hash,
		"eventos": _buffer,
		"agregados": _agregados,
		"duracion_sesion_seg": _duracion_sesion(),
	}
	var ts := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var path := ARCHIVO_LOTE % ts
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(payload, "  "))
		f.close()
	_actualizar_agregado_historico(payload)
	_buffer.clear()

func obtener_config() -> Dictionary:
	return {
		"opt_out": opt_out,
		"batch_interval_min": batch_interval_min,
		"max_buffer": max_buffer,
	}

## Tamaño del buffer pendiente (para tests/diagnóstico).
func eventos_pendientes() -> int:
	return _buffer.size()

## Duración de la sesión actual en segundos.
func _duracion_sesion() -> int:
	return int((Time.get_ticks_msec() - _inicio_sesion_ms) / 1000.0)
## Hash de sesión rotativo cada 24h: SHA256(seed + fecha).
func _refrescar_session_hash() -> void:
	var hoy := Time.get_date_string_from_system()
	if hoy != _session_dia:
		_session_dia = hoy
		var ctx := HashingContext.new()
		ctx.start(HashingContext.HASH_SHA256)
		ctx.update(("isla_ancestral|" + hoy).to_utf8_buffer())
		_session_hash = ctx.finish().hex_encode().substr(0, 16)

## Acumula los agregados del lote en el archivo histórico aggregated.json.
func _actualizar_agregado_historico(payload: Dictionary) -> void:
	var hist := {}
	if FileAccess.file_exists(ARCHIVO_AGREGADO):
		var txt := FileAccess.get_file_as_string(ARCHIVO_AGREGADO)
		var parsed = JSON.parse_string(txt)
		if typeof(parsed) == TYPE_DICTIONARY:
			hist = parsed
	var totales: Dictionary = hist.get("totales_por_tipo", {})
	for k in payload.get("agregados", {}):
		totales[k] = int(totales.get(k, 0)) + int(payload["agregados"][k])
	hist["totales_por_tipo"] = totales
	hist["ultima_actualizacion"] = Time.get_datetime_string_from_system()
	var f := FileAccess.open(ARCHIVO_AGREGADO, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(hist, "  "))
		f.close()

## Log propio vía M103 (categoría ANALYTICS), sin datos del evento.
func info_propia(msg: String) -> void:
	var lg = get_node_or_null("/root/GameLogger")
	if lg != null and lg.has_method("info"):
		lg.info(msg, lg.Category.ANALYTICS)

## Trazas debug propias (solo tipo de evento, nunca contenido).
func _log_propio(tipo: String) -> void:
	var lg = get_node_or_null("/root/GameLogger")
	if lg != null and lg.has_method("debug") and lg.is_level_enabled(lg.Level.DEBUG):
		lg.debug("analytics: %s" % tipo, lg.Category.ANALYTICS)

## ── Config ─────────────────────────────────────────────
func _cargar_config() -> void:
	var cfg_path := "res://data/analytics/config.tres"
	if ResourceLoader.exists(cfg_path):
		var cfg: Resource = load(cfg_path)
		if cfg != null and cfg.has_method("get_opt_out"):
			opt_out = cfg.get_opt_out()
			batch_interval_min = cfg.get_batch_interval_min()
			max_buffer = cfg.get_max_buffer()

## El toggle del jugador (M91) persiste y pisa la config por build.
func _cargar_opt_out() -> void:
	if FileAccess.file_exists(ARCHIVO_OPT_OUT):
		var f := FileAccess.open(ARCHIVO_OPT_OUT, FileAccess.READ)
		if f != null:
			opt_out = f.get_8() == 1
			f.close()