# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-11
#
# M17 Construccion iter. 4 — EDGE CASES de la seccion L del checklist, pedidos
# por el director (msg 140):
#   * L187: pieza sobre NPC activo -> rechazo TEMPORAL (el NPC se va y listo).
#   * L194: pieza en el limite del mundo -> rechazo claro dentro del AABB.
#   * L196: doble confirmacion rapida -> cooldown + misma celda.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter4.gd
#
# Misma guardia anti-falso-verde de 3 capas que las suites anteriores.

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE y fijado aqui.
const CHECKS_MINIMOS: int = 30

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

## Mundo plano con NPC configurable por celda (para el edge case L187).
class MundoConNpc:
	extends ConstruccionMundo
	var suelo: int = 0
	var npcs: Dictionary = {}     # "x,y,z" -> true
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y < suelo else &"aire"
	func hay_npc_en(celda: Vector3i) -> bool:
		return bool(npcs.get(ConstruccionTipos.clave(celda), false))
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

func _receta(mgr, id: StringName) -> PlacementRule:
	return mgr.receta(id)

# ── bloques ──────────────────────────────────────────────────────────────

## 1. Rechazo TEMPORAL por NPC (L187).
func _b1_npc_temporal(mgr) -> void:
	_abrir("1", "Edge case L: NPC activo -> rechazo temporal")
	var mundo := MundoConNpc.new()
	mundo.suelo = 0
	mundo.conectar_terrain(null)
	mgr.conectar_mundo(mundo)
	var inv := FakeInventario.new()
	inv.items["planks"] = 50
	inv.items["stone"] = 50
	mgr.conectar_inventario(inv)
	mgr.limpiar_estructuras()

	var piso: PlacementRule = _receta(mgr, &"piso_piedra")
	_ok(piso != null, "receta piso_piedra disponible")
	mgr.seleccionar_pieza(piso)
	mgr.set_limite_mundo(AABB())

	# sin NPC: valida
	var libre: Dictionary = mgr.validar(Vector3i(4, 0, 4))
	_ok(bool(libre["ok"]), "celda sin NPC -> valida ('%s')" % String(libre.get("texto", "")))

	# con NPC en la celda: rechazo con el motivo correcto y marcado temporal
	mundo.npcs[ConstruccionTipos.clave(Vector3i(5, 0, 5))] = true
	var con_npc: Dictionary = mgr.validar(Vector3i(5, 0, 5))
	_ok(not bool(con_npc["ok"]), "NPC en la celda -> no valida")
	_ok((con_npc["motivos"] as Array).has(ConstruccionTipos.Motivo.NPC_EN_CELDA),
		"motivo NPC_EN_CELDA presente")
	_ok(String(con_npc.get("texto", "")).contains("vecino"),
		"el texto dice 'hay un vecino en el lugar' (dio '%s')" % String(con_npc.get("texto", "")))
	_ok(bool(con_npc.get("temporal", false)),
		"el rechazo queda marcado TEMPORAL (puede desaparecer solo)")

	# el HUD lo comunica como reintentable
	var linea: String = BuildHudModel.linea_estado(con_npc, piso)
	_ok(linea.contains("RECHAZADO") and linea.contains("temporal"),
		"HUD: linea de estado dice temporal (dio '%s')" % linea)
	_ok(bool(BuildHudModel.resumen(con_npc, piso)["temporal"]),
		"HUD: resumen expone temporal=true")

	# confirmar con el NPC ahi NO coloca ni cobra
	var antes: int = inv.count_item("stone")
	var rc: Dictionary = mgr.confirmar_colocacion(Vector3i(5, 0, 5))
	_ok(not bool(rc["ok"]), "confirmar con NPC -> rechazado")
	_ok(inv.count_item("stone") == antes, "no cobra recursos al rechazar")
	_ok(mgr.cantidad_estructuras() == 0, "no queda estructura colocada")

	# el NPC se va -> la misma celda ahora es valida (TEMPORAL cumplido)
	mundo.npcs.erase(ConstruccionTipos.clave(Vector3i(5, 0, 5)))
	var despues: Dictionary = mgr.validar(Vector3i(5, 0, 5))
	_ok(bool(despues["ok"]), "NPC fuera -> misma celda vuelve a ser valida")

	# un motivo PERMANENTE (zona protegida) NO se marca temporal
	mgr.registrar_zona(AABB(Vector3(4, 0, 4), Vector3(1, 1, 1)), ConstruccionTipos.Permiso.PROTEGIDA)
	var perm: Dictionary = mgr.validar(Vector3i(4, 0, 4))
	_ok(not bool(perm.get("temporal", false)),
		"zona protegida NO es temporal (el jugador debe actuar)")
	_fin("1")

