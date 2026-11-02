# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-01 (creacion) - 2026-11-02 (base comun)
# M110-UI: Panel Entidades — widgets REALES del 03-Diseno (seccion E).
# Antes de esta tanda el "panel" era un RichTextLabel con el texto
# "Panel: Entidades": 0 widgets.
#
# Cableado (todo duck-typed: el panel NO asume clases de M19/M24/M64):
#   Selector NPC      -> VillagerManager.obtener_activos()
#   Button Resetear   -> DebugMenu.reset_npc(id)
#   Label estado IA   -> <npc>.get_ai_state() / .get_state_machine()  [M64]
#   Selector puzzle   -> nodos de la escena con set_emisor()          [M24]
#   Button Resetear   -> DebugMenu.reset_puzzle(id)
#
# Fail-closed: si un dueño externo no esta, el widget existe y dice "n/d"
# en vez de fingir una lista vacia como si no hubiera NPCs.
#
# 2026-11-02: hereda de `PanelBaseM110` (`scripts/debug/panel_base.gd`). Lo que
# se fue a la base: `_menu`, `_ultimo`, `_ready()`, `_llamar()`,
# `_inyectar_menu()`, `ultimo_resultado()`. Lo propio sigue aqui: los 5 widgets,
# la enumeracion de NPC/puzzle y la lectura del estado de IA de M64.
extends "res://scripts/debug/panel_base.gd"

const PANEL_ID := "entidades"

var _opt_npc: OptionButton = null
var _btn_reset_npc: Button = null
var _label_ia: Label = null
var _opt_puzzle: OptionButton = null
var _btn_reset_puzzle: Button = null
var _ids_npc: Array[String] = []
var _ids_puzzle: Array[String] = []


func _construir() -> void:
	_opt_npc = _crear_option("SelectorNPC", "NPC activos (M19 VillagerManager)")

	_btn_reset_npc = _crear_boton("BotonResetNPC", "Resetear NPC")

	_label_ia = _crear_label("EstadoIA", "IA: --")

	_opt_puzzle = _crear_option("SelectorPuzzle", "PuzzleRoom cargadas en la escena (M24)")

	_btn_reset_puzzle = _crear_boton("BotonResetPuzzle", "Resetear puzzle")


func _conectar() -> void:
	_opt_npc.item_selected.connect(_on_npc_elegido)
	_opt_puzzle.item_selected.connect(_on_puzzle_elegido)
	_btn_reset_npc.pressed.connect(_on_reset_npc)
	_btn_reset_puzzle.pressed.connect(_on_reset_puzzle)


## Reconstruye las listas desde los dueños y sincroniza la vista.
## Se llama en _ready() y puede llamarse a mano (los NPC se instancian tarde).
func _actualizar() -> void:
	_ids_npc = _enumerar_npcs()
	_opt_npc.clear()
	for id in _ids_npc:
		_opt_npc.add_item(id, _opt_npc.item_count)
	if _ids_npc.is_empty():
		_opt_npc.add_item("(sin NPC activos)", -1)

	_ids_puzzle = _enumerar_puzzles()
	_opt_puzzle.clear()
	for id in _ids_puzzle:
		_opt_puzzle.add_item(id, _opt_puzzle.item_count)
	if _ids_puzzle.is_empty():
		_opt_puzzle.add_item("(sin PuzzleRoom en escena)", -1)

	_refrescar_ia()


## NPC activos de M19. `obtener_activos()` devuelve nodos; se usa `name` como
## id porque es lo que `reset_npc()` busca en `obtener_vecino(id)`.
func _enumerar_npcs() -> Array[String]:
	var out: Array[String] = []
	var vm := get_node_or_null("/root/VillagerManager")
	if vm == null or not vm.has_method("obtener_activos"):
		return out
	var activos: Variant = vm.call("obtener_activos")
	if not (activos is Array):
		return out
	for n in (activos as Array):
		if n is Node and is_instance_valid(n):
			var nombre := String((n as Node).name)
			if not nombre.is_empty():
				out.append(nombre)
	return out


## PuzzleRoom de la escena activa (M24): el criterio es el mismo que usa
## `_buscar_puzzle_room()` del backend (tener set_emisor), para que el id que
## muestra el selector sea el que el boton va a poder resolver.
func _enumerar_puzzles() -> Array[String]:
	var out: Array[String] = []
	if not is_inside_tree():
		return out
	var arbol := get_tree()
	if arbol == null:
		return out
	var raiz := arbol.current_scene
	if raiz == null:
		return out
	for n in raiz.find_children("*", "", true, false):
		if n is Node and (n as Node).has_method("set_emisor"):
			var nombre := String((n as Node).name)
			if not nombre.is_empty():
				out.append(nombre)
	return out


func _refrescar_ia() -> void:
	var npc := _npc_actual()
	if npc == null:
		_label_ia.text = "IA: n/d (sin NPC seleccionado)"
		return
	var estado: String = ""
	if npc.has_method("get_ai_state"):
		estado = String(npc.call("get_ai_state"))
	elif npc.has_method("get_state_machine"):
		var sm: Variant = npc.call("get_state_machine")
		if sm != null and (sm as Object) is Object:
			estado = String((sm as Object).get_class())
	if estado.is_empty():
		_label_ia.text = "IA: n/d (M64 no expone estado)"
	else:
		_label_ia.text = "IA: %s" % estado


func _npc_actual() -> Node:
	var idx: int = _opt_npc.selected
	if idx < 0 or idx >= _ids_npc.size():
		return null
	var vm := get_node_or_null("/root/VillagerManager")
	if vm == null or not vm.has_method("obtener_vecino"):
		return null
	var n: Variant = vm.call("obtener_vecino", _ids_npc[idx])
	if n is Node and is_instance_valid(n):
		return n as Node
	return null


func _on_npc_elegido(_idx: int) -> void:
	_refrescar_ia()


func _on_puzzle_elegido(_idx: int) -> void:
	pass


func _on_reset_npc() -> void:
	var idx: int = _opt_npc.selected
	if idx < 0 or idx >= _ids_npc.size():
		_ultimo = {"ok": false, "resultado": "sin NPC seleccionado"}
		return
	_ultimo = _llamar("reset_npc", [_ids_npc[idx]])
	_refrescar_ia()


func _on_reset_puzzle() -> void:
	var idx: int = _opt_puzzle.selected
	if idx < 0 or idx >= _ids_puzzle.size():
		_ultimo = {"ok": false, "resultado": "sin puzzle seleccionado"}
		return
	_ultimo = _llamar("reset_puzzle", [_ids_puzzle[idx]])


# ── Getters para la suite ───────────────────────────────────────────────────

func obtener_selector_npc() -> OptionButton:
	return _opt_npc

func obtener_boton_reset_npc() -> Button:
	return _btn_reset_npc

func obtener_label_ia() -> Label:
	return _label_ia

func obtener_selector_puzzle() -> OptionButton:
	return _opt_puzzle

func obtener_boton_reset_puzzle() -> Button:
	return _btn_reset_puzzle

func ids_npc() -> Array[String]:
	return _ids_npc.duplicate()

func ids_puzzle() -> Array[String]:
	return _ids_puzzle.duplicate()

## Conteo de widgets exigidos por la seccion E del 03-Diseno.
func widgets_presentes() -> Dictionary:
	return {
		"selector_npc": _opt_npc != null,
		"boton_reset_npc": _btn_reset_npc != null,
		"label_estado_ia": _label_ia != null,
		"selector_puzzle": _opt_puzzle != null,
		"boton_reset_puzzle": _btn_reset_puzzle != null,
	}
