# Modelo: glm-5.3-flash (original) · endurecido por Step-5-WorkBuddy (iter. 2, 2026-10-21, Log 2082)
# Plataforma: Kilo Code / WorkBuddy
# Fecha: 2026-09-01 (original) · 2026-10-21 (guarda anti-falso-verde + postgame x4 finales)
#
# M23: Test de SecondaryStoriesService (motor, tipos de paso, ocultas, postgame,
# validador anti-repetición, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/historias/test_historias.gd
#
# Iter. 2 (Step-5-WorkBuddy): la versión original imprimía "0 fallo(s)" SIN contador
# de checks ni marcadores de bloque: un SCRIPT ERROR dentro de un bloque abortaba la
# función en silencio y la suite igual daba verde (familia falso-verde). Se agregó la
# guarda de 3 capas del repo: _fin(bloque) + CHECKS_MINIMOS medido en verde + _summary()
# en un call_deferred SEPARADO (si _run() aborta, el resumen corre igual y sale EXIT 1).
# El bloque postgame se extendió a los 4 finales de M22 (data/historia/historia_principal.json:
# final_principal/final_regresar/final_guardian/final_secreto).
# Iter. 3 (Step-5-WorkBuddy, 2026-10-21, Log 2083): merge de cadenas_ejemplo.json
# (GO del director, msg 151). Bloque A mide el catálogo mergeado (5 cadenas) y el
# bloque H afirma el reporte del merge + corrida end-to-end de la cadena añadida.
# Iter. 4 (Step-5-WorkBuddy, 2026-10-21, Log 2085): normalización de claves
# estado_mundo.* -> flags pelados (GO del director, msg 153), data-only en
# cadenas_ejemplo.json. Bloque H afirma la clave pelada en WorldState y el bloque
# I afirma que AMBAS cargas (principal y ejemplos, crudas y mergeadas) quedan en
# el mismo esquema. El principal mantiene UNA condicion con prefijo
# (secundarias.json, cadena-faro p1: 'estado_mundo.faro_apagado'): es declarativa
# (ningún consumidor en scripts/) y quedó fuera del GO — reportada al director.
# Iter. 5 (Step-5-WorkBuddy, 2026-10-22, Log 2107): 6 historias de vecinos
# (03-Diseno L31: panadera, carpintero, tejedora, pescador, guarda, alquimista;
# el farero ya estaba cubierto por cadena-faro y la doctora NO tiene NPC en
# data/villagers/ — 15 villagers medidos, ninguno médico: ítem [?] con evidencia,
# no se inventa el personaje). Bloque J afirma carga, fuente, unicidad de
# consecuencias y corrida end-to-end de DOS de las nuevas (carpintero con
# madera_roble real de data/items/ y alquimista con objeto narrativo).
# Iter. 6 (Step-5-WorkBuddy, 2026-10-22, Log 2117): cluster Lugares del 03-Diseno
# (biblioteca ya cubierta en iter. 3; faro por cadena-faro de las 4 previas).
# 3 cadenas nuevas —jardines, cofradía, molino— con NPC REALES de data/villagers/
# (mateo_mapache granjero, mercedes_lince mercader, aria_ciervo trovadora) y
# objetos REALES de data/items/ (baya_roja, fragmento_ancestral, fibra_algodon).
# Bloque K afirma carga, fuente, unicidad de consecuencias/diarios y corrida
# end-to-end de las 3. molino_funcionando era flag HUERFANO (0 archivos, Log 2082):
# la cadena-molino le da respaldo en datos.
# Iter. 7 (Step-5-WorkBuddy, 2026-10-22, Log 2125): cluster Ruinas del 03-Diseno
# L33 (biblioteca quemada, observatorio, estacion, puente). NPC REALES de
# data/villagers/ (sofia_buho bibliotecaria, vera_ardilla farera, ramon_tejon
# herrero, luna_zorra artesana) y objetos REALES de data/items/ (ancient_crystal,
# iron_ore, piedra_caliza); tomo_carbonizado es narrativo (0 items de libro en
# data/items/, mismo patron que farol_cargado/jarabe_lunar). Bloque L afirma
# carga, fuente, unicidad de consecuencias/diarios y corrida end-to-end de las 4.
# Correccion propia: la lista `existentes` del bloque K decia
# "sendero_bosque_senalizado" (con z) pero el flag real en datos es
# "sendero_bosque_senalado" -> la lista no detectaria colision con el flag real.
# Iter. 8 (Step-5-WorkBuddy, 2026-10-22, Log 2127): cluster Objetos del 03-Diseno
# L34 (relicto, gema, carta, llave, farol, brujula). NPC REALES de data/villagers/
# (teo_conejo herbolario, pablo_pato ceramista, catalina_oso cocinera, bruno_sapo
# carpintero, nico_gato guardabosques, finneas_zorro pescador) y objetos REALES de
# data/items/ (gemstone, OBJ-SEC-001 "Llave oculta", OBJ-LUZ-005 "Farol",
# OBJ-SEC-004 "Reliquia oculta"); carta_sellada y brujula_desorientada son
# narrativos (0 items de carta/brujula en data/items/, mismo patron que
# tomo_carbonizado). Bloque M afirma carga, fuente, unicidad de consecuencias y
# diarios y corrida end-to-end de las 6.
# Iter. 10 (Step-5-WorkBuddy, 2026-10-22, Log 2131): cluster Amistad del 03-Diseno
# L44 (regalo favorito, sentadilla de pesca, paseos, ficcion + ayuda a un vecino y
# cartas de amistad como 6.a mision: el 02-Analisis L25 nombra 5 temas para 6
# misiones). NPC REALES de data/villagers/ (olivia_nutria tejedora, finneas_zorro
# pescador, sofia_buho bibliotecaria, aria_ciervo trovadora, mercedes_lince
# mercader, luna_zorra artesana) y objetos REALES de data/items/ (OBJ-ROP-005
# "Bufanda", OBJ-ITE-036 "Te", OBJ-NAT-022 "Flor rara", OBJ-NAT-023 "Flor
# luminiscente", OBJ-ITE-035 "Miel", OBJ-NAT-004 "Flor silvestre"). Bloque O
# afirma carga, fuente, unicidad de consecuencias/diarios y corrida end-to-end
# de las 6.
# Iter. 11 (Step-5-WorkBuddy, 2026-10-22, Log 2134): cluster Secretas del
# 03-Diseno L38 (5 cadenas ocultas desbloqueadas por mundo: mapa secreto,
# cristal oculto, diario antiguo, pergamino mistico, mascara ceremonial).
# NPC REALES de data/villagers/ (nico_gato, vera_ardilla, sofia_buho,
# teo_conejo, luna_zorra) y objetos REALES de data/items/ por campo id
# (OBJ-SEC-002 "Mapa secreto", OBJ-SEC-003 "Cristal oculto", OBJ-SEC-005
# "Diario antiguo", OBJ-ART-002 "Pergamino mistico", OBJ-ART-004 "Mascara
# ceremonial"). Las 5 nacen oculta:true -> invisibles en
# cadenas_disponibles() hasta iniciarse (misma regla que
# cadena-secretta-luciernagas, bloque E). Bloque P afirma carga, fuente,
# ocultamiento, unicidad de consecuencias/diarios y corrida end-to-end de 2.
# Iter. 12 (Step-5-WorkBuddy, 2026-10-22, Log 2135): cluster Comerciantes del
# 03-Diseno L36 (3 cadenas de rutas y secretos; integracion M37 excluida por
# orden del director, msg 181). NPC REALES de data/villagers/ (mercedes_lince
# mercader, olivia_nutria sastra, ramon_tejon herrero) y objetos REALES de
# data/items/ por campo id (OBJ-ITE-052 "Moneda de oro", OBJ-ITE-010 "Tela",
# OBJ-TAL-002 "Yunque"). A diferencia de las secretas del bloque P, las 3
# nacen visibles: son rutas de trueque que se descubren hablando. Bloque Q
# afirma carga, fuente, visibilidad, unicidad de consecuencias/diarios y
# corrida end-to-end de 2.
# Iter. 15 (Step-5-WorkBuddy, 2026-10-23, Log 2166): cluster Exploracion del
# 03-Diseno L39 (8 misiones: brujula, fauna (M65), cronitar ruinas + 5
# extensiones declaradas). NPC REALES de data/villagers/ (finneas_zorro,
# teo_conejo, sofia_buho, aria_ciervo, catalina_oso, olivia_nutria, nico_gato,
# ramon_tejon) y objetos REALES de data/items/ por campo id (OBJ-HER-016
# "Lupa mejorada", OBJ-NAT-027 "Liana", OBJ-REL-004 "Reloj ancestral",
# OBJ-LUZ-015 "Lampara de lava", OBJ-LUZ-013 "Lampara de sal", OBJ-ITE-009
# "Cuerda", OBJ-HER-004 "Hoz", OBJ-ITE-013 "Clavos"). Integracion con M65
# (fauna) excluida, mismo patron que M37 en Comerciantes. Bloque T afirma
# carga, fuente, unicidad de consecuencias/diarios y corrida end-to-end de 3.
# Iter. 22 (2026-10-25, DeepSeek-V4.1-Flash): L159 del 05-Checklist — bloque Z
# _test_e2e_diez(): 10 cadenas COMPLETAS (una por cluster) con driver generico
# que lee la evidencia del dato + round-trip de persistencia de las 10. Hallazgo
# medido: la cadena mergeada cadena-biblioteca declara capitulo-biblioteca, fuera
# de la normalizacion mision_<id> de la iter. 21 (esa tanda toco solo
# secundarias.json); queda fijado como excepcion con guarda.

extends SceneTree

const MODULO := "M23"
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB"]

var _fallos: int = 0
var _checks: int = 0
var _h: Node = null
var _bus: Node = null
var _vistos: Dictionary = {}
## Bloque AB: eventos cosmetico_desbloqueado capturados (var miembro: las
## lambdas capturan por VALOR, un local no se veria).
var _cosm_eventos: Array = []

# Piso MEDIDO en verde (iter. 15, 2026-10-23, Log 2166): 543 checks con los
# bloques A-T (iter. 14 tenia 477 con A-S; el bloque T del cluster Exploracion
# sumo 66: 24 carga/fuente/no-oculta + 1 expuestas + 2 unicidad local +
# 8 NPC reales + 8 objetos reales + 1 diarios + 3x7 end-to-end + 1 puente
# diario + 1 higiene de flags). Medido: 543/0/EXIT 0 x3. El guardian se probo
# EN ROJO por inyeccion de runtime sobre el bloque T (ver Log 2166).
# Re-medido en el cierre del 2026-10-24 (Log 2166): 543/0/EXIT 0 x3 y
# guardian EN ROJO 478 checks / 2 fallos / EXIT 1 (inyeccion de runtime
# sobre el bloque T, sonda borrada y suite restaurada byte-exacta).
# Iter. 16 (Log 2169, 2026-10-24): +3 cadenas de construccion en disco (62
# principal + biblioteca = 63 cargadas) -> 6 asserts de conteo REPARADOS
# (esperaban 59/60) + bloque U del cluster Construccion (+37 checks: 9 carga/
# fuente/no-oculta + 3 temas previos + 1 expuestas + 2 unicidad local +
# 1 diarios + 3 NPC reales + 3 objetos reales + 2x7 end-to-end + 1 puente
# diario). Piso MEDIDO en verde: 580/0/EXIT 0 x3. El guardian se probo
# EN ROJO por inyeccion de runtime sobre el bloque U (ver Log 2169).
# Iter. 17 (Log 2172, 2026-10-24): +5 cadenas del cluster Agricultura (item
# L71 del 05; 03-Diseno L41 nombra invernadero/cruces/variantes M32 ->
# invernadero con cadena previa del principal, variantes DUENO M32 fuera, 1
# nombrada + 4 de extension declarada) -> 67 cadenas en el principal, 68
# cargadas. 4 asserts de conteo REPARADOS (63->68 x3, 62->67 x1, mismos
# valores en los mensajes) + bloque V del cluster Agricultura (+44 checks:
# 15 carga/fuente/no-oculta + 1 tema previo + 1 expuestas + 2 unicidad local
# + 1 diarios + 4 NPC reales + 5 objetos reales + 2x7 end-to-end + 1 puente
# diario). Piso MEDIDO en verde: 624/0/EXIT 0 x3. El guardian se probo
# EN ROJO por inyeccion de runtime sobre el bloque V (ver Log 2172).
# Iter. 18 (Log 2173, 2026-10-24): +10 cadenas de los clusters Pesca (item
# L77 del 05; 03-Diseno L42 nombra 3 temas -> 3 nombrados + 1 de extension
# declarada) y Coleccion (item L78; 03-Diseno L43 nombra los 6 temas) ->
# 77 cadenas en el principal, 78 cargadas. 4 asserts de conteo REPARADOS
# (67->77 x2, 68->78 x2, mismos valores en los mensajes) + bloque W
# _test_pesca_coleccion() (+67 checks: 30 carga/fuente/no-oculta + 1
# expuestas + 2 unicidad local + 1 diarios + 1 NPC distintos + 6 NPC reales
# + 1 objetos distintos + 10 objetos reales + 2x7 end-to-end + 1 puente
# diario). Titulo de cadena-coleccion-sellos renombrado ("Los Sellos de
# los Oficios") por colision con cadena-cofradia de iter. 6. Piso MEDIDO en
# verde: 691/0/EXIT 0 x3. El guardian se probo EN ROJO por inyeccion de
# runtime sobre el bloque W (ver Log 2173).
# Iter. 19 (2026-10-24): +3 cadenas del cluster Postgame (items L129/L132/
# L133/L134 del 05; 03-Diseno L47 nombra las 4: reconstruccion de la plaza
# YA cubierta por cadena-epilogo-plaza del principal + memorial del Sello +
# epilogo de la aldea + epilogo del guardian, final secreto -> oculta) ->
# 80 cadenas en el principal, 81 cargadas. 4 asserts de conteo REPARADOS
# (78->81 x2, 77->80 x1, mismos valores en los mensajes) + bloque X
# _test_postgame_cluster(). El guardian se probara EN ROJO por inyeccion de
# runtime sobre el bloque X.
# Iter. 21 (2026-10-25): L97 "20 capitulos de diario" — el puente M23->M55
# consumia data muerta (derivaba "mision_"+id sin leer recompensa.diario; 79
# valores capitulo-* con 0 usos en todo el codebase) y el catalogo de M55
# (data/diario/diario_catalog.json) solo tiene 2 de las 79 entradas
# (mision_cadena-faro, mision_cadena-invernadero) -> 77 recompensas degradan
# en silencio (registrar() false, diary_service.gd L136-137; contenido de
# M55, reportado a la directora). Fix: el puente CONSUME el capitulo declarado
# + los 79 valores renombrados al esquema real mision_<cadena_id>
# (comportamiento identico: las 2 con respaldo siguen registrando, las 77
# siguen degradando = hallazgo de M55) + bloque Y _test_recompensa_diario()
# (+8 checks: invariante diario == 'mision_'+id, 79 con / 1 sin, 77 sin
# respaldo en catalogo M55, runtime faro registrado / biblioteca no). Piso
# MEDIDO en verde: 750/0/EXIT 0 x3. El guardian se probo EN ROJO por
# inyeccion de runtime sobre el bloque Y (743<750, EXIT 1).
# Iter. 22 (2026-10-25, DeepSeek-V4.1-Flash): +bloque Z _test_e2e_diez()
# (10 cadenas completas, una por cluster, driver generico + round-trip de
# persistencia) = +119 checks. Piso MEDIDO en verde: 869/0/EXIT 0 x3. El
# guardian se probo EN ROJO en DOS modos sobre el bloque Z: (a) aborto por
# error de runtime (subscript dinamico) -> 751 checks / 1 fallo / EXIT 1 con
# "[FAIL] el bloque Z NO se ejecuto"; (b) asercion falsa sobre la excepcion
# medida -> 869 checks / 1 fallo / EXIT 1. Archivo restaurado byte-exacto
# (sha256 identico) tras cada sonda.
const CHECKS_MINIMOS := 923

# Los 4 finales de M22 (historia_principal.json, tipo "final").
const FINALES_M22 := ["principal", "regresar", "guardian", "secreto"]

# Sellos que exige c4/c7 del grafo de M22 (7 sellos + flag de templo).
const SELLOS_C4 := ["sello_ceniza_sala1", "sello_ceniza_sala2", "sello_mar_intermedia",
	"sello_mar_sala1", "sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_h = root.get_node_or_null("Historias")
	_bus = root.get_node_or_null("EventBus")
	_check(_h != null, "Historias autoload presente")
	_check(_bus != null, "EventBus presente")
	if _h == null:
		return
	_test_carga()
	_test_validador()
	_test_cadena_completa()
	_test_entrega_inventario()
	_test_ocultas()
	_test_postgame()
	_test_persistencia()
	_test_merge_ejemplos()
	_test_esquema_consistente()
	_test_vecinos()
	_test_lugares()
	_test_ruinas()
	_test_objetos()
	_test_familias()
	_test_amistad()
	_test_secretas()
	_test_comerciantes()
	_test_puzzles_investigacion()
	_test_consecuencias()
	_test_exploracion()
	_test_construccion()
	_test_agricultura()
	_test_pesca_coleccion()
	_test_postgame_cluster()
	_test_recompensa_diario()
	_test_e2e_diez()
	_test_consecuencia_taller()
	_test_cosmeticos()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d): posible aborto silencioso" % [_checks, CHECKS_MINIMOS])
	print("=== TEST %s HISTORIAS: %d fallo(s) (%d checks) ===" % [MODULO, _fallos, _checks])
	quit(1 if _fallos > 0 else 0)


func _test_carga() -> void:
	# Iter. 3: 4 del principal + 1 mergeada de ejemplos (cadena-biblioteca).
	# Iter. 5 (Log 2107): +6 historias de vecinos en el principal -> 10 + 1 = 11.
	# Iter. 6 (Log 2117): +3 del cluster Lugares -> 13 + 1 = 14.
	# Iter. 7 (Log 2125): +4 del cluster Ruinas -> 17 + 1 = 18.
	# Iter. 10 (Log 2131): +6 del cluster Amistad -> 32 + 1 = 33.
	# Iter. 11 (Log 2134): +5 del cluster Secretas -> 37 + 1 = 38.
	# Iter. 12 (Log 2135): +3 del cluster Comerciantes -> 40 + 1 = 41.
	# Iter. 13 (Log 2137): +11 de los clusters Puzzles + Investigacion -> 51 + 1 = 52.
	# Iter. 15 (Log 2166): +8 del cluster Exploracion -> 59 + 1 = 60.
	# Iter. 16 (Log 2169): +3 del cluster Construccion (plaza/senderos/kiosko,
	# aparecidas en el worktree 04:04 por corrida cortada y barridas por el CRON
	# en f6a07c6) -> 62 + 1 = 63. Los asserts de conteo de ABAJO se repararon en
	# la misma iterada: con 62 cadenas en disco la suite habia quedado ROJA
	# (6 fallos / EXIT 1, medido 05:13) por expects de 59/60 desactualizados.
	# Iter. 23 (Log 2197): +1 cadena del item L109 (cadena-taller, consecuencia
	# taller_abierto) -> 81 principal + 1 mergeada = 82 cargadas.
	_check(_h.cadenas_count() == 82, "82 cadenas cargadas tras el merge (81 principal + 1 ejemplos): %d" % _h.cadenas_count())
	_check(_h.get_section_name() == "secondary_stories", "sección 'secondary_stories'")
	_check(not _h.get_cadena("cadena-faro").is_empty(), "cadena-faro accesible")
	# Conflicto cadena-faro: gana la variante del principal (no se sobrescribe)
	var faro: Dictionary = _h.get_cadena("cadena-faro")
	_check(String(faro.get("contexto", "")).contains("quiere encender el faro"), "conflicto resuelto a favor del principal (contexto de producción)")
	_check(not String(faro.get("contexto", "")).contains("barcos perdidos"), "la variante de ejemplos NO sobrescribe al principal")
	_check(_h.fuente_cadena("cadena-faro") == "secundarias", "fuente de cadena-faro = principal")
	# Mergeada y rechazada
	_check(_h.fuente_cadena("cadena-biblioteca") == "ejemplos", "fuente de cadena-biblioteca = ejemplos")
	_check(not _h.get_cadena("cadena-biblioteca").is_empty(), "cadena-biblioteca accesible tras el merge")
	_check(_h.get_cadena("cadena-postgame-plaza").is_empty(), "cadena-postgame-plaza rechazada (tipo 'construir' desconocido), no cargada")
	_fin("A")


