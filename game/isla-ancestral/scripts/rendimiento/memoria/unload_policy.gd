# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M62: Memoria — UnloadPolicy
# Política de descarga (RF5): marca candidatos (recursos) con peso y
# distancia/edad, ejecuta descargas escalonadas por frame (anti-picos RF8).
# Diseño original (04-Codigo.md §2, UnloadPolicy).

class_name UnloadPolicy
extends RefCounted

const MAX_POR_FRAME := 3

var _candidatos: Array = []  # [{recurso, peso, distancia, edad}]

func marcar_candidato(recurso: Resource, peso: int, distancia: float = INF) -> void:
	_candidatos.append({
		"recurso": recurso,
		"peso": peso,
		"distancia": distancia,
		"edad": Time.get_ticks_msec(),
	})

## Ejecuta descargas hasta liberar `hasta_mb`, máx `max_por_frame` por llamada.
## Ordena por: lejanía primero, luego por edad (LRU). Devuelve MB "liberados"
## (peso de candidatos retirados de la cola; el drop de referencia real lo
## hace el caller, ya que Resource es RefCounted y no admite free()).
func ejecutar_descarga(hasta_mb: int, max_por_frame: int = MAX_POR_FRAME) -> int:
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
		a_eliminar.append(candidato)
	for c in a_eliminar:
		_candidatos.erase(c)
	return liberados

func candidatos_count() -> int:
	return _candidatos.size()