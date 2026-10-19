# M28: Viajes — Reserva con capacidad (RF1 del 05 real, ítem [30] cola repoblada).
# Modelo data-driven: capacidad por ruta + ocupación por pasajeros con ventana
# horaria de reserva (el zarpar respeta el calendario M29/M93 vía el caller).
# Sin dependencias de autoload: puro; el travel_service decide integrarlo.
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19.
class_name TravelReserva
extends RefCounted

## Capacidad por ruta (route_id -> asientos del vapor). Default 6 si no configurada.
var _capacidad: Dictionary = {}
## Ocupación activa: route_id -> {pasajero_id: frame_dia_de_reserva}
var _reservas: Dictionary = {}
## Historial de cancelled para auditoría (último estado por pasajero).
var _audit: Array = []


## Configura la capacidad de asientos de una ruta.
func configurar_capacidad(route_id: StringName, asientos: int) -> void:
	_capacidad[route_id] = maxi(asientos, 0)


func capacidad(route_id: StringName) -> int:
	return int(_capacidad.get(route_id, 6))


## Asientos libres de la ruta (capacidad - ocupación activa).
func asientos_libres(route_id: StringName) -> int:
	var ocupados := 0
	if _reservas.has(route_id):
		ocupados = (_reservas[route_id] as Dictionary).size()
	return maxi(capacidad(route_id) - ocupados, 0)


## ¿La ruta está llena? (sin asientos libres)
func ruta_llena(route_id: StringName) -> bool:
	return asientos_libres(route_id) <= 0


## Reserva un asiento para pasajero_id en la ruta. Devuelve:
## {"ok": bool, "motivo": String} — rechazo silencioso si llena o ya reservado.
func reservar(route_id: StringName, pasajero_id: String, dia: int = 0) -> Dictionary:
	# ya_reservado primero: si el pasajero activo re-intenta, el motivo correcto
	# NO es capacidad (aunque la ruta esté llena con su propio asiento ocupado).
	if _reservas.has(route_id) and (_reservas[route_id] as Dictionary).has(pasajero_id):
		return {"ok": false, "motivo": "ya_reservado"}
	if ruta_llena(route_id):
		return {"ok": false, "motivo": "capacidad_agotada"}
	if not _reservas.has(route_id):
		_reservas[route_id] = {}
	(_reservas[route_id] as Dictionary)[pasajero_id] = dia
	_audit.append({"ev": "reserva", "route": String(route_id), "p": pasajero_id, "dia": dia})
	return {"ok": true, "asiento": asientos_libres(route_id)}


## Cancela la reserva del pasajero (libera el asiento). Devuelve true si existía.
func cancelar_reserva(route_id: StringName, pasajero_id: String) -> bool:
	if _reservas.has(route_id) and (_reservas[route_id] as Dictionary).erase(pasajero_id):
		_audit.append({"ev": "cancel", "route": String(route_id), "p": pasajero_id})
		return true
	return false


## Libera TODOS los asientos de la ruta (al zarpar/atrame — el viaje arrancó).
func liberar_ruta(route_id: StringName) -> void:
	_reservas[route_id] = {}


## Auditoría legible (últimos n eventos).
func eventos(n: int = 10) -> Array:
	return _audit.slice(maxi(_audit.size() - n, 0))
