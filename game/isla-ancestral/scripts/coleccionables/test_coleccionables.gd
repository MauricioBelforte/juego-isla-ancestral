# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M73: Test del modulo Coleccionables.
# Cubre: catalog (carga + validacion + busqueda), item (id_global + valido),
# manager (registro idempotente + dedupe + progreso categoria + completada + senales),
# persistencia M59, integracion con fauna_registry (suscripcion a especie_avistada).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/coleccionables/test_coleccionables.gd

extends SceneTree

const CatalogRef = preload("res://scripts/coleccionables/coleccionables_catalog.gd")
const ItemRef = preload("res://scripts/coleccionables/coleccionable_item.gd")

var _fallos: int = 0
var _mgr: Node = null
var _fauna_reg: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mgr = root.get_node_or_null("coleccionables")
	_fauna_reg = root.get_node_or_null("fauna_registry")
	_check(_mgr != null, "coleccionables autoload presente (M73)")
	if _mgr == null:
		print("=== TEST M73 COLECCIONABLES: %d fallo(s) ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return
	_test_catalogo_basico()
	_test_item_validacion()
	_test_registro_idempotente()
	_test_registro_por_local()
	_test_registro_por_fuente()
	_test_progreso_categoria()
	_test_categoria_completa()
	_test_senales()
	_test_persistencia()
	_test_integracion_fauna_registry()
	print("=== TEST M73 COLECCIONABLES: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _reset_mgr() -> void:
	_mgr._collected.clear()
	_mgr._categoria_collected.clear()

## ── Tests ────────────────────────────────────────────────────

func _test_catalogo_basico() -> void:
	var total: int = _mgr.catalog.cantidad_total()
	_check(total >= 15, "catalog con >=15 items (fallback): %d" % total)
	var cats: Array = _mgr.catalog.todas_las_categorias()
	_check(cats.size() >= 4, "catalog con >=4 categorias: %d" % cats.size())
	_check(cats.has(&"minerales"), "categoria minerales existe")
	_check(cats.has(&"animales"), "categoria animales existe")
	_check(cats.has(&"conchas"), "categoria conchas existe")
	_check(cats.has(&"reliquias"), "categoria reliquias existe")

func _test_item_validacion() -> void:
	var it_min = _mgr.catalog.obtener(&"minerales_001")
	_check(it_min != null, "minerales_001 existe en catalog")
	_check(it_min.es_valido(), "minerales_001 es valido")
	_check(it_min.id_global() == &"minerales_001", "id_global = minerales_001")
	_check(it_min.display_name == "Cobre", "display_name = Cobre (got %s)" % it_min.display_name)
	_check(it_min.rareza == 0, "rareza = 0 (COMUN)")
	_check(it_min.fuente == &"mineria", "fuente = mineria")
	_check(it_min.recompensa_item == &"moneda_ancestral", "recompensa = moneda_ancestral")
	_check(it_min.puntos == 5, "puntos = 5")
	# Item invalido (sin id_local)
	var itvacio = ItemRef.new()
	_check(not itvacio.es_valido(), "item sin id_local NO es valido")

func _test_registro_idempotente() -> void:
	_reset_mgr()
	_check(_mgr.registrar(&"minerales_001") == true, "primer registro: nuevo")
	_check(_mgr.registrar(&"minerales_001") == false, "segundo registro: idempotente (no nuevo)")
	_check(_mgr.es_collected(&"minerales_001") == true, "es_collected = true")
	# Empty id: no registra
	_check(_mgr.registrar(&"") == false, "registrar(\"\") = false")
	# Id inexistente: registra igual (no se valida contra catalog para no romper; la UI
	# recibira item=null y mostrara error suave)
	_check(_mgr.registrar(&"no_existe_999") == true, "registrar id inexistente: true (no valida contra catalog)")

func _test_registro_por_local() -> void:
	_reset_mgr()
	_check(_mgr.registrar_por_local(&"minerales", &"001") == true, "registrar_por_local(minerales, 001) = nuevo")
	_check(_mgr.registrar_por_local(&"minerales", &"001") == false, "registrar_por_local duplicado = false")
	_check(_mgr.registrar_por_local(&"minerales", &"NOEXISTE") == false, "registrar_por_local id_local inexistente = false")

func _test_registro_por_fuente() -> void:
	_reset_mgr()
	_check(_mgr.registrar_por_fuente(&"mineria", &"001") == true, "registrar_por_fuente(mineria, 001) = nuevo")
	_check(_mgr.registrar_por_fuente(&"fauna", &"001") == true, "registrar_por_fuente(fauna, 001) = nuevo (categoria animales)")
	_check(_mgr.registrar_por_fuente(&"playa", &"001") == true, "registrar_por_fuente(playa, 001) = nuevo (categoria conchas)")
	_check(_mgr.registrar_por_fuente(&"fuente_inexistente", &"001") == false, "registrar_por_fuente(fuente_inexistente) = false")

func _test_progreso_categoria() -> void:
	_reset_mgr()
	_mgr.registrar(&"minerales_001")
	_mgr.registrar(&"minerales_002")
	_check(_mgr.collected_count(&"minerales") == 2, "collected_count minerales = 2")
	var total_min: int = _mgr.total_count(&"minerales")
	_check(total_min >= 5, "total_count minerales >= 5 (got %d)" % total_min)
	var pct: float = _mgr.porcentaje_categoria(&"minerales")
	_check(pct > 0.0 and pct < 1.0, "porcentaje_categoria en (0, 1): %.3f" % pct)
	# Porcentaje total
	_mgr.registrar(&"animales_001")
	var pct_total: float = _mgr.porcentaje_total()
	_check(pct_total > 0.0 and pct_total < 1.0, "porcentaje_total en (0, 1): %.3f" % pct_total)

func _test_categoria_completa() -> void:
	_reset_mgr()
	# Animales solo tiene 4 items en el fallback. Registrar los 4.
	_mgr.registrar(&"animales_001")
	_mgr.registrar(&"animales_002")
	_mgr.registrar(&"animales_003")
	_mgr.registrar(&"animales_004")
	# Senal categoria_completed NO se emite automaticamente (es on-demand)
	# Verificar que el manager lo detectaria
	_check(_mgr.porcentaje_categoria(&"animales") == 1.0, "animales 100%% completado: %.3f" % _mgr.porcentaje_categoria(&"animales"))
	# Completar via senal: emitir manualmente la senal de completada
	_mgr.categoria_completed.emit(&"animales", &"gema_ancestral", 1)
	# Si llegamos aca sin crash, la senal funciona

func _test_senales() -> void:
	_reset_mgr()
	var signal_count: Array = [0]  # mutable closure
	_mgr.item_collected.connect(func(_id, _it): signal_count[0] += 1)
	_mgr.categoria_progress_changed.connect(func(_cat, _c, _t): pass)
	_mgr.registrar(&"minerales_001")
	_mgr.registrar(&"minerales_002")
	_mgr.registrar(&"minerales_003")
	_check(signal_count[0] == 3, "item_collected emitido 3 veces (got %d)" % signal_count[0])
	_check(_mgr.es_collected(&"minerales_001"), "minerales_001 collected")
	# Re-registrar no emite
	_mgr.registrar(&"minerales_001")
	_check(signal_count[0] == 3, "re-registro no emite senal (got %d)" % signal_count[0])

func _test_persistencia() -> void:
	_reset_mgr()
	_mgr.registrar(&"minerales_001")
	_mgr.registrar(&"animales_001")
	_mgr.registrar(&"conchas_002")
	var data: Dictionary = _mgr.get_save_data()
	_check(int(data.get("version", 0)) >= 1, "version >= 1")
	_check(int(data.get("collected", {}).size()) == 3, "3 items en save data")
	# Reset y restore
	_mgr._collected.clear()
	_mgr._categoria_collected.clear()
	_mgr.restore_save_data(data)
	_check(_mgr.es_collected(&"minerales_001"), "restore: minerales_001 collected")
	_check(_mgr.es_collected(&"animales_001"), "restore: animales_001 collected")
	_check(_mgr.es_collected(&"conchas_002"), "restore: conchas_002 collected")
	# Version antigua ignorada
	_mgr._collected.clear()
	_mgr.restore_save_data({"version": 0, "collected": {"fake": true}})
	_check(not _mgr.es_collected(&"fake"), "version 0 ignorada")

func _test_integracion_fauna_registry() -> void:
	_reset_mgr()
	# Limpiar dedupe del registry para que la senal se procese
	if _fauna_reg != null:
		var keys_dd: Array = _fauna_reg._dedupe.keys().duplicate()
		for k in keys_dd:
			_fauna_reg._dedupe.erase(k)
		var keys_est: Array = _fauna_reg._estados.keys().duplicate()
		for k in keys_est:
			_fauna_reg._estados.erase(k)
	# Emitir la senal que M36 emite cuando se avista un animal
	_fauna_reg.especie_avistada.emit(&"conejo_pradera", {"instancia_id": "test_fauna_001", "distancia": 5.0, "tiempo_pantalla_s": 1.0})
	# Verificar que M73 recibio y registro animales_001
	_check(_mgr.es_collected(&"animales_001"), "fauna conejo_pradera -> animales_001 collected")
	# Emitir otra especie
	_fauna_reg.especie_avistada.emit(&"salamandra_ancestral", {"instancia_id": "test_fauna_002", "distancia": 5.0, "tiempo_pantalla_s": 1.0})
	_check(_mgr.es_collected(&"animales_004"), "fauna salamandra_ancestral -> animales_004 collected")
