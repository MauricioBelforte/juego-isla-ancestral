# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M103: Logging - CrashLogBridge (RF18, 03-Diseno.md seccion 8).
#
# Cierra el hueco que el checklist de M103 marcaba como `[?]` con la nota
# "integracion con M122 NO implementada: el modulo consumidor no existe todavia".
# MEDIDO el 2026-10-21: M122 SI existe (12 scripts en `scripts/crash/`, autoload
# `CrashReporter` en project.godot:106 y `crash_logging.gd` con la integracion
# DISENADA). Lo que faltaba no era el consumidor: era que **nadie llamaba** a
# `Logger.flush()` ni exportaba el buffer al detectarse un crash (el helper de
# M122 solo lo usaba su propia suite -> codigo muerto en produccion).
#
# El diseno 03-Diseno.md seccion 8 pide, al detectar un crash:
#   1. M122 llama a Logger.flush() para forzar escritura
#   2. se exporta el buffer de logs a crash_{timestamp}.log
#   3. el archivo se adjunta al reporte de crash
#   4. el reporte incluye metadata (version, plataforma, specs, ultimas 1000 lineas)
#
# Direccion de la dependencia: M103 -> M122 (M103 es el proveedor del log; M122 el
# consumidor). Por eso este puente vive en `scripts/logging/` y NO se toca ningun
# archivo de `scripts/crash/`: el enganche es la SENAL publica `crash_reportado`
# del autoload `CrashReporter` (crash_reporter.gd:17), que ya existia.
#
# Contrato fail-closed (misma doctrina que crash_logging.gd de M122): si el logger
# no expone `export_last_lines`, no se inventa un archivo vacio; se devuelve "" y
# no se escribe NADA. Un archivo de crash con 0 lineas es peor que ninguno.
#
# RefCounted sin `class_name` (se usa por `preload`), pitfall del proyecto: un
# `class_name` nuevo no existe para `--script` hasta regenerar la cache de clases.

extends RefCounted

## Ultimas N lineas del buffer que viajan en el crash log (03-Diseno.md seccion 8.4).
const N_LINEAS_CRASH := 1000
## Directorio por defecto: junto a los logs de M103 (`user://logs/game.log`).
const DIR_DEFECTO := "user://logs"
const PREFIJO := "crash_"
const SUFIJO := ".log"
## Senal publica de M122 que dispara el volcado.
const SENAL_M122 := "crash_reportado"

## Ultima ruta escrita (observabilidad para la suite; no la usa produccion).
var ultima_ruta: String = ""
## Cuantas veces se disparo el volcado por senal.
var volcados: int = 0
## Callables conectados, por id de instancia del emisor (idempotencia).
var _conexiones: Dictionary = {}


## Nombre de archivo a partir de un timestamp ISO. Los `:` no son validos en
## nombres de archivo de Windows, asi que se sustituyen por `-`.
func nombre_archivo(ts: String) -> String:
	return PREFIJO + ts.replace(":", "-") + SUFIJO


## Ruta completa del crash log dentro de `dir`.
func ruta_crash(ts: String, dir: String = DIR_DEFECTO) -> String:
	return dir.rstrip("/") + "/" + nombre_archivo(ts)


## Timestamp del dump si lo trae; si no, el del sistema. Se aceptan las dos
## vocabularios del dump de M122 (ingles del diseno y espanol del autoload).
func _timestamp(dump: Dictionary) -> String:
	for clave in ["timestamp", "ts", "fecha"]:
		if dump.has(clave):
			var v: String = str(dump.get(clave, ""))
			if not v.is_empty():
				return v
	return Time.get_datetime_string_from_system()


## Motivo legible del crash (una sola linea, sin saltos).
func _motivo(dump: Dictionary) -> String:
	for clave in ["error", "tipo", "message", "mensaje"]:
		if dump.has(clave):
			var v: String = str(dump.get(clave, "")).replace("\n", " ").replace("\r", " ")
			if not v.is_empty():
				return v
	return "desconocido"


