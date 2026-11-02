# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M40: SceneManager — cambio de escenas raíz con bloqueo de input (AGENTS §8).
# Según 03-Diseno §1.1: orquestador de escenas raíz; delega el progreso visual a
# M63 (pendiente) — hoy cambia con change_scene_to_file DEFERIDO (pitfall §9.20/§9.25:
# cambiar escena durante _ready/_input corrompe el árbol) y emite señales.
# Regla: una sola carga por vez (idempotencia, anti doble-click §8).

extends Node

signal cambio_iniciado(ruta: String)
signal cambio_completado(ruta: String)
signal cambio_fallido(ruta: String, motivo: String)

## Valor de `modo` que significa "no tocar el flujo" (comportamiento previo a
## la integración de M40 b3: los llamadores que no orquestan flujo no cambian).
const MODO_SIN_FLUJO: int = -1

var _cargando: bool = false
## Estado de flujo objetivo que se aplica cuando la carga termina (D40-1).
var _modo_pendiente: int = MODO_SIN_FLUJO

## Cambia a la escena raíz indicada. Bloquea input durante la carga (AGENTS §8):
## se marca flag para el GameFlowManager/UI; con M63 el progreso será real.
##
## `modo` = integración con el GameFlowManager (03-Diseno §3 y §5.5): estado al
## que se pasa CUANDO la escena termina de cargar; durante la carga se pasa a
## CARGANDO y si la carga falla, a ERROR. `MODO_SIN_FLUJO` (-1) = no tocar el
## flujo (default, conserva el contrato previo de este método).
func cambiar_escena(ruta: String, modo: int = MODO_SIN_FLUJO) -> bool:
	if _cargando:
		push_warning("[M40] Cambio ya en curso; se ignora (anti doble-click)")
		return false
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		push_warning("[M40] Escena inexistente: " + ruta)
		cambio_fallido.emit(ruta, "escena_inexistente")
		_sincronizar_error(modo)
		return false
	_cargando = true
	_modo_pendiente = modo
	if modo != MODO_SIN_FLUJO:
		sincronizar_flujo(estado_flujo("CARGANDO"))
	cambio_iniciado.emit(ruta)
	_emitir_infra("carga_iniciada", ruta)
	# §9.20/§9.25: diferido — NUNCA change_scene dentro de _ready/_input directo
	call_deferred("_do_cambio", ruta)
	return true

func _do_cambio(ruta: String) -> void:
	var tree := get_tree()
	if tree == null:
		_cargando = false
		_modo_pendiente = MODO_SIN_FLUJO
		return
	var err: Error = tree.change_scene_to_file(ruta)
	_cargando = false
	if err != OK:
		push_warning("[M40] Fallo cambio de escena (%d): %s" % [err, ruta])
		cambio_fallido.emit(ruta, "error_%d" % err)
		_sincronizar_error(_modo_pendiente)
		return
	cambio_completado.emit(ruta)
	_emitir_infra("carga_completada", ruta)
	print("[M40] Escena cargada: " + ruta)
	# 03-Diseno §3: carga_completada -> GameFlowManager al estado objetivo.
	# Se limpia el pendiente ANTES de sincronizar para que un fallo de la
	# transición no quede armado para la próxima carga.
	var objetivo := _modo_pendiente
	_modo_pendiente = MODO_SIN_FLUJO
	if objetivo != MODO_SIN_FLUJO:
		sincronizar_flujo(objetivo)

## ¿Hay una carga en curso? (para bloquear UI, AGENTS §8)
func esta_cargando() -> bool:
	return _cargando

## Reenvía eventos de carga por EventBus.infra (dominio infra M40, iter. 2).
## Sin class_name: acceso por get_node_or_null (pitfall §9.17/§9.51).
func _emitir_infra(evento: String, ruta: String) -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		return
	var infra: Variant = bus.get("infra")
	if infra == null or not (infra is Object) or not infra.has_signal(evento):
		return
	infra[evento].emit(ruta)

## ── Integración con GameFlowManager (M40 b3) ──────────────────────────────

## Nodo del GameFlowManager, o null si el build es parcial.
## Sin class_name: acceso por get_node_or_null (pitfall §9.17/§9.51).
func _game_flow() -> Node:
	return get_node_or_null("/root/GameFlowManager")

## Valor del enum `Estado` del GameFlowManager, buscado POR NOMBRE: sin números
## mágicos (el `3` de Bootstrap era exactamente ese defecto). Devuelve -1 si el
## flujo no está montado o el nombre no existe en el enum -> fail-closed, nunca
## inventa un estado. Medido en la suite: MUNDO=3, CARGANDO=2, ERROR=5;
## `TRANSICION` NO existe en el código (divergencia D40-2, ya declarada en L81).
func estado_flujo(nombre: String) -> int:
	var gfm := _game_flow()
	if gfm == null:
		return -1
	var valores: Variant = gfm.get("Estado")
	if not (valores is Dictionary) or not valores.has(nombre):
		return -1
	return int(valores[nombre])

## Lleva el GameFlowManager a `nuevo` (03-Diseno §3). Best-effort AUDITABLE:
## devuelve false y AVISA nombrando ambos estados; nunca rompe la carga de
## escena, que es la función primaria de este manager. Idempotente: si ya está
## en `nuevo` devuelve true sin emitir nada (no duplica eventos en EventBus).
func sincronizar_flujo(nuevo: int) -> bool:
	if nuevo < 0:
		return false
	var gfm := _game_flow()
	if gfm == null or not gfm.has_method("cambiar_estado") or not gfm.has_method("get_estado"):
		push_warning("[M40] Flujo no montado; estado %d no aplicado" % nuevo)
		return false
	var actual := int(gfm.get_estado())
	if actual == nuevo:
		return true
	var ok: bool = bool(gfm.cambiar_estado(nuevo))
	if not ok:
		push_warning("[M40] Flujo rechazó la sincronización %d -> %d" % [actual, nuevo])
	return ok

## Deriva a ERROR tras una carga fallida, SOLO si el llamador pidió orquestar
## flujo (`modo` != MODO_SIN_FLUJO). Con modo por defecto el flujo no se toca:
## una ruta mala de un llamador legado no debe mandar el juego entero a ERROR.
func _sincronizar_error(modo: int) -> void:
	_modo_pendiente = MODO_SIN_FLUJO
	if modo == MODO_SIN_FLUJO:
		return
	sincronizar_flujo(estado_flujo("ERROR"))

## Ruta de la escena raíz activa (contrato de 03-Diseno §5.5, que lo exigía y
## no existía en disco). "" si todavía no hay escena montada.
func escena_actual() -> String:
	var tree := get_tree()
	if tree == null or tree.current_scene == null:
		return ""
	return String(tree.current_scene.scene_file_path)

## Auditoría de la integración flujo<->escena (NO muta estado). La usan la suite
## y el reporte para medir en vez de suponer.
func verificar() -> Dictionary:
	var gfm := _game_flow()
	var estado := -1
	if gfm != null and gfm.has_method("get_estado"):
		estado = int(gfm.get_estado())
	return {
		"flujo_montado": gfm != null,
		"estado_flujo": estado,
		"cargando": _cargando,
		"modo_pendiente": _modo_pendiente,
		"escena_actual": escena_actual(),
	}