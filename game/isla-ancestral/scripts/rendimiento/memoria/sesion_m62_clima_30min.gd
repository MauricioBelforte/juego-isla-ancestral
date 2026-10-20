# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-19
#
# M62: Memoria - ITEM 12 de la COLA V3 (y cubre la condicion "sin teleport" del ITEM 23).
#   * L- "Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio"
#   * L- "Test Play Mode: drift-check de 30 min sin teleport con drift <= 5%"
#
# ⚠️ QUE MIDE ESTE ARNES Y QUE NO (declarado ANTES de correr):
#   SI: corre la ESCENA REAL (res://scenes/main_island.tscn) con sus autoloads y el
#       MemoryMonitor de produccion, durante 30 min de RELOJ DE PARED. Cada
#       CLIMA_CADA_S avanza UN dia de juego por la API de produccion
#       (GameTime.avanzar_hasta, la misma que usa "dormir en cama"), lo que dispara
#       GameTime.dia_cambio -> Weather._recalcular_dia_actual() -> EventBus.weather.clima_cambio.
#       NO inventa climas: usa el clima determinista de M32 (clima_de_dia).
#   SI: mide los observables de AUDIO que existen sin assets: AudioServer.bus_count
#       y la cantidad de nodos AudioStreamPlayer/2D/3D en el arbol (fuga de nodos).
#   SI (OPCIONAL, M62_AUDIO_BANCO_MB > 0): en cada clima_cambio crea un banco
#       SINTETICO AudioStreamWAV de ese tamano (AudioStream REAL, no un Resource
#       vacio), lo entrega con MemoryMonitor.avisar_cambio_bioma_audio() (mecanismo
#       L154) y verifica que el banco anterior muera (WeakRef). Esto mide el
#       MECANISMO del 62 bajo clima cambiante con un stand-in declarado; NO mide
#       assets reales ni el cableado M42 (set_estado_clima sigue con 0 llamadores).
#   NO: con 0 archivos de audio en el repo no hay streams de PRODUCCION. El banco
#       sintetico cubre la memoria y el contrato del 62, no el decoder ni el asset.
#       Ademas, medido en disco: AmbientDirector.set_estado_clima() (M42) tiene 0
#       llamadores de produccion, asi que el clima de M32 no llega al banco de
#       audio de M42. Esa mitad sigue siendo deuda de M42, no de este arnes.
#   NO: headless no crea renderer -> sin VRAM.
#
# ⚠️ ANTI-FALSO-VERDE:
#   1. Si no hay monitor, FALLA. Si no hay baseline a los 30 min, FALLA.
#   2. Si los cambios de clima no ocurrieron (menos de CAMBIOS_MINIMOS, o menos de
#      2 climas distintos), FALLA: un escenario que no se ejecuto no es un verde.
#   3. drift_check() de produccion manda; si da false, FALLA.
#   4. Si aparecen buses de audio o reproductores nuevos (fuga), FALLA.
#   5. Con audio activo: si no se creo un banco por clima efectivo, si el banco no
#      movio la memoria (control positivo) o si sobrevive mas de UN banco (el
#      actual), FALLA. Un escenario de audio que no se ejecuto no es un verde.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/sesion_m62_clima_30min.gd
#
# Variables de entorno (solo para probar el arnes; el run real NO las usa):
#   M62_SESION_S        duracion (default 1800)
#   M62_MUESTREO_S      intervalo de muestreo (default 5)
#   M62_CLIMA_CADA_S    cada cuantos segundos se avanza un dia (default 180 -> 10 cambios)
#   M62_BASELINE_FORZAR "1" fuerza baseline al inicio (smoke)
#   M62_INYECTAR_FUGA   "1" asigna memoria a proposito (sonda ROJA del gate de drift)
#   M62_SIN_CAMBIOS     "1" NO avanza dias (sonda ROJA del gate de escenario)
#   M62_AUDIO_BANCO_MB  MB de cada banco AudioStreamWAV sintetico (default 0 = off)
#   M62_AUDIO_FUGA      "1" retiene los bancos en el arnes (sonda ROJA de fuga audio)

extends SceneTree

