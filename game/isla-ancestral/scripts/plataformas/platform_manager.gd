# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M96: Plataformas — PlatformManager (autoload)
# Selecciona el bridge activo según la plataforma de build (RF3/RF4).
# Expone servicios de plataforma de forma unificada.
# Diseño original (04-Codigo.md §1.1, PlatformManager.cs).
#
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_MATRIZ := "res://data/plataformas/plataformas.json"

var bridge: IPlatformBridge = null
var matriz: Dictionary = {}   # data-driven desde JSON

func _ready() -> void:
	_inicializar_bridge()
	_cargar_matriz()
	_registrar_servicio()
	print("[M96] PlatformManager listo: bridge=%s, %d plataformas en matriz" % [bridge.nombre if bridge else "null", matriz.size()])

func _inicializar_bridge() -> void:
	# En desarrollo, usar NullBridge. En builds reales, detectar plataforma.
	# TODO(M149): detectar plataforma real (OS.get_name() + defines)
	bridge = NullBridge.new()

func _cargar_matriz() -> void:
	if not FileAccess.file_exists(RUTA_MATRIZ):
		push_warning("[M96] Matriz no encontrada: %s" % RUTA_MATRIZ)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_MATRIZ))
	if typeof(parsed) == TYPE_DICTIONARY:
		matriz = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("plataformas"):
		sr.register("plataformas", self)

## API de plataforma (delega al bridge activo)
func desbloquear_logro(id: String) -> void:
	if bridge:
		bridge.desbloquear_logro(id)

func cloud_disponible() -> bool:
	return bridge != null and bridge.cloud_disponible()

func guardar_save_cloud(ruta_local: String) -> bool:
	return bridge != null and bridge.guardar_save_cloud(ruta_local)

func cargar_save_cloud(ruta_local: String) -> bool:
	return bridge != null and bridge.cargar_save_cloud(ruta_local)

func mostrar_overlay() -> void:
	if bridge:
		bridge.mostrar_overlay()

## API de matriz de plataformas (data-driven)
func obtener_plataforma(id: String) -> Dictionary:
	return matriz.get(id, {})

func plataformas_por_prioridad(prioridad: String) -> Array:
	var resultado: Array = []
	for id in matriz:
		var p: Dictionary = matriz[id]
		if String(p.get("prioridad", "")) == prioridad:
			resultado.append(p)
	resultado.sort_custom(func(a, b): return int(a.get("orden", 99)) < int(b.get("orden", 99)))
	return resultado

func ids_plataformas() -> Array:
	return matriz.keys()