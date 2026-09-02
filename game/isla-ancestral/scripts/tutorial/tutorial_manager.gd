# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M92: Tutorial — TutorialManager (autoload "Tutorial").
# Orquestador del tutorial integrado no intrusivo (RF1-RF19):
#   - Registro de capítulos con pasos (PISTA/SECUENCIA/CONSEJO)
#   - Triggers de señal para disparar lecciones
#   - Revalidación: si la meta ya se cumplió, se marca sin pasos redundantes
#   - Estado ACTIVO/ESPERANDO/PISTA/SKIPPED/DORMIDO
#   - Persistencia liviana (enum de capítulos completados + consejos vistos)
# No posee UI final: expone señales; M53/M58 dibujan la presentación.
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

enum Estado { ACTIVO, ESPERANDO, PISTA, CONSECUENCIA, SKIPPED, DORMIDO }

signal capitulo_iniciado(capitulo_id: String)
signal capitulo_completado(capitulo_id: String)
signal paso_mostrado(capitulo_id: String, paso: Dictionary)
signal estado_cambiado(estado: int)
## Watchdog (RF23): capítulo pausado por timeout — cozy, nunca castiga
signal capitulo_timeout(capitulo_id: String)

const SECCION_SAVE := "tutorial"
## Watchdog por capítulo (RF23): timeout configurable (checklist default 120 s)
const WATCHDOG_TIMEOUT_S: float = 120.0
## Throttle del chequeo de proximidad (presupuesto ≤ 0.2 ms/frame, checklist)
const THROTTLE_MUNDO_S: float = 0.25

var estado: int = Estado.ESPERANDO
var capitulos: Dictionary = {}   # capitulo_id -> {pasos: Array, meta: String, rejugable: bool}
var completados: Array = []
var consejos_vistos: Array = []
var activo_actual: String = ""

var _trigger_registros: Array = []  # [{senal: String, capitulo: String}]
## Triggers de acción ya emitidos (no re-disparar la misma señal de sistema)
var _senales_emitidas: Dictionary = {}
## Triggers de mundo (RF2): target_id -> {pos: Vector3, radio: float, capitulo: String, activo: bool}
var _targets_mundo: Dictionary = {}
var _throttle_mundo: float = 0.0
## Watchdog: segundos acumulados del capítulo activo
var _tiempo_capitulo_activo: float = 0.0
## Capítulos omitidos por degradación (sistema no implementado) — log una vez
var _degradados: Dictionary = {}

func _ready() -> void:
	_registrar_capitulos_base()
	_registrar_proveedor_guardado()
	_conectar_eventbus()
	_registrar_triggers_base()

## ── Capítulos base (contenido de ejemplo) ────────────────

func _registrar_capitulos_base() -> void:
	registrar_capitulo("prologo", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.PROLOGO_BIENVENIDA", "icono_tecla": ""},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.PROLOGO_MOVERSE", "meta": "mover", "icono_tecla": "mover_norte"},
	], "mover", true)
	registrar_capitulo("interactuar", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.INTERACTUAR", "meta": "interactuar", "icono_tecla": "interactuar"},
	], "interactuar", false)
	registrar_capitulo("herramienta", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.HERRAMIENTA", "icono_tecla": "colocar"},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.HERRAMIENTA_USO", "meta": "usar_herramienta", "icono_tecla": "colocar"},
	], "usar_herramienta", false)
	registrar_capitulo("vecino", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.VECINO", "meta": "charlar", "icono_tecla": "interactuar"},
	], "charlar", true)

## Registra un capítulo. Parámetros opcionales via dict "extra":
## {sistema: "NombreAutoload" (degradación si no existe), requiere_vecino_libre: bool, vecino_id: String}
func registrar_capitulo(capitulo_id: String, pasos: Array, meta: String, rejugable: bool, extra: Dictionary = {}) -> void:
	if capitulos.has(capitulo_id):
		return
	capitulos[capitulo_id] = {
		"pasos": pasos,
		"meta": meta,
		"rejugable": rejugable,
		"sistema": String(extra.get("sistema", "")),
		"requiere_vecino_libre": bool(extra.get("requiere_vecino_libre", false)),
		"vecino_id": String(extra.get("vecino_id", "")),
	}

## ── Triggers ─────────────────────────────────────────────

## Registra que una señal del sistema dispara un capítulo.
func registrar_trigger(senal: String, capitulo_id: String) -> void:
	if capitulos.has(capitulo_id):
		_trigger_registros.append({"senal": senal, "capitulo": capitulo_id})

## Llamado por sistemas del juego (M11/M13/M70/M33/M34/M35/M16).
## Revalida: si la meta ya se cumplió, marca completo sin pasos.
## Anti-duplicado: una señal de sistema solo despliega una vez (RF2 acción).
func notificar_senal(senal: String) -> void:
	if _senales_emitidas.has(senal):
		return
	for trig in _trigger_registros:
		if trig.senal == senal:
			_senales_emitidas[senal] = true
			desplegar_capitulo(trig.capitulo)


