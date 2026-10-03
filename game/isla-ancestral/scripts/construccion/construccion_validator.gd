# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — ConstruccionValidator: la UNICA autoridad
# "puede colocar".
#
# Decision de diseno (02-Analisis §2.4): manager, preview y fantasma consultan
# LA MISMA API; no hay rutas de colocacion paralelas (evita validacion
# divergente). La validacion es declarativa: lee `PlacementRule`, no un `match`
# por tipo de pieza.
#
# Renombrado respecto al diseno: el diseno propone `BuildValidator`, pero ese
# `class_name` global YA lo usa M117 (scripts/build/build_validator.gd:10).
#
# ── El CONTEXTO (`ctx`) ─────────────────────────────────────────────────
# Para que el nucleo sea testeable en headless sin el mundo cargado, todas las
# consultas al exterior llegan por `ctx`, un Dictionary de Callables OPCIONALES:
#
#   "ocupada"           Callable(Vector3i) -> bool      celda ocupada por pieza
#   "superficie"        Callable(Vector3i) -> StringName "terreno"/"piso"/"techo"/
#                                                        "pared"/"agua"/"aire"
#   "npc"               Callable(Vector3i) -> bool      hay un NPC activo ahi
#   "pagar"             Callable(Dictionary) -> bool    M14 puede pagar el costo
#   "permiso"           Callable(Vector3i) -> int       permiso de zona (ZoneRegistry)
#   "piezas_en_zona"    Callable(PlacementRule, Vector3i) -> int   tope por zona
#
# Una clave AUSENTE se trata con el default SEGURO (no ocupada / aire / sin NPC /
# puede pagar / edificable / 0 piezas) Y queda anotada en `detalle`, para que QA
# vea que la validacion corrio con datos incompletos en vez de creerla completa.
#
# NUCLEO PURO: sin dependencias de nodos, VoxelTools ni autoloads.

class_name ConstruccionValidator
extends RefCounted

## Orden de aplicacion de las reglas (03-Diseno §5). Documentado, no decorativo:
## la zona se consulta antes que la regla de pieza, y los recursos al final.
const ORDEN: Array[String] = ["zona", "ocupacion", "soporte", "regla", "npc", "limite", "recursos"]

## Vecinos horizontales (para la regla "requiere pared").
const VECINOS_H: Array[Vector3i] = [
	Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1),
]

## ── API principal ───────────────────────────────────────────────────────

