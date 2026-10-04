# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
# Modificado: mimo-v2.6-flash-free / opencode — 2026-10-02 (lote 2: API de
#             porcentaje 0-100 para los sliders de M53)
#             2026-10-04 (BUG-092: mutes persisten en config.cfg, API
#             set_opcion() para rango_dinamico/compresion/dispositivo_salida con
#             auto-guardado y restauración al arrancar — ver 11-BUGS BUG-092)
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
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).
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

## Opciones de audio SIN auto-save propio (BUG-092): las secciones del menú que
## hasta ahora solo vivían en memoria. Este servicio las centraliza en
## config.cfg por el MISMO camino que set_volumen() (§18 del 03-Diseno).
const OPCIONES_VALIDAS: Array[String] = ["rango_dinamico", "compresion", "dispositivo_salida"]

signal volumen_cambiado(bus: String, volumen: float)
signal mute_cambiado(bus: String, mute: bool)
signal opcion_cambiada(clave: String, valor: Variant)

## volumen lineal (0-1) por bus (persistido)
var _volumenes: Dictionary = {}
## estado mute por bus (persistido en config.cfg desde BUG-092)
var _mutes: Dictionary = {}
## opciones seleccionables (rango_dinamico/compresion/dispositivo_salida, persistidas)
var _opciones: Dictionary = {}


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
	_mutes.clear()
	_opciones = {}
	var ds := get_node_or_null("/root/DataStore")
	if ds != null and ds.has_method("cargar_config"):
		var config: Dictionary = ds.cargar_config()
		var audio: Dictionary = config.get("audio", {})
		for clave in audio:
			if _volumenes.has(clave):
				_volumenes[clave] = clampf(float(audio[clave]), 0.0, 1.0)
		# BUG-092: mutes y opciones guardados como sub-diccionarios de "audio"
		var mutes_v: Variant = audio.get("mutes", {})
		if typeof(mutes_v) == TYPE_DICTIONARY:
			for k in (mutes_v as Dictionary):
				if _volumenes.has(String(k)):
					_mutes[String(k)] = bool(mutes_v[k])
		var opciones_v: Variant = audio.get("opciones", {})
		if typeof(opciones_v) == TYPE_DICTIONARY:
			_opciones = (opciones_v as Dictionary).duplicate()
	_aplicar_todo()
	_aplicar_opciones()


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


## ── API de porcentaje 0-100 (sliders de M53, §3) ────────
# El estado interno SIEMPRE es lineal 0-1; el porcentaje es solo la capa de
# presentación que usa la UI. Así persistencia, señales y mute siguen coherentes.

## Slider 0-100 → lineal 0-1 (redondeo y clamp incluidos)
static func porcentaje_a_lineal(porcentaje: float) -> float:
	return clampf(porcentaje, 0.0, 100.0) / 100.0


## Lineal 0-1 → slider 0-100
static func lineal_a_porcentaje(volumen: float) -> float:
	return clampf(volumen, 0.0, 1.0) * 100.0


## Slider 0-100 → dB (linear2db, piso -80 dB como en _aplicar_volumen).
## Útil para mostrar dB en la UI o para barras de medición.
static func porcentaje_a_db(porcentaje: float) -> float:
	return linear_to_db(maxf(porcentaje_a_lineal(porcentaje), 0.0001))


## dB → slider 0-100 (inversa de porcentaje_a_db; db_to_linear + clamp)
static func db_a_porcentaje(db: float) -> float:
	return lineal_a_porcentaje(db_to_linear(db))


## Fija el volumen de un bus desde un slider 0-100. Devuelve false si el bus no existe.
func set_volumen_porcentaje(bus: String, porcentaje: float) -> bool:
	return set_volumen(bus, porcentaje_a_lineal(porcentaje))


## Devuelve el volumen de un bus como porcentaje 0-100 (para el valor del slider)
func get_volumen_porcentaje(bus: String) -> float:
	return lineal_a_porcentaje(get_volumen(bus))


func set_mute(bus: String, mute: bool) -> void:
	_mutes[bus] = mute
	_aplicar_volumen(bus, get_volumen(bus))
	mute_cambiado.emit(bus, mute)
	# BUG-092: los mutes se auto-guardan en config.cfg igual que los volúmenes
	# (antes solo vivían en el savegame y se perdían entre sesiones).
	_guardar_config()


