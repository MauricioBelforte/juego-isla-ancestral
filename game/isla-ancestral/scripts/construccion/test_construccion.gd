# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — suite del nucleo (validacion + catalogo +
# colocacion/demolicion/undo/redo + PERSISTENCIA por duck-typing).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion.gd
#
# Guardia anti-falso-verde de 3 capas (doctrina del repo, trampas 118/119/1197):
#   1) _fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO EN VERDE (no estimado, no copiado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code.
#
# Afirma el CAMINO FELIZ explicitamente (trampa 1197: un enum con OK obliga a
# afirmar == OK; no basta con "no falla").
#
# No usa class_name: evita depender del cache de clases globales en headless.

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE (131) y fijado aqui.
const CHECKS_MINIMOS: int = 131

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

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

## Mundo falso para tests: terreno PLANO y solido por debajo de `suelo`.
## Hereda de ConstruccionMundo para poder inyectarse donde se espera ese tipo.
class MundoPlano:
	extends ConstruccionMundo
	var suelo: int = 0
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y < suelo else &"aire"
	func escribir_voxel(celdas: Array, _bloque: int) -> int:
		escrituras += celdas.size()
		return celdas.size()
	func borrar_voxel(celdas: Array) -> int:
		borrados += celdas.size()
		return celdas.size()

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

# ── utilidades de reporte ────────────────────────────────────────────────

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

# ── utilidades de construccion de contexto ───────────────────────────────

## Contexto del validador con mapa de superficies por celda.
func _ctx(mapa: Dictionary = {}, defecto: StringName = &"terreno",
		permiso: int = ConstruccionTipos.Permiso.EDIFICABLE, pagar: bool = true,
		npc: Array = [], ocupadas: Array = [], pz: int = 0) -> Dictionary:
	return ConstruccionValidator.contexto(
		func(c: Vector3i) -> bool: return ocupadas.has(c),
		func(c: Vector3i) -> StringName: return StringName(mapa.get(c, defecto)),
		func(c: Vector3i) -> bool: return npc.has(c),
		func(_costo: Dictionary) -> bool: return pagar,
		func(_c: Vector3i) -> int: return permiso,
		func(_r: PlacementRule, _c: Vector3i) -> int: return pz)

func _receta(id: String, tam: Vector2i = Vector2i.ONE, extra: Dictionary = {}) -> PlacementRule:
	var d := {"id": id, "nombre": id, "tamano": [tam.x, tam.y]}
	for k in extra.keys():
		d[k] = extra[k]
	return PlacementRule.desde_dict(d)

# ── bloques ──────────────────────────────────────────────────────────────

func _b1_tipos() -> void:
	_abrir("1", "ConstruccionTipos: claves, textos y resultados")
	var c := Vector3i(-3, 7, 12)
	_ok(ConstruccionTipos.clave(c) == "-3,7,12", "clave() -> '-3,7,12' (dio '%s')" % ConstruccionTipos.clave(c))
	_ok(ConstruccionTipos.celda_de_clave("-3,7,12") == c, "celda_de_clave() invierte clave()")
	_ok(ConstruccionTipos.celda_de_clave("basura") == Vector3i.ZERO, "clave invalida -> Vector3i.ZERO")
	_ok(ConstruccionTipos.texto(ConstruccionTipos.Motivo.CELDA_OCUPADA) == "celda ocupada por otra pieza",
		"texto(CELDA_OCUPADA) correcto")
	var ok := ConstruccionTipos.resultado_ok([Vector3i(1, 0, 1)])
	_ok(bool(ok["ok"]) == true and (ok["motivos"] as Array).is_empty(), "resultado_ok: ok=true y sin motivos")
	var no := ConstruccionTipos.resultado_fallo([ConstruccionTipos.Motivo.SIN_SOPORTE])
	_ok(bool(no["ok"]) == false and int((no["motivos"] as Array)[0]) == ConstruccionTipos.Motivo.SIN_SOPORTE,
		"resultado_fallo: ok=false con el motivo pedido")
	_ok(String(no["texto"]).contains("soporte"), "resultado_fallo compone texto legible (dio '%s')" % String(no["texto"]))
	_fin("1")

