# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M120: DLC y Expansiones — DLCBundleManager
# Gestion data-driven de bundles (Season Pass, Bundle Completo, Bundle de
# Islas): carga, precio y descuento calculado. Diseno de referencia:
# 04-Codigo.md sec.7 y sec.8.
#
# Divergencias declaradas respecto del esqueleto del diseno:
#  1. El diseno pedia un autoload propio; se implementa como RefCounted
#     instanciado por DlcManager (no se toca project.godot: trampa AM).
#  2. Ruta real `res://data/dlc/bundles.json` (el diseno decia `res://dlc/`).
#  3. Acepta el envoltorio real `{"bundles": [ ... ]}` y tambien un diccionario
#     indexado por id; y normaliza las DOS grafias de clave (id/bundle_id,
#     nombre/bundle_name, precio/bundle_price, dlcs/bundle_dlcs,
#     descripcion/bundle_description) para ser compatible con dlc_manager.gd.
#  4. El precio final de cada DLC lo fija M95 (Monetizacion); aca se lee el
#     campo `precio` de referencia del manifest y se usa 0.0 si no existe.

class_name DLCBundleManager
extends RefCounted

const RUTA_BUNDLES := "res://data/dlc/bundles.json"
const RUTA_MANIFEST := "res://data/dlc/dlc_manifest.json"

var bundles: Dictionary = {}

var _precios: Dictionary = {}
var _ruta_bundles: String = RUTA_BUNDLES
var _ruta_manifest: String = RUTA_MANIFEST

func _init(ruta_bundles: String = RUTA_BUNDLES, ruta_manifest: String = RUTA_MANIFEST) -> void:
	_ruta_bundles = ruta_bundles
	_ruta_manifest = ruta_manifest
	load_bundles()
	_cargar_precios()

## Carga y normaliza los bundles. Devuelve false si no se pudo leer ninguno.
func load_bundles() -> bool:
	bundles = {}
	var parsed := _leer_json(_ruta_bundles)
	if parsed.is_empty():
		return false
	var crudo: Variant = parsed.get("bundles", parsed)
	if typeof(crudo) == TYPE_ARRAY:
		for b in crudo:
			if typeof(b) == TYPE_DICTIONARY:
				_registrar(b)
	elif typeof(crudo) == TYPE_DICTIONARY:
		var por_id: Dictionary = crudo
		for clave in por_id:
			var v: Variant = por_id[clave]
			if typeof(v) == TYPE_DICTIONARY:
				var d: Dictionary = v
				if not d.has("id") and not d.has("bundle_id"):
					d["id"] = str(clave)
				_registrar(d)
	return not bundles.is_empty()

func total() -> int:
	return bundles.size()

func ids() -> Array:
	var out: Array = []
	for k in bundles:
		out.append(k)
	out.sort()
	return out

func get_bundle_price(bundle_id: String) -> float:
	return _num(_bundle(bundle_id).get("precio", 0.0))

func get_bundle_dlc_ids(bundle_id: String) -> Array:
	var v: Variant = _bundle(bundle_id).get("dlcs", [])
	if typeof(v) == TYPE_ARRAY:
		return v
	return []

## Descuento del bundle. Si TODOS sus DLC tienen precio > 0 se CALCULA
## (1 - precio_bundle / suma_individual); si falta algun precio se usa el
## `descuento` declarado en el JSON (un DLC sin precio haria el calculo basura).
func calculate_bundle_discount(bundle_id: String) -> float:
	var individual := 0.0
	var todos_con_precio := true
	for id in get_bundle_dlc_ids(bundle_id):
		var p := get_dlc_price(str(id))
		if p <= 0.0:
			todos_con_precio = false
		individual += p
	var precio := get_bundle_price(bundle_id)
	if todos_con_precio and individual > 0.0 and precio > 0.0 and precio < individual:
		return 1.0 - (precio / individual)
	return _num(_bundle(bundle_id).get("descuento", 0.0))

func get_dlc_price(dlc_id: String) -> float:
	return _num(_precios.get(dlc_id, 0.0))

# --- helpers ---------------------------------------------------------------

func _registrar(b: Dictionary) -> void:
	var id := str(_primero(b, ["id", "bundle_id"]))
	if id.is_empty():
		return
	bundles[id] = {
		"id": id,
		"nombre": str(_primero(b, ["nombre", "bundle_name"])),
		"precio": _num(_primero(b, ["precio", "bundle_price"])),
		"dlcs": _lista(b, ["dlcs", "bundle_dlcs"]),
		"descuento": _num(b.get("descuento", 0.0)),
		"descripcion": str(_primero(b, ["descripcion", "bundle_description"])),
	}

func _cargar_precios() -> void:
	_precios = {}
	var parsed := _leer_json(_ruta_manifest)
	if parsed.is_empty():
		return
	var crudo: Variant = parsed.get("dlcs", [])
	if typeof(crudo) != TYPE_ARRAY:
		return
	for d in crudo:
		if typeof(d) == TYPE_DICTIONARY:
			var dd: Dictionary = d
			var id := str(dd.get("id", ""))
			if not id.is_empty():
				_precios[id] = _num(dd.get("precio", 0.0))

func _bundle(bundle_id: String) -> Dictionary:
	var v: Variant = bundles.get(bundle_id, {})
	if typeof(v) == TYPE_DICTIONARY:
		return v
	return {}

func _primero(b: Dictionary, claves: Array) -> Variant:
	for c in claves:
		if b.has(c):
			return b[c]
	return null

func _lista(b: Dictionary, claves: Array) -> Array:
	for c in claves:
		var v: Variant = b.get(c, null)
		if typeof(v) == TYPE_ARRAY:
			return v
	return []

func _num(v: Variant) -> float:
	if typeof(v) == TYPE_FLOAT or typeof(v) == TYPE_INT:
		return float(v)
	if typeof(v) == TYPE_STRING:
		var s := String(v)
		if s.is_valid_float():
			return s.to_float()
	return 0.0

func _leer_json(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}
