# Modelo: deepseek-v4-flash (núcleo) · glm-5.3-flash (iter. 2) · DeepSeek-V4.1-Flash (iter. 3, iter. 5)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-01 · 2026-09-19 · 2026-10-02
#
# M62: Memoria — MemoryMonitor (autoload)
# Servicio único de monitoreo de memoria (RF1): muestrea memoria del motor
# y del juego, objetos vivos, nodos huérfanos, drift. Expone getters puros
# y señales para el resto de módulos. Diseño original (04-Codigo.md §2).
#
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).
#
# ── Iter. 3 (Log 1094, DeepSeek-V4.1-Flash) — 5 defectos reales corregidos ──
# 1. DENOMINADOR DEL SEMÁFORO. `_actualizar_semaforo` comparaba contra
#    `total_consumo_mb()` (consumo REPORTADO por los sistemas) con umbrales
#    0.9/1.3/1.5. El diseño §3 manda 80% / 90% / 95% sobre el PRESUPUESTO.
#    Con 0 sistemas reportando el total daba 0 y el semáforo quedaba mudo.
#    Ahora usa `budget.total_topes_mb()` y los 3 umbrales del diseño.
# 2. ENFORCEMENT. Igual: comparaba memoria real del OS contra el consumo
#    reportado → si nadie reportaba, `total <= 0` y NUNCA corría. Ahora se
#    dispara desde el mismo nivel que el semáforo (una sola fuente de verdad).
# 3. MUESTREO. `_process` muestreaba en CADA frame y hacía `_muestras.append()`
#    (+`pop_front`) → un alloc deliberado por frame, justo lo que el checklist
#    prohíbe en `_process`. El diseño §3 pide 5 s en calma y 1 s con movimiento
#    de cámara. Ahora hay muestreo por TIEMPO y un buffer circular
#    (`PackedFloat32Array` pre-dimensionado, cero allocs por frame).
# 4. DRIFT. `drift_porciento()` comparaba el primer y el último elemento de la
#    ventana de 600 frames (~10 s), no la baseline estabilizada a los 5 min
#    (diseño §6.4). Y `drift_check()` —que la API del diseño §2 promete— no
#    existía. Ahora hay baseline, `drift_check()` y señal `drift_detectado`.
# 5. PICO POR PUNTO DE INTERÉS. El checklist lo pedía (spawn/teleport/escena)
#    y no existía: sólo el pico de sesión.
# Además: las decisiones de descarga se registran en el log rotado de M103
# (`GameLogger`), cosa que el checklist daba por hecha y el código no hacía.
#
# ── Iter. 5 (Log 1187, DeepSeek-V4.1-Flash) — handshake con M63 y colas ──
# 6. HANDSHAKE CON M63 (diseño §5.3). El 62 anunciaba `recurso_descargar` pero
#    NADIE miraba si el 63 lo tenía EN CARGA: la orden se ejecutaba igual. Se
#    añaden `avisar_carga_iniciada/terminada()`, `esta_en_carga()` y un filtro
#    en `UnloadPolicy.ejecutar_descarga()` que VETA el candidato en carga (no se
#    descarga y queda en la cola para el próximo lote). Cierra L157 y L160.
# 7. COLA DE TRANSICIÓN DE ESCENA. Cambiar de escena dos veces antes de terminar
#    la transición no debe descargar dos veces: la segunda se ENCOLA y la
#    cancelación es limpia. Cierra L172 y L173.
# 8. CAMBIO RÁPIDO DE REGIÓN: el monitor lo detecta y FUERZA la liberación de
#    los candidatos pendientes. Cierra L168.
# 9. AUDIO PEDIDO DURANTE UNA DESCARGA: se difiere hasta que termina (nunca se
#    reproduce a medias ni revienta). Cierra L171.

extends Node

signal semaforo_cambiado(nivel: int)
signal presupuesto_superado(sistema: String, consumo_mb: int)
signal recurso_descargar(recurso: Resource, peso: int)
signal recurso_descargado(sistema: String, mb_liberados: int)
signal drift_detectado(porcentaje: float)

## ── Umbrales del diseño §3 (sobre el TOTAL DE TOPES del preset activo) ──
const UMBRAL_WARNING := 0.80      # nivel 1: log + evento, prepara candidatos
const UMBRAL_CRITICO := 0.90      # nivel 2: degradación suave + descarga ordenada
const UMBRAL_EMERGENCIA := 0.95   # nivel 3: descarga dura sin excepción
const OBJETIVO_DESCARGA := 0.80   # tras descargar se apunta al 80%

