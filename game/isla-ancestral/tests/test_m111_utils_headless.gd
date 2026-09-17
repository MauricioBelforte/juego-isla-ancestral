extends SceneTree

## Test headless de las utilidades M111 (Codigo de Calidad) — Log 891.
## Ejecuta sin GdUnit4: verifica MathUtils, ValidationUtils, FormatUtils,
## GameConstants, GameEnums y structs *Struct con asserts propios.
## Uso: godot --headless -s res://tests/test_m111_utils_headless.gd
## Exit: 0 = todo OK, 1 = algun fallo.

var _passed := 0
var _failed := 0
var _fails: Array = []


func _check(cond: bool, nombre: String, detalle := "") -> void:
	if cond:
		_passed += 1
	else:
		_failed += 1
		_fails.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))


func _initialize() -> void:
	print("=== M111 utils headless (Log 891) ===")
	_test_math_utils()
	_test_validation_utils()
	_test_format_utils()
	_test_game_constants()
	_test_game_enums()
	_test_structs()
	_test_patterns()
	_test_components()
	print("M111-UTILS-P1: passed=%d failed=%d" % [_passed, _failed])
	for f in _fails:
		print("  FALLO: " + str(f))
	if _failed > 0:
		quit(1)
	else:
		quit(0)


func _test_math_utils() -> void:
	_check(MathUtils.distance_squared(Vector3.ZERO, Vector3(3, 4, 0)) == 25.0, "math.distance_squared 3-4-5")
	_check(MathUtils.distance_squared(Vector3.ONE, Vector3.ONE) == 0.0, "math.distance_squared cero")
	_check(MathUtils.lerp_value(0.0, 10.0, 0.5) == 5.0, "math.lerp medio")
	_check(MathUtils.lerp_value(2.0, 4.0, 0.0) == 2.0, "math.lerp t=0")
	_check(MathUtils.lerp_value(2.0, 4.0, 1.0) == 4.0, "math.lerp t=1")
	_check(MathUtils.clamp_value(99.0, 0.0, 10.0) == 10.0, "math.clamp alto")
	_check(MathUtils.clamp_value(-5.0, 0.0, 10.0) == 0.0, "math.clamp bajo")
	_check(MathUtils.clamp_value(5.0, 0.0, 10.0) == 5.0, "math.clamp medio")
	var n: float = MathUtils.normalize_angle(3.0 * PI)
	_check(abs(n - -PI) < 0.0001 or abs(n - PI) < 0.0001, "math.normalize 3PI", str(n))
	_check(abs(MathUtils.normalize_angle(0.0)) < 0.0001, "math.normalize 0")


func _test_validation_utils() -> void:
	_check(ValidationUtils.is_valid_position(Vector3(10, 0, -20)), "valid.pos OK")
	_check(not ValidationUtils.is_valid_position(Vector3(99999, 0, 0)), "valid.pos fuera de mundo")
	_check(not ValidationUtils.is_valid_position("no-vector"), "valid.pos no-Vector3")
	_check(not ValidationUtils.is_valid_position(Vector3(NAN, 0, 0)), "valid.pos NaN")
	_check(ValidationUtils.is_valid_item_id("item_hacha_01"), "valid.item prefijo")
	_check(not ValidationUtils.is_valid_item_id(""), "valid.item vacio")
	_check(not ValidationUtils.is_valid_item_id("con espacio"), "valid.item espacio")
	_check(ValidationUtils.is_valid_npc_id("npc_catalina"), "valid.npc prefijo")
	_check(not ValidationUtils.is_valid_npc_id(""), "valid.npc vacio")
	_check(ValidationUtils.is_valid_mission_id("mission_intro_01"), "valid.mission mission_")
	_check(ValidationUtils.is_valid_mission_id("quest_sec_02"), "valid.mission quest_")
	_check(not ValidationUtils.is_valid_mission_id(""), "valid.mission vacio")
	_check(not ValidationUtils.is_valid_mission_id("con espacio"), "valid.mission espacio")


func _test_format_utils() -> void:
	_check(FormatUtils.format_time(65.0) == "01:05", "format.tiempo mm:ss")
	_check(FormatUtils.format_time(3661.0) == "01:01:01", "format.tiempo hh:mm:ss")
	_check(FormatUtils.format_time(0.0) == "00:00", "format.tiempo cero")
	_check(FormatUtils.format_money(150) == "150 monedas", "format.dinero")


