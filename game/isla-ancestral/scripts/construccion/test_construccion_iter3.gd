# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-04
#
# M17 Construccion iter. 3 — suite del HUD del modo (BuildHudModel), MESH REAL de
# la receta en el fantasma, FOLLOW con lerp, AUTO-OCULTADO fuera de zona,
# permisos finos M18/M25 (ZonasPermisos) y STRESS M112 (200+ piezas).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter3.gd
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

## Piso de checks. MEDIDO en la primera corrida VERDE (138) y fijado aqui.
const CHECKS_MINIMOS: int = 138

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

## true si el arbol de `nodo` NO contiene ninguna forma de colision.
func _sin_colision(nodo: Node) -> bool:
	if nodo is CollisionObject3D:
		return false
	for h in nodo.get_children():
		if not _sin_colision(h):
			return false
	return true

# ── bloques ──────────────────────────────────────────────────────────────

## 1. BuildHudModel: filas y texto de COSTO.
func _b1_hud_costo() -> void:
	_abrir("1", "BuildHudModel: filas de costo y texto legible")
	var r := PlacementRule.desde_dict({
		"id": "t", "nombre": "Torre", "costo": {"stone": 3, "planks": 1},
	})
	var filas: Array = BuildHudModel.filas_costo(r)
	_ok(filas.size() == 2, "2 filas de costo (dio %d)" % filas.size())
	var f0: Dictionary = filas[0]
	var f1: Dictionary = filas[1]
	_ok(String(f0["item_id"]) == "planks", "las filas van ORDENADAS por item_id (1a: %s)" % String(f0["item_id"]))
	_ok(String(f0["texto"]) == "tablones x1", "nombre legible de planks (dio '%s')" % String(f0["texto"]))
	_ok(String(f1["texto"]) == "piedra x3", "nombre legible de stone (dio '%s')" % String(f1["texto"]))
	_ok(BuildHudModel.texto_costo(r) == "tablones x1, piedra x3",
		"texto_costo une todo (dio '%s')" % BuildHudModel.texto_costo(r))
	_ok(BuildHudModel.costo_total(r) == 4, "costo_total = 4 (dio %d)" % BuildHudModel.costo_total(r))

	var gratis := PlacementRule.desde_dict({"id": "g", "costo": {}})
	_ok(BuildHudModel.texto_costo(gratis) == BuildHudModel.TEXTO_GRATIS, "sin costo -> 'gratis'")
	_ok(BuildHudModel.costo_total(gratis) == 0, "costo_total de gratis = 0")
	_ok(BuildHudModel.filas_costo(null).is_empty(), "receta null -> sin filas")
	_ok(BuildHudModel.nombre_item("stone") == "piedra", "nombre_item traduce stone")
	_ok(BuildHudModel.nombre_item("item_raro") == "item_raro", "nombre_item NO inventa: usa el id")
	_ok(BuildHudModel.nombre_pieza(r) == "Torre", "nombre_pieza usa el nombre")
	var sin_nombre := PlacementRule.desde_dict({"id": "zz"})
	_ok(BuildHudModel.nombre_pieza(sin_nombre) == "zz", "sin nombre -> cae al id")
	_fin("1")

