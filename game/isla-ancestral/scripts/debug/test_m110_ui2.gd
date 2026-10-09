# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI slice 2: Test headless de DebugConsole + paneles UI.
# Receta: _fin() por bloque + CHECKS_MINIMOS + _summary() diferido con SceneTree.create_timer.
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 12

func _initialize() -> void:
	print("=== TEST M110-UI 2: DebugConsole + Paneles ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# ── Bloque 1: DebugConsole ──
	var cons_script: Script = load("res://scripts/debug/debug_console.gd")
	_check("DebugConsole.gd carga", cons_script != null)
	if cons_script != null:
		var cons: Control = cons_script.new()
		_check("DebugConsole instancia (Control)", cons is Control)
		_check("DebugConsole backend no conectado (headless)", cons.backend_conectado() == false)
		cons._agregar_linea("Linea 1")
		cons._agregar_linea("Linea 2")
		cons._agregar_linea("Linea 3")
		_check("DebugConsole 3 lineas", cons.tamano() == 3)
		var lineas: Array = cons.obtener_lineas()
		_check("DebugConsole obtener_lineas", lineas.size() == 3)
		_check("DebugConsole linea 1 correcta", lineas[0] == "Linea 1")
		cons.limpiar()
		_check("DebugConsole limpiar", cons.tamano() == 0)
		# Límite de 100 líneas
		for i in range(105):
			cons._agregar_linea("L%d" % i)
		_check("DebugConsole max 100 lineas", cons.tamano() == 100)

	# ── Bloque 2: DebugVisualizer (ya en slice 1, re-verificar) ──
	var vis_script: Script = load("res://scripts/debug/debug_visualizer.gd")
	_check("DebugVisualizer.gd carga", vis_script != null)
	if vis_script != null:
		var vis: Node3D = vis_script.new()
		vis._inicializar_instancias()  # Headless: _ready() no corre sin árbol
		_check("DebugVisualizer 5 toggles", vis.obtener_estado().size() == 5)
		vis.configurar_manual("colliders", true)
		_check("DebugVisualizer colliders visible", vis.instancia_visible("colliders"))

	# ── Bloque 3: POIList ──
	var poi_script: Script = load("res://scripts/debug/poi_list.gd")
	_check("POIList.gd carga", poi_script != null)
	if poi_script != null:
		var poi: Resource = poi_script.new()
		poi.pois = [{"nombre": "Test", "pos": Vector2(100, 200)}]
		_check("POIList 1 POI", poi.tamano() == 1)
		_check("POIList pos correcto", poi.obtener_pos("Test") == Vector2(100, 200))

	# ── Red de seguridad: _summary con create_timer (no call_deferred recursivo) ──
	create_timer(0.1).timeout.connect(func(): _fin())

func _fin() -> void:
	_summary()
	quit(1 if _fallos > 0 else 0)

func _summary() -> void:
	print("=== Resumen M110-UI2: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
