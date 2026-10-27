# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-26
#
# M53 L210: ratios 16:9 y 16:10 verificados en TODAS las pantallas.
#
# Mide el FOOTPRINT de cada capa de scripts/ui/layers/ (mayor Control hijo
# directo = el panel que ocupa la pantalla) contra el lienzo de UI real
# (root.get_visible_rect()) en dos ratios y dos estados:
#   - oculta: como nace la capa (visible=false)
#   - abierta: tras open() (o visible=true)
# Un desborde en cualquiera de los 4 pares por capa es un fallo.
#
# El contenido interno de un ScrollContainer puede exceder el lienzo: eso es
# scroll legitimo, no desborde de pantalla, y se informa como INFO.
#
# Anti-falso-verde:
#   - CHECKS_MINIMOS medido en verde (40 = 10 capas x 2 ratios x 2 estados).
#   - Si corren menos checks que el piso, el resultado es FALLO (un runner que
#     aborta no puede publicar "0 fallos").
#   - EXIT 1 si hay fallo o si no se alcanzo el piso.
#   - Probado EN ROJO por inyeccion (panel de inventory a 1400 px): EXIT 1.
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_m53_ratios.gd

extends SceneTree

const LAYERS := [
	"confirm_popup.gd", "credits_layer.gd", "dialog_layer.gd", "diary_layer.gd",
	"equipment_layer.gd", "inventory_layer.gd", "loading_layer.gd",
	"menus_layer.gd", "pause_layer.gd", "settings_audio_layer.gd",
]

const BASE := "res://scripts/ui/layers/"

## Medido en verde el 2026-10-26: 10 capas x 2 ratios x (carga + instancia + 2 medidas) = 80.
const CHECKS_MINIMOS := 80

var _checks: int = 0
var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for caso in [[1920, 1080, "16:9"], [1680, 1050, "16:10"]]:
		await _medir(int(caso[0]), int(caso[1]), String(caso[2]))
	print("\n=== TEST M53 RATIOS (L210): %d checks, %d fallo(s), piso %d ===" % [_checks, _fallos, CHECKS_MINIMOS])
	if _checks < CHECKS_MINIMOS:
		print("FALLO: corrieron %d checks, por debajo del piso %d (runner abortado)" % [_checks, CHECKS_MINIMOS])
		_fallos += 1
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _medir(w: int, h: int, etiqueta: String) -> void:
	var raiz := get_root()
	raiz.size = Vector2i(w, h)
	await process_frame
	await process_frame
	var lienzo: Vector2 = raiz.get_visible_rect().size
	print("\n--- %s: root %dx%d -> lienzo UI %.0fx%.0f ---" % [etiqueta, w, h, lienzo.x, lienzo.y])
	print("  %-24s %-14s %-14s %s" % ["capa", "oculta", "abierta", "estado"])
	for archivo in LAYERS:
		var scr = load(BASE + archivo)
		_check(scr != null, "%s: no carga" % archivo)
		if scr == null:
			continue
		var nodo = scr.new()
		_check(nodo != null, "%s: no instancia" % archivo)
		if nodo == null:
			continue
		raiz.add_child(nodo)
		await process_frame
		await process_frame
		var oculta: Vector2 = _footprint(nodo)
		if nodo.has_method("open"):
			nodo.call("open")
		else:
			nodo.visible = true
		await process_frame
		await process_frame
		await process_frame
		var abierta: Vector2 = _footprint(nodo)
		_check(oculta.x <= lienzo.x + 0.5 and oculta.y <= lienzo.y + 0.5,
			"%s [%s] oculta desborda: %.0fx%.0f > lienzo %.0fx%.0f" % [archivo, etiqueta, oculta.x, oculta.y, lienzo.x, lienzo.y])
		_check(abierta.x <= lienzo.x + 0.5 and abierta.y <= lienzo.y + 0.5,
			"%s [%s] abierta desborda: %.0fx%.0f > lienzo %.0fx%.0f" % [archivo, etiqueta, abierta.x, abierta.y, lienzo.x, lienzo.y])
		print("  %-24s %-14s %-14s %s" % [
			archivo,
			"%.0fx%.0f" % [oculta.x, oculta.y],
			"%.0fx%.0f" % [abierta.x, abierta.y],
			"OK" + _info_scroll(nodo, lienzo)])
		nodo.queue_free()
		await process_frame

## Mayor Control hijo directo de la capa = el panel que ocupa la pantalla.
func _footprint(nodo: Node) -> Vector2:
	var mayor := Vector2.ZERO
	for c in nodo.get_children():
		if c is Control:
			var v: Vector2 = c.size
			if v.x > mayor.x:
				mayor.x = v.x
			if v.y > mayor.y:
				mayor.y = v.y
	return mayor

## Contenido mas grande que el lienzo DENTRO de un ScrollContainer (informativo).
func _info_scroll(nodo: Node, lienzo: Vector2) -> String:
	var out := ""
	for sc in _buscar_scroll(nodo):
		for c in sc.get_children():
			if c is Control:
				var v: Vector2 = c.get_combined_minimum_size()
				if v.y > lienzo.y or v.x > lienzo.x:
					out += "  [info: scroll interno %.0fx%.0f]" % [v.x, v.y]
	return out

func _buscar_scroll(n: Node) -> Array:
	var out: Array = []
	for c in n.get_children():
		if c is ScrollContainer:
			out.append(c)
		out.append_array(_buscar_scroll(c))
	return out
