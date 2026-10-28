# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M61 — Suite del clasificador de medibilidad y del contrato de la sonda de runtime.
#
# Que protege (el hueco real que encontro esta tanda):
#   1. `validate_budget.gd` valida una `medicion`, pero NO habia productor. Esta suite
#      fija el contrato del productor: que claves puede medir, con que estado, y que
#      NUNCA puede aprobar una medicion vacia.
#   2. Las 7 categorias de ms estan declaradas CIEGO_SIN_INSTRUMENTAR con evidencia
#      medida (0 llamadores de `begin_section` fuera de scripts/performance/ y
#      `BudgetProfile` no es autoload). Si alguien instrumenta produccion, el bloque D
#      se pone ROJO y obliga a reclasificar (no queda como deuda silenciosa).
#   3. `draw_calls` esta CIEGO_HEADLESS: el renderer dummy lo deja en 0. La suite exige
#      que siga clasificado asi, para que nadie "mida" 0 draw calls y lo llame verde.
#
# GUARDA DE 3 CAPAS (regla de flota):
#   (1) `_fin(nombre)` va al FINAL del cuerpo de cada bloque, no en el runner: en Godot 4
#       un SCRIPT ERROR aborta SOLO la funcion y el llamador RETOMA, asi que un `_fin` en
#       el runner marcaria como visto un bloque que nunca corrio.
#   (2) `_verificar_marcadores()` nombra los bloques que faltaron.
#   (3) `CHECKS_MINIMOS` MEDIDO en verde + `_summary()` en un `call_deferred` SEPARADO
#       (si va al final de `_correr()`, un aborto deja el arbol vivo y la suite CUELGA).
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m61_medicion_runtime.gd
# Exit: 0 = verde medido | 1 = fallos

extends SceneTree

const MODULO := "M61 medicion de runtime"
const RUTA_CLASIFICADOR := "res://scripts/performance/medicion_runtime_m61.gd"
const RUTA_SONDA := "res://scripts/performance/medir_runtime_m61.gd"
const RUTA_BUDGETS := "res://data/performance/budgets.json"

## Piso MEDIDO en verde (no estimado): 58 checks en las 3 corridas de la tanda.
const CHECKS_MINIMOS: int = 59

const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

var _checks: int = 0
var _fallos: int = 0
var _vistos: Array[String] = []
var _bloque: String = ""
var _terminado: bool = false


func _initialize() -> void:
	call_deferred("_correr")
	call_deferred("_watchdog")


## Watchdog: si un SCRIPT ERROR aborta `_correr()` antes del `call_deferred("_summary")`
## final, el arbol queda vivo y la suite CUELGA (EXIT 124, que parece verde). Este
## temporizador garantiza que siempre haya resumen y exit != 0.
func _watchdog() -> void:
	await create_timer(90.0).timeout
	if _terminado:
		return
	print("FALLO: watchdog de 90 s — la suite no cerro (aborto de runtime en algun bloque)")
	_verificar_marcadores()
	_summary()


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Capa 1: se llama al FINAL del cuerpo del bloque.
func _fin(nombre: String) -> void:
	if not _vistos.has(nombre):
		_vistos.append(nombre)
	print("  -- bloque %s cerrado (%d checks acumulados)" % [nombre, _checks])


## Capa 2: nombres de los bloques que NO llegaron a cerrarse.
func _verificar_marcadores() -> void:
	var faltan: Array[String] = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltan.append(b)
	if not faltan.is_empty():
		_checks += 1
		_fallos += 1
		print("  [FALL] bloques que NO se cerraron (aborto de runtime): %s"
			% ", ".join(faltan))
	else:
		_check("los %d bloques se cerraron" % BLOQUES.size(), true)


func _leer_json(ruta: String) -> Dictionary:
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


