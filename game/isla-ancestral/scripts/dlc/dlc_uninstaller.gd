# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M120: DLC y Expansiones — DLCUninstaller
# Desinstalacion de un DLC: marca los saves con contenido de ese DLC como
# "incomplete", lo descarga del manager y borra los archivos locales.
# Diseno de referencia: 04-Codigo.md sec.6.
#
# Divergencias declaradas respecto del esqueleto del diseno:
#  1. El diseno pedia un autoload propio; se implementa como RefCounted
#     instanciado por DlcManager (no se toca project.godot: trampa AM).
#  2. El directorio de saves real del proyecto es `user://saves` (M59), no
#     `user://savegames/` como decia el esqueleto.
#  3. Las rutas son INYECTABLES (`dir_saves`/`dir_dlc`) para poder testear
#     headless contra un directorio temporal sin tocar los saves reales.
#  4. Se usa un helper de apertura tolerante porque en headless con `--path`
#     relativo `DirAccess.open("user://...")` devuelve null en silencio
#     (pitfall 2.6 del skill).

class_name DLCUninstaller
extends RefCounted

const DIR_SAVES := "user://saves"
const DIR_DLC := "user://dlc"
const MARCA_INCOMPLETO := "incomplete"

var _manager: Object = null
var _dir_saves: String = DIR_SAVES
var _dir_dlc: String = DIR_DLC

func _init(manager: Object = null, dir_saves: String = DIR_SAVES, dir_dlc: String = DIR_DLC) -> void:
	_manager = manager
	_dir_saves = dir_saves
	_dir_dlc = dir_dlc

## Desinstala un DLC en orden: marcar saves -> descargar -> borrar archivos.
## Devuelve un informe observable (no lanza; el llamador decide que avisar).
func uninstall_dlc(dlc_id: String) -> Dictionary:
	var informe := {
		"dlc": dlc_id,
		"cargado": false,
		"saves_marcados": 0,
		"archivos_borrados": 0,
		"ok": false,
	}
	if dlc_id.is_empty():
		return informe
	var m := _manager
	if m == null or not _esta_cargado(m, dlc_id):
		return informe
	informe["cargado"] = true
	informe["saves_marcados"] = mark_savegames_as_incomplete(dlc_id)
	if m.has_method("desactivar"):
		m.call("desactivar", dlc_id)
	informe["archivos_borrados"] = delete_dlc_files(dlc_id)
	informe["ok"] = true
	return informe

## Marca `dlc_content[dlc_id] = "incomplete"` en los saves que lo referencian.
## Devuelve cuantos archivos se modificaron.
func mark_savegames_as_incomplete(dlc_id: String) -> int:
	if dlc_id.is_empty():
		return 0
	var dir := _abrir_dir(_dir_saves)
	if dir == null:
		return 0
	var marcados := 0
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if not dir.current_is_dir() and nombre.ends_with(".json"):
			if _marcar_archivo(_dir_saves.path_join(nombre), dlc_id):
				marcados += 1
		nombre = dir.get_next()
	dir.list_dir_end()
	return marcados

## Borra el contenido local del DLC (`dir_dlc/<dlc_id>/`) y el directorio.
## Devuelve cuantos archivos se borraron.
func delete_dlc_files(dlc_id: String) -> int:
	if dlc_id.is_empty():
		return 0
	var ruta_dlc := _dir_dlc.path_join(dlc_id)
	var dir := _abrir_dir(ruta_dlc)
	if dir == null:
		return 0
	var borrados := 0
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if not dir.current_is_dir():
			if DirAccess.remove_absolute(_absoluta(ruta_dlc.path_join(nombre))) == OK:
				borrados += 1
		nombre = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(_absoluta(ruta_dlc))
	return borrados

## Cuenta los saves que quedaron con contenido DLC marcado "incomplete".
## La reconciliacion real del payload la hace SaveManager (M59); aca se deja
## el dato observable para que el llamador pueda avisar al usuario.
func update_savegames() -> int:
	var dir := _abrir_dir(_dir_saves)
	if dir == null:
		return 0
	var incompletos := 0
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if not dir.current_is_dir() and nombre.ends_with(".json"):
			if _tiene_incompletos(_dir_saves.path_join(nombre)):
				incompletos += 1
		nombre = dir.get_next()
	dir.list_dir_end()
	return incompletos

# --- helpers ---------------------------------------------------------------

func _esta_cargado(m: Object, dlc_id: String) -> bool:
	if m.has_method("esta_activo"):
		return bool(m.call("esta_activo", dlc_id))
	if m.has_method("is_dlc_loaded"):
		return bool(m.call("is_dlc_loaded", dlc_id))
	return false

func _marcar_archivo(ruta: String, dlc_id: String) -> bool:
	var datos := _leer_json(ruta)
	if datos.is_empty():
		return false
	var crudo: Variant = datos.get("dlc_content", {})
	if typeof(crudo) != TYPE_DICTIONARY:
		return false
	var contenido: Dictionary = crudo
	if not contenido.has(dlc_id):
		return false
	contenido[dlc_id] = MARCA_INCOMPLETO
	datos["dlc_content"] = contenido
	return _escribir_json(ruta, datos)

func _tiene_incompletos(ruta: String) -> bool:
	var datos := _leer_json(ruta)
	if datos.is_empty():
		return false
	var crudo: Variant = datos.get("dlc_content", {})
	if typeof(crudo) != TYPE_DICTIONARY:
		return false
	var contenido: Dictionary = crudo
	for clave in contenido:
		if str(contenido[clave]) == MARCA_INCOMPLETO:
			return true
	return false

func _leer_json(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _escribir_json(ruta: String, datos: Dictionary) -> bool:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(datos))
	f.close()
	return true

## Resuelve una ruta `user://` a absoluta (en headless con `--path` relativo
## `globalize_path("user://...")` devuelve una ruta relativa al proyecto).
func _absoluta(ruta: String) -> String:
	if ruta.is_absolute_path():
		return ruta
	var abs := ProjectSettings.globalize_path(ruta)
	if not abs.is_absolute_path():
		abs = ProjectSettings.globalize_path("res://").path_join(abs.trim_prefix("./"))
	return abs

## Apertura tolerante de directorio (pitfall 2.6 del skill).
func _abrir_dir(ruta: String) -> DirAccess:
	var dir := DirAccess.open(ruta)
	if dir != null:
		return dir
	return DirAccess.open(_absoluta(ruta))
