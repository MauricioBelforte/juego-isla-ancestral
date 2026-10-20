# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-19
#
# M62: Memoria — ITEM 2 / 12 de la COLA V3 (Log 2021).
#   * L- "Sesion de referencia: 30 min de juego sin drift > 5% sobre la linea base"
#   * RN3 "memoria estable: sesion de 30 min con drift < 5% sobre baseline"
#
# ⚠️ QUE MIDE ESTE ARNES Y QUE NO (declarado ANTES de correr, no despues):
#   SI: corre la ESCENA REAL del juego (res://scenes/main_island.tscn) con sus
#       autoloads y el MemoryMonitor de produccion, durante 30 min de RELOJ DE
#       PARED (no frames: un --quit-after de N frames miente porque headless no
#       tiene vsync y corre a otra velocidad). La baseline la estabiliza el
#       PROPIO monitor a los 5 min (TIEMPO_BASELINE_S = 300) y el drift se lee
#       con drift_porciento() / drift_check() de produccion, sin formulas
#       paralelas.
#   NO: headless no crea renderer, asi que la memoria de GPU/texturas de video
#       no entra en OS.get_static_memory_usage(). Un verde aca NO cubre el
#       presupuesto de VRAM (eso es M61 + GPU real). Tampoco hay input de
#       jugador: la sesion es "mundo vivo en reposo + avisos de camara".
#
# ⚠️ ANTI-FALSO-VERDE:
#   1. Si el monitor no aparece en el arbol, el arnes FALLA (no puede pasar por
#      "no hay drift").
#   2. Si a los 30 min no hay baseline, drift_check() devuelve false por diseno
#      del monitor -> el arnes FALLA. Un "0.0%" sin baseline es una mentira.
#   3. La salida es EXIT 1 si el drift absoluto supera 5% o si faltan muestras.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/sesion_m62_30min.gd
#
# Variables de entorno (para pruebas cortas del propio arnes, NO para el run real):
#   M62_SESION_S        duracion en segundos (default 1800)
#   M62_MUESTREO_S      intervalo de muestreo (default 5)
#   M62_BASELINE_FORZAR si vale "1", fuerza baseline al inicio (SOLO smoke test;
#                       el run real NO lo usa, la baseline debe estabilizarse sola)

extends SceneTree

const MODULO := "M62 sesion 30 min"
const ESCENA := "res://scenes/main_island.tscn"
const DRIFT_MAX_PCT := 5.0          # limite DECLARADO por el checklist (RN3)
const MUESTRAS_MINIMAS := 300       # 30 min / 5 s = 360; 300 deja margen por jitter

var _duracion_s := 1800.0
var _muestreo_s := 5.0
var _t0_ms := 0
var _ultimo_muestreo_ms := 0
var _monitor: Node = null
var _escena_ok := false
var _muestras: Array[String] = []
var _n_muestras := 0
var _fallos := 0
var _drift_max_abs := 0.0
var _drift_max_en := 0.0
var _base_mb := 0.0
var _memoria_inicio_mb := 0.0
var _picos_por_tramo: Array[String] = []


func _initialize() -> void:
	_duracion_s = float(OS.get_environment("M62_SESION_S")) if OS.get_environment("M62_SESION_S") != "" else 1800.0
	_muestreo_s = float(OS.get_environment("M62_MUESTREO_S")) if OS.get_environment("M62_MUESTREO_S") != "" else 5.0
	_t0_ms = Time.get_ticks_msec()
	_ultimo_muestreo_ms = _t0_ms
	print("=== %s ===" % MODULO)
	print("-- inicio: %s" % Time.get_datetime_string_from_system())
	print("-- duracion: %.0f s / muestreo: %.0f s / escena: %s" % [_duracion_s, _muestreo_s, ESCENA])

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
	_escena_ok = true
	print("-- escena real instanciada; esperando al monitor de produccion")


func _process(_delta: float) -> bool:
	var ahora := Time.get_ticks_msec()
	var t := float(ahora - _t0_ms) / 1000.0

	if _monitor == null:
		_monitor = _buscar_monitor(root)
		if _monitor != null:
			_memoria_inicio_mb = _leer_memoria()
			if OS.get_environment("M62_BASELINE_FORZAR") == "1":
				_monitor.call("estabilizar_baseline", true)
				print("-- [SMOKE] baseline FORZADA (solo prueba del arnes)")
			print("-- monitor encontrado (memoria inicial %.1f MB)" % _memoria_inicio_mb)
			if _monitor.has_signal("drift_detectado"):
				_monitor.connect("drift_detectado", Callable(self, "_on_drift"))

	# Aviso de camara cada 2 s: ejercita la rama de muestreo a 1 s del monitor,
	# que es la que corre en produccion cuando el jugador se mueve.
	if _monitor != null and int(t) % 2 == 0:
		_monitor.call("avisar_movimiento_camara")

	if ahora - _ultimo_muestreo_ms >= int(_muestreo_s * 1000.0):
		_ultimo_muestreo_ms = ahora
		_muestrear(t)

	if t >= _duracion_s:
		_cerrar()
		return true
	return false


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


