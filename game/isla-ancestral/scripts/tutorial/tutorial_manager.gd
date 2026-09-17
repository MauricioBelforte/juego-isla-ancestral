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
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).

extends Node

enum Estado { ACTIVO, ESPERANDO, PISTA, CONSECUENCIA, SKIPPED, DORMIDO }

signal capitulo_iniciado(capitulo_id: String)
signal capitulo_completado(capitulo_id: String)
signal paso_mostrado(capitulo_id: String, paso: Dictionary)
signal estado_cambiado(estado: int)
## Watchdog (RF23): capítulo pausado por timeout — cozy, nunca castiga
signal capitulo_timeout(capitulo_id: String)
## RF20: capítulo descartado tras agotar las re-programaciones — descarte seguro
signal capitulo_descartado(capitulo_id: String)
## RF24 (T-033/T-034): feedback breve y **NO modal** al completar (M44 sonido, M53 mensaje)
signal feedback_capitulo(capitulo_id: String, datos: Dictionary)
## RF6 (T-044): consejo opcional mostrado (una sola vez por partida)
signal consejo_mostrado(consejo_id: String, texto_clave: String)
## P2 (cozy): la pista expiró con motivo y SIN castigo — el capítulo queda pendiente
signal pista_expirada(capitulo_id: String, motivo: String)
## T-016 / P13: capítulo pospuesto por contexto (hora/día/zona) o por prioridad
signal capitulo_pospuesto(capitulo_id: String, motivo: String)
## RF7/RF9 (T-042/T-095) / P7 / P14: pistas ocultadas (sin parpadeo) con motivo
signal pistas_ocultas(motivo: String)
## P7: las pistas reaparecen tras cerrar el modal, si el contexto sigue vivo
signal pistas_reanudadas(cantidad: int)

