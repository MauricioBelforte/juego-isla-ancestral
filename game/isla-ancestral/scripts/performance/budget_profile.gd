# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M61: Rendimiento — BudgetProfile (instrumentacion de presupuestos por categoria).
# Seccion 2.1 del 03-Diseno: marca inicio/fin de categorias, acumula tiempo en ms,
# etiqueta con el Profiler de Godot y expone lectura para diagnose y CI.
# Uso:
#   BudgetProfile.begin_section("gameplay")
#   ...trabajo...
#   BudgetProfile.end_section("gameplay")
#   BudgetProfile.get_section_ms("gameplay")   # acumulado de la ventana activa
# Overhead ~0 en release: en builds de produccion las secciones se omiten.

extends Node

const CATEGORIAS_OFICIALES := [
	"total", "gameplay", "mundo_voxel", "ia_npc", "particulas",
	"culling", "render", "ui",
]

var _activo: bool = true
var _ticks_inicio: Dictionary = {}          # categoria -> usec de inicio
var _acumulado_usec: Dictionary = {}        # categoria -> usec acumulados
var _llamadas: Dictionary = {}              # categoria -> contador
var _ventana_inicio_usec: int = 0
var _ventana_ms_total: float = 0.0

func _ready() -> void:
	# En release se desactiva la instrumentacion (overhead cero).
	_activo = not OS.has_feature("release")
	reset_profile_run()

## ── API publica ──────────────────────────────────────────

func begin_section(categoria: String) -> void:
	if not _activo:
		return
	if _ticks_inicio.has(categoria):
		push_warning("[M61] begin_section repetida sin end: " + categoria)
		return
	_ticks_inicio[categoria] = Time.get_ticks_usec()

func end_section(categoria: String) -> void:
	if not _activo:
		return
	if not _ticks_inicio.has(categoria):
		return
	var uso := Time.get_ticks_usec() - int(_ticks_inicio[categoria])
	_ticks_inicio.erase(categoria)
	_acumulado_usec[categoria] = int(_acumulado_usec.get(categoria, 0)) + uso
	_llamadas[categoria] = int(_llamadas.get(categoria, 0)) + 1

## Lectura en ms acumulada en la ventana activa (0 si no medida).
func get_section_ms(categoria: String) -> float:
	return float(_acumulado_usec.get(categoria, 0)) / 1000.0

## Lectura en ms promedio por llamada (si hubo al menos una).
func get_section_promedio_ms(categoria: String) -> float:
	var n := int(_llamadas.get(categoria, 0))
	if n == 0:
		return 0.0
	return get_section_ms(categoria) / float(n)

func get_llamadas(categoria: String) -> int:
	return int(_llamadas.get(categoria, 0))

## Todas las categorias medidas de la ventana activa (ms).
func get_resumen() -> Dictionary:
	var res := {}
	for cat in _acumulado_usec:
		res[cat] = get_section_ms(cat)
	return res

## Reinicia la ventana de medicion (lo llama la bench scene / test).
func reset_profile_run() -> void:
	_ticks_inicio.clear()
	_acumulado_usec.clear()
	_llamadas.clear()
	_ventana_inicio_usec = Time.get_ticks_usec()
	_ventana_ms_total = 0.0

## Tiempo de ventana transcurrido en ms (para CI y metrica de frames).
func ventana_ms() -> float:
	if _ventana_inicio_usec == 0:
		return 0.0
	return float(Time.get_ticks_usec() - _ventana_inicio_usec) / 1000.0

func set_activo(valor: bool) -> void:
	_activo = valor

func esta_activo() -> bool:
	return _activo
