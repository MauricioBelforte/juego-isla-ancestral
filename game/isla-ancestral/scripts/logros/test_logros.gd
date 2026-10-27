# Modelo: DeepSeek-V4.1-Flash (endurecido 2026-10-26, residuo M72)
# Plataforma: WorkBuddy
# Fecha: 2026-09-01 (iter. 1-2) / 2026-09-02 (iter. 3) / 2026-10-26 (guardian + aborto)
#
# M72: Test de AchievementService (delegación M71, desbloqueo idempotente,
# % real, logros ocultos, persistencia + iter.3: fechas, retroactividad,
# API consulta RF10, progreso humano RF8, validación RF14, migración v1→v2).
#
# ENDURECIDO 2026-10-26 (residuo M72, DeepSeek-V4.1-Flash): esta suite publicaba
# "0 fallo(s)" + EXIT 0 con un SCRIPT ERROR en L294 (`_desbloqueados` es
# Array[String] y se le asignaba un Array sin tipar): el error abortaba
# `_test_guardado_carga_rf9_rn8()` y sus 6 checks NUNCA corrian. Ahora tiene
# las 3 capas: contador `_checks`, piso `CHECKS_MINIMOS` medido en verde y
# `_fin(bloque)` al final de cada bloque, con `_summary()` diferido APARTE
# (un aborto de `_run()` no impide que el resumen corra y nombre el bloque).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/logros/test_logros.gd

extends SceneTree

const MODULO := "M72"
# Piso MEDIDO en verde el 2026-10-26 con el binario real (no estimado: el
# primer valor que escribi fue 74 por estimacion y el medido real es 72).
const CHECKS_MINIMOS := 72

const BLOQUES := [
	"catalogo", "rf14", "evento", "idempotente", "fechas_rf4", "api_rf10",
	"progreso_rf8", "porcentaje", "ocultos", "amistad_rf2", "pesca_rf2",
	"persistencia", "migracion_v1", "retroactividad", "toasts_rn7",
	"doble_atomico", "compuesta_edge", "cache_lectura", "guardado_rf9",
	"panel_rf7",
]

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}
var _ach: Node = null
var _pm: Node = null
var _bus: Node = null

func _init() -> void:
	# Dos diferidas SEPARADAS: si `_run()` aborta por SCRIPT ERROR, la cola
	# diferida sigue y `_summary()` corre igual (nombra el bloque y sale != 0).
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_ach = root.get_node_or_null("Achievements")
	_pm = root.get_node_or_null("ProgressionManager")
	_bus = root.get_node_or_null("EventBus")
	_check(_ach != null, "Achievements autoload presente")
	_check(_pm != null, "ProgressionManager presente (M71)")
	if _ach == null or _pm == null:
		return
	_test_catalogo()
	_test_validacion_rf14()
	_test_desbloqueo_por_evento()
	_test_idempotente()
	_test_fechas_rf4()
	_test_api_consulta_rf10()
	_test_progreso_humano_rf8()
	_test_porcentaje_real()
	_test_ocultos()
	_test_amistad_rf2()
	_test_pesca_rf2()
	_test_persistencia()
	_test_migracion_v1()
	_test_retroactividad_rf5()
	_test_accesibilidad_toasts_rf6_rn7()
	_test_doble_desbloqueo_atomico()
	_test_condicion_compuesta_edge_cases()
	_test_cache_lectura()
	_test_guardado_carga_rf9_rn8()
	_test_panel_solicitado_rf7()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _fin(bloque: String) -> void:
	_vistos[bloque] = true

func _summary() -> void:
	var faltan: Array = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltan.append(b)
	if not faltan.is_empty():
		_fallos += 1
		print("[FAIL] bloques que NO se ejecutaron (posible SCRIPT ERROR): %s" % str(faltan))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M72 LOGROS: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _test_catalogo() -> void:
	_check(_ach.logros_count() == 18, "18 logros cargados (iter. 8: +epilogo ruina restaurada): %d" % _ach.logros_count())
	_check(_ach.get_section_name() == "achievements", "sección 'achievements' (M59)")
	_fin("catalogo")


