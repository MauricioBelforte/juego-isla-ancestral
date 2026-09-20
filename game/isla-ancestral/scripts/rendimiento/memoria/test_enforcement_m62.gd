# Modelo: glm-5.3-flash (iter. 2) · DeepSeek-V4.1-Flash (iter. 3, Log 1094)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-01 · 2026-09-19
#
# M62: Test de enforcement / política de descarga / alarma de pico.
# Complementa test_memoria_m62.gd y test_memoria_m62_iter3.gd — no los reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/test_enforcement_m62.gd
#
# ── POR QUÉ ESTA SUITE FUE REESCRITA (Log 1094) ────────────────────────────
# La versión de iter. 2 estaba MUERTA Y DABA VERDE. Medido, no supuesto:
#   · `var budget: Node = load("…/budget_registry.gd").new()` → los registries
#     son `RefCounted`, así que la asignación tipada abortaba la función con
#     `SCRIPT ERROR: Trying to assign value of type 'RefCounted' to a variable
#     of type 'Node'`. Abortaban `_test_registros()` (línea 29) y
#     `_test_enforcement_niveles()` (línea 46): 0 checks ejecutados.
#   · `_test_alarma_pico()` sí corría, pero sus 3 aserciones eran
#     `_check(true, "…sin crash")` → INFALSIFICABLES.
#   · El resumen imprimía "0 fallo(s)" y `quit(0)`: la suite no verificaba nada
#     y sin embargo pasaba. Falso verde de manual (trampa: `SCRIPT ERROR`
#     aborta la función → los checks que no corren no fallan).
#   · Además llamaba a `monitor._muestrear()` (ya no existe) y a
#     `_enforcement()` con 1 argumento (ahora son 2).
# Ahora: tipos correctos, aserciones que pueden fallar, y guardián de 3 capas.

extends SceneTree

const MODULO := "M62-enforcement"
const BLOQUES: Array[String] = ["A", "B", "C", "D"]
## Piso MEDIDO en verde, NO copiado. Valor = salida real de la corrida
##   godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/test_enforcement_m62.gd
## el 2026-09-19 (Log 1094): "=== Resumen M62-enforcement: 47 checks, 0 fallos ===".
## Si un bloque aborta por un SCRIPT ERROR, sus checks desaparecen y el conteo
## cae por debajo del piso → la suite falla aunque no quede ningún [FAIL].
const CHECKS_MINIMOS := 47

const _SC_BUDGET := preload("res://scripts/rendimiento/memoria/budget_registry.gd")
const _SC_POOL := preload("res://scripts/rendimiento/memoria/global_pool.gd")
const _SC_UNLOAD := preload("res://scripts/rendimiento/memoria/unload_policy.gd")
const RUTA_MONITOR := "res://scripts/rendimiento/memoria/memory_monitor.gd"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	# `_summary()` va en su PROPIO call_deferred: si `_run()` aborta entero, el
	# resumen corre igual y nombra los bloques que no se ejecutaron.
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M62] Test enforcement / descarga / pico (Log 1094) ===")
	_bloque_a_registry()
	_bloque_b_unload()
	_bloque_c_enforcement()
	_bloque_d_pico()

