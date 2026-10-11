# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: capa de TUTORIALIZACION.
# Cierra los items 19, 20, 21, 22 y 23 del checklist:
#   19 guia del templo (mural) por zona
#   20 narrador suave en la primera solucion (hooks M33/M31)
#   21 iconografia de glifos reconocible en la guia
#   22 tutorializacion sin texto invasivo (visuales primero)
#   23 documentacion en el plan-actual (03-Diseno.md)
#
# Modelo de datos puro (RefCounted + static). Los murales, la iconografia y el
# narrador viven en `data/templos/tutorial.json`. El narrador es DUCK-TYPED
# contra el contrato real de M33 (`scripts/dialogos/dialogue_manager.gd`,
# `start_dialogue(dialogue_id, context) -> bool`): no se acopla al autoload.

class_name PuzzleTutorial
extends RefCounted

## Orden obligatorio de presentacion: lo visual manda (item 22).
const ORDEN_VISUAL_PRIMERO := ["visual", "icono", "texto"]

var murales: Dictionary = {}
var iconografia: Dictionary = {}
var narrador: Dictionary = {}
var presentacion: Dictionary = {}

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[M24] PuzzleTutorial.cargar: no existe %s" % path)
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(crudo) != TYPE_DICTIONARY:
		push_warning("[M24] PuzzleTutorial.cargar: %s no es un objeto JSON" % path)
		return {}
	return crudo as Dictionary

static func desde_def(d: Dictionary) -> PuzzleTutorial:
	var pt := PuzzleTutorial.new()
	pt._construir(d)
	return pt

func _construir(d: Dictionary) -> void:
	murales = {}
	iconografia = {}
	var ml: Variant = d.get("murales", [])
	if typeof(ml) == TYPE_ARRAY:
		for m in (ml as Array):
			if typeof(m) == TYPE_DICTIONARY:
				var md: Dictionary = m as Dictionary
				murales[str(md.get("zona", ""))] = md
	var il: Variant = d.get("iconografia", [])
	if typeof(il) == TYPE_ARRAY:
		for i in (il as Array):
			if typeof(i) == TYPE_DICTIONARY:
				var id: Dictionary = i as Dictionary
				iconografia[str(id.get("glifo", ""))] = id
	var nz: Variant = d.get("narrador", {})
	narrador = (nz as Dictionary) if typeof(nz) == TYPE_DICTIONARY else {}
	var pz: Variant = d.get("presentacion", {})
	presentacion = (pz as Dictionary) if typeof(pz) == TYPE_DICTIONARY else {}

# --- Item 19: guia del templo (mural) por zona ---------------------------

func guia_de_zona(zona: String) -> Dictionary:
	var m: Variant = murales.get(zona, {})
	if typeof(m) != TYPE_DICTIONARY:
		return {}
	return m as Dictionary

func tiene_guia(zona: String) -> bool:
	return murales.has(zona)

func glifos_de_zona(zona: String) -> Array:
	var g: Variant = guia_de_zona(zona).get("glifos", [])
	if typeof(g) != TYPE_ARRAY:
		return []
	return g as Array

func icono_de_zona(zona: String) -> String:
	return str(guia_de_zona(zona).get("icono", ""))

# --- Item 21: iconografia de glifos --------------------------------------

func icono_de(glifo: String) -> String:
	var i: Variant = iconografia.get(glifo, {})
	if typeof(i) != TYPE_DICTIONARY:
		return ""
	return str((i as Dictionary).get("icono", ""))

func familia_de(glifo: String) -> String:
	var i: Variant = iconografia.get(glifo, {})
	if typeof(i) != TYPE_DICTIONARY:
		return ""
	return str((i as Dictionary).get("familia", ""))

## Un glifo es reconocible si tiene icono declarado y pertenece a una familia.
func es_glifo_reconocible(glifo: String) -> bool:
	return not icono_de(glifo).is_empty() and not familia_de(glifo).is_empty()

func glifos_iconografiados() -> Array:
	return iconografia.keys()

# --- Item 22: presentacion visual-primero --------------------------------

func orden_presentacion() -> Array:
	var o: Variant = presentacion.get("orden", [])
	if typeof(o) != TYPE_ARRAY:
		return []
	return (o as Array).duplicate()

func texto_max_palabras() -> int:
	return int(presentacion.get("texto_max_palabras", 0))

## Tutorializacion sin texto invasivo: lo visual va primero y el texto no
## invade (0 palabras = solo visual/icono).
func es_visual_primero() -> bool:
	var o: Array = orden_presentacion()
	if o.is_empty():
		return false
	return str(o[0]) == "visual" and o.has("icono") and o.has("texto")

func sin_texto_invasivo() -> bool:
	return es_visual_primero() and texto_max_palabras() <= 0

# --- Item 20: narrador suave en la primera solucion ----------------------

func narrador_hook() -> Dictionary:
	return narrador.duplicate()

func narrador_primera_solucion() -> bool:
	return bool(narrador.get("primera_solucion", false))

## Dispara el narrador SOLO en la primera solucion y si el receptor expone el
## contrato de M33 (`start_dialogue(dialogue_id, context) -> bool`).
func disparar_narrador(primera_solucion: bool, narrador_obj: Object) -> bool:
	if not primera_solucion:
		return false
	if not narrador_primera_solucion():
		return false
	if narrador_obj == null or not narrador_obj.has_method("start_dialogue"):
		return false
	var did: String = str(narrador.get("dialogue_id", ""))
	if did.is_empty():
		return false
	return bool(narrador_obj.call("start_dialogue", did, {}))

func es_suave() -> bool:
	return bool(narrador.get("suave", false))

# --- Validacion -----------------------------------------------------------

## Devuelve [] si la capa de tutorializacion es coherente.
func validar() -> Array:
	var errores: Array = []
	if murales.is_empty():
		errores.append("sin murales declarados: no hay guia del templo")
	for z in murales:
		var g: Array = glifos_de_zona(str(z))
		if g.is_empty():
			errores.append("el mural de la zona '%s' no declara glifos" % str(z))
		if icono_de_zona(str(z)).is_empty():
			errores.append("el mural de la zona '%s' no declara icono" % str(z))
		for gl in g:
			if not iconografia.has(str(gl)):
				errores.append("el mural '%s' cita el glifo '%s' sin iconografia" % [str(z), str(gl)])
	if iconografia.is_empty():
		errores.append("sin iconografia declarada")
	for gl in iconografia:
		if not es_glifo_reconocible(str(gl)):
			errores.append("el glifo '%s' no es reconocible (falta icono o familia)" % str(gl))
	if not es_visual_primero():
		errores.append("la presentacion no es visual-primero: %s" % str(orden_presentacion()))
	if texto_max_palabras() > 0:
		errores.append("texto_max_palabras > 0: la tutorializacion seria textual")
	if not narrador_primera_solucion():
		errores.append("el narrador no esta declarado para la primera solucion")
	if str(narrador.get("dialogue_id", "")).is_empty():
		errores.append("el narrador no declara dialogue_id")
	return errores
