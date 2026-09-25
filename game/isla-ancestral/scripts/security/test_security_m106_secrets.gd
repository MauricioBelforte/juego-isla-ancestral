# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M106 T-006: Test headless del escáner de secrets hardcodeados.
# Lógica pura + headless-safe. Guardián anti-falso-verde: cada bloque marca `_fin()`;
# fallos reales → exit 1.

extends SceneTree

const _SCAN := preload("res://scripts/security/security_secret_scanner.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M106] Test escáner de secrets ===")
	_bloque = "A"
	_test_deteccion()
	_bloque = "B"
	_test_falsos_positivos()
	_bloque = "C"
	_test_archivo_y_directorio()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── A. detección de secrets hardcodeados ────────────────
func _test_deteccion() -> void:
	print("--- A. detección de secrets hardcodeados ---")
	var sc = _SCAN.new()
	# api key hardcodeada
	var h1: Array = sc.escanear_texto('var api_key = "AIzaSyABCDEFGHIJK123456"')
	_check("api_key hardcodeada detectada", h1.size() == 1, "n=%d" % h1.size())
	# password hardcodeado
	_check("password detectada", sc.escanear_texto('var password = "supersecreto123"').size() == 1)
	# token con comillas simples y operador :=
	_check("token detectada", sc.escanear_texto("var token := 'tok_abcdef123456789'").size() == 1)
	# AWS access key id (formato AKIA...; sin la palabra EXAMPLE para no caer en el filtro de placeholders)
	_check("AWS AKIA detectada", sc.escanear_texto('const AWS_KEY := "AKIAABCDEFGHIJKLMNOP"').size() >= 1)
	# clave privada PEM
	_check("PEM private key detectada", sc.escanear_texto("-----BEGIN RSA PRIVATE KEY-----").size() >= 1)
	# bearer token
	_check("bearer detectada", sc.escanear_texto('var h = "Bearer abcdefghijklmnopqrstuvwxyz012345"').size() >= 1)
	# número de línea correcto
	var multi := "var a = 1\nvar b = 2\nvar secret = \"miclave123456\"\n"
	var hm: Array = sc.escanear_texto(multi)
	_check("número de línea correcto", hm.size() == 1 and hm[0]["linea"] == 3, "linea=%s" % str(hm[0].get("linea") if not hm.is_empty() else -1))
	# fragmento redactado (no expone el valor)
	if not hm.is_empty():
		_check("fragmento redactado (sin secret)", hm[0]["fragmento"].contains("REDACTED") and not hm[0]["fragmento"].contains("miclave123456"))
	_check("fin A", _fin())

## ── B. falsos positivos evitados ────────────────────────
func _test_falsos_positivos() -> void:
	print("--- B. falsos positivos evitados ---")
	var sc = _SCAN.new()
	# comentario que menciona "password" -> ignorado
	_check("comentario ignorado", sc.escanear_texto('# var password = "x" # ver docs').is_empty())
	# placeholder de plantilla -> ignorado
	_check("placeholder ignorado", sc.escanear_texto('var api_key = "YOUR_API_KEY_HERE"').is_empty())
	# carga desde variable de entorno -> ignorado (NO es hardcodear)
	_check("OS.get_environment ignorado", sc.escanear_texto('var key = OS.get_environment("API_KEY")').is_empty())
	# referencia a env -> ignorado
	_check("referencia env. ignorada", sc.escanear_texto('var key = env.API_KEY').is_empty())
	# código normal sin secrets -> vacío
	_check("código limpio -> vacío", sc.escanear_texto('var vida := 100\nvar nombre := "Bruno"').is_empty())
	_check("fin B", _fin())

## ── C. escaneo de archivo y directorio ──────────────────
func _test_archivo_y_directorio() -> void:
	print("--- C. escaneo de archivo y directorio ---")
	var sc = _SCAN.new()
	# archivo inexistente -> []
	_check("archivo inexistente -> []", sc.escanear_archivo("user://no_existe_xyz.gd").is_empty())
	# archivo con secret
	var dir_tmp := "user://scan_test_m106"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_tmp))
	var ruta_mala := dir_tmp + "/config_mala.gd"
	var f := FileAccess.open(ruta_mala, FileAccess.WRITE)
	f.store_string('var password = "hardcodeada123"\n')
	f.close()
	_check("archivo con secret -> 1 hallazgo", sc.escanear_archivo(ruta_mala).size() == 1)
	# archivo limpio
	var ruta_buena := dir_tmp + "/config_buena.gd"
	var f2 := FileAccess.open(ruta_buena, FileAccess.WRITE)
	f2.store_string('var key = OS.get_environment("API_KEY")\n')
	f2.close()
	# directorio: solo reporta el archivo con hallazgos
	var res: Dictionary = sc.escanear_directorio(dir_tmp)
	_check("directorio reporta solo archivo malo", res.size() == 1 and res.has(ruta_mala), "res=%d" % res.size())
	_check("resumen legible", sc.resumen(res).contains("hallazgo"))
	# limpieza
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta_mala))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta_buena))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(dir_tmp))
	_check("fin C", _fin())

## Guardián anti-falso-verde: si un bloque se aborta (SCRIPT ERROR), su `_fin` no corre.
func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M106-secrets: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106-SECRETS FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M106-SECRETS OK — todos los checks pasaron")
		quit(0)
