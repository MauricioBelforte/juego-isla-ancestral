# test_iconos_m159.gd — M159 b2 QA: verifica (headless) que los 300 íconos del catálogo carguen sin error.
#
# Refuerza el cierre de M159 b2 (300/300 íconos) con una verificación RUNTIME (no solo de
# existencia de archivo): carga cada .tres (ItemData) y su PNG `icono`, y reporta 0 fallos.
# Ejecutar: godot --headless -s res://tests/test_iconos_m159.gd
#
# **Modelo:** agnes-3-flash (Sapiens AI)
# **Plataforma:** Kilo Code
# **Fecha:** 2026-10-20

extends SceneTree

const ITEMS_DIR := "res://data/items/"
const TOTAL := 300

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var tres := DirAccess.open(ITEMS_DIR)
	if tres == null:
		print("=== [M159 b2 QA] FAIL: no existe " + ITEMS_DIR + " ===")
		quit(1)
		return
	tres.list_dir_begin()
	var f := tres.get_next()
	var cont := 0
	var sin_icono := 0
	var png_no_cargan := 0
	var tres_no_cargan := 0
	while f != "":
		if f.get_extension().to_lower() == "tres":
			cont += 1
			var tres_obj := load(ITEMS_DIR + f)
			if tres_obj == null:
				tres_no_cargan += 1
				print("  [FALLO .tres] " + f + " no carga")
			else:
				var ico: Variant = tres_obj.get("icono")
				if ico == null or ico == "":
					sin_icono += 1
					print("  [SIN_ICONO] " + f)
				else:
					var im := Image.new()
					if im.load(ProjectSettings.globalize_path(String(ico))) != OK:
						png_no_cargan += 1
						print("  [PNG_FALLO] " + f + " -> " + String(ico))
		f = tres.get_next()
	tres.list_dir_end()

	var ok := (cont == TOTAL) and sin_icono == 0 and png_no_cargan == 0 and tres_no_cargan == 0
	print("=== [M159 b2 QA] total=%d/300 | sin_icono=%d | png_no_cargan=%d | tres_no_cargan=%d | %s ===" % [cont, sin_icono, png_no_cargan, tres_no_cargan, ("OK (300/300 íconos cargan en runtime)" if ok else "FALLO")])
	quit(0 if ok else 1)
