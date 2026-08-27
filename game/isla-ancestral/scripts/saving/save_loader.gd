class_name SaveLoader
extends RefCounted

## Módulo 59: Guardado — Carga validada con checksum, migración y backup
##
## Flujo de carga:
##  1. Leer slot_N.save
##  2. Verificar checksum (SHA-256 del payload)
##  3. Validar estructura (SaveSchema.validate)
##  4. Si falla → intentar recuperar slot_N.bak
##  5. Si schema_version < actual → migrar (M60) con backup previo
##  6. Restaurar cada sistema (SaveSnapshot.restore)

## Enumerado de resultados de carga
enum LoadResult {
	OK,          # Cargado correctamente
	NOT_FOUND,   # No existe save en ese slot
	CORRUPTED,   # Checksum/estructura inválidos y sin backup válido
	RECOVERED,   # Se recuperó desde backup
	FUTURE_VERSION, # El save es de una versión más nueva que la soportada
	EMPTY_SLOT,  # Slot existe pero está vacío/inválido
}

## Referencia al snapshot (se asigna por SaveManager)
var snapshot: SaveSnapshot = null

## Carga un slot. Devuelve { result: LoadResult, payload: Dictionary, version: int }.
func load(slot: int) -> Dictionary:
	var path := SaveWriter.path_for(slot)
	if not FileAccess.file_exists(path):
		return {"result": LoadResult.NOT_FOUND, "payload": {}, "version": 0}

	var content := FileAccess.get_file_as_string(path)
	var parsed := SaveWriter.parse_document(content)
	if not parsed.get("ok", false):
		return _try_recover(slot, String(parsed.get("reason", "documento inválido")))

	var payload: Dictionary = parsed["payload"]

	# 1) Validar estructura
	var errors: Array[String] = SaveSchema.validate(payload)
	if not errors.is_empty():
		return _try_recover(slot, "estructura inválida: %s" % ", ".join(errors))

	# 2) Verificar versión
	var version := int(payload.get("schema_version", 0))
	if version > SaveSchema.SCHEMA_VERSION:
		return {"result": LoadResult.FUTURE_VERSION, "payload": {}, "version": version}

	# 3) Migración solo hacia delante (con backup previo)
	if version < SaveSchema.SCHEMA_VERSION:
		SaveBackup.backup_manual(slot)  # backup previo a migración (M60)
		payload = _migrate(payload, version)

	# 4) Restaurar sistemas
	if snapshot != null:
		snapshot.restore(payload)

	return {
		"result": LoadResult.OK,
		"payload": payload,
		"version": SaveSchema.SCHEMA_VERSION,
	}

## Intenta recuperar desde el backup local más reciente cuando el save
## principal está corrupto. Devuelve LoadResult.RECOVERED si se pudo.
func _try_recover(slot: int, reason: String) -> Dictionary:
	push_warning("[SAVE] Save slot %d corrupto (%s), intentando backup..." % [slot, reason])
	var bak := SaveBackup.read_latest_backup(slot)
	if bak.is_empty():
		push_error("[SAVE] No hay backup válido para slot %d" % slot)
		return {"result": LoadResult.CORRUPTED, "payload": {}, "version": 0}

	var parsed := SaveWriter.parse_document(bak)
	if not parsed.get("ok", false):
		push_error("[SAVE] Backup de slot %d también está corrupto (%s)" % [slot, parsed.get("reason", "")])
		return {"result": LoadResult.CORRUPTED, "payload": {}, "version": 0}

	var payload: Dictionary = parsed["payload"]
	if snapshot != null:
		snapshot.restore(payload)
	return {
		"result": LoadResult.RECOVERED,
		"payload": payload,
		"version": int(payload.get("schema_version", 0)),
	}

## Migración de schema (M60). Actualmente no hay migraciones registradas
## (v1 es la primera), pero se deja la infraestructura para el futuro.
## Las migraciones SON solo-hacia-delante y NUNCA degradan un save.
func _migrate(payload: Dictionary, _from_version: int) -> Dictionary:
	# v1 es la primera versión, sin migraciones por ahora.
	# Al agregar v2+: aplicar transformaciones progresivas aquí.
	payload["schema_version"] = SaveSchema.SCHEMA_VERSION
	return payload