## ── Triggers avanzados (iter. 2, glm-5.3-flash 2026-09-01) ──

## Conecta señales REALES del EventBus M07 a los triggers de acción
## (RF2: primer item, primer bloque, primer uso de herramienta, primer NPC).
## Degradación grácil: si una señal no existe, se registra y se omite (RF2).
func _conectar_eventbus() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		push_warning("[M92] EventBus ausente; solo triggers manuales disponibles")
		return
	# RF2: acciones del jugador — primer ítem recogido, primer bloque colocado/roto
	var conectados: Array[String] = []
	var omitidos: Array[String] = []
	if bus.inventory != null and bus.inventory.has_signal("item_added"):
		bus.inventory.item_added.connect(func(_i, _q): notificar_senal("primer_item"))
		conectados.append("inventory.item_added")
	else:
		omitidos.append("inventory.item_added")
	if bus.world != null and bus.world.has_signal("block_placed"):
		bus.world.block_placed.connect(func(_p, _t): notificar_senal("primer_bloque"))
		conectados.append("world.block_placed")
	else:
		omitidos.append("world.block_placed")
	if bus.npc != null and bus.npc.has_signal("gift_given"):
		bus.npc.gift_given.connect(func(_n, _i, _c): notificar_senal("primer_regalo"))
		conectados.append("npc.gift_given")
	else:
		omitidos.append("npc.gift_given")
	if conectados.size() > 0:
		print("[M92] Triggers EventBus conectados: %s" % str(conectados))
	if omitidos.size() > 0:
		print("[M92] Degradación (señales sin emisor aún): %s" % str(omitidos))

## RF2: registra triggers base de acción → capítulos del tutorial
func _registrar_triggers_base() -> void:
	registrar_trigger("primer_item", "prologo")
	registrar_trigger("primer_bloque", "herramienta")
	registrar_trigger("primer_regalo", "vecino")

## RF2: trigger de mundo por proximidad (ITutorialTarget conceptual).
## Chequeo con throttle 0.25 s desde _process (presupuesto ≤0.2 ms).
func registrar_trigger_mundo(target_id: String, pos: Vector3, radio: float, capitulo_id: String) -> void:
	_targets_mundo[target_id] = {"pos": pos, "radio": radio, "capitulo": capitulo_id, "activo": true}


func desregistrar_trigger_mundo(target_id: String) -> void:
	# RF2: los triggers se registran/desregistran según mundos activos (M63)
	_targets_mundo.erase(target_id)


func activar_trigger_mundo(target_id: String, activo: bool) -> void:
	if _targets_mundo.has(target_id):
		_targets_mundo[target_id].activo = activo


func _process(delta: float) -> void:
	# RF2: proximidad del jugador a triggers de mundo (throttle)
	_throttle_mundo += delta
	if _throttle_mundo >= THROTTLE_MUNDO_S:
		_throttle_mundo = 0.0
		_chequear_proximidad()
	# RF23: watchdog del capítulo activo (timeout cozy)
	if estado == Estado.ACTIVO and activo_actual != "":
		_tiempo_capitulo_activo += delta
		if _tiempo_capitulo_activo >= WATCHDOG_TIMEOUT_S:
			_pausar_por_timeout()


func _chequear_proximidad() -> void:
	var jugador := _obtener_jugador()
	if jugador == null:
		return
	for target_id in _targets_mundo:
		var t: Dictionary = _targets_mundo[target_id]
		if not bool(t.get("activo", true)):
			continue
		# RF2: nunca disparar lecciones sobre NPCs dormidos/ocupados (M19)
		if t.has("requiere_vecino_libre") and bool(t.get("requiere_vecino_libre", false)):
			if not _vecino_libre(String(t.get("vecino_id", ""))):
				continue
		var d: float = jugador.global_position.distance_to(t.get("pos", Vector3.ZERO))
		if d <= float(t.get("radio", 0.0)):
			t.activo = false  # un trigger de mundo dispara una vez
			desplegar_capitulo(String(t.get("capitulo", "")))


## Gate M19: el vecino existe, está registrado y NO está ocupado
func _vecino_libre(vecino_id: String) -> bool:
	var vm := get_node_or_null("/root/VillagerManager")
	if vm == null:
		return true  # sin manager: no bloquear (cozy)
	var vecino: Node = vm.obtener_vecino(vecino_id)
	if vecino == null:
		return true
	if vecino.has_method("esta_disponible"):
		return vecino.esta_disponible()
	return true


func _obtener_jugador() -> Node3D:
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return null
	var players := arbol.get_nodes_in_group("player")
	if players.size() > 0 and players[0] is Node3D:
		return players[0]
	return null


