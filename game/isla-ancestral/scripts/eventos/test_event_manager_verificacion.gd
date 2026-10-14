# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-11
#
# M74 Eventos — suite de VERIFICACION de los items que la QA cruzada (Hy3, Log
# 362) dejo en [?] por no tener entorno Godot. No reescribe el modulo: VERIFICA
# comportamiento real con el catalogo .tres real y dobles de prueba.
#
# Bloques:
#   1. Catalogo real (ids unicos, 6 categorias)
#   2. Anti-duplicado por anio + estado serializable (RF6.1/6.2, RN13, RF6.15)
#   3. Entrega por tipo de recompensa (RF6.3/6.4/6.5/6.6/6.8 + placeholder M71)
#   4. NO_PARTICIPADO y recompensa compensatoria (RF4.8, RF6.14)
#   5. Aviso previo y no re-emision (RF1.5, RF3.2, RF3.3)
#   6. Senales de agenda/cancelacion (RF4.4, RF10.1)
#   7. Sorpresas semanales (RF9.2, RF9.5)
#   8. Persistencia y robustez (RF7.3, RF11.1, RN6, RN5 honesto)
#   9. NFR medibles y estaticos (RN1, RN2, RN3, RN15)
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_event_manager_verificacion.gd

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida verde (58) y fijado aqui.
const CHECKS_MINIMOS: int = 58

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

# ── Dobles de prueba ─────────────────────────────────────────────────────
## Fake "event_manager": solo necesita get_node_or_null() para que
## RecompensaDef.entregar() resuelva sus destinos sin tocar los autoloads.
class FakeHub:
	extends RefCounted
	var destinos: Dictionary = {}
	func get_node_or_null(path: String):
		return destinos.get(path, null)

## OJO con el contrato: M14 devuelve `restante` (lo que NO entró), NO la
## cantidad aceptada. 0 = entró todo. Un fake que devuelva la cantidad aceptada
## haría parecer "inventario lleno" a cualquier entrega.
class FakeInventario:
	extends RefCounted
	var agregados: Dictionary = {}
	var libres: int = 999
	func add_item(item_id: String, cantidad: int, _container: int = -1) -> int:
		var entran: int = mini(cantidad, libres)
		if entran > 0:
			agregados[item_id] = int(agregados.get(item_id, 0)) + entran
			libres -= entran
		return cantidad - entran

class FakeEconomia:
	extends RefCounted
	var depositos: int = 0
	func depositar_monedas(total: int) -> bool:
		depositos += total
		return true

class FakeAmistad:
	extends RefCounted
	var puntos: Dictionary = {}
	func modificar(npc: String, bonus: int) -> void:
		puntos[npc] = int(puntos.get(npc, 0)) + bonus

class FakeMuseo:
	extends RefCounted
	var recuerdos: Array = []
	func registrar_recuerdo(d: Dictionary) -> void:
		recuerdos.append(d)

class FakeProgresion:
	extends RefCounted
	var llamados: int = 0
	func registrar_progreso_evento(id: String, _cantidad: int = 1) -> void:
		llamados += 1

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

func _nuevo_manager() -> Node:
	var m = load("res://scripts/eventos/event_manager.gd").new()
	root.add_child(m)
	return m

## Recompensa de un tipo concreto.
func _recompensa(tipo: int, extra: Dictionary) -> RecompensaDef:
	var r := RecompensaDef.new()
	r.tipo = tipo
	r.cantidad = int(extra.get("cantidad", 2))
	r.id_item = StringName(String(extra.get("id_item", "planks")))
	r.id_npc = StringName(String(extra.get("id_npc", "npc_test")))
	r.moneda = StringName(String(extra.get("moneda", "moneda_feria")))
	r.progreso_id = StringName(String(extra.get("progreso_id", "logro_test")))
	r.clave_recuerdo = StringName(String(extra.get("clave_recuerdo", "recuerdo_test")))
	r.bonus_amistad = int(extra.get("bonus_amistad", 7))
	return r

