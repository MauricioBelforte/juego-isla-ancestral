# Modelo: deepseek-v4-flash (núcleo) · glm-5.3-flash (iter. 2) · DeepSeek-V4.1-Flash (iter. 3)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-01 · 2026-09-19
#
# M62: Memoria — GlobalPool
# Pooling global por familia (RF3): piscinas tipadas con API
# obtener/devolver/precalentar, límites y contadores.
# Diseño original (04-Codigo.md §2, GlobalPool).
# Iter. 2 (Log 604, glm-5.3-flash): auditoría de señales al devolver
# (desconexión explícita — checklist RN), fallback honesto documentado,
# drenar_familia() para cambio de escena parcial.
#
# Iter. 3 (Log 1094, DeepSeek-V4.1-Flash):
#  · `precalentar()` ahora DEVUELVE cuántos ítems creó (antes void, así que el
#    llamador no podía distinguir "precalenté 8" de "no hice nada").
#  · Guarda de precalentamiento (diseño §4): "al arrancar y en pantalla de
#    carga (M63), NUNCA en mitad de gameplay". `marcar_gameplay_iniciado()`
#    cierra la ventana y `precalentar()` pasa a ser un no-op que avisa.
#  · Contrato de "ítem limpio" VERIFICABLE: `esta_limpio(objeto)` comprueba
#    las 4 condiciones del diseño §4 en vez de confiar en que se cumplieron.
#  · `reiniciar_pool()` opcional por familia (se detecta con `has_method`).
#  · Holder opcional anti-huérfanos: los ítems estacionados cuelgan de un nodo
#    padre, así que nunca quedan huérfanos en el árbol (checklist §E).
#  · `liberar_todo()`/`drenar_familia()` ahora LIBERAN de verdad (antes sólo
#    vaciaban los arrays: los nodos quedaban vivos y sin dueño → leak).

class_name GlobalPool
extends RefCounted

var _pools: Dictionary = {}   # familia -> Array de objetos (pool)
var _limites: Dictionary = {} # familia -> int
var _tamanios_max: Dictionary = {}  # familia -> int (máximo visto)
var _holder: Node = null      # nodo padre de los ítems estacionados
var _gameplay_iniciado: bool = false
var _avisos_precalentamiento: int = 0

## Nodo padre bajo el que se cuelgan los ítems estacionados. Sin holder, los
## ítems quedan sin padre (comportamiento previo, útil en tests aislados).
func set_holder(nodo: Node) -> void:
	_holder = nodo

func holder() -> Node:
	return _holder

## Cierra la ventana de precalentamiento (diseño §4). A partir de aquí
## `precalentar()` no crea nada: precalentar en gameplay es justo lo que el
## diseño prohíbe (produce el pico de frame que RN2 evita).
func marcar_gameplay_iniciado() -> void:
	_gameplay_iniciado = true

func precalentamiento_permitido() -> bool:
	return not _gameplay_iniciado

## Precalienta `cantidad` objetos de `familia`. Devuelve cuántos creó
## (0 si no hay factory válida o si el gameplay ya arrancó).
func precalentar(familia: String, cantidad: int, factory: Callable = Callable()) -> int:
	if cantidad <= 0 or not factory.is_valid():
		return 0
	if not precalentamiento_permitido():
		_avisos_precalentamiento += 1
		if _avisos_precalentamiento == 1:
			push_warning("[M62] precalentar('%s') ignorado: el gameplay ya arrancó (diseño §4)" % familia)
		return 0
	if not _pools.has(familia):
		_pools[familia] = []
	var creados := 0
	var limite: int = _limites.get(familia, 256)
	for i in range(cantidad):
		if (_pools[familia] as Array).size() >= limite:
			break
		var obj: Node = factory.call()
		if obj == null:
			continue
		_colgar(obj)
		(_pools[familia] as Array).append(obj)
		creados += 1
	if creados > 0:
		_tamanios_max[familia] = max(_tamanios_max.get(familia, 0), (_pools[familia] as Array).size())
	return creados

## Devuelve un objeto de la familia (o null si está vacía sin factory).
func obtener(familia: String) -> Node:
	var pool: Array = _pools.get(familia, [])
	if pool.is_empty():
		return null
	var obj: Node = pool.pop_back()
	if obj == null or not is_instance_valid(obj):
		return null
	# Al salir del pool el objeto queda activo y visible (estado de uso)
	obj.set_process(true)
	obj.set_physics_process(true)
	if obj is CanvasItem:
		(obj as CanvasItem).visible = true
	if obj is Node3D:
		(obj as Node3D).visible = true
	_descolgar(obj)
	return obj

