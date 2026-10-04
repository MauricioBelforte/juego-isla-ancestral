# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-04
#
# M17 Construccion iter. 3 — ZonasPermisos: la POLITICA de permisos finos de
# M18 (Casas) y M25 (Ruinas/Templos).
#
# `ZoneRegistry` (iter. 1) es el MECANISMO generico: guarda AABBs con un permiso
# y responde `zona_de(celda)`. Este archivo es la POLITICA: que permiso tiene
# cada region segun su origen, y como se traduce a un motivo para el HUD.
#
# Presets (por modulo de origen):
#   * M18 parcela de la CASA DEL JUGADOR  -> EDIFICABLE (se amplia con piezas)
#   * M18 parcela de un NPC                -> PROTEGIDA  (nunca se construye)
#   * M25 ruina / templo                   -> PROTEGIDA  (piezas de ruina: no
#                                                         deconstruibles)
#   * guion                                -> NARRATIVA  (bloqueada hasta que el
#                                                         guion la libere)
#   * espejo de agua                       -> AGUA       (solo puentes)
#
# NUCLEO PURO: depende solo de ZoneRegistry y ConstruccionTipos (ambos puros).

class_name ZonasPermisos
extends RefCounted

## Preset: parcela de la casa del jugador (M18). Se puede ampliar.
const CASA_JUGADOR: int = ConstruccionTipos.Permiso.EDIFICABLE
## Preset: parcela de un NPC (M18). Nunca se construye encima.
const PARCELA_NPC: int = ConstruccionTipos.Permiso.PROTEGIDA
## Preset: ruina / templo (M25). Protegida; sus piezas son de ruina.
const RUINA: int = ConstruccionTipos.Permiso.PROTEGIDA
## Preset: zona de guion. Bloqueada hasta que el guion la libere.
const NARRATIVA: int = ConstruccionTipos.Permiso.NARRATIVA
## Preset: espejo de agua. Solo puentes.
const AGUA: int = ConstruccionTipos.Permiso.AGUA

## Origen (String) -> preset de permiso. Permite registro data-driven.
const POR_ORIGEN: Dictionary = {
	"casa_jugador": CASA_JUGADOR,
	"parcela_npc": PARCELA_NPC,
	"npc": PARCELA_NPC,
	"ruina": RUINA,
	"templo": RUINA,
	"narrativa": NARRATIVA,
	"agua": AGUA,
}

## ── Registro ────────────────────────────────────────────────────────────

## Registra una region con un preset de permiso. Devuelve true si la zona se
## acepto (una AABB degenerada de volumen <= 0 se ignora, como en ZoneRegistry).
static func registrar(reg: ZoneRegistry, permiso: int, aabb: AABB) -> bool:
	if reg == null:
		return false
	var vol: float = aabb.size.x * aabb.size.y * aabb.size.z
	if vol <= 0.0:
		return false
	reg.registrar_zona(aabb, permiso)
	return true

## Registra varias regiones desde datos planos. Cada entrada:
##   { aabb: AABB | [x,y,z,w,h,d], permiso: int | String (origen) }
## Devuelve cuantas se registraron.
static func registrar_lista(reg: ZoneRegistry, entradas: Array) -> int:
	if reg == null:
		return 0
	var n: int = 0
	for e in entradas:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = e
		var permiso: int = _permiso_de_valor(d.get("permiso", null), d.get("origen", null))
		var aabb: Variant = aabb_de_valor(d.get("aabb", null))
		if aabb == null:
			continue
		if registrar(reg, permiso, aabb):
			n += 1
	return n

## Convierte un valor heterogeneo en AABB (o null si no es convertible).
## Acepta AABB o [x, y, z, w, h, d].
static func aabb_de_valor(v: Variant) -> Variant:
	if v is AABB:
		return v
	if v is Array and (v as Array).size() >= 6:
		var a: Array = v
		return AABB(
			Vector3(float(a[0]), float(a[1]), float(a[2])),
			Vector3(float(a[3]), float(a[4]), float(a[5])))
	return null

## ── Consulta / traduccion ───────────────────────────────────────────────

## Nombre legible de un permiso.
static func nombre_permiso(permiso: int) -> String:
	match permiso:
		ConstruccionTipos.Permiso.EDIFICABLE:
			return "edificable"
		ConstruccionTipos.Permiso.PROTEGIDA:
			return "protegida"
		ConstruccionTipos.Permiso.NARRATIVA:
			return "narrativa"
		ConstruccionTipos.Permiso.AGUA:
			return "agua"
		_:
			return "permiso desconocido (%d)" % permiso

## Motivo de rechazo que corresponde a un permiso (para el HUD).
## EDIFICABLE no es un rechazo -> Motivo.OK.
static func motivo_de_permiso(permiso: int) -> int:
	match permiso:
		ConstruccionTipos.Permiso.EDIFICABLE:
			return ConstruccionTipos.Motivo.OK
		ConstruccionTipos.Permiso.PROTEGIDA:
			return ConstruccionTipos.Motivo.ZONA_PROTEGIDA
		ConstruccionTipos.Permiso.NARRATIVA:
			return ConstruccionTipos.Motivo.ZONA_NARRATIVA
		ConstruccionTipos.Permiso.AGUA:
			return ConstruccionTipos.Motivo.AGUA_NO_PERMITIDA
		_:
			return ConstruccionTipos.Motivo.FUERA_DE_ZONA

## Motivo por el que NO se puede construir en `celda` (OK si es edificable).
static func motivo_de(reg: ZoneRegistry, celda: Vector3i) -> int:
	if reg == null:
		return ConstruccionTipos.Motivo.OK
	return motivo_de_permiso(reg.zona_de(celda))

## true si la celda es edificable (permiso EDIFICABLE exacto).
static func edificable(reg: ZoneRegistry, celda: Vector3i) -> bool:
	if reg == null:
		return true
	return reg.zona_de(celda) == ConstruccionTipos.Permiso.EDIFICABLE

## Explicacion corta para el HUD ("protegida (no se puede construir)").
static func explicar(reg: ZoneRegistry, celda: Vector3i) -> String:
	var m: int = motivo_de(reg, celda)
	if m == ConstruccionTipos.Motivo.OK:
		return "edificable"
	return ConstruccionTipos.texto(m)

## Resumen de diagnostico del registro ("3 zonas: 1 edificable, 2 protegidas").
static func resumen(reg: ZoneRegistry) -> String:
	if reg == null:
		return "sin registro"
	var conteo: Dictionary = {}
	for z in reg.zonas():
		var p: int = int((z as Dictionary).get("permiso", -1))
		conteo[p] = int(conteo.get(p, 0)) + 1
	var partes: Array = []
	for p in conteo.keys():
		partes.append("%d %s" % [int(conteo[p]), nombre_permiso(int(p))])
	return "%d zonas: %s" % [reg.cantidad(), ", ".join(partes)]

## ── Internos ────────────────────────────────────────────────────────────

static func _permiso_de_valor(permiso: Variant, origen: Variant) -> int:
	if permiso is int or permiso is float:
		return int(permiso)
	if permiso is StringName or permiso is String:
		var s: String = String(permiso)
		if POR_ORIGEN.has(s):
			return int(POR_ORIGEN[s])
	if origen is StringName or origen is String:
		var o: String = String(origen)
		if POR_ORIGEN.has(o):
			return int(POR_ORIGEN[o])
	# Default SEGURO: si no se reconoce el origen, se PROTEGE (no se construye
	# por accidente en una parcela desconocida).
	return ConstruccionTipos.Permiso.PROTEGIDA
