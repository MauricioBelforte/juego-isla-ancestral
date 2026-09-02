# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M36: Fauna - FaunaRegistry (autoload "fauna_registry").
# Autoridad unica de descubrimientos de fauna. Mantiene estados por especie
# (NO_AVISTADA, AVISTADA, FOTOGRAFIADA) y emite senales al UI/consumidores.
# Persistencia M59 con JSON en user://fauna/registro.json (no rompe si M59 no esta).
# Reutiliza TimeCalendar (M29) para contexto temporal sin acoplamiento fuerte.
#
# Pitfalls respetados (07-GUIA-GODOT):
#   - Sin class_name (autoload, seccion 9.17)
#   - snake_case en senales
#   - Duck-typing en M29 y M59 (no falla si no existen)
#   - Tolerante a fallos (nunca rompe por ausencia de deps)

extends Node

signal especie_avistada(especie_id: StringName, contexto: Dictionary)
signal especie_fotografiada(especie_id: StringName, foto_id: String)
signal diario_cambio()

enum EstadoEspecie { NO_AVISTADA, AVISTADA, FOTOGRAFIADA }

const RUTA_SAVE_LOCAL := "user://fauna/registro.json"
const SECCION_SAVE := "fauna_registry"
const VERSION := 1
## Dedupe temporal: mismo individuo a menos de N segundos no re-registra
const DEDUPE_TIEMPO_S := 30.0
## Tolerancia minima en pantalla antes de registrar (RF: 0.5s)
const TOLERANCIA_PANTALLA_S := 0.5
## Distancia maxima de deteccion (en metros)
const DISTANCIA_AVISTAMIENTO_M := 24.0

## Estado: id -> EstadoEspecie
var _estados: Dictionary = {}
## Historial: id -> Array de contextos (timestamp, hora, dia, bioma, clima)
var _historial: Dictionary = {}
## Conteo de avistamientos por especie
var _contador_avistamientos: Dictionary = {}
## Dedupe: instancia_id -> ultimo timestamp de registro
var _dedupe: Dictionary = {}

func _ready() -> void:
	# Persistencia M59
	var sm := _get_save_manager()
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)
	# Reset dedupe al cambio de dia (M29) - los avistamientos de ayer ya no importan
	var gt := _get_time_calendar()
	if gt != null and gt.has_signal("dia_cambio"):
		gt.dia_cambio.connect(_on_dia_cambio)

## ── API publica ─────────────────────────────────────────────

func registrar_avistamiento(especie_id: StringName, contexto: Dictionary) -> void:
	if especie_id == &"":
		return
	var ahora_s: float = _tiempo_actual_s()
	var instancia_id: String = String(contexto.get("instancia_id", ""))
	# Dedupe por instancia
	if instancia_id != "":
		# Fix Log 406: has() explícito — el default 0.0 de _dedupe.get()
		# combinado con tiempo de motor bloqueaba el PRIMER avistamiento de
		# cada instancia durante los primeros 30s de sesión (regresión
		# detectada por test_fauna). Con unix-time el bug era invisible.
		if _dedupe.has(instancia_id):
			var ultimo: float = float(_dedupe[instancia_id])
			if ahora_s - ultimo < DEDUPE_TIEMPO_S:
				return
		_dedupe[instancia_id] = ahora_s
	# Tolerancia minima en pantalla
	var tiempo_pantalla: float = float(contexto.get("tiempo_pantalla_s", 0.0))
	if tiempo_pantalla < TOLERANCIA_PANTALLA_S:
		return
	# Distancia maxima
	var distancia: float = float(contexto.get("distancia", 0.0))
	if distancia > DISTANCIA_AVISTAMIENTO_M:
		return
	# Aceptar avistamiento
	var estado_actual: int = estado_especie(especie_id)
	if estado_actual == EstadoEspecie.NO_AVISTADA:
		_estados[especie_id] = EstadoEspecie.AVISTADA
	# Acumular en historial
	if not _historial.has(especie_id):
		_historial[especie_id] = []
	_historial[especie_id].append(contexto)
	# Contador
	_contador_avistamientos[especie_id] = int(_contador_avistamientos.get(especie_id, 0)) + 1
	# Emitir senales
	especie_avistada.emit(especie_id, contexto)
	diario_cambio.emit()

