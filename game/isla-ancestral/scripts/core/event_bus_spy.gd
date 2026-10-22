# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M40: Spy de eventos del EventBus para el Debug Menu (M110).
# Item [S] "Soporte de espia de eventos para el Debug Menu (M110)" del
# 05-Checklist de 40-Infraestructura (turno 2-BIS).
#
# Contrato: attach(bus) conecta TODAS las senales de TODOS los dominios
# (arity 0..5); cada emision queda en un anillo (MAX 256) y un contador.
# El Debug Menu (M110) consume capturadas()/cuenta()/limpiar(); detach()
# libera todo. Headless-safe (sin UI, sin allocs por frame en reposo).

class_name EventBusSpy
extends RefCounted

const MAX_CAPTURADAS := 256

var _bus: Node = null
var _conexiones: Array = []          # [{dominio, senal, callable, arity}]
var _anillo: Array = []              # [{dominio, evento, args, t_usec}]
var _cuentas: Dictionary = {}        # "dominio.evento" -> int
var _activa: bool = false

## Conecta todas las senales de todos los dominios del bus (arity <= 5).
## Idempotente: si ya estaba conectado, no duplica.
func attach(bus: Node) -> int:
	if _activa:
		return -1
	if bus == null:
		return 0
	_bus = bus
	_activa = true
	var conectadas: int = 0
	for dominio in bus.get_children():
		if not (dominio is Node):
			continue
		var nombre_dominio: String = String(dominio.name)
		for si in dominio.get_signal_list():
			var senal: String = String(si.name)
			var arity: int = si.args.size()
			if arity > 5:
				continue
			var dom_snapshot := nombre_dominio
			var sen_snapshot := senal
			var c: Callable
			match arity:
				0: c = func() -> void: _reg(dom_snapshot, sen_snapshot, [])
				1: c = func(a) -> void: _reg(dom_snapshot, sen_snapshot, [a])
				2: c = func(a, b) -> void: _reg(dom_snapshot, sen_snapshot, [a, b])
				3: c = func(a, b, d) -> void: _reg(dom_snapshot, sen_snapshot, [a, b, d])
				4: c = func(a, b, d, e) -> void: _reg(dom_snapshot, sen_snapshot, [a, b, d, e])
				5: c = func(a, b, d, e, f) -> void: _reg(dom_snapshot, sen_snapshot, [a, b, d, e, f])
			dominio.connect(senal, c)
			_conexiones.append({"dominio": nombre_dominio, "senal": senal, "callable": c, "nodo": dominio})
			conectadas += 1
	return conectadas

## Desconecta todo (deja el bus como estaba).
func detach() -> void:
	for c in _conexiones:
		var nodo: Node = c["nodo"]
		if is_instance_valid(nodo):
			if nodo.is_connected(String(c["senal"]), c["callable"]):
				nodo.disconnect(String(c["senal"]), c["callable"])
	_conexiones.clear()
	_activa = false
	_bus = null

## Ultimas capturas (copia del anillo, mas nuevas al final).
func capturadas() -> Array:
	return _anillo.duplicate(true)

## Cuantas veces se emitio "dominio.evento".
func cuenta(dominio: String, evento: String) -> int:
	return int(_cuentas.get(dominio + "." + evento, 0))

## Limpiar el anillo y los contadores (boton "reset" del Debug Menu).
func limpiar() -> void:
	_anillo.clear()
	_cuentas.clear()

## Esta activo?
func esta_activa() -> bool:
	return _activa

## Registro interno (curtea el anillo).
func _reg(dominio: String, evento: String, args: Array) -> void:
	var t: int = Time.get_ticks_usec()
	_anillo.append({"dominio": dominio, "evento": evento, "args": args, "t_usec": t})
	if _anillo.size() > MAX_CAPTURADAS:
		_anillo.pop_front()
	var clave := dominio + "." + evento
	_cuentas[clave] = int(_cuentas.get(clave, 0)) + 1
