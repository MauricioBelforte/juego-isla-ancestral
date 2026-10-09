# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI: Test headless de DebugVisualizer + POIList.
extends SceneTree

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	print("=== TEST M110-UI: DebugVisualizer + POIList ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# 1. DebugVisualizer se instancia
	var vis_script: Script = load("res://scripts/debug/debug_visualizer.gd")
	_check("DebugVisualizer.gd carga", vis_script != null)
	if vis_script == null:
		_resumen(); return
	var vis: Node3D = vis_script.new()
	_check("DebugVisualizer instancia", vis is Node3D)

	# 2. Obtener estado inicial (todo inactivo)
	var estado: Dictionary = vis.obtener_estado()
	_check("5 toggles definidos", estado.size() == 5)
	_check("colliders inactivo por defecto", estado.get("colliders") == false)
	_check("chunks inactivo por defecto", estado.get("chunks") == false)

	# 3. Configurar manualmente
	vis.configurar_manual("colliders", true)
	vis.configurar_manual("chunks", true)
	estado = vis.obtener_estado()
	_check("colliders activo tras configurar_manual", estado.get("colliders") == true)
	_check("chunks activo tras configurar_manual", estado.get("chunks") == true)

	# 4. Inactivar
	vis.configurar_manual("colliders", false)
	estado = vis.obtener_estado()
	_check("colliders inactivo tras desactivar", estado.get("colliders") == false)

	# 5. POIList
	var poi_script: Script = load("res://scripts/debug/poi_list.gd")
	_check("POIList.gd carga", poi_script != null)
	if poi_script != null:
		var poi: Resource = poi_script.new()
		# Probar a mano (sin depender del .tres en headless)
		poi.pois = [
			{"nombre": "Pueblo Raiz", "pos": Vector2(2560, 2560)},
			{"nombre": "Museo", "pos": Vector2(3900, 3830)},
			{"nombre": "Spawn Jugador", "pos": Vector2(2560, 2500)},
		]
		_check("poi_list: 3 POIs", poi.tamano() == 3)
		var nombres: Array = poi.obtener_nombres()
		_check("poi_list: obtener_nombres no vacío", nombres.size() == 3)
		_check("poi_list: pos Pueblo Raiz", poi.obtener_pos("Pueblo Raiz") == Vector2(2560, 2560))
		_check("poi_list: pos inexistente = ZERO", poi.obtener_pos("Inexistente") == Vector2.ZERO)
		# Verificar que poi_list.tres existe en disco
		_check("poi_list.tres existe en disco", FileAccess.file_exists("res://data/debug/poi_list.tres"))

	# 6. Límites de radio
	_check("MAX_CHUNKS_RADIO = 5.0", vis_script.MAX_CHUNKS_RADIO == 5.0)
	_check("MAX_NAVIGATION_RADIO = 50.0", vis_script.MAX_NAVIGATION_RADIO == 50.0)
	_check("MAX_AI_STATES_RADIO = 50.0", vis_script.MAX_AI_STATES_RADIO == 50.0)

	_resumen()

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _resumen() -> void:
	print("=== Resumen M110-UI: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("M110-UI OK"); quit(0)
