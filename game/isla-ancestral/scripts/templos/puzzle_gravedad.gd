# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: interprete datos-driven de la familia GRAVEDAD Y MOVIMIENTO.
#
# Extiende el framework emisor->receptor (PuzzleDef / PuzzleRoom) con la capa de
# MOVIMIENTO: zonas con gravedad propia (burbujas), plataformas moviles que se
# sincronizan por una FASE comun, pulsos de aire y cintas transportadoras. Todo
# es aritmetica ENTERA sobre datos (determinista, sin fisica visual).
#
# Mapeo item del checklist -> campo/API (03-Diseno.md, "Familias de gravedad"):
#   - item 92  burbujas de gravedad por zona -> "burbujas" {zona, dir} + direccion_gravedad(pos).
#   - item 93  cambio de direccion           -> direccion_gravedad difiere entre celdas; cambia_direccion(a,b).
#   - item 94  plataformas sincronizadas     -> "plataformas" {grupo, amplitud, periodo} + plataforma_offset(id, fase).
#   - item 95  pulsos de aire                -> "pulsos" {periodo, duracion} + pulso_activo(id, fase).
#   - item 96  cintas transportadoras        -> "cintas" {pos, dir} + cinta_dir(id).
#   - item 97  sincronizacion con reloj M29  -> fase_desde_reloj(reloj) sobre game_clock.gd (SAFE).
#   - item 98  documentacion                 -> 03-Diseno/04-Codigo (fuera de esta clase).
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef/PuzzleLuz).

class_name PuzzleGravedad
extends RefCounted

const NORTE := Vector2i(0, -1)
const ESTE := Vector2i(1, 0)
const SUR := Vector2i(0, 1)
const OESTE := Vector2i(-1, 0)

## Gravedad por defecto (hacia abajo) si la celda no esta en ninguna burbuja.
const GRAVEDAD_DEFECTO := Vector2i(0, 1)

var def: Dictionary = {}
var sala: PuzzleRoom = null

var ancho: int = 0
var alto: int = 0

var burbujas: Array = []           # [{id, zona:[x,y,w,h], dir:Vector2i}]
var plataformas: Dictionary = {}   # id -> {pos, grupo, amplitud, periodo, emisor}
var pulsos: Dictionary = {}        # id -> {periodo, duracion}
var cintas: Dictionary = {}        # id -> {pos: Vector2i, dir: Vector2i}

var _fase: int = 0
var _ultimo: Dictionary = {}

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

