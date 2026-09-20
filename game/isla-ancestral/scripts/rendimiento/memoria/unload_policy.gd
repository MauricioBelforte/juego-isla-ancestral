# Modelo: deepseek-v4-flash (núcleo) · DeepSeek-V4.1-Flash (iter. 3)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-01 · 2026-09-19
#
# M62: Memoria — UnloadPolicy
# Política de descarga (RF5): marca candidatos (recursos) con peso y
# distancia/edad, ejecuta descargas escalonadas por frame (anti-picos RF8).
# Diseño original (04-Codigo.md §2, UnloadPolicy).
#
# Iter. 3 (Log 1094): el diseño §5.4 fija el escalonamiento POR PRESET
# (Baja 8 · Media 12 · Alta 16). El código tenía una constante fija 3, que no
# es ninguno de los tres valores. Se añade `max_por_frame_para(preset)` y se
# conserva `MAX_POR_FRAME` como tope por defecto para las llamadas que no
# declaran preset. Además se registra el último lote descargado, para que el
# monitor pueda dejar la decisión en el log (M103) sin volver a recorrer nada.

class_name UnloadPolicy
extends RefCounted

## Tope por defecto (llamadas sin preset). Conservador a propósito: RN2 pide
## deltas < 50 ms y liberar de a pocos es lo que lo garantiza.
const MAX_POR_FRAME := 3

## Escalonamiento por preset (diseño §5.4).
const MAX_POR_FRAME_PRESET := {"baja": 8, "media": 12, "alta": 16}

var _candidatos: Array = []  # [{recurso, peso, distancia, edad}]
var _ultimo_lote: Array = [] # [{peso, distancia, edad}] del último ejecutar_descarga()

func marcar_candidato(recurso: Resource, peso: int, distancia: float = INF) -> void:
	_candidatos.append({
		"recurso": recurso,
		"peso": peso,
		"distancia": distancia,
		"edad": Time.get_ticks_msec(),
	})

## Tope de descargas por frame según el preset gráfico (diseño §5.4).
func max_por_frame_para(preset: String) -> int:
	return int(MAX_POR_FRAME_PRESET.get(preset, MAX_POR_FRAME))

## Ejecuta descargas hasta liberar `hasta_mb`, máx `max_por_frame` por llamada.
## Ordena por: lejanía primero, luego por edad (LRU). Devuelve MB "liberados"
## (peso de candidatos retirados de la cola; el drop de referencia real lo
## hace el caller, ya que Resource es RefCounted y no admite free()).
func ejecutar_descarga(hasta_mb: int, max_por_frame: int = MAX_POR_FRAME) -> int:
	_ultimo_lote.clear()
	# Ordenar: candidatos lejanos (distancia grande) primero, luego LRU
	_candidatos.sort_custom(func(a, b):
		var da: float = a.get("distancia", INF)
		var db: float = b.get("distancia", INF)
		if abs(da - db) > 0.001:
			return da > db
		return int(a.get("edad", 0)) < int(b.get("edad", 0))
	)
	var liberados := 0
	var descargados := 0
	var a_eliminar: Array = []
	for candidato in _candidatos:
		if liberados >= hasta_mb or descargados >= max_por_frame:
			break
		liberados += int(candidato["peso"])
		descargados += 1
		_ultimo_lote.append({
			"peso": int(candidato["peso"]),
			"distancia": float(candidato.get("distancia", INF)),
			"edad": int(candidato.get("edad", 0)),
		})
		a_eliminar.append(candidato)
	for c in a_eliminar:
		_candidatos.erase(c)
	return liberados

## Resumen textual del último lote, para el log de M103 (diseño §G).
func resumen_ultimo_lote() -> String:
	if _ultimo_lote.is_empty():
		return "sin descargas"
	var partes: Array[String] = []
	for item in _ultimo_lote:
		partes.append("%d MB (dist %.1f)" % [int(item["peso"]), float(item["distancia"])])
	return ", ".join(partes)

func candidatos_count() -> int:
	return _candidatos.size()

func ultimo_lote_count() -> int:
	return _ultimo_lote.size()

## Orden en que se descargarían los candidatos (sin consumirlos). Sirve para
## verificar el criterio distancia > edad sin tocar la cola.
func previsualizar_orden() -> Array:
	var copia: Array = _candidatos.duplicate()
	copia.sort_custom(func(a, b):
		var da: float = a.get("distancia", INF)
		var db: float = b.get("distancia", INF)
		if abs(da - db) > 0.001:
			return da > db
		return int(a.get("edad", 0)) < int(b.get("edad", 0))
	)
	var salida: Array = []
	for c in copia:
		salida.append({"peso": int(c["peso"]), "distancia": float(c.get("distancia", INF))})
	return salida
