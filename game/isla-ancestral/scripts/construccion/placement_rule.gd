# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — PlacementRule: la regla DECLARATIVA por pieza.
#
# Decision de diseno (02-Analisis §2.3): la validacion es declarativa, no un
# validador gigante con un `match` por tipo de pieza. Cada receta .tres declara
# su tamano, su soporte, su superficie valida, si necesita pared, su costo y su
# devolucion. Agregar una pieza nueva al catalogo NO toca `ConstruccionValidator`.
#
# NUCLEO PURO: extiende Resource pero no referencia VoxelTools ni nodos, de modo
# que se puede instanciar y testear en headless.

class_name PlacementRule
extends Resource

## Identificador estable (clave del catalogo y de la persistencia). Vacio = invalida.
@export var id: StringName = &""

## Nombre legible para el HUD.
@export var nombre: String = ""

## Variante de la pieza (p. ej. "esquina", "pilar", "cumbrera"). Va al save.
@export var variante: String = ""

## Familia del catalogo (RF12, bloque J). Una de `BuildCatalogDB.FAMILIAS`:
## pared / piso / techo / puerta / ventana / escalera / puente / camino /
## cerca / iluminacion / mueble / decoracion. Vacio = sin familia.
@export var familia: StringName = &""

## Huella en celdas (x, z). 1x1 = pared/piso; 1x2 = puerta; 3x1 = puente.
@export var tamano: Vector2i = Vector2i.ONE

## Altura en metros (informativa para el fantasma y la colision; 1.0 = 1 voxel).
@export var altura: float = 1.0

## Numero minimo de celdas de la base que deben apoyar en una superficie valida.
## Piso/pared = 1; techo = 2 (exige 2+ soportes); puente = 0 (va sobre agua).
@export var soportes_minimos: int = 1

## Superficies sobre las que la base puede apoyar. Valores: "terreno", "piso",
## "techo", "agua", "aire" (ver `ConstruccionMundo.superficie_en`).
@export var superficie_ok: Array[StringName] = [&"terreno", &"piso", &"techo"]

## Solo puentes: la celda debe estar en zona de AGUA.
@export var sobre_agua: bool = false

## Puertas y ventanas: exige una celda contigua con superficie "pared".
@export var requiere_pared: bool = false

## Las piezas de ruina (M25) y de evento (M73) no se demuelen/devuelven.
@export var deconstruible: bool = true

## Fraccion del costo devuelta al demoler/almacenar (0.0 - 1.0). Default 50%.
@export var devolucion: float = 0.5

## Costo en recursos de M14: { item_id: cantidad }. Vacio = gratis.
@export var costo: Dictionary = {}

## Id de bloque de M08 (`BlockType`) que se escribe en el mundo voxel. 0 = aire
## (piezas que no escriben voxel propio, p. ej. muebles decorativos).
@export var bloque: int = 0

## Ruta (res://) de la MALLA real de la pieza, para que el fantasma la muestre
## en vez de la caja de respaldo. Acepta un `.glb` (PackedScene importada) o un
## `Mesh`/`.res`. Vacio = el fantasma usa su caja de respaldo (iter. 2).
## iter. 3 (mesh real de la receta).
@export var mesh_path: String = ""

## Superficie que OFRECE la pieza ya colocada, para que otra pieza pueda apoyar
## encima: "piso" (piso/losa), "techo" (techo/cumbrera), "pared" (pared/pilar).
@export var superficie_ofrecida: StringName = &"piso"

## Modo al que pertenece la pieza: true = catalogo de decoracion (RF2).
@export var es_mueble: bool = false

## Tope suave de piezas de ESTE tipo por zona (0 = sin tope).
@export var max_por_zona: int = 0

## ── API ─────────────────────────────────────────────────────────────────

## true si la receta es usable (id no vacio).
func es_valida() -> bool:
	return id != &""

