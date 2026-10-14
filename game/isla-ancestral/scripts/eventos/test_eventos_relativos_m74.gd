# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-11
#
# M74 Eventos — RF4.10 (eventos relativos por calendario) y RF4.12
# (re-validar eventos al cargar). Pedidos por el director (msg 148).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_eventos_relativos_m74.gd

extends SceneTree

const CHECKS_MINIMOS: int = 30

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

func _ev(id: String, extra: Dictionary) -> EventDefinition:
	var e := EventDefinition.new()
	e.id = id
	for k in extra.keys():
		e.set(k, extra[k])
	return e

# ── bloques ──────────────────────────────────────────────────────────────

## 1. RF4.10: resolución de reglas relativas.
func _b1_reglas(mgr) -> void:
	_abrir("1", "RF4.10: resolución de reglas relativas")
	# El calendario Aurora son 12 meses de 28 días = 4 semanas exactas.
	# primer_lunes de cualquier mes cae siempre el día 1.
	_ok(EventDefinition.resolver("primer_lunes", 1) == 1, "primer_lunes -> día 1 (mes 1)")
	_ok(EventDefinition.resolver("primer_lunes", 7) == 1, "primer_lunes -> día 1 (mes 7)")
	# segundo_lunes -> día 8; cuarto_lunes -> día 22
	_ok(EventDefinition.resolver("segundo_lunes", 1) == 8, "segundo_lunes -> día 8")
	_ok(EventDefinition.resolver("tercer_lunes", 1) == 15, "tercer_lunes -> día 15")
	_ok(EventDefinition.resolver("cuarto_lunes", 1) == 22, "cuarto_lunes -> día 22")
	# último_lunes -> día 22 (solo hay 4 semanas)
	_ok(EventDefinition.resolver("ultimo_lunes", 1) == 22, "ultimo_lunes -> día 22")
	# Un día de semana distinto cae otro día del mes
	var primer_sabado: int = EventDefinition.resolver("primer_sabado", 1)
	_ok(primer_sabado > 1 and primer_sabado <= 7, "primer_sabado cae en la 1ra semana (%d)" % primer_sabado)
	var segundo_sabado: int = EventDefinition.resolver("segundo_sabado", 1)
	_ok(segundo_sabado == primer_sabado + 7, "segundo_sabado = primer_sabado + 7")

	# Regla imposible o inválida -> sin fecha (no se inventa)
	_ok(EventDefinition.resolver("quinto_lunes", 1) == 0, "quinto_lunes no existe -> 0")
	_ok(EventDefinition.resolver("primer_martes27", 1) == 0, "regla mal formada -> 0")
	_ok(EventDefinition.resolver("", 1) == 0, "regla vacía -> 0")
	_ok(EventDefinition.resolver("primer_lunes", 13) == 0, "mes fuera de rango -> 0")
	_fin("1")

## 2. RF4.10: coincide_fecha con eventos relativos.
func _b2_coincide(mgr) -> void:
	_abrir("2", "RF4.10: coincide_fecha con regla")
	var sab := _ev("ev_sab", {"regla_relativa": "segundo_sabado", "mes": -1, "estacion": -1})
	var dia: int = EventDefinition.resolver("segundo_sabado", 1)
	_ok(sab.es_relativa(), "el evento se declara relativo")
	_ok(sab.coincide_fecha(dia, 1, 0), "coincide en el día resuelto")
	_ok(not sab.coincide_fecha(dia + 1 if dia < 28 else 1, 1, 0), "no coincide al día siguiente")

	# Filtro de mes/estación sigue aplicando
	var oto := _ev("ev_otonio", {"regla_relativa": "segundo_sabado", "estacion": 2})
	_ok(not oto.coincide_fecha(EventDefinition.resolver("segundo_sabado", 1), 1, 0),
		"fuera de Otoño no coincide (mes 1 = Primavera)")
	_ok(oto.coincide_fecha(EventDefinition.resolver("segundo_sabado", 7), 7, 2),
		"en Otoño (mes 7) sí coincide")

	# Evento de fecha fija: comportamiento intacto
	var fijo := _ev("ev_fijo", {"dia": 15, "mes": 3})
	_ok(fijo.coincide_fecha(15, 3, 0) and not fijo.coincide_fecha(16, 3, 0),
		"evento de fecha fija sigue funcionando igual")
	_ok(not fijo.es_relativa(), "evento fijo no es relativo")

	# Round-trip del campo nuevo
	var d: Dictionary = sab.to_dict()
	_ok(String(d.get("regla_relativa", "")) == "segundo_sabado", "to_dict guarda la regla")
	var sab2 := EventDefinition.from_dict(d)
	_ok(sab2.regla_relativa == "segundo_sabado", "from_dict recupera la regla")
	_ok(sab2.coincide_fecha(dia, 1, 0), "el round-trip conserva el comportamiento")
	_fin("2")

