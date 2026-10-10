# M11: Test headless del Personaje del Jugador
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_m11.gd
# Exit: 0 = todo OK, 1 = algun fallo.
#
# ── Guardianes anti-falso-verde (2026-09-20, DeepSeek-V4.1-Flash) ─────
# Esta suite es la evidencia de los [x] del modulo, asi que tiene que poder
# FALLAR. Medido antes de confiar en ella:
#   1. Marcadores _fin("A".."E") + BLOQUES_ESPERADOS: si un bloque no cierra
#      (aborto por SCRIPT ERROR), se nombra y falla. PROBADO EN ROJO con una
#      sonda: aborto al inicio del bloque C -> "[FALLO] Bloque faltante: C",
#      26 checks / 1 fallo / EXIT 1.
#   2. Piso CHECKS_MINIMOS: un aborto PARCIAL deja menos checks y el conteo lo
#      delata. El piso es el total REAL medido en verde, no el teorico.
#   3. _summary() se registra con call_deferred en _init(). Sin esto, un aborto
#      dentro de _run() se lleva el quit(): sin --quit el proceso CUELGA
#      (medido: EXIT 124 a los 60 s, sin veredicto) y con --quit el comando sale
#      0 SIN imprimir resumen, que es un falso verde. Medido con sonda.
#   (Se elimino el guard _error_en_curso/_process: era codigo MUERTO — la
#    bandera nunca se ponia en true, asi que el guard no podia dispararse. Y se
#    elimino el helper _esperar_autoloads(), que se llamaba SIN await en 5
#    sitios: el await nunca llegaba al llamador, asi que era un no-op. Los
#    autoloads ya estan arriba cuando corre el _run() diferido — se ve en la
#    salida: "=== Bootstrap Completado ===" sale ANTES que el resumen.)
#
# ⚠️ B6-B9 son INVARIANTES INVERTIBLES: afirman que stamina/FSM/interaccion/luz
#    NO existen (divergencia documentada en 05-Checklist.md). El dia que alguno
#    se implemente van a dar ROJO: eso NO es una regresion, es la senal de que
#    hay que invertir el check y actualizar el checklist. No los borres sin
#    actualizar el documento.

extends SceneTree

const MODULO := "M11 Player"
const BLOQUES_ESPERADOS := ["A", "B", "C", "D", "E"]
## Total REAL medido en verde (2026-09-20). Si baja, algo dejo de correr.
const CHECKS_MINIMOS := 30

var _checks := 0
var _fallos := 0
var _checks_previo := 0
var _vistos: Dictionary = {}
var _terminado := false

func _init() -> void:
	call_deferred("_run")
	# Red de seguridad: si _run() aborta, la cola diferida SIGUE y este corre.
	call_deferred("_resumen_seguro")

func _resumen_seguro() -> void:
	if _terminado:
		return
	_fallos += 1
	print("!! _run() NO llego al final: aborto por SCRIPT ERROR (no hubo veredicto)")
	_summary()

func _check(ok: bool, msg: String) -> void:
	_checks += 1
	if ok:
		print("[OK]    ", msg)
	else:
		_fallos += 1
		print("[FALLO] ", msg)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	print("[FIN] bloque %s (+%d checks)" % [nombre, _checks - _checks_previo])
	_checks_previo = _checks

