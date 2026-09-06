# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M58 iter 2 (glm-5.3-flash): + RF8 subtítulos por defecto (con tamaño/fondo),
# + RF13 perfiles de control data-driven (single_hand, low_mobility),
# + RF18 pausa instantánea (pausar el juego sin menús intermedios).
# Base iter 1: RF1 daltonismo, RF19 presets, señales, persistencia M57/M59.
# Ejecutar test: Godot --headless --path game/isla-ancestral --script res://scripts/accesibilidad/test_accesibilidad_manager.gd

extends Node

signal profile_loaded(profile_name: String)
signal profile_changed(profile_name: String)
signal profile_reset
signal subtitulos_changed(activado: bool, tamano: String, fondo: bool)
signal control_changed(preset: String)
signal pausa_instantanea_activada

const RUTA_PERFIL: String = "user://accessibility_profile.json"

## Perfil activo (dict: nombre, daltonismo, dificultad, texto_grande, subtitulos...)
var _perfil: Dictionary = {}

## Perfiles predefinidos (data-driven)
const PERFILES := {
	"default": {
		"daltonismo": "",
		"dificultad": "estandar",
		"texto_grande": false,
		"subtitulos": true,
		"alto_contraste": false,
	},
	"protanopia": {"daltonismo": "protanopia", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false},
	"deuteranopia": {"daltonismo": "deuteranopia", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false},
	"tritanopia": {"daltonismo": "tritanopia", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false},
	"sereno": {"daltonismo": "", "dificultad": "sereno",
		"texto_grande": true, "subtitulos": true, "alto_contraste": false},
	"alto_contraste": {"daltonismo": "", "dificultad": "estandar",
		"texto_grande": true, "subtitulos": true, "alto_contraste": true},
}

## RF8: subtítulos por defecto — activados, tamaño mediano, fondo legible.
const SUBTITULOS_DEFECTO := {"subtitulos": true, "subtitulos_tamano": "mediano",
	"subtitulos_fondo": true}

## RF13: presets de control data-driven (mapeo de acciones → teclas/botones).
const PERFILES_CONTROL := {
	"estandar": {
		"descripcion": "Controles por defecto",
		"acciones_mantenidas_auto": false,
		"tiempo_mantener_multiplicador": 1.0,
		"remap": {},
	},
	"single_hand": {
		"descripcion": "Una sola mano: acciones agrupadas en la mitad izquierda del teclado + ratón",
		"acciones_mantenidas_auto": true,
		"tiempo_mantener_multiplicador": 1.5,
		"remap": {
			"mover_izquierda": "A",
			"mover_derecha": "D",
			"mover_arriba": "W",
			"mover_abajo": "S",
			"interactuar": "RATON_IZQ",
			"usar_herramienta": "RATON_DER",
			"inventario": "Q",
			"pausa": "E",
			"mapa": "R",
		},
	},
	"low_mobility": {
		"descripcion": "Movilidad reducida: mantener automático, tiempos extendidos, sin doble toque",
		"acciones_mantenidas_auto": true,
		"tiempo_mantener_multiplicador": 2.0,
		"remap": {
			"interactuar": "ESPACIO",
			"usar_herramienta": "F",
			"pausa": "ESC",
		},
	},
}


func _ready() -> void:
	_cargar_perfil()
	# RF8: subtítulos por defecto si el perfil no trae la configuración
	for k in SUBTITULOS_DEFECTO:
		if not _perfil.has(k):
			_perfil[k] = SUBTITULOS_DEFECTO[k]


## Aplica un perfil predefinido por nombre.
func aplicar_perfil(nombre: String) -> bool:
	if not PERFILES.has(nombre):
		return false
	_perfil = PERFILES[nombre].duplicate()
	_perfil["nombre"] = nombre
	guardar_perfil()
	profile_changed.emit(nombre)
	return true


## Modifica un campo del perfil activo.
func set_campo(clave: String, valor) -> void:
	_perfil[clave] = valor
	guardar_perfil()
	profile_changed.emit(String(_perfil.get("nombre", "custom")))


func get_campo(clave: String, fallback=null):
	return _perfil.get(clave, fallback)


func get_perfil() -> Dictionary:
	return _perfil.duplicate()


## Resetea al perfil default.
func reset_perfil() -> void:
	_perfil = {"nombre": "default", "daltonismo": "", "dificultad": "estandar",
		"texto_grande": false, "subtitulos": true, "alto_contraste": false}
	guardar_perfil()
	profile_reset.emit()


func guardar_perfil() -> void:
	var f := FileAccess.open(RUTA_PERFIL, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_perfil, "\t"))


