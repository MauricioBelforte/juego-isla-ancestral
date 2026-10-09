# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M87→M21: Test de integración Localización → Diálogos.
# Verifica que resolve_text traduzca claves MODULO.SECCION.CLAVE (RF17 M87)
# y que los placeholders se resuelvan después.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_localizacion_dialogos.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 4
const _WB_BLOQUES: Array[String] = ["_test_resolve_clave_es", "_test_resolve_clave_en", "_test_resolve_placeholder"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M21: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)



var _fallos: int = 0
var _dm: Node = null
var _loc: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_dm = load("res://scripts/dialogos/dialogue_manager.gd").new()
	root.add_child(_dm)
	_loc = root.get_node_or_null("Localization")
	_check(_loc != null, "Localization autoload presente")
	_test_resolve_clave_es()
	_fin("_test_resolve_clave_es")
	_test_resolve_clave_en()
	_fin("_test_resolve_clave_en")
	_test_resolve_placeholder()
	_fin("_test_resolve_placeholder")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_resolve_clave_es() -> void:
	_loc.set_locale("es")
	var texto: String = _dm.resolve_text("MAIN_MENU.PLAY", {})
	_check(texto == "Jugar", "clave MAIN_MENU.PLAY es -> " + texto)

func _test_resolve_clave_en() -> void:
	_loc.set_locale("en")
	var texto: String = _dm.resolve_text("MAIN_MENU.PLAY", {})
	_check(texto == "Play", "clave MAIN_MENU.PLAY en -> " + texto)

func _test_resolve_placeholder() -> void:
	# Texto con placeholder de sesión (nombre_viajero) se resuelve tras traducir
	_dm._session_vars["nombre_viajero"] = "Ana"
	var texto: String = _dm.resolve_text("Hola {nombre_viajero}", {"nombre_viajero": "Ana"})
	_check(texto == "Hola Ana", "placeholder resuelto -> " + texto)