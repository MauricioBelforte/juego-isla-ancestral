# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M156 iter. 4 (B3) — encargo canal 121 §5: G2 (grupo `voxel_terrain`) + G4
# (collision_mask del RayCast3D), con el criterio de cierre:
#   "suite que demuestre que `terrain_changed` se dispara al cambiar de bloque
#    REAL (no solo en el test sintetico), con el detector leyendo del mundo."
#
# Esta suite monta un VoxelTerrain REAL en headless (generador Flat + mesher
# Blocky + VoxelViewer, como M08) y le cuelga un TerrainDetector. Verifica
# end-to-end contra el MUNDO (no contra un stub):
#   A (G2)  el grupo "voxel_terrain" arranca VACIO -> el detector resuelve el
#           terreno de la escena y lo REGISTRA (add_to_group en runtime).
#   B (G4)  el rayo usa SOLO el bit dedicado (capa 6 = 32) y NO se frena en un
#           NPC de la capa "mundo" (1); el terreno conserva la capa 1 intacta.
#   C (D1)  _block_id_en() lee el bloque REAL del mundo (get_voxel_tool); antes
#           exigia `storage` (propiedad inexistente) y devolvia -1 SIEMPRE.
#   D (DoD) cambiar un bloque REAL del mundo (GRASS -> CLAY via VoxelTool) hace
#           que el bucle de fisica del detector dispare `terrain_changed` con el
#           terrain_id nuevo, leyendo del mundo.
#
# MEDIDO (sondas probe6/12, 2026-10-09): el addon voxel NO puebla el grupo por si
# mismo (un VoxelTerrain completo SIN detector queda con groups=[] y layer=1).
# El productor del grupo es ESTE detector (registra el terreno que resuelve).
#
# NOTA DE ENTORNO: al correr con `--script`, el autoload Bootstrap carga
# `main_island.tscn`, cuyo Player trae un TerrainDetector REAL que ya registro SU
# terreno en el grupo antes de que arranque esta suite. Para medir el ARRANQUE EN
# FRIO (grupo vacio, que es el estado real del juego antes de que corra el primer
# detector) la suite limpia el grupo: solo se toca el estado EN MEMORIA de este
# proceso de test, ningun archivo. El mundo de prueba se monta a y=2000 para no
# interferir con la isla real.
#
# ⚠️ Guardia anti-falso-verde (3 capas, trampas 11/63/122):
#   1) cada bloque cierra con `_fin(nombre)`; si aborta en silencio, el nombre
#      falta y `_summary()` FALLA (nombra los faltantes);
#   2) piso `CHECKS_MINIMOS` MEDIDO en verde (no estimado);
#   3) `_summary()` se invoca al final de `_run()` Y desde el watchdog.
#      NOTA de adaptacion: esta suite es ASINCRONA (`await`), asi que el patron
#      del repo de `call_deferred("_summary")` SEPARADO no aplica — la cola
#      diferida correria ANTES de que `_run()` retome tras el primer `await`.
#      El watchdog por temporizador cumple la funcion de red de seguridad: si
#      `_run()` muere por SCRIPT ERROR, el timer cierra con exit 1 nombrando el
#      ultimo bloque y los faltantes.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/terrenos/test_terrenos_b3.gd

extends SceneTree

const TIMEOUT_SEG := 90.0
## Piso de checks MEDIDO en verde (no estimado): un aborto parcial baja el conteo.
const CHECKS_MINIMOS := 28
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D"]

const TerrainDetectorScript = preload("res://scripts/terrenos/terrain_detector.gd")
const GRUPO_TERRENO := "voxel_terrain"
const BIT_TERRENO := 32  # 1 << (6 - 1)

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_marca: int = 0
var _cerrado: bool = false

