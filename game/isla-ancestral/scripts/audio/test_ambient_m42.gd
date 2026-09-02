# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M42: Sonido Ambiental — Test headless
# Valida: AmbientDirector (set_bioma, capas, clima, señal ambiente_cambiado,
# banco con 13 biomas sin huecos). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M42] Test de Sonido Ambiental ===")
	_test_banco()
	_test_director()
	_test_clima()
	_test_ducking()
	_test_pausa()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_banco() -> void:
	print("--- Banco: 13 biomas sin huecos ---")
	var ad := root.get_node_or_null("AmbientDirector")
	if ad == null:
		_check("AmbientDirector autoload presente", false)
		_summary()
		quit(1)
		return
	_check("AmbientDirector autoload presente", true)
	_check("banco con 13 biomas", ad.banco.size() == 13, "size=%d" % ad.banco.size())
	for bioma in ad.banco:
		var capas: Array = ad.banco[bioma].get("capas", [])
		if capas.is_empty():
			_check("bioma %s sin capas (hueco)" % bioma, false)
	_check("todos los biomas con capas", true)

func _test_director() -> void:
	print("--- AmbientDirector: set_bioma ---")
	var ad := root.get_node_or_null("AmbientDirector")
	var cambios: Array = []
	ad.ambiente_cambiado.connect(func(b, c): cambios.append([b, c]))
	ad.set_bioma("playa")
	_check("bioma playa aplicado", ad.bioma_actual == "playa")
	_check("señal emitida (playa)", cambios.size() >= 1 and cambios[0][0] == "playa")
	_check("capas de playa incluyen olas", "olas" in cambios[0][1], "capas=%s" % str(cambios[0][1]))
	ad.set_bioma("no_existe")
	_check("bioma inexistente no cambia", ad.bioma_actual == "playa")

func _test_clima() -> void:
	print("--- AmbientDirector: capas de clima ---")
	var ad := root.get_node_or_null("AmbientDirector")
	var cambios: Array = []
	ad.ambiente_cambiado.connect(func(b, c): cambios.append(c))
	ad.set_bioma("playa")
	ad.set_estado_clima(2, 0.5)
	_check("clima agrega capa lluvia_suave", cambios.size() >= 2 and "lluvia_suave" in cambios[cambios.size()-1], "capas=%s" % str(cambios[cambios.size()-1]))
	ad.set_bioma("cueva")
	ad.set_estado_clima(2, 0.5)
	_check("cueva con lluvia -> goteo_intenso", cambios.size() >= 4 and "goteo_intenso" in cambios[cambios.size()-1])

func _test_ducking() -> void:
	print("--- AmbientDirector: ducking ---")
	var ad := root.get_node_or_null("AmbientDirector")
	ad.set_bioma("playa")
	ad.set_ducking(true)
	_check("esta_ducking true", ad.esta_ducking())
	var capa0: AudioStreamPlayer = ad.get_node("Layer_0")
	_check("capa 0 baja -6 dB al ducking", is_equal_approx(capa0.volume_db, -6.0), "db=%f" % capa0.volume_db)
	ad.set_ducking(false)
	_check("capa 0 vuelve a 0 dB", is_equal_approx(capa0.volume_db, 0.0), "db=%f" % capa0.volume_db)

func _test_pausa() -> void:
	print("--- AmbientDirector: pausa ---")
	var ad := root.get_node_or_null("AmbientDirector")
	ad.set_bioma("bosque")
	ad.pausar()
	_check("esta_pausado true", ad.esta_pausado())
	ad.reanudar()
	_check("esta_pausado false", not ad.esta_pausado())

func _summary() -> void:
	print("=== Resumen M42: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M42 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M42 OK — todos los checks pasaron")
		quit(0)