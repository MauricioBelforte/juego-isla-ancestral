# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos — Contexto para diálogos (consumido por M21)
#
# Se pasa al DialogueManager al iniciar un diálogo de festival.

extends RefCounted
class_name ContextoFestival

var evento: Object = null       # EventDefinition
var participante: StringName = &""
var resultado: Dictionary = {}  # {puesto, puntos, ...}
var anio: int = 0
var es_variante_cubierta: bool = false
var dias_restantes: int = 0


func _init() -> void:
	pass
