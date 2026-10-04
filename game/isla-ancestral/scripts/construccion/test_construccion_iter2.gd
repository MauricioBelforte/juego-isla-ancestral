# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 2 — suite del catalogo de 12 familias + preview/ghost +
# integracion M64 (navmesh_delta).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter2.gd
#
# Guardia anti-falso-verde de 3 capas (doctrina del repo, trampas 118/119/1197):
#   1) _fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO EN VERDE (no estimado, no copiado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code.
#
# Afirma el CAMINO FELIZ explicitamente (trampa 1197).
# No usa class_name propio: evita depender del cache de clases globales.

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE (99) y fijado aqui.
const CHECKS_MINIMOS: int = 99

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

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

## Mundo falso: terreno PLANO y solido por debajo de `suelo`.
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

# ── bloques ──────────────────────────────────────────────────────────────

## 1. BuildCatalogDB: carga real, familias, vistas y auditoria.
func _b1_catalogo_db() -> void:
	_abrir("1", "BuildCatalogDB: carga las 12 familias y las indexa")
	var db := BuildCatalogDB.new()
	var n: int = db.cargar("res://data/construccion/piezas")
	_ok(n == 33, "carga 33 recetas reales (dio %d)" % n)
	_ok(db.cantidad() == 33, "cantidad() == 33")
	_ok(db.tiene(&"pared_madera") and db.tiene(&"puente_4") and db.tiene(&"totem"),
		"tiene() encuentra piezas de familias distintas")
	_ok(db.receta(&"no_existe") == null, "receta() de un id inexistente -> null")

	var fams: Array = db.familias_presentes()
	_ok(fams.size() == 12, "las 12 familias estan presentes (dio %d)" % fams.size())
	_ok(BuildCatalogDB.FAMILIAS.size() == 12, "FAMILIAS tiene 12 entradas")
	var faltantes: Array = []
	for f in BuildCatalogDB.FAMILIAS:
		if not fams.has(f):
			faltantes.append(String(f))
	_ok(faltantes.is_empty(), "ninguna familia quedo vacia (faltan: %s)" % str(faltantes))

	var paredes: Array = db.por_familia(&"pared")
	_ok(paredes.size() == 4, "familia 'pared' tiene 4 recetas (dio %d)" % paredes.size())
	var puentes: Array = db.por_familia(&"puente")
	_ok(puentes.size() == 3, "familia 'puente' tiene 3 recetas (dio %d)" % puentes.size())

	var decor: Array = db.por_modo(true)
	var constr: Array = db.por_modo(false)
	_ok(decor.size() + constr.size() == 33, "por_modo cubre las 33 (decor %d + constr %d)" % [decor.size(), constr.size()])
	_ok(decor.size() == 11, "modo decoracion = 11 piezas (dio %d)" % decor.size())

	var audit: Dictionary = db.validar()
	_ok(bool(audit["ok"]) == true, "validar() del catalogo real: OK (problemas: %s)" % str(audit["problemas"]))
	_ok(int(audit["n"]) == 33, "validar() reporta n=33")

	var mapa: Dictionary = db.mapa_de_familias()
	_ok(mapa.size() == 12, "mapa_de_familias() cubre las 12 (0 incluidas)")

	# quitar / limpiar / registrar
	_ok(db.quitar(&"totem") == true, "quitar() borra una receta")
	_ok(db.tiene(&"totem") == false and db.cantidad() == 32, "tras quitar, cantidad 32")
	_ok(db.quitar(&"totem") == false, "quitar() de algo ausente -> false")
	db.limpiar()
	_ok(db.cantidad() == 0, "limpiar() deja el catalogo vacio")
	_ok(db.validar()["ok"] == true, "catalogo vacio: validar() OK (no hay nada roto)")
	_fin("1")

## 2. PlacementRule.familia: round-trip dict y valor por defecto.
func _b2_familia() -> void:
	_abrir("2", "PlacementRule.familia: round-trip y validacion de familia")
	var r := PlacementRule.desde_dict({"id": "x", "nombre": "X", "familia": "cerca"})
	_ok(r.familia == &"cerca", "desde_dict lee 'familia'")
	_ok(BuildCatalogDB.es_familia(r.familia), "es_familia('cerca') = true")
	_ok(BuildCatalogDB.es_familia(&"inventada") == false, "es_familia('inventada') = false")
	var d: Dictionary = r.a_dict()
	_ok(String(d["familia"]) == "cerca", "a_dict() escribe 'familia'")
	var r2 := PlacementRule.new()
	_ok(r2.familia == &"", "familia por defecto = vacia (compatibilidad con iter. 1)")
	_fin("2")

