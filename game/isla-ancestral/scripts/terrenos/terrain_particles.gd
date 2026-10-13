# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-13
#
# M156 iter. 5 (lote I, 2026-10-13, atria-dawn): Sistema de particulas por terreno.
# Diseño §5.2 (feedback visual) y §5.3 (trigger de efectos).
#
# - Data-driven: config por terreno en data/terrenos/terrenos.json
#   (TerrainProvider.get_visual_config: frecuencia/intensidad).
# - 7 escenas particulas_<terreno>.tscn con CPUParticles3D procedural (color
#   del terreno, sin texturas externas). CPUParticles3D: funciona en headless
#   sin GPU; NO usa ParticleProcessMaterial (esa propiedad es de GPUParticles3D
#   — las props van directas en el nodo).
# - Rafagas en movimiento (velocidad horizontal >= umbral) con la frecuencia
#   por terreno; se reinicia al detenerse (§5.3).
# - Pooling de emisores: limite max_emisores y reuso (item O316).
#
# Acoplamiento: se autoconecta al hermano "TerrainDetector" (signal
# terrain_changed) y lee velocity del padre CharacterBody3D — no modifica
# player.gd (§15).
class_name TerrainParticles
extends Node3D

const SLUGS := {
	0: "ceped",
	1: "barro",
	2: "pavimento",
	3: "arena",
	4: "agua",
	5: "nieve",
	6: "rocas",
}
const RUTA_PARTICULA := "res://scenes/terrenos/particulas_%s.tscn"
const INTENSIDAD_MAX := 16

## Maximo de emisores simultaneos (pool).
@export var max_emisores: int = 6
## Segundos de emision por rafaga.
@export var duracion_rafaga: float = 0.8
## Velocidad horizontal minima para emitir (§5.3.1).
@export var velocidad_minima: float = 1.5

var _provider: Node = null
var _detector: Node = null
var _jugador: CharacterBody3D = null
var _terrain_id: int = 0
var _escenas: Dictionary = {}
var _pool: Array[CPUParticles3D] = []
var _activos: Array[Dictionary] = []
var _timer_rafaga: float = 0.0


func _ready() -> void:
	_jugador = get_parent() as CharacterBody3D
	_provider = get_node_or_null("/root/TerrainProvider")
	_detector = get_node_or_null("../TerrainDetector")
	if _detector != null and _detector.has_signal("terrain_changed"):
		_detector.terrain_changed.connect(_on_terrain_changed)
	_precargar_escenas()


## Precarga las 7 escenas de particulas (PackedScene por terreno).
func _precargar_escenas() -> void:
	for tid in SLUGS.keys():
		var ruta := RUTA_PARTICULA % SLUGS[tid]
		var escena: PackedScene = load(ruta)
		if escena == null:
			push_warning("[M156] Particulas sin escena: tid=%d (%s)" % [tid, ruta])
			continue
		_escenas[tid] = escena


func _on_terrain_changed(new_id: int) -> void:
	_terrain_id = new_id
	_timer_rafaga = 0.0


func _physics_process(delta: float) -> void:
	_gestionar_activos(delta)
	if _jugador == null or not is_inside_tree():
		return
	var vel_hor := Vector2(_jugador.velocity.x, _jugador.velocity.z)
	if vel_hor.length() < velocidad_minima:
		_timer_rafaga = 0.0  # §5.3.4
		return
	_timer_rafaga += delta
	var cfg := _config_actual()
	if cfg.is_empty():
		return
	var frecuencia := float(cfg.get("particulas_frecuencia", 1.0))
	if _timer_rafaga >= frecuencia:
		_timer_rafaga = 0.0
		_emitir_rafaga(cfg)


func _config_actual() -> Dictionary:
	if _provider != null and _provider.has_method("get_visual_config"):
		return _provider.get_visual_config(_terrain_id)
	return {}


func _emitir_rafaga(cfg: Dictionary, pos_forzada: Vector3 = Vector3.INF) -> void:
	if _activos.size() >= max_emisores:
		var viejo: Dictionary = _activos.pop_front()
		_liberar(viejo["nodo"])
	var nodo: CPUParticles3D = _obtener_nodo()
	if nodo == null:
		return
	nodo.amount = clampi(int(cfg.get("particulas_intensidad", 2)), 1, INTENSIDAD_MAX)
	nodo.global_position = pos_forzada if pos_forzada != Vector3.INF else _posicion_pies()
	nodo.visible = true
	nodo.emitting = true
	_activos.append({"nodo": nodo, "restante": duracion_rafaga})


## Pies del jugador (mismo criterio que TerrainFootprints).
func _posicion_pies() -> Vector3:
	var pos := _jugador.global_position
	pos.y -= 0.9
	return pos


func _obtener_nodo() -> CPUParticles3D:
	if _pool.size() > 0:
		return _pool.pop_back()
	var escena: PackedScene = _escenas.get(_terrain_id)
	if escena == null:
		return null
	var inst: Node = escena.instantiate()
	if not inst is CPUParticles3D:
		inst.free()
		return null
	var nodo: CPUParticles3D = inst as CPUParticles3D
	add_child(nodo)
	return nodo


func _gestionar_activos(delta: float) -> void:
	for i in range(_activos.size() - 1, -1, -1):
		var h: Dictionary = _activos[i]
		h["restante"] = float(h["restante"]) - delta
		if float(h["restante"]) <= 0.0:
			_activos.remove_at(i)
			_liberar(h["nodo"])


func _liberar(nodo: Node) -> void:
	if nodo is CPUParticles3D:
		var c: CPUParticles3D = nodo as CPUParticles3D
		c.emitting = false
		c.visible = false
		_pool.append(c)


# ── API publica (tests / QA) ──────────────────────────────

func get_emisores_activos() -> int:
	return _activos.size()


func get_pool_size() -> int:
	return _pool.size()


func get_terrain_id() -> int:
	return _terrain_id


func get_escenas_cargadas() -> int:
	return _escenas.size()


## Fuerza una rafaga en una posicion sin requerir movimiento (tests/QA).
func forzar_rafaga(pos: Vector3, terrain_id: int) -> void:
	var tid_previo := _terrain_id
	_terrain_id = terrain_id
	var cfg := _config_actual()
	if not cfg.is_empty():
		_emitir_rafaga(cfg, pos)
	_terrain_id = tid_previo


## Simula un cambio de terreno (tests/QA).
func simular_cambio_terreno(new_id: int) -> void:
	_on_terrain_changed(new_id)
