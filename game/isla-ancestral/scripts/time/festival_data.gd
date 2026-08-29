extends Resource
class_name FestivalData

## Módulo 29: Tiempo y Calendario — Datos de eventos periódicos
##
## Contiene definición de todos los eventos repetibles (regla cozy)
## Cargado desde data/time/festivals.tres

## ── Tipos de evento ─────────────────────────────────────
## EventoPeriodico se usa como Dictionary con estos campos:
## id, nombre, descripcion, tipo, dia, mes, estacion, repetible,
## duracion_horas, icono, efectos, condiciones

## ── Festivales estacionales (4) ─────────────────────────
@export var festivales_estacionales: Array[Dictionary] = [
	{
		"id": "festival_primavera",
		"nombre": "Festival de la Floración",
		"descripcion": "Celebración del renacimiento de la naturaleza. Las flores cubren la plaza.",
		"tipo": "festival",
		"dia": 15,
		"mes": 1,  # Floración (mes 1 de Primavera)
		"estacion": 0,
		"repetible": true,
		"duracion_horas": 24,
		"icono": "🌸",
		"efectos": {
			"decoracion_plaza": "flores",
			"tiendas_cerradas": true,
			"iluminacion_especial": false,
			"recompensas": ["semilla_flor", "miel"]
		},
		"condiciones": {}
	},
	{
		"id": "festival_verano",
		"nombre": "Festival de la Cosecha",
		"descripcion": "La vendimia llega a su punto máximo. Frutas y verduras abundan.",
		"tipo": "festival",
		"dia": 15,
		"mes": 5,  # Cosecha (mes 5 de Verano)
		"estacion": 1,
		"repetible": true,
		"duracion_horas": 24,
		"icono": "🌾",
		"efectos": {
			"decoracion_plaza": "cosecha",
			"tiendas_cerradas": true,
			"iluminacion_especial": false,
			"recompensas": ["fruta_madura", "vino"]
		},
		"condiciones": {}
	},
	{
		"id": "festival_otono",
		"nombre": "Festival del Viento",
		"descripcion": "Las hojas danzan al compás del viento otoñal. Cometas en el cielo.",
		"tipo": "festival",
		"dia": 15,
		"mes": 9,  # Caída (mes 9 de Otoño)
		"estacion": 2,
		"repetible": true,
		"duracion_horas": 24,
		"icono": "🍂",
		"efectos": {
			"decoracion_plaza": "hojas_cometas",
			"tiendas_cerradas": true,
			"iluminacion_especial": false,
			"recompensas": ["cometa", "hoja_dorada"]
		},
		"condiciones": {}
	},
	{
		"id": "festival_invierno",
		"nombre": "Festival de la Nieve",
		"descripcion": "La primera nevada cubre la isla. Muñecos de nieve en cada esquina.",
		"tipo": "festival",
		"dia": 15,
		"mes": 11,  # Nieve (mes 11 de Invierno - corregido: 10, 11, 12 son Invierno)
		"estacion": 3,
		"repetible": true,
		"duracion_horas": 24,
		"icono": "❄️",
		"efectos": {
			"decoracion_plaza": "nieve",
			"tiendas_cerradas": true,
			"iluminacion_especial": false,
			"recompensas": ["bufanda", "chocolate_caliente"]
		},
		"condiciones": {}
	}
]

## ── Festival Anual ──────────────────────────────────────
@export var festival_anual: Dictionary = {
	"id": "festival_luces",
	"nombre": "Festival de las Luces",
	"descripcion": "Fin de año: miles de faroles iluminan la noche más larga.",
	"tipo": "festival",
	"dia": 28,
	"mes": 12,  # Renacimiento (mes 12 de Invierno)
	"estacion": 3,
	"repetible": true,
	"duracion_horas": 12,  # Solo noche
	"icono": "🏮",
	"efectos": {
		"decoracion_plaza": "faroles",
		"tiendas_cerradas": true,
		"iluminacion_especial": true,  # M31 consume esto
		"recompensas": ["farol", "deseo_escrito"]
	},
	"condiciones": {}
}

## ── Cumpleaños (plantilla, se pobla desde M19 VillagerManager) ─────────────────
@export var plantilla_cumpleanos: Dictionary = {
	"id": "cumpleanos_",
	"nombre": "Cumpleaños de ",
	"descripcion": "¡Feliz cumpleaños! Ven a celebrarlo en la plaza.",
	"tipo": "cumpleanos",
	"dia": 1,
	"mes": 1,
	"estacion": -1,
	"repetible": true,
	"duracion_horas": 12,
	"icono": "🎂",
	"efectos": {
		"decoracion_plaza": "globos",
		"tiendas_cerradas": false,
		"iluminacion_especial": false,
		"recompensas": ["tarta", "regalo_amistad"]
	},
	"condiciones": {
		"vecino_id": ""
	}
}