func _test_validador() -> void:
	# §regla dura: el catálogo base debe pasar el validador completo
	var errores: Array = _h.validar_cadenas()
	_check(errores.is_empty(), "catálogo base sin errores de validador (%s)" % str(errores))
	_fin("B")


func _test_cadena_completa() -> void:
	# Iniciar → 4 pasos en orden → completada + consecuencia + señales
	var iniciadas: Array = []
	var cb_s := func(qid: String) -> void:
		iniciadas.append(qid)
	_bus.quest.quest_started.connect(cb_s)
	var res: Dictionary = _h.iniciar_cadena("cadena-faro")
	_check(bool(res.ok), "iniciar cadena-faro OK")
	_check(iniciadas.has("cadena-faro"), "señal quest_started emitida")
	_bus.quest.quest_started.disconnect(cb_s)
	# Paso 1: hablar con farero
	res = _h.reportar_paso("cadena-faro", "hablar", "farero")
	_check(bool(res.ok), "paso 1 hablar farero OK")
	# Paso incorrecto (tipo equivocado)
	res = _h.reportar_paso("cadena-faro", "hablar", "faro")
	_check(not bool(res.ok) and String(res.motivo).contains("tipo"), "paso 2 con tipo incorrecto rechazado")
	# Paso 2: explorar faro
	res = _h.reportar_paso("cadena-faro", "explorar", "faro")
	_check(bool(res.ok), "paso 2 explorar faro OK")
	# Paso 3: puzzle faro-linterna
	res = _h.reportar_paso("cadena-faro", "puzzle", "faro-linterna")
	_check(bool(res.ok), "paso 3 puzzle OK")
	# Paso 4: entrega — el test obtiene el farol (puzzle del paso 3 lo daría)
	var inv0 := root.get_node_or_null("Inventario")
	if inv0 != null:
		inv0.agregar_items({"farol_cargado": 1})
	# Evidencia incorrecta en paso 4
	res = _h.reportar_entrega("cadena-faro")
	_check(bool(res.ok), "paso 4 entrega farol_cargado OK (inventario)")
	# Completada + consecuencia aplicada
	_check(_h.esta_completada("cadena-faro"), "cadena-faro completada")
	var ws := root.get_node_or_null("WorldState")
	_check(ws != null and ws.has_flag("faro_encendido"), "consecuencia faro_encendido aplicada (M21)")
	# M55 registró la recompensa de diario
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(diary.esta_registrada("mision_cadena-faro"), "M55 registró 'mision_cadena-faro' (M23→M55)")
	_fin("C")


func _test_entrega_inventario() -> void:
	var inv := root.get_node_or_null("Inventario")
	_check(inv != null, "Inventario presente")
	if inv == null:
		return
	# Sin semilla: entrega rechazada
	inv.remover_items({"semilla_antigua": inv.count_item("semilla_antigua")})
	_h.iniciar_cadena("cadena-invernadero")
	_h.reportar_paso("cadena-invernadero", "hablar", "mateo_mapache")
	_h.reportar_paso("cadena-invernadero", "explorar", "invernadero")
	var res: Dictionary = _h.reportar_entrega("cadena-invernadero")
	_check(not bool(res.ok), "entrega sin semilla rechazada")
	_check(String(res.motivo).contains("no disponible"), "motivo objeto no disponible")
	# Con semilla: avanza
	inv.agregar_items({"semilla_antigua": 1})
	res = _h.reportar_entrega("cadena-invernadero")
	_check(bool(res.ok), "entrega con semilla OK")
	_check(_h.esta_completada("cadena-invernadero"), "cadena-invernadero completada")
	_check(ws_has("invernadero_abierto"), "consecuencia invernadero aplicada")
	_fin("D")


func ws_has(flag: String) -> bool:
	var ws := root.get_node_or_null("WorldState")
	return ws != null and ws.has_flag(flag)


func _test_ocultas() -> void:
	# §ocultas: no figura en disponibles hasta iniciarse
	var disponibles: Array = _h.cadenas_disponibles()
	var tiene := false
	for cid in disponibles:
		if cid == "cadena-secretta-luciernagas":
			tiene = true
	_check(not tiene, "cadena oculta NO en disponibles antes de iniciar")
	_h.iniciar_cadena("cadena-secretta-luciernagas")
	disponibles = _h.cadenas_disponibles()
	tiene = false
	for cid in disponibles:
		if cid == "cadena-secretta-luciernagas":
			tiene = true
	_check(tiene, "cadena oculta visible una vez iniciada")
	_fin("E")


func _test_postgame() -> void:
	# §postgame: exige final de M22. Iter. 2: los 4 finales del grafo
	# (principal/regresar/guardian/secreto), uno por iteración, con estado limpio.
	var h := root.get_node_or_null("Historia")
	var ws := root.get_node_or_null("WorldState")
	for final_id in FINALES_M22:
		# Estado limpio: sin final elegido y sin cadenas iniciadas
		if h != null:
			h.restore_save_data({"completados": [], "sellos": [], "final_elegido": ""})
		if ws != null:
			ws.set_flag("templo_brisa_abierto", false)
			ws.set_flag("pistas_secreto_completas", false)
		_h.restore_save_data({})
		var res: Dictionary = _h.iniciar_cadena("cadena-epilogo-plaza")
		_check(not bool(res.ok) and String(res.motivo).contains("postgame"),
			"postgame bloqueada sin final (previo a '%s')" % final_id)
		# Completar el grafo de M22 hasta el final elegido
		if h != null:
			for s in SELLOS_C4:
				h.marcar_sello(s)
			ws.set_flag("templo_brisa_abierto", true)
			for paso in ["prologo", "c1", "c2", "c3", "c4", "c5", "c6", "c7"]:
				h.completar_nodo(paso)
			if final_id == "secreto":
				ws.set_flag("pistas_secreto_completas", true)
			h.completar_nodo("final_" + final_id)
		_check(h != null and h.final_elegido() == final_id,
			"final_elegido = '%s' tras completar el nodo" % final_id)
		res = _h.iniciar_cadena("cadena-epilogo-plaza")
		_check(bool(res.ok), "cadena postgame abre tras final '%s' de M22" % final_id)
	_fin("F")


func _test_persistencia() -> void:
	# Snapshot del estado actual (los bloques previos pueden haber dejado cualquier
	# combinación de activas/completadas: el round-trip se verifica sobre el snapshot,
	# no sobre un id fijo, para no depender del orden de los bloques).
	var data: Dictionary = _h.get_save_data()
	_check(data.has("activas") and data.has("completadas"), "save_data completo")
	var completadas_esperadas: Array = data.get("completadas", [])
	# Round-trip
	_h.restore_save_data({})
	_check(_h.cadenas_disponibles().size() > 0, "restore vacío restaura disponibilidad")
	_h.restore_save_data(data)
	var todas_restauradas := true
	for cid in completadas_esperadas:
		if not _h.esta_completada(String(cid)):
			todas_restauradas = false
	_check(todas_restauradas, "round-trip restaura las %d completadas del snapshot" % completadas_esperadas.size())
	# Huérfana
	var con_huerfana: Dictionary = data.duplicate(true)
	(con_huerfana.completadas as Array).append("cadena_vieja")
	_h.restore_save_data(con_huerfana)
	_check(not _h.esta_completada("cadena_vieja"), "huérfana purgada")
	_fin("G")


func _test_merge_ejemplos() -> void:
	# Iter. 3 (Log 2083): el reporte del merge afirma qué se añadió, qué
	# colisionó y qué se rechazó — y la cadena añadida corre end-to-end.
	var rep: Dictionary = _h.merge_ejemplos_reporte()
	_check(rep.has("anadidas") and rep.has("conflictos") and rep.has("rechazadas"),
		"reporte de merge con las 3 listas")
	var anadidas: Array = rep.get("anadidas", [])
	var conflictos: Array = rep.get("conflictos", [])
	var rechazadas: Array = rep.get("rechazadas", [])
	_check(anadidas.size() == 1 and String(anadidas[0]) == "cadena-biblioteca",
		"merge añade solo cadena-biblioteca (%s)" % str(anadidas))
	_check(conflictos.size() == 1 and String(conflictos[0]) == "cadena-faro",
		"conflicto único resuelto a favor del principal: cadena-faro (%s)" % str(conflictos))
	_check(rechazadas.size() == 1, "1 cadena rechazada por esquema inválido: %d" % rechazadas.size())
	var rech := {}
	for r in rechazadas:
		if String((r as Dictionary).get("id", "")) == "cadena-postgame-plaza":
			rech = r
	_check(not rech.is_empty(), "cadena-postgame-plaza figura en rechazadas")
	var errs: Array = rech.get("errores", [])
	var menciona := false
	for e in errs:
		if String(e).contains("construir"):
			menciona = true
	_check(menciona, "rechazo nombra el tipo desconocido 'construir' (%s)" % str(errs))
	# La cadena añadida corre end-to-end en el motor (no solo "existe en el diccionario")
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"tomo_antiguo": 1})
	var res: Dictionary = _h.iniciar_cadena("cadena-biblioteca")
	_check(bool(res.ok), "iniciar cadena-biblioteca (mergeada) OK")
	res = _h.reportar_paso("cadena-biblioteca", "hablar", "bibliotecaria")
	_check(bool(res.ok), "paso 1 hablar bibliotecaria OK")
	res = _h.reportar_paso("cadena-biblioteca", "explorar", "biblioteca")
	_check(bool(res.ok), "paso 2 explorar biblioteca OK")
	res = _h.reportar_entrega("cadena-biblioteca")
	_check(bool(res.ok), "paso 3 entregar tomo_antiguo OK (inventario)")
	_check(_h.esta_completada("cadena-biblioteca"), "cadena-biblioteca completada end-to-end")
	# Consecuencia: clave PELADA tras la normalización (iter. 4, Log 2085). Antes
	# se aplicaba la clave literal 'estado_mundo.biblioteca_iluminada', que nadie
	# leía en producción (WorldState usa flags pelados: faro_encendido, etc.).
	_check(ws_has("biblioteca_iluminada"), "consecuencia biblioteca_iluminada aplicada con clave pelada (esquema canónico)")
	_check(not ws_has("estado_mundo.biblioteca_iluminada"), "NO se aplica la clave con prefijo estado_mundo.*")
	# Recompensa de diario: el puente M23→M55 exige la entrada en el catálogo
	# de M55 (diary_service.registrar valida contra _catalogo). MEDIDO (Log 2083):
	# el catálogo tiene mision_cadena-faro y mision_cadena-invernadero, NO
	# mision_cadena-biblioteca -> el puente degrada en silencio (retorna false).
	# Finding reportado al director: la entrada es contenido de M55 (dueño).
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-biblioteca"),
			"puente diario degrada sin entrada en catálogo M55 (finding medido, no se inventa contenido)")
	_fin("H")


func _test_esquema_consistente() -> void:
	# Iter. 4 (Log 2085): normalización estado_mundo.* -> flags pelados (GO del
	# director, msg 153; data-only en cadenas_ejemplo.json). El bloque afirma que
	# AMBAS cargas —principal y ejemplos, crudas y mergeadas— quedan en el mismo
	# esquema: consecuencia = clave pelada que se aplica literal a WorldState.
	var ejemplos := _leer_json("res://data/historias/cadenas_ejemplo.json")
	var principal := _leer_json("res://data/historias/secundarias.json")
	_check(ejemplos.size() == 3, "catálogo de ejemplos con 3 cadenas (crudo): %d" % ejemplos.size())
	_check(principal.size() == 81, "catálogo principal con 81 cadenas (crudo, 4 + 6 vecinos + 3 lugares + 4 ruinas + 6 objetos + 3 familias + 6 amistad + 5 secretas + 3 comerciantes + 5 investigacion + 6 puzzles + 8 exploracion + 3 construccion + 5 agricultura + 4 pesca + 6 coleccion + 3 postgame + 1 taller): %d" % principal.size())
	# 1) Ejemplos: 0 claves con prefijo (condicion Y consecuencia)
	var prefijos_ej := _prefijos_estado_mundo(ejemplos)
	_check(prefijos_ej.is_empty(), "ejemplos sin claves estado_mundo.* tras normalizar (%s)" % str(prefijos_ej))
	# 2) Principal: 0 claves de CONSECUENCIA con prefijo (esquema funcional pelado).
	#    La condicion con prefijo del principal queda fuera del GO (ver cabecera).
	var prefijos_princ := _prefijos_estado_mundo(principal, true)
	_check(prefijos_princ.is_empty(), "principal sin claves de consecuencia estado_mundo.* (%s)" % str(prefijos_princ))
	# 3) Carga mergeada en runtime: las cadenas cargadas no exponen el prefijo
	#    (ids únicos: cadena-faro está en AMBOS catálogos y gana el principal)
	var ids := {}
	for c in ejemplos + principal:
		ids[String((c as Dictionary).get("id", ""))] = true
	var cargadas := 0
	var prefijos_rt: Array = []
	for cid in ids:
		var cad: Dictionary = _h.get_cadena(cid)
		if cad.is_empty():
			continue
		cargadas += 1
		for flag in (cad.get("consecuencia", {}) as Dictionary):
			if String(flag).begins_with("estado_mundo."):
				prefijos_rt.append("%s/%s" % [cid, String(flag)])
	_check(cargadas == 82, "82 cadenas cargadas en runtime (81 principal + biblioteca): %d" % cargadas)
	_check(prefijos_rt.is_empty(), "carga mergeada sin claves estado_mundo.* (%s)" % str(prefijos_rt))
	# 4) Mismo flag, mismo deletreo en AMBOS catálogos donde los dos lo definen
	_check(_tiene_consecuencia(principal, "cadena-faro", "faro_encendido"),
		"principal: cadena-faro -> faro_encendido (pelado)")
	_check(_tiene_consecuencia(ejemplos, "cadena-faro", "faro_encendido"),
		"ejemplos: cadena-faro -> faro_encendido (pelado, mismo deletreo)")
	_check(_tiene_consecuencia(principal, "cadena-epilogo-plaza", "plaza_decorada"),
		"principal: cadena-epilogo-plaza -> plaza_decorada (pelado)")
	_check(_tiene_consecuencia(ejemplos, "cadena-postgame-plaza", "plaza_decorada"),
		"ejemplos: cadena-postgame-plaza -> plaza_decorada (pelado, mismo deletreo)")
	_fin("I")


func _leer_json(ruta: String) -> Array:
	if not FileAccess.file_exists(ruta):
		return []
	var p: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(p) != TYPE_DICTIONARY:
		return []
	var lista: Variant = (p as Dictionary).get("cadenas", [])
	return lista if typeof(lista) == TYPE_ARRAY else []


## Claves con prefijo 'estado_mundo.' en un catálogo crudo. Con
## solo_consecuencia=true mira únicamente las claves de consecuencia (las que se
## aplican a WorldState); si no, también las 'condicion' declarativas de los pasos.
func _prefijos_estado_mundo(cadenas: Array, solo_consecuencia: bool = false) -> Array:
	var encontrados: Array = []
	for c in cadenas:
		var cid := String((c as Dictionary).get("id", ""))
		for flag in ((c as Dictionary).get("consecuencia", {}) as Dictionary):
			if String(flag).begins_with("estado_mundo."):
				encontrados.append("%s/consecuencia/%s" % [cid, String(flag)])
		if solo_consecuencia:
			continue
		for p in ((c as Dictionary).get("pasos", []) as Array):
			var cond := String((p as Dictionary).get("condicion", ""))
			if cond.begins_with("estado_mundo."):
				encontrados.append("%s/%s/condicion/%s" % [cid, String((p as Dictionary).get("id", "")), cond])
	return encontrados


func _tiene_consecuencia(cadenas: Array, cid: String, flag: String) -> bool:
	for c in cadenas:
		if String((c as Dictionary).get("id", "")) == cid:
			return ((c as Dictionary).get("consecuencia", {}) as Dictionary).has(flag)
	return false


## Iter. 5 (Log 2107): las 6 historias de vecinos del 03-Diseno L31 que faltaban
## (panadera, carpintero, tejedora, pescador, guarda, alquimista). Afirma carga,
## fuente del principal, unicidad anti-repetición de las consecuencias y corrida
## end-to-end de DOS: cadena-carpintero (entrega con madera_roble, item REAL de
## data/items/) y cadena-alquimista (entrega con jarabe_lunar, objeto narrativo
## como farol_cargado/semilla_antigua del patrón de producción).
func _test_vecinos() -> void:
	# Estado limpio: el bloque no depende de lo que dejaron los anteriores
	_h.restore_save_data({})
	var nuevas := ["cadena-panadera", "cadena-carpintero", "cadena-tejedora",
		"cadena-pescador", "cadena-guarda", "cadena-alquimista"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
	# Anti-repetición: los 6 flags de consecuencia son únicos entre sí y no
	# colisionan con los de las cadenas previas (medidos en disco).
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 6, "6 consecuencias distintas en las cadenas nuevas: %d" % flags.size())
	_check(unicos, "consecuencias nuevas sin colisión con las previas (%s)" % str(flags.keys()))
	# End-to-end 1: carpintero (madera_roble real de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"madera_roble": 1})
	var res: Dictionary = _h.iniciar_cadena("cadena-carpintero")
	_check(bool(res.ok), "iniciar cadena-carpintero OK")
	res = _h.reportar_paso("cadena-carpintero", "hablar", "bruno_sapo")
	_check(bool(res.ok), "carpintero p1 hablar bruno_sapo OK")
	res = _h.reportar_paso("cadena-carpintero", "explorar", "bosque")
	_check(bool(res.ok), "carpintero p2 explorar bosque OK")
	res = _h.reportar_entrega("cadena-carpintero")
	_check(bool(res.ok), "carpintero p3 entregar madera_roble OK (inventario)")
	res = _h.reportar_paso("cadena-carpintero", "puzzle", "ensamblado-banco")
	_check(bool(res.ok), "carpintero p4 puzzle OK")
	_check(_h.esta_completada("cadena-carpintero"), "cadena-carpintero completada end-to-end")
	_check(ws_has("banco_plaza_reparado"), "consecuencia banco_plaza_reparado aplicada (M21)")
	# End-to-end 2: alquimista (jarabe_lunar narrativo, sembrado como el patrón)
	if inv != null:
		inv.agregar_items({"jarabe_lunar": 1})
	res = _h.iniciar_cadena("cadena-alquimista")
	_check(bool(res.ok), "iniciar cadena-alquimista OK")
	res = _h.reportar_paso("cadena-alquimista", "hablar", "teo_conejo")
	_check(bool(res.ok), "alquimista p1 hablar teo_conejo OK")
	res = _h.reportar_paso("cadena-alquimista", "explorar", "manantial")
	_check(bool(res.ok), "alquimista p2 explorar manantial OK")
	res = _h.reportar_paso("cadena-alquimista", "puzzle", "destilacion-lunar")
	_check(bool(res.ok), "alquimista p3 puzzle OK")
	res = _h.reportar_entrega("cadena-alquimista")
	_check(bool(res.ok), "alquimista p4 entregar jarabe_lunar OK (inventario)")
	_check(_h.esta_completada("cadena-alquimista"), "cadena-alquimista completada end-to-end")
	_check(ws_has("jarabe_lunar_listo"), "consecuencia jarabe_lunar_listo aplicada (M21)")
	_fin("J")


