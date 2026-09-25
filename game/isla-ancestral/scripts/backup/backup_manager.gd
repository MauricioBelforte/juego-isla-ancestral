# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-19
#
# M107: Backups — BackupManager (autoload)
# Backup por categorias RF1-RF15, compresion ZIP, verificacion CRC32,
# retencion automatica, restauracion, manifest/audit.
# Sin class_name: es autoload (pitfall 9.17/9.41).

extends Node

const RUTA_POLICY := "res://data/backup/backup_policy.json"
const RUTA_CATEGORIAS := "res://data/backup/backup_categories.json"
const DIR_BACKUP := "user://backups/"

var config: Dictionary = {}
var categorias: Dictionary = {}

func _ready() -> void:
	_cargar_policy()
	_cargar_categorias()
	_registrar_servicio()
	print("[M107] BackupManager listo (max %d copias, %d categorias)" % [_max_copias(), categorias.get("categorias", {}).size()])

func _cargar_policy() -> void:
	if not FileAccess.file_exists(RUTA_POLICY):
		push_warning("[M107] backup_policy.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_POLICY))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _cargar_categorias() -> void:
	if not FileAccess.file_exists(RUTA_CATEGORIAS):
		push_warning("[M107] backup_categories.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATEGORIAS))
	if typeof(parsed) == TYPE_DICTIONARY:
		categorias = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("backup"):
		sr.register("backup", self)

func _max_copias() -> int:
	return int(config.get("retencion", {}).get("max_copias", 5))

func _dir_os() -> String:
	return ProjectSettings.globalize_path(DIR_BACKUP)

# RF1-RF8: Backup por categorias

func categorias_disponibles() -> Array:
	var ids: Array = []
	for cat_id in categorias.get("categorias", {}):
		ids.append(cat_id)
	return ids

func get_categoria(cat_id: String) -> Dictionary:
	return categorias.get("categorias", {}).get(cat_id, {})

func backup_repositorio() -> String:
	return _backup_categoria("repositorio")

func backup_assets() -> String:
	return _backup_categoria("assets")

func backup_documentacion() -> String:
	return _backup_categoria("documentacion")

func backup_builds() -> String:
	return _backup_categoria("builds")

func backup_saves() -> String:
	return _backup_categoria("saves")

func backup_musica() -> String:
	return _backup_categoria("musica")

func backup_fuente() -> String:
	return _backup_categoria("fuente")

func _backup_categoria(cat_id: String) -> String:
	var cat := get_categoria(cat_id)
	if cat.is_empty():
		push_warning("[M107] Categoria no encontrada: %s" % cat_id)
		return ""
	var destino_cat: String = str(cat.get("destino", cat_id + "/"))
	var timestamp := Time.get_datetime_string_from_system(true).replace(":", "-")
	var nombre_zip := "%s_%s.zip" % [cat_id, timestamp]
	var dir_destino := "%s%s" % [DIR_BACKUP, destino_cat]
	if not DirAccess.dir_exists_absolute(dir_destino):
		DirAccess.make_dir_recursive_absolute(dir_destino)
	var ruta_zip := "%s%s" % [dir_destino, nombre_zip]
	var origenes: Array = cat.get("origenes", [])
	if origenes.is_empty():
		push_warning("[M107] Sin origenes para categoria: %s" % cat_id)
		return ""
	var dir_temp := ProjectSettings.globalize_path("user://backups/_temp_%s" % cat_id)
	DirAccess.make_dir_recursive_absolute(dir_temp)
	for origen in origenes:
		var ruta_origen := ProjectSettings.globalize_path("res://%s" % origen)
		if DirAccess.dir_exists_absolute(ruta_origen):
			_copiar_directorio(ruta_origen, dir_temp + "/" + origen.get_file())
		elif FileAccess.file_exists(ruta_origen):
			DirAccess.copy_absolute(ruta_origen, dir_temp + "/" + origen.get_file())
	var comprimir: bool = bool(cat.get("compresion", true))
	if comprimir and zip_available():
		_comprimir_directorio(dir_temp, ruta_zip)
		_limpiar_directorio_temp(dir_temp)
	else:
		DirAccess.rename_absolute(dir_temp, ruta_zip)
	_limpiar_excedentes_cat(destino_cat)
	return ruta_zip# Compresion ZIP

func zip_available() -> bool:
	# Godot 4.x: la clase es ZIPPacker (en Godot 3 era ZIPWriter — E-20 GUIA-GODOT/06)
	return ClassDB.class_exists(&"ZIPPacker")

func _comprimir_directorio(dir_path: String, zip_path: String) -> bool:
	if not zip_available():
		return false
	var writer := ZIPPacker.new()
	if writer.open(zip_path, ZIPPacker.APPEND_ADDINZIP) != OK:
		return false
	_agregar_dir_a_zip(writer, dir_path, "")
	writer.close()
	return FileAccess.file_exists(zip_path)

func _agregar_dir_a_zip(writer, dir_path: String, prefix: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre == "." or nombre == "..":
			nombre = dir.get_next()
			continue
		var ruta_completa := "%s/%s" % [dir_path, nombre]
		var entrada := "%s%s" % [prefix, nombre]
		if dir.current_is_dir():
			writer.start_file(entrada + "/")
			writer.write_file(PackedByteArray())
			_agregar_dir_a_zip(writer, ruta_completa, entrada + "/")
		else:
			var f := FileAccess.open(ruta_completa, FileAccess.READ)
			if f:
				writer.start_file(entrada)
				writer.write_file(f.get_buffer(f.get_length()))
		nombre = dir.get_next()
	dir.list_dir_end()

func _limpiar_directorio_temp(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre == "." or nombre == "..":
			nombre = dir.get_next()
			continue
		var ruta := "%s/%s" % [dir_path, nombre]
		if dir.current_is_dir():
			_limpiar_directorio_temp(ruta)
			DirAccess.remove_absolute(ruta)
		else:
			DirAccess.remove_absolute(ruta)
		nombre = dir.get_next()
	dir.list_dir_end()

func _copiar_directorio(origen: String, destino: String) -> void:
	DirAccess.make_dir_recursive_absolute(destino)
	var dir := DirAccess.open(origen)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre == "." or nombre == "..":
			nombre = dir.get_next()
			continue
		var ruta_origen := "%s/%s" % [origen, nombre]
		var ruta_destino := "%s/%s" % [destino, nombre]
		if dir.current_is_dir():
			_copiar_directorio(ruta_origen, ruta_destino)
		else:
			DirAccess.copy_absolute(ruta_origen, ruta_destino)
		nombre = dir.get_next()
	dir.list_dir_end()

# Backup individual (API original)

func crear_backup(ruta_origen: String, nombre: String) -> String:
	if not FileAccess.file_exists(ruta_origen):
		push_warning("[M107] Origen no existe: %s" % ruta_origen)
		return ""
	if not DirAccess.dir_exists_absolute(DIR_BACKUP):
		DirAccess.make_dir_recursive_absolute(DIR_BACKUP)
	var ruta_backup := "%s%s" % [DIR_BACKUP, nombre]
	var err := DirAccess.copy_absolute(ruta_origen, ruta_backup)
	if err != OK:
		return ""
	_limpiar_excedentes()
	return ruta_backup

# RF14: Verificacion de integridad (checksums)

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

func verificar_categoria(cat_id: String) -> Array:
	var resultados: Array = []
	var cat := get_categoria(cat_id)
	var destino_cat: String = str(cat.get("destino", cat_id + "/"))
	var dir_cat := "%s%s" % [DIR_BACKUP, destino_cat]
	if not DirAccess.dir_exists_absolute(dir_cat):
		return resultados
	var dir := DirAccess.open(_dir_os() + "/" + destino_cat)
	if dir == null:
		return resultados
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre == "." or nombre == ".." or nombre.ends_with(".txt"):
			nombre = dir.get_next()
			continue
		var ruta := "%s%s" % [dir_cat, nombre]
		var integridad := verificar_integridad(ruta)
		resultados.append({"nombre": nombre, "integridad": integridad})
		nombre = dir.get_next()
	dir.list_dir_end()
	return resultados

# RF12: Restauracion

func restaurar(ruta_backup: String, ruta_destino: String) -> bool:
	if not FileAccess.file_exists(ruta_backup):
		return false
	if config.get("verificacion", {}).get("integrity_check_al_restaurar", true):
		if not verificar_integridad(ruta_backup):
			return false
	var err := DirAccess.copy_absolute(ruta_backup, ruta_destino)
	return err == OK

func restaurar_categoria(cat_id: String, ruta_destino: String) -> bool:
	var cat := get_categoria(cat_id)
	var destino_cat: String = str(cat.get("destino", cat_id + "/"))
	var dir_cat := "%s%s" % [DIR_BACKUP, destino_cat]
	if not DirAccess.dir_exists_absolute(dir_cat):
		return false
	var backups := _listar_archivos_cat(destino_cat)
	if backups.is_empty():
		return false
	var mas_reciente: String = backups[0]
	for b in backups:
		if FileAccess.get_modified_time("%s%s" % [dir_cat, b]) > FileAccess.get_modified_time("%s%s" % [dir_cat, mas_reciente]):
			mas_reciente = b
	var ruta_backup := "%s%s" % [dir_cat, mas_reciente]
	if ruta_backup.ends_with(".zip") and ClassDB.class_exists(&"ZIPReader"):
		return _descomprimir_a(ruta_backup, ruta_destino)
	else:
		return restaurar(ruta_backup, ruta_destino)

func _descomprimir_a(zip_path: String, dest_dir: String) -> bool:
	var reader = ZIPReader.new()
	var err := reader.open(zip_path)
	if err != OK:
		return false
	DirAccess.make_dir_recursive_absolute(dest_dir)
	for entrada in reader.get_files():
		var ruta_salida := "%s/%s" % [dest_dir, entrada]
		if entrada.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(ruta_salida)
		else:
			var dir_padre := ruta_salida.get_base_dir()
			if not DirAccess.dir_exists_absolute(dir_padre):
				DirAccess.make_dir_recursive_absolute(dir_padre)
			var f := FileAccess.open(ruta_salida, FileAccess.WRITE)
			if f:
				f.store_buffer(reader.read_file(entrada))
				f.close()
	reader.close()
	return true

# RF13: Retencion y limpieza

func _limpiar_excedentes() -> void:
	var dir := DirAccess.open(_dir_os())
	if dir == null:
		return
	var archivos: Array = []
	for f in dir.get_files():
		archivos.append({"nombre": f, "mtime": FileAccess.get_modified_time("%s%s" % [DIR_BACKUP, f])})
	archivos.sort_custom(func(a, b): return int(a["mtime"]) > int(b["mtime"]))
	while archivos.size() > _max_copias():
		var viejo: Dictionary = archivos.pop_back()
		DirAccess.remove_absolute("%s%s" % [DIR_BACKUP, viejo["nombre"]])

func _limpiar_excedentes_cat(destino_cat: String) -> void:
	var max_dias := 30
	var dir_cat := "%s%s" % [DIR_BACKUP, destino_cat]
	if not DirAccess.dir_exists_absolute(dir_cat):
		return
	var ahora := int(Time.get_unix_time_from_system())
	var dir := DirAccess.open(_dir_os() + "/" + destino_cat)
	if dir == null:
		return
	var archivos: Array = []
	for f in dir.get_files():
		if f.ends_with(".zip") or not f.ends_with(".txt"):
			archivos.append({"nombre": f, "mtime": FileAccess.get_modified_time("%s%s" % [dir_cat, f])})
	archivos.sort_custom(func(a, b): return int(a["mtime"]) > int(b["mtime"]))
	var max_archivos := int(config.get("retencion", {}).get("max_copias", 5))
	while archivos.size() > max_archivos:
		var viejo: Dictionary = archivos.pop_back()
		DirAccess.remove_absolute("%s%s" % [dir_cat, viejo["nombre"]])
	for a in archivos:
		var edad_dias := (ahora - int(a["mtime"])) / 86400
		if edad_dias > max_dias:
			DirAccess.remove_absolute("%s%s" % [dir_cat, a["nombre"]])

func _listar_archivos_cat(destino_cat: String) -> Array:
	var archivos: Array = []
	var dir_cat := "%s%s" % [DIR_BACKUP, destino_cat]
	if not DirAccess.dir_exists_absolute(dir_cat):
		return archivos
	var dir := DirAccess.open(_dir_os() + "/" + destino_cat)
	if dir == null:
		return archivos
	for f in dir.get_files():
		if f.ends_with(".zip"):
			archivos.append(f)
	archivos.sort_custom(func(a, b): return a > b)
	return archivos

# RF11: Cantidad de backups

func cantidad_backups() -> int:
	if not DirAccess.dir_exists_absolute(DIR_BACKUP):
		return 0
	return DirAccess.get_files_at(_dir_os()).size()

func cantidad_backups_categoria(cat_id: String) -> int:
	var cat := get_categoria(cat_id)
	var destino_cat: String = str(cat.get("destino", cat_id + "/"))
	return _listar_archivos_cat(destino_cat).size()

# Audit/manifest

func listar_backups() -> Array:
	var resultado: Array = []
	if not DirAccess.dir_exists_absolute(DIR_BACKUP):
		return resultado
	var dir := DirAccess.open(_dir_os())
	if dir == null:
		return resultado
	var checksum_on := bool(config.get("verificacion", {}).get("checksum_habilitado", true))
	for f in dir.get_files():
		var ruta := "%s%s" % [DIR_BACKUP, f]
		var integridad := bool(verificar_integridad(ruta)) if checksum_on else true
		resultado.append({
			"nombre": f,
			"mtime": int(FileAccess.get_modified_time(ruta)),
			"integridad": integridad,
		})
	resultado.sort_custom(func(a, b): return int(a["mtime"]) <= int(b["mtime"]))
	return resultado

func listar_todos_backups() -> Dictionary:
	var resultado: Dictionary = {}
	for cat_id in categorias_disponibles():
		var cat := get_categoria(cat_id)
		var destino_cat: String = str(cat.get("destino", cat_id + "/"))
		resultado[cat_id] = listar_backups_categoria(destino_cat)
	return resultado

func listar_backups_categoria(destino_cat: String) -> Array:
	var resultado: Array = []
	var dir_cat := "%s%s" % [DIR_BACKUP, destino_cat]
	if not DirAccess.dir_exists_absolute(dir_cat):
		return resultado
	var dir := DirAccess.open(_dir_os() + "/" + destino_cat)
	if dir == null:
		return resultado
	for f in dir.get_files():
		var ruta := "%s%s" % [dir_cat, f]
		resultado.append({
			"nombre": f,
			"mtime": int(FileAccess.get_modified_time(ruta)),
		})
	resultado.sort_custom(func(a, b): return int(a["mtime"]) <= int(b["mtime"]))
	return resultado
