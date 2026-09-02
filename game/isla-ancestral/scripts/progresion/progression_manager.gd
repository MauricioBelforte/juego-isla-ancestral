# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M71: Progresión — ProgressionManager (autoload "ProgressionManager")
# Iteración 2: GameLogger integrado, tipo condicional nivel_modulo añadido,
# catálogo expandido a 15 hitos, logger en DOM-PROG-HITO/UNLOCK/CARGA.
#
# Pitfalls respetados (07-GUIA-GODOT):
#   - Sin class_name (autoload, seccion 9.17)
#   - snake_case en señales
#   - Duck-typing en GameLogger (M103), M13 (tool_controller), M18 (casa_manager)
#   - Tolerante a fallos: si M103 no esta, fallback a print()

extends Node

signal progreso_hito_alcanzado(id: String, nombre: String, recompensas: Array)
signal progreso_desbloqueado(id_unlock: String, tipo: String, valor: String)
signal progreso_primera_vez(actividad_id: String)
signal progreso_resumen_cargado(hitos_total: int, desbloqueos_total: int)

const RUTA_CATALOGO: String = "res://data/progresion/hitos.json"
const SECCION_VERSION: int = 1

var profile: Node = null
var _logger: Node = null

## hitos: id -> {nombre, recompensas: Array, dominio, condicion}
var _hitost: Dictionary = {}
## hitos alcanzados en orden de consecución
var _hitos_alcanzados: Array[String] = []
## desbloqueos activos: id -> {tipo, valor}
var _desbloqueos: Dictionary = {}
## condicion_id -> Array de hitos que dependen de esa condición
var _condiciones_por_hito: Dictionary = {}


func _ready() -> void:
	profile = get_node_or_null("/root/PlayerProfile")
	if profile == null:
		push_error("[M71] PlayerProfile ausente; progresión sin estadísticas")
	_logger = get_node_or_null("/root/GameLogger")
	_cargar_catalogo()
	_registrar_proveedor_guardado()
	_conectar_eventos()
	_log_info("ProgressionManager ready, " + str(_hitost.size()) + " hitos cargados")


## ── Logger helper ────────────────────────────────────────

func _log_info(msg: String) -> void:
	if _logger != null and _logger.has_method("info"):
		_logger.info(msg, 3)  # Category.GAMEPLAY = 3
	else:
		print("[M71] " + msg)


func _log_dom_hito(msg: String) -> void:
	if _logger != null and _logger.has_method("info"):
		_logger.info(msg, 3)
	else:
		print("[DOM-PROG-HITO] " + msg)


func _log_dom_unlock(msg: String) -> void:
	if _logger != null and _logger.has_method("info"):
		_logger.info(msg, 3)
	else:
		print("[DOM-PROG-UNLOCK] " + msg)


## ── Catálogo (§8, JSON data-driven) ─────────────────────

func _cargar_catalogo() -> void:
	_hitost = {}
	var texto := FileAccess.get_file_as_string(RUTA_CATALOGO)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M71] hitos.json inválido; catálogo vacío")
		return
	for hito in parseado.get("hitos", []):
		var id := String(hito.get("id", ""))
		if id.is_empty():
			continue
		_hitost[id] = {
			"nombre": String(hito.get("nombre", id)),
			"condicion": hito.get("condicion", {}),
			"recompensas": hito.get("recompensas", []),
			"dominio": String(hito.get("dominio", "generales")),
		}
		_indexar_condicion(id, _hitost[id]["condicion"])
	_log_info("Hitos cargados: " + str(_hitost.size()))


## indexa por estadística raíz para el dirty-flagging (§7: O(1) por evento)
func _indexar_condicion(hito_id: String, cond: Dictionary) -> void:
	if cond.is_empty():
		return
	var tipo := String(cond.get("tipo", ""))
	match tipo:
		"compuesta":
			for hijo in cond.get("hijos", []):
				_indexar_condicion(hito_id, hijo)
		_:
			var stat := String(cond.get("stat_id", ""))
			if stat != "":
				if not _condiciones_por_hito.has(stat):
					_condiciones_por_hito[stat] = []
				var lista: Array = _condiciones_por_hito[stat]
				if not lista.has(hito_id):
					lista.append(hito_id)


