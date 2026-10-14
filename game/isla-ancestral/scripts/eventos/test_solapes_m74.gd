# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-11
#
# M74 Eventos — solapes por prioridad (J7/J8/J12/J20), pedidos por el director
# (msg 150).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_solapes_m74.gd

extends SceneTree

const EM = preload("res://scripts/eventos/event_manager.gd")

const CHECKS_MINIMOS: int = 26

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

func _mgr() -> Node:
	var m = load("res://scripts/eventos/event_manager.gd").new()
	root.add_child(m)
	return m

func _ev(id: String, prioridad: int, extra: Dictionary = {}) -> EventDefinition:
	var e := EventDefinition.new()
	e.id = id
	e.prioridad = prioridad
	for k in extra.keys():
		e.set(k, extra[k])
	return e

# ── bloques ──────────────────────────────────────────────────────────────

## 1. J7: orden por prioridad.
func _b1_prioridad(mgr) -> void:
	_abrir("1", "J7: prioridad festival > competencia > feria > ritual > sorpresa")
	# Orden canónico pedido por el item (menor número = más importante en el
	# diseño original; aquí `prioridad` mayor gana, así que se mapea).
	var fest := _ev("festival", 100)
	var comp := _ev("competencia", 80)
	var feria := _ev("feria", 60)
	var ritual := _ev("ritual", 40)
	var sorp := _ev("sorpresa", 20)
	var mezcla: Array = [sorp, ritual, fest, feria, comp]
	var orden: Array = EM.ordenar_por_prioridad(mezcla)
	_ok(orden.size() == 5, "ordenó los 5 eventos")
	_ok(String((orden[0] as EventDefinition).id) == "festival", "gana el festival")
	_ok(String((orden[1] as EventDefinition).id) == "competencia", "2do la competencia")
	_ok(String((orden[2] as EventDefinition).id) == "feria", "3ro la feria")
	_ok(String((orden[3] as EventDefinition).id) == "ritual", "4to el ritual")
	_ok(String((orden[4] as EventDefinition).id) == "sorpresa", "5to la sorpresa")

	# Empate: desempate determinista por id (no depende del orden del diccionario)
	var a := _ev("aaa", 50)
	var b := _ev("bbb", 50)
	var ord2: Array = EM.ordenar_por_prioridad([b, a])
	_ok(String((ord2[0] as EventDefinition).id) == "aaa", "empate -> id alfabético (determinista)")
	_fin("1")

## 2. J7/J8: resolver solapes del día.
func _b2_resolver(mgr) -> void:
	_abrir("2", "J7/J8: ganador y perdedores corridos un día")
	mgr.limpiar_reprogramados()
	mgr._catalogo.clear()
	mgr._catalogo["festival"] = _ev("festival", 100, {"dia": 10, "mes": 3})
	mgr._catalogo["competencia"] = _ev("competencia", 80, {"dia": 10, "mes": 3})

	var reprogramados: Array = []
	mgr.evento_reprogramado.connect(func(_id, f): reprogramados.append(f))
	var ganadores: Array = []
	mgr.solape_resuelto.connect(func(g, p): ganadores.append([g, p]))

	var r: Dictionary = mgr.resolver_solapes({"dia": 10, "mes": 3, "estacion": 0, "anio": 1})
	_ok(r["ganador"] != null and String((r["ganador"] as EventDefinition).id) == "festival",
		"gana el festival (mayor prioridad)")
	var perdedores: Array = r["perdedores"]
	_ok(perdedores.size() == 1 and String(perdedores[0]) == "competencia",
		"la competencia es la perdedora")
	_ok(reprogramados.size() == 1, "se emite evento_reprogramado (aviso)")
	_ok(ganadores.size() == 1, "se emite solape_resuelto")

	var f: Dictionary = reprogramados[0]
	_ok(int(f["dia"]) == 11 and int(f["mes"]) == 3, "se corre al día siguiente (11/3)")
	var ef: Dictionary = mgr.fecha_efectiva("competencia")
	_ok(int(ef["dia"]) == 11 and int(ef["mes"]) == 3, "fecha_efectiva refleja la reprogramación")

	# En el día siguiente, el evento corrido ya aparece en la agenda
	var del_11: Array = mgr.get_eventos_del_dia({"dia": 11, "mes": 3, "estacion": 0})
	var hay: bool = false
	for e in del_11:
		if String((e as EventDefinition).id) == "competencia":
			hay = true
	_ok(hay, "al día siguiente la competencia aparece en la agenda")
	var del_10: Array = mgr.get_eventos_del_dia({"dia": 10, "mes": 3, "estacion": 0})
	var queda: bool = false
	for e in del_10:
		if String((e as EventDefinition).id) == "competencia":
			queda = true
	_ok(not queda, "y ya no aparece el día del festival")

	# Día sin solape: un solo evento -> es el ganador y no se corre nadie
	mgr._catalogo.clear()
	mgr._catalogo["feria"] = _ev("feria", 60, {"dia": 20, "mes": 3})
	var r3: Dictionary = mgr.resolver_solapes({"dia": 20, "mes": 3, "estacion": 0, "anio": 1})
	_ok(r3["perdedores"].is_empty() and r3["ganador"] != null,
		"día con un solo evento -> ganador sin perdedores")
	_ok(String((r3["ganador"] as EventDefinition).id) == "feria",
		"el único evento del día es el ganador")
	# Día sin eventos -> nada que resolver
	var r4: Dictionary = mgr.resolver_solapes({"dia": 21, "mes": 3, "estacion": 0, "anio": 1})
	_ok(r4["ganador"] == null and r4["perdedores"].is_empty(), "día sin eventos -> nada que resolver")
	_fin("2")