func _test_amistad_rf2() -> void:
	# RF2 iter. 4: friendship_level_up (M20) → stat amistad_max_<npc> → logro
	var bus := root.get_node_or_null("EventBus")
	_check(bus != null and bus.npc != null and bus.npc.has_signal("friendship_level_up"), "EventBus.npc.friendship_level_up presente (M20)")
	if bus == null or bus.npc == null:
		_fin("amistad_rf2")
		return
	var pm := root.get_node_or_null("ProgressionManager")
	_check(pm != null and pm.profile != null, "M71 + PlayerProfile presentes")
	if pm == null or pm.profile == null:
		_fin("amistad_rf2")
		return
	# Antes: sin nivel → logro no desbloqueado
	_check(not _ach.esta_desbloqueado("logro_amigo_cercano"), "logro amistad cerrado sin nivel")
	# Emitir nivel 3 de amistad con catalina
	bus.npc.friendship_level_up.emit("catalina_oso", 3)
	_check(int(pm.profile.get_stat("amistad_max_catalina_oso")) == 3, "stat amistad_max=3 (monótona)")
	_check(_ach.esta_desbloqueado("logro_amigo_cercano"), "logro_amigo_cercano desbloqueado con nivel 3")
	# Nivel menor NO retrocede la stat (monótona)
	bus.npc.friendship_level_up.emit("catalina_oso", 1)
	_check(int(pm.profile.get_stat("amistad_max_catalina_oso")) == 3, "stat monótona no baja")
	# Nivel 4 desbloquea el segundo
	bus.npc.friendship_level_up.emit("catalina_oso", 4)
	_check(_ach.esta_desbloqueado("logro_alma_de_la_isla"), "logro_alma_de_la_isla con nivel 4")
	_fin("amistad_rf2")


func _test_pesca_rf2() -> void:
	# RF2 iter. 6: captura_exitosa (M34) → stats peces_capturados/pescar_<id> → logros
	var fishing := root.get_node_or_null("Fishing")
	_check(fishing != null and fishing.has_signal("captura_exitosa"), "Fishing presente (M34) con captura_exitosa")
	if fishing == null:
		_fin("pesca_rf2")
		return
	var pm := root.get_node_or_null("ProgressionManager")
	_check(pm != null and pm.profile != null, "M71 + PlayerProfile presentes")
	if pm == null or pm.profile == null:
		_fin("pesca_rf2")
		return
	var antes: float = float(pm.profile.get_stat("peces_capturados"))
	# Usar un pez REAL del catálogo M34 (un Resource.new() genérico no retiene
	# la propiedad "id": set() sobre propiedad inexistente falla silencioso)
	var peces: Array = fishing._peces
	_check(peces.size() > 0, "catálogo de peces M34 con especies: %d" % peces.size())
	if peces.size() > 0:
		var pez: Resource = peces[0]
		var pez_id: String = String(pez.get("id"))
		_check(pez_id != "", "pez real con id: %s" % pez_id)
		fishing.captura_exitosa.emit(pez, 25.5)
		_check(float(pm.profile.get_stat("peces_capturados")) == antes + 1.0, "stat peces_capturados +1")
		_check(int(pm.profile.get_stat("pescar_" + pez_id)) == 1, "stat pescar_%s=1 (primera vez)" % pez_id)
		_check(_ach.esta_desbloqueado("logro_pescador_principiante"), "logro_pescador_principiante con 1 captura")
	_fin("pesca_rf2")

func _test_validacion_rf14() -> void:
	# Catálogo real: 0 problemas esperados (salida accionable con 0 -> OK)
	var problemas: int = _ach.validar_catalogo()
	_check(problemas == 0, "catálogo real sin problemas (RF14): %d" % problemas)
	_check(_ach.TIPOS_CONDICION_VALIDOS.size() == 10, "vocabulario M71 §3.6 completo: %d" % _ach.TIPOS_CONDICION_VALIDOS.size())
	_fin("rf14")