const SECCION_SAVE := "tutorial"
## Watchdog por capítulo (RF23): timeout configurable (checklist default 120 s)
const WATCHDOG_TIMEOUT_S: float = 120.0
## Throttle del chequeo de proximidad (presupuesto ≤ 0.2 ms/frame, checklist)
const THROTTLE_MUNDO_S: float = 0.25
## RF20: re-programación del trigger hasta N intentos antes del descarte seguro
const MAX_INTENTOS_CAPITULO: int = 3
## RF4 (T-041): máx. 2 pistas (burbujas) vivas simultáneas en todo momento
const MAX_PISTAS_VIVAS: int = 2
## RF6 (T-047): cooldown mínimo entre consejos (s)
const COOLDOWN_CONSEJO_S: float = 90.0
## RF6 (T-046): contextos permitidos de consejo (checklist: carga, caminata larga, pausa)
const CONTEXTOS_CONSEJO: Array[String] = ["carga_escena", "caminata_larga", "pausa"]
## RF24: duración del mensaje de éxito (checklist: 2 s) — el modal está prohibido
const FEEDBACK_DURACION_S: float = 2.0

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
## RF20: intentos fallidos de despliegue por capítulo (gate NPC ocupado / watchdog)
var _intentos: Dictionary = {}
## RF20: capítulos descartados tras agotar re-programaciones (reactivables)
var _descartados: Dictionary = {}
## Delay de re-programación automática tras un fallo de gate (segundos; 0 = sin timer)
var reprograma_delay_s: float = 30.0
## ── Iter. 3 (glm-5.3-flash, 2026-09-15): interruptores, contexto y consejos ──
## RF9 (T-042): interruptor "Pistas contextuales" (burbujas). Independiente del guiado.
var pistas_contextuales_activas: bool = true
## RF9 (T-043): interruptor propio de la secuencia guiada (prólogo)
var prologo_guiado_activo: bool = true
## RF6 (T-049): interruptor "Consejos" en opciones de juego
var consejos_activos: bool = true
## RF6 (T-044): consejo_id -> {texto_clave: String, contexto: String}
var consejos: Dictionary = {}
## P4: capitulo_id -> índice del próximo paso a mostrar (retomar tras reinicio)
var _paso_pendiente: Dictionary = {}
## T-041: contador de pistas vivas del capítulo activo
var _pistas_vivas: int = 0
var _pistas_activas_ids: Array = []
## Reloj interno de M92 (acumulado por _process). NUNCA lee el reloj del SO
## (regla del proyecto: gameplay usa ticks/contadores, ver GUIA-GODOT §9.64).
var _ahora_s: float = 0.0
var _tiempo_ultimo_consejo: float = -COOLDOWN_CONSEJO_S
## T-048: flag de diálogo (además del duck-typing a M21)
var _en_dialogo: bool = false
## T-016: contexto inyectable (hora/día/estación/zona). -1 / "" = consultar proveedor
var _contexto: Dictionary = {"hora": -1, "dia": -1, "estacion": -1, "zona": ""}
## P7: las pistas siguen vivas pero ocultas (modal/diálogo abierto)
var pistas_visibles: bool = true
## RF8/T-099 (RN11): snapshot del estado previo al re-play (no contamina la partida)
var _replay_snapshot: Dictionary = {}

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
	], "mover", true, {"guiado": true})
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
## {sistema: "NombreAutoload" (degradación si no existe), requiere_vecino_libre: bool,
##  vecino_id: String, guiado: bool (RF9/T-043: pertenece a la secuencia guiada),
##  requiere_contexto: Dictionary (T-016: {hora_min, hora_max, zona})}
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
		"guiado": bool(extra.get("guiado", false)),
		"requiere_contexto": extra.get("requiere_contexto", {}),
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
	# Reloj interno de M92 (acumulado). NUNCA se lee el reloj del SO: el gameplay
	# y el tutorial usan contadores/ticks (GUIA-GODOT §9.64).
	_ahora_s += delta
	# RF2: proximidad del jugador a triggers de mundo (throttle)
	_throttle_mundo += delta
	if _throttle_mundo >= THROTTLE_MUNDO_S:
		_throttle_mundo = 0.0
		_chequear_proximidad()
	# T-041/Q2: las pistas se evalúan por vencimiento (sin polling adicional)
	_procesar_pistas()
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
		# Q3: distancia al CUADRADO (sin sqrt en la ruta caliente)
		var d2: float = jugador.global_position.distance_squared_to(t.get("pos", Vector3.ZERO))
		var radio: float = float(t.get("radio", 0.0))
		if d2 <= radio * radio:
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
		# RF20: el timeout cuenta como intento; al agotar re-programaciones → descarte seguro
		if _registrar_intento(cap):
			return
		# Permite re-despliegue futuro: el capítulo NO se marca completado
		capitulo_timeout.emit(cap)
		print("[M92] Watchdog: %s pausado tras %d s (re-disparable, intento %d/%d)" % [cap, int(WATCHDOG_TIMEOUT_S), int(_intentos.get(cap, 0)), MAX_INTENTOS_CAPITULO])

## RF20: registra un intento fallido de despliegue; al agotar MAX_INTENTOS
## descarta el capítulo de forma segura (cozy: nunca bloquea ni castiga).
## Devuelve true si el capítulo fue descartado.
func _registrar_intento(capitulo_id: String) -> bool:
	_intentos[capitulo_id] = int(_intentos.get(capitulo_id, 0)) + 1
	if int(_intentos[capitulo_id]) >= MAX_INTENTOS_CAPITULO:
		_descartar_capitulo(capitulo_id)
		return true
	return false

func _descartar_capitulo(capitulo_id: String) -> void:
	_descartados[capitulo_id] = true
	if activo_actual == capitulo_id:
		activo_actual = ""
		estado = Estado.ESPERANDO
		estado_cambiado.emit(estado)
	capitulo_descartado.emit(capitulo_id)
	_log_m103("[M92] Capítulo '%s' DESCARTADO tras %d intentos fallidos (cozy: re-activable con reactivar_descartado)" % [capitulo_id, MAX_INTENTOS_CAPITULO])

