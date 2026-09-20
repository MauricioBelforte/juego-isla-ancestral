# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-19
#
# M62: Memoria — Suite de la iter. 3 (Log 1094)
# Cubre lo añadido/corregido en esta iteración. NO reemplaza a
# test_memoria_m62.gd (núcleo), test_enforcement_m62.gd ni test_pool_iter2.gd.
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque → nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde → caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE → si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime
#      (un watchdog en `_process` NO termina el proceso, trampa 61).
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_memoria_m62_iter3.gd

extends SceneTree

const MODULO := "M62-iter3"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
## Piso MEDIDO en verde, NO copiado. Valor = salida real de
##   godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/test_memoria_m62_iter3.gd
## el 2026-09-19 (Log 1094): "=== Resumen M62-iter3: 133 checks, 0 fallos ===".
## Si un bloque aborta por un SCRIPT ERROR sus checks desaparecen y el conteo
## cae por debajo de este piso -> la suite falla aunque no quede ningún [FAIL].
const CHECKS_MINIMOS := 133

const _SC_BUDGET := preload("res://scripts/rendimiento/memoria/budget_registry.gd")
const _SC_POOL := preload("res://scripts/rendimiento/memoria/global_pool.gd")
const _SC_UNLOAD := preload("res://scripts/rendimiento/memoria/unload_policy.gd")
const _SC_FACTORY := preload("res://scripts/rendimiento/memoria/pool_factory.gd")
const _SC_GUARD := preload("res://scripts/rendimiento/memoria/leak_guard.gd")
const _SC_TEX := preload("res://scripts/rendimiento/memoria/texture_memory.gd")
const RUTA_MONITOR := "res://scripts/rendimiento/memoria/memory_monitor.gd"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

## Nodo auxiliar para el detector de ciclos (propiedad que apunta a otro).
class NodoPrueba extends RefCounted:
	var vecino: Variant = null
	var etiqueta: String = ""

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M62] Suite iter. 3 (Log 1094) ===")
	_bloque_a_dataset()
	_bloque_b_semaforo()
	_bloque_c_enforcement()
	_bloque_d_muestreo()
	_bloque_e_drift()
	_bloque_f_puntos_de_interes()
	_bloque_g_pool()
	_bloque_h_leak_guard()
	_bloque_i_texturas()
	_bloque_j_descargas()
	_fin("J")

## ── A. Dataset y presets ─────────────────────────────────────────────────
func _bloque_a_dataset() -> void:
	print("--- A. Dataset: total de topes y cambio de preset ---")
	var b = _SC_BUDGET.new()
	_check("cargar() devuelve true", b.cargar() == true)
	_check("preset activo del dataset", b.preset() == "media", "preset=%s" % b.preset())
	_check("total_topes_mb media = 2000", b.total_topes_mb() == 2000, "total=%d" % b.total_topes_mb())
	_check("3 presets disponibles", b.presets_disponibles().size() == 3, str(b.presets_disponibles()))
	_check("8 sistemas", b.sistemas().size() == 8, str(b.sistemas()))
	b.set_preset("baja")
	_check("set_preset('baja') -> total 1500", b.total_topes_mb() == 1500, "total=%d" % b.total_topes_mb())
	b.set_preset("alta")
	_check("set_preset('alta') -> total 2500", b.total_topes_mb() == 2500, "total=%d" % b.total_topes_mb())
	_check("set_preset('nope') devuelve false", b.set_preset("nope") == false)
	b.set_preset("media")
	# Consumo vs topes: denominadores distintos, no confundir.
	b.reportar_consumo("voxel", 650)
	b.reportar_consumo("audio", 100)
	_check("total_consumo_mb suma lo REPORTADO (750)", b.total_consumo_mb() == 750, "total=%d" % b.total_consumo_mb())
	_check("total_topes_mb NO cambia con el consumo", b.total_topes_mb() == 2000, "total=%d" % b.total_topes_mb())
	_check("porcentaje_de(voxel) = 1.0 al tope", b.porcentaje_de("voxel") == 1.0, "pct=%f" % b.porcentaje_de("voxel"))
	_check("sistema_mas_critico = voxel", b.sistema_mas_critico() == "voxel", b.sistema_mas_critico())
	_fin("A")

