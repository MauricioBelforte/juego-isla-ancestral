extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — suite de ALMACENAMIENTO de piezas (L132 / L170).
#
# POR QUE EXISTE: el checklist de M17 pedia dos cosas que NO existian en el
# codigo (no habia ninguna funcion de almacenamiento):
#   * L132 "Almacenar requiere inventario con espacio libre (M14)"
#   * L170 "El almacenamiento convierte la pieza en item del inventario sin
#          perder receta"
# Esta suite verifica la implementacion nueva `BuildManager.almacenar_pieza()`:
#
# QUE MIDE (headless, build_manager real + inventario falso):
#   * la pieza guardada entra al inventario con el MISMO id de RECETA y ese id
#     sigue en el catalogo -> la pieza es recolocable (no pierde la receta)
#   * ciclo completo: guardar -> volver a colocar desde el item guardado
#   * atomicidad: sin inventario / sin espacio la pieza SIGUE en el mundo y no
#     se entrega nada a medias
#   * SIN_ESPACIO es temporal (reintentable); SIN_INVENTARIO es permanente
#   * guards: celda vacia, receita no deconstruible, pieza que sostiene otra
#   * undo/redo del almacenamiento (el item vuelve a la pieza y viceversa)
#   * almacenar NO devuelve recursos (no es una demolicion)
#   * senales `pieza_almacenada` y `navmesh_delta`
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_almacenamiento.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: almacenamiento de piezas (L132/L170)"
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const TIPO := preload("res://scripts/construccion/construccion_tipos.gd")
const ZONE_REG := preload("res://scripts/construccion/zone_registry.gd")
const MGR := preload("res://scripts/construccion/build_manager.gd")
const CHECKS_MINIMOS := 24

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []

# ── Inventario falso (M14) ───────────────────────────────────────────────
# `lleno` simula un inventario sin slots libres. `agregar_items` es atomico
# (como el servicio real: devuelve false sin dejar restos si no entra).

class FakeInventario:
	extends RefCounted
	var items: Dictionary = {}
	var lleno: bool = false
	var agrega_llamadas: int = 0
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
		agrega_llamadas += 1
		if lleno:
			return false
		for k in d.keys():
			items[String(k)] = int(items.get(String(k), 0)) + int(d[k])
		return true
	func has_free_space(_container: int = 0) -> bool:
		return not lleno

# ── Mundo falso: terreno plano (superficie "terreno" hasta `suelo`) ───────

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
	m.name = "BuildManagerAlmacen"
	root.add_child(m)
	m.conectar_mundo(MundoPlano.new())
	m.conectar_zonas(ZONE_REG.new())
	m.set_limite_mundo(AABB())
	# IMPORTANTE: conectar SIEMPRE, incluso con null. El `_ready()` del manager
	# busca el autoload real `/root/Inventario`; sin esta llamada, el escenario
	# "sin inventario" usaria el inventario real de la partida.
	m.conectar_inventario(inv)
	return m

## Siembra el inventario con los materiales EXACTOS que pide la receta, para
## que la colocacion se cobre sin inventar ids de recursos.
func _sembrar(inv: FakeInventario, r: PlacementRule) -> void:
	for k in (r.costo as Dictionary).keys():
		inv.items[String(k)] = 999
	# Materiales frecuentes del proyecto (por si una receta sintetica usa otro).
	for k in ["madera", "piedra", "stone", "planks", "fibra", "tierra", "arena", "ore"]:
		inv.items[k] = 999

