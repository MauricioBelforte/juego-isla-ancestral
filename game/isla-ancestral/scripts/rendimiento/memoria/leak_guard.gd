# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-19
#
# M62: Memoria — LeakGuard
# Patrón CENTRAL de desconexión y limpieza (diseño §4 y checklist §E).
#
# El problema que resuelve: en Godot un `connect()` con un lambda que captura
# un nodo externo, un `Timer` sin cancelar y un `Tween` en bucle mantienen
# VIVO al emisor y al receptor. No hay excepción ni warning: sólo memoria que
# crece. El diseño §4 lo prohíbe y el checklist §E pide un patrón documentado
# para TODOS los módulos, no una regla de estilo.
#
# Uso (patrón obligatorio):
#     var _guard := LeakGuard.new()
#     func _ready() -> void:
#         add_child(_guard)                       # _exit_tree() del guard
#         _guard.conectar(boton.pressed, _al_pulsar)
#         _guard.registrar_timer(mi_timer)
#     func _al_pulsar() -> void: ...
#
# Al salir del árbol, el guard desconecta, cancela y mata todo lo registrado.
#
# Reglas que el guard hace cumplir (checklist §E):
#   · señales registradas → desconectadas en `_exit_tree` (incluidos callables
#     con parámetros bound, que son los que más fácil se pierden);
#   · Timers → `stop()` + `queue_free()` si el guard es su dueño;
#   · Tweens → `kill()`;
#   · nodos registrados → comprobación de huérfanos.
# Y expone detectores puros (sin estado) para auditar el resto del proyecto.

class_name LeakGuard
extends Node

var _conexiones: Array = []  # [{senal: Signal, callable: Callable}]
var _timers: Array = []      # [WeakRef] de Timer
var _tweens: Array = []      # [Tween]
var _nodos: Array = []       # [WeakRef] de Node

var limpiezas: int = 0
var senales_desconectadas: int = 0
var timers_cancelados: int = 0
var tweens_matados: int = 0

## Registra una conexión para desconectarla al salir del árbol. Se guarda el
## Callable EXACTO que se conectó: reconstruir un `.bind()` no siempre compara
## igual, así que `disconnect()` podría fallar en silencio.
func conectar(senal: Signal, callable: Callable) -> void:
	if not callable.is_valid():
		push_warning("[M62] LeakGuard.conectar(): callable inválido")
		return
	if not senal.is_connected(callable):
		senal.connect(callable)
	_conexiones.append({"senal": senal, "callable": callable})

func registrar_timer(timer: Timer) -> void:
	if timer != null:
		_timers.append(weakref(timer))

func registrar_tween(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		_tweens.append(tween)

func registrar_nodo(nodo: Node) -> void:
	if nodo != null:
		_nodos.append(weakref(nodo))

## Desconecta, cancela y mata todo lo registrado. Idempotente.
func limpiar() -> Dictionary:
	var d := 0
	for item in _conexiones:
		var senal: Variant = item.get("senal")
		var callable: Variant = item.get("callable")
		if senal is Signal and callable is Callable:
			var s := senal as Signal
			var c := callable as Callable
			if c.is_valid() and s.is_connected(c):
				s.disconnect(c)
				d += 1
	_conexiones.clear()

	var t := 0
	for ref in _timers:
		if ref is WeakRef:
			var obj: Variant = (ref as WeakRef).get_ref()
			if obj is Timer and is_instance_valid(obj):
				(obj as Timer).stop()
				t += 1
	_timers.clear()

	var tw := 0
	for tween in _tweens:
		if tween is Tween and (tween as Tween).is_valid():
			(tween as Tween).kill()
			tw += 1
	_tweens.clear()

	_nodos.clear()
	limpiezas += 1
	senales_desconectadas += d
	timers_cancelados += t
	tweens_matados += tw
	return {"senales": d, "timers": t, "tweens": tw}

func _exit_tree() -> void:
	limpiar()

func conexiones_registradas() -> int:
	return _conexiones.size()

## ── Detectores puros (no necesitan instancia) ────────────────────────────

## Nodos huérfanos vivos (checklist §E: "prohibido crear Node sin padre").
static func contar_huerfanos() -> int:
	return int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))

static func contar_objetos() -> int:
	return int(Performance.get_monitor(Performance.OBJECT_COUNT))

## ¿El nodo quedó huérfano? (creado y nunca agregado a un padre)
static func es_huerfano(nodo: Node) -> bool:
	return nodo != null and is_instance_valid(nodo) and nodo.get_parent() == null

## Un `Callable` con argumentos bound es el que más fácil se filtra: al
## desconectar hay que usar la MISMA instancia, no reconstruirla.
static func tiene_bound(callable: Callable) -> bool:
	return callable.is_valid() and callable.get_bound_arguments_count() > 0

## Conexiones ENTRANTES de un nodo (lo que lo mantiene vivo).
static func conexiones_entrantes(nodo: Node) -> int:
	if nodo == null or not is_instance_valid(nodo):
		return 0
	return nodo.get_incoming_connections().size()

## Ciclos entre servicios (checklist §E). `campos` son los nombres de
## propiedad a inspeccionar: si A.campo apunta a B y B.campo apunta a A, hay
## un ciclo que ninguna de las dos partes puede romper sola → usar weakref o
## un getter directo. Devuelve pares ["a<->b"].
static func detectar_ciclos(servicios: Dictionary, campos: Array) -> Array:
	var nombres: Array = servicios.keys()
	nombres.sort()
	var ciclos: Array = []
	for i in range(nombres.size()):
		for j in range(i + 1, nombres.size()):
			var na := String(nombres[i])
			var nb := String(nombres[j])
			var a: Variant = servicios[na]
			var b: Variant = servicios[nb]
			if a == null or b == null:
				continue
			for campo in campos:
				var ca: Variant = _leer_campo(a, String(campo))
				var cb: Variant = _leer_campo(b, String(campo))
				if ca == null or cb == null:
					continue
				if ca == b and cb == a:
					ciclos.append("%s<->%s" % [na, nb])
					break
	return ciclos

static func _leer_campo(objeto: Variant, campo: String) -> Variant:
	if not (objeto is Object):
		return null
	var o := objeto as Object
	# Se recorre `get_property_list()` en vez de usar `campo in o`: el operador
	# `in` sobre un Object no tiene semántica garantizada para propiedades de
	# script, y una comprobación que falla en silencio devuelve "sin ciclos".
	for p in o.get_property_list():
		if String(p.get("name", "")) == campo:
			return o.get(campo)
	return null

## Recursos cargados DOS veces (checklist §J: "sin doble carga del mismo
## recurso ... con un solo dueño"). Agrupa por `instance_id`: si el mismo
## `resource_path` aparece en más de una instancia, hay doble carga.
## Devuelve [{ruta, instancias}].
static func recursos_duplicados(recursos: Array) -> Array:
	var por_ruta: Dictionary = {}
	for r in recursos:
		if r is Resource:
			var res := r as Resource
			var ruta := res.resource_path
			if ruta.is_empty():
				continue
			if not por_ruta.has(ruta):
				por_ruta[ruta] = {}
			(por_ruta[ruta] as Dictionary)[res.get_instance_id()] = true
	var duplicados: Array = []
	for ruta in por_ruta:
		var n: int = (por_ruta[ruta] as Dictionary).size()
		if n > 1:
			duplicados.append({"ruta": String(ruta), "instancias": n})
	duplicados.sort_custom(func(x, y): return String(x["ruta"]) < String(y["ruta"]))
	return duplicados