func _b2_placement_rule() -> void:
	_abrir("2", "PlacementRule: huella, rotacion, devolucion, round-trip")
	var r := _receta("piso", Vector2i(1, 1), {"costo": {"madera": 2}})
	_ok(r.es_valida(), "receta con id es valida")
	_ok(not _receta("").es_valida(), "receta sin id NO es valida")
	_ok(r.celdas(Vector3i(0, 0, 0), 0).size() == 1, "1x1 ocupa 1 celda")
	var viga := _receta("viga", Vector2i(3, 1))
	var c0 := viga.celdas(Vector3i(0, 0, 0), 0)
	_ok(c0.size() == 3 and c0[2] == Vector3i(2, 0, 0), "3x1 en rot 0 -> 3 celdas hacia +x")
	var c1 := viga.celdas(Vector3i(0, 0, 0), 1)
	_ok(c1.size() == 3 and c1[2] == Vector3i(0, 0, 2), "3x1 en rot 90 -> 3 celdas hacia +z (rotacion real)")
	_ok(viga.celdas(Vector3i(5, 0, 5), 2)[0] == Vector3i(5, 0, 5), "el ancla es la esquina de menor x/z")
	var dev := _receta("x", Vector2i.ONE, {"costo": {"madera": 5, "piedra": 3}, "devolucion": 0.5}).devolucion_por_item()
	_ok(int(dev.get("madera", 0)) == 2 and int(dev.get("piedra", 0)) == 1,
		"devolucion 50%% redondea hacia abajo (madera 5->2, piedra 3->1): %s" % str(dev))
	var r2 := PlacementRule.desde_dict(r.a_dict())
	_ok(String(r2.id) == "piso" and r2.costo == r.costo and r2.tamano == r.tamano, "desde_dict(a_dict()) es estable")
	_ok(_receta("t", Vector2i.ONE, {"costo": {"a": 4, "b": 6}}).costo_total() == 10, "costo_total() suma 4+6=10")
	_fin("2")

func _b3_zone_registry() -> void:
	_abrir("3", "ZoneRegistry: zona mas especifica, permisos, AABB degenerada")
	var z := ZoneRegistry.new()
	_ok(z.zona_de(Vector3i(0, 0, 0)) == ConstruccionTipos.Permiso.EDIFICABLE, "sin zonas -> EDIFICABLE por defecto")
	z.registrar_zona(AABB(Vector3(0, 0, 0), Vector3(10, 1, 10)), ConstruccionTipos.Permiso.PROTEGIDA)
	_ok(z.zona_de(Vector3i(5, 0, 5)) == ConstruccionTipos.Permiso.PROTEGIDA, "celda dentro de PROTEGIDA -> PROTEGIDA")
	_ok(z.zona_de(Vector3i(20, 0, 20)) == ConstruccionTipos.Permiso.EDIFICABLE, "celda fuera -> EDIFICABLE")
	z.registrar_zona(AABB(Vector3(3, 0, 3), Vector3(2, 1, 2)), ConstruccionTipos.Permiso.NARRATIVA)
	_ok(z.zona_de(Vector3i(3, 0, 3)) == ConstruccionTipos.Permiso.NARRATIVA,
		"la zona MAS ESPECIFICA (menor volumen) gana")
	_ok(z.zona_de(Vector3i(8, 0, 8)) == ConstruccionTipos.Permiso.PROTEGIDA, "fuera de la especifica -> la amplia")
	_ok(z.id_zona_de(Vector3i(3, 0, 3)) != z.id_zona_de(Vector3i(8, 0, 8)), "id_zona_de distingue regiones")
	_ok(z.id_zona_de(Vector3i(50, 0, 50)) == -1, "id_zona_de = -1 fuera de toda zona")
	_ok(z.permitido(ConstruccionTipos.Permiso.PROTEGIDA, Vector3i(5, 0, 5)), "permitido() con el permiso exacto")
	_ok(not z.permitido(ConstruccionTipos.Permiso.EDIFICABLE, Vector3i(5, 0, 5)), "permitido() false con otro permiso")
	# Trampa medida: AABB.has_point() de Godot incluye el borde MAXIMO (un AABB de
	# tamano 2 cubriria las celdas 3,4,5). Aqui la contencion es SEMIABIERTA.
	_ok(z.zona_de(Vector3i(10, 0, 10)) == ConstruccionTipos.Permiso.EDIFICABLE,
		"el borde maximo del AABB NO se incluye (celda 10 fuera de tamano 10)")
	_ok(z.zona_de(Vector3i(9, 0, 9)) == ConstruccionTipos.Permiso.PROTEGIDA, "la ultima celda (9) SI entra")
	var antes := z.cantidad()
	z.registrar_zona(AABB(Vector3(0, 0, 0), Vector3(0, 0, 0)), ConstruccionTipos.Permiso.AGUA)
	_ok(z.cantidad() == antes, "AABB de volumen 0 se ignora (no ensucia el registro)")
	z.limpiar()
	_ok(z.cantidad() == 0 and z.zona_de(Vector3i(5, 0, 5)) == ConstruccionTipos.Permiso.EDIFICABLE,
		"limpiar() deja el registro vacio")
	_fin("3")

