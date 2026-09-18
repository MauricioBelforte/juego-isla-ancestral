# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-18
#
# M52 iter. 6 (Log 1002): suite de la iteración — schema completo, loops
# ambientales (culling + fase fija), trigger centralizado y verificación de que
# los buses del catálogo EXISTEN en el EventBus real.
#
# Guardián anti-falso-verde (patrón del proyecto):
#   - cada bloque cierra con _fin(); si un bloque no corre, _summary() lo NOMBRA
#   - piso CHECKS_MINIMOS: si el total cae por debajo, el resultado es INVÁLIDO
#     (un helper roto que aborta en silencio NO puede producir un verde)
#   - _summary() va en su propio call_deferred: quit() desde _process no termina
extends SceneTree

const SCHEMA := preload("res://scripts/particles/vfx_schema.gd")
const FACTORY := preload("res://scripts/particles/vfx_factory.gd")
const LOOPS := preload("res://scripts/particles/vfx_loops.gd")
const TRIGGER := preload("res://scripts/particles/vfx_trigger.gd")

const RUTA_CATALOGO := "res://data/vfx/vfx_catalog.json"
const RUTA_EVENTBUS := "res://scripts/core/event_bus.gd"
const CHECKS_MINIMOS := 60
const BLOQUES := ["A", "B", "C", "D", "E", "F"]

var _checks := 0
var _fallos := 0
var _bloques := []
var _detalle_fallos := []
var _cat: Array = []
var _resumen_hecho := false

# --- Stub del EventBus (namespaced), para NO depender del autoload real ---
class BusWorld extends RefCounted:
	signal block_placed(pos: Vector3i, block_type: int)
	signal block_removed(pos: Vector3i, block_type: int)

class BusInventory extends RefCounted:
	signal item_added(item_id: String, quantity: int)

class BusQuest extends RefCounted:
	signal quest_completed(quest_id: String)
	signal prereq_met(seal_id: String)

class BusNpc extends RefCounted:
	signal friendship_level_up(npc_id: String, new_level: int)

class BusCalendar extends RefCounted:
	signal day_started(day: int, season: String)
	signal season_changed(old_season: String, new_season: String)

class BusWeather extends RefCounted:
	signal clima_cambio(clima: int)

class BusTravel extends RefCounted:
	signal travel_started(from_island: String, to_island: String)

class BusUi extends RefCounted:
	signal notify(toast_data: Dictionary)

class BusProgresion extends RefCounted:
	signal nivel_herramienta_cambio(herramienta_id: String, nivel: int)

class BusDiary extends RefCounted:
	signal entrada_nueva(entrada_id: String, categoria: String)

class BusStub extends Node:
	var world := BusWorld.new()
	var inventory := BusInventory.new()
	var quest := BusQuest.new()
	var npc := BusNpc.new()
	var calendar := BusCalendar.new()
	var weather := BusWeather.new()
	var travel := BusTravel.new()
	var ui := BusUi.new()
	var progresion := BusProgresion.new()
	var diary := BusDiary.new()

## Stub al que le FALTA un namespace entero (para probar `faltantes`).
class BusStubParcial extends Node:
	var world := BusWorld.new()


func _init() -> void:
	call_deferred("_run")
	# ⚠️ _summary SIEMPRE se encola, aunque _run aborte a mitad.
	# Medido el 2026-09-18: con el `_summary()` sólo al final de `_run`, un
	# `return` temprano (un helper que revienta en silencio) dejaba el proceso
	# COLGADO — nunca se llamaba a `quit()`, no había exit code y la corrida
	# moría por timeout a los 300 s. Un cuelgue no es un diagnóstico: la cola de
	# `call_deferred` garantiza el orden (_run primero, _summary después) y
	# `_resumen_hecho` hace que la segunda llamada sea inocua.
	call_deferred("_summary")


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		_detalle_fallos.append(nombre)
		print("  [FALLO] %s" % nombre)


func _fin(bloque: String) -> void:
	_bloques.append(bloque)
	print("  -- bloque %s cerrado --" % bloque)


func _roto(indice: int, campo: String, valor: Variant) -> Dictionary:
	var c: Dictionary = {"version": 2, "vfx": _cat.duplicate(true)}
	c["vfx"][indice][campo] = valor
	return c


func _errores_tienen(errores: Array, aguja: String) -> bool:
	return errores.any(func(e): return String(e).contains(aguja))


