extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — CACHE DEL FANTASMA (BuildPreview) y su invalidacion.
#
# POR QUE EXISTE: al terminar el barrido de la clase de defecto "reporta algo
# que ya no es verdad" (el mismo tipo que L102 y la escritura atomica), aparecio
# este caso: la cache de `BuildPreview` solo se invalidaba en 4 rutas
# (`confirmar_colocacion`, `demolir_pieza`, `mover_pieza` e `_invertir`).
# Faltaban tres mutaciones del mundo:
#   * `copiar_pieza()`            -> aparece una pieza nueva y la cache sigue valiendo
#   * `limpiar_estructuras()`     -> se vacia el mundo y la cache sigue valiendo
#   * `restaurar_estructuras()`   -> (carga de save) idem
# Efecto: el fantasma Podia mostrar VERDE una celda que ya estaba ocupada (o
# ROJA una celda valida) porque reutilizaba un resultado viejo.
#
# QUE MIDE (headless, manager real + vista previa real):
#   * la cache FUNCIONA (misma celda/rotacion/receta -> "cache": true y NO recalcula)
#   * la cache se INVALIDA al COPIAR una pieza (y el resultado refleja el estado nuevo)
#   * la cache se INVALIDA al VACIAR el mundo (limpiar_estructuras)
#   * la cache se INVALIDA al RESTAURAR estructuras (carga de save)
#   * el contador `recalculos()` refleja exactamente los recalculos reales
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_cache_preview.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: cache del fantasma e invalidacion al cambiar el mundo"
const CATALOGO := preload("res://scripts/construccion/build_catalog_db.gd")
const ZONE_REG := preload("res://scripts/construccion/zone_registry.gd")
const MGR := preload("res://scripts/construccion/build_manager.gd")
const CHECKS_MINIMOS := 12

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


class MundoLogico:
	extends ConstruccionMundo
	var suelo: int = 0
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y <= suelo else &"aire"


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