## Valida colocar `receta` anclada en `celda` con `rotacion` (pasos de 90).
## Devuelve { ok, motivos[], detalle[], celdas[] }. Acumula TODOS los motivos.
static func validar(receta: PlacementRule, celda: Vector3i, rotacion: int, ctx: Dictionary) -> Dictionary:
	var detalle: Array = []
	if receta == null or not receta.es_valida():
		return ConstruccionTipos.resultado_fallo(
			[ConstruccionTipos.Motivo.RECETA_INVALIDA], ["receta nula o sin id"], [])

	var celdas: Array[Vector3i] = receta.celdas(celda, rotacion)
	var motivos: Array = []

	# 1) ZONA — la celda completa debe caer en el permiso requerido.
	var requerido: int = ConstruccionTipos.Permiso.AGUA if receta.sobre_agua else ConstruccionTipos.Permiso.EDIFICABLE
	for c in celdas:
		var p: int = _permiso(ctx, c, detalle)
		if p == requerido:
			continue
		var m: int = _motivo_de_permiso(p, requerido)
		if not motivos.has(m):
			motivos.append(m)
			detalle.append("zona: %s en %s (permiso=%d)" % [
				ConstruccionTipos.texto(m), str(c), p])

	# 2) OCUPACION — ninguna celda ocupada por otra pieza.
	for c in celdas:
		if celda_ocupada(ctx, c):
			if not motivos.has(ConstruccionTipos.Motivo.CELDA_OCUPADA):
				motivos.append(ConstruccionTipos.Motivo.CELDA_OCUPADA)
				detalle.append("ocupacion: %s" % str(c))

	# 3) SOPORTE — al menos `soportes_minimos` celdas de la base apoyan bien.
	if not tiene_soporte(receta, celda, rotacion, ctx):
		motivos.append(ConstruccionTipos.Motivo.SIN_SOPORTE)
		detalle.append("soporte: %d/%d celdas de base apoyan en %s" % [
			contar_soportes(receta, celda, rotacion, ctx),
			maxi(0, receta.soportes_minimos),
			str(receta.superficie_ok)])

	# 4) REGLA ESPECIFICA — puertas/ventanas requieren pared contigua.
	if receta.requiere_pared and not tiene_pared_contigua(celda, ctx):
		motivos.append(ConstruccionTipos.Motivo.REQUIERE_PARED)
		detalle.append("regla: requiere_pared y ninguna celda contigua es 'pared'")

	# 5) NPC — nadie queda atrapado bajo una pieza.
	for c in celdas:
		if _npc(ctx, c, detalle):
			if not motivos.has(ConstruccionTipos.Motivo.NPC_EN_CELDA):
				motivos.append(ConstruccionTipos.Motivo.NPC_EN_CELDA)
				detalle.append("npc: vecino activo en %s" % str(c))

	# 6) LIMITE por zona (tope suave configurable por receta).
	if receta.max_por_zona > 0:
		var pz: int = _piezas_en_zona(ctx, receta, celda, detalle)
		if pz >= receta.max_por_zona:
			motivos.append(ConstruccionTipos.Motivo.LIMITE_DE_ZONA)
			detalle.append("limite: %d/%d piezas de %s en la zona" % [pz, receta.max_por_zona, receta.id])

	# 7) RECURSOS — ultimo; el descuento real ocurre solo al confirmar.
	if not puede_pagar(receta, ctx):
		motivos.append(ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES)
		detalle.append("recursos: costo %s no pagable" % str(receta.costo))

	if motivos.is_empty():
		var ok: Dictionary = ConstruccionTipos.resultado_ok(celdas)
		ok["detalle"] = detalle
		return ok
	return ConstruccionTipos.resultado_fallo(motivos, detalle, celdas)

## ── Helpers publicos (contrato de 03-Diseno §4) ─────────────────────────

## Huella de la pieza (delegado a la receta; aqui por contrato estable).
static func celdas_de(receta: PlacementRule, celda: Vector3i, rotacion: int) -> Array[Vector3i]:
	if receta == null:
		return []
	return receta.celdas(celda, rotacion)

## true si la celda esta ocupada por otra pieza del jugador.
static func celda_ocupada(ctx: Dictionary, celda: Vector3i) -> bool:
	if not ctx.has("ocupada"):
		return false
	return bool((ctx["ocupada"] as Callable).call(celda))

## true si la receta tiene soporte suficiente en `celda` con `rotacion`.
static func tiene_soporte(receta: PlacementRule, celda: Vector3i, rotacion: int, ctx: Dictionary) -> bool:
	if receta == null:
		return false
	return contar_soportes(receta, celda, rotacion, ctx) >= maxi(0, receta.soportes_minimos)

## Cuenta cuantas celdas de la base apoyan en una superficie permitida.
static func contar_soportes(receta: PlacementRule, celda: Vector3i, rotacion: int, ctx: Dictionary) -> int:
	if receta == null:
		return 0
	var n: int = 0
	for c in receta.celdas(celda, rotacion):
		var abajo := c + Vector3i(0, -1, 0)
		if receta.superficie_ok.has(_superficie(ctx, abajo)):
			n += 1
	return n

## true si TODA la huella cae en el permiso requerido por la receta.
static func dentro_de_zona(receta: PlacementRule, celda: Vector3i, rotacion: int, ctx: Dictionary) -> bool:
	if receta == null:
		return false
	var requerido: int = ConstruccionTipos.Permiso.AGUA if receta.sobre_agua else ConstruccionTipos.Permiso.EDIFICABLE
	var sink: Array = []
	for c in receta.celdas(celda, rotacion):
		if _permiso(ctx, c, sink) != requerido:
			return false
	return true

