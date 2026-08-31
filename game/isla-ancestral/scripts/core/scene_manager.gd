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

var _cargando: bool = false

## Cambia a la escena raíz indicada. Bloquea input durante la carga (AGENTS §8):
## se marca flag para el GameFlowManager/UI; con M63 el progreso será real.
func cambiar_escena(ruta: String) -> bool:
	if _cargando:
		push_warning("[M40] Cambio ya en curso; se ignora (anti doble-click)")
		return false
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		push_warning("[M40] Escena inexistente: " + ruta)
		cambio_fallido.emit(ruta, "escena_inexistente")
		return false
	_cargando = true
	cambio_iniciado.emit(ruta)
	# §9.20/§9.25: diferido — NUNCA change_scene dentro de _ready/_input directo
	call_deferred("_do_cambio", ruta)
	return true

func _do_cambio(ruta: String) -> void:
	var tree := get_tree()
	if tree == null:
		_cargando = false
		return
	var err: Error = tree.change_scene_to_file(ruta)
	_cargando = false
	if err != OK:
		push_warning("[M40] Fallo cambio de escena (%d): %s" % [err, ruta])
		cambio_fallido.emit(ruta, "error_%d" % err)
		return
	cambio_completado.emit(ruta)
	print("[M40] Escena cargada: " + ruta)

## ¿Hay una carga en curso? (para bloquear UI, AGENTS §8)
func esta_cargando() -> bool:
	return _cargando