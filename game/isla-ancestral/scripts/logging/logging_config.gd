# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M103: Logging — LoggingConfig (Resource).
# Define la configuración por build del Logger (sección 10 de 02-Analisis).
# Los getters permiten que el Logger lea campos sin acoplarse a la estructura.

class_name LoggingConfig
extends Resource

## Nivel mínimo que se emite (0=DEBUG...4=CRITICAL)
@export var level_min: int = 0

## Categorías habilitadas (int de Logger.Category)
@export var categories_enabled: Array[int] = [0, 1, 2, 3, 4, 5, 6]

## Tamaño máximo del archivo activo en MB antes de rotar
@export var max_file_size_mb: float = 10.0

## Máximo de archivos rotados conservados
@export var max_rotated_files: int = 5

## ¿Comprimir rotados con gzip?
@export var compress_old_logs: bool = true

## ¿Output en JSON (para herramientas)?
@export var json_output: bool = false

## ¿Sanitizar datos sensibles?
@export var sanitize_sensitive: bool = true

# ── Getters (usados por Logger via has_method) ──
func get_level_min() -> int:
	return level_min

func get_categories_enabled() -> Array[int]:
	return categories_enabled

func get_max_file_size_mb() -> float:
	return max_file_size_mb

func get_max_rotated_files() -> int:
	return max_rotated_files

func get_compress_old_logs() -> bool:
	return compress_old_logs

func get_json_output() -> bool:
	return json_output

func get_sanitize_sensitive() -> bool:
	return sanitize_sensitive