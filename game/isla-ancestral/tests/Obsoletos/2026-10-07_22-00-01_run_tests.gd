extends SceneTree

## Entry point para ejecutar la suite de tests GdUnit4 en modo headless.
##
## Uso:
##   godot --headless -s res://tests/run_tests.gd
##
## Alternativa (GdUnit4 CLI directo):
##   godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --path res://tests
##
## Exit codes:
##   0 = todos los tests pasaron
##   1 = al menos un test falló
##   2 = error de configuración/ejecución

func _initialize() -> void:
	print("=== Isla Ancestral - Test Suite Runner ===")

	if not _verify_gdunit4():
		print("ERROR: GdUnit4 no está instalado o no se puede cargar")
		quit(2)
		return

	_run_gdunit_cli()


func _finalize() -> void:
	pass


func _verify_gdunit4() -> bool:
	var config = ConfigFile.new()
	var err = config.load("res://addons/gdUnit4/plugin.cfg")
	if err == OK:
		print("GdUnit4 plugin.cfg encontrado (v" + str(config.get_value("plugin", "version")) + ")")
		return true
	print("GdUnit4 no encontrado en res://addons/gdUnit4/")
	return false


func _run_gdunit_cli() -> void:
	print("Ejecutando suite completa con GdUnit4 CLI runner...")

	var arguments := PackedStringArray([
		"-s", "-d",
		"res://addons/gdUnit4/bin/GdUnitCmdTool.gd",
		"--", "--path", "res://tests", "--verbose"
	])

	var output := Array()
	var exit_code := 0
	OS.execute(OS.get_executable_path(), arguments, output, exit_code)

	if exit_code != 0:
		print("RESULTADO: FALLÓ - Algunos tests fallaron (código: ", exit_code, ")")
		for line in output:
			print(line)
		quit(1)
	else:
		print("RESULTADO: ÉXITO - Todos los tests pasaron")
		quit(0)
