# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-18
#
# M52 iter. 6 (Log 1002): VfxTrigger — punto ÚNICO de traducción
# "evento de juego -> VFX" (RF6 / T-163: riesgo de desincronía).
#
# POR QUÉ EXISTE (bug real encontrado en la iter. 5):
#   `vfx_director.gd` se conectaba a `EventBus.evento_generico` — una señal que
#   NO EXISTE en ningún lado del repo. `has_signal()` devolvía false y el
#   director quedaba mudo: **ningún VFX se disparaba por un evento real**.
#   El `EventBus` del proyecto NO es plano: son sub-objetos con namespace
#   (`world.block_placed`, `calendar.season_changed`, `weather.clima_cambio`,
#   `quest.prereq_met`, `travel.travel_started`, `diary.entrada_nueva`,
#   `ui.notify`, `progresion.nivel_herramienta_cambio`,
#   `npc.friendship_level_up`, `inventory.item_added`).
#
# Este archivo hace explícito ese contrato: el mapa bus -> ids se DERIVA del
# catálogo, así que agregar un efecto con `bus` lo conecta sin tocar código, y
# `conectar()` REPORTA qué buses no pudo resolver en vez de fallar en silencio.
class_name VfxTrigger
extends RefCounted

# bus (namespaced) -> Array de ids de vfx
var _mapa := {}
# id -> dueño del evento (entradas sin `bus`: RF6 pendiente de otro módulo)
var _pendientes := {}


## Deriva el mapa desde el catálogo. Devuelve cuántos buses quedaron con al
## menos un VFX. Es determinista y no toca el árbol de nodos.
func construir(catalogo: Array) -> int:
	_mapa.clear()
	_pendientes.clear()
	for e in catalogo:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var id := str(e.get("id", ""))
		var bus := str(e.get("bus", ""))
		if bus.is_empty():
			var dueno := str(e.get("dueno_evento", ""))
			if not dueno.is_empty():
				_pendientes[id] = dueno
			continue
		if not _mapa.has(bus):
			_mapa[bus] = []
		_mapa[bus].append(id)
	return _mapa.size()


## Buses que el catálogo declara (ordenados).
func buses() -> Array:
	var b: Array = _mapa.keys()
	b.sort()
	return b


## Ids asociados a un bus (vacío si el bus no está en el catálogo).
func ids_de(bus: String) -> Array:
	return (_mapa.get(bus, []) as Array).duplicate()


## Entradas SIN bus: dependen de un dueño externo (RF6). Se reporta, no se
## inventa un evento.
func eventos_pendientes() -> Dictionary:
	return _pendientes.duplicate()


## Conecta cada bus del catálogo a la señal real del EventBus.
##
## `raiz` es el nodo del bus (en producción `/root/EventBus`); el test le pasa un
## STUB, para no depender del autoload (regla del proyecto). `al_disparar`
## recibe (bus, contexto).
##
## Devuelve {conectados, faltantes} — `faltantes` son buses que el catálogo
## declara pero el bus real NO expone: eso es un hallazgo, no un detalle.
func conectar(raiz: Node, al_disparar: Callable) -> Dictionary:
	var conectados := 0
	var faltantes: Array = []
	for bus_v in _mapa:
		var bus := String(bus_v)
		var partes: PackedStringArray = bus.split(".")
		var obj: Object = raiz
		for i in range(partes.size() - 1):
			if obj == null:
				break
			obj = obj.get(partes[i])
		var senal: String = partes[partes.size() - 1]
		if obj == null or not obj.has_signal(senal):
			faltantes.append(bus)
			continue
		# Lambda con 4 parámetros por defecto: las señales del EventBus real
		# llevan hasta 2 argumentos, y una Callable NO puede recibir MÁS de los
		# que declara. Con defaults amplios, cualquier aridad conecta sin error.
		var cb := func(_a = null, _b = null, _c = null, _d = null) -> void:
			al_disparar.call(bus, {})
		obj.connect(senal, cb)
		conectados += 1
	return {"conectados": conectados, "faltantes": faltantes}


## Qué VFX corresponden a un bus dado un contexto. PURO: no emite nada, sólo
## decide. Las entradas con `condicion` sólo pasan si el contexto la cumple.
func disparar(bus: String, contexto: Dictionary, catalogo: Array) -> Array:
	var salida: Array = []
	for id in ids_de(bus):
		var e := _entrada(catalogo, id)
		if e.is_empty():
			continue
		if cumple_condicion(str(e.get("condicion", "")), contexto):
			salida.append(id)
	return salida


## `condicion` = "" (siempre) o "clave:valor" (el contexto debe traer ese valor).
static func cumple_condicion(condicion: String, contexto: Dictionary) -> bool:
	if condicion.is_empty():
		return true
	var partes := condicion.split(":")
	if partes.size() != 2:
		return false
	return str(contexto.get(partes[0], "")) == partes[1]


## Cobertura para el checklist/telemetría: cuántos eventos del juego están
## cubiertos y cuántos esperan a otro módulo.
func cobertura() -> Dictionary:
	var con_vfx := 0
	for bus in _mapa:
		if not (_mapa[bus] as Array).is_empty():
			con_vfx += 1
	return {
		"buses_declarados": _mapa.size(),
		"buses_con_vfx": con_vfx,
		"pendientes_rf6": _pendientes.size(),
		"faltantes": _pendientes.duplicate(),
	}


static func _entrada(catalogo: Array, id: String) -> Dictionary:
	for e in catalogo:
		if typeof(e) == TYPE_DICTIONARY and str(e.get("id", "")) == id:
			return e
	return {}
