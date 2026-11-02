# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01 (iter. 2) / 2026-11-01 (iter. 3 — M40 b3, integración flujo<->escena)
#
# M40: Infraestructura — Test headless del flujo.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/test_infraestructura_m40.gd
# Valida: GameFlowManager (transiciones válidas/ilegales + transiciones_permitidas),
# reenvío por EventBus.infra (game_flow_changed), integración SceneManager <-> flujo
# (modo/estado_flujo/sincronizar_flujo/escena_actual/verificar), SceneManager
# anti doble-carga, señales de carga infra. Exit code != 0 si falla.
#
# DEFECTO CORREGIDO EN ITER. 3 (medido antes y después): `_test_scene_manager` es
# una corrutina (hace `await process_frame`) y se llamaba SIN `await` desde `_run`,
# así que `_summary()` corría antes de que la corrutina despertara y `quit(0)`
# cerraba el árbol: los 2 últimos checks NUNCA se ejecutaban y la suite publicaba
# "28 checks, 0 fallos / todos los checks pasaron". Ahora `_run` hace `await`.
# Capas de guarda (trampa del falso verde por aborto de runtime): `_fin()` al
# final del CUERPO de cada bloque (nombra el bloque que no corrió) + piso
# `CHECKS_MINIMOS` MEDIDO en verde (nunca estimado).

extends SceneTree

const BLOQUES: Array[String] = [
	"presencia", "infra", "transiciones", "permitidas", "eventbus",
	"integracion_flujo", "scene_manager",
]

## Piso MEDIDO en verde el 2026-11-01 (iter. 3): 60 checks reales, 7 bloques.
const CHECKS_MINIMOS: int = 60

var _fallos: int = 0
var _checks: int = 0
var _vistos: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M40] Test de Infraestructura (iter. 3) ===")
	var gfm: Node = root.get_node_or_null("GameFlowManager")
	var sm: Node = root.get_node_or_null("SceneManager")
	var bus: Node = root.get_node_or_null("EventBus")
	_check("GameFlowManager autoload presente", gfm != null)
	_check("SceneManager autoload presente", sm != null)
	_check("EventBus autoload presente", bus != null)
	_fin("presencia")
	if gfm == null or sm == null or bus == null:
		_summary()
		return

	_test_dominio_infra(bus)
	_test_transiciones(gfm)
	_test_transiciones_permitidas(gfm)
	_test_eventbus_infra(gfm, bus)
	_test_integracion_flujo(sm, gfm, bus)
	# `await` OBLIGATORIO: este bloque suspende en `await process_frame`.
	await _test_scene_manager(sm, bus)
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Marca de bloque ejecutado: va al FINAL del cuerpo del bloque, no en el llamador
## (en Godot 4 un SCRIPT ERROR aborta sólo la función y el llamador RETOMA).
func _fin(nombre: String) -> void:
	_vistos.append(nombre)
	print("  [bloque] %s (%d checks acumulados)" % [nombre, _checks])

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
	_fin("infra")

## ── GameFlowManager ─────────────────────────────────────

func _test_transiciones(gfm: Node) -> void:
	print("--- GameFlowManager: transiciones válidas/ilegales ---")
	var inicial: int = int(gfm.get_estado())
	# El orden entre los `call_deferred` de Bootstrap y los de esta suite NO es un
	# contrato: Bootstrap puede haber llevado el flujo a MUNDO (integración b3)
	# antes de llegar acá. Se aceptan los 2 estados legítimos de arranque.
	_check("estado de arranque BOOT o MUNDO", inicial == 0 or inicial == 3, "estado=%d" % inicial)
	if inicial != 0:
		gfm.cambiar_estado(5)  # cualquier estado -> ERROR
		gfm.cambiar_estado(0)  # ERROR -> BOOT
	_check("normalizado a BOOT", int(gfm.get_estado()) == 0, "estado=%d" % int(gfm.get_estado()))
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
	_fin("transiciones")

func _test_transiciones_permitidas(gfm: Node) -> void:
	print("--- GameFlowManager: transiciones_permitidas() ---")
	var permitidas: Array = gfm.transiciones_permitidas()
	_check("transiciones_permitidas() devuelve las del estado actual", permitidas.has(3) or permitidas.has(1))
	# Contrato real (antes había una aserción infalsificable: comprobaba que el
	# método existiera, no la copia). Mutar la copia NO debe tocar la tabla.
	if not permitidas.is_empty():
		var original: Array = gfm.TRANSICIONES[int(gfm.get_estado())]
		var tam_original: int = original.size()
		permitidas.append(999)
		_check("la copia es independiente de TRANSICIONES",
			gfm.TRANSICIONES[int(gfm.get_estado())].size() == tam_original)
	else:
		_check("la copia es independiente de TRANSICIONES", false, "lista vacía: no medible")
	_fin("permitidas")

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
	_fin("eventbus")

