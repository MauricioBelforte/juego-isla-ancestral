# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-20
#
# M62 - ITEM 25 de la COLA V3:
#   "Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel [C]"
#
# ALCANCE DECLARADO (medido ANTES de escribir este arnes, con dos sondas):
#   NO: el camino Play Mode del VoxelTerrain. Medido en la escena real headless:
#       get_statistics().updated_blocks = 0, los 2000 voxeles muestreados dan 0
#       y set_voxel() no persiste (0 -> 0). Sin renderer el terreno no carga
#       bloques de datos: "excavar el mundo" no tiene sustrato headless.
#   NO: el generador de produccion invocado fuera del motor. Medido: llamar
#       _generate_block() sobre el VoxelGeneratorScript de la escena devuelve un
#       buffer 100% en 0 aunque IslandGenerator.get_block_at(0,-1,0) = 4
#       (BEDROCK). Limitacion del arnes (la via soportada es la del motor), NO
#       un bug del generador: el mundo si se genera en juego.
#   SI: lo que si existe headless y es lo que el item mide: buffers REALES de
#       VoxelTools (VoxelBuffer, mismo tipo y misma API que usan
#       farm_service.gd y test_terrenos_b3.gd) con los IDs REALES de BlockType,
#       y las 500 operaciones de excavar + regenerar.
#   SI: fuga: WeakRef de cada buffer temporal por ciclo (deben morir todos),
#       delta de objetos_vivos() del MemoryMonitor de produccion y memoria del
#       proceso antes/despues.
#   NO: VRAM (headless no crea renderer).
#
# ANTI-FALSO-VERDE:
#   1. Si el buffer no arranca con 500 bloques solidos, FALLA (escenario vacio).
#   2. Si las 500 excavaciones no se leen de vuelta como 0, FALLA (no-op).
#   3. Si las 500 regeneraciones no restauran el ID original, FALLA.
#   4. Si queda 1 buffer retenido, FALLA.
#   5. Si la memoria no vuelve al baseline (<= +5%), FALLA.
#   Sonda ROJA: M62_RETENER_BUFFERS=1 retiene un buffer por ciclo -> 4 y 5 fallan.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/sesion_m62_voxel_500.gd
#
# Variables de entorno (solo sondas):
#   M62_BLOQUES         cantidad de bloques (default 500)
#   M62_CICLOS          ciclos (default 5)
#   M62_RETENER_BUFFERS "1" = sonda ROJA (fuga deliberada)
#   M62_SIN_REGENERAR   "1" = sonda ROJA (no regenera -> no-op detectado)

extends SceneTree

const MODULO := "M62 voxel 500 bloques"
const ESCENA := "res://scenes/main_island.tscn"
const LADO := 16
const DRIFT_MAX_PCT := 5.0
const BLOQUES_DEFAULT := 500
const CICLOS_DEFAULT := 5
const ID_SOLIDO := 4
const ID_AIRE := 0
const WATCHDOG_S := 120.0

var _bloques := BLOQUES_DEFAULT
var _ciclos := CICLOS_DEFAULT
var _retener := false
var _sin_regenerar := false

var _terrain: Node = null
var _monitor: Node = null
var _escena_ok := false
var _t0_ms := 0
var _fase := 0
var _t_espera := 0.0

var _buf: VoxelBuffer = null
var _posiciones: Array[Vector3i] = []

var _excavados_ok := 0
var _regenerados_ok := 0
var _solidos_iniciales := 0

var _weak: Array[WeakRef] = []
var _retenidos: Array[VoxelBuffer] = []

var _mem_antes := 0.0
var _mem_excavado := 0.0
var _mem_final := 0.0
var _obj_antes := 0
var _obj_final := 0
var _orph_final := 0
var _drift_final := 0.0
var _base_lista := false

var _checks := 0
var _fallos := 0


