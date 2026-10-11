# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: HouseDecor — colocación de muebles en grid interior fino (0.25 m).
# Sin acoplar UI: validación, colocación, rotación y persistencia del grid.
extends Node
class_name HouseDecor

signal decoracion_cambiada

const CELDA_TAMANO := 0.25
const CELDAS_POR_METRO := 4  # 1.0 / 0.25

var _grid: Dictionary = {}       # Vector3i -> {mueble: String, rotacion: int}
var _habitacion_act: String = ""
var _activado: bool = false

## Activa el modo decoración.
func activar() -> void:
	_activado = true

## Desactiva el modo decoración.
func desactivar() -> void:
	_activado = false

## ¿El modo decoración está activo?
func esta_activado() -> bool:
	return _activado

## Convierte una posición mundial en celda del grid.
func mundo_a_celda(pos: Vector3) -> Vector3i:
	return Vector3i(
		int(roundf(pos.x / CELDA_TAMANO)),
		int(roundf(pos.y / CELDA_TAMANO)),
		int(roundf(pos.z / CELDA_TAMANO))
	)

## Convierte una celda en posición mundial (esquina del grid).
func celda_a_mundo(celda: Vector3i) -> Vector3:
	return Vector3(
		float(celda.x) * CELDA_TAMANO,
		float(celda.y) * CELDA_TAMANO,
		float(celda.z) * CELDA_TAMANO
	)

## Valida si un mueble puede colocarse en una celda.
## Requiere datos de mueble (FurnitureData o Dictionary con los campos).
func validar_celda(celda: Vector3i, mueble: Variant) -> Dictionary:
	if not _activado:
		return {"ok": false, "razon": "modo decoración inactivo"}
	if mueble == null:
		return {"ok": false, "razon": "mueble nulo"}
	if _grid.has(celda):
		return {"ok": false, "razon": "celda ocupada"}
	var ancho: float = float(mueble.get("ancho", 1.0))
	var profundo: float = float(mueble.get("profundo", 1.0))
	if ancho <= 0.0 or profundo <= 0.0:
		return {"ok": false, "razon": "dimensiones inválidas"}
	# Superficie que ocupa (celdas)
	var celdas: Array = _celdas_ocupadas(celda, ancho, profundo, 0)
	for c in celdas:
		if _grid.has(c):
			return {"ok": false, "razon": "solapa otro mueble"}
	# Restricción de pared: solo en el perímetro de la habitación.
	var requiere_pared: bool = bool(mueble.get("requiere_pared", false))
	if requiere_pared and not _en_borde_habitacion(celda):
		return {"ok": false, "razon": "requiere pared y no está en el borde"}
	return {"ok": true, "celdas": celdas}

## Coloca un mueble en una celda con una rotación (pasos de 90°).
## Devuelve true si se colocó.
func colocar(celda: Vector3i, mueble_id: String, rotacion: int) -> bool:
	if not _activado or mueble_id.is_empty():
		return false
	if _grid.has(celda):
		return false
	var rot_norm: int = posmod(rotacion, 4)
	_grid[celda] = {"mueble": mueble_id, "rotacion": rot_norm}
	decoracion_cambiada.emit()
	return true

## Levanta (retira) el mueble de una celda.
func levantar(celda: Vector3i) -> void:
	_grid.erase(celda)
	decoracion_cambiada.emit()

## Rota el mueble de una celda N pasos de 90°.
func rotar(celda: Vector3i, pasos: int) -> void:
	if not _grid.has(celda):
		return
	var entrada: Dictionary = _grid[celda]
	var rot_actual: int = int(entrada.get("rotacion", 0))
	entrada["rotacion"] = posmod(rot_actual + pasos, 4)
	_grid[celda] = entrada
	decoracion_cambiada.emit()

## Devuelve el mueble de una celda (o vacío).
func obtener_mueble(celda: Vector3i) -> Dictionary:
	return _grid.get(celda, {})

## Lista todas las celdas ocupadas.
func celdas_ocupadas() -> Array:
	return _grid.keys()

## Cantidad de muebles colocados.
func cantidad_muebles() -> int:
	return _grid.size()

## Estado completo para guardado (M58/M60).
func recolectar_estado() -> Dictionary:
	var lista: Array = []
	for celda in _grid:
		var entrada: Dictionary = _grid[celda]
		lista.append({
			"celda": [celda.x, celda.y, celda.z],
			"mueble": String(entrada.get("mueble", "")),
			"rotacion": int(entrada.get("rotacion", 0)),
		})
	return {"muebles": lista}

## Restaura el estado desde guardado.
func restaurar_estado(datos: Dictionary) -> void:
	_grid.clear()
	for entrada in datos.get("muebles", []):
		var arr: Array = entrada.get("celda", [0, 0, 0])
		var celda := Vector3i(int(arr[0]), int(arr[1]), int(arr[2]))
		_grid[celda] = {
			"mueble": String(entrada.get("mueble", "")),
			"rotacion": int(entrada.get("rotacion", 0)),
		}

## Celdas que ocupa un mueble según sus dimensiones y rotación.
func _celdas_ocupadas(origen: Vector3i, ancho: float, profundo: float, rotacion: int) -> Array:
	var celdas: Array = []
	var pasos_x: int = int(ceilf(ancho * float(CELDAS_POR_METRO)))
	var pasos_z: int = int(ceilf(profundo * float(CELDAS_POR_METRO)))
	# Rotación impar intercambia ancho/profundo
	if posmod(rotacion, 2) == 1:
		var tmp: int = pasos_x
		pasos_x = pasos_z
		pasos_z = tmp
	for dx in pasos_x:
		for dz in pasos_z:
			celdas.append(Vector3i(origen.x + dx, origen.y, origen.z + dz))
	return celdas

## ¿La celda está en el borde de la habitación activa? (stub: perímetro 8x8)
func _en_borde_habitacion(celda: Vector3i) -> bool:
	const BORDE := 31  # 8 m / 0.25 m = 32 celdas → perímetro en 0 y 31
	return celda.x <= 0 or celda.x >= BORDE or celda.z <= 0 or celda.z >= BORDE
