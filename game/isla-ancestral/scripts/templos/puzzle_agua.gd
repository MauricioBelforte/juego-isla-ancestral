# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: interprete datos-driven de la familia AGUA (niveles graduales).
#
# Extiende el framework emisor->receptor (PuzzleDef / PuzzleRoom) con la capa
# HIDRAULICA: fuentes que alimentan el nivel de una celda, compuertas que abren
# al superar un umbral y barcas que cruzan cuando el nivel alcanza su umbral.
# El nivel es un ENTERO por celda (validacion por DATOS, no por fisica visual).
#
# Mapeo item del checklist -> campo/API (03-Diseno.md, "Familia agua"):
#   - item 58  compuertas con niveles de agua -> "compuertas" {pos, umbral, emisor} + compuerta_abierta(id).
#   - item 59  fuente que alimenta el nivel   -> "fuentes" {pos, caudal, max} + tick() (gradual).
#   - item 60  barca flotante que cruza       -> "barcas" {pos, umbral, destino, emisor} + barca_en_destino(id).
#   - item 61  altura de agua verificable     -> altura(celda) / alturas() (enteros, determinista).
#   - item 62  relleno/drenaje gradual        -> tick() suma EXACTAMENTE caudal; drenar() resta 1 (sin snaps).
#   - item 63  documentacion                  -> 03-Diseno/04-Codigo (fuera de esta clase).
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef/PuzzleLuz).

class_name PuzzleAgua
extends RefCounted

## Tope de nivel por celda si la fuente no declara "max".
const NIVEL_MAX_DEFECTO := 100

var def: Dictionary = {}
var sala: PuzzleRoom = null

var ancho: int = 0
var alto: int = 0

var fuentes: Dictionary = {}      # id -> {pos: Vector2i, caudal: int, max: int}
var compuertas: Dictionary = {}   # id -> {pos: Vector2i, umbral: int, emisor: int}
var barcas: Dictionary = {}       # id -> {pos: Vector2i, umbral: int, destino: Vector2i, emisor: int}

var niveles: Dictionary = {}           # Vector2i -> int
var barcas_cruzadas: Dictionary = {}   # id -> true (una vez cruzada, queda)

var _ticks: int = 0
var _ultimo: Dictionary = {}

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

