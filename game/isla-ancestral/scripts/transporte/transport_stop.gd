# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M68: Transporte y Navegación — TransportStop (Resource).
# Una parada del grafo: puerto (barco), plataforma (dirigible), estación (tren)
# o muelle local. Es la unidad de desbloqueo (M71) y de señalización (M46).
#
# Convención del proyecto: el ID es estable y snake_case ("puerto_aurora");
# el texto visible se localiza (M87) por clave "M68.STOP.<id>".

class_name TransportStop
extends Resource

## ID estable de la parada (nunca cambia entre versiones).
@export var id: StringName = &""
## Clave de localización del nombre visible (M87). Fallback: nombre_fallback.
@export var nombre_clave: String = ""
## Nombre en español, usado como fallback y en tests.
@export var nombre_fallback: String = ""
## Tipo de parada: "barco", "dirigible", "tren", "muelle".
@export var tipo: String = "barco"
## Isla a la que pertenece (M27/M28). Vacío = no declarada.
@export var isla_id: String = ""
## Posición en el mundo (voxel 1 m, Z arriba).
@export var pos: Vector3 = Vector3.ZERO
## Hora de apertura (0-23) según el reloj del juego (M29).
@export_range(0, 23) var horario_apertura: int = 6
## Hora de cierre (0-23). Si cierre <= apertura, la parada es nocturna.
@export_range(0, 23) var horario_cierre: int = 22
## ¿Tiene cartel físico en el mundo? (M46)
@export var tiene_cartel: bool = true
## ¿Está desbloqueada de inicio, o requiere una construcción/flag (M71)?
@export var desbloqueada_inicial: bool = true
## Flag de WorldState que desbloquea la parada (M71/M22). Vacío = ninguna.
@export var desbloquea_flag: StringName = &""
## POI del mapa asociado (M54). Vacío = sin marcador.
@export var poi_id: String = ""


## ¿La parada está abierta a la hora `hora` (0-23)? Soporta horario nocturno.
func abierta_a(hora: int) -> bool:
	var h: int = clampi(hora, 0, 23)
	if horario_cierre == horario_apertura:
		return true  # 24 h
	if horario_cierre > horario_apertura:
		return h >= horario_apertura and h < horario_cierre
	# Horario que cruza medianoche (ej. 22 → 5).
	return h >= horario_apertura or h < horario_cierre


## Texto del horario "06:00-22:00" (12h/24h se resuelve en la UI, M58).
func horario_texto() -> String:
	return "%02d:00-%02d:00" % [horario_apertura, horario_cierre]


func a_diccionario() -> Dictionary:
	return {
		"id": String(id),
		"tipo": tipo,
		"isla": isla_id,
		"pos": [snappedf(pos.x, 0.001), snappedf(pos.y, 0.001), snappedf(pos.z, 0.001)],
		"horario": horario_texto(),
		"cartel": tiene_cartel,
	}
