extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — suite de CONTENIDO de las piezas funcionales.
#
# POR QUE EXISTE: el checklist de M17 tenia UN item en `[?]`:
#   "La demolicion de piezas funcionales (camas, almacenamiento) libera su
#    contenido [C]" — con la nota "no existe logica de liberar contenido, no
#    existe build_interaction.gd (propuesto en 04-Codigo.md para M18)".
# Efectivamente: `build_interaction.gd` NO existia y no habia ninguna logica
# que devolviera el contenido de una pieza al demolerla (los items de un cofre
# se perdian).
#
# QUE MIDE (headless, build_manager real + inventario falso):
#   * el MODELO PURO `BuildInteraction`: normaliza el cofre en las dos formas
#     que usa el proyecto, distingue items/muebles/puertas, y NO muta al liberar
#   * la INTEGRACION en la demolicion: los items de la pieza vuelven al
#     INVENTARIO (no se pierden) y el resultado los reporta
#   * el DESHACER: la pieza vuelve INTEGRA (con su contenido) y los items
#     vuelven del inventario al cofre (no se duplican ni se pierden)
#   * una pieza SIN contenido: demolerla no rompe nada
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_contenido_piezas.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: contenido de piezas funcionales (demolucion libera contenido)"
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const TIPO := preload("res://scripts/construccion/construccion_tipos.gd")
const ZONE_REG := preload("res://scripts/construccion/zone_registry.gd")
const MGR := preload("res://scripts/construccion/build_manager.gd")
const INTERACCION := preload("res://scripts/construccion/build_interaction.gd")
const CHECKS_MINIMOS := 22

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


# ── Inventario falso (M14) ───────────────────────────────────────────────

class FakeInventario:
	extends RefCounted
	var items: Dictionary = {}

	func count_item(item_id: String, _include_house: bool = false) -> int:
		return int(items.get(item_id, 0))

	func remover_items(d: Dictionary) -> bool:
		for k in d.keys():
			if int(items.get(String(k), 0)) < int(d[k]):
				return false
		for k in d.keys():
			items[String(k)] = int(items.get(String(k), 0)) - int(d[k])
		return true

	func agregar_items(d: Dictionary) -> bool:
		for k in d.keys():
			items[String(k)] = int(items.get(String(k), 0)) + int(d[k])
		return true

	func has_free_space(_container: int = 0) -> bool:
		return true


# ── Mundo falso: terreno plano ───────────────────────────────────────────

class MundoPlano:
	extends ConstruccionMundo
	var suelo: int = 0

	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y <= suelo else &"aire"


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _motivos(res: Dictionary) -> Array:
	return res.get("motivos", [])


func _nuevo_manager(inv) -> Object:
	var m = MGR.new()
	m.name = "BuildManagerContenido"
	root.add_child(m)
	m.conectar_mundo(MundoPlano.new())
	m.conectar_zonas(ZONE_REG.new())
	m.set_limite_mundo(AABB())
	# IMPORTANTE: conectar SIEMPRE, incluso con null (el `_ready()` busca el
	# autoload real `/root/Inventario`).
	m.conectar_inventario(inv)
	return m


