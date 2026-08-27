# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Invariante base
# Clase base para todas las invariantes del detector.

## Invariante abstracta. Cada subclase implementa _check() con la lógica de detección.
class_name InvariantBase
extends RefCounted

## Categoría de prioridad (ver IRecoverable.CategoriaRecuperable, se usa como int).
var categoria: int = 0

## Si está rota, este handler debería recuperar.
var handler: IRecoverable = null

## Texto descriptivo del último fallo (para logs/toast).
var ultima_razon: String = ""

## Ejecuta el chequeo. Devuelve true si la invariante está VÁLIDA (no rota).
func check() -> bool:
	var ok := _check()
	if not ok:
		ultima_razon = _razon_fallo()
	return ok

## Implementación concreta de la validación (override obligado).
func _check() -> bool:
	return true

## Razón legible del último fallo (override opcional).
func _razon_fallo() -> String:
	return "Invariante rota sin detalle"