## 2. Limite del mundo (L194).
func _b2_limite_mundo(mgr) -> void:
	_abrir("2", "Edge case L: pieza en el limite del mundo")
	var mundo := MundoConNpc.new()
	mundo.suelo = 0
	mundo.npcs.clear()
	mgr.conectar_mundo(mundo)
	mgr.limpiar_estructuras()
	var inv := FakeInventario.new()
	inv.items["planks"] = 50
	inv.items["stone"] = 50
	mgr.conectar_inventario(inv)

	var piso: PlacementRule = _receta(mgr, &"piso_piedra")
	mgr.seleccionar_pieza(piso)

	# AABB jugable: de (0,0,0) a (9,4,9) inclusive -> 10x5x10 celdas
	mgr.set_limite_mundo(AABB(Vector3(0, 0, 0), Vector3(10, 5, 10)))
	_ok(mgr.limite_mundo().size == Vector3(10, 5, 10), "el AABB quedo guardado")

	var dentro: Dictionary = mgr.validar(Vector3i(3, 0, 3))
	_ok(bool(dentro["ok"]), "celda dentro del AABB -> valida")

	var borde: Dictionary = mgr.validar(Vector3i(9, 0, 9))
	_ok(bool(borde["ok"]), "ultima celda del AABB (9,9) -> valida (borde inclusive)")

	var fuera: Dictionary = mgr.validar(Vector3i(10, 0, 3))
	_ok(not bool(fuera["ok"]), "celda fuera en X -> rechazada")
	_ok((fuera["motivos"] as Array).has(ConstruccionTipos.Motivo.FUERA_DEL_MUNDO),
		"motivo FUERA_DEL_MUNDO presente")
	_ok(String(fuera.get("texto", "")).contains("limites de la isla"),
		"texto claro para el jugador (dio '%s')" % String(fuera.get("texto", "")))
	_ok(not bool(fuera.get("temporal", false)), "salir del mundo NO es temporal")

	var abajo: Dictionary = mgr.validar(Vector3i(3, 0, 11))
	_ok((abajo["motivos"] as Array).has(ConstruccionTipos.Motivo.FUERA_DEL_MUNDO),
		"fuera en Z tambien se detecta")

	var neg: Dictionary = mgr.validar(Vector3i(-1, 0, 3))
	_ok((neg["motivos"] as Array).has(ConstruccionTipos.Motivo.FUERA_DEL_MUNDO),
		"coordenada negativa fuera del AABB se rechaza")

	# confirmar fuera NO coloca ni cobra
	var antes: int = inv.count_item("stone")
	var rc: Dictionary = mgr.confirmar_colocacion(Vector3i(10, 0, 3))
	_ok(not bool(rc["ok"]), "confirmar fuera del mundo -> rechazado")
	_ok(inv.count_item("stone") == antes and mgr.cantidad_estructuras() == 0,
		"fuera del mundo: ni cobra ni coloca")

	# sin AABB definida no hay limite (default documentado)
	mgr.set_limite_mundo(AABB())
	var sin_limite: Dictionary = mgr.validar(Vector3i(50, 0, 50))
	_ok(bool(sin_limite["ok"]), "AABB vacia = sin limite (headless sin mundo)")
	_fin("2")

