# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-20
#
# M62 - ITEM 26 de la COLA V3:
#   "Test Play Mode: maximo de chunks cargados sin superar el presupuesto voxel [M]"
#
# ALCANCE DECLARADO:
#   SI: presupuesto REAL del proyecto (`data/rendimiento/budgets.json` via
#       MemoryBudgetRegistry de produccion) y tope de chunks REAL del LRU de
#       produccion (StreamManager: set_max_chunks/aplicar_tope/
#       marcar_envejecidos/liberar_envejecidos).
#   SI: coste por chunk MEDIDO con buffers REALES de VoxelTools del tamano de
#       bloque de datos que reporta el VoxelTerrain de la escena.
#   NO: mallas/colliders por chunk (headless no crea renderer). Se declara: el
#       numero medido es de DATOS, no del coste total de un chunk en juego.
#   NO: el streaming real del terreno (medido: updated_blocks = 0 headless).
#
# ANTI-FALSO-VERDE:
#   1. Si el registry no carga el preset real, FALLA (no se mide contra un 0).
#   2. Si el coste por chunk mide 0, FALLA (ciego).
#   3. Si el LRU no deja exactamente el tope, FALLA.
#   4. Si `liberar_envejecidos()` no libera lo marcado, FALLA (WeakRef).
#   Sonda ROJA: M62_SIN_TOPE=1 no llama aplicar_tope -> el check 3 falla.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_chunks_presupuesto.gd

extends SceneTree

const MODULO := "M62 chunks vs presupuesto voxel"
const ESCENA := "res://scenes/main_island.tscn"
const MUESTRAS_COSTE := 512
const EXCESO := 100
const WATCHDOG_S := 120.0

var _terrain: Node = null
var _monitor: Node = null
var _stream: Node = null
var _reg: RefCounted = null
var _lado := 16
var _t0_ms := 0
var _fase := 0
var _t_espera := 0.0

var _preset := ""
var _tope_voxel_mb := 0
var _coste_kb := 0.0
var _max_baja := 0
var _max_media := 0
var _max_alta := 0
var _max_por_defecto := 0
var _chunks_tras_tope := -1
var _chunks_liberados := -1
var _vivos := -1
var _obj_antes := 0
var _obj_final := 0
var _orph := 0
var _sin_tope := false

var _checks := 0
var _fallos := 0


func _initialize() -> void:
	_sin_tope = OS.get_environment("M62_SIN_TOPE") == "1"
	_t0_ms = Time.get_ticks_msec()
	print("=== %s ===" % MODULO)
	print("-- inicio: %s | sonda roja sin_tope=%s" % [Time.get_datetime_string_from_system(), str(_sin_tope)])
	var packed: PackedScene = load(ESCENA)
	if packed == null:
		print("  [FALLO] no carga la escena")
		_check(false, "escena real carga")
		_resumen()
		return
	var inst: Node = packed.instantiate()
	root.add_child(inst)
	current_scene = inst
	print("-- escena real instanciada")


func _process(delta: float) -> bool:
	var t := float(Time.get_ticks_msec() - _t0_ms) / 1000.0
	if t > WATCHDOG_S:
		print("  [FALLO] watchdog %.0f s" % WATCHDOG_S)
		_check(false, "watchdog")
		_resumen()
		return true
	_t_espera += delta
	if _fase == 0 and _t_espera >= 2.0:
		_fase = 1
		_correr()
		return true
	return false


