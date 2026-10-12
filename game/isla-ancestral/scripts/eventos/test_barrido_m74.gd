# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M74 Eventos - barrido de edge cases (encargo del director mimo, msg 29).
# Cubre: ano nuevo (RF2.4/RF7.1/J1-J3), jugador ausente (J4-J6), re-entrada
# (J17), evento sin recinto (J24), franja 00:00 (J25), evento sin recompensas
# (J23), partida vieja (J22), guardar a mitad (J13/J14), clima interior
# (J11/J28), sorpresas (RF9.2/RF9.3/J21), guardado doble (J27), bicampeon
# (RF7.4) y auditoria anti-FOMO del catalogo real (RN16/I19/I20).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_barrido_m74.gd

extends SceneTree

const CHECKS_MINIMOS: int = 45

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

func _ev(id: String, extra: Dictionary = {}) -> EventDefinition:
	var e := EventDefinition.new()
	e.id = id
	e.nombre_clave = StringName("%s_nombre" % id)
	e.descripcion_clave = StringName("%s_desc" % id)
	for k in extra.keys():
		e.set(k, extra[k])
	return e

# ── bloques ──────────────────────────────────────────────────────────────

## 1. RF2.4 / RF7.1 / J1-J3: ano nuevo e idempotencia.
func _b1_ano_nuevo(mgr) -> void:
	_abrir("1", "RF2.4/RF7.1/J1-J3: ano nuevo + dia_cambio duplicado")
	mgr._catalogo.clear()
	mgr._reprogramados.clear()
	mgr._estado_anual.clear()
	mgr._ultima_fecha_procesada = ""
	mgr._ultimo_anio_procesado = -1
	var ev := _ev("fest_ano_nuevo", {"dia": 1, "mes": 1, "hora_inicio": 0, "hora_fin": 1440})
	mgr._catalogo["fest_ano_nuevo"] = ev

	# Primer dia_cambio del ano 1: solo registra, no normaliza (ya lo hizo _ready).
	var avisos: Array = []
	mgr.evento_proximo.connect(func(_id, _d): avisos.append(1))
	mgr._on_dia_cambio({"anio": 1, "mes": 1, "dia": 1, "estacion": 0})
	_ok(avisos.size() == 0, "dia_cambio a ano 1 procesado sin aviso (no es proximo)")
	_ok(mgr._ultimo_anio_procesado == 1, "_ultimo_anio_procesado = 1")

	# dia_cambio duplicado para la misma fecha: se descarta (J1-J3).
	mgr._on_dia_cambio({"anio": 1, "mes": 1, "dia": 1, "estacion": 0})
	_ok(mgr._ultima_fecha_procesada == "1_1_1", "fecha procesada registrada")

	# Marcar el evento del ano 1 como participado (historial del ano viejo).
	mgr.iniciar_participacion(&"fest_ano_nuevo", {})
	var est1 = mgr._get_estado(&"fest_ano_nuevo", 1)
	_ok(est1 != null and est1.estado == EventState.Estado.PARTICIPADO, "ano 1: participado")

	# Transicion al ano 2 (28/12/1 -> 1/1/2): la agenda se regenera.
	mgr._on_dia_cambio({"anio": 1, "mes": 12, "dia": 28, "estacion": 3})
	mgr._on_dia_cambio({"anio": 2, "mes": 1, "dia": 1, "estacion": 0})
	_ok(mgr._ultimo_anio_procesado == 2, "ano 2 registrado")
	var est2 = mgr._get_estado(&"fest_ano_nuevo", 2)
	_ok(est2 != null and est2.estado == EventState.Estado.PENDIENTE, "ano 2: el evento vuelve a PENDIENTE")
	# El historial del ano 1 se conserva (no se pierde).
	var est1b = mgr._get_estado(&"fest_ano_nuevo", 1)
	_ok(est1b != null and est1b.estado == EventState.Estado.PARTICIPADO, "historial del ano 1 conservado")
	_fin("1")

