# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# ── iter. 2: guardado asincrónico (RF10) ──────────────────────────
# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
# Se agregó `guardar_partida_async` (IO fuera del hilo principal), la cola de
# profundidad 1 para el edge case de doble guardado concurrente y los helpers
# de hilo. La API sincrónica `guardar_partida` NO cambió de contrato.
#
# ── iter. 4: cierre de huecos verificables ────────────────────────
# Modelo: DeepSeek-V4.1-Flash · Plataforma: WorkBuddy · Fecha: 2026-09-15
# (a) `_log_m60()` centraliza el registro en M103 (antes: 4 bloques duplicados);
# (b) la carga registra el salto de versión real (origen -> destino) y el
#     resultado del contrato (ítems 56 y 69 del checklist);
# (c) validación de contrato TAMBIÉN al guardar, como diagnóstico temprano
#     NO bloqueante (ítem 66): avisa pero nunca impide escribir;
# (d) `_regenerar_meta_si_falta()`: un slot con save.json y sin meta.json
#     vuelve a listarse en el menú de M59/M53 (edge case, ítem 155);
# (e) el binario voxel también rota `.bak` (ítem 120) y `GestorSlot.borrar_slot`
#     limpia voxel + `.deflate` + las copias de backup (fuga detectada).
#
# M60: Datos y Serialización — DataStore (autoload "DataStore")
# Servicio central de datos (RF1). Unifica acceso a: partida (JSON+CRC32),
# mundo voxel (binario IAVX1), configuración (ConfigFile) y estáticos (.tres).
# Desacoplado de UI (RN7): recibe/entrega Dictionaries y PackedByteArray y
# emite señales. Delegado a SetSerializers/Validador/WriterAtomico/GestorSlot/
# GestorConfig/CatalogosEstaticos.
#
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17).

extends Node

signal guardado_slot(slot: int, ok: bool, duracion_ms: int, bytes: int)
signal cargado_slot(slot: int, ok: bool, error: String)
signal config_lista(config: Dictionary)
signal config_guardada(ok: bool)
## RF10: avisan al consumidor (M59/M53) el ciclo del guardado en hilo secundario.
signal guardado_async_iniciado(slot: int)
signal guardado_async_encolado(slot: int, reemplazo: bool)
## iter. 3 (T-164): progreso del guardado asincrónico para la UI de M53.
## `porcentaje` va de 0.0 a 1.0 y solo crece. El DIBUJO es responsabilidad de
## M53; M60 entrega el dato (regla de desacople RN7).
signal guardado_async_progreso(slot: int, porcentaje: float)

const VERSION_ACTUAL: int = 1

## iter. 4 (ítem 66): validar el contrato ANTES de escribir, como detección
## temprana. Es NO bloqueante: un save parcial legítimo no debe perderse.
const VALIDAR_AL_GUARDAR: bool = true

## iter. 3 (T-145/T-200): compresión del binario voxel bajo criterio de tamaño.
## Solo se comprime si el archivo supera el umbral Y la compresión reduce.
const UMBRAL_COMPRESION_BYTES: int = 65536
const SUFIJO_DEFLATE: String = ".deflate"

var _config_estatica: Dictionary = {}

## ── Estado del guardado asincrónico (RF10) ───────────────
## Un solo pipeline de IO por vez: la segunda petición se ENCOLA (profundidad 1,
## "la última gana") en vez de escribir dos veces el mismo archivo.
var _hilo_guardado: Thread = null
var _guardado_en_curso: bool = false
var _slot_en_curso: int = -1
var _cola_guardado: Dictionary = {}
var _ultimo_resultado_async: Dictionary = {}
## iter. 3 (T-164): el hilo ESCRIBE el progreso (float) y el hilo principal lo
## LEE en _process() para emitir la señal (las señales deben salir del
## principal). Escritura de un float = atómica para este uso.
var _progreso_hilo: float = 0.0
var _ultimo_progreso_emitido: float = -1.0
## iter. 3 (T-018): provider de la sección "buildings" registrado en M59.
var _provider_buildings: BuildingsSaveProvider = null

