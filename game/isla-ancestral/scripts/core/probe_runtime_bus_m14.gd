# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M14 (Event Bus) - SONDA DE CAPTURA RUNTIME.
# El red-probe estatico (scripts/red_probe_event_bus.py) cuenta emisiones por
# grep de `.<senal>.emit(` y por eso NO ve las 70 emisiones dinamicas
# `emit_signal("...")`. Esta sonda cuenta en VIVO: conecta las 54 senales del
# bus y arranca la escena principal, midiendo cuantas se emiten de verdad.
#
# Uso:
#   <binario> --headless --path game/isla-ancestral \
#       --script res://scripts/core/probe_runtime_bus_m14.gd
#
# Es una SONDA de inventario (no un test de aprobacion): siempre sale 0 si
# logro medir, y 2 si no pudo medir (sin bus / sin escena). Nunca sale 1: no
# hay asercion de contrato aca.

extends SceneTree

const MAX_FRAMES: int = 60
const ESCENA := "res://scenes/main_island.tscn"

var _cuenta: Dictionary = {}
var _frames: int = 0


func _init() -> void:
	call_deferred("_go")


func _marcar(nombre: String) -> void:
	_cuenta[nombre] = int(_cuenta.get(nombre, 0)) + 1


func _conectar_objeto(objeto: Object, prefijo: String) -> int:
	## Conecta TODAS las senales del objeto (incluye clases anidadas del bus).
	## El callable con 4 parametros por defecto acepta cualquier aridad 0..4.
	var n := 0
	for s in objeto.get_signal_list():
		var nombre: String = "%s.%s" % [prefijo, String(s["name"])]
		if _cuenta.has(nombre):
			continue
		_cuenta[nombre] = 0
		objeto.connect(StringName(s["name"]),
			func(_a = null, _b = null, _c = null, _d = null): _marcar(nombre))
		n += 1
	return n


func _declaradas() -> Array[String]:
	## Nombres de las senales declaradas en event_bus.gd (las 54 del oraculo).
	## El bus tambien expone objetos de OTROS servicios: esos no son "del bus".
	var out: Array[String] = []
	var txt := FileAccess.get_file_as_string("res://scripts/core/event_bus.gd")
	var re := RegEx.new()
	re.compile("(?m)^\\s*signal\\s+([A-Za-z_][A-Za-z0-9_]*)")
	for m in re.search_all(txt):
		out.append(m.get_string(1))
	return out


func _go() -> void:
	var bus := root.get_node_or_null("EventBus")
	if bus == null:
		print("[PROBE] NO_MEDIBLE: no hay /root/EventBus (autoload no cargado)")
		quit(2)
		return
	var conectadas := 0
	conectadas += _conectar_objeto(bus, "bus")
	## Las senales viven en clases anidadas: bus.inventory, bus.quest, ...
	for p in bus.get_property_list():
		var v: Variant = bus.get(String(p["name"]))
		if v is Object and v != null:
			var o: Object = v
			if o.get_signal_list().size() > 0:
				conectadas += _conectar_objeto(o, String(p["name"]))
	print("[PROBE] senales conectadas: %d" % conectadas)

	var ps := load(ESCENA)
	if ps == null:
		print("[PROBE] NO_MEDIBLE: no se pudo cargar %s" % ESCENA)
		quit(2)
		return
	var escena: Node = ps.instantiate()
	root.add_child(escena)
	print("[PROBE] escena arrancada: %s" % ESCENA)

	while _frames < MAX_FRAMES:
		await process_frame
		_frames += 1

	var emitidas: int = 0
	var total: int = 0
	for k in _cuenta:
		total += 1
		if int(_cuenta[k]) > 0:
			emitidas += 1
	print("=== PROBE RUNTIME M14: %d frames, %d senales conectadas, "
		% [_frames, total] + "%d con >=1 emision, %d con 0 ==="
		% [emitidas, total - emitidas])
	## Recorte al oraculo: solo las declaradas en event_bus.gd.
	var decl := _declaradas()
	var d_emit := 0
	var d_cero: Array[String] = []
	for nombre in decl:
		var hubo := false
		for k in _cuenta:
			if String(k).ends_with("." + nombre) and int(_cuenta[k]) > 0:
				hubo = true
				break
		if hubo:
			d_emit += 1
		else:
			d_cero.append(nombre)
	print("[PROBE] declaradas en event_bus.gd: %d | con emision en runtime: %d | "
		% [decl.size(), d_emit] + "en 0: %d" % d_cero.size())
	print("[PROBE] en 0 (runtime): %s" % ", ".join(d_cero))
	for k in _cuenta:
		if int(_cuenta[k]) > 0:
			print("   EMITIDA %-40s %d" % [k, int(_cuenta[k])])
	quit(0)