## ── B. Semáforo con los umbrales del diseño §3 ───────────────────────────
func _bloque_b_semaforo() -> void:
	print("--- B. Semáforo: 80% / 90% / 95% sobre el PRESUPUESTO ---")
	var mm = _monitor()
	_check("presupuesto_total_mb = 2000", mm.presupuesto_total_mb() == 2000, "total=%d" % mm.presupuesto_total_mb())
	# Fronteras exactas sobre 2000 MB.
	_check("1599 MB -> nivel 0 (79,95%)", mm.nivel_para(1599.0) == 0, "n=%d" % mm.nivel_para(1599.0))
	_check("1600 MB -> nivel 1 (80%)", mm.nivel_para(1600.0) == 1, "n=%d" % mm.nivel_para(1600.0))
	_check("1799 MB -> nivel 1 (89,95%)", mm.nivel_para(1799.0) == 1, "n=%d" % mm.nivel_para(1799.0))
	_check("1800 MB -> nivel 2 (90%)", mm.nivel_para(1800.0) == 2, "n=%d" % mm.nivel_para(1800.0))
	_check("1899 MB -> nivel 2 (94,95%)", mm.nivel_para(1899.0) == 2, "n=%d" % mm.nivel_para(1899.0))
	_check("1900 MB -> nivel 3 (95%)", mm.nivel_para(1900.0) == 3, "n=%d" % mm.nivel_para(1900.0))
	_check("2000 MB -> nivel 3", mm.nivel_para(2000.0) == 3, "n=%d" % mm.nivel_para(2000.0))
	# El semáforo avisa al CAMBIAR, no en cada muestra.
	var avisos: Array = []
	mm.semaforo_cambiado.connect(func(n: int) -> void: avisos.append(n))
	mm._actualizar_semaforo(1)
	mm._actualizar_semaforo(1)
	mm._actualizar_semaforo(2)
	_check("semaforo_cambiado emite 1->2 sin repetir", avisos == [1, 2], str(avisos))
	_check("semaforo queda en 2", mm.semaforo == 2, "semaforo=%d" % mm.semaforo)
	# Sin presupuesto (0 sistemas) el nivel es 0: no hay contra qué medir.
	var vacio = _SC_BUDGET.new()
	var mm2 = _monitor_con(vacio)
	_check("sin topes -> nivel 0 (no inventa)", mm2.nivel_para(99999.0) == 0)
	_fin("B")

## ── C. Enforcement: una sola fuente de verdad con el semáforo ───────────
func _bloque_c_enforcement() -> void:
	print("--- C. Enforcement: suave (nivel 2) y duro (nivel 3) ---")
	var mm = _monitor()
	var unload = mm.unload
	# Nivel 1 no descarga nada.
	_sembrar_candidatos(unload, 20, 10)
	_check("nivel 1 NO descarga", mm._enforcement(1600.0, 1) == null and unload.candidatos_count() == 20,
		"candidatos=%d" % unload.candidatos_count())
	# Nivel 2 descarga con el tope por preset (media -> 12).
	mm._enforcement(1800.0, 2)
	var restantes: int = unload.candidatos_count()
	_check("nivel 2 descarga 12 (tope del preset media)", restantes == 8, "restantes=%d" % restantes)
	_check("max_por_frame_para('media') = 12", unload.max_por_frame_para("media") == 12)
	_check("resumen_ultimo_lote() describe el lote", unload.resumen_ultimo_lote() != "sin descargas")
	# Idempotencia: el nivel 2 no re-aplica.
	mm._enforcement(1800.0, 2)
	_check("nivel 2 es idempotente", unload.candidatos_count() == 8, "restantes=%d" % unload.candidatos_count())
	# El nivel 3 SÍ re-aplica siempre.
	mm._enforcement(1900.0, 3)
	_check("nivel 3 re-aplica (descarga los 8 restantes)", unload.candidatos_count() == 0,
		"restantes=%d" % unload.candidatos_count())
	# El enforcement usa el mismo nivel que el semáforo.
	_check("nivel_para(1800) alimenta el enforcement", mm.nivel_para(1800.0) == 2)
	_check("max_por_frame_para('baja') = 8", unload.max_por_frame_para("baja") == 8)
	_check("max_por_frame_para('alta') = 16", unload.max_por_frame_para("alta") == 16)
	_check("preset desconocido -> tope conservador 3", unload.max_por_frame_para("nope") == 3)
	_fin("C")

