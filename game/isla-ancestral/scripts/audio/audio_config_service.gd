# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M91: Configuración de Audio — AudioConfigService (autoload "AudioConfig")
# Núcleo V0/V1 (03-Diseno §1/§3/§4):
#  - 7 buses de audio creados en runtime si no existen (Master ya existe de
#    base; Music/SFX/Ambient/Voice/UI/Cinematic se agregan como hijos).
#  - set_volumen/get_volumen/mute por bus (lineal 0-1 → db), con coherencia
#    con GestorConfig (M60) sección "audio" del DEFAULTS_BASE.
#  - Persistencia: guardar_config/cargar_config de M60 (escritura atómica).
#  - Señales volumen_cambiado/mute_cambiado para la UI (M53) y M41-M44.
#  - Sin bucles por frame; sin UI (dueño M53).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

## Bus -> volumen lineal por defecto (diseño §3: defaults de AudioSettings)
const DEFAULTS: Dictionary = {
	"Master": 0.8,
	"Music": 0.7,
	"SFX": 0.8,
	"Ambient": 0.6,
	"Voice": 0.9,
	"UI": 0.5,
	"Cinematic": 0.8,
}
## Orden de creación de buses hijo (Master ya existe en el engine)
const BUSES_HIJOS: Array[String] = ["Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]

signal volumen_cambiado(bus: String, volumen: float)
signal mute_cambiado(bus: String, mute: bool)

## volumen lineal (0-1) por bus (persistido)
var _volumenes: Dictionary = {}
## estado mute por bus
var _mutes: Dictionary = {}


func _ready() -> void:
	_crear_buses()
	_cargar_config()
	_registrar_proveedor_guardado()


## §4: crea los buses hijo si no existen, enroutados a Master
func _crear_buses() -> void:
	var master_idx := AudioServer.get_bus_index("Master")
	for nombre in BUSES_HIJOS:
		if AudioServer.get_bus_index(nombre) == -1:
			var idx := AudioServer.bus_count
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, nombre)
			AudioServer.set_bus_send(idx, "Master")
	# Enrutar todos los buses existentes al Master (salvo el propio Master)
	for i in range(AudioServer.bus_count):
		var nombre := AudioServer.get_bus_name(i)
		if nombre != "Master":
			AudioServer.set_bus_send(i, "Master")


func _cargar_config() -> void:
	# Defaults del diseño primero, luego lo persistido (M60 sección "audio")
	_volumenes = DEFAULTS.duplicate()
	var ds := get_node_or_null("/root/DataStore")
	if ds != null and ds.has_method("cargar_config"):
		var config: Dictionary = ds.cargar_config()
		var audio: Dictionary = config.get("audio", {})
		for clave in audio:
			if _volumenes.has(clave):
				_volumenes[clave] = clampf(float(audio[clave]), 0.0, 1.0)
	_aplicar_todo()


## Aplica los volúmenes al AudioServer (linear → db, §3)
func _aplicar_todo() -> void:
	for bus in _volumenes:
		_aplicar_volumen(String(bus), float(_volumenes[bus]))


func _aplicar_volumen(bus: String, vol: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx == -1:
		return
	if bool(_mutes.get(bus, false)):
		AudioServer.set_bus_mute(idx, true)
		return
	AudioServer.set_bus_mute(idx, false)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(vol, 0.0001)))


## ── API pública (§3) ────────────────────────────────────

func set_volumen(bus: String, vol: float) -> bool:
	if not _volumenes.has(bus):
		return false
	var v := clampf(vol, 0.0, 1.0)
	_volumenes[bus] = v
	_aplicar_volumen(bus, v)
	volumen_cambiado.emit(bus, v)
	_guardar_config()
	return true


func get_volumen(bus: String) -> float:
	return float(_volumenes.get(bus, 0.0))


func set_mute(bus: String, mute: bool) -> void:
	_mutes[bus] = mute
	_aplicar_volumen(bus, get_volumen(bus))
	mute_cambiado.emit(bus, mute)


func esta_muteado(bus: String) -> bool:
	return bool(_mutes.get(bus, false))


## Accesibilidad M58: "Sin truenos" = mute de SFX; volumen voz para subtítulos
func buses_disponibles() -> Array:
	return _volumenes.keys()


## ── Persistencia (M60 sección "audio") ──────────────────

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func _guardar_config() -> void:
	var ds := get_node_or_null("/root/DataStore")
	if ds == null or not ds.has_method("guardar_config"):
		return
	var config: Dictionary = ds.cargar_config()
	var audio: Dictionary = config.get("audio", {})
	for bus in _volumenes:
		audio[String(bus)] = float(_volumenes[bus])
	config["audio"] = audio
	ds.guardar_config(config)


func get_section_name() -> String:
	return "audio_config"


func get_save_data() -> Dictionary:
	return {"volumenes": _volumenes.duplicate(), "mutes": _mutes.duplicate()}


func restore_save_data(data: Dictionary) -> void:
	var v: Dictionary = data.get("volumenes", {})
	for k in v:
		if _volumenes.has(String(k)):
			_volumenes[String(k)] = clampf(float(v[k]), 0.0, 1.0)
	_mutes.clear()
	var m: Dictionary = data.get("mutes", {})
	for k in m:
		_mutes[String(k)] = bool(m[k])
	_aplicar_todo()