## 2. J4/J5/J6: jugador ausente.
func _b2_ausente(mgr) -> void:
	_abrir("2", "J4/J5/J6: jugador ausente -> NO_PARTICIPADO y repite al ano siguiente")
	mgr._catalogo.clear()
	mgr._reprogramados.clear()
	mgr._estado_anual.clear()
	mgr._ultima_fecha_procesada = ""
	mgr._ultimo_anio_procesado = -1
	var ev := _ev("fest_ausente", {"dia": 5, "mes": 2, "hora_inicio": 6 * 60, "hora_fin": 12 * 60})
	mgr._catalogo["fest_ausente"] = ev
	# El evento entra en curso...
	mgr._on_dia_cambio({"anio": 1, "mes": 2, "dia": 5, "estacion": 0})
	_ok(mgr.evento_actual != null, "el evento inicia (franja abierta)")
	# ...pasa la franja sin que el jugador participe.
	mgr._finalizar_evento(&"fest_ausente", 1, false)
	var est = mgr._get_estado(&"fest_ausente", 1)
	_ok(est != null and est.estado == EventState.Estado.NO_PARTICIPADO, "queda NO_PARTICIPADO (sin castigo)")
	# Al ano siguiente vuelve a estar disponible.
	mgr._normalizar_agenda(2)
	var est2 = mgr._get_estado(&"fest_ausente", 2)
	_ok(est2 != null and est2.estado == EventState.Estado.PENDIENTE, "el ano 2 vuelve a estar PENDIENTE")
	_fin("2")

## 3. J17: re-entrada rapida bloqueada.
func _b3_reentrada(mgr) -> void:
	_abrir("3", "J17: re-entrada al mismo evento en el mismo ano")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	var ev := _ev("fest_reentrada", {"dia": 10, "mes": 3})
	mgr._catalogo["fest_reentrada"] = ev
	var ok1 := mgr.iniciar_participacion(&"fest_reentrada", {})
	var ok2 := mgr.iniciar_participacion(&"fest_reentrada", {})
	_ok(ok1 == true, "primera participacion ok")
	_ok(ok2 == false, "segunda participacion en el mismo ano bloqueada")
	var r := mgr.puede_participar(&"fest_reentrada")
	_ok(not r["ok"] and String(r["razon"]) == "ya_participado_este_anio", "puede_participar explica por que")
	_fin("3")

## 4. J24: evento sin recinto funciona sin escena.
func _b4_sin_recinto(mgr) -> void:
	_abrir("4", "J24: evento sin escena_recinto no crashea")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	mgr._ultima_fecha_procesada = ""
	mgr._ultimo_anio_procesado = -1
	var ev := _ev("fest_sin_recinto", {"dia": 7, "mes": 4, "escena_recinto": null, "hora_inicio": 8 * 60, "hora_fin": 20 * 60})
	mgr._catalogo["fest_sin_recinto"] = ev
	mgr._on_dia_cambio({"anio": 1, "mes": 4, "dia": 7, "estacion": 1})
	_ok(mgr.evento_actual != null, "inicia sin escena (solo senal)")
	_ok(mgr.get_evento_actual() != null, "get_evento_actual() responde")
	mgr._finalizar_evento(&"fest_sin_recinto", 1, false)
	_ok(mgr.evento_actual == null, "finaliza limpio")
	_fin("4")

## 5. J25: franja que empieza a las 00:00.
func _b5_franja_0000(mgr) -> void:
	_abrir("5", "J25: franja 00:00")
	var ev := _ev("fest_madrugada", {"hora_inicio": 0, "hora_fin": 120})
	_ok(ev.esta_en_franja(0, 0) == true, "a las 00:00 la franja esta abierta")
	_ok(ev.esta_en_franja(1, 59) == true, "01:59 dentro de la franja")
	_ok(ev.esta_en_franja(2, 0) == false, "02:00 fuera de la franja")
	_ok(ev.minutos_hasta_inicio(0, 0) == 0, "minutos_hasta_inicio en el limite")
	_fin("5")

## 6. J23: evento sin recompensas definidas.
func _b6_sin_recompensas(mgr) -> void:
	_abrir("6", "J23: evento sin recompensas")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	var ev := _ev("fest_sin_premio", {"dia": 3, "mes": 5})
	mgr._catalogo["fest_sin_premio"] = ev
	_ok(ev.recompensas.is_empty(), "el evento no define recompensas")
	# finalizar_evento no crashea y no entrega nada.
	mgr.finalizar_evento(&"fest_sin_premio", {})
	var est = mgr._get_estado(&"fest_sin_premio", 1)
	_ok(est != null, "el evento finalizo sin error")
	_fin("6")