## ── A. BudgetRegistry: contrato básico ────────────────────────────────────
func _bloque_a_registry() -> void:
	print("--- A. BudgetRegistry: registrar / reportar / verificar ---")
	var b = _SC_BUDGET.new()
	b.cargar()
	_check("cargar() deja 8 sistemas", b.sistemas().size() == 8, "n=%d" % b.sistemas().size())
	_check("tope de voxel media = 650 (diseño §2)", b.tope_de("voxel") == 650,
		"voxel=%d" % b.tope_de("voxel"))
	_check("total de topes media = 2000", b.total_topes_mb() == 2000,
		"total=%d" % b.total_topes_mb())
	_check("test_x no existe antes de registrarlo", b.tope_de("test_x") == 0,
		"tope=%d" % b.tope_de("test_x"))
	b.registrar_sistema("test_x", 100)
	_check("tope registrado = 100", b.tope_de("test_x") == 100, "tope=%d" % b.tope_de("test_x"))
	b.reportar_consumo("test_x", 150)
	_check("consumo reportado = 150", b.consumo_de("test_x") == 150,
		"consumo=%d" % b.consumo_de("test_x"))
	var sobre: Array = b.verificar()
	_check("test_x sobre el tope detectado", sobre.size() == 1 and "test_x" in sobre,
		"sobre=%s" % str(sobre))
	b.reportar_consumo("test_x", 50)
	_check("tras bajar, verificar() queda limpio", b.verificar().is_empty(),
		"sobre=%s" % str(b.verificar()))
	_check("total_consumo_mb suma lo REPORTADO", b.total_consumo_mb() == 50,
		"total=%d" % b.total_consumo_mb())
	_check("total_topes_mb NO cambia con el consumo", b.total_topes_mb() == 2100,
		"total=%d" % b.total_topes_mb())
	_check("porcentaje_de(test_x) = 0.5 al medio tope", b.porcentaje_de("test_x") == 0.5,
		"pct=%.2f" % b.porcentaje_de("test_x"))
	# `sistema_mas_critico()` = mayor OCUPACIÓN RELATIVA, no mayor consumo:
	# test_x va al 50% de su tope y el resto al 0%, así que el crítico es test_x.
	_check("sistema_mas_critico nombra a test_x (50% de su tope)",
		b.sistema_mas_critico() == "test_x", "critico=%s" % b.sistema_mas_critico())
	_fin("A")

## ── B. UnloadPolicy: escalonamiento por preset y orden ────────────────────
func _bloque_b_unload() -> void:
	print("--- B. UnloadPolicy: tope por frame y orden de descarga ---")
	var u = _SC_UNLOAD.new()
	_check("MAX_POR_FRAME por defecto = 3", u.MAX_POR_FRAME == 3)
	_check("preset baja -> 8 (diseño §5.4)", u.max_por_frame_para("baja") == 8,
		"max=%d" % u.max_por_frame_para("baja"))
	_check("preset media -> 12 (diseño §5.4)", u.max_por_frame_para("media") == 12,
		"max=%d" % u.max_por_frame_para("media"))
	_check("preset alta -> 16 (diseño §5.4)", u.max_por_frame_para("alta") == 16,
		"max=%d" % u.max_por_frame_para("alta"))
	_check("preset desconocido -> 3 (conservador)", u.max_por_frame_para("zzz") == 3,
		"max=%d" % u.max_por_frame_para("zzz"))
	# 5 candidatos de 10 MB con distancias 0..4 (el 4 es el más lejano)
	for i in range(5):
		u.marcar_candidato(Resource.new(), 10, float(i))
	_check("5 candidatos en cola", u.candidatos_count() == 5, "n=%d" % u.candidatos_count())
	var orden: Array = u.previsualizar_orden()
	_check("previsualizar devuelve 5", orden.size() == 5, "n=%d" % orden.size())
	_check("previsualizar ordena el más lejano primero",
		absf(float(orden[0]["distancia"]) - 4.0) < 0.001, "primera dist=%s" % str(orden[0]["distancia"]))
	_check("previsualizar NO consume la cola", u.candidatos_count() == 5,
		"n=%d" % u.candidatos_count())
	_check("sin descargas el último lote está vacío", u.ultimo_lote_count() == 0)
	var liberados: int = u.ejecutar_descarga(100, 3)
	_check("ejecutar_descarga respeta max_por_frame=3", liberados == 30, "liberados=%d" % liberados)
	_check("el último lote registra 3", u.ultimo_lote_count() == 3,
		"lote=%d" % u.ultimo_lote_count())
	_check("quedan 2 candidatos", u.candidatos_count() == 2, "n=%d" % u.candidatos_count())
	_check("el resumen del lote no está vacío", u.resumen_ultimo_lote() != "sin descargas",
		"resumen='%s'" % u.resumen_ultimo_lote())
	_fin("B")