## 3. Integridad del catalogo real: item ids, agua, techos, pared.
func _b3_integridad() -> void:
	_abrir("3", "Integridad del catalogo real (item ids de M14 y reglas por familia)")
	var db := BuildCatalogDB.new()
	db.cargar("res://data/construccion/piezas")

	# (a) TODO item_id de costo debe existir como recurso real de M14.
	var malos: Array = []
	for id in db.ids():
		var r: PlacementRule = db.receta(id)
		for k in r.costo.keys():
			var item_id: String = String(k)
			if not ResourceLoader.exists("res://data/items/%s.tres" % item_id):
				malos.append("%s -> %s" % [String(id), item_id])
	_ok(malos.is_empty(), "todo item_id del costo existe en data/items/ (malos: %s)" % str(malos))

	# (b) los puentes van sobre agua y no exigen soporte.
	var puentes_ok: bool = true
	for r in db.por_familia(&"puente"):
		if not r.sobre_agua or not r.superficie_ok.has(&"agua") or r.soportes_minimos != 0:
			puentes_ok = false
	_ok(puentes_ok, "todo puente: sobre_agua + superficie 'agua' + 0 soportes")

	# (c) los techos exigen 2+ soportes.
	var techos_ok: bool = true
	for r in db.por_familia(&"techo"):
		if r.soportes_minimos < 2:
			techos_ok = false
	_ok(techos_ok, "todo techo exige 2+ soportes (regla de techos)")

	# (d) puertas y ventanas exigen pared contigua.
	var aberturas_ok: bool = true
	for fam in [&"puerta", &"ventana"]:
		for r in db.por_familia(fam):
			if not r.requiere_pared:
				aberturas_ok = false
	_ok(aberturas_ok, "toda puerta/ventana exige pared contigua")

	# (e) la puerta es 1x2 (marco) y el camino es plano.
	var puerta: PlacementRule = db.receta(&"puerta_madera")
	_ok(puerta.tamano == Vector2i(1, 2), "puerta_madera es 1x2 (dio %s)" % str(puerta.tamano))
	var camino: PlacementRule = db.receta(&"camino_piedra")
	_ok(camino.altura <= 0.2, "camino_piedra es plano (altura %.2f)" % camino.altura)

	# (f) el catalogo cargado por el AUTOLOAD coincide con la carpeta.
	var mgr = root.get_node_or_null("/root/Construccion")
	if mgr != null:
		var db2 = mgr.catalogo_db()
		_ok(db2 != null and db2.cantidad() == 33,
			"el autoload expone un BuildCatalogDB con 33 recetas (dio %s)" % str(db2.cantidad() if db2 != null else -1))
	_fin("3")

## 4. Carga RECURSIVA (subcarpetas de familia).
func _b4_carga_recursiva() -> void:
	_abrir("4", "BuildCatalogDB.cargar es recursivo (acepta subcarpetas)")
	var db := BuildCatalogDB.new()
	# apuntando al PADRE, debe bajar a piezas/ y encontrar lo mismo
	var n: int = db.cargar("res://data/construccion")
	_ok(n == 33, "cargar() desde el padre encuentra las 33 por recursion (dio %d)" % n)
	_ok(db.tiene(&"techo_losa"), "la recursion alcanzo las piezas del subdirectorio")
	var db2 := BuildCatalogDB.new()
	var n2: int = db2.cargar("res://ruta/que/no/existe")
	_ok(n2 == 0 and db2.cantidad() == 0, "carpeta inexistente -> 0 y catalogo vacio (tolerante)")
	_fin("4")

