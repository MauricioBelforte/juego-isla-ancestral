extends SceneTree

## Test de eventos de Amistad (M20) integrados con el calendario M29:
##  - Deteccion de cumpleanos (mes/dia) via M29
##  - Regalo y celebracion de cumpleanos SIN consumir el limite diario "regalo"
##  - Cartas con respuesta diferida al dia siguiente (M29)
##  - Bandeja de correo y persistencia
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/friendship/test_amistad_eventos.gd

const VECINO := preload("res://scripts/friendship/vecino_amistad.gd")
const FS_SCRIPT := preload("res://scripts/friendship/friendship_service.gd")
const PERFIL := preload("res://scripts/npc/villager_profile.gd")
const EVAL := preload("res://scripts/friendship/gift_evaluator.gd")
const WSS := preload("res://scripts/dialogos/world_state_service.gd")
const BUS := preload("res://scripts/core/event_bus.gd")

var _fallos := 0
var _checks := 0
var _fs: Object       # instancia de FriendshipService (sin arbol; ver _ejecutar)

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	print("=== TEST AMISTAD EVENTOS M20 (cumpleanos + cartas M29) ===")
	# En modo --script el autoload Friendship NO es alcanzable como hijo de /root
	# (se carga despues de este script). Se instancia manualmente y se cargan los
	# datos de forma explicita, igual que test_amistad.gd (sin depender del arbol).
	_fs = FS_SCRIPT.new()
	_fs._cargar_cumpleanos()
	_fs._cargar_cartas()
	if _fs._cumpleanos.is_empty():
		_check("datos de cumpleanos cargados", false)
		_print_resumen(); quit(1)
		return

	_test_cumpleanos_logica()
	_test_cumpleanos_cap_separado()
	_test_cumpleanos_senal_y_carta()
	_test_celebrar_cumpleanos()
	_test_carta_diferida()
	_test_persistencia()
	_test_sincronizar_cumpleanos_m19()
	_test_gustos_reales_m19()
	_test_niveles_config()
	_test_reaccion_m21()
	_test_dom_amistad()

	_print_resumen()

func _test_cumpleanos_logica() -> void:
	# FINNEAS cumple el 12/4 (ver cumpleanos.json)
	_fs.pivote_fecha(100, 4, 12, 1)   # anio 1, mes 4, dia 12
	_check("es_cumpleanos_hoy(FINNEAS) en su fecha", _fs.es_cumpleanos_hoy("FINNEAS"))
	_fs.pivote_fecha(100, 4, 13, 1)
	_check("es_cumpleanos_hoy(FINNEAS) fuera de fecha = false", not _fs.es_cumpleanos_hoy("FINNEAS"))
	_fs.pivote_fecha(100, 7, 3, 1)
	_check("es_cumpleanos_hoy(MARA) en 3/7", _fs.es_cumpleanos_hoy("MARA"))

	var prox: Dictionary = _fs.proximo_cumpleanos("FINNEAS")   # hoy 3/7, cumple 12/4
	# dia del ano: 12/4 -> (4-1)*28+12 = 96 ; hoy 3/7 -> (7-1)*28+3 = 171 ; falta 96-171<0 -> +336 = 261
	_check("proximo_cumpleanos(FINNEAS).dias = 261", int(prox.get("dias", -1)) == 261)
	_check("proximo_cumpleanos(FINNEAS).edad = edad_base (anio 1)", int(prox.get("edad", -1)) == 28)

	# wrap al ano siguiente: si hoy es el cumpleanos, falta 336
	_fs.pivote_fecha(100, 4, 12, 1)
	var prox2: Dictionary = _fs.proximo_cumpleanos("FINNEAS")
	_check("proximo_cumpleanos en dia de cumpleanos = 336 (ano siguiente)", int(prox2.get("dias", -1)) == 336)

func _test_cumpleanos_cap_separado() -> void:
	# El regalo de cumpleanos usa su propio tope y NO consume el "regalo" diario.
	var v := VECINO.new("VNPC")
	_check("limite cumpleanos dia 1 libre", v.intentar_usar_limite("cumpleanos", 1))
	_check("limite regalo dia 1 sigue libre (separado)", v.intentar_usar_limite("regalo", 1))
	_check("2do regalo mismo dia bloqueado", not v.intentar_usar_limite("regalo", 1))
	_check("2do cumpleanos mismo dia bloqueado", not v.intentar_usar_limite("cumpleanos", 1))
	_check("dia nuevo resetea ambos", v.intentar_usar_limite("regalo", 2) and v.intentar_usar_limite("cumpleanos", 2))