const MODULO := "M62 clima 30 min"
const ESCENA := "res://scenes/main_island.tscn"
const DRIFT_MAX_PCT := 5.0
const MUESTRAS_MINIMAS := 300
const CAMBIOS_MINIMOS := 5
const CLIMAS_DISTINTOS_MIN := 2
const NOMBRES := ["SOLEADO", "NUBLADO", "LLUVIA", "TORMENTA", "NIEBLA", "NIEVE", "VIENTO", "TROPICAL", "ESPECIAL"]
const AUDIO_CONTROL_MIN_MB := 1.0

var _duracion_s := 1800.0
var _muestreo_s := 5.0
var _clima_cada_s := 180.0
var _t0_ms := 0
var _ultimo_muestreo_ms := 0
var _proximo_cambio_s := 60.0   # el primer dia se avanza tras el boot del mundo
var _monitor: Node = null
var _weather: Node = null
var _gametime: Node = null
var _bus: Node = null
var _escena_ok := false
var _fallos := 0

var _n_muestras := 0
var _drift_max_abs := 0.0
var _drift_max_en := 0.0
var _base_mb := 0.0
var _memoria_inicio_mb := 0.0

var _cambios_pedidos := 0
var _cambios_efectivos := 0
var _eventos_clima := 0
var _climas_vistos: Array[int] = []
var _secuencia: Array[String] = []

var _audio_banco_mb := 0.0
var _audio_fuga := false
var _audio_creados := 0
var _audio_control_positivo := false
var _audio_refs: Array[WeakRef] = []
var _audio_retenidos: Array[AudioStreamWAV] = []
var _audio_mem_pico := 0.0

var _buses_inicio := -1
var _buses_fin := -1
var _players_inicio := -1
var _players_fin := -1
var _viajes := 0
var _viajes_medibles := false

var _muestras: Array[String] = []
var _fuga: Array[PackedByteArray] = []


func _initialize() -> void:
	var env := OS.get_environment("M62_SESION_S")
	if env != "":
		_duracion_s = float(env)
	env = OS.get_environment("M62_MUESTREO_S")
	if env != "":
		_muestreo_s = float(env)
	env = OS.get_environment("M62_CLIMA_CADA_S")
	if env != "":
		_clima_cada_s = float(env)
	env = OS.get_environment("M62_AUDIO_BANCO_MB")
	if env != "":
		_audio_banco_mb = maxf(0.0, float(env))
	_audio_fuga = OS.get_environment("M62_AUDIO_FUGA") == "1"
	_t0_ms = Time.get_ticks_msec()
	_ultimo_muestreo_ms = _t0_ms
	print("=== %s ===" % MODULO)
	print("-- inicio: %s" % Time.get_datetime_string_from_system())
	print("-- duracion: %.0f s / muestreo: %.0f s / clima cada: %.0f s / escena: %s"
		% [_duracion_s, _muestreo_s, _clima_cada_s, ESCENA])
	print("-- audio sintetico: %.1f MB por clima (%s)%s"
		% [_audio_banco_mb, ("ACTIVO" if _audio_banco_mb > 0.0 else "desactivado"),
		(" / SONDA ROJA: retiene bancos" if _audio_fuga else "")])

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
	print("-- escena real instanciada; esperando monitor y clima de produccion")


func _process(_delta: float) -> bool:
	var ahora := Time.get_ticks_msec()
	var t := float(ahora - _t0_ms) / 1000.0

	if _monitor == null:
		_monitor = _buscar_monitor(root)
		if _monitor != null:
			_memoria_inicio_mb = _leer_memoria()
			if OS.get_environment("M62_BASELINE_FORZAR") == "1":
				_monitor.call("estabilizar_baseline", true)
				print("-- [SMOKE] baseline FORZADA")
			print("-- monitor encontrado (memoria inicial %.1f MB)" % _memoria_inicio_mb)
			if _monitor.has_signal("drift_detectado"):
				_monitor.connect("drift_detectado", Callable(self, "_on_drift"))
		_conectar_produccion()
		if _weather != null:
			_buses_inicio = AudioServer.bus_count
			_players_inicio = _contar_reproductores(root)
			print("-- clima: %s | buses audio: %d | reproductores: %d | viajes medibles: %s"
				% [_nombre_clima(_clima_actual()), _buses_inicio, _players_inicio, str(_viajes_medibles)])

	if _monitor != null and int(t) % 2 == 0:
		_monitor.call("avisar_movimiento_camara")

	if OS.get_environment("M62_SIN_CAMBIOS") != "1" and t >= _proximo_cambio_s:
		_proximo_cambio_s += _clima_cada_s
		_forzar_cambio_clima(t)

	if OS.get_environment("M62_INYECTAR_FUGA") == "1":
		# Sonda ROJA: +4 MB por muestra (cada _muestreo_s), tope 200 MB para no
		# reventar el proceso. Inyectar por FRAME seria GB/s en headless.
		if _fuga.size() < 50:
			var bloque := PackedByteArray()
			bloque.resize(4 * 1024 * 1024)
			_fuga.append(bloque)

	if ahora - _ultimo_muestreo_ms >= int(_muestreo_s * 1000.0):
		_ultimo_muestreo_ms = ahora
		_muestrear(t)

	if t >= _duracion_s:
		_cerrar()
		return true
	return false


