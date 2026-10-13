# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-13
#
# M156 iter. 5 (lote I, 2026-10-13, atria-dawn): Sistema de huellas por terreno.
# Diseño §5.1 (feedback visual) y §5.3 (trigger de efectos).
#
# - Data-driven: config por terreno en data/terrenos/terrenos.json
#   (TerrainProvider.get_visual_config: distancia/tamano/alpha/color).
# - 7 escenas huella_<terreno>.tscn (mesh procedural, sin texturas externas).
# - Solo se activa en movimiento (velocidad horizontal >= umbral) y se reinicia
#   al detenerse (§5.3.1/§5.3.4).
# - Pooling de MeshInstance3D: limite max_huellas, reuso, reciclado de la mas
#   vieja cuando se satura (items L209/L210).
# - Fade-out por tween al expirar (duracion configurable) y liberacion al pool.
#
# Acoplamiento: se autoconecta al hermano "TerrainDetector" (signal
# terrain_changed) y lee velocity del padre CharacterBody3D — no modifica
# player.gd (§15: sistema separado que reutiliza contratos existentes).
class_name TerrainFootprints
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
const RUTA_HUELLA := "res://scenes/terrenos/huella_%s.tscn"

## Maximo de huellas simultaneas (limite, item L209).
@export var max_huellas: int = 24
## Segundos de vida de una huella antes de desvanecerse (item L208).
@export var duracion_huella: float = 8.0
## Velocidad horizontal minima para dejar huella (§5.3.1).
@export var velocidad_minima: float = 1.5
## Segundos de fade-out al expirar.
@export var duracion_fade: float = 0.6

var _provider: Node = null
var _detector: Node = null
var _jugador: CharacterBody3D = null
var _terrain_id: int = 0
var _escenas: Dictionary = {}
var _meshes: Dictionary = {}
var _pool: Array[MeshInstance3D] = []
var _activas: Array[Dictionary] = []
var _dist_acum: float = 0.0
var _pos_previa: Vector3 = Vector3.ZERO


func _ready() -> void:
	_jugador = get_parent() as CharacterBody3D
	_provider = get_node_or_null("/root/TerrainProvider")
	_detector = get_node_or_null("../TerrainDetector")
	if _detector != null and _detector.has_signal("terrain_changed"):
		_detector.terrain_changed.connect(_on_terrain_changed)
	if _jugador != null:
		_pos_previa = _jugador.global_position
	_cargar_escenas()


## Precarga las 7 escenas y captura sus meshes (compartidos por terreno,
# inmutables en runtime — el alpha va por material_override, unico por nodo).
func _cargar_escenas() -> void:
	for tid in SLUGS.keys():
		var ruta := RUTA_HUELLA % SLUGS[tid]
		var escena: PackedScene = load(ruta)
		if escena == null:
			push_warning("[M156] Huella sin escena: tid=%d (%s)" % [tid, ruta])
			continue
		_escenas[tid] = escena
		var inst: Node = escena.instantiate()
		if inst is MeshInstance3D:
			_meshes[tid] = (inst as MeshInstance3D).mesh
		inst.free()


func _on_terrain_changed(new_id: int) -> void:
	_terrain_id = new_id
	_dist_acum = 0.0  # reinicia el espaciado al cambiar de terreno (§5.3.2)


func _physics_process(delta: float) -> void:
	_gestionar_activas(delta)
	if _jugador == null or not is_inside_tree():
		return
	var vel_hor := Vector2(_jugador.velocity.x, _jugador.velocity.z)
	if vel_hor.length() < velocidad_minima:
		_dist_acum = 0.0  # §5.3.4: al detenerse se reinicia el espaciado
		return
	var desplaz := _jugador.global_position.distance_to(_pos_previa)
	_pos_previa = _jugador.global_position
	_dist_acum += desplaz
	var cfg := _config_actual()
	if cfg.is_empty():
		return
	var distancia_necesaria := float(cfg.get("huella_distancia", 0.7))
	# while, no if: si el frame fue largo, se ponen las huellas que correspondan.
	while _dist_acum >= distancia_necesaria:
		_dist_acum -= distancia_necesaria
		_instanciar_huella(cfg)


func _config_actual() -> Dictionary:
	if _provider != null and _provider.has_method("get_visual_config"):
		return _provider.get_visual_config(_terrain_id)
	return {}


