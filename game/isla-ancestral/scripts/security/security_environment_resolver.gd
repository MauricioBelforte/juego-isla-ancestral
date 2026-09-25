# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-20
#
# M106 T-008: Seguridad — Resolver de entornos separados dev/staging/prod (RF4).
# Selecciona la configuración del entorno activo desde security_environments.json.
# El entorno activo lo define APP_ENV (variable de entorno o argumento); por defecto "dev".
# Headless-safe, lógica pura, RefCounted vía preload (sin class_name, pitfall §9.41).

extends RefCounted

const RUTA_ENVIRONMENTS := "res://data/security/security_environments.json"

var _config: Dictionary = {}
var _entorno: String = "dev"

## app_env: entorno forzado (para tests). Si es "", lee la variable de entorno APP_ENV.
func _init(app_env: String = "") -> void:
	_cargar()
	_entorno = _resolver_entorno(app_env)

func _cargar() -> void:
	if not FileAccess.file_exists(RUTA_ENVIRONMENTS):
		push_warning("[M106] security_environments.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_ENVIRONMENTS))
	if typeof(parsed) == TYPE_DICTIONARY:
		_config = parsed

## Determina el entorno activo: 1) argumento, 2) var de entorno APP_ENV, 3) default del JSON.
func _resolver_entorno(app_env: String) -> String:
	var candidato := app_env.strip_edges().to_lower()
	if candidato == "":
		candidato = OS.get_environment("APP_ENV").strip_edges().to_lower()
	if candidato == "":
		candidato = str(_config.get("entorno_activo_por_defecto", "dev")).to_lower()
	if not _config.get("entornos", {}).has(candidato):
		push_warning("[M106] Entorno '%s' no definido; usando 'dev'" % candidato)
		return "dev"
	return candidato

## Entorno activo (dev | staging | prod).
func entorno() -> String:
	return _entorno

## Configuración completa del entorno activo.
func config_entorno() -> Dictionary:
	return _config.get("entornos", {}).get(_entorno, {}).duplicate()

## Valor de una clave del entorno activo (con default).
func valor(clave: String, por_defecto: Variant = null) -> Variant:
	return config_entorno().get(clave, por_defecto)

## ¿Es el entorno de desarrollo?
func es_dev() -> bool:
	return _entorno == "dev"

## ¿Es producción?
func es_prod() -> bool:
	return _entorno == "prod"

## Lista de entornos definidos.
func entornos_disponibles() -> Array:
	return _config.get("entornos", {}).keys()
