extends CharacterBody3D

## Módulo 19: NPC y Vecinos — Instancia runtime de un vecino
##
## Representa un NPC activo en la isla. Tiene perfil, mood, hook de diálogo,
## representación visual placeholder (cápsula + esfera + Label3D),
## e indicador de interacción.

const VillagerProfileScript = preload("res://scripts/npc/villager_profile.gd")
const VillagerMoodScript = preload("res://scripts/npc/villager_mood.gd")
const VillagerDialogueHookScript = preload("res://scripts/npc/villager_dialogue_hook.gd")

## ── Señales ────────────────────────────────────────────
signal interaccion_solicitada(vecino: Node)
signal disponible_cambio(esta_disponible: bool)

## ── Configuración ──────────────────────────────────────
@export var perfil: Resource
## M21: id del diálogo en data/dialogues/ (ej: "catalina_hola")
@export var dialogue_id: String = ""

## ── Nodos internos ─────────────────────────────────────
var mood: Node
var hook: Node
var _indicador: Node3D = null
var _label_nombre: Label3D = null
var _ocupado: bool = false
var _jugador_cercano: bool = false

## ── Constantes ─────────────────────────────────────────
const RANGO_INTERACCION: float = 3.0
const RANGO_INDICADOR: float = 5.0


func _ready() -> void:
	add_to_group("villagers")
	_crear_visuales()
	_crear_componentes()
	_crear_indicador()
	if perfil:
		_aplicar_perfil()
	# Snap al terreno: buscar la altura real del suelo en mi posición XZ
	# call_deferred porque current_scene no está listo durante _ready()
	_snap_to_ground.call_deferred()
	print("[Villager] %s creado (especie=%s)" % [perfil.nombre if perfil else "?", perfil.especie if perfil else "?"])


func _process(_delta: float) -> void:
	if not _jugador_cercano:
		return
	# Rotar indicador hacia la cámara (siempre visible)
	if _indicador and _indicador.visible:
		var cam: Camera3D = get_viewport().get_camera_3d()
		if cam:
			_indicador.look_at(cam.global_position, Vector3.UP)


## ── Creación de visuales placeholder ───────────────────

func _crear_visuales() -> void:
	# Cuerpo (cápsula)
	var body_mesh: MeshInstance3D = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.25
	capsule.height = 1.0
	body_mesh.mesh = capsule
	body_mesh.position.y = 0.5
	body_mesh.name = "Body"
	add_child(body_mesh)

	# Cabeza (esfera)
	var head_mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.2
	head_mesh.mesh = sphere
	head_mesh.position.y = 1.2
	head_mesh.name = "Head"
	add_child(head_mesh)

	# Label del nombre
	_label_nombre = Label3D.new()
	_label_nombre.text = perfil.nombre if perfil else "Vecino"
	_label_nombre.font_size = 22
	_label_nombre.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label_nombre.position.y = 2.0
	_label_nombre.modulate = Color(1, 1, 1, 0.9)
	_label_nombre.name = "LabelNombre"
	add_child(_label_nombre)

	# Colisión (capsule)
	var col: CollisionShape3D = CollisionShape3D.new()
	var shape: CapsuleShape3D = CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.6
	col.shape = shape
	col.position.y = 0.8
	add_child(col)


## ── Componentes lógicos ────────────────────────────────

func _crear_componentes() -> void:
	mood = VillagerMoodScript.new()
	mood.name = "Mood"
	add_child(mood)

	hook = VillagerDialogueHookScript.new()
	hook.name = "DialogueHook"
	add_child(hook)
	hook.inicializar(self)
	hook.dialogue_id = dialogue_id


## ── Indicador de interacción (F) ───────────────────────

func _crear_indicador() -> void:
	_indicador = Node3D.new()
	_indicador.name = "IndicadorInteraccion"
	_indicador.visible = false

	var label: Label3D = Label3D.new()
	label.text = "[ F ]"
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 2.2
	label.modulate = Color(1, 1, 0.5, 0.9)
	_indicador.add_child(label)

	add_child(_indicador)


## ── Snap al terreno ───────────────────────────────────

func _snap_to_ground() -> void:
	# Usar el generador de mundo directamente (determinista, no necesita chunks)
	var generator_script = load("res://scripts/world/island_generator.gd")
	if generator_script:
		var gen = generator_script.new(null, 42)  # seed=42, same as main_island
		gen.island_radius = 1024  # DEBE coincidir con el radio de la isla actual (main_island.gd)
		gen.max_height = 40
		var h: int = gen.get_height(int(global_position.x), int(global_position.z))
		if h > 0:
			global_position.y = float(h) + 1.0
			print("[Villager] %s snap al terreno en Y=%.1f (height=%d)" % [name, global_position.y, h])
			return
	# Fallback: mantener posición actual
	print("[Villager] %s no pudo calcular altura, manteniendo Y=%.1f" % [name, global_position.y])


## ── Aplicar datos del perfil a los visuales ────────────

func _aplicar_perfil() -> void:
	if _label_nombre:
		_label_nombre.text = perfil.nombre

	# Colorear cuerpo y cabeza según perfil
	var body: MeshInstance3D = get_node_or_null("Body") as MeshInstance3D
	var head: MeshInstance3D = get_node_or_null("Head") as MeshInstance3D
	if body and body.mesh:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = perfil.color_cuerpo
		body.material_override = mat
	if head and head.mesh:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = perfil.color_cabeza
		head.material_override = mat

	# Aplicar escala
	var escala: float = perfil.escala_cuerpo
	scale = Vector3(escala, escala, escala)


## ── Interacción (llamado por VillagerManager) ──────────

func interactuar(jugador: Node3D) -> void:
	if _ocupado:
		print("[Villager] %s está ocupado, no puede interactuar" % perfil.nombre if perfil else "?")
		return
	hook.solicitar_dialogo()
	print("[Villager] %s interactúa con el jugador" % perfil.nombre if perfil else "?")


func recibir_regalo(objeto_id: String) -> void:
	if not perfil:
		return
	var valor: float = perfil.evaluar_objeto(objeto_id)
	mood.aplicar_delta(valor, "regalo_%s" % objeto_id)
	hook.linea_reaccion_regalo(objeto_id)
	print("[Villager] %s recibió %s (valor=%.1f, ánimo=%.2f)" % [perfil.nombre, objeto_id, valor, mood.animo_efectivo()])


func set_ocupado(ocupado: bool) -> void:
	_ocupado = ocupado
	disponible_cambio.emit(not _ocupado)


func obtener_estado_animo() -> String:
	return mood.estado_emocional()


func obtener_perfil() -> Resource:
	return perfil


func esta_disponible() -> bool:
	return not _ocupado


func mostrar_indicador(mostrar: bool) -> void:
	_jugador_cercano = mostrar
	if _indicador:
		_indicador.visible = mostrar
