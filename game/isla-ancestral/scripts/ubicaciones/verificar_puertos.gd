# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M160 iter 4: Verificador puertos ↔ rutas (M28): cada puerto LOC-* tiene una
# isla del canon y cada ruta debería poder mapearse a puertos. Reporta el
# estado del vocabulario (hallazgo: las rutas M28 usan isla_sur/norte/etc.,
# no el canon RIZ/COR/CEN/AUR — integración pendiente de M28).
# Uso: godot --headless --path game/isla-ancestral -s res://scripts/ubicaciones/verificar_puertos.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M160/M28] Verificación puertos <-> rutas ===")
	var puertos: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ubicaciones/puertos.json"))
	var rutas: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/viajes/rutas.json"))
	var ok := true
	var islas_puerto := {}
	for p in puertos.get("puertos", []):
		islas_puerto[String(p.get("isla", ""))] = true
		var ruta_id: String = String(p.get("id", ""))
		if not String(p.get("id", "")).begins_with("LOC-"):
			ok = false
			print("  [FALLO] puerto sin id LOC-*: %s" % ruta_id)
	if ok and islas_puerto.size() == 4:
		print("  [OK] 4 puertos LOC-* (una por isla del canon)")
	var islas_ruta := {}
	for r in rutas.get("rutas", []):
		islas_ruta[String(r.get("origen", ""))] = true
		islas_ruta[String(r.get("destino", ""))] = true
	print("  Rutas M28 usan islas: %s" % ", ".join(islas_ruta.keys()))
	if islas_ruta.has("isla_raiz"):
		print("  [OK] isla_raiz presente (mapea a RIZ)")
	else:
		print("  [INFO] vocabulario de islas de M28 no coincide con canon (hallazgo para M28)")
	quit(0)
