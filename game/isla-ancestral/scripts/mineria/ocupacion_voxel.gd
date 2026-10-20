# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-20
#
# M35: validacion de ocupacion REUTILIZANDO la API de lectura de M08
# (item de la seccion G de 05-Checklist.md: "Validacion de ocupacion
# reutilizando API de lectura M08").
#
# NUCLEO PURO: no referencia autoloads ni escenas. El terreno se recibe por
# parametro y se consume por DUCK TYPING (`has_method("get_voxel_tool")`), igual
# que `farm_service.gd` (M33) y `construccion_mundo.gd` (M17). Eso permite
# inyectar un terreno fake en headless: el VoxelTerrain real NO genera bloques
# en `--script` (medido: `updated_blocks = 0`, Log 2028), asi que un test contra
# el terreno real daria un falso verde.
#
# SEMANTICA (medida, no supuesta): la veta se posiciona con TerrainLocator
# SOBRE el terreno (resource_spawner.gd:96 -> `posicionar_sobre_terreno`), o sea
# en la celda de AIRE que hay encima del suelo. Por eso "libre" = el voxel de su
# celda es AIR. Si alguien construyo encima (M17 escribe voxels con
# `escribir_voxel`), el bloque deja de ser AIR y la celda queda ocupada.
#
# TRES ESTADOS, no dos: "no hay terreno" o "no se puede leer" NO es lo mismo que
# "libre". Un booleano que colapse ambos produce el falso verde clasico (todo
# libre porque no se pudo leer). El llamador decide con `politica_sin_datos`.

class_name OcupacionVoxel
extends RefCounted

## La celda no tiene nada solido: la veta puede aparecer.
const LIBRE: StringName = &"libre"
## La celda tiene un bloque solido (terreno, construccion M17, agua).
const BLOQUEADA: StringName = &"bloqueada"
## No hay terreno o no se pudo leer: NO se sabe. Nunca se asume LIBRE.
const DESCONOCIDA: StringName = &"desconocida"

## Lo que devuelve `leer_bloque()` cuando no hay lectura posible.
const ID_DESCONOCIDO: int = -1

## ── Lectura de M08 ──────────────────────────────────────────────────────────

## Celda voxel que contiene una posicion mundial. Convencion de M17
## (`construccion_mundo.gd`): la celda (x,y,z) ocupa [x,x+1) x [y,y+1) x [z,z+1),
## asi que el centro esta en (x+0.5, y+0.5, z+0.5). Se usa floor en los 3 ejes,
## NO trunc: trunc(-0.5) = 0 pero la celda correcta es -1.
static func celda_de(pos: Vector3) -> Vector3i:
	return Vector3i(int(floor(pos.x)), int(floor(pos.y)), int(floor(pos.z)))

## Lee el bloque de M08 en una celda. Devuelve `ID_DESCONOCIDO` (-1) si no hay
## terreno, si no expone `get_voxel_tool()` o si la herramienta no responde.
## El `& 0xFF` es el mismo que usan M17 y M33: el canal TYPE trae el id en el
## byte bajo y basura en los altos.
static func leer_bloque(terrain: Node, celda: Vector3i) -> int:
	if terrain == null or not is_instance_valid(terrain):
		return ID_DESCONOCIDO
	if not terrain.has_method("get_voxel_tool"):
		return ID_DESCONOCIDO
	var vt = terrain.get_voxel_tool()
	if vt == null or not vt.has_method("get_voxel"):
		return ID_DESCONOCIDO
	# `get_voxel_tool()` devuelve una instancia NUEVA: hay que fijar el canal
	# en cada lectura o se lee el canal por defecto (mismo defecto documentado
	# en farm_service.gd:177).
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	return int(vt.get_voxel(celda)) & 0xFF

## Clasifica un id de bloque en los tres estados. El agua (WATER /
## SHALLOW_WATER) cuenta como BLOQUEADA: una veta no debe aparecer dentro del
## agua. Cualquier id distinto de AIR es un bloque solido para este criterio.
static func clasificar(id: int) -> StringName:
	if id == ID_DESCONOCIDO:
		return DESCONOCIDA
	if id == BlockType.AIR:
		return LIBRE
	return BLOQUEADA

## Estado de ocupacion de una posicion mundial.
static func estado_en(terrain: Node, pos: Vector3) -> StringName:
	return clasificar(leer_bloque(terrain, celda_de(pos)))

## true si la posicion esta ocupada. `politica_sin_datos` decide el caso
## DESCONOCIDA: LIBRE (por defecto, conserva el comportamiento historico: si no
## hay mundo, la veta respawnea igual) o BLOQUEADA (fail-closed: sin datos no se
## respawnea). Nunca se colapsa el caso "no se pudo leer" en "libre" por
## accidente: hay que pedirlo explicitamente.
static func esta_ocupada(terrain: Node, pos: Vector3, politica_sin_datos: StringName = LIBRE) -> bool:
	var estado: StringName = estado_en(terrain, pos)
	if estado == BLOQUEADA:
		return true
	if estado == DESCONOCIDA:
		return politica_sin_datos == BLOQUEADA
	return false

## Predicado `Callable(Vector3) -> bool` compatible con
## `MiningManager.barrido_regeneracion(..., ocupado)`. Captura el terreno y la
## politica por valor en el momento de crearlo.
static func crear_predicado(terrain: Node, politica_sin_datos: StringName = LIBRE) -> Callable:
	return func(pos: Vector3) -> bool:
		return esta_ocupada(terrain, pos, politica_sin_datos)
