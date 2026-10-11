# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: HouseUpgrade — mejoras por etapas con obra avanzada por días (M29).
extends Node
class_name HouseUpgrade

signal obra_iniciada(etapa_id: String)
signal obra_completada(etapa_id: String)

const ETAPA_MAXIMA := 5

var _etapa: int = 1
var _en_obra: bool = false
var _progreso_dias: int = 0
var _dias_totales: int = 0
var _etapa_objetivo: int = 0

## Etapa actual (1..5).
func etapa_actual() -> int:
	return _etapa

## ¿Hay una obra en curso?
func en_obra() -> bool:
	return _en_obra

## Progreso de la obra actual (0..100 %).
func progreso_obra() -> int:
	if _dias_totales <= 0:
		return 0
	return int(clampf(float(_progreso_dias) / float(_dias_totales) * 100.0, 0.0, 100.0))

## Próxima etapa alcanzable (o 0 si ya está al máximo).
func proxima_etapa() -> int:
	if _etapa >= ETAPA_MAXIMA:
		return 0
	return _etapa + 1

## Verifica los requisitos de una etapa: materiales (M14), misión, amistad.
## `inv` es el inventario del jugador (contrato count_item).
func verificar_requisitos(etapa_id: int, inv: Node, datos: Variant) -> Dictionary:
	if etapa_id <= _etapa:
		return {"ok": false, "razon": "etapa ya alcanzada"}
	if etapa_id > ETAPA_MAXIMA:
		return {"ok": false, "razon": "etapa inexistente"}
	if _en_obra:
		return {"ok": false, "razon": "obra en curso"}
	if datos == null:
		return {"ok": false, "razon": "sin datos de etapa"}
	# Requisito de misión (M21)
	var req_mision: String = String(datos.get("requisito_mision", ""))
	if not req_mision.is_empty():
		var misiones = get_node_or_null("/root/MisionManager")
		if misiones != null and misiones.has_method("esta_completada"):
			if not misiones.esta_completada(req_mision):
				return {"ok": false, "razon": "misión no completada: %s" % req_mision}
	# Requisito de amistad (M19)
	var req_amistad: int = int(datos.get("requisito_amistad", 0))
	if req_amistad > 0:
		var amigos = get_node_or_null("/root/AmistadManager")
		if amigos != null and amigos.has_method("obtener_max_amistad"):
			if int(amigos.obtener_max_amistad()) < req_amistad:
				return {"ok": false, "razon": "amistad insuficiente (%d)" % req_amistad}
	# Materiales (M14)
	var costo: Dictionary = datos.get("costo", {})
	if inv != null and inv.has_method("count_item"):
		for item_id in costo:
			var necesario: int = int(costo[item_id])
			if int(inv.count_item(String(item_id))) < necesario:
				return {"ok": false, "razon": "falta %s x%d" % [item_id, necesario]}
	return {"ok": true}

## Inicia la obra hacia una etapa. `datos` describe la etapa (costo, días).
func iniciar_obra(etapa_id: int, datos: Variant) -> bool:
	if etapa_id <= _etapa or etapa_id > ETAPA_MAXIMA or _en_obra:
		return false
	_etapa_objetivo = etapa_id
	_dias_totales = maxi(1, int(datos.get("dias_obra", 1)) if datos != null else 1)
	_progreso_dias = 0
	_en_obra = true
	obra_iniciada.emit(str(etapa_id))
	return true

## Avanza la obra un día de juego (M29). Al completar, aplica la etapa.
func tick_diario() -> void:
	if not _en_obra:
		return
	_progreso_dias += 1
	if _progreso_dias >= _dias_totales:
		_en_obra = false
		_etapa = _etapa_objetivo
		_progreso_dias = 0
		_dias_totales = 0
		obra_completada.emit(str(_etapa))

## Aplica directamente una etapa (sin obra). Para carga/trampa/debug.
func aplicar_etapa(etapa: int) -> void:
	_etapa = clampi(etapa, 1, ETAPA_MAXIMA)
	_en_obra = false
	_progreso_dias = 0

## Estado para guardado (M58/M60).
func recolectar_estado() -> Dictionary:
	return {
		"etapa": _etapa,
		"en_obra": _en_obra,
		"progreso_dias": _progreso_dias,
		"dias_totales": _dias_totales,
		"etapa_objetivo": _etapa_objetivo,
	}

## Restaura el estado desde guardado.
func restaurar_estado(datos: Dictionary) -> void:
	_etapa = int(datos.get("etapa", 1))
	_en_obra = bool(datos.get("en_obra", false))
	_progreso_dias = int(datos.get("progreso_dias", 0))
	_dias_totales = int(datos.get("dias_totales", 0))
	_etapa_objetivo = int(datos.get("etapa_objetivo", 0))