func _test_cumpleanos_senal_y_carta() -> void:
	# GDScript captura escalares por valor en lambdas: se usa un Dictionary
	# (tipo referencia) para que la senal escriba el resultado de forma fiable.
	var res := {"emitido": false, "edad": -1}
	_fs.cumpleanos_hoy.connect(func(vid: String, edad: int):
		res["emitido"] = true
		res["edad"] = edad
	)
	_fs.pivote_fecha(100, 4, 12, 2)   # anio 2: FINNEAS cumple, edad = 28 + (2-1) = 29
	_fs._procesar_nuevo_dia()
	_check("cumpleanos_hoy emitido el dia del cumpleanos", res["emitido"] == true)
	_check("edad de cumpleanos = edad_base + (anio-1)", int(res["edad"]) == 29)
	# El NPC envia una carta de cumpleanos a la bandeja del jugador
	var bandeja: Array = _fs.get_bandeja("FINNEAS")
	_check("carta de cumpleanos en bandeja", bandeja.size() >= 1 and str(bandeja[-1].get("respuesta_id","")) == "CUMPLEANOS")

func _test_celebrar_cumpleanos() -> void:
	_fs.registrar_vecino("FINNEAS")
	_fs.pivote_fecha(200, 4, 12, 1)
	var r1: Dictionary = _fs.celebrar_cumpleanos("FINNEAS")
	_check("celebrar_cumpleanos ok => +15 puntos", r1.get("ok", false) and int(r1.get("puntos", -1)) == 15)
	_check("puntos del vecino = 15 tras celebrar", _fs.get_puntos("FINNEAS") == 15)
	var r2: Dictionary = _fs.celebrar_cumpleanos("FINNEAS")   # mismo anio
	_check("celebrar 2 veces el mismo anio => ya_celebrado", not r2.get("ok", true) and str(r2.get("motivo","")) == "ya_celebrado")
	_fs.pivote_fecha(200, 4, 13, 1)
	var r3: Dictionary = _fs.celebrar_cumpleanos("FINNEAS")
	_check("celebrar fuera de cumpleanos => no_es_cumpleanos", not r3.get("ok", true) and str(r3.get("motivo","")) == "no_es_cumpleanos")

func _test_carta_diferida() -> void:
	_fs.registrar_vecino("TEST_CARTA")
	_fs.pivote_fecha(500, 1, 1, 1)
	var env: Dictionary = _fs.enviar_carta("TEST_CARTA", "CARTA_GENERICA")
	_check("enviar_carta ok", env.get("ok", false))
	_check("carta pendiente registrada", _fs.get_cartas_pendientes("TEST_CARTA").size() == 1)
	# mismo dia: segundo envio bloqueado por limite diario
	var env2: Dictionary = _fs.enviar_carta("TEST_CARTA", "CARTA_GRACIAS")
	_check("2da carta mismo dia => limite_diario", not env2.get("ok", true) and str(env2.get("motivo","")) == "limite_diario")
	# avanzar al dia siguiente (M29) -> madura y aplica puntos
	_fs.pivote_fecha(501, 1, 2, 1)
	_fs._procesar_nuevo_dia()
	var pend: Array = _fs.get_cartas_pendientes("TEST_CARTA")
	var rec: Array = _fs.get_bandeja("TEST_CARTA")
	_check("carta madurada: 0 pendientes", pend.size() == 0)
	_check("carta madurada: 1 recibida", rec.size() == 1)
	_check("carta recibida aplica 8 puntos", _fs.get_puntos("TEST_CARTA") == 8)
	_check("respuesta_id = texto_id + _R", str(rec[0].get("respuesta_id","")) == "CARTA_GENERICA_R")

func _test_persistencia() -> void:
	# El estado de cartas/cumpleanos sobrevive a guardar/cargar (M59).
	var snap: Dictionary = _fs.get_save_data()
	var tmp: Object = FS_SCRIPT.new()
	tmp._cumpleanos = _fs._cumpleanos.duplicate(true)
	tmp.restore_save_data(snap)
	check("restore: bandeja de TEST_CARTA conservada", tmp.get_bandeja("TEST_CARTA").size() == 1)
	check("restore: puntos TEST_CARTA conservados", tmp.get_puntos("TEST_CARTA") == 8)
	check("restore: anio_cumpleanos FINNEAS conservado", int(tmp._anio_cumpleanos.get("FINNEAS", 0)) == 1)

