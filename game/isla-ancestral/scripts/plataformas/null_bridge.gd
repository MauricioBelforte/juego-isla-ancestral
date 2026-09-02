# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M96: Plataformas — NullBridge
# Implementación de IPlatformBridge para desarrollo local (sin tienda).
# Todas las operaciones son no-op. Diseño original (04-Codigo.md §1.1).

class_name NullBridge
extends IPlatformBridge

func _init() -> void:
	nombre = "NullBridge"

func desbloquear_logro(_id: String) -> void:
	pass  # dev: sin logros de plataforma

func cloud_disponible() -> bool:
	return false

func guardar_cloud(_data: PackedByteArray) -> bool:
	return false

func cargar_cloud() -> PackedByteArray:
	return PackedByteArray()

func mostrar_overlay() -> void:
	pass