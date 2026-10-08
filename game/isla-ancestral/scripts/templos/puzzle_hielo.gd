# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: interprete datos-driven de la familia HIELO (deslizamiento).
#
# Extiende el framework emisor->receptor (PuzzleDef / PuzzleRoom) con la capa de
# DESLIZAMIENTO: un bloque empujado en una direccion se desliza hasta chocar con
# una pared, el borde, otro bloque o caer en un hueco. Todo se decide por DATOS
# (grilla de enteros), no por fisica visual.
#
# Mapeo item del checklist -> campo/API (03-Diseno.md, "Familia hielo"):
#   - item 67  deslizamiento de bloques    -> deslizar(id, dir): se desliza hasta chocar.
#   - item 68  patrones simetricos (Editor)-> validar_simetria() data-driven (no hay EditorPlugin).
#   - item 69  colisiones paredes y huecos -> "paredes" detienen; "huecos" consumen (el bloque cae).
#   - item 70  pedazos de hielo opcionales -> "pedazos" {pos, usos}: se agrietan y se rompen (variante).
#   - item 71  documentacion               -> 03-Diseno/04-Codigo (fuera de esta clase).
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef/PuzzleLuz).

class_name PuzzleHielo
extends RefCounted

## Direcciones cardinales (mismo convenio que PuzzleLuz: y crece hacia abajo).
const NORTE := Vector2i(0, -1)
const ESTE := Vector2i(1, 0)
const SUR := Vector2i(0, 1)
const OESTE := Vector2i(-1, 0)

## Guarda anti-bucle del deslizamiento.
const MAX_PASOS := 64

var def: Dictionary = {}
var sala: PuzzleRoom = null

var ancho: int = 0
var alto: int = 0

var paredes: Dictionary = {}   # Vector2i -> true
var huecos: Dictionary = {}    # Vector2i -> true
var bloques: Dictionary = {}   # id -> {pos: Vector2i, emisor: int}
var pedazos: Dictionary = {}   # Vector2i -> {usos: int}  (hielo agrietado, item 70)

var simetria: String = "x"     # "x" | "y" | "ambos" (item 68)

var _caidos: Dictionary = {}   # id -> true (el bloque cayo en un hueco)
var _emisores: Dictionary = {} # id -> emisor (se conserva aunque el bloque caiga)
var _ultimo: Dictionary = {}

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

