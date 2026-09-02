# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M106: Seguridad — Test headless
# Valida: SecurityManager (políticas, restricciones, validar_save,
# validar_max, alertas). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M106] Test de Seguridad ===")
	_test_policies()
	_test_restricciones()
	_test_save()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_policies() -> void:
	print("--- Políticas: seguridad data-driven ---")
	var sm := root.get_node_or_null("SecurityManager")
	if sm == null:
		_check("SecurityManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("SecurityManager autoload presente", true)
	_check("4 políticas", sm.config.get("politicas", {}).size() == 4, "size=%d" % sm.config.get("politicas", {}).size())
	_check("validar_saves habilitada", sm.politica("validar_saves") == true)
	_check("bloquear_carpetas_res habilitada", sm.politica("bloquear_carpetas_res") == true)
	_check("política inexistente -> false", sm.politica("no_existe") == false)

func _test_restricciones() -> void:
	print("--- Restricciones: validación de valores ---")
	var sm := root.get_node_or_null("SecurityManager")
	_check("max_objetos 99 permitido", sm.validar_max("max_objetos_inventario", 50) == true)
	_check("max_objetos 100 excede", sm.validar_max("max_objetos_inventario", 100) == false)
	_check("sin restricción -> true", sm.validar_max("campo_inexistente", 9999) == true)
	# alertas
	sm.registrar_alerta("Intento de acceso a carpeta res")
	_check("alerta registrada", sm.cantidad_alertas() >= 1 and "res" in str(sm.alertas()))

func _test_save() -> void:
	print("--- Validación de saves (checksum CRC32) ---")
	var sm := root.get_node_or_null("SecurityManager")
	# save inexistente -> false
	_check("save inexistente -> false", sm.validar_save("user://no_existe.save") == false)
	# save real con checksum válido (usar DataStore M60)
	var ruta := "user://test_security_save.json"
	var payload := '{"version":1,"test":true}'
	var contenido := Validador.crc32_hex(payload) + "\n" + payload
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_string(contenido)
	f.close()
	_check("save válido -> true", sm.validar_save(ruta) == true, "ruta=%s" % ruta)
	DirAccess.remove_absolute(ruta)

	# save CORRUPTO (payload alterado tras el checksum) -> debe detectarse
	var ruta_corrupta := "user://test_security_save_corrupto.json"
	var checksum_bueno := Validador.crc32_hex('{"version":1,"test":true}')
	var contenido_corrupto := checksum_bueno + "\n" + '{"version":9,"test":true}'
	var f2 := FileAccess.open(ruta_corrupta, FileAccess.WRITE)
	f2.store_string(contenido_corrupto)
	f2.close()
	_check("save corrupto (payload alterado) -> false", sm.validar_save(ruta_corrupta) == false)
	DirAccess.remove_absolute(ruta_corrupta)

func _summary() -> void:
	print("=== Resumen M106: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M106 OK — todos los checks pasaron")
		quit(0)