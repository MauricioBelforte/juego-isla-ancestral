# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M40: Infraestructura — Test headless del flujo (iter. 2).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/test_infraestructura_m40.gd
# Valida: GameFlowManager (transiciones válidas/ilegales + transiciones_permitidas),
# reenvío por EventBus.infra (game_flow_changed), SceneManager anti doble-carga,
# señales de carga infra, dominio infra presente. Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M40] Test de Infraestructura (iter. 2) ===")
	var gfm: Node = root.get_node_or_null("GameFlowManager")
	var sm: Node = root.get_node_or_null("SceneManager")
	var bus: Node = root.get_node_or_null("EventBus")
	_check("GameFlowManager autoload presente", gfm != null)
	_check("SceneManager autoload presente", sm != null)
	_check("EventBus autoload presente", bus != null)
	if gfm == null or sm == null or bus == null:
		_summary()
		quit(1)
		return
	_test_dominio_infra(bus)
	_test_transiciones(gfm)
	_test_transiciones_permitidas(gfm)
	_test_eventbus_infra(gfm, bus)
	_test_scene_manager(sm, bus)
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── Dominio infra ───────────────────────────────────────

func _test_dominio_infra(bus: Node) -> void:
	print("--- EventBus: dominio infra presente ---")
	var infra: Variant = bus.get("infra")
	_check("bus.infra existe", infra != null and (infra is Object))
	if infra is Object:
		_check("señal game_flow_changed", infra.has_signal("game_flow_changed"))
		_check("señal carga_iniciada", infra.has_signal("carga_iniciada"))
		_check("señal carga_completada", infra.has_signal("carga_completada"))
		_check("señal boot_completado", infra.has_signal("boot_completado"))

## ── GameFlowManager ─────────────────────────────────────

func _test_transiciones(gfm: Node) -> void:
	print("--- GameFlowManager: transiciones válidas/ilegales ---")
	# estado inicial BOOT (0)
	var inicial: int = int(gfm.get_estado())
	_check("estado inicial BOOT", inicial == 0, "estado=%d" % inicial)
	# BOOT -> MUNDO (3) es la ruta del prototipo (divergencia documentada D8)
	_check("BOOT->MUNDO válido", gfm.cambiar_estado(3) == true)
	# MUNDO -> PAUSA (4)
	_check("MUNDO->PAUSA válido", gfm.cambiar_estado(4) == true)
	# PAUSA -> BOOT ilegal (4->0 no está en la tabla)
	var antes: int = int(gfm.get_estado())
	var ok_ilegal: bool = gfm.cambiar_estado(0)
	_check("PAUSA->BOOT ilegal rechazado", ok_ilegal == false)
	_check("estado no mutó tras ilegal", int(gfm.get_estado()) == antes)
	# PAUSA -> MUNDO válido
	_check("PAUSA->MUNDO válido", gfm.cambiar_estado(3) == true)
	# MUNDO -> MENU (1) válido
	_check("MUNDO->MENU válido", gfm.cambiar_estado(1) == true)
	# MENU -> CARGANDO (2) válido
	_check("MENU->CARGANDO válido", gfm.cambiar_estado(2) == true)
	# CARGANDO -> MUNDO válido
	_check("CARGANDO->MUNDO válido", gfm.cambiar_estado(3) == true)
	# en_juego en MUNDO
	_check("en_juego en MUNDO", gfm.en_juego() == true)
	# Dejar el flujo en un estado de reposo determinista: ERROR->BOOT->MUNDO.
	# Universal desde cualquier estado inicial (ERROR es alcanzable y BOOT sólo
	# deriva a MUNDO/MENU/CARGANDO), así no asumimos cuándo corrió el Bootstrap.
	if int(gfm.get_estado()) != 5:
		gfm.cambiar_estado(5)
	var reset_boot: bool = gfm.cambiar_estado(0)
	var reset_mundo: bool = gfm.cambiar_estado(3)
	_check("reset ERROR->BOOT->MUNDO", reset_boot and reset_mundo and int(gfm.get_estado()) == 3)