## 3. Doble confirmacion rapida (L196).
func _b3_cooldown(mgr) -> void:
	_abrir("3", "Edge case L: doble confirmacion rapida (cooldown)")
	var mundo := MundoConNpc.new()
	mundo.suelo = 0
	mundo.npcs.clear()
	mgr.conectar_mundo(mundo)
	mgr.set_limite_mundo(AABB())
	mgr.limpiar_estructuras()
	var inv := FakeInventario.new()
	inv.items["planks"] = 50
	inv.items["stone"] = 50
	mgr.conectar_inventario(inv)

	var piso: PlacementRule = _receta(mgr, &"piso_piedra")
	mgr.seleccionar_pieza(piso)

	var r1: Dictionary = mgr.confirmar_colocacion(Vector3i(2, 0, 2))
	_ok(bool(r1["ok"]), "primera confirmacion -> ok")
	_ok(mgr.cantidad_estructuras() == 1, "1 estructura")

	# deshacer deja la celda libre otra vez (misma celda, misma validez)
	var u: Dictionary = mgr.undo()
	_ok(bool(u["ok"]) and mgr.cantidad_estructuras() == 0, "undo deja la celda libre")

	# re-confirmar la MISMA celda dentro de la ventana -> cooldown
	var r2: Dictionary = mgr.confirmar_colocacion(Vector3i(2, 0, 2))
	_ok(not bool(r2["ok"]), "re-confirmar la misma celda rapido -> rechazado")
	_ok((r2["motivos"] as Array).has(ConstruccionTipos.Motivo.DOBLE_CONFIRMACION),
		"motivo DOBLE_CONFIRMACION")
	_ok(bool(r2.get("temporal", false)), "el cooldown es temporal (reintentable)")
	_ok(mgr.cantidad_estructuras() == 0, "el cooldown NO coloco nada")

	# pasado el cooldown, la misma celda si confirma
	OS.delay_msec(300)
	var r3: Dictionary = mgr.confirmar_colocacion(Vector3i(2, 0, 2))
	_ok(bool(r3["ok"]), "pasado el cooldown -> confirma normal")

	# una celda DISTINTA no se ve afectada por el cooldown
	var r4: Dictionary = mgr.confirmar_colocacion(Vector3i(6, 0, 6))
	_ok(bool(r4["ok"]), "otra celda -> ok inmediato (el cooldown es por celda)")
	_ok(mgr.cantidad_estructuras() == 2, "2 estructuras")

	# el cooldown NO tapa el motivo real: celda ocupada sigue siendo ocupada
	var r5: Dictionary = mgr.confirmar_colocacion(Vector3i(2, 0, 2))
	_ok((r5["motivos"] as Array).has(ConstruccionTipos.Motivo.CELDA_OCUPADA),
		"celda ocupada sigue reportando CELDA_OCUPADA (no lo tapa el cooldown)")
	_fin("3")

## 4. El resto de las suites y los motivos nuevos siguen coherentes.
func _b4_regresion(mgr) -> void:
	_abrir("4", "Regresion: enum/textos/temporales coherentes")
	_ok(ConstruccionTipos.TEXTO.has(ConstruccionTipos.Motivo.FUERA_DEL_MUNDO),
		"FUERA_DEL_MUNDO tiene texto")
	_ok(ConstruccionTipos.TEXTO.has(ConstruccionTipos.Motivo.DOBLE_CONFIRMACION),
		"DOBLE_CONFIRMACION tiene texto")
	_ok(ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.NPC_EN_CELDA),
		"NPC_EN_CELDA es temporal")
	_ok(not ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.FUERA_DEL_MUNDO),
		"FUERA_DEL_MUNDO no es temporal")
	_ok(not ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.SIN_SOPORTE),
		"SIN_SOPORTE no es temporal")
	_ok(ConstruccionValidator.ORDEN.has("mundo"), "ORDEN del validador incluye 'mundo'")
	var celdas: Array[Vector3i] = [Vector3i(1, 0, 1)]
	var fuera: Array = ConstruccionValidator.fuera_del_mundo(celdas,
		ConstruccionValidator.contexto(Callable(), Callable(), Callable(), Callable(),
			Callable(), Callable(), AABB(Vector3(0, 0, 0), Vector3(3, 3, 3))))
	_ok(fuera.is_empty(), "dentro_del_mundo: celda dentro -> sin rechazo")
	var fuera2: Array = ConstruccionValidator.fuera_del_mundo(celdas,
		ConstruccionValidator.contexto(Callable(), Callable(), Callable(), Callable(),
			Callable(), Callable(), AABB(Vector3(5, 0, 5), Vector3(3, 3, 3))))
	_ok(fuera2.size() == 1, "celda fuera -> 1 rechazada")
	_fin("4")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	var mgr = root.get_node_or_null("/root/Construccion")
	_ok(mgr != null, "autoload Construccion presente en /root")
	if mgr == null:
		return
	_b1_npc_temporal(mgr)
	_b2_limite_mundo(mgr)
	_b3_cooldown(mgr)
	_b4_regresion(mgr)

func _summary() -> void:
	print("=== RESUMEN M17 CONSTRUCCION iter.4 (edge cases): %d checks, %d fallos, %d bloques cerrados ===" % [
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