## ── RN3 (drift) ──
const DRIFT_MAX_PCT := 5.0
const TIEMPO_BASELINE_S := 300.0  # baseline estabilizada a los 5 min (diseño §6.4)

## ── RF1 (muestreo periódico, diseño §3) ──
const INTERVALO_CALMA_S := 5.0
const INTERVALO_MOVIMIENTO_S := 1.0
const VIGENCIA_MOVIMIENTO_S := 2.0   # cuánto dura el "hay movimiento" tras el aviso
const VENTANA_MUESTRAS := 600        # buffer circular, pre-dimensionado

## ── Alarma de pico por frame (RN3) ──
const ALARMA_PICO_MB := 200.0

## Categoría del logger (M103). Constante NOMBRADA: los enums de un autoload no
## resuelven en modo --script (pitfall §9.24). Category.SYSTEM == 1.
const LOG_CAT_SYSTEM := 1

var semaforo: int = 0  # 0 ok · 1 warning · 2 critico · 3 emergencia
var _pico_mb: float = 0.0
var budget: MemoryBudgetRegistry = null
var pool: GlobalPool = null
var unload: UnloadPolicy = null

var _muestras: PackedFloat32Array = PackedFloat32Array()
var _muestras_idx: int = 0
var _muestras_n: int = 0

var _tiempo_sesion: float = 0.0
var _acumulado_muestreo: float = 0.0
var _ultimo_movimiento: float = -1.0e9
var _baseline_mb: float = 0.0
var _picos_poi: Dictionary = {}
var _alarmas_pico: int = 0
var _ultimo_enforcement: int = 0
var _ultima_muestra: float = 0.0
var _logger: Node = null

## ── Iter. 5: handshake con M63 (diseño §5.3) ──
## instance_id del recurso -> ruta (solo para el log). Lo que el 63 tiene EN
## CARGA ahora mismo. El 62 NUNCA descarga algo que esté aquí.
var _en_carga: Dictionary = {}
var _descartes_por_carga: int = 0

## ── Iter. 5: cola de transición de escena (checklist §K L172/L173) ──
var _transicion_en_curso: bool = false
var _transiciones_encoladas: int = 0
var _transiciones_completadas: int = 0
var _doble_descarga_evitada: int = 0
var _cancelaciones_transicion: int = 0

## ── Iter. 5: cambio rápido de región (checklist §K L168) ──
var _region_actual: String = ""
var _cambios_region: int = 0
var _liberaciones_forzadas: int = 0

## ── Iter. 5: audio pedido durante una descarga (checklist §K L171) ──
var _audio_descargando: Dictionary = {}   # banco -> true
var _audio_diferido: Dictionary = {}      # banco -> true

## ── Iter. 5: evicción de atlas con log (checklist §K L167) ──
var tex: TextureMemory = null

func _ready() -> void:
	budget = MemoryBudgetRegistry.new()
	budget.cargar()
	pool = GlobalPool.new()
	unload = UnloadPolicy.new()
	_asegurar_ventana()
	_registrar_servicio()
	print("[M62] MemoryMonitor listo (preset=%s, total=%d MB)"
		% [budget.preset(), budget.total_topes_mb()])

func _registrar_servicio() -> void:
	# Un nodo fuera del árbol no puede resolver rutas absolutas: `get_node("/root/…")`
	# escupe "Can't use get_node() with absolute paths from outside the active scene
	# tree". Pasa en los runs `--script`, donde el monitor se instancia suelto.
	if not is_inside_tree():
		return
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("memoria"):
		sr.register("memoria", self)

## ── Muestreo por tiempo (diseño §3): 5 s en calma, 1 s con movimiento ──
func _process(delta: float) -> void:
	_tiempo_sesion += delta
	_acumulado_muestreo += delta
	if _acumulado_muestreo >= intervalo_muestreo():
		_acumulado_muestreo = 0.0
		muestrear_ahora()

## Intervalo vigente según haya movimiento de cámara reciente.
func intervalo_muestreo() -> float:
	return INTERVALO_MOVIMIENTO_S if camara_en_movimiento() else INTERVALO_CALMA_S

## La cámara vive en M11/M12: allí se llama a esto en cada frame con movimiento.
func avisar_movimiento_camara() -> void:
	_ultimo_movimiento = _tiempo_sesion

