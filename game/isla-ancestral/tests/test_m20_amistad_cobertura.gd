extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-27
#
# M20-Sistema-De-Amistad - suite de COBERTURA: cierra los items [ ] del modulo que
# son verificables en headless contra la implementacion vigente.
#
# Uso: "<godot_console>" --headless --path game/isla-ancestral
#       --script res://tests/test_m20_amistad_cobertura.gd
# Exit: 0 = verde | 1 = fallos
#
# Criterio estricto (Log 2124): el nombre de cada check contiene TODAS las palabras
# del item que cierra. Los items NO verificables aqui (UI, eventos convocables,
# schema versionado) quedan documentados en 04-Codigo.md, no inflados.

const FS_SCRIPT := preload("res://scripts/friendship/friendship_service.gd")
const EVAL := preload("res://scripts/friendship/gift_evaluator.gd")
const INVENTARIO_SCRIPT := preload("res://scripts/inventario/inventario_service.gd")

const ITEM_PRUEBA := "baya_roja"
const ITEM_INEXISTENTE := "item_inexistente_m20_999"
const ITEM_RETORNO_CARTA := "FLOR_SILVESTRE"
const VECINES_RECORRIDO := 10
const DIAS_RECORRIDO := 10
const NIVEL_MINIMO_RECORRIDO := 5

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []
var _fs: Object = null
var _inv: Node = null
var _baseline: Dictionary = {}


func _initialize() -> void:
	call_deferred("_ejecutar")


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		_detalles.append(nombre)
		print("  [FAIL] %s" % nombre)


func _ejecutar() -> void:
	await process_frame
	print("=== TEST M20 AMISTAD COBERTURA ===")
	_preparar()
	_test_indice_vecinos()
	_test_recompensas_bajo_demanda()
	_test_limites_medianoche()
	_test_persistencia()
	_test_regalo_inventario()
	_test_cartas_adjuntos()
	_test_progreso_nivel()
	_test_coste_evaluacion()
	_test_recorrido_m114()
	_restaurar_inventario()
	_resumen()


func _preparar() -> void:
	_fs = FS_SCRIPT.new()
	_fs.name = "FriendshipTestCobertura"
	root.add_child(_fs)
	_inv = root.get_node_or_null("/root/Inventario")
	if _inv == null:
		_inv = INVENTARIO_SCRIPT.new()
		_inv.name = "Inventario"
		root.add_child(_inv)
	_baseline[ITEM_PRUEBA] = _inv.count_item(ITEM_PRUEBA, true)
	_baseline[ITEM_RETORNO_CARTA] = _inv.count_item(ITEM_RETORNO_CARTA, true)


func _test_indice_vecinos() -> void:
	_check("el indice de vecinos por id es un Dictionary (consultas O(1))",
		typeof(_fs._vecinos) == TYPE_DICTIONARY)
	for i in range(20):
		_fs.registrar_vecino("V%02d" % i)
	var ok: bool = _fs.vecinos().size() >= 20
	for i in range(20):
		if _fs.get_nivel("V%02d" % i) != 1:
			ok = false
	_check("indice de vecinos por id: 20 vecinos registrados se consultan por id (O(1))", ok)


func _test_recompensas_bajo_demanda() -> void:
	var v = _fs._vecino("RECOMP")
	v.aplicar_puntos(19, _fs._recompensas)
	_check("bandeja de recompensas bajo demanda: no hay recompensa pendiente antes de subir de nivel",
		v.get_recompensas_pendientes().is_empty())
	v.aplicar_puntos(1, _fs._recompensas)
	_check("bandeja de recompensas bajo demanda: al subir de nivel la recompensa queda pendiente",
		v.get_recompensas_pendientes().has("receta_herramienta_basica"))
	var copia: Array = v.get_recompensas_pendientes()
	copia.clear()
	_check("bandeja de recompensas bajo demanda: la consulta devuelve copia (no refresco continuo)",
		v.get_recompensas_pendientes().size() == 1)
	_check("reclamar recompensa: se retira de la bandeja y no se puede reclamar dos veces",
		bool(_fs.reclamar_recompensa("RECOMP", "receta_herramienta_basica"))
			and not bool(_fs.reclamar_recompensa("RECOMP", "receta_herramienta_basica")))


func _test_limites_medianoche() -> void:
	_fs.pivote_dia(100)
	_check("dia 100: la charla del dia se permite", bool(_fs.charla("MEDIANOCHE").get("ok", false)))
	_check("dia 100: la segunda charla del mismo dia se rechaza por limite diario",
		str(_fs.charla("MEDIANOCHE").get("motivo", "")) == "limite_diario")
	_fs.pivote_dia(101)
	_check("medianoche (dia 101): el limite diario se recalcula y la charla vuelve a estar disponible",
		bool(_fs.charla("MEDIANOCHE").get("ok", false)))


