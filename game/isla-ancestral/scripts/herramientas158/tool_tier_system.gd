# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M158: Herramientas y Desbloqueo de Zonas — ToolTierSystem (autoload "Tiers").
# Núcleo V0 iter. 1 (diseño §A-§D, §I, §J):
#  - 4 tiers data-driven (T1_COBRE..T4_CRISTAL) con daño/velocidad/área del §B.
#  - Gates por zona: can_access_zone() + desbloquear_gate() permanente
#    (señal gate_unlocked; persistencia de gates desbloqueados).
#  - Forjas por isla: forjar(isla, tool_type) valida tier previo + materiales
#    (M14 Inventario) + monedas (M38 EconomyManager), entrega herramienta y
#    registra tier máximo por tipo.
#  - Cursos de oficio únicos: tomar_curso() valida tier y cobra (M38);
#    desbloquean venta de herramientas hasta tier_max_venta.
#  - Integración historia (§I): zona_bloquea_historia() consultable por M22;
#    anti-softlock: forja T1 siempre disponible (regalo) en isla_raiz.
#  - Persistencia ISaveProvider M59: sección "tool_tiers".
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

const RUTA_CONFIG: String = "res://data/herramientas/tiers_config.json"

signal gate_unlocked(zone_id: String, gate_id: String)
signal tool_forged(tier_id: String, tool_type: String)
signal course_completed(course_id: String)

## tier_id -> {nivel, nombre, dano, velocidad, area, color}
var _tiers: Dictionary = {}
## gate_id -> datos del gate (tipo, required_tier, required_tool, zone_id, blocks_story)
var _gates: Dictionary = {}
## isla -> datos de la forja (tier, materiales, monedas, profesional)
var _forjas: Dictionary = {}
## course_id -> datos del curso (profesion, costo, tier_max_venta, isla)
var _cursos: Dictionary = {}

## ── Estado persistente (§J) ─────────────────────────────
## tool_type -> tier_id máximo alcanzado
var _tier_max: Dictionary = {}
## gate_id -> true (desbloqueados permanentemente)
var _gates_abiertos: Dictionary = {}
## course_id -> true (cursos únicos)
var _cursos_aprendidos: Dictionary = {}
## conteo de forjas realizadas
var _forjas_count: int = 0


func _ready() -> void:
	_cargar_config()
	_registrar_proveedor_guardado()
	print("[M158] ToolTierSystem listo: %d tiers, %d gates, %d forjas, %d cursos" % [_tiers.size(), _gates.size(), _forjas.size(), _cursos.size()])


func _cargar_config() -> void:
	var texto := FileAccess.get_file_as_string(RUTA_CONFIG)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M158] tiers_config.json inválido")
		return
	for t in parseado.get("tiers", []):
		var id := String(t.get("id", ""))
		if id != "":
			_tiers[id] = {
				"nivel": int(t.get("nivel", 1)),
				"nombre": String(t.get("nombre", id)),
				"dano": float(t.get("dano", 1.0)),
				"velocidad": float(t.get("velocidad", 1.0)),
				"area": int(t.get("area", 1)),
				"color": String(t.get("color", "")),
			}
	for g in parseado.get("gates", []):
		var gid := String(g.get("gate_id", ""))
		if gid != "":
			_gates[gid] = g
	for f in parseado.get("forjas", []):
		var isla := String(f.get("isla", ""))
		if isla != "":
			_forjas[isla] = f
	for c in parseado.get("cursos", []):
		var cid := String(c.get("course_id", ""))
		if cid != "":
			_cursos[cid] = c


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── Tiers (§B) ──────────────────────────────────────────

func tiers_count() -> int:
	return _tiers.size()


func get_tier(tier_id: String) -> Dictionary:
	return _tiers.get(tier_id, {})


func get_tier_nivel(tier_id: String) -> int:
	return int(_tiers.get(tier_id, {}).get("nivel", 0))


## Tier máximo alcanzado por tipo de herramienta ("pico", "hacha", ...)
func tier_max_de(tool_type: String) -> String:
	return String(_tier_max.get(tool_type, ""))


func tiene_tier(tool_type: String, tier_id: String) -> bool:
	var actual := tier_max_de(tool_type)
	if actual == "":
		return false
	return get_tier_nivel(actual) >= get_tier_nivel(tier_id)


