# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
# Modificado: mimo-v2.6-flash-free / opencode — 2026-10-02 (lote 2: API de
#             porcentaje 0-100; lote 4: aplicación/control por bus.
#             Piso CHECKS_MINIMOS = 103 medido en verde)
#
# M91: Test de AudioConfigService (buses, volúmenes linear→db, mute,
# persistencia M60 sección "audio", porcentaje 0-100 para sliders de M53,
# aplicación al bus propio + control independiente por familia de sonido).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/audio/test_audio_config.gd

extends SceneTree

## Piso de checks medido en verde (patrón M105): un suite que no llega al
## piso dejó de comprobar algo aunque reporte 0 fallos.
const CHECKS_MINIMOS: int = 103

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_buses_creados()
	_test_volumenes_default()
	_test_set_volumen()
	_test_mute()
	_test_persistencia_m60()
	_test_coherencia_gestor()
	_test_porcentaje_0_100()
	_test_aplicacion_y_control_por_bus()
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: piso de checks no alcanzado (%d < %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M91 AUDIO: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _db_a_linear(db: float) -> float:
	return db_to_linear(db)

func _test_buses_creados() -> void:
	for bus in ["Master", "Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]:
		_check(AudioServer.get_bus_index(bus) != -1, "bus '%s' existe" % bus)
	# Enrutado al Master
	for nombre in ["Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]:
		var idx := AudioServer.get_bus_index(nombre)
		_check(AudioServer.get_bus_send(idx) == "Master", "bus '%s' enroutado a Master" % nombre)

func _test_volumenes_default() -> void:
	var ac := root.get_node_or_null("AudioConfig")
	_check(ac != null, "AudioConfig autoload presente")
	if ac == null:
		return
	_check(absf(ac.get_volumen("Music") - 0.7) < 0.01, "default Music 0.7 (diseño §3)")
	_check(absf(ac.get_volumen("UI") - 0.5) < 0.01, "default UI 0.5 (diseño §3)")
	# AudioServer refleja el default en db (linear_to_db)
	var idx := AudioServer.get_bus_index("Music")
	_check(absf(AudioServer.get_bus_volume_db(idx) - linear_to_db(0.7)) < 0.1, "Music aplicado en AudioServer (db)")

func _test_set_volumen() -> void:
	var ac := root.get_node_or_null("AudioConfig")
	_check(ac.set_volumen("Music", 0.3), "set_volumen Music 0.3 OK")
	_check(absf(ac.get_volumen("Music") - 0.3) < 0.01, "get_volumen refleja 0.3")
	var idx := AudioServer.get_bus_index("Music")
	_check(absf(AudioServer.get_bus_volume_db(idx) - linear_to_db(0.3)) < 0.1, "AudioServer db = linear_to_db(0.3)")
	# Volumen fuera de rango: clamp a [0,1]
	ac.set_volumen("Music", 1.5)
	_check(absf(ac.get_volumen("Music") - 1.0) < 0.01, "clamp superior a 1.0")
	ac.set_volumen("Music", -0.5)
	_check(absf(ac.get_volumen("Music")) < 0.01, "clamp inferior a 0.0")
	# Bus inexistente
	_check(not ac.set_volumen("BusInexistente", 0.5), "bus inexistente rechazado")

func _test_mute() -> void:
	var ac := root.get_node_or_null("AudioConfig")
	ac.set_mute("SFX", true)
	_check(ac.esta_muteado("SFX"), "mute activado")
	var idx := AudioServer.get_bus_index("SFX")
	_check(AudioServer.is_bus_mute(idx), "AudioServer refleja mute")
	ac.set_mute("SFX", false)
	_check(not ac.esta_muteado("SFX"), "mute desactivado")
	_check(not AudioServer.is_bus_mute(idx), "AudioServer refleja unmute")

func _test_persistencia_m60() -> void:
	var ac := root.get_node_or_null("AudioConfig")
	var ds := root.get_node_or_null("DataStore")
	_check(ds != null, "DataStore presente (M60)")
	if ds == null:
		return
	# set_volumen persiste automáticamente en GestorConfig sección "audio"
	ac.set_volumen("Music", 0.42)
	var config: Dictionary = ds.cargar_config()
	_check(absf(float(config.get("audio", {}).get("Music", 0)) - 0.42) < 0.01,
		"M60 persiste Music=0.42 (%s)" % str(config.get("audio", {}).get("Music")))
	# Round-trip del provider
	var data: Dictionary = ac.get_save_data()
	_check(data.has("volumenes"), "save_data tiene volumenes")
	_check(ac.get_section_name() == "audio_config", "sección 'audio_config'")
	ac.restore_save_data({})
	_check(absf(ac.get_volumen("Music") - 0.42) < 0.01, "restore vacío mantiene (M60 es la fuente)")
	# Volver a default cozy
	ac.set_volumen("Music", 0.7)

func _test_coherencia_gestor() -> void:
	# Los defaults del diseño §3 coherentes con GestorConfig DEFAULTS_BASE (M60)
	var ac := root.get_node_or_null("AudioConfig")
	if ac == null:
		return
	_check(absf(ac.get_volumen("Master") - 0.8) < 0.01, "Master default 0.8 (coherente M60)")
	_check(absf(ac.get_volumen("SFX") - 0.8) < 0.01, "SFX default 0.8 (coherente M60)")

func _test_porcentaje_0_100() -> void:
	# API de slider 0-100 para M53 (módulo 91, lote 2, 2026-10-02).
	# Cubre: defaults en %, conversión slider→dB (linear2db), round-trip,
	# clamp, bus inexistente y coherencia con el estado interno lineal 0-1.
	var ac := root.get_node_or_null("AudioConfig")
	_check(ac != null, "AudioConfig presente (API de porcentaje)")
	if ac == null:
		return

	var esperado := {"Master": 80.0, "Music": 70.0, "SFX": 80.0,
		"Ambient": 60.0, "Voice": 90.0, "UI": 50.0, "Cinematic": 80.0}

	# 1) Defaults del diseño §3 como porcentaje de slider (ítem "valores por defecto")
	for bus in esperado:
		_check(absf(ac.get_volumen_porcentaje(String(bus)) - float(esperado[bus])) < 0.6,
			"default %s = %d%%" % [bus, int(esperado[bus])])

	# 2) Conversión 0-100 → dB coherente con lo que AudioServer tiene aplicado
	for bus in esperado:
		var pct := float(esperado[bus])
		var idx := AudioServer.get_bus_index(String(bus))
		_check(absf(AudioServer.get_bus_volume_db(idx) - ac.porcentaje_a_db(pct)) < 0.6,
			"%s: %.0f%% -> %.2f dB coincide con AudioServer" % [bus, pct, ac.porcentaje_a_db(pct)])

	# 3) Round-trip porcentaje <-> lineal
	for pct in [0.0, 25.0, 50.0, 75.0, 100.0]:
		_check(absf(ac.lineal_a_porcentaje(ac.porcentaje_a_lineal(pct)) - pct) < 0.01,
			"round-trip %.0f%%" % pct)

	# 4) set/get porcentaje + coherencia con el estado interno lineal 0-1
	_check(ac.set_volumen_porcentaje("Music", 42.0), "set_volumen_porcentaje Music 42 OK")
	_check(absf(ac.get_volumen_porcentaje("Music") - 42.0) < 0.1, "get_volumen_porcentaje refleja 42%")
	_check(absf(ac.get_volumen("Music") - 0.42) < 0.005, "estado interno lineal 0.42")
	var idx_m := AudioServer.get_bus_index("Music")
	_check(absf(AudioServer.get_bus_volume_db(idx_m) - ac.porcentaje_a_db(42.0)) < 0.1,
		"AudioServer en dB = conversión de 42%")

	# 5) Clamp fuera de rango (sliders torcidos / redondeos de UI)
	ac.set_volumen_porcentaje("Music", 150.0)
	_check(absf(ac.get_volumen_porcentaje("Music") - 100.0) < 0.1, "clamp 150% -> 100%")
	ac.set_volumen_porcentaje("Music", -20.0)
	_check(absf(ac.get_volumen_porcentaje("Music")) < 0.1, "clamp -20% -> 0%")

	# 6) Bus inexistente devuelve false (igual que set_volumen)
	_check(not ac.set_volumen_porcentaje("NoExiste", 50.0), "bus inexistente -> false")

	# 7) Pisos de la conversión a dB
	_check(absf(ac.porcentaje_a_db(100.0) - 0.0) < 0.01, "100% = 0 dB")
	_check(ac.porcentaje_a_db(0.0) <= -79.0, "0% = piso -80 dB")
	_check(absf(ac.porcentaje_a_db(50.0) - linear_to_db(0.5)) < 0.01, "50% = linear_to_db(0.5)")
	_check(absf(ac.db_a_porcentaje(0.0) - 100.0) < 0.1, "0 dB -> 100% (inversa)")

	# 8) Restaurar default cozy (no dejar estado sucio a otros tests)
	ac.set_volumen_porcentaje("Music", 70.0)
	_check(absf(ac.get_volumen_porcentaje("Music") - 70.0) < 0.6, "Music restaurado a 70%")

func _test_aplicacion_y_control_por_bus() -> void:
	# Lote 4 (mimo-v2.6-flash-free, 2026-10-02): 11 ítems del checklist —
	# "aplicación al bus de X" (Música, Efectos, Ambiente, Voces, UI,
	# Cinemáticas) y "control de X". Por cada bus hijo: set_volumen_porcentaje()
	# llega al volume_db DE ESA instancia, el estado interno lineal lo sigue, y
	# ningún otro bus se mueve (control independiente por familia de sonido).
	var ac := root.get_node_or_null("AudioConfig")
	_check(ac != null, "AudioConfig presente (aplicación/control por bus)")
	if ac == null:
		return

	var defaults := {"Master": 80.0, "Music": 70.0, "SFX": 80.0,
		"Ambient": 60.0, "Voice": 90.0, "UI": 50.0, "Cinematic": 80.0}
	var hijos: Array[String] = ["Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]

	# 1) "aplicación al bus de X": el set golpea el volume_db del bus propio
	for bus in hijos:
		var idx := AudioServer.get_bus_index(bus)
		_check(idx != -1, "bus '%s' existe para aplicar" % bus)
		var pct := minf(float(defaults[bus]) + 13.0, 99.0)
		_check(ac.set_volumen_porcentaje(bus, pct), "%s: set a %.0f%% OK" % [bus, pct])
		_check(absf(AudioServer.get_bus_volume_db(idx) - ac.porcentaje_a_db(pct)) < 0.15,
			"%s: volume_db propio = %.2f dB (esperado %.2f)" % [bus,
			AudioServer.get_bus_volume_db(idx), ac.porcentaje_a_db(pct)])
		_check(absf(ac.get_volumen(bus) - ac.porcentaje_a_lineal(pct)) < 0.005,
			"%s: estado interno lineal = %.4f" % [bus, ac.get_volumen(bus)])

	# 2) Master aplica igual (bus padre, índice 0)
	var idx_mast := AudioServer.get_bus_index("Master")
	_check(ac.set_volumen_porcentaje("Master", 61.0), "Master: set a 61% OK")
	_check(absf(AudioServer.get_bus_volume_db(idx_mast) - ac.porcentaje_a_db(61.0)) < 0.15,
		"Master: volume_db propio aplicado (%.2f dB)" % AudioServer.get_bus_volume_db(idx_mast))

	# 3) "control de X": canal independiente — mover UN bus no mueve a los demás
	var snap := {}
	for bus in hijos:
		snap[bus] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
	_check(ac.set_volumen_porcentaje("Music", 11.0), "Music: control independiente a 11%")
	_check(absf(ac.get_volumen_porcentaje("Music") - 11.0) < 0.1, "Music: get refleja 11%")
	for bus in hijos:
		if bus == "Music":
			continue
		_check(absf(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
			- float(snap[bus])) < 0.01, "%s: intacto al mover Music" % bus)

	# 4) Mute por canal tampoco contamina a los demás
	ac.set_mute("UI", true)
	_check(AudioServer.is_bus_mute(AudioServer.get_bus_index("UI")), "mute de UI aplicado")
	_check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("Voice")), "Voice no muteado por UI")
	ac.set_mute("UI", false)

	# 5) Restaurar defaults (no dejar estado sucio a otros tests)
	for bus in defaults:
		ac.set_volumen_porcentaje(String(bus), float(defaults[bus]))
	_check(absf(ac.get_volumen_porcentaje("Music") - 70.0) < 0.6, "defaults restaurados (Music 70%)")
