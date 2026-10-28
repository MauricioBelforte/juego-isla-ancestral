extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-27
#
# M20-Sistema-De-Amistad - REGRESION del BUG M20 routeado por la directora
# agnes-3-flash (canal MiniMax #059): el limite diario se consumia ANTES de
# validar el inventario, de modo que un regalo/carta fallido por falta de item
# quemaba el intento del dia (el jugador se quedaba sin poder regalar).
#
# Uso: "<godot_console>" --headless --path game/isla-ancestral
#       --script res://tests/test_m20_limite_regalo.gd
# Exit: 0 = verde | 1 = fallos
#
# Guarda anti-falso-verde: MIN_CHECKS；如果 el suite aborta antes de imprimir el
# resumen, sale con codigo 1.

const FS_SCRIPT := preload("res://scripts/friendship/friendship_service.gd")
const INVENTARIO_SCRIPT := preload("res://scripts/inventario/inventario_service.gd")

const MIN_CHECKS := 16

const ITEM_OK := "baya_roja"
const ITEM_INEXISTENTE := "item_inexistente_m20_limite_999"
const NPC_REGALO := "M20_LIMITE_REGALO"
const NPC_CARTA := "M20_LIMITE_CARTA"
const NPC_CUMPLE := "FINNEAS"
const NPC_CARTA_TEXTO := "M20_LIMITE_CARTA_TEXTO"

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []
var _fs: Object = null
var _inv: Node = null
var _baseline_item := 0


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
	print("=== TEST M20 LIMITE DIARIO (regresion bug regalo) ===")
	_preparar()
	_test_regalo_no_quema_limite()
	_test_carta_no_quema_limite()
	_test_carta_validacion_texto()
	_test_cumpleanos_no_quema_limite()
	_test_limite_diario_se_consume()
	_restaurar_inventario()
	_resumen()


func _preparar() -> void:
	_fs = FS_SCRIPT.new()
	_fs.name = "FriendshipTestLimite"
	root.add_child(_fs)
	_inv = root.get_node_or_null("/root/Inventario")
	if _inv == null:
		_inv = INVENTARIO_SCRIPT.new()
		_inv.name = "Inventario"
		root.add_child(_inv)
	_baseline_item = _inv.count_item(ITEM_OK, true)


func _asegurar_item(item_id: String) -> bool:
	if _inv.count_item(item_id, true) > 0:
		return true
	if _inv.has_method("agregar_items"):
		_inv.agregar_items({item_id: 1})
	elif _inv.has_method("add_item"):
		_inv.add_item(item_id, 1)
	return _inv.count_item(item_id, true) > 0


func _limite(npc_id: String, tipo: String) -> Dictionary:
	return _fs._vecino(npc_id).get_limite_dia(tipo)


func _test_regalo_no_quema_limite() -> void:
	_fs.pivote_dia(400)
	_fs.registrar_vecino(NPC_REGALO)
	var r_fallo: Dictionary = _fs.regalar(NPC_REGALO, ITEM_INEXISTENTE)
	_check("regalo rechazado por falta de item: se avisa sin_item y no se entrega nada",
		not bool(r_fallo.get("ok", true)) and str(r_fallo.get("motivo", "")) == "sin_item")
	_check("regalo rechazado por falta de item NO consume el limite diario de regalo",
		int(_limite(NPC_REGALO, "regalo").get("usado", -1)) == 0
			and int(_limite(NPC_REGALO, "regalo").get("restante", -1)) == 1)
	_check("regalo valido del mismo dia tras el fallo: se acepta (limite conservado)",
		_asegurar_item(ITEM_OK) and bool(_fs.regalar(NPC_REGALO, ITEM_OK).get("ok", false)))


func _test_carta_no_quema_limite() -> void:
	_fs.pivote_dia(500)
	_fs.registrar_vecino(NPC_CARTA)
	var env_fallo: Dictionary = _fs.enviar_carta(NPC_CARTA, "CARTA_GRACIAS", ITEM_INEXISTENTE)
	_check("carta con adjunto inexistente: se rechaza con sin_adjunto",
		not bool(env_fallo.get("ok", true)) and str(env_fallo.get("motivo", "")) == "sin_adjunto")
	_check("carta con adjunto inexistente NO consume el limite diario de carta",
		int(_limite(NPC_CARTA, "carta").get("usado", -1)) == 0
			and int(_limite(NPC_CARTA, "carta").get("restante", -1)) == 1)
	_check("carta valida del mismo dia tras el fallo: se envia (limite de carta conservado)",
		bool(_fs.enviar_carta(NPC_CARTA, "CARTA_GRACIAS").get("ok", false)))