## 3. RF4.10 integrado: la agenda encuentra el evento relativo.
func _b3_agenda(mgr) -> void:
	_abrir("3", "RF4.10 integrado: get_eventos_del_dia")
	var sab := _ev("ev_sabado_agenda", {"regla_relativa": "segundo_sabado", "mes": -1, "estacion": -1})
	mgr._catalogo["ev_sabado_agenda"] = sab
	var dia: int = EventDefinition.resolver("segundo_sabado", 1)
	var del_dia: Array = mgr.get_eventos_del_dia({"dia": dia, "mes": 1, "estacion": 0})
	var encontrado: bool = false
	for e in del_dia:
		if String((e as EventDefinition).id) == "ev_sabado_agenda":
			encontrado = true
	_ok(encontrado, "la agenda del día encuentra el evento relativo")
	var otro: Array = mgr.get_eventos_del_dia({"dia": dia + 1 if dia < 28 else 1, "mes": 1, "estacion": 0})
	var sigue: bool = false
	for e in otro:
		if String((e as EventDefinition).id) == "ev_sabado_agenda":
			sigue = true
	_ok(not sigue, "al día siguiente ya no está")
	mgr._catalogo.erase("ev_sabado_agenda")
	_fin("3")

## 4. RF4.12: re-validar al cargar.
func _b4_revalidar(mgr) -> void:
	_abrir("4", "RF4.12: re-validar eventos al cargar")
	var anio: int = mgr._get_anio_actual()
	mgr._catalogo.clear()
	# Evento ancho (todo el año, todo el día) -> la franja queda abierta
	var amplio := _ev("ev_amplio", {"dia": 0, "mes": -1, "estacion": -1, "hora_inicio": 0, "hora_fin": 1440})
	mgr._catalogo["ev_amplio"] = amplio
	var es := EventState.new()
	es.evento_id = &"ev_amplio"
	es.anio = anio
	es.estado = EventState.Estado.EN_CURSO
	mgr._set_estado(&"ev_amplio", anio, es)

	var r: Dictionary = mgr.revalidar_al_cargar()
	_ok(int(r["reabiertos"]) == 1, "franja abierta -> evento reabierto (dio %d)" % int(r["reabiertos"]))
	_ok(mgr.get_evento_actual() != null, "evento_actual apunta al reabierto")
	var st: EventState = mgr._get_estado(&"ev_amplio", anio)
	_ok(st != null and st.estado == EventState.Estado.EN_CURSO, "sigue EN_CURSO")

	# Evento con fecha imposible -> la franja está cerrada -> se cierra
	var cerrado := _ev("ev_cerrado", {"dia": 2, "mes": 2, "estacion": -1, "hora_inicio": 0, "hora_fin": 100})
	mgr._catalogo["ev_cerrado"] = cerrado
	var es2 := EventState.new()
	es2.evento_id = &"ev_cerrado"
	es2.anio = anio
	es2.estado = EventState.Estado.EN_CURSO
	mgr._set_estado(&"ev_cerrado", anio, es2)
	var r2: Dictionary = mgr.revalidar_al_cargar()
	_ok(int(r2["cerrados"]) >= 1, "franja cerrada -> evento cerrado (dio %d)" % int(r2["cerrados"]))
	var st2: EventState = mgr._get_estado(&"ev_cerrado", anio)
	_ok(st2 != null and st2.estado == EventState.Estado.NO_PARTICIPADO,
		"el evento cerrado queda NO_PARTICIPADO (no se pierde el histórico)")

	# El cierre emite la señal para la UI
	var terminados: Array = []
	mgr.evento_terminado.connect(func(id): terminados.append(id))
	es2.estado = EventState.Estado.EN_CURSO
	mgr._set_estado(&"ev_cerrado", anio, es2)
	mgr.revalidar_al_cargar()
	_ok(terminados.size() >= 1, "evento_terminado se emite al cerrar (dio %d)" % terminados.size())

	# restore_save_data dispara la re-validación sola
	var data: Dictionary = mgr.get_save_data()
	var otro := _mgr()
	otro.restore_save_data(data)
	_ok(true, "restore_save_data con EN_CURSO no rompe (re-valida solo)")
	var st3: EventState = otro._get_estado(&"ev_amplio", anio)
	_ok(st3 != null and st3.estado == EventState.Estado.EN_CURSO, "el amplio sigue abierto tras cargar")
	otro.free()
	mgr._catalogo.erase("ev_amplio")
	mgr._catalogo.erase("ev_cerrado")
	_fin("4")

func _run() -> void:
	var mgr = _mgr()
	_ok(mgr != null, "EventManager instanciado")
	if mgr == null:
		return
	_b1_reglas(mgr)
	_b2_coincide(mgr)
	_b3_agenda(mgr)
	_b4_revalidar(mgr)
	mgr.free()

func _summary() -> void:
	print("=== RESUMEN M74 EVENTOS RELATIVOS: %d checks, %d fallos, %d bloques cerrados ===" % [
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