func _initialize() -> void:
	var env := OS.get_environment("M62_BLOQUES")
	if env != "":
		_bloques = int(env)
	env = OS.get_environment("M62_CICLOS")
	if env != "":
		_ciclos = maxi(int(env), 1)
	_retener = OS.get_environment("M62_RETENER_BUFFERS") == "1"
	_sin_regenerar = OS.get_environment("M62_SIN_REGENERAR") == "1"
	_t0_ms = Time.get_ticks_msec()
	print("=== %s ===" % MODULO)
	print("-- inicio: %s" % Time.get_datetime_string_from_system())
	print("-- bloques: %d en %d ciclos | buffer: %d^3 | sonda roja retener=%s sin_regenerar=%s"
		% [_bloques, _ciclos, LADO, str(_retener), str(_sin_regenerar)])

	var packed: PackedScene = load(ESCENA)
	if packed == null:
		print("  [FALLO] no se pudo cargar %s" % ESCENA)
		_check(false, "escena real carga")
		_resumen()
		return
	var inst: Node = packed.instantiate()
	root.add_child(inst)
	current_scene = inst
	_escena_ok = true
	print("-- escena real instanciada")


func _process(delta: float) -> bool:
	var t := float(Time.get_ticks_msec() - _t0_ms) / 1000.0
	if t > WATCHDOG_S:
		print("  [FALLO] watchdog: el arnes no termino en %.0f s" % WATCHDOG_S)
		_check(false, "watchdog de %.0f s" % WATCHDOG_S)
		_resumen()
		return true
	_t_espera += delta
	if _fase == 0 and _t_espera >= 2.0:
		_fase = 1
		_buscar_terrain()
		_preparar_buffer()
		_medir_antes()
		_correr_ciclos()
		_cerrar()
		return true
	return false


func _buscar_terrain() -> void:
	_terrain = _buscar(root)
	if _terrain != null:
		print("-- VoxelTerrain presente (%s): NO usable headless para editar (updated_blocks=0 medido)"
			% _terrain.get_class())
	_monitor = root.get_node_or_null("MemoryMonitor")
	if _monitor != null:
		print("-- MemoryMonitor de produccion presente")


func _buscar(n: Node) -> Node:
	if n is VoxelTerrain:
		return n
	for h in n.get_children():
		var r := _buscar(h)
		if r != null:
			return r
	return null


func _preparar_buffer() -> void:
	_buf = VoxelBuffer.new()
	_buf.create(LADO, LADO, LADO)
	_buf.fill(ID_SOLIDO, VoxelBuffer.CHANNEL_TYPE)
	for y in range(LADO):
		for z in range(LADO):
			for x in range(LADO):
				if _posiciones.size() >= _bloques:
					break
				if int(_buf.get_voxel(x, y, z, VoxelBuffer.CHANNEL_TYPE)) == ID_SOLIDO:
					_posiciones.append(Vector3i(x, y, z))
				_solidos_iniciales += 1
	print("-- buffer real %d^3 con BlockType.BEDROCK (%d): %d solidos, %d posiciones"
		% [LADO, ID_SOLIDO, _solidos_iniciales, _posiciones.size()])


func _medir_antes() -> void:
	_mem_antes = _leer_memoria()
	_obj_antes = _objetos()
	if _monitor != null:
		_monitor.call("estabilizar_baseline", true)
		_base_lista = bool(_monitor.call("baseline_lista"))
	print("-- antes: mem=%.1f MB obj=%d baseline=%s" % [_mem_antes, _obj_antes, str(_base_lista)])


