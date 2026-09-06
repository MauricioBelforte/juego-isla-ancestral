# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M58 iter: AccesibilidadManager (autoload) — perfiles data-driven con:
#  - RF1: 3 perfiles de daltonismo (protanopia, deuteranopia, tritanopia)
#  - RF19: 3 presets de dificultad (Sereno, Estándar, Personalizado)
#  - Señales: profile_loaded, profile_changed, profile_reset
#  - Persistencia: user://accessibility_profile.json (M57/M59 pattern)
# Ejecutar test: Godot --headless --path game/isla-ancestral --script res://scripts/accesibilidad/test_accesibilidad_manager.gd

extends Node

signal profile_loaded(profile_name: String)
signal profile_changed(profile_name: String)
signal profile_reset

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


func _ready() -> void:
	_cargar_perfil()


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
		return
	var texto := FileAccess.get_file_as_string(RUTA_PERFIL)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) == TYPE_DICTIONARY:
		_perfil = parseado
		profile_loaded.emit(String(_perfil.get("nombre", "custom")))
	else:
		_perfil = {"nombre": "default", "daltonismo": "", "dificultad": "estandar",
			"texto_grande": false, "subtitulos": true, "alto_contraste": false}
