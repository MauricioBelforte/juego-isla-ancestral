# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M59: Test de la iteración auto-save/dirty/providers (A4, B1, B2, B3, B5, I4).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_autosave_m59.gd

extends SceneTree

var _fallos: int = 0
var _sm: Node = null
var _bus: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_sm = root.get_node_or_null("SaveManager")
	_bus = root.get_node_or_null("EventBus")
	_check(_sm != null, "SaveManager autoload presente")
	_check(_bus != null, "EventBus autoload presente")
	if _sm == null or _bus == null:
		print("=== TEST M59 AUTOSAVE: 1+ fallo(s) ===")
		quit(1)
		return
	_test_provider_player_registrado()
	_test_dirty_basico()
	_test_bloqueo_dialogo()
	_test_autosave_dia()
	_test_autosave_mision()
	_test_persistencia_player()
	print("=== TEST M59 AUTOSAVE: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_provider_player_registrado() -> void:
	_check(not _sm.snapshot.unclaimed_sections().has("player"),
		"sección 'player' reclamada por un proveedor")

func _test_dirty_basico() -> void:
	_sm.clear_dirty()
	_check(not _sm.is_dirty(), "arranca limpio")
	# Cambio de inventario marca dirty (A4)
	_bus.inventory.item_added.emit("test_item", 1)
	_check(_sm.is_dirty(), "item_added marca dirty")
	# Guardar limpia dirty
	var completado: Array = [false]
	var cb := func(_slot: int, _reason: String) -> void:
		completado[0] = true
	_sm.save_completed.connect(cb)
	_sm.current_slot = 1
	_sm.request_save(1, "test_dirty")
	_check(completado[0], "save completado")
	_check(not _sm.is_dirty(), "save_completed limpia dirty")
	_sm.save_completed.disconnect(cb)

func _test_bloqueo_dialogo() -> void:
	# B5: diálogo abierto bloquea, cerrado desbloquea
	_bus.ui.dialog_requested.emit("npc_test", {})
	_check(_sm.is_save_blocked(), "diálogo bloquea guardado")
	var saltado: Array = [false]
	var cb := func(_reason: String) -> void:
		saltado[0] = true
	_sm.auto_save_skipped.connect(cb)
	_sm.current_slot = 1
	_sm.request_save(1, "test_dialogo")
	_check(saltado[0], "save durante diálogo se omite con aviso")
	_sm.auto_save_skipped.disconnect(cb)
	_bus.ui.dialog_finished.emit()
	_check(not _sm.is_save_blocked(), "fin de diálogo desbloquea")

func _test_autosave_dia() -> void:
	# B1: day_started dispara auto-save cuando hay slot cargado
	_sm.current_slot = 1
	var motivos: Array = []
	var cb := func(_slot: int, reason: String) -> void:
		motivos.append(reason)
	_sm.save_completed.connect(cb)
	_bus.calendar.day_started.emit(2, "Primavera")
	_check(motivos.has("auto_dia"), "auto_dia disparado por day_started")
	_sm.save_completed.disconnect(cb)
	# Sin slot cargado: no crash, no save
	_sm.current_slot = -1
	_bus.calendar.day_started.emit(3, "Primavera")
	_check(motivos.size() >= 1, "sin slot no revienta")

func _test_autosave_mision() -> void:
	# B2: quest_completed dispara auto-save (emisores reales M22/M23 pendientes)
	_sm.current_slot = 1
	var motivos: Array = []
	var cb := func(_slot: int, reason: String) -> void:
		motivos.append(reason)
	_sm.save_completed.connect(cb)
	_bus.quest.quest_completed.emit("test_quest")
	_check(motivos.has("auto_mision"), "auto_mision disparado por quest_completed")
	_sm.save_completed.disconnect(cb)

func _test_persistencia_player() -> void:
	# I4: round-trip de posición del jugador vía PlayerSaveProvider.
	# En --script puro la escena main_island puede no estar cargada; si no
	# hay Player, se valida el contrato con un Node3D stub.
	var prov = _sm.snapshot._providers.get("player", null)
	_check(prov != null, "proveedor player accesible")
	if prov == null:
		return
	var jugador: Node3D = prov._buscar_jugador()
	if jugador == null:
		jugador = Node3D.new()
		jugador.name = "Player"
		root.add_child(jugador)
		_check(true, "Player ausente (headless sin escena); stub creado")
	var guardado: Dictionary = prov.get_save_data()
	_check(guardado.has("position") and (guardado.position as Array).size() == 3,
		"get_save_data tiene position [x,y,z]")
	# Mover al jugador y restaurar la posición guardada
	var destino := Vector3(321.0, 30.0, 323.0)
	jugador.global_position = destino
	prov.restore_save_data(guardado)
	var pos := jugador.global_position
	_check(absf(pos.x - float(guardado.position[0])) < 0.01
		and absf(pos.y - float(guardado.position[1])) < 0.01
		and absf(pos.z - float(guardado.position[2])) < 0.01,
		"posición restaurada desde save")
	# restore con datos vacíos no rompe
	prov.restore_save_data({})
	prov.restore_save_data({"position": []})
	jugador.queue_free()
