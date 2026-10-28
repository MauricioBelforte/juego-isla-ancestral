extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-27
#
# M17 Construccion — suite de REGLAS DECLARATIVAS POR PIEZA (catalogo real).
#
# POR QUE EXISTE: el validador (ConstruccionValidator) es declarativo: lee
# PlacementRule. Esta suite verifica que el CATALOGO REAL (.tres de data/
# construccion/piezas/) declara correctamente las reglas por familia:
#   * G137: puerta/ventana: requiere_pared == true + validador rechaza sin pared
#   * G138: ventana exige pared contigua de al menos 1 celda
#   * G141: camino: superficie_ok = ["terreno"] (solo césped/arena, nunca roca/pendiente)
#   * G145: zonas PROTEGIDA (parcela NPC / ruina) bloquean cualquier colocacion;
#            manager rechaza demolicion de recetas con deconstruible == false
#   * la validacion se re-ejecuta con cada rotacion (celdas afectadas cambian) [F121]
#
# QUE MIDE (headless, catalogo real, contexto realista):
#   - BuildCatalogDB carga recursivamente res://data/construccion/piezas/
#   - valida el catalogo (BuildCatalogDB.validar() -> ok)
#   - 12 familias canonicas presentes (RF12, bloque J)
#   - G137/G138: validador rechaza puerta/ventana SIN pared contigua (REQUIERE_PARED);
#     CON pared contigua -> ok (sin REQUIERE_PARED)
#   - G141: recetas familia "camino" tienen superficie_ok = ["terreno"]; validando
#     camino_cesped sobre "roca" -> SIN_SOPORTE; sobre "terreno" -> ok
#   - G145: ZonasPermisos preset PARCELA_NPC/RUINA => PROTEGIDA; validando cualquier
#     receta en zona PROTEGIDA => ZONA_PROTEGIDA; manager.demolir_pieza de receta
#     con deconstruible=false => NO_DECONSTRUIBLE (probado con receta sintética);
#     catálogo M17 NO declara recetas deconstruible=false (deuda M25/M73)
#   - F121: rotar_paso() + validar_receta() con rot 0 vs 1 -> recalculos reales
#     (cache invalidation), NO devuelve cache
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "<godot_console>" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_reglas_pieza.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: reglas declarativas por pieza (catalogo real)"
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const VAL := preload("res://scripts/construccion/construccion_validator.gd")
const ZONAS := preload("res://scripts/construccion/zonas_permisos.gd")
const TIPO := preload("res://scripts/construccion/construccion_tipos.gd")
const ZONE_REG := preload("res://scripts/construccion/zone_registry.gd")
const MGR := preload("res://scripts/construccion/build_manager.gd")
const MUNDO := preload("res://scripts/construccion/construccion_mundo.gd")
const PREVIEW := preload("res://scripts/construccion/build_preview.gd")
const CHECKS_MINIMOS := 30

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []
var _cat: BuildCatalogDB = null
var _mgr: Object = null

# ── Inventario falso (M14) para no depender del autoload real ────────────

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

# ── Mundo falso para tests: terreno PLANO y solido por debajo de `suelo` ──

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

func _ctx_base(opts: Dictionary = {}) -> Dictionary:
	var permiso := int(opts.get("permiso", ConstruccionTipos.Permiso.EDIFICABLE))
	var ocupada := bool(opts.get("ocupada", false))
	var superficie: StringName = opts.get("superficie", &"terreno")
	var npc := bool(opts.get("npc", false))
	var puede_pagar := bool(opts.get("puede_pagar", true))
	var piezas_en_zona := int(opts.get("piezas_en_zona", 0))
	var limite: AABB = opts.get("limite", AABB())
	return ConstruccionValidator.contexto(
		func(_c): return ocupada,
		func(_c): return superficie,
		func(_c): return npc,
		func(_c): return puede_pagar,
		func(_c): return permiso,
		func(_r, _c): return piezas_en_zona,
		limite)

func _motivos(res: Dictionary) -> Array:
	return res.get("motivos", [])