## 2. BuildHudModel: motivos, linea de estado y resumen.
func _b2_hud_motivos() -> void:
	_abrir("2", "BuildHudModel: motivos traducidos y linea de estado")
	var r := PlacementRule.desde_dict({"id": "t", "nombre": "Torre", "costo": {"stone": 3}})
	var ok := ConstruccionTipos.resultado_ok([Vector3i.ZERO])
	_ok(BuildHudModel.puede_confirmar(ok) == true, "un resultado ok se puede confirmar")
	_ok(BuildHudModel.filas_motivos(ok).is_empty(), "un resultado ok no trae motivos")
	_ok(BuildHudModel.texto_motivos(ok) == "", "texto_motivos de un ok = vacio")
	var linea_ok: String = BuildHudModel.linea_estado(ok, r)
	_ok(linea_ok.begins_with("OK") and linea_ok.contains("piedra x3"),
		"linea_estado ok nombra el costo (dio '%s')" % linea_ok)

	var malo := ConstruccionTipos.resultado_fallo(
		[ConstruccionTipos.Motivo.SIN_SOPORTE], ["detalle"])
	_ok(BuildHudModel.puede_confirmar(malo) == false, "un rechazo NO se puede confirmar")
	var fm: Array = BuildHudModel.filas_motivos(malo)
	_ok(fm.size() == 1, "1 fila de motivo (dio %d)" % fm.size())
	var fm0: Dictionary = fm[0]
	_ok(int(fm0["motivo"]) == ConstruccionTipos.Motivo.SIN_SOPORTE, "la fila lleva el motivo real")
	_ok(String(fm0["texto"]) == "sin soporte debajo", "el motivo va TRADUCIDO (dio '%s')" % String(fm0["texto"]))
	var linea_mal: String = BuildHudModel.linea_estado(malo, r)
	_ok(linea_mal.begins_with("RECHAZADO") and linea_mal.contains("sin soporte debajo"),
		"linea_estado de rechazo explica el motivo (dio '%s')" % linea_mal)

	var doble := ConstruccionTipos.resultado_fallo(
		[ConstruccionTipos.Motivo.SIN_SOPORTE, ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES])
	_ok(BuildHudModel.texto_motivos(doble) == "sin soporte debajo | recursos insuficientes",
		"texto_motivos une TODOS los motivos (dio '%s')" % BuildHudModel.texto_motivos(doble))

	# los 5 motivos que el HUD debe saber traducir (zona, soporte, ocupado, NPC, recursos)
	for par in [[ConstruccionTipos.Motivo.ZONA_PROTEGIDA, "zona protegida (no se puede construir)"],
			[ConstruccionTipos.Motivo.SIN_SOPORTE, "sin soporte debajo"],
			[ConstruccionTipos.Motivo.CELDA_OCUPADA, "celda ocupada por otra pieza"],
			[ConstruccionTipos.Motivo.NPC_EN_CELDA, "hay un vecino en el lugar"],
			[ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES, "recursos insuficientes"]]:
		var rr := ConstruccionTipos.resultado_fallo([int(par[0])])
		var ff: Array = BuildHudModel.filas_motivos(rr)
		var txt: String = String((ff[0] as Dictionary)["texto"]) if ff.size() == 1 else "<sin fila>"
		_ok(ff.size() == 1 and txt == String(par[1]),
			"HUD traduce el motivo %d -> '%s'" % [int(par[0]), txt])

	var res: Dictionary = BuildHudModel.resumen(malo, r)
	_ok(res["ok"] == false, "resumen.ok = false")
	_ok(String(res["nombre"]) == "Torre", "resumen.nombre")
	_ok((res["costo"] as Array).size() == 1, "resumen.costo con 1 fila")
	_ok(res["color"] == BuildPreview.COLOR_INVALIDO, "resumen.color rojo en rechazo")
	_ok((res["motivos"] as Array).size() == 1, "resumen.motivos con 1 fila")
	_fin("2")