func _test_sincronizar_cumpleanos_m19() -> void:
	# Perfil M19 valido con cumpleanos -> se carga en _cumpleanos
	var p := PERFIL.new()
	p.id = "CATALINA"; p.nombre = "Catalina"
	p.cumpleanos_mes = 6; p.cumpleanos_dia = 14; p.edad_base = 29
	_check("sync M19: set_cumpleanos_desde_perfil ok", _fs.set_cumpleanos_desde_perfil(p))
	_check("sync M19: mes CATALINA = 6", int(_fs.get_cumpleanos("CATALINA").get("mes", 0)) == 6)
	_check("sync M19: dia CATALINA = 14", int(_fs.get_cumpleanos("CATALINA").get("dia", 0)) == 14)
	_check("sync M19: edad_base CATALINA = 29", int(_fs.get_cumpleanos("CATALINA").get("edad_base", -1)) == 29)
	# Override del seed JSON: FINNEAS viene del JSON (4/12); un perfil M19 lo pisa.
	var p2 := PERFIL.new()
	p2.id = "FINNEAS"; p2.cumpleanos_mes = 1; p2.cumpleanos_dia = 1; p2.edad_base = 99
	_fs.set_cumpleanos_desde_perfil(p2)
	_check("sync M19: FINNEAS override del seed JSON (mes 1)", int(_fs.get_cumpleanos("FINNEAS").get("mes", 0)) == 1)
	# Perfil sin fecha (mes 0) NO debe sincronizar ni pisar nada
	var p3 := PERFIL.new()
	p3.id = "SINFECHA"
	_check("sync M19: perfil sin fecha no sincroniza", not _fs.set_cumpleanos_desde_perfil(p3) and _fs.get_cumpleanos("SINFECHA").is_empty())
	# Nodo ajeno (no VillagerProfile) tampoco sincroniza
	_check("sync M19: nodo ajeno no sincroniza", not _fs.set_cumpleanos_desde_perfil(VECINO.new("X")))

func _test_gustos_reales_m19() -> void:
	# A (gustos reales): el perfil M19 cacheado alimenta GiftEvaluator con
	# gustos/disgustos reales (antes _get_vecino_data devolvia null => siempre NEUTRAL).
	var p := PERFIL.new()
	p.id = "CATALINA_G"; p.nombre = "CatalinaG"
	p.cumpleanos_mes = 6; p.cumpleanos_dia = 14; p.edad_base = 29
	p.gustos = ["FLOR_SILVESTRE", "miel"]
	p.disgustos = ["PESCADO"]
	_check("gustos M19: set_cumpleanos_desde_perfil cachea perfil", _fs.set_cumpleanos_desde_perfil(p))
	var d: Dictionary = _fs._get_vecino_data("CATALINA_G")
	_check("gustos M19: dict tiene gustos", d.get("gustos", []).size() == 2)
	var ev_gusta: Dictionary = EVAL.evaluar(d, {"id": "FLOR_SILVESTRE", "regalo_valido": true}, false)
	_check("gustos M19: FLOR_SILVESTRE => GUSTA (10)", int(ev_gusta["clase"]) == int(EVAL.Clase.GUSTA))
	var ev_disp: Dictionary = EVAL.evaluar(d, {"id": "PESCADO", "regalo_valido": true}, false)
	_check("gustos M19: PESCADO (disgusto) => NEUTRAL (0)", int(ev_disp["clase"]) == int(EVAL.Clase.NEUTRAL))
	# Sin perfil cacheado => NEUTRAL (cozy, sin castigo)
	var ev_neutro: Dictionary = EVAL.evaluar(_fs._get_vecino_data("SINPERFIL_X"), {"id": "x", "regalo_valido": true}, false)
	_check("gustos M19: sin perfil => NEUTRAL", int(ev_neutro["clase"]) == int(EVAL.Clase.NEUTRAL))

func _test_niveles_config() -> void:
	# C (niveles en .tres): FriendshipService carga amistad_config.tres y lo
	# inyecta en cada VecinoAmistad; fallback a const UMBRALES si falta el .tres.
	_fs._cargar_config()
	_check("niveles: umbrales cargados (size 11)", _fs._umbrales.size() == 11)
	_check("niveles: umbral nivel 2 = 20", int(_fs._umbrales[1]) == 20)
	var vn: Object = _fs._vecino("T_NIVEL")
	_check("niveles: VecinoAmistad usa umbrales inyectados", vn.umbrales.size() == 11)
	_check("niveles: 20 pts => sube a nivel 2", vn.aplicar_puntos(20, {}) == true and vn.get_nivel() == 2)

