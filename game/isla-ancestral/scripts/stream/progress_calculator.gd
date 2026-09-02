# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M63: Cargas y Streaming — ProgressCalculator
# Cálculo de progreso real por pesos (04-Codigo.md §1.1): cada operación
# tiene un peso; el progreso de la cola = pesos completados / pesos totales.
# Diseño original (04-Codigo.md §1.1, progress_calculator.gd).

class_name ProgressCalculator
extends RefCounted

static func calcular_peso_total(cola: Array) -> int:
	var total := 0
	for op in cola:
		total += int(op.get("peso", 1))
	return total

## progreso en [0.0, 1.0]: completados (peso) / total (peso)
static func progreso(pesos_completados: int, peso_total: int) -> float:
	if peso_total <= 0:
		return 1.0
	return clampf(float(pesos_completados) / float(peso_total), 0.0, 1.0)

## Pesos por tipo de operación (data-driven: weights.json)
static func peso_de_tipo(tipo: String, weights: Dictionary = {}) -> int:
	if weights.has(tipo):
		return int(weights[tipo])
	match tipo:
		"escena": return 10
		"chunk": return 2
		"region": return 5
		"textura": return 1
		_:
			return 1