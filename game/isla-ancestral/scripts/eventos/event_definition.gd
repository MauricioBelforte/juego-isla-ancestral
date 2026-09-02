# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos â€” DefiniciÃ³n de evento (Resource data-driven)
#
# Cada evento (festival, feria, competencia, ritual, climÃ¡tico, sorpresa)
# se define como un .tres que carga este recurso con todos sus campos.

extends Resource
class_name EventDefinition

## Tipo de evento
enum Tipo { FESTIVAL, FERIA, COMPETENCIA, RITUAL, CLIMATICO, SORPRESA }

## ID Ãºnico del evento (ej: "festival_primavera")
@export var id: String = ""
## Tipo (enum)
@export var tipo: Tipo = Tipo.FESTIVAL
## Clave localizable para nombre (M57)
@export var nombre_clave: StringName = &""
## Clave localizable para descripciÃ³n (M57)
@export var descripcion_clave: StringName = &""

## â”€â”€ Fecha â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## DÃ­a del mes (1-28). 0 = relativo/condicional.
@export var dia: int = 0
## Mes (1-12). -1 = cualquier mes.
@export var mes: int = -1
## EstaciÃ³n (0=Primavera,1=Verano,2=OtoÃ±o,3=Invierno). -1 = cualquier.
@export var estacion: int = -1

## â”€â”€ Franja horaria (minutos desde 0:00, usa M30 GameClock) â”€â”€
@export var hora_inicio: int = 0      # 0-1439
@export var hora_fin: int = 1440      # 1440 = fin del dÃ­a

## â”€â”€ Aviso previo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## DÃ­as antes de emitir evento_proximo. Default 3.
@export var dias_aviso: int = 3

## â”€â”€ Prioridad para solapes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## Mayor gana. Festivales > Competencias > Ferias > Ritual > Sorpresa
@export var prioridad: int = 10

## â”€â”€ Condiciones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
@export var condiciones: Array = []   # Array de CondicionEvento Resources

## â”€â”€ Recompensas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
@export var recompensas: Array = []   # Array de RecompensaDef Resources

## â”€â”€ Escena/recinto â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## PackedScene del recinto del evento. null = evento sin escena (solo seÃ±al).
@export var escena_recinto: Variant = null

## â”€â”€ OcupaciÃ³n NPC â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## IDs de NPCs que participan (M19). VacÃ­o = todos disponibles.
@export var ocupacion_npc: Array = []

## â”€â”€ DiÃ¡logo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## ID del diÃ¡logo en M21 para el evento.
@export var dialogos_id: StringName = &""

## â”€â”€ Variante climÃ¡tica â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## Escena alternativa si hay clima severo (M32).
@export var variante_cubierta: Variant = null

## â”€â”€ Recompensa compensatoria (fallback) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
## Si la escena falla, entregar esta recompensa en lugar.
@export var recompensa_compensatoria: Variant = null

## â”€â”€ Flags extensibles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
@export var flags: Dictionary = {}

## â”€â”€ MÃ©todos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

## Retorna true si este evento corresponde a la fecha dada
func coincide_fecha(_p_dia: int, _p_mes: int, _p_estacion: int) -> bool:
	var coin_dia := self.dia == 0 or self.dia == _p_dia
	var coin_mes := self.mes == -1 or self.mes == _p_mes
	var coin_est := self.estacion == -1 or self.estacion == _p_estacion
	return coin_dia and coin_mes and coin_est


## Retorna true si la hora actual estÃ¡ dentro de la franja
func esta_en_franja(hora: int, minuto: int) -> bool:
	var minutos_act := hora * 60 + minuto
	return minutos_act >= hora_inicio and minutos_act < hora_fin


## Retorna minutos restantes hasta el inicio
func minutos_hasta_inicio(hora: int, minuto: int) -> int:
	var actuales = hora * 60 + minuto
	var inicio = hora_inicio
	if inicio <= actuales:
		# Ya pasÃ³ hoy, calcular para maÃ±ana
		inicio += 1440
	return inicio - actuales


## Retorna minutos restantes hasta el fin
func minutos_hasta_fin(hora: int, minuto: int) -> int:
	var actuales = hora * 60 + minuto
	return hora_fin - actuales


## Serializa a dictionary
func to_dict() -> Dictionary:
	return {
		"id": id,
		"tipo": tipo,
		"nombre_clave": str(nombre_clave),
		"descripcion_clave": str(descripcion_clave),
		"dia": dia,
		"mes": mes,
		"estacion": estacion,
		"hora_inicio": hora_inicio,
		"hora_fin": hora_fin,
		"dias_aviso": dias_aviso,
		"prioridad": prioridad,
		"escena_recinto_path": str(escena_recinto) if escena_recinto != null else "",
		"ocupacion_npc": ocupacion_npc,
		"dialogos_id": str(dialogos_id),
		"flags": flags,
	}


static func from_dict(d: Dictionary) -> EventDefinition:
	var ev := EventDefinition.new()
	ev.id = d.get("id", "")
	ev.tipo = d.get("tipo", 0)
	ev.nombre_clave = d.get("nombre_clave", &"")
	ev.descripcion_clave = d.get("descripcion_clave", &"")
	ev.dia = d.get("dia", 0)
	ev.mes = d.get("mes", -1)
	ev.estacion = d.get("estacion", -1)
	ev.hora_inicio = d.get("hora_inicio", 0)
	ev.hora_fin = d.get("hora_fin", 1440)
	ev.dias_aviso = d.get("dias_aviso", 3)
	ev.prioridad = d.get("prioridad", 10)
	ev.ocupacion_npc = d.get("ocupacion_npc", [])
	ev.dialogos_id = d.get("dialogos_id", &"")
	ev.flags = d.get("flags", {})
	return ev
