# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25

class_name ItemData
extends Resource

# Catálogo maestro de objetos del juego (M159).
# Resource serializable (.tres) que describe cada objeto coleccionable/colocable.
# Diseño: MiMo V2.5 → plan-actual/04-Codigo.md §2.1

## Categorías del catálogo (16).
enum Categoria {
	MOBILIARIO_INTERIOR,     # CAT-01 — OBJ-MES/SIL/CAM/EST
	DECORACION_PARED,        # CAT-02 — OBJ-CUA/ESP/REL
	ILUMINACION,             # CAT-03 — OBJ-LUZ
	PLANTAS_INTERIOR,        # CAT-04 — OBJ-PLA
	ALFOMBRAS,               # CAT-05 — OBJ-ALF
	COCINA,                  # CAT-06 — OBJ-COC
	TRABAJO,                 # CAT-07 — OBJ-TAL
	EXTERIORES,              # CAT-08 — OBJ-EXT
	NATURALEZA,              # CAT-09 — OBJ-NAT
	CONSTRUCCION,            # CAT-10 — OBJ-CON
	HERRAMIENTAS,            # CAT-11 — OBJ-HER
	ITEMS,                   # CAT-12 — OBJ-ITE
	ROPA,                    # CAT-13 — OBJ-ROP
	ARTE_ANCESTRAL,          # CAT-14 — OBJ-ART
	EVENTO,                  # CAT-15 — OBJ-EVE
	SECRETO,                 # CAT-16 — OBJ-SEC
}

## Rareza del objeto (4 niveles).
enum Rareza {
	COMUN,     # gris  60%
	POCHO_COMUN, # verde 25%
	RARO,       # azul 12%
	LEGENDARIO, # dorado 3%
}

## Tipos de interacción del jugador con el objeto (hasta 13).
enum Interaccion {
	NINGUNA = 0,
	SENTARSE = 1,
	DORMIR = 2,
	ALMACENAR = 3,
	COCINAR = 4,
	FABRICAR = 5,
	ENCENDER = 6,
	REGAR = 7,
	COLOCAR_ITEM = 8,
	MIRAR = 9,
	ESCULAR = 10,
	RECOGER = 11,
	ROMPER = 12,
	ABRIR_CERRAR = 13,
}

# --- Campos exportados (ver plan-actual/04-Codigo.md §2.1) ---

@export var id: String = ""
@export var nombre: String = ""
@export var descripcion: String = ""
@export var categoria: Categoria = Categoria.ITEMS
@export var subcategoria: String = ""
@export var tamano: Vector2i = Vector2i(1, 1)
@export var interactivo: bool = false
@export var interacciones: Array[Interaccion] = []
@export var fuente: String = ""
@export var precio_compra: int = 0
@export var precio_venta: int = 0
@export var rareza: Rareza = Rareza.COMUN
@export var apilable: bool = true
@export var stack_max: int = 10
@export var material: String = ""
@export var color: String = ""
@export var variante: String = ""
@export var requiere_herramienta: String = ""
@export var exportable: bool = true
@export var icono: Texture2D = null      # M45 — placeholder opcional
@export var modelo_3d: PackedScene = null  # M45 — placeholder opcional

## Devuelve `true` si el objeto puede apilarse y aún tiene cupo.
func se_puede_apilar(cantidad_actual: int) -> bool:
	return apilable and cantidad_actual < stack_max

## Valida que los campos críticos de identidad estén presentes.
func es_valido() -> bool:
	return id != "" and nombre != "" and not tamano.x <= 0 or tamano.y <= 0