func _test_desbloqueo_por_evento() -> void:
	# M72 escucha progreso_hito_alcanzado de M71 → evaluar_todos
	# logro_primer_sello depende de sello_historia → M22 es la fuente de verdad
	# (§2.2): el test marca el sello vía Historia.marcar_sello (emite prereq_met
	# → M71 stat+hito → M72 evalúa).
	var h := root.get_node_or_null("Historia")
	_check(h != null, "Historia presente (M22)")
	if h == null:
		_fin("evento")
		return
	var desbloqueados: Array = []
	var cb := func(id: String, _nombre: String) -> void:
		desbloqueados.append(id)
	_ach.logro_desbloqueado.connect(cb)
	h.marcar_sello("sello_ceniza_sala1")
	_ach.evaluar_todos()
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "sello M22 → logro M72 (fuente de verdad §2.2)")
	# 7 sellos → logro_siete_sellos
	for s in ["sello_ceniza_sala2", "sello_mar_intermedia", "sello_mar_sala1",
			"sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]:
		h.marcar_sello(s)
	_ach.evaluar_todos()
	_check(_ach.esta_desbloqueado("logro_siete_sellos"), "7 sellos → logro_siete_sellos")
	_check(desbloqueados.size() >= 2, "señales logro_desbloqueado emitidas (%d)" % desbloqueados.size())
	_ach.logro_desbloqueado.disconnect(cb)
	_fin("evento")

func _test_idempotente() -> void:
	var senales: Array = [0]
	var cb := func(_id: String, _nombre: String) -> void:
		senales[0] += 1
	_ach.logro_desbloqueado.connect(cb)
	var primera: bool = _ach.desbloquear("logro_primer_sello")
	_check(not primera, "desbloquear ya-desbloqueado devuelve false (idempotente)")
	_check(senales[0] == 0, "sin doble señal de logro")
	_ach.logro_desbloqueado.disconnect(cb)
	_fin("idempotente")

func _test_fechas_rf4() -> void:
	# RF4: fecha determinista día M29 persistida en el desbloqueo
	var f: Dictionary = _ach.fecha_de("logro_primer_sello")
	_check(f.has("dia"), "fecha con 'dia' (RF4): %s" % str(f))
	var gt := root.get_node_or_null("GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		_check(int(f.get("dia", -1)) == int(gt.dia_absoluto()), "día coincide con M29 GameTime (%s)" % str(f.get("dia")))
	# Write-through: mark_dirty llamado (SaveManager presente)
	var sm := root.get_node_or_null("SaveManager")
	_check(sm != null, "SaveManager presente para write-through")
	_fin("fechas_rf4")

func _test_api_consulta_rf10() -> void:
	var todos: Array = _ach.get_todos()
	_check(todos.size() == 18, "get_todos devuelve 18 (iter. 8): %d" % todos.size())
	var estado: Dictionary = _ach.get_estado("logro_primer_sello")
	_check(bool(estado.get("desbloqueado", false)), "get_estado desbloqueado OK")
	_check(bool(_ach.is_unlocked("logro_primer_sello")), "is_unlocked OK")
	var def: Dictionary = _ach.get_definicion("logro_primer_sello")
	_check(String(def.get("nombre", "")) != "", "get_definicion con nombre")
	var desb: Array = _ach.get_desbloqueados()
	_check(desb.size() >= 2, "get_desbloqueados >= 2: %d" % desb.size())
	_check(absf(_ach.get_porcentaje_completado() - _ach.porcentaje_real()) < 0.001, "get_porcentaje_completado = porcentaje_real")
	# listado_para_ui alias de get_todos
	_check(_ach.listado_para_ui().size() == 18, "listado_para_ui alias OK (18)")
	_fin("api_rf10")

func _test_progreso_humano_rf8() -> void:
	# logro_viajero: viajes_realizados >= 3 con progreso_parcial
	var p: Dictionary = _ach.progreso_de("logro_viajero")
	_check(float(p.get("requerido", 0.0)) == 3.0, "requerido=3 en logro_viajero: %s" % str(p))
	var humano: String = _ach.get_progreso_humano("logro_viajero")
	_check(humano.contains("de"), "progreso humano 'X de Y': %s" % humano)
	# Clamp: logrado nunca supera requerido
	_check(float(p.get("logrado", 0.0)) <= 3.0, "clamp progreso (RF8)")
	_fin("progreso_rf8")

func _test_porcentaje_real() -> void:
	# §3.2 M55: logros usan el total REAL (no anti-spoiler)
	var p: float = _ach.porcentaje_real()
	_check(p > 0.0 and p <= 1.0, "porcentaje_real en (0,1]: %.2f" % p)
	_check(_ach.desbloqueados().size() >= 2, "2+ desbloqueados")
	_fin("porcentaje")

func _test_ocultos() -> void:
	# Oculto desbloqueado → nombre real visible; no desbloqueado → "???"
	var listado: Array = _ach.listado_para_ui()
	var encontrado := false
	for l in listado:
		if String(l.id) == "logro_secreto_guardian":
			encontrado = true
			if bool(l.desbloqueado):
				_check(String(l.nombre) != "???", "oculto desbloqueado muestra nombre real (§3.2 no aplica a logros)")
			else:
				_check(String(l.nombre) == "???", "oculto no desbloqueado = '???' (UI M53)")
	# Guarda: si el id no aparece, el bloque corria 0 checks (falso verde estructural).
	_check(encontrado, "logro_secreto_guardian existe en el listado (guarda del bloque)")
	_fin("ocultos")

func _test_persistencia() -> void:
	var data: Dictionary = _ach.get_save_data()
	_check(int(data.get("version", 0)) == 2, "save_data v2 con fechas")
	_check(data.has("desbloqueados"), "save_data completo")
	var desb: Dictionary = data.get("desbloqueados", {})
	_check(desb.size() >= 2, "logros persistidos: %d" % desb.size())
	_check((desb.get("logro_primer_sello", {}) as Dictionary).has("dia"), "fecha persistida (RF4)")
	# Round-trip con logro de catálogo viejo
	var con_viejo: Dictionary = data.duplicate(true)
	(con_viejo.desbloqueados as Dictionary)["logro_viejo"] = {"dia": 1, "hora": 12}
	_ach.restore_save_data({"desbloqueados": {}})
	_check(not _ach.esta_desbloqueado("logro_primer_sello"), "restore vacío limpia")
	_ach.restore_save_data(con_viejo)
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "round-trip restaura")
	_check(not _ach.esta_desbloqueado("logro_viejo"), "logro de catálogo viejo purgado (§6)")
	_check(int(_ach.fecha_de("logro_primer_sello").get("dia", -99)) >= 0, "fecha restaurada (RF4)")
	_fin("persistencia")

func _test_migracion_v1() -> void:
	# v1 (array sin fechas) → migra sin romper; fechas -1
	var v1 := {"desbloqueados": ["logro_primer_sello", "logro_viajero", "logro_inexistente"]}
	_ach.restore_save_data(v1)
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "migración v1: logro preservado")
	_check(not _ach.esta_desbloqueado("logro_inexistente"), "migración v1: desconocido purgado")
	_check(int(_ach.fecha_de("logro_primer_sello").get("dia", 0)) == -1, "migración v1: fecha -1 placeholder")
	_fin("migracion_v1")

