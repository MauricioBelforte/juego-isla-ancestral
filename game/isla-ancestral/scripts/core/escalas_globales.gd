# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M45/M50/M36/M19: EscalasGlobales (autoload) — tabla ÚNICA de escalas de
# TODOS los objetos del juego (5-FUTURAS-MEJORAS "Estandarizar tamaños").
#  - Data-driven: data/escalas/escalas.json (vegetación, fauna, NPCs, props)
#  - escala_de(tipo) busca en todas las categorías (substring match)
#  - Fallback: 1.0 (tamaño GLB original) si el tipo no está en la tabla
#  - El usuario ajusta valores con capturas visuales (M154 iterativo)
# Referencia de mundo: personaje=1.8m, voxel=1m.
# ⚠️ Sin class_name: es autoload (07-GUIA §9.17).
extends Node

const RUTA: String = "res://data/escalas/escalas.json"

var _escalas: Dictionary = {}


func _ready() -> void:
	_cargar()


func _cargar() -> void:
	var texto := FileAccess.get_file_as_string(RUTA)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[Escalas] escalas.json inválido; fallback 1.0 para todo")
		return
	for categoria in parseado:
		if categoria.begins_with("_"):
			continue
		var tabla: Variant = parseado[categoria]
		if typeof(tabla) == TYPE_DICTIONARY:
			for clave in tabla:
				_escalas[String(clave)] = float(tabla[clave])
	print("[Escalas] Tabla cargada: %d tipos" % _escalas.size())


## Escala de un tipo de objeto. Busca por substring (ej. "arbol_frutal" matchea
## "arbol"). Fallback: 1.0 (GLB original) si no está en la tabla.
func escala_de(tipo: String) -> float:
	var t := tipo.to_lower()
	# Match exacto primero
	if _escalas.has(t):
		return float(_escalas[t])
	# Match por substring (el GLB puede venir con prefijos: 50-Vegetacion_)
	for clave in _escalas:
		if t.contains(String(clave)) or String(clave).contains(t):
			return float(_escalas[clave])
	return 1.0


## Recargar (para iteración visual en vivo desde el editor/DebugMenu)
func recargar() -> void:
	_cargar()