func _test_game_constants() -> void:
	_check(GameConstants.MAX_INVENTORY_SIZE == 64, "const.inventario 64")
	_check(GameConstants.DAY_DURATION_SECONDS == 600.0, "const.dia 600s")
	_check(GameConstants.CHUNK_SIZE == 32, "const.chunk 32")
	_check(GameConstants.MAX_PLAYERS == 1, "const.jugadores 1")
	_check(GameConstants.MAX_SAVE_SLOTS == 5, "const.slots 5")
	_check(GameConstants.AUTO_SAVE_INTERVAL_SECONDS == 120.0, "const.autosave 120s")


func _test_game_enums() -> void:
	_check(int(GameEnums.State.IDLE) == 0, "enum.state IDLE=0")
	_check(int(GameEnums.State.FARMING) == 7, "enum.state FARMING=7")
	_check(int(GameEnums.Category.GAMEPLAY) == 0, "enum.category GAMEPLAY=0")
	_check(int(GameEnums.Category.SYSTEM) == 3, "enum.category SYSTEM=3")
	_check(int(GameEnums.Priority.LOW) == 0, "enum.priority LOW=0")
	_check(int(GameEnums.Priority.IMMEDIATE) == 3, "enum.priority IMMEDIATE=3")


func _test_structs() -> void:
	var p := PlayerDataStruct.new()
	p.id = "player_01"
	p.display_name = "Ailo"
	p.health = 80.0
	p.level = 3
	_check(p.id == "player_01" and p.display_name == "Ailo", "struct.player campos")
	_check(p.health == 80.0 and p.level == 3, "struct.player stats")
	_check(p.position == Vector3.ZERO, "struct.player pos default")
	var it := ItemDataStruct.new()
	it.id = "item_semilla_01"
	it.name = "Semilla"
	it.stack_size = 10
	it.value = 5
	_check(it.id == "item_semilla_01" and it.stack_size == 10, "struct.item campos")
	var npc := NPCDataStruct.new()
	npc.id = "npc_catalina"
	npc.name = "Catalina"
	npc.friendship = 25.0
	_check(npc.id == "npc_catalina" and npc.friendship == 25.0, "struct.npc campos")
	_check(npc.schedule is Dictionary, "struct.npc schedule dict")
	var m := MissionDataStruct.new()
	m.id = "mission_intro_01"
	m.title = "Llegada"
	m.objectives = ["hablar", "explorar"]
	_check(m.id == "mission_intro_01" and m.objectives.size() == 2, "struct.mission campos")


func _test_patterns() -> void:
	var sm := StateMachine.new()
	var log: Array = []
	sm.register_state("a", func(_o): log.append("enter_a"), func(_o): log.append("exit_a"))
	sm.register_state("b", func(_o): log.append("enter_b"))
	sm.setup(null)
	sm.change_state("a")
	sm.change_state("b")
	_check(sm.current_state == "b", "pattern.sm estado actual")
	_check(log == ["enter_a", "exit_a", "enter_b"], "pattern.sm orden callbacks", str(log))
	var f := Factory.new()
	f.register("doble", func(x): return int(x) * 2)
	_check(int(str(f.create("doble", 21))) == 42, "pattern.factory crea")
	_check(f.create("inexistente") == null, "pattern.factory id-malo null")
	var c := Command.new(func(x): log.append("cmd"), func(x): return true)
	c.execute(null)
	_check(log.has("cmd"), "pattern.command ejecuta")
	var c2 := Command.new(func(x): log.append("no"), func(x): return false)
	c2.execute(null)
	_check(not log.has("no"), "pattern.command guarda bloquea")
	var s := Strategy.new()
	_check(s.execute(null) == null, "pattern.strategy base null")


func _test_components() -> void:
	var h := HealthComponent.new()
	h.max_health = 100.0
	h._current = 100.0
	h.damage(30.0)
	_check(h.current_health == 70.0, "comp.health dano", str(h.current_health))
	h.heal(50.0)
	_check(h.current_health == 100.0, "comp.health clamp max", str(h.current_health))
	h.damage(200.0)
	_check(h.current_health == 0.0, "comp.health clamp min", str(h.current_health))
	var inv := InventoryComponent.new()
	inv.add_item("item_madera", 5)
	inv.add_item("item_madera", 3)
	_check(inv.count("item_madera") == 8, "comp.inv suma", str(inv.count("item_madera")))
	_check(inv.remove_item("item_madera", 3), "comp.inv retira ok")
	_check(inv.count("item_madera") == 5, "comp.inv resto", str(inv.count("item_madera")))
	_check(not inv.remove_item("item_madera", 99), "comp.inv sin-stock false")
	var st := StateComponent.new()
	st.set_state(2)
	_check(st.current_state == 2, "comp.state cambia")
	st.set_state(2)
	_check(st.current_state == 2, "comp.state idempotente")