func _conectar_produccion() -> void:
	_weather = root.get_node_or_null("Weather")
	_gametime = root.get_node_or_null("GameTime")
	_bus = root.get_node_or_null("EventBus")
	if _bus != null and _bus.has_method("get") and _bus.get("weather") != null:
		var w: Variant = _bus.get("weather")
		if w != null and w.has_signal("clima_cambio"):
			w.connect("clima_cambio", Callable(self, "_on_clima_cambio"))
	var viajes := root.get_node_or_null("TravelService")
	if viajes == null:
		viajes = _buscar_por_script(root, "viajes/travel_service.gd")
	if viajes != null and viajes.has_signal("travel_started"):
		viajes.connect("travel_started", Callable(self, "_on_viaje"))
		_viajes_medibles = true


func _buscar_por_script(n: Node, sufijo: String) -> Node:
	if n.get_script() != null:
		var ruta := (n.get_script() as Script).resource_path
		if ruta.ends_with(sufijo):
			return n
	for h in n.get_children():
		var encontrado := _buscar_por_script(h, sufijo)
		if encontrado != null:
			return encontrado
	return null


func _forzar_cambio_clima(t: float) -> void:
	_cambios_pedidos += 1
	if _gametime == null or _weather == null:
		print("  [FALLO] sin GameTime/Weather: no se puede cambiar el clima")
		return
	var antes := _clima_actual()
	# API de produccion: la misma que "dormir en cama" (avanza minutos hasta la hora).
	_gametime.call("avanzar_hasta", 23, 59)
	_gametime.call("avanzar_hasta", 0, 0)
	var despues := _clima_actual()
	if despues != antes:
		_cambios_efectivos += 1
	if not _climas_vistos.has(despues):
		_climas_vistos.append(despues)
	_secuencia.append("%s->%s" % [_nombre_clima(antes), _nombre_clima(despues)])
	print("-- t=%5.0fs clima %d: %s -> %s (dia %d)"
		% [t, _cambios_pedidos, _nombre_clima(antes), _nombre_clima(despues), _dia_actual()])


func _clima_actual() -> int:
	if _weather == null:
		return -1
	return int(_weather.call("get_clima"))


func _dia_actual() -> int:
	if _gametime == null:
		return -1
	return int(_gametime.call("dia_absoluto"))


func _nombre_clima(c: int) -> String:
	if c < 0 or c >= NOMBRES.size():
		return "?"
	return String(NOMBRES[c])


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


func _contar_reproductores(n: Node) -> int:
	var total := 0
	if n.is_class("AudioStreamPlayer") or n.is_class("AudioStreamPlayer2D") or n.is_class("AudioStreamPlayer3D"):
		total += 1
	for h in n.get_children():
		total += _contar_reproductores(h)
	return total


func _leer_memoria() -> float:
	if _monitor != null and _monitor.has_method("memoria_actual_mb"):
		return float(_monitor.call("memoria_actual_mb"))
	return snappedf(float(OS.get_static_memory_usage()) / (1024.0 * 1024.0), 0.1)


func _muestrear(t: float) -> void:
	var mem := _leer_memoria()
	var base := 0.0
	var drift := 0.0
	var hay_base := false
	var obj := 0
	var orph := 0
	if _monitor != null:
		base = float(_monitor.call("baseline_mb"))
		hay_base = bool(_monitor.call("baseline_lista"))
		drift = float(_monitor.call("drift_porciento"))
		obj = int(_monitor.call("objetos_vivos"))
		orph = int(_monitor.call("nodos_huerfanos"))
	_n_muestras += 1
	if hay_base:
		_base_mb = base
		if absf(drift) > _drift_max_abs:
			_drift_max_abs = absf(drift)
			_drift_max_en = t
	var buses := AudioServer.bus_count
	var players := _contar_reproductores(root)
	var audio_vivos := _audio_vivos()
	if _n_muestras % int(max(1.0, 60.0 / _muestreo_s)) == 0:
		print("-- t=%6.0fs mem=%8.1f MB base=%8.1f MB drift=%+6.1f%% obj=%d orph=%d buses=%d players=%d audio_bancos=%d"
			% [t, mem, base, drift, obj, orph, buses, players, audio_vivos])
	_muestras.append("%.0f;%.1f;%.1f;%s;%.1f;%d;%d;%d;%d;%d" % [
		t, mem, base, ("1" if hay_base else "0"), drift, obj, orph, buses, players, audio_vivos])