static func desde_def(d: Dictionary) -> PuzzleAgua:
	var pa := PuzzleAgua.new()
	pa._construir(d)
	return pa

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	var az: Variant = d.get("agua", {})
	var a: Dictionary = (az as Dictionary) if typeof(az) == TYPE_DICTIONARY else {}
	var gr: Variant = a.get("grilla", {})
	var g: Dictionary = (gr as Dictionary) if typeof(gr) == TYPE_DICTIONARY else {}
	ancho = int(g.get("ancho", 0))
	alto = int(g.get("alto", 0))

	var lf: Variant = a.get("fuentes", [])
	if typeof(lf) == TYPE_ARRAY:
		for e in (lf as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			fuentes[id] = {
				"pos": _vec(ed.get("pos", [])),
				"caudal": int(ed.get("caudal", 1)),
				"max": int(ed.get("max", NIVEL_MAX_DEFECTO)),
			}

	var lc: Variant = a.get("compuertas", [])
	if typeof(lc) == TYPE_ARRAY:
		for e in (lc as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			compuertas[id] = {
				"pos": _vec(ed.get("pos", [])),
				"umbral": int(ed.get("umbral", 1)),
				"emisor": int(ed.get("emisor", -1)),
			}

	var lb: Variant = a.get("barcas", [])
	if typeof(lb) == TYPE_ARRAY:
		for e in (lb as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			barcas[id] = {
				"pos": _vec(ed.get("pos", [])),
				"umbral": int(ed.get("umbral", 1)),
				"destino": _vec(ed.get("destino", [])),
				"emisor": int(ed.get("emisor", -1)),
			}

	_evaluar()

# --- Simulacion (items 59 y 62: gradual, sin snaps) ----------------------

## Un paso de simulacion: cada fuente aporta EXACTAMENTE su caudal a su celda.
## El nivel NO salta al objetivo: sube "caudal" por tick (item 62).
func tick() -> Dictionary:
	_ticks += 1
	for id in fuentes:
		var f: Dictionary = fuentes[id]
		var pos: Vector2i = f["pos"]
		_sumar(pos, int(f["caudal"]), int(f["max"]))
	_evaluar()
	return _ultimo

## Un paso de drenaje: cada celda con agua baja EXACTAMENTE 1 nivel (item 62).
func drenar() -> Dictionary:
	for celda in niveles.keys():
		var n: int = int(niveles[celda])
		if n > 0:
			niveles[celda] = n - 1
	_evaluar()
	return _ultimo

func ticks() -> int:
	return _ticks

func _sumar(celda: Vector2i, cantidad: int, tope: int) -> void:
	var actual: int = int(niveles.get(celda, 0))
	niveles[celda] = min(actual + cantidad, tope)

func _evaluar() -> void:
	var abiertas: Array = []
	for id in compuertas:
		var c: Dictionary = compuertas[id]
		var pos: Vector2i = c["pos"]
		var abierta: bool = altura(pos) >= int(c["umbral"])
		if abierta:
			abiertas.append(str(id))
		if sala != null and int(c["emisor"]) >= 0:
			sala.set_emisor(int(c["emisor"]), abierta)

	var cruzadas: Array = []
	for id in barcas:
		var b: Dictionary = barcas[id]
		var pos: Vector2i = b["pos"]
		if altura(pos) >= int(b["umbral"]):
			barcas_cruzadas[str(id)] = true
		var cruzada: bool = barcas_cruzadas.has(str(id))
		if cruzada:
			cruzadas.append(str(id))
		if sala != null and int(b["emisor"]) >= 0:
			sala.set_emisor(int(b["emisor"]), cruzada)

	_ultimo = {
		"ticks": _ticks,
		"compuertas_abiertas": abiertas,
		"barcas_cruzadas": cruzadas,
		"receptor_activado": receptor_activado(),
	}

# --- Accesores (item 61: altura verificable por datos) -------------------

## Altura (nivel) de agua de una celda. 0 si la celda nunca recibio agua.
func altura(celda: Vector2i) -> int:
	return int(niveles.get(celda, 0))

## Copia de todos los niveles medidos (celda -> int).
func alturas() -> Dictionary:
	return niveles.duplicate()

func compuerta_abierta(id: String) -> bool:
	if not compuertas.has(id):
		return false
	var c: Dictionary = compuertas[id]
	var pos: Vector2i = c["pos"]
	return altura(pos) >= int(c["umbral"])

func barca_en_destino(id: String) -> bool:
	return barcas_cruzadas.has(id)

func receptor_activado() -> bool:
	return sala != null and sala.estado_igual_objetivo()

func compuertas_abiertas() -> Array:
	var out: Array = []
	for id in compuertas:
		if compuerta_abierta(str(id)):
			out.append(str(id))
	return out

# --- Validacion de la capa de agua ---------------------------------------

## Valida la capa hidraulica ADEMAS de PuzzleDef.validar_def. Devuelve [] si OK.
func validar_agua() -> Array:
	var errores: Array = []
	if ancho <= 0 or alto <= 0:
		errores.append("grilla invalida (%dx%d)" % [ancho, alto])
	if fuentes.is_empty():
		errores.append("sin fuentes: el nivel nunca sube")
	if compuertas.is_empty():
		errores.append("sin compuertas: nada que abrir")

	for id in fuentes:
		var f: Dictionary = fuentes[id]
		var pos: Vector2i = f["pos"]
		if not _dentro(pos):
			errores.append("fuente %s: posicion %s fuera de grilla" % [id, str(pos)])
		if int(f["caudal"]) < 1:
			errores.append("fuente %s: caudal %d invalido (se exige >= 1)" % [id, int(f["caudal"])])
		if int(f["max"]) < int(f["caudal"]):
			errores.append("fuente %s: max %d < caudal %d (nunca sube)" % [id, int(f["max"]), int(f["caudal"])])

	for id in compuertas:
		var c: Dictionary = compuertas[id]
		var pos: Vector2i = c["pos"]
		if not _dentro(pos):
			errores.append("compuerta %s: posicion %s fuera de grilla" % [id, str(pos)])
		if int(c["umbral"]) < 1:
			errores.append("compuerta %s: umbral %d invalido (se exige >= 1)" % [id, int(c["umbral"])])
		if sala == null or not sala.emisores.has(int(c["emisor"])):
			errores.append("compuerta %s: emisor %d inexistente en la sala" % [id, int(c["emisor"])])

	for id in barcas:
		var b: Dictionary = barcas[id]
		var pos: Vector2i = b["pos"]
		var destino: Vector2i = b["destino"]
		if not _dentro(pos):
			errores.append("barca %s: posicion %s fuera de grilla" % [id, str(pos)])
		if not _dentro(destino):
			errores.append("barca %s: destino %s fuera de grilla" % [id, str(destino)])
		if pos == destino:
			errores.append("barca %s: destino == posicion inicial (no cruza)" % id)
		if int(b["umbral"]) < 1:
			errores.append("barca %s: umbral %d invalido (se exige >= 1)" % [id, int(b["umbral"])])
		if sala == null or not sala.emisores.has(int(b["emisor"])):
			errores.append("barca %s: emisor %d inexistente en la sala" % [id, int(b["emisor"])])
	return errores

# --- Helpers -------------------------------------------------------------

func _dentro(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < ancho and p.y < alto

static func _vec(v: Variant) -> Vector2i:
	if typeof(v) == TYPE_ARRAY:
		var a: Array = v as Array
		if a.size() >= 2:
			return Vector2i(int(a[0]), int(a[1]))
	return Vector2i(-1, -1)
