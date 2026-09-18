# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-18
#
# M52 iter. 6 (Log 1002): VfxLoops — registro de loops ambientales.
#
# Cierra tres huecos que el checklist marcaba `[ ]`/`[?]`:
#   RF2/T-048  loops registrados con culling
#   RF4/T-061  loops con fase fija (determinismo)
#   RF9/T-097  UN emisor global por zona (no uno por chunk)
#   RF14/T-125 LOD de emisores (25% lejos)
#
# Diseño: esto es LÓGICA PURA (sin nodos ni render), así que es testeable
# headless. El nodo emisor lo crea VfxFactory/VfxPool; acá sólo se decide
# QUÉ zona emite, CON QUÉ cantidad y EN QUÉ fase del ciclo.
#
# Determinismo (RF4): la fase de un loop es el campo `fase` del catálogo, un
# valor FIJO declarado por efecto — nunca `randf()`. Dos corridas con el mismo
# catálogo y el mismo `t` dan el mismo resultado (lo verifica el test).
class_name VfxLoops
extends RefCounted

## RF14: a distancia, el emisor baja al 25% de su cantidad.
const LOD_CERCA := 1.0
const LOD_LEJOS := 0.25
## Por debajo de esta cantidad efectiva no vale la pena emitir.
const CANTIDAD_MINIMA := 4

# zona -> {vfx, posicion, radio, fase}
var _loops := {}


## Registra un loop ambiental en una zona. RF9: una zona = UN emisor, así que
## registrar dos veces la misma zona es un error de uso, no un reemplazo
## silencioso (devolver false obliga a decidir).
func registrar(vfx: Dictionary, zona: String, posicion: Vector3) -> bool:
	if zona.is_empty() or _loops.has(zona):
		return false
	if not bool(vfx.get("loop", false)):
		return false
	var radio := float(vfx.get("radio", 0.0))
	if radio <= 0.0:
		return false
	_loops[zona] = {
		"vfx": vfx,
		"posicion": posicion,
		"radio": radio,
		"fase": float(vfx.get("fase", 0.0)),
	}
	return true


func desregistrar(zona: String) -> bool:
	return _loops.erase(zona)


func tiene(zona: String) -> bool:
	return _loops.has(zona)


func zonas() -> Array:
	var z: Array = _loops.keys()
	z.sort()
	return z


func cantidad_loops() -> int:
	return _loops.size()


## Zonas cuyo radio alcanza la cámara, ordenadas por cercanía (más cerca primero).
## El culling es por distancia al CENTRO de la zona, no por chunk (RF9).
func activos(camara: Vector3) -> Array:
	var dentro: Array = []
	for zona in _loops:
		var l: Dictionary = _loops[zona]
		var d := camara.distance_to(l["posicion"])
		if d <= float(l["radio"]):
			dentro.append({"zona": zona, "distancia": d})
	dentro.sort_custom(func(a, b): return a["distancia"] < b["distancia"])
	return dentro


## RF14: factor de LOD por distancia. 1.0 dentro del 50% del radio, 0.25 fuera.
func factor_lod(vfx: Dictionary, distancia: float) -> float:
	var radio := float(vfx.get("radio", 0.0))
	if radio <= 0.0:
		return LOD_LEJOS
	return LOD_CERCA if distancia <= radio * 0.5 else LOD_LEJOS


## Cantidad a emitir por un loop vista desde la cámara (0 = no se emite).
func cantidad_efectiva(zona: String, camara: Vector3) -> int:
	if not _loops.has(zona):
		return 0
	var l: Dictionary = _loops[zona]
	var d := camara.distance_to(l["posicion"])
	if d > float(l["radio"]):
		return 0
	var vfx: Dictionary = l["vfx"]
	var n := int(round(float(vfx.get("cantidad", 0)) * factor_lod(vfx, d)))
	return n if n >= CANTIDAD_MINIMA else 0


## Posición en el ciclo [0,1) en el instante `t`, con la fase FIJA del catálogo.
## Es una función pura: sin aleatoriedad, sin estado. Dos llamadas iguales dan
## lo mismo (RF4).
func fase_en_t(vfx: Dictionary, t: float, periodo: float) -> float:
	if periodo <= 0.0:
		return float(vfx.get("fase", 0.0))
	return fposmod(float(vfx.get("fase", 0.0)) + t / periodo, 1.0)


## Fase declarada del loop de una zona (la que garantiza el determinismo).
func fase_de(zona: String) -> float:
	if not _loops.has(zona):
		return -1.0
	return float(_loops[zona]["fase"])


## Foto del estado para telemetría/log (M103): qué se está emitiendo y cuánto.
func resumen(camara: Vector3) -> Dictionary:
	var detalle: Array = []
	var total := 0
	for zona in zonas():
		var n := cantidad_efectiva(zona, camara)
		total += n
		if n > 0:
			detalle.append({"zona": zona, "cantidad": n})
	return {
		"loops_registrados": _loops.size(),
		"zonas_activas": detalle.size(),
		"particulas_totales": total,
		"detalle": detalle,
	}