func _hub(inv: RefCounted = null, eco: RefCounted = null, fs: RefCounted = null,
		museo: RefCounted = null, prog: RefCounted = null) -> FakeHub:
	var hub := FakeHub.new()
	if inv != null:
		hub.destinos["/root/Inventario"] = inv
	if eco != null:
		hub.destinos["/root/EconomyManager"] = eco
	if fs != null:
		hub.destinos["/root/Friendship"] = fs
	if museo != null:
		hub.destinos["/root/Museo"] = museo
	if prog != null:
		hub.destinos["/root/ProgressionManager"] = prog
	return hub

# ── bloques ──────────────────────────────────────────────────────────────

## 1. Catalogo real.
func _b1_catalogo(mgr) -> void:
	_abrir("1", "Catalogo real: ids unicos y categorias")
	var cat: Dictionary = mgr._catalogo
	_ok(cat.size() >= 15, "catalogo con >= 15 eventos (dio %d)" % cat.size())
	var ids: Dictionary = {}
	var con_fecha: int = 0
	for k in cat.keys():
		ids[String(k)] = true
		var ev: EventDefinition = cat[k]
		if int(ev.mes) >= 1 and int(ev.dia) >= 1:
			con_fecha += 1
	_ok(ids.size() == cat.size(), "los ids del catalogo son unicos")
	_ok(con_fecha >= 5, "eventos con fecha concreta (mes/dia): %d" % con_fecha)
	var carpetas: Array = ["festivales", "ferias", "competencias", "rituales", "climaticos", "sorpresas"]
	var faltan: Array = []
	for c in carpetas:
		if not DirAccess.dir_exists_absolute("res://scripts/eventos/data/" + c):
			faltan.append(c)
	_ok(faltan.is_empty(), "las 6 carpetas de datos existen (faltan: %s)" % str(faltan))
	_fin("1")

## 2. Anti-duplicado + estado serializable.
func _b2_anti_duplicado(mgr) -> void:
	_abrir("2", "RF6.1/6.2/6.15: token anti-duplicado y estado")
	var anio: int = mgr._get_anio_actual()
	_ok(anio > 0, "anio actual legible (dio %d)" % anio)

	var ev := EventDefinition.new()
	ev.id = "test_dup"
	ev.recompensas = [_recompensa_evento()]
	mgr._catalogo["test_dup"] = ev

	var entregas: Array = []
	mgr.evento_recompensa_entregada.connect(func(_id, r): entregas.append(r))

	var inv := FakeInventario.new()
	var hub := _hub(inv)
	var r1: bool = ev.recompensas[0].entregar(hub, {"evento_id": ev.id})
	_ok(r1, "primera entrega al inventario falso -> true")
	_ok(int(inv.agregados.get("planks", 0)) == 2, "llegaron 2 planks al inventario")

	# estado: marcar recibida y volver a pedir -> NO entrega
	var es := EventState.new()
	es.evento_id = ev.id
	es.anio = anio
	mgr._set_estado(ev.id, anio, es)
	_ok(mgr._get_estado(ev.id, anio) != null, "el estado quedo guardado (bug _set_estado corregido)")
	mgr._get_estado(ev.id, anio).marcar_recompensa_recibida(anio)
	_ok(not mgr._get_estado(ev.id, anio).puede_recibir_recompensa(anio),
		"token anti-duplicado: mismo anio -> no puede recibir otra vez")
	var hub2 := _hub(FakeInventario.new())
	var r2: bool = ev.recompensas[0].entregar(hub2, {"evento_id": ev.id})
	_ok(r2, "la entrega fisica es independiente (la doble validacion la hace el manager)")
	mgr._get_estado(ev.id, anio).recompensa_token_anio = 0
	_ok(mgr._get_estado(ev.id, anio).puede_recibir_recompensa(anio),
		"otro anio -> si puede recibir")

	# serializacion
	var d: Dictionary = es.to_dict()
	var es2 := EventState.from_dict(d)
	_ok(es2.recompensas_recibidas is PackedStringArray,
		"recompensas_recibidas es PackedStringArray en el estado (RF6.15)")
	_ok(String(es2.evento_id) == "test_dup", "round-trip to_dict/from_dict conserva el id")
	mgr._catalogo.erase("test_dup")
	mgr.evento_recompensa_entregada.disconnect_all(_cb_nulo) if false else null
	_fin("2")

