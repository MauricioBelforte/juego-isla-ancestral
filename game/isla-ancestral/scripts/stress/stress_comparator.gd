# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-15
#
# M113: Pruebas de Stress — StressComparator
# Cierra el gap que el diseño marcó [x] ("baseline versionado perf_base.json" +
# "comparación automática ±5%") pero el runner no implementaba.
# Lógica pura (RefCounted, sin class_name → se usa preload §9.52). V0 + headless.
#
# Formatos:
#   escenarios (del runner): [ { "escenario": nombre, "metricas": {m: {p50,p95,max,count}}, ... } ]
#   baseline (perf_base.json): { escenario: { metrica: { p95, max } } }

extends RefCounted

## RUTA del baseline versionado (se versiona en el repo; es el "objetivo de referencia").
const RUTA_BASELINE := "res://scripts/stress/perf_base.json"

## Tolerancia por defecto: ±5% (regresión si p95 actual > p95 base * 1.05).
const UMBRAL_REGRESION := 0.05


## Deriva el baseline a partir del reporte actual.
## Usos: primera corrida (semilla) o `--update-baseline` del runner.
func derivar_baseline(escenarios: Array) -> Dictionary:
	var base := {}
	for esc in escenarios:
		var nombre := String(esc.get("escenario", ""))
		if nombre.is_empty():
			continue
		var metricas: Dictionary = esc.get("metricas", {})
		var entradas := {}
		for metrica in metricas:
			var resumen: Variant = metricas[metrica]
			if resumen is Dictionary and resumen.has("p95"):
				entradas[metrica] = {
					"p95": float(resumen.get("p95", 0.0)),
					"max": float(resumen.get("max", 0.0)),
				}
		if not entradas.is_empty():
			base[nombre] = entradas
	return base


## Compara el reporte contra el baseline con umbral configurable.
## Regresión: p95 actual > p95 base * (1 + umbral).
## Devuelve { "regresion", "hay_baseline", "umbral", "regresiones", "sin_dato" }.
func comparar(escenarios: Array, baseline: Dictionary, umbral: float = UMBRAL_REGRESION) -> Dictionary:
	var regresiones: Array = []
	var sin_dato: Array = []
	for esc in escenarios:
		var nombre := String(esc.get("escenario", ""))
		if nombre.is_empty():
			continue
		var base_esc: Variant = baseline.get(nombre, {})
		var metricas: Dictionary = esc.get("metricas", {})
		if not (base_esc is Dictionary) or (base_esc as Dictionary).is_empty():
			if not metricas.is_empty():
				sin_dato.append(nombre)
			continue
		for metrica in metricas:
			var actual: Variant = metricas[metrica]
			if not (actual is Dictionary):
				continue
			var base_metrica: Variant = (base_esc as Dictionary).get(metrica, {})
			if not (base_metrica is Dictionary):
				continue
			var p95_base := float((base_metrica as Dictionary).get("p95", 0.0))
			if p95_base <= 0.0:
				continue
			var p95_actual := float((actual as Dictionary).get("p95", 0.0))
			var delta := (p95_actual - p95_base) / p95_base
			if delta > umbral:
				regresiones.append({
					"escenario": nombre,
					"metrica": metrica,
					"p95_base": p95_base,
					"p95_actual": p95_actual,
					"delta_pct": snappedf(delta * 100.0, 0.1),
				})
	return {
		"regresion": not regresiones.is_empty(),
		"hay_baseline": not baseline.is_empty(),
		"umbral": umbral,
		"regresiones": regresiones,
		"sin_dato": sin_dato,
	}


## Carga el baseline JSON versionado. {} si no existe o es inválido (no aborta la corrida).
func cargar(ruta: String = RUTA_BASELINE) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var file := FileAccess.open(ruta, FileAccess.READ)
	if file == null:
		return {}
	var texto := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(texto)
	if not (parsed is Dictionary):
		push_warning("[M113] Baseline inválido en %s (se ignora)" % ruta)
		return {}
	return parsed


## Guarda el baseline versionado. true si se escribió.
func guardar(ruta: String, datos: Dictionary) -> bool:
	var file := FileAccess.open(ruta, FileAccess.WRITE)
	if file == null:
		push_warning("[M113] No se pudo escribir baseline en %s" % ruta)
		return false
	file.store_string(JSON.stringify(datos, "  "))
	file.close()
	print("[M113] Baseline escrito: %s (%d escenarios)" % [ruta, datos.size()])
	return true


## Ruta del baseline versionado (la expone al runner, que lo usa vía preload).
func ruta_baseline() -> String:
	return RUTA_BASELINE
