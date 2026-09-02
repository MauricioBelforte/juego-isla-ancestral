# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M36: Auditor del catálogo de fauna (data-driven) + reporte.
extends SceneTree

const SCHEMA := preload("res://scripts/fauna/fauna_schema.gd")
const RUTA := "res://data/fauna/catalog.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M36] Auditoría del catálogo de fauna ===")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	_check("catálogo JSON válido", typeof(parsed) == TYPE_ARRAY)
	if typeof(parsed) != TYPE_ARRAY:
		quit(1)
		return
	var ids := {}
	var lineas := PackedStringArray()
	for especie in parsed:
		var errores: Array[String] = SCHEMA.validar_especie(especie)
		var id: String = String(especie.get("id", ""))
		if errores.is_empty():
			_checks += 1
			# ids únicos
			if ids.has(id):
				_fallos += 1
				lineas.append("FALLO id duplicado: " + id)
			ids[id] = true
			print("  [OK] %s" % id)
		else:
			_fallos += 1
			lineas.append("FALLO %s -> %s" % [id, "; ".join(errores)])
	print("=== Resultado M36: %d especies, %d fallo(s) ===" % [parsed.size(), _fallos])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/reportes"))
	var f := FileAccess.open("res://tools/reportes/fauna_audit.txt", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(lineas))
		f.close()
	quit(1 if _fallos > 0 else 0)
