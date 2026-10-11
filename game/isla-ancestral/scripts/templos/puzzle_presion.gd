# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: familia PRESION avanzada (elevadores, puertas encadenadas,
# sin fallo punitivo). Cierra los items 77, 78, 79 y 80 del checklist:
#   77 elevadores por placas
#   78 puertas por placas encadenadas
#   79 sin fallo punitivo (reinicio del slot, contrato M66)
#   80 documentacion en el plan-actual (03-Diseno.md)
#
# Compone el framework emisor->receptor: `PuzzleDef.a_puzzle_room(def)` construye
# la sala; esta capa traduce el estado de las placas a ALTURA de elevador y a
# APERTURA de puertas encadenadas. El reinicio vuelve al estado inicial del slot
# y NUNCA penaliza (M66, `scripts/core/invariants/puzzle_invariant.gd`).

class_name PuzzlePresion
extends RefCounted

var def: Dictionary = {}
var sala: PuzzleRoom = null
var elevadores: Array = []
var puertas: Array = []
var sin_fallo_punitivo: bool = false

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[M24] PuzzlePresion.cargar: no existe %s" % path)
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(crudo) != TYPE_DICTIONARY:
		push_warning("[M24] PuzzlePresion.cargar: %s no es un objeto JSON" % path)
		return {}
	return crudo as Dictionary

static func desde_def(d: Dictionary) -> PuzzlePresion:
	var pp := PuzzlePresion.new()
	pp._construir(d)
	return pp

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	var pz: Variant = d.get("presion", {})
	var p: Dictionary = (pz as Dictionary) if typeof(pz) == TYPE_DICTIONARY else {}
	sin_fallo_punitivo = bool(p.get("sin_fallo_punitivo", false))
	var el: Variant = p.get("elevadores", [])
	elevadores = (el as Array) if typeof(el) == TYPE_ARRAY else []
	var pu: Variant = p.get("puertas_encadenadas", [])
	puertas = (pu as Array) if typeof(pu) == TYPE_ARRAY else []

# --- Estado de placas -----------------------------------------------------

func _emisor_on(id: int) -> bool:
	if sala == null:
		return false
	return bool(sala.emisores.get(id, false))

func activar_emisor(id: int, on: bool) -> void:
	if sala != null:
		sala.set_emisor(id, on)

func emisores_on() -> Array:
	var out: Array = []
	if sala == null:
		return out
	for id in sala.emisores.keys():
		if bool(sala.emisores[id]):
			out.append(int(id))
	out.sort()
	return out

# --- Item 77: elevadores por placas --------------------------------------

func _elevador_de(id: String) -> Dictionary:
	for e in elevadores:
		if typeof(e) == TYPE_DICTIONARY and str((e as Dictionary).get("id", "")) == id:
			return e as Dictionary
	return {}

## Altura del elevador = cantidad de placas de su grupo encendidas, con tope
## en `niveles`. Devuelve -1 si el elevador no existe.
func altura_elevador(id: String) -> int:
	var e: Dictionary = _elevador_de(id)
	if e.is_empty():
		return -1
	var n: int = 0
	var grupo: Variant = e.get("grupo", [])
	if typeof(grupo) == TYPE_ARRAY:
		for g in (grupo as Array):
			if _emisor_on(int(g)):
				n += 1
	return mini(n, int(e.get("niveles", 0)))

func elevador_en_tope(id: String) -> bool:
	var e: Dictionary = _elevador_de(id)
	if e.is_empty():
		return false
	return altura_elevador(id) >= int(e.get("niveles", 0))

# --- Item 78: puertas por placas encadenadas -----------------------------

func _puerta_de(id: String) -> Dictionary:
	for p in puertas:
		if typeof(p) == TYPE_DICTIONARY and str((p as Dictionary).get("id", "")) == id:
			return p as Dictionary
	return {}

## Una puerta encadenada abre SOLO si toda su cadena de placas esta ON.
func puerta_encadenada_abierta(id: String) -> bool:
	var p: Dictionary = _puerta_de(id)
	if p.is_empty():
		return false
	var req: Variant = p.get("requiere", [])
	if typeof(req) != TYPE_ARRAY or (req as Array).is_empty():
		return false
	for r in (req as Array):
		if not _emisor_on(int(r)):
			return false
	return true

func puertas_abiertas() -> Array:
	var out: Array = []
	for p in puertas:
		if typeof(p) != TYPE_DICTIONARY:
			continue
		var pid: String = str((p as Dictionary).get("id", ""))
		if not pid.is_empty() and puerta_encadenada_abierta(pid):
			out.append(pid)
	return out

# --- Item 79: sin fallo punitivo (M66) -----------------------------------

## Reinicia la sala al estado inicial del slot: todas las placas OFF.
func reiniciar() -> void:
	if sala == null:
		return
	for id in sala.emisores.keys():
		sala.emisores[id] = false
	sala.recalcular()

## El reinicio jamas castiga al jugador (item 79).
func penalizacion_reinicio() -> int:
	return 0

func es_reinicio_punitivo() -> bool:
	return not sin_fallo_punitivo

# --- Validacion -----------------------------------------------------------

## Valida el framework + la capa de presion. Devuelve [] si es coherente.
func validar() -> Array:
	var errores: Array = []
	errores.append_array(PuzzleDef.validar_def(def))
	if not sin_fallo_punitivo:
		errores.append("la familia de presion exige sin_fallo_punitivo = true (M66)")
	var declarados: Array = PuzzleDef.ids_emisores(def)
	for e in elevadores:
		if typeof(e) != TYPE_DICTIONARY:
			errores.append("elevador no es un objeto")
			continue
		var ed: Dictionary = e as Dictionary
		var eid: int = int(ed.get("emisor", -1))
		if not declarados.has(eid):
			errores.append("elevador '%s' usa emisor inexistente %d" % [str(ed.get("id", "")), eid])
		if int(ed.get("niveles", 0)) <= 0:
			errores.append("elevador '%s' con niveles <= 0" % str(ed.get("id", "")))
		var grupo: Variant = ed.get("grupo", [])
		if typeof(grupo) != TYPE_ARRAY or (grupo as Array).is_empty():
			errores.append("elevador '%s' sin grupo de placas" % str(ed.get("id", "")))
		elif typeof(grupo) == TYPE_ARRAY:
			for g in (grupo as Array):
				if not declarados.has(int(g)):
					errores.append("elevador '%s' referencia placa inexistente %d" % [str(ed.get("id", "")), int(g)])
	for p in puertas:
		if typeof(p) != TYPE_DICTIONARY:
			errores.append("puerta encadenada no es un objeto")
			continue
		var pd: Dictionary = p as Dictionary
		var pid: int = int(pd.get("emisor", -1))
		if not declarados.has(pid):
			errores.append("puerta '%s' usa emisor inexistente %d" % [str(pd.get("id", "")), pid])
		var req: Variant = pd.get("requiere", [])
		if typeof(req) != TYPE_ARRAY or (req as Array).is_empty():
			errores.append("puerta '%s' sin cadena de placas" % str(pd.get("id", "")))
		elif typeof(req) == TYPE_ARRAY:
			for r in (req as Array):
				if not declarados.has(int(r)):
					errores.append("puerta '%s' referencia placa inexistente %d" % [str(pd.get("id", "")), int(r)])
	if elevadores.is_empty() and puertas.is_empty():
		errores.append("la capa de presion no declara elevadores ni puertas encadenadas")
	return errores
