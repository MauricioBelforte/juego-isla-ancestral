# M37: Museos y Colecciones — MuseumPlacer (RF2: instanciar + posicionar el museo en el mundo)
# agnes-3-flash (Kilo Code), 2026-10-08. 03-Diseno §2.2 + slice RF2 (escena + posicionamiento).
# Headless-friendly: si el TerrainLocator está listo, snapping al terreno (get_height + 1);
# si no (headless temprano), deja la coordenada XZ correcta (verificación de estructura sí funciona).
extends RefCounted

const MUSEO_TSCN := "res://scenes/museo/museum.tscn"

## Carga la escena del museo, la añade a `padre` y la posiciona en el mundo (MUSEO_POS).
## Devuelve el nodo Museum (null si la escena no cargó).
func crear_en_mundo(padre: Node) -> Node3D:
	var escena: Variant = load(MUSEO_TSCN)
	if escena == null:
		push_error("[M37] No cargó la escena del museo: %s" % MUSEO_TSCN)
		return null
	var museo: Node3D = escena.instantiate()
	if padre != null:
		padre.add_child(museo)
	if museo.has_method("placiar_en_mundo"):
		museo.placiar_en_mundo()
	return museo
