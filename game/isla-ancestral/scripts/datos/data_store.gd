# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — DataStore (autoload "DataStore")
# Servicio central de datos (RF1). Unifica acceso a: partida (JSON+CRC32),
# mundo voxel (binario IAVX1), configuración (ConfigFile) y estáticos (.tres).
# Desacoplado de UI (RN7): recibe/entrega Dictionaries y PackedByteArray y
# emite señales. Delegado a SetSerializers/Validador/WriterAtomico/GestorSlot/
# GestorConfig/CatalogosEstaticos.
#
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17).

extends Node

signal guardado_slot(slot: int, ok: bool, duracion_ms: int, bytes: int)
signal cargado_slot(slot: int, ok: bool, error: String)
signal config_lista(config: Dictionary)
signal config_guardada(ok: bool)

const VERSION_ACTUAL: int = 1

var _config_estatica: Dictionary = {}

func _ready() -> void:
	_registrar_servicio()
	print("[M60] DataStore listo (VERSION_ACTUAL=%d)" % VERSION_ACTUAL)

## ── ServiceRegistry (M07) ───────────────────────────────

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		push_warning("[M60] ServiceRegistry no encontrado; DataStore no registrado como servicio")
		return
	if sr.has("datos"):
		push_warning("[M60] Servicio 'datos' ya registrado; omitiendo")
		return
	sr.register("datos", self)
	print("[M60] DataStore registrado en ServiceRegistry como 'datos'")

## ── Partida: guardar / cargar ───────────────────────────

## Guarda una partida completa en el slot (flujo 3.1 de 03-Diseno).
## `datos_sistemas` = bloques aportados por los sistemas: jugador, inventario,
## tiempo, mundo_voxel, progresion, meta. El DataStore agrega version + checksum.
## Devuelve metadata del guardado (para el menú M59/M53).
func guardar_partida(slot: int, datos_sistemas: Dictionary) -> Dictionary:
	var inicio := Time.get_ticks_msec()
	var ok := false
	var error_final := ""

	if slot < 1 or slot > GestorSlot.SLOT_COUNT:
		error_final = "slot fuera de rango: %d" % slot
	else:
		var err_dir := GestorSlot.asegurar_directorio(slot)
		if err_dir != OK and err_dir != ERR_CANT_CREATE:
			error_final = "no se pudo crear directorio (err=%d)" % err_dir
		else:
			ok = _escribir_save(slot, datos_sistemas)
			if not ok:
				error_final = "fallo de escritura del save"
			else:
				var err_meta := _escribir_meta(slot)
				if err_meta != OK:
					error_final = "fallo de escritura de meta"

	if ok:
		var chunks: int = int(datos_sistemas.get("mundo_voxel", {}).get("chunks_editados", 0))
		if chunks > 0:
			_guardar_voxel_binario(slot, datos_sistemas.get("mundo_voxel", {}))

	var duracion := Time.get_ticks_msec() - inicio
	var bytes := _bytes_write(slot)
	emit_signal("guardado_slot", slot, ok, duracion, bytes)
	var meta := {
		"slot": slot,
		"ok": ok,
		"error": error_final,
		"duracion_ms": duracion,
		"bytes": bytes,
		"checksum": Validador.calcular_crc32(_payload_final(slot)),
	}
	if not ok:
		push_error("[M60] Guardado slot %d falló: %s" % [slot, error_final])
	else:
		var logger := get_node_or_null("/root/GameLogger")
		if logger and logger.has_method("info"):
			logger.info("[M60] Save slot %d escrito (%d bytes, %d ms)" % [slot, bytes, duracion])
	return meta

## Carga y entrega la partida del slot (flujo 3.2 de 03-Diseno).
## Aplica migraciones y validación; nunca crashea: devuelve {ok:false, error:...}.
func cargar_partida(slot: int) -> Dictionary:
	if slot < 1 or slot > GestorSlot.SLOT_COUNT:
		return {"ok": false, "error": "slot fuera de rango: %d" % slot}
	if not GestorSlot.existe_slot(slot):
		return {"ok": false, "error": "slot no existe"}

	var r := GestorSlot.rutas_slot(slot)
	var doc := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(r["save"]))
	if not doc.get("ok", false):
		# Corrupción: intentar restauración desde .bak una vez
		var restaurado := _intentar_restauracion(slot)
		if not restaurado:
			return {"ok": false, "error": "save corrupto sin backup: %s" % doc.get("reason", "")}
		doc = WriterAtomico.parsear_documento(FileAccess.get_file_as_string(r["save"]))

	var datos: Dictionary = doc["payload"]

	# Versión futura -> rechazo (RF: save de un juego más nuevo)
	if Versionador.version_futura(datos):
		return {"ok": false, "error": "versión más nueva que este juego (VERSION_ACTUAL=%d)" % VERSION_ACTUAL}

	# Migración ascendente (RF7) sobre copia en memoria
	var migrado := Versionador.migrar(datos)
	if not migrado["ok"]:
		return {"ok": false, "error": "migración fallida: %s" % migrado.get("error", "desconocido")}
	datos = migrado["datos"]

	# Contrato de la versión destino
	var errores := Validador.validar_contrato(datos, int(datos.get("version", 0)))
	if not errores.is_empty():
		return {"ok": false, "error": "contrato inválido: %s" % "; ".join(errores)}

	# mundo voxel adjunto (RF4) si el save lo referencia
	datos["_voxel_payload"] = cargar_mundo_voxel(slot)
	emit_signal("cargado_slot", slot, true, "")
	var logger := get_node_or_null("/root/GameLogger")
	if logger and logger.has_method("info"):
		logger.info("[M60] Save slot %d cargado y validado (versión %s)" % [slot, str(datos.get("version", 0))])
	return {"ok": true, "slot": slot, "datos": datos}

