# M53 QA — Test de regresion de los tipos de modalidad de las capas UI.
# Modelo: stepfun-step-5-preview (Kilo Code)
# Fecha: 2026-10-12
#
# Por que existe: la QA de M53 encontro que DialogLayer e InventoryLayer tenian el
# `layer_type` INTERCAMBIADO (dialogo en MODAL_FULL, inventario en MODAL_SIMPLE),
# al reves de la semantica de `ui_layer_type.gd`:
#
#     MODAL_SIMPLE: pausa el reloj pero el mundo sigue visible (dialogos)
#     MODAL_FULL:   pausa total, bloquea input del mundo (inventario, pausa)
#
# Fix aplicado por orden del director mimo (msg 243). Este test falla si alguien
# vuelve a invertirlos.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/ui/test_layer_type_m53.gd
#
# NOTA: patron obligatorio para suites headless (ver 06-GUIA-DE-CONEXION-VISION.md):
# `extends SceneTree` + `preload()`, porque el cache de clases no resuelve
# `class_name` recien creados en un checkout limpio.

extends SceneTree

const DL = preload("res://scripts/ui/layers/dialog_layer.gd")
const IL = preload("res://scripts/ui/layers/inventory_layer.gd")
const ULT = preload("res://scripts/ui/core/ui_layer_type.gd")

const CHECKS_MINIMOS: int = 10
const BLOQUES_MINIMOS: int = 4

var _checks: int = 0
var _fallos: int = 0
var _bloques: int = 0

func _init() -> void:
	call_deferred("_run")


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK]   %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)


func _bloque(desc: String) -> void:
	_bloques += 1
	print("")
	print("-- %s" % desc)


func _run() -> void:  # async por los await process_frame
	await _b1_enum()
	await _b2_dialogo()
	await _b3_inventario()
	await _b4_cambio()
	_resumen()


# -- 1. el enum existe y tiene los dos tipos ------------------------
func _b1_enum() -> void:
	_bloque("1. UILayerType expone los dos tipos")
	_check("existe el tipo MODAL_SIMPLE", ULT.Type.MODAL_SIMPLE != null)
	_check("existe el tipo MODAL_FULL", ULT.Type.MODAL_FULL != null)
	_check("los dos tipos son distintos", ULT.Type.MODAL_SIMPLE != ULT.Type.MODAL_FULL)


# -- 2. DialogLayer debe ser MODAL_SIMPLE ---------------------------
func _b2_dialogo() -> void:
	_bloque("2. DialogLayer = MODAL_SIMPLE (dialogo: mundo sigue visible)")
	var dlg = DL.new()
	get_root().add_child(dlg)
	await process_frame
	var tipo: int = dlg.layer_type
	_check("instancia sin error", dlg != null)
	_check("layer_type es MODAL_SIMPLE", tipo == ULT.Type.MODAL_SIMPLE)
	_check("NO es MODAL_FULL (no debe pausar todo)", tipo != ULT.Type.MODAL_FULL)
	dlg.queue_free()


# -- 3. InventoryLayer debe ser MODAL_FULL --------------------------
func _b3_inventario() -> void:
	_bloque("3. InventoryLayer = MODAL_FULL (inventario: bloquea input del mundo)")
	var inv = IL.new()
	get_root().add_child(inv)
	await process_frame
	var tipo: int = inv.layer_type
	_check("instancia sin error", inv != null)
	_check("layer_type es MODAL_FULL", tipo == ULT.Type.MODAL_FULL)
	_check("NO es MODAL_SIMPLE (debe pausar todo)", tipo != ULT.Type.MODAL_SIMPLE)
	inv.queue_free()


# -- 4. no pueden volver a invertirse -------------------------------
func _b4_cambio() -> void:
	_bloque("4. los dos tipos son distintos entre si")
	var dlg = DL.new()
	var inv = IL.new()
	get_root().add_child(dlg)
	get_root().add_child(inv)
	await process_frame
	_check("DialogLayer e InventoryLayer tienen layer_type distinto",
			dlg.layer_type != inv.layer_type)
	dlg.queue_free()
	inv.queue_free()


func _resumen() -> void:
	print("")
	print("-- Resultado --")
	if _checks < CHECKS_MINIMOS:
		print("RESULTADO: FALLO — %d checks, minimo %d" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	if _fallos == 0 and _bloques >= BLOQUES_MINIMOS:
		print("RESULTADO: OK — %d checks, %d bloques, 0 fallos" % [_checks, _bloques])
		quit(0)
	else:
		print("RESULTADO: FALLO — %d fallos de %d checks" % [_fallos, _checks])
		quit(1)
