extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — ATOMICIDAD de la escritura en el mundo.
#
# POR QUE EXISTE: al auditar M17 (P8) aparecio un DEFECTO de la misma clase
# que el de L102: una operacion que REPORTA EXITO sin hacer el trabajo.
# Concretamente, `confirmar_colocacion()` hacia:
#     var escritos := mundo.escribir_voxel(celdas, bloque)   # puede ser 0
#     _alta_estructura(...)                                 # se registra igual
#     return { "ok": true, ... }                             # y dice "ok"
# Si el mundo tiene terreno pero la escritura falla (0 voxels), la pieza
# quedaba REGISTRADA en la logica de M17 sin existir en el mundo: el jugador
# no veia nada y el undo/redo no cuadraban. El costo ademas ya se habia
# descontado y no se devolvia.
#
# QUE MIDE (headless, manager real + terreno falso):
#   * colocar con la escritura fallida -> motivo NO_SE_PUDO_ESCRIBIR
#   * NO se registra la pieza (no queda a medias)
#   * el COSTO se devuelve (no se pierde material)
#   * el motivo es TEMPORAL (se reintenta)
#   * lo mismo al COPIAR (y el costo de la copia se devuelve)
#   * lo mismo al MOVER, y ADEMAS el origen sigue en su sitio (no se pierde)
#   * en MODO LOGICO (sin terreno) no se bloquea nada: la pieza vive solo en la
#     logica, que es el diseno del modo logico
#   * con un terrain que responde, todo sigue funcionando (no se rompio nada)
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_atomicidad_escritura.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: atomicidad de la escritura en el mundo"
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const TIPO := preload("res://scripts/construccion/construccion_tipos.gd")
const ZONE_REG := preload("res://scripts/construccion/zone_registry.gd")
const MGR := preload("res://scripts/construccion/build_manager.gd")
const MUNDO := preload("res://scripts/construccion/construccion_mundo.gd")
const CHECKS_MINIMOS := 20

const LADO_BLOQUE := 16

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


class VoxelToolFalso:
	extends RefCounted
	var channel: int = 0
	var mode: int = 0
	var value: int = 0
	var eraser_value: int = 0
	var bloques: Dictionary = {}
	var escrituras: int = 0
	func get_voxel(celda: Vector3i) -> int:
		return int(bloques.get(celda, 0))
	func do_point(celda: Vector3i) -> void:
		escrituras += 1
		bloques[celda] = 99


class TerrainFalso:
	extends Node
	var tool: VoxelToolFalso = VoxelToolFalso.new()
	var data_blocks: Array[Vector3i] = []
	func get_voxel_tool():
		return tool
	func voxel_to_data_block(v: Vector3) -> Vector3i:
		return Vector3i(int(floor(v.x / LADO_BLOQUE)), int(floor(v.y / LADO_BLOQUE)), int(floor(v.z / LADO_BLOQUE)))
	func has_data_block(bloque: Vector3i) -> bool:
		return data_blocks.has(bloque)


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


class MundoLogico:
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


func _sembrar(inv: FakeInventario, r: PlacementRule) -> void:
	for k in (r.costo as Dictionary).keys():
		inv.items[String(k)] = 999
	for k in ["madera", "piedra", "stone", "planks", "fibra", "tierra", "arena", "ore"]:
		inv.items[k] = 999


func _manager(mundo, inv, nombre: String) -> Object:
	var m = MGR.new()
	m.name = nombre
	root.add_child(m)
	m.conectar_mundo(mundo)
	m.conectar_zonas(ZONE_REG.new())
	m.set_limite_mundo(AABB())
	m.conectar_inventario(inv)
	return m


