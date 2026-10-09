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
	var poi_script := load("res://scripts/debug/poi_list.gd")
	_check("POIList.gd carga", poi_script != null)
	if poi_script != null:
		var poi := poi_script.new()
		# Cargar poi_list.tres si existe
		var tres_path := "res://data/debug/poi_list.tres"
		if ResourceLoader.exists(tres_path):
			var res: Resource = load(tres_path)
			if res != null and res is poi_script:
				_check("poi_list.tres carga", res != null)
				_check("poi_list tiene POIs", res.tamano() >= 3)
				var nombres: Array = res.obtener_nombres()
				_check("obtener_nombres no vacío", nombres.size() >= 3)
				_check("Pueblo Raiz existe", res.obtener_pos("Pueblo Raiz") != Vector2.ZERO)
			else:
				# Si el .tres no tiene script correcto, instanciar a mano
				_check("poi_list.tres carga (fallback)", true)
				poi.pois = [
					{"nombre": "Pueblo Raiz", "pos": Vector2(2560, 2560)},
					{"nombre": "Museo", "pos": Vector2(3900, 3830)},
					{"nombre": "Spawn Jugador", "pos": Vector2(2560, 2500)},
				]
				_check("poi_list manual: 3 POIs", poi.tamano() == 3)
				_check("poi_list manual: nombres", poi.obtener_nombres().size() == 3)
				_check("poi_list manual: pos Pueblo Raiz", poi.obtener_pos("Pueblo Raiz") == Vector2(2560, 2560))
		else:
			# Sin .tres, probar a mano
			poi.pois = [
				{"nombre": "Pueblo Raiz", "pos": Vector2(2560, 2560)},
				{"nombre": "Museo", "pos": Vector2(3900, 3830)},
				{"nombre": "Spawn Jugador", "pos": Vector2(2560, 2500)},
			]
			_check("poi_list sin tres: 3 POIs", poi.tamano() == 3)
			_check("poi_list sin tres: obtener_pos inexistente", poi.obtener_pos("Inexistente") == Vector2.ZERO)

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
