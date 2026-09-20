# Modelo: deepseek-v4-flash (núcleo) · DeepSeek-V4.1-Flash (iter. 3)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-01 · 2026-09-19
#
# M62: Memoria — MemoryBudgetRegistry
# Presupuestos de RAM por sistema (RF2): tabla de topes por familia,
# verificación periódica, configuración data-driven (budgets.json).
# Diseño original (04-Codigo.md §2, BudgetRegistry).
#
# Iter. 3 (Log 1094): el dataset ya no es un archivo suelto sino un CONTRATO
# validado por `generar_budgets.gd`. Se añaden:
#   · `total_topes_mb()` — la suma de los TOPES. Antes sólo existía
#     `total_consumo_mb()` (consumo REPORTADO), y el enforcement comparaba la
#     memoria real del OS contra el consumo reportado: con 0 sistemas
#     reportando el total daba 0 y el enforcement NUNCA corría.
#   · gestión de preset (`preset()`, `set_preset()`, `presets_disponibles()`)
#     para que M90 pueda cambiar Baja/Media/Alta sin recargar el archivo.
#   · `porcentaje_de()` y `sistema_mas_critico()` para el semáforo por sistema.

class_name MemoryBudgetRegistry
extends RefCounted

const RUTA_BUDGETS := "res://data/rendimiento/budgets.json"

## Orden canónico de los 8 sistemas (diseño §2). Debe coincidir con el del
## generador validante (`generar_budgets.gd`) y con la tabla de 03-Diseno.md.
const SISTEMAS: Array[String] = [
	"voxel", "texturas", "audio", "escenas", "pools", "ui", "shaders", "reserva",
]

var _topes: Dictionary = {}       # sistema -> tope_mb
var _consumos: Dictionary = {}    # sistema -> consumo_mb reportado
var _presets: Dictionary = {}     # preset -> {sistema: tope_mb}
var _preset: String = ""

## Carga el dataset. Devuelve true si quedó utilizable.
func cargar() -> bool:
	_presets.clear()
	_topes.clear()
	if not FileAccess.file_exists(RUTA_BUDGETS):
		push_warning("[M62] budgets.json no encontrado: %s" % RUTA_BUDGETS)
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BUDGETS))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("[M62] budgets.json inválido (no es un objeto JSON)")
		return false
	var datos: Dictionary = parsed as Dictionary
	var crudos: Variant = datos.get("presets", {})
	if typeof(crudos) != TYPE_DICTIONARY or (crudos as Dictionary).is_empty():
		push_warning("[M62] budgets.json sin 'presets'")
		return false
	for nombre in (crudos as Dictionary):
		var bloque: Variant = (crudos as Dictionary)[nombre]
		if typeof(bloque) != TYPE_DICTIONARY:
			continue
		var sistemas: Dictionary = {}
		for s in (bloque as Dictionary):
			sistemas[String(s)] = int((bloque as Dictionary)[s])
		_presets[String(nombre)] = sistemas
	var activo := String(datos.get("preset_activo", ""))
	if not _presets.has(activo):
		activo = "media" if _presets.has("media") else String(_presets.keys()[0])
	return set_preset(activo)

## Aplica un preset: copia sus topes a la tabla activa.
func set_preset(nombre: String) -> bool:
	if not _presets.has(nombre):
		push_warning("[M62] preset inexistente: %s" % nombre)
		return false
	_preset = nombre
	_topes = (_presets[nombre] as Dictionary).duplicate()
	return true

func preset() -> String:
	return _preset

func presets_disponibles() -> Array:
	var nombres: Array = _presets.keys()
	nombres.sort()
	return nombres

func sistemas() -> Array:
	var nombres: Array = _topes.keys()
	nombres.sort()
	return nombres

## Suma de los TOPES del preset activo. Es el denominador del semáforo
## (diseño §3) y el presupuesto contra el que se mide la memoria real.
func total_topes_mb() -> int:
	var total := 0
	for sistema in _topes:
		total += int(_topes[sistema])
	return total

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
	sobre.sort()
	return sobre

func tope_de(sistema: String) -> int:
	return int(_topes.get(sistema, 0))

func consumo_de(sistema: String) -> int:
	return int(_consumos.get(sistema, 0))

## Consumo REPORTADO acumulado (no confundir con `total_topes_mb()`).
func total_consumo_mb() -> int:
	var total := 0
	for sistema in _consumos:
		total += int(_consumos[sistema])
	return total

## Ocupación de un sistema como fracción de su tope (0.0 si no hay tope).
func porcentaje_de(sistema: String) -> float:
	var tope := tope_de(sistema)
	if tope <= 0:
		return 0.0
	return snappedf(float(consumo_de(sistema)) / float(tope), 0.001)

## Sistema con mayor ocupación relativa ("" si no hay topes).
func sistema_mas_critico() -> String:
	var peor := ""
	var peor_pct := -1.0
	for sistema in _topes:
		var pct := porcentaje_de(String(sistema))
		if pct > peor_pct:
			peor_pct = pct
			peor = String(sistema)
	return peor
