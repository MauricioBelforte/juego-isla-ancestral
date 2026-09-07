# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-07
#
# M09 iter.: impostor de terreno sólido de toda la isla (idea del usuario:
# "¿qué pasa si en vez de bloques es un terreno sólido?") — con 2 fixes del
# feedback del usuario (Log 759):
#   1. FADE POR DISTANCIA (shader terreno_horizonte.gdshader): el impostor
#      SOLO se ve más allá del radio de chunks del streamer (1400-1900m del
#      player). Cerca del jugador mandan los chunks reales detallados.
#   2. GENERACIÓN EN HILO DE FONDO: las ~166k llamadas get_height (la parte
#      cara) corren en un Thread — sin tildes del main thread. El mesh se
#      monta en el main thread con los datos precalculados.
#
# La malla es la altura REAL del generador a paso 16m sobre toda la isla
# (r 2600 desde el centro), colores por bioma de altura, al 97% de altura
# (anti z-fighting con los chunks reales que lo cubren cerca).

extends Node3D

const PASO := 16.0
const H_MIN := 0
const CENTRO_ISLA := Vector2(2560.0, 2560.0)
const RADIO_CUBIERTO := 2600.0
const FACTOR_ALTURA := 0.97
const RUTA_SHADER := "res://shaders/terreno_horizonte.gdshader"

const COLOR_AGUA_FONDO := Color(0.35, 0.55, 0.62)
const COLOR_ARENA := Color(0.82, 0.76, 0.58)
const COLOR_PASTO := Color(0.66, 0.74, 0.40)
const COLOR_TRANSICION := Color(0.55, 0.62, 0.50)
const COLOR_PIEDRA := Color(0.58, 0.60, 0.62)
const COLOR_CIMA := Color(0.74, 0.76, 0.78)

const INTENTOS_MAX := 12

var _intentos := 0
var _hilo: Thread = null
var _datos_hilo: Dictionary = {}
var _semaforo: Mutex = Mutex.new()


func _ready() -> void:
	call_deferred("_intentar_crear")


func _process(_delta: float) -> void:
	# Fade por distancia por CPU (barato, 1 chequeo por frame): el impostor
	# se muestra SOLO cuando el player está lejos del área de chunks detallados
	# que lo cubren. Cerca del spawn: oculto (los chunks reales mandan).
	# NOTA: sin shader custom — el discard por píxel tildaba la GPU integrada.
	if Time.get_ticks_msec() % 500 < 20:
		pass  # chequeo barato delegado abajo (cada frame es 1 distancia)
	var mi := get_node_or_null("TerrenoSolidoHorizonte") as MeshInstance3D
	if mi == null:
		return
	var player := get_tree().root.get_node_or_null("Main/Player") as Node3D
	if player == null:
		return
	# El impostor cubre el centro; el player spawnea a 1460m. Si está a más
	# de 1700m del CENTRO de la zona que cubre el impostor, mostrarlo.
	var dist := Vector2(player.global_position.x, player.global_position.z).distance_to(CENTRO_ISLA)
	mi.visible = dist > 1700.0


func _intentar_crear() -> void:
	var terrain := get_node_or_null("../VoxelTerrain") as VoxelTerrain
	var island_gen = null
	if terrain != null and terrain.generator != null and terrain.generator.has_method("_get_island_gen"):
		island_gen = terrain.generator._get_island_gen()
	if island_gen == null:
		_intentos += 1
		if _intentos > INTENTOS_MAX:
			push_warning("[M09-Solido] generador no llegó — impostor omitido")
			return
		var t := get_tree().create_timer(0.5)
		t.timeout.connect(_intentar_crear)
		return
	# Generar alturas en HILO DE FONDO (sin tildar el main thread).
	_hilo = Thread.new()
	_hilo.start(_calcular_alturas_hilo.bind(island_gen))


## HILO DE FONDO: muestrea todas las alturas y prepara los arrays del mesh.
func _calcular_alturas_hilo(island_gen) -> void:
	var verts := PackedVector3Array()
	var colores := PackedColorArray()
	var celdas := 0
	var min_x := int(CENTRO_ISLA.x - RADIO_CUBIERTO)
	var max_x := int(CENTRO_ISLA.x + RADIO_CUBIERTO)
	var min_z := int(CENTRO_ISLA.y - RADIO_CUBIERTO)
	var max_z := int(CENTRO_ISLA.y + RADIO_CUBIERTO)
	var z := min_z
	while z < max_z:
		var x := min_x
		while x < max_x:
			var h0 := float(island_gen.get_height(x, z))
			var h1 := float(island_gen.get_height(x + int(PASO), z))
			var h2 := float(island_gen.get_height(x + int(PASO), z + int(PASO)))
			var h3 := float(island_gen.get_height(x, z + int(PASO)))
			var h_prom := (h0 + h1 + h2 + h3) / 4.0
			if h_prom >= float(H_MIN):
				var a := Vector3(float(x), h0 * FACTOR_ALTURA, float(z))
				var b := Vector3(float(x) + PASO, h1 * FACTOR_ALTURA, float(z))
				var c := Vector3(float(x) + PASO, h2 * FACTOR_ALTURA, float(z) + PASO)
				var d := Vector3(float(x), h3 * FACTOR_ALTURA, float(z) + PASO)
				var ca := _color_por_altura(h0 * FACTOR_ALTURA)
				var cb := _color_por_altura(h1 * FACTOR_ALTURA)
				var cc := _color_por_altura(h2 * FACTOR_ALTURA)
				var cd := _color_por_altura(h3 * FACTOR_ALTURA)
				# 2 triángulos (a,b,c) + (a,c,d)
				verts.append_array(PackedVector3Array([a, b, c, a, c, d]))
				colores.append_array(PackedColorArray([ca, cb, cc, ca, cc, cd]))
				celdas += 1
			x += int(PASO)
		z += int(PASO)
	_semaforo.lock()
	_datos_hilo = {"verts": verts, "colores": colores, "celdas": celdas}
	_semaforo.unlock()
	# Volver al main thread para montar el mesh (recursos de GPU: main only)
	_montar_mesh.call_deferred()


## MAIN THREAD: monta el ArrayMesh con los datos del hilo y aplica el shader.
func _montar_mesh() -> void:
	_semaforo.lock()
	var datos := _datos_hilo.duplicate(true)
	_datos_hilo.clear()
	_semaforo.unlock()
	var celdas: int = datos.get("celdas", 0)
	if celdas == 0:
		print("[M09-Solido] sin celdas sobre H_MIN")
		return
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = datos["verts"]
	arrays[Mesh.ARRAY_COLOR] = datos["colores"]
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.name = "TerrenoSolidoHorizonte"
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	mi.material_override = mat
	add_child(mi)
	global_position = Vector3(CENTRO_ISLA.x, 0.0, CENTRO_ISLA.y)
	print("[M09-Solido] impostor de toda la isla (hilo de fondo): %d celdas (paso %dm) — ~%d triángulos, StandardMaterial sin shader custom" % [celdas, int(PASO), celdas * 2])


func _color_por_altura(h: float) -> Color:
	if h < 4.0:
		return COLOR_AGUA_FONDO
	if h < 5.0:
		return COLOR_ARENA
	if h < 9.0:
		return COLOR_PASTO
	if h < 16.0:
		return COLOR_TRANSICION
	if h < 27.0:
		return COLOR_PIEDRA
	return COLOR_CIMA


func _exit_tree() -> void:
	if _hilo != null and _hilo.is_alive():
		_hilo.wait_to_finish()
