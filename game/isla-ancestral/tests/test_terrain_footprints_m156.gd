# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-13
#
# M156 iter. 5 (lote I): Test headless del sistema de huellas (TerrainFootprints)
# y de get_visual_config data-driven.
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/test_terrain_footprints_m156.gd

extends SceneTree

const FootprintsRef = preload("res://scripts/terrenos/terrain_footprints.gd")
const ParticlesRef = preload("res://scripts/terrenos/terrain_particles.gd")

var _fallos: int = 0
var _ok: int = 0


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _correr() -> void:
	print("\n=== M156 LOTE I: TerrainFootprints + get_visual_config ===")

	# ── 1. Provider data-driven ────────────────────────────
	var prov := root.get_node_or_null("TerrainProvider")
	_check("TerrainProvider autoload presente", prov != null)
	if prov == null:
		_finalizar()
		return
	await process_frame  # deja que _ready() del provider cargue el JSON

	_check("7 terrenos cargados", prov.terrenos_count() == 7)

	var cfg0: Dictionary = prov.get_visual_config(0)
	_check("cfg cesped tiene distancia", cfg0.has("huella_distancia"))
	_check("cfg cesped distancia=0.7", absf(float(cfg0.get("huella_distancia", 0.0)) - 0.7) < 0.001)
	_check("cfg cesped tamano=0.5", absf(float(cfg0.get("huella_tamano", 0.0)) - 0.5) < 0.001)
	_check("cfg cesped alpha=0.35", absf(float(cfg0.get("huella_alpha", 0.0)) - 0.35) < 0.001)
	var color0: Color = cfg0.get("color", Color.BLACK)
	_check("cfg cesped color r=0.4", absf(color0.r - 0.4) < 0.001)
	_check("cfg cesped color g=0.75", absf(color0.g - 0.75) < 0.001)

	var cfg4: Dictionary = prov.get_visual_config(4)
	_check("cfg agua alpha=0.4", absf(float(cfg4.get("huella_alpha", 0.0)) - 0.4) < 0.001)
	var color4: Color = cfg4.get("color", Color.BLACK)
	_check("cfg agua color b=0.9", absf(color4.b - 0.9) < 0.001)

	_check("cfg terreno desconocido (99) vacio", prov.get_visual_config(99).is_empty())

	# ── 2. Gestor: montaje y escenas ───────────────────────
	var jugador := CharacterBody3D.new()
	root.add_child(jugador)
	var fp: Node = FootprintsRef.new()
	fp.name = "TerrainFootprints"
	fp.duracion_fade = 0.0  # deterministico: liberacion sin tween
	jugador.add_child(fp)
	await process_frame  # _ready() precarga las 7 escenas

	_check("escenas huella cargadas (7)", fp.get_escenas_cargadas() == 7)
	_check("meshes huella cargados (7)", fp.get_meshes_cargados() == 7)

	# ── 3. Instanciacion forzada ───────────────────────────
	fp.forzar_huella(Vector3(10, 0, 10), 0)
	_check("1 huella activa tras forzar", fp.get_huellas_activas() == 1)
	var activa: MeshInstance3D = null
	for h in fp.get_children():
		if h is MeshInstance3D and (h as MeshInstance3D).visible:
			activa = h as MeshInstance3D
	_check("nodo huella visible", activa != null)
	if activa != null:
		_check("nodo huella tiene mesh", activa.mesh != null)
		_check("nodo huella posicion correcta", activa.global_position.distance_to(Vector3(10, 0, 10)) < 0.01)
		var mat := activa.material_override as StandardMaterial3D
		_check("material_override asignado", mat != null)
		if mat != null:
			_check("alpha aplicado (0.35)", absf(mat.albedo_color.a - 0.35) < 0.001)
			_check("color base cesped (g=0.75)", absf(mat.albedo_color.g - 0.75) < 0.001)

	# ── 4. Cambio de terreno ──────────────────────────────
	fp.simular_cambio_terreno(5)
	_check("terrain_id actualizado a 5", fp.get_terrain_id() == 5)
	fp.forzar_huella(Vector3(20, 0, 20), 5)
	_check("2 huellas activas", fp.get_huellas_activas() == 2)

	# ── 5. Limite maximo de huellas (reciclado) ────────────
	fp.max_huellas = 4
	for i in 12:
		fp.forzar_huella(Vector3(30 + i, 0, 30), i % 7)
	_check("activas limitadas a max_huellas=4", fp.get_huellas_activas() == 4)

	# ── 6. Expiracion + pooling ────────────────────────────
	var antes: int = fp.get_huellas_activas()
	fp._physics_process(100.0)  # expiran todas (restante <= 0)
	await process_frame
	_check("activas a 0 tras expirar", fp.get_huellas_activas() == 0)
	_check("pool crecio tras expirar (>= %d)" % antes, fp.get_pool_size() >= antes)

	# ── 7. Reuso del pool ─────────────────────────────────
	fp.forzar_huella(Vector3(50, 0, 50), 3)
	_check("pool disminuye al reusar", fp.get_pool_size() < antes or fp.get_pool_size() == 0)
	_check("1 huella activa tras reusar pool", fp.get_huellas_activas() == 1)

	# ── 8. Particulas: config data-driven ────────────────
	var cfgp0: Dictionary = prov.get_visual_config(0)
	_check("cfg cesped particulas_frecuencia=0.8", absf(float(cfgp0.get("particulas_frecuencia", 0.0)) - 0.8) < 0.001)
	_check("cfg cesped particulas_intensidad=2", int(cfgp0.get("particulas_intensidad", 0)) == 2)
	var cfgp3: Dictionary = prov.get_visual_config(3)
	_check("cfg arena intensidad=8", int(cfgp3.get("particulas_intensidad", 0)) == 8)

	# ── 9. Gestor de particulas ──────────────────────────
	var fp2: Node = ParticlesRef.new()
	fp2.name = "TerrainParticles"
	fp2.duracion_rafaga = 0.5
	jugador.add_child(fp2)
	await process_frame
	_check("escenas particula cargadas (7)", fp2.get_escenas_cargadas() == 7)

	fp2.forzar_rafaga(Vector3(60, 0, 60), 0)
	_check("1 emisor activo tras rafaga", fp2.get_emisores_activos() == 1)
	var emisor: CPUParticles3D = null
	for h in fp2.get_children():
		if h is CPUParticles3D and (h as CPUParticles3D).visible:
			emisor = h as CPUParticles3D
	_check("emisor visible", emisor != null)
	if emisor != null:
		_check("emisor emitiendo", emisor.emitting == true)
		_check("emisor amount=2 (intensidad cesped)", emisor.amount == 2)
		_check("emisor color cesped (g=0.75)", absf(emisor.color.g - 0.75) < 0.001)
		_check("emisor posicion correcta", emisor.global_position.distance_to(Vector3(60, 0, 60)) < 0.01)

	# cambio de terreno (arena: intensidad 8)
	fp2.simular_cambio_terreno(3)
	fp2.forzar_rafaga(Vector3(70, 0, 70), 3)
	_check("2 emisores activos", fp2.get_emisores_activos() == 2)

	# limite max_emisores
	fp2.max_emisores = 3
	for i in 8:
		fp2.forzar_rafaga(Vector3(80 + i, 0, 80), i % 7)
	_check("emisores limitados a max_emisores=3", fp2.get_emisores_activos() == 3)

	# expiracion + pooling
	fp2._physics_process(10.0)
	await process_frame
	_check("emisores a 0 tras expirar", fp2.get_emisores_activos() == 0)
	_check("pool de emisores crecio", fp2.get_pool_size() >= 3)

	# ── 10. Limpieza ─────────────────────────────────────
	jugador.queue_free()
	_finalizar()


func _finalizar() -> void:
	print("\n=== RESULTADO: %d OK / %d FAIL ===" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)