func _on_clima_cambio(_clima: int) -> void:
	_eventos_clima += 1
	_crear_banco_audio()


func _crear_banco_audio() -> void:
	if _audio_banco_mb <= 0.0:
		return
	if _monitor == null or not _monitor.has_method("avisar_cambio_bioma_audio"):
		print("  [FALLO] monitor sin avisar_cambio_bioma_audio: audio no medible")
		_audio_creados = -1
		return
	var antes := _leer_memoria()
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var datos := PackedByteArray()
	datos.resize(int(_audio_banco_mb * 1024.0 * 1024.0))
	wav.data = datos
	datos = PackedByteArray()
	var aceptado := bool(_monitor.call("avisar_cambio_bioma_audio", wav))
	var despues := _leer_memoria()
	if not _audio_control_positivo and despues - antes >= AUDIO_CONTROL_MIN_MB:
		_audio_control_positivo = true
	_audio_mem_pico = maxf(_audio_mem_pico, despues)
	_audio_creados += 1
	_audio_refs.append(weakref(wav))
	if _audio_fuga:
		_audio_retenidos.append(wav)
	print("-- audio banco %d: %.1f MB, mem %.1f -> %.1f MB, aceptado=%s, vivos=%d"
		% [_audio_creados, _audio_banco_mb, antes, despues, str(aceptado), _audio_vivos()])


func _audio_vivos() -> int:
	var vivos := 0
	for r in _audio_refs:
		if r.get_ref() != null:
			vivos += 1
	return vivos


func _on_viaje(_route_id: StringName) -> void:
	_viajes += 1


func _on_drift(porcentaje: float) -> void:
	print("  [SENAL] drift_detectado %.1f%% (t=%.0f s)"
		% [porcentaje, float(Time.get_ticks_msec() - _t0_ms) / 1000.0])


