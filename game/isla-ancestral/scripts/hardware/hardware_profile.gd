# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M115: Hardware - HardwareProfile (Resource).
# Sin `class_name` para que el test headless --script lo pueda usar via preload().
# Pitfalls respetados (07-GUIA-GODOT):
#   - snake_case en exports
#   - Enums nombrados
#   - Persistencia M59 con get_section_name/get_save_data/restore_save_data

extends Resource

enum QualityPreset { VERY_LOW, LOW, MEDIUM, HIGH, ULTRA }

@export var cpu_cores: int = 0
@export var cpu_name: String = "Unknown"
@export var cpu_freq_ghz: float = 0.0
@export var gpu_name: String = "Unknown GPU"
@export var gpu_vram_mb: int = 0
@export var ram_mb: int = 0
@export var os_name: String = "Unknown"
@export var os_version: String = "Unknown"
@export var quality_preset: int = QualityPreset.MEDIUM
@export var detected_at: String = ""
@export var user_override: bool = false

# ── Serializacion M59 ──────────────────────────────────────────

func get_section_name() -> String:
	return "hardware_profile"

func get_save_data() -> Dictionary:
	return {
		"version": 1,
		"quality_preset": quality_preset,
		"user_override": user_override,
		"detected_at": detected_at,
		"cpu_cores": cpu_cores,
		"gpu_vram_mb": gpu_vram_mb,
		"ram_mb": ram_mb,
	}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	quality_preset = int(data.get("quality_preset", QualityPreset.MEDIUM))
	user_override = bool(data.get("user_override", false))
	detected_at = String(data.get("detected_at", ""))
	cpu_cores = int(data.get("cpu_cores", cpu_cores))
	gpu_vram_mb = int(data.get("gpu_vram_mb", gpu_vram_mb))
	ram_mb = int(data.get("ram_mb", ram_mb))
