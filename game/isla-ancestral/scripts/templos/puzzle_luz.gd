# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 4: interprete datos-driven de la familia LUZ (grafo optico discreto).
#
# Extiende el framework emisor->receptor (PuzzleDef / PuzzleRoom) con la capa
# OPTICA que la familia necesita: una grilla, una fuente con direccion, espejos,
# lentes, prismas, un cristal receptor y celdas de bloqueo (jugador). El rayo se
# traza PASO A PASO por celdas (validacion por DATOS, no por fisica visual): el
# resultado se decide con enteros y posiciones, no con render.
#
# Mapeo item del checklist -> campo de datos (03-Diseno.md, "Familia luz"):
#   - item 39  espejo con angulo 45 verificable  -> "angulos" 0/45/90/135 (multiplos de 45).
#   - item 40  lente que concentra el rayo       -> "lentes" con "concentracion".
#   - item 41  prisma que desvia el rayo         -> "prismas" con "desvio" (multiplos de 90).
#   - item 42  ocultacion del rayo por el jugador-> "bloqueos" (celdas) + bloquear()/desbloquear().
#   - item 43  cristal receptor que activa runa  -> "cristal" {pos, concentracion_requerida, emisor}.
#   - item 44  validacion de rayos por datos     -> trazar() + validar_optica() (sin fisica visual).
#   - item 45  documentacion                     -> 03-Diseno/04-Codigo (fuera de esta clase).
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef/PuzzleBloques).

class_name PuzzleLuz
extends RefCounted

## Direcciones en la grilla (y crece hacia abajo, como una grilla de celdas).
const NORTE := Vector2i(0, -1)
const ESTE := Vector2i(1, 0)
const SUR := Vector2i(0, 1)
const OESTE := Vector2i(-1, 0)

## Orden horario (N->E->S->O): usado por el prisma y por nombre_dir().
const ORDEN_DIR := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

## Angulos de espejo validos en la grilla (multiplos de 45, modulo 180).
const ANGULOS_ESPEJO := [0, 45, 90, 135]

## Guarda anti-bucle del trazado (una sala honesta no necesita mas).
const MAX_PASOS := 256

var def: Dictionary = {}
var sala: PuzzleRoom = null

var ancho: int = 0
var alto: int = 0

var fuente_pos: Vector2i = Vector2i(-1, -1)
var fuente_dir: Vector2i = Vector2i(0, 0)

var espejos: Dictionary = {}    # id -> {pos: Vector2i, angulo: int}
var lentes: Dictionary = {}     # id -> {pos: Vector2i, concentracion: int}
var prismas: Dictionary = {}    # id -> {pos: Vector2i, desvio: int}

var cristal_pos: Vector2i = Vector2i(-1, -1)
var cristal_requerida: int = 0
var cristal_emisor: int = -1

var bloqueos: Dictionary = {}   # celda (Vector2i) -> true (item 42)

## Resultado del ultimo trazado (lo llena _trazar()).
var _ultimo: Dictionary = {}

# --- Carga ---------------------------------------------------------------

## Carga la definicion desde un JSON (delega en PuzzleDef para un unico parser).
static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