func _summary() -> void:
	_terminado = true
	for b in BLOQUES_ESPERADOS:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] Bloque faltante: %s" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FALLO] solo %d checks ejecutados (minimo %d): aborto parcial" % [_checks, CHECKS_MINIMOS])
	print("=== %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)

## ── Bloque A: Carga de script y constantes @export ──────────────────

func _bloque_a_constantes() -> void:
	var script = load("res://scripts/player/player.gd")
	_check(script != null, "A1 script player.gd carga correctamente")
	if script == null:
		_fin("A")
		return

	var scene_script = load("res://scenes/player/Player.tscn")
	var instance = scene_script.instantiate() if scene_script != null else null

	if instance != null:
		root.add_child(instance)
		_check(instance.move_speed > 0.0,
			"A2 move_speed=%.1f > 0" % instance.move_speed)
		_check(instance.gravity > 0.0,
			"A3 gravity=%.1f > 0" % instance.gravity)
		_check(instance.jump_force > 0.0,
			"A4 jump_force=%.1f > 0" % instance.jump_force)
		_check(instance.edit_distance >= 4.0,
			"A5 edit_distance=%.1f >= 4" % instance.edit_distance)
		instance.queue_free()
	else:
		_check(false, "A2-A5 no se pudo instanciar Player.tscn")

	_fin("A")

## ── Bloque B: Constantes del diseño vs código ───────────────────────

func _bloque_b_constantes_diseno() -> void:
	var scene_script = load("res://scenes/player/Player.tscn")
	var instance = scene_script.instantiate() if scene_script != null else null

	if instance != null:
		root.add_child(instance)

		# B1: Hitbox — verificar dimensiones del ColliderShape3D
		var collider = instance.get_node_or_null("BodyCollision")
		if collider == null:
			collider = instance.get_node_or_null("CollisionShape3D")
		if collider != null:
			var shape = collider.shape
			if shape is CapsuleShape3D:
				_check(shape.radius > 0.0 and shape.radius <= 1.0,
					"B1 radio capsule=%.2f (diseño: 0.3 half-width)" % shape.radius)
				_check(shape.height > 1.0 and shape.height <= 3.0,
					"B1 height capsule=%.2f (diseño: 1.8m)" % shape.height)
			elif shape is SphereShape3D:
				_check(shape.radius > 0.0,
					"B1 sphere radius=%.2f" % shape.radius)
			else:
				_check(false,
					"B1 shape type=%s (esperado CapsuleShape3D)" % shape.get_class())
		else:
			_check(false, "B1 BodyCollision/CollisionShape3D no encontrado en Player.tscn")

		# B2-B4: Rangos razonables
		_check(instance.move_speed >= 1.0 and instance.move_speed <= 50.0,
			"B2 move_speed=%.1f en [1,50]" % instance.move_speed)
		_check(instance.gravity >= 5.0 and instance.gravity <= 50.0,
			"B3 gravity=%.1f en [5,50]" % instance.gravity)
		_check(instance.jump_force >= 3.0 and instance.jump_force <= 20.0,
			"B4 jump_force=%.1f en [3,20]" % instance.jump_force)

		# B5: Altura salto calculada
		var alt: float = \
			(float(instance.jump_force) * float(instance.jump_force)) / \
			(2.0 * float(instance.gravity))
		_check(alt > 0.5 and alt < 5.0,
			"B5 altura_salto=%.2fm (diseño: 1.2m)" % alt)

		instance.queue_free()
	else:
		_check(false, "B1-B5 no se pudo instanciar Player.tscn")
		_fin("B")
		return

	# B6-B9: divergencias DOCUMENTADAS. OJO: afirman la AUSENCIA del sistema, o
	# sea que dan ROJO cuando alguien lo implemente (ver cabecera, INVERTIBLES).
	var method_names: Array[String] = []
	var tmp = load("res://scenes/player/Player.tscn").instantiate()
	if tmp != null:
		root.add_child(tmp)
		for _m in tmp.get_method_list():
			method_names.append(_m.name)
		tmp.queue_free()

	var has_stamina := false
	for _n in method_names:
		if "stamina" in _n.to_lower():
			has_stamina = true
			break
	_check(not has_stamina, "B6 [INVERTIBLE] stamina: NO implementado — [?] dueño M11")

	var has_fsm := false
	for _n in method_names:
		if "fsm" in _n.to_lower() or "state_machine" in _n.to_lower():
			has_fsm = true
			break
	_check(not has_fsm, "B7 [INVERTIBLE] FSM: NO implementado — [?] dueño M11")

	var has_interact := false
	for _n in method_names:
		if "interaction" in _n.to_lower() or "interact" in _n.to_lower():
			has_interact = true
			break
	_check(not has_interact, "B8 [INVERTIBLE] Interaccion/F en el Player: NO implementado — el manager existe (M70, autoload 50-interacciones) pero NO esta cableado al jugador — [?] dueño M11")

	var has_light := false
	for _n in method_names:
		if "light" in _n.to_lower() or "espor" in _n.to_lower():
			has_light = true
			break
	_check(not has_light, "B9 [INVERTIBLE] Luz/esporas: NO implementado — [?] dueño M14")

	_fin("B")

## ── Bloque C: Movement y colision basica ────────────────────────────

func _bloque_c_movement() -> void:
	var scene_script = load("res://scenes/player/Player.tscn")
	var instance = scene_script.instantiate() if scene_script != null else null

	if instance != null:
		root.add_child(instance)

		_check(instance.is_in_group("player"), "C1 jugador en grupo 'player'")
		_check(abs(instance.velocity.x - 0.0) < 0.001, "C2 velocity.x inicial = 0")
		_check(instance.gravity > 0.0, "C3 gravity positiva (%.1f)" % instance.gravity)
		_check(instance.move_speed > 0.0, "C4 move_speed positiva (%.1f)" % instance.move_speed)
		# C5 (M156 iter. 3): _equip_speed_mult fue reemplazado por la velocidad
		# efectiva data-driven (_current_effective_speed = base x terreno x
		# (1+equipo)). Sin detector/provider/equipo cargados debe ser == move_speed.
		_check(absf(instance._current_effective_speed - instance.move_speed) < 0.01,
			"C5 velocidad efectiva inicial = move_speed=%.1f (sin terreno/equipo)" % instance.move_speed)

		instance.queue_free()
	else:
		_check(false, "C1-C5 no se pudo instanciar Player.tscn")

	_fin("C")

## ── Bloque D: Equipment integration (M155) ──────────────────────────

func _bloque_d_equipment() -> void:
	var em = root.get_node_or_null("EquipmentManager")
	_check(em != null, "D1 EquipmentManager autoload presente")

	if em == null:
		_fin("D")
		return

	_check(em.has_signal("terrain_bonus_updated"),
		"D2 signal terrain_bonus_updated existe")
	_check(em.catalog.size() >= 1,
		"D3 catálogo tiene >=1 prenda (%d)" % em.catalog.size())

	# D4: Player conecta señal en _ready
	var scene_script = load("res://scenes/player/Player.tscn")
	var instance = scene_script.instantiate() if scene_script != null else null
	if instance != null:
		root.add_child(instance)
		_check(em.is_connected("terrain_bonus_updated",
			instance._on_terrain_bonus_changed),
			"D4 jugador conectado a terrain_bonus_updated")
		instance.queue_free()
	else:
		_check(false, "D4 no se pudo instanciar Player.tscn para verificar señal")

	_fin("D")

## ── Bloque E: API nativa de Voxel Tools ─────────────────────────────

func _bloque_e_voxel_box_mover() -> void:
	_check(ClassDB.class_exists("VoxelBoxMover"),
		"E1 VoxelBoxMover registrada como clase nativa")
	_check(ClassDB.can_instantiate("VoxelBoxMover"),
		"E2 VoxelBoxMover puede instanciarse")
	_check(ClassDB.class_exists("VoxelTerrain"),
		"E3 VoxelTerrain registrada como clase nativa")
	_check(ClassDB.class_has_method("VoxelTerrain", "get_voxel_tool"),
		"E4 VoxelTerrain.get_voxel_tool existe")
	_check(not ClassDB.class_has_method("VoxelTerrain", "get_height"),
		"E5 VoxelTerrain no expone get_height")
	var locator = root.get_node_or_null("TerrainLocator")
	_check(locator != null and locator.has_method("get_height"),
		"E6 TerrainLocator.get_height existe")

	_fin("E")

## ── Suite principal ─────────────────────────────────────────────────

func _run() -> void:
	print("=== %s — suite de personaje jugador ===" % MODULO)
	_bloque_a_constantes()
	_bloque_b_constantes_diseno()
	_bloque_c_movement()
	_bloque_d_equipment()
	_bloque_e_voxel_box_mover()
	_summary()
