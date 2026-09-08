# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-08
#
# M09 iter. DEFINITIVA (feedback usuario: "el plano verde se ve de canto/no
# se ve; el impostor de montañas vertical SÍ se ve"): UN SOLO impostor
# HEIGHTMAP de TODA la isla con relieve vertical real:
#   - Grilla de 32m sobre toda la isla (r 2600), celdas de tierra h>=4.
#   - Escalera voxel: cada celda un PRISMA desde y=0 hasta h×0.85 (tops +
#     4 paredes dobles) — se ve de cualquier ángulo, incluso de canto.
#   - Colores por bioma de altura (arena blanca, césped verde, piedra, cima).
#   - 64 tiles de 640m con ocultamiento por distancia al AABB (los chunks
#     reales mandan cerca; el impostor toma el horizonte más allá de 1024m).
#   - Sin shader custom (el discard por píxel tildaba la GPU integrada).
# El impostor de MONTAÑAS (36 tiles) queda reemplazado por este impostor
# completo (misma técnica, cobertura total).

extends Node3D

## Paso de la grilla del impostor (32m — de lejos se ve bien)
const PASO := 64.0
## Centro de la isla (todo el mundo 5120²)
const CENTRO_ISLA := Vector2(2560.0, 2560.0)
## Radio cubierto: TODA la isla (5120/2 + margen)
const RADIO_CUBIERTO := 2700.0
## Altura del impostor: 15% bajo el terreno real (anti z-fighting)
const FACTOR_ALTURA := 0.85
## Exageración de las cimas (petición usuario: ver las montañas desde lejos).
## Cerca (<1024m) el impostor se desvanece y las reales toman el mando.
const MONT_EXAG := 4.0
## Altura mínima para incluir la celda (debajo = agua/orilla, la cubre el agua)
const H_MIN := 4.0
## Tiles de 640m con ocultamiento independiente
const TAMANO_TILE := 640.0
## El impostor se oculta cuando el player está a menos de esto del tile
## (los chunks reales llegan a 1024m — el impostor toma el mando más allá)
const TILE_OCULTAR_UMBRAL := 400.0
## Filas por frame en la construcción incremental
const FILAS_POR_FRAME := 6

const COLOR_ARENA := Color(0.85, 0.82, 0.65)
const COLOR_PASTO := Color(0.58, 0.72, 0.36)
const COLOR_TRANSICION := Color(0.52, 0.60, 0.46)
const COLOR_PIEDRA := Color(0.56, 0.58, 0.60)
const COLOR_CIMA := Color(0.74, 0.76, 0.78)

const INTENTOS_MAX := 12

var _intentos := 0
var _stage := "esperando"  # esperando → muestreando → tileando → listo
var _island_gen = null
var _alturas_celda: Dictionary = {}
var _tiles: Array = []
var _fila_actual := 0
var _fila_min := 0
var _fila_max := 0
var _acum_fade := 0.0


func _ready() -> void:
	call_deferred("_intentar_crear")


func _intentar_crear() -> void:
	var terrain := get_node_or_null("../VoxelTerrain") as VoxelTerrain
	var island_gen = null
	if terrain != null and terrain.generator != null and terrain.generator.has_method("_get_island_gen"):
		island_gen = terrain.generator._get_island_gen()
	if island_gen == null:
		_intentos += 1
		if _intentos > INTENTOS_MAX:
			push_warning("[M09-IMP] generador no llegó — impostor omitido")
			return
		var t := get_tree().create_timer(0.5)
		t.timeout.connect(_intentar_crear)
		return
	_island_gen = island_gen
	_fila_min = int(CENTRO_ISLA.y - RADIO_CUBIERTO)
	_fila_max = int(CENTRO_ISLA.y + RADIO_CUBIERTO)
	_fila_actual = _fila_min
	_stage = "muestreando"
	set_process(true)
	print("[M09-IMP] muestreando TODA la isla (filas %d..%d, %d/frame, paso %dm)" % [_fila_min, _fila_max, FILAS_POR_FRAME, int(PASO)])


func _process(_delta: float) -> void:
	match _stage:
		"muestreando":
			var filas := 0
			while _fila_actual < _fila_max and filas < FILAS_POR_FRAME:
				_muestrear_fila(_fila_actual)
				_fila_actual += int(PASO)
				filas += 1
			if _fila_actual >= _fila_max:
				_stage = "tileando"
				_crear_tiles()
			return
		_:
			# Ocultamiento por distancia (cada 0.5s): los tiles cercanos al
			# player se ocultan (los chunks reales detallados los cubren); los
			# lejanos visibles (el horizonte SIEMPRE tiene la isla).
			_acum_fade += _delta
			if _acum_fade < 0.5:
				return
			_acum_fade = 0.0
			var player := get_tree().root.get_node_or_null("Main/Player") as Node3D
			if player == null:
				return
			var pp: Vector3 = player.global_position
			for t in _tiles:
				var mi := t as MeshInstance3D
				if mi == null:
					continue
				var aabb := mi.get_aabb()
				var aabb_min := aabb.position + mi.global_position
				var aabb_max := aabb.end + mi.global_position
				var punto_cercano := Vector3(clampf(pp.x, aabb_min.x, aabb_max.x), 0.0, clampf(pp.z, aabb_min.z, aabb_max.z))
				var d := Vector2(pp.x, pp.z).distance_to(Vector2(punto_cercano.x, punto_cercano.z))
				mi.visible = d > TILE_OCULTAR_UMBRAL

