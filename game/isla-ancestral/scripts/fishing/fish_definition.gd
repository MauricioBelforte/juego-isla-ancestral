# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: Pesca — FishDefinition + CeboDefinition + FishingRod (datos puros).
# Según 03-Diseno §2.3/2.4 y §4. Cargados desde data/balance/fishing.json (M93).

class_name FishDefinition
extends Resource

@export var id: String = ""
@export var nombre_es: String = ""
@export var biomas: Array[int] = []          # IDs de bioma M51 (vacío = todos)
@export var estaciones: Array[int] = []      # estación M29 (vacío = todas)
@export var franjas: Array[int] = []         # franjas M31 (vacío = todas)
@export var climas: Array[int] = []          # clima M32 (vacío = todos)
@export var peso_rareza: float = 1.0         # peso PRNG (común alto, raro bajo)
@export var tamano_min: float = 0.3
@export var tamano_max: float = 1.2
@export var valor_venta: int = 0
@export var cebos_preferidos: Array[String] = []
@export var pieza_museo: String = ""         # id de pieza M37 ("" = ninguna)
@export var id_receta: String = ""           # receta M15 ("" = ninguna)
@export var pity: int = 0                    # N capturas sin éxito suben la chance (0 = off)
