# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos — Definición de evento (Resource data-driven)
#
# Cada evento (festival, feria, competencia, ritual, climático, sorpresa)
# se define como un .tres que carga este recurso con todos sus campos.

extends Resource
class_name EventDefinition

## Tipo de evento
enum Tipo { FESTIVAL, FERIA, COMPETENCIA, RITUAL, CLIMATICO, SORPRESA }

## ID único del evento (ej: "festival_primavera")
@export var id: String = ""
## Tipo (enum)
@export var tipo: Tipo = Tipo.FESTIVAL
## Clave localizable para nombre (M57)
@export var nombre_clave: StringName = &""
## Clave localizable para descripción (M57)
@export var descripcion_clave: StringName = &""

## ── Fecha ────────────────────────────────────────────────
## Día del mes (1-28). 0 = relativo/condicional.
@export var dia: int = 0
## Mes (1-12). -1 = cualquier mes.
@export var mes: int = -1
## Estación (0=Primavera,1=Verano,2=Otoño,3=Invierno). -1 = cualquier.
@export var estacion: int = -1

## ── Regla relativa (RF4.10) ─────────────────────────────────────────────
## Evento definido por posición dentro del mes en vez de por fecha fija:
##   "primer_lunes", "segundo_sabado", "ultimo_viernes", "cuarto_domingo"...
## El calendario Aurora tiene 12 meses de 28 días (4 semanas exactas), así que
## "cuarto_X" existe siempre y "quinto_X" no existe (se resuelve a 0).
## Vacío = evento de fecha fija.
@export var regla_relativa: String = ""

## ── Franja horaria (minutos desde 0:00, usa M30 GameClock) ──
@export var hora_inicio: int = 0      # 0-1439
@export var hora_fin: int = 1440      # 1440 = fin del día

## ── Aviso previo ─────────────────────────────────────────
## Días antes de emitir evento_proximo. Default 3.
@export var dias_aviso: int = 3

## ── Prioridad para solapes ───────────────────────────────
## Mayor gana. Festivales > Competencias > Ferias > Ritual > Sorpresa
@export var prioridad: int = 10

## ── Condiciones ──────────────────────────────────────────
@export var condiciones: Array = []   # Array de CondicionEvento Resources

## ── Recompensas ──────────────────────────────────────────
@export var recompensas: Array = []   # Array de RecompensaDef Resources

## ── Escena/recinto ───────────────────────────────────────
## PackedScene del recinto del evento. null = evento sin escena (solo señal).
@export var escena_recinto: Variant = null

## ── Ocupación NPC ────────────────────────────────────────
## IDs de NPCs que participan (M19). Vacío = todos disponibles.
@export var ocupacion_npc: Array = []

## ── Diálogo ──────────────────────────────────────────────
## ID del diálogo en M21 para el evento.
@export var dialogos_id: StringName = &""

## ── Variante climática ───────────────────────────────────
## Escena alternativa si hay clima severo (M32).
@export var variante_cubierta: Variant = null

## ── Recompensa compensatoria (fallback) ──────────────────
## Si la escena falla, entregar esta recompensa en lugar.
@export var recompensa_compensatoria: Variant = null

## ── Flags extensibles ────────────────────────────────────
@export var flags: Dictionary = {}

## ── Métodos ──────────────────────────────────────────────

## Retorna true si este evento corresponde a la fecha dada.
## Para eventos relativos (RF4.10) resuelve la regla a un día concreto del mes.
func coincide_fecha(_p_dia: int, _p_mes: int, _p_estacion: int) -> bool:
	var coin_mes := self.mes == -1 or self.mes == _p_mes
	var coin_est := self.estacion == -1 or self.estacion == _p_estacion
	if not (coin_mes and coin_est):
		return false
	if es_relativa():
		# RF4.10: la regla decide el día dentro del mes consultado.
		return fechas_relativas(_p_mes).has(_p_dia)
	var coin_dia := self.dia == 0 or self.dia == _p_dia
	return coin_dia


## ── Reglas relativas (RF4.10) ───────────────────────────────────────────
## El calendario Aurora son 12 meses de 28 días = 4 semanas exactas, así que el
## día de la semana de (mes, dia) es ((mes-1)*28 + (dia-1)) % 7 y NO depende del
## año (igual que GameTime.get_semana_dia()).
const ORDENES: Dictionary = {
	"primer": 1, "segundo": 2, "tercer": 3, "cuarto": 4, "ultimo": -1,
}
const SEMANA: Dictionary = {
	"lunes": 0, "martes": 1, "miercoles": 2, "jueves": 3,
	"viernes": 4, "sabado": 5, "domingo": 6,
}
const DIAS_POR_MES_CAL: int = 28
const DIAS_POR_SEMANA_CAL: int = 7

## true si el evento se define por regla relativa y no por fecha fija.
func es_relativa() -> bool:
	return regla_relativa != ""

## Días del mes `p_mes` que satisfacen la regla relativa.
## Regla inválida o imposible (p. ej. "quinto_lunes") -> array vacío:
## el evento simplemente no ocurre ese mes (no se inventa una fecha).
func fechas_relativas(p_mes: int) -> Array:
	var dias: Array = []
	if not es_relativa() or p_mes < 1 or p_mes > 12:
		return dias
	var partes := regla_relativa.split("_")
	if partes.size() != 2:
		return dias
	var orden: Variant = ORDENES.get(String(partes[0]), null)
	var dia_semana: Variant = SEMANA.get(String(partes[1]), null)
	if orden == null or dia_semana == null:
		return dias
	var dentro: Array = []
	for d in range(1, DIAS_POR_MES_CAL + 1):
		if ((p_mes - 1) * DIAS_POR_MES_CAL + (d - 1)) % DIAS_POR_SEMANA_CAL != int(dia_semana):
			continue
		dentro.append(d)
	if dentro.is_empty():
		return dias
	if int(orden) == -1:
		dias.append(int(dentro[dentro.size() - 1]))
	elif int(orden) <= dentro.size():
		dias.append(int(dentro[int(orden) - 1]))
	return dias

## Día concreto que resuelve la regla para `p_mes` (0 si no aplica).
static func resolver(regla: String, p_mes: int) -> int:
	var ev := EventDefinition.new()
	ev.regla_relativa = regla
	var dias: Array = ev.fechas_relativas(p_mes)
	return 0 if dias.is_empty() else int(dias[0])


## Retorna true si la hora actual está dentro de la franja
func esta_en_franja(hora: int, minuto: int) -> bool:
	var minutos_act := hora * 60 + minuto
	return minutos_act >= hora_inicio and minutos_act < hora_fin


## Retorna minutos restantes hasta el inicio
func minutos_hasta_inicio(hora: int, minuto: int) -> int:
	var actuales = hora * 60 + minuto
	var inicio = hora_inicio
	if inicio <= actuales:
		# Ya pasó hoy, calcular para mañana
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
		"regla_relativa": regla_relativa,
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
	ev.regla_relativa = String(d.get("regla_relativa", ""))
	ev.hora_inicio = d.get("hora_inicio", 0)
	ev.hora_fin = d.get("hora_fin", 1440)
	ev.dias_aviso = d.get("dias_aviso", 3)
	ev.prioridad = d.get("prioridad", 10)
	ev.ocupacion_npc = d.get("ocupacion_npc", [])
	ev.dialogos_id = d.get("dialogos_id", &"")
	ev.flags = d.get("flags", {})
	return ev