## RF20: re-programación automática tras un fallo de gate (NPC ocupado → reintento)
func _programar_reintento(capitulo_id: String) -> void:
	if reprograma_delay_s <= 0.0:
		return
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return
	arbol.create_timer(reprograma_delay_s).timeout.connect(
		func() -> void: desplegar_capitulo(capitulo_id), CONNECT_ONE_SHOT)

## Re-play/cozy: re-activa un capítulo descartado (administración o re-play)
func reactivar_descartado(capitulo_id: String) -> void:
	_descartados.erase(capitulo_id)
	_intentos.erase(capitulo_id)

## RF19: trazabilidad vía Logger (M103) — duck-typing, tolerante a su ausencia
func _log_m103(mensaje: String) -> void:
	var logger := get_node_or_null("/root/GameLogger")
	if logger != null and logger.has_method("info"):
		logger.info(mensaje)
	else:
		print(mensaje)

## ── Despliegue de capítulos ──────────────────────────────

func desplegar_capitulo(capitulo_id: String) -> void:
	if estado == Estado.SKIPPED:
		return
	if not capitulos.has(capitulo_id):
		return
	# RF20: descarte seguro — un capítulo descartado ya no se re-dispara solo
	if _descartados.has(capitulo_id):
		return
	var capitulo: Dictionary = capitulos[capitulo_id]
	if capitulo_id in completados and not bool(capitulo.get("rejugable", false)):
		return
	# Degradación (RF2/T-019): capítulo de un sistema NO implementado → omitir con log
	var sistema := String(capitulo.get("sistema", ""))
	if sistema != "" and get_node_or_null("/root/" + sistema) == null:
		if not _degradados.has(capitulo_id):
			_degradados[capitulo_id] = true
			_log_m103("[M92] Degradación: capítulo '%s' omitido — sistema '%s' no implementado" % [capitulo_id, sistema])
		return
	# RF9 (T-042/T-043): interruptores INDEPENDIENTES. El de "Pistas contextuales"
	# no afecta la secuencia guiada del prólogo (interruptor propio).
	var guiado := bool(capitulo.get("guiado", false))
	if guiado and not prologo_guiado_activo:
		return
	if not guiado and not pistas_contextuales_activas:
		return
	# T-016: contexto permitido (día/hora/zona/sistema disponible). Sin datos
	# del proveedor → NO se bloquea (cozy): el capítulo se muestra igual.
	if not _contexto_permitido(capitulo):
		capitulo_pospuesto.emit(capitulo_id, "contexto")
		_log_m103("[M92] Capítulo '%s' pospuesto por contexto (hora/día/zona)" % capitulo_id)
		return
	# Gate M19 (RF2): nunca disparar lecciones sobre NPCs dormidos/ocupados.
	# RF20: el fallo cuenta como intento → re-programación automática;
	# al agotar MAX_INTENTOS_CAPITULO → descarte seguro.
	if bool(capitulo.get("requiere_vecino_libre", false)):
		if not _vecino_libre(String(capitulo.get("vecino_id", ""))):
			if not _registrar_intento(capitulo_id):
				_programar_reintento(capitulo_id)
			return
	# Revalidación: meta ya cumplida por jugador que sabe
	if _meta_cumplida(capitulo.get("meta", "")):
		_log_m103("[M92] Revalidación: capítulo '%s' completado en silencio (meta '%s' ya dominada)" % [capitulo_id, capitulo.get("meta", "")])
		_completar(capitulo_id)
		return
	activo_actual = capitulo_id
	_tiempo_capitulo_activo = 0.0  # watchdog (RF23) desde cero
	estado = Estado.ACTIVO
	estado_cambiado.emit(estado)
	capitulo_iniciado.emit(capitulo_id)
	# P4: reinicio a mitad de capítulo → se retoma desde el paso pendiente
	var pasos: Array = capitulo.pasos
	var desde: int = clampi(int(_paso_pendiente.get(capitulo_id, 0)), 0, pasos.size())
	if desde > 0:
		_log_m103("[M92] Capítulo '%s' retomado desde el paso %d (persistencia P4)" % [capitulo_id, desde])
	for i in range(desde, pasos.size()):
		_paso_pendiente[capitulo_id] = i + 1
		paso_mostrado.emit(capitulo_id, pasos[i])