func _b4_validator_feliz() -> void:
	_abrir("4", "ConstruccionValidator: CAMINO FELIZ afirmado explicitamente")
	var piso := _receta("piso", Vector2i.ONE, {"superficie_ok": ["terreno", "piso"]})
	var res := ConstruccionValidator.validar(piso, Vector3i(0, 0, 0), 0, _ctx())
	_ok(bool(res.get("ok", false)) == true, "piso sobre terreno -> ok=true (dio %s)" % str(res.get("ok")))
	_ok((res.get("motivos", []) as Array).is_empty(), "sin motivos en el camino feliz")
	_ok((res.get("celdas", []) as Array).size() == 1, "el resultado trae la huella (1 celda)")
	# El enum de permisos tiene un valor OK implicito: afirmamos el valor exacto.
	_ok(int(res.get("motivos", []).size()) == 0, "motivos.size() == 0 exacto (no 'no falla')")
	_fin("4")

func _b5_validator_motivos() -> void:
	_abrir("5", "ConstruccionValidator: cada motivo de rechazo, en rojo")
	var piso := _receta("piso", Vector2i.ONE, {"superficie_ok": ["terreno", "piso"]})

	# receta invalida
	var ri := ConstruccionValidator.validar(null, Vector3i.ZERO, 0, _ctx())
	_ok((ri["motivos"] as Array).has(ConstruccionTipos.Motivo.RECETA_INVALIDA), "receta nula -> RECETA_INVALIDA")

	# zona protegida
	var rp := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, _ctx({}, &"terreno", ConstruccionTipos.Permiso.PROTEGIDA))
	_ok((rp["motivos"] as Array).has(ConstruccionTipos.Motivo.ZONA_PROTEGIDA), "zona PROTEGIDA -> ZONA_PROTEGIDA")

	# zona narrativa
	var rn := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, _ctx({}, &"terreno", ConstruccionTipos.Permiso.NARRATIVA))
	_ok((rn["motivos"] as Array).has(ConstruccionTipos.Motivo.ZONA_NARRATIVA), "zona NARRATIVA -> ZONA_NARRATIVA")

	# agua sin sobre_agua
	var ra := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, _ctx({}, &"terreno", ConstruccionTipos.Permiso.AGUA))
	_ok((ra["motivos"] as Array).has(ConstruccionTipos.Motivo.AGUA_NO_PERMITIDA), "AGUA sin sobre_agua -> AGUA_NO_PERMITIDA")

	# puente sobre agua: CONTROL POSITIVO
	var puente := _receta("puente", Vector2i(3, 1), {"sobre_agua": true, "soportes_minimos": 0, "superficie_ok": ["agua"]})
	var rpu := ConstruccionValidator.validar(puente, Vector3i.ZERO, 0, _ctx({}, &"agua", ConstruccionTipos.Permiso.AGUA))
	_ok(bool(rpu["ok"]) == true, "puente sobre AGUA con sobre_agua -> ok (control positivo)")
	var rpu2 := ConstruccionValidator.validar(puente, Vector3i.ZERO, 0, _ctx({}, &"terreno", ConstruccionTipos.Permiso.EDIFICABLE))
	_ok((rpu2["motivos"] as Array).has(ConstruccionTipos.Motivo.FUERA_DE_ZONA), "puente sobre tierra firme -> FUERA_DE_ZONA")

	# ocupada
	var ro := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, _ctx({}, &"terreno", 0, true, [], [Vector3i.ZERO]))
	_ok((ro["motivos"] as Array).has(ConstruccionTipos.Motivo.CELDA_OCUPADA), "celda ocupada -> CELDA_OCUPADA")

	# sin soporte
	var rs := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, _ctx({}, &"aire"))
	_ok((rs["motivos"] as Array).has(ConstruccionTipos.Motivo.SIN_SOPORTE), "sin superficie debajo -> SIN_SOPORTE")

	# techo exige 2 soportes
	var techo := _receta("techo", Vector2i(2, 1), {"soportes_minimos": 2, "superficie_ok": ["piso"]})
	var mapa := {Vector3i(0, -1, 0): &"piso"}   # solo 1 de las 2 celdas apoyan
	var rt := ConstruccionValidator.validar(techo, Vector3i(0, 0, 0), 0, _ctx(mapa, &"aire"))
	_ok((rt["motivos"] as Array).has(ConstruccionTipos.Motivo.SIN_SOPORTE), "techo con 1/2 soportes -> SIN_SOPORTE")
	var mapa2 := {Vector3i(0, -1, 0): &"piso", Vector3i(1, -1, 0): &"piso"}
	var rt2 := ConstruccionValidator.validar(techo, Vector3i(0, 0, 0), 0, _ctx(mapa2, &"aire"))
	_ok(bool(rt2["ok"]) == true, "techo con 2/2 soportes -> ok (control positivo)")

	# requiere pared
	var puerta := _receta("puerta", Vector2i(1, 1), {"requiere_pared": true, "superficie_ok": ["piso"]})
	var rd := ConstruccionValidator.validar(puerta, Vector3i.ZERO, 0, _ctx({}, &"piso"))
	_ok((rd["motivos"] as Array).has(ConstruccionTipos.Motivo.REQUIERE_PARED), "puerta sin pared -> REQUIERE_PARED")
	var rdp := ConstruccionValidator.validar(puerta, Vector3i.ZERO, 0,
		_ctx({Vector3i(1, 0, 0): &"pared", Vector3i(0, -1, 0): &"piso"}, &"aire"))
	_ok(bool(rdp["ok"]) == true, "puerta con pared contigua y piso -> ok (control positivo)")

	# NPC
	var rnp := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, _ctx({}, &"terreno", 0, true, [Vector3i.ZERO]))
	_ok((rnp["motivos"] as Array).has(ConstruccionTipos.Motivo.NPC_EN_CELDA), "NPC en la celda -> NPC_EN_CELDA")

	# recursos
	var rr := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, _ctx({}, &"terreno", 0, false))
	_ok((rr["motivos"] as Array).has(ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES), "no pagable -> RECURSOS_INSUFICIENTES")

	# limite por zona
	var lim := _receta("lim", Vector2i.ONE, {"max_por_zona": 3})
	var rl := ConstruccionValidator.validar(lim, Vector3i.ZERO, 0, _ctx({}, &"terreno", 0, true, [], [], 3))
	_ok((rl["motivos"] as Array).has(ConstruccionTipos.Motivo.LIMITE_DE_ZONA), "3/3 piezas -> LIMITE_DE_ZONA")

	# acumula varios motivos a la vez
	var multi := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0,
		_ctx({}, &"aire", ConstruccionTipos.Permiso.PROTEGIDA, false, [Vector3i.ZERO], [Vector3i.ZERO]))
	_ok((multi["motivos"] as Array).size() >= 4,
		"acumula motivos (zona+ocupada+soporte+npc+recursos): %d" % (multi["motivos"] as Array).size())

	# ctx vacio: falla cerrado y deja constancia
	var rv := ConstruccionValidator.validar(piso, Vector3i.ZERO, 0, {})
	_ok(bool(rv["ok"]) == false, "ctx vacio -> NO valida (falla cerrado)")
	var txt := " ".join(rv["detalle"].map(func(s): return String(s)))
	_ok(txt.contains("sin 'permiso'"), "ctx vacio deja nota de datos incompletos en detalle")
	_fin("5")