## Coloca una huella bajo los pies del jugador (o en pos forzada por tests).
func _instanciar_huella(cfg: Dictionary, pos_forzada: Vector3 = Vector3.INF) -> void:
	if _activas.size() >= max_huellas:
		var vieja: Dictionary = _activas.pop_front()
		_liberar(vieja["nodo"])
	var nodo: MeshInstance3D = _obtener_nodo()
	if nodo == null:
		return
	var pos: Vector3 = pos_forzada
	if pos == Vector3.INF:
		pos = _posicion_pies()
	nodo.global_position = pos
	nodo.rotation = Vector3(0.0, randf() * TAU, 0.0)
	nodo.visible = true
	var tam := float(cfg.get("huella_tamano", 0.5))
	nodo.scale = Vector3(tam, 1.0, tam)
	var alpha := clampf(float(cfg.get("huella_alpha", 0.4)), 0.0, 1.0)
	_aplicar_alpha(nodo, alpha)
	_activas.append({"nodo": nodo, "restante": duracion_huella, "alpha": alpha})


## Punto de apoyo: pies del jugador, retrasado 0.25m opuesto a la direccion
## de marcha (la huella queda detras de la pisada, no bajo el centro).
func _posicion_pies() -> Vector3:
	var pos := _jugador.global_position
	var dir := Vector2(_jugador.velocity.x, _jugador.velocity.z)
	if dir.length() > 0.001:
		dir = dir.normalized()
		pos += Vector3(-dir.x, 0.0, -dir.y) * 0.25
	pos.y -= 0.9  # altura de los pies respecto al origen del CharacterBody3D
	return pos


func _obtener_nodo() -> MeshInstance3D:
	var mesh: Mesh = _meshes.get(_terrain_id)
	if mesh == null:
		return null
	var nodo: MeshInstance3D = null
	if _pool.size() > 0:
		nodo = _pool.pop_back()
	else:
		nodo = MeshInstance3D.new()
		add_child(nodo)
	nodo.mesh = mesh
	return nodo


## Copia unica del material base con el alpha data-driven (cada nodo activo
## necesita el suyo: el fade es independiente por huella).
func _aplicar_alpha(nodo: MeshInstance3D, alpha: float) -> void:
	var base := _material_base(nodo)
	if base == null:
		return
	var copia := base.duplicate() as StandardMaterial3D
	var c := base.albedo_color
	copia.albedo_color = Color(c.r, c.g, c.b, alpha)
	nodo.material_override = copia


func _material_base(nodo: MeshInstance3D) -> StandardMaterial3D:
	var mesh := nodo.mesh
	if mesh != null and mesh.surface_get_material(0) is StandardMaterial3D:
		return mesh.surface_get_material(0) as StandardMaterial3D
	return nodo.material_override as StandardMaterial3D


func _gestionar_activas(delta: float) -> void:
	for i in range(_activas.size() - 1, -1, -1):
		var h: Dictionary = _activas[i]
		h["restante"] = float(h["restante"]) - delta
		if float(h["restante"]) <= 0.0:
			_activas.remove_at(i)
			_desvanecer(h["nodo"], float(h["alpha"]))


## Fade-out por tween y luego liberacion al pool (item L208).
## Si duracion_fade <= 0, liberacion directa (deterministico para tests/QA).
func _desvanecer(nodo: MeshInstance3D, alpha_ini: float) -> void:
	if duracion_fade <= 0.0:
		_liberar(nodo)
		return
	var mat := nodo.material_override as StandardMaterial3D
	if mat == null:
		_liberar(nodo)
		return
	var tween := create_tween()
	tween.set_meta("huella_nodo", nodo)
	tween.tween_property(mat, "albedo_color:a", 0.0, duracion_fade) \
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_al_terminar_fade.bind(nodo, alpha_ini))


func _al_terminar_fade(nodo: MeshInstance3D, alpha_ini: float) -> void:
	# restablece el alpha para el proximo reuso del pool
	var mat := nodo.material_override as StandardMaterial3D
	if mat != null:
		mat.albedo_color.a = alpha_ini
	_liberar(nodo)


## Devuelve el nodo al pool (invisible, reutilizable).
func _liberar(nodo: Node) -> void:
	if nodo is Node3D:
		(nodo as Node3D).visible = false
	if nodo is MeshInstance3D:
		_pool.append(nodo as MeshInstance3D)


# ── API publica (tests / QA) ──────────────────────────────

func get_huellas_activas() -> int:
	return _activas.size()


func get_pool_size() -> int:
	return _pool.size()


func get_terrain_id() -> int:
	return _terrain_id


func get_escenas_cargadas() -> int:
	return _escenas.size()


func get_meshes_cargados() -> int:
	return _meshes.size()


## Fuerza una huella en una posicion sin requerir movimiento (tests/QA).
func forzar_huella(pos: Vector3, terrain_id: int) -> void:
	var tid_previo := _terrain_id
	_terrain_id = terrain_id
	var cfg := _config_actual()
	if not cfg.is_empty():
		_instanciar_huella(cfg, pos)
	_terrain_id = tid_previo


## Simula un cambio de terreno (tests/QA).
func simular_cambio_terreno(new_id: int) -> void:
	_on_terrain_changed(new_id)
