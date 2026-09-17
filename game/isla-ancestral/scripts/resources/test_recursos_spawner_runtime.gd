# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-10
#
# M15 iter 4: test de persistencia del ResourceSpawner (regiones/presupuesto)
# + test de respawn disparado por la SEÑAL REAL GameTime.dia_cambio (M29).
# Cierra los [?] de la iter 3 (05-Checklist L279-L280).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/resources/test_recursos_spawner_runtime.gd

extends SceneTree

var _fallos: int = 0
var _rm: Node = null
var _gt: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_rm = root.get_node_or_null("ResourceManager")
	_gt = root.get_node_or_null("GameTime")
	_check(_rm != null, "ResourceManager autoload presente")
	_check(_gt != null, "GameTime autoload presente")
	if _rm == null or _gt == null:
		print("=== TEST M15 ITER4: %d fallo(s) ===" % _fallos)
		quit(1)
		return
	_test_persistencia_spawner_round_trip()
	_test_idempotencia_planificar()
	_test_respawn_via_senal_real_dia_cambio()
	print("=== TEST M15 ITER4: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## ── Test 1: round-trip de la persistencia del spawner ────────────────────
## Planifica una región de prueba, agota un nodo, guarda, crea un spawner
## nuevo, restaura y verifica: región restaurada + nodo agotado con su
## estado + intactos regenerados (guardado chico).
func _test_persistencia_spawner_round_trip() -> void:
	var spawner: ResourceSpawner = _rm.spawner
	_check(spawner != null, "spawner disponible en ResourceManager")
	if spawner == null:
		return
	# Limpiar estado previo de tests (regiones de arranque si las hubo)
	var region_test := "test_region_iter4"
	_check(not spawner.region_planificada(region_test), "región test NO planificada al inicio")
	# Planificar región de prueba (centro lejos del spawn para no chocar)
	spawner.planificar_region(region_test, Vector3(500, 30, 500), _rm)
	_check(spawner.region_planificada(region_test), "región test planificada")
	var nodos_antes: int = spawner.nodos_activos()
	_check(nodos_antes > 0, "planificar creó nodos (n=%d)" % nodos_antes)
	# Agotar el PRIMER nodo de la región para tener un estado no-intacto
	var nodos: Dictionary = spawner.obtener_nodos()
	var nodo_agotado: ResourceNode = null
	for nid in nodos:
		var n: ResourceNode = nodos[nid]
		if n != null and is_instance_valid(n) and String(n.def_id) == "piedra_caliza":
			n.estado = ResourceNode.Estado.AGOTADO
			n.golpes_restantes = 0
			n.respawn_dia_absoluto = _gt.dia_absoluto() + 2
			n._actualizar_mesh()
			nodo_agotado = n
			break
	_check(nodo_agotado != null, "nodo piedra_caliza encontrado para agotar")
	# Guardar estado del spawner
	var save: Dictionary = spawner.get_save_data()
	_check(int(save.get("version", 0)) == 1, "save spawner version=1")
	var regiones_save: Dictionary = save.get("regiones", {})
	_check(regiones_save.has(region_test), "save incluye región test")
	var reg: Dictionary = regiones_save.get(region_test, {})
	var centro: Array = reg.get("centro", [])
	_check(centro.size() == 3 and absf(float(centro[0]) - 500.0) < 0.1, "centro región guardado (x=500)")
	# Solo nodos no-intactos se serializan (ítem O.3)
	var guardados: Array = reg.get("nodos", [])
	_check(guardados.size() == 1, "solo 1 nodo no-intacto serializado (n=%d)" % guardados.size())
	if guardados.size() == 1:
		var nd: Dictionary = guardados[0]
		_check(String(nd.get("def_id", "")) == "piedra_caliza", "def_id guardado correcto")
		_check(int(nd.get("estado", -1)) == ResourceNode.Estado.AGOTADO, "estado AGOTADO guardado")
		_check(int(nd.get("respawn_dia", -1)) == _gt.dia_absoluto() + 2, "respawn_dia guardado")
	# Restaurar en un spawner NUEVO (simula carga de partida)
	var spawner2 := ResourceSpawner.new(_rm)
	root.add_child(spawner2)
	spawner2.restore_save_data(save)
	_check(spawner2.region_planificada(region_test), "región restaurada en spawner nuevo")
	_check(spawner2.nodos_activos() == 1, "1 nodo re-instanciado al restaurar (n=%d)" % spawner2.nodos_activos())
	# El nodo restaurado conserva el estado AGOTADO
	var restaurado: ResourceNode = spawner2._buscar_nodo_por_def_y_pos("piedra_caliza", nodo_agotado.global_position.x, nodo_agotado.global_position.z)
	_check(restaurado != null, "nodo restaurado encontrado por def+pos")
	if restaurado != null:
		_check(restaurado.estado == ResourceNode.Estado.AGOTADO, "nodo restaurado queda AGOTADO")
		_check(restaurado.respawn_dia_absoluto == _gt.dia_absoluto() + 2, "respawn_dia restaurado")
	# planificar_region NO duplica tras restaurar (ítem L.6)
	var activos_antes: int = spawner2.nodos_activos()
	spawner2.planificar_region(region_test, Vector3(500, 30, 500), _rm)
	_check(spawner2.nodos_activos() == activos_antes, "planificar tras restore no duplica (L.6)")
	# Limpieza
	for n in spawner2.obtener_nodos().values():
		if n != null and is_instance_valid(n):
			_rm.desregistrar_nodo(n)
			n.queue_free()
	spawner2.queue_free()

## ── Test 2: idempotencia de planificar_region ───────────────────────────
## Planificar 2 veces la misma región no debe duplicar nodos.
func _test_idempotencia_planificar() -> void:
	var spawner: ResourceSpawner = _rm.spawner
	if spawner == null:
		return
	var region_id := "test_region_idem"
	if spawner.region_planificada(region_id):
		return  # ya cubierto por el test 1 (skip honesto)
	spawner.planificar_region(region_id, Vector3(600, 30, 600), _rm)
	var n1: int = spawner.nodos_activos()
	spawner.planificar_region(region_id, Vector3(600, 30, 600), _rm)
	var n2: int = spawner.nodos_activos()
	_check(n1 == n2, "planificar 2x misma región no duplica (%d == %d)" % [n1, n2])

## ── Test 3: respawn vía SEÑAL REAL de GameTime.dia_cambio (T-153) ────────
## Valida el flujo runtime completo: nodo AGOTADO con respawn_dia vencido
## → GameTime avanza a medianoche → _nuevo_dia() emite dia_cambio REAL →
## ResourceManager._on_dia_cambio_m29 → _evaluar_respawn_global →
## nodo.evaluar_respawn → vuelve a INTACTO. NADA de esto es mockeado:
## se usa avanzar_hasta() de M29 para cruzar las 24:00 reales del reloj.
func _test_respawn_via_senal_real_dia_cambio() -> void:
	var spawner: ResourceSpawner = _rm.spawner
	if spawner == null:
		return
	# Crear nodo registrado (patrón del test iter 3: add_child antes de pos)
	var nodo := ResourceNode.new()
	nodo.configurar(_rm.obtener_def(&"piedra_caliza"))  # temporada "todas" → estación -1
	root.add_child(nodo)
	nodo.global_position = Vector3(700, 30, 700)
	_rm.registrar_nodo(nodo)
	# Agotar con respawn para HOY (día actual) → debe respawnear al próximo día
	nodo.estado = ResourceNode.Estado.AGOTADO
	nodo.golpes_restantes = 0
	nodo.programar_respawn(_gt.dia_absoluto())  # vence hoy mismo
	nodo._actualizar_mesh()
	_check(nodo.estado == ResourceNode.Estado.AGOTADO, "nodo AGOTADO antes del día")
	_check(nodo.esta_listo_para_respawn(), "nodo listo para respawn")
	# Cruzar medianoche con el reloj REAL de M29 (avanzar_hasta nunca se usó
	# con spam de señales: una sola llamada, avanza minutos hasta la 0:00).
	# Estrategia: si la hora actual es <23, saltar a 23:30 y de ahí a 00:30.
	var hora_ini: int = _gt.get_hora()
	if hora_ini < 23:
		_gt.avanzar_hasta(23, 30)
	_check(_gt.get_hora() == 23, "reloj en 23:xx antes de medianoche")
	_gt.avanzar_hasta(0, 10)  # cruza las 24:00 → dispara dia_cambio REAL
	_check(_gt.get_hora() == 0, "reloj cruzó medianoche (hora=0)")
	# La señal real ya corrió: el manager evaluó el respawn global
	_check(nodo.estado == ResourceNode.Estado.INTACTO, "nodo respawneó a INTACTO vía señal real dia_cambio")
	_check(nodo.respawn_dia_absoluto == 0, "respawn_dia reseteado tras respawn real")
	# Limpieza
	_rm.desregistrar_nodo(nodo)
	nodo.queue_free()