func _leer_memoria() -> float:
	if _monitor != null and _monitor.has_method("memoria_actual_mb"):
		return float(_monitor.call("memoria_actual_mb"))
	return snappedf(float(OS.get_static_memory_usage()) / (1024.0 * 1024.0), 0.1)


func _muestrear(t: float) -> void:
	var mem := _leer_memoria()
	var base := 0.0
	var drift := 0.0
	var hay_base := false
	if _monitor != null:
		base = float(_monitor.call("baseline_mb"))
		hay_base = bool(_monitor.call("baseline_lista"))
		drift = float(_monitor.call("drift_porciento"))
	var obj := 0
	var orph := 0
	if _monitor != null:
		obj = int(_monitor.call("objetos_vivos"))
		orph = int(_monitor.call("nodos_huerfanos"))
	_n_muestras += 1
	if hay_base:
		_base_mb = base
		if absf(drift) > _drift_max_abs:
			_drift_max_abs = absf(drift)
			_drift_max_en = t
	# Muestra cada 60 s al stdout para que el log quede legible; todas al CSV.
	if _n_muestras % int(max(1.0, 60.0 / _muestreo_s)) == 0:
		print("-- t=%6.0fs mem=%8.1f MB base=%8.1f MB drift=%+6.1f%% obj=%d orph=%d"
			% [t, mem, base, drift, obj, orph])
	_muestras.append("%.0f;%.1f;%.1f;%s;%.1f;%d;%d" % [
		t, mem, base, ("1" if hay_base else "0"), drift, obj, orph])


func _on_drift(porcentaje: float) -> void:
	print("  [SENAL] drift_detectado %.1f%% (t=%.0f s)" % [porcentaje, float(Time.get_ticks_msec() - _t0_ms) / 1000.0])
	_picos_por_tramo.append("drift %.1f%%" % porcentaje)


func _cerrar() -> void:
	print("-- fin: %s" % Time.get_datetime_string_from_system())
	var hay_base := false
	var drift_final := 0.0
	var check := false
	if _monitor != null:
		hay_base = bool(_monitor.call("baseline_lista"))
		drift_final = float(_monitor.call("drift_porciento"))
		check = bool(_monitor.call("drift_check"))

	print("-- muestras: %d (minimo %d)" % [_n_muestras, MUESTRAS_MINIMAS])
	print("-- baseline: %s (%.1f MB)" % [("SI" if hay_base else "NO"), _base_mb])
	print("-- drift final: %+.1f%% | drift maximo absoluto: %.1f%% (t=%.0f s)"
		% [drift_final, _drift_max_abs, _drift_max_en])
	print("-- drift_check(): %s" % ("true" if check else "false"))
	if not _escena_ok:
		print("  [FALLO] la escena del juego no se instancio")
		_fallos += 1
	if _monitor == null:
		print("  [FALLO] MemoryMonitor de produccion no encontrado en el arbol")
		_fallos += 1
	if _monitor != null and not hay_base:
		print("  [FALLO] sin baseline a los %.0f s: no se puede afirmar RN3" % _duracion_s)
		_fallos += 1
	if _monitor != null and not check:
		print("  [FALLO] drift_check() = false (limite %.1f%%)" % DRIFT_MAX_PCT)
		_fallos += 1
	if _n_muestras < MUESTRAS_MINIMAS and _duracion_s >= 1800.0:
		print("  [FALLO] solo %d muestras de %d" % [_n_muestras, MUESTRAS_MINIMAS])
		_fallos += 1

	var ruta := "user://sesion_m62_30min.csv"
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_line("t_s;mem_mb;base_mb;hay_base;drift_pct;objetos;huerfanos")
		for linea in _muestras:
			f.store_line(linea)
		f.close()
		print("-- CSV: %s (abs: %s)" % [ruta, ProjectSettings.globalize_path(ruta)])

	print("=== Resumen %s: %d muestras, %d fallos ===" % [MODULO, _n_muestras, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — drift dentro del limite" % MODULO)
		quit(0)
