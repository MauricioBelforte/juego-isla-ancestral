# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-26
#
# M75: validate_postgame.gd — integridad del catalogo postgame (03-Diseno §3.3).
#
# Reglas implementadas (una clave estable por regla, para poder asertar la CAUSA):
#   ids_unicos       -> "id_duplicado:<id>"
#   fase_valida      -> "fase_invalida:<id>:<fase>"      (§3.1: fase ∈ {1,2})
#   fase2_oculta     -> "fase2_visible:<id>" / "fase1_oculta:<id>"  (§2.2 + Flujo D)
#   dueno_declarado  -> "dueno_ausente:<id>"
#   dueno_existe     -> "dueno_desconocido:<id>:<M>"     (§3.3 "modulo existente")
#   sin_grindeo      -> "grindeo_umbral:<id>:<n>" / "grindeo_ventana:<id>"
#   logro_hito_real  -> "logro_sin_hito:<id>:<logro>"    (§3.3 "logros Epilogo")
#
# ⚠️ extends RefCounted: NO se corre con --script (se colgaria, no es un MainLoop).
#    Lo ejercita scripts/postgame/test_postgame.gd con preload + llamadas estaticas.
extends RefCounted

const RUTA_CHECKLIST_REL: String = "../../CHECKLIST-GLOBAL.md"
const RUTA_ACTIVIDADES: String = "res://data/postgame/actividades.json"
## Campos que introducirian una ventana temporal (FOMO/grindeo por fecha unica).
const CAMPOS_VENTANA: Array[String] = ["expira", "vence", "ventana", "fecha_unica", "solo_dia"]


## Lee el catalogo CRUDO (con fase/hidden/repite/umbral) desde el JSON.
## Devuelve [] si el archivo no parsea: el llamador distingue 0 entradas de fallo.
static func cargar_catalogo(ruta: String = "") -> Array:
	var p := ruta if not ruta.is_empty() else RUTA_ACTIVIDADES
	if not FileAccess.file_exists(p):
		return []
	var parseado: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	if typeof(parseado) != TYPE_DICTIONARY:
		return []
	var datos: Dictionary = parseado
	var acts: Array = datos.get("actividades", [])
	return acts


## Valida el catalogo. `ids_modulos` vacio => la regla dueno_existe se OMITE
## (se declara en `omitidas`, nunca se da por buena en silencio).
## `hitos` vacio => la regla logro_hito_real se OMITE por la misma razon.
static func validar(actividades: Array, ids_modulos: Array = [], hitos: Array = []) -> Dictionary:
	var problemas: Array[String] = []
	var reglas: Dictionary = {}
	var omitidas: Array[String] = []
	var vistos: Dictionary = {}

	for a in actividades:
		if typeof(a) != TYPE_DICTIONARY:
			problemas.append("entrada_no_diccionario")
			continue
		var entrada: Dictionary = a
		var id := String(entrada.get("id", ""))
		if id.is_empty():
			problemas.append("id_vacio")
			continue

		# ids_unicos
		if vistos.has(id):
			problemas.append("id_duplicado:%s" % id)
		else:
			vistos[id] = true
			reglas["ids_unicos"] = int(reglas.get("ids_unicos", 0)) + 1

		# fase_valida
		var fase := int(entrada.get("fase", 0))
		reglas["fase_valida"] = int(reglas.get("fase_valida", 0)) + 1
		if fase != 1 and fase != 2:
			problemas.append("fase_invalida:%s:%d" % [id, fase])

		# fase2_oculta (§2.2: FASE 2 nunca visible; Flujo D: flag hidden)
		var oculta := bool(entrada.get("hidden", false))
		reglas["fase2_oculta"] = int(reglas.get("fase2_oculta", 0)) + 1
		if fase == 2 and not oculta:
			problemas.append("fase2_visible:%s" % id)
		if fase == 1 and oculta:
			problemas.append("fase1_oculta:%s" % id)

		# dueno_declarado / dueno_existe
		var dueno := String(entrada.get("dueno", ""))
		reglas["dueno_declarado"] = int(reglas.get("dueno_declarado", 0)) + 1
		if dueno.is_empty():
			problemas.append("dueno_ausente:%s" % id)
		elif not ids_modulos.is_empty():
			reglas["dueno_existe"] = int(reglas.get("dueno_existe", 0)) + 1
			for token in dueno.split("/", false):
				if not ids_modulos.has(String(token).strip_edges()):
					problemas.append("dueno_desconocido:%s:%s" % [id, String(token).strip_edges()])

		# sin_grindeo: ninguna actividad puede exigir acumulacion ni ventana temporal
		reglas["sin_grindeo"] = int(reglas.get("sin_grindeo", 0)) + 1
		var umbral := int(entrada.get("umbral", 0))
		if umbral > 0:
			problemas.append("grindeo_umbral:%s:%d" % [id, umbral])
		for campo in CAMPOS_VENTANA:
			if entrada.has(campo) and not String(entrada.get(campo, "")).is_empty():
				problemas.append("grindeo_ventana:%s" % id)
				break

		# logro_hito_real: si la actividad declara un logro, debe ser un hito real
		var logro := String(entrada.get("logro", ""))
		if not logro.is_empty():
			if hitos.is_empty():
				problemas.append("logro_no_verificable:%s:%s" % [id, logro])
			else:
				reglas["logro_hito_real"] = int(reglas.get("logro_hito_real", 0)) + 1
				if not hitos.has(logro):
					problemas.append("logro_sin_hito:%s:%s" % [id, logro])

	if ids_modulos.is_empty():
		omitidas.append("dueno_existe")
	if hitos.is_empty():
		omitidas.append("logro_hito_real")

	return {
		"ok": problemas.is_empty(),
		"problemas": problemas,
		"reglas": reglas,
		"omitidas": omitidas,
		"total_entradas": actividades.size(),
	}


## Ids de modulo declarados en CHECKLIST-GLOBAL.md, en la forma canonica `M<NN>`
## (la columna ID de la tabla es numerica: `| 27 | 27-Ruinas |` -> "M27", que es
## como el catalogo declara `dueno`).
## Devuelve [] si el archivo no resuelve: el llamador DEBE distinguir
## "no hay modulos" de "no pude leer" (test_postgame asevera size() > 0).
static func leer_ids_modulos() -> Array[String]:
	var ids: Array[String] = []
	var base := ProjectSettings.globalize_path("res://")
	var ruta := base.path_join(RUTA_CHECKLIST_REL).simplify_path()
	if not FileAccess.file_exists(ruta):
		return ids
	var texto := FileAccess.get_file_as_string(ruta)
	for linea in texto.split("\n"):
		var l := linea.strip_edges()
		if not l.begins_with("|"):
			continue
		var celdas := l.split("|")
		if celdas.size() < 3:
			continue
		var primera := String(celdas[1]).strip_edges()
		if primera.is_valid_int():
			ids.append("M%d" % primera.to_int())
	return ids


## Resumen legible (para el log del validador).
static func formatear(resultado: Dictionary) -> String:
	var problemas: Array = resultado.get("problemas", [])
	var omitidas: Array = resultado.get("omitidas", [])
	var partes: Array[String] = []
	partes.append("entradas=%d ok=%s problemas=%d" % [
		int(resultado.get("total_entradas", 0)),
		str(bool(resultado.get("ok", false))),
		problemas.size(),
	])
	if not omitidas.is_empty():
		partes.append("reglas omitidas=%s" % str(omitidas))
	for p in problemas:
		partes.append("  ! %s" % String(p))
	return " | ".join(partes)
