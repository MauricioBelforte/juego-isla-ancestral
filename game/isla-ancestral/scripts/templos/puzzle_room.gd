# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M24: Framework emisor-receptor para puzzles de Templos.
# Regla: el jugador activa emisores; cuando el estado de la sala S coincide con
# el objetivo T, el/los receptor (puerta) reaccionan. El grafo se valida para
# garantizar solucion unica y no arbitraria (requisito de la puerta F4).

## PuzzleRoom: vector de estado S, reglas emisor->receptor y validacion del grafo.
class_name PuzzleRoom
extends RefCounted

## Emisores de la sala (ids 0..n). Cada emisor tiene estado bool.
var emisores: Dictionary = {}

## Reglas: cada regla es {emisores: Array[int] (ids que deben estar ON), receptor: String}
## Un receptor reacciona cuando todos sus emisores estan ON.
var reglas: Array = []

## Resultado del ultimo chequeo (para feedback/test)
var completada: bool = false

## M24 (QA cruzado Hy3/WorkBuddy, iter 1): callback de notificacion. Se invoca tras
## cualquier cambio de estado con la lista de receptores activos. Permite conectar
## el framework emisor->receptor sin acoplar PuzzleRoom a nodos (es RefCounted).
## Uso: sala.al_cambiar = func(activos): puerta_evaluar(activos)
var al_cambiar: Callable = Callable()

func _init(ids_emisores: Array = []) -> void:
	for id in ids_emisores:
		emisores[id] = false

func set_emisor(id: int, valor: bool) -> void:
	if emisores.has(id):
		emisores[id] = valor
		_notificar()

func toggle_emisor(id: int) -> void:
	if emisores.has(id):
		emisores[id] = not emisores[id]
		_notificar()

## Recalcula el estado y dispara el callback al_cambiar (si asignado).
## Devuelve los receptores activos (mismo que recalcular()).
func _notificar() -> Array:
	var activos := recalcular()
	if al_cambiar.is_valid():
		al_cambiar.call(activos)
	return activos

func emisor_on_count() -> int:
	var n := 0
	for id in emisores:
		if emisores[id]:
			n += 1
	return n

## Estado de la sala como vector booleano (para serializar/validar)
func get_vector_estado() -> Array:
	var v: Array = []
	for id in emisores.keys():
		v.append(emisores[id])
	return v

## Anade una regla: el receptor reacciona si todos los emisores listados estan ON.
func add_regla(emisores_regla: Array, receptor: String) -> void:
	reglas.append({"emisores": emisores_regla, "receptor": receptor})

## Recalcula los receptores activos dado el estado actual y si la sala esta completada
## (objetivo T = todas las reglas cumplidas). Devuelve la lista de receptores activos.
func recalcular() -> Array:
	var activos: Array = []
	completada = true
	for regla in reglas:
		var cumple := true
		for eid in regla["emisores"]:
			if not emisores.get(eid, false):
				cumple = false
		if cumple:
			activos.append(regla["receptor"])
		else:
			completada = false
	completada = completada and reglas.size() > 0
	return activos

## Numero de reglas cumplidas (para el indicador de progreso / "casi solucion")
func progreso() -> int:
	var n := 0
	for regla in reglas:
		var cumple := true
		for eid in regla["emisores"]:
			if not emisores.get(eid, false):
				cumple = false
		if cumple:
			n += 1
	return n

## VALIDACION DE NO ARBITRARIEDAD: la suite exige que el puzzle tenga UNA solucion.
## Un puente trivial no basta: al menos un emisor debe poder estar OFF en la solucion.
## Se considera valido si: (a) todas las reglas usan emisores existentes,
## y (b) ninguna regla usa el conjunto vacio, y (c) el conjunto de emisores se usa.
func validar() -> Array:
	var errores: Array = []
	for regla in reglas:
		if regla["emisores"].is_empty():
			errores.append("regla con conjunto de emisores vacio (receptor %s)" % regla["receptor"])
		for eid in regla["emisores"]:
			if not emisores.has(eid):
				errores.append("regla usa emisor inexistente %d (receptor %s)" % [eid, regla["receptor"]])
	# Ningun puzzle con 0 reglas es valido (arbitrario)
	if reglas.is_empty():
		errores.append("sala sin reglas: arbitraria")
	return errores

## Devuelve una descripcion compacta del grafo para debug/tests
func descripcion() -> String:
	var partes: Array = []
	for regla in reglas:
		partes.append("%s<=%s" % [regla["receptor"], str(regla["emisores"])])
	return "S=%s | reglas: %s" % [str(get_vector_estado()), "; ".join(partes)]
