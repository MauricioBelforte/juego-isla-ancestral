# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M109: Unit tests RecipeSchema
#
# CONVERTIDO de gdUnit4 a headless (BUG-093, sub-frente) por convertir.py.
# Motivo: la suite gdUnit4 PARSEABA pero MORIA en runtime (metodos
# inexistentes: is_equal_to/is_greater_than/is_instance_of/has_not_contains/
# has_any_item -> 0 apariciones en addons/gdUnit4/). Ademas las suites gdUnit4
# NO se ejecutan en el CI del proyecto (solo `--script`, estandar 12.1).
#
# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS
# MEDIDO + _summary() en call_deferred SEPARADO + watchdog.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/unit/editor/test_recipe_schema.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 10
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F']


## M109 iter 1: tests del núcleo del Editor de Recetas (RecipeSchema).
## Regla: validar() (receta válida/inválida por campos) y roundtrip de costes.

const SCHEMA := preload("res://scripts/editor/support/recipe_schema.gd")


var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== M109 (headless) ===")
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()
	_bloque_F()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M109: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. test_receta_valida_pico_cobre")
	var receta := {
		"nombre": "Pico de cobre", "categoria": "herramientas", "nivel": 1,
		"estacion": "mesa_trabajo", "origen": "inicial",
		"coste_recursos": {"madera_roble": 3, "mineral_cobre": 4},
		"coste_ao": 0, "resultado": "pico_cobre", "resultado_cantidad": 1
	}
	var errores := SCHEMA.validar("rec_pico_cobre", receta)
	_check("errores .is_empty()", (errores).is_empty())

	_fin("A. test_receta_valida_pico_cobre")


func _bloque_B() -> void:
	_ini("B. test_receta_invalida_sin_costes")
	var receta := {
		"nombre": "Invalida", "categoria": "herramientas", "nivel": 1,
		"estacion": "mesa_trabajo", "coste_recursos": {},
		"resultado": "algo", "resultado_cantidad": 1
	}
	var errores := SCHEMA.validar("rec_invalida", receta)
	_check("errores .has_any_item(\"coste_recursos vacío o inválido\")", ("coste_recursos vacío o inválido") in (errores))

	_fin("B. test_receta_invalida_sin_costes")


func _bloque_C() -> void:
	_ini("C. test_receta_invalida_campos")
	var errores := SCHEMA.validar("", {"nombre": ""})
	_check("errores .contains(\"id vacío\")", ("id vacío") in (errores))
	_check("errores .contains(\"receta vacía\")", ("campo requerido ausente: nombre") in (errores))

	_fin("C. test_receta_invalida_campos")


func _bloque_D() -> void:
	_ini("D. test_receta_invalida_estacion_y_nivel")
	var receta := {
		"nombre": "R", "categoria": "puzzle", "nivel": 0,
		"estacion": "voladora", "coste_recursos": {"madera_roble": 1},
		"resultado": "x", "resultado_cantidad": 2
	}
	var errores := SCHEMA.validar("rec_r", receta)
	_check("errores .contains(\"nivel debe ser >= 1\")", ("nivel debe ser >= 1") in (errores))
	_check("errores .contains(\"estacion inválida: voladora\")", ("estacion inválida: voladora") in (errores))

	_fin("D. test_receta_invalida_estacion_y_nivel")


func _bloque_E() -> void:
	_ini("E. test_costes_roundtrip")
	var costes := {"madera_roble": 3, "mineral_cobre": 4}
	var texto := SCHEMA.costes_a_texto(costes)
	var de_vuelta := SCHEMA.texto_a_costes(texto)
	_check("de_vuelta .is_equal(costes)", (de_vuelta) == (costes))

	_fin("E. test_costes_roundtrip")


func _bloque_F() -> void:
	_ini("F. test_texto_a_costes_invalido")
	_check("SCHEMA.texto_a_costes(\"madera_roble:3, mal\") .is_empty()", (SCHEMA.texto_a_costes("madera_roble:3, mal")).is_empty())
	_check("SCHEMA.texto_a_costes(\"madera_roble:abc\") .is_empty()", (SCHEMA.texto_a_costes("madera_roble:abc")).is_empty())

	_fin("F. test_texto_a_costes_invalido")
