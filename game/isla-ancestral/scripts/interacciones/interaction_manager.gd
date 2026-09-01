# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M70: Interacciones — InteractionManager (autoload "interacciones").
# Orquestador unico del modulo. NO conoce los consumidores, solo despacha por
# contrato IInteractable + emite senales. Diseno simplificado para iter 1;
# lo que queda fuera (prompts visuales world-space, linea de vision voxel,
# catalogo visual, animaciones) esta marcado [?] en el plan-actual con su dueno.
# Estado del modulo y registro deterministico (orden de registro como desempate).
# Reutiliza:
#   - IInteractable (scripts/interfaces/) ampliada en este turno
#   - ToolData (scripts/tools/) para requisitos de herramienta (M13)
#   - Inventario (autoload) y TimeCalendar (M29) consultados via get_node_or_null
#   - SaveManager (M59) para persistencia de estado por interactuable
#
# Pitfalls respetados (07-GUIA-GODOT):
#   - Sin class_name (autoload, §9.17/§9.41)
#   - snake_case en señales (§1.1)
#   - _ en vars no usadas (§1.3)

extends Node

signal objetivo_seleccionado(objetivo, atenuado: bool)
signal objetivo_perdido()
signal interaccion_iniciada(objetivo, categoria: StringName)
signal interaccion_terminada(objetivo, ok: bool)
signal interaccion_cancelada(objetivo, motivo: String)
signal estado_cambiado(estado: int)

## Estado global del gestor (replica InteractionState del plan).
enum InteractionState { INACTIVO, SELECCIONANDO, INTERACTUANDO, DORMIDO }
## Estado del interactuable (replica EstadoInteractuable del plan).
enum EstadoInteractuable { DISPONIBLE, INTERACTUANDO, NO_DISPONIBLE, OCULTO }

const SECCION_SAVE := "interacciones"
const DEFAULT_RANGO := 2.5
const HISTERESIS_M := 0.15   # metros: mantener objetivo si nuevo esta <= 0.15 m mas cerca

## Jugador (inyectado por la escena principal o por tests)
var _jugador: Node = null
## VoxelTool (opcional, para línea de visión; M08)
var _voxel_tool = null

## Registro de interactuables. Array (orden de registro) para determinismo.
var _interactuables: Array = []
## Cache de evaluación de 1 frame (re-evaluado en cada _process).
var _candidatos_frame: Array = []
## Objetivo seleccionado actualmente (duck-typed: cualquier nodo con contrato IInteractable).
var _objetivo_actual = null
## Estado del gestor.
var _estado: int = InteractionState.INACTIVO
## Estado dormido externo (pausa/UI modal).
var _externo_dormido: bool = false

## Persistencia: estado por interactuable (def_id -> dict).
var _estado_guardado: Dictionary = {}

func _ready() -> void:
	# Persistencia
	var sm := _get_save_manager()
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)
	# Cambio de día: invalidar caches que dependen del calendario (M29)
	var gt := _get_game_time()
	if gt != null and gt.has_signal("dia_cambio"):
		gt.dia_cambio.connect(_on_dia_cambio)

func _process(_delta: float) -> void:
	if _estado == InteractionState.DORMIDO or _externo_dormido:
		return
	if _estado == InteractionState.INACTIVO:
		_estado = InteractionState.SELECCIONANDO
		estado_cambiado.emit(_estado)
	_evaluar_y_seleccionar()

## ── API publica ─────────────────────────────────────────────

## Inyecta el nodo jugador (M11). Llamado por la escena al arrancar.
func configurar_jugador(jugador: Node) -> void:
	_jugador = jugador

## Inyecta el VoxelTool (M08) para línea de visión. Opcional.
func configurar_voxel(voxel_tool) -> void:
	_voxel_tool = voxel_tool

## Registra un interactuable (orden de registro = desempate final).
## Llamar en _ready de cada nodo que implemente IInteractable, o manualmente.
func registrar(interactuable) -> void:
	if interactuable == null:
		return
	if interactuable in _interactuables:
		return
	_interactuables.append(interactuable)
	# Restaurar estado persistido si existe
	if _estado_guardado.has(str(interactuable.get_instance_id())):
		var saved: Dictionary = _estado_guardado[str(interactuable.get_instance_id())]
		_aplicar_estado_guardado(interactuable, saved)

