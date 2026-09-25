# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityApiSecurity (helper reutilizable, V0 + headless).
# Implementa el servicio "APISecurity" del diseño (03-Diseno.md §2), que quedó `[ ]`:
#   signal api_authenticated(success)  -> api_autenticada
#   signal rate_limit_exceeded()       -> limite_tasa_excedido
#   var api_key                        -> api_key
#   var rate_limit                     -> rate_limit
#   var request_count                  -> request_count
#   var rate_limit_timer               -> rate_limit_timer (⚠️ ver nota)
#   load_api_key()                     -> cargar_api_key
#   setup_rate_limiting()              -> configurar_limite_tasa
#   authenticate_request(headers)      -> autenticar
#   check_rate_limit()                 -> verificar_limite
#
# ⚠️ Desviación declarada del diseño: el diseño usa un nodo `Timer` hijo. Este helper es
# RefCounted (no puede tener hijos), así que `rate_limit_timer` es la VENTANA de reset en
# segundos (float) y el reset se hace por tiempo lógico (`reiniciar_contador`), no por señal.
# El rate limiting REAL por IP/usuario/endpoint vive en el autoload
# (`SecurityManager.verificar_limite_tasa`) + el middleware; esto es la variante de servicio
# autónomo del diseño. La aplicación sobre red es de M77.

extends RefCounted

signal api_autenticada(exito: bool)
signal limite_tasa_excedido

var api_key: String = ""
var rate_limit: int = 100          # solicitudes por ventana
var request_count: int = 0
var rate_limit_timer: float = 60.0  # ventana de reset, en segundos (ver nota)


## Carga la clave desde un diccionario de entorno (normalmente el proceso). Devuelve true si hay clave.
func cargar_api_key(entorno: Dictionary) -> bool:
	api_key = str(entorno.get("API_KEY", ""))
	return not api_key.is_empty()


## Configura la ventana de rate limiting (segundos) y reinicia el contador.
func configurar_limite_tasa(ventana_s: float = 60.0, max_solicitudes: int = 100) -> void:
	rate_limit_timer = ventana_s
	rate_limit = max_solicitudes
	request_count = 0


## Reinicia el contador (equivale al `timeout` del Timer del diseño).
func reiniciar_contador() -> void:
	request_count = 0


## Autentica una solicitud por header `Authorization: Bearer <api_key>`.
## Emite `api_autenticada`. Devuelve false si no hay clave configurada o no coincide (fail-closed).
func autenticar(headers: Dictionary) -> bool:
	var provisto: String = str(headers.get("Authorization", ""))
	var ok: bool = not api_key.is_empty() and provisto == "Bearer " + api_key
	api_autenticada.emit(ok)
	return ok


## Consume una unidad de tasa. Emite `limite_tasa_excedido` y devuelve false si se pasó.
func verificar_limite() -> bool:
	if request_count >= rate_limit:
		limite_tasa_excedido.emit()
		return false
	request_count += 1
	return true
