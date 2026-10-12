# Modelo: hy3 (WorkBuddy / Hunyuan)
# Plataforma: automatizacion Isla Ancestral
# Fecha: 2026-10-11
#
# M128 H3 — Test headless de contraste WCAG AA de la paleta oficial.
# Valida que los pares texto/fondo canonicos cumplan AA (4.5:1 texto normal,
# 3.0:1 texto grande/UI) y reporta la matriz completa.
# Uso: godot --headless -s res://tests/test_brand_contrast_m128.gd
# Exit 0 = OK, 1 = fallo.

extends SceneTree

const _SC := preload("res://scripts/brand/brand_config.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M128-H3] Test contraste WCAG AA paleta oficial ===")
	_test_matriz()
	_test_pares_canonicos()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Imprime la matriz completa y senala pares < 3.0 (preocupacion AA real).
func _test_matriz() -> void:
	print("--- Matriz de contraste (todas las combinaciones) ---")
	var bc: Object = _SC.new()
	var nombres: Array = bc.COLORES.keys()
	for a in nombres:
		var linea := ""
		for b in nombres:
			var r: float = bc.contraste_wcag(bc.color(a), bc.color(b))
			linea += "%s-%-16s %.2f | " % [a, b, r]
		print("  " + linea)

	# Todos los ratios deben ser finitos y > 1.0 (colores distintos).
	for a in nombres:
		for b in nombres:
			var r: float = bc.contraste_wcag(bc.color(a), bc.color(b))
			_check("ratio finito %s/%s" % [a, b], r >= 1.0 and r <= 21.0, str(r))

	# Pares criticos REALES: texto sobre fondo debe cumplir AA 4.5 (texto normal).
	# (No se exige carbon/azul_bosque: es combinacion oscuro-sobre-oscuro que no se usa;
	#  se reporta como restriccion de uso en el HALLAZGO, no como fallo duro.)
	var pares_texto_fondo := [
		["carbon", "blanco_perla"],
		["carbon", "crema"],
		["gris_piedra", "blanco_perla"],
		["gris_piedra", "crema"],
		["blanco_perla", "azul_bosque"],
	]
	for pf in pares_texto_fondo:
		var r: float = bc.contraste_wcag(bc.color(pf[0]), bc.color(pf[1]))
		_check("AA 4.5 %s/%s" % [pf[0], pf[1]], r >= 4.5, "%.2f" % r)

	# Reporte de pares < 3.0 (hallazgo real, no es fallo duro salvo los canonicos).
	var hallazgos := []
	for a in nombres:
		for b in nombres:
			if a == b:
				continue
			var r: float = bc.contraste_wcag(bc.color(a), bc.color(b))
			if r < 3.0:
				hallazgos.append("%s/%s=%.2f" % [a, b, r])
	if not hallazgos.is_empty():
		print("  [HALLAZGO] pares con contraste < 3.0 (AA grande/UI no cumple): " + ", ".join(hallazgos))
	else:
		print("  [OK] ningun par con contraste < 3.0")

func _test_pares_canonicos() -> void:
	# Asegura que el helper da valores conocidos (regression guard).
	var bc: Object = _SC.new()
	var blanco_sobre_azul: float = bc.contraste_wcag(bc.color("blanco_perla"), bc.color("azul_bosque"))
	_check("blanco_perla/azul_bosque > 4.5", blanco_sobre_azul > 4.5, "%.2f" % blanco_sobre_azul)

func _summary() -> void:
	print("=== Resumen M128-H3: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M128-H3 FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M128-H3 OK — pares canonicos cumplen AA 4.5")
		quit(0)