## 3. PlacementRule.mesh_path: round-trip y catalogo real con mallas.
func _b3_mesh_path() -> void:
	_abrir("3", "PlacementRule.mesh_path: round-trip y catalogo real")
	var r := PlacementRule.desde_dict({"id": "x", "mesh_path": "res://a/b.glb"})
	_ok(r.mesh_path == "res://a/b.glb", "desde_dict lee mesh_path")
	var d: Dictionary = r.a_dict()
	_ok(String(d["mesh_path"]) == "res://a/b.glb", "a_dict escribe mesh_path")
	var r2 := PlacementRule.new()
	_ok(r2.mesh_path == "", "mesh_path por defecto = vacio (compatibilidad iter. 2)")

	var db := BuildCatalogDB.new()
	db.cargar("res://data/construccion/piezas")
	var con_malla: int = 0
	var rutas_ok: bool = true
	for id in db.ids():
		var rec: PlacementRule = db.receta(id)
		if rec.mesh_path != "":
			con_malla += 1
			if not rec.mesh_path.begins_with("res://assets/3d/") or not rec.mesh_path.ends_with(".glb"):
				rutas_ok = false
	_ok(con_malla >= 25, "el catalogo real declara malla en >= 25 recetas (dio %d)" % con_malla)
	_ok(rutas_ok, "toda mesh_path declarada es res://assets/3d/...glb")

	var pared: PlacementRule = db.receta(&"pared_madera")
	_ok(pared.mesh_path == "res://assets/3d/alta/18-Casas_pared_madera.glb",
		"pared_madera apunta a su malla real (dio '%s')" % pared.mesh_path)
	_ok(FileAccess.file_exists(pared.mesh_path), "la malla declarada EXISTE en el repo")
	var cerca: PlacementRule = db.receta(&"cerca_madera")
	_ok(cerca.mesh_path == "", "cerca_madera (sin asset) declara mesh_path vacio")
	_fin("3")

## 4. BuildGhost: malla real, resolucion por ruta y fallback a la caja.
func _b4_ghost_malla() -> void:
	_abrir("4", "BuildGhost: malla real, resolver y fallback a la caja")
	var ghost := BuildGhost.new()
	_ok(ghost.usando_malla_real() == false, "sin configurar, NO usa malla real")
	_ok(ghost.hijos_creados() == 0, "sin configurar, no creo nodos (perezoso)")

	# (a) malla inyectada directamente (determinista, sin importador)
	var box := BoxMesh.new()
	_ok(ghost.cargar_malla(box) == true, "cargar_malla(box) devuelve true")
	_ok(ghost.usando_malla_real() == true, "tras cargar_malla, usa malla real")
	_ok(ghost.malla_actual() == box, "malla_actual() es la malla inyectada")
	_ok(ghost.hijos_creados() == 1, "creo exactamente 1 nodo hijo (mesh)")
	_ok(ghost.cargar_malla(null) == false, "cargar_malla(null) vuelve a la caja")
	_ok(ghost.usando_malla_real() == false, "tras null, NO usa malla real")

	# (b) resolucion por ruta: vacia y rota -> null (tolerante)
	_ok(ghost.malla_desde_ruta("") == null, "ruta vacia -> null")
	_ok(ghost.malla_desde_ruta("res://no/existe_zzz.glb") == null, "ruta inexistente -> null")

	# (c) la RECETA dirige la malla (registro precargado -> determinista)
	var box2 := BoxMesh.new()
	ghost.registrar_malla("res://test/malla.glb", box2)
	var r := PlacementRule.desde_dict({"id": "t", "tamano": [1, 1], "mesh_path": "res://test/malla.glb"})
	var res: Dictionary = {
		"ok": true, "celda": Vector3i(2, 0, 2), "rotacion": 0,
		"receta_id": &"t", "celdas": [Vector3i(2, 0, 2)],
	}
	ghost.aplicar_resultado(res, r)
	_ok(ghost.usando_malla_real() == true, "la receta con mesh_path hace usar la malla real")
	_ok(ghost.malla_actual() == box2, "usa la malla registrada para esa ruta")

	# (d) receta SIN mesh_path -> caja de respaldo
	var r_sin := PlacementRule.desde_dict({"id": "s", "tamano": [1, 2]})
	ghost.aplicar_resultado(res, r_sin)
	_ok(ghost.usando_malla_real() == false, "receta sin mesh_path -> caja de respaldo")
	_ok(ghost.malla_actual() is BoxMesh, "la malla mostrada es una BoxMesh")
	_ok(ghost.tamano_actual() == Vector3(1.0, 1.0, 2.0), "la caja conserva la huella 1x2")
	_ok(_sin_colision(ghost), "el fantasma NO tiene formas de colision (nunca colisiona con el mundo)")

	# (e) asset REAL: si el importador lo tiene, resuelve una malla de verdad
	var ruta_real := "res://assets/3d/alta/18-Casas_pared_madera.glb"
	_ok(FileAccess.file_exists(ruta_real), "el asset real existe en disco")
	if ResourceLoader.exists(ruta_real):
		var m: Mesh = ghost.malla_desde_ruta(ruta_real)
		_ok(m != null and m is Mesh, "el asset real importado resuelve una Mesh")
	ghost.free()
	_fin("4")

