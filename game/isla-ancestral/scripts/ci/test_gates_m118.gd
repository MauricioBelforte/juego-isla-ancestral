# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M118 iter. 2 — Test headless de gates automáticos (data_valid + assets_existen).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ci/test_gates_m118.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var m118 := root.get_node_or_null("CiCdManager")
	_check(m118 != null, "CiCdManager autoload presente")
	if m118 == null:
		print("=== TEST M118 ITER2: 1 fallo(s) ===")
		quit(1)
		return
	# Gate data_valid: todos los .json de data/ parsean sin error (retorna bool)
	var r_data: bool = m118.gate_data_valid()
	_check(r_data, "gate_data_valid OK (0 errores)")
	# Gate assets_existen: GLBs en media/ no vacíos
	var r_assets: bool = m118.gate_assets_existen()
	_check(r_assets, "gate_assets_existen OK")
	# Ejecutar todos los gates automáticos
	var res: Dictionary = m118.ejecutar_gates_automaticos()
	_check(res.has("data_valid"), "ejecutar_gates_automaticos incluye data_valid")
	_check(res.has("assets_existen"), "ejecutar_gates_automaticos incluye assets_existen")
	print("=== TEST M118 ITER2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
