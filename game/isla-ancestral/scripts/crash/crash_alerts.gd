# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashAlerts (alertas automáticas, helper headless).
# Implementa el diseño (03-Diseno.md §15), que quedó `[ ]`:
#   check_alerts  -> evaluar
#   _send_alert   -> construir_payload + enviar
#   formato       -> formatear_alerta
# RefCounted sin `class_name` (preload).
#
# Desviación: el diseño hacía `HTTPRequest.new()` dentro del helper (un Node) -> se inyecta un
# `Callable` (mismo patrón que CrashSender/BugTracking). Sin transporte, `enviar` es fail-closed.
#
# Umbrales del diseño: crítico > 5 % de usuarios; crash nueva > 1 %. Se conservan como consts.

extends RefCounted

const UMBRAL_CRITICO := 0.05
const UMBRAL_NUEVA := 0.01
const CANAL := "#crash-alerts"
const URL_WEBHOOK := "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"


## Evalúa la lista de crashes y devuelve los MENSAJES de alerta (puro y testeable).
## Cada crash puede traer `frequency`/`frecuencia` (0..1) y `new_crash`/`nueva` (bool).
func evaluar(crashes: Array) -> PackedStringArray:
	var out := PackedStringArray()
	for item in crashes:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = item
		var frec := _frecuencia(d)
		if frec > UMBRAL_CRITICO:
			out.append(formatear_alerta(d, "Crash crítico"))
		if _es_nueva(d) and frec > UMBRAL_NUEVA:
			out.append(formatear_alerta(d, "Crash nueva"))
	return out


## Formato del diseño: "<prefijo>: <stack> afecta al X.X% de usuarios".
func formatear_alerta(datos: Dictionary, prefijo: String) -> String:
	var frec := _frecuencia(datos)
	return "%s: %s afecta al %.1f%% de usuarios" % [prefijo, _identificador(datos), frec * 100.0]


## Payload del webhook de Slack (contrato del diseño: {message, channel}).
func construir_payload(mensaje: String) -> Dictionary:
	return {"message": mensaje, "channel": CANAL}


## Envía el mensaje por el transporte inyectado. Devuelve true sólo si se "envió".
func enviar(mensaje: String, transporte: Callable = Callable()) -> bool:
	if transporte.is_null():
		return false
	var respuesta: Variant = transporte.call(URL_WEBHOOK, JSON.stringify(construir_payload(mensaje)))
	return bool(respuesta)


## Envía TODAS las alertas de la lista. Devuelve cuántas se enviaron (0 si no hay transporte).
func enviar_todas(crashes: Array, transporte: Callable = Callable()) -> int:
	var n: int = 0
	for mensaje in evaluar(crashes):
		if enviar(mensaje, transporte):
			n += 1
	return n


func _frecuencia(datos: Dictionary) -> float:
	return float(datos.get("frequency", datos.get("frecuencia", 0.0)))


func _es_nueva(datos: Dictionary) -> bool:
	return bool(datos.get("new_crash", datos.get("nueva", false)))


func _identificador(datos: Dictionary) -> String:
	var stack: Variant = datos.get("stack", datos.get("stack_trace", ""))
	if typeof(stack) == TYPE_ARRAY:
		var arr: Array = stack
		if not arr.is_empty():
			return str(arr[0])
		return "(stack vacío)"
	return str(stack)
