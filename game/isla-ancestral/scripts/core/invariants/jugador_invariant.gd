# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Invariante de Jugador
# Prioridad 0: jugador vivo y sobre geometría válida; teleport al checkpoint.

## Valida el jugador: vivo, sobre geometría válida, dentro del mundo.
class_name JugadorInvariant
extends InvariantBase

func _init() -> void:
	categoria = IRecoverable.CategoriaRecuperable.JUGADOR

func _check() -> bool:
	# La validación concreta se hace en SoftlockGuard (tiene referencia al jugador).
	# Este método existe por completitud del contrato.
	return true

func _razon_fallo() -> String:
	return "Jugador fuera del mundo o en geometría inválida"
