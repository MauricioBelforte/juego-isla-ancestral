# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-19
#
# M62: Memoria — PoolFactory
# Construcción tipada de los objetos de cada familia del pool global
# (diseño §4 / 04-Codigo.md §1). Cada familia declara su tipo de nodo, su
# límite y cuántos ítems conviene precalentar al arrancar.
#
# El contrato de "ítem limpio" (diseño §4): al volver al pool un objeto queda
# INVISIBLE, QUIETO, SIN SEÑALES y SIN REFERENCIAS EXTERNAS. La parte de
# señales/visibilidad/proceso la aplica `GlobalPool.devolver()`; lo específico
# de cada familia lo aplica el propio objeto si expone `reiniciar_pool()`.
# Ese método es OPCIONAL y se detecta con `has_method` (nunca se asume).

class_name PoolFactory
extends RefCounted

## Familias del diseño §4. `tipo` es la clase de nodo a instanciar.
## `limite` y `precalentamiento` son los valores base; M90 puede ajustarlos.
const FAMILIAS: Dictionary = {
	"audio_voz":        {"tipo": "AudioStreamPlayer", "limite": 24,  "precalentamiento": 8},
	"particula":        {"tipo": "GPUParticles3D",    "limite": 64,  "precalentamiento": 8},
	"mesh_chunk":       {"tipo": "MeshInstance3D",    "limite": 256, "precalentamiento": 0},
	"objeto_recogible": {"tipo": "Node3D",            "limite": 64,  "precalentamiento": 0},
	"texto_efimero":    {"tipo": "Label",             "limite": 32,  "precalentamiento": 4},
	"npc_temporal":     {"tipo": "Node3D",            "limite": 16,  "precalentamiento": 0},
}

## Familias que el diseño §4 pide precalentar al arrancar / pantalla de carga.
const PRECALENTAMIENTO_ARRANQUE: Array[String] = ["audio_voz", "particula", "texto_efimero"]

func familia_valida(familia: String) -> bool:
	return FAMILIAS.has(familia)

func familias() -> Array:
	var nombres: Array = FAMILIAS.keys()
	nombres.sort()
	return nombres

func tipo_de(familia: String) -> String:
	var bloque: Variant = FAMILIAS.get(familia, {})
	if typeof(bloque) != TYPE_DICTIONARY:
		return ""
	return String((bloque as Dictionary).get("tipo", ""))

func limite_de(familia: String) -> int:
	var bloque: Variant = FAMILIAS.get(familia, {})
	if typeof(bloque) != TYPE_DICTIONARY:
		return 0
	return int((bloque as Dictionary).get("limite", 0))

func precalentamiento_de(familia: String) -> int:
	var bloque: Variant = FAMILIAS.get(familia, {})
	if typeof(bloque) != TYPE_DICTIONARY:
		return 0
	return int((bloque as Dictionary).get("precalentamiento", 0))

## Mapa familia -> límite, listo para `GlobalPool.set_limite()`.
func limites() -> Dictionary:
	var salida: Dictionary = {}
	for familia in FAMILIAS:
		salida[String(familia)] = limite_de(String(familia))
	return salida

## Crea un objeto de la familia en estado ESTACIONADO (invisible/quieto).
## Devuelve null si la familia no existe o el tipo no es instanciable.
func crear(familia: String) -> Node:
	if not familia_valida(familia):
		push_warning("[M62] PoolFactory: familia desconocida '%s'" % familia)
		return null
	var tipo := tipo_de(familia)
	var obj: Node = null
	match tipo:
		"AudioStreamPlayer":
			obj = AudioStreamPlayer.new()
		"GPUParticles3D":
			var gp := GPUParticles3D.new()
			gp.emitting = false
			obj = gp
		"MeshInstance3D":
			obj = MeshInstance3D.new()
		"Label":
			var lbl := Label.new()
			lbl.visible = false
			obj = lbl
		"Node3D":
			obj = Node3D.new()
		_:
			push_warning("[M62] PoolFactory: tipo no soportado '%s'" % tipo)
			return null
	_estacionar(obj)
	return obj

## Estado limpio mínimo y común a toda familia (el resto lo hace GlobalPool).
func _estacionar(obj: Node) -> void:
	obj.set_process(false)
	obj.set_physics_process(false)
	if obj is CanvasItem:
		(obj as CanvasItem).visible = false
	if obj is Node3D:
		var n3 := obj as Node3D
		n3.visible = false
		n3.position = Vector3.ZERO
		n3.rotation = Vector3.ZERO
	if obj is AudioStreamPlayer:
		(obj as AudioStreamPlayer).stream = null
		(obj as AudioStreamPlayer).stop()

## Aplica los límites de la tabla al pool dado. Devuelve cuántos aplicó.
func aplicar_limites(pool: GlobalPool) -> int:
	if pool == null:
		return 0
	var n := 0
	for familia in FAMILIAS:
		pool.set_limite(String(familia), limite_de(String(familia)))
		n += 1
	return n

## Precalienta las familias de arranque (diseño §6.1). Nunca en mitad de
## gameplay: `GlobalPool` rechaza la llamada si el gameplay ya arrancó.
func precalentar_arranque(pool: GlobalPool) -> int:
	if pool == null:
		return 0
	var total := 0
	for familia in PRECALENTAMIENTO_ARRANQUE:
		var n := precalentamiento_de(familia)
		if n > 0:
			total += pool.precalentar(familia, n, Callable(self, "crear").bind(familia))
	return total
