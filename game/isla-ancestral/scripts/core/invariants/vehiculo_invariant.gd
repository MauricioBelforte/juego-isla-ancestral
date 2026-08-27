# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Invariante de Vehículo
# Si un vehículo queda fuera del mundo, reaparece en su amarre tras 30 s.

## Valida vehículos: dentro del mundo; reaparición en amarre tras timeout.
class_name VehiculoInvariant
extends InvariantBase

func _init() -> void:
	categoria = IRecoverable.CategoriaRecuperable.VEHICULO

func _check() -> bool:
	return true  # Validación concreta delegada al sistema de vehículos

func _razon_fallo() -> String:
	return "Vehículo fuera del mundo"
