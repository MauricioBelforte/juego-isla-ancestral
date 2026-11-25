extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — suite de MATERIALES COMPARTIDOS entre instancias (L227).
#
# POR QUE EXISTE: el checklist pedia "Materiales de pieza compartidos entre
# instancias (static batching de Godot)". Lo medido en el codigo real:
#
#   * Las piezas COLOCADAS en M17 NO son mallas: `ConstruccionMundo.escribir_voxel()`
#     escribe VOXELES en el terreno (M08). Por lo tanto no hay una instancia de
#     malla por pieza colocada que pueda duplicar materiales -> esa parte del
#     item vive en M08 (VoxelTerrain/VoxelTool) y se deja anotada, no se roba.
#   * Lo que SI existe en M17 son las mallas de PREVIO (el fantasma). Antes de
#     esta tanda, `BuildGhost.malla_desde_ruta()` tenia cache POR INSTANCIA:
#     cada fantasma instanciaba su propia copia de la escena .glb de la receta
#     -> N copias de la misma malla y de sus materiales.
#
# QUE MIDE (headless, build_ghost real + una receta real del catalogo):
#   * la ruta de malla se resuelve UNA sola vez para varios consumidores
#     (contador de cargas auditable: `BuildGhost.cargas_de_malla()`)
#   * dos instancias de fantasma reciben el MISMO recurso de malla (mismo id)
#     y, por lo tanto, el mismo recurso de material (batch-friendly)
#   * las precargas explicitas (`registrar_malla`) siguen siendo POR INSTANCIA
#     (no contaminan el cache compartido: son datos de test)
#   * una ruta inexistente degrada a null sin fallar y sin gastar carga
#   * colocar una pieza NO crea ninguna MeshInstance3D (sigue siendo voxel)
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_materiales_compartidos.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: materiales compartidos entre instancias (L227)"
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const GHOST := preload("res://scripts/construccion/build_ghost.gd")
const MGR := preload("res://scripts/construccion/build_manager.gd")
const ZONE_REG := preload("res://scripts/construccion/zone_registry.gd")
const CHECKS_MINIMOS := 8

## Ruta real de malla de una receta del catalogo (pared_esquina -> pared de casa).
const RUTA_REAL := "res://assets/3d/alta/18-Casas_pared_madera.glb"

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []

func _initialize() -> void:
	call_deferred("_correr")

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])

