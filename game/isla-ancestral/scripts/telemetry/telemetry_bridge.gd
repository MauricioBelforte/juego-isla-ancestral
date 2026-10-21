# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M105 iter. 9 - PUENTE EventBus -> track_* (cierra el item 27 del backlog:
# "resolver/degradar los 45 [?]").
#
# POR QUE EXISTE (medido, no supuesto):
#   Las 13 funciones `track_*` de `telemetry_director.gd` tenian **0 llamadores de
#   produccion**: el grep de `.track_X(` sobre `scripts/` da 0 en los 13 casos y
#   solo aparecen en `test_telemetria_*`. Es decir: la API estaba completa y el
#   checklist afirmaba "M105 ya emite los 11 eventos 'first'", pero en una partida
#   real NUNCA se emitia ninguno. La unica emision de produccion era
#   `session_started`/`session_ended`, que sale del propio director.
#
#   El item 228 del checklist decia que el hook de M22 "requiere senyal
#   prereq_met -> m105; ... requiere M22 iteracion adicional". Eso es una PREMISA
#   VENCIDA: `EventBus.quest.prereq_met` existe (`scripts/core/event_bus.gd`) y
#   `scripts/historia/story_manager.gd:187` YA lo emite en produccion. Lo que
#   faltaba era el consumidor de este lado. Este puente lo aporta SIN tocar un
#   solo archivo de M22 (dependencia M105 -> M22, no al reves).
#
# DISENO:
#   - Tabla declarativa `ENTRADAS`: cada fila solo se conecta si AMBOS extremos
#     existen de verdad (senal en el bus + metodo en el director). Una fila que no
#     resuelve NO se inventa: se reporta en `motivos()`.
#   - Fail-closed: director o bus nulos => 0 conexiones y motivo explicito.
#   - Idempotente: conectar() dos veces con la MISMA instancia no duplica.
#   - NO saltea la privacidad: el puente llama a `track_*`, que filtran por
#     `opt_in`. Con opt-out no se emite nada.
#   - Sin `class_name` a proposito: un `class_name` nuevo no existe para
#     `--script` hasta regenerar la cache de clases (trampa 123). Se instancia con
#     `load(...).new()`.
#
# Uso:
#   var puente = load("res://scripts/telemetry/telemetry_bridge.gd").new()
#   puente.conectar(director, bus)      # -> cantidad de senales conectadas
#   puente.cobertura()                  # -> Dictionary auditable
extends RefCounted

## Tabla declarativa. Cada entrada necesita coincidencia SEMANTICA exacta entre
## la senal y el tracker: no se mapea "algo parecido".
##
## Estado medido 2026-10-21 de los emisores de produccion (`.X.emit(` sobre
## `scripts/`, excluyendo `test_*`):
##   prereq_met           1 emisor  -> story_manager.gd:187      (M22)  [MAPEADA]
##   quest_completed      1 emisor  -> secondary_stories_service  (M23) [NO: es
##                                   una mision secundaria, no un capitulo; mapearla
##                                   a `track_chapter_completed` inventaria ids)
##   entrada_nueva        2 emisores-> diary_service / museum.donation_service
##                                   [NO: `track_museum_first_visited` espera un
##                                   museo_id, no una entrada de diario]
##   categoria_completa   1 emisor  -> diary_service               [NO: sin tracker]
##   item_added / island_loaded / travel_started / dialog_finished / purchase_done
##                        0 emisores en produccion -> cablearlas seria una arista
##                        MUERTA en runtime (no se mapean)
const ENTRADAS := [
	{
		"dominio": "quest",
		"senal": "prereq_met",
		"metodo": "track_seal_first_obtained",
		"args": 1,
		"nota": "M22 Historia.marcar_sello -> sello obtenido (items 227/228/229)",
	},
]

var _conectadas: Dictionary = {}   # "dominio.senal" -> {"dom": Object, "cb": Callable}
var _motivos: Array = []           # Array[String] de filas NO conectadas
var _despachos: int = 0
var _descartes: int = 0            # despachos que el director no acepto


## Conecta la tabla al par (director, bus). Devuelve cuantas senales quedo
## efectivamente conectadas EN ESTA llamada (0 si ya estaban o si no resolvieron).
func conectar(director: Object, bus: Object) -> int:
	_motivos.clear()
	if director == null:
		_motivos.append("director nulo: no se conecta nada")
		return 0
	if bus == null:
		_motivos.append("bus nulo: no se conecta nada")
		return 0
	var nuevas := 0
	for e in ENTRADAS:
		var fila: Dictionary = e
		if _conectar_entrada(director, bus, fila):
			nuevas += 1
	return nuevas


