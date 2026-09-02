# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Test headless de Eventos
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/test_eventos.gd

extends SceneTree

var _fallos: int = 0
var _ok: int = 0


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _get_root(name: String) -> Node:
	return get_root().get_node_or_null(name)


func _correr() -> void:
	# --- 1. EventDefinition ---
	print("\n=== TEST EVENT DEFINITION ===")
	var ev := EventDefinition.new()
	ev.id = &"test_festival"
	ev.tipo = EventDefinition.Tipo.FESTIVAL
	ev.dia = 15
	ev.mes = 1
	ev.estacion = 0
	ev.hora_inicio = 360
	ev.hora_fin = 1320
	ev.dias_aviso = 3
	ev.prioridad = 100
	_check("id set", ev.id == &"test_festival")
	_check("tipo festival", ev.tipo == 0)
	_check("coincide fecha correcta", ev.coincide_fecha(15, 1, 0))
	_check("no coincide mes errado", not ev.coincide_fecha(15, 2, 0))
	_check("no coincide dia distinto", not ev.coincide_fecha(5, 1, 0))
	_check("no coincide mes distinto", not ev.coincide_fecha(15, 5, 0))
	_check("no coincide estacion distinta", not ev.coincide_fecha(15, 1, 3))
	_check("en franja 10:00", ev.esta_en_franja(10, 0))
	_check("en franja 6:00", ev.esta_en_franja(6, 0))
	_check("fuera franja 5:59", not ev.esta_en_franja(5, 59))
	_check("fuera franja 22:00", not ev.esta_en_franja(22, 0))
	_check("minutos hasta inicio", ev.minutos_hasta_inicio(8, 0) == 1320)
	_check("minutos hasta fin", ev.minutos_hasta_fin(10, 0) == 720)
	var d := ev.to_dict()
	_check("to_dict tiene id", d.has("id"))
	var ev2 := EventDefinition.from_dict(d)
	_check("from_dict restaura id", ev2.id == ev.id)
	_check("from_dict restaura tipo", ev2.tipo == ev.tipo)

	# --- 2. RecompensaDef ---
	print("\n=== TEST RECOMPENSA DEF ===")
	var recomp := RecompensaDef.new()
	recomp.tipo = RecompensaDef.TipoRecompensa.OBJETO
	recomp.cantidad = 5
	recomp.id_item = &"semilla_flor"
	var rd := recomp.to_dict()
	_check("to_dict tipo", rd["tipo"] == 0)
	_check("to_dict cantidad", rd["cantidad"] == 5)
	var r2 := RecompensaDef.from_dict(rd)
	_check("from_dict restaura", r2.cantidad == 5 and r2.id_item == recomp.id_item)
	var ok = recomp.entregar(null, {})
	_check("entregar sin manager no crash", true)

	# --- 3. EventState ---
	print("\n=== TEST EVENT STATE ===")
	var es := EventState.new()
	es.evento_id = &"festival_primavera"
	es.anio = 1
	es.estado = EventState.Estado.PENDIENTE
	_check("estado inicial PENDIENTE", es.estado == 0)
	_check("no particip este anio", not es.is_participated_this_year(1))
	_check("puede recibir recompensa", es.puede_recibir_recompensa(1))
	es.marcar_recompensa_recibida(1)
	_check("estado PARTICIPADO", es.estado == EventState.Estado.PARTICIPADO)
	_check("anio_participacion=1", es.anio_participacion == 1)
	_check("no puede duplicar este anio", not es.puede_recibir_recompensa(1))
	_check("puede recibir anio siguiente", es.puede_recibir_recompensa(2))
	var es_d := es.to_dict()
	var es2 := EventState.from_dict(es_d)
	_check("from_dict estado", es2.estado == es.estado)
	_check("from_dict evento_id", es2.evento_id == es.evento_id)

	# --- 4. CondicionEvento ---
	print("\n=== TEST CONDICION EVENTO ===")
	var cond := CondicionEvento.new()
	cond.tipo_condicion = CondicionEvento.TipoCondicion.ESTACION
	cond.valor = 0
	var ctx := {"estacion": 0, "hora": 10, "minuto": 0, "dia": 15, "mes": 1,
				"anio": 1, "semana_dia": 3, "clima": 0, "amistad_npcs": {},
				"historia_sellos": [], "inventario": {}}
	var result := cond.evaluar(ctx)
	_check("condicion estacion primavera OK", result.ok)
	ctx["estacion"] = 1
	result = cond.evaluar(ctx)
	_check("condicion estacion verano FAIL", not result.ok)
	cond.tipo_condicion = CondicionEvento.TipoCondicion.CLIMA_OK
	cond.valor = null
	ctx["clima"] = 3
	result = cond.evaluar(ctx)
	_check("condicion clima tormenta FAIL", not result.ok)
	ctx["clima"] = 0
	result = cond.evaluar(ctx)
	_check("condicion clima soleado OK", result.ok)

	# --- 5. Integracion autoloads ---
	print("\n=== TEST INTEGRACION AUTOLOADS ===")
	var eventos: Node = _get_root("eventos")
	_check("eventos autoload presente", eventos != null)
	var gt: Node = _get_root("GameTime")
	_check("GameTime autoload presente", gt != null)
	var tc: Node = _get_root("TimeCalendar")
	_check("TimeCalendar autoload presente", tc != null)
	var vm: Node = _get_root("VillagerManager")
	_check("VillagerManager autoload presente", vm != null)
	_check("get_catalogo_size existe", eventos.has_method("get_catalogo_size"))
	_check("get_eventos_del_dia existe", eventos.has_method("get_eventos_del_dia"))
	_check("puede_participar existe", eventos.has_method("puede_participar"))
	_check("iniciar_participacion existe", eventos.has_method("iniciar_participacion"))
	_check("entregar_recompensa existe", eventos.has_method("entregar_recompensa"))
	_check("normalizar_agenda existe", eventos.has_method("normalizar_agenda"))
	_check("get_evento_actual existe", eventos.has_method("get_evento_actual"))
	var cat_size = eventos.get_catalogo_size()
	_check("catalogo tiene eventos (>0)", cat_size > 0)
	print("  (catalogo: %d eventos)" % cat_size)

	# --- 6. Catalogo tipos ---
	print("\n=== TEST CATALOGO TIPOS ===")
	var todos: Array = eventos.get_all_events()
	var festivales := 0
	var ferias := 0
	var competencias := 0
	var rituales := 0
	var climaticos := 0
	var sorpresas := 0
	for ev_item in todos:
		match ev_item.tipo:
			0: festivales += 1
			1: ferias += 1
			2: competencias += 1
			3: rituales += 1
			4: climaticos += 1
			5: sorpresas += 1
	_check("festivales >= 4", festivales >= 4)
	_check("ferias >= 1", ferias >= 1)
	_check("competencias >= 1", competencias >= 1)
	_check("rituales >= 1", rituales >= 1)
	_check("climaticos >= 1", climaticos >= 1)
	_check("sorpresas >= 1", sorpresas >= 1)
	print("  Festivales=%d Ferias=%d Competencias=%d Ritual=%d Climatico=%d Sorpresa=%d" %
		[festivales, ferias, competencias, rituales, climaticos, sorpresas])

	# --- 7. Anti-FOMO / Repetibilidad ---
	print("\n=== TEST ANTI-FOMO ===")
	var ev_state := EventState.new()
	ev_state.evento_id = &"festival_primavera"
	ev_state.anio = 1
	ev_state.estado = EventState.Estado.PENDIENTE
	_check("estado inicial PENDIENTE", ev_state.estado == 0)
	ev_state.marcar_recompensa_recibida(1)
	_check("despues marca PARTICIPADO", ev_state.estado == 2)
	_check("token anti-dup funciona", not ev_state.puede_recibir_recompensa(1))
	_check("anio siguiente puede recibir", ev_state.puede_recibir_recompensa(2))

	# --- 8. Robustez ---
	print("\n=== TEST ROBUSTEZ ===")
	var ev_sin_recomp := EventDefinition.new()
	ev_sin_recomp.id = &"evento_test_sin_recomp"
	ev_sin_recomp.recompensas = []
	_check("evento sin recompensas no crash", true)
	var d2 := ev_sin_recomp.to_dict()
	_check("to_dict sin recompensas OK", d2.has("id"))

	# --- Fin ---
	print("\n===== RESULTADOS M74 EVENTOS =====")
	print("%d OK / %d fallos" % [_ok, _fallos])
	print("RESULTADO: %s" % ("OK" if _fallos == 0 else "FALLOS"))
	quit(1 if _fallos > 0 else 0)
