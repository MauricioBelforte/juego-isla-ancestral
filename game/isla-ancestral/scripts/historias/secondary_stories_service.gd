# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M23: Historias Secundarias — SecondaryStoriesService (autoload "Historias")
# Núcleo V0/V1 sobre el esquema del 03-Diseno (§esquema):
#  - Cadenas data-driven en data/historias/secundarias.json:
#    {id, titulo, contexto, pasos[{id, tipo, npc|lugar|objeto|ref, condicion?}],
#     recompensa{diario?, cosmetico?}, consecuencia{flag: valor}, oculta, postgame}
#  - Motor: iniciar_cadena (valida contexto/requisitos), avanzar_paso (tipos
#    hablar/explorar/puzzle/entregar — la ejecución concreta la hace el sistema
#    dueño vía reportar_paso), completar_cadena (recompensa + consecuencia via
#    WorldState M21 + señales quest_* M07 que M55/M71 ya consumen).
#  - Ocultas: no aparecen en listado hasta el primer paso (§misiones ocultas).
#  - Postgame: requiere final_elegido != "" (M22).
#  - Validador anti-repetición (§regla dura): contexto no vacío, pasos >= 3,
#    ids únicos, recompensa/consecuencia presentes, tipos conocidos.
#  - Persistencia ISaveProvider M59: sección "secondary_stories".
# Iter. 3 (Step-5-WorkBuddy, 2026-10-21, Log 2083; GO del director, msg 151):
# catálogo secundario data/historias/cadenas_ejemplo.json cableado por
# RUTA_CATALOGO_EJEMPLOS con merge por id sobre el principal: el principal gana
# los conflictos (no se sobrescribe), las cadenas nuevas que no pasan el
# validador se rechazan con sus errores, y el resultado queda consultable en
# merge_ejemplos_reporte() {anadidas, conflictos, rechazadas}.
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).
extends Node

const RUTA_CATALOGO: String = "res://data/historias/secundarias.json"
const RUTA_CATALOGO_EJEMPLOS: String = "res://data/historias/cadenas_ejemplo.json"
const FUENTE_PRINCIPAL := "secundarias"
const FUENTE_EJEMPLOS := "ejemplos"
const TIPOS_PASO: Array[String] = ["hablar", "explorar", "puzzle", "entregar"]

## cadena_id -> {titulo, contexto, pasos[], recompensa, consecuencia, oculta, postgame}
var _cadenas: Dictionary = {}
## estado: cadena_id -> {paso_actual: int, activa: bool, completada: bool}
var _estado: Dictionary = {}
## cadena_id -> "secundarias" | "ejemplos" (de qué archivo vino cada cadena)
var _fuente: Dictionary = {}
## Reporte del merge de ejemplos: {anadidas: [], conflictos: [], rechazadas: [{id, errores}]}
var _merge_ejemplos: Dictionary = {"anadidas": [], "conflictos": [], "rechazadas": []}


func _ready() -> void:
	_cargar_cadenas()
	_registrar_proveedor_guardado()


func _cargar_cadenas() -> void:
	_cadenas.clear()
	_fuente.clear()
	_merge_ejemplos = {"anadidas": [], "conflictos": [], "rechazadas": []}
	for cadena in _leer_catalogo(RUTA_CATALOGO):
		var id := String(cadena.get("id", ""))
		if id.is_empty():
			continue
		_cadenas[id] = cadena
		_fuente[id] = FUENTE_PRINCIPAL
	_mergear_ejemplos()
	var rep: Dictionary = _merge_ejemplos
	print("[M23] Cadenas cargadas: %d (ejemplos: añadidas %d, conflictos %d, rechazadas %d)" % [
		_cadenas.size(), (rep.anadidas as Array).size(),
		(rep.conflictos as Array).size(), (rep.rechazadas as Array).size()])