func esta_muteado(bus: String) -> bool:
	return bool(_mutes.get(bus, false))


## Accesibilidad M58: "Sin truenos" = mute de SFX; volumen voz para subtítulos
func buses_disponibles() -> Array:
	return _volumenes.keys()


## ── Opciones de audio (BUG-092: secciones sin auto-save) ──
# set_opcion() sigue EXACTAMENTE el camino de set_volumen(): validar → aplicar
# → persistir en config.cfg (escritura atómica de M60) → emitir señal.
# La restauración al arrancar ocurre en _cargar_config() → _aplicar_opciones().

## Fija una opción de audio. Devuelve false si la clave o el valor no son
## válidos, o si la aplicación al motor falla (no persiste en ese caso).
func set_opcion(clave: String, valor: Variant) -> bool:
	if not OPCIONES_VALIDAS.has(clave):
		return false
	if not _valor_opcion_valido(clave, valor):
		return false
	if not _aplicar_opcion(clave, valor):
		return false
	_opciones[clave] = valor
	opcion_cambiada.emit(clave, valor)
	_guardar_config()
	return true


## Devuelve una opción persistida; por_defecto si no existe.
func get_opcion(clave: String, por_defecto: Variant = null) -> Variant:
	return _opciones.get(clave, por_defecto)


## Claves de opción conocidas (para la UI de M53 y testeos).
func opciones_disponibles() -> Array[String]:
	return OPCIONES_VALIDAS.duplicate()


func _valor_opcion_valido(clave: String, valor: Variant) -> bool:
	match clave:
		"rango_dinamico":
			return typeof(valor) == TYPE_STRING \
					and DynamicRangeManager.PRESETS.has(String(valor))
		"compresion":
			return typeof(valor) == TYPE_BOOL
		"dispositivo_salida":
			return typeof(valor) == TYPE_STRING \
					and OutputDeviceManager.dispositivos().has(String(valor))
	return false


## Aplica la opción al motor (managers stateless de M91) y confirma el estado
## final. Devuelve false si no se pudo aplicar (la opción NO se persiste).
func _aplicar_opcion(clave: String, valor: Variant) -> bool:
	match clave:
		"rango_dinamico":
			if not DynamicRangeManager.aplicar(String(valor)):
				return false
			# El estado final derivado debe coincidir con lo pedido
			# ("dinamico" = sin compresión → actual() "dinamico").
			return DynamicRangeManager.actual() == String(valor)
		"compresion":
			if bool(valor):
				CompressionManager.activar()
			else:
				CompressionManager.desactivar()
			return CompressionManager.activa() == bool(valor)
		"dispositivo_salida":
			return OutputDeviceManager.seleccionar(String(valor))
	return false


## Restaura y reaplica todas las opciones persistidas (llamado desde
## _cargar_config()). Las claves desconocidas de versiones futuras se ignoran.
func _aplicar_opciones() -> void:
	for clave in _opciones:
		if OPCIONES_VALIDAS.has(clave):
			_aplicar_opcion(clave, _opciones[clave])


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
	# BUG-092: mutes y opciones van como sub-diccionarios de la misma sección
	# (ConfigFile serializa Dictionary anidado; GestorConfig los devuelve tal cual).
	audio["mutes"] = _mutes.duplicate()
	audio["opciones"] = _opciones.duplicate()
	config["audio"] = audio
	ds.guardar_config(config)


func get_section_name() -> String:
	return "audio_config"


func get_save_data() -> Dictionary:
	return {
		"volumenes": _volumenes.duplicate(),
		"mutes": _mutes.duplicate(),
		"opciones": _opciones.duplicate(),
	}


func restore_save_data(data: Dictionary) -> void:
	var v: Dictionary = data.get("volumenes", {})
	for k in v:
		if _volumenes.has(String(k)):
			_volumenes[String(k)] = clampf(float(v[k]), 0.0, 1.0)
	_mutes.clear()
	var m: Dictionary = data.get("mutes", {})
	for k in m:
		_mutes[String(k)] = bool(m[k])
	# BUG-092: las opciones se mezclan estilo volúmenes (las ausentes se
	# conservan) y se reaplican al motor.
	var o: Dictionary = data.get("opciones", {})
	for k in o:
		_opciones[String(k)] = o[k]
	_aplicar_todo()
	_aplicar_opciones()
