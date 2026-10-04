# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
# Modificado: mimo-v2.6-flash-free / opencode — 2026-10-02 (lote 2: API de
#             porcentaje 0-100; lote 4: aplicación/control por bus.
#             Piso CHECKS_MINIMOS = 103 medido en verde)
#             2026-10-04 (BUG-092: persistencia de mutes, set_opcion(),
#             round-trip config/savegame, reaplicación de opciones y
#             restauración byte-exacto de config.cfg.
#             Piso CHECKS_MINIMOS = 136 medido en verde)
#
# M91: Test de AudioConfigService (buses, volúmenes linear→db, mute,
# persistencia M60 sección "audio", porcentaje 0-100 para sliders de M53,
# aplicación al bus propio + control independiente por familia de sonido).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/audio/test_audio_config.gd

extends SceneTree

## Piso de checks medido en verde (patrón M105): un suite que no llega al
## piso dejó de comprobar algo aunque reporte 0 fallos.
const CHECKS_MINIMOS: int = 136

var _fallos: int = 0
var _checks: int = 0
## Última opción emitida por opcion_cambiada (BUG-092)
var _ultima_opcion_emitida: Dictionary = {"clave": "", "valor": null}

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
	_test_bug092_persistencia_mutes_opciones()
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: piso de checks no alcanzado (%d < %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M91 AUDIO: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _on_opcion_cambiada(clave: String, valor: Variant) -> void:
	_ultima_opcion_emitida["clave"] = clave
	_ultima_opcion_emitida["valor"] = valor

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

func _test_bug092_persistencia_mutes_opciones() -> void:
	# BUG-092 (2026-10-04): mutes + opciones de secciones sin auto-save
	# (rango_dinamico/compresion/dispositivo_salida) persisten en config.cfg y se
	# re-aplican al arrancar. Round-trip config/savegame + restauración
	# byte-exacto de config.cfg al finalizar (patrón habitual de este chat).
	var ac := root.get_node_or_null("AudioConfig")
	var ds := root.get_node_or_null("DataStore")
	_check(ac != null, "AudioConfig presente (BUG-092)")
	_check(ds != null, "DataStore presente (BUG-092)")
	if ac == null or ds == null:
		return

	# Snapshot byte-exacto de config.cfg (se restaura al final del bloque)
	var ruta_cfg := GestorConfig.RUTA_CONFIG
	var snapshot := ""
	if FileAccess.file_exists(ruta_cfg):
		snapshot = FileAccess.get_file_as_string(ruta_cfg)

	# Estado base conocido (sin opciones persistidas ni efectos en Master)
	ac._opciones.clear()
	DynamicRangeManager.remover()
	CompressionManager.desactivar()
	ac.set_mute("SFX", false)

	# ── 1) set_mute persiste en config.cfg (el bug original) ──
	ac.set_mute("SFX", true)
	var audio1: Dictionary = ds.cargar_config().get("audio", {})
	var mutes1: Variant = audio1.get("mutes", {})
	_check(typeof(mutes1) == TYPE_DICTIONARY, "config.audio.mutes es Dictionary")
	_check(bool((mutes1 as Dictionary).get("SFX", false)),
		"set_mute(SFX,true) persistido en config.cfg")
	_check(ac.esta_muteado("SFX"), "mute activo en memoria")

	# ── 2) Round-trip de mutes: la recarga lo recupera ──
	ac._cargar_config()
	_check(ac.esta_muteado("SFX"), "mute SFX sobrevive a _cargar_config()")

	# ── 3) set_opcion(rango_dinamico): valida, persiste y emite señal ──
	ac.opcion_cambiada.connect(_on_opcion_cambiada)
	_check(ac.set_opcion("rango_dinamico", "quiet"), "set_opcion(rango_dinamico,quiet) OK")
	_check(_ultima_opcion_emitida["clave"] == "rango_dinamico",
		"señal opcion_cambiada emite la clave")
	_check(str(_ultima_opcion_emitida["valor"]) == "quiet",
		"señal opcion_cambiada emite el valor")
	_check(ac.get_opcion("rango_dinamico") == "quiet", "get_opcion refleja quiet")
	_check(DynamicRangeManager.actual() == "quiet", "compressor en preset quiet")
	var audio2: Dictionary = ds.cargar_config().get("audio", {})
	var opc2: Variant = audio2.get("opciones", {})
	_check(typeof(opc2) == TYPE_DICTIONARY, "config.audio.opciones es Dictionary")
	_check(str((opc2 as Dictionary).get("rango_dinamico", "")) == "quiet",
		"rango_dinamico persistido en config.cfg")
	ac.opcion_cambiada.disconnect(_on_opcion_cambiada)

	# ── 4) Reaplicación al arrancar (recarga → motor) ──
	ac._cargar_config()
	_check(ac.get_opcion("rango_dinamico") == "quiet", "opción sobrevive a la recarga")
	_check(DynamicRangeManager.actual() == "quiet",
		"opción REAPLICADA al motor tras la recarga")

	# ── 5) compresion: on/off persiste y reaplica ──
	_check(ac.set_opcion("compresion", true), "set_opcion(compresion,true) OK")
	_check(CompressionManager.activa(), "limiter activo tras set")
	ac._cargar_config()
	_check(CompressionManager.activa(), "compresion sobrevive a la recarga")
	_check(ac.set_opcion("compresion", false), "set_opcion(compresion,false) OK")
	_check(not CompressionManager.activa(), "limiter desactivado tras set")

	# ── 6) dispositivo_salida persiste (headless: solo 'Default' existe) ──
	_check(ac.set_opcion("dispositivo_salida", "Default"), "set_opcion(dispositivo_salida,Default) OK")
	_check(str(ac.get_opcion("dispositivo_salida")) == "Default", "get_opcion refleja Default")
	ac._cargar_config()
	_check(str(ac.get_opcion("dispositivo_salida")) == "Default",
		"dispositivo_salida sobrevive a la recarga")

	# ── 7) Validaciones: nada inválido persiste ──
	_check(not ac.set_opcion("no_existe", 1), "clave desconocida rechazada")
	_check(not ac.set_opcion("rango_dinamico", "inventado"), "rango inválido rechazado")
	_check(not ac.set_opcion("dispositivo_salida", "DispositivoFantasma"),
		"dispositivo inexistente rechazado")
	var audio3: Dictionary = ds.cargar_config().get("audio", {})
	var opc3: Variant = audio3.get("opciones", {})
	_check(not (opc3 as Dictionary).has("no_existe"), "clave desconocida NO persistida")

	# ── 8) Round-trip del save_data (provider de M59) ──
	var data: Dictionary = ac.get_save_data()
	_check(data.has("mutes"), "save_data trae mutes")
	_check(data.has("opciones"), "save_data trae opciones")
	_check(str((data.get("opciones", {}) as Dictionary).get("rango_dinamico", "")) == "quiet",
		"opciones serializadas en save_data")
	data["opciones"]["rango_dinamico"] = "medio"
	ac.restore_save_data(data)
	_check(ac.get_opcion("rango_dinamico") == "medio", "restore_save_data adopta opciones")
	_check(DynamicRangeManager.actual() == "medio", "restore_save_data reaplica al motor")

	# ── 9) Restauración: estado base + config.cfg byte-exacto ──
	ac._opciones.clear()
	DynamicRangeManager.remover()
	CompressionManager.desactivar()
	ac.set_mute("SFX", false)
	if snapshot == "":
		if FileAccess.file_exists(ruta_cfg):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta_cfg))
		_check(not FileAccess.file_exists(ruta_cfg),
			"config.cfg restaurado a su estado inicial (inexistente)")
	else:
		var f := FileAccess.open(ruta_cfg, FileAccess.WRITE)
		f.store_string(snapshot)
		f.close()
		_check(FileAccess.get_file_as_string(ruta_cfg) == snapshot,
			"config.cfg restaurado byte-exacto")
