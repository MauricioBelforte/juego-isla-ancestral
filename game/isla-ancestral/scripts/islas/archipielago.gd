# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M27: Islas del Mundo — Archipielago (Resource).
# Índice del archipiélago: qué islas DEBEN existir. Es lo que permite detectar
# un `.tres` faltante (requisito de fallback: ERROR + Aurora siempre carga).
#
# El registro NO confía sólo en este índice: escanea la carpeta de definiciones
# y compara "esperadas vs encontradas". Si el índice falta, igual funciona
# (sólo se pierde la detección de faltantes).

class_name Archipielago
extends Resource

@export var version: int = 1
## Ids que deben existir (orden estable). Aurora SIEMPRE va primera.
@export var islas_esperadas: PackedStringArray = PackedStringArray()
## Id de la isla principal (nunca se descarga, siempre carga).
@export var id_principal: StringName = &"aurora"


## Compara esperadas vs encontradas. Devuelve {faltantes, extra, ok}.
func comparar(encontradas: Array) -> Dictionary:
	var set_enc: Dictionary = {}
	for e in encontradas:
		set_enc[String(e)] = true
	var faltantes: Array[String] = []
	for esperada in islas_esperadas:
		if not set_enc.has(String(esperada)):
			faltantes.append(String(esperada))
	var extra: Array[String] = []
	for e in encontradas:
		if not islas_esperadas.has(String(e)):
			extra.append(String(e))
	extra.sort()
	return {"faltantes": faltantes, "extra": extra, "ok": faltantes.is_empty()}


func contar_esperadas() -> int:
	return islas_esperadas.size()
