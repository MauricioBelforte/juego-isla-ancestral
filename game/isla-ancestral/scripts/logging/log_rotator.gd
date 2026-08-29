# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M103: Logging — LogRotator (rotación de logs).
# Rota game.log → game.log.1.gz (o .1) → ... → game.log.N, elimina el más antiguo.
# Godot 4.7: FileAccess / DirAccess, sin File/Dir antiguos.

class_name LogRotator
extends Object

## Rota el archivo de log. `max_files` es el número de rotados (game.log.1..N).
static func rotate(file_path: String, max_files: int, compress: bool) -> void:
	var dir := file_path.get_base_dir()
	if not FileAccess.file_exists(file_path):
		return

	# Eliminar el más antiguo (N) si existe.
	var oldest := _rotated_path(file_path, max_files, compress)
	if FileAccess.file_exists(oldest):
		DirAccess.remove_absolute(oldest)

	# Desplazar n-1 → n (hacia atrás).
	for i in range(max_files - 1, 0, -1):
		var src := _rotated_path(file_path, i, compress)
		var dst := _rotated_path(file_path, i + 1, compress)
		if FileAccess.file_exists(src):
			if FileAccess.file_exists(dst):
				DirAccess.remove_absolute(dst)
			DirAccess.rename_absolute(src, dst)

	# Comprimir el actual → .1 (o moverlo si no se comprime).
	if compress:
		var raw_bytes := FileAccess.get_file_as_bytes(file_path)
		var gz: PackedByteArray = raw_bytes.compress(FileAccess.COMPRESSION_GZIP)
		var f := FileAccess.open(_rotated_path(file_path, 1, true), FileAccess.WRITE)
		if f != null:
			f.store_buffer(gz)
			f.close()
	else:
		if FileAccess.file_exists(_rotated_path(file_path, 1, false)):
			DirAccess.remove_absolute(_rotated_path(file_path, 1, false))
		DirAccess.rename_absolute(file_path, _rotated_path(file_path, 1, false))

	# Crear archivo activo vacío.
	var nf := FileAccess.open(file_path, FileAccess.WRITE)
	if nf != null:
		nf.store_string("")
		nf.close()

## Devuelve la ruta del archivo rotado `i` según si se comprime (.gz) o no.
static func _rotated_path(file_path: String, i: int, compress: bool) -> String:
	return "%s.%d%s" % [file_path, i, ".gz" if compress else ""]

## Devuelve el tamaño del archivo de log en bytes (0 si no existe).
static func get_size(file_path: String) -> int:
	if not FileAccess.file_exists(file_path):
		return 0
	return FileAccess.get_file_as_string(file_path).length()