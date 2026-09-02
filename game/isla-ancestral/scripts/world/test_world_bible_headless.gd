# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M147: Verificación del WorldBible (canon data-driven).
extends SceneTree

var _fallos := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M147] Verificación del WorldBible (canon) ===")
	var bible = load("res://scripts/world/world_bible.gd").new()
	root.add_child(bible)
	await process_frame
	_check("WorldBible instanciado", bible != null)
	var canon: Dictionary = bible.config if (bible.get("config") != null) else {}
	if canon.is_empty() and bible.get("canon") != null:
		canon = bible.get("canon")
	# leer el json directamente (si el servicio no expone)
	var datos: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_data.json"))
	_check("canon_version presente", float(datos.get("canon_version", 0)) >= 1.0)
	var personajes: Dictionary = datos.get("personajes", {})
	_check("6 personajes del canon", personajes.size() == 6)
	var lugares: Dictionary = datos.get("lugares", {})
	_check("8 lugares del canon", lugares.size() == 8)
	var simbolos: Dictionary = datos.get("simbolos", {})
	_check("4 símbolos del canon", simbolos.size() == 4)
	var capas: Dictionary = datos.get("capas_por_sello", {})
	_check("4 capas por sello", capas.size() == 4)
	var linea: Array = datos.get("linea_tiempo", [])
	_check("5 eventos de línea de tiempo", linea.size() == 5)
	print("=== Resumen M147: %d fallo(s) ===" % _fallos)
	bible.free()
	quit(1 if _fallos > 0 else 0)
