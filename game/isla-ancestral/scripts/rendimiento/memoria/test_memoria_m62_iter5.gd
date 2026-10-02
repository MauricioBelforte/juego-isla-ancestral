# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-02
#
# M62: Memoria — Suite de la iter. 5 (Log 1187)
# Cubre lo añadido en esta iteración. NO reemplaza a test_memoria_m62.gd
# (núcleo), test_enforcement_m62.gd, test_pool_iter2.gd,
# test_memoria_m62_iter3.gd ni test_m62_liberacion.gd.
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63):
#   1. marcadores `_fin("X")` por bloque → nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` medido en verde → caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE → si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Qué cierra (checklist §K/§J):
#   A. Handshake con M63 (diseño §5.3) — L157, L160
#   B. El enforcement respeta el handshake
#   C. Cola de transición de escena — L172, L173
#   D. Cambio rápido de región — L168
#   E. Audio pedido durante una descarga — L171
#   F. Atlas: evicción LRU CON LOG — L167
#   G. Determinismo (RN9) — L113
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_memoria_m62_iter5.gd

extends SceneTree

const MODULO := "M62-iter5"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G"]
## Piso MEDIDO en verde, NO copiado (60 checks en la 1a corrida verde).
const CHECKS_MINIMOS := 60

const _SC_BUDGET := preload("res://scripts/rendimiento/memoria/budget_registry.gd")
const _SC_POOL := preload("res://scripts/rendimiento/memoria/global_pool.gd")
const _SC_UNLOAD := preload("res://scripts/rendimiento/memoria/unload_policy.gd")
const RUTA_MONITOR := "res://scripts/rendimiento/memoria/memory_monitor.gd"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M62] Suite iter. 5 (Log 1187) ===")
	_bloque_a_handshake()
	_bloque_b_enforcement_handshake()
	_bloque_c_cola_transicion()
	_bloque_d_region()
	_bloque_e_audio()
	_bloque_f_atlas_log()
	_bloque_g_determinismo()

## ── A. Handshake con M63 (diseño §5.3) ───────────────────────────────────
func _bloque_a_handshake() -> void:
	print("--- A. Handshake con M63: el 62 no descarga lo que el 63 carga ---")
	var mm = _monitor()
	var r := Resource.new()
	_check("un recurso recién creado NO está en carga", mm.esta_en_carga(r) == false)
	_check("recursos_en_carga() arranca en 0", mm.recursos_en_carga() == 0)
	mm.avisar_carga_iniciada(r)
	_check("tras avisar_carga_iniciada() está en carga", mm.esta_en_carga(r) == true)
	_check("recursos_en_carga() == 1", mm.recursos_en_carga() == 1)
	mm.avisar_carga_terminada(r)
	_check("tras avisar_carga_terminada() ya no", mm.esta_en_carga(r) == false)
	_check("recursos_en_carga() vuelve a 0", mm.recursos_en_carga() == 0)

	# El filtro VETA el candidato en carga: no se descarga y queda en la cola.
	var r_en_carga := Resource.new()
	var r_libre := Resource.new()
	mm.unload.marcar_candidato(r_en_carga, 100, 10.0)
	mm.unload.marcar_candidato(r_libre, 10, 5.0)
	mm.avisar_carga_iniciada(r_en_carga)
	var liberados: int = mm.unload.ejecutar_descarga(1000, 12, Callable(mm, "_puede_descargar"))
	_check("el recurso EN CARGA no se descarga (solo el libre)", liberados == 10,
		"liberados=%d" % liberados)
	_check("el veto se cuenta en diferidos_ultimo_lote()",
		mm.unload.diferidos_ultimo_lote() == 1, "n=%d" % mm.unload.diferidos_ultimo_lote())
	_check("el candidato vetado NO sale de la cola", mm.unload.candidatos_count() == 1,
		"n=%d" % mm.unload.candidatos_count())
	_check("descartes_por_carga() == 1", mm.descartes_por_carga() == 1)
	# Cuando el 63 avisa que terminó, el 62 ya puede descargarlo.
	mm.avisar_carga_terminada(r_en_carga)
	var liberados2: int = mm.unload.ejecutar_descarga(1000, 12, Callable(mm, "_puede_descargar"))
	_check("tras terminar la carga del 63, el 62 lo descarga", liberados2 == 100,
		"liberados=%d" % liberados2)
	_check("la cola queda vacía", mm.unload.candidatos_count() == 0)
	_fin("A")

