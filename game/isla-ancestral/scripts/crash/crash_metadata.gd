# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — MetadataCollector (helper reutilizable, offline/headless).
# Implementa el servicio "MetadataCollector" del diseño (03-Diseno.md §3), que quedó `[ ]`:
#   collect_hardware_metadata -> recolectar_hardware
#   collect_software_metadata -> recolectar_software
#   collect_game_context      -> recolectar_contexto_juego
# RefCounted sin `class_name` (se carga vía preload, pitfall §9.17/§9.41/§9.52). NO es Node, así
# que NO usa get_tree(): la escena y el contexto de juego se INYECTAN (testeable sin autoloads).
#
# Desviaciones del diseño medidas en el motor (no supuestas), ver 04-Codigo.md §15:
#   - `OS.get_dynamic_memory_usage()` NO EXISTE en Godot 4.7 -> era un SCRIPT ERROR de parseo.
#     Se usa `OS.get_memory_info()` -> {physical, free, available, stack}.
#   - El diseño ponía `get_processor_count()` en un campo llamado "architecture" -> se usa
#     `Engine.get_architecture_name()` (p. ej. "x86_64") y los cores quedan en `cpu_cores`.
#   - `ram_total` en el diseño era `OS.get_static_memory_usage()` (memoria DEL PROCESO, no del
#     sistema) -> se usa `memory_info.physical`. `ram_available` -> `memory_info.available`.

extends RefCounted


## Hardware: SO, CPU, GPU y memoria. Headless-safe (la GPU devuelve "" sin emitir ERROR).
func recolectar_hardware() -> Dictionary:
	var memoria: Dictionary = OS.get_memory_info()
	return {
		"os": OS.get_name(),
		"os_version": OS.get_version(),
		"architecture": Engine.get_architecture_name(),
		"cpu": OS.get_processor_name(),
		"cpu_cores": OS.get_processor_count(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"gpu_driver": RenderingServer.get_video_adapter_vendor(),
		"ram_total": int(memoria.get("physical", 0)),
		"ram_available": int(memoria.get("available", 0)),
	}


## Software: versión del juego y del motor, modo de ejecución y escena actual (inyectada).
func recolectar_software(escena: String = "") -> Dictionary:
	var info: Dictionary = Engine.get_version_info()
	return {
		"game_version": str(ProjectSettings.get_setting("application/config/version", "")),
		"godot_version": str(info.get("string", "")),
		"execution_mode": "debug" if OS.has_feature("debug") else "release",
		"scene": escena,
	}


## Contexto de juego: PURO — recibe los datos ya extraídos del juego. Así el helper no depende
## de ServiceRegistry (que en headless puede no tener game_clock/player) y se testea sin autoloads.
func recolectar_contexto_juego(datos: Dictionary) -> Dictionary:
	return {
		"game_time": str(datos.get("game_time", "")),
		"season": str(datos.get("season", "")),
		"player_position": datos.get("player_position", Vector3.ZERO),
		"world_seed": datos.get("world_seed", ""),
	}


## Fusión de las 3 capas: es lo que el CrashReporter adjunta al dump.
func recolectar_todo(escena: String = "", datos_juego: Dictionary = {}) -> Dictionary:
	var meta := recolectar_hardware()
	meta.merge(recolectar_software(escena))
	meta.merge(recolectar_contexto_juego(datos_juego))
	return meta
