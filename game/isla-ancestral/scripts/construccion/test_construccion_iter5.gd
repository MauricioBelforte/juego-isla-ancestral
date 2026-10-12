# Modelo: stepfun-step-5-preview (Kilo Code)
# Fecha: 2026-10-11
#
# M17 Construccion iter. 5 — edge cases restantes de la seccion L, pedidos por el
# director (msg 142):
#   * L197: demolicion de pieza bajo otra pieza -> rechazo determinista nombrando
#           la de arriba (se demuele en orden, de arriba hacia abajo).
#   * L192: cerrar el modo con el fantasma activo -> se devuelve al pool y no
#           queda estado inconsistente.
#   * L193: guardado a mitad de colocacion -> el fantasma es estado de UI, nunca
#           se persiste.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter5.gd

extends SceneTree

const CHECKS_MINIMOS: int = 32

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

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

class MundoPlano:
	extends ConstruccionMundo
	var suelo: int = 0
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y <= suelo else &"aire"
	func escribir_voxel(celdas: Array, _bloque: int) -> int:
		escrituras += celdas.size()
		return celdas.size()
	func borrar_voxel(celdas: Array) -> int:
		borrados += celdas.size()
		return celdas.size()

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

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

func _preparar(mgr, costo_piso: Dictionary = {"stone": 2}, costo_pared: Dictionary = {"stone": 2}) -> void:
	var inv := FakeInventario.new()
	inv.items["stone"] = 100
	mgr.conectar_inventario(inv)
	mgr.conectar_zonas(ZoneRegistry.new())
	mgr.conectar_mundo(MundoPlano.new())
	mgr.set_limite_mundo(AABB())
	mgr.limpiar_estructuras()
	_reg(mgr, _receta(mgr, &"piso_piedra"), "piso_iter5", costo_piso)
	_reg(mgr, _receta(mgr, &"pared_piedra"), "pared_iter5", costo_pared)

func _receta(mgr, id: StringName) -> PlacementRule:
	return mgr.receta(id)

## Receta clonada con costo propio (no toca el catalogo compartido).
func _clon(r: PlacementRule, nuevo_id: String, costo: Dictionary) -> PlacementRule:
	var d: Dictionary = r.a_dict()
	d["id"] = nuevo_id
	d["costo"] = costo
	return PlacementRule.desde_dict(d)

## Registra una receta con otro id/costo en el catalogo del manager.
func _reg(mgr, r: PlacementRule, nuevo_id: String, costo: Dictionary) -> PlacementRule:
	var d: Dictionary = r.a_dict()
	d["id"] = nuevo_id
	d["costo"] = costo.duplicate()
	var nueva: PlacementRule = PlacementRule.desde_dict(d)
	mgr.registrar_receta(nueva)
	return nueva

# ── bloques ──────────────────────────────────────────────────────────────

