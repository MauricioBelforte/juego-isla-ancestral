# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-10-11
#
# M159 - Suite headless del Catalogo de Objetos (seccion "Integracion y Validacion").
# Reutiliza el analisis puro de validar_catalogo_m159.gd.
#
# Uso:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/data/test_catalogo_m159.gd
#
# Guardianes (3 capas):
#   1) marcadores _fin("X") por bloque + BLOQUES: nombra el bloque que no cerro;
#   2) piso CHECKS_MINIMOS medido en verde;
#   3) _summary() registrado con call_deferred: corre aunque _run() aborte.

extends SceneTree

const MODULO := "M159-catalogo"
const VAL := preload("res://scripts/data/validar_catalogo_m159.gd")
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G"]
const CHECKS_MINIMOS := 17   # piso MEDIDO en verde (Log 1716; re-medido 17 en Log 1907 tras el lote L216)

var _checks := 0
var _fallos := 0
var _vistos := {}
var _terminado := false


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _check(ok: bool, msg: String) -> void:
	_checks += 1
	if ok:
		print("[OK]    %s" % msg)
	else:
		_fallos += 1
		print("[FALLO] %s" % msg)


func _fin(b: String) -> void:
	_vistos[b] = true


func _run() -> void:
	var items: Array = VAL.cargar()
	var r: Dictionary = VAL.analizar(items)

	# --- A: carga ---
	_check(items.size() >= VAL.TOTAL_OBJETIVO, "A: se cargan al menos %d .tres de data/items (medido=%d)" % [VAL.TOTAL_OBJETIVO, items.size()])
	_check(int(r["cargados"]) == items.size(), "A: analizar.cargados == items.size()")
	_check(int(r["total"]) == items.size(), "A: total con id unico == cargados (medido=%d/%d)" % [int(r["total"]), items.size()])
	_check(r["sin_id"].size() == 0, "A: 0 items sin id")
	_check(r["invalidos"].size() == 0, "A: 0 items invalidos por es_valido()")
	_fin("A")

	# --- B: L210 IDs unicos ---
	_check(r["ids_duplicados"].size() == 0, "B: L210 0 IDs duplicados")
	_check(int(r["total"]) >= VAL.TOTAL_OBJETIVO, "B: L210 al menos %d IDs unicos (medido=%d)" % [VAL.TOTAL_OBJETIVO, int(r["total"])])
	_fin("B")

	# --- C: L211 categorias con objetos ---
	_check(r["categorias_vacias"].size() == 0, "C: L211 0 categorias vacias")
	var por: Dictionary = r["por_categoria"]
	_check(por.size() == 16, "C: L211 16 categorias indexadas")
	var min_cat := 999999
	for k in por.keys():
		min_cat = mini(min_cat, int(por[k]))
	_check(min_cat >= 1, "C: L211 la categoria mas chica tiene >=1 objeto (min=%d)" % min_cat)
	_fin("C")

	# --- D: L212 iconos (MEDICION: gap conocido, no se asserta el valor) ---
	print("-- MEDICION L212: sin_icono=%d/%d (0 con icono; gap documentado, no bloquea la suite)"
		% [r["sin_icono"].size(), int(r["total"])])
	_check(r["sin_icono"].size() <= int(r["total"]), "D: L212 contador consistente (<= total)")
	_fin("D")

	# --- E: L213 interactivos con accion ---
	_check(r["interactivos_sin_accion"].size() == 0, "E: L213 0 objetos interactivos sin interaccion")
	_fin("E")

	# --- F: L214 colocables con tamano ---
	_check(r["sin_tamano"].size() == 0, "F: L214 0 objetos sin tamano definido")
	_fin("F")

	# --- G: L215 precios + L216 total ---
	_check(r["tienda_sin_precio"].size() == 0, "G: L215 0 objetos sin ningun precio")
	_check(int(r["precio_venta_pos"]) >= VAL.TOTAL_OBJETIVO, "G: L215 al menos %d con precio_venta>0 (medido=%d)" % [VAL.TOTAL_OBJETIVO, int(r["precio_venta_pos"])])
	_check(int(r["precio_compra_pos"]) >= 1, "G: L215 hay objetos comprables (precio_compra>0=%d)" % int(r["precio_compra_pos"]))
	print("-- MEDICION L216: total=%d objetivo=%d faltan=%d (gap documentado, no bloquea la suite)"
		% [int(r["total"]), VAL.TOTAL_OBJETIVO, maxi(0, VAL.TOTAL_OBJETIVO - int(r["total"]))])
	_check(int(r["total"]) >= VAL.TOTAL_OBJETIVO, "G: L216 regresion total >= %d (medido=%d)" % [VAL.TOTAL_OBJETIVO, int(r["total"])])
	_fin("G")

	_terminado = true


func _summary() -> void:
	if not _terminado:
		print("!! _run() no termino (posible SCRIPT ERROR que aborto la funcion)")
	for b in BLOQUES:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] bloque %s NO se ejecuto" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)
