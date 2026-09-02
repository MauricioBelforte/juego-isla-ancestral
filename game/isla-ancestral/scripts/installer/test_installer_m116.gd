# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M116: Instalador — Test headless
# Valida: InstaladorConfig (plataformas, pasos, requisitos, soporte).
# Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M116] Test de Instalador ===")
	_test_config()
	_test_plataformas()
	_test_requisitos()
	_test_pasos()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: instalador_config.json ---")
	var ic := root.get_node_or_null("InstaladorConfig")
	if ic == null:
		_check("InstaladorConfig autoload presente", false)
		_summary()
		quit(1)
		return
	_check("InstaladorConfig autoload presente", true)
	_check("3 plataformas", ic.plataformas().size() == 3, "size=%d" % ic.plataformas().size())
	_check("5 pasos", ic.pasos().size() == 5, "size=%d" % ic.pasos().size())
	_check("disco_min_mb 4096", ic.requisito("disco_min_mb") == 4096, "val=%d" % ic.requisito("disco_min_mb"))
	_check("ram_min_mb 8192", ic.requisito("ram_min_mb") == 8192)

func _test_plataformas() -> void:
	print("--- Plataformas soportadas ---")
	var ic := root.get_node_or_null("InstaladorConfig")
	_check("windows soportado", ic.soporta_plataforma("windows"))
	_check("macos soportado", ic.soporta_plataforma("macos"))
	_check("linux soportado", ic.soporta_plataforma("linux"))
	_check("nintendo no soportado", not ic.soporta_plataforma("nintendo"))
	_check("playstation no soportado", not ic.soporta_plataforma("playstation"))

func _test_requisitos() -> void:
	print("--- Verificación de requisitos ---")
	var ic := root.get_node_or_null("InstaladorConfig")
	var ok = ic.verificar_requisitos(8192, 16384)
	_check("requisitos suficientes -> sin errores", ok.is_empty(), "errores=%s" % str(ok))
	var disco_bajo = ic.verificar_requisitos(1024, 16384)
	_check("disco insuficiente detectado", not disco_bajo.is_empty())
	var ram_baja = ic.verificar_requisitos(8192, 2048)
	_check("RAM insuficiente detectada", not ram_baja.is_empty())

func _test_pasos() -> void:
	print("--- Ejecución de pasos de instalación ---")
	var ic := root.get_node_or_null("InstaladorConfig")
	var paso1 = ic.ejecutar_paso("verificar_requisitos")
	_check("paso verificar_requisitos ok", paso1.get("ok", false) == true)
	_check("paso duplicado devuelve ya completado", String(ic.ejecutar_paso("verificar_requisitos").get("resultado", "")).contains("ya completado"))
	var paso_inexistente = ic.ejecutar_paso("no_existe")
	_check("paso inexistente -> !ok", paso_inexistente.get("ok", false) == false)
	_check("instalación incompleta (1 de 5)", ic.instalacion_completa() == false)
	# ejecutar el resto
	for paso in ic.pasos():
		var id = String(paso.get("id", ""))
		ic.ejecutar_paso(id)
	_check("instalación completa tras todos los pasos", ic.instalacion_completa() == true, "completados=%d" % ic.pasos_completados().size())

func _summary() -> void:
	print("=== Resumen M116: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M116 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M116 OK — todos los checks pasaron")
		quit(0)