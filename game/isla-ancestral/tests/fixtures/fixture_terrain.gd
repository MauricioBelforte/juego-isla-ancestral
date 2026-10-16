# Modelo: DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
# Plataforma: OpenCode
# Fecha: 2026-10-16
#
# M112 — L154: Fixture de terreno — terreno voxel MÍNIMO con seed fija.
#
# Diseño (03-Diseno.md §3): un terreno voxel real (mismo generador del mundo,
# res://scripts/world/world_generator.gd) pero con isla diminuta y pocos chunks,
# para tests de generación/biome deterministas. NO es el terreno de producción:
# radio 128 y altura 24 (el mundo real usa 2560/40).
#
# Determinismo: SEED_FIJA constante + generador del mundo (semilla fija →
# generación determinista, world_generator.gd §semilla). El VoxelViewer
# (cursor de generación) se posiciona en el centro real del mundo tomado del
# punto único de verdad (mundo_raiz.gd) — mismos criterios que main_island.gd.

extends Node3D

const MUNDO_RAIZ = preload("res://scripts/world/mundo_raiz.gd")

## Semilla fija: todo test que use este fixture ve el mismo terreno.
const SEED_FIJA := 12345
## Isla diminuta del fixture (mundo real: 2560).
const RADIO_FIXTURE := 128
## Altura máxima del fixture (mundo real: 40).
const MAX_HEIGHT_FIXTURE := 24
## Radio de generación en metros: "pocos chunks" alrededor del centro.
const DISTANCIA_VISTA := 48.0

@onready var terrain: VoxelTerrain = $VoxelTerrain
@onready var viewer: VoxelViewer = $VoxelViewer

var _generador: VoxelGeneratorScript = null


func _ready() -> void:
	# Mesher mínimo (aire + bloque) — mismo recetario probado que minimal_test.gd.
	var mesher := VoxelMesherBlocky.new()
	var library := VoxelBlockyLibrary.new()
	var air := VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
	var cube := VoxelBlockyModelCube.new()
	cube.set_name("block")
	library.add_model(cube)
	library.bake()
	mesher.library = library
	terrain.mesher = mesher

	# Generador REAL del mundo con seed fija y perfil diminuto.
	_generador = load("res://scripts/world/world_generator.gd").new()
	_generador.world_seed = SEED_FIJA
	_generador.island_radius = RADIO_FIXTURE
	_generador.max_height = MAX_HEIGHT_FIXTURE
	terrain.generator = _generador

	# Diferido: evita el ERROR "!is_inside_tree()" de get_global_transform
	# (BUG-024, mismo patrón que main_island.gd L142).
	viewer.view_distance = DISTANCIA_VISTA
	viewer.set_deferred("global_position", centro_mundo())


## Semilla fija del fixture: los tests generan siempre el mismo terreno.
func seed_fija() -> int:
	return SEED_FIJA


## Centro de la isla en coordenadas del mundo (mundo_raiz.gd — fuente única).
func centro_mundo() -> Vector3:
	return Vector3(MUNDO_RAIZ.CENTRO.x, 30.0, MUNDO_RAIZ.CENTRO.y)


## Generador configurado: permite consultar get_block_at sin esperar chunks.
func generador() -> VoxelGeneratorScript:
	return _generador
