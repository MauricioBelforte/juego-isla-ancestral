# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Volcado del catálogo de localización a JSON.
#
# `TransportLocalizer.generar_catalogo()` es la ÚNICA fuente de verdad del texto
# de M68 (sección V). Este script lo vuelca a `data/transporte/m68_catalogo.json`
# para que `scripts/aplicar_locales_m68.py` lo inserte en `locales/es.po` y
# `locales/en.po` sin tocar las claves que ya son de M87.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/transporte/dump_locales_m68.gd

extends SceneTree

const RUTA_SALIDA := "res://data/transporte/m68_catalogo.json"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M68] Volcado del catálogo de localización ===")
	var tm: Node = root.get_node_or_null("TransportManager")
	if tm == null:
		print("  [FAIL] autoload TransportManager ausente")
		quit(1)
		return
	var red: TransportNetwork = null
	var r: Variant = tm.call("red")
	if r is TransportNetwork:
		red = r
	var loc := TransportLocalizer.new(red)
	var esp: Object = tm.call("especiales")
	var nar: Object = tm.call("narrativos")
	var evt: Object = tm.call("eventos_de_ruta")

	var salida: Dictionary = {"version": 1, "locales": {}, "plurales": {}}
	for l in ["es", "en"]:
		var cat: Dictionary = loc.generar_catalogo(l, red, esp, nar, evt)
		var plu: Dictionary = loc.generar_plurales(l)
		salida["locales"][l] = cat
		salida["plurales"][l] = plu
		print("  %s: %d claves simples, %d plurales" % [l, cat.size(), plu.size()])

	var f := FileAccess.open(RUTA_SALIDA, FileAccess.WRITE)
	if f == null:
		print("  [FAIL] no se pudo abrir %s" % RUTA_SALIDA)
		quit(1)
		return
	f.store_string(JSON.stringify(salida, "\t", true))
	f.close()
	print("  [OK] escrito %s" % RUTA_SALIDA)
	print("=== Resumen dump: OK ===")
	quit(0)