## ── B. El enforcement respeta el handshake ───────────────────────────────
func _bloque_b_enforcement_handshake() -> void:
	print("--- B. Enforcement (nivel 3) respeta el handshake ---")
	var mm = _monitor()
	var en_carga := Resource.new()
	var libre := Resource.new()
	mm.unload.marcar_candidato(en_carga, 100, 10.0)
	mm.unload.marcar_candidato(libre, 10, 5.0)
	mm.avisar_carga_iniciada(en_carga)
	mm._enforcement(1900.0, 3)
	_check("el nivel 3 descargó el libre", mm.descartes_por_carga() >= 1,
		"descartes=%d" % mm.descartes_por_carga())
	_check("el recurso en carga SIGUE en la cola", mm.unload.candidatos_count() == 1,
		"n=%d" % mm.unload.candidatos_count())
	_check("el veto del enforcement se registra en la política",
		mm.unload.diferidos_ultimo_lote() == 1, "n=%d" % mm.unload.diferidos_ultimo_lote())
	_fin("B")

## ── C. Cola de transición de escena (L172/L173) ──────────────────────────
func _bloque_c_cola_transicion() -> void:
	print("--- C. Cola de transición: doble cambio no descarga dos veces ---")
	var mm = _monitor()
	_check("sin transición, el estado es libre", mm.transicion_en_curso() == false)
	_check("iniciar() devuelve true (arrancó)", mm.iniciar_transicion_escena("isla_a") == true)
	_check("transición en curso", mm.transicion_en_curso() == true)
	_check("la segunda se ENCOLA (devuelve false)",
		mm.iniciar_transicion_escena("isla_b") == false)
	_check("queda 1 encolada", mm.transiciones_encoladas() == 1)
	_check("se contó la doble descarga evitada", mm.doble_descarga_evitada() == 1)
	mm.terminar_transicion_escena()
	_check("al terminar, arranca la encolada sin soltar el curso",
		mm.transicion_en_curso() == true and mm.transiciones_encoladas() == 0)
	_check("1 transición completada", mm.transiciones_completadas() == 1)
	mm.terminar_transicion_escena()
	_check("la segunda también completa", mm.transiciones_completadas() == 2)
	_check("y ahora sí queda libre", mm.transicion_en_curso() == false)

	# Cancelación limpia: drena los candidatos, no deja nada colgado.
	var mm2 = _monitor()
	_sembrar_candidatos(mm2.unload, 3, 10)
	mm2.iniciar_transicion_escena("isla_c")
	var pendientes: int = mm2.cancelar_transicion_escena()
	_check("cancelar() reporta los candidatos pendientes", pendientes == 3,
		"pendientes=%d" % pendientes)
	_check("cancelar() drena la cola (nada colgado)", mm2.unload.candidatos_count() == 0,
		"n=%d" % mm2.unload.candidatos_count())
	_check("cancelar() corta la transición", mm2.transicion_en_curso() == false)
	_check("se contó la cancelación", mm2.cancelaciones_transicion() == 1)
	_check("cancelar() sin transición devuelve 0", mm2.cancelar_transicion_escena() == 0)
	_fin("C")

## ── D. Cambio rápido de región (L168) ────────────────────────────────────
func _bloque_d_region() -> void:
	print("--- D. Cambio rápido de región: detecta y FUERZA liberación ---")
	var mm = _monitor()
	_check("región inicial vacía", mm.region_actual() == "")
	_check("primer aviso sin candidatos no fuerza nada", mm.avisar_cambio_region("r1") == false)
	_check("se contó el cambio de región", mm.cambios_region() == 1)
	_check("avisar la MISMA región no cuenta como cambio",
		mm.avisar_cambio_region("r1") == false and mm.cambios_region() == 1)
	_sembrar_candidatos(mm.unload, 3, 10)
	_check("con candidatos pendientes, el cambio FUERZA la liberación",
		mm.avisar_cambio_region("r2") == true)
	_check("la cola se vació", mm.unload.candidatos_count() == 0,
		"n=%d" % mm.unload.candidatos_count())
	_check("se contó la liberación forzada", mm.liberaciones_forzadas() == 1)
	_check("region_actual() refleja la nueva", mm.region_actual() == "r2")
	_check("2 cambios de región", mm.cambios_region() == 2)
	_fin("D")

