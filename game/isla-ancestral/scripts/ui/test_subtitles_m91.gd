# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M91: Test de SubtitleManager (autoload SubtitleManager).
# Cubre los ítems de subtítulos del módulo: toggle, tamaño 0.5x-2x,
# opacidad 0.2-1.0, fondo toggle+color, show_subtitle/hide_subtitle,
# re-entrancia de timers (race condition) y formato de guardado M60
# (enabled/size/opacity como float, color como objeto {r,g,b,a}).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_subtitles_m91.gd

extends SceneTree

## Piso de checks medido en verde (patrón M105): se recalcula tras la
## primera corrida verdes y no puede subirse nunca sin volver a medir.
const CHECKS_MINIMOS: int = 50

var _fallos: int = 0
var _checks: int = 0
var _save_original: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var sm := root.get_node_or_null("SubtitleManager")
	_test_autoload_presente(sm)
	if sm != null:
		_save_original = sm.get_save_data()
		_test_defaults(sm)
		_test_mostrar_ocultar(sm)
		_test_toggle_deshabilitado(sm)
		_test_tamano(sm)
		_test_opacidad(sm)
		_test_fondo(sm)
		_test_duracion_cero(sm)
		_test_save_data(sm)
		_test_restore(sm)
		await _test_race_condition(sm)
		# restaura el estado previo para no contaminar otros tests
		sm.restore_save_data(_save_original)
		sm.hide_subtitle()
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: piso de checks no alcanzado (%d < %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M91 SUBTITULOS: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _casi(a: float, b: float) -> bool:
	return absf(a - b) < 0.001

## ── Tests ───────────────────────────────────────────────

func _test_autoload_presente(sm: Node) -> void:
	_check(sm != null, "SubtitleManager autoload presente")
	if sm == null:
		return
	_check(sm.has_method("show_subtitle"), "existe show_subtitle")
	_check(sm.has_method("hide_subtitle"), "existe hide_subtitle")
	_check(sm.has_method("get_save_data"), "existe get_save_data")
	_check(sm.has_method("get_section_name"), "existe get_section_name")

func _test_defaults(sm: Node) -> void:
	_check(sm.get_habilitados() == true, "default habilitados = true")
	_check(_casi(sm.get_subtitle_size(), 1.0), "default tamaño = 1.0")
	_check(_casi(sm.get_subtitle_opacity(), 0.9), "default opacidad = 0.9")
	_check(sm.get_background_visible() == true, "default fondo = true")
	_check(sm.get_background_color() == Color(0, 0, 0, 0.6), "default color fondo")
	_check(sm.get_text_color() == Color(1, 1, 1, 1), "default color texto")
	_check(sm.get_font_size_aplicada() == 16, "default font_size = 16*1.0")

func _test_mostrar_ocultar(sm: Node) -> void:
	sm.show_subtitle("Hola isla", 0.0)
	_check(sm.hay_subtitulo_visible() == true, "show → visible")
	_check(sm.texto_actual() == "Hola isla", "show → texto almacenado")
	sm.show_subtitle("", 0.0)
	_check(sm.hay_subtitulo_visible() == false, "show con texto vacío → oculta")
	sm.hide_subtitle()
	_check(sm.hay_subtitulo_visible() == false, "hide_subtitle → oculto")
	_check(sm.texto_actual() == "", "hide → texto vacío")

func _test_toggle_deshabilitado(sm: Node) -> void:
	sm.set_habilitados(false)
	_check(sm.get_habilitados() == false, "set_habilitados(false)")
	sm.show_subtitle("no debe verse", 0.0)
	_check(sm.hay_subtitulo_visible() == false, "deshabilitado → show ignorado")
	sm.set_habilitados(true)
	_check(sm.get_habilitados() == true, "set_habilitados(true)")

func _test_tamano(sm: Node) -> void:
	sm.set_subtitle_size(1.5)
	_check(_casi(sm.get_subtitle_size(), 1.5), "tamaño 1.5 aceptado")
	_check(sm.get_font_size_aplicada() == 24, "font_size aplicada = 16*1.5 = 24")
	# límites del slider 0.5x a 2x
	sm.set_subtitle_size(5.0)
	_check(_casi(sm.get_subtitle_size(), 2.0), "clamp superior a 2.0")
	_check(sm.get_font_size_aplicada() == 32, "font_size aplicada = 16*2.0 = 32")
	sm.set_subtitle_size(0.1)
	_check(_casi(sm.get_subtitle_size(), 0.5), "clamp inferior a 0.5")
	_check(sm.get_font_size_aplicada() == 8, "font_size aplicada = 16*0.5 = 8")
	sm.set_subtitle_size(1.0)
	_check(_casi(sm.get_subtitle_size(), 1.0), "tamaño restaurado a 1.0")

func _test_opacidad(sm: Node) -> void:
	sm.set_subtitle_opacity(0.5)
	_check(_casi(sm.get_subtitle_opacity(), 0.5), "opacidad 0.5 aceptada")
	_check(_casi(sm.get_opacity_aplicada(), 0.5), "opacidad aplicada al label = 0.5")
	sm.set_subtitle_opacity(1.5)
	_check(_casi(sm.get_subtitle_opacity(), 1.0), "clamp superior a 1.0")
	sm.set_subtitle_opacity(0.05)
	_check(_casi(sm.get_subtitle_opacity(), 0.2), "clamp inferior a 0.2")
	_check(_casi(sm.get_opacity_aplicada(), 0.2), "opacidad aplicada = 0.2")
	sm.set_subtitle_opacity(0.9)
	_check(_casi(sm.get_subtitle_opacity(), 0.9), "opacidad restaurada a 0.9")

func _test_fondo(sm: Node) -> void:
	sm.show_subtitle("con fondo", 0.0)
	_check(sm.fondo_realmente_visible() == true, "fondo visible por defecto")
	sm.set_background_visible(false)
	_check(sm.get_background_visible() == false, "set_background_visible(false)")
	_check(sm.fondo_realmente_visible() == false, "fondo apagado → panel oculto")
	_check(sm.hay_subtitulo_visible() == true, "apagar fondo NO oculta el texto")
	sm.set_background_visible(true)
	_check(sm.fondo_realmente_visible() == true, "fondo encendido → panel visible")
	var c := Color(1.0, 0.0, 0.0, 0.5)
	sm.set_background_color(c)
	_check(sm.get_background_color() == c, "color de fondo aplicado")
	sm.set_text_color(Color(0, 1, 0, 1))
	_check(sm.get_text_color() == Color(0, 1, 0, 1), "color de texto aplicado")
	sm.hide_subtitle()

func _test_duracion_cero(sm: Node) -> void:
	sm.show_subtitle("sin reloj", 0.0)
	_check(sm.hay_subtitulo_visible() == true, "duración 0 → queda hasta hide")
	sm.hide_subtitle()

func _test_save_data(sm: Node) -> void:
	_check(sm.get_section_name() == "subtitles", "sección M60 = 'subtitles'")
	sm.set_subtitle_size(1.75)
	sm.set_subtitle_opacity(0.35)
	var d = sm.get_save_data()
	_check(d.has("enabled"), "save tiene enabled")
	_check(d.has("size"), "save tiene size")
	_check(d.has("opacity"), "save tiene opacity")
	_check(d.has("color"), "save tiene color")
	_check(d.has("background"), "save tiene background")
	_check(typeof(d["size"]) == TYPE_FLOAT, "size es float")
	_check(typeof(d["opacity"]) == TYPE_FLOAT, "opacity es float")
	_check(d["size"] is float and _casi(float(d["size"]), 1.75), "size refleja 1.75")
	_check(d["opacity"] is float and _casi(float(d["opacity"]), 0.35), "opacity refleja 0.35")
	_check(typeof(d["color"]) == TYPE_DICTIONARY, "color es Dictionary")
	var col: Dictionary = d["color"]
	for k in ["r", "g", "b", "a"]:
		_check(col.has(k), "color tiene clave '%s'" % k)
		if col.has(k):
			_check(typeof(col[k]) == TYPE_FLOAT, "color['%s'] es float" % k)
			_check(float(col[k]) >= 0.0 and float(col[k]) <= 1.0, "color['%s'] en [0,1]" % k)

func _test_restore(sm: Node) -> void:
	sm.restore_save_data({"enabled": false, "size": 2.0, "opacity": 0.2, "background": false})
	_check(sm.get_habilitados() == false, "restore enabled=false")
	_check(_casi(sm.get_subtitle_size(), 2.0), "restore size=2.0")
	_check(_casi(sm.get_subtitle_opacity(), 0.2), "restore opacity=0.2")
	_check(sm.get_background_visible() == false, "restore background=false")
	_check(sm.get_font_size_aplicada() == 32, "restore → font aplicada 32")
	# fuera de rango → clamado
	sm.restore_save_data({"size": 9.0, "opacity": -3.0})
	_check(_casi(sm.get_subtitle_size(), 2.0), "restore clama size 9.0 → 2.0")
	_check(_casi(sm.get_subtitle_opacity(), 0.2), "restore clama opacity -3.0 → 0.2")
	# diccionario vacío → no rompe ni cambia nada
	var antes_s = sm.get_subtitle_size()
	sm.restore_save_data({})
	_check(_casi(sm.get_subtitle_size(), antes_s), "restore vacío no altera estado")
	# color malformado → default
	sm.restore_save_data({"color": {"x": 1}})
	_check(sm.get_background_color() == Color(0, 0, 0, 0.6), "color malformado → default")
	sm.set_subtitle_size(1.0)
	sm.set_subtitle_opacity(0.9)

## Race condition: el primer subtítulo (reloj corto) no debe ocultar al segundo.
# Los márgenes son anchos a propósito: en --script el SceneTree corre a ~80ms
# por frame (los autoloads de mundo generan terreno), así que un margen de un
# solo frame sería flaky. El costo de exit es un umbral fijo (~50s) y no crece
# con el tiempo de juego, así que los márgenes amplios no cuestan nada extra.
func _test_race_condition(sm: Node) -> void:
	# Fase 1 — "segundo" con duración 0 NO tiene reloj propio: nadie debe
	# ocultarlo, salvo que el guard de generación falle.
	sm.show_subtitle("primero", 0.10)
	_check(sm.texto_actual() == "primero", "race: primer subtítulo activo")
	await create_timer(0.05).timeout
	sm.show_subtitle("segundo", 0.0)
	_check(sm.texto_actual() == "segundo", "race: segundo subtítulo reemplaza")
	# t≈0.40: el reloj de "primero" (0.10) venció hace rato; era obsoleto.
	await create_timer(0.35).timeout
	_check(sm.hay_subtitulo_visible() == true, "race: NO lo oculta el reloj viejo")
	_check(sm.texto_actual() == "segundo", "race: sigue siendo 'segundo'")
	# Fase 2 — un reloj VÁLIDO sí debe ocultarlo.
	sm.show_subtitle("tercero", 0.15)
	_check(sm.texto_actual() == "tercero", "race: tercer subtítulo activo")
	await create_timer(0.50).timeout
	_check(sm.hay_subtitulo_visible() == false, "race: se oculta con SU reloj")
	_check(sm.texto_actual() == "", "race: texto limpio tras ocultar")
