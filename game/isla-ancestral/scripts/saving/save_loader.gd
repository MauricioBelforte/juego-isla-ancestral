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
		# Sin save principal: puede ser un slot nuevo (no hay nada que cargar) o
		# un guardado INTERRUMPIDO. Desde M59 iter. 2 el manager rota el save
		# anterior a .bak ANTES de escribir el nuevo; si el proceso muere (o la
		# escritura falla) entre la rotación y el rename, queda .bak pero no
		# .save. Antes esto devolvía NOT_FOUND y el progreso era inalcanzable
		# aunque estuviera en disco. Si hay backup, se recupera.
		if SaveBackup.has_any_backup(slot):
			return _try_recover(slot, "falta el save principal (guardado interrumpido)")
		return {"result": LoadResult.NOT_FOUND, "payload": {}, "version": 0}

	var content := FileAccess.get_file_as_string(path)
	var parsed := SaveWriter.parse_document(content)
	if not parsed.get("ok", false):
		return _try_recover(slot, String(parsed.get("reason", "documento inválido")))

	var payload: Dictionary = parsed["payload"]

	# JSON no preserva int vs float: schema_version vuelve como float (1.0).
	# Lo normalizamos al tipo del contrato para que el payload cargado sea
	# consistente con default_payload() y la comparación de versión sea exacta.
	payload["schema_version"] = int(payload.get("schema_version", 0))

	# 0) Completar con los defaults del schema lo que falte (item H: "campos
	# nuevos (defaults) y faltantes (sin crash)"). Sin esto, un save al que le
	# falta una seccion fallaba validate() -> CORRUPTED y no se podia cargar.
	# NO toca el interior de las secciones (ver SaveSchema.completar).
	payload = SaveSchema.completar(payload)

	# 1) Validar estructura
	var errors: Array[String] = SaveSchema.validate(payload)
	if not errors.is_empty():
		return _try_recover(slot, "estructura inválida: %s" % ", ".join(errors))

	# 2) Verificar versión
	var version := int(payload.get("schema_version", 0))
	if version > SaveSchema.SCHEMA_VERSION:
		# Aviso CLARO (V: "Cargar con versión futura (aviso claro)"): el save es
		# más nuevo que el juego. Se rechaza SIN tocarlo — nunca degradar un save
		# de una versión superior. La UI (M53) recibe además el código por la
		# señal SaveManager.slot_loaded(slot, FUTURE_VERSION).
		push_warning("[SAVE] El save del slot %d es de una versión FUTURA (v%d > v%d soportada). No se carga para no degradarlo; actualizá el juego." % [slot, version, SaveSchema.SCHEMA_VERSION])
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

	# M59 iter. 2: el camino de backup debe ser tan estricto como el principal.
	# Antes _try_recover() restauraba el payload SIN normalizar ni validar, así
	# que un backup de versión FUTURA se cargaba como RECOVERED (degradando un
	# save más nuevo, contra la regla dura "nunca degradar un save").
	payload["schema_version"] = int(payload.get("schema_version", 0))
	payload = SaveSchema.completar(payload)
	var errors: Array[String] = SaveSchema.validate(payload)
	if not errors.is_empty():
		push_error("[SAVE] Backup de slot %d con estructura inválida (%s)" % [slot, ", ".join(errors)])
		return {"result": LoadResult.CORRUPTED, "payload": {}, "version": 0}
	var version := int(payload.get("schema_version", 0))
	if version > SaveSchema.SCHEMA_VERSION:
		push_warning("[SAVE] El backup del slot %d es de una versión FUTURA (v%d > v%d soportada). No se carga para no degradarlo." % [slot, version, SaveSchema.SCHEMA_VERSION])
		return {"result": LoadResult.FUTURE_VERSION, "payload": {}, "version": version}

	if snapshot != null:
		snapshot.restore(payload)
	return {
		"result": LoadResult.RECOVERED,
		"payload": payload,
		"version": version,
	}

## Migración de schema (M60). Actualmente no hay migraciones registradas
## (v1 es la primera), pero se deja la infraestructura para el futuro.
## Las migraciones SON solo-hacia-delante y NUNCA degradan un save.
func _migrate(payload: Dictionary, _from_version: int) -> Dictionary:
	# v1 es la primera versión, sin migraciones por ahora.
	# Al agregar v2+: aplicar transformaciones progresivas aquí.
	payload["schema_version"] = SaveSchema.SCHEMA_VERSION
	return payload
