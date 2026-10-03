# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — ZoneRegistry: zonas AABB con permiso.
#
# Decision de diseno (02-Analisis §2.7): las zonas se declaran por region (AABB
# en celdas voxel) y el validador las consulta ANTES que las reglas de pieza.
# Permisos: edificable / protegida (parcelas NPC, ruinas M25) / narrativa / agua.
#
# Una celda pertenece a lo sumo a UNA zona efectiva: la de AABB mas pequena que
# la contiene (la mas especifica). Si ninguna la contiene -> permiso por defecto.
#
# NUCLEO PURO: solo depende de AABB/Vector3i, testeable en headless.

class_name ZoneRegistry
extends RefCounted

## Zona registrada: { "aabb": AABB, "permiso": int, "volumen": float }
var _zonas: Array = []

## Permiso de una celda que no cae en ninguna zona registrada.
var permiso_por_defecto: int = ConstruccionTipos.Permiso.EDIFICABLE

## ── Registro ────────────────────────────────────────────────────────────

## Registra una region con permiso. `aabb` usa coordenadas de CELDA (no metros):
## `AABB(Vector3(0,0,0), Vector3(3,1,3))` cubre las celdas x,z en 0..2 e y en 0.
## Una AABB de volumen <= 0 se ignora (zona degenerada).
func registrar_zona(aabb: AABB, permiso: int) -> void:
	var vol: float = aabb.size.x * aabb.size.y * aabb.size.z
	if vol <= 0.0:
		return
	_zonas.append({"aabb": aabb, "permiso": permiso, "volumen": vol})

## Borra todas las zonas (los tests parten de un registro limpio).
func limpiar() -> void:
	_zonas.clear()

## Cantidad de zonas registradas.
func cantidad() -> int:
	return _zonas.size()

## Copia superficial de la lista de zonas (diagnostico).
func zonas() -> Array:
	return _zonas.duplicate()

## ── Consulta ────────────────────────────────────────────────────────────

## Permiso de la zona MAS ESPECIFICA (menor volumen) que contiene la celda.
## Empate de volumen -> gana la registrada mas tarde (la ultima declaracion manda).
## Sin zona contenedora -> `permiso_por_defecto`.
func zona_de(celda: Vector3i) -> int:
	var mejor: int = permiso_por_defecto
	var mejor_vol: float = INF
	for z in _zonas:
		if not _contiene(z["aabb"], celda):
			continue
		var vol: float = z["volumen"]
		if vol <= mejor_vol:
			mejor_vol = vol
			mejor = int(z["permiso"])
	return mejor

## true si la celda tiene EXACTAMENTE el permiso requerido.
func permitido(requerido: int, celda: Vector3i) -> bool:
	return zona_de(celda) == requerido

## true si la celda cae dentro de alguna zona registrada (diagnostico).
func en_alguna_zona(celda: Vector3i) -> bool:
	for z in _zonas:
		if _contiene(z["aabb"], celda):
			return true
	return false

## Indice de la zona MAS ESPECIFICA que contiene la celda, o -1 si ninguna.
## Permite agrupar piezas "de la misma zona" para el tope por zona.
func id_zona_de(celda: Vector3i) -> int:
	var mejor: int = -1
	var mejor_vol: float = INF
	for i in range(_zonas.size()):
		var z: Dictionary = _zonas[i]
		if not _contiene(z["aabb"], celda):
			continue
		var vol: float = z["volumen"]
		if vol <= mejor_vol:
			mejor_vol = vol
			mejor = i
	return mejor

## ── Contencion (semantica de CELDAS) ────────────────────────────────────
## OJO (trampa medida): `AABB.has_point()` de Godot usa el borde MAXIMO
## INCLUSIVO, de modo que un AABB de tamano 2 cubriria 3 celdas enteras
## (p. ej. x en 3,4,5). Aqui la contencion es de INTERVALO SEMIABIERTO
## [pos, pos+tamano): un AABB de tamano 10 sobre x=0 cubre las celdas 0..9.
## El volumen (`size.x*size.y*size.z`) es entonces el numero exacto de celdas.
static func _contiene(aabb: AABB, celda: Vector3i) -> bool:
	var p := aabb.position
	var s := aabb.size
	return (float(celda.x) >= p.x and float(celda.x) < p.x + s.x
		and float(celda.y) >= p.y and float(celda.y) < p.y + s.y
		and float(celda.z) >= p.z and float(celda.z) < p.z + s.z)