static func desde_def(d: Dictionary) -> PuzzleHielo:
	var ph := PuzzleHielo.new()
	ph._construir(d)
	return ph

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	var hz: Variant = d.get("hielo", {})
	var h: Dictionary = (hz as Dictionary) if typeof(hz) == TYPE_DICTIONARY else {}
	var gr: Variant = h.get("grilla", {})
	var g: Dictionary = (gr as Dictionary) if typeof(gr) == TYPE_DICTIONARY else {}
	ancho = int(g.get("ancho", 0))
	alto = int(g.get("alto", 0))
	simetria = str(h.get("simetria", "x"))

	var lp: Variant = h.get("paredes", [])
	if typeof(lp) == TYPE_ARRAY:
		for p in (lp as Array):
			var celda: Vector2i = _vec(p)
			if _dentro(celda):
				paredes[celda] = true

	var lh: Variant = h.get("huecos", [])
	if typeof(lh) == TYPE_ARRAY:
		for p in (lh as Array):
			var celda: Vector2i = _vec(p)
			if _dentro(celda):
				huecos[celda] = true

	var lb: Variant = h.get("bloques", [])
	if typeof(lb) == TYPE_ARRAY:
		for e in (lb as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var id: String = str(ed.get("id", ""))
			if id.is_empty():
				continue
			bloques[id] = {"pos": _vec(ed.get("pos", [])), "emisor": int(ed.get("emisor", -1))}
			_emisores[id] = int(ed.get("emisor", -1))

	var lpd: Variant = h.get("pedazos", [])
	if typeof(lpd) == TYPE_ARRAY:
		for e in (lpd as Array):
			if typeof(e) != TYPE_DICTIONARY:
				continue
			var ed: Dictionary = e as Dictionary
			var celda: Vector2i = _vec(ed.get("pos", []))
			if _dentro(celda):
				pedazos[celda] = {"usos": int(ed.get("usos", 1))}

	_evaluar()

# --- Deslizamiento (items 67 y 69) ---------------------------------------

## Empuja el bloque "id" en "dir". Se desliza hasta chocar con el borde, una
## pared o otro bloque; si entra en un hueco, CAE (se elimina del tablero).
## Devuelve true si el bloque se movio (o cayo).
func deslizar(id: String, dir: Vector2i) -> bool:
	if not bloques.has(id):
		return false
	if not _dir_valida(dir):
		return false
	var b: Dictionary = bloques[id]
	var pos: Vector2i = b["pos"]
	var pasos := 0
	var cayo := false
	while pasos < MAX_PASOS:
		var sig: Vector2i = pos + dir
		if not _dentro(sig):
			break
		if paredes.has(sig):
			break
		if not _bloque_en(sig).is_empty():
			break
		pos = sig
		pasos += 1
		# Un hueco PRE-EXISTENTE consume el bloque; un pedazo agrietado se rompe
		# DESPUES (deja un hueco para el proximo bloque, no para este).
		if huecos.has(pos):
			cayo = true
			break
		_desgastar_pedazo(pos)
	if cayo:
		_caidos[id] = true
		bloques.erase(id)
	else:
		b["pos"] = pos
	_evaluar()
	return pasos > 0

func pos_de(id: String) -> Vector2i:
	if not bloques.has(id):
		return Vector2i(-1, -1)
	var b: Dictionary = bloques[id]
	return b["pos"]

func cayo_en_hueco(id: String) -> bool:
	return _caidos.has(id)

func bloque_activo(id: String) -> bool:
	return bloques.has(id)

## Un pedazo de hielo agrietado pierde un uso al ser pisado; al llegar a 0 se
## rompe y la celda pasa a ser un hueco (item 70: variante opcional).
func _desgastar_pedazo(celda: Vector2i) -> void:
	if not pedazos.has(celda):
		return
	var p: Dictionary = pedazos[celda]
	var usos: int = int(p["usos"]) - 1
	p["usos"] = usos
	if usos <= 0:
		pedazos.erase(celda)
		huecos[celda] = true

func usos_pedazo(celda: Vector2i) -> int:
	if not pedazos.has(celda):
		return -1
	var p: Dictionary = pedazos[celda]
	return int(p["usos"])

func es_hueco(celda: Vector2i) -> bool:
	return huecos.has(celda)

func es_pared(celda: Vector2i) -> bool:
	return paredes.has(celda)

# --- Simetria data-driven (item 68) --------------------------------------

## Verifica que el tablero (paredes + huecos) sea simetrico respecto de los ejes
## declarados en "simetria". Devuelve [] si es simetrico. Data-driven: NO depende
## de un EditorPlugin (no existe en el proyecto).
func validar_simetria() -> Array:
	var errores: Array = []
	if simetria != "x" and simetria != "y" and simetria != "ambos":
		errores.append("simetria declarada '%s' invalida (se exige x|y|ambos)" % simetria)
		return errores
	if simetria == "x" or simetria == "ambos":
		errores.append_array(_simetria_eje("x"))
	if simetria == "y" or simetria == "ambos":
		errores.append_array(_simetria_eje("y"))
	return errores

func _simetria_eje(eje: String) -> Array:
	var errores: Array = []
	for celda in paredes:
		var p: Vector2i = celda
		var q: Vector2i = _espejo(p, eje)
		if not paredes.has(q):
			errores.append("pared %s sin reflejo %s (eje %s)" % [str(p), str(q), eje])
	for celda in huecos:
		var p: Vector2i = celda
		var q: Vector2i = _espejo(p, eje)
		if not huecos.has(q):
			errores.append("hueco %s sin reflejo %s (eje %s)" % [str(p), str(q), eje])
	return errores

func _espejo(p: Vector2i, eje: String) -> Vector2i:
	if eje == "x":
		return Vector2i(ancho - 1 - p.x, p.y)
	return Vector2i(p.x, alto - 1 - p.y)

# --- Evaluacion del receptor ---------------------------------------------

func _evaluar() -> void:
	var en_destino: Array = []
	for id in bloques:
		var b: Dictionary = bloques[id]
		var pos: Vector2i = b["pos"]
		var emisor: int = int(b["emisor"])
		# El emisor esta ON si el bloque NO esta en su celda inicial declarada.
		var inicial: Vector2i = _pos_inicial(str(id))
		var movido: bool = pos != inicial
		if movido:
			en_destino.append(str(id))
		if sala != null and emisor >= 0:
			sala.set_emisor(emisor, movido)
	# Un bloque que cayo en un hueco desaparece: su emisor vuelve a OFF.
	for id in _caidos:
		var em: int = int(_emisores.get(str(id), -1))
		if sala != null and em >= 0:
			sala.set_emisor(em, false)
	_ultimo = {
		"bloques_movidos": en_destino,
		"caidos": _caidos.keys(),
		"receptor_activado": receptor_activado(),
	}

func receptor_activado() -> bool:
	return sala != null and sala.estado_igual_objetivo()

func bloques_movidos() -> Array:
	var out: Array = []
	for id in bloques:
		if pos_de(str(id)) != _pos_inicial(str(id)):
			out.append(str(id))
	return out

func _pos_inicial(id: String) -> Vector2i:
	var lb: Variant = def.get("hielo", {})
	if typeof(lb) != TYPE_DICTIONARY:
		return Vector2i(-1, -1)
	var lbi: Variant = (lb as Dictionary).get("bloques", [])
	if typeof(lbi) != TYPE_ARRAY:
		return Vector2i(-1, -1)
	for e in (lbi as Array):
		if typeof(e) == TYPE_DICTIONARY:
			var ed: Dictionary = e as Dictionary
			if str(ed.get("id", "")) == id:
				return _vec(ed.get("pos", []))
	return Vector2i(-1, -1)

# --- Validacion de la capa de hielo --------------------------------------

## Valida la capa de deslizamiento ADEMAS de PuzzleDef.validar_def. Devuelve [] si OK.
func validar_hielo() -> Array:
	var errores: Array = []
	if ancho <= 0 or alto <= 0:
		errores.append("grilla invalida (%dx%d)" % [ancho, alto])
	if bloques.is_empty():
		errores.append("sin bloques: nada que deslizar")

	var ocupadas: Dictionary = {}
	for celda in paredes:
		ocupadas[celda] = "pared"
	for celda in huecos:
		if ocupadas.has(celda):
			errores.append("celda %s es pared y hueco a la vez" % str(celda))
		else:
			ocupadas[celda] = "hueco"

	for id in bloques:
		var b: Dictionary = bloques[id]
		var pos: Vector2i = b["pos"]
		if not _dentro(pos):
			errores.append("bloque %s: posicion %s fuera de grilla" % [id, str(pos)])
		elif ocupadas.has(pos):
			errores.append("bloque %s: celda %s ya ocupada por %s" % [id, str(pos), str(ocupadas[pos])])
		else:
			ocupadas[pos] = "bloque %s" % id
		if sala == null or not sala.emisores.has(int(b["emisor"])):
			errores.append("bloque %s: emisor %d inexistente en la sala" % [id, int(b["emisor"])])

	for celda in pedazos:
		var p: Vector2i = celda
		if paredes.has(p):
			errores.append("pedazo %s: celda ya es pared" % str(p))
		var reg: Dictionary = pedazos[celda]
		if int(reg["usos"]) < 1:
			errores.append("pedazo %s: usos %d invalido (se exige >= 1)" % [str(p), int(reg["usos"])])

	errores.append_array(validar_simetria())
	return errores

# --- Helpers -------------------------------------------------------------

func _dentro(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < ancho and p.y < alto

func _dir_valida(dir: Vector2i) -> bool:
	return dir == NORTE or dir == ESTE or dir == SUR or dir == OESTE

func _bloque_en(celda: Vector2i) -> String:
	for id in bloques:
		var b: Dictionary = bloques[id]
		var pos: Vector2i = b["pos"]
		if pos == celda:
			return str(id)
	return ""

static func _vec(v: Variant) -> Vector2i:
	if typeof(v) == TYPE_ARRAY:
		var a: Array = v as Array
		if a.size() >= 2:
			return Vector2i(int(a[0]), int(a[1]))
	return Vector2i(-1, -1)
