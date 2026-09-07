# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M49 iter. 4: skyline de montañas a lo lejos (feedback usuario: "no se ve
# ninguna montaña a lo lejos; subir chunks es muy pesado").
#
# Solución: 2 cintas verticales lowpoly (mesh custom, 2 triángulos por
# segmento) que reproducen la SILUETA REAL de la isla muestreando el
# IslandGenerator (sin streaming ni chunks):
#   - Cinta de colinas (r 2050): alturas ×0.55, color pasto claro (1ª capa).
#   - Cinta de montañas (r 2550): alturas reales, color azul-gris de
#     perspectiva atmosférica (2ª capa, detrás).
# La base queda a y=0: la parte baja queda oculta por el agua voxel y las
# cintas emergen del mar como montañas del horizonte. Costo: ~720 triángulos,
# 0 chunks, 0 streaming.

extends Node3D

## Número de segmentos del anillo (2° por segmento)
const SEGMENTOS := 180
## Radios de las 2 cintas [colinas, montañas]
const RADIO_COLINAS := 2050.0
const RADIO_MONTANAS := 2550.0
## Muestras radiales por ángulo para calcular la silueta (el máximo del perfil)
const MUESTRAS_RADIALES := 14
const R_MUESTREO_MIN := 200.0
const R_MUESTREO_MAX := 2350.0
## Colores (perspectiva atmosférica: cuanto más lejos, más claro y azulado)
const COLOR_COLINA_BASE := Color(0.58, 0.70, 0.52)
const COLOR_COLINA_CIMA := Color(0.62, 0.72, 0.60)
const COLOR_MONTANA_BASE := Color(0.55, 0.64, 0.62)
const COLOR_MONTANA_CIMA := Color(0.62, 0.70, 0.72)

const INTENTOS_MAX := 12

var _intentos := 0


func _ready() -> void:
	# El generador se conecta en el _ready del main_island (padre) — reintento
	# diferido hasta que esté disponible (patrón TerrainLocator).
	call_deferred("_intentar_crear")


func _intentar_crear() -> void:
	var terrain := get_node_or_null("../VoxelTerrain") as VoxelTerrain
	var island_gen = null
	if terrain != null and terrain.generator != null and terrain.generator.has_method("_get_island_gen"):
		island_gen = terrain.generator._get_island_gen()
	if island_gen == null:
		_intentos += 1
		if _intentos > INTENTOS_MAX:
			push_warning("[M49-Skyline] IslandGenerator no llegó tras %d reintentos — skyline omitido" % INTENTOS_MAX)
			return
		var t := get_tree().create_timer(0.5)
		t.timeout.connect(_intentar_crear)
		return
	_crear_cinta(island_gen, RADIO_COLINAS, COLOR_COLINA_BASE, COLOR_COLINA_CIMA, 1.1, "ColinasSkyline")
	_crear_cinta(island_gen, RADIO_MONTANAS, COLOR_MONTANA_BASE, COLOR_MONTANA_CIMA, 1.8, "MontanasSkyline")
	print("[M49-Skyline] 2 cintas de horizonte creadas (colinas r=%.0f, montañas r=%.0f, %d segmentos)" % [RADIO_COLINAS, RADIO_MONTANAS, SEGMENTOS])


## Silueta de la isla vista desde un ángulo: máximo height del perfil radial.
func _silueta_para_angulo(island_gen, ang: float, escala: float) -> float:
	var dir := Vector2(cos(ang), sin(ang))
	var maximo := 3.0  # mínimo: orilla
	for i in range(MUESTRAS_RADIALES):
		var t := float(i) / float(MUESTRAS_RADIALES - 1)
		var r := lerpf(R_MUESTREO_MIN, R_MUESTREO_MAX, t)
		var x := 2560.0 + dir.x * r
		var z := 2560.0 + dir.y * r
		var h := float(island_gen.get_height(int(x), int(z)))
		maximo = maxf(maximo, h)
	return maximo * escala


## Crea una cinta vertical (anillo de quads) con las alturas de la silueta.
func _crear_cinta(island_gen, radio: float, color_base: Color, color_cima: Color, escala: float, nombre: String) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var alturas: Array = []
	for i in range(SEGMENTOS):
		var ang := TAU * float(i) / float(SEGMENTOS)
		alturas.append(_silueta_para_angulo(island_gen, ang, escala))
	for i in range(SEGMENTOS):
		var ang0 := TAU * float(i) / float(SEGMENTOS)
		var ang1 := TAU * float(i + 1) / float(SEGMENTOS)
		var h0: float = alturas[i]
		var h1: float = alturas[(i + 1) % SEGMENTOS]
		var p0b := Vector3(cos(ang0) * radio, 0.0, sin(ang0) * radio)
		var p0t := Vector3(cos(ang0) * radio, h0, sin(ang0) * radio)
		var p1b := Vector3(cos(ang1) * radio, 0.0, sin(ang1) * radio)
		var p1t := Vector3(cos(ang1) * radio, h1, sin(ang1) * radio)
		# Doble cara: 2 quads (frontal y trasera) para verse desde dentro y fuera
		for cara in range(2):
			if cara == 0:
				_tri(st, p0b, COLOR_COLINA_BASE, p0t, COLOR_COLINA_CIMA, p1t, COLOR_COLINA_CIMA)
				_tri(st, p0b, COLOR_COLINA_BASE, p1t, COLOR_COLINA_CIMA, p1b, COLOR_COLINA_BASE)
			else:
				_tri(st, p0b, COLOR_COLINA_BASE, p1t, COLOR_COLINA_CIMA, p0t, COLOR_COLINA_CIMA)
				_tri(st, p0b, COLOR_COLINA_BASE, p1b, COLOR_COLINA_BASE, p1t, COLOR_COLINA_CIMA)
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.name = nombre
	# Sin sombras ni colisión: es solo horizonte
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = mat
	add_child(mi)
	# Centrar en el real de la isla (MundoRaiz)
	var mundo := get_node_or_null("/root/MundoRaiz")
	if mundo != null:
		global_position = Vector3(mundo.CENTRO.x, 0.0, mundo.CENTRO.y)
	else:
		global_position = Vector3(2560.0, 0.0, 2560.0)


func _tri(st: SurfaceTool, a: Vector3, ca: Color, b: Vector3, cb: Color, c: Vector3, cc: Color) -> void:
	st.set_color(ca)
	st.add_vertex(a)
	st.set_color(cb)
	st.add_vertex(b)
	st.set_color(cc)
	st.add_vertex(c)
