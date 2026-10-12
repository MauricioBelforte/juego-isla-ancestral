# M49 Iluminación — LightPool (pool de luces dinámicas).
# Modelo: stepfun-step-5-preview
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# Implementa 03-Diseno.md §1 (dynamic/light_pool.gd) y §3.2:
#   * tope total por escena: MAX_DINAMICAS = 20
#   * tope con sombra por escena: MAX_CONT_SOMBRA = 6
#   * descarte por distancia: RADIO_DESCARTE = 30 m (M61)
#   * flicker determinista (fase + semilla), <= 2 Hz y <= 15 % de amplitud (G56/H63)
#
# Regla anti-oscuridad: nunca se desactiva una luz si eso dejaría la escena sin
# ninguna luz activa (J74: ambiente >= 0.15 garantizado por el perfil, no por el pool).
#
# Sin class_name: se accede por ruta (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17).
# Núcleo puro: testeable en headless sin luces reales (LV_DUMMY).

extends Node

## Tope total de luces dinámicas por escena (03-Diseno.md §3.2).
const MAX_DINAMICAS: int = 20
## Tope de luces dinámicas CON sombra por escena (§3.2).
const MAX_CONT_SOMBRA: int = 6
## Radio de descarte por distancia a la cámara (§3.2, M61).
const RADIO_DESCARTE: float = 30.0

## Flicker: diseño M49 §3.2 (frecuencia <= 2 Hz, amplitud <= 15 %).
const FLICKER_HZ_MAX: float = 2.0
const FLICKER_AMPLITUD_MAX: float = 0.15

## Tipos de luz del catálogo de diseño (03-Diseno.md §1 dynamic/).
const TIPOS: Dictionary = {
	"luz_farol": {"hz": 0.9, "amplitud": 0.10, "sombra": true, "alcance": 12.0, "energia": 1.0},
	"luz_fuego": {"hz": 1.7, "amplitud": 0.14, "sombra": true, "alcance": 9.0, "energia": 1.2},
	"luz_cristal": {"hz": 0.5, "amplitud": 0.06, "sombra": false, "alcance": 7.0, "energia": 0.8},
	"linterna": {"hz": 0.0, "amplitud": 0.0, "sombra": true, "alcance": 18.0, "energia": 1.5},
}

## Una entrada del pool.
class Entrada:
	extends RefCounted
	var tipo: StringName = &""
	var posicion: Vector3 = Vector3.ZERO
	var luz: Node3D = null
	var activa: bool = false
	var con_sombra: bool = false
	var fase: float = 0.0
	var semilla: int = 0
	var energia_base: float = 1.0
	var usos: int = 0
	# Config heredada del tipo (para flicker y QA).
	var alcance: float = 10.0
	var hz: float = 0.0
	var amplitud: float = 0.0

var _libres: Array[Entrada] = []
var _activas: Array[Entrada] = []
var _creadas_totales: int = 0
var _descartes: int = 0
var _rechazos_tope: int = 0
var _semilla: int = 12345

# ── API ──────────────────────────────────────────────────────────────────

## Semilla del flicker determinista (misma semilla + misma fase = mismo flicker).
func set_semilla(s: int) -> void:
	_semilla = s

## Obtiene una luz del pool para `tipo` en `pos`.
## 1) reutiliza una libre del tipo si existe;
## 2) si no, crea una nueva respetando MAX_DINAMICAS;
## 3) si el pool está lleno, devuelve null (NO se roba una luz activa: el
##    jugador nunca pierde la que ya tiene).
func obtener(tipo: StringName, pos: Vector3) -> Entrada:
	var cfg: Dictionary = TIPOS.get(String(tipo), {})
	var sombra: bool = bool(cfg.get("sombra", false))
	# Reutilización: primero una libre del mismo tipo.
	for e in _libres:
		if e.tipo == tipo:
			_libres.erase(e)
			_activar(e, pos, sombra)
			return e
	# Creación nueva con topes.
	if _activas.size() >= MAX_DINAMICAS:
		_rechazos_tope += 1
		return null
	if sombra and _contar_con_sombra() >= MAX_CONT_SOMBRA:
		# El tope de sombra no bloquea la luz: se crea SIN sombra (degrada).
		sombra = false
	var e := Entrada.new()
	e.tipo = tipo
	e.con_sombra = sombra
	e.semilla = _semilla
	e.fase = _fase_determinista(tipo, pos)
	e.energia_base = float(cfg.get("energia", 1.0))
	e.alcance = float(cfg.get("alcance", 10.0))
	e.hz = float(cfg.get("hz", 0.0))
	e.amplitud = float(cfg.get("amplitud", 0.0))
	_creadas_totales += 1
	_activar(e, pos, sombra)
	return e