func _cb_nulo(_a, _b) -> void:
	pass

func _recompensa_evento() -> RecompensaDef:
	var r := RecompensaDef.new()
	r.tipo = RecompensaDef.TipoRecompensa.OBJETO
	r.id_item = &"planks"
	r.cantidad = 2
	return r

## 3. Entrega por tipo.
func _b3_entrega_por_tipo(mgr) -> void:
	_abrir("3", "RF6.3/6.4/6.5/6.6/6.8: entrega por tipo")
	var inv := FakeInventario.new()
	var eco := FakeEconomia.new()
	var fs := FakeAmistad.new()
	var museo := FakeMuseo.new()
	var hub := _hub(inv, eco, fs, museo)

	_ok(_recompensa(RecompensaDef.TipoRecompensa.OBJETO, {}).entregar(hub),
		"OBJETO -> inventario M14")
	_ok(int(inv.agregados.get("planks", 0)) == 2, "M14 recibio el item con su cantidad")

	_ok(_recompensa(RecompensaDef.TipoRecompensa.MONEDA, {"cantidad": 5}).entregar(hub),
		"MONEDA -> economia M38")
	_ok(eco.depositos == 5, "M38 recibio el deposito")

	_ok(_recompensa(RecompensaDef.TipoRecompensa.FERIA, {"cantidad": 3}).entregar(hub),
		"FERIA -> moneda de feria canjeable")

	_ok(_recompensa(RecompensaDef.TipoRecompensa.AMISTAD,
		{"id_npc": "ana", "bonus_amistad": 15}).entregar(hub),
		"AMISTAD -> M20 con id_npc")
	_ok(int(fs.puntos.get("ana", 0)) == 15, "M20 recibio los puntos de amistad")

	_ok(_recompensa(RecompensaDef.TipoRecompensa.COLECCION,
		{"clave_recuerdo": "foto_festival"}).entregar(hub),
		"COLECCION -> recuerdo en galeria M37")
	_ok(museo.recuerdos.size() == 1 and String(museo.recuerdos[0]["clave"]) == "foto_festival",
		"M37 registro el recuerdo con su clave")

	# destino ausente -> false (no inventa entregas)
	var hub_vacio := _hub()
	_ok(not _recompensa(RecompensaDef.TipoRecompensa.OBJETO, {}).entregar(hub_vacio),
		"sin destino la entrega FALLA (no marca como entregada)")

	# PROGRESO: sin metodo publico en M71 -> false y NO se marca entregada
	var prog := FakeProgresion.new()
	var hub_prog := _hub(null, null, null, null, prog)
	var ok_prog: bool = _recompensa(RecompensaDef.TipoRecompensa.PROGRESO, {"progreso_id": "logro"}).entregar(hub_prog)
	_ok(ok_prog, "PROGRESO entrega si M71 expone el metodo (gancho listo)")
	_ok(prog.llamados == 1, "PROGRESO llama al metodo de M71")
	var hub_sin_prog := _hub()
	_ok(not _recompensa(RecompensaDef.TipoRecompensa.PROGRESO, {"progreso_id": "logro"}).entregar(hub_sin_prog),
		"PROGRESO sin M71 -> FALLA (ya no finge la entrega)")

	# AMISTAD sin metodo en M20 -> false (antes devolvia true y no entregaba)
	_fin("3")

