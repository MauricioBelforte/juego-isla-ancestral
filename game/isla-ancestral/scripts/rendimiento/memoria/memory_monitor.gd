# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M62: Memoria — MemoryMonitor (autoload)
# Servicio único de monitoreo de memoria (RF1): muestrea memoria del motor
# y del juego, objetos vivos, nodos huérfanos, drift. Expone getters puros
# y señales para el resto de módulos. Diseño original (04-Codigo.md §2).
#
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

signal semaforo_cambiado(nivel: int)
signal presupuesto_superado(sistema: String, consumo_mb: int)
signal recurso_descargar(recurso: Resource, peso: int)
signal recurso_descargado(sistema: String, mb_liberados: int)

var semaforo: int = 0  # 0 ok · 1 warning · 2 critico · 3 emergencia
var _pico_mb: float = 0.0
var _muestras: Array = []
var budget: MemoryBudgetRegistry = null
var pool: GlobalPool = null
var unload: UnloadPolicy = null

func _ready() -> void:
	budget = MemoryBudgetRegistry.new()
	budget.cargar()
	pool = GlobalPool.new()
	unload = UnloadPolicy.new()
	_registrar_servicio()
	print("[M62] MemoryMonitor listo")

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("memoria"):
		sr.register("memoria", self)

func _process(_delta: float) -> void:
	_muestrear()

## M62 iter. 2 (glm-5.3-flash): enforcement — actual vs presupuesto total.
## Suave al 90%: descarga ordenada vía UnloadPolicy. Duro al 95%: forzada
## sin excepción (diseño §2/§3). Idempotente por nivel de semáforo.
var _ultimo_enforcement: int = 0

func _enforcement(actual_mb: float) -> void:
	if unload == null or budget == null:
		return
	var total: int = budget.total_consumo_mb()
	if total <= 0:
		return
	var nivel := 0  # 0 ok · 1 suave (90%) · 2 duro (95%)
	if actual_mb >= float(total) * 0.95:
		nivel = 2
	elif actual_mb >= float(total) * 0.90:
		nivel = 1
	if nivel == 0 or nivel <= _ultimo_enforcement and nivel < 2:
		return
	# Objetivo de descarga: bajar al 80% del presupuesto
	var objetivo := int(float(total) * 0.8)
	var liberados := unload.ejecutar_descarga(objetivo, 3)
	print("[M62] enforcement %s: actual=%d MB presupuesto=%d MB — descargados %d objetos"
		% ["DURO" if nivel == 2 else "SUAVE", int(actual_mb), total, liberados])
	_ultimo_enforcement = nivel

## Alarma de pico por frame (diseño §RN3): salto > 200 MB entre muestras
const ALARMA_PICO_MB: float = 200.0
var _ultima_muestra: float = 0.0

func _alarma_pico(actual: float) -> void:
	if _ultima_muestra > 0.0 and (actual - _ultima_muestra) > ALARMA_PICO_MB:
		push_warning("[M62] Pico de memoria > 200 MB en un frame: +%.1f MB (actual %.1f MB)"
			% [actual - _ultima_muestra, actual])

## RF3: registro de candidatos al pool/unload por sistema
func registrar_candidato_descarga(recurso: Resource, peso: int, distancia: float = INF) -> void:
	if unload != null:
		unload.marcar_candidato(recurso, peso, distancia)

func _muestrear() -> void:
	var actual := memoria_actual_mb()
	if actual > _pico_mb:
		_pico_mb = actual
	_actualizar_semaforo(actual)
	_enforcement(actual)
	_alarma_pico(actual)
	_ultima_muestra = actual
	_muestras.append(actual)
	if _muestras.size() > 600:
		_muestras.pop_front()

func memoria_actual_mb() -> float:
	return snappedf(float(OS.get_static_memory_usage()) / (1024.0 * 1024.0), 0.1)

func memoria_pico_mb() -> float:
	return snappedf(_pico_mb, 0.1)

func objetos_vivos() -> int:
	return Performance.get_monitor(Performance.OBJECT_COUNT)

func nodos_huerfanos() -> int:
	return Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func consumo_de(sistema: String) -> int:
	return budget.consumo_de(sistema) if budget else 0

func presupuesto_de(sistema: String) -> int:
	return budget.tope_de(sistema) if budget else 0

func drift_porciento() -> float:
	if _muestras.size() < 2:
		return 0.0
	var primera: float = _muestras[0]
	var ultima: float = _muestras[_muestras.size() - 1]
	if primera <= 0:
		return 0.0
	return snappedf((ultima - primera) / primera * 100.0, 0.1)

func _actualizar_semaforo(actual: float) -> void:
	var total_budget: int = budget.total_consumo_mb() if budget else 500
	var nuevo: int = 0
	if actual > total_budget * 1.5:
		nuevo = 3  # emergencia
	elif actual > total_budget * 1.3:
		nuevo = 2  # critico
	elif actual > total_budget * 0.9:
		nuevo = 1  # warning
	if nuevo != semaforo:
		semaforo = nuevo
		emit_signal("semaforo_cambiado", nuevo)