## 5. BuildGhost: follow con lerp.
func _b5_ghost_follow() -> void:
	_abrir("5", "BuildGhost: follow con lerp (sin sobrepasar)")
	var ghost := BuildGhost.new()
	var obj := Vector3(10.0, 0.0, 0.0)

	# paso pequeno: avanza pero NO llega ni sobrepasa
	ghost.position = Vector3.ZERO
	var p1: Vector3 = ghost.seguir(obj, 0.016, 12.0)
	_ok(p1.x > 0.0 and p1.x < 10.0, "con delta pequeno avanza sin sobrepasar (x=%.3f)" % p1.x)
	_ok(ghost.asentado(obj) == false, "todavia no esta asentado")

	# delta grande: factor acotado a 1 -> llega exacto
	ghost.seguir(obj, 10.0, 12.0)
	_ok(ghost.asentado(obj) == true, "con delta grande se asienta en el objetivo")
	_ok(ghost.position.x <= 10.0001, "NUNCA sobrepasa el objetivo (x=%.4f)" % ghost.position.x)

	# convergencia iterativa
	ghost.position = Vector3.ZERO
	var pasos: int = 0
	while not ghost.asentado(obj, 0.05) and pasos < 2000:
		ghost.seguir(obj, 0.016, 12.0)
		pasos += 1
	_ok(pasos < 2000, "converge en menos de 2000 pasos (dio %d)" % pasos)
	_ok(ghost.distancia_a(obj) <= 0.05, "queda a <= 0.05 m del objetivo")

	# destino_de = centro de la huella (con rotacion)
	var r := PlacementRule.desde_dict({"id": "t", "tamano": [2, 1], "altura": 2.0})
	_ok(BuildGhost.destino_de(Vector3i(0, 0, 0), r, 0) == Vector3(1.0, 1.0, 0.5),
		"destino_de = centro de la huella 2x1 (dio %s)" % str(BuildGhost.destino_de(Vector3i(0, 0, 0), r, 0)))
	_ok(BuildGhost.destino_de(Vector3i(0, 0, 0), r, 1) == Vector3(0.5, 1.0, 1.0),
		"rotado 90 intercambia ancho/fondo (dio %s)" % str(BuildGhost.destino_de(Vector3i(0, 0, 0), r, 1)))

	# seguir_celda
	ghost.position = Vector3.ZERO
	ghost.seguir_celda(Vector3i(0, 0, 0), r, 10.0, 0)
	_ok(ghost.asentado(BuildGhost.destino_de(Vector3i(0, 0, 0), r, 0)), "seguir_celda llega al destino")

	# refleja la ELEVACION: la celda.y sube el fantasma una planta
	var r1 := PlacementRule.desde_dict({"id": "e", "tamano": [1, 1], "altura": 1.0})
	ghost.aplicar_resultado({"ok": true, "celda": Vector3i(0, 2, 0), "rotacion": 0,
		"receta_id": &"e", "celdas": [Vector3i(0, 2, 0)]}, r1)
	_ok(is_equal_approx(ghost.position.y, 2.5),
		"refleja la elevacion: y = celda.y + altura/2 (dio %.3f)" % ghost.position.y)
	ghost.free()
	_fin("5")