func _ready() -> void:
	_registrar_servicio()
	_registrar_provider_buildings()
	print("[M60] DataStore listo (VERSION_ACTUAL=%d)" % VERSION_ACTUAL)

## iter. 3 (T-018): publica el provider de la sección "buildings" (M17/M18) en
## el registro de M59. Idempotente y tolerante: si M59 no está o la sección ya
## la reclamó otro provider, se omite sin romper el arranque.
func _registrar_provider_buildings() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null or not sm.has_method("register_provider"):
		print("[M60] SaveManager ausente; provider 'buildings' no registrado")
		return
	_provider_buildings = BuildingsSaveProvider.new()
	if sm.register_provider(_provider_buildings):
		print("[M60] Provider 'buildings' registrado (fuente activa: %s)"
			% str(_provider_buildings.tiene_fuente()))
	else:
		_provider_buildings = null

## Cierre ordenado: unir el hilo de guardado antes de morir. Sin esto el
## Thread queda como objeto filtrado al salir (warning ObjectDB leaked).
func _exit_tree() -> void:
	if _hilo_guardado != null:
		if _hilo_guardado.is_started():
			_hilo_guardado.wait_to_finish()
		_hilo_guardado = null
	_guardado_en_curso = false
	_slot_en_curso = -1
	_cola_guardado = {}

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
		mantener_backups(slot)  # iter. 3 (T-109): ventana de copias

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

## ── Partida: guardado ASINCRÓNICO (RF10) ────────────────

## true si hay un guardado asincrónico en curso (el hilo está vivo).
func guardado_en_curso() -> bool:
	return _guardado_en_curso

## Slot del guardado en curso (-1 si no hay ninguno).
func slot_en_curso() -> int:
	return _slot_en_curso

## iter. 3 (T-164): progreso del guardado asincrónico, 0.0..1.0 (1.0 = listo).
## Alternativa por polling a la señal `guardado_async_progreso` (M53).
func progreso_guardado() -> float:
	if not _guardado_en_curso:
		return 1.0 if not _ultimo_resultado_async.is_empty() else 0.0
	return _progreso_hilo

## Resultado del último guardado asincrónico terminado ({} si aún no hubo).
## Mismo formato que el Dictionary que devuelve `guardar_partida`.
func ultimo_resultado_async() -> Dictionary:
	return _ultimo_resultado_async

## Guarda una partida FUERA del hilo principal (RF10).
##
## Contrato:
##  - El Dictionary se COPIA en profundidad (`duplicate(true)`) en el hilo
##    llamador: el consumidor puede seguir mutando su copia sin corromper la
##    escritura en curso (thread-safety sin locks).
##  - Si ya hay un guardado en curso, la petición se ENCOLA (profundidad 1,
##    "la última gana") en vez de escribir dos veces el mismo archivo
##    (edge case: doble guardado concurrente).
##  - Al terminar emite `guardado_slot` (misma señal que la vía sincrónica),
##    así M59/M53 no necesitan dos caminos de UI.
## Devuelve {ok, aceptado, encolado, reemplazo, error}.
func guardar_partida_async(slot: int, datos_sistemas: Dictionary) -> Dictionary:
	if slot < 1 or slot > GestorSlot.SLOT_COUNT:
		return {"ok": false, "aceptado": false, "encolado": false, "reemplazo": false,
			"error": "slot fuera de rango: %d" % slot}

	if _guardado_en_curso:
		var reemplazo: bool = not _cola_guardado.is_empty()
		_cola_guardado = {"slot": slot, "datos": datos_sistemas.duplicate(true)}
		emit_signal("guardado_async_encolado", slot, reemplazo)
		_log_m60("info", "Guardado async slot %d encolado (reemplazo=%s)" % [slot, str(reemplazo)])
		return {"ok": true, "aceptado": true, "encolado": true, "reemplazo": reemplazo, "error": ""}

	_arrancar_hilo_guardado(slot, datos_sistemas.duplicate(true))
	return {"ok": true, "aceptado": true, "encolado": false, "reemplazo": false, "error": ""}