## Devuelve una luz al pool (no la destruye: reutilización).
func liberar(e: Entrada) -> void:
	if e == null:
		return
	e.activa = false
	_activas.erase(e)
	if not _libres.has(e):
		_libres.append(e)

## Desactiva las luces a más de `radio` de `centro` (M61). Nunca deja la escena
## sin ninguna luz activa: si todas quedarían fuera, no descarta ninguna.
## Devuelve cuántas se desactivaron.
func desactivar_lejanas(centro: Vector3, radio: float = RADIO_DESCARTE) -> int:
	var fuera: Array[Entrada] = []
	for e in _activas:
		if e.posicion.distance_to(centro) > radio:
			fuera.append(e)
	if fuera.size() == _activas.size() and _activas.size() > 0:
		return 0  # todas quedarían fuera: no se apaga la escena
	for e in fuera:
		e.activa = false
		_activas.erase(e)
		_libres.append(e)
	_descartes += fuera.size()
	return fuera.size()

## Aplica el flicker determinista de una luz en el tiempo `t` (segundos).
## Devuelve el factor de energía [1-amplitud, 1+amplitud].
func flicker(e: Entrada, t: float) -> float:
	if e == null or e.hz <= 0.0 or e.amplitud <= 0.0:
		return 1.0
	var ang: float = (t * e.hz + e.fase) * TAU
	return 1.0 + (sin(ang) * e.amplitud)

## Métricas para QA y profiler.
func stats() -> Dictionary:
	return {
		"activas": _activas.size(),
		"libres": _libres.size(),
		"creadas": _creadas_totales,
		"descartes": _descartes,
		"rechazos_tope": _rechazos_tope,
		"con_sombra": _contar_con_sombra(),
	}

func activas() -> Array:
	return _activas.duplicate()

func contar_con_sombra_publico() -> int:
	return _contar_con_sombra()

func vaciar() -> void:
	_libres.clear()
	_activas.clear()

# ── internos ─────────────────────────────────────────────────────────────

func _activar(e: Entrada, pos: Vector3, sombra: bool) -> void:
	e.posicion = pos
	e.activa = true
	e.con_sombra = sombra
	e.usos += 1
	if not _activas.has(e):
		_activas.append(e)

func _contar_con_sombra() -> int:
	var n: int = 0
	for e in _activas:
		if e.con_sombra:
			n += 1
	return n

## Fase determinista por tipo+posición: mismo semilla y misma posición => misma fase.
func _fase_determinista(tipo: StringName, pos: Vector3) -> float:
	var h: int = _semilla
	h = h * 31 + hash(String(tipo))
	h = h * 31 + int(pos.x * 100.0)
	h = h * 31 + int(pos.y * 100.0)
	h = h * 31 + int(pos.z * 100.0)
	return absf(float(h % 1000) / 1000.0)

## Verificación estática de los límites de flicker del catálogo (G56/H63).
static func catalogo_valido() -> Array:
	var errores: Array = []
	for tipo in TIPOS.keys():
		var cfg: Dictionary = TIPOS[tipo]
		if float(cfg.get("hz", 0.0)) > FLICKER_HZ_MAX:
			errores.append("%s: hz %.2f > %.2f" % [tipo, float(cfg["hz"]), FLICKER_HZ_MAX])
		if float(cfg.get("amplitud", 0.0)) > FLICKER_AMPLITUD_MAX:
			errores.append("%s: amplitud %.2f > %.2f" % [tipo, float(cfg["amplitud"]), FLICKER_AMPLITUD_MAX])
	return errores