var _mundo: Node3D = null
var _vt: VoxelTerrain = null
var _npc: StaticBody3D = null
var _det: Node = null
var _celda: Vector3i = Vector3i(0, 4, 0)


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== [M156-B3] G2 grupo voxel_terrain + G4 collision_mask + DoD signal (headless) ===")
	await _montar_mundo()
	_bloque_a_g2()
	_fin("A. G2 grupo/registro")
	_bloque_b_g4()
	_fin("B. G4 mascara/aislamiento")
	_bloque_c_d1()
	_fin("C. D1 lectura real")
	await _bloque_d_dod()
	_fin("D. DoD signal con cambio real")
	_summary()


func _on_watchdog() -> void:
	if _cerrado:
		return
	_abortado = true
	print("[M156-B3] WATCHDOG: la suite no termino en %.0f s — ABORTO (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	_summary()


## ── Helpers ─────────────────────────────────────────────

func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	print("[FIN] %s (+%d checks)" % [nombre, _checks - _checks_marca])
	_checks_marca = _checks


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	if _cerrado:
		return
	_cerrado = true
	# Capa 1: bloques que no cerraron (aborto silencioso).
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	if not faltantes.is_empty():
		_fallos += 1
		print("[FAIL] bloques que NO se ejecutaron: %s (posible SCRIPT ERROR)" % str(faltantes))
	# Capa 2: piso de checks medido en verde.
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("\n=== Resumen M156-B3: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		print("TEST M156-B3 ABORTADO por watchdog")
	elif _fallos == 0:
		print("TEST M156-B3 OK — todos los checks pasaron")
	quit(1 if _fallos > 0 else 0)


## ── Montaje del mundo voxel REAL (M08) ───────────────────

func _montar_mundo() -> void:
	_ini("montaje del mundo voxel real")
	_mundo = Node3D.new()
	_mundo.name = "MundoB3"
	# Aislado de la isla real (que el harness carga en el origen): y=2000.
	_mundo.position = Vector3(0, 2000, 0)
	root.add_child(_mundo)

	# VoxelTerrain con generador + mesher Blocky + viewer (patron de M08).
	_vt = VoxelTerrain.new()
	_vt.name = "VoxelTerrain"
	_mundo.add_child(_vt)
	var gen = ClassDB.instantiate("VoxelGeneratorFlat")
	gen.set("height", 0)
	gen.set("block_type", BlockType.GRASS)
	gen.set("channel", VoxelBuffer.CHANNEL_TYPE)
	_vt.generator = gen
	var mesher = ClassDB.instantiate("VoxelMesherBlocky")
	var lib = ClassDB.instantiate("VoxelBlockyLibrary")
	var empty = ClassDB.instantiate("VoxelBlockyModelEmpty")
	empty.set_name("air")
	lib.add_model(empty)
	for i in range(1, 32):
		var m = ClassDB.instantiate("VoxelBlockyModelCube")
		m.set_name("b%d" % i)
		lib.add_model(m)
	lib.bake()
	mesher.library = lib
	_vt.mesher = mesher
	var viewer: VoxelViewer = VoxelViewer.new()
	viewer.view_distance = 128.0
	viewer.position = Vector3(0.5, 6.0, 0.5)
	_mundo.add_child(viewer)

	# Esperar a que el area este mallada y con colision.
	for i in range(60):
		await process_frame

	# Bloque conocido y controlado encima del suelo plano (altura 0).
	var vtool: VoxelTool = _vt.get_voxel_tool()
	vtool.channel = VoxelBuffer.CHANNEL_TYPE
	vtool.set_voxel(_celda, BlockType.GRASS)
	for i in range(30):
		await process_frame

	# NPC falso en la capa "mundo" (1) — el mismo default que los NPC reales
	# (npc_agent.tscn / villager.tscn NO fijan collision_layer). Queda EN MEDIO
	# del rayo para probar G4.
	_npc = StaticBody3D.new()
	_npc.name = "NPCFalso"
	_npc.collision_layer = 1
	_npc.collision_mask = 0
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1, 1, 1)
	cs.shape = box
	_npc.add_child(cs)
	_mundo.add_child(_npc)
	_npc.position = Vector3(0.5, 6.0, 0.5)
	for i in range(5):
		await physics_frame

	# ── Arranque en frio (G2) ────────────────────────────────
	# Ver la nota de entorno del encabezado: el harness ya dejo el terreno de la
	# isla real en el grupo. Se limpia para medir el estado real de arranque.
	var ajenos: Array = get_nodes_in_group(GRUPO_TERRENO)
	print("[M156-B3] limpieza de arranque: %d nodo(s) ajeno(s) del harness en el grupo" % ajenos.size())
	for n in ajenos:
		(n as Node).remove_from_group(GRUPO_TERRENO)
	_check("precondicion G2: grupo '%s' VACIO antes del detector" % GRUPO_TERRENO,
		get_nodes_in_group(GRUPO_TERRENO).is_empty(),
		"quedan %d" % get_nodes_in_group(GRUPO_TERRENO).size())

	# Detector sobre el bloque (rayo de 8 m hacia abajo: local y=9 a y=1).
	_det = TerrainDetectorScript.new()
	_det.ray_length = 8.0
	_mundo.add_child(_det)
	_det.position = Vector3(0.5, 9.0, 0.5)
	for i in range(10):
		await physics_frame


## ── A. G2 — resolucion y registro del terreno en el grupo ─

func _bloque_a_g2() -> void:
	_ini("A. G2 grupo voxel_terrain")
	var t: Node = _det.get_terreno()
	_check("get_terreno() != null (detector resolvio el terreno)", t != null)
	_check("get_terreno() == el VoxelTerrain de la escena", t == _vt, "t=%s" % str(t))
	_check("el VoxelTerrain quedo EN el grupo '%s'" % GRUPO_TERRENO, _vt.is_in_group(GRUPO_TERRENO))
	var en_grupo: Array = get_nodes_in_group(GRUPO_TERRENO)
	_check("el grupo ya NO esta vacio", en_grupo.size() >= 1, "size=%d" % en_grupo.size())
	_check("el grupo contiene exactamente 1 nodo (sin duplicar)", en_grupo.size() == 1,
		"size=%d" % en_grupo.size())
	_check("el unico nodo del grupo ES el terreno del test", en_grupo.size() == 1 and en_grupo[0] == _vt)
	_check("resolver es idempotente (2a llamada sigue OK)", _det._resolver_terreno() == true)


## ── B. G4 — mascara dedicada y aislamiento del NPC ───────

func _bloque_b_g4() -> void:
	_ini("B. G4 collision_mask / aislamiento")
	_check("RayCast3D.collision_mask == 32 (solo bit dedicado)", int(_det.collision_mask) == BIT_TERRENO,
		"mask=%d" % int(_det.collision_mask))
	_check("collide_with_areas == false (agua decorativa es Area3D)", _det.collide_with_areas == false)
	_check("collide_with_bodies == true", _det.collide_with_bodies == true)
	_check("el terreno tiene el bit dedicado (capa 6 = 32)",
		(int(_vt.collision_layer) & BIT_TERRENO) != 0, "layer=%d" % int(_vt.collision_layer))
	_check("el terreno CONSERVA la capa 'mundo' 1 (no se quito)",
		(int(_vt.collision_layer) & 1) != 0, "layer=%d" % int(_vt.collision_layer))

	# Con la mascara dedicada, el rayo ignora el NPC y pega en el terreno.
	_det.collision_mask = BIT_TERRENO
	_det.force_raycast_update()
	_check("mask=32 -> el rayo pega en el VoxelTerrain (no en el NPC)",
		_det.get_collider() == _vt, "collider=%s" % str(_det.get_collider()))

	# Prueba de que el NPC SI esta en el camino y en la capa 1: con mask=1 lo intercepta.
	_det.collision_mask = 1
	_det.force_raycast_update()
	_check("control: con mask=1 el rayo SI se frena en el NPC (capa 1)",
		_det.get_collider() == _npc, "collider=%s" % str(_det.get_collider()))

	# Restaurar y confirmar aislamiento de nuevo.
	_det.collision_mask = BIT_TERRENO
	_det.force_raycast_update()
	_check("restaurada mask=32 -> vuelve a pegar en el VoxelTerrain",
		_det.get_collider() == _vt, "collider=%s" % str(_det.get_collider()))


## ── C. D1 — lectura del bloque REAL del mundo ────────────

func _bloque_c_d1() -> void:
	_ini("C. D1 lectura real del bloque")
	_check("VoxelTerrain expone get_voxel_tool()", _vt.has_method("get_voxel_tool"))
	# Documenta la causa raiz del codigo muerto: la propiedad `storage` no existe.
	_check("VoxelTerrain NO tiene la propiedad 'storage' (codigo muerto D1)",
		not ("storage" in _vt))
	_det.force_raycast_update()
	var punto: Vector3 = _det.get_collision_point()
	var leido: int = _det._block_id_en(punto - Vector3(0, 0.1, 0))
	_check("_block_id_en() lee el bloque REAL (no -1)", leido != -1, "leido=%d" % leido)
	_check("el bloque leido == GRASS(%d) colocado en el mundo" % BlockType.GRASS,
		leido == BlockType.GRASS, "leido=%d" % leido)
	_check("_block_a_terrain(leido) == 0 (cesped)", _det._block_a_terrain(leido) == 0,
		"terrain=%d" % _det._block_a_terrain(leido))


## ── D. DoD — terrain_changed con cambio de bloque REAL ───

func _bloque_d_dod() -> void:
	_ini("D. DoD terrain_changed con cambio real")
	# Deteccion agil: cada frame de fisica, sin debounce (solo para el test).
	_det.detection_interval = 0.0
	_det.debounce_seg = 0.0
	for i in range(15):
		await physics_frame
	var id_inicial: int = _det.get_current_terrain_id()
	_check("detector estabilizado en cesped(0) leyendo del mundo", id_inicial == 0,
		"id=%d" % id_inicial)

	var emisiones: Array[int] = []
	_det.terrain_changed.connect(func(tid: int) -> void: emisiones.append(tid))

	# Cambio de bloque REAL en el mundo (no sintetico): GRASS -> CLAY (barro=1).
	var vtool: VoxelTool = _vt.get_voxel_tool()
	vtool.channel = VoxelBuffer.CHANNEL_TYPE
	vtool.set_voxel(_celda, BlockType.CLAY)

	var disparo := false
	for i in range(150):
		await physics_frame
		if not emisiones.is_empty():
			disparo = true
			break

	_check("el bloque REAL del mundo cambio a CLAY(%d)" % BlockType.CLAY,
		int(vtool.get_voxel(_celda)) == BlockType.CLAY, "voxel=%d" % int(vtool.get_voxel(_celda)))
	_check("terrain_changed SE DISPARO con el cambio de bloque real", disparo,
		"emisiones=%s" % str(emisiones))

	# Estabilizacion: 30 frames sin nuevas emisiones (detecta flickering).
	var s1 := emisiones.size()
	for i in range(30):
		await physics_frame
	var s2 := emisiones.size()

	_check("el ultimo terrain_id emitido == 1 (arcilla -> barro)",
		s2 > 0 and emisiones[s2 - 1] == 1, "emisiones=%s" % str(emisiones))
	_check("current_terrain_id quedo en 1", _det.get_current_terrain_id() == 1,
		"id=%d" % _det.get_current_terrain_id())
	_check("estable: sin nuevas emisiones tras estabilizar (sin flickering)", s2 == s1,
		"s1=%d s2=%d" % [s1, s2])
	_check("el detector sigue leyendo el mundo (get_terreno == terreno del test)",
		_det.get_terreno() == _vt)
