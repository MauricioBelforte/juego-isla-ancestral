# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: familia HERRAMIENTAS.
# Cierra los items 121, 122, 123 y 124 del checklist:
#   121 uso de pico (grieta)
#   122 uso de gancho (pasarela)
#   123 uso de farol (iluminar runa)
#   124 condicion de inventario presente para la herramienta
#
# Modelo de datos puro (RefCounted + static). Cada `uso` declara una herramienta,
# un objetivo del mundo, una posicion y el emisor que activa. La condicion de
# inventario (item 124) exige que el item REAL del catalogo este presente en el
# inventario del jugador (duck-typed contra `scripts/inventario/inventario_service.gd`,
# `count_item(item_id, include_house) -> int`).
#
# Los ids de item son los REALES del catalogo (`data/items/*.tres`). MEDIDO: el
# indice de `CatalogosEstaticos` indexa por NOMBRE DE ARCHIVO, asi que el id
# valido de "Pico de hierro" es `item_obj_her_002` (no el `OBJ-HER-002` que
# declara el .tres) y el de "Farol" es `item_obj_luz_005`.
#
# Residual honesto (item 122): el catalogo NO tiene un item "gancho"; su USO esta
# definido y su condicion de inventario tambien, pero sin item concreto el uso
# queda bloqueado. `residuales()` lo nombra para el dueno del catalogo de items.

class_name PuzzleHerramientas
extends RefCounted

var def: Dictionary = {}
var sala: PuzzleRoom = null
var inventario_requerido: bool = false

## tipo de herramienta -> id REAL del catalogo ("" si no hay item).
var inventario: Dictionary = {}
var usos: Array = []

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[M24] PuzzleHerramientas.cargar: no existe %s" % path)
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(crudo) != TYPE_DICTIONARY:
		push_warning("[M24] PuzzleHerramientas.cargar: %s no es un objeto JSON" % path)
		return {}
	return crudo as Dictionary

static func desde_def(d: Dictionary) -> PuzzleHerramientas:
	var ph := PuzzleHerramientas.new()
	ph._construir(d)
	return ph

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	inventario = {}
	usos = []
	var hz: Variant = d.get("herramientas", {})
	var h: Dictionary = (hz as Dictionary) if typeof(hz) == TYPE_DICTIONARY else {}
	inventario_requerido = bool(h.get("inventario_requerido", false))
	var iv: Variant = h.get("inventario", {})
	if typeof(iv) == TYPE_DICTIONARY:
		for k in (iv as Dictionary):
			inventario[str(k)] = str((iv as Dictionary)[k])
	var ul: Variant = h.get("usos", [])
	if typeof(ul) == TYPE_ARRAY:
		usos = (ul as Array).duplicate(true)

# --- Lectura de usos ------------------------------------------------------

func usos_declarados() -> Array:
	return usos.duplicate(true)

func uso(id: String) -> Dictionary:
	for u in usos:
		if typeof(u) == TYPE_DICTIONARY and str((u as Dictionary).get("id", "")) == id:
			return u as Dictionary
	return {}

func _campo_uso(id: String, campo: String, def_val: String = "") -> String:
	return str(uso(id).get(campo, def_val))

func herramienta_de(uso_id: String) -> String:
	return _campo_uso(uso_id, "herramienta")

func objetivo_de(uso_id: String) -> String:
	return _campo_uso(uso_id, "objetivo")

func emisor_de(uso_id: String) -> int:
	return int(uso(uso_id).get("emisor", -1))

## Tipos de herramienta usados por algun `uso`, sin repetir y ordenados.
func herramientas_usadas() -> Array:
	var out: Array = []
	for u in usos:
		if typeof(u) != TYPE_DICTIONARY:
			continue
		var t: String = str((u as Dictionary).get("herramienta", ""))
		if not t.is_empty() and not out.has(t):
			out.append(t)
	out.sort()
	return out

# --- Item 124: condicion de inventario presente --------------------------

func mapa_inventario() -> Dictionary:
	return inventario.duplicate()

## Id real del catalogo para un tipo de herramienta ("" si no esta mapeado).
func item_de(herramienta: String) -> String:
	return str(inventario.get(herramienta, ""))

func tiene_item_mapeado(herramienta: String) -> bool:
	return not item_de(herramienta).is_empty()

## True si el inventario (duck-typed) tiene al menos 1 del item. Un inventario
## null o sin `count_item` cuenta como vacio.
func inventario_presente(inv: Object, item_id: String) -> bool:
	if item_id.is_empty() or inv == null:
		return false
	if not inv.has_method("count_item"):
		return false
	return int(inv.call("count_item", item_id, true)) > 0

## Condicion (item 124): el uso se permite solo si la herramienta requerida esta
## presente. Sin inventario requerido, todo uso esta permitido.
func puede_usar(uso_id: String, inv: Object) -> bool:
	var u: Dictionary = uso(uso_id)
	if u.is_empty():
		return false
	if not inventario_requerido:
		return true
	var item_id: String = item_de(herramienta_de(uso_id))
	if item_id.is_empty():
		return false
	return inventario_presente(inv, item_id)

## Ejecuta el uso: activa el emisor SOLO si la condicion de inventario se cumple.
func usar(uso_id: String, inv: Object) -> bool:
	if not puede_usar(uso_id, inv):
		return false
	var e: int = emisor_de(uso_id)
	if e < 0 or sala == null:
		return false
	sala.set_emisor(e, true)
	return true

## Usos que el inventario actual permite ejecutar.
func usos_posibles(inv: Object) -> Array:
	var out: Array = []
	for u in usos:
		if typeof(u) != TYPE_DICTIONARY:
			continue
		var uid: String = str((u as Dictionary).get("id", ""))
		if puede_usar(uid, inv):
			out.append(uid)
	return out

## Tipos de herramienta usados por algun `uso` pero SIN item real en el catalogo.
## No es un error del framework: es un residuo del catalogo de items.
func residuales() -> Array:
	var out: Array = []
	for t in herramientas_usadas():
		if not tiene_item_mapeado(str(t)):
			out.append(str(t))
	return out

# --- Validacion -----------------------------------------------------------

## Valida el framework + la capa de herramientas. Devuelve [] si es coherente.
## NO consulta el catalogo de items (se mantiene puro); para eso ver `residuales()`.
func validar() -> Array:
	var errores: Array = []
	errores.append_array(PuzzleDef.validar_def(def))
	if usos.is_empty():
		errores.append("la familia de herramientas no declara usos")
	if inventario_requerido and inventario.is_empty():
		errores.append("se exige inventario pero no hay ningun item mapeado")
	var declarados: Array = PuzzleDef.ids_emisores(def)
	for u in usos:
		if typeof(u) != TYPE_DICTIONARY:
			errores.append("uso no es un objeto")
			continue
		var ud: Dictionary = u as Dictionary
		var uid: String = str(ud.get("id", ""))
		if uid.is_empty():
			errores.append("uso sin id")
		if str(ud.get("herramienta", "")).is_empty():
			errores.append("el uso '%s' no declara herramienta" % uid)
		if str(ud.get("objetivo", "")).is_empty():
			errores.append("el uso '%s' no declara objetivo" % uid)
		var e: int = int(ud.get("emisor", -1))
		if not declarados.has(e):
			errores.append("el uso '%s' usa emisor inexistente %d" % [uid, e])
	for k in inventario:
		if str(inventario[k]).is_empty():
			errores.append("la herramienta '%s' esta mapeada a un item vacio" % str(k))
	return errores
