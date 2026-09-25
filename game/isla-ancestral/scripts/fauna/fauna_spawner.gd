# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-25
#
# M36 iter 2 / M65 (P-49, Log 1161): FaunaSpawner — nodo de escena para
# main_island. El M36 FaunaManager solo provee el API (catalogo +
# candidatos); "instanciar los nodos" quedo delegado a "iter 2" (comment de
# fauna_manager.gd L7). Este script cierra ese gap: crea criaturas reales con
# el script fauna_behavior (M36) que se AUTO-registran en M65 (PackLogic /
# SchoolLogic) y en el registry de avistamiento, y deambulan en el mundo.
#
# Es el paso que convierte a M65 de "autoload que funciona en tests" a
# "manada/banco visible en produccion": sin esto, main_island solo tenia NPCs
# legacy (Tortuga/Cangrejo/Jabali/Gaviota .gd, sin fauna_behavior ni especie)
# y los grupos [M65] nunca se veian.
#
# Modelo a seguir: VegetationSpawner (M50, Log 930) — espera frames (terreno
# listo), usa MundoRaiz como punto unico de verdad del layout y TerrainLocator
# para el snap (h>=3 = tierra firme, BUG-022). No toca los NPCs legacy.
#
# Lookup de autoloads: se resuelven LAZY via Engine.get_main_loop().root
# (el patron probado de este repo, ver fauna_manager.gd L130 y
# fauna_behavior.gd L281). En el _ready del nodo la arbol a veces no tiene
# todavia el autoload listo, asi no se cachea en _ready y se reintenta.

extends Node

const BehaviorRef = preload("res://scripts/fauna/fauna_behavior.gd")

## Presupuesto global: no exceder el _presupuesto_max de animal_ai (40).
const MAX_INDIVIDUOS: int = 24
## Grupos iniciales (1 por zona) para que el jugador vea fauna al arrancar.
const GRUPOS_INICIALES: int = 3
## Despues del inicial, agrega 1 grupo cada N segundos hasta MAX_INDIVIDUOS.
const INTERVALO_SPAWN: float = 15.0
## Tope de reintentos para encontrar el autoload 'fauna' antes de rendirse.
const MAX_REINTENTO_FAUNA: int = 120

var _rng: RandomNumberGenerator = null
var _poblado_inicial := false
var _fauna_indisponible := false
var _frames_espera := 0
var _acumulado := 0.0
var _individuos_totales := 0
var _contador_nodo := 0

## Zonas de bioma del spawn de contenido (M09/M167). M09 no expone todavia
## una API bioma_de_posicion, asi que el spawner usa anillos nominales
## derivados de las constantes de MundoRaiz (documentado, no magic numbers).
## - pradera: alrededor del SPAWN_CONTENIDO (donde arranca el jugador).
## - playa / humedal: banda costera, en la direccion contenido desde el centro.
func _zonas() -> Array:
	var mundo = _get_mundo()
	var centro: Vector2 = mundo.CENTRO if mundo else Vector2(2560.0, 2560.0)
	# .xz es property read-only y NO pasa por el dispatch dinámico de Variant:
	# se arma el Vector2 con .x/.z (mismo acceso que usa VegetationSpawner M50).
	var objetivo: Vector2 = Vector2(mundo.SPAWN_CONTENIDO.x, mundo.SPAWN_CONTENIDO.z) if mundo else Vector2(3860.0, 3860.0)
	var dir_dir: Vector2 = objetivo - centro
	if dir_dir.length() < 0.01:
		dir_dir = Vector2(1.0, 1.0)
	dir_dir = dir_dir.normalized()
	var radio_orilla: float = mundo.RADIO_ORILLA if mundo else 1700.0
	var costa := centro + dir_dir * (radio_orilla * 0.98)
	var humedal := centro + dir_dir * (radio_orilla + 80.0)
	return [
		{"bioma": &"pradera", "centro": objetivo, "radio": 250.0},
		{"bioma": &"playa", "centro": costa, "radio": 120.0},
		{"bioma": &"humedal", "centro": humedal, "radio": 100.0},
	]

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	# No se cachea el autoload aqui (timing del arbol); se resuelve lazy.
	set_process(true)

func _process(_delta: float) -> void:
	if not _poblado_inicial:
		_frames_espera += 1
		if _frames_espera >= 2:
			var f = _get_fauna()
			if f != null:
				_poblado_inicial = true
				_poblar_inicial(f)
			elif _frames_espera > MAX_REINTENTO_FAUNA:
				_fauna_indisponible = true
				_poblado_inicial = true
				push_warning("[M36-SPAWNER] autoload 'fauna' no aparecio tras %d frames: se omite el poblado (no rompe main_island)" % MAX_REINTENTO_FAUNA)
		return
	if _fauna_indisponible:
		return
	# Re-spawn periodico hasta el tope.
	if _individuos_totales < MAX_INDIVIDUOS:
		_acumulado += _delta
		if _acumulado >= INTERVALO_SPAWN:
			_acumulado = 0.0
			var zonas := _zonas()
			var zona: Dictionary = zonas[_rng.randi() % zonas.size()]
			_spawn_grupo(zona, _get_fauna())

func _poblar_inicial(fauna) -> void:
	print("[M36-SPAWNER] poblando fauna (P-49)...")
	var zonas := _zonas()
	for i in range(mini(GRUPOS_INICIALES, zonas.size())):
		_spawn_grupo(zonas[i], fauna)
	print("[M36-SPAWNER] poblacion inicial: %d individuos en %d zonas" % [_individuos_totales, GRUPOS_INICIALES])