## ── Integración SceneManager <-> GameFlowManager (M40 b3) ────────────────

func _test_integracion_flujo(sm: Node, gfm: Node, bus: Node) -> void:
	print("--- Integración SceneManager <-> GameFlowManager (M40 b3) ---")
	# 1. El enum se resuelve POR NOMBRE: cero números mágicos en el cableado.
	_check("estado_flujo('MUNDO') == 3", sm.estado_flujo("MUNDO") == 3, "=%d" % sm.estado_flujo("MUNDO"))
	_check("estado_flujo('CARGANDO') == 2", sm.estado_flujo("CARGANDO") == 2, "=%d" % sm.estado_flujo("CARGANDO"))
	_check("estado_flujo('ERROR') == 5", sm.estado_flujo("ERROR") == 5, "=%d" % sm.estado_flujo("ERROR"))
	# D40-2: 03-Diseno §4 declara TRANSICION y el código no lo tiene -> -1, no un
	# estado inventado. La divergencia está declarada, no silenciada.
	_check("estado_flujo('TRANSICION') == -1 (D40-2)", sm.estado_flujo("TRANSICION") == -1,
		"=%d" % sm.estado_flujo("TRANSICION"))
	_check("estado_flujo('NO_EXISTE') == -1 (fail-closed)", sm.estado_flujo("NO_EXISTE") == -1)

	# 2. Contrato de 03-Diseno §5.5: `escena_actual()` estaba documentado y no
	# existía en disco (0 apariciones medido antes de escribirlo). En modo
	# `--script` el árbol puede no tener escena raíz todavía, así que acá se mide
	# el CONTRATO (String, "" o una ruta res://); el valor tras la carga real se
	# verifica en el bloque scene_manager.
	var escena_previa := String(sm.escena_actual())
	_check("escena_actual() devuelve String vacío o ruta res://",
		sm.has_method("escena_actual") and (escena_previa.is_empty() or escena_previa.begins_with("res://")),
		"='%s'" % escena_previa)

	# 3. Guardas de sincronizar_flujo (sin cargar ninguna escena).
	if int(gfm.get_estado()) != 0:
		gfm.cambiar_estado(5)
		gfm.cambiar_estado(0)
	_check("sincronizar_flujo(-1) rechazado", sm.sincronizar_flujo(-1) == false)
	_check("sincronizar_flujo(-1) no mutó el flujo", int(gfm.get_estado()) == 0)
	_check("sincronizar_flujo(BOOT->MUNDO) aplicado", sm.sincronizar_flujo(sm.estado_flujo("MUNDO")) == true)
	_check("el flujo quedó en MUNDO", int(gfm.get_estado()) == 3, "estado=%d" % int(gfm.get_estado()))
	# Idempotencia: ya en MUNDO -> true y CERO eventos nuevos en EventBus.infra.
	var infra: Variant = bus.get("infra")
	var eventos: Array = []
	if infra is Object and infra.has_signal("game_flow_changed"):
		infra.game_flow_changed.connect(func(a, n): eventos.append([a, n]))
	_check("sincronizar_flujo al mismo estado -> true", sm.sincronizar_flujo(3) == true)
	_check("no emitió evento redundante", eventos.is_empty(), "eventos=%d" % eventos.size())
	# Transición que la tabla prohíbe: MUNDO->BOOT -> false y estado intacto.
	_check("transición prohibida MUNDO->BOOT rechazada", sm.sincronizar_flujo(0) == false)
	_check("el flujo no mutó tras el rechazo", int(gfm.get_estado()) == 3)

	# 4. Carga fallida CON modo -> el flujo deriva a ERROR (03-Diseno §3).
	_check("cambiar_escena('', MUNDO) devuelve false", sm.cambiar_escena("", sm.estado_flujo("MUNDO")) == false)
	_check("carga fallida con modo -> flujo en ERROR", int(gfm.get_estado()) == 5,
		"estado=%d" % int(gfm.get_estado()))
	# Carga fallida SIN modo -> el flujo NO se toca (contrato previo conservado).
	gfm.cambiar_estado(0)  # ERROR -> BOOT
	_check("cambiar_escena('') sin modo devuelve false", sm.cambiar_escena("") == false)
	_check("sin modo el flujo no se toca", int(gfm.get_estado()) == 0, "estado=%d" % int(gfm.get_estado()))

	# 5. verificar(): auditoría legible, sin mutar nada.
	var info: Dictionary = sm.verificar()
	_check("verificar() trae las 5 claves",
		info.has("flujo_montado") and info.has("estado_flujo") and info.has("cargando")
		and info.has("modo_pendiente") and info.has("escena_actual"))
	_check("verificar().flujo_montado == true", bool(info.get("flujo_montado", false)))
	_check("verificar().estado_flujo coincide con el real",
		int(info.get("estado_flujo", -1)) == int(gfm.get_estado()))
	_check("verificar().modo_pendiente == -1 (sin carga en curso)",
		int(info.get("modo_pendiente", 99)) == -1)
	_check("verificar().cargando == false", bool(info.get("cargando", true)) == false)
	_fin("integracion_flujo")

