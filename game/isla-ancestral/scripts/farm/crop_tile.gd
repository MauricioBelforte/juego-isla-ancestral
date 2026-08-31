# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33: Agricultura — CropTile (estado de UN voxel cultivado).
# RefCounted ligero según 03-Diseno §2.3. Métodos puros; la orquestación
# (inventario, eventos) vive en FarmService.

class_name CropTile
extends RefCounted

enum GrowthStage { SEMILLA = 0, BROTE = 1, CRECIENDO = 2, MADURA = 3, LISTA = 4, DORMANTE = 5, SIN_AGUA = 6 }

var voxel_pos: Vector3i
var crop_def: CropDefinition
var stage: int = GrowthStage.SEMILLA
var grown_days: int = 0
var water_level: int = 0
var fertilized: bool = false
var quality: int = 0        # 0 COMUN / 1 BUENA / 2 EXCELENTE
var planted_at_day: int = 0
var prev_stage: int = GrowthStage.SEMILLA  # etapa previa a pausa (reanudar)
var fruit_cooldown: int = 0                 # árboles frutales: días hasta nueva fruta

func is_ready() -> bool:
	return stage == GrowthStage.LISTA

func is_paused() -> bool:
	return stage == GrowthStage.DORMANTE or stage == GrowthStage.SIN_AGUA

func current_stage_index() -> int:
	return stage

## ¿Puede avanzar hoy? (estación apta y agua suficiente)
func can_advance_today(season: int, rain: bool) -> bool:
	if is_ready() or stage == GrowthStage.LISTA:
		return false
	if crop_def == null:
		return false
	var estacion_apta: bool = crop_def.seasons.is_empty() or crop_def.seasons.has(season)
	if not estacion_apta:
		return false
	var agua_efectiva: int = 2 if rain else water_level
	return agua_efectiva >= crop_def.water_need

## Tick diario (llamado por FarmService.advance_day en orden de estación apta).
## Devuelve true si cambió de etapa (para evento/sonido).
func apply_daily_tick(season: int, rain: bool) -> bool:
	if crop_def == null:
		return false
	var estacion_apta: bool = crop_def.seasons.is_empty() or crop_def.seasons.has(season)
	# Pausa por estación (regla cozy: DORMANTE nunca retrocede)
	if not estacion_apta:
		return _entrar_pausa(CropTile.GrowthStage.DORMANTE)
	# Pausa por agua
	var agua_efectiva: int = 2 if rain else water_level
	if agua_efectiva < crop_def.water_need:
		return _entrar_pausa(CropTile.GrowthStage.SIN_AGUA)
	# Activo: reanudar si venía de pausa (misma etapa, mismos días)
	if is_paused():
		stage = prev_stage
	# Consumir agua del día
	water_level = maxi(0, water_level - crop_def.water_need)
	# Árboles frutales en cooldown: contar días, sin avanzar etapa
	if crop_def.is_tree and fruit_cooldown > 0:
		fruit_cooldown -= 1
		return true
	# Avanzar crecimiento
	var dias_por_dia: int = 2 if fertilized else 1
	grown_days += dias_por_dia
	var dias_necesarios: int = maxi(1, crop_def.grow_days - crop_def.fertilizer_bonus)
	var etapa_esperada: int = clampi(
		int(float(grown_days) / float(dias_necesarios) * float(crop_def.stage_count)),
		0, crop_def.stage_count)
	var nuevo_stage: int = GrowthStage.LISTA if grown_days >= dias_necesarios else etapa_esperada
	if nuevo_stage != stage:
		stage = nuevo_stage
		return true
	return false

func _entrar_pausa(nuevo: int) -> bool:
	if stage == nuevo:
		return false
	if not is_paused():
		prev_stage = stage
	stage = nuevo
	return true

## Riego manual: sube agua hasta 2 (nunca se desperdicia con castigo).
func regar() -> void:
	water_level = mini(2, water_level + 1)
	if stage == GrowthStage.SIN_AGUA and water_level >= 1:
		stage = prev_stage

## Cosecha: rendimiento calculado de forma legible (sin RNG oculto, §3 flujo 3).
func calcular_rendimiento() -> Array:
	var out: Array = []
	if crop_def == null or crop_def.decorative_only:
		return out
	var cantidad: int = crop_def.yield_amount_max if quality >= 2 else (
		crop_def.yield_amount_min + (1 if quality >= 1 else 0))
	if cantidad < crop_def.yield_amount_min:
		cantidad = crop_def.yield_amount_min
	out.append({"item_id": str(crop_def.yield_item_id), "cantidad": cantidad})
	if crop_def.yield_seed_id != &"" and crop_def.yield_seed_amount > 0:
		out.append({"item_id": str(crop_def.yield_seed_id), "cantidad": crop_def.yield_seed_amount})
	return out

## Serialización (M59)
func serializar() -> Dictionary:
	return {
		"pos": [voxel_pos.x, voxel_pos.y, voxel_pos.z],
		"crop": str(crop_def.crop_id) if crop_def else "",
		"stage": stage,
		"grown_days": grown_days,
		"water": water_level,
		"fert": fertilized,
		"quality": quality,
		"planted": planted_at_day,
		"prev": prev_stage,
		"cooldown": fruit_cooldown,
	}

func deserializar(data: Dictionary, def: CropDefinition) -> void:
	var p: Array = data.get("pos", [0, 0, 0])
	voxel_pos = Vector3i(int(p[0]), int(p[1]), int(p[2]))
	crop_def = def
	stage = int(data.get("stage", 0))
	grown_days = int(data.get("grown_days", 0))
	water_level = int(data.get("water", 0))
	fertilized = bool(data.get("fert", false))
	quality = int(data.get("quality", 0))
	planted_at_day = int(data.get("planted", 0))
	prev_stage = int(data.get("prev", 0))
	fruit_cooldown = int(data.get("cooldown", 0))