## 5. BuildPreview: validacion, color, cache y resumen.
func _b5_preview(mgr) -> void:
	_abrir("5", "BuildPreview: color, cache de celda y resumen para el HUD")
	var prev := BuildPreview.new()
	var db := BuildCatalogDB.new()
	db.cargar("res://data/construccion/piezas")
	var piso: PlacementRule = db.receta(&"piso_piedra")

	# con mundo plano + inventario lleno, el piso debe validar en (5,0,5)
	var mundo := MundoPlano.new()
	mundo.suelo = 0
	mgr.conectar_mundo(mundo)
	var inv := FakeInventario.new()
	inv.items = {"stone": 99, "planks": 99, "grass": 99, "glass": 99, "sand": 99, "clay": 99, "wood": 99, "crystal": 99}
	mgr.conectar_inventario(inv)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)

	var celda := Vector3i(5, 0, 5)
	var res: Dictionary = prev.evaluar_receta(mgr, piso, celda, 0)
	_ok(bool(res["ok"]) == true, "piso_piedra valida sobre terreno plano (texto: %s)" % String(res["texto"]))
	_ok(bool(res["cache"]) == false, "la primera evaluacion NO viene de cache")
	_ok(res["color"] == BuildPreview.COLOR_VALIDO, "color valido = verde")
	_ok((res["celdas"] as Array).size() == 1, "huella 1x1 = 1 celda")
	_ok(int(res["costo_total"]) == 3, "costo_total = 3 (dio %d)" % int(res["costo_total"]))
	_ok(BuildPreview.resumen(res) == "OK", "resumen() de un valido = 'OK'")

	# segunda evaluacion identica -> cache
	var res2: Dictionary = prev.evaluar_receta(mgr, piso, celda, 0)
	_ok(bool(res2["cache"]) == true, "la segunda evaluacion identica SI viene de cache")
	_ok(prev.recalculos() == 1, "solo 1 recalculo real (dio %d)" % prev.recalculos())

	# cambio de celda -> recalcula
	var res3: Dictionary = prev.evaluar_receta(mgr, piso, Vector3i(9, 0, 9), 0)
	_ok(bool(res3["cache"]) == false, "cambiar de celda invalida la cache")
	_ok(prev.recalculos() == 2, "2 recalculos tras cambiar de celda")

	# invalido: celda flotante (sin soporte) -> rojo y motivo
	var res4: Dictionary = prev.evaluar_receta(mgr, piso, Vector3i(5, 9, 5), 0)
	_ok(bool(res4["ok"]) == false, "piso en el aire NO valida")
	_ok(res4["color"] == BuildPreview.COLOR_INVALIDO, "color invalido = rojo")
	_ok(not (res4["motivos"] as Array).is_empty(), "el rechazo trae al menos un motivo")
	_ok(BuildPreview.resumen(res4) != "OK", "resumen() de un invalido NO dice 'OK'")

	# el preview NUNCA cobra ni escribe
	var antes: int = int(inv.items.get("stone", 0))
	prev.evaluar_receta(mgr, piso, Vector3i(1, 0, 1), 0)
	_ok(int(inv.items.get("stone", 0)) == antes, "el preview no descuenta recursos")
	_ok(mundo.escrituras == 0, "el preview no escribe voxeles (dio %d)" % mundo.escrituras)

	# el manager expone preview() con la receta seleccionada
	mgr.seleccionar_pieza(piso)
	var res5: Dictionary = mgr.preview(Vector3i(2, 0, 2))
	_ok(res5.has("color") and res5.has("celdas"), "mgr.preview() devuelve color y celdas")
	_ok(mgr.preview_actual() != null, "mgr.preview_actual() expone el evaluador")
	_fin("5")

