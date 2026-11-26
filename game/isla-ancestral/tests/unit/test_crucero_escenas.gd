# Modelo: ERNIE-5.5-Flash-Preview
# Plataforma: Kilo Code
# Fecha: 2026-11-26
#
# M169: Verifica que las escenas de interior carguen sin errores (T04-01).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/unit/test_crucero_escenas.gd
#
# Convencion SceneTree del repo. Carga cada .tscn, la instancia, comprueba que
# tenga StaticBody3D (colisiones) y la libera (queue_free) para no acumular.

extends SceneTree

var _ok: int = 0
var _fallos: int = 0


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _correr() -> void:
	print("\n=== TEST M169 CRUCERO ESCENAS (interiores) ===")
	var cubiertas := [1, 2, 3, 4]
	var cargadas := 0
	for n: int in cubiertas:
		var ruta := "res://scenes/crucero/interior_cubierta_%d.tscn" % n
		var ps: PackedScene = load(ruta)
		_check("escena %d carga" % n, ps != null)
		if ps == null:
			continue
		var inst: Node = ps.instantiate()
		root.add_child(inst)
		cargadas += 1
		# Debe tener al menos un StaticBody3D (colisiones piso/paredes).
		var bodies := inst.find_children("*", "StaticBody3D", true, false)
		_check("escena %d tiene StaticBody3D" % n, bodies.size() >= 1)
		# El script CruceroInterior debe estar en la raiz.
		_check("escena %d usa CruceroInterior" % n, inst.get_script() != null)
		inst.queue_free()

	_check("4/4 interiores cargados", cargadas == 4)
	print("\nRESULTADO: %d OK / %d FAIL" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)