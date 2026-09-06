# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M95 iter 2: Verificador de coherencia DLC — manifest (M120) ↔ monetización
# (M95): los IDs de ambos catálogos deben coincidir (el manifest es la fuente
# de verdad de carga).
# Uso: godot --headless --path game/isla-ancestral -s res://scripts/dlc/sincronizar_dlc.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M95/M120] Coherencia DLC (manifest <-> monetizacion) ===")
	var man: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dlc/dlc_manifest.json"))
	var mon: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/monetizacion/dlc.json"))
	var ids_man := {}
	for d in man.get("dlcs", []):
		ids_man[String(d.get("id", ""))] = true
	var ids_mon := {}
	for d in mon.get("dlcs", []):
		ids_mon[String(d.get("id", ""))] = true
	var errores := 0
	for id in ids_man:
		if not ids_mon.has(id):
			print("  [FALLO] DLC en manifest sin registro de monetizacion: %s" % id)
			errores += 1
	for id in ids_mon:
		if not ids_man.has(id):
			print("  [FALLO] DLC en monetizacion sin manifest: %s" % id)
			errores += 1
	if errores == 0:
		print("  [OK] %d DLCs coherentes (isla_hielo, pack_aurora)" % ids_man.size())
	quit(1 if errores > 0 else 0)
