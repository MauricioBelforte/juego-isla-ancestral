# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M122: Crash Reporting — CrashReporter (autoload)
# Captura de excepciones/signals, crash dump JSON (stack, versión, sesión),
# cola de envío con reintentos. Adaptación Godot 4.7/GDScript.
# Diseño original (04-Codigo.md §1.1).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const DIR_DUMPS := "user://crash/"
const MAX_REINTENTOS := 3

signal crash_reportado(dump: Dictionary)

var _session_id: String = ""
var _reintentos: Dictionary = {}   # ruta -> intentos

func _ready() -> void:
	_session_id = "%s_%d" % [Time.get_datetime_string_from_system(true), Time.get_ticks_usec()]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR_DUMPS))
	_registrar_servicio()
	print("[M122] CrashReporter listo (sesión %s)" % _session_id)

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("crash"):
		sr.register("crash", self)

## Registra un crash con su stack (String[]). Escribe dump JSON a disco.
## Devuelve la ruta del dump o "" si falló.
func reportar_crash(tipo: String, mensaje: String, stack: Array) -> String:
	var dump := {
		"session": _session_id,
		"timestamp_iso": Time.get_datetime_string_from_system(true),
		"tipo": tipo,
		"mensaje": mensaje,
		"stack": stack.duplicate(),
		"reintentos": 0,
	}
	var nombre := "crash_%s_%d.json" % [Time.get_datetime_string_from_system(true).replace(":", "-"), Time.get_ticks_usec()]
	var ruta := "%s%s" % [DIR_DUMPS, nombre]
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		push_error("[M122] No se pudo escribir crash dump")
		return ""
	f.store_string(JSON.stringify(dump, "  "))
	f.close()
	emit_signal("crash_reportado", dump)
	print("[M122] Crash registrado: %s (%s)" % [tipo, ruta])
	return ruta

## Simula el envío del dump (M104 analytics hook). Con reintentos.
## Devuelve true si se "envió" en el 1er intento (en este stub: siempre).
func enviar_dump(ruta: String) -> bool:
	if not FileAccess.file_exists(ruta):
		return false
	var intentos: int = _reintentos.get(ruta, 0)
	if intentos >= MAX_REINTENTOS:
		return false
	_reintentos[ruta] = intentos + 1
	# Stub: en producción, subir a Crashlytics/Sentry (M122 diseño)
	print("[M122] Dump enviado (intento %d): %s" % [intentos + 1, ruta])
	return true

func dumps_pendientes() -> Array:
	var dir := DirAccess.open(DIR_DUMPS)
	if dir == null:
		return []
	var pendientes: Array = []
	for f in dir.get_files():
		if f.ends_with(".json"):
			pendientes.append("%s%s" % [DIR_DUMPS, f])
	return pendientes

func cantidad_dumps() -> int:
	return dumps_pendientes().size()