## ── D. Muestreo periódico y buffer circular ──────────────────────────────
func _bloque_d_muestreo() -> void:
	print("--- D. Muestreo: 5 s en calma, 1 s con movimiento, buffer circular ---")
	var mm = _monitor()
	_check("en calma el intervalo es 5 s", mm.intervalo_muestreo() == 5.0, "i=%f" % mm.intervalo_muestreo())
	mm.avisar_movimiento_camara()
	_check("con movimiento el intervalo es 1 s", mm.intervalo_muestreo() == 1.0, "i=%f" % mm.intervalo_muestreo())
	_check("camara_en_movimiento() true", mm.camara_en_movimiento() == true)
	mm._tiempo_sesion = 10.0   # el aviso queda viejo (>2 s)
	_check("el aviso de movimiento caduca", mm.camara_en_movimiento() == false)
	_check("vuelve al intervalo de calma", mm.intervalo_muestreo() == 5.0)
	# Buffer circular: no crece más allá de la ventana.
	_check("ventana vacía al empezar", mm.muestras_registradas() == 0)
	for i in range(5):
		mm.muestrear_ahora()
	_check("5 muestras registradas", mm.muestras_registradas() == 5, "n=%d" % mm.muestras_registradas())
	_check("ventana_muestras() devuelve 5", mm.ventana_muestras().size() == 5)
	for i in range(700):
		mm.muestrear_ahora()
	_check("la ventana se topa en 600 (no crece sin fin)", mm.muestras_registradas() == 600,
		"n=%d" % mm.muestras_registradas())
	_check("ventana_muestras() sigue en 600", mm.ventana_muestras().size() == 600)
	_check("pico de sesión > 0", mm.memoria_pico_mb() > 0.0, "pico=%f" % mm.memoria_pico_mb())
	_fin("D")

## ── E. Drift y baseline ──────────────────────────────────────────────────
func _bloque_e_drift() -> void:
	print("--- E. Drift: baseline a los 5 min y drift_check() ---")
	var mm = _monitor()
	_check("sin baseline, drift_check() es false (no se puede afirmar)", mm.drift_check() == false)
	_check("sin baseline, drift_porciento() = 0", mm.drift_porciento() == 0.0)
	_check("baseline_lista() false", mm.baseline_lista() == false)
	# El diseño pide baseline ESTABILIZADA a los 5 min: antes no se fija sola.
	mm._tiempo_sesion = 10.0
	mm.estabilizar_baseline()
	_check("a los 10 s NO se fija sola", mm.baseline_lista() == false)
	mm._tiempo_sesion = 301.0
	mm.estabilizar_baseline()
	_check("pasados 5 min se fija sola", mm.baseline_lista() == true, "baseline=%f" % mm.baseline_mb())
	_check("drift recién fijada ~0 y dentro de RN3", mm.drift_check() == true,
		"drift=%f" % mm.drift_porciento())
	# Drift real: baseline artificialmente baja -> el drift se dispara.
	var detectados: Array = []
	mm.drift_detectado.connect(func(p: float) -> void: detectados.append(p))
	mm._baseline_mb = mm.memoria_actual_mb() * 0.5
	_check("drift > 5% -> drift_check() false", mm.drift_check() == false, "drift=%f" % mm.drift_porciento())
	_check("emite drift_detectado", detectados.size() == 1, str(detectados))
	_check("drift_porciento() ronda +100%", absf(mm.drift_porciento() - 100.0) < 1.0,
		"drift=%f" % mm.drift_porciento())
	# Baseline artificialmente alta -> drift negativo, también fuera de rango.
	mm._baseline_mb = mm.memoria_actual_mb() * 2.0
	_check("drift negativo también se detecta", mm.drift_check() == false, "drift=%f" % mm.drift_porciento())
	_fin("E")