## 6. BuildGhost: representacion, rotacion, LOD y pooling.
func _b6_ghost(mgr) -> void:
	_abrir("6", "BuildGhost: malla, color, rotacion, LOD y pooling")
	var db := BuildCatalogDB.new()
	db.cargar("res://data/construccion/piezas")
	var cama: PlacementRule = db.receta(&"cama")   # 1x2
	var ghost := BuildGhost.new()

	_ok(ghost.esta_visible() == false, "el fantasma arranca oculto")
	_ok(ghost.hijos_creados() == 0, "sin configurar, no creo nodos (perezoso)")

	var res: Dictionary = {
		"ok": true, "celda": Vector3i(3, 0, 3), "rotacion": 0,
		"receta_id": &"cama", "celdas": [Vector3i(3, 0, 3), Vector3i(3, 0, 4)],
	}
	ghost.aplicar_resultado(res, cama)
	_ok(ghost.esta_visible() == true, "tras aplicar, el fantasma esta visible")
	_ok(ghost.color_actual() == BuildPreview.COLOR_VALIDO, "color valido = verde")
	_ok(ghost.celdas_actuales().size() == 2, "refleja las 2 celdas de la cama")
	_ok(ghost.tamano_actual() == Vector3(1.0, 1.0, 2.0), "sin rotar: 1x2 (dio %s)" % str(ghost.tamano_actual()))
	_ok(ghost.hijos_creados() == 1, "creo exactamente 1 nodo hijo (mesh)")

	# rotacion 90 -> intercambia ancho/fondo
	res["rotacion"] = 1
	ghost.aplicar_resultado(res, cama)
	_ok(ghost.tamano_actual() == Vector3(2.0, 1.0, 1.0), "rotado 90: 2x1 (dio %s)" % str(ghost.tamano_actual()))
	_ok(ghost.hijos_creados() == 1, "POOLING: no creo un 2do nodo al reconfigurar")

	# invalido -> rojo
	res["ok"] = false
	ghost.aplicar_resultado(res, cama)
	_ok(ghost.color_actual() == BuildPreview.COLOR_INVALIDO, "invalido = rojo")

	# LOD
	_ok(ghost.aplicar_lod(10.0) == false and ghost.en_lod() == false, "a 10 m sin LOD")
	_ok(ghost.aplicar_lod(80.0) == true and ghost.en_lod() == true, "a 80 m con LOD")

	ghost.ocultar()
	_ok(ghost.esta_visible() == false and ghost.celdas_actuales().is_empty(),
		"ocultar() apaga y limpia celdas")
	_ok(ghost.hijos_creados() == 1, "ocultar() NO destruye la malla (pooling)")
	ghost.devolver_al_pool()
	_ok(ghost.esta_visible() == false, "devolver_al_pool() deja el fantasma oculto")
	ghost.free()
	_fin("6")

## 7. Integracion M64: la senal navmesh_delta se emite al cambiar el mundo.
func _b7_navmesh(mgr) -> void:
	_abrir("7", "M64: navmesh_delta al colocar/demoler/undo (bloque K)")
	var deltas: Array = []
	mgr.navmesh_delta.connect(func(celdas: Array) -> void: deltas.append(celdas.size()))

	var mundo := MundoPlano.new()
	mundo.suelo = 0
	mgr.conectar_mundo(mundo)
	var inv := FakeInventario.new()
	inv.items = {"stone": 99, "planks": 99, "grass": 99, "glass": 99, "sand": 99, "clay": 99, "wood": 99, "crystal": 99}
	mgr.conectar_inventario(inv)
	mgr.limpiar_estructuras()
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)

	var piso: PlacementRule = mgr.receta(&"piso_piedra")
	_ok(piso != null, "el autoload tiene piso_piedra en el catalogo")
	mgr.seleccionar_pieza(piso)
	var res: Dictionary = mgr.confirmar_colocacion(Vector3i(5, 0, 5))
	_ok(bool(res["ok"]) == true, "colocar piso_piedra con inventario: OK")
	_ok(deltas.size() == 1 and int(deltas[0]) == 1, "navmesh_delta emitido con 1 celda (deltas=%s)" % str(deltas))

	var dem: Dictionary = mgr.demolir_pieza(Vector3i(5, 0, 5))
	_ok(bool(dem["ok"]) == true, "demoler: OK")
	_ok(deltas.size() == 2, "navmesh_delta emitido tambien al demoler (deltas=%s)" % str(deltas))

	# rehacer via undo -> otra emision
	mgr.seleccionar_pieza(piso)
	mgr.confirmar_colocacion(Vector3i(6, 0, 6))
	var u: Dictionary = mgr.undo()
	_ok(bool(u["ok"]) == true, "undo: OK")
	_ok(deltas.size() == 4, "navmesh_delta emitido en colocar + undo (deltas=%s)" % str(deltas))
	_fin("7")