## Lee un catálogo JSON y devuelve su lista de cadenas (vacía si el archivo
## falta o no parsea: el merge degrada, no aborta la carga del principal).
func _leer_catalogo(ruta: String) -> Array:
	if not FileAccess.file_exists(ruta):
		push_warning("[M23] catálogo ausente: %s" % ruta)
		return []
	var texto := FileAccess.get_file_as_string(ruta)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M23] catálogo inválido: %s" % ruta)
		return []
	var lista: Variant = parseado.get("cadenas", [])
	if typeof(lista) != TYPE_ARRAY:
		push_error("[M23] catálogo sin lista 'cadenas': %s" % ruta)
		return []
	return lista


## Merge del catálogo de ejemplos sobre el principal (§GO director, msg 151):
##  - id ya presente -> conflicto: gana el principal (no se sobrescribe);
##  - cadena nueva que no pasa el validador -> rechazada con sus errores;
##  - cadena nueva válida -> añadida con fuente "ejemplos".
func _mergear_ejemplos() -> void:
	var titulos := {}
	for cid in _cadenas:
		titulos[String(_cadenas[cid].get("titulo", ""))] = true
	for cadena in _leer_catalogo(RUTA_CATALOGO_EJEMPLOS):
		var id := String(cadena.get("id", ""))
		if id.is_empty():
			continue
		if _cadenas.has(id):
			(_merge_ejemplos.conflictos as Array).append(id)
			continue
		var errores := _errores_de_cadena(id, cadena, titulos)
		if not errores.is_empty():
			(_merge_ejemplos.rechazadas as Array).append({"id": id, "errores": errores})
			continue
		_cadenas[id] = cadena
		_fuente[id] = FUENTE_EJEMPLOS
		(_merge_ejemplos.anadidas as Array).append(id)


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── Consultas ────────────────────────────────────────────

func cadenas_count() -> int:
	return _cadenas.size()


## De qué archivo vino la cadena: "secundarias", "ejemplos" o "" si no existe.
func fuente_cadena(cadena_id: String) -> String:
	return String(_fuente.get(cadena_id, ""))


## Copia del reporte del merge de ejemplos: {anadidas, conflictos, rechazadas}.
func merge_ejemplos_reporte() -> Dictionary:
	return _merge_ejemplos.duplicate(true)


## Cadenas visibles: ocultas solo si ya iniciadas; postgame solo con final M22
func cadenas_disponibles() -> Array[String]:
	var result: Array[String] = []
	var h := get_node_or_null("/root/Historia")
	var hay_final := h != null and String(h.final_elegido()) != ""
	for cid in _cadenas:
		var c: Dictionary = _cadenas[cid]
		var iniciada := _estado.has(cid)
		if bool(c.get("oculta", false)) and not iniciada:
			continue
		if bool(c.get("postgame", false)) and not hay_final:
			continue
		if _estado.has(cid) and bool(_estado[cid].get("completada", false)):
			continue
		result.append(String(cid))
	return result


func get_cadena(cadena_id: String) -> Dictionary:
	return _cadenas.get(cadena_id, {})


func esta_completada(cadena_id: String) -> bool:
	return _estado.has(cadena_id) and bool(_estado[cadena_id].get("completada", false))


func esta_activa(cadena_id: String) -> bool:
	return _estado.has(cadena_id) and bool(_estado[cadena_id].get("activa", false))


## ── Motor de cadenas ─────────────────────────────────────

## Inicia una cadena (§esquema). Las ocultas se pueden iniciar aunque no
## figuren en el listado (se descubren por el mundo).
func iniciar_cadena(cadena_id: String) -> Dictionary:
	if _cadenas.get(cadena_id, {}).is_empty():
		return {"ok": false, "motivo": "cadena inexistente"}
	if _estado.has(cadena_id):
		return {"ok": false, "motivo": "ya iniciada o completada"}
	var c: Dictionary = _cadenas[cadena_id]
	if bool(c.get("postgame", false)):
		var h := get_node_or_null("/root/Historia")
		if h == null or String(h.final_elegido()) == "":
			return {"ok": false, "motivo": "requiere postgame (final de M22)"}
	_estado[cadena_id] = {"paso_actual": 0, "activa": true, "completada": false}
	var bus := get_node_or_null("/root/EventBus")
	if bus != null:
		bus.quest.quest_started.emit(cadena_id)
	print("[M23] Cadena iniciada: %s — %s" % [cadena_id, String(c.get("titulo", ""))])
	return {"ok": true, "motivo": ""}


