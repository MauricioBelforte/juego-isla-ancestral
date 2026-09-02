# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: Mapa — Test de MapaBusqueda.
# Exit code != 0 si falla.

extends SceneTree

const _SC_BUSQ := preload("res://scripts/mapa/mapa_busqueda.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M54] Test de MapaBusqueda ===")
	var bq = _SC_BUSQ.new()
	bq.cargar()
	_test_busqueda(bq)
	_test_conteo(bq)
	_test_islas(bq)
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_busqueda(bq) -> void:
	print("--- Búsqueda por nombre/tipo ---")
	var templos = bq.buscar_por_nombre("templo")
	_check("templos = 3", templos.size() == 3, "size=%d" % templos.size())
	var faro = bq.buscar_por_nombre("faro")
	_check("faro = 1", faro.size() == 1, "size=%d" % faro.size())
	var nada = bq.buscar_por_nombre("xyz")
	_check("sin resultados -> vacío", nada.is_empty())

func _test_conteo(bq) -> void:
	print("--- Conteo por tipo ---")
	_check("lugar = 3", bq.contar_por_tipo("lugar") == 3, "n=%d" % bq.contar_por_tipo("lugar"))
	_check("templo = 3", bq.contar_por_tipo("templo") == 3, "n=%d" % bq.contar_por_tipo("templo"))
	_check("tienda = 0 (sin datos)", bq.contar_por_tipo("tienda") == 0)

func _test_islas(bq) -> void:
	print("--- IDs por isla ---")
	var raiz = bq.ids_por_isla("raiz")
	_check("raiz 2 ids", raiz.size() == 2, "size=%d" % raiz.size())
	_check("faro en raiz", "faro" in raiz)
	_check("isla inexistente -> vacío", bq.ids_por_isla("no").is_empty())

func _summary() -> void:
	print("=== Resumen M54-Busqueda: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		quit(1)
	else:
		print("TEST OK — todos los checks pasaron")
		quit(0)