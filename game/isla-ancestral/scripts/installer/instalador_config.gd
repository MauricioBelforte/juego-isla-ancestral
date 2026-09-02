# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M116: Instalador — InstaladorConfig (autoload)
# Configuración data-driven del instalador (instalador_config.json):
# plataformas, pasos de instalación, requisitos, verificación de checksum,
# desinstalador. ⚠️ Sin class_name (autoload).

extends Node

const RUTA_CONFIG := "res://data/installer/instalador_config.json"

var config: Dictionary = {}
var _pasos_completados: Array = []

func _ready() -> void:
	_cargar_config()
	_registrar_servicio()
	print("[M116] InstaladorConfig listo (%d plataformas, %d pasos)" % [config.get("plataformas", []).size(), config.get("pasos", []).size()])

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_CONFIG):
		push_warning("[M116] instalador_config.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONFIG))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("instalador"):
		sr.register("instalador", self)

func plataformas() -> Array:
	return config.get("plataformas", []).duplicate()

func pasos() -> Array:
	return config.get("pasos", []).duplicate(true)

func requisito(nombre: String) -> int:
	return int(config.get("requisitos", {}).get(nombre, 0))

func soporta_plataforma(p: String) -> bool:
	return p in config.get("plataformas", [])

## Verifica los requisitos del sistema (disco/RAM) contra un estado dado.
func verificar_requisitos(disco_mb: int, ram_mb: int) -> Array:
	var errores: Array = []
	var disco_min := requisito("disco_min_mb")
	var ram_min := requisito("ram_min_mb")
	if disco_mb < disco_min:
		errores.append("Disco insuficiente: %d MB (mínimo %d)" % [disco_mb, disco_min])
	if ram_mb < ram_min:
		errores.append("RAM insuficiente: %d MB (mínimo %d)" % [ram_mb, ram_min])
	return errores

## Verifica checksum de un archivo contra el valor esperado (CRC32 patrón M60).
func verificar_checksum(archivo: String, checksum_esperado: String) -> bool:
	if not FileAccess.file_exists(archivo):
		return false
	var contenido := FileAccess.get_file_as_string(archivo)
	return Validador.crc32_hex(contenido) == checksum_esperado

## Ejecuta un paso por id. Devuelve {ok, paso, resultado}.
func ejecutar_paso(id: String) -> Dictionary:
	for paso in config.get("pasos", []):
		if String(paso.get("id", "")) == id:
			if id in _pasos_completados:
				return {"ok": true, "paso": id, "resultado": "ya completado"}
			_pasos_completados.append(id)
			return {"ok": true, "paso": id, "resultado": "paso ejecutado: %s" % paso.get("descripcion", "")}
	return {"ok": false, "paso": id, "resultado": "paso inexistente"}

func pasos_completados() -> Array:
	return _pasos_completados.duplicate()

func instalacion_completa() -> bool:
	return _pasos_completados.size() >= config.get("pasos", []).size()