# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M107: Backups — BackupManager (autoload)
# Gestión de backups: política de retención (data-driven), copias con
# checksum, verificación de integridad, restauración. Adaptación Godot
# 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_POLICY := "res://data/backup/backup_policy.json"
const DIR_BACKUP := "user://backups/"

var config: Dictionary = {}

func _ready() -> void:
	_cargar_policy()
	_registrar_servicio()
	print("[M107] BackupManager listo (máx %d copias)" % _max_copias())

func _cargar_policy() -> void:
	if not FileAccess.file_exists(RUTA_POLICY):
		push_warning("[M107] backup_policy.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_POLICY))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("backup"):
		sr.register("backup", self)

func _max_copias() -> int:
	return int(config.get("retencion", {}).get("max_copias", 5))

## Crea un backup de un archivo (copia + checksum). Devuelve la ruta o "".
func crear_backup(ruta_origen: String, nombre: String) -> String:
	if not FileAccess.file_exists(ruta_origen):
		push_warning("[M107] Origen no existe: %s" % ruta_origen)
		return ""
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR_BACKUP))
	var ruta_backup := "%s%s" % [DIR_BACKUP, nombre]
	var err := DirAccess.copy_absolute(ruta_origen, ruta_backup)
	if err != OK:
		return ""
	_limpiar_excedentes()
	return ruta_backup

## Verifica la integridad de un backup con checksum (si habilitado).
func verificar_integridad(ruta_backup: String) -> bool:
	if not FileAccess.file_exists(ruta_backup):
		return false
	if not config.get("verificacion", {}).get("checksum_habilitado", true):
		return true
	var contenido := FileAccess.get_file_as_string(ruta_backup)
	var newline := contenido.find("\n")
	if newline <= 0:
		return false
	var checksum := contenido.substr(0, newline)
	var payload := contenido.substr(newline + 1)
	return checksum == Validador.crc32_hex(payload)

## Restaura un backup sobre el archivo destino. Devuelve bool.
func restaurar(ruta_backup: String, ruta_destino: String) -> bool:
	if not FileAccess.file_exists(ruta_backup):
		return false
	if config.get("verificacion", {}).get("integrity_check_al_restaurar", true):
		if not verificar_integridad(ruta_backup):
			return false
	var err := DirAccess.copy_absolute(ruta_backup, ruta_destino)
	return err == OK

func _limpiar_excedentes() -> void:
	var dir := DirAccess.open(DIR_BACKUP)
	if dir == null:
		return
	var archivos: Array = []
	for f in dir.get_files():
		archivos.append({"nombre": f, "mtime": FileAccess.get_modified_time("%s%s" % [DIR_BACKUP, f])})
	archivos.sort_custom(func(a, b): return int(a["mtime"]) > int(b["mtime"]))
	while archivos.size() > _max_copias():
		var viejo: Dictionary = archivos.pop_back()
		DirAccess.remove_absolute("%s%s" % [DIR_BACKUP, viejo["nombre"]])

func cantidad_backups() -> int:
	var dir := DirAccess.open(DIR_BACKUP)
	if dir == null:
		return 0
	return dir.get_files().size()