func camara_en_movimiento() -> bool:
	return (_tiempo_sesion - _ultimo_movimiento) <= VIGENCIA_MOVIMIENTO_S

## Fuerza una muestra (lo usa `_process` y los tests, que no tienen frames).
func muestrear_ahora() -> void:
	var actual := memoria_actual_mb()
	if actual > _pico_mb:
		_pico_mb = actual
	_registrar_muestra(actual)
	_estabilizar_baseline(actual)
	var nivel := nivel_para(actual)
	_actualizar_semaforo(nivel)
	_enforcement(actual, nivel)
	_alarma_pico(actual)
	_ultima_muestra = actual

func _registrar_muestra(valor: float) -> void:
	_asegurar_ventana()
	_muestras[_muestras_idx] = valor
	_muestras_idx = (_muestras_idx + 1) % VENTANA_MUESTRAS
	if _muestras_n < VENTANA_MUESTRAS:
		_muestras_n += 1

## Dimensiona el buffer circular de forma PEREZOSA. `_ready()` no corre si el
## monitor se instancia suelto (tests `--script`, `load(...).new()`), y entonces
## `_muestras` quedaba vacío y `_muestras[0] = …` abortaba con
## "Out of bounds set index '0' (on base: 'PackedFloat32Array')" — un SCRIPT
## ERROR que mataba la función en silencio. Tras la primera llamada `size()` ya
## es el correcto, así que NO hay allocs por frame (que es lo que el diseño
## prohíbe en `_process`).
func _asegurar_ventana() -> void:
	if _muestras.size() != VENTANA_MUESTRAS:
		_muestras.resize(VENTANA_MUESTRAS)

## Nivel del semáforo para un valor de memoria (diseño §3). Denominador =
## suma de TOPES del preset activo, no el consumo reportado.
func nivel_para(actual_mb: float) -> int:
	var total := presupuesto_total_mb()
	if total <= 0:
		return 0
	var pct := actual_mb / float(total)
	if pct >= UMBRAL_EMERGENCIA:
		return 3
	if pct >= UMBRAL_CRITICO:
		return 2
	if pct >= UMBRAL_WARNING:
		return 1
	return 0

## Presupuesto total (MB) del preset activo.
func presupuesto_total_mb() -> int:
	return budget.total_topes_mb() if budget != null else 0

## Ocupación actual como fracción del presupuesto total.
func ocupacion_porciento() -> float:
	var total := presupuesto_total_mb()
	if total <= 0:
		return 0.0
	return snappedf(memoria_actual_mb() / float(total), 0.001)

func _actualizar_semaforo(nuevo: int) -> void:
	if nuevo == semaforo:
		return
	var anterior := semaforo
	semaforo = nuevo
	emit_signal("semaforo_cambiado", nuevo)
	_log_m62("semaforo %d -> %d (actual %d MB, presupuesto %d MB)"
		% [anterior, nuevo, int(memoria_actual_mb()), presupuesto_total_mb()], 1)

## Enforcement (diseño §3): nivel 2 degradación suave, nivel 3 descarga dura.
## El nivel lo calcula `nivel_para()` — una sola fuente de verdad con el semáforo.
func _enforcement(actual_mb: float, nivel: int) -> void:
	if unload == null or budget == null:
		return
	if nivel < 2:
		_ultimo_enforcement = nivel
		return
	# Idempotente por nivel: el 2 no re-aplica si ya se aplicó; el 3 siempre.
	if nivel <= _ultimo_enforcement and nivel < 3:
		return
	var total := presupuesto_total_mb()
	if total <= 0:
		return
	var objetivo := int(float(total) * OBJETIVO_DESCARGA)
	var max_por_frame := unload.max_por_frame_para(budget.preset())
	var liberados := unload.ejecutar_descarga(objetivo, max_por_frame, _puede_descargar)
	var etiqueta := "DURO" if nivel == 3 else "SUAVE"
	print("[M62] enforcement %s: actual=%d MB presupuesto=%d MB — descargados %d objetos"
		% [etiqueta, int(actual_mb), total, liberados])
	_log_m62("enforcement %s: actual=%d MB presupuesto=%d MB descargados=%d"
		% [etiqueta, int(actual_mb), total, liberados], 2 if nivel == 3 else 1)
	emit_signal("recurso_descargado", "enforcement_%s" % etiqueta.to_lower(), liberados)
	_ultimo_enforcement = nivel

