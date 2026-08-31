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
@export var fertilizer_bonus: int = 0        # días que reduce (fer M13)

## Color del placeholder visual por cultivo (hasta assets del arte M47).
func color_visual() -> Color:
	match crop_id:
		&"tomate": return Color(0.85, 0.25, 0.2)
		&"zanahoria": return Color(0.9, 0.55, 0.2)
		&"calabaza": return Color(0.85, 0.5, 0.15)
		&"tela_lino", &"algodon": return Color(0.85, 0.85, 0.75)
		_: return Color(0.35, 0.65, 0.3)
