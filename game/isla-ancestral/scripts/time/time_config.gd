extends Resource
class_name TimeConfig

## Módulo 29: Tiempo y Calendario — Configuración de knobs
##
## Duraciones ajustables sin recompilar. Cargado como autoload "TimeConfig"
## o instanciado desde data/time/time_config.tres

## ── Duración del ciclo ───────────────────────────────────
@export var seg_dia_real: float = 1440.0     # 24 min reales = día de juego
@export var min_por_dia: int = 1440           # 24 * 60 minutos de juego
@export var dias_por_semana: int = 7
@export var dias_por_mes: int = 28
@export var meses_por_anio: int = 12
@export var proporcion_tiempo: float = 40.0   # 1:40 (1 s real = 1 min juego)

## ── Nombres localizables ─────────────────────────────────
@export var nombres_dias: Array[String] = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
@export var nombres_meses: Array[String] = [
	"Floración", "Lluvia", "Crecimiento",     # Primavera
	"Sol", "Cosecha", "Madurez",              # Verano
	"Viento", "Caída", "Reposo",              # Otoño
	"Nieve", "Silencio", "Renacimiento"       # Invierno
]
@export var nombres_estaciones: Array[String] = ["Primavera", "Verano", "Otoño", "Invierno"]
@export var estacion_por_mes: Array[int] = [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3]

## ── Horarios especiales ──────────────────────────────────
@export var hora_amanecer: int = 6
@export var hora_atardecer: int = 20
@export var duracion_gradiente_amanecer: float = 90.0   # segundos reales
@export var duracion_gradiente_atardecer: float = 90.0  # segundos reales

## ── Configuración de eventos ───────────────────────────
@export var ventana_aviso_evento_horas: int = 24   # aviso 24h antes
@export var dias_proximos_eventos: int = 7          # próximos 7 días en UI

## ── Año inicial ────────────────────────────────────────
@export var anio_fundacion: int = 1
@export var estacion_inicial: int = 0  # Primavera

## ── Formato de hora ────────────────────────────────────
@export var usar_formato_12h: bool = false

## ── Semilla de tiempo por partida ──────────────────────
@export var usar_semilla_tiempo: bool = true


## Cálculos derivados
func get_dias_por_anio() -> int:
	return meses_por_anio * dias_por_mes

func get_min_por_hora() -> int:
	return 60

func get_seg_por_min_real() -> float:
	return 1.0  # 1 segundo real = 1 min juego


## Validación básica
func _validate_property(property_info: Dictionary) -> void:
	var property = property_info.name
	match property:
		"seg_dia_real":
			if seg_dia_real <= 0:
				push_error("seg_dia_real debe ser > 0")
		"min_por_dia":
			if min_por_dia <= 0:
				push_error("min_por_dia debe ser > 0")
		"dias_por_semana":
			if dias_por_semana <= 0:
				push_error("dias_por_semana debe ser > 0")
		"dias_por_mes":
			if dias_por_mes <= 0:
				push_error("dias_por_mes debe ser > 0")
		"meses_por_anio":
			if meses_por_anio <= 0:
				push_error("meses_por_anio debe ser > 0")
		"proporcion_tiempo":
			if proporcion_tiempo <= 0:
				push_error("proporcion_tiempo debe ser > 0")
		"hora_amanecer":
			if hora_amanecer < 0 or hora_amanecer >= 24:
				push_error("hora_amanecer debe estar entre 0 y 23")
		"hora_atardecer":
			if hora_atardecer < 0 or hora_atardecer >= 24 or hora_atardecer <= hora_amanecer:
				push_error("hora_atardecer debe estar entre 0 y 23 y ser > hora_amanecer")