## 6. BuildGhost: auto-ocultado fuera de zona.
func _b6_ghost_ocultar() -> void:
	_abrir("6", "BuildGhost: auto-ocultado cuando el rechazo es de zona")
	var ok := ConstruccionTipos.resultado_ok()
	_ok(BuildGhost.debe_ocultarse(ok) == false, "un ok NO se oculta")
	var fuera := ConstruccionTipos.resultado_fallo([ConstruccionTipos.Motivo.FUERA_DE_ZONA])
	_ok(BuildGhost.debe_ocultarse(fuera) == true, "FUERA_DE_ZONA se oculta")
	for m in [ConstruccionTipos.Motivo.ZONA_PROTEGIDA, ConstruccionTipos.Motivo.ZONA_NARRATIVA,
			ConstruccionTipos.Motivo.AGUA_NO_PERMITIDA]:
		_ok(BuildGhost.debe_ocultarse(ConstruccionTipos.resultado_fallo([m])) == true,
			"motivo de zona %d se oculta" % m)
	var soporte := ConstruccionTipos.resultado_fallo([ConstruccionTipos.Motivo.SIN_SOPORTE])
	_ok(BuildGhost.debe_ocultarse(soporte) == false, "un rechazo NO de zona NO se oculta (rojo visible)")
	var recursos := ConstruccionTipos.resultado_fallo([ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES])
	_ok(BuildGhost.debe_ocultarse(recursos) == false,
		"recursos insuficientes -> fantasma rojo VISIBLE (no se oculta)")

	var ghost := BuildGhost.new()
	_ok(ghost.actualizar_visibilidad(ok) == true and ghost.esta_visible(), "ok -> visible")
	_ok(ghost.actualizar_visibilidad(fuera) == false and ghost.esta_visible() == false,
		"fuera de zona -> oculto")
	_ok(ghost.actualizar_visibilidad(soporte) == true and ghost.esta_visible(),
		"rechazo de soporte -> visible (rojo)")
	_ok(ghost.actualizar_visibilidad(ok, false) == false and ghost.esta_visible() == false,
		"sin terreno -> oculto")
	_ok(ghost.hijos_creados() == 1, "ocultar/mostrar no crea nodos (pooling)")
	ghost.free()
	_fin("6")