## Desregistra un interactuable. Llamar en _exit_tree o cuando se destruye.
## Si era el objetivo actual, lo limpia y emite objetivo_perdido.
func desregistrar(interactuable) -> void:
	if interactuable == null:
		return
	_interactuables.erase(interactuable)
	if _objetivo_actual == interactuable:
		_objetivo_actual = null
		objetivo_perdido.emit()

## Entrada unica de input. Llamado por el input handler al presionar "interact".
## Delega al consumidor del objetivo actual via IInteractable.interactuar().
func presionar_interact() -> void:
	if _estado == InteractionState.DORMIDO or _externo_dormido:
		return
	if _estado == InteractionState.INTERACTUANDO:
		return  # ya hay una en curso
	if _objetivo_actual == null:
		# Sin candidato: no genera error ni castigo (regla cozy RF8).
		return
	var obj: IInteractable = _objetivo_actual
	var estado_obj: int = obj.obtener_estado()
	if estado_obj != EstadoInteractuable.DISPONIBLE:
		# Candidato atenuado: feedback respetuoso sin despacho (RF4, RF22).
		interaccion_cancelada.emit(obj, "no_disponible")
		return
	# Despachar
	_estado = InteractionState.INTERACTUANDO
	estado_cambiado.emit(_estado)
	interaccion_iniciada.emit(obj, obj.obtener_categoria())
	var datos := {"jugador": _jugador, "tool": _tool_en_mano(), "timestamp": Time.get_ticks_msec()}
	obj.interactuar(datos)

## Notifica al gestor que una interacción terminó. Llamado por el consumidor (RF9).
func finalizar_interaccion(objetivo, ok: bool) -> void:
	if objetivo == _objetivo_actual:
		_estado = InteractionState.SELECCIONANDO
		estado_cambiado.emit(_estado)
	interaccion_terminada.emit(objetivo, ok)

## Cancela la interacción en curso (RF12). Llamado por UI/pausa o por el consumidor.
func cancelar_interaccion(objetivo, motivo: String) -> void:
	if objetivo == _objetivo_actual:
		_estado = InteractionState.SELECCIONANDO
		estado_cambiado.emit(_estado)
	interaccion_cancelada.emit(objetivo, motivo)

## Pausa / reanuda el gestor (RF14, RF25). Llamado por UIManager (M53).
func set_estado_dormido(dormido: bool) -> void:
	_externo_dormido = dormido
	if dormido:
		if _estado != InteractionState.DORMIDO:
			_estado_anterior = _estado
			_estado = InteractionState.DORMIDO
			estado_cambiado.emit(_estado)
	else:
		if _estado == InteractionState.DORMIDO:
			_estado = _estado_anterior if _estado_anterior != -1 else InteractionState.SELECCIONANDO
			_estado_anterior = -1
			estado_cambiado.emit(_estado)

var _estado_anterior: int = -1

## Devuelve el objetivo actualmente seleccionado (o null).
func obtener_objetivo_actual():
	return _objetivo_actual

## Devuelve el estado actual del gestor.
func obtener_estado() -> int:
	return _estado

## Cantidad de interactuables registrados (para tests / debug).
func cantidad_registrados() -> int:
	return _interactuables.size()

## Para tests: snapshot del array de candidatos del último frame.
func obtener_candidatos_frame() -> Array:
	return _candidatos_frame.duplicate()

## ── Evaluacion y seleccion (RF4-RF6, RF19) ────────────────────

