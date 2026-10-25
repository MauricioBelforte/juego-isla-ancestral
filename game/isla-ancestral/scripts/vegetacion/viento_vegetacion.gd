# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-24
#
# M50 - BACKLOG-11 D8, bloque 50-Vegetacion: modelo de VIENTO DETERMINISTA con
# amplitud por bioma y clima (item L176 del checklist de M50).
#
# QUE ES Y QUE NO ES
#   NO es un shader. El shader existe (shaders/wind_vegetacion.gdshader, M90) y
#   es de otro frente: no se toca. Lo que ese shader NO tiene es la AMPLITUD por
#   bioma/clima ni una base determinista: usa TIME (reloj real del shader) y un
#   unico uniform `amplitud` con default fijo.
#
#   ESTE archivo es el MODELO que le falta:
#     * tablas de amplitud por bioma y por clima (y multiplicador por preset),
#     * `uniformes()` -> los 4 uniforms que el shader ya declara, calculados,
#     * `desplazamiento()` -> la MISMA formula del shader evaluada en CPU, para
#       poder verificarla headless (un shader no se puede asertar en CI).
#
# DETERMINISMO (la parte que el shader hoy no cumple)
#   El desplazamiento depende SOLO de (tick, posicion, bioma, clima, fase). NO
#   usa TIME ni RandomNumberGenerator: el mismo tick devuelve el mismo valor en
#   cualquier orden de llamada y en cualquier corrida. `tick` sale del reloj de
#   juego (entero), no del reloj de pared.
#
# Formula (espejo exacto de shaders/wind_vegetacion.gdshader:18-22):
#   s = sin(t * frecuencia + fase + x * 0.6 + z * 0.6) * amplitud * uv_y
#   VERTEX += direccion_viento * s

extends RefCounted

## Segundos por tick de simulacion. El viento NO avanza por frame: avanza por
## tick, asi que dos corridas con distinto framerate dan el MISMO viento.
const TICK_S := 0.05

## Techo del uniform `amplitud` en el shader (hint_range(0.0, 2.0)).
const AMPLITUD_MAX := 2.0

## Amplitud base por bioma (m). Un arbol en la montana se mueve mas que un
## helecho en el humedal; la playa tiene brisa constante.
const AMP_BIOMA := {
	"playa": 0.55,
	"pradera": 0.35,
	"bosque": 0.30,
	"montana": 0.70,
	"ribera": 0.40,
	"humedal": 0.25,
	"cercanias": 0.35,
	"cercanias_spawn": 0.35,
}

## Multiplicador por clima (M29/M31: el clima es del reloj del mundo).
const AMP_CLIMA := {
	"despejado": 1.0,
	"nublado": 1.25,
	"lluvia": 1.6,
	"tormenta": 2.0,
	"niebla": 0.7,
	"nieve": 1.3,
}

## Frecuencia (Hz del seno) por bioma. Dentro del hint_range(0.1, 5.0).
const FREQ_BIOMA := {
	"playa": 1.8,
	"pradera": 1.2,
	"bosque": 0.9,
	"montana": 2.2,
	"ribera": 1.4,
	"humedal": 0.8,
	"cercanias": 1.2,
	"cercanias_spawn": 1.2,
}

## Direccion dominante del viento por bioma (se normaliza al usarla).
const DIR_BIOMA := {
	"playa": Vector3(0.94, 0.0, 0.34),
	"pradera": Vector3(0.80, 0.0, 0.60),
	"bosque": Vector3(0.60, 0.0, 0.80),
	"montana": Vector3(1.00, 0.0, 0.20),
	"ribera": Vector3(0.70, 0.0, 0.71),
	"humedal": Vector3(0.50, 0.0, 0.87),
	"cercanias": Vector3(0.80, 0.0, 0.60),
	"cercanias_spawn": Vector3(0.80, 0.0, 0.60),
}

## Multiplicador por preset grafico: es el de data/performance/budgets.json
## (vegetacion.multiplicador_por_preset), no una tabla nueva.
const MULT_PRESET := {"baja": 0.2, "media": 0.45, "alta": 0.8, "ultra": 1.0}

const BIOMA_DEF := "pradera"
const CLIMA_DEF := "despejado"
const PRESET_DEF := "media"


## Amplitud efectiva (m) = amplitud del bioma x multiplicador del clima x preset.
## Nunca supera AMPLITUD_MAX (el techo que declara el shader).
static func amplitud(bioma: String, clima: String, preset: String = PRESET_DEF) -> float:
	var ab: float = float(AMP_BIOMA.get(bioma, AMP_BIOMA[BIOMA_DEF]))
	var ac: float = float(AMP_CLIMA.get(clima, AMP_CLIMA[CLIMA_DEF]))
	var mp: float = float(MULT_PRESET.get(preset, MULT_PRESET[PRESET_DEF]))
	return clampf(ab * ac * mp, 0.0, AMPLITUD_MAX)


static func frecuencia(bioma: String) -> float:
	return clampf(float(FREQ_BIOMA.get(bioma, FREQ_BIOMA[BIOMA_DEF])), 0.1, 5.0)


static func direccion(bioma: String) -> Vector3:
	var v: Vector3 = DIR_BIOMA.get(bioma, DIR_BIOMA[BIOMA_DEF])
	if v.length() < 0.0001:
		return Vector3(1.0, 0.0, 0.0)
	return v.normalized()


## Fase por instancia: 0..TAU derivada de la semilla del item del plan, para que
## dos arbustos vecinos no se muevan en fase. Determinista por semilla.
static func fase_de_item(seed_item: int) -> float:
	return fposmod(float(seed_item) * 0.61803398875, TAU)


## Desplazamiento local (m) que aplicaria el vertex shader.
## Espejo exacto de wind_vegetacion.gdshader: s = sin(...) * amplitud * uv_y.
static func desplazamiento(tick: int, pos: Vector3, bioma: String, clima: String,
		uv_y: float = 1.0, fase: float = 0.0, preset: String = PRESET_DEF) -> Vector3:
	var t := float(tick) * TICK_S
	var amp := amplitud(bioma, clima, preset)
	var m := clampf(uv_y, 0.0, 1.0)
	var s := sin(t * frecuencia(bioma) + fase + pos.x * 0.6 + pos.z * 0.6) * amp * m
	return direccion(bioma) * s


## Los 4 uniforms que declara el shader, calculados para (bioma, clima, preset).
## Es el contrato de cableado: quien monte el material asigna estos valores.
static func uniformes(bioma: String, clima: String, preset: String = PRESET_DEF,
		fase: float = 0.0) -> Dictionary:
	return {
		"amplitud": amplitud(bioma, clima, preset),
		"frecuencia": frecuencia(bioma),
		"direccion_viento": direccion(bioma),
		"fase": fase,
		"capa_mask": 1.0,
	}


## Valida las tablas contra la lista de biomas/climas que el llamador conoce.
## Devuelve la lista de faltantes (vacia = tablas completas).
static func validar_tablas(biomas: Array, climas: Array) -> Array:
	var faltan: Array = []
	for b in biomas:
		var k := String(b)
		if not AMP_BIOMA.has(k) or not FREQ_BIOMA.has(k) or not DIR_BIOMA.has(k):
			faltan.append("bioma:" + k)
	for c in climas:
		var k := String(c)
		if not AMP_CLIMA.has(k):
			faltan.append("clima:" + k)
	return faltan
