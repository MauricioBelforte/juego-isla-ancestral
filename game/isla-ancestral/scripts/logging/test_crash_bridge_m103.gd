# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M103: Logging - suite de RF18 (puente de crash log, 03-Diseno.md seccion 8).
#
# Que mide (y que NO): mide el EFECTO observable del puente -- que al detectarse
# un crash se escriba `crash_{timestamp}.log` con las ultimas N lineas y la
# metadata del diseno --, no que exista un metodo con cierto nombre.
#
# Guardas anti-falso-verde (3 capas, obligatorias en este repo):
#   1. `_fin("X")` por bloque + `BLOQUES` -> nombra el bloque que no se ejecuto.
#   2. `CHECKS_MINIMOS` MEDIDO en verde (no estimado) -> un aborto parcial baja el
#      conteo y el resumen sale en rojo.
#   3. `_summary()` en un `call_deferred` SEPARADO del de `_correr()` -> si `_correr()`
#      aborta por un SCRIPT ERROR de runtime, el resumen igual corre y hace quit(1)
#      (un resumen al final de `_correr()` CUELGA la suite: medido en Log 2066).
#
# Los fixtures viven en `OS.get_temp_dir()` (absoluta, FUERA del repo): usar
# `user://` cae dentro de `game/isla-ancestral/Godot/` y ensucia el árbol.

extends SceneTree

const MODULO := "M103"
const _BRIDGE := preload("res://scripts/logging/crash_log_bridge.gd")
const _LOGGER := preload("res://scripts/logging/logger.gd")

const BLOQUES := ["A", "B", "C", "D", "E"]
## Piso MEDIDO en verde el 2026-10-21 (49 checks / 0 fallos / EXIT 0 x3). No estimar.
const CHECKS_MINIMOS := 49

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _base: String = ""


## Emisor falso con la MISMA señal que el autoload de M122 (crash_reporter.gd:17).
class EmisorFalso:
	extends Node
	signal crash_reportado(dump: Dictionary)


## Logger que NO expone `export_last_lines`: sirve para probar el fail-closed.
class LoggerMudo:
	extends RefCounted
	var flushed: int = 0
	func flush() -> void:
		flushed += 1


func _init() -> void:
	call_deferred("_correr")
	call_deferred("_summary")   # corre aunque _correr() aborte


func _check(ok: bool, desc: String) -> void:
	_checks += 1
	if ok:
		print("[OK] %s" % desc)
	else:
		_fallos += 1
		print("[FALLO] %s" % desc)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	print("[FIN] bloque %s (acumulado %d checks)" % [nombre, _checks])


