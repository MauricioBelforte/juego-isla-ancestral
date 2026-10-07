# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 4: interprete datos-driven de la familia ESPEJOS (rotacion discreta).
#
# ENCADENA con la familia LUZ (item 52): no reimplementa el trazado, sino que
# COMPONE un `PuzzleLuz` (motor optico) y le agrega la capa de ROTACION. Asi el
# espejo rotado cambia el camino del rayo y, si llega al cristal con la
# concentracion requerida, activa la runa (receptor del framework).
#
# Mapeo item del checklist -> campo/API (03-Diseno.md, "Familia espejos"):
#   - item 49  rotacion en multiplos de 45        -> rotar(id, grados) rechaza grados % 45 != 0.
#   - item 50  caminos verificables de rayo       -> camino() + validar_camino() (contiguo, termina en el cristal).
#   - item 51  espejos fijos y moviles            -> "fijos"/"moviles" + es_fijo()/es_movil(); solo los moviles rotan.
#   - item 52  interaccion con la familia de luz  -> composicion: `luz: PuzzleLuz` (el espejo maneja el rayo de luz).
#   - item 53  feedback de direccion al rotar     -> feedback(id) = "N->S" con la salida registrada por el trazado.
#   - item 54  documentacion                      -> 03-Diseno/04-Codigo (fuera de esta clase).
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef/PuzzleLuz).

class_name PuzzleEspejos
extends RefCounted

## Paso minimo de rotacion: 45 grados (item 49).
const PASO_GRADOS := 45

var def: Dictionary = {}

## Motor optico de la familia de luz (item 52: cadena luz -> espejos).
var luz: PuzzleLuz = null

var fijos: Dictionary = {}     # id -> true
var moviles: Dictionary = {}   # id -> true

## Rotacion declarada en datos (debe ser multiplo de 45; item 49).
var rotacion_declarada: int = PASO_GRADOS

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

static func desde_def(d: Dictionary) -> PuzzleEspejos:
	var pe := PuzzleEspejos.new()
	pe._construir(d)
	return pe

func _construir(d: Dictionary) -> void:
	def = d
	luz = PuzzleLuz.desde_def(d)
	var eb: Variant = d.get("espejos", {})
	var e: Dictionary = (eb as Dictionary) if typeof(eb) == TYPE_DICTIONARY else {}
	rotacion_declarada = int(e.get("rotacion_grados", PASO_GRADOS))
	var lf: Variant = e.get("fijos", [])
	if typeof(lf) == TYPE_ARRAY:
		for x in (lf as Array):
			fijos[str(x)] = true
	var lm: Variant = e.get("moviles", [])
	if typeof(lm) == TYPE_ARRAY:
		for x in (lm as Array):
			moviles[str(x)] = true

# --- Rotacion (item 49) --------------------------------------------------

## Rota un espejo MOVIL en "grados" (debe ser multiplo de 45). Devuelve true si roto.
## Rechaza (sin rotar): espejo inexistente, espejo fijo, o grados no multiplo de 45.
func rotar(id: String, grados: int) -> bool:
	if not luz.espejos.has(id):
		return false
	if not es_movil(id):
		return false
	if grados % PASO_GRADOS != 0:
		return false
	luz.set_angulo_espejo(id, PuzzleLuz._norm_angulo(luz.angulo_espejo(id) + grados))
	return true

func es_movil(id: String) -> bool:
	return moviles.has(id)

func es_fijo(id: String) -> bool:
	return fijos.has(id)

func angulo(id: String) -> int:
	return luz.angulo_espejo(id)

# --- Caminos verificables (item 50) --------------------------------------

## Camino de celdas recorrido por el rayo en el estado actual.
func camino() -> Array:
	return luz.celdas()

## Verifica que el camino sea contiguo (cada celda adyacente a la anterior) y,
## si el rayo llega, que termine en el cristal. Devuelve [] si es verificable.
func validar_camino() -> Array:
	var errores: Array = []
	var c: Array = luz.celdas()
	if c.is_empty():
		errores.append("camino vacio")
		return errores
	for i in range(1, c.size()):
		var a: Vector2i = c[i - 1]
		var b: Vector2i = c[i]
		var d: Vector2i = b - a
		if abs(d.x) + abs(d.y) != 1:
			errores.append("paso no contiguo en el indice %d: %s -> %s" % [i, str(a), str(b)])
	if luz.llega():
		var ult: Vector2i = c[c.size() - 1]
		if ult != luz.cristal_pos:
			errores.append("el rayo llega pero no termina en el cristal (%s)" % str(ult))
	return errores

# --- Feedback de direccion (item 53) -------------------------------------

## Direccion con la que el rayo SALE de un espejo, como "entrada->salida" ("" si no lo toco).
func feedback(id: String) -> String:
	var s: Dictionary = luz.salidas()
	if not s.has(id):
		return ""
	var reg: Dictionary = s[id]
	var ent: Vector2i = reg["entrada"]
	var sal: Vector2i = reg["salida"]
	return "%s->%s" % [PuzzleLuz.nombre_dir(ent), PuzzleLuz.nombre_dir(sal)]

## Direccion de salida de un espejo (Vector2i.ZERO si no lo toco).
func direccion_salida(id: String) -> Vector2i:
	return luz.direccion_salida(id)

# --- Validacion de la capa de espejos ------------------------------------

## Valida la capa de rotacion ADEMAS de PuzzleDef.validar_def + PuzzleLuz.validar_optica.
func validar_espejos() -> Array:
	var errores: Array = []
	if rotacion_declarada % PASO_GRADOS != 0:
		errores.append("rotacion declarada %d no es multiplo de 45" % rotacion_declarada)
	if moviles.is_empty():
		errores.append("sin espejos moviles: nada que rotar")
	for id in moviles:
		if not luz.espejos.has(id):
			errores.append("espejo movil %s inexistente" % id)
	for id in fijos:
		if not luz.espejos.has(id):
			errores.append("espejo fijo %s inexistente" % id)
		if moviles.has(id):
			errores.append("espejo %s declarado fijo y movil a la vez" % id)
	return errores

# --- Accesores de la cadena con luz (item 52) ----------------------------

func receptor_activado() -> bool:
	return luz.receptor_activado()

func llega() -> bool:
	return luz.llega()

func concentracion() -> int:
	return luz.concentracion()

func sala() -> PuzzleRoom:
	return luz.sala
