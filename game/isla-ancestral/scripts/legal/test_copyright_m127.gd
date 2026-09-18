# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# Modelo: deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash / WorkBuddy (fix BUG-033 + guarda, iter. 2)
# Plataforma: Kilo Code (iter. 1) · WorkBuddy (fix BUG-033 / iter. 2)
# Fecha: 2026-09-02 (iter. 1) · 2026-09-14 (fix BUG-033) · 2026-09-16 (iter. 2, guarda anti-falso-verde)
#
# M127: Copyright del Juego — Test headless
# Valida: CopyrightValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.
#
# fix BUG-033 (2026-09-14): las aserciones de conteo estaban fijadas a
# `elementos == 5` / `politicas == 2` y el catálogo creció a **7 / 5** →
# **false-red** en CI/QA (2 fallos con los datos validando 0 errores). Ahora se
# exige un **mínimo** (el catálogo puede crecer sin romper el test) y se añade una
# comprobación real de regresión de datos: **ids de elementos únicos**. No volver
# a fijar el número exacto.
#
# iter. 2 (2026-09-16): **guarda anti-falso-verde**. El suite no tenía ninguna:
# un `SCRIPT ERROR` dentro de `_run()` habría saltado un bloque entero y el
# resumen habría impreso "0 fallos" igual (trampa 11 del skill), y al ser
# `extends SceneTree` + `call_deferred` el aborto **cuelga el árbol** sin llegar
# nunca a `quit()` (trampa 28). Se añaden las tres piezas obligatorias:
#   1. `BLOQUES` + `_fin()` por bloque,
#   2. `_summary()` que **nombra los bloques que no terminaron**,
#   3. watchdog en `_process` que corta con `quit(1)` si `_run()` no termina.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/copyright_validator.gd")
const RUTA_DATA := "res://data/legal/copyright.json"
const MIN_ELEMENTOS := 5   # mínimo histórico del catálogo (M127 iter. 1)
const MIN_POLITICAS := 2   # mínimo histórico del catálogo (M127 iter. 1)

# Todos los bloques que DEBEN ejecutarse. Si uno no llama a _fin(), el suite falla.
const BLOQUES := ["datos", "validator", "validator_errores"]
const FRAMES_MAX := 300

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false

func _init() -> void:
	# ⚠️ `_summary()` va en un `call_deferred` SEPARADO a propósito (medido 2026-09-16):
	# si un SCRIPT ERROR aborta `_run()`, la cola de llamadas diferidas SIGUE y
	# `_summary()` se ejecuta igual → el suite siempre reporta y siempre sale con
	# `quit()`. Es la defensa que de verdad funciona; el watchdog de `_process` es
	# sólo diagnóstico (ver abajo).
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M127] Test de Copyright del Juego ===")
	_test_data()
	_test_validator()
	_test_validator_errores()

## Marca un bloque como ejecutado. Se llama al FINAL de cada bloque.
func _fin(nombre: String) -> void:
	_vistos[nombre] = true

## Watchdog: red de seguridad DIAGNÓSTICA. ⚠️ Medido con sonda mínima (2026-09-16):
## en este build `quit(1)` desde `_process` — incluso devolviendo `true` — **detiene
## el bucle pero NO termina el proceso**: el proceso queda vivo hasta que lo mata un
## timeout externo (EXIT 124). Por eso el watchdog imprime el motivo (útil en el log)
## pero **no se usa como mecanismo de corte**: de eso se encarga `_summary()` vía
## `call_deferred`, que sí termina con `quit()`.
func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > FRAMES_MAX:
		_terminado = true
		_checks += 1
		_fallos += 1
		print("!! WATCHDOG: _run() no terminó en %d frames (posible SCRIPT ERROR que abortó la función)" % FRAMES_MAX)
		print("=== Resumen M127: %d checks, %d fallos ===" % [_checks, _fallos])
		quit(1)
		return true
	return false

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed as Dictionary
	return {}

func _test_data() -> void:
	print("--- Datos: copyright.json ---")
	var data: Dictionary = _cargar()
	_check("copyright.json cargado", not data.is_empty())
	var n_elem: int = (data.get("elementos", []) as Array).size()
	var n_pol: int = (data.get("politicas", {}) as Dictionary).size()
	_check("elementos >= %d (real %d)" % [MIN_ELEMENTOS, n_elem], n_elem >= MIN_ELEMENTOS,
		"size=%d" % n_elem)
	_check("políticas >= %d (real %d)" % [MIN_POLITICAS, n_pol], n_pol >= MIN_POLITICAS,
		"size=%d" % n_pol)
	# Regresión REAL de datos (no un número fijo): ids de elementos únicos y no vacíos.
	var vistos: Dictionary = {}
	var duplicado: String = ""
	var sin_id: int = 0
	for e in data.get("elementos", []):
		var id: String = str((e as Dictionary).get("id", ""))
		if id.is_empty():
			sin_id += 1
			continue
		if vistos.has(id):
			duplicado = id
		vistos[id] = true
	_check("ids de elementos únicos", duplicado == "", "duplicado=%s" % duplicado)
	_check("todos los elementos tienen id", sin_id == 0, "sin id=%d" % sin_id)
	# iter. 2: el validador de signoff (tools/legal) exige `year` en cada elemento.
	# Comprobarlo acá evita que el artefacto generado y el signoff se desalineen.
	var sin_year: int = 0
	for e in data.get("elementos", []):
		if not (e as Dictionary).has("year"):
			sin_year += 1
	_check("todos los elementos tienen year (contrato de signoff_check.py)", sin_year == 0,
		"sin year=%d" % sin_year)
	_fin("datos")

func _test_validator() -> void:
	print("--- CopyrightValidator: data real ---")
	var data: Dictionary = _cargar()
	var errores: Array = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))
	_fin("validator")

func _test_validator_errores() -> void:
	print("--- CopyrightValidator: errores detectados ---")
	var malo: Dictionary = {
		"elementos": [
			{"id": "", "elemento": "", "titular": ""}
		],
		"politicas": {}
	}
	var errores: Array = _SC_VALIDATOR.validar(malo)
	_check("sin id detectado", str(errores).contains("sin id"))
	_check("sin nombre detectado", str(errores).contains("sin nombre"))
	_check("sin titular detectado", str(errores).contains("sin titular"))
	_check("sin políticas detectado", str(errores).contains("políticas"))
	_fin("validator_errores")

func _summary() -> void:
	# Guarda anti-falso-verde: todo bloque declarado en BLOQUES debe haber llamado a _fin().
	var faltantes: Array = []
	for n in BLOQUES:
		if not _vistos.has(n):
			faltantes.append(n)
	_check("los %d bloques se completaron" % BLOQUES.size(), faltantes.is_empty(),
		"no terminaron: %s" % str(faltantes))
	_terminado = true
	print("=== Resumen M127: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M127 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M127 OK — todos los checks pasaron")
		quit(0)