func hitos_count() -> int:
	return _hitost.size()


## ── Registro de eventos de dominio (§1, §5) ─────────────

func _conectar_eventos() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		push_warning("[M71] EventBus ausente; solo evaluación manual")
		return
	if bus.inventory != null and bus.inventory.has_signal("item_added"):
		bus.inventory.item_added.connect(func(_i: String, q: int): _stat("+", "items_recolectados", q))
	if bus.economy != null and bus.economy.has_signal("purchase_done"):
		bus.economy.purchase_done.connect(func(_i: String, cost: int): _stat("+", "monedas_gastadas", cost))
	if bus.npc != null and bus.npc.has_signal("gift_given"):
		bus.npc.gift_given.connect(func(_n: String, _i: String, _c: int): _stat("+", "regalos_dados", 1))
	if bus.quest != null and bus.quest.has_signal("prereq_met"):
		bus.quest.prereq_met.connect(func(seal_id: String):
			_reflejar_hito_narrativo("sello_" + seal_id)
			_stat("+", "sellos_obtenidos", 1)
		)
	if bus.quest != null and bus.quest.has_signal("quest_completed"):
		bus.quest.quest_completed.connect(func(_q: String): _stat("+", "misiones_completadas", 1))
	if bus.npc != null and bus.npc.has_signal("friendship_level_up"):
		bus.npc.friendship_level_up.connect(func(_n: String, _lv: int): _stat("+", "amistades_subidas", 1))
	if bus.travel != null and bus.travel.has_signal("travel_started"):
		bus.travel.travel_started.connect(func(_f: String, _t: String): _stat("+", "viajes_realizados", 1))
	# RF7: reset de estadísticas del día al empezar un día laborable (M29)
	if bus.calendar != null and bus.calendar.has_signal("day_started"):
		bus.calendar.day_started.connect(func(_d: int, _s: String):
			if profile != null and profile.has_method("reset_dia"):
				profile.reset_dia()
		)
	# M13 iter. 5 (glm-5.3-flash): nivel_herramienta_cambio (§3.6 nivel_modulo).
	# El ToolController (M13) es un nodo de escena (no autoload): la escena lo
	# conecta llamando conectar_tool_controller(tc) — helper público. En
	# _ready solo intentamos el autoload si existiera.
	var tc := get_node_or_null("/root/ToolController")
	if tc != null and tc.has_signal("herramienta_equipada"):
		conectar_tool_controller(tc)


## §5: conexión explícita del ToolController de escena (M13) con el puente.
func conectar_tool_controller(tc: Node) -> void:
	if tc == null or not tc.has_signal("herramienta_equipada"):
		return
	if not tc.herramienta_equipada.is_connected(_on_herramienta_equipada):
		tc.herramienta_equipada.connect(_on_herramienta_equipada)
		print("[M71] ToolController conectado (nivel_herramienta_cambio activo)")


## §5: traducción herramienta_equipada → nivel_herramienta_cambio + estadística monótona
func _on_herramienta_equipada(tool: Resource) -> void:
	if tool == null:
		return
	# tool_id legible: "pico", "azada", ... (del enum Tipo de ToolData)
	var tipos := ["pico", "azada", "hacha", "pala", "regadera", "cana", "martillo", "tijeras", "lupa"]
	var tool_id := ""
	var nivel := 0
	if "tipo" in tool:
		var idx := int(tool.tipo)
		tool_id = tipos[idx] if idx >= 0 and idx < tipos.size() else str(idx)
	if "nivel" in tool:
		nivel = int(tool.nivel)
	EventBus.progresion.nivel_herramienta_cambio.emit(tool_id, nivel)
	# Estadística para M71: nivel máximo alcanzado por herramienta (monótono)
	var stat := "nivel_" + tool_id
	var prev := int(profile.get_stat(stat)) if profile != null else 0
	if nivel > prev and profile != null:
		profile.incrementar(stat, nivel - prev)


func _stat(oper: String, stat_id: String, cantidad: int) -> void:
	if profile != null:
		profile.incrementar(stat_id, cantidad)
	_reevaluar(stat_id)


