# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Contrato IRecoverable
# Interface/contrato que implementan los sistemas que pueden ser reparados.
# En GDScript se modela como RefCounted con duck-typing (no Node).
# Ubicación: scripts/core/invariants/irecoverable.gd

## Contrato de recuperación. Cada sistema externo (misiones, NPC, vehículos, puzzles)
## implementa este contrato y registra su handler al SoftlockGuard.
class_name IRecoverable
extends RefCounted

## Categorías de prioridad (el guard chequea en este orden).
enum CategoriaRecuperable {
	JUGADOR = 0,       # Prioridad 0 (más alta)
	MISION = 1,
	NPC = 2,
	OBJETO_CLAVE = 3,
	VEHICULO = 4,
	PUZZLE = 5,        # Prioridad 5 (más baja)
}

## Devuelve true si el estado actual es válido (no hay softlock en esta categoría).
func es_valido() -> bool:
	return true

## Ejecuta la recuperación. Devuelve true si se recuperó correctamente.
## El guard llama a este método solo si es_valido() devuelve false.
func recuperar() -> bool:
	return false