## Huella de celdas que ocuparia la pieza anclada en `celda`, con rotacion en
## pasos de 90 grados (0..3). El ancla es la esquina de menor x/z.
## En rotaciones impares (90 y 270) se intercambian ancho y fondo.
func celdas(celda: Vector3i, rotacion: int = 0) -> Array[Vector3i]:
	var paso: int = posmod(rotacion, 4)
	var dim: Vector2i = tamano
	if paso % 2 == 1:
		dim = Vector2i(tamano.y, tamano.x)
	var out: Array[Vector3i] = []
	for dx in range(maxi(1, dim.x)):
		for dz in range(maxi(1, dim.y)):
			out.append(celda + Vector3i(dx, 0, dz))
	return out

## Suma total de unidades del costo (para logs y comparaciones rapidas).
func costo_total() -> int:
	var total: int = 0
	for v in costo.values():
		total += int(v)
	return total

## Costo efectivo devuelto al demoler, por item (redondeo hacia abajo, entero).
func devolucion_por_item() -> Dictionary:
	var out: Dictionary = {}
	var frac: float = clampf(devolucion, 0.0, 1.0)
	for k in costo.keys():
		var devuelto: int = int(floor(float(int(costo[k])) * frac))
		if devuelto > 0:
			out[k] = devuelto
	return out

## Construye una regla desde un Dictionary plano (catalogos JSON / tests).
## Tolerante: campos ausentes usan el default del Resource.
static func desde_dict(d: Dictionary) -> PlacementRule:
	var r := PlacementRule.new()
	r.id = StringName(String(d.get("id", "")))
	r.nombre = String(d.get("nombre", ""))
	r.variante = String(d.get("variante", ""))
	r.familia = StringName(String(d.get("familia", "")))
	var t: Variant = d.get("tamano", null)
	if t is Vector2i:
		r.tamano = t
	elif t is Array and (t as Array).size() >= 2:
		r.tamano = Vector2i(int(t[0]), int(t[1]))
	r.altura = float(d.get("altura", 1.0))
	r.soportes_minimos = int(d.get("soportes_minimos", 1))
	var sup: Variant = d.get("superficie_ok", null)
	if sup is Array and not (sup as Array).is_empty():
		var arr: Array[StringName] = []
		for s in (sup as Array):
			arr.append(StringName(String(s)))
		r.superficie_ok = arr
	r.sobre_agua = bool(d.get("sobre_agua", false))
	r.requiere_pared = bool(d.get("requiere_pared", false))
	r.deconstruible = bool(d.get("deconstruible", true))
	r.devolucion = float(d.get("devolucion", 0.5))
	var c: Variant = d.get("costo", null)
	if c is Dictionary:
		r.costo = (c as Dictionary).duplicate()
	r.bloque = int(d.get("bloque", 0))
	r.mesh_path = String(d.get("mesh_path", ""))
	r.superficie_ofrecida = StringName(String(d.get("superficie_ofrecida", "piso")))
	r.es_mueble = bool(d.get("es_mueble", false))
	r.max_por_zona = int(d.get("max_por_zona", 0))
	return r

## Vuelca la regla a un Dictionary plano (diagnostico / catalogo serializable).
func a_dict() -> Dictionary:
	return {
		"id": String(id),
		"nombre": nombre,
		"variante": variante,
		"familia": String(familia),
		"tamano": [tamano.x, tamano.y],
		"altura": altura,
		"soportes_minimos": soportes_minimos,
		"superficie_ok": superficie_ok.map(func(s: StringName) -> String: return String(s)),
		"sobre_agua": sobre_agua,
		"requiere_pared": requiere_pared,
		"deconstruible": deconstruible,
		"devolucion": devolucion,
		"costo": costo.duplicate(),
		"bloque": bloque,
		"mesh_path": mesh_path,
		"superficie_ofrecida": String(superficie_ofrecida),
		"es_mueble": es_mueble,
		"max_por_zona": max_por_zona,
	}
