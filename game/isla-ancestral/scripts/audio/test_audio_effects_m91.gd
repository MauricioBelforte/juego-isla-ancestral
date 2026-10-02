# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M91: Test de rango dinámico + compresión + dispositivo de salida
# (los tres subsistemas NUEVOS de este lote). NO sustituye a
# test_audio_config.gd: esa suite (buses/volúmenes/persistencia M60) debe
# seguir en verde en paralelo.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/audio/test_audio_effects_m91.gd

extends SceneTree

# Piso de checks MEDIDO en verde (patrón M105) — no estimado.
# Medido 2026-10-02 con Godot 4.7.2 headless: 82 checks, 0 fallos.
const CHECKS_MINIMOS := 82

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _run() -> void:
	_test_regresion_buses()
	_test_rango_dinamico()
	_test_compresion()
	_test_dispositivo_salida()
	_limpieza()
	print("=== TEST M91 EFECTOS: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("[FAIL] checks ejecutados (%d) por debajo del piso (%d)" % [_checks, CHECKS_MINIMOS])
	quit(1 if (_fallos > 0 or _checks < CHECKS_MINIMOS) else 0)


## Regresión: los cambios de este lote no deben tocar la topología de buses.
func _test_regresion_buses() -> void:
	for bus in ["Master", "Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]:
		_check(AudioServer.get_bus_index(bus) != -1, "bus '%s' sigue existiendo" % bus)
	_check(AudioServer.bus_count == 7, "bus_count sigue en 7 (hay %d)" % AudioServer.bus_count)
	for nombre in ["Music", "SFX", "Ambient", "Voice", "UI", "Cinematic"]:
		var idx := AudioServer.get_bus_index(nombre)
		_check(AudioServer.get_bus_send(idx) == "Master", "'%s' sigue enrutado a Master" % nombre)


func _test_rango_dinamico() -> void:
	_check(DynamicRangeManager.RANGOS.size() == 3, "3 rangos definidos")
	_check(DynamicRangeManager.RANGOS.has("quiet"), "RANGOS contiene quiet")
	_check(DynamicRangeManager.RANGOS.has("dinamico"), "RANGOS contiene dinamico")

	# quiet -> compresión alta
	_check(DynamicRangeManager.aplicar("quiet"), "aplicar('quiet') OK")
	_check(DynamicRangeManager.compresion_activa(), "quiet deja compressor en Master")
	_check(DynamicRangeManager.actual() == "quiet", "actual()==quiet (got %s)" % DynamicRangeManager.actual())
	var p: Dictionary = DynamicRangeManager.PRESETS["quiet"]
	var comp := _compressor_master()
	_check(comp != null, "AudioEffectCompressor presente")
	if comp != null:
		_check(absf(comp.threshold - float(p["threshold"])) < 0.01, "quiet threshold -20 dB")
		_check(absf(comp.ratio - float(p["ratio"])) < 0.01, "quiet ratio 10")
		_check(comp.attack_us == int(p["attack_us"]), "quiet attack_us 5000")
		_check(absf(comp.release_ms - float(p["release_ms"])) < 0.01, "quiet release_ms 250")

	# medio -> compresión media
	_check(DynamicRangeManager.aplicar("medio"), "aplicar('medio') OK")
	_check(DynamicRangeManager.actual() == "medio", "actual()==medio")
	comp = _compressor_master()
	if comp != null:
		_check(absf(comp.threshold + 10.0) < 0.01, "medio threshold -10 dB")
		_check(absf(comp.ratio - 5.0) < 0.01, "medio ratio 5")

	# dinamico -> sin compresión
	_check(DynamicRangeManager.aplicar("dinamico"), "aplicar('dinamico') OK")
	_check(not DynamicRangeManager.compresion_activa(), "dinamico quita el compressor")
	_check(DynamicRangeManager.actual() == "dinamico", "actual()==dinamico")

	# entradas inválidas
	_check(not DynamicRangeManager.aplicar("no_existe"), "rango desconocido rechazado")
	_check(not DynamicRangeManager.aplicar("quiet", "BusInexistente"), "bus desconocido rechazado")

	# compresión manual (knobs libres)
	_check(DynamicRangeManager.aplicar_compresion_manual(-15.0, 7.0, 3000, 180.0),
		"aplicar_compresion_manual OK")
	_check(DynamicRangeManager.actual() == "custom", "manual da 'custom'")
	comp = _compressor_master()
	if comp != null:
		_check(absf(comp.threshold + 15.0) < 0.01, "manual threshold -15")
		_check(absf(comp.ratio - 7.0) < 0.01, "manual ratio 7")
		_check(comp.attack_us == 3000, "manual attack_us 3000")
		_check(absf(comp.release_ms - 180.0) < 0.01, "manual release_ms 180")

	_check(DynamicRangeManager.remover(), "remover() OK")
	_check(not DynamicRangeManager.compresion_activa(), "sin compresión tras remover")
	_check(not DynamicRangeManager.remover(), "remover() sin efecto devuelve false")
	_check(not DynamicRangeManager.remover("BusInexistente"), "remover() en bus malo false")


func _test_compresion() -> void:
	_check(not CompressionManager.activa(), "limiter ausente al arrancar el test")
	_check(CompressionManager.activar(), "activar() OK")
	_check(CompressionManager.activa(), "activa()==true")
	var q: Dictionary = CompressionManager.parametros()
	_check(q.size() == 4, "4 parámetros expuestos")
	_check(absf(float(q["threshold_db"]) - CompressionManager.THRESHOLD_DB_DEFECTO) < 0.01,
		"threshold_db default -3")
	_check(absf(float(q["ceiling_db"]) - CompressionManager.CEILING_DB_DEFECTO) < 0.01,
		"ceiling_db default 0")
	_check(absf(float(q["soft_clip_db"]) - CompressionManager.SOFT_CLIP_DB_DEFECTO) < 0.01,
		"soft_clip_db default -6")
	_check(absf(float(q["soft_clip_ratio"]) - CompressionManager.SOFT_CLIP_RATIO_DEFECTO) < 0.01,
		"soft_clip_ratio default 2")

	_check(CompressionManager.configurar(-10.0, -1.0, -4.0, 3.0), "configurar() OK")
	q = CompressionManager.parametros()
	_check(absf(float(q["threshold_db"]) + 10.0) < 0.01, "config threshold -10")
	_check(absf(float(q["ceiling_db"]) + 1.0) < 0.01, "config ceiling -1")
	_check(absf(float(q["soft_clip_db"]) + 4.0) < 0.01, "config soft_clip_db -4")
	_check(absf(float(q["soft_clip_ratio"]) - 3.0) < 0.01, "config soft_clip_ratio 3")

	_check(CompressionManager.desactivar(), "desactivar() OK")
	_check(not CompressionManager.activa(), "activa()==false tras desactivar")
	_check(CompressionManager.parametros().is_empty(), "parametros()=={} sin limiter")
	_check(not CompressionManager.desactivar(), "desactivar() sin efecto false")
	_check(not CompressionManager.activar("BusInexistente"), "activar() en bus malo false")
	_check(not CompressionManager.configurar(0.0, 0.0, 0.0, 0.0, "BusInexistente"),
		"configurar() en bus malo false")


func _test_dispositivo_salida() -> void:
	var lista := OutputDeviceManager.dispositivos()
	_check(lista is PackedStringArray, "dispositivos() devuelve PackedStringArray")
	_check(lista.size() > 0, "lista de dispositivos no vacía (Default siempre presente)")
	var actual := OutputDeviceManager.actual()
	_check(actual != "", "hay dispositivo activo")
	_check(lista.has(actual), "el activo pertenece a la lista")

	_check(OutputDeviceManager.seleccionar(actual), "seleccionar(actual) OK")
	_check(OutputDeviceManager.seleccionar("dispositivo_inexistente_xyz") == false,
		"dispositivo desconocido rechazado")
	_check(OutputDeviceManager.actual() == actual, "el desconocido no cambió el activo")

	var cats := OutputDeviceManager.categorias()
	_check(cats.size() == 5, "5 categorías definidas (got %d)" % cats.size())
	for c in ["predeterminado", "auriculares", "altavoces", "HDMI", "Bluetooth"]:
		_check(cats.has(c), "categoría '%s' definida" % c)
		_check(OutputDeviceManager.es_categoria(c), "es_categoria('%s')" % c)
	_check(not OutputDeviceManager.es_categoria("microfono_de_mesa"), "categoría desconocida false")


## Limpieza: el proceso termina igual, pero no dejamos efectos residuales.
func _limpieza() -> void:
	DynamicRangeManager.remover()
	CompressionManager.desactivar()


func _compressor_master() -> AudioEffectCompressor:
	var bidx := AudioServer.get_bus_index("Master")
	if bidx == -1:
		return null
	for i in AudioServer.get_bus_effect_count(bidx):
		var e := AudioServer.get_bus_effect(bidx, i)
		if e is AudioEffectCompressor:
			return e as AudioEffectCompressor
	return null
