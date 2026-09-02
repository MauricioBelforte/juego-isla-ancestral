# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M109: Diálogos Auditor — recorre el dataset de diálogos (data/dialogues/
# + data/dialogues/contextual/) SIN recursión (get_files_at), valida cada grafo
# con DialogoSchema y escribe tools/reportes/dialogos_audit.txt.
# Ejecutar: godot --headless --path game/isla-ancestral -s res://scripts/editor/tools/dialogos_auditor.gd

extends SceneTree

const SCHEMA := preload("res://scripts/editor/support/dialogo_schema.gd")

var _fallos: int = 0
var _checks: int = 0
var total_json: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M109] Auditoría de grafos de diálogo ===")
	var lineas := PackedStringArray()
	for carpeta in ["res://data/dialogues/", "res://data/dialogues/contextual/"]:
		var archivos := DirAccess.get_files_at(carpeta)
		for nombre in archivos:
			if nombre.ends_with(".json"):
				_total_dialogo(carpeta + nombre, lineas)
	lineas.append("")
	lineas.append("=== Resultado: %d grafos auditados, %d OK, %d con problemas ===" % [total_json, total_json - lineas.size() + 1, lineas.size()])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/reportes"))
	var f := FileAccess.open("res://tools/reportes/dialogos_audit.txt", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(lineas))
		f.close()
	print(lineas[lineas.size() - 1])
	quit(1 if _fallos > 0 else 0)

func _total_dialogo(ruta_archivo: String, lineas: PackedStringArray) -> void:
	total_json += 1
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta_archivo))
	var errores: Array[String] = SCHEMA.validar_grafo(parsed)
	if errores.is_empty():
		_checks += 1
	else:
		_fallos += 1
		print("  [FALLO] %s -> %s" % [ruta_archivo.trim_prefix("res://"), "; ".join(errores)])
		lineas.append("FALLO %s -> %s" % [ruta_archivo.trim_prefix("res://"), "; ".join(errores)])