## Conecta una fila. Devuelve true solo si esta llamada creo la conexion.
func _conectar_entrada(director: Object, bus: Object, e: Dictionary) -> bool:
	var dominio := str(e.get("dominio", ""))
	var senal := str(e.get("senal", ""))
	var metodo := str(e.get("metodo", ""))
	var clave := "%s.%s" % [dominio, senal]

	if dominio.is_empty() or senal.is_empty() or metodo.is_empty():
		_motivos.append("fila incompleta: %s" % clave)
		return false
	if _conectadas.has(clave):
		_motivos.append("%s: ya conectada (idempotente)" % clave)
		return false

	var dom: Variant = bus.get(dominio)
	if dom == null:
		_motivos.append("%s: el bus no expone el dominio '%s'" % [clave, dominio])
		return false
	var dom_obj: Object = dom as Object
	if dom_obj == null:
		_motivos.append("%s: el dominio '%s' no es un Object" % [clave, dominio])
		return false
	if not dom_obj.has_signal(senal):
		_motivos.append("%s: el dominio no declara la senal '%s'" % [clave, senal])
		return false
	if not director.has_method(metodo):
		_motivos.append("%s: el director no tiene el metodo '%s'" % [clave, metodo])
		return false

	var cb := Callable(self, "_despachar").bind(director, metodo)
	if dom_obj.is_connected(senal, cb):
		_motivos.append("%s: ya estaba conectada al mismo callable" % clave)
		return false
	dom_obj.connect(senal, cb)
	_conectadas[clave] = {"dom": dom_obj, "cb": cb, "senal": senal}
	return true


## Desconecta todo lo que esta instancia haya conectado (simetria de conectar()).
## Devuelve cuantas conexiones se quitaron.
func desconectar() -> int:
	var quitadas := 0
	for clave in _conectadas.keys():
		var reg: Dictionary = _conectadas[clave]
		var dom_obj: Object = reg.get("dom") as Object
		var cb: Callable = reg.get("cb")
		var senal_reg := str(reg.get("senal", ""))
		if dom_obj == null or not is_instance_valid(dom_obj):
			continue
		if dom_obj.is_connected(senal_reg, cb):
			dom_obj.disconnect(senal_reg, cb)
			quitadas += 1
	_conectadas.clear()
	return quitadas


## Unico punto de despacho. `bind` agrega los argumentos DESPUES de los de la
## senal, asi que llega (arg0_de_la_senal, director, metodo).
func _despachar(arg0, director: Object, metodo: String) -> void:
	if director == null or not is_instance_valid(director):
		_descartes += 1
		return
	if not director.has_method(metodo):
		_descartes += 1
		return
	_despachos += 1
	director.call(metodo, str(arg0))


## Auditoria: que filas resolvieron contra el par (bus, director) AHORA.
## No conecta nada. Sirve para que la suite pruebe la tabla sin efectos.
func verificar(director: Object, bus: Object) -> Dictionary:
	var detalle: Array = []
	var ok := 0
	for e in ENTRADAS:
		var entrada: Dictionary = e
		var dominio := str(entrada.get("dominio", ""))
		var senal := str(entrada.get("senal", ""))
		var metodo := str(entrada.get("metodo", ""))
		var fila := {
			"clave": "%s.%s" % [dominio, senal],
			"metodo": metodo,
			"senal_existe": false,
			"metodo_existe": false,
			"ok": false,
		}
		if bus != null:
			var dom: Variant = bus.get(dominio)
			var dom_obj: Object = dom as Object
			if dom_obj != null and dom_obj.has_signal(senal):
				fila["senal_existe"] = true
		if director != null and director.has_method(metodo):
			fila["metodo_existe"] = true
		fila["ok"] = bool(fila["senal_existe"]) and bool(fila["metodo_existe"])
		if fila["ok"]:
			ok += 1
		detalle.append(fila)
	return {
		"declaradas": ENTRADAS.size(),
		"verificadas": ok,
		"detalle": detalle,
	}


## Estado auditable del puente.
func cobertura() -> Dictionary:
	return {
		"declaradas": ENTRADAS.size(),
		"conectadas": _conectadas.size(),
		"claves": _conectadas.keys(),
		"despachos": _despachos,
		"descartes": _descartes,
		"motivos": _motivos.duplicate(),
	}
