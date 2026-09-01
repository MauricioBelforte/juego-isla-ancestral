# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M21 (consumo de M20): Test headless de que DialogueManager reacciona al regalo
# por clase exacta de GiftEvaluator.Clase y al subir de nivel de amistad.
#
# El cableado vive en _ready() (suscripcion a EventBus.npc.gift_given /
# friendship_level_up). Este test usa el autoload real /root/DialogueManager,
# cuyo _ready() ya se ejecuto al iniciar el SceneTree.
#
# NOTA: en --script los autoloads se anaden al arbol DESPUES de _init(), por eso
# la ejecucion se difiere con call_deferred (como test_amistad_eventos.gd).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/dialogos/test_reaccion_m21_dialogo.gd

extends SceneTree

var _fallos: int = 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_test_reaccion_regalo_clases()
	_test_reaccion_regalo_almacenada()
	_test_reaccion_level_up()
	print("=== TEST REACCION M21 (consumo gift_given M20): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

## M20 -> M21: cada clase de GiftEvaluator se traduce a la reaccion de dialogo
## correcta (R_AMADO/R_GUSTA/R_NEUTRAL/R_DUPLICADO) y propaga item_id.
func _test_reaccion_regalo_clases() -> void:
	var dm: Node = root.get_node_or_null("/root/DialogueManager")
	var bus: Node = root.get_node_or_null("/root/EventBus")
	if dm == null or bus == null or bus.npc == null:
		_check(false, "M21: autoloads DialogueManager y EventBus presentes")
		return
	var recibidas: Array = []
	dm.gift_reaction.connect(func(npc_id: String, reaccion_id: String, clase: int, item_id: String, expresion: String):
		recibidas.append({"npc": npc_id, "id": reaccion_id, "clase": clase, "item": item_id, "expresion": expresion}))
	bus.npc.gift_given.emit("R_T1", "FLOR", int(0))
	bus.npc.gift_given.emit("R_T2", "MANZANA", int(1))
	bus.npc.gift_given.emit("R_T3", "PIEDRA", int(2))
	bus.npc.gift_given.emit("R_T4", "VELA", int(3))
	_check(recibidas.size() == 4, "M21: 4 reacciones emitidas por gift_reaction")
	if recibidas.size() == 4:
		_check(recibidas[0]["id"] == "R_AMADO", "M21: clase 0 -> R_AMADO")
		_check(recibidas[1]["id"] == "R_GUSTA", "M21: clase 1 -> R_GUSTA")
		_check(recibidas[2]["id"] == "R_NEUTRAL", "M21: clase 2 -> R_NEUTRAL")
		_check(recibidas[3]["id"] == "R_DUPLICADO", "M21: clase 3 -> R_DUPLICADO")
		_check(recibidas[0]["item"] == "FLOR", "M21: item_id propagado en reaccion (FLOR)")
		_check(int(recibidas[1]["clase"]) == 1, "M21: clase propagada exacta (1)")

## M20 -> M21: la ultima reaccion queda guardada por NPC para dialogos
## subsiguientes (contexto de la UI).
func _test_reaccion_regalo_almacenada() -> void:
	var dm: Node = root.get_node_or_null("/root/DialogueManager")
	var bus: Node = root.get_node_or_null("/root/EventBus")
	if dm == null or bus == null:
		return
	bus.npc.gift_given.emit("R_STORE", "FRESIA", int(1))
	var r: Dictionary = dm.get_ultima_reaccion_regalo("R_STORE")
	_check(not r.is_empty(), "M21: ultima reaccion almacenada para R_STORE")
	if not r.is_empty():
		_check(str(r.get("id")) == "R_GUSTA", "M21: reaccion almacenada = R_GUSTA")
		_check(str(r.get("item_id")) == "FRESIA", "M21: item almacenado = FRESIA")
		_check(str(r.get("expresion")) == "feliz", "M21: expresion almacenada = feliz")
	_check(dm.get_ultima_reaccion_regalo("R_INEXISTENTE").is_empty(),
		"M21: NPC sin regalo devuelve {}")

## M20 -> M21: el ascenso de nivel de amistad tambien se reenvia a la UI.
func _test_reaccion_level_up() -> void:
	var dm: Node = root.get_node_or_null("/root/DialogueManager")
	var bus: Node = root.get_node_or_null("/root/EventBus")
	if dm == null or bus == null or bus.npc == null:
		_check(false, "M21: autoloads presentes para level_up")
		return
	var lvl: Array = []
	dm.level_up_reaction.connect(func(npc_id: String, new_level: int):
		lvl.append({"npc": npc_id, "lvl": new_level}))
	bus.npc.friendship_level_up.emit("R_LU", 3)
	_check(lvl.size() == 1, "M21: level_up_reaction emitida")
	if lvl.size() == 1:
		_check(int(lvl[0]["lvl"]) == 3, "M21: level_up nuevo nivel = 3")
		_check(str(lvl[0]["npc"]) == "R_LU", "M21: level_up npc = R_LU")