func _test_carta_validacion_texto() -> void:
	_fs.pivote_dia(510)
	_fs.registrar_vecino(NPC_CARTA_TEXTO)
	var vacio: Dictionary = _fs.enviar_carta(NPC_CARTA_TEXTO, "")
	_check("carta sin texto seleccionado (texto_id vacio): se rechaza con texto_vacio",
		not bool(vacio.get("ok", true)) and str(vacio.get("motivo", "")) == "texto_vacio")
	_check("carta sin texto no consume el limite diario de carta",
		int(_limite(NPC_CARTA_TEXTO, "carta").get("usado", -1)) == 0)
	var inexistente: Dictionary = _fs.enviar_carta(NPC_CARTA_TEXTO, "CARTA_QUE_NO_EXISTE")
	_check("carta con texto_id inexistente en data: se rechaza con texto_invalido",
		not bool(inexistente.get("ok", true)) and str(inexistente.get("motivo", "")) == "texto_invalido")
	_check("carta con texto_id inexistente no consume el limite diario de carta",
		int(_limite(NPC_CARTA_TEXTO, "carta").get("usado", -1)) == 0)
	_check("carta con texto_id valido tras los rechazos: se envia (limite de carta conservado)",
		bool(_fs.enviar_carta(NPC_CARTA_TEXTO, "CARTA_GENERICA").get("ok", false)))


func _test_cumpleanos_no_quema_limite() -> void:
	var datos: Dictionary = _fs.get_cumpleanos(NPC_CUMPLE)
	if datos.is_empty():
		_check("cumpleanos: hay datos de cumpleanos cargados para el vecino de prueba", false)
		return
	_fs.pivote_fecha(600, int(datos.get("mes", 1)), int(datos.get("dia", 1)), 1)
	_check("cumpleanos: la fecha de prueba coincide con el cumpleanos del vecino",
		bool(_fs.es_cumpleanos_hoy(NPC_CUMPLE)))
	var r_fallo: Dictionary = _fs.regalar_en_cumpleanos(NPC_CUMPLE, ITEM_INEXISTENTE)
	_check("regalo de cumpleanos rechazado por falta de item: se avisa sin_item",
		not bool(r_fallo.get("ok", true)) and str(r_fallo.get("motivo", "")) == "sin_item")
	_check("regalo de cumpleanos fallido NO consume el limite diario de cumpleanos",
		int(_limite(NPC_CUMPLE, "cumpleanos").get("usado", -1)) == 0)
	_check("regalo de cumpleanos valido tras el fallo: se acepta (limite conservado)",
		_asegurar_item(ITEM_OK) and bool(_fs.regalar_en_cumpleanos(NPC_CUMPLE, ITEM_OK).get("ok", false)))
	_check("regalo de cumpleanos NO consume el limite diario de regalo",
		int(_limite(NPC_CUMPLE, "regalo").get("usado", -1)) == 0)


func _test_limite_diario_se_consume() -> void:
	_fs.pivote_dia(700)
	_fs.registrar_vecino("M20_LIMITE_CONSUMO")
	_asegurar_item(ITEM_OK)
	var r1: Dictionary = _fs.regalar("M20_LIMITE_CONSUMO", ITEM_OK)
	_check("regalo valido: el limite diario de regalo queda consumido (usado=1)",
		bool(r1.get("ok", false)) and int(_limite("M20_LIMITE_CONSUMO", "regalo").get("usado", -1)) == 1)
	var r2: Dictionary = _fs.regalar("M20_LIMITE_CONSUMO", ITEM_OK)
	_check("segundo regalo del mismo dia: se rechaza con limite_diario",
		not bool(r2.get("ok", true)) and str(r2.get("motivo", "")) == "limite_diario")
	_fs.pivote_dia(701)
	_asegurar_item(ITEM_OK)
	var r3: Dictionary = _fs.regalar("M20_LIMITE_CONSUMO", ITEM_OK)
	_check("dia siguiente: el limite diario de regalo se reinicia y el regalo se acepta",
		bool(r3.get("ok", false)))


func _restaurar_inventario() -> void:
	var actual: int = _inv.count_item(ITEM_OK, true)
	if actual > _baseline_item:
		_inv.remover_items({ITEM_OK: actual - _baseline_item})
	elif actual < _baseline_item:
		_inv.add_item(ITEM_OK, _baseline_item - actual)


func _resumen() -> void:
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < MIN_CHECKS:
		print("TEST M20 LIMITE DIARIO FALLIDO (fallos=%d, checks=%d, min=%d)" % [_fallos, _checks, MIN_CHECKS])
		quit(1)
	else:
		print("M20 LIMITE DIARIO OK (%d checks)" % _checks)
		quit(0)