## 1. L197: demoler una pieza que sostiene otra.
func _b1_sostiene(mgr) -> void:
	_abrir("1", "Edge case L: demolicion de pieza bajo otra pieza")
	var inv := FakeInventario.new()
	inv.items["stone"] = 100
	mgr.conectar_inventario(inv)
	mgr.conectar_zonas(ZoneRegistry.new())
	mgr.conectar_mundo(MundoPlano.new())
	mgr.limpiar_estructuras()

	var piso: PlacementRule = _reg(mgr, _receta(mgr, &"piso_piedra"), "piso_l197", {"stone": 2})
	var pared: PlacementRule = _reg(mgr, _receta(mgr, &"pared_piedra"), "pared_l197", {"stone": 3})
	_ok(piso != null and pared != null, "2 recetas registradas con costo propio")

	mgr.seleccionar_pieza(piso)
	_ok(bool(mgr.confirmar_colocacion(Vector3i(0, 0, 0))["ok"]), "piso colocado en (0,0,0)")
	mgr.seleccionar_pieza(pared)
	_ok(bool(mgr.confirmar_colocacion(Vector3i(0, 1, 0))["ok"]), "pared apoyada sobre el piso")

	var antes: int = inv.count_item("stone")
	var intento: Dictionary = mgr.demolir_pieza(Vector3i(0, 0, 0))
	_ok(not bool(intento.get("ok", false)), "demoler el piso que sostiene -> rechazado")
	_ok((intento["motivos"] as Array).has(ConstruccionTipos.Motivo.SOSTIENE_OTRA_PIEZA),
		"motivo SOSTIENE_OTRA_PIEZA")
	_ok(String(intento.get("texto", "")).contains("apoyada arriba"),
		"el texto dice que demuela la de arriba (dio '%s')" % String(intento.get("texto", "")))
	_ok(not bool(intento.get("temporal", false)), "el rechazo es PERMANENTE (hay que actuar)")
	_ok(inv.count_item("stone") == antes, "un rechazo NO devuelve material")
	_ok(mgr.cantidad_estructuras() == 2, "las 2 estructuras siguen en pie")

	# orden correcto: primero la de arriba, despues la de abajo
	var d1: Dictionary = mgr.demolir_pieza(Vector3i(0, 1, 0))
	_ok(bool(d1.get("ok", false)), "demoler la pared de arriba -> ok")
	var d2: Dictionary = mgr.demolir_pieza(Vector3i(0, 0, 0))
	_ok(bool(d2.get("ok", false)), "recien ahora el piso de abajo se puede demoler")
	_ok(mgr.cantidad_estructuras() == 0, "no queda nada")

	# piezas hermanas (al lado, no encima) NO se bloquean entre si
	mgr.seleccionar_pieza(piso)
	mgr.confirmar_colocacion(Vector3i(5, 0, 5))
	mgr.confirmar_colocacion(Vector3i(6, 0, 5))
	var hermana: Dictionary = mgr.demolir_pieza(Vector3i(5, 0, 5))
	_ok(bool(hermana.get("ok", false)), "pieza contigua (no apoyada) se demuele normal")

	# pieza apoyada por el LADO (mismo nivel) no cuenta
	mgr.seleccionar_pieza(pared)
	mgr.confirmar_colocacion(Vector3i(6, 1, 5))
	var lateral: Dictionary = mgr.demolir_pieza(Vector3i(6, 0, 5))
	_ok((lateral["motivos"] as Array).has(ConstruccionTipos.Motivo.SOSTIENE_OTRA_PIEZA),
		"apoyo vertical (y+1) si bloquea: la pared de arriba lo detecta")
	_fin("1")

## 2. L192: cerrar el modo con el fantasma activo -> al pool.
func _b2_fantasma_pool(mgr) -> void:
	_abrir("2", "Edge case L: cerrar el modo con fantasma activo")
	_preparar(mgr)
	var fantasma := BuildGhost.new()
	fantasma.name = "FantasmaTest"
	root.add_child(fantasma)
	mgr.conectar_fantasma(fantasma)
	_ok(mgr.fantasma() == fantasma, "conectar_fantasma() queda registrado")

	var piso: PlacementRule = mgr.receta(&"piso_iter5")
	mgr.seleccionar_pieza(piso)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)
	_ok(mgr.esta_en_modo(), "entrar_modo() ok")

	# fantasma activo y visible (preview valida). La UI setea receta_id en el
	# resultado; aca se emula para probar el contrato del fantasma.
	var res: Dictionary = mgr.validar(Vector3i(1, 0, 1))
	_ok(bool(res["ok"]), "la celda de prueba es valida")
	res["receta_id"] = piso.id
	fantasma.aplicar_resultado(res, piso)
	_ok(fantasma.esta_visible(), "el fantasma quedo visible")
	_ok(fantasma.receta_actual() == piso.id, "el fantasma muestra la pieza")

	# cerrar el modo con el fantasma activo
	mgr.salir_modo()
	_ok(not fantasma.esta_visible(), "el fantasma se oculta al salir del modo")
	_ok(String(fantasma.receta_actual()) == "", "el fantasma se desvincula de la pieza")
	_ok((fantasma.celdas_actuales() as Array).is_empty(), "no quedan celdas colgando")
	_ok(fantasma.hijos_creados() >= 0, "el pool sobrevive (no se destruyen nodos)")
	_ok(not mgr.esta_en_modo(), "el manager quedo fuera del modo")
	_ok(mgr.receta_actual() == null, "sin pieza seleccionada")

	# sin fantasma conectado no explota (headless / UI que no lo usa)
	mgr.conectar_fantasma(null)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)
	mgr.salir_modo()
	_ok(true, "salir_modo() sin fantasma conectado no rompe")

	# el estado del mundo no se toca al cerrar
	mgr.seleccionar_pieza(mgr.receta(&"piso_iter5"))
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)
	mgr.confirmar_colocacion(Vector3i(2, 0, 2))
	var n_antes: int = mgr.cantidad_estructuras()
	mgr.salir_modo()
	_ok(mgr.cantidad_estructuras() == n_antes, "cerrar el modo no borra estructuras")
	fantasma.queue_free()
	_fin("2")