## Devuelve el objeto al pool. Auditoría de señales (RN del checklist):
## desconecta TODAS las conexiones entrantes del objeto antes de
## estacionarlo (evita callbacks a nodos liberados). Si la familia está
## llena, fallback honesto: el objeto se libera con queue_free (sin
## crecer sin tope). Ítem devuelto: invisible, quieto, sin señales.
func devolver(familia: String, objeto: Node) -> bool:
	if objeto == null or not is_instance_valid(objeto):
		return false
	if not _pools.has(familia):
		_pools[familia] = []
	var pool: Array = _pools[familia]
	var limite: int = _limites.get(familia, 256)
	if pool.size() >= limite:
		# Fallback honesto (checklist RF): no crecer sin tope
		objeto.queue_free()
		return false
	objeto.set_process(false)
	objeto.set_physics_process(false)
	if objeto is CanvasItem:
		(objeto as CanvasItem).visible = false
	if objeto is Node3D:
		(objeto as Node3D).visible = false
	_auditar_senales(objeto)
	_reiniciar_estado(objeto)
	_colgar(objeto)
	pool.append(objeto)
	_tamanios_max[familia] = max(_tamanios_max.get(familia, 0), pool.size())
	return true

## Contrato de "ítem limpio" del diseño §4, VERIFICABLE: invisible, sin
## proceso, sin física y sin conexiones entrantes. No confía en que
## `devolver()` hizo su trabajo — lo comprueba.
func esta_limpio(objeto: Node) -> bool:
	if objeto == null or not is_instance_valid(objeto):
		return false
	if objeto.is_processing() or objeto.is_physics_processing():
		return false
	if objeto is CanvasItem and (objeto as CanvasItem).visible:
		return false
	if objeto is Node3D and (objeto as Node3D).visible:
		return false
	if not objeto.get_incoming_connections().is_empty():
		return false
	return true

## RN Auditoría de señales: desconecta las conexiones ENTRANTES al objeto
## (las que otros nodos le conectaron a él) para que un ítem estacionado
## no retenga callbacks a objetos que podrían liberarse primero.
func _auditar_senales(objeto: Node) -> void:
	var lista := objeto.get_incoming_connections()
	for conn in lista:
		var senal: Variant = conn.get("signal")
		var callable: Variant = conn.get("callable")
		if senal is Signal and callable is Callable:
			var s := senal as Signal
			var c := callable as Callable
			if c.is_valid() and s.is_connected(c):
				s.disconnect(c)

## Limpieza específica de la familia: si el objeto expone `reiniciar_pool()`,
## se llama (contrato opcional, detectado — nunca asumido).
func _reiniciar_estado(objeto: Node) -> void:
	if objeto.has_method("reiniciar_pool"):
		objeto.call("reiniciar_pool")

func _colgar(objeto: Node) -> void:
	if _holder == null or not is_instance_valid(_holder):
		return
	if objeto.get_parent() != _holder:
		if objeto.get_parent() != null:
			objeto.get_parent().remove_child(objeto)
		_holder.add_child(objeto)

func _descolgar(objeto: Node) -> void:
	if _holder != null and is_instance_valid(_holder) and objeto.get_parent() == _holder:
		_holder.remove_child(objeto)

func set_limite(familia: String, limite: int) -> void:
	_limites[familia] = limite

func limite(familia: String) -> int:
	return int(_limites.get(familia, 256))

func tamanio(familia: String) -> int:
	return int(_pools.get(familia, []).size())

func tamanio_maximo_visto(familia: String) -> int:
	return int(_tamanios_max.get(familia, 0))

## Drena UNA familia (cambio de escena parcial). Libera los nodos de verdad
## y devuelve cuántos liberó.
func drenar_familia(familia: String) -> int:
	var pool: Array = _pools.get(familia, [])
	var n := 0
	for obj in pool:
		if obj != null and is_instance_valid(obj):
			obj.queue_free()
			n += 1
	_pools[familia] = []
	return n

## Drena todos los pools (cambio de escena). Libera los nodos de verdad y
## devuelve cuántos liberó.
func liberar_todo() -> int:
	var total := 0
	for familia in _pools:
		total += drenar_familia(String(familia))
	return total

func familias() -> Array:
	var nombres: Array = _pools.keys()
	nombres.sort()
	return nombres
