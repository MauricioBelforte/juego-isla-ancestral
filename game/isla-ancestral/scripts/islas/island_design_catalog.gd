# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M27: Islas del Mundo — IslandDesignCatalog (iter. 2).
#
# Catálogo VERIFICABLE de los puntos de la sección 26 del plan maestro
# (`DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md`, líneas 796-821).
#
# ⚠️ El checklist de M27 dice "los 24 puntos de la sección 26". Medido sobre el
# plan: la sección 26 tiene **26** puntos (13 islas + rutas + 13 atributos). El
# catálogo es la fuente de verdad y `validar()` falla si el conteo no cuadra.
#
# Cada punto declara DÓNDE se resuelve:
#   `dataset:<id>`  → una definición real en `data/islas/definiciones/`
#   `campo:<nombre>` → un campo real de `IslandDefinition` (se comprueba con
#                      `get_property_list()`, no por fe)
#   `externo:M##`   → fuera del alcance de M27; el dueño está declarado
#
# Estados:
#   `resuelto`    → M27 lo resuelve a nivel de datos y el dato es real
#   `declarativo` → M27 declara el campo, pero los ids son provisionales hasta
#                   que el dueño publique su catálogo
#   `externo`     → no es de M27
#
# Uso:
#   var err: Array[String] = IslandDesignCatalog.validar(defs)
#   var cob: Dictionary = IslandDesignCatalog.cobertura()

class_name IslandDesignCatalog
extends RefCounted

const GRUPO_ISLAS := "islas"
const GRUPO_RUTAS := "rutas"
const GRUPO_ATRIBUTOS := "atributos"
const GRUPOS: Array[String] = [GRUPO_ISLAS, GRUPO_RUTAS, GRUPO_ATRIBUTOS]

const EST_RESUELTO := "resuelto"
const EST_DECLARATIVO := "declarativo"
const EST_EXTERNO := "externo"
const ESTADOS: Array[String] = [EST_RESUELTO, EST_DECLARATIVO, EST_EXTERNO]

## Puntos REALES de la §26 del plan maestro. Si el plan cambia, este número
## cambia y `validar()` lo detecta.
const TOTAL_PLAN := 26

const RUTA_PLAN := "DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md"
const LINEA_INICIO_PLAN := 796
const LINEA_FIN_PLAN := 821


# ── Los 26 puntos ─────────────────────────────────────────────────────────

static func _p(n: int, texto: String, grupo: String, resolucion: String, estado: String, evidencia: String) -> Dictionary:
	return {
		"n": n,
		"texto": texto,
		"grupo": grupo,
		"resolucion": resolucion,
		"estado": estado,
		"evidencia": evidencia,
		"clave": "M27.DISENO.P%02d" % n,
	}