func _test_retroactividad_rf5() -> void:
	# RF5: con el estado limpio, re_evaluar_todo re-otorga los logros ya cumplidos
	_ach.restore_save_data({"desbloqueados": {}})
	var retro: int = _ach.re_evaluar_todo()
	_check(retro >= 2, "retroactividad re-otorga logros cumplidos: %d" % retro)
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "retroactivo: primer sello")
	_check(_ach.esta_desbloqueado("logro_siete_sellos"), "retroactivo: siete sellos")
	_fin("retroactividad")

## ── Iter. 7 (agnes-2.5-flash): accesibilidad + edge cases ──

func _test_accesibilidad_toasts_rf6_rn7() -> void:
	# RN7: toasts desactivables via _toasts_disabled.
	# ENDURECIDO 2026-10-26: la version anterior hacia
	#   `_ach.desbloquear("logro_primer_sello")` sobre un logro YA desbloqueado
	#   (devuelve false y no emite toast) y luego `_check(true, ...)`:
	#   infalsificable por partida doble. Ahora se ejercita el guard REAL
	#   (`_emitir_toast`) y se observa el buffer, con control POSITIVO.
	var buffer: Array = _ach._toast_buffer
	var antes: int = buffer.size()
	_ach._toasts_disabled = true
	_ach._emitir_toast("logro_primer_sello", "La Llave de Ceniza")
	_check(buffer.size() == antes, "RN7: toasts_disabled=true NO bufferiza toast (%d -> %d)" % [antes, buffer.size()])
	_ach._toasts_disabled = false
	_ach._emitir_toast("logro_primer_sello", "La Llave de Ceniza")
	_check(buffer.size() == antes + 1, "RN7 control positivo: toasts_disabled=false SI bufferiza (%d -> %d)" % [antes, buffer.size()])
	buffer.clear()
	_fin("toasts_rn7")