func _b6_history() -> void:
	_abrir("6", "BuildHistory: registrar, undo/redo, invalidacion del redo")
	var h := BuildHistory.new()
	_ok(not h.puede_undo() and not h.puede_redo(), "pila nueva vacia")
	h.registrar({"tipo": "colocar", "celda": Vector3i(0, 0, 0)})
	h.registrar({"tipo": "demoler", "celda": Vector3i(1, 0, 0)})
	_ok(h.tamanos() == {"undo": 2, "redo": 0}, "2 acciones -> undo=2 redo=0")
	var d := h.undo_ultimo()
	_ok(String(d.get("tipo", "")) == "demoler", "undo_ultimo devuelve la ultima (LIFO)")
	_ok(h.tamanos() == {"undo": 1, "redo": 1}, "tras undo -> undo=1 redo=1")
	var d2 := h.redo_siguiente()
	_ok(String(d2.get("tipo", "")) == "demoler", "redo_siguiente devuelve la deshecha")
	h.registrar({"tipo": "mover", "celda": Vector3i(2, 0, 0)})
	_ok(not h.puede_redo(), "registrar una accion nueva invalida el redo")
	h.limpiar()
	_ok(h.tamanos() == {"undo": 0, "redo": 0}, "limpiar() vacia ambas pilas")
	var h2 := BuildHistory.new()
	h2.limite = 2
	h2.registrar({"tipo": "a"}); h2.registrar({"tipo": "b"}); h2.registrar({"tipo": "c"})
	_ok(h2.tamanos()["undo"] == 2, "limite=2 descarta la accion mas vieja")
	_ok(h2.undo_ultimo().get("tipo") == "c", "el tope conserva las acciones recientes")
	_fin("6")

