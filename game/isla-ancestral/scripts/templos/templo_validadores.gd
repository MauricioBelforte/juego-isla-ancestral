# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-14
#
# M26 — Templo Subterráneo (iteración 2).
# TemploValidadores: validadores estáticos de las suites que el diseño exige y
# que hasta ahora no existían como código verificable:
#   - softlocks por zona (grafo de salas alcanzable, recompensas con 2+ caminos)
#   - anti-exploit (sin teleports, sellos únicos, salida sellada, rampas <= 20°)
#   - voxel-compatibilidad (metría 4x4x4 m, puertas 2x3, techos 3x3, 45°)
#   - accesibilidad (M58: contraste, iconografía, sin presión temporal)
#   - orientación (mojones cada 40 m, mapa de zona, deriva < 2 min)
#   - checkpoints (5 CP con respaldo .bak)
#
# Todos son `static func` puros: reciben datos y devuelven Array[String] con los
# problemas (vacío = válido). Nada de nodos ni de estado global.

class_name TemploValidadores
extends RefCounted

const RAMPA_GRADOS_MAX := 20.0
const MOJON_METROS_MAX := 40.0
const CONTRASTE_MIN := 4.5
const ICONO_PX_MIN := 16
const DERIVA_MAX_S := 120.0
const CP_ESPERADOS := 5
const ANILLOS_ESPERADOS := 7
const SELLOS_ESPERADOS := 7


# ---------------------------------------------------------------- grafo ----

## Tabla de adyacencia a partir de `salas` + `conexiones` (pares bidireccionales).
static func adyacencia(layout: Dictionary) -> Dictionary:
	var adj: Dictionary = {}
	var salas: Variant = layout.get("salas", [])
	if typeof(salas) == TYPE_ARRAY:
		for sala in (salas as Array):
			if typeof(sala) != TYPE_DICTIONARY:
				continue
			var sid := str((sala as Dictionary).get("id", ""))
			if sid.is_empty():
				continue
			if not adj.has(sid):
				adj[sid] = []
	var conexiones: Variant = layout.get("conexiones", [])
	if typeof(conexiones) == TYPE_ARRAY:
		for par in (conexiones as Array):
			if typeof(par) != TYPE_ARRAY or (par as Array).size() < 2:
				continue
			var a := str((par as Array)[0])
			var b := str((par as Array)[1])
			if a.is_empty() or b.is_empty():
				continue
			if not adj.has(a):
				adj[a] = []
			if not adj.has(b):
				adj[b] = []
			(adj[a] as Array).append(b)
			(adj[b] as Array).append(a)
	return adj


## BFS: conjunto de salas alcanzables desde `desde`.
static func alcanzables(layout: Dictionary, desde: String) -> Dictionary:
	var adj := adyacencia(layout)
	var visto: Dictionary = {}
	if not adj.has(desde):
		return visto
	var cola: Array = [desde]
	visto[desde] = true
	while not cola.is_empty():
		var actual: String = str(cola.pop_front())
		for vecino in (adj.get(actual, []) as Array):
			var v := str(vecino)
			if not visto.has(v):
				visto[v] = true
				cola.append(v)
	return visto


static func _salas(layout: Dictionary) -> Array:
	var s: Variant = layout.get("salas", [])
	return (s as Array) if typeof(s) == TYPE_ARRAY else []


static func _sala_por_tipo(layout: Dictionary, tipo: String) -> Array:
	var res: Array = []
	for sala in _salas(layout):
		if str((sala as Dictionary).get("tipo", "")) == tipo:
			res.append(sala)
	return res


# ------------------------------------------------------------- softlock ----

