# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M13: Herramientas — Recurso mock para preview visual
# Expone el contrato mínimo que ToolController espera de un recurso del mundo:
# get_acciones_validas() / try_extract(velocidad) / try_place(id, meta).

extends MeshInstance3D

## Acciones válidas sobre este recurso (ToolData.Accion)
var _acciones: Array = []

func setup(acciones: Array) -> void:
	_acciones = acciones

func get_acciones_validas() -> Array:
	return _acciones

## Contrato M08/M50 mock: simula extracción (siempre ok en preview).
func try_extract(_velocidad: float) -> Dictionary:
	return {"ok": true, "drops": ["mock_drop"], "bloque": 1}

## Contrato M08/M17 mock: simula colocación.
func try_place(_block_id: int, _metadata: Dictionary = {}) -> bool:
	return true
