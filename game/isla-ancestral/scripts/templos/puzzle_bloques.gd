# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 3: interprete datos-driven de la familia BLOQUES (push/pull).
#
# Extiende el framework emisor->receptor (PuzzleDef / PuzzleRoom) con la capa
# ESPACIAL que la familia necesita: una grilla, piezas empujables con UN eje
# permitido, ranuras de destino y limites de sala. Cada pieza cuya posicion
# coincide con su ranura enciende su emisor; cuando el estado de la sala S
# coincide con el objetivo T, el receptor (puente desplegable) se activa.
#
# Mapeo item del checklist -> campo de datos (03-Diseno.md, "Familia bloques"):
#   - item 84  push/pull con restriccion de 1 eje  -> "eje" por pieza (x|y).
#   - item 85  ranuras de destino                  -> "ranura" por pieza.
#   - item 86  puentes desplegables                -> receptor del puzzle.
#   - item 87  sin empuje a otras salas (limites)  -> "limites" de la sala.
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef).

class_name PuzzleBloques
extends RefCounted

## Ejes de movimiento permitidos. Una pieza declara UNO solo (item 84).
const EJES_VALIDOS := ["x", "y"]

## Definicion cruda del puzzle (esquema {emisores, reglas, objetivo} + "bloques").
var def: Dictionary = {}

## Sala del framework (PuzzleRoom) construida desde la misma definicion.
var sala: PuzzleRoom = null

## Grilla de la sala (celdas), origen arriba-izquierda.
var ancho: int = 0
var alto: int = 0

## Limites declarados de la sala (item 87).
var limites: Dictionary = {}

## Piezas: id -> {pos: Vector2i, eje: String, ranura: Vector2i, emisor: int}.
var piezas: Dictionary = {}

var _puente_activo: bool = false

# --- Carga ---------------------------------------------------------------

## Carga la definicion desde un JSON (delega en PuzzleDef para un unico parser).
static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

## Construye el interprete espacial desde una definicion ya cargada.
static func desde_def(d: Dictionary) -> PuzzleBloques:
	var pb := PuzzleBloques.new()
	pb._construir(d)
	return pb

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	var bl: Variant = d.get("bloques", {})
	var b: Dictionary = (bl as Dictionary) if typeof(bl) == TYPE_DICTIONARY else {}
	var gr: Variant = b.get("grilla", {})
	var g: Dictionary = (gr as Dictionary) if typeof(gr) == TYPE_DICTIONARY else {}
	ancho = int(g.get("ancho", 0))
	alto = int(g.get("alto", 0))
	var lim: Variant = b.get("limites", {})
	limites = (lim as Dictionary) if typeof(lim) == TYPE_DICTIONARY else {}
	var lista: Variant = b.get("piezas", [])
	if typeof(lista) == TYPE_ARRAY:
		for p in (lista as Array):
			if typeof(p) != TYPE_DICTIONARY:
				continue
			var pd: Dictionary = p as Dictionary
			var id: String = str(pd.get("id", ""))
			if id.is_empty():
				continue
			piezas[id] = {
				"pos": _vec(pd.get("pos", [])),
				"eje": str(pd.get("eje", "")),
				"ranura": _vec(pd.get("ranura", [])),
				"emisor": int(pd.get("emisor", -1)),
			}
	_sincronizar_emisores()

# --- Movimiento (push/pull) ----------------------------------------------

## Intenta mover una pieza un paso (dx,dy). Devuelve true solo si se movio.
## Rechaza (devuelve false, sin mover):
##   - direccion no ortogonal o nula;
##   - eje NO permitido para la pieza (item 84);
##   - destino fuera de la grilla (item 87: sin empuje a otras salas);
##   - destino ocupado por otra pieza (item 87).
func empujar(pieza_id: String, dx: int, dy: int) -> bool:
	if not piezas.has(pieza_id):
		return false
	if abs(dx) + abs(dy) != 1:
		return false
	var p: Dictionary = piezas[pieza_id]
	var eje: String = str(p.get("eje", ""))
	if not _eje_permite(eje, dx, dy):
		return false
	var pos: Vector2i = p["pos"]
	var destino := pos + Vector2i(dx, dy)
	if not _dentro(destino):
		return false
	if _ocupada(destino, pieza_id):
		return false
	p["pos"] = destino
	piezas[pieza_id] = p
	_sincronizar_emisores()
	return true

## Eje declarado de una pieza ("" si no existe).
func eje_de(pieza_id: String) -> String:
	if not piezas.has(pieza_id):
		return ""
	return str(piezas[pieza_id].get("eje", ""))

