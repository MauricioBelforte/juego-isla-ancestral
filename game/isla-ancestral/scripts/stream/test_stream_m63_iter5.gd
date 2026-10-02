# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-02
#
# M63: Cargas y Streaming — Suite de la iter. 5 (Log 1192)
# Cubre lo añadido en esta iteración. NO reemplaza a test_stream.gd,
# test_stream_m63.gd, test_pausa_cargas.gd ni test_pantalla_carga.gd.
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63/119):
#   1. marcadores `_fin("X")` por bloque → nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` MEDIDO en verde → caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE → si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Qué cierra (checklist §J/§B/§F/§H/§K):
#   A. Handshake lado 63: StreamManager emite avisar_carga_iniciada/terminada (L157/L160)
#   B. Integración REAL con M62: el recurso marcado por el 63 queda vetado en M62
#   C. Anti doble carga de la misma ruta (L158)
#   D. Chunks ofrecidos como candidatos a descarga de M62
#   E. Precalentamiento del menú (§7, P9)
#   F. Streaming por región: océano/subterráneo/islas (§5, P12-P14)
#   G. Determinismo de las decisiones (§5)
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/stream/test_stream_m63_iter5.gd

extends SceneTree

const MODULO := "M63-iter5"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G"]
## Piso MEDIDO en verde (51 checks, Log 1192), NO copiado. Bajar el conteo
## (bloque abortado por SCRIPT ERROR o borrado) dispara el FAIL del piso.
const CHECKS_MINIMOS := 51

const RUTA_SHADER := "res://shaders/agua_olas.gdshader"
## Script del manager, para instanciar copias AISLADAS en el bloque E (el
## autoload acumula estado de los bloques previos y falsearía la comparación).
const StreamManagerScript := preload("res://scripts/stream/stream_manager.gd")

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M63] Suite iter. 5 (Log 1192) ===")
	var sm := root.get_node_or_null("StreamManager")
	var mm := root.get_node_or_null("MemoryMonitor")
	if sm == null or mm == null:
		_check("autoloads StreamManager + MemoryMonitor presentes", false,
			"sm=%s mm=%s" % [sm, mm])
		return
	_check("autoloads StreamManager + MemoryMonitor presentes", true)
	_bloque_a_handshake(sm, mm)
	_bloque_b_integracion_m62(sm, mm)
	_bloque_c_anti_doble_carga(sm)
	_bloque_d_chunks_candidatos(sm, mm)
	_bloque_e_precalentamiento(sm)
	_bloque_f_regiones(sm)
	_bloque_g_determinismo(sm)


## ── A. Handshake lado 63 (§5.3) ──────────────────────────────────────────
func _bloque_a_handshake(sm: Node, mm: Node) -> void:
	print("--- A. Handshake: el 63 declara qué carga; el 62 lo ve ---")
	var avisos0: int = int(sm.avisos_m62())
	var en_carga0: int = int(sm.recursos_en_carga_63())
	var r := Resource.new()
	_check("un recurso recién creado NO está en carga (63)", sm.esta_en_carga_63(r) == false)
	sm.avisar_carga_iniciada(r)
	_check("tras avisar_carga_iniciada() el 63 lo tiene", sm.esta_en_carga_63(r) == true)
	_check("recursos_en_carga_63() sube 1", sm.recursos_en_carga_63() == en_carga0 + 1,
		"%d -> %d" % [en_carga0, sm.recursos_en_carga_63()])
	_check("el aviso llegó a M62 (avisos_m62 sube 1)", int(sm.avisos_m62()) == avisos0 + 1,
		"%d -> %d" % [avisos0, int(sm.avisos_m62())])
	_check("M62 también lo ve (mm.esta_en_carga)", mm.esta_en_carga(r) == true)
	sm.avisar_carga_terminada(r)
	_check("tras avisar_carga_terminada() el 63 lo suelta", sm.esta_en_carga_63(r) == false)
	_check("M62 también lo suelta", mm.esta_en_carga(r) == false)
	# Robustez: null no rompe ni cuenta
	var avisos1: int = int(sm.avisos_m62())
	sm.avisar_carga_iniciada(null)
	sm.avisar_carga_terminada(null)
	_check("avisar con null es no-op (no cuenta ni rompe)", int(sm.avisos_m62()) == avisos1)
	_fin("A")