## Metadata que el reporte adjunta (03-Diseno.md seccion 8.4): version, plataforma,
## specs y cuantas lineas se volcaron.
func metadata(dump: Dictionary, n_lineas: int) -> Dictionary:
	var version: String = str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
	var sesion: String = ""
	for clave in ["session_id", "sesion", "session"]:
		if dump.has(clave):
			sesion = str(dump.get(clave, ""))
			break
	return {
		"version": version,
		"plataforma": OS.get_name(),
		"cpu": OS.get_processor_name(),
		"nucleos": OS.get_processor_count(),
		"sesion": sesion,
		"motivo": _motivo(dump),
		"lineas": n_lineas,
		"timestamp": _timestamp(dump),
	}


## Encabezado del archivo. ASCII puro a proposito: un crash log se lee con
## herramientas que no siempre asumen UTF-8.
func encabezado(meta: Dictionary) -> PackedStringArray:
	var l := PackedStringArray()
	l.append("# CRASH LOG - M103 Logging (RF18 / 03-Diseno.md seccion 8)")
	l.append("# generado: %s" % str(meta.get("timestamp", "")))
	l.append("# version: %s | plataforma: %s | cpu: %s | nucleos: %d" % [
		str(meta.get("version", "")), str(meta.get("plataforma", "")),
		str(meta.get("cpu", "")), int(meta.get("nucleos", 0))])
	l.append("# sesion: %s | motivo: %s | lineas: %d" % [
		str(meta.get("sesion", "")), str(meta.get("motivo", "")), int(meta.get("lineas", 0))])
	l.append("# --- inicio del buffer de log ---")
	return l


## Contrato minimo del logger para que el volcado tenga sentido.
func _logger_utilizable(logger: Object) -> bool:
	return logger != null and logger.has_method("export_last_lines")


## Vuelca el buffer del logger a `crash_{timestamp}.log`. Devuelve la ruta escrita
## o "" si no se pudo (fail-closed: en ese caso NO se escribe ningun archivo).
func exportar(dump: Dictionary, logger: Object, dir: String = DIR_DEFECTO) -> String:
	if not _logger_utilizable(logger):
		return ""
	# Paso 1 del diseno: forzar la escritura ANTES de leer el archivo.
	if logger.has_method("flush"):
		logger.call("flush")
	var texto: String = str(logger.call("export_last_lines", N_LINEAS_CRASH))
	if texto.is_empty():
		return ""
	var lineas := PackedStringArray()
	for linea in texto.split("\n", false):
		lineas.append(linea)
	var meta := metadata(dump, lineas.size())
	DirAccess.make_dir_recursive_absolute(dir)
	var ruta := ruta_crash(str(meta.get("timestamp", "")), dir)
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		return ""
	for l in encabezado(meta):
		f.store_line(l)
	for l in lineas:
		f.store_line(l)
	f.flush()
	f.close()
	ultima_ruta = ruta
	return ruta


## Conecta la senal `crash_reportado` de M122 al volcado. Idempotente: llamarla dos
## veces deja UNA sola conexion. Devuelve false si el emisor no expone la senal.
func conectar(emisor: Object, logger: Object, dir: String = DIR_DEFECTO) -> bool:
	if emisor == null or not emisor.has_signal(SENAL_M122):
		return false
	if not _logger_utilizable(logger):
		return false
	var clave: int = emisor.get_instance_id()
	if _conexiones.has(clave):
		return true
	var cb := Callable(self, "_on_crash_reportado").bind(logger, dir)
	emisor.connect(SENAL_M122, cb)
	_conexiones[clave] = cb
	return true


## ¿Hay una conexion viva con este emisor?
func esta_conectado(emisor: Object) -> bool:
	if emisor == null:
		return false
	return _conexiones.has(emisor.get_instance_id())


## Desconecta (util para tests aislados y para no dejar senales colgadas).
func desconectar(emisor: Object) -> bool:
	if emisor == null:
		return false
	var clave: int = emisor.get_instance_id()
	if not _conexiones.has(clave):
		return false
	var cb: Callable = _conexiones[clave]
	if emisor.is_connected(SENAL_M122, cb):
		emisor.disconnect(SENAL_M122, cb)
	_conexiones.erase(clave)
	return true


## Handler de la senal: el dump de M122 llega como unico argumento; `logger` y `dir`
## vienen fijados por `bind`.
func _on_crash_reportado(dump: Dictionary, logger: Object, dir: String) -> void:
	volcados += 1
	exportar(dump, logger, dir)