func _test_reaccion_m21() -> void:
	# B (reaccion M21): el regalo propaga la CLASE EXACTA (GiftEvaluator.Clase) y
	# WorldStateService la lee EN VIVO para condiciones de dialogo amistad_<npc>.
	# 1) Contrato de senal: gift_given lleva 3 args (npc, item, clase), no liked:bool.
	var bus_def := BUS.new()
	var args_gift := -1
	for s in bus_def.npc.get_signal_list():
		if str(s["name"]) == "gift_given":
			args_gift = int(s["args"].size())
	_check("M21: gift_given lleva clase exacta (3 args)", args_gift == 3)
	# 2) Propagacion: _emitir_npc_events EMITE en gift_given la CLASE EXACTA (M21 la consume).
	# Se inyecta _fs en el arbol para que la emision llegue al EventBus real, y se prueba
	# con clases distintas para descartar que M21 solo reciba un bool "liked".
	if root == null:
		_check("M21: arbol no disponible para emit", false); return
	_fs.name = "FriendshipTest"
	root.add_child(_fs)
	var bus: Node = root.get_node_or_null("/root/EventBus")
	if bus == null or bus.npc == null:
		_check("M21: EventBus autoload disponible", false); return
	var emitido := {"clase": -99}
	bus.npc.gift_given.connect(func(npc_id: String, item_id: String, clase: int):
		emitido["clase"] = clase)
	# La clase GUSTA debe propagarse tal cual (no colapsada a liked:bool).
	_fs._emitir_npc_events("R_M21", "FLOR_SILVESTRE", int(EVAL.Clase.GUSTA))
	_check("M21: gift_given EMITE clase GUSTA exacta (no solo liked)",
		int(emitido["clase"]) == int(EVAL.Clase.GUSTA))
	# Y para una clase distinta, para descartar hardcoded.
	_fs._emitir_npc_events("R_M21B", "PIEDRA", int(EVAL.Clase.NEUTRAL))
	_check("M21: gift_given EMITE clase NEUTRAL exacta",
		int(emitido["clase"]) == int(EVAL.Clase.NEUTRAL))
	# 3) Puente en vivo: WorldStateService lee el nivel de M20 (autoload real Friendship).
	var fs_real: Node = root.get_node_or_null("/root/Friendship")
	if fs_real == null:
		_check("M21: Friendship autoload disponible para puente", false); return
	var ws := WSS.new()
	root.add_child(ws)
	fs_real.registrar_vecino("R_M21_WS")
	fs_real._vecino("R_M21_WS").aplicar_puntos(20, {})
	_check("M21: WorldStateService amistad_R_M21_WS = nivel vivo M20",
		int(ws.get_value("amistad_R_M21_WS", -1)) == fs_real.get_nivel("R_M21_WS"))

func _test_dom_amistad() -> void:
	# D (DOM-AMISTAD): log centralizado con rotacion (cap LOG_CAP) y persistencia.
	_fs.registrar_evento("regalo", "D_A", "FLOR_SILVESTRE", int(EVAL.Clase.GUSTA))
	_fs.registrar_evento("nivel", "D_A", "2")
	_fs.registrar_evento("cumpleanos", "D_A", "")
	_fs.registrar_evento("carta_npc", "D_A", "CUMPLEANOS")
	_check("DOM: al menos 1 evento registrado", _fs.get_eventos().size() >= 1)
	check("DOM: filtrado por npc devuelve eventos de D_A", _fs.get_eventos_npc("D_A").size() >= 1)
	var tipos_da := []
	for e in _fs.get_eventos_npc("D_A"):
		tipos_da.append(str(e.get("tipo", "")))
	_check("DOM: D_A registra regalo/nivel/cumpleanos/carta",
		"regalo" in tipos_da and "nivel" in tipos_da and "cumpleanos" in tipos_da and "carta_npc" in tipos_da)
	# Rotacion: empujar mas alla de LOG_CAP (100). Los mas antiguos se descartan.
	for i in range(150):
		_fs.registrar_evento("rot", "D_B", str(i))
	_check("DOM: rotacion respeta cap %d" % _fs.LOG_CAP, _fs.get_eventos().size() <= _fs.LOG_CAP)
	# Persistencia: el log sobrevive a guardar/cargar (M59).
	var snap: Dictionary = _fs.get_save_data()
	var tmp: Object = FS_SCRIPT.new()
	tmp._cumpleanos = _fs._cumpleanos.duplicate(true)
	tmp.restore_save_data(snap)
	check("DOM: eventos persistidos tras restore", tmp.get_eventos().size() >= 1)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

# alias para no colisionar con la senal carta_recibida
func check(nombre: String, cond: bool) -> void:
	_check(nombre, cond)

func _print_resumen() -> void:
	print("=== Resumen eventos: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS AMISTAD EVENTOS"); quit(1)
	else:
		print("AMISTAD EVENTOS OK"); quit(0)