## true si hay un NPC activo en alguna celda de la huella.
static func hay_npc_en_celda(ctx: Dictionary, celdas: Array, sink: Array = []) -> bool:
	if not ctx.has("npc"):
		return false
	var f: Callable = ctx["npc"]
	for c in celdas:
		if bool(f.call(c)):
			return true
	return false

## true si M14 puede pagar el costo de la receta (ctx ausente -> true, anotado).
static func puede_pagar(receta: PlacementRule, ctx: Dictionary) -> bool:
	if receta == null:
		return false
	if not ctx.has("pagar"):
		return true
	return bool((ctx["pagar"] as Callable).call(receta.costo))

## true si alguna celda contigua horizontal es "pared" (puertas/ventanas).
static func tiene_pared_contigua(celda: Vector3i, ctx: Dictionary) -> bool:
	if not ctx.has("superficie"):
		return false
	for d in VECINOS_H:
		if _superficie(ctx, celda + d) == &"pared":
			return true
	return false

## Contexto vacio (todo ausente). Util para pruebas de "datos incompletos":
## la validacion corre pero deja constancia en `detalle`.
static func contexto_vacio() -> Dictionary:
	return {}

## Contexto explicito con todos los callables (para tests y para el manager).
static func contexto(ocupada: Callable = Callable(), superficie: Callable = Callable(),
		npc: Callable = Callable(), pagar: Callable = Callable(),
		permiso: Callable = Callable(), piezas_en_zona: Callable = Callable()) -> Dictionary:
	var ctx: Dictionary = {}
	if ocupada.is_valid():
		ctx["ocupada"] = ocupada
	if superficie.is_valid():
		ctx["superficie"] = superficie
	if npc.is_valid():
		ctx["npc"] = npc
	if pagar.is_valid():
		ctx["pagar"] = pagar
	if permiso.is_valid():
		ctx["permiso"] = permiso
	if piezas_en_zona.is_valid():
		ctx["piezas_en_zona"] = piezas_en_zona
	return ctx

## ── Internos ────────────────────────────────────────────────────────────

static func _permiso(ctx: Dictionary, celda: Vector3i, detalle: Array) -> int:
	if not ctx.has("permiso"):
		if not detalle.has("ctx: sin 'permiso' -> EDIFICABLE por defecto"):
			detalle.append("ctx: sin 'permiso' -> EDIFICABLE por defecto")
		return ConstruccionTipos.Permiso.EDIFICABLE
	return int((ctx["permiso"] as Callable).call(celda))

static func _superficie(ctx: Dictionary, celda: Vector3i) -> StringName:
	if not ctx.has("superficie"):
		return &"desconocido"
	return StringName((ctx["superficie"] as Callable).call(celda))

static func _npc(ctx: Dictionary, celda: Vector3i, detalle: Array) -> bool:
	if not ctx.has("npc"):
		return false
	return bool((ctx["npc"] as Callable).call(celda))

static func _piezas_en_zona(ctx: Dictionary, receta: PlacementRule, celda: Vector3i, detalle: Array) -> int:
	if not ctx.has("piezas_en_zona"):
		detalle.append("ctx: sin 'piezas_en_zona' -> tope por zona no aplicado")
		return 0
	return int((ctx["piezas_en_zona"] as Callable).call(receta, celda))

## Traduce un permiso no coincidente al motivo mas util para el jugador.
static func _motivo_de_permiso(permiso: int, requerido: int) -> int:
	match permiso:
		ConstruccionTipos.Permiso.PROTEGIDA:
			return ConstruccionTipos.Motivo.ZONA_PROTEGIDA
		ConstruccionTipos.Permiso.NARRATIVA:
			return ConstruccionTipos.Motivo.ZONA_NARRATIVA
		ConstruccionTipos.Permiso.AGUA:
			return ConstruccionTipos.Motivo.AGUA_NO_PERMITIDA
		_:
			# requerido == AGUA y la celda es EDIFICABLE (o desconocida).
			return ConstruccionTipos.Motivo.FUERA_DE_ZONA
