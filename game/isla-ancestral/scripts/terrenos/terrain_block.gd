extends StaticBody3D

## Bloque de terreno base (M156). Hereda de StaticBody3D para colision fisica.
## Valores por tipo provienen de data/terrenos/terrenos.json (L1).

@export var terrain_type: String = "ceped"
@export var friction: float = 0.8
@export var dust_color: Color = Color(0.4, 0.75, 0.3)
@export var dust_intensity: float = 2.0

func _ready() -> void:
	# Asignar layer segun tipo de terreno (M156)
	collision_layer = _layer_for_type(terrain_type)
	# Cargar valores desde data (L1 - variantes por script)
	_load_from_data(terrain_type)

func _layer_for_type(t: String) -> int:
	match t:
		"ceped": return 1
		"barro": return 2
		"pavimento": return 4
		"arena": return 8
		"agua": return 16
		"nieve": return 32
		"rocas": return 64
		_: return 1

func _load_from_data(t: String) -> void:
	# Lee data/terrenos/terrenos.json y aplica modificador/friction/dust (L1+L2)
	var file := FileAccess.open("res://data/terrenos/terrenos.json", FileAccess.READ)
	if file == null: return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK: return
	var data = json.data
	if not data.has("terrenos"): return
	for terr in data["terrenos"]:
		if terr.get("nombre", "").to_lower() == t.to_lower():
			friction = terr.get("modificador", friction)
			if terr.has("particulas"):
				dust_intensity = terr["particulas"].get("intensidad", dust_intensity)
			break