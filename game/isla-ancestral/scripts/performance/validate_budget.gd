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
	# iter. agnes (Log 943): dimension de limites de CANTIDAD (spec M61 sec.M + flag M52)
	_validar_limites(data)
	# iter. atria (Log 1755): dimension de NORMAS transversales (RF1/RF2/RF3/RF8/RF9/RF11/RF12/RF18/RF21)
	_validar_normas(data)

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


## iter. agnes (Log 943): valida el bloque "limites" (cantidad) si existe.
## Tolera su ausencia (no rompe el gate temporal previo); si esta, exige bien formado
## + los 3 limites canonicos + particulas_simultaneas_max == 500 (spec M61 sec.M / RF13).
func _validar_limites(data: Dictionary) -> void:
	if not data.has("limites"):
		return
	var limites: Variant = data.get("limites", {})
	_check(limites is Dictionary, "bloque limitas es un Dictionary")
	if not (limites is Dictionary):
		return
	var limes: Dictionary = limites
	_check(limes.size() >= 3, "limites: >=3 limites declarados (%d)" % limes.size())
	for clave in limes:
		var valor: Variant = limes[clave]
		if clave == "nota":
			continue
		_check(typeof(valor) == TYPE_INT or typeof(valor) == TYPE_FLOAT,
			"limite %s es numerico" % clave)
		if (typeof(valor) == TYPE_INT or typeof(valor) == TYPE_FLOAT) and float(valor) <= 0.0:
			_check(false, "limite %s > 0 (%s)" % [clave, str(valor)])
	_check(int(limes.get("particulas_simultaneas_max", 0)) == 500,
		"particulas_simultaneas_max == 500 (spec M61 sec.M / flag M52)")
	_check(limes.has("draw_calls_max"), "draw_calls_max declarado")
	_check(limes.has("objetos_mundo_max"), "objetos_mundo_max declarado")
	# Lectura dentro de limites -> OK; excedida -> debe detectarse
	_check(_medicion_dentro_limites(limes, {"particulas_simultaneas": 480, "draw_calls": 390, "objetos_mundo": 900}),
		"medicion de cantidad dentro de limites OK")
	_check(not _medicion_dentro_limites(limes, {"particulas_simultaneas": 600, "draw_calls": 390, "objetos_mundo": 900}),
		"particulas excediendo 500 detectada")
	print("[M61] limites: %d limit(es) de cantidad validados (particulas_simultaneas_max=%s)" % [
		limes.size() - (1 if limes.has("nota") else 0),
		str(limes.get("particulas_simultaneas_max", "?")),
	])

## Devuelve true si cada clave de la medicion (si existe en limites) no excede su limite.
func _medicion_dentro_limites(limites: Dictionary, medicion: Dictionary) -> bool:
	for clave in medicion:
		var clave_s: String = String(clave)
		var clave_limite: String = clave_s + "_max"
		if limites.has(clave_limite):
			if float(medicion[clave_s]) > float(limites[clave_limite]):
				return false
	return true


## iter. atria (Log 1755): valida el bloque "normas" (umbrales transversales de
## RF1/RF2/RF3/RF8/RF9/RF11/RF12/RF18/RF21). Tolera su ausencia (no rompe el gate
## de ramas anteriores); si esta, exige bien formado + los valores canonicos de la
## spec M61 (01-Requerimientos y 03-Diseno).
func _validar_normas(data: Dictionary) -> void:
	if not data.has("normas"):
		return
	var normas: Variant = data.get("normas", {})
	_check(normas is Dictionary, "bloque normas es un Dictionary")
	if not (normas is Dictionary):
		return
	var n: Dictionary = normas
	_check(bool(n.get("vsync", false)), "vsync activado (RF1: sin tearing)")
	_check(int(n.get("fps_objetivo", 0)) == 60, "fps_objetivo == 60 (RF1)")
	_check(int(n.get("fps_minimo", 0)) == 30, "fps_minimo == 30 (RF1)")
	_check(int(n.get("fps_minimo", 0)) < int(n.get("fps_objetivo", 0)), "fps_minimo < fps_objetivo")
	_check(String(n.get("resolucion_base", "")) == "1080p", "resolucion_base 1080p (RF2)")
	# Distancia de dibujado: 3 presets ascendentes 100/150/220 m (RF18, presets M91)
	var presets: Variant = n.get("distancia_dibujado_presets_m", [])
	_check(presets is Array and (presets as Array).size() == 3,
		"distancia_dibujado_presets_m: 3 presets (RF18)")
	if presets is Array and (presets as Array).size() == 3:
		var arr: Array = presets
		var ok_valores: bool = int(arr[0]) == 100 and int(arr[1]) == 150 and int(arr[2]) == 220
		_check(ok_valores, "presets == 100/150/220 m (RF18)")
	# LOD: 3 niveles + transicion sin pop (RF21)
	_check(int(n.get("lod_niveles", 0)) == 3, "lod_niveles == 3 (RF21)")
	_check(float(n.get("lod_transicion_sin_pop_m", 0.0)) > 0.0, "lod_transicion_sin_pop_m > 0 (RF21)")
	# NPCs activos visibles (RF12)
	_check(int(n.get("npcs_activos_max", 0)) == 20, "npcs_activos_max == 20 (RF12)")
	# Remesh por bloque destruido (RF11)
	_check(float(n.get("remesh_bloque_ms_max", 0.0)) > 0.0 and float(n.get("remesh_bloque_ms_max", 99.0)) <= 2.0,
		"remesh_bloque_ms_max <= 2.0 ms (RF11)")
	# Cargas: fria <30 s, caliente <10 s, HDD no soportado (RF8/RF9)
	_check(float(n.get("carga_fria_s_max", 0.0)) > 0.0 and float(n.get("carga_fria_s_max", 99.0)) <= 30.0,
		"carga_fria_s_max <= 30 s (RF8)")
	_check(float(n.get("carga_caliente_s_max", 0.0)) > 0.0 and float(n.get("carga_caliente_s_max", 99.0)) <= 10.0,
		"carga_caliente_s_max <= 10 s (RF8)")
	_check(not bool(n.get("almacenamiento_hdd_soportado", true)),
		"almacenamiento_hdd_soportado == false (RF8: HDD no soportado)")
	print("[M61] normas: %d umbral(es) transversales validados (fps %d/%d, presets %s, LOD %d, NPCs %d)" % [
		n.size() - (1 if n.has("nota") else 0),
		int(n.get("fps_objetivo", 0)),
		int(n.get("fps_minimo", 0)),
		str(n.get("distancia_dibujado_presets_m", [])),
		int(n.get("lod_niveles", 0)),
		int(n.get("npcs_activos_max", 0)),
	])
