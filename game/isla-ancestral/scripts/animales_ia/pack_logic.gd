# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M65: Animales IA — PackLogic (comportamiento de manada)
#
# Maneja grupos de animales terrestres/gregarios:
# - Lider rotativo (cambia cada N segundos o cuando el lider huye)
# - Seguidores mantienen delta <= 5m del lider
# - Huida coordinada: si el lider huye, todos siguen
# - Cohesion: fuerza leve hacia el centro del grupo

extends RefCounted

const RADIO_MANADA: float = 8.0
const DELTA_SEGUIDOR: float = 5.0
const TIEMPO_LIDER_MAX: float = 15.0
const TIEMPO_LIDER_MIN: float = 5.0
const VELOCIDAD_COHESION: float = 0.3

var _miembros: Array = []
var _lider_id: String = ""
var _rng: RandomNumberGenerator = null


func _init(rng: RandomNumberGenerator = null) -> void:
	_rng = rng if rng != null else RandomNumberGenerator.new()
	_rng.randomize()


func agregar(nodo, instancia_id: String) -> void:
	if not _existe(instancia_id):
		_miembros.append({"nodo": nodo, "id": instancia_id, "es_lider": false, "tiempo_lider": 0.0, "huyendo": false})


func remover(instancia_id: String) -> void:
	for i in range(_miembros.size() - 1, -1, -1):
		if _miembros[i].id == instancia_id:
			_miembros.remove_at(i)
			if _lider_id == instancia_id:
				_lider_id = ""
			return


func _existe(instancia_id: String) -> bool:
	for m in _miembros:
		if m.id == instancia_id:
			return true
	return false


func tamanio() -> int:
	return _miembros.size()


func tiene_lider() -> bool:
	return _lider_id != ""


func posicion_lider() -> Vector3:
	if not tiene_lider():
		return Vector3.ZERO
	for m in _miembros:
		if m.id == _lider_id:
			if m.nodo != null and m.nodo.has_method("get_global_position"):
				return m.nodo.get_global_position()
	return Vector3.ZERO


func tick(delta: float, pos_jugador: Vector3) -> void:
	if _miembros.size() < 2:
		return
	_actualizar_lider(delta)
	_cohesion(delta, pos_jugador)


func _actualizar_lider(delta: float) -> void:
	if not tiene_lider():
		_asignar_lider()
		return
	var lider_data = _find_miembro(_lider_id)
	if lider_data == null:
		_lider_id = ""
		_asignar_lider()
		return
	lider_data.tiempo_lider += delta
	if lider_data.tiempo_lider >= _rng.randf_range(TIEMPO_LIDER_MIN, TIEMPO_LIDER_MAX):
		_cambiar_lider()


func _asignar_lider() -> void:
	if _miembros.size() == 0:
		return
	var idx := _rng.randi() % _miembros.size()
	for m in _miembros:
		m.es_lider = false
		m.tiempo_lider = 0.0
	_miembros[idx].es_lider = true
	_miembros[idx].tiempo_lider = 0.0
	_lider_id = _miembros[idx].id


func _cambiar_lider() -> void:
	var candidatos := []
	for m in _miembros:
		if not m.es_lider:
			candidatos.append(m)
	if candidatos.size() > 0:
		var nuevo = candidatos[_rng.randi() % candidatos.size()]
		nuevo.es_lider = true
		nuevo.tiempo_lider = 0.0
		_lider_id = nuevo.id


func _cohesion(_delta: float, _pos_jugador: Vector3) -> void:
	var lider_pos := posicion_lider()
	if lider_pos == Vector3.ZERO:
		return
	for m in _miembros:
		if m.id == _lider_id:
			continue
		if m.nodo == null or not is_instance_valid(m.nodo):
			continue
		var pos = m.nodo.global_position
		var dist = pos.distance_to(lider_pos)
		if dist > DELTA_SEGUIDOR:
			var dir = (lider_pos - pos).normalized()
			dir.y = 0
			if m.nodo.has_signal("solicitar_movimiento"):
				m.nodo.solicitar_movimiento.emit(pos + dir * dist * 0.1, VELOCIDAD_COHESION)


func _find_miembro(id: String) -> Dictionary:
	for m in _miembros:
		if m.id == id:
			return m
	return {}


func debe_huir_coordinado(instancia_id: String, distancia_jugador: float, radio_alarma: float) -> bool:
	if distancia_jugador > radio_alarma * 2.0:
		return false
	if instancia_id == _lider_id:
		return true
	if tiene_lider():
		var lider = _find_miembro(_lider_id)
		if lider != null and lider.get("huyendo", false):
			return true
	return false


func marcar_huyendo(instancia_id: String, huyendo: bool) -> void:
	for m in _miembros:
		if m.id == instancia_id:
			m.huyendo = huyendo


func destino_huida_coordinada(pos_jugador: Vector3) -> Vector3:
	var centro := Vector3.ZERO
	var count := 0
	for m in _miembros:
		if m.nodo != null and m.nodo.has_method("get_global_position"):
			centro += m.nodo.get_global_position()
			count += 1
	if count == 0:
		return pos_jugador + Vector3(10, 0, 10)
	centro /= float(count)
	var dir = (centro - pos_jugador)
	dir.y = 0
	if dir.length() < 0.01:
		dir = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
	else:
		dir = dir.normalized()
	return centro + dir * 10.0


func limpiar() -> void:
	var i := 0
	while i < _miembros.size():
		var m = _miembros[i]
		if m.nodo == null or not is_instance_valid(m.nodo):
			if m.id == _lider_id:
				_lider_id = ""
			_miembros.remove_at(i)
		else:
			i += 1
## Test helpers
func _get_lider_id() -> String:
	return _lider_id

func _set_lider(id: String) -> void:
	_lider_id = id
	for m in _miembros:
		m.es_lider = (m.id == id)
		m.tiempo_lider = 0.0
