# Modelo: atria-dawn-preview
# Plataforma: Kilo Code
# Fecha: 2026-10-02
#
# M70: Interacciones - CatalogoCategorias (Resource).
# Fuente unica de las 8 categorias de interaccion (RF2). Cargado por el
# InteractionManager desde data/interacciones/categorias_interaccion.tres.
# Si el .tres tiene el arreglo vacio, se rellena con las 8 categorias por
# defecto (DEFAULT_CATEGORIAS) para que el modulo nunca quede sin catalogo.
#
# Nota: preload (no class_name) para que el modulo compile tambien en
# --script headless, donde el registro global de class_name no se construye.

class_name CatalogoCategorias
extends Resource

const CategoriaInteraccionGd := preload("res://scripts/interacciones/categoria_interaccion.gd")

@export var categorias: Array[CategoriaInteraccionGd] = []

# 8 categorias por defecto (RF2). prioridad_base: mayor = mas prioritario.
# requiere_vision segun RF4 (npc, cofre, puerta, evento).
const DEFAULT_CATEGORIAS := {
	&"npc": [100, "M70_CAT_NPC", true],
	&"cofre": [90, "M70_CAT_COFRE", true],
	&"puerta": [80, "M70_CAT_PUERTA", true],
	&"evento": [70, "M70_CAT_EVENTO", true],
	&"cosecha": [60, "M70_CAT_COSECHA", false],
	&"animal": [50, "M70_CAT_ANIMAL", false],
	&"objeto": [30, "M70_CAT_OBJETO", false],
	&"decorativo": [10, "M70_CAT_DECORATIVO", false],
}

func _init() -> void:
	if categorias.is_empty():
		categorias = _construir_defaults()

func _construir_defaults() -> Array[CategoriaInteraccionGd]:
	var out: Array[CategoriaInteraccionGd] = []
	for id_cat in DEFAULT_CATEGORIAS:
		var cfg = DEFAULT_CATEGORIAS[id_cat]
		var c := CategoriaInteraccionGd.new()
		c.id = id_cat
		c.prioridad_base = int(cfg[0])
		c.etiqueta = String(cfg[1])
		c.requiere_vision = bool(cfg[2])
		out.append(c)
	return out

func obtener(id_cat) -> Resource:
	var clave := StringName(id_cat) if id_cat != null else &""
	if clave == &"":
		return null
	for c in categorias:
		if c != null and c.id == clave:
			return c
	return null

func prioridad_de(id_cat) -> int:
	var c = obtener(id_cat)
	return c.prioridad_base if c != null else 0

func requiere_vision(id_cat) -> bool:
	var c = obtener(id_cat)
	return c.requiere_vision if c != null else false

func etiqueta_de(id_cat) -> String:
	var c = obtener(id_cat)
	return c.etiqueta if c != null else ""

func tiene(id_cat) -> bool:
	return obtener(id_cat) != null

func cantidad() -> int:
	return categorias.size()