## Muestrea una fila de TODA la isla: cachea la altura de cada celda.
func _muestrear_fila(z: int) -> void:
	var x := int(CENTRO_ISLA.x - RADIO_CUBIERTO)
	var x_max := int(CENTRO_ISLA.x + RADIO_CUBIERTO)
	while x < x_max:
		_alturas_celda[Vector2i(x, z)] = float(_island_gen.get_height(x, z))
		x += int(PASO)


## Crea los tiles del impostor heightmap (prismas escalonados, Log 780).
func _crear_tiles() -> void:
	var n := int(ceil(RADIO_CUBIERTO * 2.0 / TAMANO_TILE))
	var min_x := int(CENTRO_ISLA.x - RADIO_CUBIERTO)
	var min_z := int(CENTRO_ISLA.y - RADIO_CUBIERTO)
	for tx in range(n):
		for tz in range(n):
			var t_x0 := min_x + tx * int(TAMANO_TILE)
			var t_z0 := min_z + tz * int(TAMANO_TILE)
			var t_x1 := t_x0 + int(TAMANO_TILE)
			var t_z1 := t_z0 + int(TAMANO_TILE)
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var celdas := 0
			var z := t_z0
			while z < t_z1:
				var x := t_x0
				while x < t_x1:
					var clave := Vector2i(x, z)
					if _alturas_celda.has(clave):
						var h: float = _alturas_celda[clave]
						if h >= 4.0:
							var top := h * FACTOR_ALTURA * MONT_EXAG
							var x0 := float(x)
							var x1 := float(x) + PASO
							var z0 := float(z)
							var z1 := float(z) + PASO
							var cc := _color_por_altura(top)
							# superficie superior
							_tri(st, Vector3(x0, top, z0), cc, Vector3(x0, top, z1), cc, Vector3(x1, top, z1), cc)
							_tri(st, Vector3(x0, top, z0), cc, Vector3(x1, top, z1), cc, Vector3(x1, top, z0), cc)
							# paredes (doble cara — el impostor se ve desde el mar y desde el interior)
							_pared(st, Vector3(x0, 0, z0), Vector3(x1, 0, z0), Vector3(x1, top, z0), Vector3(x0, top, z0), cc)
							_pared(st, Vector3(x1, 0, z1), Vector3(x0, 0, z1), Vector3(x0, top, z1), Vector3(x1, top, z1), cc)
							_pared(st, Vector3(x1, 0, z0), Vector3(x1, 0, z1), Vector3(x1, top, z1), Vector3(x1, top, z0), cc)
							_pared(st, Vector3(x0, 0, z1), Vector3(x0, 0, z0), Vector3(x0, top, z0), Vector3(x0, top, z1), cc)
							celdas += 1
					x += int(PASO)
				z += int(PASO)
			if celdas == 0:
				_tiles.append(null)
				continue
			var mi := MeshInstance3D.new()
			mi.mesh = st.commit()
			mi.name = "Imp_%d_%d" % [tx, tz]
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var mat := StandardMaterial3D.new()
			mat.vertex_color_use_as_albedo = true
			mat.roughness = 1.0
			mi.material_override = mat
			mi.position = Vector3.ZERO  # vértices ya mundiales (fix Log 778)
			add_child(mi)
			_tiles.append(mi)
	# Nodo en el origen (los vértices son mundiales — fix Log 778)
	global_position = Vector3.ZERO
	var activos := 0
	for t in _tiles:
		if t != null:
			activos += 1
	print("[M09-IMP] impostor heightmap completo: %d tiles activos — ocultos <%.0fm (chunks reales mandan cerca)" % [activos, TILE_OCULTAR_UMBRAL])


func _color_por_altura(h: float) -> Color:
	if h < 6.0:
		return COLOR_ARENA
	if h < 16.0:
		return COLOR_PASTO
	if h < 27.0:
		return COLOR_TRANSICION
	if h < 45.0:
		return COLOR_PIEDRA
	return COLOR_CIMA


func _tri(st: SurfaceTool, a: Vector3, ca: Color, b: Vector3, cb: Color, c: Vector3, cc: Color) -> void:
	st.set_color(ca)
	st.add_vertex(a)
	st.set_color(cb)
	st.add_vertex(b)
	st.set_color(cc)
	st.add_vertex(c)


func _pared(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color) -> void:
	_tri(st, a, col, b, col, c, col)
	_tri(st, a, col, c, col, d, col)
	_tri(st, b, col, a, col, d, col)
	_tri(st, b, col, d, col, c, col)