## RF5 (T-035/T-072): avanza al siguiente paso de una SECUENCIA.
## Devuelve true si había un paso más. Nunca bloquea otras acciones del jugador.
func avanzar_paso(capitulo_id: String) -> bool:
	if activo_actual != capitulo_id or not capitulos.has(capitulo_id):
		return false
	var pasos: Array = capitulos[capitulo_id].pasos
	var n: int = int(_paso_pendiente.get(capitulo_id, 0))
	if n < pasos.size():
		_paso_pendiente[capitulo_id] = n + 1
		paso_mostrado.emit(capitulo_id, pasos[n])
		return true
	return false

## P4: índice del próximo paso pendiente (0 = sin progreso registrado)
func paso_pendiente(capitulo_id: String) -> int:
	return int(_paso_pendiente.get(capitulo_id, 0))

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
	_intentos.erase(capitulo_id)  # RF20: el capítulo resuelto limpia su historial
	_paso_pendiente.erase(capitulo_id)
	estado = Estado.CONSECUENCIA
	estado_cambiado.emit(estado)
	# P15: el estado se PERSISTE ANTES del feedback. Si el jugador cierra el juego
	# justo en el instante del mensaje de éxito, el capítulo ya quedó registrado.
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("save_now"):
		sm.save_now()
	capitulo_completado.emit(capitulo_id)
	# RF24 (T-033/T-034): feedback breve (2 s), informativo y NUNCA modal.
	feedback_capitulo.emit(capitulo_id, {
		"duracion_s": FEEDBACK_DURACION_S,
		"modal": false,
		"sonido": "exito",   # M44
		"texto_clave": "TUTORIAL.CAPITULO_COMPLETADO",
	})
	activo_actual = ""
	estado = Estado.ESPERANDO
	estado_cambiado.emit(estado)

## ── Iter. 3: pistas, contexto, interruptores, re-play ─────

## RF4 (T-041): registra una pista viva. Máx. MAX_PISTAS_VIVAS simultáneas.
## P13: si no hay cupo, la de MENOR prioridad (la nueva) se POSPONE, no se descarta.
func registrar_pista(pista_id: String, capitulo_id: String, duracion_s: float = 25.0) -> bool:
	if _pistas_activas_ids.size() >= MAX_PISTAS_VIVAS:
		capitulo_pospuesto.emit(capitulo_id, "prioridad")
		return false
	_pistas_activas_ids.append({
		"id": pista_id,
		"capitulo": capitulo_id,
		"expira_en": _ahora_s + duracion_s,
	})
	_pistas_vivas = _pistas_activas_ids.size()
	pistas_visibles = true
	return true

## T-039: la pista se oculta con fade al expirar, al alejarse (> 6 m) o al cumplir
## la acción. El `motivo` viaja en la señal para que la UI haga el fade correcto.
func ocultar_pista(pista_id: String, motivo: String = "cumplida") -> void:
	for i in range(_pistas_activas_ids.size() - 1, -1, -1):
		if String(_pistas_activas_ids[i].get("id", "")) == pista_id:
			_pistas_activas_ids.remove_at(i)
	_pistas_vivas = _pistas_activas_ids.size()
	pistas_ocultas.emit(motivo)

## P14: fast-travel (M69) o cambio de escena con pista activa → descarte LIMPIO.
func descartar_pistas(motivo: String = "fast_travel") -> void:
	if _pistas_activas_ids.is_empty():
		return
	_pistas_activas_ids.clear()
	_pistas_vivas = 0
	pistas_ocultas.emit(motivo)

