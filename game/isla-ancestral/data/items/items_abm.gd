# M159: datos de ABM del arbol de items (encargo director #794, agnes-3-flash 2026-10-22).
# Define los campos de gestion (drops/precios/stack/tier/durabilidad/slots/rareza/
# interacciones/regeneracion/festivales/bonificaciones) por categoria. Headless:
# es DATA pura (const) para que M14/M16/M38/M58 la consuman. No toca el render.

class_name ItemsABM
extends RefCounted

## Stack maximo por categoria (recursos apilan, herramientas 1).
const STACK_MAX: Dictionary = {
	"materiales": 99, "comida": 20, "minerales": 99, "herramientas": 1,
	"ropa": 1, "mobiliario": 1, "decoracion": 1, "iluminacion": 1,
	"planta": 99, "construccion": 25, "arte": 1, "evento": 10, "secreto": 1,
}

## Precios base de compra/venta por categoria (moneda M38). [compra, venta]
const PRECIOS: Dictionary = {
	"materiales": [5, 2], "comida": [8, 3], "minerales": [12, 6],
	"herramientas": [50, 20], "ropa": [30, 12], "mobiliario": [80, 40],
	"decoracion": [40, 18], "iluminacion": [45, 20], "planta": [3, 1],
	"construccion": [100, 50], "arte": [300, 150], "evento": [15, 5], "secreto": [500, 250],
}

## Stats por tier de herramientas T1-T4 (dano / durabilidad).
const TIER_STATS: Dictionary = {
	"t1": {"dano": 5, "durabilidad": 60},   # madera
	"t2": {"dano": 10, "durabilidad": 120},  # cobre
	"t3": {"dano": 18, "durabilidad": 240},  # hierro
	"t4": {"dano": 30, "durabilidad": 480},  # encantada
}

## Slots de vestimenta (M155): campo de equipo por item de ropa.
const SLOTS: Dictionary = {
	"cabeza": ["sombrero", "gorro", "bandana"],
	"cuerpo": ["camisa", "vestido", "abrigo", "sweater", "chaqueta"],
	"pies": ["zapatos", "botas", "sandalias", "zapatillas"],
	"accesorio": ["guantes", "bufanda", "amuleto"],
}

## Rareza de objetos ancestrales / secretos (solo Raro/Legendario).
const RAREZA_ESPECIAL: Dictionary = {"arte": "raro", "secreto": "legendario"}

## Interacciones por categoria (accion del jugador al interactuar).
const INTERACCIONES: Dictionary = {
	"cocina": ["cocinar", "hornear", "freir", "calentar"],
	"taller": ["fabricar", "forjar", "tallar"],
	"naturaleza": ["cortar", "minar", "recoger"],
	"construccion": ["abrir", "cerrar", "colocar"],
	"arte": ["mirar", "leer_lore"],
	"secreto": ["desbloquear_puzzle"],
}

## Drops de materiales al explotar/interactuar (tabla por recurso).
const DROP_TABLE: Dictionary = {
	"arbol_madera": [{"id": "obj_madera", "p": 1.0}, {"id": "obj_fibra", "p": 0.3}],
	"roca_mineral": [{"id": "obj_piedra", "p": 0.8}, {"id": "obj_mineral_cobre", "p": 0.25}],
	"arbusto": [{"id": "obj_fibra_algodon", "p": 0.5}, {"id": "obj_baya_roja", "p": 0.4}],
	"mina": [{"id": "obj_mineral_hierro", "p": 0.3}, {"id": "obj_obsidiana", "p": 0.05}],
}

## Tiempo de regeneracion de recursos naturales (en horas de juego, M29).
const REGENERACION_HORAS: Dictionary = {
	"arbol": 8, "arbusto": 3, "roca": 48, "mina": 120, "planta": 6,
}

## Bonificaciones por terreno/bioma (material/accion recibe +X% en su bioma nativo).
const BONO_TERRENO: Dictionary = {
	"madera_bosque": 0.2, "piedra_montana": 0.15, "fibras_pradera": 0.1,
	"mineral_cueva": 0.25, "arena_costa": 0.1,
}

## Festivales (items de evento asocian a un festival M29).
const FESTIVALES: Dictionary = {
	"obj_decor_primavera": "festival_sembrar", "obj_decor_verano": "festival_playa",
	"obj_decor_otoño": "festival_cosecha", "obj_decor_invierno": "festival_invierno",
}


## Devuelve el stack_max de un item segun su categoria. 1 si no se reconoce.
func stack_max(categoria: String) -> int:
	return int(STACK_MAX.get(categoria, 1))


## Precio de compra de un item de una categoria (int).
func precio_compra(categoria: String) -> int:
	return int(PRECIOS.get(categoria, [1, 0])[0])


## Precio de venta de un item de una categoria (int).
func precio_venta(categoria: String) -> int:
	return int(PRECIOS.get(categoria, [1, 0])[1])


## Durabilidad de una herramienta del tier dado (t1-t4).
func durabilidad_herramienta(tier: String) -> int:
	return int(TIER_STATS.get(tier, TIER_STATS["t1"])["durabilidad"])


## Interacciones validas de una categoria.
func interacciones(categoria: String) -> Array:
	return INTERACCIONES.get(categoria, [])


## ¿El item de una categoria es apilable?
func apilable(categoria: String) -> bool:
	return stack_max(categoria) > 1