## El sistema dueño del paso (M19 diálogo, M25 puzzle, M14 inventario) reporta
## que el paso actual fue cumplido. El motor valida el tipo y avanza.
func reportar_paso(cadena_id: String, tipo: String, evidencia: String) -> Dictionary:
	if not esta_activa(cadena_id):
		return {"ok": false, "motivo": "cadena no activa"}
	var c: Dictionary = _cadenas[cadena_id]
	var pasos: Array = c.get("pasos", [])
	var idx := int(_estado[cadena_id].get("paso_actual", 0))
	if idx >= pasos.size():
		return {"ok": false, "motivo": "sin pasos pendientes"}
	var paso: Dictionary = pasos[idx]
	if String(paso.get("tipo", "")) != tipo:
		return {"ok": false, "motivo": "tipo incorrecto: esperado %s" % String(paso.get("tipo", ""))}
	# Referencia esperada del paso (npc/lugar/objeto/ref) — evidencia debe coincidir
	var esperado := String(paso.get("npc", paso.get("lugar", paso.get("objeto", paso.get("ref", "")))))
	if esperado != "" and _slug(evidencia) != _slug(esperado):
		return {"ok": false, "motivo": "evidencia incorrecta: esperado %s" % esperado}
	# Avanzar
	_estado[cadena_id]["paso_actual"] = idx + 1
	if idx + 1 >= pasos.size():
		return _completar_cadena(cadena_id)
	return {"ok": true, "motivo": "", "paso": idx + 1}


## §4.1.5-6: entregar un objeto consume del inventario (tipo "entregar")
func reportar_entrega(cadena_id: String) -> Dictionary:
	if not esta_activa(cadena_id):
		return {"ok": false, "motivo": "cadena no activa"}
	var c: Dictionary = _cadenas[cadena_id]
	var idx := int(_estado[cadena_id].get("paso_actual", 0))
	var pasos: Array = c.get("pasos", [])
	if idx >= pasos.size():
		return {"ok": false, "motivo": "sin pasos pendientes"}
	var paso: Dictionary = pasos[idx]
	if String(paso.get("tipo", "")) != "entregar":
		return {"ok": false, "motivo": "paso actual no es entrega"}
	var objeto := String(paso.get("objeto", ""))
	var inv := get_node_or_null("/root/Inventario")
	if inv == null or int(inv.count_item(objeto)) < 1:
		return {"ok": false, "motivo": "objeto no disponible: %s" % objeto}
	if not inv.remover_items({objeto: 1}):
		return {"ok": false, "motivo": "no se pudo retirar el objeto"}
	return reportar_paso(cadena_id, "entregar", objeto)


func _completar_cadena(cadena_id: String) -> Dictionary:
	var c: Dictionary = _cadenas[cadena_id]
	_estado[cadena_id]["activa"] = false
	_estado[cadena_id]["completada"] = true
	# Consecuencia → estado del mundo (M21)
	var consec: Dictionary = c.get("consecuencia", {})
	var ws := get_node_or_null("/root/WorldState")
	if ws != null:
		for flag in consec:
			ws.set_flag(String(flag), bool(consec[flag]))
	# Recompensa de diario → M55 (categoría "misiones"; entrada = el capítulo
	# DECLARADO en recompensa.diario, no un id derivado — iter. 21, Log 2187).
	# Antes se derivaba "mision_"+cadena_id y el valor declarado quedaba como
	# data muerta (0 usos en todo el codebase; el validador solo miraba la
	# clave). El catálogo de M55 valida la entrada: si no existe, registrar()
	# devuelve false EN SILENCIO (medido: 2 de 79 capítulos existen en disco;
	# el resto es contenido de M55 — hallazgo reportado a la directora).
	var rec: Dictionary = c.get("recompensa", {})
	var capitulo := String(rec.get("diario", ""))
	if capitulo != "":
		var diary := get_node_or_null("/root/Diary")
		if diary != null:
			diary.registrar(capitulo, "misiones")
	# Cosmético → señal de desbloqueo (M71 escucha)
	var bus := get_node_or_null("/root/EventBus")
	if String(rec.get("cosmetico", "")) != "" and bus != null:
		bus.quest.quest_updated.emit(cadena_id, "cosmetico", 1)
	if bus != null:
		bus.quest.quest_completed.emit(cadena_id)
	print("[M23] Cadena completada: %s" % cadena_id)
	return {"ok": true, "motivo": "", "completada": true}