func pistas_vivas() -> int:
	return _pistas_activas_ids.size()

## T-041/Q2: vencimiento evaluado en _process (sin polling extra ni allocaciones).
func _procesar_pistas() -> void:
	if _pistas_activas_ids.is_empty():
		return
	var i: int = _pistas_activas_ids.size() - 1
	while i >= 0:
		var p: Dictionary = _pistas_activas_ids[i]
		if float(p.get("expira_en", 0.0)) <= _ahora_s:
			var cap := String(p.get("capitulo", ""))
			_pistas_activas_ids.remove_at(i)
			# P2 (cozy): la pista expira SIN castigo; el capítulo queda pendiente.
			pista_expirada.emit(cap, "expirada")
		i -= 1
	_pistas_vivas = _pistas_activas_ids.size()

## RF9 (T-042): interruptor "Pistas contextuales". Al apagarlo, las pistas se
## ocultan de inmediato y SIN parpadeo (RF7/T-095).
func set_pistas_contextuales(activo: bool) -> void:
	pistas_contextuales_activas = activo
	if not activo:
		_pistas_activas_ids.clear()
		_pistas_vivas = 0
		pistas_ocultas.emit("interruptor")

func pistas_contextuales_on() -> bool:
	return pistas_contextuales_activas

## RF9 (T-043): interruptor del PRÓLOGO, separado del de pistas contextuales.
func set_prologo_guiado(activo: bool) -> void:
	prologo_guiado_activo = activo

func prologo_guiado_on() -> bool:
	return prologo_guiado_activo

## RF6 (T-049): interruptor "Consejos" (opciones de juego).
func set_consejos(activo: bool) -> void:
	consejos_activos = activo

func consejos_on() -> bool:
	return consejos_activos

## P8/P9: ícono de tecla dinámico leído del InputMap según el dispositivo activo.
## Remapear la tecla (P8) o cambiar de dispositivo (P9) se refleja en vivo:
## la UI no cachea el texto, lo consulta antes de cada pista.
func icono_tecla_dinamico(accion: String) -> String:
	if accion == "" or not InputMap.has_action(accion):
		return ""
	var eventos := InputMap.action_get_events(accion)
	if eventos.is_empty():
		return ""
	var pad := Input.get_connected_joypads().size() > 0
	for ev in eventos:
		if pad and ev is InputEventJoypadButton:
			return ev.as_text()
		if not pad and ev is InputEventKey:
			return ev.as_text()
	return eventos[0].as_text()

## T-016: contexto inyectable (hora/día/estación/zona). El juego lo empuja desde
## M30 (tiempo) / M32 (clima); sin inyección se consulta al proveedor.
func establecer_contexto(ctx: Dictionary) -> void:
	for k in ctx:
		_contexto[k] = ctx[k]

func contexto_actual() -> Dictionary:
	return _contexto.duplicate()

## T-016: un capítulo puede declarar "requiere_contexto": {hora_min, hora_max, zona}.
## Sin datos del proveedor (-1 / "") NO se bloquea: cozy manda.
func _contexto_permitido(capitulo: Dictionary) -> bool:
	var req: Dictionary = capitulo.get("requiere_contexto", {})
	if req.is_empty():
		return true
	if req.has("hora_min") or req.has("hora_max"):
		var hora := _hora_del_mundo()
		if hora >= 0:
			if req.has("hora_min") and hora < int(req["hora_min"]):
				return false
			if req.has("hora_max") and hora > int(req["hora_max"]):
				return false
	var zona := String(_contexto.get("zona", ""))
	if req.has("zona") and zona != "" and zona != String(req["zona"]):
		return false
	return true

func _hora_del_mundo() -> int:
	var v := int(_contexto.get("hora", -1))
	if v >= 0:
		return v
	var prov := get_node_or_null("/root/TimeSystem")
	if prov != null and prov.has_method("get_hour"):
		return int(prov.get_hour())
	return -1