## Iter. 6 (Log 2117): cluster Lugares del 03-Diseno — biblioteca ya cubierta
## (iter. 3) y faro por cadena-faro (4 previas). Las 3 cadenas nuevas usan NPC
## REALES de data/villagers/ (mateo_mapache granjero, mercedes_lince mercader,
## aria_ciervo trovadora) y objetos REALES de data/items/ (baya_roja,
## fragmento_ancestral, fibra_algodon). Afirma carga, fuente del principal,
## unicidad anti-repeticion de consecuencias y diarios, y corrida end-to-end
## de las 3. molino_funcionando era flag huerfano (0 archivos, Log 2082).
func _test_lugares() -> void:
	# Estado limpio: el bloque no depende de lo que dejaron los anteriores
	_h.restore_save_data({})
	var nuevas := ["cadena-jardines", "cadena-cofradia", "cadena-molino"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
	# Anti-repeticion: 3 flags de consecuencia nuevos, sin colision con los 11 previos
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 3, "3 consecuencias distintas en las cadenas de lugares: %d" % flags.size())
	_check(unicos, "consecuencias de lugares sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 3, "3 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: jardines (baya_roja REAL de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"baya_roja": 1})
	var res: Dictionary = _h.iniciar_cadena("cadena-jardines")
	_check(bool(res.ok), "iniciar cadena-jardines OK")
	res = _h.reportar_paso("cadena-jardines", "hablar", "mateo_mapache")
	_check(bool(res.ok), "jardines p1 hablar mateo_mapache OK")
	res = _h.reportar_paso("cadena-jardines", "explorar", "jardines")
	_check(bool(res.ok), "jardines p2 explorar jardines OK")
	res = _h.reportar_entrega("cadena-jardines")
	_check(bool(res.ok), "jardines p3 entregar baya_roja OK (inventario)")
	res = _h.reportar_paso("cadena-jardines", "puzzle", "semillas-perdidas")
	_check(bool(res.ok), "jardines p4 puzzle OK")
	_check(_h.esta_completada("cadena-jardines"), "cadena-jardines completada end-to-end")
	_check(ws_has("jardin_florecido"), "consecuencia jardin_florecido aplicada (M21)")
	# End-to-end 2: cofradia (fragmento_ancestral REAL de data/items/)
	if inv != null:
		inv.agregar_items({"fragmento_ancestral": 1})
	res = _h.iniciar_cadena("cadena-cofradia")
	_check(bool(res.ok), "iniciar cadena-cofradia OK")
	res = _h.reportar_paso("cadena-cofradia", "hablar", "mercedes_lince")
	_check(bool(res.ok), "cofradia p1 hablar mercedes_lince OK")
	res = _h.reportar_paso("cadena-cofradia", "explorar", "cofradia")
	_check(bool(res.ok), "cofradia p2 explorar cofradia OK")
	res = _h.reportar_entrega("cadena-cofradia")
	_check(bool(res.ok), "cofradia p3 entregar fragmento_ancestral OK (inventario)")
	res = _h.reportar_paso("cadena-cofradia", "puzzle", "sellos-antiguos")
	_check(bool(res.ok), "cofradia p4 puzzle OK")
	_check(_h.esta_completada("cadena-cofradia"), "cadena-cofradia completada end-to-end")
	_check(ws_has("cofradia_activa"), "consecuencia cofradia_activa aplicada (M21)")
	# End-to-end 3: molino (fibra_algodon REAL). Ademas respalda el flag
	# molino_funcionando, huerfano desde el relevamiento del Log 2082.
	if inv != null:
		inv.agregar_items({"fibra_algodon": 1})
	res = _h.iniciar_cadena("cadena-molino")
	_check(bool(res.ok), "iniciar cadena-molino OK")
	res = _h.reportar_paso("cadena-molino", "hablar", "aria_ciervo")
	_check(bool(res.ok), "molino p1 hablar aria_ciervo OK")
	res = _h.reportar_paso("cadena-molino", "explorar", "molino")
	_check(bool(res.ok), "molino p2 explorar molino OK")
	res = _h.reportar_entrega("cadena-molino")
	_check(bool(res.ok), "molino p3 entregar fibra_algodon OK (inventario)")
	res = _h.reportar_paso("cadena-molino", "puzzle", "melodia-del-molino")
	_check(bool(res.ok), "molino p4 puzzle OK")
	_check(_h.esta_completada("cadena-molino"), "cadena-molino completada end-to-end")
	_check(ws_has("molino_funcionando"), "consecuencia molino_funcionando aplicada (M21) - flag huerfano respaldado")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en el bloque H). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-jardines"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("K")


