# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — Versionador
# Versionado de esquema + migraciones automáticas (RF6/RF7/RF11).
# Cada migración es una función pura (dict -> dict), aplicada en orden estricto.
# RN4: todo campo nuevo debe tener default o migración.

class_name Versionador
extends RefCounted

## Versión actual del esquema de save. Sube con cada cambio ROTACIONAL.
const VERSION_ACTUAL: int = 1

## Migraciones en orden ascendente: migraciones[0] sube de v1 a v2.
## Se agregan al subir VERSION_ACTUAL; jamás se edita una existente.
const MIGRACIONES: Array[Callable] = [
	# migrar_v1_a_v2,  # descomentar al subir VERSION_ACTUAL a 2
]

## Migración de ejemplo (v1 -> v2), función pura testeable en aislamiento.
## Aditiva: agrega el bloque "region" con default, nunca borra datos.
static func migrar_v1_a_v2(datos: Dictionary) -> Dictionary:
	var resultado := datos.duplicate(true)
	if not resultado.has("region"):
		resultado["region"] = {"nombre": "aurora", "explorada": []}
	else:
		var region: Dictionary = resultado["region"]
		if not region.has("explorada"):
			region["explorada"] = []
	resultado["version"] = 2
	return resultado

## Aplica migraciones en orden estricto desde datos.version hasta VERSION_ACTUAL.
## Devuelve {ok, datos} — nunca muta el original; sobre copia en memoria.
## Si la versión es >= VERSION_ACTUAL, devuelve sin cambios.
## Si es futura (usa Cargar() para eso), migrar no la toca: ok=true, datos=original.
static func migrar(datos: Dictionary) -> Dictionary:
	var version: int = int(datos.get("version", 0))
	if version >= VERSION_ACTUAL:
		return {"ok": true, "datos": datos.duplicate(true)}
	var copia := datos.duplicate(true)
	var v := version
	while v < VERSION_ACTUAL:
		# MIGRACIONES[v - 1] lleva de v a v+1
		var idx := v - 1
		if idx < 0:
			# Un save sin versión (v0 original) no tiene migración de partida:
			# le asignamos version 1 directamente (defaults de v1).
			copia["version"] = 1
			v = 1
			continue
		if idx >= MIGRACIONES.size():
			return {"ok": false, "error": "Falta migración v%d -> v%d" % [v, v + 1]}
		var migracion: Callable = MIGRACIONES[idx]
		var antes: int = int(copia.get("version", 0))
		copia = migracion.call(copia)
		var despues: int = int(copia.get("version", antes))
		if despues <= antes:
			return {"ok": false, "error": "Migración no avanzó versión (%d -> %d)" % [antes, despues]}
		v = despues
	return {"ok": true, "datos": copia}

## true si el save es de una versión más nueva que este juego (rechazar carga).
static func version_futura(datos: Dictionary) -> bool:
	var version: int = int(datos.get("version", 0))
	return version > VERSION_ACTUAL

## Asigna la versión en el dict (por convención al final de cada migración).
static func set_version(datos: Dictionary, v: int) -> void:
	datos["version"] = v