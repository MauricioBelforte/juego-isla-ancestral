# Modelo: step-5-kilocode
# Plataforma: Kilo Code
# Fecha: 2026-10-11
#
# M113: Escenario — FlyCamStress (sobrevuelo)
# Cierra el ítem L70 del 05-Checklist: "Definir prueba con cámara rápida
# (sobrevuelo)". Simula una cámara en movimiento continuo sobre el mundo
# poblado (45+ instancias de vegetación, el plan real de M50) y mide el
# coste por frame del recorrido, con PRNG determinista (seed 42).
#
# Mide: frames simulados, ms totales, ms/frame (p50/p95 vía la base) y la
# integridad del recorrido (todas las muestras dentro del radio esperado).
# Si la vegetación no está disponible, usa un plan sintético determinista
# (no falla: el escenario mide el recorrido, no el poblar).

class_name FlyCamStress
extends StressScenario

## Muestras del recorrido (equivalente a ~8 s a 60 fps), repetidas para que la
## medición sea estable en headless (Time.get_ticks_msec() tiene resolución de ms).
const MUESTRAS: int = 480
const PASADAS: int = 200

## Radio del sobrevuelo sobre el spawn (debe coincidir con el mundo de prueba).
const RADIO: float = 256.0
const CENTRO := Vector2(256.0, 256.0)

## Velocidad de la cámara (m/s) y delta fijo de frame (1/60 s).
const VELOCIDAD: float = 25.0
const DELTA: float = 1.0 / 60.0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _plan: Array = []
var _fuera_de_radio: int = 0

func _init() -> void:
	_nombre = "FlyCamStress"

func setup() -> void:
	_rng.seed = 42
	_fuera_de_radio = 0
	_plan = _cargar_plan()
	print("[M113] FlyCamStress: %d muestras, radio %.0f, vel %.0f m/s (seed 42)"
		% [MUESTRAS, RADIO, VELOCIDAD])

func execute() -> Dictionary:
	var total := 0.0
	for i in range(PASADAS):
		var t := _medir_ms(func(): _recorrer())
		total += float(t["ms"])
	var frame_ms: float = snappedf(total / float(MUESTRAS * PASADAS), 0.0001)
	_registrar_metrica("frame_us", frame_ms * 1000.0)
	_registrar_metrica("frame_ms", frame_ms)
	_registrar_metrica("recorrido_ms", total)
	_registrar_metrica("objetivos_visitados", float(_plan.size()))
	_registrar_metrica("integridad_ok", 1.0 if _fuera_de_radio == 0 else 0.0)
	return resumen_metricas()

## Recorre el plan de vegetación con una cámara que avanza a velocidad fija.
func _recorrer() -> bool:
	if _plan.is_empty():
		return false
	var acumulado := 0.0
	for i in range(MUESTRAS):
		var obj: Dictionary = _plan[i % _plan.size()]
		var pos := Vector2(float(obj["posicion"]["x"]), float(obj["posicion"]["z"]))
		# la cámara se acerca al objetivo a velocidad fija
		var dir := (pos - CENTRO).normalized()
		acumulado += VELOCIDAD * DELTA
		var cam := CENTRO + dir * minf(acumulado, (pos - CENTRO).length())
		if cam.distance_to(CENTRO) > RADIO + 0.001:
			_fuera_de_radio += 1
	return true

## Intenta usar el plan real de M50; si no está, arma uno sintético determinista.
func _cargar_plan() -> Array:
	var plan_node: Node = Engine.get_main_loop().root.get_node_or_null("/root/VegetationSpawner")
	if plan_node != null and plan_node.has_method("generar_plan"):
		var p: Array = plan_node.generar_plan(CENTRO, RADIO, 42)
		if not p.is_empty():
			return p
	# sintético: 45 puntos en anillo determinista (coincide con el inventario M50)
	var sintetico: Array = []
	for i in range(45):
		var ang := TAU * float(i) / 45.0
		var r := RADIO * 0.8
		sintetico.append({
			"posicion": {"x": CENTRO.x + cos(ang) * r, "z": CENTRO.y + sin(ang) * r},
			"bioma": "sintetico",
		})
	return sintetico

func teardown() -> void:
	print("[M113] FlyCamStress: teardown completado (fuera de radio: %d)" % _fuera_de_radio)
