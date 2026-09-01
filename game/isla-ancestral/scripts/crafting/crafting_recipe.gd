# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M16: Crafting — CraftingRecipe (Resource con los datos de una receta).
# Modelo de datos según 03-Diseno §1.2. Las recetas se cargan desde
# data/balance/crafting.json (fuente de datos M93) vía CraftingService.

class_name CraftingRecipe
extends Resource

enum Categoria { HERRAMIENTAS, ESTRUCTURA, TEXTILES, COCINA, DECORACION, ANCESTRAL, OCULTA }
enum Estacion { MESA_TRABAJO, FOGATA, TELAR }
enum Origen { INICIAL, EXPERIMENTACION, COMPRA, EVENTO }

@export var id: String = ""
@export var nombre: String = ""
@export var categoria: int = Categoria.ESTRUCTURA
@export var nivel: int = 1
@export var estacion: int = Estacion.MESA_TRABAJO
@export var materiales: Dictionary = {}   # {item_id: cantidad}
@export var coste_ao: int = 0
@export var resultado_id: String = ""
@export var resultado_cantidad: int = 1
@export var origen: int = Origen.INICIAL
@export var precio_pergamino: int = 0
@export var tags: Array[String] = []
@export var temporadas: Array[String] = []  # RF5: vacío = siempre; ["primavera","verano"] = solo esas

## Categorías de texto → enum (para carga data-driven)
const CATEGORIAS_TEXTO := {
	"herramientas": Categoria.HERRAMIENTAS,
	"estructura": Categoria.ESTRUCTURA,
	"textiles": Categoria.TEXTILES,
	"cocina": Categoria.COCINA,
	"decoracion": Categoria.DECORACION,
	"ancestral": Categoria.ANCESTRAL,
	"oculta": Categoria.OCULTA,
}

const ESTACIONES_TEXTO := {
	"mesa_trabajo": Estacion.MESA_TRABAJO,
	"fogata": Estacion.FOGATA,
	"telar": Estacion.TELAR,
}

const ORIGENES_TEXTO := {
	"inicial": Origen.INICIAL,
	"experimentacion": Origen.EXPERIMENTACION,
	"compra": Origen.COMPRA,
	"evento": Origen.EVENTO,
}

const ESTACIONES_ANYO_TEXTO := {
	"primavera": 0,
	"verano": 1,
	"otono": 2,
	"invierno": 3,
}

## ── RF5: filtrado estacional (M29) ────────────────────────

## Indica si la receta es fabricable en la estacion actual del juego.
## estacion: int (0..3) = GameTime.get_estacion(). Si temporadas vacío => siempre.
func es_fabricable_ahora(estacion_actual: int) -> bool:
	if temporadas.is_empty():
		return true
	for t in temporadas:
		var clave: String = str(t).to_lower().strip_edges()
		if ESTACIONES_ANYO_TEXTO.has(clave):
			if int(ESTACIONES_ANYO_TEXTO[clave]) == int(estacion_actual):
				return true
	return false

## Etiquetas legibles para UI.
func etiquetas_temporadas() -> String:
	if temporadas.is_empty():
		return "todo el año"
	return ", ".join(temporadas)
