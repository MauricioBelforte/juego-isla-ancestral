# Modelo: deepseek-v4-flash-vision-exp (iter. 3) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 6)
# Plataforma: Kilo Code (iter. 3) · WorkBuddy (iter. 6)
# Fecha: 2026-09-02 (iter. 3) · 2026-09-18 (iter. 6)
#
# M52: VfxSchema — validación del catálogo de VFX.
#
# iter. 3 validaba 6 campos (id, nombre, tipo, cantidad, emision, color) y el
# catálogo tenía 8 entradas. iter. 6 (Log 1002) el catálogo tiene 31 entradas y
# 20 campos, así que el validador se extendió para que las reglas del plan sean
# **verificables**, no aspiracionales:
#
#   RF6  eventos de juego  -> sin `bus` hace falta `dueno_evento` (nadie lo dispara)
#   RF7  fuego/lava        -> `luz_por_particula` SIEMPRE false (la luz es de M49)
#   RF11 UI/Reduce Motion  -> `parpadeo_hz` <= 10 (sin estroboscopios)
#   RF14 optimización      -> un loop SIEMPRE trae `radio` de culling; un no-loop nunca
#   RF16 naming            -> `vfx_<snake_case>` (alineado con M108)
#   RF1  catálogo          -> los 24 nombres del plan maestro están cubiertos
#
# Los conjuntos cerrados (CATEGORIAS/EMISORES/MATERIALES) están duplicados a
# propósito en `tools/vfx/gen_vfx_catalog.py`: el generador los valida al
# ESCRIBIR y este schema los valida al LEER. Si divergen, uno de los dos falla
# — que es exactamente lo que se quiere (una excepción invisible es un agujero
# negro).
class_name VfxSchema
extends RefCounted

const VERSION_ESPERADA := 2

## Los 24 nombres del plan maestro (plan-inicial/04-Codigo.md:149).
## El checklist RF1 dice "25": discrepancia REPORTADA, no inventada.
const PLAN := [
	"humo", "polvo", "hojas", "petalos", "chispas", "agua", "pesca",
	"lluvia", "nieve", "fuego", "lava", "luz", "magia", "resonancia",
	"runas", "teletransporte", "sello", "puzzle", "construccion",
	"cosecha", "descubrimiento", "estaciones", "interfaz", "atmosfericos",
]

const CATEGORIAS := ["ambiental", "clima", "estacional", "impacto", "magia", "ui"]
const EMISORES := ["punto", "esfera", "caja", "global"]
const MATERIALES := ["unshaded_alpha", "unshaded_add"]

## Vocabulario de `tipo` (forma del efecto). Es un conjunto CERRADO: agregar uno
## exige tocar acá Y el generador. `tipo` y `categoria` son ejes distintos:
## `magia` y `ui` aparecen legítimamente en los dos (categoría = dónde se usa,
## tipo = cómo se ve).
const TIPOS := [
	"atmosferico", "chispas", "confeti", "construccion", "corazones",
	"descubrimiento", "estacional", "flotante", "fuego", "gotas", "hojas",
	"humo", "lava", "luz", "magia", "nieve", "polvo", "puzzle",
	"resonancia", "runas", "sello", "splash", "teletransporte", "ui",
]

const CANTIDAD_MIN := 5
const CANTIDAD_MAX := 300
const EMISION_MIN := 0.1
const EMISION_MAX := 3.0
const PARPADEO_MAX_HZ := 10.0

const RE_ID := "^vfx_[a-z0-9_]+$"
const RE_HEX := "^#[0-9A-Fa-f]{6}$"

