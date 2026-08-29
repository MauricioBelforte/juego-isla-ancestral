# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M103: Logging — LogExporter (exportación RFC16/§8 de diseño 03).
# Escribe un archivo exportado en user://logs/export_{timestamp}.log
# con el contenido filtrado. Reutiliza el Logger para leer/filtrar.

class_name LogExporter
extends Object

## Escribe el contenido exportado a un archivo y devuelve su ruta.
static func export_to_file(contenido: String) -> String:
	DirAccess.make_dir_recursive_absolute("user://logs")
	var ts := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var path := "user://logs/export_%s.log" % ts
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(contenido)
	f.close()
	return path

## Exporta todo el log a un archivo (RFC16). `logger` es el autoload GameLogger.
static func export_all(logger: Node) -> String:
	return export_to_file(logger.export_all())

## Exporta las últimas N líneas (para bug reports). `logger` es el autoload GameLogger.
static func export_last_lines(logger: Node, lines: int) -> String:
	return export_to_file(logger.export_last_lines(lines))