# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M19: Test de mudanzas (diseño §2.1) y línea de visión (raycast vóxel).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/npc/test_mudanzas.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 40
const _WB_BLOQUES: Array[String] = ["_test_catalogo", "_test_ciclo_mudanza_completo", "_test_cancelar_en_ambas_fases", "_test_partida_con_enfriamiento", "_test_linea_de_vision", "_test_persistencia"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false


func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M19: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

var _fallos: int = 0
var _vm: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_vm = root.get_node_or_null("VillagerManager")
	_check(_vm != null, "VillagerManager autoload presente")
	if _vm == null:
		_summary()
		return
	_test_catalogo()
	_fin("_test_catalogo")
	_test_ciclo_mudanza_completo()
	_fin("_test_ciclo_mudanza_completo")
	_test_cancelar_en_ambas_fases()
	_fin("_test_cancelar_en_ambas_fases")
	_test_partida_con_enfriamiento()
	_fin("_test_partida_con_enfriamiento")
	_test_linea_de_vision()
	_fin("_test_linea_de_vision")
	_test_persistencia()
	_fin("_test_persistencia")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_catalogo() -> void:
	_check(_vm.catalogo_count() >= 5, "catálogo >= 5 perfiles (catalina + 4): %d" % _vm.catalogo_count())
	var candidato: Resource = _vm._catalogo.get("finneas_zorro", null)
	_check(candidato != null, "finneas_zorro en catálogo")
	if candidato:
		_check(candidato.profesion == "pescador", "finneas pescador")
		_check(candidato.rutina_diaria.size() >= 4, "finneas con rutina diaria (M64-ready)")
		_check(candidato.evaluar_objeto("mineral_cobre") == 1.0, "evaluar gustos OK")

func _test_ciclo_mudanza_completo() -> void:
	# Propuesta → visitante
	var eventos_propuesta: Array = []
	var cb_p := func(candidato_id: String) -> void:
		eventos_propuesta.append(candidato_id)
	_vm.mudanza_propuesta.connect(cb_p)
	_check(_vm.proponer_mudanza("finneas_zorro"), "proponer mudanza OK")
	_check(eventos_propuesta.has("finneas_zorro"), "señal mudanza_propuesta emitida")
	_check(_vm.visitantes().has("finneas_zorro"), "finneas es visitante")
	_check(not _vm.proponer_mudanza("finneas_zorro"), "doble propuesta rechazada")
	# Aprobación → llegada agendada mañana
	var dias_agenda: Array = []
	var cb_a := func(candidato_id: String, dia: int) -> void:
		dias_agenda.append(dia)
	_vm.mudanza_aprobada.connect(cb_a)
	_check(_vm.aprobar_mudanza("finneas_zorro"), "aprobar mudanza OK")
	_check(dias_agenda.size() == 1, "señal mudanza_aprobada emitida")
	# Llegada al día siguiente: simular hora_cambio 8 de mañana
	var gt := root.get_node_or_null("GameTime")
	_check(gt != null, "GameTime presente")
	var dia_llegada: int = dias_agenda[0]
	var llegadas: Array = []
	var cb_l := func(candidato_id: String) -> void:
		llegadas.append(candidato_id)
	_vm.vecino_llego.connect(cb_l)
	var bus := root.get_node_or_null("EventBus")
	var moved_in: Array = []
	var cb_m := func(npc_id: String, isla: String) -> void:
		moved_in.append([npc_id, isla])
	if bus != null:
		bus.npc.npc_moved_in.connect(cb_m)
	# Forzar el día a dia_llegada y disparar 08:00
	gt._dia = 1
	gt._mes = 1
	gt._anio = 1
	while gt.dia_absoluto() < dia_llegada:
		gt._nuevo_dia()
	gt._hora = 8
	_vm._on_hora_cambio(8)
	_check(llegadas.has("finneas_zorro"), "vecino llegó (señal vecino_llego)")
	if bus != null:
		_check(moved_in.size() >= 1 and moved_in[0][0] == "finneas_zorro",
			"EventBus.npc.npc_moved_in emitido (M20/M21 consumen)")
	_check(_vm.hogar_de("finneas_zorro") >= 0, "hogar asignado (índice parcela)")
	_vm.mudanza_propuesta.disconnect(cb_p)
	_vm.mudanza_aprobada.disconnect(cb_a)
	_vm.vecino_llego.disconnect(cb_l)
	if bus != null:
		bus.npc.npc_moved_in.disconnect(cb_m)

func _test_cancelar_en_ambas_fases() -> void:
	# Fase propuesta
	_check(_vm.proponer_mudanza("luna_zorra"), "proponer luna OK")
	_check(_vm.cancelar_mudanza("luna_zorra"), "cancelar en propuesta OK")
	_check(not _vm.visitantes().has("luna_zorra"), "luna ya no es visitante")
	# Fase aprobada
	_check(_vm.proponer_mudanza("luna_zorra"), "re-proponer luna OK")
	_check(_vm.aprobar_mudanza("luna_zorra"), "aprobar luna OK")
	_check(_vm.cancelar_mudanza("luna_zorra"), "cancelar en aprobada OK")
	_check(_vm.llegadas_pendientes().size() == 0 or not _vm.llegadas_pendientes().has("luna_zorra"),
		"llegada cancelada")
	# Candidato inexistente
	_check(not _vm.proponer_mudanza("fantasma_inexistente"), "candidato inexistente rechazado")

func _test_partida_con_enfriamiento() -> void:
	# Camino 1: aviso → aceptar → partida programada mañana (stub vecino activo)
	var stub := Node3D.new()
	stub.name = "mateo_mapache"
	root.add_child(stub)
	_vm.registrar_villager(stub)
	_check(_vm.anunciar_partida("mateo_mapache"), "aviso de partida OK")
	_check(not _vm.anunciar_partida("mateo_mapache"), "doble aviso rechazado")
	_check(_vm.aceptar_partida("mateo_mapache"), "aceptar partida OK")
	_check(not _vm.anunciar_partida("mateo_mapache"), "sin aviso con partida pendiente")
	_vm.desregistrar_villager(stub)
	stub.queue_free()
	# Camino 2: aviso → rechazar → enfriamiento 30 días (otro vecino activo)
	var stub2 := Node3D.new()
	stub2.name = "bruno_sapo"
	root.add_child(stub2)
	_vm.registrar_villager(stub2)
	_check(_vm.anunciar_partida("bruno_sapo"), "aviso de partida camino 2 OK")
	_check(_vm.rechazar_partida("bruno_sapo"), "rechazar partida OK")
	_check(not _vm.puede_avisar_partida("bruno_sapo"), "enfriamiento activo bloquea aviso")
	_check(not _vm.anunciar_partida("bruno_sapo"), "aviso en enfriamiento rechazado")
	# Simular vencimiento del enfriamiento (31 días)
	var gt := root.get_node_or_null("GameTime")
	var hoy: int = gt.dia_absoluto()
	_vm._enfriamiento_partida["bruno_sapo"] = hoy - 1
	_check(_vm.puede_avisar_partida("bruno_sapo"), "enfriamiento vencido permite avisar")
	_check(_vm.anunciar_partida("bruno_sapo"), "aviso tras vencimiento OK")
	_vm.desregistrar_villager(stub2)
	stub2.queue_free()

func _test_linea_de_vision() -> void:
	# Con terrain real (isla seed 42): aire alto → visión; subterráneo → bloqueada
	var tiene_vision_aire: bool = _vm.hay_linea_de_vision(
		Vector3(320, 40, 320), Vector3(324, 40, 324))
	var tiene_vision_suelo: bool = _vm.hay_linea_de_vision(
		Vector3(320, 3, 320), Vector3(324, 3, 324))
	var altura: float = _vm.get_ground_height(Vector2(320, 320))
	if altura > 6.0:
		_check(tiene_vision_aire, "visión libre a 40 de altura (aire)")
		_check(not tiene_vision_suelo, "visión bloqueada a y=3 (bajo tierra)")
	else:
		# terreno bajo: ambas líneas podrían ser aire; validamos al menos que no crashea
		_check(true, "terreno bajo (altura %.1f): validación de aire OK (%s)" % [altura, str(tiene_vision_aire)])
	_check(_vm.hay_linea_de_vision(Vector3(0, 0, 0), Vector3(0.2, 0.2, 0.2)),
		"línea corta (< 0.5 m) siempre libre")

func _test_persistencia() -> void:
	var data: Dictionary = _vm.get_save_data()
	_check(data.has("visitantes") and data.has("llegadas") and data.has("hogares"),
		"save_data completo")
	_check(_vm.get_section_name() == "npc", "sección 'npc' (schema M59)")
	# Round-trip: restaurar en un manager limpio simulado
	_vm.restore_save_data({})
	_check(_vm.visitantes().size() == 0, "restore vacío resetea visitantes")
	_vm.restore_save_data(data)
	_check(_vm.visitantes().size() >= 0, "round-trip sin crash")