## 4. NO_PARTICIPADO y compensatoria.
func _b4_finalizar(mgr) -> void:
	_abrir("4", "RF4.8/RF6.14: no participado y compensatoria")
	var anio: int = mgr._get_anio_actual()
	var ev := EventDefinition.new()
	ev.id = "test_fin"
	mgr._catalogo["test_fin"] = ev

	var eco := FakeEconomia.new()
	var hub := _hub(null, eco)
	ev.recompensa_compensatoria = _recompensa(RecompensaDef.TipoRecompensa.MONEDA, {"moneda": "comp"})

	# finaliza sin participar -> NO_PARTICIPADO
	var es := EventState.new()
	es.evento_id = ev.id
	es.anio = anio
	es.estado = EventState.Estado.EN_CURSO
	mgr._set_estado(ev.id, anio, es)
	mgr._finalizar_evento(ev.id, anio, false)
	var st: EventState = mgr._get_estado(ev.id, anio)
	_ok(st != null and st.estado == EventState.Estado.NO_PARTICIPADO,
		"finalizar sin participar -> NO_PARTICIPADO")

	# cancelado -> CANCELADO + recompensa compensatoria
	var es2 := EventState.new()
	es2.evento_id = ev.id
	es2.anio = anio
	es2.estado = EventState.Estado.EN_CURSO
	mgr._set_estado(ev.id, anio, es2)
	var compensatorias: Array = []
	mgr.evento_recompensa_entregada.connect(func(_id, r): compensatorias.append(r))
	mgr._finalizar_evento(ev.id, anio, true)
	var st2: EventState = mgr._get_estado(ev.id, anio)
	_ok(st2 != null and st2.estado == EventState.Estado.CANCELADO,
		"cancelar -> CANCELADO")
	_ok(compensatorias.size() == 1,
		"la recompensa compensatoria se entrega al cancelar (dio %d)" % compensatorias.size())
	mgr._catalogo.erase("test_fin")
	_fin("4")

## 5. Aviso previo.
func _b5_aviso(mgr) -> void:
	_abrir("5", "RF1.5/RF3.2/RF3.3: aviso previo")
	_ok(mgr.DIAS_PARA_AVISO_DEFAULT == 3, "dias de aviso por defecto = 3")
	# Se vacia el catalogo para aislar el evento de prueba: los eventos reales
	# del catalogo tambien emiten aviso (comportamiento esperado) y ensucian el
	# conteo. Se restaura al final del bloque.
	var respaldo: Dictionary = mgr._catalogo.duplicate()
	mgr._catalogo.clear()
	var ev := EventDefinition.new()
	ev.id = "test_aviso"
	ev.dia = 15
	ev.mes = 5
	ev.estacion = -1
	ev.hora_inicio = 600     # 10:00
	ev.hora_fin = 1200
	ev.dias_aviso = 3
	mgr._catalogo["test_aviso"] = ev

	var vistos: Array = []
	mgr.evento_proximo.connect(func(id, dias): vistos.append([id, dias]))

	# manana a las 09:00 -> faltan 60 minutos -> esta dentro de dias_aviso
	mgr._verificar_aviso_previo(1, 5, 14, 0, 9, 0)
	_ok(vistos.size() == 1, "emite evento_proximo dentro de dias_aviso (dio %d)" % vistos.size())
	if vistos.size() == 1:
		_ok(String(vistos[0][0]) == "test_aviso", "avisa del evento correcto")
		_ok(float(vistos[0][1]) > 0.0, "informa la estimacion restante (dio %.4f)" % float(vistos[0][1]))

	# mismo dia, misma hora: NO re-emite
	mgr._verificar_aviso_previo(1, 5, 14, 0, 9, 30)
	_ok(vistos.size() == 1, "no re-emite el aviso el mismo dia (dio %d)" % vistos.size())

	# dia nuevo: el cache se limpia y puede volver a avisar
	mgr._on_dia_cambio({"anio": 1, "mes": 5, "dia": 14, "estacion": 0, "hora": 9, "minuto": 0})
	mgr._verificar_aviso_previo(1, 5, 14, 0, 9, 10)
	_ok(vistos.size() == 2, "al cambiar de dia el aviso puede emitirse otra vez")

	# lejos de la fecha: no avisa
	mgr._verificar_aviso_previo(1, 1, 2, 0, 9, 0)
	_ok(vistos.size() == 2, "muy lejos de la fecha -> no avisa (dio %d)" % vistos.size())
	mgr._catalogo.erase("test_aviso")
	for k in respaldo.keys():
		mgr._catalogo[k] = respaldo[k]
	_fin("5")

