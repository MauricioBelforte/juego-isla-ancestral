# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 2 — BuildPreview: la logica del fantasma (RF3, bloque E).
#
# Separacion deliberada: `BuildPreview` es NUCLEO PURO (no es un nodo). Decide si
# la colocacion es valida, con que color se pinta y que celdas ocupa. `BuildGhost`
# (Node3D) es solo la representacion: consume el resultado de `BuildPreview`.
# Asi el comportamiento del fantasma se testea headless sin abrir una ventana.
#
# Cache: la celda objetivo se recalcula SOLO si cambio la celda o la rotacion
# (bloque E: "La celda objetivo se recalcula solo si el cursor cambio (cache)").

class_name BuildPreview
extends RefCounted

## Color del fantasma cuando la colocacion es valida (verde, semi-transparente).
const COLOR_VALIDO := Color(0.25, 0.85, 0.35, 0.45)
## Color del fantasma cuando la colocacion es invalida (rojo, semi-transparente).
const COLOR_INVALIDO := Color(0.90, 0.25, 0.20, 0.45)

var _celda: Vector3i = Vector3i.ZERO
var _rotacion: int = 0
var _receta_id: StringName = &""
var _evaluado: bool = false
var _resultado: Dictionary = {}
var _recalculos: int = 0

## ── API ─────────────────────────────────────────────────────────────────

## Evalua la receta SELECCIONADA del manager en `celda`. Devuelve un Dictionary
## con {celda, celdas, ok, valido, motivos, texto, costo, color, cache}.
## `manager` es el autoload `Construccion` (se accede por duck-typing).
func evaluar(manager, celda: Vector3i) -> Dictionary:
	var r: PlacementRule = null
	var rot: int = 0
	if manager != null and manager.has_method("receta_actual"):
		r = manager.receta_actual()
	if manager != null and manager.has_method("rotacion_actual"):
		rot = int(manager.rotacion_actual())
	return evaluar_receta(manager, r, celda, rot)

## Evalua una receta arbitraria (QA, y el propio `evaluar`).
func evaluar_receta(manager, r: PlacementRule, celda: Vector3i, rotacion: int) -> Dictionary:
	var rid: StringName = r.id if r != null else &""
	if _evaluado and celda == _celda and posmod(rotacion, 4) == _rotacion and rid == _receta_id:
		var cacheado: Dictionary = _resultado.duplicate()
		cacheado["cache"] = true
		return cacheado

	var base: Dictionary = {}
	if manager != null and manager.has_method("validar_receta") and r != null:
		base = manager.validar_receta(r, celda, rotacion)
	else:
		base = {
			"ok": false,
			"motivos": [],
			"detalle": ["sin receta o sin manager -> no evaluable"],
			"celdas": [],
		}
	var ok: bool = bool(base.get("ok", false))
	var celdas: Array = base.get("celdas", [])
	if celdas.is_empty() and r != null:
		celdas = r.celdas(celda, rotacion)

	_resultado = {
		"celda": celda,
		"rotacion": posmod(rotacion, 4),
		"receta_id": rid,
		"ok": ok,
		"valido": ok,
		"motivos": base.get("motivos", []),
		"texto": String(base.get("texto", "")),
		"detalle": base.get("detalle", []),
		"celdas": celdas,
		"costo": (r.costo.duplicate() if r != null else {}),
		"costo_total": (r.costo_total() if r != null else 0),
		"color": color_de(ok),
		"cache": false,
	}
	_celda = celda
	_rotacion = posmod(rotacion, 4)
	_receta_id = rid
	_evaluado = true
	_recalculos += 1
	return _resultado.duplicate()

## Ultimo resultado evaluado (o {} si nunca se evaluo).
func ultimo() -> Dictionary:
	return _resultado.duplicate()

## true si (celda, rotacion, receta) difieren de lo ultimo evaluado.
func cambio(celda: Vector3i, rotacion: int, receta_id: StringName) -> bool:
	if not _evaluado:
		return true
	return celda != _celda or posmod(rotacion, 4) != _rotacion or receta_id != _receta_id

## Cuantos recalculos reales se hicieron (auditoria de la cache). NO cuenta los
## aciertos de cache.
func recalculos() -> int:
	return _recalculos

func limpiar() -> void:
	_evaluado = false
	_resultado = {}
	_recalculos = 0
	_receta_id = &""

## ── Utilidades estaticas ────────────────────────────────────────────────

## Color del fantasma segun validez.
static func color_de(valido: bool) -> Color:
	return COLOR_VALIDO if valido else COLOR_INVALIDO

## Color a partir de un resultado de validacion (usa `ok`).
static func color_del_resultado(res: Dictionary) -> Color:
	return color_de(bool(res.get("ok", false)))

## Texto corto para el HUD: "OK" o el primer motivo traducido.
static func resumen(res: Dictionary) -> String:
	if bool(res.get("ok", false)):
		return "OK"
	var t: String = String(res.get("texto", ""))
	if t != "":
		return t
	var motivos: Array = res.get("motivos", [])
	if motivos.is_empty():
		return "invalido"
	return ConstruccionTipos.texto(int(motivos[0]))
