extends SceneTree
# Sonda FIX agnes #033: GiftEvaluator._clasificar con item_meta = Dictionary
# (ruta de tests) Y ItemData Resource (ruta de produccion, ItemDatabase.get_item).
# Confirma: 0 SCRIPT ERROR + clase/puntos exactos por caso.

const G = preload("res://scripts/friendship/gift_evaluator.gd")
const ID = preload("res://scripts/data/item_data.gd")

var _fallos := 0

func _ck(label: String, r: Dictionary, exp_clase: int, exp_pts: int) -> void:
	var ok := (int(r["clase"]) == exp_clase and int(r["puntos"]) == exp_pts)
	if not ok:
		_fallos += 1
	print(("OK  " if ok else "FAL ") + label + " -> clase=%s puntos=%s (esp clase=%s pts=%s)" % [int(r["clase"]), int(r["puntos"]), exp_clase, exp_pts])

func _init() -> void:
	# 1. Dictionary (test path): vecino ama el item.
	_ck("1 dict-ama", G.evaluar({"regalos_amados": ["FLOR"]}, {"id": "FLOR", "regalo_valido": true}, false), 0, 20)
	# 2. Resource (produccion): ItemData id=PESCADO, vecino lo ama.
	var it := ID.new()
	it.id = "PESCADO"
	_ck("2 res-ama", G.evaluar({"regalos_amados": ["PESCADO"]}, it, false), 0, 20)
	# 3. Resource sin gustos -> NEUTRAL.
	_ck("3 res-neutro", G.evaluar({}, it, false), 2, 5)
	# 4. ya_regalado -> DUPLICADO (2 pts).
	_ck("4 duplicado", G.evaluar({}, it, true), 3, 2)
	# 5. Dictionary regalo_valido=false -> NEUTRAL.
	_ck("5 inv-invalido", G.evaluar({"regalos_amados": ["FLOR"]}, {"id": "FLOR", "regalo_valido": false}, false), 2, 5)
	# 6. Resource sin id (id="") -> NEUTRAL (item no es regalo valido).
	var it2 := ID.new()
	_ck("6 res-sin-id", G.evaluar({"regalos_amados": ["X"]}, it2, false), 2, 5)
	# 7. Resource gusta (no amado) -> GUSTA 10.
	var it3 := ID.new(); it3.id = "MANZANA"
	_ck("7 res-gusta", G.evaluar({"gustos": ["MANZANA"]}, it3, false), 1, 10)
	print("=== SONDAGIFT: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)