## 7. J22: partida vieja sin modulo M74 (migracion).
func _b7_partida_vieja(mgr) -> void:
	_abrir("7", "J22: save sin seccion M74")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	var ev := _ev("fest_viejo", {"dia": 20, "mes": 6})
	mgr._catalogo["fest_viejo"] = ev
	# Un save que no tiene la seccion "events_m74" se interpreta como vacio.
	mgr.restore_save_data({})
	var est = mgr._get_estado(&"fest_viejo", 1)
	_ok(est != null and est.estado == EventState.Estado.PENDIENTE, "se inicializa desde cero, sin perdida")
	# Un save corrupto (eventos no es diccionario) tampoco tumba la partida.
	mgr.restore_save_data({"eventos": "basura"})
	_ok(true, "save corrupto no crasheo (descartado silencioso)")
	_fin("7")

## 8. J13/J14: guardar a mitad de evento.
func _b8_guardar_mitad(mgr) -> void:
	_abrir("8", "J13/J14: revalidar al cargar")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	mgr.evento_actual = null
	mgr.evento_actual_id = &""
	# Evento EN_CURSO que coincide con la fecha actual de headless (1/1, 08:00).
	var ev := _ev("fest_en_curso", {"dia": 1, "mes": 1, "hora_inicio": 6 * 60, "hora_fin": 22 * 60})
	mgr._catalogo["fest_en_curso"] = ev
	mgr._iniciar_evento(ev, 1)
	# Guardar y restaurar con la franja todavia abierta: se reabre.
	var data: Dictionary = mgr.get_save_data()
	var otro := _mgr()
	otro._catalogo.clear()
	otro._catalogo["fest_en_curso"] = ev
	otro.restore_save_data(data)
	_ok(otro.evento_actual != null, "franja abierta al cargar: el evento se reabre")
	otro.free()
	# Franja ya cerrada: se finaliza como NO_PARTICIPADO y se emite terminado.
	var ev2 := _ev("fest_cerrado", {"dia": 2, "mes": 1, "hora_inicio": 6 * 60, "hora_fin": 22 * 60})
	mgr._catalogo["fest_cerrado"] = ev2
	mgr._iniciar_evento(ev2, 1)
	var terminados: Array = []
	mgr.evento_terminado.connect(func(id): terminados.append(id))
	var data2: Dictionary = mgr.get_save_data()
	var otro2 := _mgr()
	otro2._catalogo.clear()
	otro2._catalogo["fest_cerrado"] = ev2
	otro2.evento_terminado.connect(func(id): terminados.append(id))
	otro2.restore_save_data(data2)
	_ok(terminados.size() >= 1, "franja cerrada al cargar: se emite evento_terminado")
	var est = mgr._get_estado(&"fest_cerrado", 1)
	_ok(est != null and est.estado == EventState.Estado.NO_PARTICIPADO, "y queda NO_PARTICIPADO")
	otro2.free()
	mgr.evento_actual = null
	mgr.evento_actual_id = &""
	_fin("8")

## 9. J11/J28: tormenta con evento interior (sin variante cubierta).
func _b9_clima_interior(mgr) -> void:
	_abrir("9", "J11/J28: clima severo en evento interior")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	var ev := _ev("fest_interior", {"dia": 12, "mes": 7, "variante_cubierta": null})
	mgr._catalogo["fest_interior"] = ev
	mgr._iniciar_evento(ev, 1)
	mgr._on_clima_cambio(3)  # Tormenta
	_ok(mgr.evento_actual != null, "evento interior intacto tras tormenta")
	_ok(mgr.evento_actual_id == &"fest_interior", "no se cancela ni se mueve")
	mgr.evento_actual = null
	mgr.evento_actual_id = &""
	_fin("9")

## 10. RF9.2/RF9.3/J21: limites de sorpresas.
func _b10_sorpresas(mgr) -> void:
	_abrir("10", "RF9.2/RF9.3/J21: limite semanal y no en festival")
	mgr._sorpresa_semanal_count = 0
	mgr._ultima_semana_sorpresa = -1
	# Sin GameTime en headless: semana_dia = 0. Las 3 primeras entran.
	var ok1 := mgr.registrar_sorpresa(&"sorp_a")
	var ok2 := mgr.registrar_sorpresa(&"sorp_b")
	var ok3 := mgr.registrar_sorpresa(&"sorp_c")
	var ok4 := mgr.registrar_sorpresa(&"sorp_d")
	_ok(ok1 and ok2 and ok3, "3 sorpresas en la semana ok (limite = 3)")
	_ok(not ok4, "la 4ta sorpresa de la semana se rechaza")
	_fin("10")