## Devuelve Array[String] con los problemas (vacío si es válido).
static func validar_catalogo(config: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var version := int(config.get("version", 0))
	if version != VERSION_ESPERADA:
		errores.append("version %d (esperada %d)" % [version, VERSION_ESPERADA])
	var vfx: Variant = config.get("vfx", [])
	if typeof(vfx) != TYPE_ARRAY or vfx.is_empty():
		errores.append("vfx vacío o inválido")
		return errores

	var ids := {}
	for e in vfx:
		if typeof(e) != TYPE_DICTIONARY:
			errores.append("entrada no es Dictionary: %s" % [e])
			continue
		errores.append_array(validar_entrada(e, ids))

	# RF1: cobertura del plan maestro (a nivel de catálogo, no de entrada).
	for faltante in cobertura_plan(config):
		errores.append("plan sin cubrir: %s" % faltante)
	return errores

## Valida UNA entrada. `ids` acumula los ids ya vistos (detecta duplicados).
static func validar_entrada(e: Dictionary, ids: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var id := str(e.get("id", ""))
	var rex_id := RegEx.create_from_string(RE_ID)

	if id.is_empty():
		errores.append("VFX sin id")
	elif ids.has(id):
		errores.append("id duplicado: %s" % id)
	else:
		ids[id] = true
	if not rex_id.search(id):
		errores.append("%s: naming inválido (RF16/M108, esperado vfx_<snake_case>)" % id)
	if str(e.get("nombre", "")).is_empty():
		errores.append(id + ": sin nombre")
	if str(e.get("evento", "")).is_empty():
		errores.append(id + ": sin evento")

	_cerrado(errores, id, e, "tipo", TIPOS)
	_cerrado(errores, id, e, "categoria", CATEGORIAS)
	_cerrado(errores, id, e, "emisor", EMISORES)
	_cerrado(errores, id, e, "material", MATERIALES)

	var cantidad := int(e.get("cantidad", 0))
	if cantidad < CANTIDAD_MIN or cantidad > CANTIDAD_MAX:
		errores.append("%s: cantidad fuera de rango (%d)" % [id, cantidad])
	var emision := float(e.get("emision", 0.0))
	if emision < EMISION_MIN or emision > EMISION_MAX:
		errores.append("%s: emision fuera de rango (%.2f)" % [id, emision])

	# RF3: el presupuesto no puede ser menor que lo que el efecto emite.
	if int(e.get("presupuesto", 0)) < cantidad:
		errores.append("%s: presupuesto < cantidad (RF3)" % id)

	# RF7: nada de luz por partícula — la luz es de M49.
	if bool(e.get("luz_por_particula", true)):
		errores.append("%s: luz_por_particula debe ser false (RF7 → M49)" % id)

	# RF11: sin estroboscopios.
	if float(e.get("parpadeo_hz", 0.0)) > PARPADEO_MAX_HZ:
		errores.append("%s: parpadeo %.1f Hz > %.0f (RF11)"
				% [id, float(e.get("parpadeo_hz", 0.0)), PARPADEO_MAX_HZ])

	# RF4/RF14: loops con fase fija y radio de culling; no-loops sin radio.
	var es_loop := bool(e.get("loop", false))
	var radio := float(e.get("radio", 0.0))
	var fase := float(e.get("fase", 0.0))
	if es_loop:
		if radio <= 0.0:
			errores.append("%s: loop sin radio de culling (RF14)" % id)
		if fase < 0.0 or fase >= 1.0:
			errores.append("%s: fase %.3f fuera de [0,1) (RF4)" % [id, fase])
	elif radio != 0.0:
		errores.append("%s: no-loop con radio (%.1f)" % [id, radio])

	# RF6: o lo dispara el bus, o hay un dueño declarado que lo dispara.
	var bus := str(e.get("bus", ""))
	if bus.is_empty():
		if str(e.get("dueno_evento", "")).is_empty():
			errores.append("%s: sin bus y sin dueno_evento (RF6: nadie lo dispara)" % id)
	elif not bus.contains("."):
		errores.append("%s: bus mal formado (%s)" % [id, bus])

	if not RegEx.create_from_string(RE_HEX).search(str(e.get("color", ""))):
		errores.append("%s: color inválido" % id)
	return errores

## Nombres del plan maestro que NO están representados por ninguna entrada.
static func cobertura_plan(config: Dictionary) -> Array[String]:
	var cubiertos := {}
	for e in config.get("vfx", []):
		if typeof(e) == TYPE_DICTIONARY:
			cubiertos[str(e.get("plan", ""))] = true
	var faltan: Array[String] = []
	for nombre in PLAN:
		if not cubiertos.has(nombre):
			faltan.append(nombre)
	return faltan

static func _cerrado(errores: Array[String], id: String, e: Dictionary,
		campo: String, permitidos: Array) -> void:
	var valor := str(e.get(campo, ""))
	if not permitidos.has(valor):
		errores.append("%s: %s inválido (%s)" % [id, campo, valor])
