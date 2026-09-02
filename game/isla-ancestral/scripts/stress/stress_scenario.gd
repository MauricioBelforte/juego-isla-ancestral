# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M113: Pruebas de Stress — StressScenario (base)
# Clase base de un escenario de stress (adaptación GDScript del diseño
# Unity/C# de 04-Codigo.md §2): Setup -> Execute -> Teardown con registro
# de métricas (p50/p95/max) por nombre. Cada escenario define su propio
# Nombre y la lógica de ejecución.

class_name StressScenario
extends RefCounted

## Nombre único del escenario (override en cada subclase).
var _nombre: String = "escenario"

## Métricas registradas: { nombre_metrica: Array[float] }
var _metricas: Dictionary = {}

func _init() -> void:
	pass

func nombre() -> String:
	return _nombre

## Prepara el escenario (mundo, listas de prueba, estado).
## Llamado una vez antes de execute(). Puede lanzar push_warning en fallo leve.
func setup() -> void:
	pass

## Ejecuta la carga de stress. Devuelve un Dictionary con métricas finales
## calculadas (p50/p95/max por métrica) o vacío si se usó _registrar_metrica.
func execute() -> Dictionary:
	return {}

## Limpia / resetea el estado tras la ejecución.
func teardown() -> void:
	pass

## Registra una muestra de métrica (valor numérico) para el cálculo p50/p95.
func _registrar_metrica(nombre_metrica: String, valor: float) -> void:
	if not _metricas.has(nombre_metrica):
		_metricas[nombre_metrica] = []
	(_metricas[nombre_metrica] as Array).append(valor)

## Calcula p50/p95/max de una lista de valores (ordenada por copia).
## Devuelve {p50, p95, max, count} o ceros si no hay muestras.
func _resumen_metrica(muestras: Array) -> Dictionary:
	if muestras.is_empty():
		return {"p50": 0.0, "p95": 0.0, "max": 0.0, "count": 0}
	var ordenadas := muestras.duplicate()
	ordenadas.sort()
	var n := ordenadas.size()
	var p50 := _percentil(ordenadas, 0.50)
	var p95 := _percentil(ordenadas, 0.95)
	return {
		"p50": snappedf(p50, 0.001),
		"p95": snappedf(p95, 0.001),
		"max": snappedf(float(ordenadas[n - 1]), 0.001),
		"count": n,
	}

## Percentil lineal (método de interpolación). `p` en [0, 1].
func _percentil(ordenadas: Array, p: float) -> float:
	if ordenadas.is_empty():
		return 0.0
	var n := ordenadas.size()
	var pos := p * float(n - 1)
	var base := int(pos)
	var frac := pos - float(base)
	if base >= n - 1:
		return float(ordenadas[n - 1])
	return lerpf(float(ordenadas[base]), float(ordenadas[base + 1]), frac)

## Devuelve el resumen consolidado de TODAS las métricas del escenario.
## Formato: { nombre_metrica: {p50,p95,max,count}, ... }
func resumen_metricas() -> Dictionary:
	var out: Dictionary = {}
	for nombre_metrica in _metricas:
		out[nombre_metrica] = _resumen_metrica(_metricas[nombre_metrica])
	return out

## Medición de tiempo de una Callable (ms). Devuelve {ms, resultado}.
func _medir_ms(callable_ejecutar: Callable) -> Dictionary:
	var inicio := Time.get_ticks_msec()
	var resultado: Variant = callable_ejecutar.call()
	var duracion := Time.get_ticks_msec() - inicio
	return {"ms": duracion, "resultado": resultado}