func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ── A. La malla se carga UNA vez y se comparte entre instancias ──────
	var fantasma_a := GHOST.new()
	var fantasma_b := GHOST.new()
	root.add_child(fantasma_a)
	root.add_child(fantasma_b)

	var cargas_antes: int = GHOST.cargas_de_malla()
	var malla_a: Mesh = fantasma_a.malla_desde_ruta(RUTA_REAL)
	var cargas_tras_a: int = GHOST.cargas_de_malla()
	var malla_b: Mesh = fantasma_b.malla_desde_ruta(RUTA_REAL)
	var cargas_tras_b: int = GHOST.cargas_de_malla()

	_check("A1: la ruta de malla de la receta resuelve una malla real",
		malla_a != null and malla_b != null, "ruta=%s" % RUTA_REAL)
	_check("A2: la carga de la malla ocurre UNA sola vez (cache compartida, no 1 por consumidor)",
		cargas_tras_a - cargas_antes == 1,
		"cargas tras el 1er consumidor=%d" % (cargas_tras_a - cargas_antes))
	_check("A3: el 2do consumidor NO vuelve a cargar la malla (reutiliza la compartida)",
		cargas_tras_b == cargas_tras_a,
		"cargas=%d -> %d" % [cargas_tras_a, cargas_tras_b])
	_check("A4: las dos instancias reciben el MISMO recurso de malla (mismo instance id)",
		malla_a != null and malla_b != null and malla_a.get_instance_id() == malla_b.get_instance_id(),
		"a=%s b=%s" % [str(malla_a.get_instance_id()) if malla_a else "-", str(malla_b.get_instance_id()) if malla_b else "-"])

	# Los materiales de superficie viajan dentro del recurso de malla: si la
	# malla es la MISMA, sus materiales son los mismos (batch-friendly).
	var mat_a: Material = malla_a.surface_get_material(0) if malla_a != null and malla_a.get_surface_count() > 0 else null
	var mat_b: Material = malla_b.surface_get_material(0) if malla_b != null and malla_b.get_surface_count() > 0 else null
	_check("A5: el material de superficie es el MISMO recurso en ambas instancias (no se duplica)",
		mat_a == null or mat_b == null or mat_a.get_instance_id() == mat_b.get_instance_id(),
		"superficies=%s" % str(malla_a.get_surface_count() if malla_a != null else 0))

	# ── B. Las precargas explicitas siguen siendo POR INSTANCIA ─────────
	var malla_sintetica := BoxMesh.new()
	fantasma_a.registrar_malla("res://assets/3d/alta/18-Casas_pared_madera.glb", malla_sintetica)
	var res_preload_a: Mesh = fantasma_a.malla_desde_ruta(RUTA_REAL)
	var res_preload_b: Mesh = fantasma_b.malla_desde_ruta(RUTA_REAL)
	_check("B1: la precarga explicita (registrar_malla) tiene prioridad en SU instancia",
		res_preload_a != null and res_preload_a.get_instance_id() == malla_sintetica.get_instance_id())
	_check("B2: la precarga de una instancia NO contamina el cache compartido de las otras",
		res_preload_b != null and res_preload_b.get_instance_id() == malla_a.get_instance_id(),
		"b=%s" % str(res_preload_b.get_instance_id() if res_preload_b else "-"))

	# ── C. Ruta inexistente: degrada a null, sin fallar y sin gastar carga ─
	var cargas_pre: int = GHOST.cargas_de_malla()
	var malla_rota: Mesh = fantasma_a.malla_desde_ruta("res://assets/3d/alta/NO_EXISTE_este_archivo.glb")
	_check("C1: una ruta inexistente devuelve null (degrada sin error)",
		malla_rota == null)
	_check("C2: una ruta inexistente no consume una carga de malla",
		GHOST.cargas_de_malla() == cargas_pre,
		"cargas=%d -> %d" % [cargas_pre, GHOST.cargas_de_malla()])

	# ── D. Colocar una pieza NO crea mallas (sigue siendo voxel de M08) ──
	var mgr = MGR.new()
	mgr.name = "BuildManagerMateriales"
	root.add_child(mgr)
	mgr.conectar_mundo(null)
	mgr.conectar_zonas(ZONE_REG.new())
	mgr.set_limite_mundo(AABB())
	await process_frame

	var cat := CATALOGO.new()
	cat.cargar("res://data/construccion/piezas")
	var receta: PlacementRule = cat.por_familia(&"pared")[0] if not cat.por_familia(&"pared").is_empty() else null
	var mallas_antes: int = _contar_mallas(root)
	mgr.registrar_receta(receta)
	mgr.seleccionar_pieza(receta)
	mgr.confirmar_colocacion(Vector3i(5, 1, 5))
	var mallas_despues: int = _contar_mallas(root)
	_check("D1: colocar una pieza NO crea instancias de malla en M17 (la pieza es un VOXEL de M08)",
		mallas_despues == mallas_antes,
		"mallas antes=%d despues=%d" % [mallas_antes, mallas_despues])
	_check("D2: la pieza colocada SI quedo registrada en el mundo de M17",
		mgr.cantidad_estructuras() == 1, "estructuras=%d" % mgr.cantidad_estructuras())

	# La resolucion por receta usa la cache compartida (mismo camino).
	var resuelta_a: Mesh = fantasma_a.resolver_malla(receta)
	var resuelta_b: Mesh = fantasma_b.resolver_malla(receta)
	_check("D3: resolver_malla de la MISMA receta en dos instancias da el mismo recurso",
		resuelta_a != null and resuelta_b != null and resuelta_a.get_instance_id() == resuelta_b.get_instance_id(),
		"a=%s b=%s" % [str(resuelta_a.get_instance_id()) if resuelta_a else "-", str(resuelta_b.get_instance_id()) if resuelta_b else "-"])

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST M17 MATERIALES COMPARTIDOS FALLIDO (checks=%d, minimo=%d)" % [_checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST M17 MATERIALES COMPARTIDOS OK — L227 verificado (malla y materiales compartidos entre instancias)")
		quit(0)

func _contar_mallas(nodo: Node) -> int:
	var n: int = 0
	if nodo is MeshInstance3D:
		n += 1
	for hijo in nodo.get_children():
		n += _contar_mallas(hijo)
	return n
