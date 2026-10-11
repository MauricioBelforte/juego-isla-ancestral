extends InteractableBase

@export var dialogue_id: String = "shaman_intro"
@export var spawn_position: Vector3 = Vector3(320, 35, 300)

const TIMEOUT_REINTENTOS_MS: int = 8000

var _ui: Control = null
var _reintentando: bool = false
var _t_inicio_reintentos: int = -1
var _locator = null  # inyectable en tests (patron IncenseSpawner)

func _ready() -> void:
	super._ready()
	categoria = &"npc"
	prioridad = 10
	radio = 2.5
	_crear_visuales()
	global_position = spawn_position
	# Reintento de altura (BUG-119 chaman, autorizado msg 74): mismo patron
	# _process del incienso (1 probe/frame, timeout 8s). Corrige el fallback
	# hardcodeado y=35 de main_island._crear_shaman cuando el locator existe
	# pero el terreno aun no responde (arranque --script). Sin locator o sin
	# MundoRaiz se queda en spawn_position (historico). NUNCA call_deferred
	# recursivo (SIGSEGV, ver Log 1475 / 11-BUGS).
	set_process(false)
	var locator = _locator if _locator != null else get_node_or_null("/root/TerrainLocator")
	var mundo := get_node_or_null("/root/MundoRaiz")
	if locator and locator.has_method("get_height") and mundo:
		var tx := float(mundo.CENTRO.x) - 240.0
		var tz := float(mundo.CENTRO.y) - 260.0
		if int(locator.get_height(tx, tz)) < 0:
			_t_inicio_reintentos = Time.get_ticks_msec()
			_reintentando = true
			set_process(true)

func _process(_delta: float) -> void:
	if not _reintentando:
		return
	if not is_inside_tree():
		_reintentando = false
		set_process(false)
		return
	if Time.get_ticks_msec() - _t_inicio_reintentos > TIMEOUT_REINTENTOS_MS:
		_reintentando = false
		set_process(false)
		push_warning("[M163] ShamanNPC: altura sin resolver tras %d ms; se queda en el fallback"
				% TIMEOUT_REINTENTOS_MS)
		return
	var locator = _locator if _locator != null else get_node_or_null("/root/TerrainLocator")
	var mundo := get_node_or_null("/root/MundoRaiz")
	if locator == null or not locator.has_method("get_height") or mundo == null:
		return
	var tx := float(mundo.CENTRO.x) - 240.0
	var tz := float(mundo.CENTRO.y) - 260.0
	var h := int(locator.get_height(tx, tz))
	if h >= 0:
		_reintentando = false
		set_process(false)
		global_position = Vector3(tx, h + 1.0, tz)
		print("[M163] ShamanNPC reposicionado sobre el terreno: ", global_position)

# BUG-124 (encargo msg 82): placeholder visual con el mismo patron que
# villager.gd::_crear_visuales (capsula + cabeza + Label3D). Sin
# CollisionShape3D: villager lo necesita por ser CharacterBody3D; aca el nodo
# es Node3D plano (InteractableBase) y la interaccion es por radio, sin
# fisicas. Sin material override: mismo estilo por defecto que los demas NPCs.
func _crear_visuales() -> void:
	var body_mesh: MeshInstance3D = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.25
	capsule.height = 1.0
	body_mesh.mesh = capsule
	body_mesh.position.y = 0.5
	body_mesh.name = "Body"
	add_child(body_mesh)

	var head_mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.2
	head_mesh.mesh = sphere
	head_mesh.position.y = 1.2
	head_mesh.name = "Head"
	add_child(head_mesh)

	var label := Label3D.new()
	label.text = "Chamán"
	label.font_size = 42
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 2.0
	label.modulate = Color(1, 1, 1, 0.95)
	label.outline_size = 6
	label.name = "LabelNombre"
	add_child(label)

func interactuar(_datos: Dictionary) -> void:
	# M163 B: dialogo contextual local segun progresion (L47/L56/L57/L58).
	#  - 0 encantos -> shaman_intro (primera visita)
	#  - 1+ encantos -> shaman_regreso (recuerda {encantos} encantos)
	#  - todas encantadas -> shaman_todas (frase especial)
	var system = get_node_or_null("/root/EnchantmentSystem")
	var encantos := 0
	if system and system.has_method("get_encantos_totales"):
		encantos = system.get_encantos_totales()
	var inventario = get_node_or_null("/root/Inventario")
	var item_db = get_node_or_null("/root/ItemDatabase")
	var ui_script = load("res://scripts/enchantment/shaman_ui.gd")
	var ids: Array = []
	if ui_script and ui_script.has_method("ids_herramientas"):
		ids = ui_script.ids_herramientas(inventario, item_db)
	var todas := bool(system and system.has_method("todas_encantadas")
			and system.todas_encantadas(ids))
	var id_dialogo := dialogue_id
	if todas:
		id_dialogo = "shaman_todas"
	elif encantos > 0:
		id_dialogo = "shaman_regreso"
	var dialogue_manager = get_node_or_null("/root/DialogueManager")
	if dialogue_manager and dialogue_manager.has_method("start_dialogue"):
		# start_dialogue valida el grafo; si falla, la UI se abre igual (degrada
		# a sin dialogo en vez de bloquear el flujo — RF cozy).
		dialogue_manager.start_dialogue(id_dialogo, {"npc_id": name, "encantos": encantos})
	_abrir_ui_encantamiento()

func _abrir_ui_encantamiento() -> void:
	if _ui:
		_ui.cerrar()
		_ui = null
		return

	var ui_script = preload("res://scripts/enchantment/shaman_ui.gd")
	if not ui_script:
		push_warning("[ShamanNPC] ShamanUI no disponible")
		return

	_ui = ui_script.new()
	_ui.npc_node = self
	var ui_root = get_node_or_null("/root/UIRoot")
	if ui_root:
		ui_root.add_child(_ui)
	_ui.abrir()
