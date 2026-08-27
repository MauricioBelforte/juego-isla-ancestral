# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M20: Amistad — GiftEvaluator (lógica pura de evaluación de regalos)
# Reglas del balanceo (03-Diseno §4):
#   Amado=20, Gusta=10, Neutral=5, Duplicado=2. Nunca 0 (sin frustración).
# Determinista y sin aleatoriedad crítica.
class_name GiftEvaluator
extends RefCounted

enum Clase { AMADO, GUSTA, NEUTRAL, DUPLICADO }

const PUNTOS := {
	Clase.AMADO: 20,
	Clase.GUSTA: 10,
	Clase.NEUTRAL: 5,
	Clase.DUPLICADO: 2,
}

## Evalúa un regalo para un vecino. `vecino_data` es VecinoData (M19) por
## duck-typing; puede ser null si M19 aún no existe (fallback neutral).
## `item_meta` es ItemData (M14) por duck-typing.
## `ya_regalado` indica si el item ya fue regalado antes a este vecino (duplicado).
static func evaluar(vecino_data, item_meta, ya_regalado: bool) -> Dictionary:
	var clase := _clasificar(vecino_data, item_meta, ya_regalado)
	if clase == Clase.DUPLICADO:
		# Duplicado manda sobre cualquier preferencia (memoria del NPC).
		clase = Clase.DUPLICADO
	return {
		"clase": clase,
		"puntos": int(PUNTOS[clase]),
		"reaccion_id": _reaccion(clase),
	}

static func _clasificar(vecino_data, item_meta, ya_regalado: bool) -> int:
	if ya_regalado:
		return Clase.DUPLICADO
	if item_meta == null:
		return Clase.NEUTRAL
	# ítems no válidos para regalo devuelven neutral (nunca castigan)
	if item_meta.get("regalo_valido") == false:
		return Clase.NEUTRAL
	var item_id := str(item_meta.get("id", ""))
	var categoria := str(item_meta.get("categoria", ""))
	if vecino_data == null:
		return Clase.NEUTRAL
	# Gustos del vecino: amados > gusta > disgustos
	var amados: Array = vecino_data.get("regalos_amados", [])
	if item_id in amados or categoria in amados:
		return Clase.AMADO
	var gusta: Array = vecino_data.get("gustos", [])
	if item_id in gusta or categoria in gusta:
		return Clase.GUSTA
	var disgustos: Array = vecino_data.get("disgustos", [])
	if item_id in disgustos or categoria in disgustos:
		# El vecino nunca es hostil: un disgusto baja a neutral, no castiga.
		return Clase.NEUTRAL
	return Clase.NEUTRAL

static func _reaccion(clase: int) -> String:
	match clase:
		Clase.AMADO:
			return "R_AMADO"
		Clase.GUSTA:
			return "R_GUSTA"
		Clase.NEUTRAL:
			return "R_NEUTRAL"
		Clase.DUPLICADO:
			return "R_DUPLICADO"
	return "R_NEUTRAL"
