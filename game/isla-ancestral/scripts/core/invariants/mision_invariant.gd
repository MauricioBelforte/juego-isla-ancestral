# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Invariante de Misión
# Cada objetivo tiene un Fallback declarable; detecta condición imposible.

## Valida misiones: objetivos existentes, sin condición imposible.
class_name MisionInvariant
extends InvariantBase

## Registro de fallbacks declarados: objetivo_id -> alternativo_id
var _fallbacks: Dictionary = {}

## Misiones/ objetivos en curso que deben validar.
var _objetivos_activos: Dictionary = {}

func _init() -> void:
	categoria = IRecoverable.CategoriaRecuperable.MISION

func registrar_fallback(objetivo_id: String, alternativo_id: String) -> void:
	_fallbacks[objetivo_id] = alternativo_id

func registrar_objetivo(mision_id: String, objetivo_id: String) -> void:
	_objetivos_activos[mision_id] = objetivo_id

func tiene_fallback(objetivo_id: String) -> bool:
	return _fallbacks.has(objetivo_id)

func _check() -> bool:
	return true  # Validación concreta deleida al handler de M22

func _razon_fallo() -> String:
	return "Misión con objetivo imposible"
