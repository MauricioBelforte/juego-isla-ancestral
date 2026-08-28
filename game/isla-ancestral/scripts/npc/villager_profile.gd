extends Resource

## Módulo 19: NPC y Vecinos — Hoja de datos del vecino
##
## Cada vecino tiene un VillagerProfile como Resource (.tres).
## Contiene identidad, personalidad, gustos y rutina.

## ── Identidad ──────────────────────────────────────────
@export var id: String = ""
@export var nombre: String = ""
@export var especie: String = ""
@export var personalidad: String = ""
@export var edad_categoria: String = "adulto"
@export var profesion: String = ""

## ── Apariencia ─────────────────────────────────────────
## Color de la silueta (placeholder visual hasta modelos reales)
@export var color_cuerpo: Color = Color(0.6, 0.4, 0.3)
@export var color_cabeza: Color = Color(0.8, 0.6, 0.4)
@export var escala_cuerpo: float = 1.0

## ── Personalidad y gustos ─────────────────────────────
@export var historia: String = ""
@export var gustos: Array[String] = []
@export var disgustos: Array[String] = []
@export var hobbies: Array[String] = []

## ── Rutina ─────────────────────────────────────────────
## Diccionario franja_horaria → actividad (ej: "08:00": "trabajar")
@export var rutina_diaria: Dictionary = {}

## ── Diálogo ────────────────────────────────────────────
@export var linea_saludo: String = "¡Hola!"
@export var linea_despedida: String = "¡Hasta luego!"
@export var linea_sueno: String = "ZZZ..."

## ── Hogar ──────────────────────────────────────────────
@export var hogar_deseado: String = "bosque"


## Evalúa un objeto según gustos/disgustos del vecino.
## Retorna: +1.0 si gusta, -0.5 si disgusta, 0.0 neutro.
func evaluar_objeto(objeto_id: String) -> float:
	if objeto_id in gustos:
		return 1.0
	if objeto_id in disgustos:
		return -0.5
	return 0.0


## Retorna la clave de rutina activa para una hora dada.
func proxima_franja(hora: float) -> String:
	var hora_str: String = "%02d:00" % int(hora)
	if rutina_diaria.has(hora_str):
		return str(rutina_diaria[hora_str])
	return "libre"
