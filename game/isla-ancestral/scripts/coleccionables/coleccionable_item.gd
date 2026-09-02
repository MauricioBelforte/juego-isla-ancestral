# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M73: Coleccionables - ColeccionableItem (Resource).
# Datos puros de un item coleccionable: id unico, categoria, nombre, icono path, fuente (donde se obtiene), recompensa.
# Sin class_name (07-GUIA-GODOT §9.17): se instancia via .new() o preload.

extends Resource

## Categoria del item (segun el plan: reliquias, fragmentos, conchas, minerales, peces, plantas, ancestrales, animales, etc.)
@export var categoria: StringName = &""
## Identificador unico dentro de la categoria. Se compone con la categoria para formar el id global.
@export var id_local: StringName = &""
## Nombre legible (sin localizacion en iter 1)
@export var display_name: String = ""
## Rareza (COMUN, POCO_COMUN, RARA, MUY_RARA, UNICA) - heredamos semantica de M36
@export var rareza: int = 0
## Fuente: como se obtiene (mineria, pesca, cosecha, fotografia, faunaregistry, etc.)
@export var fuente: StringName = &""
## ID del item que se otorga como recompensa al completar la coleccion (de esta categoria)
@export var recompensa_item: StringName = &""
## Cantidad de la recompensa
@export var recompensa_cantidad: int = 0
## Multiplicador de puntos M74 (opcional)
@export var puntos: int = 10

## ── API publica ─────────────────────────────────────────────

## Devuelve el id global (categoria + id_local)
func id_global() -> StringName:
	return StringName(String(categoria) + "_" + String(id_local))

## Valida que el item tiene los datos minimos
func es_valido() -> bool:
	if categoria == &"" or id_local == &"":
		return false
	if display_name.is_empty():
		return false
	return true

## Serializacion minima (para logs y persistencia)
func to_dict() -> Dictionary:
	return {
		"id": String(id_global()),
		"categoria": String(categoria),
		"display_name": display_name,
		"rareza": rareza,
		"fuente": String(fuente),
		"puntos": puntos,
	}