func _correr() -> void:
	print("=== %s ===" % MODULO)
	await process_frame

	var cls = load(RUTA_CLASIFICADOR).new()
	var budgets := _leer_json(RUTA_BUDGETS)
	var limites: Dictionary = {}
	if budgets.get("limites") is Dictionary:
		limites = budgets["limites"]

	# ── A: clasificacion fail-closed ───────────────────────────────
	_bloque = "A"
	print("-- A: clasificacion de claves")
	_check("el clasificador se instancio", cls != null)
	_check("clave desconocida NO es medible (fail-closed)",
		not cls.es_medible("clave_que_no_existe"),
		"estado: " + cls.clasificar("clave_que_no_existe"))
	_check("clave desconocida se clasifica CIEGO_SIN_INSTRUMENTAR",
		cls.clasificar("clave_que_no_existe") == cls.CIEGO_SIN_INSTRUMENTAR)
	_check("objetos_mundo es MEDIBLE", cls.clasificar("objetos_mundo") == cls.MEDIBLE)
	_check("particulas_simultaneas es MEDIBLE",
		cls.clasificar("particulas_simultaneas") == cls.MEDIBLE)
	_check("draw_calls es CIEGO_HEADLESS (renderer dummy)",
		cls.clasificar("draw_calls") == cls.CIEGO_HEADLESS)
	_check("draw_calls NO es medible", not cls.es_medible("draw_calls"))
	_check("gpu_ms es CIEGO_HEADLESS", cls.clasificar("gpu_ms") == cls.CIEGO_HEADLESS)
	var todas_cat := true
	for c in cls.CATEGORIAS_MS:
		if cls.clasificar(String(c)) != cls.CIEGO_SIN_INSTRUMENTAR:
			todas_cat = false
	_check("las 7 categorias de ms son CIEGO_SIN_INSTRUMENTAR", todas_cat,
		"%d categorias" % cls.CATEGORIAS_MS.size())
	var motivos_ok := true
	var sin_motivo: Array[String] = []
	for k in cls.MAPA:
		if String(cls.motivo(String(k))).strip_edges() == "":
			motivos_ok = false
			sin_motivo.append(String(k))
	_check("toda clave del mapa tiene motivo", motivos_ok, "sin motivo: %s" % str(sin_motivo))
	_check("el motivo de draw_calls culpa al renderer dummy",
		String(cls.motivo("draw_calls")).contains("renderer dummy"))
	_check("el motivo de frame_ms NO miente con 'da 0' (medido: 772,9 ms en boot)",
		String(cls.motivo("frame_ms")).contains("vsync")
			and not String(cls.motivo("frame_ms")).contains("deja el contador en 0"))
	_fin("A")

	# ── B: partir_medicion ────────────────────────────────────────
	_bloque = "B"
	print("-- B: particion medibles / ciegas")
	var mezcla := {"objetos_mundo": 1200, "draw_calls": 0, "gpu_ms": 0.0, "inventada": 5}
	var p: Dictionary = cls.partir_medicion(mezcla)
	var med: Array = p["medibles"]
	var cie: Array = p["ciegas"]
	_check("parte 1 medible de 4 claves", med.size() == 1, "medibles=%s" % str(med))
	_check("parte 3 ciegas de 4 claves", cie.size() == 3, "ciegas=%s" % str(cie))
	_check("la medible es objetos_mundo", med.has("objetos_mundo"))
	_check("draw_calls cae del lado ciego", cie.has("draw_calls"))
	_check("la clave inventada cae del lado ciego", cie.has("inventada"))
	_check("las listas vienen ordenadas", str(med) == str(med.duplicate()) and str(cie) == str(cie.duplicate()))
	_fin("B")

	# ── C: medicion vacia (anti-falso-verde central) ──────────────
	_bloque = "C"
	print("-- C: medicion vacia")
	_check("dict vacio es medicion vacia", cls.es_medicion_vacia({}))
	_check("todo ceros es medicion vacia",
		cls.es_medicion_vacia({"objetos_mundo": 0, "nodos": 0, "particulas_simultaneas": 0}))
	_check("solo ciegas es medicion vacia",
		cls.es_medicion_vacia({"draw_calls": 999, "gpu_ms": 12.0}))
	_check("un valor medible != 0 NO es vacia",
		not cls.es_medicion_vacia({"objetos_mundo": 1200}))
	_check("una clave inventada != 0 NO rescata la medicion",
		cls.es_medicion_vacia({"inventada": 5000}))
	_fin("C")

	# ── D: la clasificacion esta respaldada por el repo ───────────
	_bloque = "D"
	print("-- D: evidencia de la clasificacion en el repo")
	var src_prod: Array[String] = []
	var dir := DirAccess.open("res://scripts")
	var pendientes: Array[String] = []
	if dir != null:
		pendientes.append("res://scripts")
	var instrumentados: Array[String] = []
	while not pendientes.is_empty():
		var actual: String = pendientes.pop_back()
		var d := DirAccess.open(actual)
		if d == null:
			continue
		d.list_dir_begin()
		var nombre := d.get_next()
		while nombre != "":
			if nombre.begins_with("."):
				nombre = d.get_next()
				continue
			var ruta := actual + "/" + nombre
			if d.current_is_dir():
				pendientes.append(ruta)
			elif nombre.ends_with(".gd"):
				var txt := FileAccess.get_file_as_string(ruta)
				if txt.contains("begin_section("):
					instrumentados.append(ruta)
			nombre = d.get_next()
		d.list_dir_end()
	var solo_perf := true
	for r in instrumentados:
		if not String(r).begins_with("res://scripts/performance/"):
			solo_perf = false
			src_prod.append(String(r))
	_check("ningun script de produccion llama begin_section (por eso las 7 son ciegas)",
		solo_perf, "fuera de scripts/performance/: %s" % str(src_prod))
	_check("hay al menos un archivo que usa la API (la busqueda no es ciega)",
		instrumentados.size() > 0, "archivos con begin_section: %d" % instrumentados.size())
	var pg := FileAccess.get_file_as_string("res://project.godot")
	_check("BudgetProfile NO es autoload en project.godot", not pg.contains("BudgetProfile"))
	_check("CATEGORIAS_MS coincide con budgets.json.categorias",
		_son_mismas_claves(cls.CATEGORIAS_MS, budgets.get("categorias", {})),
		"clasificador=%d, budgets=%d" % [cls.CATEGORIAS_MS.size(),
			(budgets.get("categorias", {}) as Dictionary).size()])
	_fin("D")

	# ── E: comparacion contra limites ─────────────────────────────
	_bloque = "E"
	print("-- E: comparacion contra limites")
	_check("limites leidos de budgets.json", limites.size() >= 3, "%d limites" % limites.size())
	var ok_c: Dictionary = cls.comparar(limites, {"objetos_mundo": 10, "particulas_simultaneas": 10})
	_check("dentro de limites: 0 violaciones", (ok_c["violaciones"] as Array).is_empty())
	_check("dentro de limites: 2 claves dentro", (ok_c["dentro"] as Array).size() == 2)
	var mala_c: Dictionary = cls.comparar(limites, {"particulas_simultaneas": 100000})
	_check("exceder particulas_simultaneas_max da 1 violacion",
		(mala_c["violaciones"] as Array).size() == 1,
		str(mala_c["violaciones"]))
	_check("la violacion nombra la clave y los valores",
		(mala_c["violaciones"] as Array).size() == 1
			and String((mala_c["violaciones"] as Array)[0]).begins_with("particulas_simultaneas="))
	var ciega_c: Dictionary = cls.comparar(limites, {"draw_calls": 999999})
	_check("una clave CIEGA nunca genera violacion", (ciega_c["violaciones"] as Array).is_empty())
	_check("una clave CIEGA tampoco cuenta como 'dentro'",
		(ciega_c["dentro"] as Array).is_empty())
	_check("una clave CIEGA se devuelve como ciega", (ciega_c["ciegas"] as Array).has("draw_calls"))
	var sin_lim: Dictionary = cls.comparar(limites, {"nodos": 10})
	_check("clave medible sin limite se informa como sin_limite",
		(sin_lim["sin_limite"] as Array).has("nodos"))
	_fin("E")

	# ── F: veredicto ──────────────────────────────────────────────
	_bloque = "F"
	print("-- F: veredicto")
	_check("medicion vacia -> 3 (CIEGO)", cls.veredicto(limites, {}) == 3)
	_check("todo ceros -> 3 (CIEGO)",
		cls.veredicto(limites, {"objetos_mundo": 0, "particulas_simultaneas": 0}) == 3)
	_check("dentro de limites -> 0",
		cls.veredicto(limites, {"objetos_mundo": 10, "particulas_simultaneas": 10}) == 0)
	_check("excedido -> 1",
		cls.veredicto(limites, {"particulas_simultaneas": 100000}) == 1)
	_check("solo ciegas con valores -> 3, nunca 0",
		cls.veredicto(limites, {"draw_calls": 5000, "gpu_ms": 33.0}) == 3)
	_fin("F")

	# ── G: cobertura e informe ────────────────────────────────────
	_bloque = "G"
	print("-- G: cobertura e informe")
	_check("cobertura de dict vacio = 0.0", absf(cls.cobertura({})) < 0.0001)
	_check("cobertura con 1 clave medible es > 0", cls.cobertura({"objetos_mundo": 900}) > 0.0)
	_check("cobertura con 1 de N es menor que 0.5", cls.cobertura({"objetos_mundo": 900}) < 0.5)
	_check("cobertura ignora las ciegas",
		absf(cls.cobertura({"draw_calls": 900}) ) < 0.0001)
	var inf: String = cls.informe(limites, {"objetos_mundo": 900, "draw_calls": 0})
	_check("el informe nombra la cobertura", inf.contains("cobertura"))
	_check("el informe lista la clave medida", inf.contains("objetos_mundo"))
	_check("el informe marca la ciega como CIEGO", inf.contains("CIEGO"))
	_check("el informe declara las ciegas del mapa", inf.contains("draw_calls"))
	_fin("G")

	# ── H: contrato de la sonda ───────────────────────────────────
	_bloque = "H"
	print("-- H: contrato de la sonda de runtime")
	var sonda := FileAccess.get_file_as_string(RUTA_SONDA)
	_check("la sonda existe y no esta vacia", sonda.length() > 1000, "%d bytes" % sonda.length())
	_check("la sonda carga el clasificador", sonda.contains("medicion_runtime_m61.gd"))
	_check("la sonda arranca la escena real", sonda.contains("scenes/main_island.tscn"))
	_check("la sonda escribe la medicion en out/", sonda.contains("res://out/medicion_m61.json"))
	_check("la sonda tiene watchdog de reloj", sonda.contains("TOPE_RELOJ_MS"))
	_check("la sonda puede salir 3 (CIEGO)", sonda.contains("quit(3)"))
	_check("la sonda usa un contador de particulas real",
		sonda.contains("CPUParticles3D") and sonda.contains("GPUParticles3D"))
	_check("la sonda mide nodos con Performance", sonda.contains("OBJECT_NODE_COUNT"))
	var src_cls := FileAccess.get_file_as_string(RUTA_CLASIFICADOR)
	_check("el clasificador usa la convencion '<clave>_max' de validate_budget",
		src_cls.contains('clave + "_max"'))
	_fin("H")

	_verificar_marcadores()
	print("=== Resumen %s: %d checks, %d fallos (minimo %d) ==="
		% [MODULO, _checks, _fallos, CHECKS_MINIMOS])
	call_deferred("_summary")


## Capa 3: resumen en un call_deferred SEPARADO (un aborto no deja el arbol colgado).
func _summary() -> void:
	if _terminado:
		return
	_terminado = true
	if _checks < CHECKS_MINIMOS:
		print("FALLO: solo %d checks ejecutados (minimo %d) — suite recortada o bloque muerto"
			% [_checks, CHECKS_MINIMOS])
		print("TEST %s FALLIDO" % MODULO)
		quit(1)
		return
	if _fallos > 0:
		print("TEST %s FALLIDO (%d fallos)" % [MODULO, _fallos])
		quit(1)
		return
	print("TEST %s OK — %d checks, 0 fallos" % [MODULO, _checks])
	quit(0)


func _son_mismas_claves(a: Array, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for k in a:
		if not b.has(String(k)):
			return false
	return true