## ── SceneManager ──────────────────────────────────────────

func _test_scene_manager(sm: Node, bus: Node) -> void:
	print("--- SceneManager: anti doble-carga + señales infra + flujo durante la carga ---")
	var gfm: Node = root.get_node_or_null("GameFlowManager")
	var infra: Variant = bus.get("infra")
	var iniciadas: Array = []
	var completadas: Array = []
	if infra is Object:
		if infra.has_signal("carga_iniciada"):
			infra.carga_iniciada.connect(func(r): iniciadas.append(r))
		if infra.has_signal("carga_completada"):
			infra.carga_completada.connect(func(r): completadas.append(r))

	# Dejar el flujo en BOOT para que la carga tenga un estado de partida conocido.
	if gfm != null:
		if int(gfm.get_estado()) != 5:
			gfm.cambiar_estado(5)
		gfm.cambiar_estado(0)

	_check("cambiar_escena over ruta inexistente -> false", sm.cambiar_escena("") == false)
	var ok_primera: bool = sm.cambiar_escena("res://scenes/main_island.tscn", sm.estado_flujo("MUNDO"))
	_check("cambiar_escena escena existente -> true", ok_primera)
	_check("esta_cargando tras pedido", sm.esta_cargando() == true)
	# Durante la carga el flujo debe estar en CARGANDO (03-Diseno §3).
	if gfm != null:
		_check("durante la carga el flujo es CARGANDO", int(gfm.get_estado()) == 2,
			"estado=%d" % int(gfm.get_estado()))
		_check("modo_pendiente armado en MUNDO", int(sm.verificar().get("modo_pendiente", -1)) == 3)
	# segundo pedido durante la carga -> rechazado (anti doble-click §8)
	var ok_segunda: bool = sm.cambiar_escena("res://scenes/main_island.tscn")
	_check("segundo pedido rechazado (anti doble-click)", ok_segunda == false)

	# esperar a que el deferred termine (damos un frame)
	await _procesar_frame()
	_check("carga_iniciada emitida por infra", iniciadas.size() >= 1, "n=%d" % iniciadas.size())
	_check("carga_completada emitida por infra", completadas.size() >= 1, "n=%d" % completadas.size())
	_check("esta_cargando == false al terminar", sm.esta_cargando() == false)
	# El corazón de b3: carga_completada -> flujo al estado objetivo.
	if gfm != null:
		_check("tras la carga el flujo es MUNDO (carga_completada -> MUNDO)",
			int(gfm.get_estado()) == 3, "estado=%d" % int(gfm.get_estado()))
		_check("modo_pendiente consumido", int(sm.verificar().get("modo_pendiente", 99)) == -1)
	_check("escena_actual() es la escena cargada",
		String(sm.escena_actual()) == "res://scenes/main_island.tscn", "='%s'" % String(sm.escena_actual()))
	_fin("scene_manager")

func _procesar_frame() -> void:
	for i in range(3):
		await process_frame

## ── Cierre ───────────────────────────────────────────────

func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_fallos += 1
		print("  [FAIL] bloques que NO se ejecutaron: %s" % [faltantes])
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M40: %d checks, %d fallos, %d bloques ===" % [_checks, _fallos, _vistos.size()])
	if _fallos > 0:
		print("TEST M40 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M40 OK — todos los checks pasaron")
		quit(0)