func _cargar_perfil() -> void:
	if not FileAccess.file_exists(RUTA_PERFIL):
		_perfil = {"nombre": "default", "daltonismo": "", "dificultad": "estandar",
			"texto_grande": false, "subtitulos": true, "alto_contraste": false}
		for k in SUBTITULOS_DEFECTO:
			_perfil[k] = SUBTITULOS_DEFECTO[k]
		return
	var texto := FileAccess.get_file_as_string(RUTA_PERFIL)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) == TYPE_DICTIONARY:
		_perfil = parseado
		for k in SUBTITULOS_DEFECTO:
			if not _perfil.has(k):
				_perfil[k] = SUBTITULOS_DEFECTO[k]
		profile_loaded.emit(String(_perfil.get("nombre", "custom")))
	else:
		_perfil = {"nombre": "default", "daltonismo": "", "dificultad": "estandar",
			"texto_grande": false, "subtitulos": true, "alto_contraste": false}
		for k in SUBTITULOS_DEFECTO:
			_perfil[k] = SUBTITULOS_DEFECTO[k]

# ═══════════ Iter. 2 (glm-5.3-flash): RF8 + RF13 + RF18 ═══════════

## RF8: activa/desactiva subtítulos con tamaño y fondo.
func set_subtitulos(activado: bool, tamano: String = "mediano", fondo: bool = true) -> void:
	_perfil["subtitulos"] = activado
	_perfil["subtitulos_tamano"] = tamano
	_perfil["subtitulos_fondo"] = fondo
	guardar_perfil()
	subtitulos_changed.emit(activado, tamano, fondo)
	profile_changed.emit(String(_perfil.get("nombre", "custom")))

## RF8: configura el tamaño de los subtítulos (pequeno/mediano/grande).
func set_subtitulos_tamano(tamano: String) -> bool:
	if not ["pequeno", "mediano", "grande"].has(tamano):
		return false
	_perfil["subtitulos_tamano"] = tamano
	guardar_perfil()
	subtitulos_changed.emit(bool(_perfil.get("subtitulos", true)), tamano, bool(_perfil.get("subtitulos_fondo", true)))
	return true

## RF8: estado actual de subtítulos para la capa de diálogo (M53/M150).
func get_subtitulos() -> Dictionary:
	return {"activado": bool(_perfil.get("subtitulos", true)),
		"tamano": String(_perfil.get("subtitulos_tamano", "mediano")),
		"fondo": bool(_perfil.get("subtitulos_fondo", true))}

## RF13: aplica un preset de control data-driven.
func aplicar_perfil_control(preset: String) -> bool:
	if not PERFILES_CONTROL.has(preset):
		return false
	_perfil["control_preset"] = preset
	guardar_perfil()
	control_changed.emit(preset)
	profile_changed.emit(String(_perfil.get("nombre", "custom")))
	return true

## RF13: mapeo de acciones del preset activo ({accion: tecla}).
func get_remap_control() -> Dictionary:
	var preset := String(_perfil.get("control_preset", "estandar"))
	var conf: Dictionary = PERFILES_CONTROL.get(preset, PERFILES_CONTROL["estandar"])
	return conf.get("remap", {})

## RF13: ¿las acciones de mantener se ejecutan automáticas? (low_mobility).
func mantener_automatico() -> bool:
	var preset := String(_perfil.get("control_preset", "estandar"))
	var conf: Dictionary = PERFILES_CONTROL.get(preset, PERFILES_CONTROL["estandar"])
	return bool(conf.get("acciones_mantenidas_auto", false))

## RF13: multiplicador de tiempos de mantener (1.0 estándar, 1.5/2.0 extendidos).
func tiempo_mantener_multiplicador() -> float:
	var preset := String(_perfil.get("control_preset", "estandar"))
	var conf: Dictionary = PERFILES_CONTROL.get(preset, PERFILES_CONTROL["estandar"])
	return float(conf.get("tiempo_mantener_multiplicador", 1.0))

## RF18: pausa instantánea — congela el árbol de escena sin menús intermedios.
## Emite pausa_instantanea_activada para que la capa de UI (M53) muestre su overlay.
func pausar_instantaneo() -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	if tree.paused:
		return true  # idempotente
	tree.paused = true
	pausa_instantanea_activada.emit()
	print("[M58] RF18: pausa instantánea activada")
	return true

## RF18: reanuda el juego tras la pausa instantánea.
func reanudar() -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	tree.paused = false
	return true

## RF18: ¿el juego está en pausa instantánea?
func esta_pausado() -> bool:
	var tree := get_tree()
	return tree != null and tree.paused
