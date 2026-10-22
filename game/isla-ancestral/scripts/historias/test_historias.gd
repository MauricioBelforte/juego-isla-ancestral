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

extends SceneTree

const MODULO := "M23"
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]

var _fallos: int = 0
var _checks: int = 0
var _h: Node = null
var _bus: Node = null
var _vistos: Dictionary = {}

# Piso MEDIDO en verde (iter. 5, 2026-10-22): 98 checks con los bloques A-J
# (iter. 4 tenía 70 con A-I; el bloque J de las 6 historias de vecinos sumó 28).
# Medido: 98/0/EXIT 0. El guardián se probó EN ROJO por inyección de runtime
# sobre el bloque J (ver Log 2107).
const CHECKS_MINIMOS := 98

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
	_check(_h.cadenas_count() == 11, "11 cadenas cargadas tras el merge (10 principal + 1 ejemplos): %d" % _h.cadenas_count())
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
	_check(principal.size() == 10, "catálogo principal con 10 cadenas (crudo, 4 + 6 vecinos): %d" % principal.size())
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
	_check(cargadas == 11, "11 cadenas cargadas en runtime (10 principal + biblioteca): %d" % cargadas)
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
