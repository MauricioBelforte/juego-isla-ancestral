# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: interprete datos-driven del SISTEMA DE PISTAS Y AYUDA.
#
# Extiende el framework emisor->receptor (PuzzleDef / PuzzleRoom) con las PISTAS.
# TODA pista se DERIVA de los datos del grafo (`PuzzleDef.reglas_def()` /
# `solucion_minima()`): no hay texto suelto escrito a mano (item 138). Las pistas
# son informacion, nunca penalizacion (item 139).
#
# Anclas reales (verificadas por archivo, no por doc):
#   - `scripts/templos/templo_telemetria.gd` (TempleTelemetria): registrar_intento(puzzle_id, pistas_usadas).
#   - `scripts/diario/diary_service.gd`: registrar(entrada_id, categoria) -> bool (capa 2, item 132).
#
# Mapeo item del checklist -> campo/API (03-Diseno.md, "Pistas y sistema de ayuda"):
#   - item 132 3 capas (ambiental -> diario -> total) -> capas() + registrar_en_diario(diary).
#   - item 134 pista diferida (90 s sin progreso)     -> avanzar(dt) + pista_diferida_disponible().
#   - item 135 pista de familia textual               -> pista_familia().
#   - item 136 pista de emisor exacto                 -> pista_emisor_exacto().
#   - item 137 solucion paso a paso tras 3 pistas     -> solucion_paso_a_paso() (exige 3 pistas).
#   - item 138 pistas ancladas a reglas del grafo     -> pista_anclada_a_grafo() (deriva de reglas_def).
#   - item 139 eleccion libre sin penalizacion        -> usar_pista() + penalizacion() == 0.
#
# RefCounted + static: no instancia escenas (igual que PuzzleDef/PuzzleLuz).

class_name PuzzlePistas
extends RefCounted

## Pistas necesarias antes de ofrecer la solucion paso a paso (item 137).
const PISTAS_PARA_SOLUCION := 3

## Segundos sin progreso antes de ofrecer la pista diferida (item 134).
const DEMORA_PISTA_S := 90.0

## Las 3 capas del sistema de ayuda (item 132).
const CAPAS := ["ambiental", "diario", "total"]

var def: Dictionary = {}
var familia: String = ""
var categoria_diario: String = "templos"

var _pistas_usadas: int = 0
var _segundos_sin_progreso: float = 0.0
var _ultima_pista: String = ""

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	return PuzzleDef.cargar(path)

static func desde_def(d: Dictionary) -> PuzzlePistas:
	var pp := PuzzlePistas.new()
	pp._construir(d)
	return pp

func _construir(d: Dictionary) -> void:
	def = d
	familia = str(d.get("familia", ""))
	var pz: Variant = d.get("pistas", {})
	var p: Dictionary = (pz as Dictionary) if typeof(pz) == TYPE_DICTIONARY else {}
	categoria_diario = str(p.get("categoria_diario", "templos"))

# --- Las 3 capas (item 132) ----------------------------------------------

func capas() -> Array:
	return CAPAS.duplicate()

## Capa 2: registra la entrada en el diario (ancla real: diary_service.registrar).
## Duck-typed: sirve el autoload real como un diario de prueba.
func registrar_en_diario(diary: Object) -> bool:
	if diary == null:
		return false
	if not diary.has_method("registrar"):
		return false
	var entrada_id: String = "templo_%s_%s" % [familia, str(def.get("id", ""))]
	return bool(diary.call("registrar", entrada_id, categoria_diario))

# --- Pista diferida (item 134) -------------------------------------------

## Avanza el reloj de "sin progreso". Cualquier progreso real llama a reiniciar_espera().
func avanzar(delta_s: float) -> void:
	if delta_s > 0.0:
		_segundos_sin_progreso += delta_s

func reiniciar_espera() -> void:
	_segundos_sin_progreso = 0.0

func segundos_sin_progreso() -> float:
	return _segundos_sin_progreso

func pista_diferida_disponible() -> bool:
	return _segundos_sin_progreso >= DEMORA_PISTA_S

# --- Pistas derivadas del grafo (items 135, 136, 138) --------------------

