# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: interprete datos-driven de la familia SONIDO Y SECUENCIA.
#
# Extiende el framework emisor->receptor (PuzzleDef / PuzzleRoom) con la capa de
# SECUENCIA: campanas/gongs como emisores; el jugador los toca en un orden y el
# receptor se activa cuando la secuencia coincide con la declarada.
#
# MODELO PURO DE DATOS: esta clase NO toca `AudioServer` ni ningun nodo de audio
# (item 104). El "sonido" es un identificador de tono (dato), no una reproduccion:
# asi el puzzle es verificable en headless y no depende del hardware del jugador.
#
# Mapeo item del checklist -> campo/API (03-Diseno.md, "Familias de sonido"):
#   - item 102 campanas/gongs como emisores -> "campanas" {pos, tono, emisor} + tocar(id).
#   - item 104 sin hardware de audio        -> modelo puro (0 referencias a AudioServer); test por grep.
#   - item 105 secuencias de 3-5 simbolos   -> "secuencia" (se valida 3 <= n <= 5).
#   - item 106 pista del patron tras 2 intentos -> pista_disponible() / pista_patron().
#   - item 107 documentacion                -> 03-Diseno/04-Codigo (fuera de esta clase).
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef/PuzzleLuz).

class_name PuzzleSonido
extends RefCounted

## Intentos fallidos necesarios antes de ofrecer la pista completa (item 106).
const INTENTOS_PARA_PISTA := 2

## Rango valido del largo de la secuencia (item 105).
const LARGO_MIN := 3
const LARGO_MAX := 5

var def: Dictionary = {}
var sala: PuzzleRoom = null

var campanas: Dictionary = {}   # id -> {pos: Vector2i, tono: int, emisor: int}
var secuencia: Array = []       # ids de campanas, en orden

var _intento: Array = []
var _fallos: int = 0
var _resuelto: bool = false
var _ultimo: Dictionary = {}

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

static func desde_def(d: Dictionary) -> PuzzleSonido:
	var ps := PuzzleSonido.new()
	ps._construir(d)
	return ps

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	var sz: Variant = d.get("sonido", {})
	var s: Dictionary = (sz as Dictionary) if typeof(sz) == TYPE_DICTIONARY else {}

	var lc: Variant = s.get("campanas", [])
	if typeof(lc) == TYPE_ARRAY:
		for e in (lc as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			campanas[id] = {
				"pos": _vec(ed.get("pos", [])),
				"tono": int(ed.get("tono", 0)),
				"emisor": int(ed.get("emisor", -1)),
			}

	var ls: Variant = s.get("secuencia", [])
	if typeof(ls) == TYPE_ARRAY:
		for x in (ls as Array):
			secuencia.append(str(x))

	_evaluar()

# --- Tocar (items 102 y 105) ---------------------------------------------

## El jugador toca una campana. Devuelve {aceptado, correcto, resuelto, ...}.
## Un toque equivocado reinicia el intento y suma un fallo (alimenta la pista).
func tocar(id: String) -> Dictionary:
	if _resuelto:
		return {"aceptado": false, "correcto": false, "resuelto": true, "motivo": "ya resuelto"}
	if not campanas.has(id):
		return {"aceptado": false, "correcto": false, "resuelto": false, "motivo": "campana inexistente"}
	_intento.append(id)
	var i: int = _intento.size() - 1
	if i >= secuencia.size() or str(secuencia[i]) != id:
		_fallos += 1
		_intento = []
		_evaluar()
		return {"aceptado": true, "correcto": false, "resuelto": false, "fallos": _fallos}
	if _intento.size() == secuencia.size():
		_resuelto = true
		_evaluar()
		return {"aceptado": true, "correcto": true, "resuelto": true}
	_evaluar()
	return {"aceptado": true, "correcto": true, "resuelto": false, "progreso": _intento.size()}

## Toca la secuencia completa (atajo de test/uso: el jugador acierta).
func tocar_secuencia() -> bool:
	for x in secuencia:
		tocar(str(x))
	return _resuelto

func intento_actual() -> Array:
	return _intento.duplicate()

func intentos_fallidos() -> int:
	return _fallos

# --- Pista del patron (item 106) -----------------------------------------

func pista_disponible() -> bool:
	return _fallos >= INTENTOS_PARA_PISTA

## Patron completo si ya se fallo 2 veces; [] si todavia no (no se regala).
func pista_patron() -> Array:
	if not pista_disponible():
		return []
	return secuencia.duplicate()

# --- Evaluacion del receptor ---------------------------------------------

func _evaluar() -> void:
	for id in campanas:
		var c: Dictionary = campanas[id]
		var emisor: int = int(c["emisor"])
		if sala != null and emisor >= 0:
			sala.set_emisor(emisor, _resuelto)
	_ultimo = {
		"fallos": _fallos,
		"progreso": _intento.size(),
		"resuelto": _resuelto,
		"receptor_activado": receptor_activado(),
	}

func receptor_activado() -> bool:
	return sala != null and sala.estado_igual_objetivo()

func resuelto() -> bool:
	return _resuelto

# --- Validacion de la capa de sonido -------------------------------------

## Valida la capa de secuencia ADEMAS de PuzzleDef.validar_def. Devuelve [] si OK.
func validar_sonido() -> Array:
	var errores: Array = []
	if campanas.is_empty():
		errores.append("sin campanas: nada que tocar")
	if secuencia.size() < LARGO_MIN or secuencia.size() > LARGO_MAX:
		errores.append("secuencia de %d simbolos: se exige entre %d y %d" % [secuencia.size(), LARGO_MIN, LARGO_MAX])

	var con_emisor: int = 0
	for id in campanas:
		var c: Dictionary = campanas[id]
		if sala == null or not sala.emisores.has(int(c["emisor"])):
			errores.append("campana %s: emisor %d inexistente en la sala" % [id, int(c["emisor"])])
		else:
			con_emisor += 1
	if campanas.size() > 0 and con_emisor == 0:
		errores.append("ninguna campana tiene un emisor valido")

	for x in secuencia:
		if not campanas.has(str(x)):
			errores.append("secuencia usa campana inexistente %s" % str(x))
	return errores

# --- Helpers -------------------------------------------------------------

static func _vec(v: Variant) -> Vector2i:
	if typeof(v) == TYPE_ARRAY:
		var a: Array = v as Array
		if a.size() >= 2:
			return Vector2i(int(a[0]), int(a[1]))
	return Vector2i(-1, -1)
