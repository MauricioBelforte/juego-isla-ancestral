# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M62: Memoria — Test headless
# Valida: BudgetRegistry (carga data-driven, verificación, topes),
# GlobalPool (obtener/devolver/precalentar/límites/liberar_todo),
# UnloadPolicy (LRU/distancia, descarga escalonada), MemoryMonitor
# (memoria/pico/objetos/huérfanos/drift). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.
#
# Log 1094 (DeepSeek-V4.1-Flash): se añade el guardián de 3 capas que faltaba.
# `_summary()` se llamaba SÓLO desde `_run()`: un `SCRIPT ERROR` que abortara
# `_run()` dejaba la suite sin resumen, sin `quit()` y con salida 0 → verde por
# omisión. Ahora `_summary()` va en su propio `call_deferred`, cada bloque se
# marca con `_fin()` y hay un piso de checks medido.

extends SceneTree

const MODULO := "M62"
const BLOQUES: Array[String] = ["budget", "pool", "unload", "monitor"]
## Piso MEDIDO en verde, NO copiado (Log 1094): 27 checks, 0 fallos.
const CHECKS_MINIMOS := 27

const _SC_BUDGET := preload("res://scripts/rendimiento/memoria/budget_registry.gd")
const _SC_POOL := preload("res://scripts/rendimiento/memoria/global_pool.gd")
const _SC_UNLOAD := preload("res://scripts/rendimiento/memoria/unload_policy.gd")

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M62] Test de Memoria ===")
	_test_budget_registry()
	_test_global_pool()
	_test_unload_policy()
	_test_memory_monitor()
	# Sin `_summary()` aquí a propósito: lo cierra el `call_deferred` de `_init()`,
	# así corre aunque esta función aborte por un SCRIPT ERROR.

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── BudgetRegistry ─────────────────────────────────────

func _test_budget_registry() -> void:
	print("--- BudgetRegistry: carga data-driven + verificación ---")
	var b = _SC_BUDGET.new()
	b.cargar()
	_check("8 sistemas con preset media", b.tope_de("voxel") > 0 and b.tope_de("texturas") > 0 and b.tope_de("audio") > 0, "voxel=%d" % b.tope_de("voxel"))
	# Diseño §2: preset media -> voxel = 650. El dataset había divergido a 640 y
	# ESTA aserción consagraba el valor divergente: dos errores que se cancelaban
	# y daban verde. Corregido en Log 1094 junto con el dataset (budgets.json).
	_check("tope media voxel = 650", b.tope_de("voxel") == 650, "voxel=%d" % b.tope_de("voxel"))
	# Guarda contra la divergencia silenciosa: la suma de topes debe dar el total
	# declarado del preset (1500 baja / 2000 media / 2500 alta).
	_check("suma de topes media = 2000", b.total_topes_mb() == 2000, "total=%d" % b.total_topes_mb())
	b.registrar_sistema("test", 100)
	_check("registrar_sistema manual", b.tope_de("test") == 100)
	b.reportar_consumo("voxel", 500)
	b.reportar_consumo("test", 150)
	var sobre = b.verificar()
	_check("test sobre tope detectado", sobre.size() == 1 and "test" in sobre, "sobre=%s" % str(sobre))
	_check("voxel bajo tope", not ("voxel" in sobre))
	b.reportar_consumo("test", 50)
	_check("verificación limpia tras reducir", b.verificar().is_empty())
	_check("total_consumo", b.total_consumo_mb() == 550, "total=%d" % b.total_consumo_mb())
	_fin("budget")

## ── GlobalPool ──────────────────────────────────────────

func _test_global_pool() -> void:
	print("--- GlobalPool: obtener/devolver/precalentar/límites ---")
	var p = _SC_POOL.new()
	var n1 := Node.new()
	var n2 := Node.new()
	p.set_limite("nodos", 2)
	p.devolver("nodos", n1)
	p.devolver("nodos", n2)
	_check("tamaño pool = 2", p.tamanio("nodos") == 2)
	var extra := Node.new()
	_check("devolver sobre límite -> false", p.devolver("nodos", extra) == false)
	extra.free()
	var sacado = p.obtener("nodos")
	_check("obtener devuelve nodo", sacado != null)
	sacado.free()
	var sacado2 = p.obtener("nodos")
	_check("2do obtener devuelve el otro nodo", sacado2 != null)
	sacado2.free()
	_check("pool vacío -> null", p.obtener("nodos") == null)
	# precalentar con factory
	var pre = _SC_POOL.new()
	pre.precalentar("textos", 3, func(): return Node.new())
	_check("precalentar 3", pre.tamanio("textos") == 3)
	var t = pre.obtener("textos")
	t.free()
	_check("obtener tras precalentar", pre.tamanio("textos") == 2)
	# liberar todo
	var pre2 = _SC_POOL.new()
	pre2.precalentar("meshes", 5, func(): return Node.new())
	var liberados := pre2.liberar_todo()
	_check("liberar_todo devuelve 5", liberados == 5)
	_check("pool vacío tras liberar", pre2.tamanio("meshes") == 0)
	_fin("pool")

## ── UnloadPolicy ────────────────────────────────────────

func _test_unload_policy() -> void:
	print("--- UnloadPolicy: LRU/distancia + descarga escalonada ---")
	var u = _SC_UNLOAD.new()
	var r1 := Resource.new()
	var r2 := Resource.new()
	var r3 := Resource.new()
	var r4 := Resource.new()
	u.marcar_candidato(r1, 10, 100.0)
	u.marcar_candidato(r2, 20, 50.0)
	u.marcar_candidato(r3, 30, 200.0)
	u.marcar_candidato(r4, 40, 10.0)
	_check("4 candidatos", u.candidatos_count() == 4)
	# descarga escalonada: max 2 por frame, hasta 100 mb
	var liberados := u.ejecutar_descarga(100, 2)
	_check("descargó 2 por frame", u.candidatos_count() == 2, "count=%d" % u.candidatos_count())
	_check("liberó el más lejano (30) + segundo (10)", liberados == 40, "lib=%d" % liberados)
	# los objetos r1/r3 fueron liberados; r2/r4 quedan (no se pueden tocar)
	_check("quedan 2 candidatos", u.candidatos_count() == 2)
	_fin("unload")

## ── MemoryMonitor ───────────────────────────────────────

func _test_memory_monitor() -> void:
	print("--- MemoryMonitor: getters y semáforo ---")
	var mm := root.get_node_or_null("MemoryMonitor")
	if mm == null:
		# Sin autoload: se marca el bloque como visto y se deja que `_summary()`
		# (capa 3) cierre con el fallo contado. Nada de `quit()` a mano aquí.
		_check("MemoryMonitor autoload presente", false)
		_fin("monitor")
		return
	_check("MemoryMonitor autoload presente", true)
	_check("memoria_actual_mb > 0", mm.memoria_actual_mb() > 0.0, "mb=%f" % mm.memoria_actual_mb())
	_check("presupuesto voxel > 0", mm.presupuesto_de("voxel") > 0)
	_check("objetos_vivos >= 0", mm.objetos_vivos() >= 0)
	_check("nodos_huerfanos >= 0", mm.nodos_huerfanos() >= 0)
	_check("semaforo en rango 0-3", mm.semaforo >= 0 and mm.semaforo <= 3)
	_fin("monitor")

## ── Utilidades ──────────────────────────────────────────

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecutó (posible SCRIPT ERROR que abortó la función)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST M62 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M62 OK — todos los checks pasaron")
		quit(0)