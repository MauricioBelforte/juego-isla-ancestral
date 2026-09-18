# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1 — parte data-driven): BossData — extends EnemyData con las
# mecanicas de jefe: fases con umbrales de HP y habilidades especiales.
# 2 jefes del diseno: Guardian de la Montana (Templo/Montana) y Senor del
# Templo. La ejecucion de fases la consume enemy_ai (M64, pendiente).
class_name BossData
extends EnemyData

## Numero de fases del jefe (cambia patron a cierto % de HP).
@export var phases: int = 1
## Umbrales de HP (0.0-1.0) que disparan cambio de fase, ordenados.
@export var phase_thresholds: Array[float] = []
## Identificadores de habilidades especiales (las resuelve M64/M163).
@export var special_abilities: Array[String] = []
## Musica propia del jefe (dueño M43/M65 — vacio = musica de zona).
@export var music_track: AudioStream = null

func _init() -> void:
	categoria = Categoria.JEFE

## Valida jefe: esquema EnemyData + fases coherentes.
func es_valido_jefe() -> bool:
	if not es_valido():
		return false
	if phases < 1:
		return false
	# Los umbrales deben estar en (0,1) y ordenados (la tabla del diseño
	# los expresa de HP alto a bajo: 0.75, 0.5, 0.25 — descendente).
	var anterior: float = 1.0
	for t in phase_thresholds:
		if t <= 0.0 or t >= 1.0 or t > anterior:
			return false
		anterior = t
	return true
