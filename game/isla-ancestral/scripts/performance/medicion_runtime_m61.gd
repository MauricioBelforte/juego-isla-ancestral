# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M61 (Rendimiento) — Clasificador de MEDIBILIDAD de metricas de runtime.
#
# POR QUE EXISTE
# -------------
# `validate_budget.gd` sabe validar una `medicion` contra `data/performance/budgets.json`,
# pero en el repo NO habia NINGUN productor de esa medicion: el unico llamador era el
# propio validador con un diccionario escrito a mano (L60-64). El `[?]` L221 del checklist
# declara "no medible en headless", y esa afirmacion nunca se habia probado metrica por
# metrica.
#
# Este modulo separa TRES estados, que es lo que faltaba:
#   - MEDIBLE               : se puede medir hoy, headless, con un contador del engine.
#   - CIEGO_HEADLESS        : el contador existe pero el renderer headless (dummy) lo deja
#                             en 0 SIEMPRE -> medirlo daria un falso verde.
#   - CIEGO_SIN_INSTRUMENTAR: no hay instrumentacion en produccion (nadie llama a la API).
#
# REGLA DURA (anti-falso-verde): una clave DESCONOCIDA se clasifica como
# CIEGO_SIN_INSTRUMENTAR, nunca como MEDIBLE. Y una medicion cuyas claves medibles estan
# todas en 0 se declara VACIA: no puede aprobar nada.
#
# Sin `class_name` a proposito (trampa 123: un class_name nuevo no existe para `--script`
# hasta reimportar `.godot/`, y el worktree es compartido). Se carga por `preload`.

extends RefCounted

## Estados de medibilidad.
const MEDIBLE := "medible"
const CIEGO_HEADLESS := "ciego_headless"
const CIEGO_SIN_INSTRUMENTAR := "ciego_sin_instrumentar"

## Claves de CATEGORIA (ms). Las 7 de RF28 en `budgets.json.categorias`.
## Medido 2026-10-28: `begin_section` tiene 0 llamadores fuera de `scripts/performance/`
## (solo `bench_recorder.gd`, que es una escena de banco, y su propio test), y
## `BudgetProfile` NO figura en `project.godot` como autoload -> en una corrida real
## las 7 categorias valen 0 por construccion.
const CATEGORIAS_MS: Array[String] = [
	"gameplay_ms", "mundo_voxel_ms", "ia_npc_ms", "particulas_ms",
	"culling_ms", "render_ms", "ui_ms",
]

## Mapa canonico clave -> estado. Es la UNICA fuente de verdad de la clasificacion.
const MAPA: Dictionary = {
	# Categorias de tiempo: sin instrumentacion en produccion.
	"gameplay_ms": CIEGO_SIN_INSTRUMENTAR,
	"mundo_voxel_ms": CIEGO_SIN_INSTRUMENTAR,
	"ia_npc_ms": CIEGO_SIN_INSTRUMENTAR,
	"particulas_ms": CIEGO_SIN_INSTRUMENTAR,
	"culling_ms": CIEGO_SIN_INSTRUMENTAR,
	"render_ms": CIEGO_SIN_INSTRUMENTAR,
	"ui_ms": CIEGO_SIN_INSTRUMENTAR,
	# Cantidades: contadores reales del engine, disponibles headless.
	"objetos_mundo": MEDIBLE,
	"particulas_simultaneas": MEDIBLE,
	"nodos": MEDIBLE,
	# Render: el renderer dummy de --headless deja estos contadores en 0.
	"draw_calls": CIEGO_HEADLESS,
	"primitivas": CIEGO_HEADLESS,
	"vram_mb": CIEGO_HEADLESS,
	"overdraw": CIEGO_HEADLESS,
	"shader_coste_material_ms": CIEGO_HEADLESS,
	# Tiempo de frame: en headless no hay presentacion ni vsync; el valor no representa
	# el frame time del jugador (medido: corre desacoplado del render).
	"frame_ms": CIEGO_HEADLESS,
	"gpu_ms": CIEGO_HEADLESS,
}

## Motivo legible por estado (para el informe; no participa de la logica).
const MOTIVOS: Dictionary = {
	MEDIBLE: "contador del engine disponible y vivo en headless",
	CIEGO_HEADLESS: "el renderer dummy de --headless deja el contador en 0 (medirlo seria falso verde)",
	CIEGO_SIN_INSTRUMENTAR: "no hay instrumentacion en produccion (0 llamadores de la API)",
}

## Motivos por clave cuando el generico MENTIRIA. Medido en la 1.a corrida (Log 2232):
## `TIME_PROCESS` NO da 0 en headless (pico de 772,9 ms en el frame de boot, dominado por
## generacion de mundo); lo que no representa es el frame time del jugador (sin
## presentacion ni vsync). Decir "da 0" seria tan falso como medirlo como gate.
const MOTIVOS_CLAVE: Dictionary = {
	"frame_ms": "sin presentacion ni vsync: el valor no es el frame time del jugador (medido: pico de 772,9 ms en boot)",
	"gpu_ms": "sin GPU real en --headless: no hay tiempo de GPU que medir",
	"vram_mb": "el renderer dummy no asigna VRAM",
	"primitivas": "el renderer dummy no emite primitivas",
}