func _summary() -> void:
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	var faltantes: Array = []
	for n in BLOQUES:
		if not _vistos.has(n):
			faltantes.append(n)
	if not faltantes.is_empty():
		_fallos += 1
		print("[FAIL] bloques que NO se ejecutaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	if _fallos == 0:
		print("TEST OK %s" % MODULO)
	else:
		print("TEST FALLIDO %s (%d fallo(s))" % [MODULO, _fallos])
	quit(0 if _fallos == 0 else 1)


## Logger real de M103, aislado en `dir` (sin tocar user:// ni el autoload).
func _logger_en(dir: String) -> Node:
	var l: Node = _LOGGER.new()
	l.call("_load_config")
	l.call("set_console_echo", false)
	l.call("set_log_path", dir + "/game.log")
	l.call("_open_log_file")
	return l


func _escribir(logger: Node, desde: int, hasta: int) -> void:
	for i in range(desde, hasta + 1):
		logger.call("info", "LINEA-%04d" % i, 1)   # Category.SYSTEM == 1


func _lineas_de(ruta: String) -> PackedStringArray:
	if not FileAccess.file_exists(ruta):
		return PackedStringArray()
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return PackedStringArray()
	var txt: String = f.get_as_text()
	f.close()
	var out := PackedStringArray()
	for l in txt.split("\n", false):
		out.append(l)
	return out


func _correr() -> void:
	_base = OS.get_temp_dir().rstrip("/") + "/m103_rf18_" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(_base)
	var b = _BRIDGE.new()
	var dump := {"error": "boom-test", "session_id": "s-123", "timestamp": "2026-10-21T05:00:00"}

	# ── A. Nombres y rutas ────────────────────────────────────────────
	print("--- A. Nombres y rutas ---")
	_check(b.call("nombre_archivo", "2026-10-21T05:00:00") == "crash_2026-10-21T05-00-00.log",
		"A1 nombre con ':' sustituido (valido en Windows)")
	_check(str(b.call("nombre_archivo", "2026-10-21T05:00:00")).begins_with("crash_"),
		"A2 prefijo 'crash_' (no 'export_' del LogExporter)")
	_check(not str(b.call("nombre_archivo", "2026-10-21T05:00:00")).begins_with("export_"),
		"A3 no colisiona con export_{timestamp}.log")
	_check(str(b.call("ruta_crash", "2026-10-21T05:00:00", "user://logs")) == "user://logs/crash_2026-10-21T05-00-00.log",
		"A4 ruta_crash une dir + nombre")
	_check(str(b.call("ruta_crash", "2026-10-21T05:00:00", "user://logs/")) == "user://logs/crash_2026-10-21T05-00-00.log",
		"A5 ruta_crash tolera '/' final (no duplica)")
	_check(str(b.call("ruta_crash", "X", "user://otro")).begins_with("user://otro/"),
		"A6 ruta_crash respeta el directorio pedido")
	_fin("A")

	# ── B. Volcado real: ultimas N lineas ─────────────────────────────
	print("--- B. Volcado real (1200 lineas -> ultimas 1000) ---")
	var dir_b: String = _base + "/b"
	var lg := _logger_en(dir_b)
	_escribir(lg, 1, 1200)
	var ruta_b: String = str(b.call("exportar", dump, lg, dir_b))
	_check(not ruta_b.is_empty(), "B1 exportar devuelve una ruta no vacia")
	_check(FileAccess.file_exists(ruta_b), "B2 el archivo existe en disco")
	_check(ruta_b.get_file() == "crash_2026-10-21T05-00-00.log",
		"B3 el nombre usa el timestamp del DUMP, no el del sistema")
	var lineas_b := _lineas_de(ruta_b)
	var log_b: Array = []
	for l in lineas_b:
		if l.contains("LINEA-"):
			log_b.append(l)
	_check(log_b.size() == 1000, "B4 vuelca exactamente 1000 lineas (medido: %d)" % log_b.size())
	var ultima: String = str(log_b[log_b.size() - 1]) if log_b.size() > 0 else ""
	var primera: String = str(log_b[0]) if log_b.size() > 0 else ""
	_check(ultima.contains("LINEA-1200"), "B5 la ULTIMA linea escrita esta presente")
	_check(not primera.contains("LINEA-0001"), "B6 la primera del archivo NO entra (recorte real)")
	_check(primera.contains("LINEA-0201"), "B7 el recorte empieza en la linea 201 (1200-1000+1)")
	var cab_b: int = lineas_b.size() - log_b.size()
	_check(cab_b == 5, "B8 encabezado de 5 lineas (medido: %d)" % cab_b)
	_check(lg.call("get_log_file_path") == dir_b + "/game.log",
		"B9 el crash log NO pisa el game.log del logger")
	lg.call("set_log_path", dir_b + "/cerrado.log")   # cierra el FileAccess abierto
	_fin("B")

	# ── C. Fail-closed: sin logger valido no se escribe NADA ──────────
	print("--- C. Fail-closed ---")
	var dir_c: String = _base + "/c"
	_check(str(b.call("exportar", dump, null, dir_c)) == "", "C1 logger null -> '' (no inventa)")
	_check(not DirAccess.dir_exists_absolute(dir_c), "C2 con logger null NO se crea el directorio")
	var mudo := LoggerMudo.new()
	_check(str(b.call("exportar", dump, mudo, dir_c)) == "", "C3 logger sin export_last_lines -> ''")
	_check(not DirAccess.dir_exists_absolute(dir_c), "C4 con logger mudo NO se crea ningun archivo")
	_check(mudo.flushed == 0, "C5 al logger mudo ni siquiera se le llama flush (medido: %d)" % mudo.flushed)
	var dir_c2: String = _base + "/c2"
	var lg_vacio := _logger_en(dir_c2)
	_check(str(b.call("exportar", dump, lg_vacio, dir_c2)) == "", "C6 logger valido pero buffer VACIO -> ''")
	_check(lg_vacio.call("get_log_file_path") == dir_c2 + "/game.log",
		"C7 el logger vacio no se rompio (ruta intacta)")
	lg_vacio.call("set_log_path", dir_c2 + "/cerrado.log")
	_fin("C")

	# ── D. Senal de M122 -> volcado automatico ────────────────────────
	print("--- D. Enganche por senal crash_reportado ---")
	var dir_d: String = _base + "/d"
	var lg_d := _logger_en(dir_d)
	_escribir(lg_d, 1, 30)
	var emisor := EmisorFalso.new()
	_check(bool(b.call("conectar", emisor, lg_d, dir_d)), "D1 conectar() con emisor que tiene la senal -> true")
	_check(bool(b.call("esta_conectado", emisor)), "D2 esta_conectado() -> true")
	_check(emisor.get_signal_connection_list("crash_reportado").size() == 1,
		"D3 exactamente 1 conexion (medido: %d)" % emisor.get_signal_connection_list("crash_reportado").size())
	_check(bool(b.call("conectar", emisor, lg_d, dir_d)), "D4 conectar() dos veces sigue devolviendo true")
	_check(emisor.get_signal_connection_list("crash_reportado").size() == 1,
		"D5 idempotente: sigue habiendo 1 conexion (medido: %d)" % emisor.get_signal_connection_list("crash_reportado").size())
	emisor.emit_signal("crash_reportado", dump)
	var ruta_d: String = str(b.get("ultima_ruta"))
	_check(not ruta_d.is_empty() and FileAccess.file_exists(ruta_d), "D6 la senal disparo el volcado en disco")
	_check(int(b.get("volcados")) == 1, "D7 1 volcado por 1 senal (medido: %d)" % int(b.get("volcados")))
	var lineas_d := _lineas_de(ruta_d)
	var log_d: int = 0
	for l in lineas_d:
		if l.contains("LINEA-"):
			log_d += 1
	_check(log_d == 30, "D8 volco las 30 lineas disponibles (medido: %d)" % log_d)
	var sin_senal := Node.new()
	_check(not bool(b.call("conectar", sin_senal, lg_d, dir_d)), "D9 emisor SIN la senal -> false")
	_check(not bool(b.call("esta_conectado", sin_senal)), "D10 un emisor rechazado no queda registrado")
	_check(bool(b.call("desconectar", emisor)), "D11 desconectar() -> true")
	_check(not bool(b.call("esta_conectado", emisor)), "D12 tras desconectar, esta_conectado() -> false")
	sin_senal.free()
	emisor.free()
	lg_d.call("set_log_path", dir_d + "/cerrado.log")
	_fin("D")

	# ── E. Metadata del reporte (03-Diseno 8.4) ───────────────────────
	print("--- E. Metadata ---")
	var meta: Dictionary = b.call("metadata", dump, 1000)
	_check(meta.has("version") and not str(meta.get("version")).is_empty(), "E1 metadata.version presente")
	_check(meta.has("plataforma") and not str(meta.get("plataforma")).is_empty(), "E2 metadata.plataforma presente")
	_check(int(meta.get("lineas")) == 1000, "E3 metadata.lineas = 1000")
	_check(str(meta.get("sesion")) == "s-123", "E4 metadata.sesion sale del dump")
	_check(str(meta.get("motivo")) == "boom-test", "E5 metadata.motivo sale del dump")
	_check(str(meta.get("timestamp")) == "2026-10-21T05:00:00", "E6 metadata.timestamp sale del dump")
	_check(int(meta.get("nucleos")) > 0, "E7 metadata.nucleos > 0 (medido: %d)" % int(meta.get("nucleos")))
	var cab: PackedStringArray = b.call("encabezado", meta)
	_check(cab.size() == 5, "E8 encabezado de 5 lineas")
	var unido := "\n".join(cab)
	_check(unido.contains("CRASH LOG"), "E9 el encabezado se identifica como crash log")
	_check(unido.contains("RF18"), "E10 el encabezado cita RF18 (trazabilidad al requisito)")
	_check(unido.contains(str(meta.get("version"))), "E11 el encabezado lleva la version")
	_check(unido.contains("sesion: s-123"), "E12 el encabezado lleva la sesion")
	var ascii := true
	for ch in unido:
		if ch.unicode_at(0) > 126 or ch.unicode_at(0) < 9:
			ascii = false
	_check(ascii, "E13 el encabezado es ASCII puro")
	var ruta_b2: String = str(b.get("ultima_ruta"))
	var txt_b := "\n".join(_lineas_de(ruta_b2))
	_check(txt_b.contains("# CRASH LOG"), "E14 el archivo escrito contiene el encabezado")
	_check(txt_b.contains("motivo: boom-test"), "E15 el archivo escrito contiene el motivo")
	_fin("E")

	_limpiar()


func _limpiar() -> void:
	for sub in ["b", "c", "c2", "d"]:
		var d: String = _base + "/" + sub
		if not DirAccess.dir_exists_absolute(d):
			continue
		var dir := DirAccess.open(d)
		if dir == null:
			continue
		for f in dir.get_files():
			DirAccess.remove_absolute(d + "/" + f)
		DirAccess.remove_absolute(d)
	DirAccess.remove_absolute(_base)
