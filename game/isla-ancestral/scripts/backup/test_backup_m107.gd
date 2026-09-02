# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M107: Backups — Test headless
# Valida: BackupManager (crear backup, verificar integridad con checksum,
# restaurar, retención máx copias). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M107] Test de Backups ===")
	_test_policy()
	_test_backup()
	_test_restaurar()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_policy() -> void:
	print("--- Policy: backup_policy.json ---")
	var bm := root.get_node_or_null("BackupManager")
	if bm == null:
		_check("BackupManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("BackupManager autoload presente", true)
	_check("retención máx 5", int(bm.config.get("retencion", {}).get("max_copias", 0)) == 5)
	_check("checksum habilitado", bm.config.get("verificacion", {}).get("checksum_habilitado", false) == true)

func _test_backup() -> void:
	print("--- Crear y verificar backups ---")
	var bm := root.get_node_or_null("BackupManager")
	var origen := "user://test_backup_src.json"
	var payload := '{"test":true,"n":1}'
	var contenido := Validador.crc32_hex(payload) + "\n" + payload
	var f := FileAccess.open(origen, FileAccess.WRITE)
	f.store_string(contenido)
	f.close()
	var ruta = bm.crear_backup(origen, "backup_test.json")
	_check("backup creado", ruta != "" and FileAccess.file_exists(ruta))
	_check("integridad verifica", bm.verificar_integridad(ruta) == true, "ruta=%s" % ruta)
	_check("cantidad backups >= 1", bm.cantidad_backups() >= 1)
	_check("origen inexistente -> ''", bm.crear_backup("user://no_existe.json", "x.json") == "")
	DirAccess.remove_absolute(origen)

func _test_restaurar() -> void:
	print("--- Restaurar backup ---")
	var bm := root.get_node_or_null("BackupManager")
	var origen := "user://test_restore_src.json"
	var payload := '{"version":1}'
	var contenido := Validador.crc32_hex(payload) + "\n" + payload
	var f := FileAccess.open(origen, FileAccess.WRITE)
	f.store_string(contenido)
	f.close()
	var ruta = bm.crear_backup(origen, "backup_restore.json")
	# Corromper el origen y restaurar
	var g := FileAccess.open(origen, FileAccess.WRITE)
	g.store_string("corrupto")
	g.close()
	var ok = bm.restaurar(ruta, origen)
	_check("restaura backup", ok and FileAccess.get_file_as_string(origen).contains("version"))
	# Backup corrupto no se restaura
	var malo = "user://backups/malo.json"
	var h := FileAccess.open(malo, FileAccess.WRITE)
	h.store_string("sin_checksum")
	h.close()
	_check("backup corrupto no restaura", bm.restaurar(malo, origen) == false)
	DirAccess.remove_absolute(origen)
	DirAccess.remove_absolute(malo)

func _summary() -> void:
	print("=== Resumen M107: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M107 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M107 OK — todos los checks pasaron")
		quit(0)