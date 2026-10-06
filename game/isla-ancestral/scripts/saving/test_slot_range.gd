# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-114: defensa en profundidad del rango de slot.
#
# Antes, las estaticas de SaveWriter no validaban que `slot` estuviera en
# 1..SLOT_COUNT: write_atomic(99, ...) creaba user://saves/slot_99.save sin
# protestar. Los llamadores actuales validan, asi que era defensa ausente.
#
# Fix: SaveSchema.SLOT_COUNT es la fuente unica del rango; write_atomic y
# cleanup_orphan_tmp lo validan. NO se toco `save_exists` (guardarlo volveria
# trivialmente verdaderos 2 checks de la suite aceptada test_slots_m59, patron de
# falso verde prohibido; el rango de lectura lo validan los llamadores).
#
# RED por inyeccion: sin el guard, write_atomic(99/0/4) devuelve true y crea el
# archivo fuera de rango.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_slot_range.gd

extends SceneTree

## Piso MEDIDO en verde (10 checks).
const CHECKS_MINIMOS := 10

const SLOT_FUERA := 99

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_recursive_absolute("user://saves")
	_limpiar()

	# Predicado de rango.
	_check(SaveSchema.slot_valido(1) == true, "slot_valido(1) true")
	_check(SaveSchema.slot_valido(SaveSchema.SLOT_COUNT) == true, "slot_valido(%d) true" % SaveSchema.SLOT_COUNT)
	_check(SaveSchema.slot_valido(0) == false, "slot_valido(0) false")
	_check(SaveSchema.slot_valido(SaveSchema.SLOT_COUNT + 1) == false, "slot_valido(%d) false" % (SaveSchema.SLOT_COUNT + 1))
	_check(SaveSchema.slot_valido(SLOT_FUERA) == false, "slot_valido(%d) false" % SLOT_FUERA)

	# write_atomic rechaza slots fuera de rango y NO crea el archivo.
	var p: Dictionary = SaveSchema.default_payload("x")
	_check(SaveWriter.write_atomic(SLOT_FUERA, p) == false, "write_atomic(%d) false (BUG-114)" % SLOT_FUERA)
	_check(not FileAccess.file_exists("user://saves/slot_%d.save" % SLOT_FUERA),
		"write_atomic(%d) NO crea el archivo fuera de rango" % SLOT_FUERA)
	_check(SaveWriter.write_atomic(0, p) == false, "write_atomic(0) false")
	_check(SaveWriter.write_atomic(SaveSchema.SLOT_COUNT + 1, p) == false,
		"write_atomic(%d) false" % (SaveSchema.SLOT_COUNT + 1))

	# cleanup_orphan_tmp con slot fuera de rango no debe crashear ni crear nada.
	SaveWriter.cleanup_orphan_tmp(SLOT_FUERA)
	_check(not FileAccess.file_exists("user://saves/slot_%d.tmp" % SLOT_FUERA),
		"cleanup_orphan_tmp(%d) no crea ni borra fuera de rango" % SLOT_FUERA)

	_limpiar()
	_resumen()

func _limpiar() -> void:
	for suf in [".save", ".tmp"]:
		var p := "user://saves/slot_%d%s" % [SLOT_FUERA, suf]
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST SLOT-RANGE: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST SLOT-RANGE FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