## Posicion actual de una pieza (Vector2i(-1,-1) si no existe).
func posicion(pieza_id: String) -> Vector2i:
	if not piezas.has(pieza_id):
		return Vector2i(-1, -1)
	var p: Dictionary = piezas[pieza_id]
	return p["pos"]

## Ranura de destino declarada de una pieza.
func ranura_de(pieza_id: String) -> Vector2i:
	if not piezas.has(pieza_id):
		return Vector2i(-1, -1)
	var p: Dictionary = piezas[pieza_id]
	return p["ranura"]

## Cuantas piezas estan sobre su ranura.
func ranuras_ocupadas() -> int:
	var n := 0
	for id in piezas:
		var p: Dictionary = piezas[id]
		var pos: Vector2i = p["pos"]
		var ranura: Vector2i = p["ranura"]
		if pos == ranura:
			n += 1
	return n

## True si todas las ranuras estan ocupadas (el puente se arma).
func puente_activo() -> bool:
	return _puente_activo

# --- Validacion de la capa espacial --------------------------------------

## Valida la capa espacial ADEMAS de PuzzleDef.validar_def. Devuelve [] si OK.
func validar_espacial() -> Array:
	var errores: Array = []
	if ancho <= 0 or alto <= 0:
		errores.append("grilla invalida (%dx%d)" % [ancho, alto])
	if piezas.is_empty():
		errores.append("sin piezas declaradas")
	var emisores_vistos: Dictionary = {}
	for id in piezas:
		var p: Dictionary = piezas[id]
		var eje: String = str(p.get("eje", ""))
		if not EJES_VALIDOS.has(eje):
			errores.append("pieza %s: eje '%s' no permitido (se exige 1 eje: x o y)" % [id, eje])
		var pos: Vector2i = p["pos"]
		var ranura: Vector2i = p["ranura"]
		if not _dentro(pos):
			errores.append("pieza %s: posicion inicial %s fuera de grilla" % [id, str(pos)])
		if not _dentro(ranura):
			errores.append("pieza %s: ranura de destino %s fuera de grilla" % [id, str(ranura)])
		var emisor: int = int(p.get("emisor", -1))
		if emisor < 0 or sala == null or not sala.emisores.has(emisor):
			errores.append("pieza %s: emisor %d inexistente en la sala" % [id, emisor])
		elif emisores_vistos.has(emisor):
			errores.append("pieza %s: emisor %d ya asignado a otra pieza" % [id, emisor])
		else:
			emisores_vistos[emisor] = true
	if not limites.has("salir_de_grilla"):
		errores.append("limites: falta declarar 'salir_de_grilla' (item 87)")
	elif bool(limites["salir_de_grilla"]):
		errores.append("limites: 'salir_de_grilla' debe ser false (sin empuje a otras salas)")
	if not limites.has("salas_adyacentes"):
		errores.append("limites: falta declarar 'salas_adyacentes' (item 87)")
	elif bool(limites["salas_adyacentes"]):
		errores.append("limites: 'salas_adyacentes' debe ser false (sin empuje a otras salas)")
	return errores

# --- Helpers privados ----------------------------------------------------

func _eje_permite(eje: String, dx: int, dy: int) -> bool:
	if eje == "x":
		return dy == 0 and dx != 0
	if eje == "y":
		return dx == 0 and dy != 0
	return false

func _dentro(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < ancho and p.y < alto

func _ocupada(p: Vector2i, excepto: String) -> bool:
	for id in piezas:
		if str(id) == excepto:
			continue
		var q: Dictionary = piezas[id]
		var qpos: Vector2i = q["pos"]
		if qpos == p:
			return true
	return false

## Empuja el estado de las ranuras a los emisores de la sala y recalcula el puente.
func _sincronizar_emisores() -> void:
	if sala == null:
		return
	for id in piezas:
		var p: Dictionary = piezas[id]
		var emisor: int = int(p.get("emisor", -1))
		if emisor < 0:
			continue
		var pos: Vector2i = p["pos"]
		var ranura: Vector2i = p["ranura"]
		sala.set_emisor(emisor, pos == ranura)
	_puente_activo = sala.estado_igual_objetivo()

static func _vec(v: Variant) -> Vector2i:
	if typeof(v) == TYPE_ARRAY:
		var a: Array = v as Array
		if a.size() >= 2:
			return Vector2i(int(a[0]), int(a[1]))
	return Vector2i(-1, -1)
