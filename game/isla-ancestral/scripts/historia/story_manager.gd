# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M22: Historia Principal — HistoriaService (autoload "Historia")
# Núcleo data-driven V0/V1 sobre el diseño de 03-Diseno.md:
#  - Grafo de escenas {id, capitulo, tipo, requisitos[], siguiente[]} en
#    data/historia/historia_principal.json (compatible conceptual M21).
#  - Gating real: C4 y finales exigen 7 sellos + flag de templo abierto;
#    el final secreto exige su flag de pistas (M25/M147 los alimentan).
#  - Requisitos verificables (M66): capitulo completado / sellos / flag M21 /
#    objeto M14. Sin dependencia de contenido narrativo (textos mínimos).
#  - Persistencia ISaveProvider (M59): sección "historia".
#  - Emite EventBus.quest.prereq_met(seal_id) por cada sello (contrato M07).
# ⚠️ Sin class_name: es autoload (pitfall documentado 07-GUIA-GODOT §9.17/§9.41).
extends Node

## Cargas del JSON del grafo
var _datos: Dictionary = {}
var _nodos: Dictionary = {}
var _orden_nodos: Array[String] = []

## Estado de progreso (persistido)
var _completados: Array[String] = []
var _sellos: Array[String] = []
var _final_elegido: String = ""


func _ready() -> void:
	_cargar_grafo()
	_validar_grafo_en_ready()
	_registrar_proveedor_guardado()

## M22 (QA cruzado Hy3/WorkBuddy, iter 1): gate de validacion del grafo al cargar.
## Detecta temprano (push_error) estructuras rotas que el validador externo tambien
## chequea, para no silenciar errores de edicion del JSON en runtime.
## No es fallo duro: el juego arranca, pero deja constancia en consola.
func _validar_grafo_en_ready() -> void:
	if _nodos.is_empty():
		return
	# 1) Sin huérfanos: todo "siguiente" apunta a un nodo existente.
	for id in _orden_nodos:
		var nodo: Dictionary = _nodos[id]
		for sig in nodo.get("siguiente", []):
			if not _nodos.has(String(sig)):
				push_error("[Historia][VAL-HST] nodo '%s' apunta a siguiente inexistente '%s'" % [id, String(sig)])
	# 2) Sin ciclos de capítulo (retroceso no permitido por diseño DAG).
	for id in _orden_nodos:
		var nodo: Dictionary = _nodos[id]
		var cap := int(nodo.get("capitulo", 0))
		for sig in nodo.get("siguiente", []):
			var sig_nodo: Dictionary = _nodos.get(String(sig), {})
			if int(sig_nodo.get("capitulo", 0)) < cap:
				push_error("[Historia][VAL-HST] retroceso de capítulo: %s(%d) → %s(%d)"
					% [id, cap, String(sig), int(sig_nodo.get("capitulo", 0))])
	# 3) Prólogo presente y finales alcanzables por aristas (sin gating).
	if not _nodos.has("prologo"):
		push_error("[Historia][VAL-HST] falta el nodo 'prologo'")
	var alcanzables := {"prologo": true}
	var cola := ["prologo"]
	while not cola.is_empty():
		var actual: String = cola.pop_front()
		var n_actual: Dictionary = _nodos.get(actual, {})
		for sig in n_actual.get("siguiente", []):
			var s := String(sig)
			if not alcanzables.has(s):
				alcanzables[s] = true
				cola.append(s)
	var finales := 0
	for id in _orden_nodos:
		if String(_nodos[id].get("tipo", "")) == "final":
			finales += 1
			if not alcanzables.has(id):
				push_error("[Historia][VAL-HST] final in-alcanzable por aristas: '%s'" % id)
	var declarados: int = int(_datos.get("finales", []).size())
	if finales != declarados:
		push_error("[Historia][VAL-HST] finales en grafo (%d) != declarados (%d)" % [finales, declarados])


func _cargar_grafo() -> void:
	var texto := FileAccess.get_file_as_string("res://data/historia/historia_principal.json")
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[Historia] historia_principal.json inválido; grafo vacío")
		return
	_datos = parseado
	_nodos.clear()
	_orden_nodos.clear()
	for nodo in _datos.get("nodos", []):
		var id := String(nodo.get("id", ""))
		if id.is_empty():
			continue
		_nodos[id] = nodo
		_orden_nodos.append(id)


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── API pública (03-Diseno §3/§4) ────────────────────────

func get_nodo(id: String) -> Dictionary:
	return _nodos.get(id, {})


func nodos_count() -> int:
	return _nodos.size()


func esta_completado(id: String) -> bool:
	return id in _completados