## 8. Colocacion real con el catalogo de 12 familias (piso -> pared -> techo).
func _b8_obra(mgr) -> void:
	_abrir("8", "Obra real: piso, paredes y techo desde el catalogo de 12 familias")
	var mundo := MundoPlano.new()
	mundo.suelo = 0
	mgr.conectar_mundo(mundo)
	var inv := FakeInventario.new()
	inv.items = {"stone": 999, "planks": 999, "grass": 999, "glass": 999}
	mgr.conectar_inventario(inv)
	mgr.limpiar_estructuras()
	mgr.set_rotacion(0)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)

	var piso: PlacementRule = mgr.receta(&"piso_piedra")
	var pared: PlacementRule = mgr.receta(&"pared_piedra")
	var techo: PlacementRule = mgr.receta(&"techo_losa")
	_ok(piso != null and pared != null and techo != null, "las 3 recetas de la obra existen")
	# El techo DEBE abarcar 2+ celdas: un techo 1x1 con soportes_minimos=2 seria
	# inconstruible (la huella no puede aportar 2 soportes). Regresion cubierta.
	_ok(techo.tamano == Vector2i(2, 2), "el techo cubre 2x2 (huella >= 2 celdas)")
	_ok(techo.soportes_minimos == 2, "el techo exige 2 soportes (regla de techos)")

	# 1) DOS losas de piso: cada una sera la base de una pared.
	mgr.seleccionar_pieza(piso)
	_ok(bool(mgr.confirmar_colocacion(Vector3i(10, 0, 10))["ok"]) == true, "piso 1 colocado")
	_ok(bool(mgr.confirmar_colocacion(Vector3i(11, 0, 10))["ok"]) == true, "piso 2 colocado")

	# 2) DOS paredes, cada una apoyada en SU losa (superficie_ofrecida = 'piso').
	mgr.seleccionar_pieza(pared)
	var rp: Dictionary = mgr.confirmar_colocacion(Vector3i(10, 1, 10))
	_ok(bool(rp["ok"]) == true, "pared 1 apoyada sobre el piso: OK (texto '%s')" % String(rp["texto"]))
	var rp2: Dictionary = mgr.confirmar_colocacion(Vector3i(11, 1, 10))
	_ok(bool(rp2["ok"]) == true, "pared 2 apoyada sobre el piso: OK (texto '%s')" % String(rp2["texto"]))

	# 3) el techo 2x2 sobre las 2 paredes: exactamente 2 soportes reales.
	mgr.seleccionar_pieza(techo)
	var rt: Dictionary = mgr.confirmar_colocacion(Vector3i(10, 2, 10))
	_ok(bool(rt["ok"]) == true, "techo 2x2 con 2 soportes: OK (texto '%s')" % String(rt["texto"]))
	_ok((rt["celdas"] as Array).size() == 4, "el techo ocupa 4 celdas (dio %d)" % (rt["celdas"] as Array).size())
	_ok(mgr.cantidad_estructuras() == 5,
		"hay 5 estructuras (2 pisos + 2 paredes + techo, dio %d)" % mgr.cantidad_estructuras())

	# el techo NO valida donde no hay 2 soportes
	var rt2: Dictionary = mgr.confirmar_colocacion(Vector3i(30, 2, 30))
	_ok(bool(rt2["ok"]) == false, "techo sin soportes NO valida")
	_ok((rt2["motivos"] as Array).has(ConstruccionTipos.Motivo.SIN_SOPORTE),
		"el rechazo del techo es SIN_SOPORTE")

	# un puente NO valida sobre terreno (solo agua)
	mgr.seleccionar_pieza(mgr.receta(&"puente_2"))
	var rb: Dictionary = mgr.confirmar_colocacion(Vector3i(20, 0, 20))
	_ok(bool(rb["ok"]) == false, "puente sobre terreno NO valida")
	_fin("8")

