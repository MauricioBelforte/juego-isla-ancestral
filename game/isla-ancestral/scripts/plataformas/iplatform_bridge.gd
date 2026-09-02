# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M96: Plataformas — IPlatformBridge
# Interfaz común de plataforma (RF10/RF11): logros, cloud saves, overlay.
# El core NUNCA referencia SDKs directos (Steamworks/EOS/GOG): siempre a
# través de esta abstracción (diseño original 04-Codigo.md §1.1).
# Cada plataforma implementa esta clase base (Steam/EOS/GOG/Null).

class_name IPlatformBridge
extends RefCounted

var nombre: String = "bridge"

## Desbloquea un logro (mapeo M59). No-op si la plataforma no lo soporta.
func desbloquear_logro(_id: String) -> void:
	push_warning("[M96] %s: desbloquear_logro no implementado" % nombre)

func cloud_disponible() -> bool:
	return false

func guardar_cloud(_data: PackedByteArray) -> bool:
	return false

func cargar_cloud() -> PackedByteArray:
	return PackedByteArray()

func mostrar_overlay() -> void:
	pass

## Guarda el save en la nube si está disponible (RF13 cross-save).
func guardar_save_cloud(ruta_local: String) -> bool:
	if not cloud_disponible():
		return false
	if not FileAccess.file_exists(ruta_local):
		return false
	var data := FileAccess.get_file_as_bytes(ruta_local)
	return guardar_cloud(data)

## Carga el save desde la nube y lo escribe en ruta_local.
func cargar_save_cloud(ruta_local: String) -> bool:
	if not cloud_disponible():
		return false
	var data := cargar_cloud()
	if data.is_empty():
		return false
	var f := FileAccess.open(ruta_local, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(data)
	f.close()
	return true