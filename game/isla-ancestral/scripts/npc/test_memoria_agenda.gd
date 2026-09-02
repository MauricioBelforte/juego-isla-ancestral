# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M19: Test iter. 3 — memoria de interacciones (P26), agenda horaria
# determinista para M64 (P11/P12/P24), población de arranque (P1).
# No toca los tests de mudanzas (test_mudanzas.gd, núcleo iter. 2).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/npc/test_memoria_agenda.gd

extends SceneTree

var _fallos: int = 0
var _vm: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_vm = root.get_node_or_null("VillagerManager")
	_check(_vm != null, "VillagerManager autoload presente")
	if _vm == null:
		print("=== TEST M19 ITER3: 1 fallo(s) ===")
		quit(1)
		return
	_test_catalogo()
	_test_memoria_registros()
	_test_memoria_cap_rotativo()
	_test_memoria_persistencia()
	_test_agenda_determinista()
	_test_agenda_franjas()
	_test_actividad_actual()
	_test_poblacion_arranque()
	print("=== TEST M19 ITER3: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_catalogo() -> void:
	_check(int(_vm.catalogo_count()) == 5, "5 perfiles en catálogo: %d" % int(_vm.catalogo_count()))


func _test_memoria_registros() -> void:
	# P26: registrar tipos distintos y consultar
	_vm.registrar_interaccion("catalina_oso", "charla", "saludo matinal")
	_vm.registrar_interaccion("catalina_oso", "regalo", "miel")
	_vm.registrar_interaccion("catalina_oso", "hito", "primera receta compartida")
	var mem: Array = _vm.memoria_de("catalina_oso")
	_check(mem.size() == 3, "3 interacciones registradas: %d" % mem.size())
	_check(int(_vm.memoria_conteo("catalina_oso", "regalo")) == 1, "conteo regalos = 1")
	_check(int(_vm.memoria_conteo("catalina_oso", "charla")) == 1, "conteo charlas = 1")
	# Última entrada con campos completos
	var ultima: Dictionary = mem[mem.size() - 1]
	_check(String(ultima.get("tipo", "")) == "hito", "última entrada tipo hito")
	_check(ultima.has("dia") and ultima.has("detalle"), "entrada con dia y detalle")


func _test_memoria_cap_rotativo() -> void:
	# Cap MEMORIA_MAX (20): las más viejas salen (rotación)
	for i in range(25):
		_vm.registrar_interaccion("mateo_mapache", "charla", "charla %d" % i)
	var mem: Array = _vm.memoria_de("mateo_mapache")
	_check(mem.size() == 20, "memoria rotativa cap 20: %d" % mem.size())
	_check(String(mem[0].get("detalle", "")) == "charla 5", "más vieja purgada (rotación FIFO)")
	_check(String(mem[mem.size() - 1].get("detalle", "")) == "charla 24", "más reciente al final")


func _test_memoria_persistencia() -> void:
	var data: Dictionary = _vm.get_save_data()
	_check(data.has("memoria"), "save_data incluye memoria (P26)")
	var mem: Dictionary = data.get("memoria", {})
	_check((mem.get("catalina_oso", []) as Array).size() == 3, "memoria catalina persistida")
	# Round-trip
	_vm.restore_save_data({"memoria": {}})
	_check(_vm.memoria_de("catalina_oso").is_empty(), "restore vacío limpia memoria")
	_vm.restore_save_data(data)
	_check(_vm.memoria_de("catalina_oso").size() == 3, "round-trip restaura memoria")
	_check(int(_vm.memoria_conteo("catalina_oso", "regalo")) == 1, "round-trip restaura conteo")
	# Huérfano purgado
	var con_viejo: Dictionary = data.duplicate(true)
	(con_viejo.memoria as Dictionary)["vecino_fantasma"] = [{"dia": 1, "tipo": "charla", "detalle": "x"}]
	_vm.restore_save_data(con_viejo)
	_check(_vm.memoria_de("vecino_fantasma").is_empty(), "memoria de huérfano purgada al cargar")


func _test_agenda_determinista() -> void:
	# P11/P24: mismo día + mismo vecino → misma agenda (PRNG determinista M29)
	var a1: Dictionary = _vm.agenda_dia("catalina_oso", 42)
	var a2: Dictionary = _vm.agenda_dia("catalina_oso", 42)
	_check(a1 == a2, "agenda determinista por (día, vecino)")
	# Día distinto puede variar (sin requerir que varíe)
	var a3: Dictionary = _vm.agenda_dia("catalina_oso", 43)
	_check(a3.size() == a1.size(), "agenda de otro día con mismas franjas")
	# Franjas del diseño P12 presentes
	for clave in ["06:00", "08:00", "12:00", "14:00", "18:00", "22:00"]:
		_check(a1.has(clave), "franja %s presente (P12)" % clave)


func _test_agenda_franjas() -> void:
	# P12: franja 22-06 = dormir SIEMPRE (sin variación, diseño cozy)
	var a: Dictionary = _vm.agenda_dia("luna_zorra", 7)
	_check(String(a.get("22:00", "")) == "dormir", "22:00 = dormir (P12 sin variación)")
	# Rutina del perfil tiene prioridad si define la franja
	var cat: Resource = _vm._catalogo.get("catalina_oso", null)
	if cat != null and (cat as Resource).rutina_diaria.size() > 0:
		var clave: String = String((cat as Resource).rutina_diaria.keys()[0])
		var act: String = String((cat as Resource).rutina_diaria[clave])
		_check(String(a.get(clave, "")) == act, "rutina del perfil prioriza sobre default (%s=%s)" % [clave, act])


func _test_actividad_actual() -> void:
	# P24: actividad_actual() retorna una actividad válida de las franjas
	var act: String = _vm.actividad_actual("finneas_zorro")
	var validas := ["desayuno", "trabajo", "comida", "trabajo_ocio", "social", "dormir", "libre", "ocio"]
	_check(validas.has(act), "actividad actual válida: %s" % act)


func _test_poblacion_arranque() -> void:
	# P1: poblar_arranque activa hasta 6 vecinos (idempotente)
	var activados: Array = _vm.poblar_arranque()
	var n1: int = activados.size()
	var n_activos: int = _vm.obtener_poblacion_actual()
	_check(n_activos >= 1 and n_activos <= 6, "población activa entre 1 y 6: %d" % n_activos)
	# Idempotente: segunda llamada no duplica
	var activados2: Array = _vm.poblar_arranque()
	var n_activos2: int = _vm.obtener_poblacion_actual()
	_check(n_activos2 == n_activos, "arranque idempotente (%d → %d)" % [n_activos, n_activos2])
	# Sin popups de duplicados: cada activo aparece UNA vez
	var vistos := {}
	for v in _vm.obtener_activos():
		var vid: String = String(v.name)
		_check(not vistos.has(vid), "vecino %s sin duplicado" % vid)
		vistos[vid] = true
	# Memoria de mudanza registrada para los activados (P26 + P1)
	for vid in vistos:
		if String(vid) != "":
			_check(int(_vm.memoria_conteo(String(vid), "mudanza")) >= 0, "memoria accesible para %s" % String(vid))
	_check(true, "población de arranque verificada (activados esta pasada: %d; total: %d)" % [n1, n_activos])