## 9. M18/M60: catalogo por modo (interiores) y round-trip de persistencia.
func _b9_m18_persistencia(mgr) -> void:
	_abrir("9", "M18/M60: filtrado por modo y round-trip de persistencia")
	# (a) el modo decoracion (interiores de M18) ve SOLO muebles/decoracion.
	var deco: Array = mgr.piezas_de_modo(ConstruccionTipos.Modo.DECORACION)
	var constr: Array = mgr.piezas_de_modo(ConstruccionTipos.Modo.CONSTRUCCION)
	_ok(deco.size() == 11, "modo DECORACION ve 11 muebles (dio %d)" % deco.size())
	_ok(constr.size() == 22, "modo CONSTRUCCION ve 22 piezas (dio %d)" % constr.size())
	var todos_mueble: bool = true
	for r in deco:
		if not (r as PlacementRule).es_mueble:
			todos_mueble = false
	_ok(todos_mueble, "todo lo del modo decoracion es es_mueble")
	var ningun_mueble: bool = true
	for r in constr:
		if (r as PlacementRule).es_mueble:
			ningun_mueble = false
	_ok(ningun_mueble, "nada del modo construccion es mueble")

	# (b) round-trip de persistencia con el catalogo de 12 familias (M60/M59),
	#     incluida una pieza de huella MULTI-celda (techo 2x2).
	var mundo := MundoPlano.new()
	mundo.suelo = 0
	mgr.conectar_mundo(mundo)
	var inv := FakeInventario.new()
	inv.items = {"stone": 999, "planks": 999}
	mgr.conectar_inventario(inv)
	mgr.limpiar_estructuras()
	mgr.set_rotacion(0)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)

	mgr.seleccionar_pieza(mgr.receta(&"piso_piedra"))
	mgr.confirmar_colocacion(Vector3i(40, 0, 40))
	mgr.confirmar_colocacion(Vector3i(41, 0, 40))
	mgr.seleccionar_pieza(mgr.receta(&"pared_piedra"))
	mgr.confirmar_colocacion(Vector3i(40, 1, 40))
	mgr.confirmar_colocacion(Vector3i(41, 1, 40))
	mgr.seleccionar_pieza(mgr.receta(&"techo_losa"))
	_ok(bool(mgr.confirmar_colocacion(Vector3i(40, 2, 40))["ok"]) == true,
		"la mini-obra cierra con el techo 2x2")
	_ok(mgr.cantidad_estructuras() == 5,
		"5 estructuras antes de serializar (dio %d)" % mgr.cantidad_estructuras())

	var guardado: Array = mgr.obtener_estructuras()
	_ok(guardado.size() == 5, "obtener_estructuras() devuelve 5")
	var claves_ok: bool = true
	for e in guardado:
		for k in ["id", "tipo", "pos", "rot_y", "planta", "variante"]:
			if not (e as Dictionary).has(k):
				claves_ok = false
	_ok(claves_ok, "cada estructura trae las 6 claves canonicas de M60")

	# restaurar es IDEMPOTENTE (limpia y reconstruye) — 03-Diseno §6.
	mgr.restaurar_estructuras(guardado)
	_ok(mgr.cantidad_estructuras() == 5,
		"restaurar deja 5 (idempotente, dio %d)" % mgr.cantidad_estructuras())
	mgr.restaurar_estructuras(guardado)
	_ok(mgr.cantidad_estructuras() == 5,
		"restaurar 2 veces NO duplica (dio %d)" % mgr.cantidad_estructuras())
	# la huella 2x2 del techo se restauro completa (ancla + esquina opuesta).
	_ok(not mgr.pieza_en_celda(Vector3i(40, 2, 40)).is_empty()
			and not mgr.pieza_en_celda(Vector3i(41, 2, 41)).is_empty(),
		"la huella 2x2 del techo se restauro completa (4 celdas)")
	mgr.limpiar_estructuras()
	_fin("9")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	_b1_catalogo_db()
	_b2_familia()
	_b3_integridad()
	_b4_carga_recursiva()

	var mgr = root.get_node_or_null("/root/Construccion")
	_ok(mgr != null, "autoload Construccion presente en /root")
	if mgr == null:
		return
	_b5_preview(mgr)
	_b6_ghost(mgr)
	_b7_navmesh(mgr)
	_b8_obra(mgr)
	_b9_m18_persistencia(mgr)

	# deja el autoload limpio (no contamina otras suites del mismo proceso)
	mgr.limpiar_estructuras()
	mgr.salir_modo()
	mgr.conectar_inventario(null)

func _summary() -> void:
	print("=== RESUMEN M17 CONSTRUCCION iter.2: %d checks, %d fallos, %d bloques cerrados ===" % [
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
