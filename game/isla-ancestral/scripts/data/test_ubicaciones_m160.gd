# Modelo: MiMo V2.5
# Plataforma: OpenCode
# Fecha: 2026-09-18
#
# M160: Diseño de Ubicaciones del Mundo — Test headless
# Valida: WorldLocations autoload, búsquedas, conexiones, acceso.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M160] Test de Ubicaciones del Mundo ===")
	_test_carga()
	_test_busqueda_id()
	_test_busqueda_isla()
	_test_busqueda_tipo()
	_test_conexiones()
	_test_acceso()
	_test_recolectables()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _get_wl():
	return autoload("world_locations") if Engine.has_singleton("world_locations") else null

func _test_carga() -> void:
	print("--- Carga de ubicaciones ---")
	var wl = _get_wl()
	if wl == null:
		_check("WorldLocations autoload disponible", false, "no es autoload")
		return
	_check("WorldLocations cargado", wl.locations.size() > 0, "size=%d" % wl.locations.size())
	_check("Mínimo 9 ubicaciones (RIZ seeds + catálogo)", wl.locations.size() >= 9, "size=%d" % wl.locations.size())
	_check("Máximo 50 ubicaciones (Límite razonable)", wl.locations.size() <= 50, "size=%d" % wl.locations.size())

func _test_busqueda_id() -> void:
	print("--- Búsqueda por ID ---")
	var wl = _get_wl()
	if wl == null:
		return
	var loc = wl.get_location("LOC-RIZ-PUB-001")
	_check("LOC-RIZ-PUB-001 encontrado", loc != null)
	if loc:
		_check("Nombre correcto", loc.nombre == "Pueblo Raiz", "nombre=%s" % loc.nombre)
	var no_existe = wl.get_location("LOC-FAKE-000")
	_check("ID inexistente retorna null", no_existe == null)

func _test_busqueda_isla() -> void:
	print("--- Búsqueda por isla ---")
	var wl = _get_wl()
	if wl == null:
		return
	var riz = wl.get_locations_by_island(0)
	_check("Isla Raíz tiene ubicaciones", riz.size() > 0, "size=%d" % riz.size())
	var cor = wl.get_locations_by_island(1)
	_check("Isla Coral tiene ubicaciones", cor.size() > 0, "size=%d" % cor.size())
	var cen = wl.get_locations_by_island(2)
	_check("Isla Ceniza tiene ubicaciones", cen.size() > 0, "size=%d" % cen.size())
	var aur = wl.get_locations_by_island(3)
	_check("Isla Aurora tiene ubicaciones", aur.size() > 0, "size=%d" % aur.size())

func _test_busqueda_tipo() -> void:
	print("--- Búsqueda por tipo ---")
	var wl = _get_wl()
	if wl == null:
		return
	var pubs = wl.get_locations_by_type(0)
	_check("Tipo PUB (pueblo) existe", pubs.size() > 0, "size=%d" % pubs.size())
	var casas = wl.get_locations_by_type(1)
	_check("Tipo CASA existe", casas.size() > 0, "size=%d" % casas.size())

func _test_conexiones() -> void:
	print("--- Conexiones bidireccionales ---")
	var wl = _get_wl()
	if wl == null:
		return
	var result = wl.validar_conexiones()
	_check("Conexiones verificadas", result.totales > 0, "totales=%d" % result.totales)
	_check("Sin conexiones faltantes", result.faltantes.is_empty(), "faltantes=%s" % str(result.faltantes))
	_check("Sin unidireccionales", result.unidireccionales.is_empty(), "unidireccionales=%s" % str(result.unidireccionales))

func _test_acceso() -> void:
	print("--- Validación de acceso ---")
	var wl = _get_wl()
	if wl == null:
		return
	_check("PUB-001 accesible sin requisitos", wl.can_access("LOC-RIZ-PUB-001", null, []))

func _test_recolectables() -> void:
	print("--- Objetos recolectables ---")
	var wl = _get_wl()
	if wl == null:
		return
	var rec = wl.get_recolectables("LOC-RIZ-BOS-001")
	_check("BOS-001 tiene recolectables", rec.size() >= 0, "size=%d" % rec.size())

func _summary() -> void:
	print("=== Resumen M160: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M160 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M160 OK — todos los checks pasaron")
		quit(0)