## Pista de FAMILIA (item 135): textual, derivada de la familia declarada.
func pista_familia() -> String:
	var etiqueta: String = familia if not familia.is_empty() else "desconocida"
	return "Este templo es de la familia '%s': observa como interactua el entorno antes de tocar nada." % etiqueta

## Pista de EMISOR EXACTO (item 136): nombra el/los emisor(es) de la solucion.
func pista_emisor_exacto() -> String:
	var sol: Array = PuzzleDef.solucion_minima(def)
	if sol.is_empty():
		return "No se pudo derivar la solucion del grafo (revisar el puzzle)."
	var partes: Array = []
	for id in sol:
		partes.append(str(int(id)))
	return "El emisor exacto que debes activar es: %s." % ", ".join(partes)

## Pista ANCLADA A LAS REGLAS del grafo (item 138): nunca texto suelto; cita la
## regla real (receptor <- conjunto de emisores) declarada en los datos.
func pista_anclada_a_grafo() -> String:
	var reglas: Array = PuzzleDef.reglas_def(def)
	if reglas.is_empty():
		return "El puzzle no declara reglas."
	var partes: Array = []
	for regla in reglas:
		if typeof(regla) != TYPE_DICTIONARY:
			continue
		var r: Dictionary = regla as Dictionary
		var receptor: String = str(r.get("receptor", "?"))
		var emisores: Array = []
		var em: Variant = r.get("emisores", [])
		if typeof(em) == TYPE_ARRAY:
			for x in (em as Array):
				emisores.append(str(int(x)))
		partes.append("%s requiere [%s]" % [receptor, ", ".join(emisores)])
	return "Reglas del grafo: %s." % "; ".join(partes)

# --- Solucion paso a paso (item 137) -------------------------------------

## Pasos para resolver. Solo se ofrece tras usar 3 pistas (no se regala antes).
func solucion_paso_a_paso() -> Array:
	if _pistas_usadas < PISTAS_PARA_SOLUCION:
		return []
	var pasos: Array = []
	var sol: Array = PuzzleDef.solucion_minima(def)
	var ordenados: Array = sol.duplicate()
	ordenados.sort()
	var n: int = 0
	for id in ordenados:
		n += 1
		pasos.append("Paso %d: activa el emisor %d." % [n, int(id)])
	var receptor: String = "?"
	var reglas: Array = PuzzleDef.reglas_def(def)
	if not reglas.is_empty() and typeof(reglas[0]) == TYPE_DICTIONARY:
		receptor = str((reglas[0] as Dictionary).get("receptor", "?"))
	pasos.append("Paso %d: el receptor %s se activa." % [n + 1, receptor])
	return pasos

# --- Eleccion libre, sin penalizacion (item 139) -------------------------

## El jugador consulta una pista: suma el contador, NUNCA aplica castigo.
func usar_pista() -> int:
	_pistas_usadas += 1
	return _pistas_usadas

func pistas_usadas() -> int:
	return _pistas_usadas

## Penalizacion por consultar la guia: SIEMPRE 0 (eleccion libre, item 139).
func penalizacion() -> int:
	return 0

func ultima_pista() -> String:
	return _ultima_pista

func pista_actual() -> String:
	var pista: String = ""
	if pista_diferida_disponible():
		pista = pista_familia()
	else:
		pista = pista_anclada_a_grafo()
	_ultima_pista = pista
	return pista

# --- Validacion de la capa de pistas -------------------------------------

## Valida la capa de pistas ADEMAS de PuzzleDef.validar_def. Devuelve [] si OK.
func validar_pistas() -> Array:
	var errores: Array = []
	if def.is_empty():
		errores.append("definicion vacia")
		return errores
	if familia.is_empty():
		errores.append("sin familia declarada: la pista de familia queda vacia")
	var sol: Array = PuzzleDef.solucion_minima(def)
	if sol.is_empty():
		errores.append("el grafo no tiene una solucion minima unica: no se pueden derivar pistas")
	if PuzzleDef.reglas_def(def).is_empty():
		errores.append("sin reglas: la pista anclada al grafo queda vacia")
	if CAPAS.size() != 3:
		errores.append("el sistema de pistas debe tener 3 capas (tiene %d)" % CAPAS.size())
	if PISTAS_PARA_SOLUCION < 1:
		errores.append("PISTAS_PARA_SOLUCION invalido")
	return errores