## Motivo de una clave: el especifico si existe, si no el del estado.
func motivo(clave: String) -> String:
	if MOTIVOS_CLAVE.has(clave):
		return String(MOTIVOS_CLAVE[clave])
	return String(MOTIVOS[clasificar(clave)])


## Estado de medibilidad de una clave. DESCONOCIDA -> CIEGO_SIN_INSTRUMENTAR (fail-closed).
func clasificar(clave: String) -> String:
	if MAPA.has(clave):
		return String(MAPA[clave])
	return CIEGO_SIN_INSTRUMENTAR


## true si la clave se puede medir hoy headless.
func es_medible(clave: String) -> bool:
	return clasificar(clave) == MEDIBLE


## Claves del mapa en un estado dado (ordenadas para que el informe sea estable).
func claves_en(estado: String) -> Array[String]:
	var out: Array[String] = []
	for k in MAPA:
		if String(MAPA[k]) == estado:
			out.append(String(k))
	out.sort()
	return out


## Claves de una medicion que son medibles, y las que no.
func partir_medicion(medicion: Dictionary) -> Dictionary:
	var medibles: Array[String] = []
	var ciegas: Array[String] = []
	for k in medicion:
		if es_medible(String(k)):
			medibles.append(String(k))
		else:
			ciegas.append(String(k))
	medibles.sort()
	ciegas.sort()
	return {"medibles": medibles, "ciegas": ciegas}


## true si NO hay nada medido de verdad: dict vacio, o todas las claves medibles en 0.
## Un gate que aprobara esto seria un falso verde (es el patron de las suites muertas).
func es_medicion_vacia(medicion: Dictionary) -> bool:
	if medicion.is_empty():
		return true
	var p := partir_medicion(medicion)
	var medibles: Array = p["medibles"]
	if medibles.is_empty():
		return true
	for k in medibles:
		if absf(float(medicion[String(k)])) > 0.0:
			return false
	return true


## Cobertura real: claves medibles con valor != 0 sobre el total del mapa.
## Devuelve un float 0.0..1.0.
func cobertura(medicion: Dictionary) -> float:
	if MAPA.is_empty():
		return 0.0
	var n := 0
	for k in medicion:
		if es_medible(String(k)) and absf(float(medicion[String(k)])) > 0.0:
			n += 1
	return float(n) / float(MAPA.size())


## Compara SOLO las claves medibles contra `limites` (convencion `<clave>_max`, la misma
## de `validate_budget._medicion_dentro_limites`). Las ciegas se devuelven aparte: nunca
## se dan por buenas.
## Devuelve {"violaciones": [String], "dentro": [String], "ciegas": [String],
##           "sin_limite": [String]}.
func comparar(limites: Dictionary, medicion: Dictionary) -> Dictionary:
	var violaciones: Array[String] = []
	var dentro: Array[String] = []
	var sin_limite: Array[String] = []
	var p := partir_medicion(medicion)
	for k in p["medibles"]:
		var clave := String(k)
		var clave_limite := clave + "_max"
		if not limites.has(clave_limite):
			sin_limite.append(clave)
			continue
		var tope := float(limites[clave_limite])
		if float(medicion[clave]) > tope:
			violaciones.append("%s=%s > %s" % [clave, str(medicion[clave]), str(tope)])
		else:
			dentro.append(clave)
	return {
		"violaciones": violaciones,
		"dentro": dentro,
		"ciegas": p["ciegas"],
		"sin_limite": sin_limite,
	}


## Veredicto del probe.
##   0 = el subconjunto MEDIBLE esta dentro de limites (NO significa "el modulo pasa":
##       la cobertura se informa aparte y es parcial por construccion).
##   1 = una clave medible excede su limite.
##   3 = CIEGO: no se midio nada (medicion vacia). Nunca 0.
func veredicto(limites: Dictionary, medicion: Dictionary) -> int:
	if es_medicion_vacia(medicion):
		return 3
	var c := comparar(limites, medicion)
	if not (c["violaciones"] as Array).is_empty():
		return 1
	return 0


## Informe legible (una linea por bloque). No decide nada: solo describe.
func informe(limites: Dictionary, medicion: Dictionary) -> String:
	var lineas: Array[String] = []
	var c := comparar(limites, medicion)
	var medibles: Array = (partir_medicion(medicion))["medibles"]
	lineas.append("M61 medicion de runtime: %d clave(s) medida(s) de %d del mapa (cobertura %.0f%%)"
		% [medibles.size(), MAPA.size(), cobertura(medicion) * 100.0])
	for k in medibles:
		var clave := String(k)
		var estado := "SIN LIMITE DECLARADO"
		if limites.has(clave + "_max"):
			estado = "<= %s" % str(limites[clave + "_max"])
		lineas.append("  MEDIDO  %-24s = %-12s %s" % [clave, str(medicion[clave]), estado])
	for k in c["ciegas"]:
		lineas.append("  CIEGO   %-24s (%s)" % [String(k), motivo(String(k))])
	for k in c["violaciones"]:
		lineas.append("  VIOLA   %s" % String(k))
	for k in c["sin_limite"]:
		lineas.append("  AVISO   %-24s medible pero sin limite en budgets.json" % String(k))
	lineas.append("  ciegas declaradas por el mapa y NO medidas: %s"
		% ", ".join(claves_en(CIEGO_HEADLESS) + claves_en(CIEGO_SIN_INSTRUMENTAR)))
	return "\n".join(lineas)