## 3. J12/J20: fin de mes y año.
func _b3_limites(mgr) -> void:
	_abrir("3", "J12/J20: corrida al siguiente mes/año")
	# 28 -> 1 del mes siguiente
	var s: Dictionary = mgr._siguiente_dia(28, 3, 1)
	_ok(int(s["dia"]) == 1 and int(s["mes"]) == 4 and int(s["anio"]) == 1, "28 de mes -> 1 del siguiente")
	# 28/12 -> 1/1 del año siguiente
	var f: Dictionary = mgr._siguiente_dia(28, 12, 1)
	_ok(int(f["dia"]) == 1 and int(f["mes"]) == 1 and int(f["anio"]) == 2, "fin de año -> 1/1 del año 2")
	# Un evento reprogramado al 1 del mes siguiente ya no se "pierde"
	mgr.limpiar_reprogramados()
	mgr._catalogo.clear()
	mgr._catalogo["f"] = _ev("f", 100, {"dia": 28, "mes": 12})
	mgr._catalogo["g"] = _ev("g", 50, {"dia": 28, "mes": 12})
	var r: Dictionary = mgr.resolver_solapes({"dia": 28, "mes": 12, "estacion": 3, "anio": 1})
	_ok(r["perdedores"].size() == 1, "se resolvió el solape de fin de año")
	var ef: Dictionary = mgr.fecha_efectiva("g")
	_ok(int(ef["dia"]) == 1 and int(ef["mes"]) == 1 and int(ef["anio"]) == 2,
		"el perdedor cae el 1/1 del año siguiente (no se pierde)")
	mgr.limpiar_reprogramados()
	_fin("3")

## 4. Persistencia de los reprogramados.
func _b4_persistencia(mgr) -> void:
	_abrir("4", "J7/J8: reprogramaciones en el save")
	mgr.limpiar_reprogramados()
	mgr._catalogo.clear()
	mgr._catalogo["a"] = _ev("a", 100, {"dia": 5, "mes": 5})
	mgr._catalogo["b"] = _ev("b", 20, {"dia": 5, "mes": 5})
	mgr.resolver_solapes({"dia": 5, "mes": 5, "estacion": 1, "anio": 1})
	_ok(mgr.reprogramados().size() == 1, "1 reprogramado antes de guardar")

	var data: Dictionary = mgr.get_save_data()
	_ok(data.has("reprogramados"), "el save trae 'reprogramados'")
	var otro := _mgr()
	otro.restore_save_data(data)
	_ok(otro.reprogramados().size() == 1, "round-trip: la reprogramación sobrevive")
	var ef: Dictionary = otro.fecha_efectiva("b")
	_ok(int(ef["dia"]) == 6, "y apunta al día correcto")
	otro.free()
	mgr.limpiar_reprogramados()
	_fin("4")

## 5. Integración: el ciclo diario resuelve solo.
func _b5_ciclo(mgr) -> void:
	_abrir("5", "J7/J8 integrado al dia_cambio")
	mgr.limpiar_reprogramados()
	mgr._catalogo.clear()
	mgr._catalogo["fest"] = _ev("fest", 100, {"dia": 0, "mes": -1})
	mgr._catalogo["comp"] = _ev("comp", 80, {"dia": 0, "mes": -1})
	var vistos: Array = []
	mgr.evento_reprogramado.connect(func(id, _f): vistos.append(id))
	mgr._on_dia_cambio({"anio": 1, "mes": 1, "dia": 1, "estacion": 0, "hora": 8, "minuto": 0})
	_ok(vistos.size() == 1, "el dia_cambio resuelve el solape y avisa (dio %d)" % vistos.size())
	_ok(String(vistos[0]) == "comp", "el perdedor es el de menor prioridad")
	mgr.limpiar_reprogramados()
	_fin("5")

func _run() -> void:
	var mgr = _mgr()
	_ok(mgr != null, "EventManager instanciado")
	if mgr == null:
		return
	_b1_prioridad(mgr)
	_b2_resolver(mgr)
	_b3_limites(mgr)
	_b4_persistencia(mgr)
	_b5_ciclo(mgr)
	mgr.free()

func _summary() -> void:
	print("=== RESUMEN M74 SOLAPES: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON:")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d < %d" % [_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
