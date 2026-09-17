# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Transporte y Navegación: VIAJES NARRATIVOS (sección O).
#
# Rutas que AVANZAN la historia (M22/M23). Reglas duras del diseño
# (03-Diseno §2.3):
#   * SIN coste (no se cobra boleto);
#   * SIN horario ni restricción de clima (ruta especial);
#   * NO interrumpible (no se puede cancelar a mitad);
#   * diálogos a bordo (M21) y avance de hitos/sellos al llegar (M22/M23).
#
# El registro está anclado a los nodos y sellos REALES de
# `data/historia/historia_principal.json`: c4 ("El Valle de los Vientos",
# Templo de la Brisa → `puerto_brisa`), c7 ("La Cámara del Sello") y
# final_secreto (flag `pistas_secreto_completas` → `puerto_espejo`).
#
# Puro y sin escena: el plan se construye con `TransportTripPlanner` y el avance
# de hitos se delega por duck-typing en `Historia` (M22), así que es verificable
# headless sin el runtime 3D.

class_name TransportNarrativeTrips
extends RefCounted

## Modo que el planner no produce por sí solo: viaje narrativo.
const MODO_NARRATIVO := "narrativo"

var _viajes: Array[Dictionary] = []


func _init(viajes: Array[Dictionary] = []) -> void:
	_viajes = viajes if not viajes.is_empty() else crear_registro_defecto()


## ── Registro por defecto (anclado al grafo de historia real) ──────────────

static func crear_registro_defecto() -> Array[Dictionary]:
	return [
		{
			"id": "nar_c4_templo_brisa",
			"capitulo": 4,
			"ruta_id": "r_aurora_brisa",
			"origen_id": "puerto_aurora",
			"destino_id": "puerto_brisa",
			"nombre_clave": "M68.NARR.C4_BRIS",
			"sin_coste": true,
			"precio": 0,
			"interrumpible": false,
			"hito_llegada": "c4",
			"sello_llegada": "",
			"requiere_flag": "templo_brisa_abierto",
			"dialogos_a_bordo": ["M68.NARR.C4.01", "M68.NARR.C4.02"],
			"duracion_seg": 90.0,
		},
		{
			"id": "nar_c7_camara_sello",
			"capitulo": 7,
			"ruta_id": "r_aurora_brisa",
			"origen_id": "puerto_aurora",
			"destino_id": "puerto_brisa",
			"nombre_clave": "M68.NARR.C7_CAMARA",
			"sin_coste": true,
			"precio": 0,
			"interrumpible": false,
			"hito_llegada": "c7",
			"sello_llegada": "sello_brisa_camara",
			"requiere_flag": "",
			"dialogos_a_bordo": ["M68.NARR.C7.01", "M68.NARR.C7.02", "M68.NARR.C7.03"],
			"duracion_seg": 90.0,
		},
		{
			"id": "nar_final_secreto",
			"capitulo": 7,
			"ruta_id": "r_aurora_espejo",
			"origen_id": "puerto_aurora",
			"destino_id": "puerto_espejo",
			"nombre_clave": "M68.NARR.FINAL_SECRETO",
			"sin_coste": true,
			"precio": 0,
			"interrumpible": false,
			"hito_llegada": "final_secreto",
			"sello_llegada": "",
			"requiere_flag": "pistas_secreto_completas",
			"dialogos_a_bordo": ["M68.NARR.SECRETO.01"],
			"duracion_seg": 110.0,
		},
	]


## ── Registro en runtime (M22/M23 pueden añadir los suyos) ────────────────

## Añade un viaje narrativo. Rechaza ids duplicados y viajes con coste.
func registrar(viaje: Dictionary) -> bool:
	if viaje.is_empty():
		return false
	var id: String = str(viaje.get("id", ""))
	if id.is_empty() or not viaje(id).is_empty():
		return false
	if not bool(viaje.get("sin_coste", false)):
		return false
	_viajes.append(viaje)
	return true


func viajes() -> Array[Dictionary]:
	return _viajes.duplicate()


func contar() -> int:
	return _viajes.size()


