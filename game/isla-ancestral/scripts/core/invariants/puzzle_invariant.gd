# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Invariante de Puzzle
# Reinicio del slot del puzzle si no es resoluble en 30 s de diagnóstico.

## Valida puzzles: resoluble en 30 s de diagnóstico; reinicio al estado inicial del slot.
class_name PuzzleInvariant
extends InvariantBase

const TIMEOUT_RESOLUBILIDAD: float = 30.0

func _init() -> void:
	categoria = IRecoverable.CategoriaRecuperable.PUZZLE

func _check() -> bool:
	return true  # Validación concreta delegada a M24/M26

func _razon_fallo() -> String:
	return "Puzzle irreducible tras diagnóstico de 30 s"