## Arranca el hilo de guardado. Si el motor no puede crear el hilo, cae al
## camino sincrónico (nunca se pierde un guardado por falta de hilo).
func _arrancar_hilo_guardado(slot: int, datos: Dictionary) -> void:
	_guardado_en_curso = true
	_slot_en_curso = slot
	_progreso_hilo = 0.0
	_ultimo_progreso_emitido = -1.0
	_hilo_guardado = Thread.new()
	var err := _hilo_guardado.start(_tarea_guardado.bind(slot, datos))
	if err != OK:
		_hilo_guardado = null
		_guardado_en_curso = false
		_slot_en_curso = -1
		push_warning("[M60] No se pudo crear el hilo de guardado (err=%d); fallback sincrónico" % err)
		_ultimo_resultado_async = guardar_partida(slot, datos)
		return
	emit_signal("guardado_async_iniciado", slot)
	emit_signal("guardado_async_progreso", slot, 0.0)

## Cuerpo del hilo: SOLO IO y helpers puros (sin árbol de escena, sin señales,
## sin autoloads). Todo lo que toque el motor se hace en `_finalizar_hilo_guardado`.
func _tarea_guardado(slot: int, datos: Dictionary) -> Dictionary:
	var inicio := Time.get_ticks_msec()
	var ok := false
	var error_final := ""
	var payload_str := ""

	_progreso_hilo = 0.05
	var err_dir := GestorSlot.asegurar_directorio(slot)
	if err_dir != OK and err_dir != ERR_CANT_CREATE:
		error_final = "no se pudo crear directorio (err=%d)" % err_dir
	else:
		_progreso_hilo = 0.25
		var escritura := _escribir_save_con_payload(slot, datos)
		ok = bool(escritura.get("ok", false))
		payload_str = String(escritura.get("payload_str", ""))
		if not ok:
			error_final = "fallo de escritura del save"
		else:
			_progreso_hilo = 0.60
			var err_meta := _escribir_meta(slot)
			if err_meta != OK:
				error_final = "fallo de escritura de meta"

	if ok:
		var chunks: int = int(datos.get("mundo_voxel", {}).get("chunks_editados", 0))
		if chunks > 0:
			_progreso_hilo = 0.75
			_guardar_voxel_binario(slot, datos.get("mundo_voxel", {}))
	_progreso_hilo = 0.95

	return {
		"slot": slot,
		"ok": ok,
		"error": error_final,
		"duracion_ms": Time.get_ticks_msec() - inicio,
		"bytes": _bytes_write(slot),
		"checksum": Validador.crc32_hex(payload_str),
		"hilo": true,
	}

## Poll del hilo en el hilo principal (barato: is_alive() + comparar un float).
## También propaga el progreso: la señal sale SIEMPRE del hilo principal.
func _process(_delta: float) -> void:
	if _hilo_guardado == null:
		return
	if _hilo_guardado.is_alive():
		if _progreso_hilo != _ultimo_progreso_emitido:
			_ultimo_progreso_emitido = _progreso_hilo
			emit_signal("guardado_async_progreso", _slot_en_curso, _progreso_hilo)
		return
	_finalizar_hilo_guardado()