static func puntos() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	# ── Islas (1-13): cada una es una definición real y validada ──────────
	out.append(_p(1, "Diseñar isla principal", GRUPO_ISLAS, "dataset:aurora", EST_RESUELTO,
		"`aurora` (NUCLEO, radio 256, Bosque, altura 0-140); 03-Diseno §5"))
	out.append(_p(2, "Diseñar Isla de Coral", GRUPO_ISLAS, "dataset:coral", EST_RESUELTO,
		"`coral` (CERCANO, radio 200, Tropical)"))
	out.append(_p(3, "Diseñar Isla Verde", GRUPO_ISLAS, "dataset:verde", EST_RESUELTO,
		"`verde` (CERCANO, radio 190, Tropical)"))
	out.append(_p(4, "Diseñar Isla de las Cenizas", GRUPO_ISLAS, "dataset:cenizas", EST_RESUELTO,
		"`cenizas` (MEDIO, radio 200, Volcánico, flag `progreso_medio`)"))
	out.append(_p(5, "Diseñar Islas del Cielo", GRUPO_ISLAS, "dataset:cielo", EST_RESUELTO,
		"`cielo` (LEJANO, flotante, altura 60-130)"))
	out.append(_p(6, "Diseñar islas de nieve", GRUPO_ISLAS, "dataset:nieve", EST_RESUELTO,
		"`nieve` (LEJANO, radio 190, Nevado)"))
	out.append(_p(7, "Diseñar islas del desierto", GRUPO_ISLAS, "dataset:desierto", EST_RESUELTO,
		"`desierto` (MEDIO, radio 180, Desierto, playa 14)"))
	out.append(_p(8, "Diseñar islas volcánicas", GRUPO_ISLAS, "dataset:volcanica", EST_RESUELTO,
		"`volcanica` (LEJANO, radio 210, Volcánico, altura 0-150)"))
	out.append(_p(9, "Diseñar islas submarinas", GRUPO_ISLAS, "dataset:submarina", EST_RESUELTO,
		"`submarina` (LEJANO, radio 170, altura 0-20, playa 16)"))
	out.append(_p(10, "Diseñar islas flotantes", GRUPO_ISLAS, "dataset:flotante", EST_RESUELTO,
		"`flotante` (MEDIO, flotante, altura 40-90)"))
	out.append(_p(11, "Diseñar islas misteriosas", GRUPO_ISLAS, "dataset:misteriosa", EST_RESUELTO,
		"`misteriosa` (LEJANO, radio 200, Ruinas)"))
	out.append(_p(12, "Diseñar islas pequeñas", GRUPO_ISLAS, "dataset:pequena", EST_RESUELTO,
		"`pequena` (CERCANO, radio 96, Costa)"))
	out.append(_p(13, "Diseñar islas secretas", GRUPO_ISLAS, "dataset:secreta", EST_RESUELTO,
		"`secreta` (LEJANO, `es_secreta`, flag `pista_secreta`)"))
	# ── Rutas (14-15) ─────────────────────────────────────────────────────
	out.append(_p(14, "Diseñar rutas entre islas", GRUPO_RUTAS, "externo:M28", EST_EXTERNO,
		"M27 expone `vecinas()` y `posicion_ancla()`; la travesía es de M28 (M68 para el transporte)"))
	out.append(_p(15, "Definir distancia", GRUPO_RUTAS, "campo:anillo,campo:radio", EST_RESUELTO,
		"Anillos NUCLEO/CERCANO/MEDIO/LEJANO + radio; distancia mínima `ra+rb+64` validada por `validar_anclas()`"))
	# ── Atributos y contenido (16-26) ─────────────────────────────────────
	out.append(_p(16, "Definir navegación", GRUPO_ATRIBUTOS, "externo:M28", EST_EXTERNO,
		"M27 declara el océano navegable entre islas (RF4); barco y navegación son de M28/M67"))
	out.append(_p(17, "Definir clima", GRUPO_ATRIBUTOS, "campo:clima_tendencia", EST_DECLARATIVO,
		"`clima_tendencia` por isla; el id de M32 no está reconciliado todavía"))
	out.append(_p(18, "Definir flora", GRUPO_ATRIBUTOS, "campo:flora_endemica", EST_DECLARATIVO,
		"`flora_endemica` con ids provisionales; el catálogo real es de M50"))
	out.append(_p(19, "Definir fauna", GRUPO_ATRIBUTOS, "campo:fauna_endemica", EST_DECLARATIVO,
		"`fauna_endemica` con ids provisionales; el catálogo real es de M36"))
	out.append(_p(20, "Definir recursos", GRUPO_ATRIBUTOS, "campo:recursos_exclusivos", EST_DECLARATIVO,
		"`recursos_exclusivos` con ids provisionales; el catálogo real es de M15"))
	out.append(_p(21, "Definir NPC", GRUPO_ATRIBUTOS, "campo:npc_residentes", EST_DECLARATIVO,
		"`npc_residentes` con ids provisionales; el catálogo real es de M19"))
	out.append(_p(22, "Definir arquitectura", GRUPO_ATRIBUTOS, "externo:M17", EST_EXTERNO,
		"M27 fija `punto_llegada`/`punto_partida`; el muelle y las casas son de M17/M40"))
	out.append(_p(23, "Definir música", GRUPO_ATRIBUTOS, "campo:musica_clave", EST_DECLARATIVO,
		"`musica_clave` por isla; el id real es de M41"))
	out.append(_p(24, "Definir puzzles", GRUPO_ATRIBUTOS, "campo:puzzles", EST_DECLARATIVO,
		"`puzzles` con ids provisionales; los puzzles son de M23/M24"))
	out.append(_p(25, "Definir recompensa", GRUPO_ATRIBUTOS, "externo:M73", EST_EXTERNO,
		"Regla cozy: nada exclusivo e inaccesible; la vía alternativa es de M73/M28"))
	out.append(_p(26, "Definir relevancia narrativa", GRUPO_ATRIBUTOS, "campo:desbloqueo_flag,campo:es_secreta", EST_RESUELTO,
		"`desbloqueo_flag` (M22 vía WorldState) + `es_secreta`; sin FOMO (M152)"))
	return out


# ── Consultas ─────────────────────────────────────────────────────────────

static func contar() -> int:
	return puntos().size()


static func punto(n: int) -> Dictionary:
	for p in puntos():
		if int(p["n"]) == n:
			return p
	return {}