## ── C. Enforcement del monitor (niveles sobre el presupuesto) ─────────────
func _bloque_c_enforcement() -> void:
	print("--- C. Enforcement: suave (nivel 2) y duro (nivel 3) ---")
	var b = _SC_BUDGET.new()
	b.cargar()
	var mm = load(RUTA_MONITOR).new()
	mm.budget = b
	mm.unload = _SC_UNLOAD.new()
	mm.pool = _SC_POOL.new()
	_check("presupuesto total = 2000", mm.presupuesto_total_mb() == 2000,
		"total=%d" % mm.presupuesto_total_mb())
	_check("nivel_para(1600) = 1 (80%)", mm.nivel_para(1600.0) == 1,
		"nivel=%d" % mm.nivel_para(1600.0))
	_check("nivel_para(1800) = 2 (90%)", mm.nivel_para(1800.0) == 2,
		"nivel=%d" % mm.nivel_para(1800.0))
	_check("nivel_para(1900) = 3 (95%)", mm.nivel_para(1900.0) == 3,
		"nivel=%d" % mm.nivel_para(1900.0))
	# Sembrar 20 candidatos de 100 MB
	for i in range(20):
		mm.unload.marcar_candidato(Resource.new(), 100, float(i))
	# Nivel 1 NO debe descargar
	mm._enforcement(1600.0, 1)
	_check("nivel 1 NO descarga", mm.unload.candidatos_count() == 20,
		"quedan=%d" % mm.unload.candidatos_count())
	# Nivel 2 descarga con el tope del preset activo (media = 12)
	var emitidos: Array = [0]
	mm.recurso_descargado.connect(func(_s, _mb): emitidos[0] += 1)
	mm._enforcement(1800.0, 2)
	_check("nivel 2 descarga 12 (tope del preset media)",
		mm.unload.candidatos_count() == 8, "quedan=%d" % mm.unload.candidatos_count())
	_check("el lote quedó registrado con 12", mm.unload.ultimo_lote_count() == 12,
		"lote=%d" % mm.unload.ultimo_lote_count())
	_check("emitió recurso_descargado", emitidos[0] == 1, "emisiones=%d" % emitidos[0])
	mm._enforcement(1800.0, 2)
	_check("nivel 2 es idempotente (no re-descarga)", mm.unload.candidatos_count() == 8,
		"quedan=%d" % mm.unload.candidatos_count())
	# Nivel 3 siempre re-aplica
	mm._enforcement(1900.0, 3)
	_check("nivel 3 re-aplica y drena el resto", mm.unload.candidatos_count() == 0,
		"quedan=%d" % mm.unload.candidatos_count())
	_check("nivel 3 volvió a emitir la señal", emitidos[0] == 2, "emisiones=%d" % emitidos[0])
	_check("nivel_para(1000) = 0 sin presión", mm.nivel_para(1000.0) == 0,
		"nivel=%d" % mm.nivel_para(1000.0))
	_fin("C")

## ── D. Alarma de pico (ahora OBSERVABLE vía alarmas_pico()) ───────────────
func _bloque_d_pico() -> void:
	print("--- D. Alarma de pico: umbral 200 MB y contador ---")
	var mm = load(RUTA_MONITOR).new()
	_check("arranca sin alarmas", mm.alarmas_pico() == 0, "n=%d" % mm.alarmas_pico())
	mm._ultima_muestra = 0.0
	_check("sin muestra previa no alarma", mm._alarma_pico(500.0) == false)
	_check("y el contador sigue en 0", mm.alarmas_pico() == 0, "n=%d" % mm.alarmas_pico())
	mm._ultima_muestra = 100.0
	_check("salto de exactamente 200 MB NO alarma (el umbral es estricto)",
		mm._alarma_pico(300.0) == false)
	mm._ultima_muestra = 100.0
	_check("salto de 200,1 MB SÍ alarma", mm._alarma_pico(300.1) == true)
	_check("el contador subió a 1", mm.alarmas_pico() == 1, "n=%d" % mm.alarmas_pico())
	mm._ultima_muestra = 300.1
	_check("salto chico no alarma", mm._alarma_pico(310.0) == false)
	_check("el contador no se movió", mm.alarmas_pico() == 1, "n=%d" % mm.alarmas_pico())
	var rep: Dictionary = mm.exportar_reporte()
	_check("el reporte expone alarmas_pico", rep.has("alarmas_pico") and int(rep["alarmas_pico"]) == 1,
		"rep=%s" % str(rep.get("alarmas_pico")))
	_fin("D")

## ── Utilidades ────────────────────────────────────────────────────────────
func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

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
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