func registrar_foto(especie_id: StringName, foto_id: String) -> void:
	if especie_id == &"":
		return
	_estados[especie_id] = EstadoEspecie.FOTOGRAFIADA
	especie_fotografiada.emit(especie_id, foto_id)
	diario_cambio.emit()

func estado_especie(especie_id: StringName) -> int:
	return int(_estados.get(especie_id, EstadoEspecie.NO_AVISTADA))

func porcentaje_descubierto(total_especies: int) -> float:
	if total_especies <= 0:
		return 0.0
	var descubiertas: int = 0
	for s in _estados.values():
		if s != EstadoEspecie.NO_AVISTADA:
			descubiertas += 1
	return float(descubiertas) / float(total_especies)

func encontrar_registrados() -> Array:
	# Devuelve las especies que tienen al menos NO_AVISTADA -> AVISTADA o FOTOGRAFIADA
	var out: Array = []
	for id in _estados.keys():
		var s: int = int(_estados[id])
		if s != EstadoEspecie.NO_AVISTADA:
			out.append({"id": id, "estado": s, "contador": int(_contador_avistamientos.get(id, 0))})
	return out

func obtener_contexto_especie(especie_id: StringName) -> Dictionary:
	var historial: Array = _historial.get(especie_id, [])
	if historial.is_empty():
		return {}
	return historial[historial.size() - 1]

func total_avistamientos(especie_id: StringName) -> int:
	return int(_contador_avistamientos.get(especie_id, 0))

## ── Persistencia M59 ───────────────────────────────────────

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	# Convertir StringName -> String para serializacion JSON
	var estados_s: Dictionary = {}
	for k in _estados.keys():
		estados_s[String(k)] = int(_estados[k])
	var contador_s: Dictionary = {}
	for k in _contador_avistamientos.keys():
		contador_s[String(k)] = int(_contador_avistamientos[k])
	return {
		"version": VERSION,
		"estados": estados_s,
		"contador_avistamientos": contador_s,
		"cantidad_historiales": _historial.size(),
	}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < VERSION:
		return
	_estados.clear()
	_contador_avistamientos.clear()
	var estados_s: Dictionary = data.get("estados", {})
	for k in estados_s.keys():
		_estados[StringName(String(k))] = int(estados_s[k])
	var contador_s: Dictionary = data.get("contador_avistamientos", {})
	for k in contador_s.keys():
		_contador_avistamientos[StringName(String(k))] = int(contador_s[k])

## ── Persistencia local (independiente de M59) ──────────────

func guardar_local() -> void:
	var f := FileAccess.open(RUTA_SAVE_LOCAL, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(get_save_data()))
	f.close()

func cargar_local() -> bool:
	if not FileAccess.file_exists(RUTA_SAVE_LOCAL):
		return false
	var f := FileAccess.open(RUTA_SAVE_LOCAL, FileAccess.READ)
	if f == null:
		return false
	var content := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	restore_save_data(parsed)
	return true

## ── Internos ───────────────────────────────────────────────

func _tiempo_actual_s() -> float:
	# Fix C56 (M30 re-auditoría, Log 406): el reloj del SO está PROHIBIDO en
	# gameplay (regla de oro del módulo 30; el scan caso_reloj_tests.gd lo
	# detecta y hacía fallar el check). El dedupe es POR SESIÓN: _dedupe NO se
	# persiste en get_save_data() (se resetea en cada arranque y con
	# dia_cambio), así que unix-time "entre sesiones" nunca aplicó en la
	# práctica. Time.get_ticks_msec() (tiempo de motor: segundos reales de
	# pared desde el arranque) preserva el comportamiento observable —
	# 30s reales entre re-registros del mismo individuo en la sesión.
	# Ver 07-GUIA-GODOT §9.63.
	return float(Time.get_ticks_msec()) / 1000.0

func _on_dia_cambio(_info: Dictionary) -> void:
	# Reset dedupe diario
	_dedupe.clear()

func _get_save_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("SaveManager")

func _get_time_calendar() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("TimeCalendar")
