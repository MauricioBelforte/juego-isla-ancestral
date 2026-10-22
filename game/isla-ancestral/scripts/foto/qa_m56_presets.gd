# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-23
#
# M56: QA de los presets de foto (data/foto/foto_presets.json) validados con
# FotoSchema.validar_preset. Ejecutar: Godot --headless --path
# game\isla-ancestral --script res://scripts/foto/qa_m56_presets.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA presets M56: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var f := FileAccess.open("res://data/foto/foto_presets.json", FileAccess.READ)
	_check(f != null, "foto_presets.json abre")
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	_check(typeof(parsed) == TYPE_DICTIONARY, "JSON parseado como Dictionary")
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var presets: Dictionary = parsed.get("presets", {})
	_check(presets.size() >= 6 and presets.size() <= 8, "6-8 presets (hay %d)" % presets.size())

	var schema = load("res://scripts/foto/foto_schema.gd")
	_check(schema != null, "FotoSchema carga")
	if schema == null:
		return

	var esperados := ["natural", "calido_playa", "verde_selva", "crepusculo_rojo", "niebla_costera", "pintura_retro"]
	for id in esperados:
		_check(presets.has(id), "preset canonico presente: " + id)

	var errores_totales := 0
	for id in presets:
		var errores = schema.validar_preset(String(id), presets[id])
		errores_totales += errores.size()
		if errores.size() > 0:
			print("  preset invalido [" + String(id) + "]: " + ", ".join(errores))
	_check(errores_totales == 0, "todos los presets validan con FotoSchema (0 errores)")