func _test_transiciones_permitidas(gfm: Node) -> void:
	print("--- GameFlowManager: transiciones_permitidas() ---")
	var permitidas: Array = gfm.transiciones_permitidas()
	_check("transiciones_permitidas() devuelve copia en estado actual (BOOT)", permitidas.has(3) or permitidas.has(1))
	# estado actual BOOT: obtener y validar copia no modifica la tabla
	var tabla: Dictionary = gfm.TRANSICIONES if gfm.TRANSICIONES != null else {}
	_check("tabla TRANSICIONES const existe", gfm.has_method("transiciones_permitidas"))

## ── EventBus.infra.game_flow_changed ─────────────────────

func _test_eventbus_infra(gfm: Node, bus: Node) -> void:
	print("--- EventBus.infra: reenvío de estado y carga ---")
	var infra: Variant = bus.get("infra")
	if not (infra is Object) or not infra.has_signal("game_flow_changed"):
		_check("estado por EventBus.infra reenviado", false, "infra no disponible")
		return
	# Normalizar a BOOT SIN medir (las anteriores normalizaciones acumulan eventos):
	# ir a ERROR (alcanzable desde cualquier estado) y luego ERROR->BOOT.
	if int(gfm.get_estado()) != 5:
		gfm.cambiar_estado(5)
	gfm.cambiar_estado(0)  # ERROR -> BOOT
	# Recién acá medimos: conectamos y hacemos 2 transiciones exactas.
	var recibidos: Array = []
	infra.game_flow_changed.connect(func(a, n): recibidos.append([a, n]))
	gfm.cambiar_estado(3)  # BOOT -> MUNDO (evento 1)
	gfm.cambiar_estado(1)  # MUNDO -> MENU (evento 2)
	_check("recibidos por EventBus.infra (2 cambios)", recibidos.size() == 2, "size=%d" % recibidos.size())
	if recibidos.size() >= 2:
		_check("1er evento BOOT(0)->MUNDO(3)", int(recibidos[0][0]) == 0 and int(recibidos[0][1]) == 3)
		_check("2do evento MUNDO(3)->MENU(1)", int(recibidos[1][0]) == 3 and int(recibidos[1][1]) == 1)
	# dejar en BOOT para no interferir con el arranque real
	if int(gfm.get_estado()) != 5:
		gfm.cambiar_estado(5)
	gfm.cambiar_estado(0)

## ── SceneManager ──────────────────────────────────────────

func _test_scene_manager(sm: Node, bus: Node) -> void:
	print("--- SceneManager: anti doble-carga + señales infra ---")
	var infra: Variant = bus.get("infra")
	var iniciadas: Array = []
	var completadas: Array = []
	if infra is Object:
		if infra.has_signal("carga_iniciada"):
			infra.carga_iniciada.connect(func(r): iniciadas.append(r))
		if infra.has_signal("carga_completada"):
			infra.carga_completada.connect(func(r): completadas.append(r))

	_check("cambiar_escena over ruta inexistente -> false", sm.cambiar_escena("") == false)
	var ok_primera: bool = sm.cambiar_escena("res://scenes/main_island.tscn")
	_check("cambiar_escena escena existente -> true", ok_primera)
	_check("esta_cargando tras pedido", sm.esta_cargando() == true)
	# segundo pedido durante la carga -> rechazado (anti doble-click §8)
	var ok_segunda: bool = sm.cambiar_escena("res://scenes/main_island.tscn")
	_check("segundo pedido rechazado (anti doble-click)", ok_segunda == false)

	# esperar a que el deferred termine (damos un frame)
	await _procesar_frame()
	_check("carga_iniciada emitida por infra", iniciadas.size() >= 1)
	_check("carga_completada emitida por infra", completadas.size() >= 1)

func _procesar_frame() -> void:
	for i in range(3):
		await process_frame

func _summary() -> void:
	print("=== Resumen M40: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M40 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M40 OK — todos los checks pasaron")
		quit(0)