static func desde_def(d: Dictionary) -> PuzzleGravedad:
	var pg := PuzzleGravedad.new()
	pg._construir(d)
	return pg

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	var gz: Variant = d.get("gravedad", {})
	var g: Dictionary = (gz as Dictionary) if typeof(gz) == TYPE_DICTIONARY else {}
	var gr: Variant = g.get("grilla", {})
	var gd: Dictionary = (gr as Dictionary) if typeof(gr) == TYPE_DICTIONARY else {}
	ancho = int(gd.get("ancho", 0))
	alto = int(gd.get("alto", 0))

	var lb: Variant = g.get("burbujas", [])
	if typeof(lb) == TYPE_ARRAY:
		for e in (lb as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var zona: Array = []
			var zr: Variant = ed.get("zona", [])
			if typeof(zr) == TYPE_ARRAY:
				for x in (zr as Array):
					zona.append(int(x))
			burbujas.append({"id": str(ed.get("id", "")), "zona": zona, "dir": _vec(ed.get("dir", []))})

	var lp: Variant = g.get("plataformas", [])
	if typeof(lp) == TYPE_ARRAY:
		for e in (lp as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			plataformas[id] = {
				"pos": _vec(ed.get("pos", [])),
				"grupo": str(ed.get("grupo", "g1")),
				"amplitud": int(ed.get("amplitud", 1)),
				"periodo": int(ed.get("periodo", 8)),
				"emisor": int(ed.get("emisor", -1)),
			}

	var lpu: Variant = g.get("pulsos", [])
	if typeof(lpu) == TYPE_ARRAY:
		for e in (lpu as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			pulsos[id] = {"periodo": int(ed.get("periodo", 4)), "duracion": int(ed.get("duracion", 1))}

	var lc: Variant = g.get("cintas", [])
	if typeof(lc) == TYPE_ARRAY:
		for e in (lc as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			cintas[id] = {"pos": _vec(ed.get("pos", [])), "dir": _vec(ed.get("dir", []))}

	_evaluar()

# --- Burbujas de gravedad (items 92 y 93) --------------------------------

## Direccion de la gravedad en una celda. La ULTIMA burbuja que contiene la
## celda gana (permite solapar zonas con prioridad de declaracion).
func direccion_gravedad(pos: Vector2i) -> Vector2i:
	var dir: Vector2i = GRAVEDAD_DEFECTO
	for b in burbujas:
		var bd: Dictionary = b
		if _zona_contiene(bd["zona"], pos):
			dir = bd["dir"]
	return dir

## True si dos celdas tienen direccion de gravedad distinta (item 93).
func cambia_direccion(a: Vector2i, b: Vector2i) -> bool:
	return direccion_gravedad(a) != direccion_gravedad(b)

func en_burbuja(pos: Vector2i) -> bool:
	for b in burbujas:
		var bd: Dictionary = b
		if _zona_contiene(bd["zona"], pos):
			return true
	return false

# --- Plataformas sincronizadas (item 94) ---------------------------------

## Desplazamiento de una plataforma en una fase dada (onda triangular, entero).
func plataforma_offset(id: String, fase: int) -> int:
	if not plataformas.has(id):
		return 0
	var p: Dictionary = plataformas[id]
	return _onda(fase, int(p["periodo"]), int(p["amplitud"]))

## True si la plataforma esta en un extremo de su recorrido en esa fase.
func plataforma_en_extremo(id: String, fase: int) -> bool:
	if not plataformas.has(id):
		return false
	var p: Dictionary = plataformas[id]
	return abs(plataforma_offset(id, fase)) == int(p["amplitud"])

## Ids de las plataformas de un grupo (sincronizadas = mismo grupo + mismo periodo).
func plataformas_de(grupo: String) -> Array:
	var out: Array = []
	for id in plataformas:
		var p: Dictionary = plataformas[id]
		if str(p["grupo"]) == grupo:
			out.append(str(id))
	return out

# --- Pulsos de aire (item 95) --------------------------------------------

## Un pulso esta ACTIVO si la fase cae dentro de su ventana [0, duracion).
func pulso_activo(id: String, fase: int) -> bool:
	if not pulsos.has(id):
		return false
	var p: Dictionary = pulsos[id]
	var periodo: int = int(p["periodo"])
	if periodo <= 0:
		return false
	return (((fase % periodo) + periodo) % periodo) < int(p["duracion"])

# --- Cintas transportadoras (item 96) ------------------------------------

func cinta_dir(id: String) -> Vector2i:
	if not cintas.has(id):
		return Vector2i.ZERO
	var c: Dictionary = cintas[id]
	return c["dir"]

## Id de la cinta que ocupa una celda ("" si ninguna).
func cinta_en(pos: Vector2i) -> String:
	for id in cintas:
		var c: Dictionary = cintas[id]
		var p: Vector2i = c["pos"]
		if p == pos:
			return str(id)
	return ""

# --- Sincronizacion con el reloj de datos M29 (item 97) ------------------

## Fase (minutos absolutos) derivada del reloj del juego M29
## (scripts/time/game_clock.gd: dia_absoluto()/get_hora()/get_minuto()).
## Duck-typed: sirve tanto el autoload real como un reloj de prueba.
## Devuelve -1 si el objeto no expone el contrato.
func fase_desde_reloj(reloj: Object) -> int:
	if reloj == null:
		return -1
	if not (reloj.has_method("dia_absoluto") and reloj.has_method("get_hora") and reloj.has_method("get_minuto")):
		return -1
	var dia: int = int(reloj.call("dia_absoluto"))
	var hora: int = int(reloj.call("get_hora"))
	var minuto: int = int(reloj.call("get_minuto"))
	return dia * 1440 + hora * 60 + minuto

# --- Avance de la simulacion ---------------------------------------------

## Avanza la fase de la sala un paso y re-evalua los emisores.
func tick() -> Dictionary:
	_fase += 1
	_evaluar()
	return _ultimo

func fase() -> int:
	return _fase

func _evaluar() -> void:
	var extremos: Array = []
	for id in plataformas:
		var pid: String = str(id)
		var p: Dictionary = plataformas[pid]
		var en_extremo: bool = abs(plataforma_offset(pid, _fase)) == int(p["amplitud"])
		if en_extremo:
			extremos.append(pid)
		var emisor: int = int(p["emisor"])
		if sala != null and emisor >= 0:
			sala.set_emisor(emisor, en_extremo)
	_ultimo = {
		"fase": _fase,
		"plataformas_en_extremo": extremos,
		"receptor_activado": receptor_activado(),
	}

func receptor_activado() -> bool:
	return sala != null and sala.estado_igual_objetivo()

# --- Validacion de la capa de gravedad -----------------------------------

## Valida la capa de movimiento ADEMAS de PuzzleDef.validar_def. Devuelve [] si OK.
func validar_gravedad() -> Array:
	var errores: Array = []
	if ancho <= 0 or alto <= 0:
		errores.append("grilla invalida (%dx%d)" % [ancho, alto])

	for b in burbujas:
		var bd: Dictionary = b
		if str(bd["id"]).is_empty():
			errores.append("burbuja sin id")
		if not _dir_valida(bd["dir"]):
			errores.append("burbuja %s: direccion %s invalida (se exige N/E/S/O)" % [str(bd["id"]), str(bd["dir"])])
		if (bd["zona"] as Array).size() != 4:
			errores.append("burbuja %s: zona invalida (se exige [x,y,w,h])" % str(bd["id"]))

	if plataformas.is_empty():
		errores.append("sin plataformas: nada que sincronizar")

	var periodos: Dictionary = {}
	for id in plataformas:
		var p: Dictionary = plataformas[id]
		if int(p["periodo"]) <= 0:
			errores.append("plataforma %s: periodo %d invalido (se exige > 0)" % [id, int(p["periodo"])])
		if int(p["amplitud"]) < 1:
			errores.append("plataforma %s: amplitud %d invalida (se exige >= 1)" % [id, int(p["amplitud"])])
		if not _dentro(p["pos"]):
			errores.append("plataforma %s: posicion %s fuera de grilla" % [id, str(p["pos"])])
		var grupo: String = str(p["grupo"])
		var periodo: int = int(p["periodo"])
		if periodos.has(grupo) and int(periodos[grupo]) != periodo:
			errores.append("grupo %s: periodos distintos (%d vs %d): no estan sincronizadas" % [grupo, int(periodos[grupo]), periodo])
		periodos[grupo] = periodo
		if sala == null or not sala.emisores.has(int(p["emisor"])):
			errores.append("plataforma %s: emisor %d inexistente en la sala" % [id, int(p["emisor"])])

	for id in pulsos:
		var p: Dictionary = pulsos[id]
		if int(p["periodo"]) <= 0:
			errores.append("pulso %s: periodo %d invalido" % [id, int(p["periodo"])])
		if int(p["duracion"]) < 1 or int(p["duracion"]) > int(p["periodo"]):
			errores.append("pulso %s: duracion %d fuera de (0, periodo]" % [id, int(p["duracion"])])

	for id in cintas:
		var c: Dictionary = cintas[id]
		if not _dir_valida(c["dir"]):
			errores.append("cinta %s: direccion %s invalida" % [id, str(c["dir"])])
		if not _dentro(c["pos"]):
			errores.append("cinta %s: posicion %s fuera de grilla" % [id, str(c["pos"])])
	return errores

# --- Helpers -------------------------------------------------------------

## Onda triangular entera en [0, amplitud] con periodo "periodo".
func _onda(fase: int, periodo: int, amplitud: int) -> int:
	if periodo <= 0:
		return 0
	var ciclo: int = ((fase % periodo) + periodo) % periodo
	var mitad: int = int(float(periodo) / 2.0)
	var k: int = ciclo if ciclo <= mitad else periodo - ciclo
	return int(float(amplitud * 2 * k) / float(periodo))

func _zona_contiene(zona: Array, pos: Vector2i) -> bool:
	if zona.size() != 4:
		return false
	var x: int = int(zona[0])
	var y: int = int(zona[1])
	var w: int = int(zona[2])
	var h: int = int(zona[3])
	return pos.x >= x and pos.x < x + w and pos.y >= y and pos.y < y + h

func _dentro(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < ancho and p.y < alto

func _dir_valida(dir: Vector2i) -> bool:
	return dir == NORTE or dir == ESTE or dir == SUR or dir == OESTE

static func _vec(v: Variant) -> Vector2i:
	if typeof(v) == TYPE_ARRAY:
		var a: Array = v as Array
		if a.size() >= 2:
			return Vector2i(int(a[0]), int(a[1]))
	return Vector2i(-1, -1)
