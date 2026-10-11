# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: HouseVisit — visitas de vecinos: agenda horaria (M29), reacciones
# a la decoración y puntos de amistad por valor decorativo (M19).
# Lee el estado de HouseManager por duck-typing; no lo modifica.
extends Node
class_name HouseVisit

signal visita_iniciada(vecino_id: String, house_id: String)
signal visita_terminada(vecino_id: String, house_id: String)

const FRANJAS_HORARIAS := {"manana": 9, "mediodia": 12, "tarde": 16, "noche": 20}

var _visitas_hoy: Dictionary = {}  # vecino_id -> bool
var _agenda: Dictionary = {}       # franja -> Array[vecino_id]
var _preferencias: Dictionary = {} # vecino_id -> String (estilo preferido)

## Programa una visita en una franja horaria (M29).
func programar_visita(vecino_id: String, franja: String) -> void:
	if not FRANJAS_HORARIAS.has(franja):
		return
	if not _agenda.has(franja):
		_agenda[franja] = []
	var arr: Array = _agenda[franja]
	if not arr.has(vecino_id):
		arr.append(vecino_id)
	_agenda[franja] = arr

## Vecinos que visitan en una franja.
func visitas_programadas(franja: String) -> Array:
	return _agenda.get(franja, [])

## Intenta iniciar la visita de un vecino a una casa.
## Requiere que el vecino sea el dueño/amigo de esa casa (contrato manager).
func iniciar_visita(vecino_id: String, house_id: String, manager: Node) -> Dictionary:
	if vecino_id.is_empty() or house_id.is_empty():
		return {"ok": false, "razon": "parámetros vacíos"}
	if _visitas_hoy.has(vecino_id):
		return {"ok": false, "razon": "ya visitó hoy"}
	if manager == null:
		return {"ok": false, "razon": "sin manager"}
	# Solo entra si es su casa o si tiene amistad (M19).
	var vecino_casa: String = ""
	if manager.has_method("obtener_vecino"):
		vecino_casa = String(manager.obtener_vecino(house_id))
	var permitido: bool = vecino_casa == vecino_id
	if not permitido:
		var amigos = get_node_or_null("/root/AmistadManager")
		if amigos != null and amigos.has_method("obtener_amistad"):
			permitido = int(amigos.obtener_amistad(vecino_id)) > 0
	if not permitido:
		return {"ok": false, "razon": "vecino no vinculado a la casa"}
	_visitas_hoy[vecino_id] = true
	if manager.has_method("registrar_entrada_vecino"):
		manager.registrar_entrada_vecino(house_id, vecino_id)
	visita_iniciada.emit(vecino_id, house_id)
	return {"ok": true}

## Termina la visita y devuelve siempre una salida (nunca bloquea la puerta).
func terminar_visita(vecino_id: String, house_id: String, manager: Node) -> void:
	_visitas_hoy.erase(vecino_id)
	if manager != null and manager.has_method("registrar_salida_vecino"):
		manager.registrar_salida_vecino(house_id, vecino_id)
	visita_terminada.emit(vecino_id, house_id)

## Reacción del vecino a la decoración de la casa (comentario M21).
## El comentario depende de si el estilo coincide con su preferencia.
func reaccion_decoracion(vecino_id: String, estilo_casa: String) -> Dictionary:
	var pref: String = String(_preferencias.get(vecino_id, ""))
	if pref.is_empty():
		return {"reacciona": true, "comentario": "¡Qué acogedora está tu casa!"}
	if estilo_casa == pref:
		return {
			"reacciona": true,
			"comentario": "¡Adoro este estilo %s! Has captado mi gusto." % estilo_casa.to_lower()
		}
	return {
		"reacciona": true,
		"comentario": "Interesante decoración... yo habría elegido el estilo %s." % pref.to_lower()
	}

## El vecino usa un mueble apto (sentarse en una silla, admirar un cuadro).
## Requiere `mueble` con categoría (FurnitureData o Dictionary).
func vecino_usa_mueble(mueble: Variant) -> Dictionary:
	if mueble == null:
		return {"usa": false, "accion": ""}
	var cat: String = String(mueble.get("categoria", "decorativo"))
	var nombre: String = String(mueble.get("nombre", "mueble"))
	match cat:
		"funcional":
			return {"usa": true, "accion": "sentarse", "mueble": nombre}
		"almacenamiento":
			return {"usa": true, "accion": "admirar", "mueble": nombre}
		_:
			return {"usa": true, "accion": "admirar", "mueble": nombre}

## Puntos de amistad ganados por el valor decorativo de la casa.
## `valor` = suma del valor de los muebles colocados (HouseManager).
func puntos_amistad_por_valor(valor: int) -> int:
	return int(clampf(float(valor) / 10.0, 0.0, 50.0))

## Define la preferencia de estilo de un vecino.
func definir_preferencia(vecino_id: String, estilo: String) -> void:
	if not vecino_id.is_empty() and not estilo.is_empty():
		_preferencias[vecino_id] = estilo

## Reinicia las visitas diarias (tick M29 al cambiar de día).
func reiniciar_dia() -> void:
	_visitas_hoy.clear()

## Estado para guardado (M58/M60).
func recolectar_estado() -> Dictionary:
	return {
		"visitas_hoy": _visitas_hoy.duplicate(true),
		"agenda": _agenda.duplicate(true),
		"preferencias": _preferencias.duplicate(true),
	}

## Restaura el estado desde guardado.
func restaurar_estado(datos: Dictionary) -> void:
	_visitas_hoy = datos.get("visitas_hoy", {}).duplicate(true)
	_agenda = datos.get("agenda", {}).duplicate(true)
	_preferencias = datos.get("preferencias", {}).duplicate(true)
