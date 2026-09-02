# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M94: Retención sin FOMO — ObjetivoActivo
# Estado vivo de un objetivo: progreso actual, cobrado o no, versión del ciclo.
# Diseño original (04-Codigo.md §1.1, ObjetivoActivo.cs).

class_name ObjetivoActivo
extends RefCounted

var objetivo_id: String = ""
var progreso: int = 0
var cobrado: bool = false
var ciclo: int = 1          # rotación (día/semana/mes de juego)
var completado: bool = false

func _init(p_id: String = "") -> void:
	objetivo_id = p_id

func esta_completo(cantidad_requerida: int) -> bool:
	return progreso >= cantidad_requerida

## Avanza progreso y devuelve true si recién se completó.
func avanzar(cantidad_requerida: int, delta: int = 1) -> bool:
	var antes := esta_completo(cantidad_requerida)
	progreso += delta
	var despues := esta_completo(cantidad_requerida)
	if despues and not antes:
		completado = true
		return true
	return false

func a_diccionario() -> Dictionary:
	return {
		"objetivo_id": objetivo_id,
		"progreso": progreso,
		"cobrado": cobrado,
		"ciclo": ciclo,
		"completado": completado,
	}

static func desde_diccionario(d: Dictionary) -> ObjetivoActivo:
	var o := ObjetivoActivo.new(String(d.get("objetivo_id", "")))
	o.progreso = int(d.get("progreso", 0))
	o.cobrado = bool(d.get("cobrado", false))
	o.ciclo = int(d.get("ciclo", 1))
	o.completado = bool(d.get("completado", false))
	return o