func _cerrar() -> void:
	print("-- fin: %s" % Time.get_datetime_string_from_system())
	var hay_base := false
	var drift_final := 0.0
	var check := false
	if _monitor != null:
		hay_base = bool(_monitor.call("baseline_lista"))
		drift_final = float(_monitor.call("drift_porciento"))
		check = bool(_monitor.call("drift_check"))
	_buses_fin = AudioServer.bus_count
	_players_fin = _contar_reproductores(root)
	var audio_actual: RefCounted = null
	var audio_pendiente: RefCounted = null
	if _monitor != null:
		if _monitor.has_method("audio_banco_actual"):
			audio_actual = _monitor.call("audio_banco_actual")
		if _monitor.has_method("audio_banco_pendiente"):
			audio_pendiente = _monitor.call("audio_banco_pendiente")
	var audio_vivos := _audio_vivos()

	print("-- muestras: %d (minimo %d)" % [_n_muestras, MUESTRAS_MINIMAS])
	print("-- baseline: %s (%.1f MB)" % [("SI" if hay_base else "NO"), _base_mb])
	print("-- drift final: %+.1f%% | maximo absoluto: %.1f%% (t=%.0f s)"
		% [drift_final, _drift_max_abs, _drift_max_en])
	print("-- drift_check(): %s" % ("true" if check else "false"))
	print("-- clima: %d cambios pedidos, %d efectivos, %d eventos clima_cambio, %d climas distintos %s"
		% [_cambios_pedidos, _cambios_efectivos, _eventos_clima, _climas_vistos.size(), str(_climas_vistos)])
	print("-- secuencia: %s" % ", ".join(_secuencia))
	print("-- audio: buses %d -> %d | reproductores %d -> %d" % [_buses_inicio, _buses_fin, _players_inicio, _players_fin])
	print("-- audio sintetico: %d bancos creados, %d vivos, actual=%s pendiente=%s, control=%s, pico=%.1f MB"
		% [_audio_creados, audio_vivos, str(audio_actual != null), str(audio_pendiente != null),
		str(_audio_control_positivo), _audio_mem_pico])
	print("-- viajes (teleport): %s" % (("%d" % _viajes) if _viajes_medibles else "no medible (servicio ausente)"))

	if not _escena_ok:
		print("  [FALLO] la escena del juego no se instancio")
		_fallos += 1
	if _monitor == null:
		print("  [FALLO] MemoryMonitor de produccion no encontrado")
		_fallos += 1
	if _monitor != null and not hay_base:
		print("  [FALLO] sin baseline a los %.0f s" % _duracion_s)
		_fallos += 1
	if _monitor != null and not check:
		print("  [FALLO] drift_check() = false (limite %.1f%%)" % DRIFT_MAX_PCT)
		_fallos += 1
	if _n_muestras < MUESTRAS_MINIMAS and _duracion_s >= 1800.0:
		print("  [FALLO] solo %d muestras de %d" % [_n_muestras, MUESTRAS_MINIMAS])
		_fallos += 1
	if _cambios_efectivos < CAMBIOS_MINIMOS:
		print("  [FALLO] solo %d cambios de clima efectivos (minimo %d): el escenario no se ejecuto"
			% [_cambios_efectivos, CAMBIOS_MINIMOS])
		_fallos += 1
	if _climas_vistos.size() < CLIMAS_DISTINTOS_MIN:
		print("  [FALLO] solo %d climas distintos (minimo %d): 'clima cambiante' vacio"
			% [_climas_vistos.size(), CLIMAS_DISTINTOS_MIN])
		_fallos += 1
	if _buses_inicio >= 0 and _buses_fin > _buses_inicio:
		print("  [FALLO] buses de audio %d -> %d (fuga de buses)" % [_buses_inicio, _buses_fin])
		_fallos += 1
	if _players_inicio >= 0 and _players_fin > _players_inicio:
		print("  [FALLO] reproductores de audio %d -> %d (fuga de nodos)" % [_players_inicio, _players_fin])
		_fallos += 1
	if _audio_banco_mb > 0.0:
		if _monitor == null or not _monitor.has_method("avisar_cambio_bioma_audio"):
			print("  [FALLO] audio sintetico: falta MemoryMonitor.avisar_cambio_bioma_audio()")
			_fallos += 1
		if _audio_creados < _cambios_efectivos:
			print("  [FALLO] audio sintetico: %d bancos creados para %d climas efectivos"
				% [_audio_creados, _cambios_efectivos])
			_fallos += 1
		if not _audio_control_positivo:
			print("  [FALLO] audio sintetico: el banco no movio la memoria (control positivo < %.1f MB)"
				% AUDIO_CONTROL_MIN_MB)
			_fallos += 1
		if audio_vivos != 1:
			print("  [FALLO] audio sintetico: %d bancos vivos (se espera solo el actual)" % audio_vivos)
			_fallos += 1
		if audio_pendiente != null:
			print("  [FALLO] audio sintetico: quedo un banco PENDIENTE sin liberar")
			_fallos += 1
		if audio_actual == null:
			print("  [FALLO] audio sintetico: no quedo banco ACTUAL (audio cortado)")
			_fallos += 1
		else:
			var actual_id := audio_actual.get_instance_id()
			var coincide := false
			for r in _audio_refs:
				var o: RefCounted = r.get_ref()
				if o != null and o.get_instance_id() == actual_id:
					coincide = true
			if not coincide:
				print("  [FALLO] audio sintetico: el banco vivo no es el ACTUAL del monitor")
				_fallos += 1
	if _viajes_medibles and _viajes > 0:
		print("  [FALLO] hubo %d viajes: la condicion 'sin teleport' no se cumple" % _viajes)
		_fallos += 1

	var ruta := "user://sesion_m62_clima_30min.csv"
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_line("t_s;mem_mb;base_mb;hay_base;drift_pct;objetos;huerfanos;buses;players;audio_bancos")
		for linea in _muestras:
			f.store_line(linea)
		f.close()
		print("-- CSV: %s (abs: %s)" % [ruta, ProjectSettings.globalize_path(ruta)])

	print("=== Resumen %s: %d muestras, %d fallos ===" % [MODULO, _n_muestras, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO - salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK" % MODULO)
		quit(0)