## 7. ZonasPermisos: politica M18/M25.
func _b7_zonas_permisos() -> void:
	_abrir("7", "ZonasPermisos: presets M18/M25 y traduccion a motivo")
	_ok(ZonasPermisos.CASA_JUGADOR == ConstruccionTipos.Permiso.EDIFICABLE, "casa del jugador -> EDIFICABLE")
	_ok(ZonasPermisos.PARCELA_NPC == ConstruccionTipos.Permiso.PROTEGIDA, "parcela NPC -> PROTEGIDA")
	_ok(ZonasPermisos.RUINA == ConstruccionTipos.Permiso.PROTEGIDA, "ruina M25 -> PROTEGIDA")
	_ok(ZonasPermisos.NARRATIVA == ConstruccionTipos.Permiso.NARRATIVA, "narrativa -> NARRATIVA")
	_ok(ZonasPermisos.AGUA == ConstruccionTipos.Permiso.AGUA, "agua -> AGUA")
	_ok(ConstruccionValidator.ORDEN.size() > 0 and String(ConstruccionValidator.ORDEN[0]) == "zona",
		"la zona se evalua ANTES que el soporte (ORDEN[0]='zona')")

	var reg := ZoneRegistry.new()
	_ok(ZonasPermisos.registrar(reg, ZonasPermisos.CASA_JUGADOR, AABB(Vector3(0, 0, 0), Vector3(4, 2, 4))) == true,
		"registra la parcela de la casa")
	_ok(ZonasPermisos.registrar(reg, ZonasPermisos.PARCELA_NPC, AABB(Vector3(10, 0, 0), Vector3(3, 2, 3))) == true,
		"registra la parcela NPC")
	_ok(ZonasPermisos.registrar(reg, ZonasPermisos.RUINA, AABB(Vector3(20, 0, 0), Vector3(5, 3, 5))) == true,
		"registra la ruina M25")
	_ok(reg.cantidad() == 3, "3 zonas registradas (dio %d)" % reg.cantidad())
	_ok(ZonasPermisos.edificable(reg, Vector3i(1, 0, 1)) == true, "dentro de la casa: edificable")
	_ok(ZonasPermisos.edificable(reg, Vector3i(11, 0, 1)) == false, "dentro de la parcela NPC: NO edificable")
	_ok(ZonasPermisos.motivo_de(reg, Vector3i(11, 0, 1)) == ConstruccionTipos.Motivo.ZONA_PROTEGIDA,
		"parcela NPC -> motivo ZONA_PROTEGIDA")
	_ok(ZonasPermisos.motivo_de(reg, Vector3i(21, 0, 1)) == ConstruccionTipos.Motivo.ZONA_PROTEGIDA,
		"ruina M25 -> motivo ZONA_PROTEGIDA")
	_ok(ZonasPermisos.motivo_de(reg, Vector3i(1, 0, 1)) == ConstruccionTipos.Motivo.OK, "casa -> motivo OK")
	_ok(ZonasPermisos.explicar(reg, Vector3i(11, 0, 1)) == "zona protegida (no se puede construir)",
		"explicar() traduce el permiso")
	_ok(ZonasPermisos.nombre_permiso(ZonasPermisos.RUINA) == "protegida", "nombre_permiso de ruina")
	_ok(ZonasPermisos.motivo_de_permiso(ConstruccionTipos.Permiso.AGUA) == ConstruccionTipos.Motivo.AGUA_NO_PERMITIDA,
		"permiso AGUA -> motivo AGUA_NO_PERMITIDA")

	# registro data-driven por ORIGEN
	var reg2 := ZoneRegistry.new()
	var n: int = ZonasPermisos.registrar_lista(reg2, [
		{"aabb": [0, 0, 0, 4, 1, 4], "origen": "casa_jugador"},
		{"aabb": [10, 0, 0, 3, 1, 3], "permiso": "parcela_npc"},
		{"aabb": [20, 0, 0, 5, 1, 5], "origen": "ruina"},
		{"aabb": AABB(Vector3(30, 0, 0), Vector3(2, 1, 2)), "origen": "narrativa"},
		{"aabb": [0, 0, 0, 0, 0, 0], "origen": "ruina"},
	])
	_ok(n == 4, "registrar_lista registra 4 (la degenerada se ignora, dio %d)" % n)
	_ok(reg2.cantidad() == 4, "el registro data-driven tiene 4 zonas")
	_ok(ZonasPermisos.motivo_de(reg2, Vector3i(31, 0, 1)) == ConstruccionTipos.Motivo.ZONA_NARRATIVA,
		"zona narrativa -> motivo ZONA_NARRATIVA")

	# default SEGURO: origen desconocido -> protegida
	var reg3 := ZoneRegistry.new()
	ZonasPermisos.registrar_lista(reg3, [{"aabb": [0, 0, 0, 2, 1, 2], "origen": "misterio"}])
	_ok(ZonasPermisos.edificable(reg3, Vector3i(1, 0, 1)) == false,
		"origen desconocido -> PROTEGIDA (default seguro)")
	_ok(ZonasPermisos.resumen(reg).contains("3 zonas"), "resumen() nombra la cantidad (dio '%s')" % ZonasPermisos.resumen(reg))
	_fin("7")

