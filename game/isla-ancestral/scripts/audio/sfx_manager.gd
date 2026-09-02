# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M43: Efectos de Sonido — SFXManager (autoload)
# Pool de 24 voces con prioridades (04-Codigo.md §1.1): reproducción por
# superficie con variaciones, límite duro (si el pool está lleno y la nueva
# prioridad es mayor, corta la voz más antigua de menor prioridad; nunca
# crece sin tope). Diseño original (04-Codigo.md §1.1).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const MAX_VOCES := 24
const RUTA_SURFACES := "res://data/audio/sfx_surfaces.json"

var surfaces: Dictionary = {}
var _voces: Array = []  # [{tipo, prioridad, tiempo_ms}]

func _ready() -> void:
	_cargar_surfaces()
	_registrar_servicio()
	print("[M43] SFXManager listo (%d superficies)" % surfaces.size())

func _cargar_surfaces() -> void:
	if not FileAccess.file_exists(RUTA_SURFACES):
		push_warning("[M43] sfx_surfaces.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SURFACES))
	if typeof(parsed) == TYPE_DICTIONARY:
		surfaces = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("sfx"):
		sr.register("sfx", self)

## Reproduce el sonido de una superficie (ej: "madera", "piedra").
## Prioridad 0-10. Devuelve la variación elegida o "" si se descartó.
func reproducir_superficie(superficie: String, prioridad: int = 5) -> String:
	var variaciones: Array = surfaces.get(superficie, {}).get("variaciones", [])
	if variaciones.is_empty():
		return ""
	var variacion := String(variaciones[randi() % variaciones.size()])
	_reproducir("superficie_%s" % superficie, prioridad)
	return variacion

## Reproduce un SFX directo con prioridad. Aplica límite duro del pool.
func reproducir(tipo: String, prioridad: int = 5) -> bool:
	return _reproducir(tipo, prioridad)

func _reproducir(tipo: String, prioridad: int) -> bool:
	var ahora := Time.get_ticks_msec()
	# Limpiar voces viejas (> 5 s)
	for i in range(_voces.size() - 1, -1, -1):
		if ahora - int(_voces[i]["tiempo_ms"]) > 5000:
			_voces.remove_at(i)
	if _voces.size() < MAX_VOCES:
		_voces.append({"tipo": tipo, "prioridad": prioridad, "tiempo_ms": ahora})
		return true
	# Pool lleno: buscar la voz de menor prioridad
	var idx_min := 0
	var min_prio := 999
	for i in range(_voces.size()):
		if int(_voces[i]["prioridad"]) < min_prio:
			min_prio = int(_voces[i]["prioridad"])
			idx_min = i
	if prioridad > min_prio:
		_voces[idx_min] = {"tipo": tipo, "prioridad": prioridad, "tiempo_ms": ahora}
		return true
	return false  # descartada (límite duro)

func voces_activas() -> int:
	return _voces.size()