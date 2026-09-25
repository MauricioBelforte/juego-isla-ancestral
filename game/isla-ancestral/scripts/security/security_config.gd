# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M106: Seguridad — SecurityConfig (Resource de configuración, V0).
# Implementa el "SecurityConfig (Resource)" del diseño (03-Diseno.md §11), que quedó `[ ]`:
#   api_rate_limit              -> api_rate_limit
#   max_gold                    -> max_gold
#   max_items                   -> max_items
#   enable_checksum_validation  -> enable_checksum_validation
#   enable_signature_validation -> enable_signature_validation
#   enable_duplication_prevention -> enable_duplication_prevention
#   enable_economy_validation   -> enable_economy_validation
#   enable_audit_logging        -> enable_audit_logging
#
# ⚠️ Sin `class_name` a propósito (convención del repo §9.17/§9.41 para scripts de este módulo):
# se carga vía `preload("res://scripts/security/security_config.gd")`. Un Resource con @export
# funciona igual; sólo cambia cómo se referencia desde código.

extends Resource

@export var api_rate_limit: int = 100
@export var max_gold: int = 1000000
@export var max_items: int = 9999
@export var enable_checksum_validation: bool = true
@export var enable_signature_validation: bool = true
@export var enable_duplication_prevention: bool = true
@export var enable_economy_validation: bool = true
@export var enable_audit_logging: bool = true


## Construye un diccionario plano (para inyectar en otros servicios o serializar).
func como_diccionario() -> Dictionary:
	return {
		"api_rate_limit": api_rate_limit,
		"max_gold": max_gold,
		"max_items": max_items,
		"enable_checksum_validation": enable_checksum_validation,
		"enable_signature_validation": enable_signature_validation,
		"enable_duplication_prevention": enable_duplication_prevention,
		"enable_economy_validation": enable_economy_validation,
		"enable_audit_logging": enable_audit_logging,
	}