## Une el hilo, emite el resultado en el hilo principal y arranca la cola.
func _finalizar_hilo_guardado() -> void:
	var crudo: Variant = _hilo_guardado.wait_to_finish()
	_hilo_guardado = null
	_guardado_en_curso = false
	_slot_en_curso = -1

	var resultado: Dictionary = crudo if typeof(crudo) == TYPE_DICTIONARY else {}
	_ultimo_resultado_async = resultado

	var slot: int = int(resultado.get("slot", -1))
	var ok: bool = bool(resultado.get("ok", false))
	var duracion: int = int(resultado.get("duracion_ms", 0))
	var bytes: int = int(resultado.get("bytes", 0))
	emit_signal("guardado_async_progreso", slot, 1.0)
	_ultimo_progreso_emitido = -1.0
	emit_signal("guardado_slot", slot, ok, duracion, bytes)

	if ok:
		_log_m60("info", "Save slot %d escrito en hilo secundario (%d bytes, %d ms)" % [slot, bytes, duracion])
	else:
		push_error("[M60] Guardado async slot %d falló: %s" % [slot, String(resultado.get("error", ""))])

	if not _cola_guardado.is_empty():
		var siguiente: Dictionary = _cola_guardado
		_cola_guardado = {}
		_arrancar_hilo_guardado(int(siguiente.get("slot", -1)), siguiente.get("datos", {}))

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
		_log_m60("error", "rechazo del slot %d: versión más nueva que este juego (VERSION_ACTUAL=%d)"
			% [slot, VERSION_ACTUAL])
		return {"ok": false, "error": "versión más nueva que este juego (VERSION_ACTUAL=%d)" % VERSION_ACTUAL}

	# Migración ascendente (RF7) sobre copia en memoria
	var version_origen: int = int(datos.get("version", 0))
	var migrado := Versionador.migrar(datos)
	if not migrado["ok"]:
		# iter. 4 (ítem 55): la migración es en memoria; si falla NO se toca el
		# archivo en disco (no hace falta restaurar el .bak: nada se escribió).
		_log_m60("error", "migración fallida en el slot %d (v%d): %s"
			% [slot, version_origen, String(migrado.get("error", "desconocido"))])
		return {"ok": false, "error": "migración fallida: %s" % migrado.get("error", "desconocido")}
	datos = migrado["datos"]

	# iter. 4 (ítem 56): registrar el salto REAL de versión (origen -> destino).
	var version_destino: int = int(datos.get("version", version_origen))
	if version_destino != version_origen:
		_log_m60("info", "save del slot %d migrado v%d -> v%d" % [slot, version_origen, version_destino])

	# Contrato de la versión destino
	var errores := Validador.validar_contrato(datos, int(datos.get("version", 0)))
	if not errores.is_empty():
		# iter. 4 (ítem 69): el resultado de la validación se vuelca al log (M103).
		_log_m60("error", "contrato inválido en el slot %d: %s" % [slot, "; ".join(errores)])
		return {"ok": false, "error": "contrato inválido: %s" % "; ".join(errores)}

	# iter. 4 (edge case ítem 155): si el slot perdió su meta.json, regenerarla
	# para que el menú de M59/M53 lo vuelva a listar.
	if _regenerar_meta_si_falta(slot):
		_log_m60("info", "meta.json regenerada en el slot %d" % slot)

	# mundo voxel adjunto (RF4) si el save lo referencia
	datos["_voxel_payload"] = cargar_mundo_voxel(slot)
	emit_signal("cargado_slot", slot, true, "")
	_log_m60("info", "Save slot %d cargado y validado (versión %d)" % [slot, version_destino])
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
## iter. 3 (T-145/T-200): prefiere el archivo comprimido si existe; cae al
## plano sin cambiar el contrato (misma PackedByteArray IAVX1).
func cargar_mundo_voxel(slot: int) -> PackedByteArray:
	var r := GestorSlot.rutas_slot(slot)
	var comprimido: String = String(r["voxel"]) + SUFIJO_DEFLATE
	if FileAccess.file_exists(comprimido):
		var f := FileAccess.open_compressed(comprimido, FileAccess.READ, FileAccess.COMPRESSION_DEFLATE)
		if f != null:
			var largo := f.get_length()
			var buf := f.get_buffer(largo)
			f.close()
			return buf
		push_warning("[M60] No se pudo leer %s; se intenta el binario plano" % comprimido)
	if not FileAccess.file_exists(r["voxel"]):
		return PackedByteArray()
	return FileAccess.get_file_as_bytes(r["voxel"])