## Migra un Dictionary de save desde su versión actual hasta VERSION_ACTUAL.
## Devuelve {ok, datos|error}. No toca disco.
func migrar(datos: Dictionary) -> Dictionary:
	return Versionador.migrar(datos)

## ── Slots ──────────────────────────────────────────────

## Borrado seguro de un slot (con confirmación del llamador).
func borrar_slot(slot: int) -> bool:
	return GestorSlot.borrar_slot(slot)

## Lista slots existentes (rápido: solo meta.json).
func listar_slots() -> Array:
	var slots: Array = []
	for i in range(1, GestorSlot.SLOT_COUNT + 1):
		var meta := GestorSlot.leer_meta(i)
		if not meta.is_empty():
			slots.append({"slot": i, "meta": meta})
	return slots

## ── Configuración (M58/90/91) ──────────────────────────

## Guarda configuración en user://config.cfg (escritura atómica).
func guardar_config(datos: Dictionary) -> Error:
	var err := GestorConfig.guardar_config(datos)
	emit_signal("config_guardada", err == OK)
	print("[M60] Config guardada (err=%d)" % err)
	return err

## Carga configuración con defaults para claves ausentes.
func cargar_config() -> Dictionary:
	_config_estatica = GestorConfig.cargar_config()
	emit_signal("config_lista", _config_estatica)
	return _config_estatica

## Configuración actual (cache de la última carga).
func config_actual() -> Dictionary:
	return _config_estatica

## ── Mundo voxel (M08) ──────────────────────────────────────

## Entrega el payload del mundo voxel guardado (edits del jugador).
func cargar_mundo_voxel(slot: int) -> PackedByteArray:
	var r := GestorSlot.rutas_slot(slot)
	if not FileAccess.file_exists(r["voxel"]):
		return PackedByteArray()
	return FileAccess.get_file_as_bytes(r["voxel"])

## ── Internos ───────────────────────────────────────────

## Construye el payload final: version + datos_sistemas + checksum.
func _payload_final(slot: int) -> Dictionary:
	var meta_cache: Dictionary = {}
	var m := GestorSlot.rutas_slot(slot)
	if FileAccess.file_exists(m["meta"]):
		meta_cache = JSON.parse_string(FileAccess.get_file_as_string(m["meta"]))
	if typeof(meta_cache) != TYPE_DICTIONARY:
		meta_cache = GestorSlot.meta_default(slot)
	var doc := WriterAtomico.parsear_documento(FileAccess.get_file_as_string(m["save"]))
	if not doc.get("ok", false):
		return {}
	var p: Dictionary = doc["payload"]
	return p

## Escribe save.json con checksum (patrón cadena-exacta §9.11).
func _escribir_save(slot: int, datos_sistemas: Dictionary) -> bool:
	var plano := Serializer.a_plano(datos_sistemas)
	plano["version"] = VERSION_ACTUAL
	# orden determinista para el checksum: el payload_str es la fuente de verdad
	var payload_str := Serializer.a_json(plano)
	var contenido := WriterAtomico.construir_con_checksum(payload_str)
	var r := GestorSlot.rutas_slot(slot)
	var err := WriterAtomico.escribir_atomicamente(r["save"], contenido)
	if err != OK:
		push_error("[M60] guardar save.json falló (err=%d)" % err)
		return false
	return true

func _escribir_meta(slot: int) -> Error:
	var meta := GestorSlot.meta_default(slot)
	meta["guardado_iso"] = Time.get_datetime_string_from_system(true)
	return GestorSlot.escribir_meta(slot, meta)

## Guarda / reenvía el binario voxel si el payload lo incluye.
func _guardar_voxel_binario(slot: int, voxel_config: Dictionary) -> void:
	var chunks: Array = voxel_config.get("chunks", [])
	if chunks.is_empty():
		return
	# Asegurar directorio y escribir binario IAVX1 (RF4)
	var r := GestorSlot.rutas_slot(slot)
	var err_dir := GestorSlot.asegurar_directorio(slot)
	if err_dir != OK and err_dir != ERR_CANT_CREATE:
		return
	var bin := Serializer.a_binario_voxel(chunks)
	var archivo := FileAccess.open(r["voxel"], FileAccess.WRITE)
	if archivo == null:
		push_error("[M60] No se pudo abrir mundo_voxel.bin")
		return
	archivo.store_buffer(bin)
	archivo.close()
	print("[M60] Mundo voxel binario guardado (%d bytes, %d chunks)" % [bin.size(), chunks.size()])

## Intenta restaurar el .bak (recuperación de una corrupción).
func _intentar_restauracion(slot: int) -> bool:
	var r := GestorSlot.rutas_slot(slot)
	var err := WriterAtomico.restaurar_backup(r["save"])
	if err == OK:
		print("[M60] Save restaurado desde backup (slot %d)" % slot)
		return true
	return false

## Bytes escritos en disco para el slot (PURO diagnóstico para la señal).
func _bytes_write(slot: int) -> int:
	var r := GestorSlot.rutas_slot(slot)
	var total := 0
	for clave in ["save", "voxel", "meta"]:
		var p: String = r[clave]
		if FileAccess.file_exists(p):
			total += FileAccess.get_file_as_bytes(p).size()
	return total