## ── Handshake con M63 (diseño §5.3) ─────────────────────────────────────
## El 63 avisa qué está cargando. El 62 NO descarga un recurso en carga: la
## orden se DESCARTA y el candidato queda en la cola para el próximo lote.
func avisar_carga_iniciada(recurso: Resource) -> void:
	if recurso == null:
		return
	_en_carga[recurso.get_instance_id()] = recurso.resource_path

func avisar_carga_terminada(recurso: Resource) -> void:
	if recurso == null:
		return
	_en_carga.erase(recurso.get_instance_id())

func esta_en_carga(recurso: Resource) -> bool:
	return recurso != null and _en_carga.has(recurso.get_instance_id())

## Filtro que `UnloadPolicy` consulta por candidato. Devuelve false = vetar.
func _puede_descargar(recurso: Resource) -> bool:
	if esta_en_carga(recurso):
		_descartes_por_carga += 1
		_log_m62("descarga DESCARTADA: recurso en carga por M63 (%s)"
			% recurso.resource_path, 1)
		return false
	return true

func recursos_en_carga() -> int:
	return _en_carga.size()

func descartes_por_carga() -> int:
	return _descartes_por_carga

## ── Cola de transición de escena (checklist §K L172/L173) ────────────────
## Cambiar de escena dos veces antes de terminar la transición no debe
## descargar dos veces: la segunda se ENCOLA.
func iniciar_transicion_escena(destino: String = "") -> bool:
	if _transicion_en_curso:
		_transiciones_encoladas += 1
		_doble_descarga_evitada += 1
		_log_m62("transición a '%s' ENCOLADA (ya hay una en curso)" % destino, 1)
		return false
	_transicion_en_curso = true
	_log_m62("transición a '%s' iniciada" % destino, 1)
	return true

func terminar_transicion_escena() -> void:
	if not _transicion_en_curso:
		return
	_transiciones_completadas += 1
	if _transiciones_encoladas > 0:
		# Arranca la encolada SIN volver a descargar nada: eso es lo que evita
		# la doble descarga. La transición sigue en curso.
		_transiciones_encoladas -= 1
		return
	_transicion_en_curso = false

func transicion_en_curso() -> bool:
	return _transicion_en_curso

func transiciones_completadas() -> int:
	return _transiciones_completadas

func transiciones_encoladas() -> int:
	return _transiciones_encoladas

func doble_descarga_evitada() -> int:
	return _doble_descarga_evitada

## Cancelación limpia: corta la transición y drena los candidatos pendientes.
## Devuelve cuántos candidatos había pendientes (ninguno queda colgado).
func cancelar_transicion_escena() -> int:
	if not _transicion_en_curso and _transiciones_encoladas == 0:
		return 0
	_transicion_en_curso = false
	_transiciones_encoladas = 0
	_cancelaciones_transicion += 1
	var pendientes := unload.candidatos_count() if unload != null else 0
	if unload != null and pendientes > 0:
		var total := presupuesto_total_mb()
		if total > 0:
			var max_pf := unload.max_por_frame_para(budget.preset()) if budget != null else 3
			unload.ejecutar_descarga(int(float(total) * OBJETIVO_DESCARGA), max_pf, _puede_descargar)
	_log_m62("transición CANCELADA: %d candidatos drenados" % pendientes, 1)
	return pendientes

func cancelaciones_transicion() -> int:
	return _cancelaciones_transicion

## ── Cambio rápido de región (checklist §K L168) ──────────────────────────
## El monitor DETECTA el cambio de región y, si hay candidatos pendientes,
## FUERZA su liberación (no espera a que el semáforo llegue al 90%).
## Devuelve true si forzó una liberación.
func avisar_cambio_region(region: String) -> bool:
	if region == _region_actual:
		return false
	_region_actual = region
	_cambios_region += 1
	if unload == null or unload.candidatos_count() == 0:
		return false
	var total := presupuesto_total_mb()
	if total <= 0:
		return false
	var objetivo := int(float(total) * OBJETIVO_DESCARGA)
	var max_pf := unload.max_por_frame_para(budget.preset()) if budget != null else 3
	var liberados := unload.ejecutar_descarga(objetivo, max_pf, _puede_descargar)
	if liberados > 0:
		_liberaciones_forzadas += 1
		_log_m62("cambio de región '%s': liberación FORZADA de %d MB" % [region, liberados], 1)
	return liberados > 0

