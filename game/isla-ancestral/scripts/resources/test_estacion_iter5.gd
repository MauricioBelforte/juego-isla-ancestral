# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-11
#
# M15 iter 5: test del handler de cambio de estación (L.1/L.2).
# Valida con la SEÑAL REAL del motor (estacion_cambio de GameTime):
#   1. ResourceManager queda conectado a estacion_cambio (get_connections).
#   2. Nodo estacional AGOTADO respawnea SOLO cuando la estación coincide.
#   3. Nodo "todas las estaciones" (respawn_estacion == -1) respawnea en
#      cualquier cambio de estación (vía señal real del motor).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/resources/test_estacion_iter5.gd

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
		print("=== TEST M15 ITER5: %d fallo(s) ===" % _fallos)
		quit(1)
		return
	_test_conexion_estacion_cambio()
	_test_respawn_estacional_filtrado()
	_test_respawn_todas_estaciones_via_senal_real()
	print("=== TEST M15 ITER5: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## ── Test 1: el manager queda conectado a estacion_cambio (L.1) ────────────
func _test_conexion_estacion_cambio() -> void:
	_check(_gt.has_signal("estacion_cambio"), "GameTime tiene señal estacion_cambio")
	var conexiones: Array = _gt.estacion_cambio.get_connections()
	var conectado: bool = false
	for c in conexiones:
		if c.callable.get_object() == _rm:
			conectado = true
	_check(conectado, "ResourceManager conectado a estacion_cambio (L.1)")
	# Bandera idempotente: reconectar no debe duplicar (patrón dia_cambio)
	_rm._conectar_estacion_cambio()
	var n: int = 0
	for c in _gt.estacion_cambio.get_connections():
		if c.callable.get_object() == _rm:
			n += 1
	_check(n == 1, "conexión idempotente (1 sola tras re-llamar, n=%d)" % n)

## ── Test 2: nodo estacional AGOTADO respawnea solo con estación exacta ────
## Usa la señal REAL del motor. Para que la emisión sea coherente con el
## reloj (como en runtime real), se setea _mes Y se emite la señal — patrón
## del test oficial de M16 (test_crafting.gd L229, _mes=4 + emit verano).
func _test_respawn_estacional_filtrado() -> void:
	# Nodo de PRIMAVERA (estacion 0): cristal estacional no existe en el
	# catálogo base, así que se construye una def ad-hoc con respawn estacional.
	var def := ResourceDefinition.new()
	def.def_id = &"test_estacional_iter5"
	def.categoria = ResourceDefinition.Categoria.RARO
	def.golpes_requeridos = 1
	def.herramienta_requerida = &"pico"
	def.temporada_respawn = &"primavera"
	var nodo := ResourceNode.new()
	nodo.configurar(def)
	root.add_child(nodo)
	nodo.global_position = Vector3(710, 30, 710)
	_rm.registrar_nodo(nodo)
	_check(nodo.respawn_estacion == 0, "def primavera → respawn_estacion=0")
	# Agotar con respawn ya vencido
	nodo.estado = ResourceNode.Estado.AGOTADO
	nodo.golpes_restantes = 0
	nodo.programar_respawn(_gt.dia_absoluto())  # vencido
	nodo._actualizar_mesh()
	var mes_original: int = _gt._mes
	# Cambio REAL de estación a VERANO (mes 4, estación 1): NO debe respawnear
	_gt._mes = 4
	_gt.emit_signal("estacion_cambio", 1)
	_check(nodo.estado == ResourceNode.Estado.AGOTADO, "estación equivocada (verano): nodo queda AGOTADO")
	# Cambio a PRIMAVERA (mes 1, estación 0): SÍ respawnea
	_gt._mes = 1
	_gt.emit_signal("estacion_cambio", 0)
	_check(nodo.estado == ResourceNode.Estado.INTACTO, "estación correcta (primavera): nodo respawnea vía señal real")
	# Limpieza: restaurar mes del reloj
	_rm.desregistrar_nodo(nodo)
	nodo.queue_free()
	_gt._mes = mes_original
	_gt.emit_signal("estacion_cambio", _gt.get_estacion())

## ── Test 3: nodo "todas las estaciones" respawnea en cualquier cambio ────
## (respawn_estacion == -1: piedra_caliza del catálogo base). Señal REAL.
func _test_respawn_todas_estaciones_via_senal_real() -> void:
	var nodo := ResourceNode.new()
	nodo.configurar(_rm.obtener_def(&"piedra_caliza"))  # temporada "todas"
	root.add_child(nodo)
	nodo.global_position = Vector3(720, 30, 720)
	_rm.registrar_nodo(nodo)
	_check(nodo.respawn_estacion == -1, "piedra_caliza → respawn_estacion=-1 (todas)")
	nodo.estado = ResourceNode.Estado.AGOTADO
	nodo.golpes_restantes = 0
	nodo.programar_respawn(_gt.dia_absoluto())  # vencido
	nodo._actualizar_mesh()
	var est_actual: int = _gt.get_estacion()
	var mes_original: int = _gt._mes
	# Cualquier estación distinta de la actual debe disparar el respawn
	# (mes coherente con la estación emitida — como en runtime real)
	var otra: int = (est_actual + 1) % 4
	_gt._mes = otra * 3 + 1  # mes inicial de esa estación (est*3+1)
	_gt.emit_signal("estacion_cambio", otra)
	_check(nodo.estado == ResourceNode.Estado.INTACTO, "nodo todas-estaciones respawnea en cambio a estación %d vía señal real" % otra)
	# Limpieza + restaurar mes del reloj
	_rm.desregistrar_nodo(nodo)
	nodo.queue_free()
	_gt._mes = mes_original
	_gt.emit_signal("estacion_cambio", _gt.get_estacion())
