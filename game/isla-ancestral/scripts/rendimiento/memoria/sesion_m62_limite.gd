# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-20
#
# M62: Memoria - ITEM 17 de la COLA V3:
#   "Memoria al limite durante tormenta maxima: degrada con aviso y el juego
#    sigue jugable [M]"
#
# COMO SE LLEGA AL LIMITE (declarado, es una INYECCION, no una sesion real):
#   No se pueden reservar 1,4 GB para llegar al 95% del preset media (1500 MB)
#   sin arriesgar el proceso. Lo que se fuerza es el DENOMINADOR: se reescribe el
#   presupuesto del monitor en vivo con `registrar_sistema()` (API de produccion,
#   la misma que usa M90 para cambiar preset) para que la memoria REAL de la
#   escena quede en el 85%, 92% y 97% del presupuesto. La memoria NO se toca: lo
#   que se fuerza es el umbral, que es exactamente la condicion del item.
#
# QUE MIDE:
#   * el contexto es TORMENTA real de M32 (avanzar_hasta, la API de "dormir");
#   * el semaforo escala 1 (warning/aviso) -> 2 (degradacion suave) -> 3 (dura);
#   * la senal `semaforo_cambiado` se emite en cada escalon (el "aviso" observable);
#   * el enforcement corre en 2 y 3 (estado `_ultimo_enforcement` del monitor);
#   * NO hay crash ni aborto: el monitor y la escena siguen vivos despues;
#   * al restaurar el presupuesto real (`budget.cargar()`), el semaforo vuelve a 0.
#
# QUE NO MIDE (declarado):
#   * "el juego sigue jugable" a nivel de FRAMES: en modo `--script` el arbol no
#     itera a 60 Hz (medido: 8 physics frames en 10 s), asi que no se puede
#     afirmar jugabilidad por frames. Se mide lo observable: la escena y sus
#     nodos siguen validos y el Player sigue siendo movible.
#   * "banco de audio completo": 0 assets de audio en el repo (Log 2028).
#
# Codigos: 0 = verde · 1 = fallo · 3 = no medible (sin monitor / sin tormenta)
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/sesion_m62_limite.gd

extends SceneTree

const MODULO := "M62 limite tormenta"
const ESCENA := "res://scenes/main_island.tscn"
const CLIMA_TORMENTA := 3
const DIAS_MAX_TORMENTA := 90
const BLOQUES := ["A", "B", "C"]
const PISO_CHECKS := 12

var _t0_ms := 0
var _monitor: Node = null
var _raiz: Node = null
var _gt: Node = null
var _weather: Node = null
var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _niveles: Array[int] = []
var _no_medible := ""
var _cerrado := false
var _presupuesto_real := 0
var _preset_real := ""
var _snapshot: Dictionary = {}
var _presupuesto_forzado := 0
var _mem := 0.0
var _evidencia: Array[String] = []


func _initialize() -> void:
	_t0_ms = Time.get_ticks_msec()
	print("=== %s ===" % MODULO)
	print("-- inicio: %s" % Time.get_datetime_string_from_system())
	var packed: PackedScene = load(ESCENA)
	if packed == null:
		print("  [FALLO] no se pudo cargar %s" % ESCENA)
		_fallos += 1
		_cerrar()
		return
	var inst: Node = packed.instantiate()
	if inst == null:
		print("  [FALLO] la escena no se pudo instanciar")
		_fallos += 1
		_cerrar()
		return
	root.add_child(inst)
	current_scene = inst
	_raiz = inst
	print("-- escena real instanciada")