## T-048/P7: marca que hay un diálogo (M21) o modal abierto. El tutorial se
## duerme y las pistas se ocultan SIN parpadear; al cerrar, reaparecen si el
## contexto sigue vivo (pistas_reanudadas). No destruye nada.
func set_en_dialogo(valor: bool) -> void:
	_en_dialogo = valor
	set_dormido(valor)
	if valor:
		pistas_visibles = false
		if not _pistas_activas_ids.is_empty():
			pistas_ocultas.emit("dormido")
	elif not _pistas_activas_ids.is_empty():
		pistas_visibles = true
		pistas_reanudadas.emit(_pistas_activas_ids.size())

func en_dialogo() -> bool:
	return _en_dialogo

## ── Controles ─────────────────────────────────────────────

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

## S4 (T-101/P3): revalidación silenciosa por maestría previa.
## Si el jugador ya dominó la meta antes de que el capítulo se despliegue,
## el capítulo se marca completo SIN mostrar pasos.
func revalidar_si_dominado(capitulo_id: String) -> bool:
	if not capitulos.has(capitulo_id):
		return false
	return _meta_cumplida(capitulos[capitulo_id].get("meta", ""))

## RF7 (T-094): skip de UN capítulo. Libera el guion actual SIN marcarlo como
## completado (el jugador lo puede retomar después). Las pistas se ocultan de
## inmediato y sin parpadeo (T-095).
func skip_capitulo(capitulo_id: String) -> void:
	if activo_actual == capitulo_id:
		activo_actual = ""
		_tiempo_capitulo_activo = 0.0
		estado = Estado.ESPERANDO
		estado_cambiado.emit(estado)
	_paso_pendiente.erase(capitulo_id)
	descartar_pistas("skip_capitulo")

## RF8 (T-097/T-099/T-100): re-play de un capítulo suelto.
## Toma un SNAPSHOT del estado previo para no contaminar la partida (RN11):
## el re-play no marca `completados` ni toca la persistencia.
func iniciar_replay(capitulo_id: String) -> Dictionary:
	if not capitulos.has(capitulo_id):
		return {}
	var snapshot := {
		"activo_actual": activo_actual,
		"estado": estado,
		"paso_pendiente": _paso_pendiente.duplicate(),
		"completados": completados.duplicate(),
	}
	_replay_snapshot = snapshot
	activo_actual = capitulo_id
	_paso_pendiente[capitulo_id] = 0
	estado = Estado.ACTIVO
	estado_cambiado.emit(estado)
	capitulo_iniciado.emit(capitulo_id)
	# T-100: el re-play usa estado_replay — muestra TODOS los pasos sin revalidar
	var pasos: Array = capitulos[capitulo_id].pasos
	for i in range(pasos.size()):
		_paso_pendiente[capitulo_id] = i + 1
		paso_mostrado.emit(capitulo_id, pasos[i])
	return snapshot

## T-099: cierra el re-play y RESTAURA el estado previo (la partida no se contamina).
func terminar_replay() -> void:
	if _replay_snapshot.is_empty():
		return
	activo_actual = String(_replay_snapshot.get("activo_actual", ""))
	estado = int(_replay_snapshot.get("estado", Estado.ESPERANDO))
	_paso_pendiente = _replay_snapshot.get("paso_pendiente", {}).duplicate()
	completados = _replay_snapshot.get("completados", []).duplicate()
	_replay_snapshot = {}
	estado_cambiado.emit(estado)

func en_replay() -> bool:
	return not _replay_snapshot.is_empty()

## P5: el objeto de la lección fue destruido (árbol talado, parcela removida).
## Se cuenta como intento: al agotar las re-programaciones → descarte seguro (RF20).
## Devuelve true si el capítulo fue descartado.
func notificar_objetivo_destruido(capitulo_id: String) -> bool:
	if not capitulos.has(capitulo_id):
		return false
	if _registrar_intento(capitulo_id):
		return true
	_programar_reintento(capitulo_id)
	return false

