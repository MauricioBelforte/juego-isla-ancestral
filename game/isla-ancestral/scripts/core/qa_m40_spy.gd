# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M40: QA del Spy de EventBus (item [S] "Soporte de espia de eventos para el
# Debug Menu (M110)" del 05-Checklist; turno 2-BIS).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/qa_m40_spy.gd

extends SceneTree

const CHECKS_MINIMOS := 10
var _checks: int = 0
var _fallos: int = 0

func _summary() -> void:
	print("=== Resumen QA spy M40: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	const SpyC := preload("res://scripts/core/event_bus_spy.gd")
	var bus := root.get_node_or_null("/root/EventBus")
	_check(bus != null, "EventBus autoload presente")
	if bus == null:
		return
	var spy = SpyC.new()
	_check(spy.esta_activa() == false, "spy nace inactivo")
	var n: int = spy.attach(bus)
	_check(n > 0, "spy: %d senales conectadas a traves de los dominios" % n)
	_check(spy.esta_activa(), "spy activo tras attach")
	# Doble attach protegido (no duplica conexiones)
	var n2: int = spy.attach(bus)
	_check(n2 == -1, "spy: doble attach rechazado (-1)")
	# Emitir senales reales del dominio world (arity 2) e inventory (arity 2)
	# El bus expone dominios como CLASES INTERNAS (RefCounted, NO Nodes):
	# se resuelven por propiedad con bus.get() (hallazgo del propio QA).
	var world: Variant = bus.get("world")
	_check(world != null and world is Object, "dominio world resuelto via bus.get")
	_check(world != null, "dominio world resuelto (propiedad del bus)")
	world.block_placed.emit(Vector3i(1, 2, 3), 5)
	world.block_placed.emit(Vector3i(4, 5, 6), 7)
	world.biome_changed.emit("playa", "bosque")
	var cap: Array = spy.capturadas()
	_check(cap.size() == 3, "spy: 3 capturas en el anillo (%d)" % cap.size())
	_check(spy.cuenta("world", "block_placed") == 2, "spy: cuenta world.block_placed == 2")
	_check(spy.cuenta("world", "biome_changed") == 1, "spy: cuenta world.biome_changed == 1")
	_check(spy.cuenta("world", "chunk_modified") == 0, "spy: senal no emitida cuenta 0")
	var ult = cap[cap.size() - 1]
	_check(String(ult.get("dominio", "")) == "world" and String(ult.get("evento", "")) == "biome_changed",
		"spy: la ultima captura es world.biome_changed")
	_check((ult.get("args") as Array).size() == 2 and (ult["args"] as Array)[0] == "playa",
		"spy: los args se conservan (playa -> bosque)")
	# Arity 3 (npc.gift_given) y arity 1 (quest.quest_completed)
	var npc = bus.get("npc")
	if npc != null and npc.has_signal("gift_given"):
		npc.gift_given.emit("bruno_sapo", "regalo_x", 2)
		_check(spy.cuenta("npc", "gift_given") == 1, "spy: senal de arity 3 capturada")
	var quest = bus.get("quest")
	if quest != null and quest.has_signal("quest_completed"):
		quest.quest_completed.emit("mision_test")
		_check(spy.cuenta("quest", "quest_completed") == 1, "spy: senal de arity 1 capturada")
	# limpiar + detach completos
	spy.limpiar()
	_check(spy.capturadas().is_empty() and spy.cuenta("world", "block_placed") == 0, "spy: limpiar vacia anillo y contadores")
	spy.detach()
	# tras detach: emitir de nuevo NO suma (sin conexion)
	world.block_removed.emit(Vector3i(9, 9, 9), 1)
	_check(spy.cuenta("world", "block_removed") == 0, "spy: tras detach no captura (bus limpio)")
	_check(spy.esta_activa() == false, "spy: inactivo tras detach")