func _evaluar_y_seleccionar() -> void:
	_candidatos_frame.clear()
	if _jugador == null:
		return
	var pos_jugador: Vector3 = _jugador.global_position
	var rango_max := DEFAULT_RANGO
	var candidatos_validos: Array = []
	for it in _interactuables:
		if it == null or not is_instance_valid(it):
			continue
		var estado_it: int = it.obtener_estado()
		if estado_it == EstadoInteractuable.OCULTO or estado_it == EstadoInteractuable.INTERACTUANDO:
			continue  # RF4
		var pos_it: Vector3 = it.obtener_posicion_interaccion()
		var radio: float = maxf(it.obtener_radio(), 0.1)
		var dx := pos_it.x - pos_jugador.x
		var dz := pos_it.z - pos_jugador.z
		var dist_cuad := dx * dx + dz * dz
		var rango_total := rango_max + radio
		if dist_cuad > rango_total * rango_total:
			continue  # filtro barato sin sqrt (RN-rendimiento)
		if not it.requisitos_cumplidos(_jugador):
			_candidatos_frame.append({"obj": it, "valido": false, "dist": dist_cuad, "prioridad": it.get_interaction_priority()})
			continue
		candidatos_validos.append({"obj": it, "valido": true, "dist": dist_cuad, "prioridad": it.obtener_interaction_priority()})
	_candidatos_frame.append_array(candidatos_validos)
	# Ordenar: prioridad desc, luego dist asc, luego orden de registro (estable).
	candidatos_validos.sort_custom(_comparar_candidatos)
	if candidatos_validos.is_empty():
		_perder_objetivo_si_corresponde()
		return
	var mejor: Dictionary = candidatos_validos[0]
	# Histéresis (RF6): mantener objetivo si el nuevo no es >HISTERESIS_M más cerca.
	if _objetivo_actual != null and _objetivo_actual in _interactuables:
		var dist_actual: float = _dist_cuadrada(_objetivo_actual, pos_jugador)
		if dist_actual - mejor.dist <= HISTERESIS_M * HISTERESIS_M:
			return  # mantener
	_perder_objetivo_si_corresponde()
	_objetivo_actual = mejor.obj
	var atenuado: bool = not bool(mejor.get("valido", true))
	objetivo_seleccionado.emit(_objetivo_actual, atenuado)

func _comparar_candidatos(a: Dictionary, b: Dictionary) -> bool:
	# prioridad desc
	if a.prioridad != b.prioridad:
		return a.prioridad > b.prioridad
	# distancia asc
	if not is_equal_approx(a.dist, b.dist):
		return a.dist < b.dist
	# orden de registro: el que apareció antes gana (estable)
	return _interactuables.find(a.obj) < _interactuables.find(b.obj)

func _dist_cuadrada(obj, pos_jugador: Vector3) -> float:
	var p := obj.obtener_posicion_interaccion()
	var dx := p.x - pos_jugador.x
	var dz := p.z - pos_jugador.z
	return dx * dx + dz * dz

func _perder_objetivo_si_corresponde() -> void:
	if _objetivo_actual != null:
		_objetivo_actual = null
		objetivo_perdido.emit()

## ── Persistencia M59 ─────────────────────────────────────────

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	# estado por instancia (instance_id -> dict)
	var snap: Dictionary = {}
	for it in _interactuables:
		if it == null or not is_instance_valid(it):
			continue
		snap[str(it.get_instance_id())] = _snapshot_interactuable(it)
	return {"version": 1, "estado": snap, "externo_dormido": _externo_dormido, "estado_gestor": _estado}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	_estado_guardado = data.get("estado", {})
	_externo_dormido = bool(data.get("externo_dormido", false))
	_estado = int(data.get("estado_gestor", InteractionState.SELECCIONANDO))

func _snapshot_interactuable(it) -> Dictionary:
	# Solo guardamos lo que el consumidor considere persistible via property "save_key" si existe,
	# si no, guardamos el estado publico minimo.
	var d := {"estado": it.obtener_estado()}
	return d

func _aplicar_estado_guardado(it, saved: Dictionary) -> void:
	# El consumidor puede override _aplicar_estado_guardado via property "save_apply";
	# por defecto solo marcamos el estado si el interactuable lo soporta.
	if it.has_method("aplicar_estado_guardado"):
		it.aplicar_estado_guardado(saved)

func _on_dia_cambio(_info: Dictionary) -> void:
	# Re-evaluar candidatos (RF17: requisitos temporales como puertas/cosechas)
	if _estado == InteractionState.SELECCIONANDO:
		_evaluar_y_seleccionar()

## ── Helpers internos ──────────────────────────────────────────

func _tool_en_mano():
	# Sin acoplar a M13: si existe ToolController, expone tool actual.
	if _jugador != null and _jugador.has_node("ToolController"):
		var tc = _jugador.get_node("ToolController")
		if tc != null and "herramienta" in tc:
			return tc.herramienta
	return null

func _get_save_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("SaveManager")

func _get_game_time() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("GameTime")