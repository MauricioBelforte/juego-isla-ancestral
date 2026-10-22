# Modelo: Hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# F1 (FINDING, M71) — Reproduccion aislada del defecto en `_reevaluar()`:
# marca TODOS los hitos indexados bajo una estadistica sucia SIN revalidar
# el umbral de su condicion. Resultado: recolectar 10 items (umbral de
# hito_items_10) marca tambien hito_items_50 (umbral 50) y la cadena
# compuesta hito_explorador_completo.
#
# Esto NO es un fallo de marcar_hito() (el contrato de entrega de recompensa
# se verifica verde en test_flujo_xp_recompensa_m71_hy3.gd, Bloque C #55).
# El defecto vive en el camino dirigido por eventos (_reevaluar).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/progresion/test_bug_reevaluar_m71_hy3.gd
# Esperado: FALLO (las 2 aserciones de integridad de umbral deben fallar
# hasta que se corrija progression_manager.gd:_reevaluar).
#
# Guarda anti-falso-verde (3 capas) igual que #55.

extends SceneTree

const CHECKS_MINIMOS := 7
const _WB_BLOQUES: Array[String] = ["_test_reevaluar_threshold"]
var _checks: int = 0
var _fallos: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _pm: Node = null
var _bus: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true

func _run() -> void:
	print("=== [HY3][F1] Repro _reevaluar sin validar umbral (M71) ===")
	_pm = root.get_node_or_null("ProgressionManager")
	_bus = root.get_node_or_null("EventBus")
	_check(_pm != null, "ProgressionManager autoload presente")
	_check(_bus != null, "EventBus autoload presente")
	if _pm == null or _bus == null:
		return
	_pm.restore_save_data({})
	_check(not _pm.hito_alcanzado("hito_items_50"),
		"aislamiento: hito_items_50 limpio antes de eventos")
	# 10 items recolectados (umbral de hito_items_10 = 10, de hito_items_50 = 50)
	var alcanzados: Array = []
	var cb := func(id: String, _n: String, _r: Array) -> void:
		alcanzados.append(id)
	_pm.progreso_hito_alcanzado.connect(cb)
	for i in range(10):
		_bus.inventory.item_added.emit("baya_roja", 1)
	_pm.progreso_hito_alcanzado.disconnect(cb)
	# --- Comportamiento CORRECTO (debe pasar) ---
	_check(alcanzados.has("hito_items_10"),
		"hito_items_10 alcanzado con 10 items (umbral 10): OK")
	_check(float(_pm.get_stat_safe("items_recolectados")) >= 10.0,
		"items_recolectados acumulados = 10: %s" % _pm.get_stat_safe("items_recolectados"))
	# --- INTEGRIDAD DE UMBRAL (debe pasar PERO FALLA => defecto) ---
	_check(not _pm.hito_alcanzado("hito_items_50"),
		"INTEGRIDAD: hito_items_50 NO alcanzado con solo 10 items (umbral 50)")
	_check(not _pm.hito_alcanzado("hito_explorador_completo"),
		"INTEGRIDAD: hito_explorador_completo NO alcanzado (cadena compuesta)")
	_fin("_test_reevaluar_threshold")

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % msg)
	else:
		_fallos += 1
		print("  [FAIL] %s" % msg)

func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO ejecutado (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen HY3 F1 M71: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLO (fallos=%d, checks=%d) -- defecto _reevaluar confirmado" % [_fallos, _checks])
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON -- defecto corregido")
		quit(0)