## ── Compresión del voxel (T-145/T-200) ──────────────────────
##
## Comprime `mundo_voxel.bin` con ZIP_DEFLATE SOLO si supera
## UMBRAL_COMPRESION_BYTES y la compresión realmente reduce el tamaño. Cuando
## gana, el archivo plano se elimina y queda `mundo_voxel.bin.deflate`;
## `cargar_mundo_voxel` lo detecta solo (contrato intacto).
## Devuelve {ok, comprimido, bytes_antes, bytes_despues, motivo, error}.
func comprimir_mundo_voxel(slot: int) -> Dictionary:
	var r := GestorSlot.rutas_slot(slot)
	var plano: String = String(r["voxel"])
	var comprimido := plano + SUFIJO_DEFLATE

	# Ya comprimido (el plano se borró al comprimir): no re-comprimir.
	if FileAccess.file_exists(comprimido) and not FileAccess.file_exists(plano):
		var antes_estimado := 0
		var f0 := FileAccess.open_compressed(comprimido, FileAccess.READ, FileAccess.COMPRESSION_DEFLATE)
		if f0 != null:
			antes_estimado = f0.get_length()
			f0.close()
		return {"ok": true, "comprimido": true, "bytes_antes": antes_estimado,
			"bytes_despues": FileAccess.get_file_as_bytes(comprimido).size(),
			"motivo": "ya comprimido", "error": ""}

	if not FileAccess.file_exists(plano):
		return {"ok": false, "comprimido": false, "bytes_antes": 0, "bytes_despues": 0,
			"motivo": "", "error": "no existe mundo_voxel.bin en el slot %d" % slot}

	var crudo := FileAccess.get_file_as_bytes(plano)
	var antes := crudo.size()
	if antes < UMBRAL_COMPRESION_BYTES:
		return {"ok": true, "comprimido": false, "bytes_antes": antes, "bytes_despues": antes,
			"motivo": "bajo el umbral (%d < %d)" % [antes, UMBRAL_COMPRESION_BYTES], "error": ""}

	var f := FileAccess.open_compressed(comprimido, FileAccess.WRITE, FileAccess.COMPRESSION_DEFLATE)
	if f == null:
		return {"ok": false, "comprimido": false, "bytes_antes": antes, "bytes_despues": antes,
			"motivo": "", "error": "no se pudo abrir %s" % comprimido}
	f.store_buffer(crudo)
	f.close()

	var en_disco := FileAccess.get_file_as_bytes(comprimido).size()
	if en_disco >= antes:
		DirAccess.remove_absolute(comprimido)
		return {"ok": true, "comprimido": false, "bytes_antes": antes, "bytes_despues": antes,
			"motivo": "la compresión no reduce (%d >= %d)" % [en_disco, antes], "error": ""}

	DirAccess.remove_absolute(plano)
	print("[M60] Voxel comprimido (slot %d): %d -> %d bytes (-%d%%)"
		% [slot, antes, en_disco, int(100.0 * (1.0 - float(en_disco) / float(antes)))])
	return {"ok": true, "comprimido": true, "bytes_antes": antes, "bytes_despues": en_disco,
		"motivo": "", "error": ""}

## Descomprime el voxel a la forma plana canónica (revierte la compresión).
## Devuelve {ok, bytes} — útil para builds que no quieran el .deflate.
func descomprimir_mundo_voxel(slot: int) -> Dictionary:
	var r := GestorSlot.rutas_slot(slot)
	var plano: String = String(r["voxel"])
	var comprimido := plano + SUFIJO_DEFLATE
	if not FileAccess.file_exists(comprimido):
		return {"ok": false, "bytes": 0}
	var datos := cargar_mundo_voxel(slot)
	var f := FileAccess.open(plano, FileAccess.WRITE)
	if f == null:
		return {"ok": false, "bytes": 0}
	f.store_buffer(datos)
	f.close()
	DirAccess.remove_absolute(comprimido)
	return {"ok": true, "bytes": datos.size()}

## ── Backups (T-109, coordinado con M107) ────────────────────

## Copias de backup disponibles del save de un slot (0 = `.bak` más reciente).
func copias_backup(slot: int) -> Array[String]:
	return GestorBackups.listar(String(GestorSlot.rutas_slot(slot)["save"]))

