# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M91: Test de AudioConfigService (buses, volúmenes linear→db, mute,
# persistencia M60 sección "audio").
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/audio/test_audio_config.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_buses_creados()
	_test_volumenes_default()
	_test_set_volumen()
	_test_mute()
	_test_persistencia_m60()
	_test_coherencia_gestor()
	print("=== TEST M91 AUDIO: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
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