## ── Validador anti-repetición (§regla dura, para CI/editor) ──

## Devuelve lista de errores de las cadenas del catálogo (vacío = válido).
func validar_cadenas() -> Array[String]:
	var errores: Array[String] = []
	var titulos_vistos := {}
	for cid in _cadenas:
		errores.append_array(_errores_de_cadena(String(cid), _cadenas[cid], titulos_vistos))
	return errores


## Errores de UNA cadena contra el esquema. titulos_vistos se actualiza con el
## título (anti-repetición); pasar un diccionario fresco limita la regla al
## alcance de quien llama (p. ej. el merge de ejemplos sobre los títulos ya vistos).
func _errores_de_cadena(cid: String, c: Dictionary, titulos_vistos: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var contexto := String(c.get("contexto", ""))
	# Regla dura: contexto narrativo no vacío (anti "recoge N" genéricos)
	if contexto.strip_edges().length() < 10:
		errores.append("%s: contexto ausente o muy corto" % cid)
	var pasos: Array = c.get("pasos", [])
	# Esquema: pasos >= 3
	if pasos.size() < 3:
		errores.append("%s: menos de 3 pasos" % cid)
	# Tipos conocidos + ids de paso únicos dentro de la cadena
	var ids_paso := {}
	for p in pasos:
		var tipo := String(p.get("tipo", ""))
		if not (tipo in TIPOS_PASO):
			errores.append("%s/%s: tipo desconocido '%s'" % [cid, String(p.get("id", "")), tipo])
		var pid := String(p.get("id", ""))
		if ids_paso.has(pid):
			errores.append("%s: id de paso duplicado '%s'" % [cid, pid])
		ids_paso[pid] = true
	# Recompensa y consecuencia presentes (única por cadena)
	if c.get("recompensa", {}).is_empty():
		errores.append("%s: sin recompensa" % cid)
	if c.get("consecuencia", {}).is_empty():
		errores.append("%s: sin consecuencia" % cid)
	# Anti-repetición: título único
	var titulo := String(c.get("titulo", ""))
	if titulos_vistos.has(titulo):
		errores.append("%s: título duplicado '%s'" % [cid, titulo])
	titulos_vistos[titulo] = true
	return errores


func _slug(s: String) -> String:
	var r := s.to_lower()
	r = r.replace("á", "a").replace("é", "e").replace("í", "i")
	r = r.replace("ó", "o").replace("ú", "u").replace("ñ", "n")
	return r


## ── Persistencia (M59) ──────────────────────────────────

func get_section_name() -> String:
	return "secondary_stories"


func get_save_data() -> Dictionary:
	var activas := {}
	for cid in _estado:
		if not bool(_estado[cid].get("completada", false)):
			activas[String(cid)] = _estado[cid]
	var completadas: Array[String] = []
	for cid in _estado:
		if bool(_estado[cid].get("completada", false)):
			completadas.append(String(cid))
	return {"activas": activas, "completadas": completadas}


func restore_save_data(data: Dictionary) -> void:
	_estado.clear()
	var activas: Dictionary = data.get("activas", {})
	for cid in activas:
		if _cadenas.has(String(cid)):
			_estado[String(cid)] = activas[cid]
		else:
			print("[M23] Huérfana ignorada al cargar: %s" % String(cid))
	var completadas: Array = data.get("completadas", [])
	for cid in completadas:
		if _cadenas.has(String(cid)):
			_estado[String(cid)] = {"paso_actual": 0, "activa": false, "completada": true}