func _b7_sesion(mgr) -> void:
	_abrir("7", "BuildManager: entrada/salida de modo y senal obra_activa")
	var visto: Array = []
	mgr.obra_activa.connect(func(a: bool) -> void: visto.append(a))
	mgr.entrar_modo(ConstruccionTipos.Modo.DECORACION)
	_ok(mgr.esta_en_modo(), "esta_en_modo() true tras entrar_modo()")
	_ok(mgr.modo_actual() == ConstruccionTipos.Modo.DECORACION, "modo_actual() = DECORACION")
	_ok(visto == [true], "obra_activa(true) emitida (dio %s)" % str(visto))
	mgr.salir_modo()
	_ok(not mgr.esta_en_modo(), "esta_en_modo() false tras salir_modo()")
	_ok(visto == [true, false], "obra_activa(false) emitida al salir")
	_ok(mgr.receta_actual() == null, "salir_modo() deselecciona la pieza")
	mgr.rotar_paso(); mgr.rotar_paso(); mgr.rotar_paso(); mgr.rotar_paso()
	_ok(mgr.rotacion_actual() == 0, "rotar_paso() cicla 0..3 (4 giros -> 0)")
	mgr.set_planta(3)
	_ok(mgr.planta_actual() == 3, "set_planta()/planta_actual()")
	_fin("7")

func _b8_colocar(mgr) -> void:
	_abrir("8", "BuildManager: colocar con costo real (inventario inyectado)")
	var inv := FakeInventario.new()
	inv.items = {"madera": 10}
	mgr.conectar_inventario(inv)
	mgr.conectar_zonas(ZoneRegistry.new())
	mgr.conectar_mundo(MundoPlano.new())   # terreno plano falso -> soporte en y=-1
	mgr.limpiar_estructuras()
	var piso := _receta("piso", Vector2i.ONE, {"costo": {"madera": 2}, "superficie_ok": ["terreno", "piso"]})
	mgr.registrar_receta(piso)
	_ok(mgr.seleccionar_pieza(piso), "seleccionar_pieza() acepta una receta valida")
	_ok(not mgr.seleccionar_pieza(null), "seleccionar_pieza(null) rechazado")

	var res: Dictionary = mgr.confirmar_colocacion(Vector3i(0, 0, 0))
	_ok(bool(res.get("ok", false)) == true, "colocar en celda valida -> ok")
	_ok(int(inv.count_item("madera")) == 8, "costo descontado: 10-2=8 (dio %d)" % inv.count_item("madera"))
	_ok(mgr.cantidad_estructuras() == 1, "1 estructura registrada")
	_ok(mgr._ctx_ocupada(Vector3i(0, 0, 0)), "la celda quedo ocupada")

	var res2: Dictionary = mgr.confirmar_colocacion(Vector3i(0, 0, 0))
	_ok(bool(res2.get("ok", false)) == false, "recolocar en la misma celda -> rechazado")
	_ok((res2["motivos"] as Array).has(ConstruccionTipos.Motivo.CELDA_OCUPADA), "motivo CELDA_OCUPADA")
	_ok(int(inv.count_item("madera")) == 8, "un rechazo NO cobra recursos")

	# sin recursos
	inv.items = {"madera": 0}
	var res3: Dictionary = mgr.confirmar_colocacion(Vector3i(5, 0, 5))
	_ok(bool(res3.get("ok", false)) == false, "sin recursos -> rechazado")
	_ok((res3["motivos"] as Array).has(ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES), "motivo RECURSOS_INSUFICIENTES")
	_fin("8")

