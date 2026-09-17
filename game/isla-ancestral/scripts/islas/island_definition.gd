# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M27: Islas del Mundo — IslandDefinition (Resource).
# Datos INMUTABLES de una isla: identidad, losa (radio/alturas/playa), biomas,
# contenido exclusivo y puntos de llegada/partida.
#
# Dos campos son RUNTIME y no se serializan en el .tres (los puebla M10):
#   - `ancla`        (Vector3i centro en voxels del mundo)
#   - `semilla_isla` (derivada de la semilla de partida, PRNG de M10)
#
# Desviación documentada del diseño: `desbloqueo: Callable` NO es serializable
# en un `.tres`, así que se reemplaza por `desbloqueo_flag: StringName` (la flag
# de WorldState que evalúa M22). El efecto es el mismo y el dato es editable.

class_name IslandDefinition
extends Resource

## Catálogo de biomas de M09 (índice = id entero).
## M09 documenta 13 biomas por NOMBRE pero todavía no expone ids numéricos
## (03-Diseno §2 de M09). M27 fija este mapeo estable para poder serializar
## `bioma_base: int` en los `.tres`; los consumidores (M09/M32/M50) pueden
## resolver el nombre con `bioma_nombre()`. Orden = el del catálogo de M09.
const BIOMAS: Array[String] = [
	"Costa", "Pradera", "Bosque", "Humedal", "Valle", "Montaña", "Cumbre",
	"Desierto", "Nevado", "Volcánico", "Tropical", "Ruinas", "Resonancia",
]

## ── Identidad ─────────────────────────────────────────────
@export var id: StringName = &""
## Clave de localización (M87): "M27.ISLA.<id>.NOMBRE".
@export var nombre_clave: String = ""
## Texto en español: fallback si M87 no está y valor de los tests.
@export var nombre_display: String = ""
## Lore para el diario (M55).
@export_multiline var descripcion: String = ""

## ── Losa (voxel) ──────────────────────────────────────────
@export var radio: int = 160
@export var altura_min: int = 10
@export var altura_max: int = 96
@export var playa_ancho: int = 8

## ── Biomas (ids de M09) ───────────────────────────────────
@export var bioma_base: int = 0
@export var biomas_mezcla: Array[int] = []
## Proporciones de `biomas_mezcla` (misma longitud; suma ≈ 1.0).
@export var proporciones_mezcla: Array[float] = []

## ── Ambiente ──────────────────────────────────────────────
## Tendencia de clima (id de M32): la isla sesga el sorteo, no lo fuerza.
@export var clima_tendencia: int = 0
## Tema musical (clave de M41).
@export var musica_clave: StringName = &""

## ── Contenido exclusivo ───────────────────────────────────
@export var recursos_exclusivos: PackedStringArray = PackedStringArray()
@export var flora_endemica: PackedStringArray = PackedStringArray()
@export var fauna_endemica: PackedStringArray = PackedStringArray()
@export var puzzles: PackedStringArray = PackedStringArray()
@export var npc_residentes: PackedStringArray = PackedStringArray()

## ── Llegada / partida (locales, relativos al ancla) ───────
@export var punto_llegada: Vector3i = Vector3i.ZERO
@export var punto_partida: Vector3i = Vector3i.ZERO

## ── Clasificación ─────────────────────────────────────────
## IslandRing.NUCLEO | CERCANO | MEDIO | LEJANO
@export var anillo: int = IslandRing.CERCANO
## Oculta en el mapa (M54) hasta descubrirla.
@export var es_secreta: bool = false
## Islas del cielo / flotante: sin océano debajo.
@export var es_flotante: bool = false
## Flag de WorldState que desbloquea la isla (M22). Vacío = sin requisito.
@export var desbloqueo_flag: StringName = &""
## Índice del anillo visual del archipiélago (M09), informativo.
@export var orden_anillo: int = 0

## ── Runtime (NO serializado; lo puebla M10) ───────────────
var ancla: Vector3i = Vector3i.ZERO
var semilla_isla: int = 0
var ancla_asignada: bool = false


## ── Geometría ─────────────────────────────────────────────

## Nombre del bioma por índice (catálogo M09). Fuera de rango → "Desconocido".
static func bioma_nombre(indice: int) -> String:
	if indice < 0 or indice >= BIOMAS.size():
		return "Desconocido"
	return BIOMAS[indice]


func bioma_base_nombre() -> String:
	return bioma_nombre(bioma_base)


## Bounds en el plano XZ (voxels) para el streaming de M63.
func bounds_locales() -> Rect2i:
	return Rect2i(ancla.x - radio, ancla.z - radio, radio * 2, radio * 2)


