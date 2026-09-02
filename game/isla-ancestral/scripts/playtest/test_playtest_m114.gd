# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M114: Playtest — Test headless
# Valida: PlaytestValidator (sesiones, encuestas, índice de tono cozy,
# hallazgos, metas por hito). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/playtest/playtest_validator.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M114] Test de Playtest ===")
	var v = _SC_VALIDATOR.new()
	v.cargar_schema()
	_test_sesion(v)
	_test_encuesta(v)
	_test_tono(v)
	_test_hallazgo(v)
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_sesion(v) -> void:
	print("--- Sesión: campos obligatorios y tipos ---")
	var ok_sesion = v.validar_sesion({"build": "abc123", "fecha": "2026-09-02", "ronda": "R1", "tipo": "GUIADA"})
	_check("sesión válida", ok_sesion.is_empty(), "errores=%s" % str(ok_sesion))
	var falta_build = v.validar_sesion({"fecha": "2026-09-02", "ronda": "R1", "tipo": "GUIADA"})
	_check("falta build detectado", not falta_build.is_empty())
	var tipo_malo = v.validar_sesion({"build": "a", "fecha": "d", "ronda": "r", "tipo": "INVALIDO"})
	_check("tipo inválido detectado", str(tipo_malo).contains("inválido"))

func _test_encuesta(v) -> void:
	print("--- Encuesta: 7 respuestas en rango 1-5 ---")
	var ok = v.validar_encuesta([2, 3, 2, 4, 4, 4, 3])
	_check("encuesta válida", ok.is_empty(), "errores=%s" % str(ok))
	var fuera = v.validar_encuesta([1, 2, 3, 4, 5, 6, 7])
	_check("valor fuera de rango detectado", not fuera.is_empty())
	var corta = v.validar_encuesta([1, 2, 3])
	_check("encuesta corta detectada", str(corta).contains("7"))

func _test_tono(v) -> void:
	print("--- Índice de tono cozy + metas ---")
	# Estrés 2, Abrum 3, Aburr 2 | Tranquilo 4, Disfrute 4, Agencia 3 -> (11/3)-(7/3)=3.67-2.33=1.33
	var tono = v.calcular_tono([2, 3, 2, 4, 4, 3, 4])
	_check("tono calculado ~1.33", abs(tono - 1.33) < 0.01, "tono=%f" % tono)
	_check("meta prototipo alcanzada (0.5)", v.meta_tono_alcanzado(tono, "prototipo") == true)
	_check("meta prealpha alcanzada (1.0)", v.meta_tono_alcanzado(tono, "prealpha") == true)
	var negativo = v.calcular_tono([4, 4, 3, 2, 2, 2, 1])
	_check("tono negativo = -1.67", abs(negativo - (-1.67)) < 0.01, "tono=%f" % negativo)
	_check("meta no alcanzada con negativo", v.meta_tono_alcanzado(negativo, "prototipo") == false)

func _test_hallazgo(v) -> void:
	print("--- Hallazgo: severidad y módulo ---")
	var ok = v.validar_hallazgo({"severidad": "S2", "modulo": "M102"})
	_check("hallazgo válido", ok.is_empty(), "errores=%s" % str(ok))
	var sev_mala = v.validar_hallazgo({"severidad": "S9", "modulo": "M102"})
	_check("severidad inválida detectada", str(sev_mala).contains("Severidad"))
	var mod_malo = v.validar_hallazgo({"severidad": "S1", "modulo": "M999"})
	_check("módulo inválido detectado", str(mod_malo).contains("Módulo"))

func _summary() -> void:
	print("=== Resumen M114: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M114 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M114 OK — todos los checks pasaron")
		quit(0)