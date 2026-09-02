# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M62: Memoria — MemoryBudgetRegistry
# Presupuestos de RAM por sistema (RF2): tabla de topes por familia,
# verificación periódica, configuración data-driven (budgets.json).
# Diseño original (04-Codigo.md §2, BudgetRegistry).

class_name MemoryBudgetRegistry
extends RefCounted

const RUTA_BUDGETS := "res://data/rendimiento/budgets.json"

var _topes: Dictionary = {}       # sistema -> tope_mb
var _consumos: Dictionary = {}    # sistema -> consumo_mb reportado

func cargar() -> void:
	if not FileAccess.file_exists(RUTA_BUDGETS):
		push_warning("[M62] budgets.json no encontrado: %s" % RUTA_BUDGETS)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BUDGETS))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("presets"):
		push_warning("[M62] budgets.json inválido")
		return
	var preset: String = parsed.get("preset_activo", "media")
	var familias: Dictionary = parsed.get("presets", {}).get(preset, {})
	for sistema in familias:
		_topes[String(sistema)] = int(familias[sistema])

func registrar_sistema(nombre: String, tope_mb: int) -> void:
	_topes[nombre] = tope_mb

func reportar_consumo(nombre: String, mb: int) -> void:
	_consumos[nombre] = mb

## Verifica qué sistemas están sobre su tope. Devuelve Array de nombres.
func verificar() -> Array:
	var sobre: Array = []
	for sistema in _topes:
		var consumo: int = _consumos.get(sistema, 0)
		if consumo > int(_topes[sistema]):
			sobre.append(sistema)
	return sobre

func tope_de(sistema: String) -> int:
	return int(_topes.get(sistema, 0))

func consumo_de(sistema: String) -> int:
	return int(_consumos.get(sistema, 0))

func total_consumo_mb() -> int:
	var total := 0
	for sistema in _consumos:
		total += int(_consumos[sistema])
	return total