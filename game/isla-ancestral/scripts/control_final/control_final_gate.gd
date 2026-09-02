# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M151: ControlFinalGate — gate CLI de la puerta de release.
# Lee el estado de gates desde data/control_final/estado_release.json
# (actualizado por los sistemas QA/CI) y devuelve:
#   0 = RELEASE OK (7 gates cumplidos) · 1 = BLOQUEADO (gates inscritos)
# Uso: godot --headless -s res://scripts/control_final/control_final_gate.gd

extends SceneTree

const SCHEMA := preload("res://scripts/control_final/control_final_schema.gd")
const RUTA_ESTADO := "res://data/control_final/estado_release.json"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var estado: Dictionary = {}
	if FileAccess.file_exists(RUTA_ESTADO):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_ESTADO))
		if typeof(parsed) == TYPE_DICTIONARY:
			estado = parsed.get("gates", {})
	var pendientes: Array[String] = SCHEMA.verificar_gates(estado)
	if pendientes.is_empty():
		print("== [M151] CONTROL FINAL: RELEASE OK (7/7 gates cumplidos) ==")
		quit(0)
	else:
		print("== [M151] CONTROL FINAL: BLOQUEADO — gates pendientes: %s ==" % ", ".join(pendientes))
		quit(1)
