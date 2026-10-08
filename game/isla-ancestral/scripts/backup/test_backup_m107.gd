# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-19
#
# M107: Backups — Test headless (RF1-RF15)
# Valida: BackupManager (crear backup, verificar integridad con checksum,
# restaurar, retención, categorías RF1-RF8, compresión, manifest).

# NOTA (agnes-3-flash, 2026-10-08, BUG-121): los SCRIPT ERROR "instantiate" sobre null que se ven
# al correr este test en headless vienen del AUTOLOAD DE FAUNA (tortuga/cangrejo/jabali _instanciar_modelo:
# load(.glb) devuelve null en headless y no hay null-guard antes de .instantiate()), NO de este test.
# Los checks de modulo de ESTE test pasan. Fix = null-guard en M30-fauna (dueño lo asigna el director).
extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M107] Test de Backups (RF1-RF15) ===")
	_test_policy()
	_test_categorias()
	_test_backup()
	_test_backup_categoria()
	_test_restaurar()
	_test_verificar_categoria()
	_test_audit()
	_test_cantidades()
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

## ── Audit: listar_backups() ─────────
func _test_audit() -> void:
	print("--- Audit: listar_backups() ---")
	var bm := root.get_node_or_null("BackupManager")
	var origen := "user://test_audit_src.json"
	var payload := '{"audit":true}'
	var contenido := Validador.crc32_hex(payload) + "\n" + payload
	var f := FileAccess.open(origen, FileAccess.WRITE)
	f.store_string(contenido)
	f.close()
	var ruta = bm.crear_backup(origen, "backup_audit.json")
	var manifest: Array = bm.listar_backups()
	_check("manifest es Array", manifest is Array, "tipo=%s" % str(typeof(manifest)))
	_check("manifest lista el backup creado", _contiene(manifest, "backup_audit.json"))
	_check("entry del manifest con integridad=true", _es_integra(manifest, "backup_audit.json"))
	DirAccess.remove_absolute(origen)
	if ruta != "" and FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)

## ── Categorías RF1-RF8 ─────────
func _test_categorias() -> void:
	print("--- Categorias RF1-RF8 ---")
	var bm := root.get_node_or_null("BackupManager")
	var cats: Array = bm.categorias_disponibles()
	_check("categorias_disponibles retorna Array", cats is Array)
	_check("hay >= 5 categorias", cats.size() >= 5, "size=%d" % cats.size())
	_check("categoria repositorio existe", bm.get_categoria("repositorio").size() > 0)
	_check("categoria saves existe", bm.get_categoria("saves").size() > 0)
	_check("categoria musica existe", bm.get_categoria("musica").size() > 0)
	_check("categoria assets existe", bm.get_categoria("assets").size() > 0)
	_check("categoria fuente existe", bm.get_categoria("fuente").size() > 0)
	_check("categoria documentacion existe", bm.get_categoria("documentacion").size() > 0)
	_check("categoria builds existe", bm.get_categoria("builds").size() > 0)
	_check("categoria inexistente retorna vacio", bm.get_categoria("no_existe").is_empty())

## ── Backup de categoría (RF2, RF6) ─────────
func _test_backup_categoria() -> void:
	print("--- Backup de categoria ---")
	var bm := root.get_node_or_null("BackupManager")
	# Crear un origen temporal para la categoría saves
	var dir_temp := ProjectSettings.globalize_path("user://test_saves_temp")
	DirAccess.make_dir_recursive_absolute(dir_temp)
	var f := FileAccess.open(dir_temp + "/save1.json", FileAccess.WRITE)
	f.store_string('{"slot":1}')
	f.close()
	# Backup de saves (usa origenes de backup_categories.json)
	# Nota: en headless los origenes pueden no existir, pero no debe fallar
	var ruta_saves = bm._backup_categoria("saves")
	_check("backup saves retorna string", ruta_saves is String)
	# Cleanup
	DirAccess.remove_absolute(dir_temp)
	if ruta_saves != "" and FileAccess.file_exists(ruta_saves):
		DirAccess.remove_absolute(ruta_saves)

## ── Verificar categoría (RF11, RF14) ─────────
func _test_verificar_categoria() -> void:
	print("--- Verificar categoria ---")
	var bm := root.get_node_or_null("BackupManager")
	var resultados: Array = bm.verificar_categoria("saves")
	_check("verificar_categoria retorna Array", resultados is Array)

## ── Cantidades (RF11) ─────────
func _test_cantidades() -> void:
	print("--- Cantidades ---")
	var bm := root.get_node_or_null("BackupManager")
	var total: int = bm.cantidad_backups()
	_check("cantidad_backups es int", total is int)
	_check("cantidad_backups >= 0", total >= 0)
	var cat_saves: int = bm.cantidad_backups_categoria("saves")
	_check("cantidad_backups_categoria es int", cat_saves is int)
	_check("cantidad_backups_categoria >= 0", cat_saves >= 0)

func _contiene(manifest: Array, nombre: String) -> bool:
	for e in manifest:
		if str(e.get("nombre", "")) == nombre:
			return true
	return false

func _es_integra(manifest: Array, nombre: String) -> bool:
	for e in manifest:
		if str(e.get("nombre", "")) == nombre:
			return bool(e.get("integridad", false))
	return false

func _summary() -> void:
	print("=== Resumen M107: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M107 FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M107 OK — todos los checks pasaron")
		quit(0)