func sellos_count() -> int:
	return _sellos.size()


func sellos_totales() -> int:
	return int(_datos.get("sellos_totales", 7))


func final_elegido() -> String:
	return _final_elegido


## Capítulo actual = capítulo menor de los nodos aún no completados.
func capitulo_actual() -> int:
	var actual := 99
	for id in _orden_nodos:
		var nodo: Dictionary = _nodos[id]
		var cap := int(nodo.get("capitulo", 99))
		if not (id in _completados) and cap < actual:
			actual = cap
	return actual if actual != 99 else 7


## Evalúa los requisitos de un nodo: {ok: bool, motivos: Array[String]}.
func puede_entrar(id: String) -> Dictionary:
	var motivos: Array[String] = []
	var nodo: Dictionary = get_nodo(id)
	if nodo.is_empty():
		motivos.append("nodo inexistente: %s" % id)
		return {"ok": false, "motivos": motivos}
	for req in nodo.get("requisitos", []):
		var tipo := String(req.get("tipo", ""))
		match tipo:
			"capitulo":
				if not (String(req.get("id", "")) in _completados):
					motivos.append("capítulo previo incompleto: %s" % String(req.get("id", "")))
			"sellos":
				if _sellos.size() < int(req.get("cantidad", 0)):
					motivos.append("sellos insuficientes: %d/%d" % [_sellos.size(), int(req.get("cantidad", 0))])
			"flag":
				var ws := get_node_or_null("/root/WorldState")
				if ws == null or not ws.has_flag(String(req.get("id", ""))):
					motivos.append("bandera faltante: %s" % String(req.get("id", "")))
			"objeto":
				var inv := get_node_or_null("/root/Inventario")
				var cantidad := int(req.get("cantidad", 1))
				if inv == null or inv.count_item(String(req.get("id", ""))) < cantidad:
					motivos.append("objeto faltante: %s x%d" % [String(req.get("id", "")), cantidad])
			_:
				motivos.append("requisito desconocido: %s" % tipo)
	return {"ok": motivos.is_empty(), "motivos": motivos}


## Marca un sello obtenido (id del catálogo de sellos del grafo).
## Emite EventBus.quest.prereq_met (M07) para M21/M71/M38.
func marcar_sello(sello_id: String) -> bool:
	var catalogo: Array = _datos.get("sellos", [])
	var existe := false
	for s in catalogo:
		if String(s.get("id", "")) == sello_id:
			existe = true
			break
	if not existe:
		push_warning("[Historia] sello desconocido: %s" % sello_id)
		return false
	if sello_id in _sellos:
		return true
	_sellos.append(sello_id)
	EventBus.quest.prereq_met.emit(sello_id)
	return true


## Intenta completar un nodo (valida requisitos otra vez, contracto M66).
func completar_nodo(id: String) -> Dictionary:
	var res := puede_entrar(id)
	if not bool(res.ok):
		return res
	if id in _completados:
		return {"ok": true, "motivos": []}
	_completados.append(id)
	var nodo: Dictionary = get_nodo(id)
	if String(nodo.get("tipo", "")) == "final":
		_final_elegido = String(nodo.get("final_id", ""))
	EventBus.quest.quest_started.emit(id)
	return {"ok": true, "motivos": []}


## Siguientes nodos de un nodo completado, filtrados por puede_entrar.
func siguientes_disponibles(id: String) -> Array[String]:
	var disponibles: Array[String] = []
	for sig in get_nodo(id).get("siguiente", []):
		if bool(puede_entrar(String(sig)).ok):
			disponibles.append(String(sig))
	return disponibles


## Finales aún no elegidos que están alcanzables (QA: "cada final alcanzable").
func finales_alcanzables() -> Array[String]:
	var result: Array[String] = []
	for id in _orden_nodos:
		var nodo: Dictionary = _nodos[id]
		if String(nodo.get("tipo", "")) == "final":
			var f := String(nodo.get("final_id", ""))
			if f != _final_elegido and bool(puede_entrar(id).ok):
				result.append(f)
	return result


## ── Persistencia (ISaveProvider M59) ─────────────────────

func get_section_name() -> String:
	return "historia"


func get_save_data() -> Dictionary:
	return {
		"completados": _completados.duplicate(),
		"sellos": _sellos.duplicate(),
		"final_elegido": _final_elegido,
	}


func restore_save_data(data: Dictionary) -> void:
	_completados.clear()
	for e in data.get("completados", []):
		_completados.append(String(e))
	_sellos.clear()
	for s in data.get("sellos", []):
		_sellos.append(String(s))
	_final_elegido = String(data.get("final_elegido", ""))
