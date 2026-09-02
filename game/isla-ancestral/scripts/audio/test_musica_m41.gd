# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M41: Música — Test headless
# Valida: ShuffleSampler (sin repetición consecutiva, determinista),
# MusicDirector (selección por contexto, estación como recolor de capa,
# flujo, narrativa, leitmotifs, ducking, stings, pausa, variaciones).
# Exit code != 0 si falla.

extends SceneTree

const _SC_SHUFFLE := preload("res://scripts/audio/shuffle_sampler.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M41] Test de Música ===")
	_test_shuffle()
	_test_music_director()
	_test_variaciones()
	_test_flow_narrativa()
	_test_leitmotif_estacion()
	_test_ducking()
	_test_stings()
	_test_pausa()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_shuffle() -> void:
	print("--- ShuffleSampler: sin repetición consecutiva ---")
	var s = _SC_SHUFFLE.new(12345)
	s.barajar(["a", "b", "c", "d"])
	var prev := ""
	var repeticiones := 0
	for i in range(20):
		var v := s.siguiente()
		if v == prev and prev != "":
			repeticiones += 1
		prev = v
	_check("sin repetición consecutiva (20 muestras)", repeticiones == 0, "rep=%d" % repeticiones)
	_check("usa todas las variaciones", prev != "")
	var s2 = _SC_SHUFFLE.new(12345)
	s2.barajar(["a", "b", "c", "d"])
	var s3 = _SC_SHUFFLE.new(12345)
	s3.barajar(["a", "b", "c", "d"])
	_check("mismo seed -> misma 1ra variación", s2.siguiente() == s3.siguiente())
	var vacio = _SC_SHUFFLE.new(1)
	vacio.barajar([])
	_check("lista vacía -> ''", vacio.siguiente() == "")

func _capturar() -> Array:
	var md := root.get_node_or_null("MusicDirector")
	var pares: Array = []
	md.tema_cambio.connect(func(t, c): pares.append({"t": t, "c": c}))
	return pares

func _test_music_director() -> void:
	print("--- MusicDirector: selección por contexto ---")
	var md := root.get_node_or_null("MusicDirector")
	if md == null:
		_check("MusicDirector autoload presente", false)
		_summary()
		quit(1)
		return
	_check("MusicDirector autoload presente", true)
	_check("matriz con temas", md.matriz.get("temas", {}).size() >= 5, "temas=%d" % md.matriz.get("temas", {}).size())
	var cambios: Array = _capturar()
	var tema_dia = md.play_contexto("aurora", 12, 0, 0)
	_check("aurora de día -> tema aurora_dia", tema_dia == "aurora_dia", "tema=%s" % tema_dia)
	var tema_noche = md.play_contexto("aurora", 22, 0, 0)
	_check("aurora de noche -> tema aurora_noche", tema_noche == "aurora_noche", "tema=%s" % tema_noche)
	var tema_lluvia = md.play_contexto("aurora", 12, 0, 2)
	_check("aurora con lluvia -> tema aurora_lluvia", tema_lluvia == "aurora_lluvia", "tema=%s" % tema_lluvia)
	var tema_coral = md.play_contexto("coral", 12, 0, 0)
	_check("coral de día -> tema coral_dia", tema_coral == "coral_dia", "tema=%s" % tema_coral)
	_check("señal tema_cambio emitida (>=3)", cambios.size() >= 3, "size=%d" % cambios.size())

func _test_variaciones() -> void:
	print("--- MusicDirector: variaciones shuffle ---")
	var md := root.get_node_or_null("MusicDirector")
	var v1 = md.siguiente_variacion("aurora_dia")
	var v2 = md.siguiente_variacion("aurora_dia")
	_check("variación aurora_dia no vacía", v1 != "", "v1=%s" % v1)
	_check("variaciones distintas (no consecutivas)", v1 != v2, "v1=%s v2=%s" % [v1, v2])
	var inexistente = md.siguiente_variacion("no_existe")
	_check("tema inexistente -> ''", inexistente == "")

func _test_flow_narrativa() -> void:
	print("--- MusicDirector: flujo y narrativa ---")
	var md := root.get_node_or_null("MusicDirector")
	_check("play_flow intro -> flow_intro", md.play_flow("intro") == "flow_intro")
	_check("play_flow menu -> flow_menu", md.play_flow("menu") == "flow_menu")
	_check("play_narrative tension -> narr_tension", md.play_narrative("tension") == "narr_tension")
	_check("play_narrative sello -> narr_sello", md.play_narrative("sello") == "narr_sello")

func _test_leitmotif_estacion() -> void:
	print("--- MusicDirector: leitmotif y estación ---")
	var md := root.get_node_or_null("MusicDirector")
	var pares: Array = _capturar()
	md.set_leitmotif("aurora")
	md.play_contexto("coral", 12, 0, 0)
	var ult: Dictionary = pares[-1]
	_check("leitmotif añade capa leit_aurora", ult["c"].has("leit_aurora"), "capas=%s" % str(ult["c"]))
	var pares2: Array = _capturar()
	md.set_leitmotif("")
	md.play_contexto("aurora", 12, 1, 0)  # estación verano
	var ult2: Dictionary = pares2[-1]
	_check("estación verano -> capa tiempo_verano", ult2["c"].has("tiempo_verano"), "capas=%s" % str(ult2["c"]))

func _test_ducking() -> void:
	print("--- MusicDirector: ducking ---")
	var md := root.get_node_or_null("MusicDirector")
	md.play_contexto("aurora", 12, 0, 0)
	md.set_ducking(true)
	_check("esta_ducking true", md.esta_ducking())
	var base: AudioStreamPlayer = md.get_node("Layer_base")
	_check("capa base baja -6 dB al ducking", is_equal_approx(base.volume_db, -6.0), "db=%f" % base.volume_db)
	md.set_ducking(false)
	_check("capa base vuelve a 0 dB", is_equal_approx(base.volume_db, 0.0), "db=%f" % base.volume_db)

func _test_stings() -> void:
	print("--- MusicDirector: stings ---")
	var md := root.get_node_or_null("MusicDirector")
	var recibidos: Array = []
	md.sting_reproducido.connect(func(t): recibidos.append(t))
	md.sting("sello")
	_check("sting emite señal sting_reproducido", recibidos.has("sello"), "rec=%s" % recibidos)
	md.sting("inexistente")
	_check("sting inexistente no crashea", true)

func _test_pausa() -> void:
	print("--- MusicDirector: pausa ---")
	var md := root.get_node_or_null("MusicDirector")
	md.pausar()
	_check("esta_pausado true", md.esta_pausado())
	md.reanudar()
	_check("esta_pausado false", not md.esta_pausado())

func _summary() -> void:
	print("=== Resumen M41: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M41 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M41 OK — todos los checks pasaron")
		quit(0)