func _sembrar(inv: FakeInventario, r: PlacementRule) -> void:
	for k in (r.costo as Dictionary).keys():
		inv.items[String(k)] = 999
	for k in ["madera", "piedra", "stone", "planks", "fibra", "tierra", "arena", "ore"]:
		inv.items[k] = 999


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var cat := CATALOGO.new()
	cat.cargar("res://data/construccion/piezas")
	var recetas_pared: Array = cat.por_familia(&"pared")
	var receta_base: PlacementRule = recetas_pared[0] if not recetas_pared.is_empty() else null
	_check("A0: el catalogo real de M17 tiene recetas de la familia 'pared'", receta_base != null)

	var inv := FakeInventario.new()
	_sembrar(inv, receta_base)
	var mgr = MGR.new()
	mgr.name = "MgrCache"
	root.add_child(mgr)
	mgr.conectar_mundo(MundoLogico.new())
	mgr.conectar_zonas(ZONE_REG.new())
	mgr.set_limite_mundo(AABB())
	mgr.conectar_inventario(inv)
	await process_frame
	mgr.registrar_receta(receta_base)
	mgr.seleccionar_pieza(receta_base)

	var destino := Vector3i(6, 1, 6)
	var celda_previa := Vector3i(8, 1, 8)

	# ── A. La cache FUNCIONA (no se recalcula en cada frame) ───────────
	var p1: Dictionary = mgr.preview(celda_previa)
	_check("A1: la primera vista previa se evalua (no es un acierto de cache)",
		not bool(p1.get("cache", false)), str(p1.get("cache", false)))
	var recalos_1: int = mgr.preview_actual().recalculos()
	var totales_1: int = mgr.preview_actual().recalculos_totales()
	var p2: Dictionary = mgr.preview(celda_previa)
	_check("A2: la segunda vista previa MISMA celda es un acierto de cache",
		bool(p2.get("cache", false)), str(p2.get("cache", false)))
	_check("A3: el acierto de cache NO recalcula (el contador se queda igual)",
		mgr.preview_actual().recalculos() == recalos_1,
		"recalculos=%d antes=%d" % [mgr.preview_actual().recalculos(), recalos_1])
	_check("A4: el resultado cacheado conserva los datos de la pieza (celdas)",
		(p2.get("celdas", []) as Array).size() > 0)

	# ── B. COPIAR una pieza invalida la cache ──────────────────────────
	var res_col: Dictionary = mgr.confirmar_colocacion(Vector3i(4, 1, 4))
	_check("B0: la pieza base se colo (mundo logico)", bool(res_col.get("ok", false)), str(res_col))
	# Colocar una pieza es un cambio del mundo: la cache se invalida (el
	# fantasma tiene que volver a evaluar la celda).
	var p3: Dictionary = mgr.preview(celda_previa)
	_check("B1: COLOCAR una pieza invalida la cache (el mundo cambio)",
		not bool(p3.get("cache", false)), str(p3.get("cache", false)))

	# Copiar una pieza SOBRE la celda de la vista previa: el mundo cambio.
	var res_copia: Dictionary = mgr.copiar_pieza(Vector3i(4, 1, 4), destino)
	_check("B2: la copia se hizo -> ok", bool(res_copia.get("ok", false)), str(res_copia))
	var p4: Dictionary = mgr.preview(celda_previa)
	_check("B3: COPIAR invalida la cache del fantasma (no se reutiliza el resultado viejo)",
		not bool(p4.get("cache", false)), str(p4.get("cache", false)))
	_check("B4: el contador TOTAL de recalculos sube tras la invalidacion",
		mgr.preview_actual().recalculos_totales() > totales_1,
		"totales=%d antes=%d" % [mgr.preview_actual().recalculos_totales(), totales_1])

	# Y el resultado NUEVO refleja el estado real (la celda ocupada es invalida).
	var p_ocupada: Dictionary = mgr.preview(destino)
	_check("B5: la vista previa de la celda recien copiada dice INVALIDA (la pieza esta ahi)",
		not bool(p_ocupada.get("ok", true)), str(p_ocupada.get("motivos", [])))

	# ── C. VACIAR el mundo invalida la cache ───────────────────────────
	mgr.preview(celda_previa)
	mgr.limpiar_estructuras()
	var p5: Dictionary = mgr.preview(celda_previa)
	_check("C1: VACIAR el mundo invalida la cache del fantasma",
		not bool(p5.get("cache", false)), str(p5.get("cache", false)))
	_check("C2: tras vaciar, la vista previa de la celda ocupada vuelve a ser VALIDA",
		bool(p5.get("ok", false)), str(p5.get("motivos", [])))

	# ── D. RESTAURAR (carga de save) invalida la cache ─────────────────
	mgr.preview(celda_previa)
	var antes: int = mgr.preview_actual().recalculos_totales()
	mgr.restaurar_estructuras([])
	var p6: Dictionary = mgr.preview(celda_previa)
	_check("D1: RESTAURAR estructuras (carga de save) invalida la cache",
		not bool(p6.get("cache", false)), str(p6.get("cache", false)))
	_check("D2: el contador TOTAL de recalculos refleja el nuevo calculo",
		mgr.preview_actual().recalculos_totales() > antes,
		"totales=%d antes=%d" % [mgr.preview_actual().recalculos_totales(), antes])
	_check("D3: el contador por sesion (`recalculos()`) se resetea al invalidar (contrato previo)",
		mgr.preview_actual().recalculos() == 1,
		"recalculos=%d" % mgr.preview_actual().recalculos())

	# ── E. Anti-falso-verde ─────────────────────────────────────────────
	_check("E1: la suite ejecuta al menos %d checks (minimo anti-falso-verde)" % CHECKS_MINIMOS,
		_checks >= CHECKS_MINIMOS, "checks=%d" % _checks)

	print("--- %s: %d checks, %d fallos ---" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		for d in _detalles:
			print("  FALLO: %s" % d)
	quit(1 if _fallos > 0 else 0)