## Crea un grupo de una especie activa en el bioma de la zona (o 0 si no hay
## candidatas en la hora actual). Devuelve la cantidad de individuos creados.
func _spawn_grupo(zona: Dictionary, fauna) -> int:
	if fauna == null:
		return 0
	var hora := _hora_actual()
	var bioma: StringName = zona.bioma
	var sp = fauna.especie_aleatoria_para(hora, bioma)
	if sp == null:
		# No hay especie activa de este bioma en la hora: grupo vacio.
		return 0
	# Tamano del grupo: especies gregarias en [manada_min, manada_max];
	# solitarias = 1. candidatos_de_especie lo clampa al rango real.
	var n_peticion: int = int(sp.cantidad_manada_max) if sp.gregaria else 1
	var cands: Array = fauna.candidatos_de_especie(sp, n_peticion)
	if cands.is_empty():
		return 0
	var creados := 0
	for cand in cands:
		if _individuos_totales >= MAX_INDIVIDUOS:
			break
		if _crear_individuo(sp, cand, zona):
			creados += 1
	if creados > 0:
		print("[M36-SPAWNER] grupo %s (%d) en %s @ (%.0f, %.0f)" % [sp.id, creados, bioma, zona.centro.x, zona.centro.y])
	return creados

## Crea 1 individuo (fauna_behavior + mesh placeholder) y lo registra en M65/M36.
func _crear_individuo(sp, cand: Dictionary, zona: Dictionary) -> bool:
	var radio: float = float(zona.radio)
	var ang: float = _rng.randf() * TAU
	var dist: float = _rng.randf() * radio
	var x: float = float(zona.centro.x) + cos(ang) * dist
	var z: float = float(zona.centro.y) + sin(ang) * dist
	var y := _altura_superficie(x, z, sp)
	if y < 0.0:
		# No hay superficie valida para esta clase en este punto: se omite.
		return false
	var nodo := Node3D.new()
	_contador_nodo += 1
	nodo.name = "Fauna_%s_%d" % [sp.id, _contador_nodo]
	nodo.set_script(BehaviorRef)
	nodo.especie = sp
	nodo.instancia_id = str(cand.instancia_id)
	nodo.position = Vector3(x, y, z)
	_agregar_visual(nodo, sp)
	# add_child dispara _ready de fauna_behavior -> auto-registro en M65
	# (animal_ai) + M36 (registry) + TimeCalendar. especie ya esta seteado,
	# asi el _grupo_agregar clasifica a la manada/banco correctamente.
	add_child(nodo)
	# DEAMBULAR + factor_miedo individual (post-_ready, _rng ya existe).
	nodo.inicializar(sp)
	_individuos_totales += 1
	return true

## Altura Y de spawn segun la clase de la especie + snap del terreno.
## Devuelve y, o -1 si no hay superficie adecuada (y el individuo se omite).
func _altura_superficie(x: float, z: float, sp) -> float:
	var locator = _get_locator()
	var h: float = 4.0
	if locator != null and locator.has_method("get_height"):
		h = float(locator.get_height(int(x), int(z)))
	else:
		return 4.0  # sin TerrainLocator: altura nominal, no bloquea el spawn
	var clase: int = int(sp.clase)
	match clase:
		1:  # ACUATICA: franja de aguas someras (costanera).
			if h >= 2.5 and h <= 4.5:
				return h + 0.2
			return -1.0
		2:  # AEREA: vuela sobre la superficie (no necesita tierra).
			return maxf(h, 3.0) + 1.5
		_:  # TERRESTRE / ANFIBIA: solo tierra firme (h>=3, BUG-022).
			if h >= 3.0:
				return h + 0.1
			return -1.0

## Mesh placeholder de una esfera (M45 entregara los modelos reales a futuro;
## hoy las faunas corren con placeholders geometricos, precedente M36).
func _agregar_visual(nodo: Node3D, sp) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "Cuerpo"
	var esfera := SphereMesh.new()
	esfera.radius = 0.5
	esfera.height = 0.9
	mesh.mesh = esfera
	var mat := StandardMaterial3D.new()
	var colores: Array = sp.color_variantes
	mat.albedo_color = colores[_rng.randi() % colores.size()] if not colores.is_empty() else Color(0.7, 0.6, 0.5)
	mat.roughness = 0.8
	mesh.material_override = mat
	nodo.add_child(mesh)
	var escala: float = _rng.randf_range(float(sp.escala_min), float(sp.escala_max))
	nodo.scale = Vector3(escala, escala, escala)

## Hora del juego (M29/M10) para el filtro de ventana horaria de M36.
func _hora_actual() -> int:
	var tc = _get_tc()
	if tc != null and tc.has_method("get_hora"):
		return int(tc.get_hora())
	return 8

## QA (P-49): estado del spawner para inspeccion / tests.
func individuos_totales() -> int:
	return _individuos_totales

func grupos_activos() -> int:
	return get_child_count()

## ── Lookup de autoloads (patron del repo: Engine.get_main_loop().root) ──
func _get_fauna():
	return Engine.get_main_loop().root.get_node_or_null("fauna")

func _get_locator():
	return Engine.get_main_loop().root.get_node_or_null("TerrainLocator")

func _get_mundo():
	return Engine.get_main_loop().root.get_node_or_null("MundoRaiz")

func _get_tc():
	return Engine.get_main_loop().root.get_node_or_null("TimeCalendar")