func _b9_demoler_undo(mgr) -> void:
	_abrir("9", "BuildManager: demoler (devolucion 50%), undo y redo")
	var inv := FakeInventario.new()
	inv.items = {"madera": 10}
	mgr.conectar_inventario(inv)
	mgr.conectar_zonas(ZoneRegistry.new())
	mgr.conectar_mundo(MundoPlano.new())
	mgr.limpiar_estructuras()
	var piso := _receta("piso", Vector2i.ONE, {"costo": {"madera": 4}, "superficie_ok": ["terreno", "piso"]})
	mgr.registrar_receta(piso)
	mgr.seleccionar_pieza(piso)
	mgr.confirmar_colocacion(Vector3i(0, 0, 0))
	_ok(int(inv.count_item("madera")) == 6, "tras colocar: 10-4=6")

	var d: Dictionary = mgr.demolir_pieza(Vector3i(0, 0, 0))
	_ok(bool(d.get("ok", false)) == true, "demoler -> ok")
	_ok(int(inv.count_item("madera")) == 8, "devolucion 50%%: 6+2=8 (dio %d)" % inv.count_item("madera"))
	_ok(mgr.cantidad_estructuras() == 0, "la estructura desaparecio")
	_ok(not mgr._ctx_ocupada(Vector3i(0, 0, 0)), "la celda quedo libre")

	var d2: Dictionary = mgr.demolir_pieza(Vector3i(9, 0, 9))
	_ok(bool(d2.get("ok", false)) == false, "demoler celda vacia -> rechazado")
	_ok((d2["motivos"] as Array).has(ConstruccionTipos.Motivo.NO_HAY_PIEZA), "motivo NO_HAY_PIEZA")

	var u: Dictionary = mgr.undo()
	_ok(bool(u.get("ok", false)) == true, "undo de la demolicion -> ok")
	_ok(mgr.cantidad_estructuras() == 1, "undo restauro la estructura")
	_ok(mgr._ctx_ocupada(Vector3i(0, 0, 0)), "undo reocupo la celda")
	_ok(int(inv.count_item("madera")) == 6, "undo re-cobro la devolucion: 8-2=6 (dio %d)" % inv.count_item("madera"))

	var r: Dictionary = mgr.redo()
	_ok(bool(r.get("ok", false)) == true, "redo -> ok")
	_ok(mgr.cantidad_estructuras() == 0, "redo volvio a demoler")
	_ok(int(inv.count_item("madera")) == 8, "redo devolvio otra vez: 8 (dio %d)" % inv.count_item("madera"))
	_fin("9")

func _b10_mover(mgr) -> void:
	_abrir("10", "BuildManager: mover pieza (sin re-cobrar) y rollback")
	var inv := FakeInventario.new()
	inv.items = {"madera": 10}
	mgr.conectar_inventario(inv)
	var z := ZoneRegistry.new()
	# zona protegida en el destino para forzar el rollback
	z.registrar_zona(AABB(Vector3(8, 0, 8), Vector3(2, 2, 2)), ConstruccionTipos.Permiso.PROTEGIDA)
	mgr.conectar_zonas(z)
	mgr.conectar_mundo(MundoPlano.new())
	mgr.limpiar_estructuras()
	var piso := _receta("piso", Vector2i.ONE, {"costo": {"madera": 4}, "superficie_ok": ["terreno", "piso"]})
	mgr.registrar_receta(piso)
	mgr.seleccionar_pieza(piso)
	mgr.confirmar_colocacion(Vector3i(0, 0, 0))
	var madera_tras_colocar: int = inv.count_item("madera")

	var m: Dictionary = mgr.mover_pieza(Vector3i(0, 0, 0), Vector3i(2, 0, 2))
	_ok(bool(m.get("ok", false)) == true, "mover a celda valida -> ok")
	_ok(not mgr._ctx_ocupada(Vector3i(0, 0, 0)) and mgr._ctx_ocupada(Vector3i(2, 0, 2)), "origen libre, destino ocupado")
	_ok(int(inv.count_item("madera")) == madera_tras_colocar, "mover NO re-cobra recursos")

	var m2: Dictionary = mgr.mover_pieza(Vector3i(2, 0, 2), Vector3i(8, 0, 8))
	_ok(bool(m2.get("ok", false)) == false, "mover a zona protegida -> rechazado")
	_ok(mgr._ctx_ocupada(Vector3i(2, 0, 2)), "rollback: la pieza sigue en el origen")
	_ok(not mgr._ctx_ocupada(Vector3i(8, 0, 8)), "rollback: el destino NO quedo ocupado")

	var u: Dictionary = mgr.undo()
	_ok(bool(u.get("ok", false)) == true, "undo del movimiento -> ok")
	_ok(mgr._ctx_ocupada(Vector3i(0, 0, 0)), "undo devolvio la pieza a (0,0,0)")
	_fin("10")

