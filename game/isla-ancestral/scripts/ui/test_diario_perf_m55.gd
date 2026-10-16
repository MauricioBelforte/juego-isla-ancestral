# Modelo: Step-5-WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-10-16
#
# M55 (iter. 4, Step-5-WorkBuddy): Test headless del lote de RENDIMIENTO (W)
# de DiaryLayer — virtualización, pooling de filas (M62) y LazyLoad con 500+
# entradas. Verifica con evidencia medida (no estructural):
#  - apertura < 100 ms con 500+ entradas sintéticas (antes: un Button por
#    entrada en el árbol)
#  - la lista solo instancia la ventana visible (≤ FILAS_VENTANA_MAX nodos)
#  - los espaciadores sostienen la altura total (scroll con extensión real)
#  - el scroll desliza la ventana y las filas se RECICLAN del pool (M62):
#    el conteo de nodos no crece al deslizar
#  - progreso_global() coincide con la suma manual de progreso_categoria()
#    (el % global sin materializar categorías no visibles)
#  - LazyLoad: un refresco llama entradas_de() solo para la categoría activa
#    (antes: 14 llamadas, una por categoría, en cada apertura)
#
# Sonda roja reproducible: M55_SONDA=1 inyecta un aborto de runtime tras el
# check 5 (EXIT 1 + sin resumen falso). El piso CHECKS_MINIMOS se mide en verde.
#
# Estado de DiaryService se SNAPSHOTA y restaura al final (no ensuciar el entorno).
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_diario_perf_m55.gd

extends SceneTree

## Piso de checks medido en verde (patrón M105)
const CHECKS_MINIMOS: int = 18