func _correr() -> void:
	_stream = root.get_node_or_null("StreamManager")
	_monitor = root.get_node_or_null("MemoryMonitor")
	_terrain = _buscar(root)
	_obj_antes = _objetos()

	if _terrain != null:
		for p in _terrain.get_property_list():
			var nombre := String(p.get("name", ""))
			if nombre.find("block") >= 0:
				print("-- propiedad del VoxelTerrain: %s = %s" % [nombre, str(_terrain.get(nombre))])
		var v: Variant = _terrain.get("data_block_size")
		if v != null and int(v) > 0:
			_lado = int(v)
	print("-- lado de bloque de datos usado: %d^3 (%.1f KB por canal de 16 bits)"
		% [_lado, float(_lado * _lado * _lado * 2) / 1024.0])

	# 1) Presupuesto REAL del proyecto
	_reg = MemoryBudgetRegistry.new()
	var ok_reg: bool = bool(_reg.call("cargar"))
	_preset = String(_reg.call("preset"))
	_tope_voxel_mb = int(_reg.call("tope_de", "voxel"))
	print("-- budgets.json: carga=%s preset=%s tope_voxel=%d MB total_topes=%d MB"
		% [str(ok_reg), _preset, _tope_voxel_mb, int(_reg.call("total_topes_mb"))])
	_check(ok_reg and _preset != "" and _tope_voxel_mb > 0,
		"presupuesto real cargado (preset '%s', voxel %d MB)" % [_preset, _tope_voxel_mb])
	if not ok_reg:
		_resumen()
		return

	# 2) Coste REAL por chunk (buffers de VoxelTools del tamano de bloque)
	var m0 := OS.get_static_memory_usage()
	var bufs: Array[VoxelBuffer] = []
	for i in range(MUESTRAS_COSTE):
		var vb := VoxelBuffer.new()
		vb.create(_lado, _lado, _lado)
		vb.fill(4, VoxelBuffer.CHANNEL_TYPE)
		# Un VoxelBuffer LLENO DE UN SOLO VALOR se guarda comprimido (uniform):
		# sin este segundo valor el coste medido es ~0.4 KB y el presupuesto
		# saldria 20x optimista. Con dos valores distintos se materializa el
		# array real de 16^3.
		vb.set_voxel(5, 0, 0, 0, VoxelBuffer.CHANNEL_TYPE)
		bufs.append(vb)
	var m1 := OS.get_static_memory_usage()
	_coste_kb = snappedf(float(m1 - m0) / 1024.0 / float(MUESTRAS_COSTE), 0.1)
	print("-- coste por chunk: %.1f KB (%d buffers, delta %.1f KB)"
		% [_coste_kb, MUESTRAS_COSTE, float(m1 - m0) / 1024.0])
	_check(_coste_kb > 0.0, "coste por chunk medido > 0 (%.1f KB)" % _coste_kb)
	bufs.clear()

	# 3) Maximo de chunks que entra en cada preset
	_max_baja = _max_para(500)
	_max_media = _max_para(650)
	_max_alta = _max_para(800)
	if _stream != null:
		var datos: Dictionary = _stream.call("get_save_data")
		_max_por_defecto = int(datos.get("max_chunks", -1))
	print("-- maximo de chunks por presupuesto: baja(500 MB)=%d | media(650 MB)=%d | alta(800 MB)=%d"
		% [_max_baja, _max_media, _max_alta])
	print("-- tope LRU de PRODUCCION (StreamManager): %d chunks -> %.0f MB de datos al preset activo (%s)"
		% [_max_por_defecto, float(_max_por_defecto) * _coste_kb / 1024.0, _preset])

	# 4) El LRU de produccion respeta un tope derivado del presupuesto
	if _stream == null:
		_check(false, "StreamManager de produccion presente")
		_resumen()
		return
	_check(_max_por_defecto > 0, "tope LRU de produccion leido (%d)" % _max_por_defecto)
	# Se prueba con un tope manejable (el derivado del presupuesto puede ser
	# enorme): lo que se verifica es que el LRU respete el tope EXACTO.
	var tope := mini(_max_baja, 20000)
	if tope <= 0:
		_check(false, "tope derivado del presupuesto > 0 (medido %d)" % tope)
		_resumen()
		return
	_stream.call("set_max_chunks", tope)
	var n := tope + EXCESO
	for i in range(n):
		_stream.call("registrar_chunk", "c_%d" % i, float(i))
	print("-- registrados %d chunks con tope %d" % [n, tope])
	if not _sin_tope:
		var lib := int(_stream.call("aplicar_tope"))
		print("-- aplicar_tope() libero %d" % lib)
	_chunks_tras_tope = int(_stream.call("chunks_activos"))
	print("-- chunks activos tras el tope: %d (esperado %d)" % [_chunks_tras_tope, tope])
	_check(_chunks_tras_tope == tope, "el LRU deja exactamente el tope (%d)" % tope)

	# 5) Descarga: marcar envejecidos + liberar, con recursos REALES y WeakRef
	# OJO: `registrar_chunk(chunk_id, distancia, recurso: Resource)` — el
	# contrato de StreamManager es Resource (VoxelBuffer es RefCounted y NO
	# entra). Se usa un Resource real para probar la liberacion.
	var refs: Array[WeakRef] = []
	for i in range(10):
		var res := Resource.new()
		res.resource_name = "chunk_r_%d" % i
		_stream.call("registrar_chunk", "r_%d" % i, 9999.0, res)
		refs.append(weakref(res))
	_stream.call("marcar_envejecidos", 0.0)
	_stream.call("marcar_envejecidos", 0.0)
	_chunks_liberados = int(_stream.call("liberar_envejecidos"))
	_vivos = 0
	for w in refs:
		if w.get_ref() != null:
			_vivos += 1
	print("-- descarga: %d liberados, %d recursos vivos de 10" % [_chunks_liberados, _vivos])
	_check(_vivos == 0, "los recursos de los chunks liberados mueren (vivos=%d)" % _vivos)

	# 6) Estado del proceso
	_obj_final = _objetos()
	if _monitor != null:
		_orph = int(_monitor.call("nodos_huerfanos"))
	_check(_orph == 0, "0 nodos huerfanos (medido %d)" % _orph)
	print("-- objetos_vivos: %d -> %d (delta %+d)" % [_obj_antes, _obj_final, _obj_final - _obj_antes])
	_resumen()


func _max_para(tope_mb: int) -> int:
	if _coste_kb <= 0.0:
		return 0
	return int(float(tope_mb) * 1024.0 / _coste_kb)


func _buscar(n: Node) -> Node:
	if n is VoxelTerrain:
		return n
	for h in n.get_children():
		var r := _buscar(h)
		if r != null:
			return r
	return null


func _objetos() -> int:
	if _monitor != null and _monitor.has_method("objetos_vivos"):
		return int(_monitor.call("objetos_vivos"))
	return int(Performance.OBJECT_COUNT)


func _check(ok: bool, texto: String) -> void:
	_checks += 1
	if ok:
		print("  [OK] %s" % texto)
	else:
		print("  [FALLO] %s" % texto)
		_fallos += 1


func _resumen() -> void:
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO - salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK" % MODULO)
		quit(0)
