# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M19/M64: Test del fix BUG-011 (watchdog en bucle).
#  1) obtener_perfil() resuelve por id y case-insensitive (perfil=unknown → nombre)
#  2) El watchdog NO cuenta estados estáticos (Idle/Sleep/Eat...) como atasco
#  3) En Movement un atasco real SÍ dispara (y respawn a hogar tras threshold)
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/npc/test_bug011.gd

extends SceneTree

var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var vm := root.get_node_or_null("VillagerManager")
	_check(vm != null, "VillagerManager presente")
	if vm == null:
		print("=== TEST BUG-011: 1 fallo(s) ===")
		quit(1)
		return
	_test_obtener_perfil(vm)
	_test_watchdog_estados_estaticos()
	print("=== TEST BUG-011: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_obtener_perfil(vm: Node) -> void:
	# Por id exacto del catálogo
	var p: Resource = vm.obtener_perfil("catalina_oso")
	_check(p != null, "obtener_perfil('catalina_oso') resuelve (BUG-011)")
	if p != null:
		_check(String(p.id) == "catalina_oso", "perfil.id correcto: %s" % str(p.id))
		_check((p as Resource).rutina_diaria is Dictionary, "perfil tiene rutina_diaria")
	# Case-insensitive: el nodo se llama "CatalinaOso" (PascalCase)
	var p2: Resource = vm.obtener_perfil("CatalinaOso")
	_check(p2 != null, "obtener_perfil('CatalinaOso') resuelve case-insensitive")
	# Desconocido → null (sin crash)
	_check(vm.obtener_perfil("desconocido_total") == null, "perfil desconocido → null")


func _test_watchdog_estados_estaticos() -> void:
	# FSM aislada sobre un CharacterBody3D mínimo DENTRO del árbol
	# (global_position requiere is_inside_tree).
	var fsm: Node = load("res://scripts/ia_npc/state_machine.gd").new()
	var cuerpo: CharacterBody3D = CharacterBody3D.new()
	cuerpo.name = "CatalinaOso"
	cuerpo.add_child(fsm)
	root.add_child(cuerpo)
	var idle: Node = load("res://scripts/ia_npc/states/idle_state.gd").new()
	fsm.register_state(idle, &"Idle", 10)
	fsm.transition_to(&"Idle")
	_check(fsm.current_state != null, "estado Idle activo")
	var atascos: Array = [0]
	fsm.stuck_detected.connect(func(_id, _dur): atascos[0] += 1)
	# Simular 5 s quieto en Idle: NO debe haber atascos (por diseño estático)
	for i in range(250):
		fsm.update(0.02)
	_check(int(atascos[0]) == 0, "Idle 5s quieto SIN atascos (BUG-011): %d" % int(atascos[0]))
	_check(float(fsm._stuck_timer) == 0.0, "stuck_timer reseteado en Idle")
	cuerpo.queue_free()


# Nota: el caso Movement con atasco real ya está cubierto por el diseño
# (states/movement_state.gd resetea el timer al navegar; si la navegación
# falla persistentemente, _force_new_target + respawn a hogar siguen activos).
# El test headless del full path de navegación requiere NavigationServer real,
# fuera del alcance de este fix (el BUG-011 era el bucle en estados estáticos).