func _b11_persistencia(mgr) -> void:
	_abrir("11", "Persistencia: codec canonico + duck-typing de BuildingsSaveProvider (BUG-057)")
	var inv := FakeInventario.new()
	inv.items = {"madera": 100}
	mgr.conectar_inventario(inv)
	mgr.conectar_zonas(ZoneRegistry.new())
	mgr.conectar_mundo(MundoPlano.new())
	mgr.limpiar_estructuras()
	var pared := _receta("pared_madera", Vector2i(1, 1), {"costo": {"madera": 1}, "superficie_ofrecida": "pared"})
	var piso := _receta("piso_tablones", Vector2i(2, 1), {"costo": {"madera": 1}, "superficie_ok": ["terreno", "piso"]})
	mgr.registrar_receta(pared)
	mgr.registrar_receta(piso)
	mgr.seleccionar_pieza(piso)
	mgr.confirmar_colocacion(Vector3i(0, 0, 0))
	mgr.seleccionar_pieza(pared)
	mgr.confirmar_colocacion(Vector3i(5, 0, 5))

	var lista: Array = mgr.obtener_estructuras()
	_ok(lista.size() == 2, "obtener_estructuras() devuelve 2")
	_ok(lista[0] is Dictionary and (lista[0] as Dictionary).has("id"), "cada estructura trae id")
	var claves := ["id", "tipo", "pos", "rot_y", "planta", "variante"]
	var primera: Dictionary = lista[0]
	var todas: bool = true
	for k in claves:
		if not primera.has(k):
			todas = false
	_ok(todas, "la estructura trae las 6 claves canonicas del codec: %s" % str(primera.keys()))
	_ok((primera["pos"] as Array).size() == 3, "pos es [x,y,z]")
	_ok(typeof((primera["pos"] as Array)[0]) == TYPE_INT, "pos es INT (no float) — trampa 1197")

	# el codec acepta y normaliza
	var seccion := EstructurasCodec.a_seccion(lista)
	var norm := EstructurasCodec.desde_seccion(seccion)
	_ok(norm.size() == 2, "codec: a_seccion/desde_seccion conserva 2")
	_ok((EstructurasCodec.validar(norm) as Array).is_empty(), "codec.validar() sin errores")
	_ok(EstructurasCodec.contar(norm) == 2, "codec.contar(lista) == 2")

	# sin aliasing: mutar el retorno no toca el estado
	var l1: Array = mgr.obtener_estructuras()
	(l1[0] as Dictionary)["tipo"] = "MUTADO"
	var l2: Array = mgr.obtener_estructuras()
	_ok(String((l2[0] as Dictionary)["tipo"]) != "MUTADO", "obtener_estructuras() no aliasa el estado interno")

	# PROVIDER REAL por duck-typing: esto es el cierre de BUG-057
	var prov := BuildingsSaveProvider.new()
	_ok(prov.tiene_fuente(), "BuildingsSaveProvider encuentra la fuente (autoload Construccion) por duck-typing")
	_ok(prov.get_section_name() == EstructurasCodec.SECCION, "la seccion del provider es 'buildings'")
	var sec: Dictionary = prov.get_save_data()
	_ok(sec.has("structures") and (sec["structures"] as Array).size() == 2,
		"get_save_data() -> {structures: [2]} (dio %s)" % str((sec.get("structures", []) as Array).size()))

	# restauracion idempotente
	mgr.limpiar_estructuras()
	_ok(mgr.cantidad_estructuras() == 0, "limpiar_estructuras() vacia")
	prov.restore_save_data(sec)
	_ok(mgr.cantidad_estructuras() == 2, "restore_save_data() restauro 2")
	var antes: Array = mgr.obtener_estructuras()
	prov.restore_save_data(sec)
	var despues: Array = mgr.obtener_estructuras()
	_ok(antes.size() == despues.size(), "restaurar 2 veces es IDEMPOTENTE (no duplica): %d -> %d" % [
		antes.size(), despues.size()])
	var tipos: Array = despues.map(func(e): return String((e as Dictionary)["tipo"]))
	tipos.sort()
	_ok(tipos == ["pared_madera", "piso_tablones"], "los tipos restaurados son los esperados: %s" % str(tipos))

	# rot_y se conserva y vuelve como multiplo de 90
	mgr.limpiar_estructuras()
	mgr.seleccionar_pieza(piso)
	mgr.set_rotacion(1)   # 90 grados
	mgr.confirmar_colocacion(Vector3i(0, 0, 0))
	var e0: Dictionary = mgr.obtener_estructuras()[0]
	_ok(int(e0["rot_y"]) == 90, "rot_y guardado como grados (90): %d" % int(e0["rot_y"]))
	_fin("11")

