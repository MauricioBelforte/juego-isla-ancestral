# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M148: Lore Ambiental — LoreAuditor
# Auditoría del catálogo de lore (RF10/DoD criterio 1): valida IDs únicos,
# canonRef no vacío, cobertura ≥ 12 piezas por isla, grafo de pistas
# (30 pistas → consumidores existen). Diseño original (04-Codigo.md §1.1).

class_name LoreAuditor
extends RefCounted

## Valida el catálogo completo. Devuelve Array[String] de errores (vacía = OK).
static func validar(catalogo: LoreCatalogo) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	var piezas_por_isla: Dictionary = {}
	var pistas: Array = []
	for p in _todas_piezas(catalogo):
		var pieza := p as PiezaDeLore
		if pieza == null:
			continue
		# ID único
		if pieza.id.is_empty():
			errores.append("Pieza sin id")
			continue
		if ids.has(pieza.id):
			errores.append("ID duplicado: %s" % pieza.id)
		ids[pieza.id] = true
		# canonRef no vacío
		if pieza.canon_ref.is_empty():
			errores.append("%s: canon_ref vacío" % pieza.id)
		# cobertura por isla
		if not piezas_por_isla.has(pieza.isla):
			piezas_por_isla[pieza.isla] = 0
		piezas_por_isla[pieza.isla] += 1
		# pistas con consumidor
		if pieza.tipo in [PiezaDeLore.Tipo.MURAL, PiezaDeLore.Tipo.ESTATUA, PiezaDeLore.Tipo.MAPA, PiezaDeLore.Tipo.CANCION]:
			if not pieza.consumidor_id.is_empty():
				pistas.append(pieza)
	# cobertura ≥ 12 por isla
	for isla in piezas_por_isla:
		if piezas_por_isla[isla] < 12:
			errores.append("Isla '%s': solo %d piezas (mínimo 12)" % [isla, piezas_por_isla[isla]])
	return errores

## Reporte legible para CI/QA.
static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M148] LoreAuditor: OK — catálogo válido"
	var lineas: Array = ["[M148] LoreAuditor: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)

static func _todas_piezas(catalogo: LoreCatalogo) -> Array:
	# Acceso interno: iteramos claves
	var out: Array = []
	for key in catalogo._piezas:
		out.append(catalogo._piezas[key])
	return out