## ── B. Integración REAL: el veto del handshake en M62 ────────────────────
func _bloque_b_integracion_m62(sm: Node, mm: Node) -> void:
	print("--- B. El recurso que el 63 carga NO lo descarga el 62 ---")
	# Vaciar la cola de candidatos de M62 para que el conteo sea determinista.
	mm.unload.ejecutar_descarga(1000000, 1000000)
	_check("cola de candidatos de M62 vaciada", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	var r := Resource.new()
	mm.registrar_candidato_descarga(r, 100, 10.0)
	_check("el candidato entró en la cola de M62", mm.unload.candidatos_count() == 1)
	sm.avisar_carga_iniciada(r)
	var liberados: int = mm.unload.ejecutar_descarga(1000000, 1000000,
		Callable(mm, "_puede_descargar"))
	_check("M62 NO descargó el recurso en carga", mm.unload.candidatos_count() == 1,
		"n=%d liberados=%d" % [mm.unload.candidatos_count(), liberados])
	_check("el veto se registró en la política", mm.unload.diferidos_ultimo_lote() == 1,
		"n=%d" % mm.unload.diferidos_ultimo_lote())
	sm.avisar_carga_terminada(r)
	mm.unload.ejecutar_descarga(1000000, 1000000, Callable(mm, "_puede_descargar"))
	_check("al soltarlo, M62 SÍ lo descarga", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_fin("B")


## ── C. Anti doble carga de la misma ruta (L158) ──────────────────────────
func _bloque_c_anti_doble_carga(sm: Node) -> void:
	print("--- C. La misma ruta no se carga dos veces ---")
	sm.pausar_cargas()
	var n1: int = sm.precalentar_mundo({
		"forzar": true, "shaders": [RUTA_SHADER], "bancos": [], "atlas": [],
	})
	_check("la 1.ª precarga encoló 1 operación", n1 == 1, "n=%d" % n1)
	_check("la ruta queda EN VUELO", sm.esta_cargando_ruta(RUTA_SHADER) == true)
	_check("rutas_en_carga() >= 1", sm.rutas_en_carga() >= 1, "n=%d" % sm.rutas_en_carga())
	var n2: int = sm.precalentar_mundo({
		"forzar": true, "shaders": [RUTA_SHADER], "bancos": [], "atlas": [],
	})
	_check("la 2.ª precarga de la MISMA ruta NO encola (anti doble carga)", n2 == 0,
		"n=%d" % n2)
	sm.reanudar_cargas()
	# Procesar hasta que la op termine (máx 60 frames)
	for i in range(60):
		sm._process(0.016)
		if not sm.esta_cargando_ruta(RUTA_SHADER):
			break
	_check("al completarse, la ruta sale de vuelo", sm.esta_cargando_ruta(RUTA_SHADER) == false)
	_fin("C")


## ── D. Chunks ofrecidos como candidatos a M62 ────────────────────────────
func _bloque_d_chunks_candidatos(sm: Node, mm: Node) -> void:
	print("--- D. El 63 ofrece sus chunks al 62 como candidatos ---")
	mm.unload.ejecutar_descarga(1000000, 1000000)
	var antes: int = mm.unload.candidatos_count()
	var r := Resource.new()
	sm.registrar_chunk("chk_iter5_d", 77.0, r)
	_check("un chunk NUEVO con recurso se ofrece a M62",
		mm.unload.candidatos_count() == antes + 1,
		"%d -> %d" % [antes, mm.unload.candidatos_count()])
	# Re-registrar el MISMO chunk no vuelve a ofrecer (no crece la cola)
	var antes2: int = mm.unload.candidatos_count()
	sm.registrar_chunk("chk_iter5_d", 80.0, r)
	_check("re-registrar el mismo chunk NO vuelve a ofrecer",
		mm.unload.candidatos_count() == antes2,
		"%d -> %d" % [antes2, mm.unload.candidatos_count()])
	_check("el chunk sigue registrado en el LRU", sm.chunk_activo("chk_iter5_d") == true)
	_fin("D")


## ── E. Precalentamiento del menú (§7 / P9) ───────────────────────────────
## Dos mediciones complementarias:
##   (1) el AUTOLOAD real: que precalentar_mundo() encola de verdad, deja
##       `precalentado()` en true y es idempotente sin `forzar`;
##   (2) la comparación con/sin partida (§7.1) sobre INSTANCIAS AISLADAS:
##       el autoload acumula estado (rutas en vuelo de los bloques A-D) y el
##       anti doble carga (L158) "se come" el re-encolado, falseando el conteo.
##       Con copias nuevas el único factor que cambia es `hay_partida`.
func _bloque_e_precalentamiento(sm: Node) -> void:
	print("--- E. Precalentamiento: menú -> mundo ---")
	# (1) Autoload real.
	sm.pausar_cargas()
	var n_auto: int = sm.precalentar_mundo({"forzar": true, "hay_partida": false})
	_check("precalentar_mundo() (autoload) encola operaciones", n_auto > 0, "n=%d" % n_auto)
	_check("precalentado() queda en true", sm.precalentado() == true)
	_check("una 2.ª llamada sin forzar NO encola (idempotente)",
		sm.precalentar_mundo({}) == 0)
	sm.reanudar_cargas()

	# (2) Comparación limpia con instancias aisladas (§7.1).
	var sin_partida: Node = StreamManagerScript.new()
	var con_partida: Node = StreamManagerScript.new()
	var n_sin: int = sin_partida.precalentar_mundo({"hay_partida": false})
	var n_con: int = con_partida.precalentar_mundo({"hay_partida": true})
	var anillos: int = int(sin_partida.ANILLOS_SPAWN)
	_check("sin partida encola shaders + banco (n>0)", n_sin > 0, "n=%d" % n_sin)
	_check("con partida encola MÁS que sin partida", n_con > n_sin,
		"con=%d sin=%d" % [n_con, n_sin])
	_check("la diferencia es exactamente los anillos del spawn",
		n_con - n_sin == anillos, "dif=%d anillos=%d" % [n_con - n_sin, anillos])
	_check("los anillos del spawn son 3 (§7.1)", anillos == 3, "anillos=%d" % anillos)
	_check("la 2.ª instancia también quedó precalentada", con_partida.precalentado() == true)
	sin_partida.free()
	con_partida.free()

	# (3) operaciones_restantes() refleja la cola real y respeta el tope §7.2.
	sm.pausar_cargas()
	sm.precalentar_mundo({"forzar": true, "hay_partida": true})
	_check("operaciones_restantes() refleja la cola",
		sm.operaciones_restantes() == sm.cola_size(),
		"rest=%d cola=%d" % [sm.operaciones_restantes(), sm.cola_size()])
	_check("operaciones_restantes() queda bajo el tope de 'Continuar' (§7.2)",
		sm.operaciones_restantes() <= int(sm.OPERACIONES_CONTINUAR_MAX),
		"rest=%d tope=%d" % [sm.operaciones_restantes(), int(sm.OPERACIONES_CONTINUAR_MAX)])
	sm.reanudar_cargas()
	_fin("E")


## ── F. Streaming por región (§5 / P12-P14) ───────────────────────────────
func _bloque_f_regiones(sm: Node) -> void:
	print("--- F. Regiones: océano, subterráneo, islas ---")
	# Océano: 3 coronas (§5). Radio del StreamableBox = 10 m.
	_check("corona 0 (costa) a 5 m", sm.corona_oceano(5.0) == 0)
	_check("corona 1 (medio) a 20 m", sm.corona_oceano(20.0) == 1)
	_check("corona 2 (lejano) a 100 m", sm.corona_oceano(100.0) == 2)
	_check("hay exactamente 3 coronas", int(sm.CORONAS_OCEANO) == 3)
	# Subterráneo: pisos LOD 0-2 (§5)
	_check("piso 0 en superficie", sm.piso_subterraneo(-1.0) == 0)
	_check("piso 1 a 10 m de profundidad", sm.piso_subterraneo(10.0) == 1)
	_check("piso 2 a 50 m de profundidad", sm.piso_subterraneo(50.0) == 2)
	_check("hay exactamente 3 pisos", int(sm.PISOS_SUBTERRANEO) == 3)
	# Islas: StreamableBox radio 10 m (§5)
	_check("dentro del box a 5 m del centro",
		sm.dentro_streamable_box(Vector3(5, 0, 0), Vector3.ZERO) == true)
	_check("fuera del box a 20 m del centro",
		sm.dentro_streamable_box(Vector3(20, 0, 0), Vector3.ZERO) == false)
	_check("el radio del box es 10 m", is_equal_approx(sm.RADIO_STREAMABLE_BOX, 10.0))
	# Vuelo de aproximación (M28): precarga al 60% de la ruta
	_check("al 59% de la ruta NO toca precargar", sm.toca_precargar_destino(0.59) == false)
	_check("al 60% de la ruta SÍ toca precargar", sm.toca_precargar_destino(0.60) == true)
	# Encadenado al subir: no se libera el piso bajo sin LOD 0 del destino
	_check("sin LOD 0 del destino NO se libera el piso", sm.piso_liberable(2, false) == -1)
	_check("con LOD 0 del destino se libera el piso de abajo", sm.piso_liberable(2, true) == 1)
	_fin("F")


## ── G. Determinismo (§5) ─────────────────────────────────────────────────
func _bloque_g_determinismo(sm: Node) -> void:
	print("--- G. Determinismo: misma entrada -> misma decisión ---")
	var ok_coronas := true
	var ok_pisos := true
	for d in [1.0, 9.9, 10.0, 10.1, 40.0, 40.1, 500.0]:
		if sm.corona_oceano(d) != sm.corona_oceano(d):
			ok_coronas = false
		if sm.piso_subterraneo(d) != sm.piso_subterraneo(d):
			ok_pisos = false
	_check("corona_oceano() es determinista en 7 distancias", ok_coronas)
	_check("piso_subterraneo() es determinista en 7 profundidades", ok_pisos)
	# Fronteras exactas: no dependen del orden de evaluación
	_check("frontera 10 m es corona 0 (<=)",
		sm.corona_oceano(sm.RADIO_STREAMABLE_BOX) == 0)
	_check("frontera 40 m es corona 1 (<= 4x radio)",
		sm.corona_oceano(sm.RADIO_STREAMABLE_BOX * 4.0) == 1)
	_fin("G")


## ── Utilidades ───────────────────────────────────────────────────────────

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