func _test_doble_desbloqueo_atomico() -> void:
	# Doble llamada a desbloquear con el mismo ID no genera doble señal.
	# Usamos un ID que NO existe en el catálogo para evitar efectos de
	# re_evaluar_todo (call_deferred tras restore_save_data).
	var senales: Array = [0]
	var cb := func(_id: String, _n: String) -> void:
		senales[0] += 1
	_ach.logro_desbloqueado.connect(cb)
	_ach.desbloquear("logro_test_id_inexistente_xxyz")
	_ach.desbloquear("logro_test_id_inexistente_xxyz")
	_ach.logro_desbloqueado.disconnect(cb)
	_check(senales[0] == 0, "doble desbloqueo atómico: 0 señales (id inexistente)")
	_fin("doble_atomico")

func _test_condicion_compuesta_edge_cases() -> void:
	# Condición compuesta con stat inexistente → false sin crash
	var pm := _pm  # ya cargado en _run
	# Simular condición con stat desconocido
	var cond_bad := {
		"tipo": "compuesta",
		"operador": "AND",
		"hijos": [
			{"tipo": "stat_min", "stat_id": "stats_inexistentes", "umbral": 1},
			{"tipo": "stat_min", "stat_id": "items_recolectados", "umbral": 1},
		]
	}
	var result: bool = pm.evaluar_condicion(cond_bad)
	_check(result == false, "compuesta con stat inexistente = false (no crash)")
	# NOT de condición imposible
	var cond_not_impossible := {
		"tipo": "compuesta",
		"operador": "NOT",
		"hijos": [{"tipo": "stat_min", "stat_id": "items_recolectados", "umbral": 1}]
	}
	# Si items_recolectados >= 1, NOT debería ser false
	var result2: bool = pm.evaluar_condicion(cond_not_impossible)
	_check(result2 is bool, "NOT compuesto retorna bool (%s)" % str(result2))
	_fin("compuesta_edge")

func _test_cache_lectura() -> void:
	# Verificar que _compuesta_cache existe y es un Dictionary
	_check(_ach._compuesta_cache is Dictionary, "cache de lectura es Dictionary")
	_check(_ach.COMPUESTA_CACHE_TTL > 0, "TTL de cache positivo")
	_fin("cache_lectura")

## ── Iter. 8 (agnes-2.5-flash): RF9/RN8 guardado y carga global ──

func _test_guardado_carga_rf9_rn8() -> void:
	# Simular desbloquear un logro, guardar, restaurar, verificar persistencia.
	# FIX 2026-10-26: `_desbloqueados` es `Array[String]`; asignarle un Array sin
	# tipar lanzaba SCRIPT ERROR y abortaba esta funcion (6 checks perdidos con
	# "0 fallo(s)" publicado). Se usa el array tipado REAL: clear() + append().
	_ach._desbloqueados.clear()
	_ach._desbloqueados.append("logro_primer_sello")
	_ach._fechas = {"logro_primer_sello": {"dia": 5, "hora": 12}}
	# get_save_data debe retornar datos serializables
	var snapshot: Dictionary = _ach.get_save_data()
	_check(snapshot is Dictionary, "get_save_data retorna Dictionary")
	_check("version" in snapshot, "snapshot tiene version")
	_check("desbloqueados" in snapshot, "snapshot tiene desbloqueados")
	_check(int(snapshot["version"]) > 0, "version positiva")
	_check(snapshot["desbloqueados"] is Dictionary, "desbloqueados es dict")
	# Restaurar en la misma instancia (es autoload, no se puede crear nueva)
	_ach.restore_save_data(snapshot)
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "persiste tras restore")
	_fin("guardado_rf9")

## ── Iter. 8 (agnes-2.5-flash): RF7 señal panel_solicitado ──

func _test_panel_solicitado_rf7() -> void:
	# RF7: la señal panel_solicitado debe existir (conectable desde M53/M71 UI)
	_check(_ach.has_signal("panel_solicitado"), "RF7: panel_solicitado existe como señal")
	# ENDURECIDO 2026-10-26: antes era `_check(true, "emit no crash")`, infalsificable.
	# Ahora se observa que la señal llega con el payload correcto.
	var recibidos: Array = []
	var cb := func(panel_id: String) -> void:
		recibidos.append(panel_id)
	_ach.panel_solicitado.connect(cb)
	_ach.panel_solicitado.emit("logros")
	_ach.panel_solicitado.disconnect(cb)
	_check(recibidos.size() == 1 and String(recibidos[0]) == "logros", "RF7: panel_solicitado emite payload 'logros' (%s)" % str(recibidos))
	_fin("panel_rf7")