## ── F. Pico por punto de interés ─────────────────────────────────────────
func _bloque_f_puntos_de_interes() -> void:
	print("--- F. Pico por punto de interés (spawn / teleport / escena) ---")
	var mm = _monitor()
	_check("POI desconocido -> 0.0", mm.pico_de_poi("nada") == 0.0)
	_check("lista vacía al empezar", mm.puntos_de_interes().is_empty())
	var p1: float = mm.marcar_punto_de_interes("spawn_aurora")
	_check("marcar POI devuelve el valor actual", p1 > 0.0, "p=%f" % p1)
	_check("pico_de_poi lo recupera", mm.pico_de_poi("spawn_aurora") == p1)
	var p2: float = mm.marcar_punto_de_interes("spawn_aurora")
	_check("el POI nunca decrece", p2 >= p1, "%f vs %f" % [p2, p1])
	mm.marcar_punto_de_interes("teleport_extremo")
	_check("2 POIs registrados", mm.puntos_de_interes().size() == 2, str(mm.puntos_de_interes()))
	_check("el reporte incluye los POIs", (mm.exportar_reporte() as Dictionary).has("puntos_de_interes"))
	_fin("F")

## ── G. Pool: familias, precalentamiento e ítem limpio ────────────────────
func _bloque_g_pool() -> void:
	print("--- G. Pool: 6 familias, precalentamiento y contrato de ítem limpio ---")
	var fac = _SC_FACTORY.new()
	_check("6 familias del diseño §4", fac.familias().size() == 6, str(fac.familias()))
	_check("familia inválida -> false", fac.familia_valida("nada") == false)
	_check("límite de audio_voz = 24", fac.limite_de("audio_voz") == 24)
	_check("crear('particula') es GPUParticles3D", fac.crear("particula") is GPUParticles3D)
	var part = fac.crear("particula")
	_check("la partícula nace apagada", (part as GPUParticles3D).emitting == false)
	part.free()
	var lbl = fac.crear("texto_efimero")
	_check("el texto efímero nace invisible", (lbl as Label).visible == false)
	lbl.free()
	_check("crear() de familia inválida -> null", fac.crear("nada") == null)

	var pool = _SC_POOL.new()
	_check("aplicar_limites aplica 6", fac.aplicar_limites(pool) == 6)
	_check("el límite llegó al pool", pool.limite("audio_voz") == 24)
	# Precalentamiento de arranque: 8 + 8 + 4 = 20.
	var creados: int = fac.precalentar_arranque(pool)
	_check("precalentar_arranque crea 20", creados == 20, "creados=%d" % creados)
	_check("pool de particula con 8", pool.tamanio("particula") == 8, "n=%d" % pool.tamanio("particula"))
	# Contrato de ítem limpio, verificado (no asumido).
	var obj = pool.obtener("particula")
	_check("obtener() lo activa", obj != null and not pool.esta_limpio(obj))
	_check("devolver() lo deja limpio", pool.devolver("particula", obj) == true and pool.esta_limpio(obj))
	# Guarda de precalentamiento: en gameplay no se precalienta.
	pool.marcar_gameplay_iniciado()
	_check("precalentamiento_permitido() false", pool.precalentamiento_permitido() == false)
	var antes: int = pool.tamanio("particula")
	_check("precalentar en gameplay devuelve 0", pool.precalentar("particula", 5, Callable(fac, "crear").bind("particula")) == 0)
	_check("y no creció nada", pool.tamanio("particula") == antes, "%d vs %d" % [pool.tamanio("particula"), antes])
	# Holder anti-huérfanos.
	var holder := Node.new()
	root.add_child(holder)
	var pool2 = _SC_POOL.new()
	pool2.set_holder(holder)
	var n := Node.new()
	pool2.devolver("nodos", n)
	_check("el ítem estacionado cuelga del holder", n.get_parent() == holder)
	_check("no queda huérfano", _SC_GUARD.es_huerfano(n) == false)
	var sacado = pool2.obtener("nodos")
	_check("obtener() lo des-cuelga", sacado != null and sacado.get_parent() == null)
	# liberar_todo LIBERA de verdad (antes sólo vaciaba el array).
	var pool3 = _SC_POOL.new()
	var vigilado := Node.new()
	pool3.devolver("x", vigilado)
	var liberados: int = pool3.liberar_todo()
	_check("liberar_todo devuelve 1", liberados == 1, "n=%d" % liberados)
	_check("y el nodo quedó encolado para liberar", vigilado.is_queued_for_deletion() == true)
	_check("el pool quedó vacío", pool3.tamanio("x") == 0)
	holder.queue_free()
	_fin("G")