func viaje(id: String) -> Dictionary:
	for v in _viajes:
		if str(v.get("id", "")) == id:
			return v
	return {}


## Primer viaje narrativo declarado para un capítulo ("" si no hay).
func viaje_para_capitulo(capitulo: int) -> Dictionary:
	for v in _viajes:
		if int(v.get("capitulo", -1)) == capitulo:
			return v
	return {}


func capitulos_cubiertos() -> Array[int]:
	var out: Array[int] = []
	for v in _viajes:
		var c: int = int(v.get("capitulo", -1))
		if c >= 0 and not out.has(c):
			out.append(c)
	out.sort()
	return out


## ¿Se puede iniciar? Exige capítulo alcanzado y flag de historia (si la hay).
func disponible_para(viaje: Dictionary, capitulo_actual: int, flags: Array = []) -> Dictionary:
	if viaje.is_empty():
		return {"ok": false, "motivo": "viaje narrativo inexistente"}
	var cap: int = int(viaje.get("capitulo", -1))
	if capitulo_actual < cap:
		return {"ok": false, "motivo": "requiere el capítulo %d" % cap}
	var flag: String = str(viaje.get("requiere_flag", ""))
	if not flag.is_empty() and not flags.has(flag):
		return {"ok": false, "motivo": "requiere progreso: %s" % flag}
	return {"ok": true, "motivo": ""}


## ── Plan del viaje narrativo (sin coste, no interrumpible) ───────────────

## Construye el plan con el planner común y le inyecta lo narrativo.
## Devuelve el plan (o un plan abortado si la ruta/parada no existen).
func plan_narrativo(viaje: Dictionary, red: TransportNetwork, opciones: Dictionary = {}) -> Dictionary:
	if viaje.is_empty():
		return {"ok": false, "motivo": "viaje narrativo inexistente", "modo": MODO_NARRATIVO}
	if red == null:
		return {"ok": false, "motivo": "sin red de transporte", "modo": MODO_NARRATIVO}
	var ruta: TransportRoute = red.ruta(StringName(str(viaje.get("ruta_id", ""))))
	var destino: TransportStop = red.stop(StringName(str(viaje.get("destino_id", ""))))
	var opts: Dictionary = opciones.duplicate()
	if not opts.has("destino_nombre"):
		opts["destino_nombre"] = destino.nombre_fallback if destino != null else ""
	var plan: Dictionary = TransportTripPlanner.planificar(ruta, destino, opts)
	plan["modo"] = MODO_NARRATIVO
	plan["narrativo"] = true
	plan["viaje_id"] = str(viaje.get("id", ""))
	plan["capitulo"] = int(viaje.get("capitulo", -1))
	plan["precio"] = 0
	plan["sin_coste"] = true
	plan["interrumpible"] = false
	plan["dialogos_a_bordo"] = _lista(viaje.get("dialogos_a_bordo", []))
	plan["hito_llegada"] = str(viaje.get("hito_llegada", ""))
	plan["sello_llegada"] = str(viaje.get("sello_llegada", ""))
	return plan


## Diálogos a bordo declarados (M21). Sin coste de ejecución: sólo los ids.
func dialogos_a_bordo(viaje: Dictionary) -> Array[String]:
	return _lista(viaje.get("dialogos_a_bordo", []))


## ¿Es interrumpible? El diseño exige que NO lo sea.
func es_interrumpible(viaje: Dictionary) -> bool:
	return bool(viaje.get("interrumpible", true))


## ── Avance de hitos al llegar (M22/M23, duck-typing tolerante) ───────────