## Receta que la validacion ACEPTA (no exige soporte, no pide agua) pero cuyo
## bloque es 0: la escritura en el mundo devuelve 0 voxels aunque el terreno
## responda. Inyecta el fallo de forma DETERMINISTA para poder probar la
## atomicidad (la escritura falla de verdad, no de mentira).
func _receta_sin_bloque() -> PlacementRule:
	var r := PlacementRule.new()
	r.id = &"pieza_sin_bloque"
	r.nombre = "Pieza sin bloque"
	r.familia = &"estructura"
	r.tamano = Vector2i(1, 1)
	r.altura = 1.0
	r.soportes_minimos = 0
	r.superficie_ok = [&"terreno", &"piso", &"techo"]
	r.sobre_agua = false
	r.requiere_pared = false
	r.deconstruible = true
	r.devolucion = 0.5
	r.costo = {"planks": 2}
	r.bloque = 0
	return r


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var cat := CATALOGO.new()
	cat.cargar("res://data/construccion/piezas")
	var recetas_pared: Array = cat.por_familia(&"pared")
	var receta_base: PlacementRule = recetas_pared[0] if not recetas_pared.is_empty() else null
	_check("A0: el catalogo real de M17 tiene recetas de la familia 'pared'", receta_base != null)

	# ── A. Colocar con la ESCRITURA FALLIDA ────────────────────────────
	var terreno := TerrainFalso.new()
	terreno.name = "TerrainRoto"
	root.add_child(terreno)
	terreno.data_blocks.append(Vector3i(0, 0, 0))
	for x in range(0, 8):
		for z in range(0, 8):
			terreno.tool.bloques[Vector3i(x, 0, z)] = 12
	var mundo := MUNDO.new()
	mundo.conectar_terrain(terreno)

	var inv := FakeInventario.new()
	_sembrar(inv, receta_base)
	var receta_puente := _receta_sin_bloque()
	var mgr = _manager(mundo, inv, "MgrRoto")
	await process_frame
	mgr.registrar_receta(receta_puente)
	mgr.seleccionar_pieza(receta_puente)

	var costo: Dictionary = (receta_puente.costo as Dictionary).duplicate()
	var recursos_antes: Dictionary = {}
	for k in costo.keys():
		recursos_antes[String(k)] = int(inv.items.get(String(k), 0))

	var celda := Vector3i(2, 1, 2)
	var res: Dictionary = mgr.confirmar_colocacion(celda)
	_check("A1: escribir en el mundo falla -> motivo NO_SE_PUDO_ESCRIBIR",
		(_motivos(res) as Array).has(TIPO.Motivo.NO_SE_PUDO_ESCRIBIR), str(_motivos(res)))
	_check("A2: NO se reporta exito (la operacion no se hace)",
		not bool(res.get("ok", false)), str(res.get("detalle", [])))
	_check("A3: NO se registro la pieza (no queda a medias)",
		(mgr.pieza_en_celda(celda) as Dictionary).is_empty())
	var devuelto := true
	for k in costo.keys():
		if int(inv.items.get(String(k), 0)) != int(recursos_antes.get(String(k), 0)):
			devuelto = false
	_check("A4: el COSTO se devuelve (el material no se pierde)", devuelto,
		"antes=%s ahora=%s" % [str(recursos_antes), str(inv.items)])
	_check("A5: NO_SE_PUDO_ESCRIBIR es TEMPORAL (se reintenta)",
		TIPO.es_temporal(TIPO.Motivo.NO_SE_PUDO_ESCRIBIR))
	_check("A6: el texto del motivo es legible para el HUD",
		TIPO.texto(TIPO.Motivo.NO_SE_PUDO_ESCRIBIR).contains("escribir"),
		TIPO.texto(TIPO.Motivo.NO_SE_PUDO_ESCRIBIR))

	# ── B. COPIAR y MOVER con la escritura fallida ─────────────────────
	# Con el terreno sano primero (para tener una pieza ORIGEN).
	var terreno_ok := TerrainFalso.new()
	terreno_ok.name = "TerrainOK"
	root.add_child(terreno_ok)
	terreno_ok.data_blocks.append(Vector3i(0, 0, 0))
	for x in range(0, 8):
		terreno_ok.tool.bloques[Vector3i(x, 0, 0)] = 12
	var mundo_ok := MUNDO.new()
	mundo_ok.conectar_terrain(terreno_ok)
	var mgr_ok = _manager(mundo_ok, inv, "MgrOK")
	await process_frame
	mgr_ok.registrar_receta(receta_puente)
	mgr_ok.seleccionar_pieza(receta_puente)
	# La variante sana de la receta (con bloque real) escribe de verdad.
	var receta_sana := _receta_sin_bloque()
	receta_sana.bloque = 12
	mgr_ok.registrar_receta(receta_sana)
	mgr_ok.seleccionar_pieza(receta_sana)
	var res_ok: Dictionary = mgr_ok.confirmar_colocacion(Vector3i(3, 1, 0))
	_check("B0: con el terreno sano la colocacion funciona (no se rompio nada)",
		bool(res_ok.get("ok", false)), str(_motivos(res_ok)))
	_check("B1: con el terreno sano la pieza queda registrada y escrita",
		not (mgr_ok.pieza_en_celda(Vector3i(3, 1, 0)) as Dictionary).is_empty()
			and terreno_ok.tool.escrituras > 0, "escrituras=%d" % terreno_ok.tool.escrituras)

	# Ahora el CATALOGO cambia: la misma receta pasa a no tener bloque, asi que
	# la escritura falla. Copiar y mover deben fallar sin romper nada.
	var receta_sin_bloque := _receta_sin_bloque()
	receta_sin_bloque.id = receta_sana.id
	mgr_ok.registrar_receta(receta_sin_bloque)
	var inv_antes := {}
	for k in costo.keys():
		inv_antes[String(k)] = int(inv.items.get(String(k), 0))
	var res_copia: Dictionary = mgr_ok.copiar_pieza(Vector3i(3, 1, 0), Vector3i(5, 1, 0))
	_check("B2: copiar con la escritura fallida -> motivo NO_SE_PUDO_ESCRIBIR",
		(_motivos(res_copia) as Array).has(TIPO.Motivo.NO_SE_PUDO_ESCRIBIR), str(_motivos(res_copia)))
	_check("B3: la copia NO se registro",
		(mgr_ok.pieza_en_celda(Vector3i(5, 1, 0)) as Dictionary).is_empty())
	var costo_ok := true
	for k in costo.keys():
		if int(inv.items.get(String(k), 0)) != int(inv_antes.get(String(k), 0)):
			costo_ok = false
	_check("B4: el costo de la COPIA se devuelve", costo_ok, "antes=%s ahora=%s" % [str(inv_antes), str(inv.items)])

	var res_mover: Dictionary = mgr_ok.mover_pieza(Vector3i(3, 1, 0), Vector3i(6, 1, 0))
	_check("B5: mover con la escritura fallida -> motivo NO_SE_PUDO_ESCRIBIR",
		(_motivos(res_mover) as Array).has(TIPO.Motivo.NO_SE_PUDO_ESCRIBIR), str(_motivos(res_mover)))
	_check("B6: al no poder mover, la pieza ORIGEN sigue en su sitio (no se pierde)",
		not (mgr_ok.pieza_en_celda(Vector3i(3, 1, 0)) as Dictionary).is_empty())
	_check("B7: no se registro la pieza en el destino",
		(mgr_ok.pieza_en_celda(Vector3i(6, 1, 0)) as Dictionary).is_empty())

	# ── C. Modo LOGICO: la pieza vive solo en la logica (diseno) ────────
	var mundo_logico := MundoLogico.new()
	var mgr_logico = _manager(mundo_logico, inv, "MgrLogico")
	await process_frame
	mgr_logico.registrar_receta(receta_puente)
	mgr_logico.seleccionar_pieza(receta_puente)
	var res_logico: Dictionary = mgr_logico.confirmar_colocacion(Vector3i(50, 1, 50))
	_check("C1: en modo LOGICO se coloca igual que siempre (0 voxels writings es lo normal ahi)",
		bool(res_logico.get("ok", false)), str(_motivos(res_logico)))
	_check("C2: en modo LOGICO la pieza queda registrada en la logica",
		not (mgr_logico.pieza_en_celda(Vector3i(50, 1, 50)) as Dictionary).is_empty())

	# ── D. La operacion fallida NO deja rastro ─────────────────────────
	var tamanos: Dictionary = mgr.historial().tamanos()
	var piezas_tras_fallo: int = mgr.cantidad_estructuras()
	_check("D1: la colocacion fallida NO dejo entrada en el historial (no hay undo que deshacer)",
		int(tamanos.get("undo", 0)) + int(tamanos.get("redo", 0)) == 0, str(tamanos))
	_check("D2: la colocacion fallida NO dejo ninguna pieza registrada",
		piezas_tras_fallo == 0, "piezas=%d" % piezas_tras_fallo)
	_check("D3: no se puede deshacer una colocacion que nunca ocurrio",
		not bool(mgr.historial().puede_undo()))

	# ── E. Con el camino sano, el costo SI se consume (contraste) ───────
	var inv_antes_ok: Dictionary = {}
	for k in costo.keys():
		inv_antes_ok[String(k)] = int(inv.items.get(String(k), 0))
	mgr_ok.seleccionar_pieza(receta_sana)
	var res_sana: Dictionary = mgr_ok.confirmar_colocacion(Vector3i(7, 1, 7))
	_check("E1: con la escritura correcta la colocacion -> ok",
		bool(res_sana.get("ok", false)), str(_motivos(res_sana)))
	var consumido := false
	for k in costo.keys():
		if int(inv.items.get(String(k), 0)) < int(inv_antes_ok.get(String(k), 0)):
			consumido = true
	_check("E2: en el camino sano el costo SI se consume (no es un reembolso fantasma)",
		consumido, "antes=%s ahora=%s" % [str(inv_antes_ok), str(inv.items)])
	_check("E3: en el camino sano la pieza queda registrada",
		not (mgr_ok.pieza_en_celda(Vector3i(7, 1, 7)) as Dictionary).is_empty())

	# ── F. Anti-falso-verde ─────────────────────────────────────────────
	_check("F1: la suite ejecuta al menos %d checks (minimo anti-falso-verde)" % CHECKS_MINIMOS,
		_checks >= CHECKS_MINIMOS, "checks=%d" % _checks)

	print("--- %s: %d checks, %d fallos ---" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		for d in _detalles:
			print("  FALLO: %s" % d)
	quit(1 if _fallos > 0 else 0)