## Construye el interprete optico desde una definicion ya cargada.
static func desde_def(d: Dictionary) -> PuzzleLuz:
	var pl := PuzzleLuz.new()
	pl._construir(d)
	return pl

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	var lz: Variant = d.get("luz", {})
	var l: Dictionary = (lz as Dictionary) if typeof(lz) == TYPE_DICTIONARY else {}
	var gr: Variant = l.get("grilla", {})
	var g: Dictionary = (gr as Dictionary) if typeof(gr) == TYPE_DICTIONARY else {}
	ancho = int(g.get("ancho", 0))
	alto = int(g.get("alto", 0))

	var f: Variant = l.get("fuente", {})
	if typeof(f) == TYPE_DICTIONARY:
		var fd: Dictionary = f as Dictionary
		fuente_pos = _vec(fd.get("pos", []))
		fuente_dir = _vec(fd.get("dir", []))

	var le: Variant = l.get("espejos", [])
	if typeof(le) == TYPE_ARRAY:
		for e in (le as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			espejos[id] = {"pos": _vec(ed.get("pos", [])), "angulo": int(ed.get("angulo", 0))}

	var ll: Variant = l.get("lentes", [])
	if typeof(ll) == TYPE_ARRAY:
		for e in (ll as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ld: Dictionary = e as Dictionary
			var id: String = str(ld.get("id", ""))
			if id.is_empty():
				continue
			lentes[id] = {"pos": _vec(ld.get("pos", [])), "concentracion": int(ld.get("concentracion", 1))}

	var lp: Variant = l.get("prismas", [])
	if typeof(lp) == TYPE_ARRAY:
		for e in (lp as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var pd: Dictionary = e as Dictionary
			var id: String = str(pd.get("id", ""))
			if id.is_empty():
				continue
			prismas[id] = {"pos": _vec(pd.get("pos", [])), "desvio": int(pd.get("desvio", 0))}

	var c: Variant = l.get("cristal", {})
	if typeof(c) == TYPE_DICTIONARY:
		var cd: Dictionary = c as Dictionary
		cristal_pos = _vec(cd.get("pos", []))
		cristal_requerida = int(cd.get("concentracion_requerida", 0))
		cristal_emisor = int(cd.get("emisor", -1))

	var bl: Variant = l.get("bloqueos", [])
	if typeof(bl) == TYPE_ARRAY:
		for b in (bl as Array):
			var celda: Vector2i = _vec(b)
			if celda.x >= 0 and celda.y >= 0:
				bloqueos[celda] = true

	trazar()

# --- Trazado (validacion por datos: item 44) -----------------------------

## Re-traza el rayo con el estado actual y devuelve el resultado.
## Claves: celdas (Array[Vector2i]), concentracion (int), llega (bool),
## receptor_activado (bool), salidas ({id_espejo: {entrada, salida}}), pasos (int).
func trazar() -> Dictionary:
	_trazar()
	return _ultimo

func _trazar() -> void:
	var celdas: Array = []
	var concentracion := 0
	var llega := false
	var salidas: Dictionary = {}
	var pos := fuente_pos
	var dir := fuente_dir
	var pasos := 0
	while pasos < MAX_PASOS:
		pasos += 1
		if not _dentro(pos):
			break
		celdas.append(pos)
		if bloqueos.has(pos):
			break
		if pos == cristal_pos:
			llega = true
			break
		var id_esp := _id_en(espejos, pos)
		if not id_esp.is_empty():
			var e: Dictionary = espejos[id_esp]
			var entrada := dir
			dir = _reflexion(dir, int(e.get("angulo", 0)))
			# Solo la PRIMERA interaccion: es el feedback de direccion estable (item 53).
			# Si el rayo vuelve a pasar por el mismo espejo (bucle), no se pisa.
			if not salidas.has(id_esp):
				salidas[id_esp] = {"entrada": entrada, "salida": dir}
			pos = pos + dir
			continue
		var id_len := _id_en(lentes, pos)
		if not id_len.is_empty():
			concentracion += int((lentes[id_len] as Dictionary).get("concentracion", 1))
			pos = pos + dir
			continue
		var id_pri := _id_en(prismas, pos)
		if not id_pri.is_empty():
			dir = _desviar(dir, int((prismas[id_pri] as Dictionary).get("desvio", 0)))
			pos = pos + dir
			continue
		pos = pos + dir
	_ultimo = {
		"celdas": celdas,
		"concentracion": concentracion,
		"llega": llega,
		"receptor_activado": llega and concentracion >= cristal_requerida,
		"salidas": salidas,
		"pasos": pasos,
	}
	if sala != null and cristal_emisor >= 0:
		sala.set_emisor(cristal_emisor, bool(_ultimo["receptor_activado"]))

# --- Accesores del ultimo trazado ---------------------------------------

func celdas() -> Array:
	var c: Variant = _ultimo.get("celdas", [])
	return (c as Array).duplicate() if typeof(c) == TYPE_ARRAY else []

func concentracion() -> int:
	return int(_ultimo.get("concentracion", 0))

func llega() -> bool:
	return bool(_ultimo.get("llega", false))

func receptor_activado() -> bool:
	return bool(_ultimo.get("receptor_activado", false))

func pasos() -> int:
	return int(_ultimo.get("pasos", 0))

## Salidas registradas por espejo: {id: {entrada: Vector2i, salida: Vector2i}}.
func salidas() -> Dictionary:
	var s: Variant = _ultimo.get("salidas", {})
	return (s as Dictionary) if typeof(s) == TYPE_DICTIONARY else {}

## Direccion con la que el rayo SALE de un espejo (Vector2i.ZERO si no lo toco).
func direccion_salida(id_espejo: String) -> Vector2i:
	var s: Dictionary = salidas()
	if not s.has(id_espejo):
		return Vector2i.ZERO
	var reg: Dictionary = s[id_espejo]
	var v: Vector2i = reg["salida"]
	return v

## Angulo actual de un espejo (lo lee la familia espejos para rotar).
func angulo_espejo(id: String) -> int:
	if not espejos.has(id):
		return 0
	var e: Dictionary = espejos[id]
	return int(e["angulo"])

## Fija el angulo de un espejo (uso interno / familia espejos) y re-traza.
func set_angulo_espejo(id: String, angulo: int) -> void:
	if not espejos.has(id):
		return
	var e: Dictionary = espejos[id]
	e["angulo"] = angulo
	trazar()

# --- Ocultacion del rayo por el jugador (item 42) ------------------------

## El jugador bloquea una celda: el rayo se detiene al entrar en ella.
func bloquear(celda: Vector2i) -> void:
	bloqueos[celda] = true
	trazar()

func desbloquear(celda: Vector2i) -> void:
	bloqueos.erase(celda)
	trazar()

func esta_bloqueada(celda: Vector2i) -> bool:
	return bloqueos.has(celda)

# --- Validacion optica (item 44: por datos, no fisica visual) ------------

## Valida la capa optica ADEMAS de PuzzleDef.validar_def. Devuelve [] si OK.
func validar_optica() -> Array:
	var errores: Array = []
	if ancho <= 0 or alto <= 0:
		errores.append("grilla invalida (%dx%d)" % [ancho, alto])
	if not _dentro(fuente_pos):
		errores.append("fuente fuera de la grilla (%s)" % str(fuente_pos))
	if ORDEN_DIR.find(fuente_dir) < 0:
		errores.append("direccion de fuente invalida %s (se exige N/E/S/O)" % str(fuente_dir))
	if not _dentro(cristal_pos):
		errores.append("cristal receptor fuera de la grilla (%s)" % str(cristal_pos))
	if cristal_emisor < 0 or sala == null or not sala.emisores.has(cristal_emisor):
		errores.append("cristal: emisor %d inexistente en la sala" % cristal_emisor)

	var ocupadas: Dictionary = {}
	if _dentro(fuente_pos):
		ocupadas[fuente_pos] = "fuente"
	if _dentro(cristal_pos):
		ocupadas[cristal_pos] = "cristal"

	for id in espejos:
		var e: Dictionary = espejos[id]
		var pos: Vector2i = e["pos"]
		var angulo: int = int(e["angulo"])
		if angulo % 45 != 0:
			errores.append("espejo %s: angulo %d no es multiplo de 45" % [id, angulo])
		elif not ANGULOS_ESPEJO.has(_norm_angulo(angulo)):
			errores.append("espejo %s: angulo %d invalido en la grilla (se exige 0/45/90/135)" % [id, angulo])
		errores.append_array(_validar_celda(id, "espejo", pos, ocupadas))

	for id in lentes:
		var e: Dictionary = lentes[id]
		var pos: Vector2i = e["pos"]
		if int(e.get("concentracion", 1)) < 1:
			errores.append("lente %s: concentracion %d invalida (se exige >= 1)" % [id, int(e.get("concentracion", 1))])
		errores.append_array(_validar_celda(id, "lente", pos, ocupadas))

	for id in prismas:
		var e: Dictionary = prismas[id]
		var pos: Vector2i = e["pos"]
		var desvio: int = int(e["desvio"])
		if desvio % 90 != 0:
			errores.append("prisma %s: desvio %d no es multiplo de 90 (no permanece en la grilla)" % [id, desvio])
		errores.append_array(_validar_celda(id, "prisma", pos, ocupadas))

	if espejos.is_empty() and lentes.is_empty() and prismas.is_empty():
		errores.append("sin elementos opticos: el rayo no se puede dirigir")
	return errores

func _validar_celda(id: String, tipo: String, pos: Vector2i, ocupadas: Dictionary) -> Array:
	var errores: Array = []
	if not _dentro(pos):
		errores.append("%s %s: posicion %s fuera de grilla" % [tipo, id, str(pos)])
		return errores
	if ocupadas.has(pos):
		errores.append("%s %s: celda %s ya ocupada por %s" % [tipo, id, str(pos), str(ocupadas[pos])])
	else:
		ocupadas[pos] = "%s %s" % [tipo, id]
	return errores

# --- Helpers -------------------------------------------------------------

func _dentro(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < ancho and p.y < alto

func _id_en(d: Dictionary, pos: Vector2i) -> String:
	for id in d:
		var e: Dictionary = d[id]
		var p: Vector2i = e["pos"]
		if p == pos:
			return str(id)
	return ""

## Reflexion del espejo segun su angulo (multiplos de 45, modulo 180).
##   0   (horizontal "_"): invierte la componente vertical  (N<->S)
##   90  (vertical   "|"): invierte la componente horizontal (E<->O)
##   45  ("/"): N<->E, S<->O
##   135 ("\"): E<->S, N<->O
func _reflexion(dir: Vector2i, angulo: int) -> Vector2i:
	match _norm_angulo(angulo):
		0:
			return Vector2i(dir.x, -dir.y)
		90:
			return Vector2i(-dir.x, dir.y)
		45:
			return Vector2i(-dir.y, -dir.x)
		135:
			return Vector2i(dir.y, dir.x)
	return dir

## Desvia la direccion girando en sentido horario "grados" (multiplos de 90).
func _desviar(dir: Vector2i, grados: int) -> Vector2i:
	var idx := ORDEN_DIR.find(dir)
	if idx < 0:
		return dir
	var pasos := int(grados / 90)
	var n := ORDEN_DIR.size()
	return ORDEN_DIR[((idx + pasos) % n + n) % n]

## Normaliza un angulo a [0, 180) (un espejo es simetrico a 180 grados).
static func _norm_angulo(a: int) -> int:
	return ((a % 180) + 180) % 180

## Nombre corto de una direccion ("N"/"E"/"S"/"O", "?" si no es una cardinal).
static func nombre_dir(dir: Vector2i) -> String:
	if dir == NORTE:
		return "N"
	if dir == ESTE:
		return "E"
	if dir == SUR:
		return "S"
	if dir == OESTE:
		return "O"
	return "?"

static func _vec(v: Variant) -> Vector2i:
	if typeof(v) == TYPE_ARRAY:
		var a: Array = v as Array
		if a.size() >= 2:
			return Vector2i(int(a[0]), int(a[1]))
	return Vector2i(-1, -1)