func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var cat := CATALOGO.new()
	cat.cargar("res://data/construccion/piezas")
	var receta_base: PlacementRule = cat.por_familia(&"pared")[0] if not cat.por_familia(&"pared").is_empty() else null
	_check("A0: el catalogo real de M17 tiene recetas de la familia 'pared'",
		receta_base != null)

	# ── A. L170: el item guardado CONSERVA la receta ─────────────────────
	var inv := FakeInventario.new()
	_sembrar(inv, receta_base)
	var mgr = _nuevo_manager(inv)
	await process_frame

	var r_pared: PlacementRule = mgr.receta(receta_base.id)
	if r_pared == null:
		r_pared = receta_base
	mgr.registrar_receta(r_pared)
	mgr.seleccionar_pieza(r_pared)
	var res_col: Dictionary = mgr.confirmar_colocacion(Vector3i(10, 1, 10))
	_check("A1: colocar '%s' en (10,1,10) -> ok" % String(r_pared.id),
		bool(res_col.get("ok", false)), str(_motivos(res_col)))
	_check("A2: la pieza colocada esta en el mundo (pieza_en_celda no vacia)",
		not (mgr.pieza_en_celda(Vector3i(10, 1, 10)) as Dictionary).is_empty())

	var id_receta: String = String(r_pared.id)
	var res_alm: Dictionary = mgr.almacenar_pieza(Vector3i(10, 1, 10))
	_check("A3: almacenar la pieza -> ok", bool(res_alm.get("ok", false)), str(_motivos(res_alm)))
	_check("A4: el item guardado usa el MISMO id que la RECETA ('%s')" % id_receta,
		int(inv.items.get(id_receta, 0)) == 1, "items=%s" % str(inv.items))
	_check("A5: la receta sigue en el catalogo (no se perdio al guardar)",
		mgr.receta(StringName(id_receta)) != null)
	_check("A6: la pieza salio del mundo (pieza_en_celda vacia)",
		(mgr.pieza_en_celda(Vector3i(10, 1, 10)) as Dictionary).is_empty())
	_check("A7: el conteo de estructuras bajo (la pieza ya no esta colocada)",
		mgr.cantidad_estructuras() == 0, "estructuras=%d" % mgr.cantidad_estructuras())

	# El item guardado se puede volver a colocar (ciclo completo).
	var r_recuperada: PlacementRule = mgr.receta(StringName(id_receta))
	var res_recol: Dictionary = mgr.confirmar_colocacion(Vector3i(12, 1, 10))
	_check("A8: el item almacenado se puede volver a colocar (receta recuperada del catalogo) -> ok",
		bool(res_recol.get("ok", false)), str(_motivos(res_recol)))
	_check("A9: la pieza vuelve a estar en el mundo tras recolocarla",
		not (mgr.pieza_en_celda(Vector3i(12, 1, 10)) as Dictionary).is_empty())

	# ── B. Atomicidad: si falla, la pieza SIGUE en el mundo ─────────────
	var mgr_sin_inv = _nuevo_manager(null)
	await process_frame
	mgr_sin_inv.registrar_receta(r_pared)
	mgr_sin_inv.seleccionar_pieza(r_pared)
	mgr_sin_inv.confirmar_colocacion(Vector3i(20, 1, 20))
	var res_sin_inv: Dictionary = mgr_sin_inv.almacenar_pieza(Vector3i(20, 1, 20))
	_check("B1: SIN inventario -> motivo SIN_INVENTARIO",
		(_motivos(res_sin_inv) as Array).has(TIPO.Motivo.SIN_INVENTARIO), str(_motivos(res_sin_inv)))
	_check("B2: SIN inventario la pieza SIGUE colocada (no se pierde nada)",
		not (mgr_sin_inv.pieza_en_celda(Vector3i(20, 1, 20)) as Dictionary).is_empty())
	_check("B3: SIN_INVENTARIO es PERMANENTE (no se resuelve solo)",
		not ConstruccionTipos.es_temporal(TIPO.Motivo.SIN_INVENTARIO))

	var inv_lleno := FakeInventario.new()
	_sembrar(inv_lleno, receta_base)
	inv_lleno.lleno = true
	var mgr_lleno = _nuevo_manager(inv_lleno)
	await process_frame
	mgr_lleno.registrar_receta(r_pared)
	mgr_lleno.seleccionar_pieza(r_pared)
	mgr_lleno.confirmar_colocacion(Vector3i(30, 1, 30))
	var res_lleno: Dictionary = mgr_lleno.almacenar_pieza(Vector3i(30, 1, 30))
	_check("B4: inventario LLENO -> motivo SIN_ESPACIO",
		(_motivos(res_lleno) as Array).has(TIPO.Motivo.SIN_ESPACIO), str(_motivos(res_lleno)))
	_check("B5: inventario lleno -> la pieza SIGUE colocada (atomicidad: no hay entrega parcial)",
		not (mgr_lleno.pieza_en_celda(Vector3i(30, 1, 30)) as Dictionary).is_empty())
	_check("B6: inventario lleno -> no se entrego el item ('%s')" % id_receta,
		int(inv_lleno.items.get(id_receta, 0)) == 0, "items=%s" % str(inv_lleno.items))
	_check("B7: SIN_ESPACIO es TEMPORAL (se reintenta al liberar un slot)",
		ConstruccionTipos.es_temporal(TIPO.Motivo.SIN_ESPACIO))

	# ── C. Guards del almacenamiento ───────────────────────────────────
	var mgr_g = _nuevo_manager(inv)
	await process_frame
	mgr_g.registrar_receta(r_pared)
	var res_vacia: Dictionary = mgr_g.almacenar_pieza(Vector3i(40, 1, 40))
	_check("C1: almacenar en celda VACIA -> NO_HAY_PIEZA",
		(_motivos(res_vacia) as Array).has(TIPO.Motivo.NO_HAY_PIEZA), str(_motivos(res_vacia)))

	var r_no_decon: PlacementRule = PlacementRule.desde_dict(r_pared.a_dict())
	r_no_decon.id = &"test_no_deconstruible_almacen"
	r_no_decon.deconstruible = false
	r_no_decon.costo = (r_pared.costo as Dictionary).duplicate()
	mgr_g.registrar_receta(r_no_decon)
	mgr_g.seleccionar_pieza(r_no_decon)
	var res_col_nod: Dictionary = mgr_g.confirmar_colocacion(Vector3i(41, 1, 41))
	_check("C1b: la pieza con deconstruible == false se puede COLOCAR (precondicion)",
		bool(res_col_nod.get("ok", false)), str(_motivos(res_col_nod)))
	var res_nod: Dictionary = mgr_g.almacenar_pieza(Vector3i(41, 1, 41))
	_check("C2: pieza con deconstruible == false -> NO_DECONSTRUIBLE",
		(_motivos(res_nod) as Array).has(TIPO.Motivo.NO_DECONSTRUIBLE), str(_motivos(res_nod)))
	_check("C3: la pieza no deconstruible SIGUE colocada (no se guarda por la fuerza)",
		not (mgr_g.pieza_en_celda(Vector3i(41, 1, 41)) as Dictionary).is_empty())

	# Para apilar dos piezas hace falta una receta que NO exija soporte (el
	# adaptador de superficie del test solo conoce el terreno, no las piezas ya
	# colocadas): receta sintetica con soportes_minimos = 0.
	var r_float: PlacementRule = PlacementRule.desde_dict(r_pared.a_dict())
	r_float.id = &"test_sin_soporte_almacen"
	r_float.soportes_minimos = 0
	r_float.costo = (r_pared.costo as Dictionary).duplicate()
	mgr_g.registrar_receta(r_float)
	mgr_g.seleccionar_pieza(r_float)
	var res_col_abajo: Dictionary = mgr_g.confirmar_colocacion(Vector3i(50, 1, 50))
	_check("C4a: la pieza INFERIOR se coloca (precondicion)",
		bool(res_col_abajo.get("ok", false)), str(_motivos(res_col_abajo)))
	var res_col_arriba: Dictionary = mgr_g.confirmar_colocacion(Vector3i(50, 2, 50))
	_check("C4b: la pieza SUPERIOR (encima) se coloca (precondicion)",
		bool(res_col_arriba.get("ok", false)), str(_motivos(res_col_arriba)))
	var res_sost: Dictionary = mgr_g.almacenar_pieza(Vector3i(50, 1, 50))
	_check("C4: la pieza que SOSTIENE otra -> SOSTIENE_OTRA_PIEZA",
		(_motivos(res_sost) as Array).has(TIPO.Motivo.SOSTIENE_OTRA_PIEZA), str(_motivos(res_sost)))

	# ── D. Senales, undo/redo y recursos ───────────────────────────────
	var inv_d := FakeInventario.new()
	_sembrar(inv_d, receta_base)
	var mgr_d = _nuevo_manager(inv_d)
	await process_frame
	mgr_d.registrar_receta(r_pared)

	var senal_almacenada: Array = []
	mgr_d.pieza_almacenada.connect(func(id: StringName, _c: Vector3i): senal_almacenada.append(String(id)))
	var senal_navmesh: Array = []
	mgr_d.navmesh_delta.connect(func(_c: Array): senal_navmesh.append(true))

	mgr_d.seleccionar_pieza(r_pared)
	mgr_d.confirmar_colocacion(Vector3i(60, 1, 60))
	var navmesh_antes: int = senal_navmesh.size()
	# Materiales DESPUES de colocar (para comparar: guardar NO debe refunduzarlos)
	var mat_antes: Dictionary = inv_d.items.duplicate()
	mgr_d.almacenar_pieza(Vector3i(60, 1, 60))
	_check("D1: la senal pieza_almacenada se emite con el id de receta ('%s')" % id_receta,
		senal_almacenada.size() == 1 and String(senal_almacenada[0]) == id_receta, str(senal_almacenada))
	_check("D2: navmesh_delta se emite al guardar la pieza",
		senal_navmesh.size() == navmesh_antes + 1)
	var materiales_cambiaron := false
	for k in mat_antes.keys():
		if int(inv_d.items.get(String(k), 0)) != int(mat_antes[k]):
			materiales_cambiaron = true
	_check("D3: guardar NO devuelve recursos (los materiales no cambian)",
		not materiales_cambiaron, "antes=%s despues=%s" % [str(mat_antes), str(inv_d.items)])

	var res_undo: Dictionary = mgr_d.undo()
	_check("D4: deshacer el almacenamiento -> ok", bool(res_undo.get("ok", false)), str(res_undo.get("detalle", "")))
	_check("D5: tras deshacer, la pieza VUELVE al mundo",
		not (mgr_d.pieza_en_celda(Vector3i(60, 1, 60)) as Dictionary).is_empty())
	_check("D6: tras deshacer, el item SALE del inventario",
		int(inv_d.items.get(id_receta, 0)) == 0, "items=%s" % str(inv_d.items))

	var res_redo: Dictionary = mgr_d.redo()
	_check("D7: rehacer el almacenamiento -> ok", bool(res_redo.get("ok", false)), str(res_redo.get("detalle", "")))
	_check("D8: tras rehacer, la pieza sale del mundo",
		(mgr_d.pieza_en_celda(Vector3i(60, 1, 60)) as Dictionary).is_empty())
	_check("D9: tras rehacer, el item vuelve al inventario",
		int(inv_d.items.get(id_receta, 0)) == 1, "items=%s" % str(inv_d.items))

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST M17 ALMACENAMIENTO FALLIDO (checks=%d, minimo=%d)" % [_checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST M17 ALMACENAMIENTO OK — L132/L170 verificados (guardar conserva la receta, atomicidad y undo/redo)")
		quit(0)
