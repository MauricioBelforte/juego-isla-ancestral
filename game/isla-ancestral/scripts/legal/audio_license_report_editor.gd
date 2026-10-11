# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-11
#
# M84: Música y Audio Legal — Editor entry point (L117)
# Tool de editor INVOCABLE (en el editor de Godot: File → Run, o desde el
# pipeline de build de M117). Genera Builds/<plataforma>/LICENCIAS-AUDIO.md
# para el build actual. NO es runtime: solo se ejecuta en el editor/build.
#
# Uso desde el editor: abrir este archivo y File → Run.
# Uso desde build (M117): AudioLicenseReportTool.generar_reporte_build(...)
# con la plataforma destino del export preset.

extends EditorScript


func _run() -> void:
	var plataforma := OS.get_name()  # Windows / Linux / macOS (el pipeline pasa la del export preset)
	var builds_root := ProjectSettings.globalize_path("res://../Builds").path_join(plataforma)
	var inventario := "res://data/legal/audio_licenses.json"
	# Raíces de audio del proyecto (las inexistentes se ignoran sin error).
	var raices := [
		"res://assets/audio/",
		"res://assets/music/",
		"res://assets/sfx/",
		"res://audio/",
	]
	var resumen: Dictionary = AudioLicenseReportTool.generar_reporte_build(plataforma, builds_root, inventario, raices)
	if not String(resumen["error"]).is_empty():
		push_error("[M84] Reporte de licencias fallido: %s" % String(resumen["error"]))
		return
	print("[M84] Reporte de licencias generado: %s" % String(resumen["ruta_reporte"]))
	print("[M84] Assets de audio: %d (%d con licencia registrada, %d SIN LICENCIA REGISTRADA)" % [int(resumen["total"]), int(resumen["con_licencia"]), int(resumen["sin_licencia"])])
	if int(resumen["sin_licencia"]) > 0:
		push_error("[M84] BUILD CON AUDIO SIN LICENCIA REGISTRADA — corregir antes del release. Detalle: %s" % String(resumen["ruta_reporte"]))
