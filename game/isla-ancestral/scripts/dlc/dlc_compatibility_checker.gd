# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M120: DLC y Expansiones — DLCCompatibilityChecker
# Verifica que un DLC sea compatible con la version del juego base y con los
# demas DLC que requiere. Diseno de referencia: 04-Codigo.md sec.5.
#
# Divergencias declaradas respecto del esqueleto del diseno:
#  1. El diseno pedia un autoload propio; se implementa como RefCounted
#     instanciado por DlcManager para NO tocar project.godot (archivo
#     compartido por varios agentes: trampa AM del skill). El manager es
#     inyectable para poder testearlo headless sin autoload.
#  2. La comparacion de versiones es SEMANTICA (a.b.c), no `==` como el
#     esqueleto ("en implementacion real, usar comparacion semantica").
#  3. Acepta tanto el esquema anidado `dlc_compatibility` del diseno como los
#     campos reales del manifest (`version_requerida`, `dependencias`).
#  4. NO preloadea dlc_manager.gd: el manager lo preloadea a el (evita un
#     preload circular). La comparacion semantica vive aca y la suite la
#     CRUZA contra DlcManager.comparar_versiones para que no derive.

class_name DLCCompatibilityChecker
extends RefCounted

const CLAVE_BASE := "base_game_version"
const CLAVE_OTROS := "other_dlc"
const CLAVE_BACKWARD := "backward_compatible"

## DlcManager inyectable (autoload en runtime; fake en tests headless).
var _manager: Object = null

func _init(manager: Object = null) -> void:
	_manager = manager

## Resuelve el manager: el inyectado o el autoload DlcManager del arbol.
func _mgr() -> Object:
	if _manager != null:
		return _manager
	var bucle := Engine.get_main_loop()
	if bucle is SceneTree:
		return (bucle as SceneTree).root.get_node_or_null("DlcManager")
	return null

func get_base_game_version() -> String:
	var m := _mgr()
	if m != null and m.has_method("version_base_actual"):
		return str(m.call("version_base_actual"))
	return String(ProjectSettings.get_setting("application/config/version", "1.0.0"))

## ¿La version `current` alcanza el requisito `required`? (semantico: 1.10.0 > 1.9.0)
func is_version_compatible(current_version: String, required_version: String) -> bool:
	if required_version.strip_edges().is_empty():
		return true
	return _comparar_versiones(current_version, required_version) >= 0

## Compara dos versiones "a.b.c" SEMANTICAMENTE. Devuelve -1, 0 o 1.
## Tolera segmentos faltantes ("1.2" == "1.2.0") y sufijos ("1.0.0-beta" -> 1.0.0).
## Espeja DlcManager.comparar_versiones (el manager NO se preloadea aca para no
## crear un preload circular); la suite cruza ambas implementaciones.
func _comparar_versiones(a: String, b: String) -> int:
	var pa := _parsear(a)
	var pb := _parsear(b)
	var n: int = maxi(pa.size(), pb.size())
	for i in range(n):
		var xa: int = pa[i] if i < pa.size() else 0
		var xb: int = pb[i] if i < pb.size() else 0
		if xa != xb:
			return 1 if xa > xb else -1
	return 0

func _parsear(v: String) -> Array[int]:
	var out: Array[int] = []
	for parte in v.strip_edges().split("."):
		var limpio := ""
		for ch in parte.strip_edges():
			if ch.is_valid_int():
				limpio += ch
			else:
				break
		out.append(int(limpio) if limpio != "" else 0)
	return out

## Requisitos declarados por el DLC, normalizados desde los DOS esquemas.
## Devuelve {"version": String, "otros": Array}.
func requisitos(dlc_data: Dictionary) -> Dictionary:
	var version := ""
	var otros: Array = []
	var crudo: Variant = dlc_data.get("dlc_compatibility", {})
	if typeof(crudo) == TYPE_DICTIONARY:
		var compat: Dictionary = crudo
		version = str(compat.get(CLAVE_BASE, ""))
		var o: Variant = compat.get(CLAVE_OTROS, [])
		if typeof(o) == TYPE_ARRAY:
			otros = o
	if version.is_empty():
		version = str(dlc_data.get("version_requerida", ""))
	if otros.is_empty():
		var dep: Variant = dlc_data.get("dependencias", [])
		if typeof(dep) == TYPE_ARRAY:
			otros = dep
	return {"version": version, "otros": otros}

## Compatibilidad completa: version base + DLC requeridos cargados/activos.
func check_compatibility(dlc_data: Dictionary) -> bool:
	if dlc_data.is_empty():
		return false
	var req := requisitos(dlc_data)
	if not is_version_compatible(get_base_game_version(), str(req.get("version", ""))):
		return false
	var otros: Array = req.get("otros", [])
	for requerido in otros:
		var rid := str(requerido)
		if rid.is_empty():
			continue
		if not _dlc_cargado(rid):
			return false
	return true

## Bandera `backward_compatible` declarada por el DLC (default: true).
## Un DLC backward compatible tolera versiones base POSTERIORES a la requerida.
func es_backward_compatible(dlc_data: Dictionary) -> bool:
	var crudo: Variant = dlc_data.get("dlc_compatibility", {})
	if typeof(crudo) == TYPE_DICTIONARY:
		var compat: Dictionary = crudo
		return bool(compat.get(CLAVE_BACKWARD, true))
	return true

func _dlc_cargado(dlc_id: String) -> bool:
	var m := _mgr()
	if m == null:
		return false
	if m.has_method("esta_activo"):
		return bool(m.call("esta_activo", dlc_id))
	if m.has_method("is_dlc_loaded"):
		return bool(m.call("is_dlc_loaded", dlc_id))
	return false
