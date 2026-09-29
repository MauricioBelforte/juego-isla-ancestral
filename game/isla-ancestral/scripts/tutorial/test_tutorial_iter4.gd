# Modelo: glm-5.3-flash
# Plataforma: Cline
# Fecha: 2026-09-17
#
# M92: Test de iter. 4 — Q5 guiones .tres (Resource + fallback) y Q2/Q7 hot path.
# Complementa test_tutorial / test_tutorial_triggers / test_tutorial_iter3.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/tutorial/test_tutorial_iter4.gd

extends SceneTree

var _fallos: int = 0
var _tut: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_tut = root.get_node_or_null("Tutorial")
	_check(_tut != null, "Tutorial autoload presente")
	if _tut == null:
		print("=== TEST M92 ITER4: 1 fallo(s) ===")
		quit(1)
		return
	_test_q5_resource()
	_test_q5_consumido_por_manager()
	_test_q2_q7_hot_path()
	print("=== TEST M92 ITER4: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Q5: el Resource existe, expone 'capitulos' y trae los 4 capítulos base completos
func _test_q5_resource() -> void:
	var res: Resource = load("res://data/tutorial/guiones_base.tres")
	_check(res != null, "Q5: guiones_base.tres carga sin errores")
	if res == null:
		return
	var caps = res.get("capitulos")
	_check(caps is Dictionary, "Q5: el recurso expone 'capitulos' Dictionary")
	if not (caps is Dictionary):
		return
	_check(caps.size() == 4, "Q5: 4 capítulos base serializados (hay %d)" % caps.size())
	for cid in ["prologo", "interactuar", "herramienta", "vecino"]:
		_check(caps.has(cid), "Q5: capítulo '%s' presente en el .tres" % cid)
	var p: Dictionary = caps.get("prologo", {})
	_check(String(p.get("meta", "")) == "mover", "Q5: prólogo con meta 'mover'")
	_check(bool(p.get("rejugable", false)) == true, "Q5: prólogo rejugable")
	_check(p.get("pasos", []).size() == 2, "Q5: prólogo con 2 pasos")
	_check(bool(p.get("extra", {}).get("guiado", false)) == true, "Q5: prólogo guiado (RF9/T-043)")

## Q5: el manager consumió el .tres al arrancar (capítulos registrados e intactos)
func _test_q5_consumido_por_manager() -> void:
	_check(_tut.capitulos.has("prologo"), "Q5: manager registró 'prologo' desde el Resource")
	var pro: Dictionary = _tut.capitulos.get("prologo", {})
	_check(String(pro.get("meta", "")) == "mover", "Q5: meta del .tres llegó al manager")
	_check(pro.get("pasos", []).size() == 2, "Q5: pasos del prólogo intactos tras la carga")
	_check(bool(pro.get("guiado", false)) == true, "Q5: flag 'guiado' del .tres llegó al manager (RF9)")
	_check(_tut.capitulos.has("vecino") and bool(_tut.capitulos["vecino"].get("rejugable", false)),
		"Q5: 'vecino' rejugable según el .tres")

## Q2/Q7: hot path — con targets vacíos no consulta al jugador; proximidad intacta con target
func _test_q2_q7_hot_path() -> void:
	_check(_tut._targets_mundo.is_empty(), "Q2: sin triggers de mundo al iniciar el test")
	# Excede el throttle (0.25 s): con targets vacíos NO debe consultar al jugador
	_tut._process(0.3)
	_tut._process(0.01)
	_check(_tut.pistas_vivas() == 0, "Q7: sin pistas el vencimiento es no-op (sin allocs)")
	_check(_tut.get_save_data() is Dictionary, "Q7: guardado accesible tras ticks con hot path vacío")
	# Con un target registrado la proximidad sigue funcionando (el early-return no la rompe)
	var stub := Node3D.new()
	stub.name = "PlayerIter4"
	stub.add_to_group("player")
	root.add_child(stub)
	stub.global_position = Vector3(915, 40, 900)  # 10 m del target: fuera del radio 5
	_tut.registrar_capitulo("cap_iter4_q2", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_ITER4", "icono_tecla": ""}
	], "meta_iter4_q2", false)
	_tut.registrar_trigger_mundo("t_iter4", Vector3(905, 40, 900), 5.0, "cap_iter4_q2")
	_tut._process(0.3)
	_tut._process(0.01)
	_check(not _tut.capitulo_estado("meta_iter4_q2") and _tut.activo_actual != "cap_iter4_q2",
		"Q2: con target registrado y jugador lejos NO dispara (proximidad intacta)")
	stub.global_position = Vector3(903, 40, 900)  # 2 m: dentro
	_tut._process(0.3)
	_tut._process(0.01)
	_check(_tut.capitulo_estado("meta_iter4_q2") or _tut.activo_actual == "cap_iter4_q2",
		"Q2: jugador dentro del radio → dispara (early-return no rompe el polling necesario)")
	_tut.desregistrar_trigger_mundo("t_iter4")
	stub.queue_free()