## Centro del mundo en 3D, a la altura media de la losa (para POI y cámara).
func centro_mundo() -> Vector3:
	var media: float = (float(altura_min) + float(altura_max)) * 0.5
	return Vector3(float(ancla.x), media, float(ancla.z))


func punto_llegada_mundo() -> Vector3:
	return Vector3(float(ancla.x + punto_llegada.x), float(punto_llegada.y), float(ancla.z + punto_llegada.z))


func punto_partida_mundo() -> Vector3:
	return Vector3(float(ancla.x + punto_partida.x), float(punto_partida.y), float(ancla.z + punto_partida.z))


## Distancia en XZ del ancla al centro del archipiélago (para validar anillos).
func distancia_a(otro: IslandDefinition) -> float:
	if otro == null:
		return INF
	var dx: float = float(ancla.x - otro.ancla.x)
	var dz: float = float(ancla.z - otro.ancla.z)
	return sqrt(dx * dx + dz * dz)


func anillo_nombre() -> String:
	return IslandRing.nombre(anillo)


## ── Validación ────────────────────────────────────────────

## Errores de definición (vacío = válida). NO valida el ancla: eso es
## `IslandRegistry.validar_anclas()`, porque depende del resto del archipiélago.
func validar() -> Array[String]:
	var errores: Array[String] = []
	if String(id).is_empty():
		errores.append("id vacío")
	if nombre_display.strip_edges().is_empty() and nombre_clave.strip_edges().is_empty():
		errores.append("%s: sin nombre (ni display ni clave M87)" % id)
	if radio <= 0:
		errores.append("%s: radio inválido (%d)" % [id, radio])
	if altura_min < 0:
		errores.append("%s: altura_min negativa (%d)" % [id, altura_min])
	if altura_max <= altura_min:
		errores.append("%s: altura_max (%d) <= altura_min (%d)" % [id, altura_max, altura_min])
	if playa_ancho < 0:
		errores.append("%s: playa_ancho negativa (%d)" % [id, playa_ancho])
	if playa_ancho * 2 >= radio:
		errores.append("%s: playa_ancho (%d) se come el radio (%d)" % [id, playa_ancho, radio])
	if bioma_base < 0 or bioma_base >= BIOMAS.size():
		errores.append("%s: bioma_base fuera del catálogo M09 (%d)" % [id, bioma_base])
	if biomas_mezcla.size() != proporciones_mezcla.size():
		errores.append("%s: biomas_mezcla (%d) y proporciones_mezcla (%d) desalineados"
			% [id, biomas_mezcla.size(), proporciones_mezcla.size()])
	else:
		var suma: float = 0.0
		for p in proporciones_mezcla:
			if p < 0.0:
				errores.append("%s: proporción de mezcla negativa (%.3f)" % [id, p])
			suma += p
		if not proporciones_mezcla.is_empty() and absf(suma - 1.0) > 0.05:
			errores.append("%s: proporciones de mezcla suman %.3f (se espera ≈ 1.0)" % [id, suma])
	if not IslandRing.es_valido(anillo):
		errores.append("%s: anillo inválido (%d)" % [id, anillo])
	if anillo == IslandRing.NUCLEO and es_secreta:
		errores.append("%s: la isla NÚCLEO no puede ser secreta" % id)
	if es_flotante and punto_llegada.y <= altura_max:
		errores.append("%s: isla flotante con punto de llegada bajo la losa (y=%d <= %d)"
			% [id, punto_llegada.y, altura_max])
	# Los puntos de llegada/partida deben caer dentro del disco de la isla.
	for par in [["llegada", punto_llegada], ["partida", punto_partida]]:
		var etiqueta: String = par[0]
		var p: Vector3i = par[1]
		var d: float = sqrt(float(p.x * p.x + p.z * p.z))
		if d > float(radio) - float(playa_ancho):
			errores.append("%s: punto de %s fuera del disco (d=%.0f > %d)"
				% [id, etiqueta, d, radio - playa_ancho])
	return errores


func es_valida() -> bool:
	return validar().is_empty()


## Huella determinista de la definición (para auditoría/CI).
func huella() -> String:
	return "%s|%d|%d|%d|%d|%d|%d|%d|%s" % [
		id, radio, altura_min, altura_max, playa_ancho, bioma_base, anillo,
		(int(es_secreta) | (int(es_flotante) << 1)),
		",".join(recursos_exclusivos),
	]


func a_diccionario() -> Dictionary:
	return {
		"id": String(id),
		"nombre": nombre_display,
		"anillo": anillo_nombre(),
		"radio": radio,
		"bioma_base": bioma_base,
		"secreta": es_secreta,
		"flotante": es_flotante,
		"ancla": [ancla.x, ancla.y, ancla.z],
		"semilla_isla": semilla_isla,
	}
