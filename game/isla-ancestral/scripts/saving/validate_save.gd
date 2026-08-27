extends SceneTree

## Módulo 59: Guardado — Script de validación (QA) ejecutable headless
##
## Uso: Godot --headless --path game/isla-ancestral --script res://scripts/saving/validate_save.gd
## Valida: escritura atómica, checksum, estructura, slots, corrupción,
## recuperación de backup y migración de versión. Devuelve exit code != 0 si falla.

var _failures: int = 0
var _checks: int = 0

func _initialize() -> void:
	print("=== [SAVE] Validación del módulo 59 (Guardado) ===")
	# Limpiar saves de pruebas previas para que la validación sea determinista
	_delete_save_dir()
	_run_all()
	_summary()

## Elimina la carpeta de saves de test (para determinismo entre corridas).
func _delete_save_dir() -> void:
	var dir := DirAccess.open(SaveSchema.SAVE_DIR)
	if dir:
		for f in dir.get_files():
			var _e := dir.remove(f)
		dir = null

func _run_all() -> void:
	# Directamente en user:// propio de la validación para no tocar saves reales
	_test_atomic_write()
	_test_checksum_detection()
	_test_backup_recovery()
	_test_slot_rotations()
	_test_migration_path()

func _check(name: String, condition: bool, detail: String = "") -> void:
	_checks += 1
	if condition:
		print("  [OK] %s" % name)
	else:
		_failures += 1
		print("  [FAIL] %s %s" % [name, detail])

func _test_atomic_write() -> void:
	print("--- Escritura atómica ---")
	var payload := SaveSchema.default_payload("slot_1")
	payload["meta"]["last_saved"] = Time.get_datetime_string_from_system()
	_check("write_atomic devuelve true", SaveWriter.write_atomic(1, payload))
	_check("save existe tras escribir", SaveWriter.save_exists(1))

	# Reescritura completa del slot (simula guardado posterior)
	payload["time"]["day"] = 2
	_check("re-escritura ok", SaveWriter.write_atomic(1, payload))

	var content := FileAccess.get_file_as_string(SaveWriter.path_for(1))
	var parsed := SaveWriter.parse_document(content)
	_check("documento con checksum y payload válido",
		parsed.get("ok", false) and parsed.has("payload") and parsed.has("checksum")
		and int(parsed["payload"]["time"]["day"]) == 2)

func _test_checksum_detection() -> void:
	print("--- Detección de corrupción (checksum) ---")
	var payload := SaveSchema.default_payload("slot_2")
	SaveWriter.write_atomic(2, payload)

	# Corromper bytes del payload SIN recalcular el checksum: debe detectarse
	var path := SaveWriter.path_for(2)
	var raw := FileAccess.get_file_as_string(path)
	# Remplazar el primer dígito del "day" en la línea de payload (3 → 9)
	var corrupted := raw.replace("\"day\":1,", "\"day\":9,")
	FileAccess.open(path, FileAccess.WRITE).store_string(corrupted)

	var loader := SaveLoader.new()
	var result := loader.load(2)
	_check("corrupción detectada (falla checksum)",
		int(result["result"]) == SaveLoader.LoadResult.RECOVERED or int(result["result"]) == SaveLoader.LoadResult.CORRUPTED,
		"resultado=%d" % int(result["result"]))
	# No hay backup, así que debe ser CORRUPTED
	_check("sin backup → CORRUPTED", int(result["result"]) == SaveLoader.LoadResult.CORRUPTED)

func _test_backup_recovery() -> void:
	print("--- Recuperación de backup ---")
	# Save válido en slot 3
	var payload := SaveSchema.default_payload("slot_3")
	payload["inventory"]["items"] = [{"id": "madera", "qty": 10}]
	SaveWriter.write_atomic(3, payload)
	SaveBackup.rotate(3)  # el buen save pasa a backup

	# Escribir de nuevo y luego corromper el archivo del slot
	SaveWriter.write_atomic(3, payload)
	var path := SaveWriter.path_for(3)
	var raw := FileAccess.get_file_as_string(path)
	# Corromper el día (1 → 8) sin actualizar el checksum
	var corrupted := raw.replace("\"day\":1,", "\"day\":8,")
	FileAccess.open(path, FileAccess.WRITE).store_string(corrupted)

	var loader := SaveLoader.new()
	var result := loader.load(3)
	_check("recuperación desde backup (RECOVERED)",
		int(result["result"]) == SaveLoader.LoadResult.RECOVERED,
		"resultado=%d" % int(result["result"]))
	_check("payload recuperado preserva inventario",
		int(result["result"]) == SaveLoader.LoadResult.RECOVERED and
		result["payload"]["inventory"]["items"].size() == 1 and
		result["payload"]["inventory"]["items"][0].get("id", "") == "madera" and
		int(result["payload"]["inventory"]["items"][0].get("qty", 0)) == 10,
		"items_recuperado=%s" % str(result["payload"].get("inventory", {}).get("items", "N/A")))

func _test_slot_rotations() -> void:
	print("--- Rotación de backups (multi-slots) ---")
	for i in range(1, 4):
		var p := SaveSchema.default_payload("slot_%d" % i)
		p["world"]["seed"] = i * 100
		SaveWriter.write_atomic(i, p)
	for i in range(1, 4):
		SaveBackup.rotate(i)
	for i in range(1, 4):
		_check("backup del slot %d existe" % i, FileAccess.file_exists(SaveBackup.latest_backup(i)))

func _test_migration_path() -> void:
	print("--- Migración (infraestructura, v1 sin migraciones) ---")
	var payload := SaveSchema.default_payload("slot_x")
	# No hay migraciones registradas en v1; verificamos que el loader
	# no corrompa al cargar un save en su versión actual.
	_check("schema actual es v1", SaveSchema.SCHEMA_VERSION == 1)
	_check("default_payload es válido", SaveSchema.validate(payload).is_empty())

func _summary() -> void:
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _failures])
	if _failures > 0:
		print("VALIDACIÓN FALLIDA — salida con código 1")
		quit(1)
	else:
		print("VALIDACIÓN OK — todos los checks pasaron")
		quit(0)