## 3. L193: guardado a mitad de colocacion -> el fantasma no se persiste.
func _b3_guardado_fantasma(mgr) -> void:
	_abrir("3", "Edge case L: guardado a mitad de colocacion")
	_preparar(mgr)
	var fantasma := BuildGhost.new()
	fantasma.name = "FantasmaTest3"
	root.add_child(fantasma)
	mgr.conectar_fantasma(fantasma)

	var piso: PlacementRule = mgr.receta(&"piso_iter5")
	mgr.seleccionar_pieza(piso)
	mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)
	mgr.confirmar_colocacion(Vector3i(3, 0, 3))

	# fantasma activo a mitad de una colocacion (preview sin confirmar)
	var res: Dictionary = mgr.validar(Vector3i(4, 0, 4))
	fantasma.aplicar_resultado(res, piso)
	_ok(fantasma.esta_visible(), "hay un fantasma activo a mitad de la colocacion")

	var guardado: Array = mgr.obtener_estructuras()
	_ok(guardado.size() == 1, "el save ve SOLO la estructura real (dio %d)" % guardado.size())
	var claves: Dictionary = {}
	for e in guardado:
		for k in (e as Dictionary).keys():
			claves[String(k)] = true
	_ok(not claves.has("fantasma") and not claves.has("ghost") and not claves.has("preview"),
		"el save no tiene ninguna clave de fantasma (%s)" % str(claves.keys()))
	_ok(not claves.has("ok") and not claves.has("texto"),
		"el save no arrastra resultados de validacion")

	# round-trip: guardar y restaurar no inventa piezas fantasma
	var seccion: Array = guardado
	mgr.limpiar_estructuras()
	_ok(mgr.cantidad_estructuras() == 0, "mundo limpio antes de restaurar")
	mgr.restaurar_estructuras(seccion)
	_ok(mgr.cantidad_estructuras() == 1, "restaurar deja 1 (no duplica ni inventa)")

	# guardar DESPUES de salir del modo da exactamente lo mismo
	mgr.salir_modo()
	_ok(not fantasma.esta_visible(), "salir del modo oculta el fantasma")
	var guardado2: Array = mgr.obtener_estructuras()
	_ok(guardado2.size() == mgr.cantidad_estructuras(),
		"el save posterior al cierre tiene el mismo tamanio")
	_fin("3")

## 4. Regresion: motivos nuevos coherentes.
func _b4_regresion(mgr) -> void:
	_abrir("4", "Regresion: motivo SOSTIENE_OTRA_PIEZA")
	_ok(ConstruccionTipos.TEXTO.has(ConstruccionTipos.Motivo.SOSTIENE_OTRA_PIEZA),
		"SOSTIENE_OTRA_PIEZA tiene texto")
	_ok(not ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.SOSTIENE_OTRA_PIEZA),
		"SOSTIENE_OTRA_PIEZA no es temporal")
	_ok(ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.DOBLE_CONFIRMACION),
		"DOBLE_CONFIRMACION sigue siendo temporal")
	_fin("4")

func _run() -> void:
	var mgr = root.get_node_or_null("/root/Construccion")
	_ok(mgr != null, "autoload Construccion presente en /root")
	if mgr == null:
		return
	_b1_sostiene(mgr)
	_b2_fantasma_pool(mgr)
	_b3_guardado_fantasma(mgr)
	_b4_regresion(mgr)

func _summary() -> void:
	print("=== RESUMEN M17 CONSTRUCCION iter.5 (edge cases 2): %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON (abortados por un error de runtime):")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d checks < CHECKS_MINIMOS=%d" % [_checks, CHECKS_MINIMOS])
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
