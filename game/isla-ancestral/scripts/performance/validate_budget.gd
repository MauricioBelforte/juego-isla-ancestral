# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M61: Rendimiento — ValidateBudget (validador de presupuestos).
# Seccion 3.2 del 03-Diseno: valida que la tabla de presupuestos este completa
# (RF28), que una medicion de bench scene no exceda el total con tolerancia,
# y que todas las categorias esten dentro de su presupuesto individual.
# Corre en editor y en CI (M116). Ejecutar:
#   Godot --headless --script res://scripts/performance/validate_budget.gd
# Exit code: 0 = OK, 1 = fallo.

extends SceneTree

const RUTA_BUDGETS := "res://data/performance/budgets.json"

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_cargar_y_validar_tabla()
	print("=== VALIDATE BUDGET M61: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _cargar_y_validar_tabla() -> void:
	var f := FileAccess.open(RUTA_BUDGETS, FileAccess.READ)
	_check(f != null, "budgets.json abierto")
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	_check(parsed is Dictionary, "budgets.json es JSON valido")
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed
	_check(float(data.get("presupuesto_total_ms", 0.0)) > 0.0, "presupuesto_total_ms > 0")
	_check(float(data.get("tolerancia_ci", 0.0)) > 0.0, "tolerancia_ci > 0")
	var cats: Dictionary = data.get("categorias", {})
	_check(cats.size() >= 7, "7 categorias declaradas (RF28): %d" % cats.size())
	# Cada categoria > 0 y suma coherente
	var suma: float = 0.0
	for clave in cats:
		var ms := float(cats[clave])
		_check(ms > 0.0, "categoria %s > 0 (%s)" % [clave, str(ms)])
		suma += ms
	var total := float(data.get("presupuesto_total_ms", 0.0))
	_check(suma <= total * 1.3, "suma categorias dentro del total con margen (%.1f <= %.1f)" % [suma, total])
	# Hardware declarado
	var hw: Dictionary = data.get("hardware", {})
	_check(hw.get("minimo", "") != "" and hw.get("recomendado", "") != "", "hardware min/recomendado declarado")
	# Validar una medicion de ejemplo dentro de tolerancia
	var medicion := {"gameplay_ms": 2.0, "mundo_voxel_ms": 3.5, "ia_npc_ms": 1.5, "particulas_ms": 0.8, "culling_ms": 0.4, "render_ms": 4.5, "ui_ms": 1.2}
	_check(_validar_medicion(data, medicion), "medicion dentro de presupuesto OK")
	# Medicion excedida -> debe detectarse
	var mala := {"gameplay_ms": 20.0, "mundo_voxel_ms": 20.0, "ia_npc_ms": 20.0, "particulas_ms": 20.0, "culling_ms": 20.0, "render_ms": 20.0, "ui_ms": 20.0}
	_check(not _validar_medicion(data, mala), "medicion excedida detectada")

func _validar_medicion(data: Dictionary, medicion: Dictionary) -> bool:
	var cats: Dictionary = data.get("categorias", {})
	var tolerancia := float(data.get("tolerancia_ci", 0.1))
	# Chequeo individual: cada categoria medida dentro de su presupuesto + tolerancia
	var fallo_individual := false
	for clave in cats:
		if medicion.has(clave):
			var presupuesto := float(cats[clave])
			var medida := float(medicion[clave])
			if medida > presupuesto * (1.0 + tolerancia):
				fallo_individual = true
	# Chequeo total: suma <= total * (1+tolerancia)
	var suma: float = 0.0
	for clave in medicion:
		suma += float(medicion[clave])
	var total := float(data.get("presupuesto_total_ms", 0.0))
	return (not fallo_individual) and suma <= total * (1.0 + tolerancia)