## ── H. LeakGuard ─────────────────────────────────────────────────────────
func _bloque_h_leak_guard() -> void:
	print("--- H. LeakGuard: desconexión central, timers, tweens, ciclos ---")
	var guard = _SC_GUARD.new()
	root.add_child(guard)
	var emisor := Timer.new()
	root.add_child(emisor)
	var receptor := Node.new()
	root.add_child(receptor)
	var cb := Callable(receptor, "queue_free")
	guard.conectar(emisor.timeout, cb)
	_check("la conexión existe", emisor.timeout.is_connected(cb) == true)
	_check("queda registrada", guard.conexiones_registradas() == 1)
	var res: Dictionary = guard.limpiar()
	_check("limpiar() desconecta 1", int(res["senales"]) == 1, str(res))
	_check("la señal ya no está conectada", emisor.timeout.is_connected(cb) == false)
	# Callables con bound: hay que guardar la MISMA instancia para desconectar.
	var con_bound := Callable(receptor, "queue_free").bind(1)
	_check("tiene_bound() detecta el bind", _SC_GUARD.tiene_bound(con_bound) == true)
	_check("un callable normal no tiene bound", _SC_GUARD.tiene_bound(Callable(receptor, "queue_free")) == false)
	var guard2 = _SC_GUARD.new()
	root.add_child(guard2)
	guard2.conectar(emisor.timeout, con_bound)
	_check("conexión con bound registrada", emisor.timeout.is_connected(con_bound) == true)
	guard2.limpiar()
	_check("con bound también se desconecta", emisor.timeout.is_connected(con_bound) == false)
	_check("no quedan conexiones entrantes", emisor.timeout.get_connections().is_empty() == true)
	# Timers.
	var t := Timer.new()
	root.add_child(t)
	t.start(10.0)
	var guard3 = _SC_GUARD.new()
	root.add_child(guard3)
	guard3.registrar_timer(t)
	_check("el timer corre", t.is_stopped() == false)
	var res3: Dictionary = guard3.limpiar()
	_check("limpiar() cancela el timer", t.is_stopped() == true and int(res3["timers"]) == 1, str(res3))
	# Tweens.
	var tw: Tween = t.create_tween()
	tw.set_loops()
	var guard4 = _SC_GUARD.new()
	root.add_child(guard4)
	guard4.registrar_tween(tw)
	var res4: Dictionary = guard4.limpiar()
	_check("limpiar() mata el tween", int(res4["tweens"]) == 1 and tw.is_valid() == false, str(res4))
	# _exit_tree dispara la limpieza.
	var guard5 = _SC_GUARD.new()
	root.add_child(guard5)
	guard5.conectar(emisor.timeout, cb)
	root.remove_child(guard5)
	_check("_exit_tree() limpia solo", emisor.timeout.is_connected(cb) == false)
	_check("y contó la limpieza", guard5.limpiezas >= 1, "n=%d" % guard5.limpiezas)
	# Detector de ciclos entre servicios.
	var a := NodoPrueba.new()
	var b := NodoPrueba.new()
	a.etiqueta = "a"
	b.etiqueta = "b"
	a.vecino = b
	b.vecino = a
	var ciclos: Array = _SC_GUARD.detectar_ciclos({"a": a, "b": b}, ["vecino"])
	_check("detecta el ciclo a<->b", ciclos.size() == 1 and String(ciclos[0]) == "a<->b", str(ciclos))
	b.vecino = null
	_check("sin ciclo no reporta nada", _SC_GUARD.detectar_ciclos({"a": a, "b": b}, ["vecino"]).is_empty())
	# Recursos duplicados (doble carga).
	var r1 = load("res://data/rendimiento/budgets.json")
	var r2 = ResourceLoader.load("res://data/rendimiento/budgets.json", "", ResourceLoader.CACHE_MODE_IGNORE)
	_check("dos instancias distintas del mismo recurso", r1 != r2 and r1.get_instance_id() != r2.get_instance_id())
	var dup: Array = _SC_GUARD.recursos_duplicados([r1, r2])
	_check("detecta la doble carga", dup.size() == 1, str(dup))
	_check("una sola instancia NO es duplicado", _SC_GUARD.recursos_duplicados([r1, r1]).is_empty())
	_check("contar_huerfanos() responde", _SC_GUARD.contar_huerfanos() >= 0)
	guard.queue_free()
	guard2.queue_free()
	guard3.queue_free()
	guard4.queue_free()
	guard5.queue_free()
	emisor.queue_free()
	receptor.queue_free()
	t.queue_free()
	_fin("H")