## RF23: watchdog — el capítulo se PAUSA (puede re-dispararse), nunca se pierde
func _pausar_por_timeout() -> void:
	var cap := activo_actual
	_tiempo_capitulo_activo = 0.0
	activo_actual = ""
	estado = Estado.ESPERANDO
	estado_cambiado.emit(estado)
	if cap != "":
		# Permite re-despliegue futuro: el capítulo NO se marca completado
		capitulo_timeout.emit(cap)
		print("[M92] Watchdog: %s pausado tras %d s (re-disparable)" % [cap, int(WATCHDOG_TIMEOUT_S)])

## ── Despliegue de capítulos ──────────────────────────────

func desplegar_capitulo(capitulo_id: String) -> void:
	if estado == Estado.SKIPPED:
		return
	if not capitulos.has(capitulo_id):
		return
	var capitulo: Dictionary = capitulos[capitulo_id]
	if capitulo_id in completados and not bool(capitulo.get("rejugable", false)):
		return
	# Degradación (RF2): capítulo de un sistema NO implementado → omitir con log
	var sistema := String(capitulo.get("sistema", ""))
	if sistema != "" and get_node_or_null("/root/" + sistema) == null:
		if not _degradados.has(capitulo_id):
			_degradados[capitulo_id] = true
			print("[M92] Degradación: capítulo '%s' omitido — sistema '%s' no implementado" % [capitulo_id, sistema])
		return
	# Gate M19 (RF2): nunca disparar lecciones sobre NPCs dormidos/ocupados
	if bool(capitulo.get("requiere_vecino_libre", false)):
		if not _vecino_libre(String(capitulo.get("vecino_id", ""))):
			return  # se reintenta cuando otro trigger lo vuelva a invocar
	# Revalidación: meta ya cumplida por jugador que sabe
	if _meta_cumplida(capitulo.get("meta", "")):
		_completar(capitulo_id)
		return
	activo_actual = capitulo_id
	_tiempo_capitulo_activo = 0.0  # watchdog (RF23) desde cero
	estado = Estado.ACTIVO
	estado_cambiado.emit(estado)
	capitulo_iniciado.emit(capitulo_id)
	for paso in capitulo.pasos:
		paso_mostrado.emit(capitulo_id, paso)

func _meta_cumplida(meta: String) -> bool:
	if meta == "":
		return false
	return meta in completados

## Marca una meta como cumplida (la llama el sistema enseñado o el watchdog).
func cumplir_meta(meta: String) -> void:
	if meta == "" or meta in completados:
		return
	completados.append(meta)
	if activo_actual != "" and capitulos.has(activo_actual):
		var capitulo: Dictionary = capitulos[activo_actual]
		if capitulo.get("meta", "") == meta:
			_completar(activo_actual)

func _completar(capitulo_id: String) -> void:
	if capitulo_id in completados:
		return
	completados.append(capitulo_id)
	estado = Estado.CONSECUENCIA
	estado_cambiado.emit(estado)
	capitulo_completado.emit(capitulo_id)
	activo_actual = ""
	estado = Estado.ESPERANDO
	estado_cambiado.emit(estado)

## ── Controles ────────────────────────────────────────────

func skip_todo() -> void:
	estado = Estado.SKIPPED
	estado_cambiado.emit(estado)

func reanudar() -> void:
	if estado == Estado.SKIPPED:
		estado = Estado.ESPERANDO
		estado_cambiado.emit(estado)

func set_dormido(valor: bool) -> void:
	if valor and estado != Estado.SKIPPED:
		estado = Estado.DORMIDO
		estado_cambiado.emit(estado)
	elif not valor and estado == Estado.DORMIDO:
		estado = Estado.ESPERANDO
		estado_cambiado.emit(estado)

func esta_activo() -> bool:
	return estado == Estado.ACTIVO

func capitulos_completados() -> Array:
	return completados.duplicate()

func capitulo_estado(capitulo_id: String) -> bool:
	return capitulo_id in completados

## ── Consejos (tips opcionales) ───────────────────────────

func marcar_consejo_visto(consejo_id: String) -> void:
	if consejo_id not in consejos_vistos:
		consejos_vistos.append(consejo_id)

func consejo_visto(consejo_id: String) -> bool:
	return consejo_id in consejos_vistos

## ── Persistencia (M59) ───────────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {
		"completados": completados.duplicate(),
		"consejos_vistos": consejos_vistos.duplicate(),
		"skip": estado == Estado.SKIPPED,
	}

func restore_save_data(data: Dictionary) -> void:
	completados.clear()
	for c in data.get("completados", []):
		completados.append(str(c))
	consejos_vistos.clear()
	for c in data.get("consejos_vistos", []):
		consejos_vistos.append(str(c))
	if bool(data.get("skip", false)):
		estado = Estado.SKIPPED