const N_SINTETICAS: int = 500

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var diary = root.get_node_or_null("Diary")
	var ui = root.get_node_or_null("UIManager")
	var loc = root.get_node_or_null("Localization")
	_check(diary != null, "Diary autoload presente")
	_check(ui != null, "UIManager autoload presente")
	if diary == null or ui == null:
		_resumen()
		return
	if loc != null and loc.has_method("set_locale"):
		loc.set_locale("es")

	var snap: Dictionary = diary.get_save_data().duplicate(true)
	diary.restore_save_data({"schema_version": 1, "entradas": {}})

	var previa = ui._buscar_capa("DiaryLayer")
	if previa != null:
		previa.free()
	var base_stack: int = ui.stack_size()
	var script := load("res://scripts/ui/layers/diary_layer.gd")
	_check(script != null, "diary_layer.gd carga")
	if script == null or not script.can_instantiate():
		_check(false, "diary_layer.gd compila sin errores de parseo")
		_resumen()
		return
	var capa = script.new()
	capa.name = "DiaryLayer"
	root.add_child(capa)
	_check(ui.stack_size() == base_stack + 1, "capa registrada en la pila")

	# ── 1) Baseline: catálogo actual (44 entradas) ──────────────────
	var t0 := Time.get_ticks_usec()
	capa.open()
	var us_base := int(Time.get_ticks_usec() - t0)
	_check(us_base < 100000, "apertura baseline < 100 ms (%d µs)" % us_base)
	var lista = _buscar(capa, "ListaEntradas")
	_check(lista != null, "ListaEntradas existe")
	var n_base := _contar_filas(lista)
	_check(n_base >= 0 and n_base <= capa.FILAS_VENTANA_MAX, "baseline: filas ≤ ventana máxima (%d ≤ %d)" % [n_base, capa.FILAS_VENTANA_MAX])
	_check(_buscar(capa, "EspaciadorArriba") != null and _buscar(capa, "EspaciadorAbajo") != null, "espaciadores arriba/abajo existen")
	var esp_a = _buscar(capa, "EspaciadorArriba")
	var esp_b = _buscar(capa, "EspaciadorAbajo")
	_check(float(esp_a.custom_minimum_size.y) == 0.0, "sin scroll: espaciador arriba en 0 (first=0)")

	# ── 2) Edge: 500+ entradas sintéticas en personajes ─────────────
	var cat_per: Array = diary._catalogo.get("personajes", [])
	var base_entradas: int = diary.total_entradas()
	for i in N_SINTETICAS:
		var eid := "perf_synth_%03d" % i
		cat_per.append({"id": eid, "titulo": "Sintética %03d" % i, "secreta": false, "descripcion": "", "refs": []})
		var ok: bool = diary.registrar(eid, "personajes")
		if i < 3:
			_check(ok, "registrar sintética %03d" % i)
	_check(diary.total_entradas() == base_entradas + N_SINTETICAS, "catálogo con %d entradas (%d + %d)" % [diary.total_entradas(), base_entradas, N_SINTETICAS])

	# ── 3) Apertura con 500+ entradas: < 100 ms y ventana acotada ───
	capa.close()
	t0 = Time.get_ticks_usec()
	capa.open()
	var us_edge := int(Time.get_ticks_usec() - t0)
	_check(us_edge < 100000, "APERTURA con 500+ entradas < 100 ms (%d µs) — L193" % us_edge)
	var n_lista: int = capa._entradas_cache.size()
	_check(n_lista >= N_SINTETICAS, "lista visible con %d entradas (≥ %d)" % [n_lista, N_SINTETICAS])
	var n_edge := _contar_filas(lista)
	_check(n_edge <= capa.FILAS_VENTANA_MAX, "VIRTUALIZACIÓN: %d filas en árbol ≤ %d (L194)" % [n_edge, capa.FILAS_VENTANA_MAX])
	_check(n_edge >= capa.FILAS_VENTANA_MIN, "ventana ≥ piso (%d ≥ %d)" % [n_edge, capa.FILAS_VENTANA_MIN])
	var alto_total: float = float(esp_a.custom_minimum_size.y) + float(n_edge) * capa._paso + float(esp_b.custom_minimum_size.y)
	var alto_esperado: float = float(n_lista) * capa._paso
	_check(absf(alto_total - alto_esperado) < capa._paso, "altura de contenido ≈ n*paso (%.0f ≈ %.0f)" % [alto_total, alto_esperado])

	# ── 4) Scroll: la ventana desliza ───────────────────────────────
	var scroll = _buscar(capa, "ScrollLista")
	_check(scroll != null, "ScrollLista existe")
	_check(scroll.get_v_scroll_bar().is_connected("value_changed", Callable(capa, "_on_lista_scroll")), "value_changed del scrollbar conectado al handler")
	var mid: float = float(n_lista / 2) * capa._paso
	capa._on_lista_scroll(mid)
	var first_medio := int(floor(mid / capa._paso))
	_check(capa._first_fila == first_medio, "scroll al medio → first_fila = %d (obtuvo %d)" % [first_medio, capa._first_fila])
	var fila0 = _filas(lista)[0]
	_check(fila0 != null and String(fila0.name) == "Fila_perf_synth_%03d" % first_medio, "primera fila visible = sintética %03d" % first_medio)
	_check(float(esp_a.custom_minimum_size.y) > 0.0, "espaciador arriba > 0 tras scrollear")

	# ── 5) Pooling (M62): el conteo de nodos NO crece al deslizar ────
	var n_antes := _contar_filas(lista)
	capa._on_lista_scroll(mid + capa._paso * 3)
	var n_despues := _contar_filas(lista)
	_check(n_despues == n_antes, "POOLING (L196): mismas filas tras deslizar (%d → %d)" % [n_antes, n_despues])

	# ── 6) LazyLoad (L195): 1 categoría materializada por refresco ───
	var antes: int = diary.debug_llamadas_entradas_de()
	capa._refrescar_completo()
	var delta: int = diary.debug_llamadas_entradas_de() - antes
	_check(delta <= 2, "LazyLoad: refresco ≤ 2 llamadas entradas_de (activa; las 13 no visibles NO se materializan — obtuvo %d)" % delta)
	var pg: Dictionary = diary.progreso_global()
	var vistas_manual: int = 0
	var total_manual: int = 0
	for cat in diary.get_categorias():
		var p: Dictionary = diary.progreso_categoria(cat)
		vistas_manual += int(p.get("vistas", 0))
		total_manual += int(p.get("descubiertas", 0))
	_check(int(pg.get("vistas", -1)) == vistas_manual and int(pg.get("descubiertas", -1)) == total_manual, "progreso_global == suma manual (vistas %d, total %d)" % [vistas_manual, total_manual])

	# ── Sonda roja (M55_SONDA=1): sabotaje la virtualización ────────
	# Con la variable puesta, la ventana real (≥ FILAS_VENTANA_MIN) NO puede
	# pasar la aserción de ≤ 1 fila: la suite debe FALLAR (no es un falso
	# verde) y salir con EXIT 1. Sin la variable, nunca se ejecuta.
	if OS.get_environment("M55_SONDA") == "1":
		_check(n_edge <= 1, "SONDA: virtualización sabotada (esperaba fallar: %d filas)" % n_edge)
		print("FALLO: piso no alcanzado por la sonda (%d checks)" % _checks)
		quit(1)

	# ── Restaurar el estado real del diario ─────────────────────────
	diary.restore_save_data(snap)
	capa.free()
	_resumen()

func _filas(lista: Node) -> Array:
	var res: Array = []
	if lista == null:
		return res
	for h in lista.get_children():
		if h is Button and String(h.name).begins_with("Fila_"):
			res.append(h)
	return res

func _contar_filas(lista: Node) -> int:
	return _filas(lista).size()

func _buscar(node: Node, nombre: String) -> Node:
	if node.name == nombre:
		return node
	for child in node.get_children():
		if child.name == nombre:
			return child
		var r := _buscar(child, nombre)
		if r:
			return r
	return null

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: piso de checks no alcanzado (%d < %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M55 DIARIO PERF: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