func region_actual() -> String:
	return _region_actual

func cambios_region() -> int:
	return _cambios_region

func liberaciones_forzadas() -> int:
	return _liberaciones_forzadas

## ── Audio pedido durante una descarga (checklist §K L171) ────────────────
## Si un banco se pide MIENTRAS se descarga, no se reproduce a medias: se
## DIFIERE hasta que la descarga termina. Nunca revienta.
func iniciar_descarga_audio(banco: String) -> void:
	if not banco.is_empty():
		_audio_descargando[banco] = true

func terminar_descarga_audio(banco: String) -> void:
	_audio_descargando.erase(banco)

func descargando_audio(banco: String) -> bool:
	return _audio_descargando.has(banco)

## Devuelve "reproducir" o "diferido". El caller (M42) decide qué hacer con el
## "diferido": encolarlo o silenciarlo graceful.
func pedir_banco_audio(banco: String) -> String:
	if _audio_descargando.has(banco):
		_audio_diferido[banco] = true
		return "diferido"
	return "reproducir"

func bancos_audio_diferidos() -> Array:
	var nombres: Array = _audio_diferido.keys()
	nombres.sort()
	return nombres

func audio_diferido_count() -> int:
	return _audio_diferido.size()

## ── Evicción de atlas CON LOG (checklist §K L167) ───────────────────────
## El detector puro vive en `TextureMemory`; acá se lo conecta al log (M103) y
## a la señal de descarga, para que la evicción NO sea silenciosa. El diseño §G
## pide que toda decisión de descarga quede registrada.
func evictar_atlas(entradas: Array, hasta_mb: int, max_entradas: int) -> Array:
	if tex == null:
		tex = TextureMemory.new()
	var evictadas := tex.evictar_atlas(entradas, hasta_mb, max_entradas)
	if evictadas.is_empty():
		return evictadas
	var mb := 0
	var nombres: Array[String] = []
	for e in evictadas:
		mb += int((e as Dictionary).get("mb", 0))
		nombres.append(String((e as Dictionary).get("nombre", "")))
	_log_m62("atlas: evictadas %d entradas (%d MB): %s"
		% [evictadas.size(), mb, ", ".join(nombres)], 1)
	emit_signal("recurso_descargado", "atlas", mb)
	return evictadas

## Alarma de pico (RN3): salto > 200 MB entre muestras consecutivas.
## Devuelve true si alarmó y lo cuenta en `alarmas_pico()`. Sin ese contador la
## alarma sólo era un `push_warning` y NO se podía asertar: la suite iter. 2
## tenía que conformarse con `_check(true, "…sin crash")`, que nunca falla.
func _alarma_pico(actual: float) -> bool:
	if _ultima_muestra > 0.0 and (actual - _ultima_muestra) > ALARMA_PICO_MB:
		var delta := actual - _ultima_muestra
		_alarmas_pico += 1
		push_warning("[M62] Pico de memoria > %d MB entre muestras: +%.1f MB (actual %.1f MB)"
			% [int(ALARMA_PICO_MB), delta, actual])
		_log_m62("pico +%.1f MB (actual %.1f MB)" % [delta, actual], 2)
		return true
	return false

## Cuántas alarmas de pico se dispararon en la sesión (para M110 y tests).
func alarmas_pico() -> int:
	return _alarmas_pico

## ── RN3: baseline y drift (diseño §6.4) ──

## Fija la baseline. Con `forzar=false` sólo la fija pasados los 5 min de
## sesión (el diseño pide una baseline ESTABILIZADA). Los tests usan `forzar`.
func _estabilizar_baseline(actual_mb: float, forzar: bool = false) -> void:
	if _baseline_mb > 0.0:
		return
	if forzar or _tiempo_sesion >= TIEMPO_BASELINE_S:
		_baseline_mb = actual_mb
		_log_m62("baseline estabilizada en %.1f MB (t=%.0f s)" % [_baseline_mb, _tiempo_sesion], 1)

func estabilizar_baseline(forzar: bool = false) -> void:
	_estabilizar_baseline(memoria_actual_mb(), forzar)

func baseline_mb() -> float:
	return snappedf(_baseline_mb, 0.1)

func baseline_lista() -> bool:
	return _baseline_mb > 0.0

## Drift contra la baseline (%). 0.0 si todavía no hay baseline.
func drift_porciento() -> float:
	if _baseline_mb <= 0.0:
		return 0.0
	return snappedf((memoria_actual_mb() - _baseline_mb) / _baseline_mb * 100.0, 0.1)

