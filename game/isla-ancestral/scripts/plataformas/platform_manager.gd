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

## Senales para integracion con M55/M59/M149.
signal plataforma_cambiada(plataforma_id: String, bridge_nombre: String)
signal plataforma_no_soportada(plataforma_id: String, motivo: String)

var bridge: IPlatformBridge = null
var matriz: Dictionary = {}   # data-driven desde JSON
var plataforma_actual: String = "null"  # id de la plataforma detectada (steam, mac, etc.)

func _ready() -> void:
	_inicializar_bridge()
	_cargar_matriz()
	_registrar_servicio()
	print("[M96] PlatformManager listo: bridge=%s, plataforma=%s, %d plataformas en matriz" % [bridge.nombre if bridge else "null", plataforma_actual, matriz.size()])

func _inicializar_bridge() -> void:
	# RF3/RF4: detectar plataforma actual via OS.
	var plat: String = _detectar_plataforma_actual()
	plataforma_actual = plat
	# Mapeo OS -> id de plataforma. Si no hay match, usar null.
	var bridge_factory: Callable = _bridge_para(plat)
	if bridge_factory.is_valid():
		bridge = bridge_factory.call()
	else:
		bridge = NullBridge.new()
		plataforma_no_soportada.emit(plat, "Sin bridge para OS detectado; usando NullBridge")
	plataforma_cambiada.emit(plat, bridge.nombre if bridge else "null")

## Auto-deteccion de plataforma. RF3/RF4: OS.get_name() + defines.
## Si build es Windows, plataforma = "steam".
## En produccion: usa defines exportadas (steam_deck verified, consola con SDK).
## En dev: retorna "null" o lo que el OS.get_name() indique.
func _detectar_plataforma_actual() -> String:
	var os_name: String = OS.get_name()
	# Mapeo basico; los defines custom de export son responsabilidad de M96 build pipeline
	if os_name == "Windows" or os_name == "Linux" or os_name == "FreeBSD" or os_name == "NetBSD" or os_name == "BSD" or os_name == "macOS":
		return os_name.to_lower()  # "windows", "linux", "macos"
	# Android/iOS no son objetivo de M96
	return "null"

## Factory: dado un id de plataforma, devuelve el Callable que crea su bridge.
## RF11: cada plataforma tiene su bridge concreto.
## En dev: todos los bridges son mock o null. En produccion: real (Steamworks, EOS, GOG Galaxy).
func _bridge_para(plat: String) -> Callable:
	match plat:
		"steam", "windows", "linux", "macos":
			# En dev: usar SteamBridge mock. En produccion: real SDK.
			return func(): return SteamBridge.new()
		"steam_deck":
			return func(): return SteamBridge.new()
		"epic", "gog", "playstation", "xbox", "nintendo":
			# Sin SDK en M96 iter 1; se delega a M77/M118
			return Callable()
		_:
			return Callable()  # sin bridge; el manager cae a NullBridge

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