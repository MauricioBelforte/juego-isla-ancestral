# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33: Agricultura — CropDefinition (Resource, datos por cultivo).
# Según 03-Diseno §2.1. Los catálogos se cargan desde data/balance/farming.json
# (M93) vía FarmService. Estaciones: enum del GameClock (M29) — aquí se manejan
# como Array[int] para no acoplarse al autoload.

class_name CropDefinition
extends Resource

@export var crop_id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var seasons: Array[int] = []         # estaciones donde crece (M29)
@export var grow_days: int = 4               # días hasta LISTA sin fertilizante
@export var stage_count: int = 4             # etapas visuales (2..6)
@export var water_need: int = 1              # agua requerida por día (1 o 2)
@export var yield_item_id: StringName = &""  # ítem principal de la cosecha
@export var yield_amount_min: int = 1
@export var yield_amount_max: int = 3
@export var yield_seed_id: StringName = &""  # semilla reproducida al cosechar (opcional)
@export var yield_seed_amount: int = 0
@export var quality_levels: bool = false     # expone COMUN/BUENA/EXCELENTE
@export var is_tree: bool = false            # perenne (no replantar)
@export var is_flower: bool = false          # decorativa / cruce
@export var is_ancestral: bool = false       # desbloqueo narrativo M22
@export var decorative_only: bool = false    # sin ítems
@export var rare: bool = false               # P23: semilla rara
@export var unlock_min_days: int = 0         # P23/P11: días de progresión para desbloquear (0 = libre)
@export var island_exclusive: bool = false   # P24: exclusiva de la isla
@export var hybrid_of: Array[StringName] = []  # P15: padres del híbrido (regla legible, sin RNG)
@export var fertilizer_bonus: int = 0        # días que reduce (fer M13)

## Color del placeholder visual por cultivo (hasta assets del arte M47).
func color_visual() -> Color:
	match crop_id:
		&"tomate": return Color(0.85, 0.25, 0.2)
		&"zanahoria": return Color(0.9, 0.55, 0.2)
		&"calabaza": return Color(0.85, 0.5, 0.15)
		&"tela_lino", &"algodon": return Color(0.85, 0.85, 0.75)
		&"trigo_invernal": return Color(0.85, 0.75, 0.45)
		&"higo": return Color(0.55, 0.3, 0.55)
		&"maiz_ancestral": return Color(0.95, 0.85, 0.3)
		&"flor_tulipan": return Color(0.9, 0.35, 0.45)
		&"flor_lavanda": return Color(0.6, 0.45, 0.85)
		&"lirio_estelar": return Color(0.75, 0.65, 0.95)
		&"trigo_estelar": return Color(0.98, 0.9, 0.55)
		&"palma_coco": return Color(0.75, 0.65, 0.45)
		&"flor_coral": return Color(0.95, 0.45, 0.5)
		_: return Color(0.35, 0.65, 0.3)

## P15: clave canónica del cruce (par de padres ordenado alfabéticamente).
## Regla legible: el híbrido depende SOLO de los padres, nunca del azar.
func clave_cruce() -> String:
	var partes: Array = []
	for p in hybrid_of:
		partes.append(String(p))
	partes.sort()
	return "|".join(partes)