## Llama a `Historia` (M22) para completar el nodo y marcar el sello. Nunca
## lanza: si M22 no está o el id no existe, devuelve el motivo.
func avanzar_hitos(viaje: Dictionary, historia: Object = null) -> Dictionary:
	var res: Dictionary = {
		"ok": false,
		"hito": str(viaje.get("hito_llegada", "")),
		"hito_ok": false,
		"sello": str(viaje.get("sello_llegada", "")),
		"sello_ok": false,
		"motivo": "",
	}
	if historia == null:
		res["motivo"] = "sin M22 (Historia)"
		return res
	if res["hito"] != "" and historia.has_method("completar_nodo"):
		var r: Variant = historia.call("completar_nodo", res["hito"])
		if r is Dictionary:
			var rd: Dictionary = r
			res["hito_ok"] = bool(rd.get("ok", false))
			if not res["hito_ok"]:
				res["motivo"] = str(rd.get("motivo", "hito no completado"))
		else:
			res["hito_ok"] = bool(r)
	if res["sello"] != "" and historia.has_method("marcar_sello"):
		res["sello_ok"] = bool(historia.call("marcar_sello", res["sello"]))
	res["ok"] = bool(res["hito_ok"]) or bool(res["sello_ok"])
	if not res["ok"] and str(res["motivo"]).is_empty():
		res["motivo"] = "sin hitos declarados"
	return res


## ── Validación ───────────────────────────────────────────────────────────

func validar(red: TransportNetwork, historia: Object = null) -> Array[String]:
	var errores: Array[String] = []
	if red == null:
		return ["sin red de transporte"]
	var vistos: Array[String] = []
	for v in _viajes:
		var id: String = str(v.get("id", ""))
		if id.is_empty():
			errores.append("viaje narrativo sin id")
			continue
		if vistos.has(id):
			errores.append("id de viaje narrativo duplicado: %s" % id)
		vistos.append(id)
		# Regla dura: sin coste.
		if not bool(v.get("sin_coste", false)):
			errores.append("%s: un viaje narrativo no puede costar" % id)
		if int(v.get("precio", -1)) != 0:
			errores.append("%s: precio debe ser 0" % id)
		# Regla dura: no interrumpible.
		if bool(v.get("interrumpible", true)):
			errores.append("%s: un viaje narrativo no puede ser interrumpible" % id)
		# Ruta y paradas reales.
		var ruta: TransportRoute = red.ruta(StringName(str(v.get("ruta_id", ""))))
		if ruta == null:
			errores.append("%s: ruta inexistente '%s'" % [id, str(v.get("ruta_id", ""))])
		else:
			if String(ruta.from_id) != str(v.get("origen_id", "")):
				errores.append("%s: origen declarado no coincide con la ruta" % id)
			if String(ruta.to_id) != str(v.get("destino_id", "")):
				errores.append("%s: destino declarado no coincide con la ruta" % id)
		# Capítulo en rango.
		var cap: int = int(v.get("capitulo", -1))
		if cap < 0 or cap > 7:
			errores.append("%s: capítulo fuera de rango (%d)" % [id, cap])
		# Hito y sello deben existir en M22 si M22 está disponible.
		if historia != null and historia.has_method("get_nodo"):
			var hito: String = str(v.get("hito_llegada", ""))
			if not hito.is_empty():
				var nodo: Variant = historia.call("get_nodo", hito)
				var vacio: bool = true
				if nodo is Dictionary:
					vacio = (nodo as Dictionary).is_empty()
				if vacio:
					errores.append("%s: hito '%s' no existe en M22" % [id, hito])
		# Diálogos a bordo declarados (M21): sin ids no hay guion que reproducir.
		if _lista(v.get("dialogos_a_bordo", [])).is_empty():
			errores.append("%s: sin diálogos a bordo declarados (M21)" % id)
	return errores


func claves_localizacion() -> Array[String]:
	var out: Array[String] = []
	for v in _viajes:
		var k: String = str(v.get("nombre_clave", ""))
		if not k.is_empty() and not out.has(k):
			out.append(k)
		for d in _lista(v.get("dialogos_a_bordo", [])):
			if not out.has(d):
				out.append(d)
	out.sort()
	return out


func resumen() -> String:
	return "M68 narrativos: %d viajes, capítulos %s" % [_viajes.size(), str(capitulos_cubiertos())]


static func _lista(valor: Variant) -> Array[String]:
	var out: Array[String] = []
	if valor is Array:
		for x in valor:
			out.append(str(x))
	return out
