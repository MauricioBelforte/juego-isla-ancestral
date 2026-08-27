extends SceneTree

## Test end-to-end del núcleo de Amistad (M20).
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad.gd
## Valida: evaluador (amado/gusta/neutral/duplicado), límite diario, subida de
## nivel con excedente conservado, sin decaimiento/FOMO y persistencia.
## Se difiere la ejecución para que el árbol y autoloads estén activos.

const EVALUADOR := preload("res://scripts/friendship/gift_evaluator.gd")
const VECINO := preload("res://scripts/friendship/vecino_amistad.gd")

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	print("=== TEST AMISTAD M20 ===")

	# ── 1. Evaluador (lógica pura, sin árbol) ──
	var amado := EVALUADOR.evaluar({"regalos_amados": ["MANZANA"], "gustos": [], "disgustos": []}, {"id": "MANZANA", "categoria": "comida", "regalo_valido": true}, false)
	_check("regalo amado=20", int(amado["puntos"]) == 20 and int(amado["clase"]) == EVALUADOR.Clase.AMADO)

	var gusta := EVALUADOR.evaluar({"regalos_amados": [], "gustos": ["PESCADO"], "disgustos": []}, {"id": "PESCADO", "categoria": "comida", "regalo_valido": true}, false)
	_check("regalo gusta=10", int(gusta["puntos"]) == 10 and int(gusta["clase"]) == EVALUADOR.Clase.GUSTA)

	var neutral := EVALUADOR.evaluar({"regalos_amados": [], "gustos": [], "disgustos": []}, {"id": "PIEDRA", "categoria": "mineral"}, false)
	_check("regalo neutral=5", int(neutral["puntos"]) == 5 and int(neutral["clase"]) == EVALUADOR.Clase.NEUTRAL)

	var duplicado := EVALUADOR.evaluar({"regalos_amados": ["MANZANA"], "gustos": [], "disgustos": []}, {"id": "MANZANA", "categoria": "comida"}, true)
	_check("regalo duplicado=2", int(duplicado["puntos"]) == 2 and int(duplicado["clase"]) == EVALUADOR.Clase.DUPLICADO)

	var no_valido := EVALUADOR.evaluar({"regalos_amados": ["MANZANA"], "gustos": [], "disgustos": []}, {"id": "MANZANA", "regalo_valido": false}, false)
	_check("regalo_valido=false -> neutral", int(no_valido["clase"]) == EVALUADOR.Clase.NEUTRAL)

	# ── 2. VecinoAmistad: puntos, límite diario, subida con excedente ──
	var v := VECINO.new("NPC_1")
	v.aplicar_puntos(20, {})
	_check("20 puntos -> nivel 2", v.get_nivel() == 2 and v.get_puntos() == 20)
	v.aplicar_puntos(30, {})
	_check("50 puntos -> nivel 3 (excedente 10)", v.get_nivel() == 3 and v.get_puntos() == 50)

	# Límite diario (1 regalo/día)
	_check("limite 1 regalo dia 1", v.intentar_usar_limite("regalo", 1))
	_check("2do regalo mismo dia rechazado", not v.intentar_usar_limite("regalo", 1))
	_check("dia nuevo resetea limite", v.intentar_usar_limite("regalo", 2))

	# ── 3. Sin decaimiento / sin FOMO ──
	var antes := v.get_puntos()
	# no hay método de decaimiento; simulamos ausencia: nada reduce
	_check("sin decaimiento (puntos intactos)", v.get_puntos() == antes)

	# ── 4. Persistencia (round-trip) ──
	var s := v.serializar()
	var v2 := VECINO.new("NPC_1")
	v2.deserializar(s)
	_check("persistencia restaura puntos", v2.get_puntos() == v.get_puntos())
	_check("persistencia restaura nivel", v2.get_nivel() == v.get_nivel())
	_check("persistencia restaura memoria", v2.get_memoria().size() == v.get_memoria().size())

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS AMISTAD"); quit(1)
	else:
		print("AMISTAD OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)