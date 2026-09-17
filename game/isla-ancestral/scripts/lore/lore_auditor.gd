# Modelo: deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 2)
# Plataforma: Kilo Code (iter. 1) · WorkBuddy (iter. 2)
# Fecha: 2026-09-01 (iter. 1) · 2026-09-13 (iter. 2)
#
# M148: Lore Ambiental — LoreAuditor
# Auditoría del catálogo de lore (RF10/DoD criterio 1): valida IDs únicos,
# canonRef no vacío, tipo válido, campos de texto, cobertura ≥ 12 piezas por
# isla y el grafo de pistas (cada pista apunta a un consumidor REGISTRADO).
# Diseño original (04-Codigo.md §1.1) — reimplementado en GDScript.

class_name LoreAuditor
extends RefCounted

## Mínimo de piezas por isla (RF9).
const COBERTURA_MINIMA := 12

## Valida el catálogo completo. Devuelve Array[String] de errores (vacía = OK).
static func validar(catalogo: LoreCatalogo) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	var piezas_por_isla: Dictionary = {}
	# Duplicados detectados al CARGAR (un Dictionary por id los colapsaría
	# antes de este bucle: sin esto el chequeo de duplicados sería inútil).
	for id_dup in catalogo.ids_duplicados():
		errores.append("ID duplicado: %s" % id_dup)
	if catalogo.entradas_sin_id() > 0:
		errores.append("%d entrada(s) descartada(s) sin id" % catalogo.entradas_sin_id())
	for id in catalogo.todos_los_ids():
		var pieza: PiezaDeLore = catalogo.obtener_pieza(id)
		if pieza == null:
			continue
		# ID presente y único
		if pieza.id.is_empty():
			errores.append("Pieza sin id")
			continue
		if ids.has(pieza.id):
			errores.append("ID duplicado: %s" % pieza.id)
		ids[pieza.id] = true
		# canonRef no vacío (RF10)
		if pieza.canon_ref.is_empty():
			errores.append("%s: canon_ref vacío" % pieza.id)
		# tipo dentro del enum (0..TERRENO)
		if pieza.tipo < 0 or pieza.tipo > PiezaDeLore.Tipo.TERRENO:
			errores.append("%s: tipo fuera de rango (%d)" % [pieza.id, pieza.tipo])
		# texto obligatorio (una pieza sin texto no cuenta lore)
		if pieza.titulo.is_empty():
			errores.append("%s: titulo vacío" % pieza.id)
		if pieza.texto.is_empty():
			errores.append("%s: texto vacío" % pieza.id)
		# cobertura por isla
		if pieza.isla.is_empty():
			errores.append("%s: isla vacía" % pieza.id)
		else:
			if not piezas_por_isla.has(pieza.isla):
				piezas_por_isla[pieza.isla] = 0
			piezas_por_isla[pieza.isla] += 1
		# pistas: consumidor obligatorio y registrado
		if LoreCatalogo.es_tipo_pista(pieza.tipo):
			if pieza.consumidor_id.is_empty():
				errores.append("%s: pista sin consumidor_id" % pieza.id)
			elif not catalogo.consumidor_valido(pieza.consumidor_id):
				errores.append("%s: consumidor desconocido '%s'" % [pieza.id, pieza.consumidor_id])
	# cobertura ≥ 12 por isla
	for isla in piezas_por_isla:
		if piezas_por_isla[isla] < COBERTURA_MINIMA:
			errores.append("Isla '%s': solo %d piezas (mínimo %d)" % [isla, piezas_por_isla[isla], COBERTURA_MINIMA])
	return errores

## Valida SOLO el grafo de pistas (RF3): toda pista tiene consumidor y el
## consumidor existe en el registro. Devuelve Array[String] (vacía = OK).
static func validar_grafo(catalogo: LoreCatalogo) -> Array:
	var errores: Array = []
	var pistas: Array = catalogo.pistas()
	if pistas.is_empty():
		errores.append("Grafo de pistas vacío (0 pistas)")
		return errores
	for p in pistas:
		var pieza: PiezaDeLore = p
		if pieza == null:
			continue
		if pieza.consumidor_id.is_empty():
			errores.append("Pista sin consumidor: %s" % pieza.id)
		elif not catalogo.consumidor_valido(pieza.consumidor_id):
			errores.append("Pista %s -> consumidor desconocido '%s'" % [pieza.id, pieza.consumidor_id])
	return errores

## Reporte de cobertura por isla y por tipo (DoD criterio 1/RF9).
static func reporte_cobertura(catalogo: LoreCatalogo) -> String:
	var lineas: Array = ["[M148] Cobertura de lore ambiental:"]
	var islas: Dictionary = {}
	for id in catalogo.todos_los_ids():
		var pieza: PiezaDeLore = catalogo.obtener_pieza(id)
		if pieza == null:
			continue
		islas[pieza.isla] = int(islas.get(pieza.isla, 0)) + 1
	var nombres_islas: Array = islas.keys()
	nombres_islas.sort()
	for isla in nombres_islas:
		var n: int = islas[isla]
		var marca := "OK" if n >= COBERTURA_MINIMA else "INSUFICIENTE"
		lineas.append("  - %s: %d piezas [%s]" % [isla, n, marca])
	lineas.append("  - pistas: %d (consumidores registrados: %d)" % [catalogo.pistas().size(), catalogo.ids_consumidores().size()])
	return "\n".join(lineas)

## Reporte legible para CI/QA.
static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M148] LoreAuditor: OK — catálogo válido"
	var lineas: Array = ["[M148] LoreAuditor: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)