## Reevalúa SOLO los hitos dependientes de la estadística sucia (§7)
func _reevaluar(stat_id: String) -> void:
	if not _condiciones_por_hito.has(stat_id):
		return
	for hito_id in _condiciones_por_hito[stat_id]:
		if not hito_alcanzado(String(hito_id)):
			marcar_hito(String(hito_id))


## ── Evaluador de condiciones (11 tipos, §3.6) ───────────

func evaluar_condicion(cond: Dictionary) -> bool:
	if cond.is_empty():
		return false
	var tipo := String(cond.get("tipo", ""))
	var valor := func(stat_id: String) -> float:
		return float(profile.get_stat(stat_id)) if profile != null else 0.0
	match tipo:
		"stat_min":
			return valor.call(String(cond.get("stat_id", ""))) >= float(cond.get("umbral", 0))
		"dias_jugados":
			var gt := get_node_or_null("/root/GameTime")
			var dias := int(gt.dia_absoluto()) if gt != null else 0
			return dias >= int(cond.get("umbral", 0))
		"sello_historia":
			return _sello_obtenido(cond)
		"capitulo_historia":
			var h := get_node_or_null("/root/Historia")
			return h != null and int(h.capitulo_actual()) >= int(cond.get("capitulo", 99))
		"riqueza_acumulada":
			return valor.call("monedas_ganadas") >= float(cond.get("umbral", 0))
		"primera_vez":
			return _primera_vez_hecha(String(cond.get("actividad_id", "")))
		"hito_previo":
			return hito_alcanzado(String(cond.get("milestone_id", "")))
		"coleccion_completa":
			var reg := get_node_or_null("/root/CollectionRegistry")
			return reg != null and bool(reg.is_exhibition_completed(String(cond.get("coleccion_id", ""))))
		"nivel_modulo":
			return _evaluar_nivel_modulo(cond)
		"compuesta":
			var op := String(cond.get("operador", "AND"))
			var hijos: Array = cond.get("hijos", [])
			if hijos.is_empty():
				return false
			if op == "AND":
				for h in hijos:
					if not evaluar_condicion(h):
						return false
				return true
			if op == "OR":
				for h in hijos:
					if evaluar_condicion(h):
						return true
				return false
			if op == "NOT":
				return not evaluar_condicion(hijos[0])
			return false
		_:
			return false


func _evaluar_nivel_modulo(cond: Dictionary) -> bool:
	# M13 tool_controller: obtener_nivel_herramienta(id) -> int
	# M18 casa_manager: obtener_nivel_casa() -> int
	# Duck-typing: intenta ambos, fallback 0 si ninguno existe
	var modulo := String(cond.get("modulo", ""))
	var umbral := int(cond.get("umbral", 0))
	if modulo == "herramienta":
		var ref := get_node_or_null("/root/ToolController")
		if ref != null and ref.has_method("obtener_nivel_herramienta"):
			var id_herr := String(cond.get("ref", ""))
			var niv := int(ref.obtener_nivel_herramienta(id_herr)) if id_herr != "" else 0
			return niv >= umbral
		return false
	if modulo == "casa":
		var ref := get_node_or_null("/root/CasaManager")
		if ref != null and ref.has_method("obtener_nivel_casa"):
			var niv := int(ref.obtener_nivel_casa())
			return niv >= umbral
		return false
	# modulo desconocido -> false
	return false


func _sello_obtenido(cond: Dictionary) -> bool:
	var h := get_node_or_null("/root/Historia")
	if h == null:
		return false
	if h.has_method("sello_marcado"):
		return bool(h.sello_marcado(String(cond.get("sello_id", ""))))
	return false


func _primera_vez_hecha(actividad_id: String) -> bool:
	return profile != null and not profile.primera_vez(actividad_id)


## ── Hitos (marcado idempotente, §3.1) ───────────────────

