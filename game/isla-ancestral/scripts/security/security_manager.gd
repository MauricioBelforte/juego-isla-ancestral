# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M106: Seguridad — SecurityManager (autoload)
# Políticas de seguridad data-driven (security_policies.json): validación
# de saves con checksum, bloqueo de escritura en res://, rechazo de inputs
# fuera de rango, no-logs sensibles. Adaptación Godot 4.7/GDScript.
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_POLICIES := "res://data/security/security_policies.json"

var config: Dictionary = {}
var _alertas: Array = []

func _ready() -> void:
	_cargar_policies()
	_registrar_servicio()
	print("[M106] SecurityManager listo (%d políticas)" % config.get("politicas", {}).size())

func _cargar_policies() -> void:
	if not FileAccess.file_exists(RUTA_POLICIES):
		push_warning("[M106] security_policies.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_POLICIES))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("security"):
		sr.register("security", self)

## ¿Está habilitada una política?
func politica(nombre: String) -> bool:
	return bool(config.get("politicas", {}).get(nombre, {}).get("habilitada", false))

## Valida un valor contra una restricción numérica (máx).
func validar_max(campo: String, valor: int) -> bool:
	var max_valor: int = int(config.get("restricciones", {}).get(campo, 0))
	if max_valor <= 0:
		return true  # sin restricción configurada
	return valor <= max_valor

## Valida integridad de un save (checksum CRC32 patrón M60).
func validar_save(ruta: String) -> bool:
	if not politica("validar_saves"):
		return true
	if not FileAccess.file_exists(ruta):
		return false
	var contenido := FileAccess.get_file_as_string(ruta)
	var newline := contenido.find("\n")
	if newline <= 0:
		return false
	var checksum := contenido.substr(0, newline)
	var payload := contenido.substr(newline + 1)
	return checksum == Validador.crc32_hex(payload)

## Registra una alerta de seguridad (no sensible).
func registrar_alerta(mensaje: String) -> void:
	_alertas.append(mensaje)
	push_warning("[M106] Alerta: %s" % mensaje)

func alertas() -> Array:
	return _alertas.duplicate()

func cantidad_alertas() -> int:
	return _alertas.size()