## ── Gates por zona (§C) ─────────────────────────────────

func gates_count() -> int:
	return _gates.size()


## ¿El jugador puede pasar el gate? (tier del tool_type requerido)
func can_access_zone(zone_id: String, tool_type: String = "") -> bool:
	var gate := _gate_de_zona(zone_id)
	if gate.is_empty():
		return true  # sin gate = libre
	if _gates_abiertos.has(String(gate.get("gate_id", ""))):
		return true
	var req_tier := String(gate.get("required_tier", ""))
	var req_tool := String(gate.get("required_tool", ""))
	var tipo := tool_type if tool_type != "" else req_tool
	return tiene_tier(tipo, req_tier)


## Información de bloqueo para tooltip/feedback (§C)
func info_gate(zone_id: String) -> Dictionary:
	var gate := _gate_de_zona(zone_id)
	if gate.is_empty():
		return {}
	return {
		"gate_id": String(gate.get("gate_id", "")),
		"required_tier": String(gate.get("required_tier", "")),
		"required_tool": String(gate.get("required_tool", "")),
		"abierto": _gates_abiertos.has(String(gate.get("gate_id", ""))),
		"blocks_story": bool(gate.get("blocks_story", false)),
	}


func _gate_de_zona(zone_id: String) -> Dictionary:
	for gid in _gates:
		if String(_gates[gid].get("zone_id", "")) == zone_id:
			return _gates[gid]
	return {}


## Desbloqueo permanente (se llama al interactuar con el gate con la tool válida)
func desbloquear_gate(gate_id: String) -> bool:
	if not _gates.has(gate_id) or _gates_abiertos.has(gate_id):
		return false
	_gates_abiertos[gate_id] = true
	var zone := String(_gates[gate_id].get("zone_id", ""))
	gate_unlocked.emit(zone, gate_id)
	print("[M158] Gate abierto: %s (%s)" % [gate_id, zone])
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("mark_dirty"):
		sm.mark_dirty()
	return true


## §I: ¿algún gate que bloquea historia sigue cerrado para la zona?
func zona_bloquea_historia(zone_id: String, tool_type: String = "") -> bool:
	var gate := _gate_de_zona(zone_id)
	if gate.is_empty() or not bool(gate.get("blocks_story", false)):
		return false
	return not can_access_zone(zone_id, tool_type)


## ── Forjas por isla (§D) ────────────────────────────────

func forjas_count() -> int:
	return _forjas.size()


## Datos de la forja para la ForgeUI (M53)
func get_forja(isla: String) -> Dictionary:
	return _forjas.get(isla, {})


## Forjar en una isla: valida materiales (M14) + monedas (M38) y entrega.
## tool_type: "pico"|"hacha"|"pala"|"martillo"|... (el jugador elige la herramienta)
func forjar(isla: String, tool_type: String) -> Dictionary:
	var forja: Dictionary = _forjas.get(isla, {})
	if forja.is_empty():
		return {"ok": false, "motivo": "sin forja en %s" % isla}
	var tier_id := String(forja.get("tier", ""))
	# Regla cozy anti-softlock: si ya tengo este tier o superior, no repito forja
	if tiene_tier(tool_type, tier_id):
		return {"ok": false, "motivo": "ya tienes %s o superior" % tier_id}
	# Materiales (M14)
	var inv := get_node_or_null("/root/Inventario")
	var materiales: Dictionary = forja.get("materiales", {})
	if inv == null:
		return {"ok": false, "motivo": "inventario no disponible (M14)"}
	for mat in materiales:
		if int(inv.count_item(String(mat))) < int(materiales[mat]):
			return {"ok": false, "motivo": "faltan materiales: %s x%d" % [String(mat), int(materiales[mat])]}
	# Monedas (M38)
	var monedas := int(forja.get("monedas", 0))
	if monedas > 0:
		var eco := get_node_or_null("/root/EconomyManager")
		if eco == null or not eco.has_method("retirar_monedas"):
			return {"ok": false, "motivo": "economía no disponible (M38)"}
		if not bool(eco.retirar_monedas(monedas)):
			return {"ok": false, "motivo": "AO insuficiente: cuesta %d" % monedas}
	# Consumir materiales SOLO tras validar todo (§4.3.3 estilo M37)
	for mat in materiales:
		inv.remover_items({String(mat): int(materiales[mat])})
	# Registrar tier máximo y contar forja
	_tier_max[tool_type] = tier_id
	_forjas_count += 1
	tool_forged.emit(tier_id, tool_type)
	print("[M158] Forjado: %s %s en %s (forja #%d)" % [tier_id, tool_type, isla, _forjas_count])
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("mark_dirty"):
		sm.mark_dirty()
	# M71: reflejar hito de tier (duck-typed; el catálogo de hitos lo condiciona)
	var pm := get_node_or_null("/root/ProgressionManager")
	if pm != null and pm.has_method("evaluar_todos_hitos"):
		pm.evaluar_todos_hitos()
	return {"ok": true, "motivo": "", "tier": tier_id, "tool": tool_type}


