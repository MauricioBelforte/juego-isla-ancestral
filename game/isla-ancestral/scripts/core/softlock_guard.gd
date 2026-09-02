# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — SoftlockGuard (detector central)
# Singleton autoload: tick de 60 s, disparo en transiciones/guardado,
# dispatcher de invariantes en cascada con cooldown de toast.

## Singleton central: detecta invariantes rotas y ejecuta recuperaciones en cascada.
extends Node

# Preloads de clases del módulo M66 (evita race condition de autoload vs class_name).
const _IRecoverable := preload("res://scripts/core/invariants/irecoverable.gd")
const _InvariantBase := preload("res://scripts/core/invariants/invariant_base.gd")
const _JugadorInvariant := preload("res://scripts/core/invariants/jugador_invariant.gd")
const _MisionInvariant := preload("res://scripts/core/invariants/mision_invariant.gd")
const _NpcInvariant := preload("res://scripts/core/invariants/npc_invariant.gd")
const _ObjetoClaveInvariant := preload("res://scripts/core/invariants/objeto_clave_invariant.gd")
const _VehiculoInvariant := preload("res://scripts/core/invariants/vehiculo_invariant.gd")
const _PuzzleInvariant := preload("res://scripts/core/invariants/puzzle_invariant.gd")
const _CofreRecuperacion := preload("res://scripts/core/recovery/cofre_recuperacion.gd")
const _CheckpointManager := preload("res://scripts/core/recovery/checkpoint_manager.gd")

## Señal: emitido cuando se detecta un estado inválido grave.
signal estado_invalido_detectado(categoria: int, razon: String)

## Señal: emitido cuando una recuperación se completa.
signal recuperacion_completada(categoria: int, razon: String)

## Señal: para el toast de UI (M57). Sólo si afecta al jugador.
signal toast_requerido(mensaje: String, categoria: int)

## Tiempo real acumulado para el tick periódico
var _timer: float = 0.0

## Timestamp del último toast de cada categoría (anti-spam)
var _ultimo_toast: Dictionary = {}

## Timestamp del último fallo por instancia (ventana 10 min)
var _fallos_instancia: Dictionary = {}

## Handlers externos registrados (implementan IRecoverable)
var _handlers: Array = []

## Invariantes activas (orden de prioridad)
var _invariantes: Array = []

## Cofre de recuperación
var cofre = null  # tipo: CofreRecuperacion (vía preload)

## Manager de checkpoints
var checkpoints = null  # tipo: CheckpointManager (vía preload)

## Flag de actividad
var activo: bool = true

func _ready() -> void:
	# Instanciar sub-sistemas si no fueron asignados desde escena
	if cofre == null:
		cofre = _CofreRecuperacion.new()
		add_child(cofre)
	if checkpoints == null:
		checkpoints = _CheckpointManager.new()
		add_child(checkpoints)
	_registrar_invariantes_por_defecto()
	_conectar_disparos()

## M66 iter. 2 (glm-5.3-flash): disparos del detector (checklist ítems 11-12)
## — transición de escena (M40 infra.carga_iniciada) y guardado (M59 save_completed).
func _conectar_disparos() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.infra != null and bus.infra.has_signal("carga_iniciada"):
		bus.infra.carga_iniciada.connect(func(_ruta: String): forzar_chequeo("transicion_escena"))
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_signal("save_completed"):
		sm.save_completed.connect(func(_slot: int, _reason: String): forzar_chequeo("guardado"))

## Registra las 6 invariantes base en orden de prioridad (jugador primero).
func _registrar_invariantes_por_defecto() -> void:
	_invariantes.clear()
	_invariantes.append(_JugadorInvariant.new())
	_invariantes.append(_MisionInvariant.new())
	_invariantes.append(_NpcInvariant.new())
	_invariantes.append(_ObjetoClaveInvariant.new())
	_invariantes.append(_VehiculoInvariant.new())
	_invariantes.append(_PuzzleInvariant.new())

func _process(delta: float) -> void:
	if not activo:
		return
	_timer += delta
	if _timer >= SoftlockRules.DETECTOR_TICK_SEGUNDOS:
		_timer = 0.0
		_ejecutar_chequeo_ciclico()

## Chequeo cíclico (tick de 60 s).
func _ejecutar_chequeo_ciclico() -> void:
	for inv in _invariantes:
		_check_and_recover(inv)

## Chequeo manual (llamado por eventos de guardado/transición).
func forzar_chequeo(evento: String = "evento") -> void:
	for inv in _invariantes:
		_check_and_recover(inv)

## Registra un handler IRecoverable (los sistemas externos lo llaman).
func registrar_handler(handler) -> void:
	if not _handlers.has(handler):
		_handlers.append(handler)

## Registra una clave única para vigilar (delegado al ObjetoClaveInvariant).
func registrar_clave(clave: String, item_id: String = "") -> void:
	for inv in _invariantes:
		if inv is _ObjetoClaveInvariant:
			(inv as _ObjetoClaveInvariant).registrar_clave(clave, null, true)

## Deposita un objeto clave perdido en el cofre de recuperación.
func depositar_en_cofre(clave: String, item_id: String) -> bool:
	if cofre == null:
		return false
	return cofre.depositar(clave, item_id)

## Registra un fallback de misión (delegado al MisionInvariant).
func registrar_fallback(objetivo_id: String, alternativo_id: String) -> void:
	for inv in _invariantes:
		if inv is _MisionInvariant:
			(inv as _MisionInvariant).registrar_fallback(objetivo_id, alternativo_id)

## Chequea una invariante y, si rota, ejecuta la recuperación en cascada.
func _check_and_recover(inv) -> void:
	if not inv.has_method("check") or inv.check():
		return
	var categoria := int(inv.get("categoria", 0)) if inv.has_method("get") else 0
	var razon := ""
	if inv.has_method("_razon_fallo"):
		razon = inv._razon_fallo()
	emit_signal("estado_invalido_detectado", categoria, razon)

	# Ventana de múltiples fallos (3 en 10 min → cofre + toast informativo)
	var key := str(categoria)
	var now := Time.get_ticks_msec()
	if not _fallos_instancia.has(key):
		_fallos_instancia[key] = []
	var fallos: Array = _fallos_instancia[key]
	fallos.append(now)
	while fallos.size() > 0 and (now - int(fallos[0])) > int(SoftlockRules.VENTANA_MULTIPLES_FALLOS * 1000):
		fallos.pop_front()
	if fallos.size() >= 3:
		_solicitar_toast("Múltiples fallos detectados. Revisa el cofre de recuperación.", categoria)
		_fallos_instancia[key] = []
		return

	# Recovery: intentar los handlers registrados de esta categoría
	for handler in _handlers:
		if handler.has_method("es_valido") and handler.es_valido():
			continue
		if handler.has_method("recuperar") and handler.recuperar():
			emit_signal("recuperacion_completada", categoria, razon)
			_solicitar_toast("Recuperación automática: %s" % razon, categoria)
			return

## Emite un toast respetando el cooldown.
func _solicitar_toast(mensaje: String, categoria: int) -> void:
	if not SoftlockRules.TOAST_ACTIVO:
		return
	var now := Time.get_ticks_msec()
	var last := int(_ultimo_toast.get(str(categoria), 0))
	if now - last < int(SoftlockRules.TOAST_COOLDOWN * 1000):
		return
	_ultimo_toast[str(categoria)] = now
	emit_signal("toast_requerido", mensaje, categoria)


