# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — Test headless del núcleo (autoload CrashReporter).
# Valida: reportar_crash -> dump JSON en user://crash/, enviar_dump con reintentos (máx 3),
# dumps_pendientes/cantidad_dumps.
#
# Iter. P-36 (2026-09-25, Log 1150): ENDURECIDO con el guardián de 3 capas. Antes esta suite
# estaba en **ROJO** (12 checks, 2 fallos) porque `dumps_pendientes()` usaba
# `DirAccess.open("user://...")`, que devuelve null en headless (pitfall §9.6). La nota del
# checklist afirmaba "12 checks, 0 fallos (Log 518)" -> era un FALSO VERDE. El bug se corrigió en
# `crash_reporter.gd` (`_abrir_dir` tolerante) y la suite se blinda para que un aborto no pase
# como "0 fallos".
#
# ⚠️ Los dumps de este test NO se limpian a propósito: `user://crash/` es el directorio real del
# módulo y sirve como evidencia de que la captura funciona. No contamina saves.

extends SceneTree

const BLOQUES := ["A", "B", "C"]
const CHECKS_MINIMOS := 13   # medido en verde, no estimado

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""
var _cerrados: Array = []

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")   # corre aunque _run() aborte a mitad de frame (trampa 62)

func _run() -> void:
	print("=== [M122] Test de Crash Reporting ===")
	_bloque = "A"; _test_reporter()
	_bloque = "B"; _test_envio()
	_bloque = "C"; _test_dumps()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _fin(nombre: String) -> void:
	_cerrados.append(nombre)

func _test_reporter() -> void:
	print("--- A. CrashReporter: dump JSON ---")
	var cr := root.get_node_or_null("CrashReporter")
	_check("CrashReporter autoload presente", cr != null)
	if cr == null:
		return
	var ruta: String = cr.reportar_crash("null_error", "objeto null", ["func_a:10", "func_b:20"])
	_check("dump escrito", ruta != "" and FileAccess.file_exists(ruta))
	if FileAccess.file_exists(ruta):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		_check("dump JSON válido", typeof(parsed) == TYPE_DICTIONARY)
		var d: Dictionary = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
		_check("dump con stack", (d.get("stack", []) as Array).size() == 2)
		_check("dump con sesión", String(d.get("session", "")) != "")
	else:
		_check("dump JSON válido", false, "no existe el archivo")
		_check("dump con stack", false, "no existe el archivo")
		_check("dump con sesión", false, "no existe el archivo")
	_fin("A")

func _test_envio() -> void:
	print("--- B. CrashReporter: envío con reintentos ---")
	var cr := root.get_node_or_null("CrashReporter")
	if cr == null:
		return
	var ruta: String = cr.reportar_crash("script_error", "parse", ["a:1"])
	_check("envío 1er intento ok", cr.enviar_dump(ruta) == true)
	_check("envío 2do intento ok", cr.enviar_dump(ruta) == true)
	_check("envío 3er intento ok", cr.enviar_dump(ruta) == true)
	_check("envío 4to intento falla (máx 3)", cr.enviar_dump(ruta) == false)
	_check("envío ruta inexistente falla", cr.enviar_dump("user://no_existe.json") == false)
	_fin("B")

func _test_dumps() -> void:
	print("--- C. CrashReporter: dumps pendientes (bug headless corregido) ---")
	var cr := root.get_node_or_null("CrashReporter")
	if cr == null:
		return
	var cantidad: int = cr.cantidad_dumps()
	_check("dumps en disco (>=2)", cantidad >= 2, "count=%d" % cantidad)
	var pendientes: Array = cr.dumps_pendientes()
	_check("dumps_pendientes lista JSON", pendientes.size() >= 2)
	_check("dumps_pendientes ordenado", _esta_ordenado(pendientes), str(pendientes))
	_fin("C")

func _esta_ordenado(lista: Array) -> bool:
	for i in range(1, lista.size()):
		if str(lista[i - 1]) > str(lista[i]):
			return false
	return true

## Guardián de 3 capas: (1) nombra los bloques que NO cerraron; (2) piso de checks medido en verde.
func _summary() -> void:
	var faltantes: Array = []
	for b in BLOQUES:
		if not _cerrados.has(b):
			faltantes.append(b)
	print("=== Resumen M122: %d checks, %d fallos ===" % [_checks, _fallos])
	if not faltantes.is_empty():
		print("[FAIL] bloques que NO se ejecutaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		print("[FAIL] checks ejecutados (%d) por debajo del piso (%d)" % [_checks, CHECKS_MINIMOS])
	if _fallos > 0 or not faltantes.is_empty() or _checks < CHECKS_MINIMOS:
		print("TEST M122 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M122 OK — todos los checks pasaron")
		quit(0)
