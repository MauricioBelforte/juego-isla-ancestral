# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashBugTracking (integración M102, helper headless).
# Implementa la integración del diseño (03-Diseno.md §9), que quedó `[ ]`:
#   create_issue_for_crash -> debe_crear_issue + formatear_titulo + formatear_cuerpo + crear_issue
#   _format_issue_body     -> formatear_cuerpo
#   _create_github_issue   -> crear_issue (transporte inyectado)
# RefCounted sin `class_name` (preload).
#
# DEFECTO del diseño corregido (04-Codigo.md §15): su `_format_issue_body` usaba una variable
# `crash` que NUNCA se declaraba (`crash.metadata.get("ram_total", 0)`) -> en GDScript eso es un
# error de parseo/ejecución. Acá se usa `datos` (el parámetro) en las 4 referencias.
#
# Desviación: el diseño hacía `HTTPRequest.new()` dentro del helper -> se inyecta un `Callable`
# (mismo patrón que CrashSender). Sin transporte, `crear_issue` devuelve false (fail-closed).

extends RefCounted

const PRIORIDAD_CRITICA := "CRITICAL"
const URL_API := "https://api.github.com/repos/MauricioBelforte/juego-isla-ancestral/issues"


## ¿Corresponde abrir un issue? Sólo para prioridad CRÍTICA (contrato del diseño).
func debe_crear_issue(datos: Dictionary) -> bool:
	var p := str(datos.get("priority", datos.get("prioridad", ""))).to_upper()
	return p == PRIORIDAD_CRITICA


func formatear_titulo(datos: Dictionary) -> String:
	var escena := str(_contexto(datos).get("scene", "unknown"))
	var err := str(datos.get("error", datos.get("tipo", "unknown")))
	return "[CRASH] Crash en %s - %s" % [escena, err]


## Cuerpo del issue (Markdown). Puro: no toca red ni disco.
func formatear_cuerpo(datos: Dictionary) -> String:
	var meta: Dictionary = _metadata(datos)
	var ctx := _contexto(datos)
	var cuerpo := "Stack trace:\n%s\n\n" % _stack_a_texto(datos.get("stack", datos.get("stack_trace", [])))
	cuerpo += "Metadata:\n"
	cuerpo += "- Versión: %s\n" % str(meta.get("game_version", "unknown"))
	cuerpo += "- OS: %s\n" % str(meta.get("os", "unknown"))
	cuerpo += "- GPU: %s\n" % str(meta.get("gpu", "unknown"))
	cuerpo += "- CPU: %s\n" % str(meta.get("cpu", "unknown"))
	cuerpo += "- RAM: %s GB\n" % _a_gb(int(meta.get("ram_total", 0)))
	cuerpo += "\nContexto:\n"
	cuerpo += "- Escena: %s\n" % str(ctx.get("scene", "unknown"))
	cuerpo += "- Hora: %s\n" % str(ctx.get("game_time", "unknown"))
	cuerpo += "- Estación: %s\n" % str(ctx.get("season", "unknown"))
	cuerpo += "- Posición: %s\n" % str(ctx.get("player_position", Vector3.ZERO))
	cuerpo += "\nFrecuencia: %s usuarios afectados\n" % str(datos.get("frequency", datos.get("frecuencia", 0)))
	cuerpo += "Prioridad: 🔴 CRÍTICA"
	return cuerpo


## Crea el issue si corresponde y hay transporte. Devuelve true sólo si se "envió".
func crear_issue(datos: Dictionary, transporte: Callable = Callable()) -> bool:
	if not debe_crear_issue(datos) or transporte.is_null():
		return false
	var payload := {
		"title": formatear_titulo(datos),
		"body": formatear_cuerpo(datos),
	}
	var respuesta: Variant = transporte.call(URL_API, JSON.stringify(payload))
	return bool(respuesta)


func _metadata(datos: Dictionary) -> Dictionary:
	var m: Variant = datos.get("metadata", {})
	if typeof(m) != TYPE_DICTIONARY:
		return {}
	var out: Dictionary = m
	return out


func _contexto(datos: Dictionary) -> Dictionary:
	var c: Variant = datos.get("context", datos.get("contexto", {}))
	if typeof(c) != TYPE_DICTIONARY:
		return {}
	var out: Dictionary = c
	return out


func _stack_a_texto(stack: Variant) -> String:
	if typeof(stack) == TYPE_ARRAY:
		var arr: Array = stack
		var partes := PackedStringArray()
		for linea in arr:
			partes.append(str(linea))
		return "\n".join(partes)
	return str(stack)


func _a_gb(bytes: int) -> String:
	return "%.2f" % (float(bytes) / 1024.0 / 1024.0 / 1024.0)