## Softlocks por zona (M66): grafo sano y sin callejones sin salida.
static func validar_softlock(layout: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var salas := _salas(layout)
	if salas.is_empty():
		return ["layout sin salas"]
	var ids: Dictionary = {}
	for sala in salas:
		var sid := str((sala as Dictionary).get("id", ""))
		if sid.is_empty():
			errores.append("sala sin id")
		elif ids.has(sid):
			errores.append("sala duplicada: %s" % sid)
		else:
			ids[sid] = true
	# Exactamente una entrada y una salida.
	var entradas := _sala_por_tipo(layout, "entrada")
	var salidas := _sala_por_tipo(layout, "salida")
	if entradas.size() != 1:
		errores.append("debe haber exactamente 1 sala de tipo 'entrada' (hay %d)" % entradas.size())
	if salidas.size() != 1:
		errores.append("debe haber exactamente 1 sala de tipo 'salida' (hay %d)" % salidas.size())
	# Toda sala debe ser alcanzable desde la entrada (nada de zonas muertas).
	if entradas.size() == 1:
		var entrada_id := str((entradas[0] as Dictionary).get("id", ""))
		var alcanzables_ids := alcanzables(layout, entrada_id)
		for sala in salas:
			var sid := str((sala as Dictionary).get("id", ""))
			if not alcanzables_ids.has(sid):
				errores.append("sala inalcanzable desde la entrada: %s" % sid)
	# Toda sala (salvo la salida) debe poder continuar: >= 1 conexión.
	var adj := adyacencia(layout)
	var salida_id := str((salidas[0] as Dictionary).get("id", "")) if salidas.size() == 1 else ""
	for sala in salas:
		var sid := str((sala as Dictionary).get("id", ""))
		if sid == salida_id:
			continue
		if (adj.get(sid, []) as Array).is_empty():
			errores.append("sala sin conexiones (callejón sin salida): %s" % sid)
	# Zonas con recompensa (salas secretas) deben tener 2+ caminos (M66).
	for sala in salas:
		var sd: Dictionary = sala as Dictionary
		var es_secreta := str(sd.get("tipo", "")) == "secreta" or not str(sd.get("recompensa", "")).is_empty()
		if not es_secreta:
			continue
		var sid := str(sd.get("id", ""))
		var vecinos := adj.get(sid, []) as Array
		if vecinos.size() < 2:
			errores.append("zona con recompensa con menos de 2 caminos: %s (%d)" % [sid, vecinos.size()])
	# Todo puzzle referenciado por una sala debe existir en `puzzles`.
	var ids_puzzles: Dictionary = {}
	var puzzles: Variant = layout.get("puzzles", [])
	if typeof(puzzles) == TYPE_ARRAY:
		for p in (puzzles as Array):
			ids_puzzles[str((p as Dictionary).get("id", ""))] = true
	for sala in salas:
		var sd: Dictionary = sala as Dictionary
		var sp: Variant = sd.get("puzzles", [])
		if typeof(sp) != TYPE_ARRAY:
			continue
		for pid in (sp as Array):
			if not ids_puzzles.has(str(pid)):
				errores.append("sala %s referencia un puzzle inexistente: %s" % [sd.get("id", ""), pid])
	return errores


# ----------------------------------------------------------- anti-exploit --

## Exploits: sellos duplicados, entrada por la salida sellada, teleports, rampas.
static func validar_anti_exploit(layout: Dictionary, blueprint: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	# 1) Sellos únicos: ninguna recompensa repetida en dos puzzles.
	var vistas: Dictionary = {}
	var puzzles: Variant = layout.get("puzzles", [])
	if typeof(puzzles) == TYPE_ARRAY:
		for p in (puzzles as Array):
			var pd: Dictionary = p as Dictionary
			var rec := str(pd.get("recompensa", ""))
			if rec.is_empty():
				continue
			if vistas.has(rec):
				errores.append("recompensa duplicada (sello duplicable): %s" % rec)
			vistas[rec] = true
	# 2) La salida debe declarar que requiere el sello restaurado.
	var salidas := _sala_por_tipo(layout, "salida")
	if salidas.size() == 1:
		var req := str((salidas[0] as Dictionary).get("requiere", ""))
		if req != "sello_restaurado":
			errores.append("la salida no exige 'sello_restaurado' (requiere='%s')" % req)
	# 3) Blueprint: sin teleports, con barreras en huecos, rampas dentro del límite.
	var vox: Variant = blueprint.get("voxel", {})
	if typeof(vox) == TYPE_DICTIONARY:
		var vd: Dictionary = vox as Dictionary
		if bool(vd.get("teleports", true)):
			errores.append("blueprint permite teleports (anti-exploit)")
		if not bool(vd.get("barreras_en_huecos", false)):
			errores.append("blueprint sin barreras invisibles en huecos")
		if float(vd.get("rampa_grados_max", 999.0)) > RAMPA_GRADOS_MAX:
			errores.append("rampa %.0f° > %.0f° (permite aceleración por salto)" % [
				float(vd.get("rampa_grados_max", 999.0)), RAMPA_GRADOS_MAX])
	else:
		errores.append("blueprint sin sección voxel")
	# 4) El gating debe declarar 7 anillos y sellos únicos.
	var gat: Variant = blueprint.get("gating", {})
	if typeof(gat) == TYPE_DICTIONARY:
		var gd: Dictionary = gat as Dictionary
		if int(gd.get("anillos", 0)) != ANILLOS_ESPERADOS:
			errores.append("gating.anillos debe ser %d (real %s)" % [ANILLOS_ESPERADOS, gd.get("anillos", 0)])
		if not bool(gd.get("sellos_unicos", false)):
			errores.append("gating.sellos_unicos debe ser true")
		if str(gd.get("salida_requiere", "")) != "sello_restaurado":
			errores.append("gating.salida_requiere debe ser 'sello_restaurado'")
	return errores


# ---------------------------------------------------------------- voxel ----

## Metría voxel-compatible: corredor 4x4x4 m, puerta 2x3, techo 3x3, 45°.
static func validar_voxel(blueprint: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var vox: Variant = blueprint.get("voxel", {})
	if typeof(vox) != TYPE_DICTIONARY:
		return ["blueprint sin sección voxel"]
	var vd: Dictionary = vox as Dictionary
	var cor: Variant = vd.get("corredor", {})
	if typeof(cor) != TYPE_DICTIONARY:
		errores.append("voxel.corredor ausente")
	else:
		var cd: Dictionary = cor as Dictionary
		if int(cd.get("ancho", 0)) != 4 or int(cd.get("alto", 0)) != 4 or int(cd.get("largo", 0)) != 4:
			errores.append("corredor debe ser 4x4x4 m (real %sx%sx%s)" % [
				cd.get("ancho", 0), cd.get("alto", 0), cd.get("largo", 0)])
	var pu: Variant = vd.get("puerta", {})
	if typeof(pu) != TYPE_DICTIONARY:
		errores.append("voxel.puerta ausente")
	else:
		var pd: Dictionary = pu as Dictionary
		if int(pd.get("ancho", 0)) != 2 or int(pd.get("alto", 0)) != 3:
			errores.append("puerta debe ser 2x3 bloques (real %sx%s)" % [pd.get("ancho", 0), pd.get("alto", 0)])
	var te: Variant = vd.get("techo", {})
	if typeof(te) != TYPE_DICTIONARY:
		errores.append("voxel.techo ausente")
	else:
		var td: Dictionary = te as Dictionary
		if int(td.get("ancho", 0)) != 3 or int(td.get("alto", 0)) != 3:
			errores.append("techo debe ser 3x3 bloques (real %sx%s)" % [td.get("ancho", 0), td.get("alto", 0)])
	if int(vd.get("transiciones_grados", 0)) != 45:
		errores.append("transiciones deben ser 45° (real %s)" % vd.get("transiciones_grados", 0))
	if float(vd.get("rampa_grados_max", 999.0)) > RAMPA_GRADOS_MAX:
		errores.append("rampa %.0f° > %.0f°" % [float(vd.get("rampa_grados_max", 999.0)), RAMPA_GRADOS_MAX])
	if float(vd.get("unidad_m", 0.0)) != 1.0:
		errores.append("unidad debe ser 1 m (voxel 1 m del proyecto)")
	return errores


# --------------------------------------------------------- accesibilidad ----

## Accesibilidad M58: contraste, iconografía, sin presión temporal, opciones.
static func validar_accesibilidad(blueprint: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var acc: Variant = blueprint.get("accesibilidad", {})
	if typeof(acc) != TYPE_DICTIONARY:
		return ["blueprint sin sección accesibilidad"]
	var ad: Dictionary = acc as Dictionary
	if float(ad.get("contraste_min", 0.0)) < CONTRASTE_MIN:
		errores.append("contraste %.1f:1 < %.1f:1 (M58)" % [float(ad.get("contraste_min", 0.0)), CONTRASTE_MIN])
	if int(ad.get("icono_px_min", 0)) < ICONO_PX_MIN:
		errores.append("iconografía %d px < %d px (M58)" % [int(ad.get("icono_px_min", 0)), ICONO_PX_MIN])
	if bool(ad.get("presion_temporal", true)):
		errores.append("los puzzles no deben tener presión temporal (cozy)")
	if not bool(ad.get("subtitulos", false)):
		errores.append("faltan subtítulos activables (M43)")
	if not bool(ad.get("reduccion_particulas", false)):
		errores.append("falta opción de reducción de partículas")
	if not bool(ad.get("reduccion_parpadeo", false)):
		errores.append("falta opción de reducción de parpadeo (fotosensibilidad)")
	return errores


# ------------------------------------------------------------ orientación --

## Orientación: mojones cada ≤ 40 m, mapa de zona, deriva máxima.
static func validar_orientacion(blueprint: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var ori: Variant = blueprint.get("orientacion", {})
	if typeof(ori) != TYPE_DICTIONARY:
		return ["blueprint sin sección orientacion"]
	var od: Dictionary = ori as Dictionary
	if float(od.get("mojon_metros_max", 999.0)) > MOJON_METROS_MAX:
		errores.append("mojones cada %.0f m > %.0f m" % [float(od.get("mojon_metros_max", 999.0)), MOJON_METROS_MAX])
	if not bool(od.get("mapa_de_zona", false)):
		errores.append("falta el mapa de zona simplificado (panel M58)")
	if float(od.get("deriva_max_s", 9999.0)) > DERIVA_MAX_S:
		errores.append("deriva máxima %.0f s > %.0f s" % [float(od.get("deriva_max_s", 9999.0)), DERIVA_MAX_S])
	return errores


# ------------------------------------------------------------ checkpoints --

## Los 5 checkpoints deben estar presentes y con respaldo .bak declarado.
static func validar_checkpoints(layout: Dictionary, blueprint: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var cps: Array = []
	for sala in _salas(layout):
		if bool((sala as Dictionary).get("checkpoint", false)):
			cps.append(str((sala as Dictionary).get("id", "")))
	if cps.size() != CP_ESPERADOS:
		errores.append("deben existir %d checkpoints (hay %d: %s)" % [CP_ESPERADOS, cps.size(), str(cps)])
	var decl: Variant = blueprint.get("checkpoints", [])
	if typeof(decl) != TYPE_ARRAY or (decl as Array).size() != CP_ESPERADOS:
		errores.append("blueprint.checkpoints debe listar %d ids" % CP_ESPERADOS)
	else:
		for id in (decl as Array):
			if not cps.has(str(id)):
				errores.append("blueprint declara el checkpoint '%s' pero ninguna sala lo tiene" % id)
	if not bool(blueprint.get("checkpoint_respaldo_bak", false)):
		errores.append("blueprint debe declarar checkpoint_respaldo_bak=true")
	return errores


# --------------------------------------------------------------- conjunto --

## Corre todas las suites y devuelve {suite: [errores]}. `ok` = todas vacías.
static func validar_todo(layout: Dictionary, blueprint: Dictionary) -> Dictionary:
	var res: Dictionary = {
		"softlock": validar_softlock(layout),
		"anti_exploit": validar_anti_exploit(layout, blueprint),
		"voxel": validar_voxel(blueprint),
		"accesibilidad": validar_accesibilidad(blueprint),
		"orientacion": validar_orientacion(blueprint),
		"checkpoints": validar_checkpoints(layout, blueprint),
	}
	var ok := true
	for clave in res:
		if not (res[clave] as Array).is_empty():
			ok = false
	res["ok"] = ok
	return res