## 8. Stress M112: 200+ piezas reales, consistencia y undo/redo masivo.
func _b8_stress(mgr) -> void:
	_abrir("8", "Stress M112: 200+ piezas, consistencia de ocupacion y undo masivo")
	var mundo := MundoPlano.new()
	mundo.suelo = 0
	mgr.conectar_mundo(mundo)
	var inv := FakeInventario.new()
	inv.items = {"stone": 999999, "planks": 999999}
	mgr.conectar_inventario(inv)
	mgr.limpiar_estructuras()
	mgr.set_rotacion(0)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)

	var piso: PlacementRule = mgr.receta(&"piso_piedra")
	var pared: PlacementRule = mgr.receta(&"pared_piedra")
	var techo: PlacementRule = mgr.receta(&"techo_losa")
	_ok(piso != null and pared != null and techo != null, "las 3 recetas del stress existen")

	var t0: int = Time.get_ticks_msec()
	# 225 pisos (15x15) en y=0
	mgr.seleccionar_pieza(piso)
	var pisos: int = 0
	for x in range(15):
		for z in range(15):
			if bool(mgr.confirmar_colocacion(Vector3i(x, 0, z))["ok"]):
				pisos += 1
	_ok(pisos == 225, "se colocaron 225 pisos (dio %d)" % pisos)

	# 25 paredes (5x5) en y=1
	mgr.seleccionar_pieza(pared)
	var paredes: int = 0
	for x in range(5):
		for z in range(5):
			if bool(mgr.confirmar_colocacion(Vector3i(x, 1, z))["ok"]):
				paredes += 1
	_ok(paredes == 25, "se colocaron 25 paredes (dio %d)" % paredes)

	# 1 techo 2x2 sobre 4 paredes
	mgr.seleccionar_pieza(techo)
	var rt: Dictionary = mgr.confirmar_colocacion(Vector3i(0, 2, 0))
	_ok(bool(rt["ok"]) == true, "el techo 2x2 cierra sobre 4 paredes (texto '%s')" % String(rt["texto"]))
	_ok((rt["celdas"] as Array).size() == 4, "el techo ocupa 4 celdas")
	var ms: int = Time.get_ticks_msec() - t0

	var total: int = mgr.cantidad_estructuras()
	_ok(total == 251, "251 estructuras en total (225+25+1, dio %d)" % total)
	print("  [info] stress: %d piezas colocadas en %d ms" % [total, ms])

	# consistencia de ocupacion: cada celda de cada estructura esta ocupada
	var celdas_totales: int = 0
	var celdas_ok: bool = true
	for e in mgr.obtener_estructuras():
		var tipo := StringName(String(e["tipo"]))
		var pos: Array = e["pos"]
		var celda := Vector3i(int(pos[0]), int(pos[1]), int(pos[2]))
		var rec: PlacementRule = mgr.receta(tipo)
		var paso: int = posmod(int(round(float(int(e["rot_y"])) / 90.0)), 4)
		for c in rec.celdas(celda, paso):
			celdas_totales += 1
			if mgr.pieza_en_celda(c).is_empty():
				celdas_ok = false
	_ok(celdas_ok, "toda celda de toda estructura queda OCUPADA (sin huecos)")
	_ok(celdas_totales == 254, "254 celdas ocupadas (225+25+4, dio %d)" % celdas_totales)
	_ok(mundo.escrituras == 254, "se escribieron 254 voxeles (dio %d)" % mundo.escrituras)

	# cache de preview tras el stress
	mgr.seleccionar_pieza(piso)
	var p1: Dictionary = mgr.preview(Vector3i(100, 0, 100))
	var p2: Dictionary = mgr.preview(Vector3i(100, 0, 100))
	_ok(bool(p1["ok"]) == true, "preview valida en una celda libre lejos del stress")
	_ok(bool(p2["cache"]) == true, "la 2a preview identica viene de cache")
	_ok(mgr.preview_actual().recalculos() == 1, "1 solo recalculo real tras el stress")

	# undo MASIVO: el tope de la pila es 200
	var n_undo: int = 0
	while mgr.historial().puede_undo():
		mgr.undo()
		n_undo += 1
	_ok(n_undo == 200, "el undo masivo respeta el tope de 200 (dio %d)" % n_undo)
	_ok(mgr.cantidad_estructuras() == 51, "quedan 51 tras 200 undos (dio %d)" % mgr.cantidad_estructuras())

	# redo MASIVO: vuelve al estado completo
	var n_redo: int = 0
	while mgr.historial().puede_redo():
		mgr.redo()
		n_redo += 1
	_ok(n_redo == 200, "el redo masivo restaura 200 (dio %d)" % n_redo)
	_ok(mgr.cantidad_estructuras() == 251, "vuelve a 251 tras el redo (dio %d)" % mgr.cantidad_estructuras())

	# presupuesto GENEROSO (solo caza un patologico O(n^2); no es un benchmark)
	_ok(ms < 10000, "el stress completo tardo < 10 s (dio %d ms)" % ms)
	mgr.limpiar_estructuras()
	_fin("8")

