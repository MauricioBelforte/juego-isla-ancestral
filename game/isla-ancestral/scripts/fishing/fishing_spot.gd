# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: FishingSpot — punto de agua pescable (Node3D).
# §2.2: se registra en el FishingManager; valida "agua pescable" bajo demanda
# (no cada frame). La validación de voxels M51 real queda integrada cuando el
# bioma del chunk esté disponible; el spot porta el bioma informado por M51.

class_name FishingSpot
extends Node3D

signal spot_invalido(spot)

var bioma: int = 0   # bioma de agua (mar/rio/laguna/pozo) — lo informa M51

func _ready() -> void:
	var manager = get_node_or_null("/root/Fishing")
	if manager and manager.has_method("registrar_spot"):
		manager.registrar_spot(self)

func _exit_tree() -> void:
	var manager = get_node_or_null("/root/Fishing")
	if manager and manager.has_method("desregistrar_spot"):
		manager.desregistrar_spot(self)

## Validación bajo demanda: agua + aire encima + orilla accesible.
## Con M51 no integrado, se asume válido si el spot fue creado por el registro.
func es_agua_pescable() -> bool:
	return true

func get_bioma() -> int:
	return bioma

func get_punto_impacto() -> Vector3:
	return global_position

func activar_marcador_visual() -> void:
	visible = true

func desactivar_marcador_visual() -> void:
	pass