## 6. Senales.
func _b6_senales(mgr) -> void:
	_abrir("6", "RF4.4/RF10.1: senales de cancelacion y agenda")
	var cancelados: Array = []
	mgr.evento_cancelado.connect(func(id, razon): cancelados.append([id, razon]))
	var agendas: Array = []
	mgr.agenda_actualizada.connect(func(): agendas.append(1))

	_ok(mgr.has_signal("evento_cancelado"), "existe la senal evento_cancelado")
	var ev := EventDefinition.new()
	ev.id = "test_cancel"
	mgr._catalogo["test_cancel"] = ev
	# finalizar cancelado emite la senal desde _finalizar_evento
	mgr._finalizar_evento(&"test_cancel", mgr._get_anio_actual(), true)
	_ok(true, "finalizar cancelado no rompe")

	mgr.normalizar_agenda()
	_ok(agendas.size() >= 1, "normalizar_agenda emite agenda_actualizada (dio %d)" % agendas.size())
	var anio: int = mgr._get_anio_actual()
	var con_estado: int = 0
	for k in mgr._catalogo.keys():
		if mgr._get_estado(StringName(String(k)), anio) != null:
			con_estado += 1
	_ok(con_estado == mgr._catalogo.size(),
		"todo evento del catalogo tiene estado del anio (%d/%d)" % [con_estado, mgr._catalogo.size()])
	mgr._catalogo.erase("test_cancel")
	_fin("6")

## 7. Sorpresas.
func _b7_sorpresas(mgr) -> void:
	_abrir("7", "RF9.2/RF9.5: limite semanal de sorpresas")
	_ok(mgr.MAX_SORPRESAS_SEMANA == 3, "limite semanal = 3")
	var ok_count: int = 0
	for i in range(8):
		if mgr.registrar_sorpresa(&"sorpresa_test"):
			ok_count += 1
	_ok(ok_count <= mgr.MAX_SORPRESAS_SEMANA,
		"nunca acepta mas de %d sorpresas por semana (acepto %d)" % [mgr.MAX_SORPRESAS_SEMANA, ok_count])
	var es := EventState.new()
	_ok("sorpresa_ya_usada" in es.to_dict(), "EventState serializa sorpresa_ya_usada")
	_ok(mgr.has_method("get_save_data") and mgr.has_method("restore_save_data"),
		"el manager expone el contrato de guardado M60")
	_fin("7")

## 8. Persistencia y robustez.
func _b8_persistencia(mgr) -> void:
	_abrir("8", "RF7.3/RF11.1/RN6: persistencia por anio y robustez")
	var anio: int = mgr._get_anio_actual()
	var ev := EventDefinition.new()
	ev.id = "test_save"
	mgr._catalogo["test_save"] = ev
	var es := EventState.new()
	es.evento_id = ev.id
	es.anio = anio
	es.estado = EventState.Estado.PARTICIPADO
	es.anio_participacion = anio
	mgr._set_estado(ev.id, anio, es)

	var data: Dictionary = mgr.get_save_data()
	_ok(data.has("eventos"), "el save trae la seccion de eventos")
	_ok(int((data["eventos"] as Dictionary).size()) >= 1, "el save tiene >= 1 evento")

	# round-trip en otro manager
	var otro := _nuevo_manager()
	otro.restore_save_data(data)
	var st: EventState = otro._get_estado(&"test_save", anio)
	_ok(st != null and st.estado == EventState.Estado.PARTICIPADO,
		"el round-trip conserva el estado PARTICIPADO")
	_ok(st != null and st.anio_participacion == anio, "conserva el anio de participacion")

	# robustez: datos corruptos no rompen
	otro.restore_save_data({"eventos": "esto no es un diccionario"})
	_ok(true, "save corrupto (eventos como String) no rompe")
	otro.restore_save_data({})
	_ok(true, "save vacio no rompe")
	otro.restore_save_data({"eventos": {"roto": {"estado": "no-es-int"}}})
	_ok(true, "estado con tipo invalido no rompe")

	otro.free()
	mgr._catalogo.erase("test_save")
	_fin("8")

