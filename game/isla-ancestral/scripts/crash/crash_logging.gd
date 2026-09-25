# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashLogging (integración M103, helper headless).
# Implementa la integración del diseño (03-Diseno.md §8), que quedó `[ ]`:
#   log_crash                 -> registrar
#   nivel CRITICAL            -> CATEGORIA_CRASH / NIVEL
#   contenido (error, stack, metadata, contexto) -> formatear_entradas
# RefCounted sin `class_name` (preload).
#
# Desviación del diseño (04-Codigo.md §15): el diseño obtenía el logger con
# `ServiceRegistry.get("logger")` DENTRO del helper -> imposible de testear sin el autoload y
# rompía si M103 no estaba cargado. Acá el logger se INYECTA y `registrar` es fail-closed:
# sin logger (o sin el método `critical`) devuelve 0, NO inventa un registro.
#
# `Category.CRASH == 6` (verificado contra `scripts/logging/logger.gd:35`); se fija como const
# para no depender de un preload de M103 (el helper no debe arrastrar el módulo entero).

extends RefCounted

## Nivel CRITICAL de M103 (Level.CRITICAL). Se registra como texto para no preload-ear logger.gd.
const NIVEL := "CRITICAL"
## `Category.CRASH` del enum de M103 (scripts/logging/logger.gd:35).
const CATEGORIA_CRASH := 6


## Construye las 4 líneas CRITICAL del diseño SIN tocar ningún logger (puro y testeable).
## Acepta las dos vocabularios del dump: {error, stack, metadata, context} y
## {tipo, stack, metadata, contexto} (el autoload usa el segundo).
func formatear_entradas(datos: Dictionary) -> PackedStringArray:
	var l := PackedStringArray()
	l.append("Crash detected: %s" % str(_valor(datos, ["error", "tipo"], "desconocido")))
	l.append("Stack trace: %s" % _stack_a_texto(_valor(datos, ["stack", "stack_trace"], [])))
	l.append("Metadata: %s" % JSON.stringify(_valor(datos, ["metadata"], {})))
	l.append("Context: %s" % JSON.stringify(_valor(datos, ["context", "contexto"], {})))
	return l


## Registra las 4 líneas en `logger` (inyectado). Devuelve cuántas líneas registró.
## Contrato de `logger`: exponer `critical(message: String, category: int, context: Dictionary)`.
func registrar(datos: Dictionary, logger: Object = null) -> int:
	if logger == null or not logger.has_method("critical"):
		return 0
	var n: int = 0
	for linea in formatear_entradas(datos):
		logger.call("critical", linea, CATEGORIA_CRASH)
		n += 1
	return n


func _stack_a_texto(stack: Variant) -> String:
	if typeof(stack) == TYPE_ARRAY:
		var arr: Array = stack
		var partes := PackedStringArray()
		for linea in arr:
			partes.append(str(linea))
		return " | ".join(partes)
	return str(stack)


func _valor(datos: Dictionary, claves: Array, por_defecto: Variant) -> Variant:
	for k in claves:
		if datos.has(k):
			return datos[k]
	return por_defecto
