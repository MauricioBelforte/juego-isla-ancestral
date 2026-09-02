# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M65: Animales IA — SchoolLogic (comportamiento de banco/enjambre)
#
# Maneja grupos de animales acuaticos/aereos que forman bancos:
# - Delta <= 1.2m entre miembros (separacion minima)
# - Cohesion: moverse hacia el centro del grupo
# - Alineacion: misma direccion promedio
# - Separacion: evitar colisiones con vecinos cercanos
# - Migracion coordinada: todos cambian direction juntos

extends RefCounted

const DELTA_MAX_BANCO: float = 1.2
const RADIO_COHESION: float = 5.0
const RADIO_SEPARACION: float = 2.0
const VELOCIDAD_COHESION: float = 0.5
const VELOCIDAD_ALINEACION: float = 0.3
const VELOCIDAD_SEPARACION: float = 1.0

var _miembros: Array = []
var _direccion_grupal: Vector3 = Vector3(1, 0, 0)
var _tiempo_migracion: float = 0.0
const TIEMPO_MIGRACION: float = 30.0


func agregar(nodo, instancia_id: String) -> void:
	if not _existe(instancia_id):
		_miembros.append({
			"nodo": nodo,
			"id": instancia_id,
			"vel_dir": Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized(),
		})


func remover(instancia_id: String) -> void:
	for i in range(_miembros.size() - 1, -1, -1):
		if _miembros[i].id == instancia_id:
			_miembros.remove_at(i)
			return


func _existe(instancia_id: String) -> bool:
	for m in _miembros:
		if m.id == instancia_id:
			return true
	return false


func tamanio() -> int:
	return _miembros.size()


func tick(delta: float, pos_jugador: Vector3) -> void:
	if _miembros.size() < 2:
		return
	_direccion_grupal = _calcular_direccion_grupal()
	for m in _miembros:
		if m.nodo == null or not is_instance_valid(m.nodo):
			continue
		_aplicar_reglas(m, pos_jugador)
	_tiempo_migracion += delta
	if _tiempo_migracion >= TIEMPO_MIGRACION:
		_tiempo_migracion = 0.0
		_cambiar_direccion_migracion()


func _aplicar_reglas(miembro: Dictionary, pos_jugador: Vector3) -> void:
	var pos = miembro.nodo.global_position
	var cohesion: Vector3 = (_calcular_centro() - pos).normalized() * VELOCIDAD_COHESION
	var alineacion: Vector3 = _direccion_grupal * VELOCIDAD_ALINEACION
	var separacion: Vector3 = _calcular_separacion(miembro, pos)
	var vel: Vector3 = cohesion + alineacion + separacion
	vel.y = 0
	if vel.length() > 0.01:
		vel = vel.normalized()
	miembro.vel_dir = vel
	if miembro.nodo.has_signal("solicitar_movimiento"):
		var destino = pos + vel * 2.0
		miembro.nodo.solicitar_movimiento.emit(destino, 1.5)


func _calcular_centro() -> Vector3:
	var sum := Vector3.ZERO
	var count := 0
	for m in _miembros:
		if m.nodo != null and is_instance_valid(m.nodo):
			sum += m.nodo.global_position
			count += 1
	if count == 0:
		return Vector3.ZERO
	return sum / float(count)


func _calcular_direccion_grupal() -> Vector3:
	var sum := Vector3.ZERO
	var count := 0
	for m in _miembros:
		if m.nodo != null and is_instance_valid(m.nodo):
			sum += m.vel_dir
			count += 1
	if count == 0:
		return Vector3(1, 0, 0)
	return sum.normalized()


func _calcular_separacion(miembro: Dictionary, pos: Vector3) -> Vector3:
	var separacion := Vector3.ZERO
	for m in _miembros:
		if m.id == miembro.id:
			continue
		if m.nodo == null or not is_instance_valid(m.nodo):
			continue
		var otras_pos = m.nodo.global_position
		var dist = pos.distance_to(otras_pos)
		if dist < RADIO_SEPARACION and dist > 0.01:
			var away = (pos - otras_pos).normalized() / dist
			separacion += away
	if separacion.length() > 0.01:
		return separacion.normalized() * VELOCIDAD_SEPARACION
	return Vector3.ZERO


func _cambiar_direccion_migracion() -> void:
	_direccion_grupal = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
	for m in _miembros:
		m.vel_dir = _direccion_grupal


func debe_huir_banco(distancia_jugador: float, radio_alarma: float) -> bool:
	return distancia_jugador < radio_alarma * 3.0


func destino_huida_banco(pos_jugador: Vector3) -> Vector3:
	var centro := _calcular_centro()
	var dir = (centro - pos_jugador)
	dir.y = 0
	if dir.length() < 0.01:
		dir = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
	else:
		dir = dir.normalized()
	return centro + dir * 15.0


func verificar_delta_max() -> bool:
	if _miembros.size() < 2:
		return true
	var centro := _calcular_centro()
	for m in _miembros:
		if m.nodo != null and is_instance_valid(m.nodo):
			var dist = m.nodo.global_position.distance_to(centro)
			if dist > RADIO_COHESION:
				return false
	return true


func limpiar() -> void:
	_miembros.clear()