## P6: el nodo objetivo está fuera del mundo activo (M63 streaming).
## El capítulo se PAUSA hasta que el mundo se active: nunca se pierde.
func pausar_por_mundo_inactivo(capitulo_id: String) -> void:
	if activo_actual == capitulo_id:
		activo_actual = ""
		_tiempo_capitulo_activo = 0.0
		estado = Estado.ESPERANDO
		estado_cambiado.emit(estado)
	_log_m103("[M92] Capítulo '%s' pausado: mundo objetivo fuera del mundo activo (M63)" % capitulo_id)

## ── Consejos (tips opcionales) ───────────────────────────

func marcar_consejo_visto(consejo_id: String) -> void:
	if consejo_id not in consejos_vistos:
		consejos_vistos.append(consejo_id)

func consejo_visto(consejo_id: String) -> bool:
	return consejo_id in consejos_vistos

## RF6 (T-044): registra un consejo de profundización (riego, horarios, senderismo).
## contexto debe pertenecer a CONTEXTOS_CONSEJO (carga_escena, caminata_larga, pausa).
func registrar_consejo(consejo_id: String, texto_clave: String, contexto: String) -> void:
	consejos[consejo_id] = {"texto_clave": texto_clave, "contexto": contexto}

## RF6 (T-045..T-048): intenta mostrar un consejo. Devuelve true si se mostró.
## Reglas: se muestra UNA sola vez (T-045), cooldown de 90 s (T-047), contexto
## permitido (T-046), NUNCA durante diálogos/cutscenes (T-048), interruptor
## "Consejos" (T-049), y jamás modal (cozy).
func intentar_mostrar_consejo(contexto: String) -> bool:
	if not consejos_activos:
		return false
	if contexto not in CONTEXTOS_CONSEJO:
		return false
	if _en_dialogo or _en_cutscene():   # T-048
		return false
	if _ahora_s - _tiempo_ultimo_consejo < COOLDOWN_CONSEJO_S:   # T-047
		return false
	for consejo_id in consejos:
		var c: Dictionary = consejos[consejo_id]
		if String(c.get("contexto", "")) != contexto:
			continue
		if consejo_visto(consejo_id):   # T-045
			continue
		marcar_consejo_visto(consejo_id)
		_tiempo_ultimo_consejo = _ahora_s
		consejo_mostrado.emit(consejo_id, String(c.get("texto_clave", "")))
		return true
	return false

func _en_cutscene() -> bool:
	var cs := get_node_or_null("/root/CutsceneManager")
	if cs != null and cs.has_method("esta_en_cutscene"):
		return bool(cs.esta_en_cutscene())
	return false

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
		# Iter. 3: reanudación fina y preferencias del jugador (muy liviano, < 1 KB)
		"paso_pendiente": _paso_pendiente.duplicate(),
		"pistas_on": pistas_contextuales_activas,
		"prologo_on": prologo_guiado_activo,
		"consejos_on": consejos_activos,
	}

func restore_save_data(data: Dictionary) -> void:
	completados.clear()
	for c in data.get("completados", []):
		completados.append(str(c))
	consejos_vistos.clear()
	for c in data.get("consejos_vistos", []):
		consejos_vistos.append(str(c))
	# P4: si el guardado quedó a mitad de capítulo, se retoma desde el paso pendiente
	_paso_pendiente.clear()
	var pp: Dictionary = data.get("paso_pendiente", {})
	for k in pp:
		_paso_pendiente[str(k)] = int(pp[k])
	pistas_contextuales_activas = bool(data.get("pistas_on", true))
	prologo_guiado_activo = bool(data.get("prologo_on", true))
	consejos_activos = bool(data.get("consejos_on", true))
	if bool(data.get("skip", false)):
		estado = Estado.SKIPPED