## ── Visitas semanales (Gran Vapor) ────────────────────
@export var visitas_semanales: Array[Dictionary] = [
	{
		"id": "visita_comerciante",
		"nombre": "Llegada del Comerciante Viajero",
		"descripcion": "El Gran Vapor trae un comerciante con rarezas de otras islas.",
		"tipo": "visita",
		"dia": 7,  # Cada domingo
		"mes": -1,  # Todos los meses
		"estacion": -1,
		"repetible": true,
		"duracion_horas": 12,
		"icono": "⛴️",
		"efectos": {
			"decoracion_plaza": "puesto_comerciante",
			"tiendas_cerradas": false,
			"iluminacion_especial": false,
			"recompensas": ["objeto_raro", "semilla_exotica"]
		},
		"condiciones": {
			"frecuencia": "semanal",
			"dia_semana": 6  # Domingo (0=Lunes)
		}
	},
	{
		"id": "visita_artesano",
		"nombre": "Visita del Artesano Errante",
		"descripcion": "Un artesano ofrece talleres y planos exclusivos.",
		"tipo": "visita",
		"dia": 14,  # Cada dos semanas (quincenal)
		"mes": -1,
		"estacion": -1,
		"repetible": true,
		"duracion_horas": 8,
		"icono": "🔨",
		"efectos": {
			"decoracion_plaza": "taller_temporal",
			"tiendas_cerradas": false,
			"iluminacion_especial": false,
			"recompensas": ["plano_exclusivo", "material_raro"]
		},
		"condiciones": {
			"frecuencia": "quincenal",
			"dia_semana": 6
		}
	}
]

## ── Eventos mensuales ──────────────────────────────────
@export var eventos_mensuales: Array[Dictionary] = [
	{
		"id": "mercado_especial",
		"nombre": "Mercado Especial Mensual",
		"descripcion": "Productores locales ofrecen lo mejor de la temporada.",
		"tipo": "mercado",
		"dia": 1,  # Primer día de cada mes
		"mes": -1,
		"estacion": -1,
		"repetible": true,
		"duracion_horas": 12,
		"icono": "🏪",
		"efectos": {
			"decoracion_plaza": "puestos_mercado",
			"tiendas_cerradas": false,
			"iluminacion_especial": false,
			"recompensas": ["descuento_mercado"]
		},
		"condiciones": {}
	},
	{
		"id": "luna_cosecha",
		"nombre": "Luna de Cosecha",
		"descripcion": "Bajo la luna llena, los cultivos crecen más rápido esta noche.",
		"tipo": "especial",
		"dia": 14,  # Mitad de mes (luna llena aprox)
		"mes": -1,
		"estacion": -1,
		"repetible": true,
		"duracion_horas": 8,  # Noche
		"icono": "🌕",
		"efectos": {
			"decoracion_plaza": "",
			"tiendas_cerradas": false,
			"iluminacion_especial": true,
			"recompensas": ["bonus_cultivo"]
		},
		"condiciones": {
			"solo_noche": true
		}
	}
]

## ── Cumpleaños del jugador ────────────────────────────
@export var cumpleanos_jugador: Dictionary = {
	"id": "cumpleanos_jugador",
	"nombre": "¡Tu Cumpleaños!",
	"descripcion": "¡Feliz cumpleaños! Los vecinos prepararon una sorpresa.",
	"tipo": "cumpleanos",
	"dia": 1,
	"mes": 1,
	"estacion": -1,
	"repetible": true,
	"duracion_horas": 24,
	"icono": "🎁",
	"efectos": {
		"decoracion_plaza": "fiesta_jugador",
		"tiendas_cerradas": false,
		"iluminacion_especial": true,
		"recompensas": ["regalo_especial", "carta_vecinos"]
	},
	"condiciones": {}
}

## Obtiene todos los eventos como array plano para fácil iteración
func obtener_todos_eventos() -> Array[Dictionary]:
	var todos: Array[Dictionary] = []
	todos.append_array(festivales_estacionales)
	todos.append(festival_anual)
	todos.append_array(visitas_semanales)
	todos.append_array(eventos_mensuales)
	todos.append(cumpleanos_jugador)
	return todos

## Obtiene eventos para un día/mes específicos
func obtener_eventos_fecha(dia: int, mes: int, estacion: int) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var todos = obtener_todos_eventos()

	for evento in todos:
		var coincide_dia = (evento.dia == dia) or (evento.dia == -1)
		var coincide_mes = (evento.mes == mes) or (evento.mes == -1)
		var coincide_estacion = (evento.estacion == estacion) or (evento.estacion == -1)

		if coincide_dia and coincide_mes and coincide_estacion:
			resultado.append(evento)

	return resultado

## Obtiene próximos eventos desde una fecha dada
func obtener_proximos_eventos(dia_actual: int, mes_actual: int, anio_actual: int, dias_adelante: int = 7, time_config: Resource = null) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []

	# Usar config pasado o cargar por defecto
	var config = time_config
	if config == null:
		config = load("res://data/time/time_config.tres")
	if config == null:
		push_error("[FestivalData] No se pudo cargar time_config.tres")
		return resultado

	var dias_por_mes = config.dias_por_mes
	var meses_por_anio = config.meses_por_anio

	for i in range(1, dias_adelante + 1):
		var dia = dia_actual + i
		var mes = mes_actual
		var anio = anio_actual

		while dia > dias_por_mes:
			dia -= dias_por_mes
			mes += 1
			if mes > meses_por_anio:
				mes = 1
				anio += 1

		var est = config.estacion_por_mes[clampi(mes - 1, 0, meses_por_anio - 1)]
		var eventos_dia = obtener_eventos_fecha(dia, mes, est)

		for ev in eventos_dia:
			var ev_copia = ev.duplicate(true)
			ev_copia["dia_relativo"] = i
			ev_copia["fecha_absoluta"] = {"dia": dia, "mes": mes, "anio": anio}
			resultado.append(ev_copia)

	return resultado