## Iter. 7 (Log 2125): cluster Ruinas del 03-Diseno L33 (biblioteca quemada,
## observatorio, estacion, puente). NPC REALES de data/villagers/ (sofia_buho
## bibliotecaria, vera_ardilla farera, ramon_tejon herrero, luna_zorra artesana)
## y objetos REALES de data/items/ (ancient_crystal, iron_ore, piedra_caliza);
## tomo_carbonizado es narrativo (0 items de libro en data/items/). Afirma carga,
## fuente del principal, unicidad anti-repeticion de consecuencias y diarios, y
## corrida end-to-end de las 4.
func _test_ruinas() -> void:
	# Estado limpio: el bloque no depende de lo que dejaron los anteriores
	_h.restore_save_data({})
	var nuevas := ["cadena-biblioteca-quemada", "cadena-observatorio",
		"cadena-estacion", "cadena-puente"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
	# Anti-repeticion: 4 flags de consecuencia nuevos, sin colision con los 14 previos
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo", "jardin_florecido",
		"cofradia_activa", "molino_funcionando"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 4, "4 consecuencias distintas en las cadenas de ruinas: %d" % flags.size())
	_check(unicos, "consecuencias de ruinas sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 4, "4 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: biblioteca quemada (sofia_buho REAL; tomo_carbonizado narrativo)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"tomo_carbonizado": 1})
	var res: Dictionary = _h.iniciar_cadena("cadena-biblioteca-quemada")
	_check(bool(res.ok), "iniciar cadena-biblioteca-quemada OK")
	res = _h.reportar_paso("cadena-biblioteca-quemada", "hablar", "sofia_buho")
	_check(bool(res.ok), "biblioteca quemada p1 hablar sofia_buho OK")
	res = _h.reportar_paso("cadena-biblioteca-quemada", "explorar", "biblioteca_quemada")
	_check(bool(res.ok), "biblioteca quemada p2 explorar biblioteca_quemada OK")
	res = _h.reportar_entrega("cadena-biblioteca-quemada")
	_check(bool(res.ok), "biblioteca quemada p3 entregar tomo_carbonizado OK (inventario)")
	res = _h.reportar_paso("cadena-biblioteca-quemada", "puzzle", "cenizas-legibles")
	_check(bool(res.ok), "biblioteca quemada p4 puzzle OK")
	_check(_h.esta_completada("cadena-biblioteca-quemada"), "cadena-biblioteca-quemada completada end-to-end")
	_check(ws_has("biblioteca_quemada_rescatada"), "consecuencia biblioteca_quemada_rescatada aplicada (M21)")
	# End-to-end 2: observatorio (ancient_crystal REAL de data/items/)
	if inv != null:
		inv.agregar_items({"ancient_crystal": 1})
	res = _h.iniciar_cadena("cadena-observatorio")
	_check(bool(res.ok), "iniciar cadena-observatorio OK")
	res = _h.reportar_paso("cadena-observatorio", "hablar", "vera_ardilla")
	_check(bool(res.ok), "observatorio p1 hablar vera_ardilla OK")
	res = _h.reportar_paso("cadena-observatorio", "explorar", "observatorio")
	_check(bool(res.ok), "observatorio p2 explorar observatorio OK")
	res = _h.reportar_entrega("cadena-observatorio")
	_check(bool(res.ok), "observatorio p3 entregar ancient_crystal OK (inventario)")
	res = _h.reportar_paso("cadena-observatorio", "puzzle", "alineacion-estelar")
	_check(bool(res.ok), "observatorio p4 puzzle OK")
	_check(_h.esta_completada("cadena-observatorio"), "cadena-observatorio completada end-to-end")
	_check(ws_has("observatorio_alineado"), "consecuencia observatorio_alineado aplicada (M21)")
	# End-to-end 3: estacion (iron_ore REAL de data/items/)
	if inv != null:
		inv.agregar_items({"iron_ore": 1})
	res = _h.iniciar_cadena("cadena-estacion")
	_check(bool(res.ok), "iniciar cadena-estacion OK")
	res = _h.reportar_paso("cadena-estacion", "hablar", "ramon_tejon")
	_check(bool(res.ok), "estacion p1 hablar ramon_tejon OK")
	res = _h.reportar_paso("cadena-estacion", "explorar", "estacion")
	_check(bool(res.ok), "estacion p2 explorar estacion OK")
	res = _h.reportar_entrega("cadena-estacion")
	_check(bool(res.ok), "estacion p3 entregar iron_ore OK (inventario)")
	res = _h.reportar_paso("cadena-estacion", "puzzle", "engranajes-oxidados")
	_check(bool(res.ok), "estacion p4 puzzle OK")
	_check(_h.esta_completada("cadena-estacion"), "cadena-estacion completada end-to-end")
	_check(ws_has("estacion_reparada"), "consecuencia estacion_reparada aplicada (M21)")
	# End-to-end 4: puente (piedra_caliza REAL de data/items/)
	if inv != null:
		inv.agregar_items({"piedra_caliza": 1})
	res = _h.iniciar_cadena("cadena-puente")
	_check(bool(res.ok), "iniciar cadena-puente OK")
	res = _h.reportar_paso("cadena-puente", "hablar", "luna_zorra")
	_check(bool(res.ok), "puente p1 hablar luna_zorra OK")
	res = _h.reportar_paso("cadena-puente", "explorar", "puente")
	_check(bool(res.ok), "puente p2 explorar puente OK")
	res = _h.reportar_entrega("cadena-puente")
	_check(bool(res.ok), "puente p3 entregar piedra_caliza OK (inventario)")
	res = _h.reportar_paso("cadena-puente", "puzzle", "arco-de-piedra")
	_check(bool(res.ok), "puente p4 puzzle OK")
	_check(_h.esta_completada("cadena-puente"), "cadena-puente completada end-to-end")
	_check(ws_has("puente_cruzable"), "consecuencia puente_cruzable aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en H y cadena-jardines en K). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-puente"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("L")


## Iter. 8: cluster Objetos del 03-Diseno L34 (relicto, gema, carta, llave,
## farol, brujula). NPC REALES de data/villagers/ (teo_conejo herbolario,
## pablo_pato ceramista, catalina_oso cocinera, bruno_sapo carpintero,
## nico_gato guardabosques, finneas_zorro pescador) y objetos REALES de
## data/items/ (gemstone, OBJ-SEC-001 "Llave oculta", OBJ-LUZ-005 "Farol",
## OBJ-SEC-004 "Reliquia oculta"); carta_sellada y brujula_desorientada son
## narrativos (0 items de carta/brujula en data/items/). Afirma carga,
## fuente del principal, unicidad anti-repeticion de consecuencias y diarios,
## y corrida end-to-end de las 6.
func _test_objetos() -> void:
	# Estado limpio: el bloque no depende de lo que dejaron los anteriores
	_h.restore_save_data({})
	var nuevas := ["cadena-relicto", "cadena-gema", "cadena-carta",
		"cadena-llave", "cadena-farol", "cadena-brujula"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
	# Anti-repeticion: 6 flags de consecuencia nuevos, sin colision con los 18 previos
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo", "jardin_florecido",
		"cofradia_activa", "molino_funcionando", "biblioteca_quemada_rescatada",
		"observatorio_alineado", "estacion_reparada", "puente_cruzable"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 6, "6 consecuencias distintas en las cadenas de objetos: %d" % flags.size())
	_check(unicos, "consecuencias de objetos sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 6, "6 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: relicto (teo_conejo REAL; OBJ-SEC-004 "Reliquia oculta" REAL de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-SEC-004": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-relicto")
	_check(bool(res1.ok), "iniciar cadena-relicto OK")
	res1 = _h.reportar_paso("cadena-relicto", "hablar", "teo_conejo")
	_check(bool(res1.ok), "relicto p1 hablar teo_conejo OK")
	res1 = _h.reportar_paso("cadena-relicto", "explorar", "guardarropa")
	_check(bool(res1.ok), "relicto p2 explorar guardarropa OK")
	res1 = _h.reportar_entrega("cadena-relicto")
	_check(bool(res1.ok), "relicto p3 entregar OBJ-SEC-004 OK (inventario)")
	res1 = _h.reportar_paso("cadena-relicto", "puzzle", "sellos-del-relicto")
	_check(bool(res1.ok), "relicto p4 puzzle OK")
	_check(_h.esta_completada("cadena-relicto"), "cadena-relicto completada end-to-end")
	_check(ws_has("relicto_devuelto"), "consecuencia relicto_devuelto aplicada (M21)")
	# End-to-end 2: gema (pablo_pato REAL; gemstone REAL de data/items/)
	if inv != null:
		inv.agregar_items({"gemstone": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-gema")
	_check(bool(res2.ok), "iniciar cadena-gema OK")
	res2 = _h.reportar_paso("cadena-gema", "hablar", "pablo_pato")
	_check(bool(res2.ok), "gema p1 hablar pablo_pato OK")
	res2 = _h.reportar_paso("cadena-gema", "explorar", "barrizal")
	_check(bool(res2.ok), "gema p2 explorar barrizal OK")
	res2 = _h.reportar_entrega("cadena-gema")
	_check(bool(res2.ok), "gema p3 entregar gemstone OK (inventario)")
	res2 = _h.reportar_paso("cadena-gema", "puzzle", "gema-encastrada")
	_check(bool(res2.ok), "gema p4 puzzle OK")
	_check(_h.esta_completada("cadena-gema"), "cadena-gema completada end-to-end")
	_check(ws_has("gema_devuelta"), "consecuencia gema_devuelta aplicada (M21)")
	# End-to-end 3: carta (catalina_oso REAL; carta_sellada narrativo, 0 items de carta)
	if inv != null:
		inv.agregar_items({"carta_sellada": 1})
	var res3: Dictionary = _h.iniciar_cadena("cadena-carta")
	_check(bool(res3.ok), "iniciar cadena-carta OK")
	res3 = _h.reportar_paso("cadena-carta", "hablar", "catalina_oso")
	_check(bool(res3.ok), "carta p1 hablar catalina_oso OK")
	res3 = _h.reportar_paso("cadena-carta", "explorar", "arca_de_recetas")
	_check(bool(res3.ok), "carta p2 explorar arca_de_recetas OK")
	res3 = _h.reportar_entrega("cadena-carta")
	_check(bool(res3.ok), "carta p3 entregar carta_sellada OK (inventario)")
	res3 = _h.reportar_paso("cadena-carta", "puzzle", "tinta-borrada")
	_check(bool(res3.ok), "carta p4 puzzle OK")
	_check(_h.esta_completada("cadena-carta"), "cadena-carta completada end-to-end")
	_check(ws_has("receta_heredada"), "consecuencia receta_heredada aplicada (M21)")
	# End-to-end 4: llave (bruno_sapo REAL; OBJ-SEC-001 "Llave oculta" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-SEC-001": 1})
	var res4: Dictionary = _h.iniciar_cadena("cadena-llave")
	_check(bool(res4.ok), "iniciar cadena-llave OK")
	res4 = _h.reportar_paso("cadena-llave", "hablar", "bruno_sapo")
	_check(bool(res4.ok), "llave p1 hablar bruno_sapo OK")
	res4 = _h.reportar_paso("cadena-llave", "explorar", "armario_restaurado")
	_check(bool(res4.ok), "llave p2 explorar armario_restaurado OK")
	res4 = _h.reportar_entrega("cadena-llave")
	_check(bool(res4.ok), "llave p3 entregar OBJ-SEC-001 OK (inventario)")
	res4 = _h.reportar_paso("cadena-llave", "puzzle", "cerradura-oxidada")
	_check(bool(res4.ok), "llave p4 puzzle OK")
	_check(_h.esta_completada("cadena-llave"), "cadena-llave completada end-to-end")
	_check(ws_has("llave_encontrada"), "consecuencia llave_encontrada aplicada (M21)")
	# End-to-end 5: farol (nico_gato REAL; OBJ-LUZ-005 "Farol" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-LUZ-005": 1})
	var res5: Dictionary = _h.iniciar_cadena("cadena-farol")
	_check(bool(res5.ok), "iniciar cadena-farol OK")
	res5 = _h.reportar_paso("cadena-farol", "hablar", "nico_gato")
	_check(bool(res5.ok), "farol p1 hablar nico_gato OK")
	res5 = _h.reportar_paso("cadena-farol", "explorar", "bosque_nocturno")
	_check(bool(res5.ok), "farol p2 explorar bosque_nocturno OK")
	res5 = _h.reportar_entrega("cadena-farol")
	_check(bool(res5.ok), "farol p3 entregar OBJ-LUZ-005 OK (inventario)")
	res5 = _h.reportar_paso("cadena-farol", "puzzle", "mecanismo-del-farol")
	_check(bool(res5.ok), "farol p4 puzzle OK")
	_check(_h.esta_completada("cadena-farol"), "cadena-farol completada end-to-end")
	_check(ws_has("patrulla_nocturna"), "consecuencia patrulla_nocturna aplicada (M21)")
	# End-to-end 6: brujula (finneas_zorro REAL; brujula_desorientada narrativo, 0 items de brujula)
	if inv != null:
		inv.agregar_items({"brujula_desorientada": 1})
	var res6: Dictionary = _h.iniciar_cadena("cadena-brujula")
	_check(bool(res6.ok), "iniciar cadena-brujula OK")
	res6 = _h.reportar_paso("cadena-brujula", "hablar", "finneas_zorro")
	_check(bool(res6.ok), "brujula p1 hablar finneas_zorro OK")
	res6 = _h.reportar_paso("cadena-brujula", "explorar", "muelle_viejo")
	_check(bool(res6.ok), "brujula p2 explorar muelle_viejo OK")
	res6 = _h.reportar_entrega("cadena-brujula")
	_check(bool(res6.ok), "brujula p3 entregar brujula_desorientada OK (inventario)")
	res6 = _h.reportar_paso("cadena-brujula", "puzzle", "aguja-imantada")
	_check(bool(res6.ok), "brujula p4 puzzle OK")
	_check(_h.esta_completada("cadena-brujula"), "cadena-brujula completada end-to-end")
	_check(ws_has("brujula_calibrada"), "consecuencia brujula_calibrada aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en H, cadena-jardines en K y cadena-puente en L).
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-brujula"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("M")


## Iter. 9: cluster Familias del 03-Diseno L35 (molinera, pescadores, guardas).
## NPC REALES de data/villagers/ (mateo_mapache granjero, finneas_zorro pescador,
## nico_gato guardabosques) y objetos REALES de data/items/ (OBJ-REL-003 "Reloj
## de arena", OBJ-HER-014 "Red de captura", OBJ-LUZ-011 "Candil", verificados
## por campo id dentro del .tres - item_database.gd indexa por ese id). Afirma
## carga, fuente del principal, unicidad anti-repeticion de consecuencias y
## diarios, y corrida end-to-end de las 3.
func _test_familias() -> void:
	# Estado limpio: el bloque no depende de lo que dejaron los anteriores
	_h.restore_save_data({})
	var nuevas := ["cadena-molinera", "cadena-pescadores", "cadena-guardas"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
	# Anti-repeticion: 3 flags de consecuencia nuevos, sin colision con los 24 previos
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo", "jardin_florecido",
		"cofradia_activa", "molino_funcionando", "biblioteca_quemada_rescatada",
		"observatorio_alineado", "estacion_reparada", "puente_cruzable",
		"relicto_devuelto", "gema_devuelta", "receta_heredada", "llave_encontrada",
		"patrulla_nocturna", "brujula_calibrada"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 3, "3 consecuencias distintas en las cadenas de familias: %d" % flags.size())
	_check(unicos, "consecuencias de familias sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 3, "3 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: molinera (mateo_mapache REAL; OBJ-REL-003 "Reloj de arena" REAL de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-REL-003": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-molinera")
	_check(bool(res1.ok), "iniciar cadena-molinera OK")
	res1 = _h.reportar_paso("cadena-molinera", "hablar", "mateo_mapache")
	_check(bool(res1.ok), "molinera p1 hablar mateo_mapache OK")
	res1 = _h.reportar_paso("cadena-molinera", "explorar", "molino")
	_check(bool(res1.ok), "molinera p2 explorar molino OK")
	res1 = _h.reportar_entrega("cadena-molinera")
	_check(bool(res1.ok), "molinera p3 entregar OBJ-REL-003 OK (inventario)")
	res1 = _h.reportar_paso("cadena-molinera", "puzzle", "piedras-de-molienda")
	_check(bool(res1.ok), "molinera p4 puzzle OK")
	_check(_h.esta_completada("cadena-molinera"), "cadena-molinera completada end-to-end")
	_check(ws_has("molienda_familiar_restaurada"), "consecuencia molienda_familiar_restaurada aplicada (M21)")
	# End-to-end 2: pescadores (finneas_zorro REAL; OBJ-HER-014 "Red de captura" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-HER-014": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-pescadores")
	_check(bool(res2.ok), "iniciar cadena-pescadores OK")
	res2 = _h.reportar_paso("cadena-pescadores", "hablar", "finneas_zorro")
	_check(bool(res2.ok), "pescadores p1 hablar finneas_zorro OK")
	res2 = _h.reportar_paso("cadena-pescadores", "explorar", "muelle_viejo")
	_check(bool(res2.ok), "pescadores p2 explorar muelle_viejo OK")
	res2 = _h.reportar_entrega("cadena-pescadores")
	_check(bool(res2.ok), "pescadores p3 entregar OBJ-HER-014 OK (inventario)")
	res2 = _h.reportar_paso("cadena-pescadores", "puzzle", "nudo-del-abuelo")
	_check(bool(res2.ok), "pescadores p4 puzzle OK")
	_check(_h.esta_completada("cadena-pescadores"), "cadena-pescadores completada end-to-end")
	_check(ws_has("red_del_abuelo_reparada"), "consecuencia red_del_abuelo_reparada aplicada (M21)")
	# End-to-end 3: guardas (nico_gato REAL; OBJ-LUZ-011 "Candil" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-LUZ-011": 1})
	var res3: Dictionary = _h.iniciar_cadena("cadena-guardas")
	_check(bool(res3.ok), "iniciar cadena-guardas OK")
	res3 = _h.reportar_paso("cadena-guardas", "hablar", "nico_gato")
	_check(bool(res3.ok), "guardas p1 hablar nico_gato OK")
	res3 = _h.reportar_paso("cadena-guardas", "explorar", "bosque_nocturno")
	_check(bool(res3.ok), "guardas p2 explorar bosque_nocturno OK")
	res3 = _h.reportar_entrega("cadena-guardas")
	_check(bool(res3.ok), "guardas p3 entregar OBJ-LUZ-011 OK (inventario)")
	res3 = _h.reportar_paso("cadena-guardas", "puzzle", "ronda-de-los-guardas")
	_check(bool(res3.ok), "guardas p4 puzzle OK")
	_check(_h.esta_completada("cadena-guardas"), "cadena-guardas completada end-to-end")
	_check(ws_has("vigilia_de_los_guardas"), "consecuencia vigilia_de_los_guardas aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L y
	# cadena-brujula en M). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-guardas"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("N")

## Iter. 10 (Step-5-WorkBuddy, 2026-10-22, Log 2131): cluster Amistad del 03-Diseno
## L44 (regalo favorito, sentadilla de pesca, paseos, ficcion, ayuda a un vecino,
## cartas de amistad). NPC REALES de data/villagers/ (olivia_nutria, finneas_zorro,
## sofia_buho, aria_ciervo, mercedes_lince, luna_zorra) y objetos REALES de
## data/items/ (OBJ-ROP-005 "Bufanda", OBJ-ITE-036 "Te", OBJ-NAT-022 "Flor rara",
## OBJ-NAT-023 "Flor luminiscente", OBJ-ITE-035 "Miel", OBJ-NAT-004 "Flor
## silvestre"). Afirma carga, fuente, unicidad de consecuencias/diarios y corrida
## end-to-end de las 6.
func _test_amistad() -> void:
	# Estado limpio: el bloque no depende de lo que dejaron los anteriores
	_h.restore_save_data({})
	var nuevas := ["cadena-regalo-favorito", "cadena-sentadilla-pesca", "cadena-paseos",
		"cadena-ficcion", "cadena-ayuda-vecino", "cadena-cartas-amistad"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
	# Anti-repeticion: 6 flags de consecuencia nuevos, sin colision con los 27 previos
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo", "jardin_florecido",
		"cofradia_activa", "molino_funcionando", "biblioteca_quemada_rescatada",
		"observatorio_alineado", "estacion_reparada", "puente_cruzable",
		"relicto_devuelto", "gema_devuelta", "receta_heredada", "llave_encontrada",
		"patrulla_nocturna", "brujula_calibrada", "molienda_familiar_restaurada",
		"red_del_abuelo_reparada", "vigilia_de_los_guardas"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 6, "6 consecuencias distintas en las cadenas de amistad: %d" % flags.size())
	_check(unicos, "consecuencias de amistad sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 6, "6 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: regalo favorito (olivia_nutria REAL; OBJ-ROP-005 "Bufanda" REAL de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-ROP-005": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-regalo-favorito")
	_check(bool(res1.ok), "iniciar cadena-regalo-favorito OK")
	res1 = _h.reportar_paso("cadena-regalo-favorito", "hablar", "olivia_nutria")
	_check(bool(res1.ok), "regalo p1 hablar olivia_nutria OK")
	res1 = _h.reportar_paso("cadena-regalo-favorito", "explorar", "plaza")
	_check(bool(res1.ok), "regalo p2 explorar plaza OK")
	res1 = _h.reportar_entrega("cadena-regalo-favorito")
	_check(bool(res1.ok), "regalo p3 entregar OBJ-ROP-005 OK (inventario)")
	res1 = _h.reportar_paso("cadena-regalo-favorito", "puzzle", "envoltorio-sin-cinta")
	_check(bool(res1.ok), "regalo p4 puzzle OK")
	_check(_h.esta_completada("cadena-regalo-favorito"), "cadena-regalo-favorito completada end-to-end")
	_check(ws_has("regalo_favorito_entregado"), "consecuencia regalo_favorito_entregado aplicada (M21)")
	# End-to-end 2: sentadilla de pesca (finneas_zorro REAL; OBJ-ITE-036 "Te" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-ITE-036": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-sentadilla-pesca")
	_check(bool(res2.ok), "iniciar cadena-sentadilla-pesca OK")
	res2 = _h.reportar_paso("cadena-sentadilla-pesca", "hablar", "finneas_zorro")
	_check(bool(res2.ok), "sentadilla p1 hablar finneas_zorro OK")
	res2 = _h.reportar_paso("cadena-sentadilla-pesca", "explorar", "muelle")
	_check(bool(res2.ok), "sentadilla p2 explorar muelle OK")
	res2 = _h.reportar_entrega("cadena-sentadilla-pesca")
	_check(bool(res2.ok), "sentadilla p3 entregar OBJ-ITE-036 OK (inventario)")
	res2 = _h.reportar_paso("cadena-sentadilla-pesca", "puzzle", "sedal-silencioso")
	_check(bool(res2.ok), "sentadilla p4 puzzle OK")
	_check(_h.esta_completada("cadena-sentadilla-pesca"), "cadena-sentadilla-pesca completada end-to-end")
	_check(ws_has("sentadilla_de_pesca_amistosa"), "consecuencia sentadilla_de_pesca_amistosa aplicada (M21)")
	# End-to-end 3: paseos (sofia_buho REAL; OBJ-NAT-022 "Flor rara" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-NAT-022": 1})
	var res3: Dictionary = _h.iniciar_cadena("cadena-paseos")
	_check(bool(res3.ok), "iniciar cadena-paseos OK")
	res3 = _h.reportar_paso("cadena-paseos", "hablar", "sofia_buho")
	_check(bool(res3.ok), "paseos p1 hablar sofia_buho OK")
	res3 = _h.reportar_paso("cadena-paseos", "explorar", "jardin")
	_check(bool(res3.ok), "paseos p2 explorar jardin OK")
	res3 = _h.reportar_entrega("cadena-paseos")
	_check(bool(res3.ok), "paseos p3 entregar OBJ-NAT-022 OK (inventario)")
	res3 = _h.reportar_paso("cadena-paseos", "puzzle", "rutas-del-atardecer")
	_check(bool(res3.ok), "paseos p4 puzzle OK")
	_check(_h.esta_completada("cadena-paseos"), "cadena-paseos completada end-to-end")
	_check(ws_has("paseo_con_amiga"), "consecuencia paseo_con_amiga aplicada (M21)")
	# End-to-end 4: ficcion (aria_ciervo REAL; OBJ-NAT-023 "Flor luminiscente" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-NAT-023": 1})
	var res4: Dictionary = _h.iniciar_cadena("cadena-ficcion")
	_check(bool(res4.ok), "iniciar cadena-ficcion OK")
	res4 = _h.reportar_paso("cadena-ficcion", "hablar", "aria_ciervo")
	_check(bool(res4.ok), "ficcion p1 hablar aria_ciervo OK")
	res4 = _h.reportar_paso("cadena-ficcion", "explorar", "plaza")
	_check(bool(res4.ok), "ficcion p2 explorar plaza OK")
	res4 = _h.reportar_entrega("cadena-ficcion")
	_check(bool(res4.ok), "ficcion p3 entregar OBJ-NAT-023 OK (inventario)")
	res4 = _h.reportar_paso("cadena-ficcion", "puzzle", "final-inventado")
	_check(bool(res4.ok), "ficcion p4 puzzle OK")
	_check(_h.esta_completada("cadena-ficcion"), "cadena-ficcion completada end-to-end")
	_check(ws_has("historia_de_ficcion_escrita"), "consecuencia historia_de_ficcion_escrita aplicada (M21)")
	# End-to-end 5: ayuda a un vecino (mercedes_lince REAL; OBJ-ITE-035 "Miel" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-ITE-035": 1})
	var res5: Dictionary = _h.iniciar_cadena("cadena-ayuda-vecino")
	_check(bool(res5.ok), "iniciar cadena-ayuda-vecino OK")
	res5 = _h.reportar_paso("cadena-ayuda-vecino", "hablar", "mercedes_lince")
	_check(bool(res5.ok), "ayuda p1 hablar mercedes_lince OK")
	res5 = _h.reportar_paso("cadena-ayuda-vecino", "explorar", "plaza")
	_check(bool(res5.ok), "ayuda p2 explorar plaza OK")
	res5 = _h.reportar_entrega("cadena-ayuda-vecino")
	_check(bool(res5.ok), "ayuda p3 entregar OBJ-ITE-035 OK (inventario)")
	res5 = _h.reportar_paso("cadena-ayuda-vecino", "puzzle", "recuento-de-la-pila")
	_check(bool(res5.ok), "ayuda p4 puzzle OK")
	_check(_h.esta_completada("cadena-ayuda-vecino"), "cadena-ayuda-vecino completada end-to-end")
	_check(ws_has("puesto_de_mercedes_ordenado"), "consecuencia puesto_de_mercedes_ordenado aplicada (M21)")
	# End-to-end 6: cartas de amistad (luna_zorra REAL; OBJ-NAT-004 "Flor silvestre" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-NAT-004": 1})
	var res6: Dictionary = _h.iniciar_cadena("cadena-cartas-amistad")
	_check(bool(res6.ok), "iniciar cadena-cartas-amistad OK")
	res6 = _h.reportar_paso("cadena-cartas-amistad", "hablar", "luna_zorra")
	_check(bool(res6.ok), "cartas p1 hablar luna_zorra OK")
	res6 = _h.reportar_paso("cadena-cartas-amistad", "explorar", "muelle_viejo")
	_check(bool(res6.ok), "cartas p2 explorar muelle_viejo OK")
	res6 = _h.reportar_entrega("cadena-cartas-amistad")
	_check(bool(res6.ok), "cartas p3 entregar OBJ-NAT-004 OK (inventario)")
	res6 = _h.reportar_paso("cadena-cartas-amistad", "puzzle", "sello-de-cera")
	_check(bool(res6.ok), "cartas p4 puzzle OK")
	_check(_h.esta_completada("cadena-cartas-amistad"), "cadena-cartas-amistad completada end-to-end")
	_check(ws_has("correspondencia_retomada"), "consecuencia correspondencia_retomada aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L,
	# cadena-brujula en M y cadena-guardas en N). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-regalo-favorito"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("O")

func _test_secretas() -> void:
	# Iter. 11 (Log 2134): cluster Secretas del 03-Diseno L38 — 5 cadenas ocultas
	# "desbloqueadas por mundo". Misma regla de ocultamiento que
	# cadena-secretta-luciernagas (bloque E): oculta:true -> no figuran en
	# cadenas_disponibles() hasta iniciarse.
	_h.restore_save_data({})
	var nuevas := ["cadena-mapa-secreto", "cadena-cristal-oculto", "cadena-diario-antiguo",
		"cadena-pergamino-mistico", "cadena-mascara-ceremonial"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(bool((_h.get_cadena(cid).get("oculta", false))), "%s es oculta" % cid)
	# Ocultamiento: ninguna figura en disponibles antes de iniciarse
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in nuevas:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 0, "las 5 secretas NO estan en disponibles antes de iniciar (%d expuestas)" % expuestas)
	# Al iniciar una, pasa a ser visible (regla de descubrimiento por mundo)
	_h.iniciar_cadena("cadena-mapa-secreto")
	disponibles = _h.cadenas_disponibles()
	var visible := false
	for d in disponibles:
		if String(d) == "cadena-mapa-secreto":
			visible = true
	_check(visible, "cadena-mapa-secreto visible tras iniciarse")
	# Estado limpio para los end-to-end: la cadena ya quedo iniciada por el check
	# de visibilidad y no se puede iniciar dos veces (misma regla que el resto).
	_h.restore_save_data({})
	# Anti-repeticion: 5 flags de consecuencia nuevos, sin colision con los 33 previos
	# (27 previos a amistad + 6 de amistad)
	var existentes := ["faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo", "jardin_florecido",
		"cofradia_activa", "molino_funcionando", "biblioteca_quemada_rescatada",
		"observatorio_alineado", "estacion_reparada", "puente_cruzable",
		"relicto_devuelto", "gema_devuelta", "receta_heredada", "llave_encontrada",
		"patrulla_nocturna", "brujula_calibrada", "molienda_familiar_restaurada",
		"red_del_abuelo_reparada", "vigilia_de_los_guardas",
		"regalo_favorito_entregado", "sentadilla_de_pesca_amistosa", "paseo_con_amiga",
		"historia_de_ficcion_escrita", "puesto_de_mercedes_ordenado",
		"correspondencia_retomada"]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 5, "5 consecuencias distintas en las cadenas secretas: %d" % flags.size())
	_check(unicos, "consecuencias secretas sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 5, "5 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: mapa secreto (nico_gato REAL; OBJ-SEC-002 "Mapa secreto" REAL de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-SEC-002": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-mapa-secreto")
	_check(bool(res1.ok), "iniciar cadena-mapa-secreto OK")
	res1 = _h.reportar_paso("cadena-mapa-secreto", "hablar", "nico_gato")
	_check(bool(res1.ok), "mapa p1 hablar nico_gato OK")
	res1 = _h.reportar_paso("cadena-mapa-secreto", "explorar", "sendero_secreto")
	_check(bool(res1.ok), "mapa p2 explorar sendero_secreto OK")
	res1 = _h.reportar_entrega("cadena-mapa-secreto")
	_check(bool(res1.ok), "mapa p3 entregar OBJ-SEC-002 OK (inventario)")
	res1 = _h.reportar_paso("cadena-mapa-secreto", "puzzle", "marcas-en-la-corteza")
	_check(bool(res1.ok), "mapa p4 puzzle OK")
	_check(_h.esta_completada("cadena-mapa-secreto"), "cadena-mapa-secreto completada end-to-end")
	_check(ws_has("sendero_secreto_revelado"), "consecuencia sendero_secreto_revelado aplicada (M21)")
	# End-to-end 2: mascara ceremonial (luna_zorra REAL; OBJ-ART-004 "Mascara ceremonial" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-ART-004": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-mascara-ceremonial")
	_check(bool(res2.ok), "iniciar cadena-mascara-ceremonial OK")
	res2 = _h.reportar_paso("cadena-mascara-ceremonial", "hablar", "luna_zorra")
	_check(bool(res2.ok), "mascara p1 hablar luna_zorra OK")
	res2 = _h.reportar_paso("cadena-mascara-ceremonial", "explorar", "bosque_nocturno")
	_check(bool(res2.ok), "mascara p2 explorar bosque_nocturno OK")
	res2 = _h.reportar_entrega("cadena-mascara-ceremonial")
	_check(bool(res2.ok), "mascara p3 entregar OBJ-ART-004 OK (inventario)")
	res2 = _h.reportar_paso("cadena-mascara-ceremonial", "puzzle", "rostro-de-corteza")
	_check(bool(res2.ok), "mascara p4 puzzle OK")
	_check(_h.esta_completada("cadena-mascara-ceremonial"), "cadena-mascara-ceremonial completada end-to-end")
	_check(ws_has("mascara_ceremonial_restaurada"), "consecuencia mascara_ceremonial_restaurada aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L,
	# cadena-brujula en M, cadena-guardas en N y cadena-regalo-favorito en O).
	# No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-mapa-secreto"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("P")

func _test_comerciantes() -> void:
	# Iter. 12 (Log 2135): cluster Comerciantes del 03-Diseno L36 — 3 cadenas de
	# rutas y secretos (integracion M37 excluida por orden del director, msg 181).
	# NPC REALES de data/villagers/ (mercedes_lince mercader, olivia_nutria
	# sastra, ramon_tejon herrero) y objetos REALES de data/items/ por campo id
	# (OBJ-ITE-052 "Moneda de oro", OBJ-ITE-010 "Tela", OBJ-TAL-002 "Yunque").
	# A diferencia de las secretas (bloque P), las 3 nacen visibles: son rutas
	# de trueque que se descubren hablando, no secretos de mundo.
	_h.restore_save_data({})
	var nuevas := ["cadena-ruta-del-mercader", "cadena-cargamento-de-telas",
		"cadena-secreto-del-yunque"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(not bool((_h.get_cadena(cid).get("oculta", false))), "%s NO es oculta (ruta visible)" % cid)
	# Visibles en disponibles desde el inicio (regla opuesta a las secretas)
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in nuevas:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 3, "las 3 comerciantes figuran en disponibles desde el inicio (%d expuestas)" % expuestas)
	# Anti-repeticion: 3 flags de consecuencia nuevos, sin colision con los 38
	# previos (37 del principal + biblioteca_iluminada del merge de ejemplos)
	var existentes := [
		"faro_encendido", "invernadero_abierto", "plaza_decorada",
		"luciernagas_vueltas", "biblioteca_iluminada", "pan_fiesta_horneado",
		"banco_plaza_reparado", "manto_niebla_terminado", "red_pescador_reparada",
		"sendero_bosque_senalado", "jarabe_lunar_listo", "jardin_florecido",
		"cofradia_activa", "molino_funcionando", "biblioteca_quemada_rescatada",
		"observatorio_alineado", "estacion_reparada", "puente_cruzable",
		"relicto_devuelto", "gema_devuelta", "receta_heredada",
		"llave_encontrada", "patrulla_nocturna", "brujula_calibrada",
		"molienda_familiar_restaurada", "red_del_abuelo_reparada", "vigilia_de_los_guardas",
		"regalo_favorito_entregado", "sentadilla_de_pesca_amistosa", "paseo_con_amiga",
		"historia_de_ficcion_escrita", "puesto_de_mercedes_ordenado", "correspondencia_retomada",
		"sendero_secreto_revelado", "cristal_oculto_recuperado", "autor_del_diario_identificado",
		"versos_antiguos_descifrados", "mascara_ceremonial_restaurada"
	]
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag) or existentes.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 3, "3 consecuencias distintas en las cadenas de comerciantes: %d" % flags.size())
	_check(unicos, "consecuencias de comerciantes sin colision con las previas (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 3, "3 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: ruta del mercader (mercedes_lince REAL; OBJ-ITE-052 "Moneda de oro" REAL de data/items/)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-ITE-052": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-ruta-del-mercader")
	_check(bool(res1.ok), "iniciar cadena-ruta-del-mercader OK")
	res1 = _h.reportar_paso("cadena-ruta-del-mercader", "hablar", "mercedes_lince")
	_check(bool(res1.ok), "ruta p1 hablar mercedes_lince OK")
	res1 = _h.reportar_paso("cadena-ruta-del-mercader", "explorar", "ruta_comercial")
	_check(bool(res1.ok), "ruta p2 explorar ruta_comercial OK")
	res1 = _h.reportar_entrega("cadena-ruta-del-mercader")
	_check(bool(res1.ok), "ruta p3 entregar OBJ-ITE-052 OK (inventario)")
	res1 = _h.reportar_paso("cadena-ruta-del-mercader", "puzzle", "paradas-en-orden")
	_check(bool(res1.ok), "ruta p4 puzzle OK")
	_check(_h.esta_completada("cadena-ruta-del-mercader"), "cadena-ruta-del-mercader completada end-to-end")
	_check(ws_has("ruta_comercial_reabierta"), "consecuencia ruta_comercial_reabierta aplicada (M21)")
	# End-to-end 2: cargamento de telas (olivia_nutria REAL; OBJ-ITE-010 "Tela" REAL de data/items/)
	if inv != null:
		inv.agregar_items({"OBJ-ITE-010": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-cargamento-de-telas")
	_check(bool(res2.ok), "iniciar cadena-cargamento-de-telas OK")
	res2 = _h.reportar_paso("cadena-cargamento-de-telas", "hablar", "olivia_nutria")
	_check(bool(res2.ok), "telas p1 hablar olivia_nutria OK")
	res2 = _h.reportar_paso("cadena-cargamento-de-telas", "explorar", "almacen_del_camino")
	_check(bool(res2.ok), "telas p2 explorar almacen_del_camino OK")
	res2 = _h.reportar_entrega("cadena-cargamento-de-telas")
	_check(bool(res2.ok), "telas p3 entregar OBJ-ITE-010 OK (inventario)")
	res2 = _h.reportar_paso("cadena-cargamento-de-telas", "puzzle", "ovillo-enredado")
	_check(bool(res2.ok), "telas p4 puzzle OK")
	_check(_h.esta_completada("cadena-cargamento-de-telas"), "cadena-cargamento-de-telas completada end-to-end")
	_check(ws_has("telas_reunidas"), "consecuencia telas_reunidas aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L,
	# cadena-brujula en M, cadena-guardas en N, cadena-regalo-favorito en O y
	# cadena-mapa-secreto en P). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-ruta-del-mercader"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("Q")


func _test_puzzles_investigacion() -> void:
	# Iter. 13 (Log 2137): clusters Puzzles (6, 03-Diseno L46: templos 24/25/26
	# + ruinas con puzzles ocultos) e Investigacion (5, L45: faro, biblioteca,
	# geodesia, mapas + cartas estelares) consolidados en UN bloque (regla del
	# fundador, msg 183 del director). NPC REALES de data/villagers/
	# (vera_ardilla farera, sofia_buho bibliotecaria, pablo_pato ceramista,
	# teo_conejo herbolario, bruno_sapo carpintero, luna_zorra artesana,
	# catalina_oso cocinera) y objetos REALES de data/items/ por campo id
	# (OBJ-LUZ-012 "Linterna", OBJ-EST-006 "Vitrina", OBJ-REL-002 "Reloj de
	# pendulo", OBJ-HER-015 "Lupa", OBJ-LUZ-008 "Lampara de cristal",
	# OBJ-TAL-004 "Rueda de alfarero", OBJ-HER-018 "Sierra", OBJ-PLA-004
	# "Orquidea", OBJ-ITE-021 "Pan", OBJ-NAT-024 "Seta", OBJ-LUZ-004
	# "Veladora"). A diferencia de las secretas (bloque P), las 11 nacen
	# visibles: se descubren hablando.
	_h.restore_save_data({})
	var investigacion := ["cadena-registro-del-faro", "cadena-catalogo-perdido",
		"cadena-mediciones-de-la-isla", "cadena-mapa-de-las-plantas",
		"cadena-cartas-estelares"]
	var puzzles := ["cadena-templo-de-las-24-marcas", "cadena-templo-de-los-25-engranajes",
		"cadena-templo-de-las-26-mareas", "cadena-ruinas-del-barrizal",
		"cadena-ruinas-del-manantial", "cadena-ruinas-del-acantilado"]
	var nuevas := investigacion + puzzles
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(not bool((_h.get_cadena(cid).get("oculta", false))), "%s NO es oculta (se descubre hablando)" % cid)
	# Visibles en disponibles desde el inicio
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in nuevas:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 11, "las 11 puzzles+investigacion figuran en disponibles desde el inicio (%d expuestas)" % expuestas)
	# Unicidad GLOBAL de consecuencias medida sobre la carga real (63 cadenas ->
	# 63 flags, 1 por cadena): reemplaza la lista transcrita a mano, que podia
	# omitir un flag y dar un falso verde de unicidad.
	var principal := _leer_json("res://data/historias/secundarias.json")
	var ejemplos := _leer_json("res://data/historias/cadenas_ejemplo.json")
	var flags := {}
	var multi := []
	for c in principal + ejemplos:
		var cid := String((c as Dictionary).get("id", ""))
		var cad: Dictionary = _h.get_cadena(cid)
		if cad.is_empty():
			continue
		var cons: Dictionary = cad.get("consecuencia", {})
		if cons.size() != 1:
			multi.append(cid)
		for flag in cons:
			flags[flag] = true
	_check(flags.size() == 82, "82 consecuencias distintas sobre 82 cadenas cargadas (unicidad global): %d" % flags.size())
	_check(multi.is_empty(), "cada cadena aporta exactamente 1 flag de consecuencia (%s)" % str(multi))
	# NPCs REALES: cada npc de las 11 cadenas existe como recurso en data/villagers/
	var npcs := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var npc := String((p as Dictionary).get("npc", ""))
			if npc != "":
				npcs[npc] = true
	for npc in npcs:
		_check(FileAccess.file_exists("res://data/villagers/%s.tres" % npc),
			"NPC REAL %s existe en data/villagers/" % npc)
	# Objetos REALES: cada objeto existe en data/items/ por campo id (efecto,
	# no nombre de archivo)
	var objetos := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var obj := String((p as Dictionary).get("objeto", ""))
			if obj != "":
				objetos[obj] = true
	var ids_items := _ids_items_reales()
	for obj in objetos:
		_check(ids_items.has(obj), "objeto REAL %s existe en data/items/ (por campo id)" % obj)
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 11, "11 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# End-to-end 1: registro del faro (vera_ardilla REAL; OBJ-LUZ-012 "Linterna" REAL)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-LUZ-012": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-registro-del-faro")
	_check(bool(res1.ok), "iniciar cadena-registro-del-faro OK")
	res1 = _h.reportar_paso("cadena-registro-del-faro", "hablar", "vera_ardilla")
	_check(bool(res1.ok), "faro p1 hablar vera_ardilla OK")
	res1 = _h.reportar_paso("cadena-registro-del-faro", "explorar", "faro")
	_check(bool(res1.ok), "faro p2 explorar faro OK")
	res1 = _h.reportar_paso("cadena-registro-del-faro", "puzzle", "alturas-de-la-luz")
	_check(bool(res1.ok), "faro p3 puzzle OK")
	res1 = _h.reportar_entrega("cadena-registro-del-faro")
	_check(bool(res1.ok), "faro p4 entregar OBJ-LUZ-012 OK (inventario)")
	_check(_h.esta_completada("cadena-registro-del-faro"), "cadena-registro-del-faro completada end-to-end")
	_check(ws_has("registro_del_faro_recuperado"), "consecuencia registro_del_faro_recuperado aplicada (M21)")
	# End-to-end 2: templo de las 24 marcas (pablo_pato REAL; OBJ-TAL-004 "Rueda de alfarero" REAL)
	if inv != null:
		inv.agregar_items({"OBJ-TAL-004": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-templo-de-las-24-marcas")
	_check(bool(res2.ok), "iniciar cadena-templo-de-las-24-marcas OK")
	res2 = _h.reportar_paso("cadena-templo-de-las-24-marcas", "hablar", "pablo_pato")
	_check(bool(res2.ok), "templo p1 hablar pablo_pato OK")
	res2 = _h.reportar_paso("cadena-templo-de-las-24-marcas", "explorar", "templo_24")
	_check(bool(res2.ok), "templo p2 explorar templo_24 OK")
	res2 = _h.reportar_entrega("cadena-templo-de-las-24-marcas")
	_check(bool(res2.ok), "templo p3 entregar OBJ-TAL-004 OK (inventario)")
	res2 = _h.reportar_paso("cadena-templo-de-las-24-marcas", "puzzle", "sellos-de-arcilla")
	_check(bool(res2.ok), "templo p4 puzzle OK")
	_check(_h.esta_completada("cadena-templo-de-las-24-marcas"), "cadena-templo-de-las-24-marcas completada end-to-end")
	_check(ws_has("templo_de_las_24_marcas_abierto"), "consecuencia templo_de_las_24_marcas_abierto aplicada (M21)")
	# End-to-end 3: ruinas del barrizal (catalina_oso REAL; OBJ-ITE-021 "Pan" REAL)
	if inv != null:
		inv.agregar_items({"OBJ-ITE-021": 1})
	var res3: Dictionary = _h.iniciar_cadena("cadena-ruinas-del-barrizal")
	_check(bool(res3.ok), "iniciar cadena-ruinas-del-barrizal OK")
	res3 = _h.reportar_paso("cadena-ruinas-del-barrizal", "hablar", "catalina_oso")
	_check(bool(res3.ok), "ruinas p1 hablar catalina_oso OK")
	res3 = _h.reportar_paso("cadena-ruinas-del-barrizal", "explorar", "barrizal")
	_check(bool(res3.ok), "ruinas p2 explorar barrizal OK")
	res3 = _h.reportar_entrega("cadena-ruinas-del-barrizal")
	_check(bool(res3.ok), "ruinas p3 entregar OBJ-ITE-021 OK (inventario)")
	res3 = _h.reportar_paso("cadena-ruinas-del-barrizal", "puzzle", "ofrenda-de-la-ruina")
	_check(bool(res3.ok), "ruinas p4 puzzle OK")
	_check(_h.esta_completada("cadena-ruinas-del-barrizal"), "cadena-ruinas-del-barrizal completada end-to-end")
	_check(ws_has("ruinas_del_barrizal_leidas"), "consecuencia ruinas_del_barrizal_leidas aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# los bloques H/K/L/M/N/O/P/Q). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-registro-del-faro"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	_fin("R")


## Escanea res://data/items/*.tres y devuelve {id: archivo} leyendo el campo id
## de cada recurso. Verificacion por EFECTO (campo real), no por nombre de
## archivo: el mapeo id -> archivo no es derivable del id.
func _ids_items_reales() -> Dictionary:
	var out := {}
	var dir := DirAccess.open("res://data/items")
	if dir == null:
		return out
	for fn in dir.get_files():
		if not fn.ends_with(".tres"):
			continue
		var f := FileAccess.open("res://data/items/" + fn, FileAccess.READ)
		if f == null:
			continue
		var texto := f.get_as_text()
		f.close()
		for linea in texto.split("\n"):
			if linea.begins_with('id = "'):
				var partes := linea.split('"')
				if partes.size() >= 2:
					out[partes[1]] = fn
				break
	return out

## Iter. 14 (Log 2163): seccion "Consecuencias y dialogos posteriores" del
## 05-Checklist. 03-Diseno L53 fija las 12 consecuencias persistentes; los items
## L108 ("jardin florecido"), L109 ("taller abierto") y L111 ("cofradia activa")
## piden 3 de ellas. Que el nombre figure en el diseno NO prueba que exista: se
## mide cual tiene respaldo REAL en disco (flag aplicado por una cadena) y se
## corre end-to-end las dos cuyos items se flippean. El negativo de
## "taller_abierto" es una GUARDA: si algun dia el flag aparece, este check falla
## y avisa que el item L109 dejo de ser honesto.
func _test_consecuencias() -> void:
	_h.restore_save_data({})
	var ws := root.get_node_or_null("WorldState")
	_check(ws != null, "WorldState presente (M21)")
	# 1) Cobertura de las 12 consecuencias sobre los dos catalogos reales
	var doce := ["faro_encendido", "jardin_florecido", "taller_abierto",
		"plaza_decorada", "puente_cruzable", "cofradia_activa", "kiosko_abierto",
		"molino_funcionando", "estacion_reparada", "biblioteca_iluminada",
		"camino_al_faro_despejado", "puerto_ampliado"]
	var principal := _leer_json("res://data/historias/secundarias.json")
	var ejemplos := _leer_json("res://data/historias/cadenas_ejemplo.json")
	var flags := {}
	for c in principal + ejemplos:
		var cons: Dictionary = (c as Dictionary).get("consecuencia", {})
		for flag in cons:
			flags[flag] = true
	var con_respaldo := []
	var sin_respaldo := []
	for f in doce:
		if flags.has(f):
			con_respaldo.append(f)
		else:
			sin_respaldo.append(f)
	# Iter. 16 (Log 2169): cadena-construccion-kiosko aplica kiosko_abierto ->
	# 9 de las 12 con respaldo (antes 8).
	# Iter. 23 (Log 2197): cadena-taller aplica taller_abierto (item L109) ->
	# 10 de las 12 con respaldo; el negativo de taller_abierto se INVIERTE en
	# guarda POSITIVA (abajo), porque el item dejo de ser un [ ] honesto.
	_check(con_respaldo.size() == 10, "10 de las 12 consecuencias con respaldo en disco: %d (%s)" % [con_respaldo.size(), str(con_respaldo)])
	_check(sin_respaldo.size() == 2, "2 de las 12 sin respaldo en disco: %d (%s)" % [sin_respaldo.size(), str(sin_respaldo)])
	_check(flags.has("biblioteca_iluminada"),
		"biblioteca_iluminada con respaldo: la aplica cadena-biblioteca del catalogo de ejemplos (mergeado y vivo, iter. 3)")
	_check(con_respaldo.has("jardin_florecido") and con_respaldo.has("cofradia_activa"),
		"jardin_florecido y cofradia_activa entre las CON respaldo (items L108/L111)")
	_check(con_respaldo.has("taller_abierto"),
		"taller_abierto entre las CON respaldo: lo aplica cadena-taller (item L109, iter. 23)")
	_check(sin_respaldo.has("camino_al_faro_despejado") and sin_respaldo.has("puerto_ampliado"),
		"las 2 SIN respaldo son camino_al_faro_despejado y puerto_ampliado (sin item propio en el 05)")
	# 2) Guarda POSITIVA sobre el arbol de DATOS (res://data): el token existe y
	# en UN solo catalogo. Alcance declarado: mide DATOS, no scripts. La version
	# anterior afirmaba lo contrario (token ausente) como guarda del item L109;
	# al crearse la cadena la guarda se invierte: si el dato desaparece, este
	# check falla y avisa que el item volvio a ser [ ] honesto.
	var hits_taller := _token_en_arbol("taller_abierto", "res://data")
	_check(hits_taller.size() == 1 and String(hits_taller[0]).ends_with("secundarias.json"),
		"token 'taller_abierto' en UN catalogo de res://data (%d hits: %s)" % [hits_taller.size(), str(hits_taller)])
	# 3) End-to-end de las 2 cadenas cuyos items se flippean (estado limpio)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"baya_roja": 1})
	var res: Dictionary = _h.iniciar_cadena("cadena-jardines")
	_check(bool(res.ok), "iniciar cadena-jardines OK")
	res = _h.reportar_paso("cadena-jardines", "hablar", "mateo_mapache")
	_check(bool(res.ok), "jardines p1 hablar mateo_mapache OK")
	res = _h.reportar_paso("cadena-jardines", "explorar", "jardines")
	_check(bool(res.ok), "jardines p2 explorar jardines OK")
	res = _h.reportar_entrega("cadena-jardines")
	_check(bool(res.ok), "jardines p3 entregar baya_roja OK (inventario)")
	res = _h.reportar_paso("cadena-jardines", "puzzle", "semillas-perdidas")
	_check(bool(res.ok), "jardines p4 puzzle OK")
	_check(_h.esta_completada("cadena-jardines"), "cadena-jardines completada end-to-end")
	_check(ws_has("jardin_florecido"), "consecuencia jardin_florecido aplicada a WorldState (M21)")
	if inv != null:
		inv.agregar_items({"fragmento_ancestral": 1})
	res = _h.iniciar_cadena("cadena-cofradia")
	_check(bool(res.ok), "iniciar cadena-cofradia OK")
	res = _h.reportar_paso("cadena-cofradia", "hablar", "mercedes_lince")
	_check(bool(res.ok), "cofradia p1 hablar mercedes_lince OK")
	res = _h.reportar_paso("cadena-cofradia", "explorar", "cofradia")
	_check(bool(res.ok), "cofradia p2 explorar cofradia OK")
	res = _h.reportar_entrega("cadena-cofradia")
	_check(bool(res.ok), "cofradia p3 entregar fragmento_ancestral OK (inventario)")
	res = _h.reportar_paso("cadena-cofradia", "puzzle", "sellos-antiguos")
	_check(bool(res.ok), "cofradia p4 puzzle OK")
	_check(_h.esta_completada("cadena-cofradia"), "cadena-cofradia completada end-to-end")
	_check(ws_has("cofradia_activa"), "consecuencia cofradia_activa aplicada a WorldState (M21)")
	# 4) Higiene: se apagan los flags para no contaminar un bloque posterior
	if ws != null:
		ws.set_flag("jardin_florecido", false)
		ws.set_flag("cofradia_activa", false)
	_fin("S")


## Iter. 15 (Log 2166): cluster Exploracion del 03-Diseno L39. El diseno
## nombra 3 temas para 8 misiones (brujula, fauna (M65), cronitar ruinas,
## 02-Analisis L20: "llevar una foto/brujula a un punto, observar fauna M65,
## cronitar ruinas"); las 5 restantes son extension declarada (mismo patron
## que Amistad 4+2 e Investigacion 4+1): cartografia con la brujula, mirador
## del acantilado, grutas del manantial, playas del sur, sendero del bosque y
## muelle viejo. La integracion con M65 (sistema de fauna) queda FUERA por
## orden del patron del director (M37 en Comerciantes, msg 181): se crean las
## cadenas M23, no el consumidor de fauna. No existe item de "foto" en
## data/items/ (medido: 0 coincidencias) -> el "llevar una foto" del 02 se
## cubre con el paso explorar de cada mision.
func _test_exploracion() -> void:
	_h.restore_save_data({})
	var nuevas := ["cadena-cartografia-de-la-isla", "cadena-fauna-de-la-isla",
		"cadena-cronologia-de-las-ruinas", "cadena-mirador-del-acantilado",
		"cadena-grutas-del-manantial", "cadena-playas-del-sur",
		"cadena-sendero-del-bosque", "cadena-muelle-viejo"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(not bool((_h.get_cadena(cid).get("oculta", false))), "%s NO es oculta (se descubre hablando)" % cid)
	# Visibles en disponibles desde el inicio
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in nuevas:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 8, "las 8 de exploracion figuran en disponibles desde el inicio (%d expuestas)" % expuestas)
	# Unicidad LOCAL de las 8 consecuencias nuevas (la global sobre las 60
	# cadenas cargadas la mide el bloque R)
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 8, "8 consecuencias distintas en las cadenas de exploracion: %d" % flags.size())
	_check(unicos, "consecuencias de exploracion sin colision entre si (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 8, "8 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# NPCs REALES: cada npc de las 8 cadenas existe como recurso en data/villagers/
	var npcs := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var npc := String((p as Dictionary).get("npc", ""))
			if npc != "":
				npcs[npc] = true
	for npc in npcs:
		_check(FileAccess.file_exists("res://data/villagers/%s.tres" % npc),
			"NPC REAL %s existe en data/villagers/" % npc)
	# Objetos REALES: cada objeto existe en data/items/ por campo id (efecto,
	# no nombre de archivo)
	var objetos := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var obj := String((p as Dictionary).get("objeto", ""))
			if obj != "":
				objetos[obj] = true
	var ids_items := _ids_items_reales()
	for obj in objetos:
		_check(ids_items.has(obj), "objeto REAL %s existe en data/items/ (por campo id)" % obj)
	# End-to-end 1: cartografia de la isla (finneas_zorro REAL; OBJ-HER-016 "Lupa mejorada" REAL)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-HER-016": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-cartografia-de-la-isla")
	_check(bool(res1.ok), "iniciar cadena-cartografia-de-la-isla OK")
	res1 = _h.reportar_paso("cadena-cartografia-de-la-isla", "hablar", "finneas_zorro")
	_check(bool(res1.ok), "cartografia p1 hablar finneas_zorro OK")
	res1 = _h.reportar_paso("cadena-cartografia-de-la-isla", "explorar", "faro")
	_check(bool(res1.ok), "cartografia p2 explorar faro OK")
	res1 = _h.reportar_entrega("cadena-cartografia-de-la-isla")
	_check(bool(res1.ok), "cartografia p3 entregar OBJ-HER-016 OK (inventario)")
	res1 = _h.reportar_paso("cadena-cartografia-de-la-isla", "puzzle", "rumbos-de-la-carta")
	_check(bool(res1.ok), "cartografia p4 puzzle OK")
	_check(_h.esta_completada("cadena-cartografia-de-la-isla"), "cadena-cartografia-de-la-isla completada end-to-end")
	_check(ws_has("isla_cartografiada"), "consecuencia isla_cartografiada aplicada (M21)")
	# End-to-end 2: fauna de la isla (teo_conejo REAL; OBJ-NAT-027 "Liana" REAL)
	if inv != null:
		inv.agregar_items({"OBJ-NAT-027": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-fauna-de-la-isla")
	_check(bool(res2.ok), "iniciar cadena-fauna-de-la-isla OK")
	res2 = _h.reportar_paso("cadena-fauna-de-la-isla", "hablar", "teo_conejo")
	_check(bool(res2.ok), "fauna p1 hablar teo_conejo OK")
	res2 = _h.reportar_paso("cadena-fauna-de-la-isla", "explorar", "bosque")
	_check(bool(res2.ok), "fauna p2 explorar bosque OK")
	res2 = _h.reportar_entrega("cadena-fauna-de-la-isla")
	_check(bool(res2.ok), "fauna p3 entregar OBJ-NAT-027 OK (inventario)")
	res2 = _h.reportar_paso("cadena-fauna-de-la-isla", "puzzle", "recuento-de-huellas")
	_check(bool(res2.ok), "fauna p4 puzzle OK")
	_check(_h.esta_completada("cadena-fauna-de-la-isla"), "cadena-fauna-de-la-isla completada end-to-end")
	_check(ws_has("fauna_de_la_isla_registrada"), "consecuencia fauna_de_la_isla_registrada aplicada (M21)")
	# End-to-end 3: cronologia de las ruinas (sofia_buho REAL; OBJ-REL-004 "Reloj ancestral" REAL)
	if inv != null:
		inv.agregar_items({"OBJ-REL-004": 1})
	var res3: Dictionary = _h.iniciar_cadena("cadena-cronologia-de-las-ruinas")
	_check(bool(res3.ok), "iniciar cadena-cronologia-de-las-ruinas OK")
	res3 = _h.reportar_paso("cadena-cronologia-de-las-ruinas", "hablar", "sofia_buho")
	_check(bool(res3.ok), "cronologia p1 hablar sofia_buho OK")
	res3 = _h.reportar_paso("cadena-cronologia-de-las-ruinas", "explorar", "biblioteca_quemada")
	_check(bool(res3.ok), "cronologia p2 explorar biblioteca_quemada OK")
	res3 = _h.reportar_entrega("cadena-cronologia-de-las-ruinas")
	_check(bool(res3.ok), "cronologia p3 entregar OBJ-REL-004 OK (inventario)")
	res3 = _h.reportar_paso("cadena-cronologia-de-las-ruinas", "puzzle", "orden-de-las-ruinas")
	_check(bool(res3.ok), "cronologia p4 puzzle OK")
	_check(_h.esta_completada("cadena-cronologia-de-las-ruinas"), "cadena-cronologia-de-las-ruinas completada end-to-end")
	_check(ws_has("ruinas_datadas"), "consecuencia ruinas_datadas aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# los bloques H/K/L/M/N/O/P/Q/R). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-cartografia-de-la-isla"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	# Higiene: se apagan los flags para no contaminar un bloque posterior
	var ws := root.get_node_or_null("WorldState")
	if ws != null:
		ws.set_flag("isla_cartografiada", false)
		ws.set_flag("fauna_de_la_isla_registrada", false)
		ws.set_flag("ruinas_datadas", false)
	_fin("T")


## Iter. 16 (Log 2169): cluster Construccion del 05-Checklist (L69: "Crear 6
## misiones de construccion: puentes, cofradia, plaza, senderos, kiosko,
## jardin"). Los 6 temas tienen cadena en disco: cofradia y jardines de la
## iter. 6, puente de la iter. 7 (tema de reparacion, consecuencia
## puente_cruzable) y plaza/senderos/kiosko — las 3 ultimas aparecieron en el
## worktree el 2026-10-24 04:04 por una corrida cortada (sin log ni mensaje) y
## fueron barridas por el CRON en f6a07c6. Este bloque RE-VERIFICA esas 3
## cadenas (regla de la familia It. 10/15: no rehacer, verificar y reparar):
## carga/fuente/no-oculta, expuestas en disponibles, unicidad local, capitulos
## de diario, NPC/objetos REALES por campo id y 2 end-to-end con consecuencia
## aplicada a WorldState (M21).
func _test_construccion() -> void:
	_h.restore_save_data({})
	var nuevas := ["cadena-construccion-plaza", "cadena-construccion-senderos",
		"cadena-construccion-kiosko"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(not bool((_h.get_cadena(cid).get("oculta", false))), "%s NO es oculta (se descubre hablando)" % cid)
	# Los 6 temas del item L69 con cadena en disco (las 3 de arriba + las 3 previas)
	for cid in ["cadena-cofradia", "cadena-jardines", "cadena-puente"]:
		_check(not _h.get_cadena(cid).is_empty(), "tema L69 con cadena previa: %s" % cid)
	# Visibles en disponibles desde el inicio
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in nuevas:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 3, "las 3 de construccion figuran en disponibles desde el inicio (%d expuestas)" % expuestas)
	# Unicidad LOCAL de las 3 consecuencias nuevas (la global sobre las 63
	# cadenas cargadas la mide el bloque R)
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 3, "3 consecuencias distintas en las cadenas de construccion: %d" % flags.size())
	_check(unicos, "consecuencias de construccion sin colision entre si (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 3, "3 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# NPCs REALES: cada npc de las 3 cadenas existe como recurso en data/villagers/
	var npcs := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var npc := String((p as Dictionary).get("npc", ""))
			if npc != "":
				npcs[npc] = true
	for npc in npcs:
		_check(FileAccess.file_exists("res://data/villagers/%s.tres" % npc),
			"NPC REAL %s existe en data/villagers/" % npc)
	# Objetos REALES: cada objeto existe en data/items/ por campo id (efecto,
	# no nombre de archivo)
	var objetos := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var obj := String((p as Dictionary).get("objeto", ""))
			if obj != "":
				objetos[obj] = true
	var ids_items := _ids_items_reales()
	for obj in objetos:
		_check(ids_items.has(obj), "objeto REAL %s existe en data/items/ (por campo id)" % obj)
	# End-to-end 1: el kiosko de la plaza (pablo_pato REAL; OBJ-ITE-001 "Madera" REAL)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-ITE-001": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-construccion-kiosko")
	_check(bool(res1.ok), "iniciar cadena-construccion-kiosko OK")
	res1 = _h.reportar_paso("cadena-construccion-kiosko", "hablar", "pablo_pato")
	_check(bool(res1.ok), "kiosko p1 hablar pablo_pato OK")
	res1 = _h.reportar_paso("cadena-construccion-kiosko", "explorar", "plaza")
	_check(bool(res1.ok), "kiosko p2 explorar plaza OK")
	res1 = _h.reportar_entrega("cadena-construccion-kiosko")
	_check(bool(res1.ok), "kiosko p3 entregar OBJ-ITE-001 OK (inventario)")
	res1 = _h.reportar_paso("cadena-construccion-kiosko", "puzzle", "armado-del-kiosko")
	_check(bool(res1.ok), "kiosko p4 puzzle OK")
	_check(_h.esta_completada("cadena-construccion-kiosko"), "cadena-construccion-kiosko completada end-to-end")
	_check(ws_has("kiosko_abierto"), "consecuencia kiosko_abierto aplicada (M21)")
	# End-to-end 2: los senderos del pueblo (nico_gato REAL; gravel "Grava" REAL)
	if inv != null:
		inv.agregar_items({"gravel": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-construccion-senderos")
	_check(bool(res2.ok), "iniciar cadena-construccion-senderos OK")
	res2 = _h.reportar_paso("cadena-construccion-senderos", "hablar", "nico_gato")
	_check(bool(res2.ok), "senderos p1 hablar nico_gato OK")
	res2 = _h.reportar_paso("cadena-construccion-senderos", "explorar", "senderos_del_pueblo")
	_check(bool(res2.ok), "senderos p2 explorar senderos_del_pueblo OK")
	res2 = _h.reportar_entrega("cadena-construccion-senderos")
	_check(bool(res2.ok), "senderos p3 entregar gravel OK (inventario)")
	res2 = _h.reportar_paso("cadena-construccion-senderos", "puzzle", "nivelado-de-senderos")
	_check(bool(res2.ok), "senderos p4 puzzle OK")
	_check(_h.esta_completada("cadena-construccion-senderos"), "cadena-construccion-senderos completada end-to-end")
	_check(ws_has("senderos_del_pueblo_reparados"), "consecuencia senderos_del_pueblo_reparados aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# los bloques H/K/L/M/N/O/P/Q/R/T). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-construccion-kiosko"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	# Higiene: se apagan los flags para no contaminar un bloque posterior
	var ws := root.get_node_or_null("WorldState")
	if ws != null:
		ws.set_flag("kiosko_abierto", false)
		ws.set_flag("senderos_del_pueblo_reparados", false)
	_fin("U")


func _test_agricultura() -> void:
	# Iter. 17 (Log 2171, 2026-10-24): +5 cadenas del cluster Agricultura
	# (item L71 del 05: "Crear 5 misiones de agricultura"). Los 3 temas que
	# nombra 03-Diseno L41 son invernadero / cruces de semillas / variantes M32:
	#   - invernadero YA tenia cadena previa (cadena-invernadero, principal)
	#   - variantes estacionales = item L72, DUENO M32 (fuera, no se inventa)
	#   -> las 5 de abajo son 1 tema nombrado (cruces de semillas) + 4 de
	#      extension declarada (cultivos del invernadero, primera cosecha,
	#      riego del manantial, macetas de la plaza), mismo patron que
	#      Exploracion (3+5) e Investigacion (4+1).
	_h.restore_save_data({})
	var nuevas := ["cadena-agricultura-cruces", "cadena-agricultura-cultivos",
		"cadena-agricultura-cosecha", "cadena-agricultura-riego",
		"cadena-agricultura-macetas"]
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(not bool((_h.get_cadena(cid).get("oculta", false))), "%s NO es oculta (se descubre hablando)" % cid)
	# Tema "invernadero" del diseno: cadena previa del principal (no se duplica)
	_check(not _h.get_cadena("cadena-invernadero").is_empty(), "tema invernadero con cadena previa: cadena-invernadero")
	# Visibles en disponibles desde el inicio
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in nuevas:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 5, "las 5 de agricultura figuran en disponibles desde el inicio (%d expuestas)" % expuestas)
	# Unicidad LOCAL de las 5 consecuencias nuevas (la global sobre las 68
	# cadenas cargadas la mide el bloque R)
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 5, "5 consecuencias distintas en las cadenas de agricultura: %d" % flags.size())
	_check(unicos, "consecuencias de agricultura sin colision entre si (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 5, "5 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# NPCs REALES: cada npc existe como recurso en data/villagers/
	# (vera_ardilla = farera, guardiana de semillas; mateo_mapache = granjero;
	#  teo_conejo = herbolario; luna_zorra = artesana - roles medidos en los .tres)
	var npcs := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var npc := String((p as Dictionary).get("npc", ""))
			if npc != "":
				npcs[npc] = true
	for npc in npcs:
		_check(FileAccess.file_exists("res://data/villagers/%s.tres" % npc),
			"NPC REAL %s existe en data/villagers/" % npc)
	# Objetos REALES: cada objeto existe en data/items/ por campo id
	var objetos := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var obj := String((p as Dictionary).get("objeto", ""))
			if obj != "":
				objetos[obj] = true
	var ids_items := _ids_items_reales()
	for obj in objetos:
		_check(ids_items.has(obj), "objeto REAL %s existe en data/items/ (por campo id)" % obj)
	# End-to-end 1: los cruces de semillas (vera_ardilla REAL;
	# OBJ-EXT-011 "Jardin de hierbas" REAL)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-EXT-011": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-agricultura-cruces")
	_check(bool(res1.ok), "iniciar cadena-agricultura-cruces OK")
	res1 = _h.reportar_paso("cadena-agricultura-cruces", "hablar", "vera_ardilla")
	_check(bool(res1.ok), "cruces p1 hablar vera_ardilla OK")
	res1 = _h.reportar_paso("cadena-agricultura-cruces", "explorar", "jardin")
	_check(bool(res1.ok), "cruces p2 explorar jardin OK")
	res1 = _h.reportar_entrega("cadena-agricultura-cruces")
	_check(bool(res1.ok), "cruces p3 entregar OBJ-EXT-011 OK (inventario)")
	res1 = _h.reportar_paso("cadena-agricultura-cruces", "puzzle", "cruz-de-semillas")
	_check(bool(res1.ok), "cruces p4 puzzle OK")
	_check(_h.esta_completada("cadena-agricultura-cruces"), "cadena-agricultura-cruces completada end-to-end")
	_check(ws_has("cruces_de_semillas"), "consecuencia cruces_de_semillas aplicada (M21)")
	# End-to-end 2: el riego del manantial (teo_conejo REAL;
	# OBJ-HER-013 "Regadera mejorada" REAL)
	if inv != null:
		inv.agregar_items({"OBJ-HER-013": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-agricultura-riego")
	_check(bool(res2.ok), "iniciar cadena-agricultura-riego OK")
	res2 = _h.reportar_paso("cadena-agricultura-riego", "hablar", "teo_conejo")
	_check(bool(res2.ok), "riego p1 hablar teo_conejo OK")
	res2 = _h.reportar_paso("cadena-agricultura-riego", "explorar", "manantial")
	_check(bool(res2.ok), "riego p2 explorar manantial OK")
	res2 = _h.reportar_entrega("cadena-agricultura-riego")
	_check(bool(res2.ok), "riego p3 entregar OBJ-HER-013 OK (inventario)")
	res2 = _h.reportar_paso("cadena-agricultura-riego", "puzzle", "canal-del-manantial")
	_check(bool(res2.ok), "riego p4 puzzle OK")
	_check(_h.esta_completada("cadena-agricultura-riego"), "cadena-agricultura-riego completada end-to-end")
	_check(ws_has("riego_del_huerto"), "consecuencia riego_del_huerto aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# los bloques H/K/L/M/N/O/P/Q/R/T/U). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-agricultura-cruces"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	# Higiene: se apenden los flags para no contaminar un bloque posterior
	var ws := root.get_node_or_null("WorldState")
	if ws != null:
		ws.set_flag("cruces_de_semillas", false)
		ws.set_flag("riego_del_huerto", false)
	_fin("V")

func _test_pesca_coleccion() -> void:
	# Iter. 18 (Log 2173, 2026-10-24): +10 cadenas de los clusters Pesca
	# (item L77 del 05: "Crear 4 misiones de pesca") y Coleccion (item L78:
	# "Crear 6 misiones de coleccion"). 03-Diseno L42 nombra 3 temas de pesca
	# (peces-trofeo M36, documentacion, suelta) y L43 nombra los 6 de coleccion
	# (murales, glifos, sellos decorativos, minerales, peces, plantas M36):
	#   -> pesca = 3 temas nombrados + 1 de extension declarada (nocturna),
	#      mismo patron que Exploracion (3+5) e Investigacion (4+1).
	#   -> coleccion = los 6 temas nombrados.
	_h.restore_save_data({})
	var pesca := ["cadena-pesca-trofeos", "cadena-pesca-documentacion",
		"cadena-pesca-suelta", "cadena-pesca-nocturna"]
	var coleccion := ["cadena-coleccion-murales", "cadena-coleccion-glifos",
		"cadena-coleccion-sellos", "cadena-coleccion-minerales",
		"cadena-coleccion-peces", "cadena-coleccion-plantas"]
	var nuevas := pesca + coleccion
	for cid in nuevas:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(not bool((_h.get_cadena(cid).get("oculta", false))), "%s NO es oculta (se descubre hablando)" % cid)
	# Visibles en disponibles desde el inicio
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in nuevas:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 10, "las 10 de pesca/coleccion figuran en disponibles desde el inicio (%d expuestas)" % expuestas)
	# Unicidad LOCAL de las 10 consecuencias nuevas (la global sobre las 78
	# cadenas cargadas la mide el bloque R)
	var flags := {}
	var unicos := true
	for cid in nuevas:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 10, "10 consecuencias distintas en las cadenas de pesca/coleccion: %d" % flags.size())
	_check(unicos, "consecuencias de pesca/coleccion sin colision entre si (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in nuevas:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 10, "10 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# NPCs REALES: cada npc existe como recurso en data/villagers/
	# (finneas_zorro = pescador, sofia_buho = bibliotecaria, teo_conejo =
	#  herbolario, luna_zorra = artesana, olivia_nutria = sastra,
	#  ramon_tejon = herrero - profesiones medidas en los .tres)
	var npcs := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var npc := String((p as Dictionary).get("npc", ""))
			if npc != "":
				npcs[npc] = true
	_check(npcs.size() == 6, "6 NPC distintos en las 10 cadenas: %d" % npcs.size())
	for npc in npcs:
		_check(FileAccess.file_exists("res://data/villagers/%s.tres" % npc),
			"NPC REAL %s existe en data/villagers/" % npc)
	# Objetos REALES: cada objeto existe en data/items/ por campo id
	var objetos := {}
	for cid in nuevas:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var obj := String((p as Dictionary).get("objeto", ""))
			if obj != "":
				objetos[obj] = true
	_check(objetos.size() == 10, "10 objetos distintos en las 10 cadenas: %d" % objetos.size())
	var ids_items := _ids_items_reales()
	for obj in objetos:
		_check(ids_items.has(obj), "objeto REAL %s existe en data/items/ (por campo id)" % obj)
	# End-to-end 1: los peces trofeo (finneas_zorro REAL;
	# OBJ-HER-011 "Cana de oro" REAL)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"OBJ-HER-011": 1})
	var res1: Dictionary = _h.iniciar_cadena("cadena-pesca-trofeos")
	_check(bool(res1.ok), "iniciar cadena-pesca-trofeos OK")
	res1 = _h.reportar_paso("cadena-pesca-trofeos", "hablar", "finneas_zorro")
	_check(bool(res1.ok), "trofeos p1 hablar finneas_zorro OK")
	res1 = _h.reportar_paso("cadena-pesca-trofeos", "explorar", "muelle_viejo")
	_check(bool(res1.ok), "trofeos p2 explorar muelle_viejo OK")
	res1 = _h.reportar_paso("cadena-pesca-trofeos", "puzzle", "trofeo-de-la-marea")
	_check(bool(res1.ok), "trofeos p3 puzzle OK")
	res1 = _h.reportar_entrega("cadena-pesca-trofeos")
	_check(bool(res1.ok), "trofeos p4 entregar OBJ-HER-011 OK (inventario)")
	_check(_h.esta_completada("cadena-pesca-trofeos"), "cadena-pesca-trofeos completada end-to-end")
	_check(ws_has("trofeo_de_la_marea_exhibido"), "consecuencia trofeo_de_la_marea_exhibido aplicada (M21)")
	# End-to-end 2: las plantas raras (teo_conejo REAL;
	# OBJ-PLA-004 "Orquidea" REAL)
	if inv != null:
		inv.agregar_items({"OBJ-PLA-004": 1})
	var res2: Dictionary = _h.iniciar_cadena("cadena-coleccion-plantas")
	_check(bool(res2.ok), "iniciar cadena-coleccion-plantas OK")
	res2 = _h.reportar_paso("cadena-coleccion-plantas", "hablar", "teo_conejo")
	_check(bool(res2.ok), "plantas p1 hablar teo_conejo OK")
	res2 = _h.reportar_paso("cadena-coleccion-plantas", "explorar", "jardines")
	_check(bool(res2.ok), "plantas p2 explorar jardines OK")
	res2 = _h.reportar_paso("cadena-coleccion-plantas", "puzzle", "orquidea-escondida")
	_check(bool(res2.ok), "plantas p3 puzzle OK")
	res2 = _h.reportar_entrega("cadena-coleccion-plantas")
	_check(bool(res2.ok), "plantas p4 entregar OBJ-PLA-004 OK (inventario)")
	_check(_h.esta_completada("cadena-coleccion-plantas"), "cadena-coleccion-plantas completada end-to-end")
	_check(ws_has("plantas_raras_clasificadas"), "consecuencia plantas_raras_clasificadas aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# los bloques H/K/L/M/N/O/P/Q/R/T/U/V). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-pesca-trofeos"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	# Higiene: se apenden los flags para no contaminar un bloque posterior
	var ws := root.get_node_or_null("WorldState")
	if ws != null:
		ws.set_flag("trofeo_de_la_marea_exhibido", false)
		ws.set_flag("plantas_raras_clasificadas", false)
	_fin("W")


func _test_postgame_cluster() -> void:
	# Iter. 19 (2026-10-24): cluster Postgame del 03-Diseno L47. Las 4 cadenas
	# de postgame = reconstruccion de la plaza (cadena-epilogo-plaza del
	# principal, L130) + memorial del Sello (item L132 del 05) + epilogo de la
	# aldea (L133) + epilogo del guardian (L134, final secreto). Esta iteracion
	# crea las 3 que faltaban; todas nacen con postgame:true (las filtra
	# cadenas_disponibles/iniciar_cadena hasta que Historia elige un final,
	# medido abajo). El epilogo del guardian es OCULTO (final secreto, patron
	# ocultas L38): no figura en disponibles hasta iniciarse. L34 (historia de
	# la plaza) sigue [ ] honesto: el rechazo del tipo "construir" es
	# PERSISTENTE (decision del director, msg 153) - no se toca sin orden.
	_h.restore_save_data({})
	var memorial := ["cadena-memorial-sello", "cadena-epilogo-aldea",
		"cadena-epilogo-guardian"]
	var postgame_previas := ["cadena-epilogo-plaza"]
	for cid in memorial:
		_check(not _h.get_cadena(cid).is_empty(), "%s cargada" % cid)
		_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal" % cid)
		_check(bool(_h.get_cadena(cid).get("postgame", false)), "%s marcada postgame" % cid)
	# Las 4 de postgame del diseno estan en el catalogo
	var todas_postgame := memorial + postgame_previas
	var en_catalogo := 0
	for cid in todas_postgame:
		if not _h.get_cadena(cid).is_empty():
			en_catalogo += 1
	_check(en_catalogo == 4, "las 4 cadenas de postgame del diseno estan en el catalogo (%d)" % en_catalogo)
	# Oculta: el guardian (final secreto) NO figura en disponibles; memorial y
	# aldea tampoco figuran por el gate de postgame (sin final elegido)
	_check(bool(_h.get_cadena("cadena-epilogo-guardian").get("oculta", false)),
		"cadena-epilogo-guardian es oculta (final secreto)")
	_check(not bool(_h.get_cadena("cadena-memorial-sello").get("oculta", false)),
		"cadena-memorial-sello NO es oculta")
	_check(not bool(_h.get_cadena("cadena-epilogo-aldea").get("oculta", false)),
		"cadena-epilogo-aldea NO es oculta")
	# Estado limpio: el bloque F dejo un final elegido (su loop termina en
	# "secreto"); se limpia para medir el gate de postgame desde cero (mismo
	# montaje que el bloque F).
	var h := root.get_node_or_null("Historia")
	var ws := root.get_node_or_null("WorldState")
	if h != null:
		h.restore_save_data({"completados": [], "sellos": [], "final_elegido": ""})
	if ws != null:
		ws.set_flag("templo_brisa_abierto", false)
		ws.set_flag("pistas_secreto_completas", false)
	_h.restore_save_data({})
	var disponibles: Array = _h.cadenas_disponibles()
	var expuestas := 0
	for cid in memorial:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 0, "ninguna de las 3 en disponibles sin final elegido (gate postgame/oculta) (%d expuestas)" % expuestas)
	# Unicidad LOCAL de las 3 consecuencias nuevas (la global sobre las 81
	# cargadas la mide el bloque R)
	var flags := {}
	var unicos := true
	for cid in memorial:
		var cons: Dictionary = _h.get_cadena(cid).get("consecuencia", {})
		for flag in cons:
			if flags.has(flag):
				unicos = false
			flags[flag] = true
	_check(flags.size() == 3, "3 consecuencias distintas en las cadenas de postgame: %d" % flags.size())
	_check(unicos, "consecuencias de postgame sin colision entre si (%s)" % str(flags.keys()))
	# Capitulos de diario distintos entre si
	var diarios := {}
	var dunicos := true
	for cid in memorial:
		var d := String((_h.get_cadena(cid).get("recompensa", {}) as Dictionary).get("diario", ""))
		if diarios.has(d):
			dunicos = false
		diarios[d] = true
	_check(dunicos and diarios.size() == 3, "3 capitulos de diario distintos (%s)" % str(diarios.keys()))
	# NPCs REALES: cada npc existe como recurso en data/villagers/
	# (ramon_tejon herrero, aria_ciervo trovadora, pablo_pato ceramista,
	#  catalina_oso cocinera, nico_gato guardabosques - profesiones medidas
	#  en los .tres)
	var npcs := {}
	for cid in memorial:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var npc := String((p as Dictionary).get("npc", ""))
			if npc != "":
				npcs[npc] = true
	_check(npcs.size() == 5, "5 NPC distintos en las 3 cadenas: %d" % npcs.size())
	for npc in npcs:
		_check(FileAccess.file_exists("res://data/villagers/%s.tres" % npc),
			"NPC REAL %s existe en data/villagers/" % npc)
	# Objetos REALES: cada objeto existe en data/items/ por campo id
	var objetos := {}
	for cid in memorial:
		for p in (_h.get_cadena(cid).get("pasos", []) as Array):
			var obj := String((p as Dictionary).get("objeto", ""))
			if obj != "":
				objetos[obj] = true
	_check(objetos.size() == 3, "3 objetos distintos en las 3 cadenas: %d" % objetos.size())
	var ids_items := _ids_items_reales()
	for obj in objetos:
		_check(ids_items.has(obj), "objeto REAL %s existe en data/items/ (por campo id)" % obj)
	# End-to-end: completar el grafo de M22 hasta final_principal (mismo
	# montaje que el bloque F) y correr las 3 cadenas.
	if h != null:
		for s in SELLOS_C4:
			h.marcar_sello(s)
		if ws != null:
			ws.set_flag("templo_brisa_abierto", true)
		for paso in ["prologo", "c1", "c2", "c3", "c4", "c5", "c6", "c7"]:
			h.completar_nodo(paso)
		h.completar_nodo("final_principal")
	_check(h != null and h.final_elegido() == "principal",
		"final_elegido = 'principal' tras completar el grafo de M22")
	# Con final elegido, las 2 visibles ya figuran en disponibles (la oculta no)
	disponibles = _h.cadenas_disponibles()
	expuestas = 0
	for cid in ["cadena-memorial-sello", "cadena-epilogo-aldea"]:
		for d in disponibles:
			if String(d) == cid:
				expuestas += 1
	_check(expuestas == 2, "memorial y aldea en disponibles tras el final (%d expuestas)" % expuestas)
	# E2E 1: memorial del sello (ramon_tejon REAL; piedra_caliza REAL)
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"piedra_caliza": 1})
	var r1: Dictionary = _h.iniciar_cadena("cadena-memorial-sello")
	_check(bool(r1.ok), "iniciar cadena-memorial-sello OK")
	r1 = _h.reportar_paso("cadena-memorial-sello", "hablar", "ramon_tejon")
	_check(bool(r1.ok), "memorial p1 hablar ramon_tejon OK")
	r1 = _h.reportar_paso("cadena-memorial-sello", "explorar", "plaza")
	_check(bool(r1.ok), "memorial p2 explorar plaza OK")
	r1 = _h.reportar_entrega("cadena-memorial-sello")
	_check(bool(r1.ok), "memorial p3 entregar piedra_caliza OK (inventario)")
	r1 = _h.reportar_paso("cadena-memorial-sello", "hablar", "aria_ciervo")
	_check(bool(r1.ok), "memorial p4 hablar aria_ciervo OK")
	_check(_h.esta_completada("cadena-memorial-sello"), "cadena-memorial-sello completada end-to-end")
	_check(ws_has("memorial_del_sello_erguido"), "consecuencia memorial_del_sello_erguido aplicada (M21)")
	# E2E 2: epilogo de la aldea (pablo_pato REAL; clay "Arcilla" REAL)
	if inv != null:
		inv.agregar_items({"clay": 1})
	var r2: Dictionary = _h.iniciar_cadena("cadena-epilogo-aldea")
	_check(bool(r2.ok), "iniciar cadena-epilogo-aldea OK")
	r2 = _h.reportar_paso("cadena-epilogo-aldea", "hablar", "pablo_pato")
	_check(bool(r2.ok), "aldea p1 hablar pablo_pato OK")
	r2 = _h.reportar_paso("cadena-epilogo-aldea", "explorar", "senderos_del_pueblo")
	_check(bool(r2.ok), "aldea p2 explorar senderos_del_pueblo OK")
	r2 = _h.reportar_entrega("cadena-epilogo-aldea")
	_check(bool(r2.ok), "aldea p3 entregar clay OK (inventario)")
	r2 = _h.reportar_paso("cadena-epilogo-aldea", "hablar", "catalina_oso")
	_check(bool(r2.ok), "aldea p4 hablar catalina_oso OK")
	_check(_h.esta_completada("cadena-epilogo-aldea"), "cadena-epilogo-aldea completada end-to-end")
	_check(ws_has("epilogo_de_la_aldea_contado"), "consecuencia epilogo_de_la_aldea_contado aplicada (M21)")
	# E2E 3: epilogo del guardian (nico_gato REAL; fragmento_ancestral REAL)
	if inv != null:
		inv.agregar_items({"fragmento_ancestral": 1})
	var r3: Dictionary = _h.iniciar_cadena("cadena-epilogo-guardian")
	_check(bool(r3.ok), "iniciar cadena-epilogo-guardian OK (oculta se inicia directo)")
	r3 = _h.reportar_paso("cadena-epilogo-guardian", "hablar", "nico_gato")
	_check(bool(r3.ok), "guardian p1 hablar nico_gato OK")
	r3 = _h.reportar_paso("cadena-epilogo-guardian", "explorar", "acantilado")
	_check(bool(r3.ok), "guardian p2 explorar acantilado OK")
	r3 = _h.reportar_paso("cadena-epilogo-guardian", "puzzle", "guardian-ultima-guarda")
	_check(bool(r3.ok), "guardian p3 puzzle OK")
	r3 = _h.reportar_entrega("cadena-epilogo-guardian")
	_check(bool(r3.ok), "guardian p4 entregar fragmento_ancestral OK (inventario)")
	_check(_h.esta_completada("cadena-epilogo-guardian"), "cadena-epilogo-guardian completada end-to-end")
	_check(ws_has("epilogo_del_guardian_cantado"), "consecuencia epilogo_del_guardian_cantado aplicada (M21)")
	# Puente diario M23->M55: sin entrada mision_cadena-* en el catalogo de M55
	# el puente degrada en silencio (finding medido, dueno M55; mismo patron que
	# los bloques H/K/L/M/N/O/P/Q/R/T/U/V/W). No se inventa contenido de M55.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_cadena-memorial-sello"),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	# Higiene: se apagan los flags para no contaminar un bloque posterior
	if ws != null:
		ws.set_flag("memorial_del_sello_erguido", false)
		ws.set_flag("epilogo_de_la_aldea_contado", false)
		ws.set_flag("epilogo_del_guardian_cantado", false)
	_fin("X")


func _test_recompensa_diario() -> void:
	# Iter. 21 (Log 2187): L97 "Crear 20 capitulos de diario (recompensa
	# narrativa)" medido sobre disco. El puente M23->M55 derivaba
	# "mision_"+cadena_id SIN LEER el capitulo declarado en recompensa.diario
	# (03-Diseno L18): el campo era data muerta (79 valores capitulo-*, 0 usos
	# en todo el codebase; quest_chain.gd L43 solo miraba la clave). Ademas el
	# catalogo de M55 (data/diario/diario_catalog.json) solo tiene 2 de las 79
	# entradas (mision_cadena-faro, mision_cadena-invernadero — esquema
	# mision_<id> del puente de M22, diary_service.gd L103) -> 77 recompensas
	# degradan en silencio (registrar() devuelve false, diary_service.gd
	# L136-137; finding de contenido de M55, reportado a la directora).
	# TANDA: (1) el puente ahora CONSUME el capitulo declarado; (2) los 79
	# valores renombrados al esquema real mision_<cadena_id> (comportamiento
	# identico: las 2 con respaldo siguen registrando, las 77 siguen degradando
	# — con el dataset actual declarado == derivado, el check de runtime pasa
	# bajo ambas implementaciones; lo que cambia es el dataset futuro); (3) el
	# invariante y el hueco quedan fijados en suite.
	var principal := _leer_json("res://data/historias/secundarias.json")
	var cat_raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/diario/diario_catalog.json"))
	var ids_m55 := {}
	if typeof(cat_raw) == TYPE_DICTIONARY:
		for c in (cat_raw as Dictionary).get("categorias", []):
			for e in (c as Dictionary).get("entradas", []):
				ids_m55[String((e as Dictionary).get("id", ""))] = true
	var con_diario := 0
	var sin_diario := []
	var sin_respaldo := 0
	var viol := []
	for c in principal:
		var cid := String((c as Dictionary).get("id", ""))
		var rec: Dictionary = (c as Dictionary).get("recompensa", {})
		var d := String(rec.get("diario", ""))
		if d == "":
			sin_diario.append(cid)
			continue
		con_diario += 1
		if d != "mision_" + cid:
			viol.append("%s=%s" % [cid, d])
		if not ids_m55.has(d):
			sin_respaldo += 1
	_check(principal.size() == 81, "catalogo principal con 81 cadenas (crudo): %d" % principal.size())
	_check(con_diario == 80, "80 cadenas declaran capitulo de diario: %d" % con_diario)
	_check(sin_diario.size() == 1 and sin_diario[0] == "cadena-secretta-luciernagas",
		"1 cadena sin diario (solo cosmetico) = cadena-secretta-luciernagas: %s" % str(sin_diario))
	_check(viol.is_empty(), "invariante recompensa.diario == 'mision_'+id en las 80 (violaciones: %s)" % str(viol))
	_check(sin_respaldo == 78, "78 de 80 capitulos NO existen en el catalogo M55 (contenido de M55, hallazgo): %d" % sin_respaldo)
	_check(ids_m55.has("mision_cadena-faro") and ids_m55.has("mision_cadena-invernadero"),
		"las 2 entradas con respaldo en M55 son mision_cadena-faro y mision_cadena-invernadero")
	# Runtime: el capitulo CON respaldo se registra al completar (el puente
	# consume la declaracion; el bloque C completo cadena-faro antes de Y).
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(diary.esta_registrada("mision_cadena-faro"),
			"mision_cadena-faro registrado tras completar cadena-faro (puente consume recompensa.diario)")
		_check(not diary.esta_registrada("mision_cadena-biblioteca"),
			"mision_cadena-biblioteca NO registrado (sin entrada en catalogo M55: el puente degrada en silencio)")
	_fin("Y")


func _test_e2e_diez() -> void:
	# Iter. 22 (2026-10-25, DeepSeek-V4.1-Flash): L159 del 05-Checklist —
	# "Disenar test E2E de 10 cadenas completas". Los bloques H-Z corrian 2-3
	# cadenas end-to-end por cluster; este corre DIEZ cadenas COMPLETAS (una
	# por cluster) con un driver GENERICO: visibilidad -> iniciar -> los pasos
	# en el orden DECLARADO -> completar -> consecuencias en M21 -> sale de
	# disponibles -> no se re-inicia -> puente de diario contra el catalogo
	# M55. Despues: save/restore round-trip de las 10.
	# Anti-falso-verde: (a) los flags de consecuencia se APAGAN antes de
	# correr, asi el check prueba que la cadena los aplico y no que ya estaban
	# de un bloque previo; (b) la evidencia de cada paso se lee del DATO
	# (npc/lugar/ref/objeto), no de una lista paralela escrita a mano; (c) el
	# puente de diario se compara contra diario_catalog.json leido en disco,
	# no contra un numero fijo.
	_h.restore_save_data({})
	var inv := root.get_node_or_null("Inventario")
	var ws := root.get_node_or_null("WorldState")
	# 10 cadenas, una por cluster: principal / merge de ejemplos / vecinos /
	# lugares / familias / amistad / secretas / comerciantes / puzzles /
	# pesca-coleccion.
	var e2e := ["cadena-faro", "cadena-biblioteca", "cadena-panadera",
		"cadena-jardines", "cadena-molinera", "cadena-regalo-favorito",
		"cadena-mapa-secreto", "cadena-ruta-del-mercader",
		"cadena-templo-de-las-24-marcas", "cadena-pesca-nocturna"]
	var distintos := {}
	for cid in e2e:
		distintos[cid] = true
	_check(e2e.size() == 10 and distintos.size() == 10,
		"muestra E2E = 10 cadenas distintas (%d de %d)" % [distintos.size(), e2e.size()])
	# Cobertura de las dos rutas especiales del motor
	_check(_h.fuente_cadena("cadena-biblioteca") == "ejemplos",
		"la muestra incluye 1 cadena MERGEADA de cadenas_ejemplo.json (cadena-biblioteca)")
	_check(bool(_h.get_cadena("cadena-mapa-secreto").get("oculta", false)),
		"la muestra incluye 1 cadena OCULTA (cadena-mapa-secreto)")
	# Catalogo de M55 leido en disco: el puente de diario se mide contra el
	# dato y no contra una cifra fija.
	var ids_m55 := {}
	var cat_raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/diario/diario_catalog.json"))
	if typeof(cat_raw) == TYPE_DICTIONARY:
		for cat in (cat_raw as Dictionary).get("categorias", []):
			for entrada in (cat as Dictionary).get("entradas", []):
				ids_m55[String((entrada as Dictionary).get("id", ""))] = true
	# (a) apagar los flags ANTES: el check posterior prueba la aplicacion
	for cid in e2e:
		for flag in (_h.get_cadena(cid).get("consecuencia", {}) as Dictionary):
			if ws != null:
				ws.set_flag(String(flag), false)
	var diary := root.get_node_or_null("Diary")
	var pasos_totales := 0
	var pasos_ok := 0
	var fuera_esquema := []
	for cid in e2e:
		var c: Dictionary = _h.get_cadena(cid)
		_check(not c.is_empty(), "%s cargada en el catalogo" % cid)
		if c.is_empty():
			continue
		var oculta := bool(c.get("oculta", false))
		_check(_h.cadenas_disponibles().has(cid) != oculta,
			"%s visibilidad previa coherente (oculta=%s)" % [cid, str(oculta)])
		var res: Dictionary = _h.iniciar_cadena(cid)
		_check(bool(res.ok), "%s iniciar OK" % cid)
		# Driver generico: la evidencia sale del propio paso declarado
		var pasos: Array = c.get("pasos", [])
		var ok_cadena := 0
		for p in pasos:
			var paso: Dictionary = p
			var tipo := String(paso.get("tipo", ""))
			if tipo == "entregar":
				var objeto := String(paso.get("objeto", ""))
				if inv != null:
					var lote := {}
					lote[objeto] = 1
					inv.agregar_items(lote)
				res = _h.reportar_entrega(cid)
			else:
				var evidencia := String(paso.get("npc", paso.get("lugar", paso.get("ref", ""))))
				res = _h.reportar_paso(cid, tipo, evidencia)
			if bool(res.ok):
				ok_cadena += 1
			else:
				print("[E2E] %s paso %s (%s): %s" % [cid, String(paso.get("id", "?")), tipo, String(res.get("motivo", ""))])
		pasos_totales += pasos.size()
		pasos_ok += ok_cadena
		_check(ok_cadena == pasos.size(), "%s: %d/%d pasos en el orden declarado" % [cid, ok_cadena, pasos.size()])
		_check(_h.esta_completada(cid), "%s completada end-to-end" % cid)
		_check(not _h.esta_activa(cid), "%s deja de estar activa al completar" % cid)
		var cons: Dictionary = c.get("consecuencia", {})
		var aplicadas := 0
		for flag in cons:
			if ws_has(String(flag)):
				aplicadas += 1
		_check(cons.size() > 0 and aplicadas == cons.size(),
			"%s aplica sus %d consecuencias en M21 (%d)" % [cid, cons.size(), aplicadas])
		_check(not _h.cadenas_disponibles().has(cid), "%s sale de cadenas_disponibles al completar" % cid)
		var res2: Dictionary = _h.iniciar_cadena(cid)
		_check(not bool(res2.ok), "%s no se re-inicia completada (recompensa unica)" % cid)
		var capitulo := String((c.get("recompensa", {}) as Dictionary).get("diario", ""))
		_check(capitulo != "", "%s declara capitulo de diario (%s)" % [cid, capitulo])
		if capitulo != "" and capitulo != "mision_" + cid:
			fuera_esquema.append("%s=%s" % [cid, capitulo])
		if diary != null and capitulo != "":
			_check(diary.esta_registrada(capitulo) == ids_m55.has(capitulo),
				"%s puente de diario coherente con el catalogo M55 (registrada=%s, en_catalogo=%s)"
					% [cid, str(diary.esta_registrada(capitulo)), str(ids_m55.has(capitulo))])
	_check(pasos_ok == pasos_totales, "los %d pasos de las 10 cadenas avanzaron (%d)" % [pasos_totales, pasos_ok])
	# Hallazgo medido: la cadena MERGEADA quedo fuera de la normalizacion
	# mision_<id> de la iter. 21 (esa tanda toco solo secundarias.json). El
	# check fija la excepcion para que un cambio silencioso del dato falle.
	_check(fuera_esquema.size() == 1 and fuera_esquema[0] == "cadena-biblioteca=capitulo-biblioteca",
		"9 de 10 capitulos siguen mision_<id>; la mergeada es la excepcion medida (%s)" % str(fuera_esquema))
	# Persistencia E2E: save -> vacio -> restore
	var data: Dictionary = _h.get_save_data()
	var completadas: Array = data.get("completadas", [])
	var en_save := 0
	for cid in e2e:
		if completadas.has(cid):
			en_save += 1
	_check(en_save == 10, "las 10 completadas figuran en get_save_data (%d)" % en_save)
	_h.restore_save_data({})
	var tras_vacio := 0
	for cid in e2e:
		if _h.esta_completada(cid):
			tras_vacio += 1
	_check(tras_vacio == 0, "restore vacio limpia las 10 (%d)" % tras_vacio)
	_h.restore_save_data(data)
	var tras_restore := 0
	for cid in e2e:
		if _h.esta_completada(cid):
			tras_restore += 1
	_check(tras_restore == 10, "round-trip restaura las 10 completadas (%d)" % tras_restore)
	_check(_h.validar_cadenas().is_empty(), "el catalogo sigue valido tras las 10 corridas E2E")
	# Higiene: dejar mundo y motor como estaban para cualquier bloque posterior
	for cid in e2e:
		for flag in (_h.get_cadena(cid).get("consecuencia", {}) as Dictionary):
			if ws != null:
				ws.set_flag(String(flag), false)
	_h.restore_save_data({})
	_fin("Z")


## Iter. 23 (2026-10-25, DeepSeek-V4.1-Flash, Log 2197): item L109 del
## 05-Checklist — "Crear la consecuencia 'taller abierto'", una de las 12 del
## 03-Diseno L53. Hasta la iter. 22 el flag taller_abierto tenia 0 respaldo en
## disco (0 cadenas lo aplicaban y 0 hits del token en res://data: el bloque S
## lo fijaba como GUARDA negativa). Esta iteracion crea cadena-taller con
## evidencia REAL: npc ramon_tejon (data/villagers/ramon_tejon.tres, herrero),
## lugar taller_viejo (ya declarado por cadena-llave p2) y objeto iron_ore
## (data/items/iron_ore.tres, "Hierro"), 4 pasos con los tipos del esquema.
## El bloque S invierte su guarda a POSITIVA sobre el mismo token.
func _test_consecuencia_taller() -> void:
	_h.restore_save_data({})
	var ws := root.get_node_or_null("WorldState")
	_check(ws != null, "WorldState presente (M21) para medir taller_abierto")
	var cid := "cadena-taller"
	var cad: Dictionary = _h.get_cadena(cid)
	_check(not cad.is_empty(), "%s cargada desde el catalogo" % cid)
	_check(_h.fuente_cadena(cid) == "secundarias", "%s viene del principal (no del merge)" % cid)
	_check(not bool(cad.get("oculta", false)), "%s NO es oculta (se descubre hablando)" % cid)
	_check(not bool(cad.get("postgame", false)), "%s NO es postgame" % cid)
	# Esquema: 4 pasos con tipos declarados y 1 sola consecuencia
	var pasos: Array = cad.get("pasos", [])
	_check(pasos.size() == 4, "%s declara 4 pasos: %d" % [cid, pasos.size()])
	var tipos_validos := ["hablar", "explorar", "puzzle", "entregar"]
	var tipos_ok := true
	for p in pasos:
		if not (String((p as Dictionary).get("tipo", "")) in tipos_validos):
			tipos_ok = false
	_check(tipos_ok, "los 4 pasos usan tipos del esquema (hablar/explorar/puzzle/entregar)")
	var cons: Dictionary = cad.get("consecuencia", {})
	_check(cons.size() == 1 and bool(cons.get("taller_abierto", false)),
		"%s aplica exactamente el flag taller_abierto: %s" % [cid, str(cons)])
	# NPC y objeto REALES por efecto (archivo en disco / campo id)
	_check(FileAccess.file_exists("res://data/villagers/ramon_tejon.tres"),
		"NPC REAL ramon_tejon existe en data/villagers/")
	var ids_items := _ids_items_reales()
	_check(ids_items.has("iron_ore"), "objeto REAL iron_ore existe en data/items/ (por campo id)")
	# Recompensa: capitulo con el esquema del puente y cosmetico propio (cozy)
	var rec: Dictionary = cad.get("recompensa", {})
	_check(String(rec.get("diario", "")) == "mision_" + cid,
		"recompensa.diario == mision_%s (esquema del puente): %s" % [cid, str(rec.get("diario", ""))])
	_check(String(rec.get("cosmetico", "")) != "", "recompensa.cosmetico declarado (cozy, sin stats)")
	# Visible en disponibles antes de iniciarse (no es oculta ni postgame)
	var expuesta := false
	for d in _h.cadenas_disponibles():
		if String(d) == cid:
			expuesta = true
	_check(expuesta, "%s figura en cadenas_disponibles() sin final elegido" % cid)
	# End-to-end por el camino real del servicio
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"iron_ore": 1})
	var res: Dictionary = _h.iniciar_cadena(cid)
	_check(bool(res.ok), "iniciar %s OK" % cid)
	res = _h.reportar_paso(cid, "hablar", "ramon_tejon")
	_check(bool(res.ok), "taller p1 hablar ramon_tejon OK")
	res = _h.reportar_paso(cid, "explorar", "taller_viejo")
	_check(bool(res.ok), "taller p2 explorar taller_viejo OK")
	res = _h.reportar_paso(cid, "puzzle", "fragua-apagada")
	_check(bool(res.ok), "taller p3 puzzle fragua-apagada OK")
	res = _h.reportar_entrega(cid)
	_check(bool(res.ok), "taller p4 entregar iron_ore OK (inventario)")
	_check(_h.esta_completada(cid), "%s completada end-to-end" % cid)
	_check(ws_has("taller_abierto"), "consecuencia taller_abierto aplicada a WorldState (M21)")
	# Puente diario M23->M55: el capitulo declarado NO existe en el catalogo de
	# M55 (finding de contenido, dueno M55) -> degrada en silencio, igual que
	# 78 de los 80. No se inventa contenido ajeno.
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(not diary.esta_registrada("mision_" + cid),
			"puente diario degrada sin entrada en catalogo M55 (finding medido, dueno M55)")
	# Higiene: dejar el mundo como estaba para cualquier bloque posterior
	if ws != null:
		ws.set_flag("taller_abierto", false)
	_h.restore_save_data({})
	_fin("AA")


## Bloque AB (iter. 24, Log 2202) — catalogo de cosmeticos + puente de la
## recompensa cosmetica. Mide el defecto que motivo la tanda: 77 cadenas
## declaran `recompensa.cosmetico` con un NOMBRE VISIBLE que no existia en
## ningun catalogo y que el puente no transportaba (`quest_updated(id,
## "cosmetico", 1)`, sin listener). Ahora: catalogo con id estable + senal
## `cosmetico_desbloqueado` + estado derivado de las completadas.
func _test_cosmeticos() -> void:
	var cat: RefCounted = _h.catalogo_cosmeticos()
	_check(cat != null, "AB catalogo de cosmeticos cargado (no null)")
	if cat == null:
		_fin("AB")
		return
	var total: int = int(cat.cantidad())
	var declarados: Array = _h.nombres_cosmeticos_declarados()
	# L99: "10+ cosmeticos" — el catalogo debe cubrir el minimo del diseno.
	_check(total >= 10, "AB catalogo con 10+ entradas (L99): %d" % total)
	_check(total == declarados.size(),
		"AB catalogo == nombres unicos declarados (%d vs %d)" % [total, declarados.size()])
	var errores: Array = _h.validar_cosmeticos()
	if not errores.is_empty():
		for e in errores:
			print("   AB error: %s" % String(e))
	_check(errores.is_empty(), "AB validar_cosmeticos() sin errores (0 de %d)" % errores.size())
	# Los 3 tipos que nombra 03-Diseno L62 + "casa" como contenedor del resto.
	var conteo: Dictionary = cat.conteo_por_tipo()
	_check(int(conteo.get("disfraz", 0)) >= 1, "AB tipo disfraz presente: %d" % int(conteo.get("disfraz", 0)))
	_check(int(conteo.get("sombrero", 0)) >= 1, "AB tipo sombrero presente: %d" % int(conteo.get("sombrero", 0)))
	_check(int(conteo.get("paleta", 0)) >= 1, "AB tipo paleta presente: %d" % int(conteo.get("paleta", 0)))
	_check(int(conteo.get("casa", 0)) >= 1, "AB tipo casa presente: %d" % int(conteo.get("casa", 0)))
	var suma := 0
	for t in conteo:
		suma += int(conteo[t])
	_check(suma == total, "AB suma por tipo == total del catalogo (%d vs %d)" % [suma, total])
	# Invariantes por entrada (id con prefijo, solo visual, sin stats).
	var ids_ok := true
	var visual_ok := true
	var stats_ok := true
	for c in cat.todos():
		var d: Dictionary = c
		if not String(d.get("id", "")).begins_with("cosm-"):
			ids_ok = false
		if not bool(d.get("solo_visual", false)):
			visual_ok = false
		if bool(d.get("afecta_stats", true)):
			stats_ok = false
	_check(ids_ok, "AB todos los ids con prefijo cosm-")
	_check(visual_ok, "AB todos solo_visual = true (03-Diseno L62)")
	_check(stats_ok, "AB ninguno afecta stats (vision cozy)")
	# Identidad: nombre visible declarado -> id estable del catalogo.
	_check(String(_h.cosmetico_de("cadena-faro")) == "cosm-farol-de-atardecer",
		"AB cosmetico_de(cadena-faro) == cosm-farol-de-atardecer: %s" % String(_h.cosmetico_de("cadena-faro")))
	var info: Dictionary = _h.cosmetico_info("cadena-faro")
	_check(String(info.get("nombre", "")) == "farol de atardecer",
		"AB info.nombre == 'farol de atardecer': %s" % String(info.get("nombre", "")))
	_check(String(info.get("tipo", "")) == "casa",
		"AB info.tipo == casa: %s" % String(info.get("tipo", "")))
	_check(String(_h.cosmetico_de("cadena-epilogo-plaza")) == "",
		"AB cadena sin cosmetico declarado -> id vacio")
	_check(String(cat.id_de_nombre("cosmetico inexistente")) == "",
		"AB nombre no catalogado -> id vacio (no inventa)")
	# Cobertura: NINGUNA entrada del catalogo queda ilegible por id.
	var sin_resolver: Array = []
	var ids: Array = cat.ids()
	for i in ids.size():
		var ficha: Dictionary = cat.obtener(String(ids[i]))
		if ficha.is_empty():
			sin_resolver.append(String(ids[i]))
	_check(sin_resolver.is_empty(), "AB todas las entradas del catalogo se leen por id: %d" % sin_resolver.size())
	# Colision de contenido DOCUMENTADA: 2 cadenas declaran "sello de cera".
	var a := String(_h.cosmetico_de("cadena-cartas-amistad"))
	var b := String(_h.cosmetico_de("cadena-coleccion-sellos"))
	_check(a != "" and a == b,
		"AB 'sello de cera' resuelve al MISMO id en las 2 cadenas: %s / %s" % [a, b])
	var ficha_sello: Dictionary = cat.obtener(a)
	var origen: Array = ficha_sello.get("origen", [])
	_check(origen.has("cadena-cartas-amistad") and origen.has("cadena-coleccion-sellos"),
		"AB la ficha de 'sello de cera' declara las 2 cadenas de origen: %s" % str(origen))
	# Discriminacion del cruce: un detector que nunca ve nada dice lo mismo que
	# uno limpio -> control positivo + control negativo, medidos.
	_check(cat.faltantes(["farol de atardecer"]).is_empty(),
		"AB faltantes() control positivo: un nombre catalogado NO falta")
	_check(cat.faltantes(["no existe"]).size() == 1,
		"AB faltantes() discrimina: un nombre inventado SI falta")
	_check(cat.huerfanos(declarados).is_empty(),
		"AB huerfanos(declarados) vacio: 0 entradas sin cadena que las declare")
	_check(cat.huerfanos(["farol de atardecer"]).size() == total - 1,
		"AB huerfanos() discrimina: con 1 solo declarado, %d quedan huerfanos" % (total - 1))
	# Runtime: completar una cadena REAL desbloquea su cosmetico y emite el id.
	_check(_h.has_signal("cosmetico_desbloqueado"),
		"AB el servicio declara la senal cosmetico_desbloqueado")
	var previos: Array = _h.cosmeticos_desbloqueados()
	_check(previos.is_empty(), "AB sin cadenas completadas no hay cosmeticos: %d" % previos.size())
	_cosm_eventos.clear()
	var ya_conectado := _h.is_connected("cosmetico_desbloqueado", Callable(self, "_on_cosmetico"))
	if not ya_conectado:
		_h.connect("cosmetico_desbloqueado", Callable(self, "_on_cosmetico"))
	var cid := "cadena-taller"
	var inv := root.get_node_or_null("Inventario")
	if inv != null:
		inv.agregar_items({"iron_ore": 1})
	var res: Dictionary = _h.iniciar_cadena(cid)
	_check(bool(res.ok), "AB iniciar %s OK" % cid)
	res = _h.reportar_paso(cid, "hablar", "ramon_tejon")
	res = _h.reportar_paso(cid, "explorar", "taller_viejo")
	res = _h.reportar_paso(cid, "puzzle", "fragua-apagada")
	res = _h.reportar_entrega(cid)
	_check(_h.esta_completada(cid), "AB %s completada end-to-end (camino real)" % cid)
	_check(_cosm_eventos.size() == 1,
		"AB 1 evento cosmetico_desbloqueado al completar: %d" % _cosm_eventos.size())
	if _cosm_eventos.size() == 1:
		var ev: Dictionary = _cosm_eventos[0]
		_check(String(ev.get("cadena", "")) == cid,
			"AB evento.cadena == %s: %s" % [cid, String(ev.get("cadena", ""))])
		_check(String(ev.get("cosmetico", "")) == "cosm-delantal-de-herrero",
			"AB evento.cosmetico == cosm-delantal-de-herrero: %s" % String(ev.get("cosmetico", "")))
	var desbloqueados: Array = _h.cosmeticos_desbloqueados()
	_check(desbloqueados.has("cosm-delantal-de-herrero"),
		"AB cosmeticos_desbloqueados() incluye el de la cadena completada: %s" % str(desbloqueados))
	# Higiene: desconectar y dejar el estado como estaba.
	if _h.is_connected("cosmetico_desbloqueado", Callable(self, "_on_cosmetico")):
		_h.disconnect("cosmetico_desbloqueado", Callable(self, "_on_cosmetico"))
	var ws := root.get_node_or_null("WorldState")
	if ws != null:
		ws.set_flag("taller_abierto", false)
	_h.restore_save_data({})
	_fin("AB")


func _on_cosmetico(cadena_id: String, cosmetico_id: String) -> void:
	_cosm_eventos.append({"cadena": cadena_id, "cosmetico": cosmetico_id})


## Busca un token literal en un arbol (.json/.tres) y devuelve las rutas que lo
## contienen. Alcance DECLARADO por quien llama: por defecto res://data (datos
## del juego). No camina docs/, herramientas ni worktrees a proposito.
func _token_en_arbol(token: String, raiz: String = "res://data") -> Array:
	var hits := []
	_scan_token(DirAccess.open(raiz), raiz, token, hits)
	return hits


func _scan_token(dir: DirAccess, ruta: String, token: String, hits: Array) -> void:
	if dir == null:
		return
	for sub in dir.get_directories():
		_scan_token(DirAccess.open(ruta + "/" + sub), ruta + "/" + sub, token, hits)
	for fn in dir.get_files():
		if not (fn.ends_with(".json") or fn.ends_with(".tres")):
			continue
		var f := FileAccess.open(ruta + "/" + fn, FileAccess.READ)
		if f == null:
			continue
		var texto := f.get_as_text()
		f.close()
		if texto.find(token) != -1:
			hits.append(ruta + "/" + fn)
