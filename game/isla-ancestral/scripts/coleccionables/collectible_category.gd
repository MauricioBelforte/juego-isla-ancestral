# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M73: Coleccionables - CollectibleCategory (Resource).
# Metadatos de una categoría de coleccionables: id, nombre i18n, descripción,
# icono path, total esperado, recompensas al completar, orden de exhibición.
# Se carga dinámicamente con load() desde tests y otros scripts.

extends Resource

## ID único de la categoría (coincide con keys del catálogo)
@export var id: StringName = &""
## Nombre en español (i18n placeholder — usar key para localización)
@export var nombre_es: String = ""
## Descripción breve de la categoría
@export var descripcion: String = ""
## Ruta al ícono (null si no tiene)
@export var icono_path: String = ""
## Total esperado de items en esta categoría (0 = infinito/dinámico)
@export var total_esperado: int = 0
## Recompensa por completar la categoría
@export var recompensa_item: StringName = &""
@export var recompensa_cantidad: int = 0
## Orden de exhibición en el museo (M55)
@export var orden_exposicion: int = 0
## Tags para filtrado (ej: ["fauna", "naturaleza"])
@export var tags: Array[StringName] = []
## Categoría padre para jerarquías (null = raíz)
@export var categoria_padre: StringName = &""


## ── API pública ─────────────────────────────────────────────

## Devuelve verdadero si la categoría está completa (total_esperado > 0 y alcanzado)
func esta_completa(collected_count: int) -> bool:
	if total_esperado <= 0:
		return false
	return collected_count >= total_esperado


## Devuelve porcentaje 0..1 de progreso
func progreso(collected_count: int) -> float:
	if total_esperado <= 0:
		return 0.0
	return float(collected_count) / float(total_esperado)


## Serialización a Dictionary (para logs y debugging)
func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"nombre_es": nombre_es,
		"descripcion": descripcion,
		"icono_path": icono_path,
		"total_esperado": total_esperado,
		"recompensa_item": String(recompensa_item),
		"recompensa_cantidad": recompensa_cantidad,
		"orden_exposicion": orden_exposicion,
		"tags": [String(t) for t in tags],
	}


## Carga categorías desde un Dictionary parseado de JSON
static func cargar_desde_json(datos: Dictionary) -> Array:
	"""Retorna Array de CollectibleCategory instanciados."""
	var categorias: Array = []
	for entry in datos.get("categorias", []):
		if not (entry is Dictionary):
			continue
		var cat := CollectibleCategory.new()
		cat.id = StringName(String(entry.get("id", "")))
		cat.nombre_es = String(entry.get("nombre_es", String(cat.id)))
		cat.descripcion = String(entry.get("descripcion", ""))
		cat.icono_path = String(entry.get("icono_path", ""))
		cat.total_esperado = int(entry.get("total_esperado", 0))
		cat.recompensa_item = StringName(String(entry.get("recompensa_item", "")))
		cat.recompensa_cantidad = int(entry.get("recompensa_cantidad", 0))
		cat.orden_exposicion = int(entry.get("orden_exposicion", 0))
		var raw_tags = entry.get("tags", [])
		if raw_tags is Array:
			for t in raw_tags:
				if t is String or t is StringName:
					cat.tags.append(StringName(String(t)))
		categorias.append(cat)
	return categorias


## Catálogo fallback construido desde exhibiciones.json + catalog.json
static func crear_catalogo_fallback() -> Dictionary:
	return {
		"categorias": [
			{
				"id": "minerales",
				"nombre_es": "Minerales",
				"descripcion": "Vetas y minerales encontrados en las ruinas mineras",
				"total_esperado": 5,
				"recompensa_item": "moneda_ancestral",
				"recompensa_cantidad": 500,
				"orden_exposicion": 1,
				"tags": ["minería", "recursos"],
			},
			{
				"id": "animales",
				"nombre_es": "Animales",
				"descripcion": "Especies avistadas en la isla",
				"total_esperado": 4,
				"recompensa_item": "moneda_ancestral",
				"recompensa_cantidad": 300,
				"orden_exposicion": 2,
				"tags": ["fauna", "naturaleza"],
			},
			{
				"id": "conchas",
				"nombre_es": "Conchas",
				"descripcion": "Conchas encontradas en la playa",
				"total_esperado": 3,
				"recompensa_item": "moneda_ancestral",
				"recompensa_cantidad": 200,
				"orden_exposicion": 3,
				"tags": ["playa", "mar"],
			},
			{
				"id": "reliquias",
				"nombre_es": "Reliquias",
				"descripcion": "Artefactos ancestrales de ruinas y templos",
				"total_esperado": 3,
				"recompensa_item": "gema_ancestral",
				"recompensa_cantidad": 1,
				"orden_exposicion": 4,
				"tags": ["ruinas", "templos", "ancestral"],
			},
			{
				"id": "plantas",
				"nombre_es": "Plantas",
				"descripcion": "Flores, hierbas y cultivos raros",
				"total_esperado": 0,
				"recompensa_item": "",
				"recompensa_cantidad": 0,
				"orden_exposicion": 5,
				"tags": ["agricultura", "naturaleza"],
			},
			{
				"id": "peces",
				"nombre_es": "Peces",
				"descripcion": "Especies de peces del archipiélago",
				"total_esperado": 0,
				"recompensa_item": "",
				"recompensa_cantidad": 0,
				"orden_exposicion": 6,
				"tags": ["pesca", "mar"],
			},
		],
	}