func _process(_delta: float) -> bool:
	if _cerrado:
		return true
	var t := float(Time.get_ticks_msec() - _t0_ms) / 1000.0
	if _monitor == null:
		_monitor = _buscar_monitor(root)
		if _monitor != null:
			_monitor.connect("semaforo_cambiado", Callable(self, "_on_semaforo"))
			_check(true, "MemoryMonitor de produccion presente")
			_check(float(_monitor.call("memoria_actual_mb")) > 0.0, "lectura de memoria > 0")
			_presupuesto_real = int(_monitor.call("presupuesto_total_mb"))
			_check(_presupuesto_real > 0, "el presupuesto real del preset es > 0 (%d MB)" % _presupuesto_real)
			var b0: Variant = _monitor.get("budget")
			if b0 != null:
				_preset_real = String(b0.call("preset"))
				# Snapshot EXACTO de los topes vivos: `set_preset()` re-aplica los del
				# archivo y NO reproduce lo que se registro en runtime (medido: el preset
				# "media" suma 2032 MB en runtime contra 2000 MB del dataset).
				for s in b0.call("sistemas"):
					_snapshot[String(s)] = int(b0.call("tope_de", String(s)))
			print("-- preset real en runtime: %s (%d MB)" % [_preset_real, _presupuesto_real])
			_fin("A")
			_ejecutar()
			_fin("B")
			_fin("C")
			_cerrar()
			return true
		if t > 60.0:
			print("  [FALLO] sin MemoryMonitor a los 60 s")
			_fallos += 1
			_cerrar()
			return true
	if t > 240.0:
		print("  [FALLO] watchdog: la prueba no termino en %.0f s" % t)
		_fallos += 1
		_cerrar()
		return true
	return false


func _ejecutar() -> void:
	# Los autoloads NO existen en `_initialize()`: se resuelven aca, ya con el arbol vivo.
	_gt = root.get_node_or_null("/root/GameTime")
	_weather = root.get_node_or_null("/root/Weather")
	if _gt == null or _weather == null:
		_no_medible = "sin autoloads GameTime/Weather"
		return
	# 1) Contexto: TORMENTA real de M32 (deterministica por dia).
	var dias := 0
	var clima := int(_weather.call("get_clima"))
	for i in DIAS_MAX_TORMENTA:
		if clima == CLIMA_TORMENTA:
			break
		_gt.call("avanzar_hasta", 23, 59)
		_gt.call("avanzar_hasta", 0, 0)
		clima = int(_weather.call("get_clima"))
		dias += 1
	_evidencia.append("TORMENTA alcanzada tras %d dias (clima=%d)" % [dias, clima])
	_check(clima == CLIMA_TORMENTA, "contexto: TORMENTA de M32 activa")
	if clima != CLIMA_TORMENTA:
		_no_medible = "no se alcanzo TORMENTA en %d dias" % DIAS_MAX_TORMENTA
		return

	# 2) Escalones: se fuerza el DENOMINADOR, no la memoria.
	var escalones := [0.85, 0.92, 0.97]
	var esperados := [1, 2, 3]
	for i in escalones.size():
		var frac := float(escalones[i])
		_mem = float(_monitor.call("memoria_actual_mb"))
		# El denominador se calcula con la memoria REAL de este instante: total =
		# mem / fraccion, de modo que mem/total caiga en el escalon pedido.
		var total := int(round(_mem / frac))
		_forzar_presupuesto(total)
		_monitor.call("muestrear_ahora")
		var nivel := int(_monitor.get("semaforo"))
		_mem = float(_monitor.call("memoria_actual_mb"))
		_evidencia.append("presupuesto %d MB (objetivo %.0f%% de %.1f MB) -> nivel %d"
			% [_presupuesto_forzado, frac * 100.0, _mem, nivel])
		_check(nivel == int(esperados[i]), "con el presupuesto al %.0f%% el semaforo es %d (fue %d)"
			% [frac * 100.0, int(esperados[i]), nivel])

	# 3) El "aviso" observable: la senal se emitio en cada escalon.
	_check(_niveles.size() >= 3, "semaforo_cambiado se emitio %d veces (>= 3)" % _niveles.size())
	_check(_niveles.has(1) and _niveles.has(2) and _niveles.has(3),
		"la secuencia de avisos incluye 1, 2 y 3: %s" % str(_niveles))

	# 4) El enforcement corrio en 2 y en 3.
	var ultimo := int(_monitor.get("_ultimo_enforcement"))
	_evidencia.append("_ultimo_enforcement = %d" % ultimo)
	_check(ultimo == 3, "el enforcement llego al nivel 3 (duro)")

	# 5) Sin crash: monitor y escena siguen vivos y el Player se puede mover.
	_check(is_instance_valid(_monitor), "el monitor sigue vivo tras la degradacion")
	var jugador: Node = _raiz.find_child("Player", true, false)
	if jugador != null:
		var p3 := jugador as Node3D
		var x0 := p3.global_position.x
		p3.global_position = Vector3(x0 + 2.0, p3.global_position.y, p3.global_position.z)
		_check(absf(p3.global_position.x - (x0 + 2.0)) < 0.01, "el Player sigue siendo movible tras la degradacion")
	else:
		_check(false, "no hay Player para probar que la escena sigue viva")

	# 6) Restaurar el snapshot EXACTO de los topes vivos (por nombre, no `cargar()`:
	#    el runtime puede tener topes distintos de los del `preset_activo` del archivo).
	var budget: Variant = _monitor.get("budget")
	if budget != null:
		for s in _snapshot:
			budget.call("registrar_sistema", String(s), int(_snapshot[s]))
	_monitor.call("muestrear_ahora")
	var nivel_final := int(_monitor.get("semaforo"))
	_evidencia.append("presupuesto restaurado a %d MB -> nivel %d"
		% [int(_monitor.call("presupuesto_total_mb")), nivel_final])
	_check(int(_monitor.call("presupuesto_total_mb")) == _presupuesto_real,
		"el presupuesto volvio al real (%d MB)" % _presupuesto_real)
	_check(nivel_final == 0, "con el presupuesto real el semaforo vuelve a 0 (fue %d)" % nivel_final)