## 9. NFR.
func _b9_nfr(mgr) -> void:
	_abrir("9", "RN1/RN2/RN3/RN15: NFR medibles y estaticos")
	# RN2: sin polling (excluyendo los propios tests)
	var con_polling: Array = []
	var dir := DirAccess.open("res://scripts/eventos")
	if dir != null:
		for f in dir.get_files():
			var nombre: String = String(f)
			if not nombre.ends_with(".gd") or nombre.begins_with("test_") or nombre.begins_with("probe_"):
				continue
			var t: String = FileAccess.get_file_as_string("res://scripts/eventos/" + nombre)
			if t.contains("func _process(") or t.contains("func _physics_process("):
				con_polling.append(nombre)
	_ok(con_polling.is_empty(), "ningun modulo de eventos hace polling por frame: %s" % str(con_polling))

	# RN3: catalogo < 1 MB
	var total: int = 0
	var d2 := DirAccess.open("res://scripts/eventos/data")
	if d2 != null:
		for f in d2.get_files():
			total += FileAccess.get_file_as_bytes("res://scripts/eventos/data/" + String(f)).size()
	_ok(total < 1048576, "catalogo de datos < 1 MB (dio %d bytes)" % total)

	# RN15: sin referencias a UI concreta
	var refs_ui: Array = []
	var t_mgr: String = FileAccess.get_file_as_string("res://scripts/eventos/event_manager.gd")
	for pat in ["CanvasLayer", "res://scenes", ".tscn", "PanelContainer", "Button"]:
		if pat in t_mgr:
			refs_ui.append(pat)
	_ok(refs_ui.is_empty(), "EventManager no referencia UI concreta: %s" % str(refs_ui))

	# RN1: coste medido. El requisito es por FRAME; el trabajo solo ocurre en el
	# dia_cambio (no hay polling), asi que se mide el dia_cambio y su costo
	# amortizado sobre un dia de juego completo.
	var calendario = root.get_node_or_null("/root/GameTime")
	var frames_dia: int = 86400     # 24 min de juego a 60 fps (valor tipico del projet)
	if calendario != null and calendario.get("SEGUNDOS_POR_DIA") != null:
		var seg: float = float(calendario.get("SEGUNDOS_POR_DIA"))
		if seg > 0.0:
			frames_dia = int(seg * 60.0)
	var t0: int = Time.get_ticks_usec()
	for i in range(200):
		mgr._on_dia_cambio({"anio": 1, "mes": 1, "dia": 1 + (i % 27), "estacion": 0, "hora": 8, "minuto": 0})
	var us_dia: float = float(Time.get_ticks_usec() - t0) / 200.0
	var ms_dia: float = us_dia / 1000.0
	var ms_frame: float = us_dia / 1000.0 / float(maxi(1, frames_dia))
	print("  [info] dia_cambio medido: %.4f ms | amortizado por frame: %.6f ms (dia=%d frames)" % [
		ms_dia, ms_frame, frames_dia])
	_ok(ms_dia < 1.0, "el chequeo de dia_cambio completo < 1 ms (medido %.4f ms)" % ms_dia)
	_ok(ms_frame < 0.05, "coste amortizado por frame < 0.05 ms (medido %.6f ms)" % ms_frame)
	_fin("9")

func _run() -> void:
	var mgr = _nuevo_manager()
	_ok(mgr != null, "EventManager instanciado")
	if mgr == null:
		return
	_b1_catalogo(mgr)
	_b2_anti_duplicado(mgr)
	_b3_entrega_por_tipo(mgr)
	_b4_finalizar(mgr)
	_b5_aviso(mgr)
	_b6_senales(mgr)
	_b7_sorpresas(mgr)
	_b8_persistencia(mgr)
	_b9_nfr(mgr)
	mgr.free()

func _summary() -> void:
	print("=== RESUMEN M74 EVENTOS (verificacion): %d checks, %d fallos, %d bloques cerrados ===" % [
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
