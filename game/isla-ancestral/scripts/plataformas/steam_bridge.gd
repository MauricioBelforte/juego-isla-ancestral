# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M96: Plataformas — SteamBridge
# Implementación Steam (Steamworks): logros, cloud, overlay, Deck.
# ⚠️ MOCK: el SDK Steamworks no está integrado en este proyecto Godot aún
# (depende de M149 tiendas). Esta clase provee el contrato y un stub
# funcional con cloud simulada en disco para tests de cross-save.
# Diseño original (04-Codigo.md §1.1).

class_name SteamBridge
extends IPlatformBridge

const CLOUD_DIR := "user://cloud/steam"

func _init() -> void:
	nombre = "SteamBridge"

func desbloquear_logro(_id: String) -> void:
	# TODO(M149): Steamworks.Achievement.Store cuando el SDK esté integrado
	pass

func cloud_disponible() -> bool:
	return true

func guardar_cloud(data: PackedByteArray) -> bool:
	var dir := CLOUD_DIR
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var f := FileAccess.open("%s/save.bin" % dir, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(data)
	f.close()
	return true

func cargar_cloud() -> PackedByteArray:
	var path := "%s/save.bin" % CLOUD_DIR
	if not FileAccess.file_exists(path):
		return PackedByteArray()
	return FileAccess.get_file_as_bytes(path)

func mostrar_overlay() -> void:
	# TODO(M149): Steamworks overlay
	pass