## 9. End-to-end: preview -> HUD -> fantasma, con zona protegida.
func _b9_end_to_end(mgr) -> void:
	_abrir("9", "End-to-end: preview -> HUD -> fantasma (valido y en zona protegida)")
	var mundo := MundoPlano.new()
	mundo.suelo = 0
	mgr.conectar_mundo(mundo)
	var inv := FakeInventario.new()
	inv.items = {"stone": 99, "planks": 99}
	mgr.conectar_inventario(inv)
	mgr.limpiar_estructuras()
	mgr.zonas().limpiar()
	mgr.set_rotacion(0)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)

	var piso: PlacementRule = mgr.receta(&"piso_piedra")
	mgr.seleccionar_pieza(piso)
	var res: Dictionary = mgr.preview(Vector3i(3, 0, 3))
	_ok(bool(res["ok"]) == true, "preview valida en celda libre")

	var hud: Dictionary = BuildHudModel.resumen(res, piso)
	_ok(hud["ok"] == true, "HUD: se puede confirmar")
	_ok(String(hud["linea"]).begins_with("OK"), "HUD: linea de estado OK")
	_ok(String(hud["costo_texto"]) == "piedra x3", "HUD: costo legible (dio '%s')" % String(hud["costo_texto"]))
	_ok(hud["color"] == BuildPreview.COLOR_VALIDO, "HUD: color verde")

	var ghost := BuildGhost.new()
	ghost.aplicar_resultado(res, piso)
	_ok(ghost.esta_visible() == true, "fantasma visible en celda valida")
	_ok(ghost.celdas_actuales().size() == 1, "el fantasma refleja 1 celda")
	_ok(ghost.color_actual() == BuildPreview.COLOR_VALIDO, "fantasma verde")
	_ok(piso.mesh_path != "", "piso_piedra declara una malla real")
	if ResourceLoader.exists(piso.mesh_path):
		_ok(ghost.usando_malla_real() == true, "el fantasma usa la MALLA REAL de la receta")
	_ok(ghost.actualizar_visibilidad(res) == true, "actualizar_visibilidad deja el fantasma visible")

	# zona protegida (M18/M25) -> motivo en el HUD y fantasma oculto
	mgr.registrar_zona(AABB(Vector3(50, 0, 50), Vector3(4, 4, 4)), ConstruccionTipos.Permiso.PROTEGIDA)
	var res2: Dictionary = mgr.preview(Vector3i(51, 0, 51))
	_ok(bool(res2["ok"]) == false, "preview rechaza la celda en zona protegida")
	var hud2: Dictionary = BuildHudModel.resumen(res2, piso)
	_ok(String(hud2["linea"]).begins_with("RECHAZADO"), "HUD: linea de estado RECHAZADO")
	_ok((hud2["motivos"] as Array).size() >= 1, "HUD: hay al menos un motivo")
	_ok(ZonasPermisos.motivo_de(mgr.zonas(), Vector3i(51, 0, 51)) == ConstruccionTipos.Motivo.ZONA_PROTEGIDA,
		"ZonasPermisos explica la zona protegida")
	_ok(ghost.actualizar_visibilidad(res2) == false and ghost.esta_visible() == false,
		"el fantasma se OCULTA en zona protegida")

	ghost.free()
	mgr.zonas().limpiar()
	mgr.limpiar_estructuras()
	mgr.conectar_inventario(null)
	mgr.salir_modo()
	_fin("9")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	_b1_hud_costo()
	_b2_hud_motivos()
	_b3_mesh_path()
	_b4_ghost_malla()
	_b5_ghost_follow()
	_b6_ghost_ocultar()
	_b7_zonas_permisos()

	var mgr = root.get_node_or_null("/root/Construccion")
	_ok(mgr != null, "autoload Construccion presente en /root")
	if mgr == null:
		return
	_b8_stress(mgr)
	_b9_end_to_end(mgr)

func _summary() -> void:
	print("=== RESUMEN M17 CONSTRUCCION iter.3: %d checks, %d fallos, %d bloques cerrados ===" % [
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