## ── E. Audio pedido durante una descarga (L171) ──────────────────────────
func _bloque_e_audio() -> void:
	print("--- E. Audio pedido mientras se descarga: diferido, no revienta ---")
	var mm = _monitor()
	_check("sin descarga en curso, el banco se reproduce",
		mm.pedir_banco_audio("bioma_selva") == "reproducir")
	mm.iniciar_descarga_audio("bioma_selva")
	_check("descargando_audio() true", mm.descargando_audio("bioma_selva") == true)
	_check("pedido DURANTE la descarga → diferido",
		mm.pedir_banco_audio("bioma_selva") == "diferido")
	_check("el banco diferido queda registrado", mm.audio_diferido_count() == 1)
	_check("bancos_audio_diferidos() lo nombra",
		mm.bancos_audio_diferidos().has("bioma_selva"))
	_check("otro banco no se ve afectado",
		mm.pedir_banco_audio("bioma_playa") == "reproducir")
	mm.terminar_descarga_audio("bioma_selva")
	_check("terminada la descarga, ya no está diferido",
		mm.descargando_audio("bioma_selva") == false)
	_check("y el pedido pasa a reproducir",
		mm.pedir_banco_audio("bioma_selva") == "reproducir")
	_fin("E")

## ── F. Atlas: evicción LRU CON LOG (L167) ────────────────────────────────
func _bloque_f_atlas_log() -> void:
	print("--- F. Atlas: evicción LRU con log del evento ---")
	var mm = _monitor()
	var entradas: Array = [
		{"nombre": "reciente", "mb": 10, "ultimo_uso": 300},
		{"nombre": "vieja", "mb": 10, "ultimo_uso": 100},
		{"nombre": "media", "mb": 10, "ultimo_uso": 200},
	]
	var evictadas: Array = mm.evictar_atlas(entradas, 30, 2)
	_check("evicta 2 por tope de entradas", evictadas.size() == 2, str(evictadas))
	_check("evicta las de uso más ANTIGUO", String(evictadas[0]["nombre"]) == "vieja",
		String(evictadas[0]["nombre"]))
	_check("y la segunda más antigua", String(evictadas[1]["nombre"]) == "media")
	_check("no evicta la reciente", not _contiene_nombre(evictadas, "reciente"))
	_check("las entradas originales siguen intactas", entradas.size() == 3)
	_check("sin entradas que evictar devuelve vacío",
		mm.evictar_atlas(entradas, 0, 0).is_empty())
	_fin("F")

## ── G. Determinismo (RN9 / L113) ─────────────────────────────────────────
func _bloque_g_determinismo() -> void:
	print("--- G. Determinismo: misma entrada -> misma decisión (RN9) ---")
	var a = _monitor()
	var b = _monitor()
	var valores: Array[float] = [0.0, 1599.0, 1600.0, 1799.0, 1800.0, 1899.0, 1900.0, 2000.0]
	var iguales := true
	for v in valores:
		if a.nivel_para(v) != b.nivel_para(v):
			iguales = false
	_check("nivel_para() idéntico en dos monitores para 8 valores", iguales)
	# El umbral 80% de 2000 = 1600 → warning; 90% = 1800 → crítico; 95% = 1900 → emergencia.
	_check("1599 MB es OK", a.nivel_para(1599.0) == 0)
	_check("1600 MB es warning (80%)", a.nivel_para(1600.0) == 1)
	_check("1800 MB es crítico (90%)", a.nivel_para(1800.0) == 2)
	_check("1900 MB es emergencia (95%)", a.nivel_para(1900.0) == 3)
	# Mismo orden de descarga en dos políticas sembradas igual.
	var u1 = _SC_UNLOAD.new()
	var u2 = _SC_UNLOAD.new()
	_sembrar_candidatos(u1, 5, 10)
	_sembrar_candidatos(u2, 5, 10)
	_check("el orden de descarga es idéntico", str(u1.previsualizar_orden()) == str(u2.previsualizar_orden()))
	var l1: int = u1.ejecutar_descarga(1000, 2)
	var l2: int = u2.ejecutar_descarga(1000, 2)
	_check("los MB liberados coinciden", l1 == l2, "%d vs %d" % [l1, l2])
	_fin("G")

## ── Utilidades ───────────────────────────────────────────────────────────

## Monitor aislado con su propio registry (no toca el autoload).
func _monitor() -> Variant:
	var b = _SC_BUDGET.new()
	b.cargar()
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