func _test_persistencia() -> void:
	var vacio := FS_SCRIPT.new()
	vacio.restore_save_data({})
	_check("guardado corrupto del modulo: fallback a estado vacio sin crash",
		vacio.vecinos().is_empty())
	var roto := FS_SCRIPT.new()
	roto.restore_save_data({"vecinos": {"CORR": {"puntos": "basura", "nivel": 999, "regalos": [], "dia": 3}}})
	_check("guardado corrupto del modulo: valores por defecto sin crash (puntos 0, nivel clamp 10)",
		roto.get_puntos("CORR") == 0 and roto.get_nivel("CORR") == 10)
	_fs._vecino("V00").aplicar_puntos(30, _fs._recompensas)
	var copia := FS_SCRIPT.new()
	copia.restore_save_data(_fs.get_save_data())
	copia.registrar_vecino("NUEVO_POST")
	_check("vecinos nuevos agregados al schema sin romper guardados previos (estado previo intacto)",
		copia.get_puntos("V00") == _fs.get_puntos("V00")
			and copia.get_nivel("V00") == _fs.get_nivel("V00")
			and copia.get_nivel("NUEVO_POST") == 1)


func _test_regalo_inventario() -> void:
	var antes: int = _inv.count_item(ITEM_PRUEBA, true)
	_inv.add_item(ITEM_PRUEBA, 1)
	var r: Dictionary = _fs.regalar("INV_TEST", ITEM_PRUEBA)
	var despues: int = _inv.count_item(ITEM_PRUEBA, true)
	_check("extraccion del item al regalar integrada: el item sale del inventario al regalar",
		bool(r.get("ok", false)) and despues == antes and int(r.get("puntos", 0)) > 0)
	var r2: Dictionary = _fs.regalar("INV_VACIO", ITEM_INEXISTENTE)
	_check("inventario vacio: regalar se rechaza con aviso sin_item (no se extrae nada)",
		not bool(r2.get("ok", true)) and str(r2.get("motivo", "")) == "sin_item"
			and _inv.count_item(ITEM_INEXISTENTE, true) == 0)


func _test_cartas_adjuntos() -> void:
	_fs.pivote_dia(200)
	_inv.add_item(ITEM_PRUEBA, 1)
	var antes: int = _inv.count_item(ITEM_PRUEBA, true)
	var env: Dictionary = _fs.enviar_carta("CARTAS", "CARTA_GRACIAS", ITEM_PRUEBA)
	_check("adjuntos de carta usados correctamente: el adjunto se consume del inventario al enviar",
		bool(env.get("ok", false)) and _inv.count_item(ITEM_PRUEBA, true) == antes - 1)
	_fs.pivote_dia(201)
	_fs._procesar_nuevo_dia()
	_check("adjuntos de carta recibidos correctamente: el adjunto de retorno llega al inventario al responder",
		_inv.count_item(ITEM_RETORNO_CARTA, true) == int(_baseline.get(ITEM_RETORNO_CARTA, 0)) + 1)


func _test_progreso_nivel() -> void:
	var v = _fs._vecino("PROGRESO")
	v.aplicar_puntos(25, _fs._recompensas)
	var p: Dictionary = v.get_progreso()
	_check("progress visible: barra de progreso dentro del nivel actual (en_nivel, ancho, progreso)",
		int(p.get("nivel", 0)) == 2 and int(p.get("en_nivel", -1)) == 5
			and int(p.get("ancho", 0)) == 20 and absf(float(p.get("progreso", -1.0)) - 0.25) < 0.001)


func _test_coste_evaluacion() -> void:
	var data := {"gustos": [ITEM_PRUEBA], "disgustos": []}
	var meta := {"id": ITEM_PRUEBA, "categoria": "fruta", "regalo_valido": true}
	var n := 2000
	var t0 := Time.get_ticks_usec()
	for i in range(n):
		EVAL.evaluar(data, meta, false)
	var t1 := Time.get_ticks_usec()
	var medio := float(t1 - t0) / float(n) / 1000.0
	_check("coste de evaluacion menor a 1 ms por regalo (medido %.4f ms en %d evaluaciones)" % [medio, n],
		medio < 1.0)


func _test_recorrido_m114() -> void:
	var errores := 0
	for i in range(VECINES_RECORRIDO):
		var vid := "REC_%02d" % i
		_fs.registrar_vecino(vid)
		for d in range(1, DIAS_RECORRIDO + 1):
			_fs.pivote_dia(300 + d)
			_fs._procesar_nuevo_dia()
			if not bool(_fs.charla(vid).get("ok", false)):
				errores += 1
			_inv.add_item(ITEM_PRUEBA, 1)
			if not bool(_fs.regalar(vid, ITEM_PRUEBA).get("ok", false)):
				errores += 1
			if not bool(_fs.enviar_carta(vid, "CARTA_GENERICA").get("ok", false)):
				errores += 1
	var min_nivel := 99
	for i in range(VECINES_RECORRIDO):
		min_nivel = mini(min_nivel, _fs.get_nivel("REC_%02d" % i))
	_check("recorrido M114: 10 vecinos a nivel 5+ en sesiones simuladas sin fallos (nivel minimo %d, %d errores)"
		% [min_nivel, errores],
		errores == 0 and min_nivel >= NIVEL_MINIMO_RECORRIDO)


func _restaurar_inventario() -> void:
	for id in _baseline:
		var base: int = int(_baseline[id])
		var actual: int = _inv.count_item(id, true)
		if actual > base:
			_inv.remover_items({id: actual - base})
		elif actual < base:
			_inv.add_item(id, base - actual)


func _resumen() -> void:
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0:
		print("TEST M20 COBERTURA FALLIDO")
		quit(1)
	else:
		print("M20 COBERTURA OK (%d checks)" % _checks)
		quit(0)
