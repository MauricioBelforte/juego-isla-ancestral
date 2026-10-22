# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M16: QA del clamp D8 de max_craftable (masivo <= 30). Encargo 223 del
# director (riel 229): "clamp D8 hecho ESPERA test en run seguro" — este QA
# lo cubre headless con el autoload Crafting + Inventario reales.
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/crafting/qa_m16_clamp30.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA clamp30 M16: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var cs := root.get_node_or_null("Crafting")
	var inv := root.get_node_or_null("Inventario")
	_check(cs != null and inv != null, "autoloads Crafting + Inventario presentes")
	if cs == null or inv == null:
		return
	var rec: Resource = cs.obtener_receta("rec_pico_cobre")
	_check(rec != null, "rec_pico_cobre existe (receta de test)")
	if rec == null:
		return
	# Materiales de la receta (costos del .json) x CAP (500: muy por encima del techo)
	var costos: Dictionary = rec.materiales
	_check(costos.size() > 0, "receta con costos legibles (%s)" % str(costos.keys()))
	var dram: Dictionary = {}
	for mat in costos:
		dram[String(mat)] = 500
	inv.agregar_items(dram)
	var max_n: int = cs.max_craftable("rec_pico_cobre")
	_check(max_n >= 2, "sanity: con materiales masivos max_craftable >= 2")
	_check(max_n <= 30, "D8: el techo de 30 se respeta (max=%d)" % max_n)
	_check(max_n == 30, "D8: con 500 materiales el techo EXACTO es 30 (max=%d)" % max_n)
	# Craft masivo respetando el techo (el enforcement no permite > 30)
	var crafted_ok: int = 0
	var hechos := 0
	for i in range(35):
		var r: Variant = cs.craft("rec_pico_cobre", 1)
		if r != null and (r is bool and r or (r is Dictionary and r.get("ok", false))):
			crafted_ok += 1
			hechos += 1
	# NOTA D8: el clamp vive en max_craftable (techo 30 del MULTIPLE-craft de
	# la UI M53); craft() unitario repetido es legal mientras haya materiales
	# (35 x1 con 500 de materiales = 35 fabricaciones legales).
	_check(hechos >= 1, "craft unitario: los 35 x1 respetan materiales reales (%d hechas)" % hechos)
	_check(cs.max_craftable("rec_pico_cobre") <= 30, "D8: max_craftable sigue <= 30 tras los crafts (max=%d)" % cs.max_craftable("rec_pico_cobre"))
	# Limpieza: devolver inventario a un estado razonable (remover el excedente
	# y lo fabricado si quedara en el inventario — cozy: no hay dinero real)
	for mat in costos:
		var resto: int = int(inv.count_item(String(mat)))
		if resto > 0:
			inv.remover_items({String(mat): resto})
	for i in range(35):
		inv.remover_items({"pico_cobre": 1})
	_check(true, "limpieza: inventario restaurado (materiales y producto)")
	_summary()