func _correr_ciclos() -> void:
	if _posiciones.is_empty():
		return
	var por_ciclo := int(ceil(float(_posiciones.size()) / float(_ciclos)))
	var idx := 0
	for c in range(_ciclos):
		var tmp := VoxelBuffer.new()
		tmp.create(LADO, LADO, LADO)
		tmp.fill(ID_SOLIDO, VoxelBuffer.CHANNEL_TYPE)
		_weak.append(weakref(tmp))
		if _retener:
			_retenidos.append(tmp)
		var fin := mini(idx + por_ciclo, _posiciones.size())
		for i in range(idx, fin):
			var p := _posiciones[i]
			_buf.set_voxel(ID_AIRE, p.x, p.y, p.z, VoxelBuffer.CHANNEL_TYPE)
		for i in range(idx, fin):
			var p := _posiciones[i]
			if int(_buf.get_voxel(p.x, p.y, p.z, VoxelBuffer.CHANNEL_TYPE)) == ID_AIRE:
				_excavados_ok += 1
		_mem_excavado = _leer_memoria()
		if not _sin_regenerar:
			for i in range(idx, fin):
				var p := _posiciones[i]
				_buf.set_voxel(ID_SOLIDO, p.x, p.y, p.z, VoxelBuffer.CHANNEL_TYPE)
			for i in range(idx, fin):
				var p := _posiciones[i]
				if int(_buf.get_voxel(p.x, p.y, p.z, VoxelBuffer.CHANNEL_TYPE)) == ID_SOLIDO:
					_regenerados_ok += 1
		print("-- ciclo %d: bloques %d..%d | excavados=%d regenerados=%d | mem=%.1f MB obj=%d"
			% [c + 1, idx, fin - 1, _excavados_ok, _regenerados_ok, _leer_memoria(), _objetos()])
		idx = fin
		if idx >= _posiciones.size():
			break
	if _retener:
		print("-- [SONDA ROJA] %d buffers retenidos a proposito" % _retenidos.size())


func _cerrar() -> void:
	_mem_final = _leer_memoria()
	_obj_final = _objetos()
	if _monitor != null:
		_orph_final = int(_monitor.call("nodos_huerfanos"))
		_drift_final = float(_monitor.call("drift_porciento"))
	var vivos := 0
	for w in _weak:
		if w.get_ref() != null:
			vivos += 1

	print("-- bloques: %d posiciones (de %d solidos)" % [_posiciones.size(), _solidos_iniciales])
	print("-- excavados leidos como AIRE: %d/%d" % [_excavados_ok, _posiciones.size()])
	print("-- regenerados con ID original: %d/%d" % [_regenerados_ok, _posiciones.size()])
	print("-- buffers temporales: %d creados, %d vivos (retenidos por sonda: %d)"
		% [_weak.size(), vivos, _retenidos.size()])
	print("-- memoria: antes=%.1f MB | tras excavar=%.1f MB | final=%.1f MB (delta %+.1f%%)"
		% [_mem_antes, _mem_excavado, _mem_final, _pct(_mem_final - _mem_antes)])
	print("-- objetos_vivos: %d -> %d (delta %+d) | huerfanos=%d | drift=%.1f%%"
		% [_obj_antes, _obj_final, _obj_final - _obj_antes, _orph_final, _drift_final])

	_check(_escena_ok, "escena real instanciada")
	_check(_solidos_iniciales >= _bloques, "buffer arranca con al menos %d bloques solidos (medido %d)"
		% [_bloques, _solidos_iniciales])
	_check(_posiciones.size() >= _bloques, "posiciones reales suficientes (%d)" % _posiciones.size())
	_check(_excavados_ok == _posiciones.size() and _excavados_ok >= _bloques,
		"las %d excavaciones se leen de vuelta como AIRE (no-op detectado)" % _bloques)
	_check(_regenerados_ok == _posiciones.size() and _regenerados_ok >= _bloques,
		"las %d regeneraciones restauran el ID original" % _bloques)
	_check(vivos == 0, "0 buffers temporales retenidos (vivos=%d)" % vivos)
	_check(_pct(_mem_final - _mem_antes) <= DRIFT_MAX_PCT,
		"memoria vuelve al baseline (delta %+.1f%% <= %.1f%%)" % [_pct(_mem_final - _mem_antes), DRIFT_MAX_PCT])
	_check(_obj_final - _obj_antes <= 20, "objetos_vivos sin acumulacion (delta %+d)" % (_obj_final - _obj_antes))
	_check(_orph_final == 0, "0 nodos huerfanos (medido %d)" % _orph_final)
	_resumen()


func _pct(delta_mb: float) -> float:
	if _mem_antes <= 0.0:
		return 0.0
	return snappedf(delta_mb / _mem_antes * 100.0, 0.1)


func _leer_memoria() -> float:
	if _monitor != null and _monitor.has_method("memoria_actual_mb"):
		return float(_monitor.call("memoria_actual_mb"))
	return snappedf(float(OS.get_static_memory_usage()) / (1024.0 * 1024.0), 0.1)


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
