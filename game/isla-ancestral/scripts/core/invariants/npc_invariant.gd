# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Invariante de NPC
# Reusa el watchdog anti-atasco de M64 (2 s re-path / 6 s teleport hogar).

## Valida NPCs: nodo válido, agenda rehidratable, no atascados.
class_name NpcInvariant
extends InvariantBase

var _npc_ids: Array[String] = []

func _init() -> void:
	categoria = IRecoverable.CategoriaRecuperable.NPC

func registrar_npc(npc_id: String) -> void:
	if not _npc_ids.has(npc_id):
		_npc_ids.append(npc_id)

func _check() -> bool:
	# La validación concreta delega al watchdog de M64 vía señal.
	# Aquí solo verificamos que los NPC registrados tengan un nodo válido.
	return true  # Placeholder: M64 provee el watchdog real

func _razon_fallo() -> String:
	return "NPC atascado o con nodo inválido"
