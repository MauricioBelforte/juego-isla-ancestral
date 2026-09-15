# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — Versionador
# Versionado de esquema + migraciones automáticas (RF6/RF7/RF11).
# Cada migración es una función pura (dict -> dict), aplicada en orden estricto.
# RN4: todo campo nuevo debe tener default o migración.
#
# ── iter. 4 ───────────────────────────────────────────────────────────────
# Modelo: DeepSeek-V4.1-Flash · Plataforma: WorkBuddy · Fecha: 2026-09-15
# `migrar()` se partió en `migrar_con_cadena()` (motor con cadena y objetivo
# INYECTABLES) para poder probar en headless los caminos que la producción aún
# no alcanza con MIGRACIONES vacío: N saltos, fallo de migración, no-avance de
# versión, cadena incompleta e idempotencia. Se agregaron los patrones puros
# `renombrar_campo` / `eliminar_campo` / `transformar_valor`.

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
	return migrar_con_cadena(datos, MIGRACIONES, VERSION_ACTUAL)

## ── iter. 4: motor de migración inyectable (testeable en aislamiento) ──────
## Misma semántica que `migrar()`, pero la cadena y la versión objetivo se
## pasan como parámetros. Permite PROBAR los caminos que la producción todavía
## no alcanza (MIGRACIONES está vacío mientras VERSION_ACTUAL == 1):
## N saltos reales, migración que falla, migración que no avanza versión,
## cadena incompleta, idempotencia. `migrar()` delega aquí sin cambiar nada.
##
## `cadena[i]` lleva de la versión i+1 a la i+2 (igual que MIGRACIONES).
## Devuelve {ok, datos} o {ok:false, error}. Nunca muta `datos`.
static func migrar_con_cadena(datos: Dictionary, cadena: Array, objetivo: int) -> Dictionary:
	var version: int = int(datos.get("version", 0))
	if version >= objetivo:
		return {"ok": true, "datos": datos.duplicate(true)}
	var copia := datos.duplicate(true)
	var v := version
	while v < objetivo:
		# cadena[v - 1] lleva de v a v+1
		var idx := v - 1
		if idx < 0:
			# Un save sin versión (v0 original) no tiene migración de partida:
			# le asignamos version 1 directamente (defaults de v1).
			copia["version"] = 1
			v = 1
			continue
		if idx >= cadena.size():
			return {"ok": false, "error": "Falta migración v%d -> v%d" % [v, v + 1]}
		var migracion: Callable = cadena[idx]
		var antes: int = int(copia.get("version", 0))
		copia = migracion.call(copia)
		var despues: int = int(copia.get("version", antes))
		if despues <= antes:
			return {"ok": false, "error": "Migración no avanzó versión (%d -> %d)" % [antes, despues]}
		v = despues
	return {"ok": true, "datos": copia}

## ── iter. 4: patrones reutilizables de migración (funciones puras) ─────────
## Los tres cambios de esquema que más se repiten. Son puras (no mutan la
## entrada) y se combinan dentro de una migración registrada en MIGRACIONES.

## Patrón "campo renombrado": mueve `viejo` -> `nuevo`. Si `viejo` no está y
## `nuevo` tampoco, aplica `por_defecto` (o no toca nada si es null).
static func renombrar_campo(datos: Dictionary, viejo: String, nuevo: String, por_defecto: Variant = null) -> Dictionary:
	var r := datos.duplicate(true)
	if r.has(viejo):
		r[nuevo] = r[viejo]
		r.erase(viejo)
	elif not r.has(nuevo) and por_defecto != null:
		r[nuevo] = por_defecto
	return r

## Patrón "campo eliminado": limpia el dato sin romper a los consumidores
## (los consumidores deben tolerar la ausencia vía default del contrato).
static func eliminar_campo(datos: Dictionary, campo: String) -> Dictionary:
	var r := datos.duplicate(true)
	r.erase(campo)
	return r

## Patrón "transformación de valores" (ej: energía de kcal a J): aplica `fn`
## al valor del campo. Si el campo no existe, no inventa nada.
static func transformar_valor(datos: Dictionary, campo: String, fn: Callable) -> Dictionary:
	var r := datos.duplicate(true)
	if r.has(campo):
		r[campo] = fn.call(r[campo])
	return r

## true si el save es de una versión más nueva que este juego (rechazar carga).
static func version_futura(datos: Dictionary) -> bool:
	var version: int = int(datos.get("version", 0))
	return version > VERSION_ACTUAL

## Asigna la versión en el dict (por convención al final de cada migración).
static func set_version(datos: Dictionary, v: int) -> void:
	datos["version"] = v