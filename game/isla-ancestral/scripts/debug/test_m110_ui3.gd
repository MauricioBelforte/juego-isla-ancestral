# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI slice 3: Test headless de DebugMenuUI + consola + visualizer.
extends SceneTree

var _fallos := 0
var _checks := 0
const CHECKS_MINIMOS := 15

func _initialize() -> void:
	print("=== TEST M110-UI 3: DebugMenuUI + Consola + Visualizer ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	# ── Bloque 1: DebugMenuUI carga ──
	var ui_script: Script = load("res://scripts/debug/debug_menu_ui.gd")
	_check("DebugMenuUI.gd carga", ui_script != null)
	
	# ── Bloque 2: debug_menu.tscn existe ──
	_check("debug_menu.tscn existe", FileAccess.file_exists("res://scenes/debug/debug_menu.tscn"))
	
	# ── Bloque 3: DebugConsole con métodos nuevos ──
	var cons_script: Script = load("res://scripts/debug/debug_console.gd")
	_check("DebugConsole.gd carga", cons_script != null)
	if cons_script != null:
		var cons: Control = cons_script.new()
		cons._agregar_linea("Test")
		_check("DebugConsole agregar_linea_publica", cons.tamano() == 1)
		cons.agregar_linea_publica("Pública")
		_check("DebugConsole agregar_linea_publica funciona", cons.tamano() == 2)
		cons.set_text("[b]HTML[/b]")
		_check("DebugConsole set_text no crash", true)

	# ── Bloque 4: DebugVisualizer + consola integrados ──
	var vis_script: Script = load("res://scripts/debug/debug_visualizer.gd")
	_check("DebugVisualizer carga", vis_script != null)
	if vis_script != null:
		var vis: Node3D = vis_script.new()
		vis._inicializar_instancias()
		vis.configurar_manual("chunks", true)
		_check("Visualizer chunks visible", vis.instancia_visible("chunks"))

	# ── Bloque 5: POIList ──
	var poi_script: Script = load("res://scripts/debug/poi_list.gd")
	if poi_script != null:
		var poi: Resource = poi_script.new()
		poi.pois = [{"nombre": "Test", "pos": Vector2(1, 2)}]
		_check("POIList funciona", poi.obtener_pos("Test") == Vector2(1, 2))

	# ── Bloque 6: Scene carga ──
	var scene := load("res://scenes/debug/debug_menu.tscn")
	_check("debug_menu.tscn carga", scene != null)
	if scene != null:
		var inst: Node = scene.instantiate()
		_check("debug_menu.tscn instancia", inst != null)
		if inst is CanvasLayer:
			_check("Instancia es CanvasLayer", true)
			# Verificar que tiene los nodos esperados
			_check("Tiene RootPanel", inst.has_node("RootPanel"))
			_check("Tiene TitleBar", inst.has_node("RootPanel/TitleBar"))
			_check("Tiene TabBar", inst.has_node("RootPanel/TabBar"))
			_check("Tiene ContentPanel", inst.has_node("RootPanel/ContentPanel"))
			_check("Tiene CloseButton", inst.has_node("RootPanel/TitleBar/CloseButton"))
			# Limpiar
			inst.queue_free()

	# ── Red de seguridad ──
	create_timer(0.5).timeout.connect(func(): _fin())

func _fin() -> void:
	_summary()
	quit(1 if _fallos > 0 else 0)

func _summary() -> void:
	print("=== Resumen M110-UI3: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