func _b12_catalogo_tres() -> void:
	_abrir("12", "Catalogo .tres real: 3 piezas prototipo cargan con sus campos")
	var dir := "res://data/construccion/piezas"
	var d := DirAccess.open(dir)
	_ok(d != null, "DirAccess abre %s (si falla, el catalogo data-driven estaria muerto)" % dir)
	if d == null:
		_fin("12")
		return
	var esperados := ["pared_madera", "piso_tablones", "techo_paja"]
	var encontrados: Array = []
	for f in d.get_files():
		if String(f).ends_with(".tres"):
			encontrados.append(String(f).get_basename())
	encontrados.sort()
	# iter. 2 crecio el catalogo a 33 recetas (12 familias): las 3 prototipo deben
	# seguir presentes, pero ya NO son las unicas.
	var faltan: Array = []
	for e in esperados:
		if not encontrados.has(e):
			faltan.append(e)
	_ok(faltan.is_empty(), "las 3 piezas prototipo siguen en el catalogo (faltan: %s)" % str(faltan))

	var pared = load("%s/pared_madera.tres" % dir)
	_ok(pared is PlacementRule, "pared_madera es una PlacementRule")
	_ok(String(pared.id) == "pared_madera" and pared.bloque == 8, "pared: id y bloque correctos")
	_ok(String(pared.superficie_ofrecida) == "pared", "pared ofrece superficie 'pared'")
	# iter. 2: el item_id se corrigio a uno REAL de M14 (data/items/planks.tres);
	# "madera" NO existe como item y el costo era impagable.
	_ok(int(pared.costo.get("planks", 0)) == 4, "pared cuesta 4 de planks (item real de M14)")

	var techo = load("%s/techo_paja.tres" % dir)
	_ok(techo.soportes_minimos == 2, "techo exige 2 soportes (regla de techos)")
	_ok(String(techo.variante) == "cumbrera", "techo trae variante 'cumbrera'")
	_ok(String(techo.superficie_ofrecida) == "techo", "techo ofrece superficie 'techo'")

	var piso = load("%s/piso_tablones.tres" % dir)
	_ok(piso.altura == 0.5, "piso tiene altura 0.5 (losa)")

	# el autoload debe haberlos cargado en su catalogo
	var mgr = root.get_node_or_null("/root/Construccion")
	if mgr != null:
		_ok(mgr.catalogo().size() >= 3, "el autoload cargo >= 3 recetas (dio %d)" % mgr.catalogo().size())
		_ok(mgr.receta(&"pared_madera") != null, "el catalogo del autoload tiene pared_madera")
	_fin("12")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	_b1_tipos()
	_b2_placement_rule()
	_b3_zone_registry()
	_b4_validator_feliz()
	_b5_validator_motivos()
	_b6_history()

	var mgr = root.get_node_or_null("/root/Construccion")
	_ok(mgr != null, "autoload Construccion presente en /root")
	if mgr == null:
		return
	_b7_sesion(mgr)
	_b8_colocar(mgr)
	_b9_demoler_undo(mgr)
	_b10_mover(mgr)
	_b11_persistencia(mgr)
	_b12_catalogo_tres()

	# deja el autoload limpio (no contamina otras suites del mismo proceso)
	mgr.limpiar_estructuras()
	mgr.salir_modo()
	mgr.conectar_inventario(null)

func _summary() -> void:
	print("=== RESUMEN M17 CONSTRUCCION: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON (abortados por un error de runtime):")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d checks < CHECKS_MINIMOS=%d (suite muerta o recortada)" % [
			_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