func _sembrar(inv: FakeInventario, r: PlacementRule) -> void:
	for k in (r.costo as Dictionary).keys():
		inv.items[String(k)] = 999
	for k in ["madera", "piedra", "stone", "planks", "fibra", "tierra", "arena", "ore"]:
		inv.items[k] = 999


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ── A. El MODELO PURO (BuildInteraction) ────────────────────────────
	var canon: Dictionary = {"contenido": [{"item_id": "madera", "cantidad": 4}]}
	var items_canon: Dictionary = INTERACCION.items_de_contenido(canon)
	_check("A1: el cofre canonico {'contenido':[{item_id,cantidad}]} se normaliza a {item_id: cantidad}",
		int(items_canon.get("madera", 0)) == 4, str(items_canon))

	var alt: Dictionary = {"items": {"piedra": 2}}
	var items_alt: Dictionary = INTERACCION.items_de_contenido(alt)
	_check("A2: la forma alternativa {'items':{...}} tambien se normaliza",
		int(items_alt.get("piedra", 0)) == 2, str(items_alt))

	_check("A3: una forma de cofre desconocida NO inventa datos (devuelve {})",
		(INTERACCION.items_de_contenido({"raro": 1}) as Dictionary).is_empty())
	_check("A4: un cofre nulo devuelve {} (no crashea)",
		(INTERACCION.items_de_contenido(null) as Dictionary).is_empty())

	var vacio: Dictionary = INTERACCION.contenido_de({})
	_check("A5: contenido_de({}) devuelve las 3 claves (items/muebles/puertas) vacias",
		vacio.has("items") and vacio.has("muebles") and vacio.has("puertas")
			and (vacio["items"] as Dictionary).is_empty())

	var estructura: Dictionary = {
		"tipo": "cofre_ancestral",
		"cofre": {"contenido": [{"item_id": "madera", "cantidad": 4}]},
		"muebles": [{"celda": [1, 0, 1], "mueble": "mesa", "rotacion": 1}],
		"puertas": [{"celda": [0, 0, 1], "abierta": true}],
	}
	var cont: Dictionary = INTERACCION.contenido_de(estructura)
	_check("A6: contenido_de separa items (1), muebles (1) y puertas (1)",
		(cont["items"] as Dictionary).size() == 1
			and (cont["muebles"] as Array).size() == 1
			and (cont["puertas"] as Array).size() == 1, str(cont))
	_check("A7: tiene_contenido = true con cofre con items",
		INTERACCION.tiene_contenido(estructura))
	_check("A8: tiene_contenido = false en una pieza sin contenido",
		not INTERACCION.tiene_contenido({"tipo": "pared"}))

	var copia: Dictionary = estructura.duplicate(true)
	var liberado: Dictionary = INTERACCION.liberar_contenido(copia)
	_check("A9: liberar_contenido devuelve los items de la pieza",
		int((liberado["items"] as Dictionary).get("madera", 0)) == 4, str(liberado))
	_check("A10: liberar_contenido NO vacia el cofre (la pieza guardada sigue INTEGRA para el deshacer)",
		int(INTERACCION.items_de_contenido(copia["cofre"]).get("madera", 0)) == 4)

	var a_vaciar: Dictionary = estructura.duplicate(true)
	var vaciado: Dictionary = INTERACCION.vaciar_contenido(a_vaciar)
	_check("A11: vaciar_contenido SI vacia el cofre y devuelve lo que tenia",
		int((vaciado["items"] as Dictionary).get("madera", 0)) == 4
			and (INTERACCION.items_de_contenido(a_vaciar["cofre"]) as Dictionary).is_empty())

	var ida: Dictionary = INTERACCION.items_a_contenido({"piedra": 3, "madera": 1})
	var vuelta: Dictionary = INTERACCION.items_de_contenido(ida)
	_check("A12: items_a_contenido -> items_de_contenido es una ida y vuelta (piedra 3, madera 1)",
		int(vuelta.get("piedra", 0)) == 3 and int(vuelta.get("madera", 0)) == 1, str(vuelta))
	_check("A13: total_items suma las cantidades",
		INTERACCION.total_items({"items": {"madera": 4, "piedra": 2}}) == 6)
	_check("A14: texto_contenido dice 'vuelve: nada' cuando no hay items",
		INTERACCION.texto_contenido({"items": {}}) == "vuelve: nada")
	_check("A15: texto_contenido lista los items (vuelve: madera x4)",
		INTERACCION.texto_contenido({"items": {"madera": 4}}) == "vuelve: madera x4",
		INTERACCION.texto_contenido({"items": {"madera": 4}}))
	_check("A16: es_funcional = true para un cofre y false para una pared",
		INTERACCION.es_funcional(&"cofre_ancestral") and not INTERACCION.es_funcional(&"pared"))

	# ── B. La INTEGRACION en la demolicion ──────────────────────────────
	var cat := CATALOGO.new()
	cat.cargar("res://data/construccion/piezas")
	var recetas_pared: Array = cat.por_familia(&"pared")
	var receta_base: PlacementRule = recetas_pared[0] if not recetas_pared.is_empty() else null
	_check("B0: el catalogo real de M17 tiene recetas de la familia 'pared'", receta_base != null)

	var inv := FakeInventario.new()
	_sembrar(inv, receta_base)
	var mgr = _nuevo_manager(inv)
	await process_frame
	mgr.registrar_receta(receta_base)
	mgr.seleccionar_pieza(receta_base)
	var res_col: Dictionary = mgr.confirmar_colocacion(Vector3i(10, 1, 10))
	_check("B1: colocar la pieza -> ok", bool(res_col.get("ok", false)), str(_motivos(res_col)))

	var celda := Vector3i(10, 1, 10)
	var clave: String = TIPO.clave(celda)
	var asignado: bool = mgr.asignar_contenido(clave, {"madera": 4})
	_check("B2: asignar_contenido guarda 4 de madera en la pieza colocada",
		asignado, "clave=%s" % clave)

	var leido: Dictionary = mgr.contenido_de_pieza(clave)
	_check("B3: contenido_de_pieza devuelve los items guardados (madera 4)",
		int((leido.get("items", {}) as Dictionary).get("madera", 0)) == 4, str(leido))
	_check("B4: contenido_de_pieza de una clave SIN pieza devuelve vacio (no crashea)",
		(mgr.contenido_de_pieza("999:999:999") as Dictionary).is_empty())
	_check("B5: asignar_contenido en una clave SIN pieza devuelve false",
		not mgr.asignar_contenido("999:999:999", {"madera": 1}))

	# Los items que se guardaron SALEN del "almacen" de la pieza: los pongo a
	# cero en el inventario para ver que la demolicion los devuelve.
	inv.items.erase("madera")

	var res_dem: Dictionary = mgr.demolir_pieza(celda)
	_check("B6: demoler la pieza con contenido -> ok", bool(res_dem.get("ok", false)), str(_motivos(res_dem)))
	_check("B7: la demolicion DEVUELVE los items al inventario (no se pierden)",
		int(inv.items.get("madera", 0)) == 4, "items=%s" % str(inv.items))
	var liberados: Dictionary = res_dem.get("items_liberados", {})
	_check("B8: el resultado de la demolicion reporta los items liberados (madera 4)",
		int(liberados.get("madera", 0)) == 4, str(liberados))

	# ── C. El DESHACER devuelve la pieza INTEGRA ────────────────────────
	var res_undo: Dictionary = mgr.undo()
	_check("C1: deshacer la demolicion -> ok", bool(res_undo.get("ok", false)), str(res_undo))
	_check("C2: la pieza vuelve a estar colocada", not (mgr.pieza_en_celda(celda) as Dictionary).is_empty())
	var leido2: Dictionary = mgr.contenido_de_pieza(TIPO.clave(celda))
	_check("C3: la pieza vuelve INTEGRA (con su cofre y sus 4 de madera)",
		int((leido2.get("items", {}) as Dictionary).get("madera", 0)) == 4, str(leido2))
	_check("C4: al deshacer, los items vuelven del inventario al cofre (no se duplican)",
		int(inv.items.get("madera", 0)) == 0, "items=%s" % str(inv.items))

	# ── D. Una pieza SIN contenido: demolerla no rompe nada ─────────────
	var mgr2 = _nuevo_manager(inv)
	await process_frame
	mgr2.registrar_receta(receta_base)
	mgr2.seleccionar_pieza(receta_base)
	mgr2.confirmar_colocacion(Vector3i(20, 1, 20))
	var res_dem2: Dictionary = mgr2.demolir_pieza(Vector3i(20, 1, 20))
	_check("D1: demoler una pieza SIN contenido -> ok (no rompe nada)",
		bool(res_dem2.get("ok", false)), str(_motivos(res_dem2)))
	_check("D2: una pieza sin contenido no libera items (lista vacia)",
		(res_dem2.get("items_liberados", {}) as Dictionary).is_empty(),
		str(res_dem2.get("items_liberados", {})))

	# ── E. Anti-falso-verde: el minimo de checks y el resumen ───────────
	_check("E1: la suite ejecuta al menos %d checks (minimo anti-falso-verde)" % CHECKS_MINIMOS,
		_checks >= CHECKS_MINIMOS, "checks=%d" % _checks)

	print("--- %s: %d checks, %d fallos ---" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		for d in _detalles:
			print("  FALLO: %s" % d)
	quit(1 if _fallos > 0 else 0)