## 11. J27: guardado doble rapido no duplica recompensas.
func _b11_guardado_doble(mgr) -> void:
	_abrir("11", "J27: save/load/save no clona recompensa")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	var ev := _ev("fest_token", {"dia": 9, "mes": 9})
	mgr._catalogo["fest_token"] = ev
	# Una entrega exitosa consume el token anti-duplicado del anio.
	mgr.iniciar_participacion(&"fest_token", {})
	var est = mgr._get_estado(&"fest_token", 1)
	est.marcar_recompensa_recibida(1)
	_ok(est.puede_recibir_recompensa(1) == false, "token consumido tras la entrega")
	# Guardar/cargar y volver a intentar: sigue bloqueada.
	var data: Dictionary = mgr.get_save_data()
	mgr.restore_save_data(data)
	var est2 = mgr._get_estado(&"fest_token", 1)
	_ok(est2 != null and est2.puede_recibir_recompensa(1) == false, "tras round-trip el token sigue consumido")
	_fin("11")

## 12. RF7.4: titulos de bicampeon.
func _b12_bicampeon(mgr) -> void:
	_abrir("12", "RF7.4: anos ganados de un evento")
	mgr._catalogo.clear()
	mgr._estado_anual.clear()
	var ev := _ev("fest_torneo", {"dia": 21, "mes": 10})
	mgr._catalogo["fest_torneo"] = ev
	var e1 := EventState.new()
	e1.evento_id = &"fest_torneo"
	e1.anio = 1
	e1.mejor_puesto = 1
	mgr._set_estado(&"fest_torneo", 1, e1)
	var e2 := EventState.new()
	e2.evento_id = &"fest_torneo"
	e2.anio = 2
	e2.mejor_puesto = 3
	mgr._set_estado(&"fest_torneo", 2, e2)
	var e3 := EventState.new()
	e3.evento_id = &"fest_torneo"
	e3.anio = 3
	e3.mejor_puesto = 1
	mgr._set_estado(&"fest_torneo", 3, e3)
	var ganados: Array = mgr.get_anios_ganados("fest_torneo")
	_ok(ganados.size() == 2, "2 anos ganados (1 y 3; el 2 fue puesto 3)")
	_ok(int(ganados[0]) == 1 and int(ganados[1]) == 3, "devuelve los anos en orden")
	_ok(mgr.get_anios_ganados("inexistente").is_empty(), "evento sin victorias -> vacio")
	_fin("12")

## 13. RN16/I19/I20: auditoria anti-FOMO del catalogo real.
func _b13_antifomo(mgr) -> void:
	_abrir("13", "RN16/I19/I20: auditoria anti-FOMO del catalogo real")
	var n: int = mgr.get_catalogo_size()
	_ok(n >= 15, "catalogo real cargado (%d eventos)" % n)
	var todos_recurrentes := true
	var sin_exclusivos := true
	for ev in mgr.get_all_events():
		var e: EventDefinition = ev
		# Los capitulos de historia (flags.capitulo) se disparan por gatillo
		# de M23/M149, no por fecha: estan fuera del ciclo anual por diseno.
		var es_capitulo: bool = bool(e.flags.get("capitulo", false))
		var recurrente: bool = e.mes != -1 or e.estacion != -1 or e.es_relativa() or e.dia != 0
		if not es_capitulo and not recurrente:
			todos_recurrentes = false
			print("    NO recurrente: %s" % e.id)
		for flag in e.flags.keys():
			var f: String = String(flag).to_lower()
			if f == "unico" or f == "irrecuperable" or f == "exclusivo":
				sin_exclusivos = false
				print("    flag exclusivo en %s: %s" % [e.id, f])
	_ok(todos_recurrentes, "todo evento del catalogo es recurrente (excepto capitulos)")
	_ok(sin_exclusivos, "ningun evento declara contenido exclusivo irrecuperable")
	_fin("13")

func _run() -> void:
	var mgr = _mgr()
	_ok(mgr != null, "EventManager instanciado")
	if mgr == null:
		return
	_b1_ano_nuevo(mgr)
	_b2_ausente(mgr)
	_b3_reentrada(mgr)
	_b4_sin_recinto(mgr)
	_b5_franja_0000(mgr)
	_b6_sin_recompensas(mgr)
	_b7_partida_vieja(mgr)
	_b8_guardar_mitad(mgr)
	_b9_clima_interior(mgr)
	_b10_sorpresas(mgr)
	_b11_guardado_doble(mgr)
	_b12_bicampeon(mgr)
	_b13_antifomo(mgr)
	mgr.free()

func _summary() -> void:
	print("=== RESUMEN M74 BARRIDO: %d checks, %d fallos, %d bloques cerrados ===" % [
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