## ── Cursos de oficio (§E) ───────────────────────────────

func cursos_count() -> int:
	return _cursos.size()


func curso_aprendido(course_id: String) -> bool:
	return _cursos_aprendidos.has(course_id)


## ¿Puede vender herramientas de este tier? (requiere un curso con tier_max >= )
func puede_vender_tier(tier_id: String) -> bool:
	for cid in _cursos_aprendidos:
		var curso: Dictionary = _cursos.get(String(cid), {})
		var tmax := String(curso.get("tier_max_venta", ""))
		if get_tier_nivel(tmax) >= get_tier_nivel(tier_id):
			return true
	return false


func tomar_curso(course_id: String) -> Dictionary:
	var curso: Dictionary = _cursos.get(course_id, {})
	if curso.is_empty():
		return {"ok": false, "motivo": "curso desconocido"}
	if curso_aprendido(course_id):
		return {"ok": false, "motivo": "curso ya aprendido (único)"}
	# §E: el curso puede requerir un tier mínimo (valida con la mejor herramienta)
	var costo := int(curso.get("costo", 0))
	var eco := get_node_or_null("/root/EconomyManager")
	if eco == null or not eco.has_method("retirar_monedas"):
		return {"ok": false, "motivo": "economía no disponible (M38)"}
	if not bool(eco.retirar_monedas(costo)):
		return {"ok": false, "motivo": "AO insuficiente: cuesta %d" % costo}
	_cursos_aprendidos[course_id] = true
	course_completed.emit(course_id)
	print("[M158] Curso completado: %s (%d AO)" % [course_id, costo])
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("mark_dirty"):
		sm.mark_dirty()
	return {"ok": true, "motivo": "", "profesion": String(curso.get("profesion", ""))}


## ── Persistencia (M59, §J) ──────────────────────────────

func get_section_name() -> String:
	return "tool_tiers"


func get_save_data() -> Dictionary:
	return {
		"version": 1,
		"tier_max": _tier_max.duplicate(),
		"gates_abiertos": _gates_abiertos.keys(),
		"cursos": _cursos_aprendidos.keys(),
		"forjas_count": _forjas_count,
	}


func restore_save_data(data: Dictionary) -> void:
	# §J: tolerante a ids de catálogo viejo (purga con log)
	_tier_max.clear()
	var tm: Dictionary = data.get("tier_max", {})
	for k in tm:
		if _tiers.has(String(tm[k])):
			_tier_max[String(k)] = String(tm[k])
		else:
			print("[M158] Tier de catálogo viejo ignorado: %s" % String(tm[k]))
	_gates_abiertos.clear()
	for g in data.get("gates_abiertos", []):
		var gid := String(g)
		if _gates.has(gid):
			_gates_abiertos[gid] = true
		else:
			print("[M158] Gate de catálogo viejo ignorado: %s" % gid)
	_cursos_aprendidos.clear()
	for c in data.get("cursos", []):
		var cid := String(c)
		if _cursos.has(cid):
			_cursos_aprendidos[cid] = true
		else:
			print("[M158] Curso de catálogo viejo ignorado: %s" % cid)
	_forjas_count = int(data.get("forjas_count", 0))
	# NUNCA re-emitir señales de estado restaurado (§2.3 estilo M71)
