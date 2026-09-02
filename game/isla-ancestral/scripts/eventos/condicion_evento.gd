# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos — Condición reutilizable para eventos
#
# Cada condición se evalúa contra un contexto (Dictionary) y retorna
# {ok: bool, razon: StringName}.

extends Resource
class_name CondicionEvento

## Tipo de condición
enum TipoCondicion {
	HORA_EN_FRANJA,    # Hora dentro de rango
	ESTACION,          # Estación del año
	CLIMA_OK,          # Clima permite (no tormenta)
	AMISTAD_MIN,       # Amistad mínima con NPC
	HISTORIA_PROGRESO, # Progreso de historia requerido
	INVENTARIO_TIENE,  # Tener item en inventario
	SEMANA_DIA,        # Día de la semana
	DIA_MES,           # Día específico del mes
}

@export var tipo_condicion: TipoCondicion = TipoCondicion.ESTACION
@export var valor: Variant = null     # int/String según tipo
@export var bandera: bool = true      # true = requiere, false = excluye
@export var mensaje_fallo_clave: StringName = &""


## Evalúa la condición contra el contexto
## ctx debe tener: hora, minuto, dia, mes, anio, estacion, semana_dia,
##                 clima, amistad_npcs (dict), historia_sellos (array), inventario (dict)
func evaluar(ctx: Dictionary) -> Dictionary:
	var ok := false
	var razon: StringName = &""

	match tipo_condicion:
		TipoCondicion.HORA_EN_FRANJA:
			var hora = ctx.get("hora", 0)
			var minuta = ctx.get("minuto", 0)
			var mins = hora * 60 + minuta
			ok = mins >= int(valor)

		TipoCondicion.ESTACION:
			var est = ctx.get("estacion", -1)
			ok = est == int(valor)

		TipoCondicion.CLIMA_OK:
			var clima = ctx.get("clima", 0)
			# 0=soleado, 1=nublado, 2=lluvia, 3=tormenta, 4=tropical
			# Clima_OK significa que NO es tormenta
			ok = clima != 3

		TipoCondicion.AMISTAD_MIN:
			var npc_id = str(valor)
			var amistad = ctx.get("amistad_npcs", {})
			var nivel = int(amistad.get(npc_id, 0))
			ok = nivel >= int(ctx.get("umbral_amistad", 0))

		TipoCondicion.HISTORIA_PROGRESO:
			var sellos = ctx.get("historia_sellos", [])
			ok = sellos.has(str(valor))

		TipoCondicion.INVENTARIO_TIENE:
			var inv = ctx.get("inventario", {})
			ok = int(inv.get(str(valor), 0)) > 0

		TipoCondicion.SEMANA_DIA:
			var sd = ctx.get("semana_dia", -1)
			ok = sd == int(valor)

		TipoCondicion.DIA_MES:
			var d = ctx.get("dia", -1)
			ok = d == int(valor)

	if not ok and mensaje_fallo_clave != &"":
		razon = mensaje_fallo_clave
	elif not ok:
		razon = _tipo_a_nombre()

	return {"ok": ok, "razon": razon}


func _tipo_a_nombre() -> StringName:
	match tipo_condicion:
		TipoCondicion.HORA_EN_FRANJA:
			return &"fuera_de_horario"
		TipoCondicion.ESTACION:
			return &"estacion_incorrecta"
		TipoCondicion.CLIMA_OK:
			return &"clima_severo"
		TipoCondicion.AMISTAD_MIN:
			return &"amistad_insuficiente"
		TipoCondicion.HISTORIA_PROGRESO:
			return &"historia_no_alcanzada"
		TipoCondicion.INVENTARIO_TIENE:
			return &"item_no_posuido"
		TipoCondicion.SEMANA_DIA:
			return &"dia_incorrecto"
		TipoCondicion.DIA_MES:
			return &"dia_incorrecto"
		_:
			return &"condicion_no_cumplida"
