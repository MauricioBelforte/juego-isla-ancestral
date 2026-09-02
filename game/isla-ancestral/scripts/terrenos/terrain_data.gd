# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M156: Terrenos y Movimiento — TerrainData (Resource, diseño §1.5).
# Datos configurables de un tipo de terreno: modificador de velocidad,
# feedback visual/audio (V2 con dueño), color de debug.
class_name TerrainData
extends Resource

## Identificador del terreno (0-6 según §4.1)
@export var terrain_id: int = 0
@export var terrain_name: String = ""
## Modificador de velocidad (0.6-1.0 según diseño; 1.0 = sin cambio)
@export var speed_modifier: float = 1.0

# Configuración visual (V2 — dueño M45/M52; placeholders para el sistema)
@export var visual_config: Dictionary = {
	"footprint_scene": null,
	"particle_scene": null,
	"footprint_intensity": 0.5,
	"particle_intensity": 0.5
}

# Configuración audio (V2 — dueño M42/M44)
@export var audio_config: Dictionary = {
	"footstep_sounds": [],
	"volume": 0.5,
	"pitch_variation": 0.05
}

@export var debug_color: Color = Color.WHITE