## ── I. TextureMemory ─────────────────────────────────────────────────────
func _bloque_i_texturas() -> void:
	print("--- I. Texturas: gigante sin mips, atlas LRU, nodos por frame ---")
	var tm = _SC_TEX.new()
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.4, 0.6, 1.0))
	var tex: Texture2D = ImageTexture.create_from_image(img)
	_check("peso estimado > 0", tm.peso_mb(tex) > 0.0, "mb=%f" % tm.peso_mb(tex))
	# Con el umbral por defecto (4096) no es gigante.
	_check("64 px NO es gigante con umbral 4096", tm.es_gigante(tex) == false)
	tm.umbral_lado = 64
	_check("con umbral 64 sí es gigante", tm.es_gigante(tex) == true)
	_check("nace sin mips", tm.sin_mips(tex) == true)
	_check("requiere_degradacion() true", tm.requiere_degradacion(tex) == true)
	var antes := tm.peso_mb(tex)
	var pol: Dictionary = tm.aplicar_politica(tex, 2)
	_check("la política se aplicó", bool(pol["aplicada"]) == true)
	var nueva: Texture2D = pol["textura"]
	_check("la textura degradada mide la mitad", nueva.get_width() == 32, "w=%d" % nueva.get_width())
	_check("y ahora tiene mips", tm.sin_mips(nueva) == false)
	_check("ocupa menos que antes", float(pol["mb_despues"]) < antes,
		"%f -> %f" % [antes, float(pol["mb_despues"])])
	# Segunda pasada: ya no requiere degradación (tiene mips) pero sigue siendo
	# "gigante" por el umbral de 64 px -> no vuelve a degradar por mips.
	_check("sin mips es lo que dispara la degradación", tm.requiere_degradacion(nueva) == false)
	# Atlas: evicción por orden de uso.
	var entradas: Array = [
		{"nombre": "reciente", "mb": 10, "ultimo_uso": 300},
		{"nombre": "vieja", "mb": 10, "ultimo_uso": 100},
		{"nombre": "media", "mb": 10, "ultimo_uso": 200},
	]
	var evictadas: Array = tm.evictar_atlas(entradas, 30, 2)
	_check("evicta 2 por tope de entradas", evictadas.size() == 2, str(evictadas))
	_check("evicta las de uso más ANTIGUO", String(evictadas[0]["nombre"]) == "vieja",
		String(evictadas[0]["nombre"]))
	_check("y la segunda más antigua", String(evictadas[1]["nombre"]) == "media")
	_check("no evicta la reciente", not _contiene_nombre(evictadas, "reciente"))
	_check("las 3 entradas siguen intactas", entradas.size() == 3)
	var por_peso: Array = tm.evictar_atlas(entradas, 10, 99)
	_check("con tope de MB evicta 1", por_peso.size() == 1, str(por_peso))
	# Detector de nodos por frame.
	var det = _SC_TEX.DetectorNodosPorFrame.new()
	det.umbral_por_frame = 2.0
	det.muestrear(100)
	det.muestrear(110)
	det.muestrear(120)
	_check("3 frames muestreados", det.frames_muestreados() == 3)
	_check("10 nodos por frame", absf(det.nodos_por_frame() - 10.0) < 0.001, "%f" % det.nodos_por_frame())
	_check("excede el umbral", det.excede_umbral() == true)
	_check("la alerta describe el crecimiento", det.alerta() != "")
	det.reiniciar()
	det.muestrear(500)
	det.muestrear(500)
	_check("sin crecimiento no hay alerta", det.excede_umbral() == false and det.alerta() == "")
	_fin("I")