## RN3: true si el drift está dentro de ±5%. Sin baseline devuelve **false**:
## no se puede afirmar que la sesión cumple RN3 si no hay contra qué medir.
func drift_check() -> bool:
	if not baseline_lista():
		return false
	var d := absf(drift_porciento())
	if d > DRIFT_MAX_PCT:
		emit_signal("drift_detectado", drift_porciento())
		_log_m62("drift %.1f%% supera el máximo de %.1f%% (baseline %.1f MB)"
			% [drift_porciento(), DRIFT_MAX_PCT, _baseline_mb], 2)
		return false
	return true

## ── Pico por punto de interés (spawn / teleport / escena) ──
func marcar_punto_de_interes(nombre: String) -> float:
	var actual := memoria_actual_mb()
	var previo := float(_picos_poi.get(nombre, 0.0))
	if actual > previo:
		_picos_poi[nombre] = actual
	return float(_picos_poi[nombre])

func pico_de_poi(nombre: String) -> float:
	return snappedf(float(_picos_poi.get(nombre, 0.0)), 0.1)

func puntos_de_interes() -> Array:
	var nombres: Array = _picos_poi.keys()
	nombres.sort()
	return nombres

## ── Getters puros ──
func memoria_actual_mb() -> float:
	return snappedf(float(OS.get_static_memory_usage()) / (1024.0 * 1024.0), 0.1)

func memoria_pico_mb() -> float:
	return snappedf(_pico_mb, 0.1)

func objetos_vivos() -> int:
	return Performance.get_monitor(Performance.OBJECT_COUNT)

func nodos_huerfanos() -> int:
	return Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func consumo_de(sistema: String) -> int:
	return budget.consumo_de(sistema) if budget != null else 0

func presupuesto_de(sistema: String) -> int:
	return budget.tope_de(sistema) if budget != null else 0

func muestras_registradas() -> int:
	return _muestras_n

## Copia ordenada de la ventana de muestras (para tests y para el panel M110).
func ventana_muestras() -> PackedFloat32Array:
	var salida := PackedFloat32Array()
	var n := _muestras_n
	var inicio := (_muestras_idx - n + VENTANA_MUESTRAS) % VENTANA_MUESTRAS
	for i in range(n):
		salida.append(_muestras[(inicio + i) % VENTANA_MUESTRAS])
	return salida

## ── RF3: registro de candidatos al pool/unload por sistema ──
func registrar_candidato_descarga(recurso: Resource, peso: int, distancia: float = INF) -> void:
	if unload != null:
		unload.marcar_candidato(recurso, peso, distancia)

## Reporte para M110/M103 (panel de debug y log rotado).
func exportar_reporte() -> Dictionary:
	return {
		"actual_mb": memoria_actual_mb(),
		"pico_mb": memoria_pico_mb(),
		"presupuesto_mb": presupuesto_total_mb(),
		"preset": budget.preset() if budget != null else "",
		"semaforo": semaforo,
		"drift_pct": drift_porciento(),
		"baseline_mb": baseline_mb(),
		"drift_ok": drift_check(),
		"objetos_vivos": objetos_vivos(),
		"nodos_huerfanos": nodos_huerfanos(),
		"sistemas_sobre_tope": budget.verificar() if budget != null else [],
		"puntos_de_interes": _picos_poi.duplicate(),
		"alarmas_pico": _alarmas_pico,
	}

## Registra en el log rotado de M103 (diseño §7). El autoload puede no existir
## en un run `--script`, así que se busca por ruta y se comprueba `has_method`
## antes de llamar (pitfall §9.24). Nunca un `push_warning` por muestra.
func _log_m62(mensaje: String, nivel: int) -> void:
	if _logger == null:
		# Fuera del árbol no se puede resolver `/root/GameLogger` sin escupir un
		# ERROR de ruta absoluta. En ese caso simplemente no se loguea.
		if not is_inside_tree():
			return
		_logger = get_node_or_null("/root/GameLogger")
	if _logger == null:
		return
	if not _logger.has_method("info"):
		return
	if nivel >= 2 and _logger.has_method("warning"):
		_logger.call("warning", "[M62] " + mensaje, LOG_CAT_SYSTEM)
	elif _logger.has_method("info"):
		_logger.call("info", "[M62] " + mensaje, LOG_CAT_SYSTEM)
