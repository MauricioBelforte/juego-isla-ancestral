# Modelo: ERNIE-5.5-Flash-Preview
# Plataforma: Kilo Code
# Fecha: 2026-11-17
#
# M169: Tests del CruceroManager (7 pruebas).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/unit/test_crucero_manager.gd
#
# Nota: el proyecto usa tests estilo SceneTree (ver tests/test_m65.gd), no suites GdUnit4,
# aunque el addon este instalado. Se sigue la convencion real del repo.
#
# El autoload no se resuelve como identificador en modo --script (parse-time), pero SI
# existe en runtime como hijo del root: se obtiene con get_node_or_null y, si faltara,
# se instancia el script para que el test corra igual.

extends SceneTree

var _ok: int = 0
var _fallos: int = 0
var _cm: Node = null


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _manager() -> Node:
	if _cm != null:
		return _cm
	_cm = root.get_node_or_null("CruceroManager")
	if _cm == null:
		var script: Script = load("res://scripts/crucero/crucero_manager.gd")
		_cm = script.new()
		root.add_child(_cm)
	return _cm


func _correr() -> void:
	print("\n=== TEST M169 CRUCERO MANAGER ===")

	var cm := _manager()
	_check("manager disponible", cm != null)
	if cm == null:
		print("RESULTADO: 0 OK / 1 FAIL (sin manager)")
		quit(1)
		return

	# 1-2. catalogos
	_check("3 clases cargadas", cm.clases_disponibles().size() == 3)
	_check("7 camarotes cargados", cm.camarotes_disponibles().size() == 7)

	# 3. precios del catalogo
	_check("precio primera = 140", cm.precio_de(&"primera") == 140)
	_check("precio tercera = 30", cm.precio_de(&"tercera") == 30)
	_check("suite duo tiene 2 niveles", int(cm.info_camarote(&"suite_duo").get("niveles", 0)) == 2)

	# 4-5. cubiertas
	cm.cambiar_cubierta(1)
	_check("cambiar a cubierta 4", cm.cambiar_cubierta(4) and cm.cubierta_actual == 4)
	_check("rechaza cubierta 9", cm.cambiar_cubierta(9) == false)
	_check("rechaza cubierta -1", cm.cambiar_cubierta(-1) == false)

	# 6. persistencia roundtrip
	var d: Dictionary = cm.a_dict()
	cm.cambiar_cubierta(1)
	cm.cargar_desde(d)
	_check("roundtrip conserva cubierta 4", cm.cubierta_actual == 4)

	# 7. estado inicial / embarque sin pasaje
	_check("estado inicial ATRACADO", int(cm.estado) == 0)
	_check("sin pasaje no se puede embarcar", cm.puede_embarcar() == false)

	# extra: rechazo de clase inexistente
	var r: Dictionary = cm.vender_pasaje(&"clase_que_no_existe", &"ruta", &"origen", &"destino")
	_check("rechaza clase inexistente", not bool(r.get("ok", true)))

	print("\nRESULTADO: %d OK / %d FAIL" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)