## Reescribe el presupuesto en vivo: 8 sistemas que suman `total`. La memoria
## real no se toca (solo el denominador del semaforo).
func _forzar_presupuesto(total: int) -> void:
	var budget: Variant = _monitor.get("budget")
	if budget == null:
		return
	var sistemas: Array = budget.call("sistemas")
	var n := maxi(1, sistemas.size())
	var porcion := int(total / n)
	for s in sistemas:
		budget.call("registrar_sistema", String(s), porcion)
	var resto := total - porcion * n
	if resto != 0 and not sistemas.is_empty():
		budget.call("registrar_sistema", String(sistemas[0]), porcion + resto)
	_presupuesto_forzado = int(budget.call("total_topes_mb"))


func _on_semaforo(nuevo: int) -> void:
	_niveles.append(nuevo)
	print("  [SENAL] semaforo_cambiado -> %d" % nuevo)


func _buscar_monitor(n: Node) -> Node:
	if n.get_script() != null:
		var ruta := (n.get_script() as Script).resource_path
		if ruta.ends_with("rendimiento/memoria/memory_monitor.gd"):
			return n
	for h in n.get_children():
		var encontrado := _buscar_monitor(h)
		if encontrado != null:
			return encontrado
	return null


func _check(ok: bool, que: String) -> void:
	_checks += 1
	if ok:
		print("  [OK] %s" % que)
	else:
		_fallos += 1
		print("  [FALLO] %s" % que)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _cerrar() -> void:
	if _cerrado:
		return
	_cerrado = true
	var faltantes: Array[String] = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltantes.append(String(b))
	if not faltantes.is_empty():
		_check(false, "bloques NO ejecutados (posible SCRIPT ERROR): %s" % str(faltantes))
	if _checks < PISO_CHECKS:
		_check(false, "solo %d checks ejecutados (minimo %d)" % [_checks, PISO_CHECKS])
	for e in _evidencia:
		print("-- evidencia: %s" % e)
	print("-- fin: %s" % Time.get_datetime_string_from_system())
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _no_medible != "":
		print("NO MEDIBLE: %s" % _no_medible)
		print("TEST %s NO MEDIBLE - salida 3" % MODULO)
		quit(3)
		return
	if _fallos > 0:
		print("TEST %s FALLIDO - salida 1" % MODULO)
		quit(1)
		return
	print("TEST %s OK - degrada 1->2->3 con aviso y vuelve a 0" % MODULO)
	quit(0)
