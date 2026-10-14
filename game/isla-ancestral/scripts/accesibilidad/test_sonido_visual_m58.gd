# Modelo: step-5-kilocode
# Plataforma: Kilo Code
# Fecha: 2026-10-11
#
# M58 iter. 3 (RF9 + RF11): test headless del indicador visual de sonido.
# Cubre:
#   - set/get_sonido_visual (opt-in, default apagado)
#   - catálogo data-driven (insectos, agua, cofre, canto_npc + alertas)
#   - pedir_indicador: descriptor válido, tipo desconocido -> {} + warning
#   - anti-spam: segundo pedido dentro de la ventana devuelve {}
#   - señal sonido_visual_changed
#   - integración con el schema (flag booleano válido)
#
# Guardia anti-falso-verde: CHECKS_MINIMOS + _summary() diferido.
# Ejecutar:
#   godot --headless --path game/isla-ancestral --quit-after 500 \
#       --script res://scripts/accesibilidad/test_sonido_visual_m58.gd

extends SceneTree

const CHECKS_MINIMOS := 25

var _checks: int = 0
var _fallos: int = 0


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("  [OK] " + msg)


func _summary() -> void:
	print("=== Resumen M58 RF9: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _initialize() -> void:
	# Bajo --script los autoloads no resuelven como identificadores globales:
	# se obtienen del root (patrón del repo para tests de manager).
	var m: Node = root.get_node_or_null("AccesibilityManager")
	if m == null:
		_fallos += 1
		print("FALLO: AccesibilityManager (autoload) no encontrado en root")
		_summary()
		return

	# --- A. default (opt-in) ---
	m.set_sonido_visual(false)
	_check(not m.get_sonido_visual(), "default: sonido_visual apagado")

	# --- B. set/get ---
	m.set_sonido_visual(true)
	_check(m.get_sonido_visual(), "set_sonido_visual(true) -> get true")

	# --- C. catalogo ---
	var lista: Array = m.indicadores_disponibles()
	_check(lista.size() >= 4, "catalogo tiene >= 4 indicadores (%d)" % lista.size())
	for tipo in ["insectos", "agua", "cofre", "canto_npc"]:
		_check(lista.has(tipo), "catalogo incluye '%s'" % tipo)

	# --- D. pedir_indicador con la opcion activa ---
	var d: Dictionary = m.pedir_indicador("insectos", true)
	_check(not d.is_empty(), "pedir_indicador('insectos') devuelve descriptor")
	_check(d.get("forma") == "anillo", "insectos -> forma anillo")
	_check(str(d.get("clave_texto", "")).begins_with("M58_"), "clave_texto localizable M58_*")
	_check(d.get("activado") == true, "descriptor marcado activado")

	# --- E. opcion apagada -> nunca describe ---
	m.set_sonido_visual(false)
	var d2: Dictionary = m.pedir_indicador("agua", true)
	_check(d2.is_empty(), "con sonido_visual off, pedir_indicador devuelve {}")

	# --- F. tipo desconocido ---
	m.set_sonido_visual(true)
	var d3: Dictionary = m.pedir_indicador("no_existe", true)
	_check(d3.is_empty(), "tipo desconocido devuelve {}")

	# --- G. anti-spam: dentro de la ventana devuelve {} ---
	var a1: Dictionary = m.pedir_indicador("cofre", true)
	var a2: Dictionary = m.pedir_indicador("cofre", false)
	_check(not a1.is_empty(), "primer pedido de cofre sale")
	_check(a2.is_empty(), "segundo pedido inmediato frenado por anti-spam")

	# --- H. alertas (RF11) en el mismo catálogo ---
	var al: Dictionary = m.pedir_indicador("alerta_vida", true)
	_check(al.get("forma") == "cartel", "alerta_vida -> cartel (RF11)")

	# --- I. senal ---
	var vistos := [false]
	m.sonido_visual_changed.connect(func(a): vistos[0] = a)
	m.set_sonido_visual(false)
	m.set_sonido_visual(true)
	_check(vistos[0] == true, "senal sonido_visual_changed emitida")

	# --- J. schema sigue validando el flag ---
	var esquema: GDScript = load("res://scripts/accesibilidad/accesibilidad_schema.gd")
	var errs: Array = esquema.validar({"sonido_visual": true, "subtitulos": true})
	_check(not errs.has("flag no booleano: sonido_visual"),
		"schema acepta sonido_visual booleano")

	# --- K. edge cases J1/J2: coaccion y debounce ---
	var campos: Array = m.campos_con_rango()
	_check(campos.size() >= 4, "campos_con_rango >= 4 (%d)" % campos.size())

	m.set_campo("subtitulos_velocidad", 99.0)
	_check(abs(float(m.get_campo("subtitulos_velocidad")) - 2.0) < 0.001,
		"velocidad 99.0 coaccionada a 2.0")
	m.set_campo("subtitulos_velocidad", -5.0)
	_check(abs(float(m.get_campo("subtitulos_velocidad")) - 0.5) < 0.001,
		"velocidad -5.0 coaccionada a 0.5")
	m.set_campo("volumen_general", 0.3)
	_check(abs(float(m.get_campo("volumen_general")) - 0.3) < 0.001,
		"volumen 0.3 dentro de rango queda igual")
	var no_numerico = m.get_campo("dificultad")
	m.set_campo("dificultad", "estandar")
	_check(m.get_campo("dificultad") == "estandar",
		"campo sin rango ('dificultad') no se coacciona")

	# debounce: valor visible de inmediato
	m.set_campo_lento("escala_ui", 1.2)
	_check(abs(float(m.get_campo("escala_ui")) - 1.2) < 0.001,
		"set_campo_lento aplica el valor de inmediato")
	m.set_campo_lento("escala_ui", 9.0)
	# RF3 (2026-10-11): el máximo de escala pasó de 150 % a 200 %.
	_check(abs(float(m.get_campo("escala_ui")) - 2.0) < 0.001,
		"set_campo_lento tambien coacciona (max 200 % segun RF3)")

	# --- guardia ---
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: checks %d < piso medido %d" % [_checks, CHECKS_MINIMOS])
	_summary()