## Restaura una copia de backup del save del slot (M107).
func restaurar_backup(slot: int, indice: int = 0) -> Error:
	return GestorBackups.restaurar(String(GestorSlot.rutas_slot(slot)["save"]), indice)

## Rota/limpia los backups del slot según la política (ventana MAX_BACKUPS).
func mantener_backups(slot: int) -> Dictionary:
	return GestorBackups.mantener_slot(slot)

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
## Devuelve {ok, payload_str}: el payload_str permite calcular el checksum
## sin releer el archivo (lo usan la vía sincrónica y el hilo de RF10).
func _escribir_save_con_payload(slot: int, datos_sistemas: Dictionary) -> Dictionary:
	var plano := Serializer.a_plano(datos_sistemas)
	plano["version"] = VERSION_ACTUAL
	# iter. 4 (ítem 66): detección temprana — validar ANTES de escribir. Es
	# diagnóstico NO bloqueante: avisa al log pero jamás impide el guardado
	# (un save parcial legítimo no debe perderse por un bloque ausente).
	if VALIDAR_AL_GUARDAR:
		var errores := Validador.validar_contrato(plano, VERSION_ACTUAL)
		if not errores.is_empty():
			_log_m60("error", "detección temprana: el save del slot %d no cumple el contrato v%d: %s"
				% [slot, VERSION_ACTUAL, "; ".join(errores)])
	# orden determinista para el checksum: el payload_str es la fuente de verdad
	var payload_str := Serializer.a_json(plano)
	var contenido := WriterAtomico.construir_con_checksum(payload_str)
	var r := GestorSlot.rutas_slot(slot)
	var err := WriterAtomico.escribir_atomicamente(r["save"], contenido)
	if err != OK:
		push_error("[M60] guardar save.json falló (err=%d)" % err)
		return {"ok": false, "payload_str": payload_str}
	return {"ok": true, "payload_str": payload_str}

func _escribir_save(slot: int, datos_sistemas: Dictionary) -> bool:
	return bool(_escribir_save_con_payload(slot, datos_sistemas).get("ok", false))

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
	# iter. 3 (T-145/T-200): compresión bajo criterio de tamaño (no-op si no aplica)
	comprimir_mundo_voxel(slot)

## Intenta restaurar el .bak (recuperación de una corrupción).
func _intentar_restauracion(slot: int) -> bool:
	var r := GestorSlot.rutas_slot(slot)
	var err := WriterAtomico.restaurar_backup(r["save"])
	if err == OK:
		print("[M60] Save restaurado desde backup (slot %d)" % slot)
		return true
	return false

## iter. 4 (RF12/M103): registro centralizado de las operaciones de datos.
## Tolerante: si M103 (GameLogger) no está cargado — headless, tests — no hace
## nada. `nivel` es "info" o "error".
func _log_m60(nivel: String, mensaje: String) -> void:
	var logger := get_node_or_null("/root/GameLogger")
	if logger == null:
		return
	if nivel == "error" and logger.has_method("error"):
		logger.error("[M60] " + mensaje)
	elif logger.has_method("info"):
		logger.info("[M60] " + mensaje)

## iter. 4 (edge case ítem 155): regenera `meta.json` si el slot tiene
## save.json pero perdió su metadata (borrado a mano, escritura interrumpida).
## Sin esto, `listar_slots()` no devuelve el slot y el menú lo "pierde".
## Devuelve true si escribió la metadata.
func _regenerar_meta_si_falta(slot: int) -> bool:
	var r := GestorSlot.rutas_slot(slot)
	if FileAccess.file_exists(r["meta"]):
		return false
	var meta := GestorSlot.meta_default(slot)
	meta["regenerada"] = true
	return GestorSlot.escribir_meta(slot, meta) == OK

## Bytes escritos en disco para el slot (PURO diagnóstico para la señal).
func _bytes_write(slot: int) -> int:
	var r := GestorSlot.rutas_slot(slot)
	var total := 0
	for clave in ["save", "voxel", "meta"]:
		var p: String = r[clave]
		if FileAccess.file_exists(p):
			total += FileAccess.get_file_as_bytes(p).size()
	return total