static func por_estado(estado: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for p in puntos():
		if str(p["estado"]) == estado:
			out.append(p)
	return out


static func por_grupo(grupo: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for p in puntos():
		if str(p["grupo"]) == grupo:
			out.append(p)
	return out


## Resoluciones declaradas por un punto (puede haber varias, separadas por coma).
static func resoluciones(p: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for r in str(p.get("resolucion", "")).split(",", false):
		var t: String = r.strip_edges()
		if not t.is_empty():
			out.append(t)
	return out


static func cobertura() -> Dictionary:
	var resueltos: int = por_estado(EST_RESUELTO).size()
	var declarativos: int = por_estado(EST_DECLARATIVO).size()
	var externos: int = por_estado(EST_EXTERNO).size()
	var total: int = contar()
	return {
		"total": total,
		"resueltos": resueltos,
		"declarativos": declarativos,
		"externos": externos,
		"porcentaje_resuelto": (100.0 * float(resueltos) / float(total)) if total > 0 else 0.0,
		"porcentaje_en_alcance": (100.0 * float(resueltos + declarativos) / float(total)) if total > 0 else 0.0,
	}


static func claves_localizacion() -> Array[String]:
	var out: Array[String] = []
	for p in puntos():
		out.append(str(p["clave"]))
	return out


# ── Validación contra el dataset real ─────────────────────────────────────

static func _campo_existe(defs: Dictionary, campo: String) -> bool:
	for k in defs.keys():
		var d: IslandDefinition = defs[k]
		if d == null:
			continue
		for prop in d.get_property_list():
			if str(prop.get("name", "")) == campo:
				return true
	return false


static func _ids_dataset(defs: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for k in defs.keys():
		out.append(str(k))
	out.sort()
	return out


## Valida el catálogo contra el dataset REAL de islas.
## `defs` = `{id: IslandDefinition}`.
static func validar(defs: Dictionary) -> Array[String]:
	var err: Array[String] = []
	var lista: Array[Dictionary] = puntos()
	if lista.size() != TOTAL_PLAN:
		err.append("el catálogo tiene %d puntos y la §26 del plan tiene %d" % [lista.size(), TOTAL_PLAN])
	var vistos: Dictionary = {}
	for p in lista:
		var n: int = int(p["n"])
		if vistos.has(n):
			err.append("punto duplicado en el catálogo: %d" % n)
		vistos[n] = true
		if n < 1 or n > TOTAL_PLAN:
			err.append("número de punto fuera de rango: %d" % n)
		if str(p["texto"]).strip_edges().is_empty():
			err.append("punto %d sin texto" % n)
		if not GRUPOS.has(str(p["grupo"])):
			err.append("punto %d con grupo inválido: %s" % [n, str(p["grupo"])])
		if not ESTADOS.has(str(p["estado"])):
			err.append("punto %d con estado inválido: %s" % [n, str(p["estado"])])
		if str(p["evidencia"]).strip_edges().is_empty():
			err.append("punto %d sin evidencia declarada" % n)
		var res: Array[String] = resoluciones(p)
		if res.is_empty():
			err.append("punto %d sin resolución declarada" % n)
		for r in res:
			if r.begins_with("dataset:"):
				var id: String = r.substr(8)
				if not defs.has(id):
					err.append("punto %d referencia el dataset '%s', que no existe" % [n, id])
			elif r.begins_with("campo:"):
				var campo: String = r.substr(6)
				if not _campo_existe(defs, campo):
					err.append("punto %d referencia el campo '%s', que no existe en IslandDefinition" % [n, campo])
			elif r.begins_with("externo:"):
				var dueno: String = r.substr(8).strip_edges()
				if dueno.is_empty():
					err.append("punto %d declara un dueño externo vacío" % n)
			else:
				err.append("punto %d con resolución mal formada: %s" % [n, r])
	for i in range(1, TOTAL_PLAN + 1):
		if not vistos.has(i):
			err.append("falta el punto %d del plan" % i)
	return err


## Campos citados por el catálogo que NO existen en IslandDefinition.
static func campos_faltantes(defs: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for p in puntos():
		for r in resoluciones(p):
			if not r.begins_with("campo:"):
				continue
			var campo: String = r.substr(6)
			if not out.has(campo) and not _campo_existe(defs, campo):
				out.append(campo)
	return out


## Islas del plan que no tienen definición en el dataset.
static func islas_faltantes(defs: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for p in por_grupo(GRUPO_ISLAS):
		for r in resoluciones(p):
			if not r.begins_with("dataset:"):
				continue
			var id: String = r.substr(8)
			if not defs.has(id) and not out.has(id):
				out.append(id)
	return out


static func informe(defs: Dictionary) -> Dictionary:
	var cob: Dictionary = cobertura()
	return {
		"total": cob["total"],
		"plan_dice": "24 (checklist de M27)",
		"plan_tiene": TOTAL_PLAN,
		"cobertura": cob,
		"grupos": {
			GRUPO_ISLAS: por_grupo(GRUPO_ISLAS).size(),
			GRUPO_RUTAS: por_grupo(GRUPO_RUTAS).size(),
			GRUPO_ATRIBUTOS: por_grupo(GRUPO_ATRIBUTOS).size(),
		},
		"campos_faltantes": campos_faltantes(defs),
		"islas_faltantes": islas_faltantes(defs),
		"errores": validar(defs).size(),
		"fuente": "%s L%d-%d" % [RUTA_PLAN, LINEA_INICIO_PLAN, LINEA_FIN_PLAN],
	}


static func resumen() -> String:
	var cob: Dictionary = cobertura()
	return "IslandDesignCatalog(%d puntos: %d resueltos, %d declarativos, %d externos)" % [
		cob["total"], cob["resueltos"], cob["declarativos"], cob["externos"]
	]