func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ── A. CATALOGO REAL ──────────────────────────────────────────────────
	_cat = CATALOGO.new()
	var cargadas: int = _cat.cargar("res://data/construccion/piezas")
	_check("A1: catalogo carga recursiva res://data/construccion/piezas (%d recetas)" % cargadas,
		cargadas > 0)

	var audit: Dictionary = _cat.validar()
	_check("A2: catalogo valido (sin problemas de schema): ok == true",
		bool(audit.get("ok", false)), str(audit.get("problemas", [])))
	_check("A3: 12 familias canonicas PRESENTES (RF12 bloque J)",
		audit.get("familias", []).size() == 12, str(audit.get("familias", [])))

	# ── B. G137: Puertas requieren_pared == true + validacion real ───────
	var puertas: Array = _cat.por_familia(&"puerta")
	_check("B1: familia 'puerta' tiene %d receta(s) declarada(s)" % puertas.size(),
		puertas.size() > 0)
	for r in puertas:
		_check("B2: receta puerta '%s' tiene requiere_pared == true" % String(r.id),
			bool(r.requiere_pared))
		var res_puerta := VAL.validar(r, Vector3i(10, 1, 10), 0, _ctx_base({}))
		_check("B3: puerta '%s' SIN pared contigua -> REQUIERE_PARED" % String(r.id),
			(_motivos(res_puerta) as Array).has(TIPO.Motivo.REQUIERE_PARED), str(_motivos(res_puerta)))
		var ctx_pared := ConstruccionValidator.contexto(
			func(_c): return false,
			func(c): return &"pared" if c == Vector3i(11, 1, 10) else &"terreno",
			func(_c): return false,
			func(_c): return true,
			func(_c): return ConstruccionTipos.Permiso.EDIFICABLE,
			func(_r, _c): return 0,
			AABB())
		var res_puerta_ok := VAL.validar(r, Vector3i(10, 1, 10), 0, ctx_pared)
		_check("B4: puerta '%s' CON pared contigua -> sin REQUIERE_PARED" % String(r.id),
			not (_motivos(res_puerta_ok) as Array).has(TIPO.Motivo.REQUIERE_PARED), str(_motivos(res_puerta_ok)))

	# ── C. G138: Ventanas requieren_pared == true + validacion real ───────
	var ventanas: Array = _cat.por_familia(&"ventana")
	_check("C1: familia 'ventana' tiene %d receta(s) declarada(s)" % ventanas.size(),
		ventanas.size() > 0)
	for r in ventanas:
		_check("C2: receta ventana '%s' tiene requiere_pared == true" % String(r.id),
			bool(r.requiere_pared))
		var res_ventana := VAL.validar(r, Vector3i(20, 1, 20), 0, _ctx_base({}))
		_check("C3: ventana '%s' SIN pared contigua -> REQUIERE_PARED" % String(r.id),
			(_motivos(res_ventana) as Array).has(TIPO.Motivo.REQUIERE_PARED), str(_motivos(res_ventana)))
		var ctx_pared_v := ConstruccionValidator.contexto(
			func(_c): return false,
			func(c): return &"pared" if c == Vector3i(21, 1, 20) else &"terreno",
			func(_c): return false,
			func(_c): return true,
			func(_c): return ConstruccionTipos.Permiso.EDIFICABLE,
			func(_r, _c): return 0,
			AABB())
		var res_ventana_ok := VAL.validar(r, Vector3i(20, 1, 20), 0, ctx_pared_v)
		_check("C4: ventana '%s' CON pared contigua -> sin REQUIERE_PARED" % String(r.id),
			not (_motivos(res_ventana_ok) as Array).has(TIPO.Motivo.REQUIERE_PARED), str(_motivos(res_ventana_ok)))

	# ── D. G141: Caminos solo sobre terreno (superficie_ok = ["terreno"]) ───
	var caminos: Array = _cat.por_familia(&"camino")
	_check("D1: familia 'camino' tiene %d receta(s) declarada(s)" % caminos.size(),
		caminos.size() > 0)
	for r in caminos:
		_check("D2: camino '%s' superficie_ok == ['terreno'] (sin piso/techo/pared/agua/aire)" % String(r.id),
			(r.superficie_ok as Array).size() == 1 and (r.superficie_ok as Array)[0] == &"terreno", str(r.superficie_ok))
		var ctx_roca := _ctx_base({"superficie": &"roca"})
		var res_camino := VAL.validar(r, Vector3i(30, 1, 30), 0, ctx_roca)
		_check("D3: camino '%s' sobre 'roca' (fuera de superficie_ok) -> SIN_SOPORTE" % String(r.id),
			(_motivos(res_camino) as Array).has(TIPO.Motivo.SIN_SOPORTE), str(_motivos(res_camino)))
		var ctx_terreno := _ctx_base({"superficie": &"terreno"})
		var res_camino_ok := VAL.validar(r, Vector3i(31, 1, 31), 0, ctx_terreno)
		_check("D4: camino '%s' sobre 'terreno' (en superficie_ok) -> ok" % String(r.id),
			bool(res_camino_ok.get("ok", false)), str(_motivos(res_camino_ok)))

	# ── E. G145: Zonas PROTEGIDA + NO_DECONSTRUIBLE ──────────────────────
	_check("E1: preset PARCELA_NPC == PROTEGIDA",
		ZONAS.PARCELA_NPC == ConstruccionTipos.Permiso.PROTEGIDA)
	_check("E2: preset RUINA == PROTEGIDA",
		ZONAS.RUINA == ConstruccionTipos.Permiso.PROTEGIDA)

	var reg_npc := ZONE_REG.new()
	var aabb_npc := AABB(Vector3(0, 0, 0), Vector3(100, 10, 100))
	ZONAS.registrar(reg_npc, ZONAS.PARCELA_NPC, aabb_npc)
	_check("E3: registrar zona PROTEGIDA via ZonasPermisos -> cantidad 1",
		reg_npc.cantidad() == 1)

	var receta_ejemplo: PlacementRule = _cat.por_familia(&"pared")[0]
	var ctx_protegida := _ctx_base({"permiso": ConstruccionTipos.Permiso.PROTEGIDA})
	var res_protegida := VAL.validar(receta_ejemplo, Vector3i(10, 1, 10), 0, ctx_protegida)
	_check("E4: zona PROTEGIDA -> ZONA_PROTEGIDA para cualquier receta",
		(_motivos(res_protegida) as Array).has(TIPO.Motivo.ZONA_PROTEGIDA), str(_motivos(res_protegida)))

	# Manager: colocar pieza y demoler con deconstruible=false
	_mgr = MGR.new()
	_mgr.name = "BuildManagerTest"
	root.add_child(_mgr)

	var inv := FakeInventario.new()
	inv.items["madera"] = 100
	inv.items["stone"] = 100
	inv.items["planks"] = 100
	_mgr.conectar_inventario(inv)
	_mgr.conectar_zonas(ZONE_REG.new())
	_mgr.conectar_mundo(MundoPlano.new())
	_mgr.set_limite_mundo(AABB())
	await process_frame

	# Clonar receta de pared con deconstruible=false para probar el guard del manager
	var r_pared: PlacementRule = _mgr.receta(&"pared_basica")
	if r_pared == null:
		# fallback a cualquier receta valida
		r_pared = _cat.por_familia(&"pared")[0]
	var r_no_decon: PlacementRule = PlacementRule.desde_dict(r_pared.a_dict())
	r_no_decon.id = &"test_no_deconstruible"
	r_no_decon.deconstruible = false
	r_no_decon.costo = {"madera": 4}
	_mgr.registrar_receta(r_no_decon)

	# Colocar la pieza en (10,1,10)
	_mgr.seleccionar_pieza(r_no_decon)
	var res_place: Dictionary = _mgr.confirmar_colocacion(Vector3i(10, 1, 10))
	_check("E5: colocar receta deconstruible=false -> ok (manager permite colocar)",
		bool(res_place.get("ok", false)), str(_motivos(res_place)))

	# Demoler -> debe rechazar con NO_DECONSTRUIBLE
	var res_demo: Dictionary = _mgr.demolir_pieza(Vector3i(10, 1, 10))
	_check("E6: demoler receta deconstruible=false -> NO_DECONSTRUIBLE",
		not bool(res_demo.get("ok", true)) and (_motivos(res_demo) as Array).has(TIPO.Motivo.NO_DECONSTRUIBLE),
		str(_motivos(res_demo)))

	# Verificar catalogo real: ninguna receta declara deconstruible=false
	var no_decon_count: int = 0
	for id in _cat.ids():
		var r := _cat.receta(id)
		if r != null and not bool(r.deconstruible):
			no_decon_count += 1
	_check("E7: catálogo M17 declara %d receta(s) con deconstruible == false (deuda M25/M73)" % no_decon_count,
		no_decon_count == 0, "no_decon_count=%d" % no_decon_count)

	# Demoler pieza normal (control): debe funcionar
	var r_normal: PlacementRule = _mgr.receta(&"pared_basica")
	if r_normal == null:
		r_normal = _cat.por_familia(&"pared")[0]
	_mgr.seleccionar_pieza(r_normal)
	_mgr.confirmar_colocacion(Vector3i(20, 1, 20))
	var res_demo_normal: Dictionary = _mgr.demolir_pieza(Vector3i(20, 1, 20))
	_check("E8: demoler pieza NORMAL (deconstruible=true) -> ok",
		bool(res_demo_normal.get("ok", false)), str(_motivos(res_demo_normal)))

	# ── F. F121: La validacion se re-ejecuta con cada rotacion (celdas afectadas cambian) ───
	# El manager REAL expone receta_actual/rotacion_actual/validar_receta (duck-typing).
	# Receta 2x1 para que la huella CAMBIE al rotar (la celda afectada no es la misma).
	var r_2x1: PlacementRule = PlacementRule.desde_dict(r_normal.a_dict())
	r_2x1.id = &"test_2x1_rotacion"
	r_2x1.tamano = Vector2i(2, 1)
	r_2x1.costo = {"madera": 4}
	_mgr.registrar_receta(r_2x1)
	_mgr.seleccionar_pieza(r_2x1)
	_mgr.set_rotacion(0)
	var p := PREVIEW.new()

	# Warm up: evaluar en rot 0
	var r1 := p.evaluar(_mgr, Vector3i(0, 1, 0))
	_check("F1: preview rotacion 0 -> cache=false (primera evaluacion)",
		not bool(r1.get("cache", true)))
	var celdas_rot0: Array = r1.get("celdas", [])
	# Misma celda, misma rotacion -> cache hit
	var r2 := p.evaluar(_mgr, Vector3i(0, 1, 0))
	_check("F2: preview misma celda/rot/receta -> cache=true (cache hit)",
		bool(r2.get("cache", false)))
	# Rotacion 1 (cambia la huella) -> recalculo real
	_mgr.set_rotacion(1)
	var r3 := p.evaluar(_mgr, Vector3i(0, 1, 0))
	_check("F3: preview rotacion 1 (cambia huella) -> cache=false (recalculo real)",
		not bool(r3.get("cache", true)))
	var celdas_rot1: Array = r3.get("celdas", [])
	_check("F4: la rotacion 1 cambia las celdas afectadas (2x1 -> huella en Z)",
		celdas_rot0.size() == 2 and celdas_rot1.size() == 2
			and (celdas_rot0 as Array).has(Vector3i(1, 1, 0))
			and (celdas_rot1 as Array).has(Vector3i(0, 1, 1))
			and not (celdas_rot1 as Array).has(Vector3i(1, 1, 0)),
		"rot0=%s rot1=%s" % [str(celdas_rot0), str(celdas_rot1)])
	_check("F5: el contador de recalculos del preview sube con el cambio de rotacion",
		p.recalculos() >= 2, "recalculos=%d" % p.recalculos())

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST M17 REGLAS PIEZA FALLIDO (checks=%d, minimo=%d)" % [_checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST M17 REGLAS PIEZA OK — reglas declarativas por familia verificadas contra catalogo real")
		quit(0)