func _run() -> void:
	print("=== [M52 iter. 6] Catalogo + loops + trigger ===")
	var config: Dictionary = JSON.parse_string(
			FileAccess.get_file_as_string(RUTA_CATALOGO))
	_cat = config["vfx"]

	# ---------------------------------------------------------------- A
	print("--- A. Catalogo real valido ---")
	var errores: Array = SCHEMA.validar_catalogo(config)
	_check("catalogo real sin errores (0)", errores.is_empty())
	if not errores.is_empty():
		for e in errores:
			print("      ! %s" % e)
	_check("version == 2", int(config["version"]) == 2)
	_check("31 entradas", _cat.size() == 31)
	_check("cobertura del plan completa", SCHEMA.cobertura_plan(config).is_empty())
	_check("24 nombres canonicos en PLAN", SCHEMA.PLAN.size() == 24)
	_check("12 loops declarados", _cat.filter(func(e): return e["loop"]).size() == 12)
	var tipos := {}
	for e in _cat:
		tipos[e["tipo"]] = true
	_check("24 tipos distintos", tipos.size() == 24)
	_fin("A")

	# ---------------------------------------------------------------- B
	print("--- B. Reglas del schema (por inyeccion) ---")
	var e1: Array = SCHEMA.validar_catalogo(_roto(0, "luz_por_particula", true))
	_check("RF7: luz_por_particula=true -> error", _errores_tienen(e1, "luz_por_particula"))
	var e2: Array = SCHEMA.validar_catalogo(_roto(0, "parpadeo_hz", 12.0))
	_check("RF11: 12 Hz -> error de estroboscopio", _errores_tienen(e2, "parpadeo"))
	var e3: Array = SCHEMA.validar_catalogo(_roto(0, "radio", 0.0))
	_check("RF14: loop sin radio -> error", _errores_tienen(e3, "radio de culling"))
	var e4: Array = SCHEMA.validar_catalogo(_roto(2, "radio", 30.0))
	_check("no-loop con radio -> error", _errores_tienen(e4, "no-loop con radio"))
	var e5: Array = SCHEMA.validar_catalogo(_roto(0, "presupuesto", 5))
	_check("RF3: presupuesto < cantidad -> error", _errores_tienen(e5, "presupuesto"))
	# vfx_bloque_roto (indice 2) tiene bus pero NO dueno_evento: al vaciarle el
	# bus queda sin nadie que lo dispare. (Vaciarle el bus a vfx_humo no sirve:
	# tiene dueno_evento M49, asi que sigue cumpliendo RF6.)
	var e6: Array = SCHEMA.validar_catalogo(_roto(2, "bus", ""))
	_check("RF6: sin bus y sin dueno -> error", _errores_tienen(e6, "dueno_evento"))
	var e7: Array = SCHEMA.validar_catalogo(_roto(0, "bus", "malformado"))
	_check("bus sin namespace -> error", _errores_tienen(e7, "bus mal formado"))
	var e8: Array = SCHEMA.validar_catalogo(_roto(1, "id", "vfx_humo"))
	_check("id duplicado -> error", _errores_tienen(e8, "duplicado"))
	var e9: Array = SCHEMA.validar_catalogo(_roto(0, "id", "Humo_Malo"))
	_check("RF16: naming invalido -> error", _errores_tienen(e9, "naming"))
	var e10: Array = SCHEMA.validar_catalogo(_roto(0, "categoria", "inventada"))
	_check("categoria fuera del conjunto -> error", _errores_tienen(e10, "categoria"))
	var e11: Array = SCHEMA.validar_catalogo(_roto(0, "tipo", "inventado"))
	_check("tipo fuera del conjunto -> error", _errores_tienen(e11, "tipo"))
	var e12: Array = SCHEMA.validar_catalogo(_roto(0, "emisor", "inventado"))
	_check("emisor fuera del conjunto -> error", _errores_tienen(e12, "emisor"))
	var e13: Array = SCHEMA.validar_catalogo(_roto(0, "material", "inventado"))
	_check("material fuera del conjunto -> error", _errores_tienen(e13, "material"))
	var e14: Array = SCHEMA.validar_catalogo(_roto(0, "color", "azul"))
	_check("color no-hex -> error", _errores_tienen(e14, "color"))
	var e15: Array = SCHEMA.validar_catalogo(_roto(0, "cantidad", 9999))
	_check("cantidad 9999 -> error", _errores_tienen(e15, "cantidad fuera de rango"))
	var e16: Array = SCHEMA.validar_catalogo(_roto(0, "emision", 9.0))
	_check("emision 9.0 -> error", _errores_tienen(e16, "emision fuera de rango"))
	var e17: Array = SCHEMA.validar_catalogo(_roto(0, "fase", 1.5))
	_check("RF4: fase 1.5 -> error", _errores_tienen(e17, "fase"))
	var mala_version: Dictionary = {"version": 99, "vfx": _cat.duplicate(true)}
	_check("version != 2 -> error", _errores_tienen(
			SCHEMA.validar_catalogo(mala_version), "version"))
	var sin_plan: Dictionary = {"version": 2, "vfx": [_cat[2].duplicate(true)]}
	_check("plan sin cubrir -> error de cobertura",
			SCHEMA.cobertura_plan(sin_plan).size() == 23)
	_fin("B")

	# ---------------------------------------------------------------- C
	print("--- C. Loops ambientales (RF2/RF9/RF14) ---")
	var loops := LOOPS.new()
	var humo := _vfx("vfx_humo")
	_check("registrar loop en zona nueva", loops.registrar(humo, "playa", Vector3.ZERO))
	_check("RF9: misma zona 2 veces -> false", not loops.registrar(humo, "playa", Vector3.ZERO))
	var no_loop := _vfx("vfx_bloque_roto")
	_check("no-loop no se registra", not loops.registrar(no_loop, "otra", Vector3.ZERO))
	var sin_radio: Dictionary = humo.duplicate(true)
	sin_radio["radio"] = 0.0
	_check("loop sin radio no se registra", not loops.registrar(sin_radio, "sinradio", Vector3.ZERO))
	_check("tiene('playa')", loops.tiene("playa"))
	_check("zonas() = ['playa']", loops.zonas() == ["playa"])
	_check("cantidad_loops = 1", loops.cantidad_loops() == 1)
	# humo: cantidad 40, radio 40
	_check("cerca (d=0): cantidad completa 40", loops.cantidad_efectiva("playa", Vector3.ZERO) == 40)
	_check("LOD lejos (d=35): 25% = 10",
			loops.cantidad_efectiva("playa", Vector3(35, 0, 0)) == 10)
	_check("fuera de radio (d=41): 0", loops.cantidad_efectiva("playa", Vector3(41, 0, 0)) == 0)
	_check("factor_lod cerca = 1.0", loops.factor_lod(humo, 10.0) == 1.0)
	_check("factor_lod lejos = 0.25", loops.factor_lod(humo, 30.0) == 0.25)
	_check("activos() con camara dentro", loops.activos(Vector3.ZERO).size() == 1)
	_check("activos() con camara fuera", loops.activos(Vector3(500, 0, 0)).is_empty())
	var resumen: Dictionary = loops.resumen(Vector3.ZERO)
	_check("resumen: 1 zona activa, 40 particulas",
			int(resumen["zonas_activas"]) == 1 and int(resumen["particulas_totales"]) == 40)
	_check("fase_de('playa') = 0.0 (humo)", loops.fase_de("playa") == 0.0)
	_check("desregistrar('playa')", loops.desregistrar("playa"))
	_check("tras desregistrar: 0 loops", loops.cantidad_loops() == 0)
	_fin("C")

	# ---------------------------------------------------------------- D
	print("--- D. Determinismo (RF4) ---")
	var l2 := LOOPS.new()
	l2.registrar(_vfx("vfx_polvo"), "desierto", Vector3.ZERO)
	var f1 := l2.fase_en_t(_vfx("vfx_polvo"), 3.0, 10.0)
	var f2 := l2.fase_en_t(_vfx("vfx_polvo"), 3.0, 10.0)
	_check("fase_en_t es pura (2 llamadas iguales)", f1 == f2)
	_check("fase_en_t(t=0) == fase declarada",
			l2.fase_en_t(_vfx("vfx_polvo"), 0.0, 10.0) == 0.13)
	var fa := l2.fase_en_t(_vfx("vfx_polvo"), 2.0, 10.0)
	var fb := l2.fase_en_t(_vfx("vfx_polvo"), 12.0, 10.0)
	_check("fase_en_t periodica (t y t+periodo)", absf(fa - fb) < 0.0001)
	var otra := LOOPS.new()
	otra.registrar(_vfx("vfx_polvo"), "desierto", Vector3.ZERO)
	_check("dos instancias -> misma cantidad",
			otra.cantidad_efectiva("desierto", Vector3(20, 0, 0))
			== l2.cantidad_efectiva("desierto", Vector3(20, 0, 0)))
	_fin("D")

	# ---------------------------------------------------------------- E
	print("--- E. Trigger centralizado (RF5/RF6) ---")
	var trig := TRIGGER.new()
	var n_buses := trig.construir(_cat)
	_check("13 buses derivados del catalogo", n_buses == 13)
	_check("buses() devuelve 13", trig.buses().size() == 13)
	_check("calendar.season_changed -> 4 ids",
			trig.ids_de("calendar.season_changed").size() == 4)
	_check("bus inexistente -> []", trig.ids_de("no.existe").is_empty())
	# conexion contra el stub COMPLETO
	var disparos: Array = []
	var stub := BusStub.new()
	var cb := func(bus: String, _ctx: Dictionary) -> void:
		disparos.append(bus)
	var r: Dictionary = trig.conectar(stub, cb)
	_check("stub completo: 13 conectados", int(r["conectados"]) == 13)
	_check("stub completo: 0 faltantes", (r["faltantes"] as Array).is_empty())
	# la senal REAL llega al callback
	stub.calendar.season_changed.emit("verano", "otono")
	_check("emitir season_changed llega al callback",
			disparos.has("calendar.season_changed"))
	stub.world.block_removed.emit(Vector3i(1, 0, 0), 3)
	_check("emitir block_removed llega al callback",
			disparos.has("world.block_removed"))
	# conexion contra un stub al que le faltan namespaces
	var r2: Dictionary = trig.conectar(BusStubParcial.new(), cb)
	_check("stub parcial: 2 conectados", int(r2["conectados"]) == 2)
	_check("stub parcial: 11 faltantes NOMBRADOS", (r2["faltantes"] as Array).size() == 11)
	_check("faltantes incluye quest.prereq_met",
			(r2["faltantes"] as Array).has("quest.prereq_met"))
	# condicion
	_check("condicion vacia -> siempre",
			TRIGGER.cumple_condicion("", {}))
	_check("condicion estacion:otono con contexto",
			TRIGGER.cumple_condicion("estacion:otono", {"estacion": "otono"}))
	_check("condicion estacion:otono sin contexto",
			not TRIGGER.cumple_condicion("estacion:otono", {}))
	_check("condicion mal formada -> false",
			not TRIGGER.cumple_condicion("otono", {"otono": "otono"}))
	var otono: Array = trig.disparar("calendar.season_changed", {"estacion": "otono"}, _cat)
	_check("otono -> 2 vfx (hojas + estacional)", otono.size() == 2)
	_check("otono incluye vfx_hojas", otono.has("vfx_hojas"))
	var primavera: Array = trig.disparar("calendar.season_changed", {"estacion": "primavera"}, _cat)
	_check("primavera -> 3 vfx", primavera.size() == 3)
	_check("primavera incluye vfx_polen", primavera.has("vfx_polen"))
	var cov: Dictionary = trig.cobertura()
	_check("cobertura: 13 buses con vfx", int(cov["buses_con_vfx"]) == 13)
	_check("cobertura: 10 pendientes RF6", int(cov["pendientes_rf6"]) == 10)
	_fin("E")

	# ---------------------------------------------------------------- F
	print("--- F. Integracion con el catalogo real y el EventBus real ---")
	var lr := LOOPS.new()
	var registrados := 0
	for e in _cat:
		if bool(e["loop"]) and lr.registrar(e, str(e["id"]), Vector3.ZERO):
			registrados += 1
	_check("los 12 loops del catalogo se registran", registrados == 12)
	_check("12 zonas registradas", lr.cantidad_loops() == 12)
	var pend: Dictionary = trig.eventos_pendientes()
	_check("10 pendientes RF6", pend.size() == 10)
	_check("todo pendiente RF6 tiene dueno",
			pend.values().all(func(d): return not String(d).is_empty()))
	# cada bus del catalogo debe existir en el EventBus REAL (texto del archivo)
	var fuente := FileAccess.get_file_as_string(RUTA_EVENTBUS)
	_check("event_bus.gd legible", not fuente.is_empty())
	var faltan_reales: Array = []
	for bus in trig.buses():
		var partes := String(bus).split(".")
		var senal := "signal %s(" % partes[1]
		if not fuente.contains(senal):
			faltan_reales.append(bus)
	_check("los 13 buses existen como signal en event_bus.gd",
			faltan_reales.is_empty())
	if not faltan_reales.is_empty():
		print("      ! sin respaldo en event_bus.gd: %s" % [faltan_reales])
	_check("evento_generico NO existe (bug de iter. 5 confirmado)",
			not fuente.contains("evento_generico"))
	_fin("F")

	call_deferred("_summary")


func _vfx(id: String) -> Dictionary:
	for e in _cat:
		if str(e["id"]) == id:
			return e.duplicate(true)
	return {}


func _summary() -> void:
	if _resumen_hecho:
		return
	_resumen_hecho = true
	var faltan := []
	for b in BLOQUES:
		if not _bloques.has(b):
			faltan.append(b)
	print("=== Resumen M52 iter. 6: %d checks, %d fallos ===" % [_checks, _fallos])
	print("    bloques ejecutados: %d/%d %s" % [_bloques.size(), BLOQUES.size(), _bloques])
	if not faltan.is_empty():
		print("    BLOQUES QUE NO CORRIERON: %s" % [faltan])
	print("    piso de checks: %d (medidos %d)" % [CHECKS_MINIMOS, _checks])
	if not faltan.is_empty() or _checks < CHECKS_MINIMOS:
		print("=== RESULTADO: INVALIDO (bloques faltantes o bajo el piso) ===")
		quit(2)
		return
	if _fallos > 0:
		for f in _detalle_fallos:
			print("    - %s" % f)
		print("=== RESULTADO: FALLO ===")
		quit(1)
		return
	print("=== RESULTADO: OK ===")
	quit(0)
