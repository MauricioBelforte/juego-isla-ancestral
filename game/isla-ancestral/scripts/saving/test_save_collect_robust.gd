# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-111 (reclasificado): robustez de SaveSnapshot.collect().
#
# Hallazgo medido: el sintoma literal de BUG-111 (_writing colgado) NO se reproduce
# (ver Log de la cola). El bug REAL adyacente es este: si un proveedor LANZA (error
# de runtime) o devuelve un tipo que NO es Dictionary, la asignacion tipada
# `var data: Dictionary = provider.get_save_data()` abortaba collect() ENTERO ->
# devolvia {} -> SaveWriter escribia un save VACIO y el progreso del jugador se
# perdia en SILENCIO al recargar (medido: 47 secciones -> 0, con "save OK").
#
# Esta sonda afirma el comportamiento arreglado: un proveedor roto se OMITE y las
# demas secciones se conservan. Es RED sin el fix (collect devolveria {} -> size 0).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_save_collect_robust.gd

extends SceneTree

## Piso MEDIDO en verde. Si un bloque aborta en silencio, _checks cae por debajo
## y el resumen sale con EXIT 1 en vez de un "0 fallos" enganoso.
const CHECKS_MINIMOS := 9

## Baseline sano MEDIDO (collect sin proveedores rotos): 47 secciones.
const SECCIONES_MINIMAS := 40

var _fallos: int = 0
var _checks: int = 0
var _sm: Node = null

## Proveedor que devuelve un ARRAY (viola el contrato Dictionary). NO lanza error.
class BadTypeProvider:
	extends RefCounted
	func get_section_name() -> String:
		return "probe_badtype"
	func get_save_data():
		return [1, 2, 3]
	func restore_save_data(_d) -> void:
		pass

## Proveedor que devuelve null sin lanzar (seccion "ausente").
class NullProvider:
	extends RefCounted
	func get_section_name() -> String:
		return "probe_null"
	func get_save_data():
		return null
	func restore_save_data(_d) -> void:
		pass

## Proveedor SANO: su seccion SI debe escribirse (control de no-regresion).
class GoodProvider:
	extends RefCounted
	func get_section_name() -> String:
		return "probe_good"
	func get_save_data() -> Dictionary:
		return {"v": 7}
	func restore_save_data(_d) -> void:
		pass

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_sm = root.get_node_or_null("SaveManager")
	_check(_sm != null, "SaveManager autoload presente")
	if _sm == null:
		_resumen()
		return
	var snap: SaveSnapshot = _sm.snapshot
	_check(snap != null, "SaveManager.snapshot presente")
	if snap == null:
		_resumen()
		return

	# 1) Baseline sano: collect trae TODAS las secciones del schema.
	var sano: Dictionary = snap.collect("slot_probe")
	_check(sano.size() >= SECCIONES_MINIMAS,
		"baseline: collect sano >= %d secciones (medido %d)" % [SECCIONES_MINIMAS, sano.size()])
	_check(sano.has("inventory") and typeof(sano["inventory"]) == TYPE_DICTIONARY,
		"baseline: 'inventory' presente y es Dictionary")

	# 2) Proveedor de TIPO INCORRECTO (Array): NO debe vaciar el snapshot.
	snap.register_provider(BadTypeProvider.new())
	var con_malo: Dictionary = snap.collect("slot_probe")
	_check(con_malo.size() >= SECCIONES_MINIMAS,
		"tipo incorrecto: snapshot conserva >= %d secciones (medido %d)" % [SECCIONES_MINIMAS, con_malo.size()])
	_check(con_malo.has("inventory"), "tipo incorrecto: 'inventory' sobrevive")
	_check(not con_malo.has("probe_badtype"), "tipo incorrecto: su seccion NO se escribe (se omite)")

	# 3) Proveedor que devuelve null: tampoco debe vaciar el snapshot.
	snap.register_provider(NullProvider.new())
	var con_null: Dictionary = snap.collect("slot_probe")
	_check(con_null.size() >= SECCIONES_MINIMAS,
		"null: snapshot conserva >= %d secciones (medido %d)" % [SECCIONES_MINIMAS, con_null.size()])
	_check(not con_null.has("probe_null"), "null: su seccion NO se escribe (se omite)")

	# 4) Control de no-regresion: un proveedor SANO si se escribe.
	snap.register_provider(GoodProvider.new())
	var con_bueno: Dictionary = snap.collect("slot_probe")
	_check(con_bueno.get("probe_good", {}).get("v", -1) == 7,
		"control: un proveedor sano SI escribe su seccion")

	_resumen()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST SAVE-COLLECT-ROBUST: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST SAVE-COLLECT-ROBUST FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
