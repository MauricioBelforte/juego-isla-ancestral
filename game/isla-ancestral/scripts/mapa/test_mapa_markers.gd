# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: Mapa — Test de MapaMarkers (clusterización, POI, capas).
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_MARKERS := preload("res://scripts/mapa/mapa_markers.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M54] Test de MapaMarkers ===")
	var mk = _SC_MARKERS.new()
	mk.cargar()
	_test_carga(mk)
	_test_busqueda(mk)
	_test_cluster(mk)
	_test_capas(mk)
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_carga(mk) -> void:
	print("--- Carga de marcadores ---")
	_check("6 marcadores", mk.marcadores().size() == 6, "size=%d" % mk.marcadores().size())

func _test_busqueda(mk) -> void:
	print("--- Búsqueda de POIs ---")
	var templos = mk.buscar_poi("templo")
	_check("búsqueda 'templo' (3)", templos.size() == 3, "size=%d" % templos.size())
	var faro = mk.buscar_poi("faro")
	_check("búsqueda 'faro' (1)", faro.size() == 1, "size=%d" % faro.size())
	var vacio = mk.buscar_poi("xyz")
	_check("búsqueda sin resultado", vacio.is_empty())

func _test_cluster(mk) -> void:
	print("--- Clusterización ---")
	var clusters = mk.clusterizar()
	_check("clusters generados", clusters.size() >= 1, "size=%d" % clusters.size())
	var total_ids := 0
	for c in clusters:
		total_ids += int(c.get("count", 0))
	_check("total ids en clusters = 6", total_ids == 6, "total=%d" % total_ids)
	_check("cluster con centro Vector3", (clusters[0] as Dictionary).get("centro", null) is Vector3)

func _test_capas(mk) -> void:
	print("--- Capas de exploración ---")
	var explorados := {"faro": true, "puerto_coral": true, "volcan_ceniza": true}
	var capas = mk.separar_por_exploracion(explorados)
	_check("3 visibles", (capas.get("visibles", []) as Array).size() == 3, "size=%d" % (capas.get("visibles", []) as Array).size())
	_check("3 ocultos", (capas.get("ocultos", []) as Array).size() == 3, "size=%d" % (capas.get("ocultos", []) as Array).size())

func _summary() -> void:
	print("=== Resumen M54-Markers: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST OK — todos los checks pasaron")
		quit(0)