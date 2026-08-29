extends Node

## Módulo 59: Guardado — SaveManager (autoload)
##
## Punto de entrada central del sistema de guardado. Encola peticiones
## (una a la vez), delega la escritura a SaveWriter (atómica), rota backups
## y coordina el registro de proveedores (ISaveProvider) para el snapshot.
##
## Señales emitidas:
##  - save_completed(slot, reason)
##  - save_failed(slot, reason)
##  - slot_loaded(slot, result)
##  - auto_save_skipped(reason)   (ej: durante diálogo/transición)

signal save_completed(slot: int, reason: String)
signal save_failed(slot: int, reason: String)
signal slot_loaded(slot: int, result: int)

## Número de slots disponibles
const SLOT_COUNT: int = 3

## Intervalo en segundos del auto-save temporizado (0 = desactivado)
@export var auto_save_interval: float = 300.0

## Flags que bloquean el guardado durante puntos sensibles
var _blocked: bool = false

## Cola de peticiones de guardado
var _queue: Array[Dictionary] = []

## Indica si hay una escritura en curso
var _writing: bool = false

## Snapshot manager (recolecta/restaura)
var snapshot: SaveSnapshot = SaveSnapshot.new()

## Loader para carga validada
var loader: SaveLoader = SaveLoader.new()

## Slot actualmente cargado (-1 = ninguno)
var current_slot: int = -1

## Registro de motivos de la última petición (para logs)
var last_reason: String = ""

func _ready() -> void:
	loader.snapshot = snapshot
	_process_init_cleanup()

func _process(delta: float) -> void:
	if auto_save_interval > 0.0:
		_auto_save_timer += delta
		if _auto_save_timer >= auto_save_interval:
			_auto_save_timer = 0.0
			if current_slot >= 1:
				request_save(current_slot, "timer")
			else:
				print("[SAVE] Auto-save omitido: no hay slot cargado (current_slot=%d)" % current_slot)

var _auto_save_timer: float = 0.0

## Bloquea / desbloquea el guardado (durante diálogo, minijuego, transición).
func set_save_blocked(value: bool) -> void:
	_blocked = value

func is_save_blocked() -> bool:
	return _blocked

## Registra un proveedor de sección del save.
## Sin tipo estricto: los proveedores pueden ser Nodes (ej: autoload Inventario M14)
## que implementan get_section_name/get_save_data/restore_save_data por duck-typing.
func register_provider(provider) -> bool:
	return snapshot.register_provider(provider)

## Solicita un guardado. Si está bloqueado o no hay slot, se omite.
func request_save(slot: int, reason: String) -> void:
	if _blocked:
		emit_signal("auto_save_skipped", "(bloqueado) %s" % reason)
		return
	if slot < 1 or slot > SLOT_COUNT:
		push_warning("[SAVE] Slot fuera de rango: %d" % slot)
		return
	_queue.append({"slot": slot, "reason": reason})
	if not _writing:
		_process_queue()

## Procesa la cola de guardados (uno a la vez, sin bloquear el frame).
func _process_queue() -> void:
	if _queue.is_empty() or _writing:
		return
	_writing = true
	var req: Dictionary = _queue.pop_front()
	var slot := int(req["slot"])
	var reason := String(req["reason"])
	last_reason = reason

	var payload := snapshot.collect("slot_%d" % slot)
	var ok := SaveWriter.write_atomic(slot, payload)
	if ok:
		SaveBackup.rotate(slot)
		current_slot = slot
		emit_signal("save_completed", slot, reason)
		print("[SAVE] OK slot %d (%s)" % [slot, reason])
	else:
		emit_signal("save_failed", slot, reason)
		push_error("[SAVE] Error guardando slot %d (%s)" % [slot, reason])
	_writing = false
	if not _queue.is_empty():
		_process_queue()

## Carga un slot de forma síncrona y restaura los sistemas.
## Devuelve el LoadResult (int).
func load_slot(slot: int) -> int:
	if slot < 1 or slot > SLOT_COUNT:
		return SaveLoader.LoadResult.NOT_FOUND
	var result := loader.load(slot)
	var code := int(result["result"])
	if code == SaveLoader.LoadResult.OK or code == SaveLoader.LoadResult.RECOVERED:
		current_slot = slot
	emit_signal("slot_loaded", slot, code)
	return code

## Devuelve metadatos resumidos de un slot (para la UI), o null si no existe.
func slot_metadata(slot: int) -> Dictionary:
	if not SaveWriter.save_exists(slot):
		return {}
	var path := SaveWriter.path_for(slot)
	var doc: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(doc) != TYPE_DICTIONARY:
		return {}
	var payload: Variant = doc.get("payload", {})
	if typeof(payload) != TYPE_DICTIONARY:
		return {}
	var time_dict: Dictionary = payload.get("time", {})
	return {
		"day": int(time_dict.get("day", 0)),
		"version": int(payload.get("schema_version", 0)),
		"last_saved": String(payload.get("meta", {}).get("last_saved", "")),
	}

## Devuelve si un slot tiene save y backups (para la UI de recuperación).
func slot_recoverable(slot: int) -> bool:
	return SaveBackup.has_any_backup(slot)

## Procesa limpieza de .tmp huérfanos al arrancar (regla anti-corrupción).
func _process_init_cleanup() -> void:
	for i in range(1, SLOT_COUNT + 1):
		SaveWriter.cleanup_orphan_tmp(i)