## ── J. Descargas registradas en el log ───────────────────────────────────
func _bloque_j_descargas() -> void:
	print("--- J. Log de descargas (M103) y orden de la política ---")
	var unload = _SC_UNLOAD.new()
	_sembrar_candidatos(unload, 4, 10)
	var orden: Array = unload.previsualizar_orden()
	_check("4 candidatos en la previsualización", orden.size() == 4)
	_check("el primero es el más lejano", float(orden[0]["distancia"]) == 3.0, str(orden[0]))
	_check("previsualizar NO consume la cola", unload.candidatos_count() == 4)
	_check("antes de descargar no hay lote", unload.resumen_ultimo_lote() == "sin descargas")
	unload.ejecutar_descarga(1000, 2)
	_check("el lote registra 2 descargas", unload.ultimo_lote_count() == 2, "n=%d" % unload.ultimo_lote_count())
	_check("el resumen nombra MB y distancia", unload.resumen_ultimo_lote().contains("MB"),
		unload.resumen_ultimo_lote())
	_check("quedan 2 candidatos", unload.candidatos_count() == 2)
	var mm = _monitor()
	var rep: Dictionary = mm.exportar_reporte()
	_check("el reporte tiene las claves del panel M110",
		rep.has("semaforo") and rep.has("presupuesto_mb") and rep.has("drift_ok"), str(rep.keys()))
	_check("el reporte declara el preset", String(rep["preset"]) == "media", String(rep["preset"]))
	_fin("J")

## ── Utilidades ───────────────────────────────────────────────────────────

## Monitor aislado con su propio registry (no toca el autoload).
func _monitor() -> Variant:
	var b = _SC_BUDGET.new()
	b.cargar()
	return _monitor_con(b)

func _monitor_con(b: Variant) -> Variant:
	var mm = load(RUTA_MONITOR).new()
	mm.budget = b
	mm.unload = _SC_UNLOAD.new()
	mm.pool = _SC_POOL.new()
	return mm

## Siembra `n` candidatos de `peso` MB con distancias 0..n-1.
func _sembrar_candidatos(unload: Variant, n: int, peso: int) -> void:
	for i in range(n):
		unload.marcar_candidato(Resource.new(), peso, float(i))

func _contiene_nombre(entradas: Array, nombre: String) -> bool:
	for e in entradas:
		if String((e as Dictionary).get("nombre", "")) == nombre:
			return true
	return false

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
