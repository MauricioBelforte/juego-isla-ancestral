# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashSender (envío a servicio externo, helper headless).
# Implementa el servicio "CrashSender" del diseño (03-Diseno.md §6), que quedó `[ ]`:
#   has_connection       -> tiene_conexion
#   send_crash           -> enviar
#   send_cached_crashes  -> enviar_cache
#   headers HTTP         -> construir_headers
#   api_key              -> api_key (var)
# RefCounted sin `class_name` (preload).
#
# Desviación CLAVE del diseño (04-Codigo.md §15): el diseño instanciaba `HTTPRequest` dentro del
# helper (un Node) -> imposible de testear headless y acoplado al árbol. Acá el TRANSPORTE es un
# `Callable` INYECTADO: en producción se le pasa uno que use HTTPRequest; en tests, un stub.
# Sin transporte configurado, `enviar()` devuelve FALSE (fail-closed): nunca inventa un envío.
#
# La `api_key` NO se lee de ProjectSettings en `_init` (el diseño lo hacía y quedaba ""): se
# INYECTA con `configurar()`, así el helper no depende de la config del proyecto ni filtra
# secretos en el dump.

extends RefCounted

const URL_POR_DEFECTO := "https://crash-reporting-service.com/api/crashes"
const MAX_REINTENTOS := 3

var url_servicio: String = URL_POR_DEFECTO
var api_key: String = ""
var _transporte: Callable = Callable()
var _intentos: Dictionary = {}   # huella -> intentos realizados


## Configura el servicio. `transporte` recibe (url, headers, cuerpo) y debe devolver bool.
func configurar(url: String = URL_POR_DEFECTO, clave: String = "", transporte: Callable = Callable()) -> void:
	url_servicio = url
	api_key = clave
	_transporte = transporte


func tiene_transporte() -> bool:
	return not _transporte.is_null()


## ¿Hay conexión? En el diseño era `OS.has_feature("online")`; se conserva el contrato.
func tiene_conexion() -> bool:
	return OS.has_feature("online")


func construir_headers() -> PackedStringArray:
	var h := PackedStringArray(["Content-Type: application/json"])
	if not api_key.is_empty():
		h.append("Authorization: Bearer %s" % api_key)
	return h


func construir_cuerpo(datos: Dictionary) -> String:
	return JSON.stringify(datos)


## Envía UN crash. Devuelve false si no hay transporte o si el transporte falló.
func enviar(datos: Dictionary) -> bool:
	if _transporte.is_null():
		return false
	var respuesta: Variant = _transporte.call(url_servicio, construir_headers(), construir_cuerpo(datos))
	return bool(respuesta)


## Envía una lista de crashes con hasta `max_intentos` intentos por elemento.
## Devuelve {enviados: int, fallidos: Array} — los fallidos quedan para la próxima reconexión.
func enviar_cache(cache: Array, max_intentos: int = MAX_REINTENTOS) -> Dictionary:
	var enviados: int = 0
	var fallidos: Array = []
	for item in cache:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var datos: Dictionary = item
		var ok := false
		var intentos: int = 0
		while intentos < max_intentos and not ok:
			intentos += 1
			ok = enviar(datos)
		if ok:
			enviados += 1
		else:
			fallidos.append(datos)
	return {"enviados": enviados, "fallidos": fallidos}


## Cuántas veces se intentó enviar el dump de una ruta (para el techo de reintentos del autoload).
func intentos_de(ruta: String) -> int:
	return int(_intentos.get(ruta, 0))


func marcar_intento(ruta: String) -> int:
	var n: int = int(_intentos.get(ruta, 0)) + 1
	_intentos[ruta] = n
	return n


## Comprime el cuerpo (GZIP) antes de enviarlo — ítem "compresión de datos" del checklist.
## Reduce el tamaño de los dumps (stack traces largos) sin perder información.
func comprimir(texto: String) -> PackedByteArray:
	return texto.to_utf8_buffer().compress(FileAccess.COMPRESSION_GZIP)


## Descomprime un cuerpo GZIP. Devuelve "" si los bytes no son GZIP válido.
func descomprimir(bytes: PackedByteArray) -> String:
	if bytes.is_empty():
		return ""
	var plano: PackedByteArray = bytes.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	if plano.is_empty():
		return ""
	return plano.get_string_from_utf8()