func marcar_hito(milestone_id: String) -> bool:
	if hito_alcanzado(milestone_id) or not _hitost.has(milestone_id):
		return false
	_hitost[milestone_id]["recompensa_entregada"] = true
	_hitos_alcanzados.append(milestone_id)
	var nombre := String(_hitost[milestone_id].get("nombre", milestone_id))
	var recompensas: Array = _hitost[milestone_id].get("recompensas", [])
	progreso_hito_alcanzado.emit(milestone_id, nombre, recompensas.duplicate())
	_log_dom_hito(milestone_id + " (" + nombre + ")")
	# Recompensas tipo "unlock" activan desbloqueos (cosméticos/info — §8)
	for rec in recompensas:
		var r: Dictionary = rec
		if String(r.get("tipo", "")) == "unlock":
			activar_desbloqueo(String(r.get("unlock_id", "")), String(r.get("tipo_unlock", "info")), String(r.get("valor", "")))
	return true


func hito_alcanzado(milestone_id: String) -> bool:
	return milestone_id in _hitos_alcanzados


func hitos_alcanzados() -> Array:
	return _hitos_alcanzados.duplicate()


## Progreso parcial de un hito (para la UI M53, evaluación perezosa §7)
func progreso_parcial(milestone_id: String) -> Dictionary:
	var hito: Dictionary = _hitost.get(milestone_id, {})
	var cond: Dictionary = hito.get("condicion", {})
	if cond.is_empty():
		return {"logrado": 0, "requerido": 0}
	if String(cond.get("tipo", "")) == "stat_min":
		var val_f := float(profile.get_stat(String(cond.get("stat_id", "")))) if profile != null else 0.0
		return {"logrado": val_f, "requerido": float(cond.get("umbral", 0))}
	return {"logrado": int(hito_alcanzado(milestone_id)), "requerido": 1}


## ── Desbloqueos (§3.1 activador) ────────────────────────

func activar_desbloqueo(unlock_id: String, tipo: String, valor: String) -> void:
	if _desbloqueos.has(unlock_id):
		return
	_desbloqueos[unlock_id] = {"tipo": tipo, "valor": valor}
	progreso_desbloqueado.emit(unlock_id, tipo, valor)
	_log_dom_unlock(unlock_id + " (" + tipo + ": " + valor + ")")


func desbloqueo_activo(unlock_id: String) -> bool:
	return _desbloqueos.has(unlock_id)


## ── Reflejo narrativo (§2.2: solo lectura, M22 es la verdad) ──

func _reflejar_hito_narrativo(hito_id: String) -> void:
	if _hitost.has(hito_id) and not hito_alcanzado(hito_id):
		marcar_hito(hito_id)


## ── Persistencia (§6, versionada) ───────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return "progresion"


func get_save_data() -> Dictionary:
	return {
		"version": SECCION_VERSION,
		"hitos_alcanzados": _hitos_alcanzados.duplicate(),
		"desbloqueos_activos": _desbloqueos.duplicate(),
		"estadisticas_totales": profile.guardar().get("estadisticas_totales", {}) if profile != null else {},
		"estadisticas_dia": profile.guardar().get("estadisticas_dia", {}) if profile != null else {},
		"primeras_veces": profile.guardar().get("primeras_veces", []) if profile != null else [],
		"contribucion": profile.contribucion_actual() if profile != null else 0.0,
	}


func restore_save_data(data: Dictionary) -> void:
	_hitos_alcanzados.clear()
	for h in data.get("hitos_alcanzados", []):
		var hid := String(h)
		if _hitost.has(hid):
			_hitos_alcanzados.append(hid)
		else:
			_log_info("Hito de catálogo antiguo ignorado: " + hid)
	_desbloqueos.clear()
	var d: Dictionary = data.get("desbloqueos_activos", {})
	for k in d:
		_desbloqueos[String(k)] = d[k]
	if profile != null:
		profile.cargar({
			"estadisticas_totales": data.get("estadisticas_totales", {}),
			"estadisticas_dia": data.get("estadisticas_dia", {}),
			"primeras_veces": data.get("primeras_veces", []),
			"contribucion": data.get("contribucion", 0.0),
		})
	progreso_resumen_cargado.emit(_hitos_alcanzados.size(), _desbloqueos.size())
	_log_info("Progreso restaurado: " + str(_hitos_alcanzados.size()) + " hitos, " + str(_desbloqueos.size()) + " desbloqueos")
	# §2.3: NUNCA re-emitir señales de hitos restaurados (idempotencia)
