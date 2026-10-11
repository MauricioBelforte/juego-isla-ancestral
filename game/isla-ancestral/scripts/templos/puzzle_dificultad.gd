# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: capa de DIFICULTAD y AYUDA PROGRESIVA.
# Cierra los items 10, 11, 13 y 14 del checklist:
#   10 3 bandas de dificultad (Exploracion / Ritual / Antiguo)
#   11 progresion de dificultad por zona del templo
#   13 subida de la ayuda por intentos fallidos (ayuda progresiva)
#   14 documentacion en el plan-actual (03-Diseno.md, seccion "Dificultad")
#
# Modelo de datos puro (RefCounted + static): no instancia escenas. Las bandas y
# las zonas viven en `data/templos/dificultad.json`; la clase solo las lee y
# deriva la dificultad efectiva. La ayuda progresiva SOLO puede REDUCIR la
# demora de la pista (nunca subirla): es ayuda, no castigo.

class_name PuzzleDificultad
extends RefCounted

## Bandas obligatorias, de menor a mayor dificultad (03-Diseno.md, "Dificultad").
const BANDAS := ["exploracion", "ritual", "antiguo"]

## Segundos que la ayuda progresiva recorta por cada subida.
const AYUDA_PASO_S := 15

## Suelo de la demora de pista: la ayuda nunca la baja de aca.
const AYUDA_MINIMO_S := 30

var bandas: Dictionary = {}
var zonas: Dictionary = {}
var intentos_para_subir: int = 3
var max_subidas: int = 1

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[M24] PuzzleDificultad.cargar: no existe %s" % path)
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(crudo) != TYPE_DICTIONARY:
		push_warning("[M24] PuzzleDificultad.cargar: %s no es un objeto JSON" % path)
		return {}
	return crudo as Dictionary

static func desde_def(d: Dictionary) -> PuzzleDificultad:
	var pd := PuzzleDificultad.new()
	pd._construir(d)
	return pd

func _construir(d: Dictionary) -> void:
	bandas = {}
	zonas = {}
	var bl: Variant = d.get("bandas", [])
	if typeof(bl) == TYPE_ARRAY:
		for b in (bl as Array):
			if typeof(b) == TYPE_DICTIONARY:
				var bd: Dictionary = b as Dictionary
				bandas[str(bd.get("id", ""))] = bd
	var zl: Variant = d.get("zonas", [])
	if typeof(zl) == TYPE_ARRAY:
		for z in (zl as Array):
			if typeof(z) == TYPE_DICTIONARY:
				var zd: Dictionary = z as Dictionary
				zonas[str(zd.get("id", ""))] = str(zd.get("banda", ""))
	var ap: Variant = d.get("ayuda_progresiva", {})
	if typeof(ap) == TYPE_DICTIONARY:
		var a: Dictionary = ap as Dictionary
		intentos_para_subir = int(a.get("intentos_para_subir", 3))
		max_subidas = int(a.get("max_subidas", 1))

# --- Item 11: progresion por zona ----------------------------------------

func banda_de_zona(zona: String) -> String:
	return str(zonas.get(zona, ""))

func datos_banda(id: String) -> Dictionary:
	var b: Variant = bandas.get(id, {})
	if typeof(b) != TYPE_DICTIONARY:
		return {}
	return b as Dictionary

func es_banda_valida(id: String) -> bool:
	return bandas.has(id)

## Zonas que pertenecen a una banda (orden de declaracion).
func zonas_de_banda(id: String) -> Array:
	var out: Array = []
	for z in zonas:
		if str(zonas[z]) == id:
			out.append(z)
	return out

## Demora base de la pista de una zona, en segundos (0 si la zona no existe).
func demora_pista(zona: String) -> int:
	var b: String = banda_de_zona(zona)
	if b.is_empty():
		return 0
	return int(datos_banda(b).get("pista_segundos", 0))

func familias_ocultas(zona: String) -> int:
	var b: String = banda_de_zona(zona)
	if b.is_empty():
		return -1
	return int(datos_banda(b).get("familias_ocultas", 0))

# --- Item 13: ayuda progresiva por intentos fallidos ----------------------

## Cuantas subidas de ayuda corresponden a esa cantidad de intentos fallidos.
func nivel_ayuda(intentos_fallidos: int) -> int:
	if intentos_para_subir <= 0 or intentos_fallidos <= 0:
		return 0
	return clampi(intentos_fallidos / intentos_para_subir, 0, max_subidas)

## Demora efectiva: base menos la ayuda. NUNCA supera la base (es ayuda).
func demora_pista_efectiva(zona: String, intentos_fallidos: int) -> int:
	var base: int = demora_pista(zona)
	if base <= 0:
		return 0
	var nivel: int = nivel_ayuda(intentos_fallidos)
	return maxi(base - nivel * AYUDA_PASO_S, AYUDA_MINIMO_S)

func ayuda_activa(zona: String, intentos_fallidos: int) -> bool:
	return demora_pista(zona) > 0 and nivel_ayuda(intentos_fallidos) > 0

# --- Item 10: bandas ------------------------------------------------------

func ids_bandas() -> Array:
	return BANDAS.duplicate()

func rango_emisores(zona: String) -> Dictionary:
	var b: String = banda_de_zona(zona)
	if b.is_empty():
		return {}
	var d: Dictionary = datos_banda(b)
	return {"min": int(d.get("emisores_min", 0)), "max": int(d.get("emisores_max", 0))}

# --- Validacion -----------------------------------------------------------

## Valida la coherencia de bandas/zonas/ayuda. Devuelve [] si es coherente.
func validar() -> Array:
	var errores: Array = []
	if bandas.is_empty():
		errores.append("sin bandas declaradas")
		return errores
	for b in BANDAS:
		if not bandas.has(b):
			errores.append("falta la banda obligatoria '%s'" % b)
	for b in bandas:
		var d: Dictionary = datos_banda(str(b))
		if int(d.get("emisores_min", 0)) <= 0:
			errores.append("la banda '%s' declara emisores_min <= 0" % str(b))
		if int(d.get("emisores_max", 0)) < int(d.get("emisores_min", 0)):
			errores.append("la banda '%s' tiene emisores_max < emisores_min" % str(b))
		if int(d.get("pista_segundos", 0)) <= 0:
			errores.append("la banda '%s' declara pista_segundos <= 0" % str(b))
	if zonas.is_empty():
		errores.append("sin zonas declaradas")
	for z in zonas:
		var b: String = str(zonas[z])
		if not bandas.has(b):
			errores.append("la zona '%s' apunta a una banda inexistente '%s'" % [str(z), b])
	# La progresion por zona debe cubrir las 3 bandas (item 11).
	var cubiertas: Dictionary = {}
	for z in zonas:
		cubiertas[str(zonas[z])] = true
	for b in BANDAS:
		if not cubiertas.has(b):
			errores.append("la progresion por zona no cubre la banda '%s'" % b)
	if intentos_para_subir <= 0:
		errores.append("intentos_para_subir invalido (%d)" % intentos_para_subir)
	if max_subidas < 0:
		errores.append("max_subidas invalido (%d)" % max_subidas)
	return errores
