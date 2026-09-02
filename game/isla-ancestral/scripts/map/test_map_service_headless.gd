# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: Test headless del MapDataService + MapSchema (RF3/RF5/RF6).
extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _run() -> void:
	print("=== [M54] Test del servicio de mapa ===")
	var schema = load("res://scripts/map/map_schema.gd")
	var datos = load("res://scripts/map/map_data_service.gd").new()
	root.add_child(datos)
	await process_frame
	# Schema de datos
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/map/map_data.json"))
	_check("Schema: 9 POIs válidos", schema.validar_pois(config).is_empty())
	# Service
	_check("Service: POIs cargados (9)", datos.pois().size() == 9)
	_check("Service: categoria templo", datos.pois_por_categoria("templo").size() >= 1)
	_check("Service: dentro de la isla (256,256)", datos.dentro_de_isla(256, 256))
	_check("Service: fuera de la isla (999,999)", not datos.dentro_de_isla(999, 999))
	# Niebla RF5
	datos.marcar_region_visitada("centro")
	_check("RF5: región visitada", datos.region_visitada("centro"))
	_check("RF5: región sin visitar", not datos.region_visitada("lejos"))
	var antes = datos._celdas_vistas.size()
	datos.marcar_celda_vista("c1")
	datos.marcar_celda_vista("c1")
	_check("RF5: celda vista única", datos._celdas_vistas.size() == antes + 1)
	_check("RF5: porcentaje esperado (celdas/100)", absf(datos.porcentaje_explorado(100) - float(datos._celdas_vistas.size()) / 100.0) < 0.001)
	# Pines RF6
	var senal := [0]
	datos.pines_modificados.connect(_on_pines.bind(senal))
	datos.add_pin(256.0, 256.0, "cave pintoresca")
	datos.add_pin(300.0, 300.0)
	_check("RF6: 2 pines añadidos", datos.pines().size() == 2)
	_check("RF6: señal pines", senal[0] == 2)
	datos.remove_pin(0)
	_check("RF6: 1 pin tras remove", datos.pines().size() == 1)
	datos.free()
	print("=== Resumen M54: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _on_pines(cantidad: int, contenedor: Array) -> void:
	contenedor[0] = cantidad
