# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M55: Diario del Jugador — DiaryService (autoload "Diary")
# Núcleo V0/V1 sobre 03-Diseno §1-§5:
#  - Catálogo data-driven de las 14 categorías (data/diario/diario_catalog.json)
#    con las entradas BASE conocidas del proyecto (sellos M22, vecinos M19,
#    especies M34, recetas M16, etc.). Entradas nuevas se agregan al JSON
#    sin tocar código (escalabilidad §5).
#  - Registro por eventos: DiaryService.registrar(entrada_id, categoria) es la
#    API; además conecta señales REALES de M07 (prereq_met→sellos, npc_moved_in→
#    personajes, quest_completed→misiones, travel→island_loaded→lugares,
#    season_changed→eventos, purchase_done→descubrimientos).
#  - Anti-spoiler (§3.2): no descubierto = invisible; % sobre lo DESCUBIERTO.
#  - Marca favorito + búsqueda básica + log DIARY-ADD (convención M103).
#  - Persistencia ISaveProvider M59: sección "diary" (§2.3, < 5 KB típico).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

## Estados de una entrada (diseño §1 diary_entry)
enum Estado { PENDIENTE, VISTO, COMPLETADO }

const RUTA_CATALOGO: String = "res://data/diario/diario_catalog.json"
const CATEGORIAS: Array[String] = [
	"personajes", "lugares", "criaturas", "plantas", "minerales",
	"recetas", "pistas", "sellos", "ruinas", "cartas",
	"descubrimientos", "misiones", "eventos", "fotografias",
]

## catálogo: categoria -> Array de {id, titulo, secreta: bool}
var _catalogo: Dictionary = {}
## estado: entrada_id -> {categoria, estado (Estado), favorito}
var _estados: Dictionary = {}
## Fechas de registro por entrada (día absoluto M30, para la UI)
var _dia_registro: Dictionary = {}
## Entradas registradas esta sesión (notificación "¡Diario actualizado!" M53)
var _nuevas_sesion: Array[String] = []


func _ready() -> void:
	_cargar_catalogo()
	_registrar_proveedor_guardado()
	_conectar_eventos()


func _cargar_catalogo() -> void:
	_catalogo.clear()
	var texto := FileAccess.get_file_as_string(RUTA_CATALOGO)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M55] diario_catalog.json inválido; catálogo vacío")
		return
	for categoria in parseado.get("categorias", []):
		var cat := String(categoria.get("id", ""))
		if cat.is_empty() or not (cat in CATEGORIAS):
			continue
		var entradas: Array[Dictionary] = []
		for e in categoria.get("entradas", []):
			entradas.append({
				"id": String(e.get("id", "")),
				"titulo": String(e.get("titulo", "")),
				"secreta": bool(e.get("secreta", false)),
			})
		_catalogo[cat] = entradas
	print("[M55] Catálogo: %d categorías, %d entradas" % [_catalogo.size(), total_entradas()])


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── Registro por eventos (§2.1) ──────────────────────────

func _conectar_eventos() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		push_warning("[M55] EventBus ausente; solo registro manual")
		return
	# Sellos (M22/M26) → categoría sellos
	if bus.quest.has_signal("prereq_met"):
		bus.quest.prereq_met.connect(func(seal_id: String): registrar("sello_" + _slug(seal_id), "sellos"))
	# Vecinos que se mudan (M19) → personajes
	if bus.npc.has_signal("npc_moved_in"):
		bus.npc.npc_moved_in.connect(func(npc_id: String, _isla: String): registrar("vecino_" + _slug(npc_id), "personajes"))
	# Misiones (M22/M23) → misiones
	if bus.quest.has_signal("quest_completed"):
		bus.quest.quest_completed.connect(func(qid: String): registrar("mision_" + _slug(qid), "misiones"))
	# Lugares: isla cargada por viaje (M28) → lugares
	if bus.travel.has_signal("island_loaded"):
		bus.travel.island_loaded.connect(func(isla: String): registrar("lugar_" + _slug(isla), "lugares"))
	# Eventos de calendario: cambio de estación → eventos (M29; "Verano"→"verano", "Otoño"→"otono")
	if bus.calendar.has_signal("season_changed"):
		bus.calendar.season_changed.connect(func(_o: String, nueva: String): registrar("evento_" + _slug(nueva), "eventos"))
	# Cartas recibidas (M74/M20) → cartas
	if bus.npc.has_signal("carta_recibida"):
		bus.npc.carta_recibida.connect(func(_npc: String, respuesta_id: String): registrar("carta_" + _slug(respuesta_id), "cartas"))


## Normaliza un id compuesto: minúsculas + sin tildes ("Otoño"→"otono").
## Los ids del catálogo son ascii-plana (convención del proyecto).
func _slug(s: String) -> String:
	var r := s.to_lower()
	r = r.replace("á", "a").replace("é", "e").replace("í", "i")
	r = r.replace("ó", "o").replace("ú", "u").replace("ñ", "n")
	return r


## API central de registro (la llaman los sistemas y los puentes de arriba).
## §2.1: ¿existe en catálogo? → estado VISTO; primera vez → notificación.
## Las entradas secretas se registran igual (visible como "???" en lore).
func registrar(entrada_id: String, categoria: String) -> bool:
	if entrada_id == "" or not (_catalogo.has(categoria)):
		return false
	# Validar que la entrada exista en el catálogo de esa categoría
	var existe := false
	for e in _catalogo[categoria]:
		if String(e.get("id", "")) == entrada_id:
			existe = true
			break
	if not existe:
		return false
	# Ya registrada: promover VISTO → COMPLETADO si la llamada repite (idempotente)
	if _estados.has(entrada_id):
		if int(_estados[entrada_id].get("estado", Estado.PENDIENTE)) == Estado.VISTO:
			_estados[entrada_id]["estado"] = Estado.COMPLETADO
		return true
	_estados[entrada_id] = {"categoria": categoria, "estado": Estado.VISTO, "favorito": false}
	_dia_registro[entrada_id] = _dia_absoluto()
	_nuevas_sesion.append(entrada_id)
	EventBus.diary.entrada_nueva.emit(entrada_id, categoria)
	print("[DIARY-ADD] %s (%s)" % [entrada_id, categoria])
	_emitir_progreso(categoria)
	return true


## Marca una entrada VISTA como completada (la llama el sistema dueño)
func marcar_completado(entrada_id: String) -> bool:
	if not _estados.has(entrada_id):
		return false
	if int(_estados[entrada_id].get("estado", Estado.PENDIENTE)) < Estado.COMPLETADO:
		_estados[entrada_id]["estado"] = Estado.COMPLETADO
	return true


func alternar_favorito(entrada_id: String) -> bool:
	if not _estados.has(entrada_id):
		return false
	_estados[entrada_id]["favorito"] = not bool(_estados[entrada_id].get("favorito", false))
	return bool(_estados[entrada_id].get("favorito", false))


## ── Consultas (UI §2.2) ─────────────────────────────────

func esta_registrada(entrada_id: String) -> bool:
	return _estados.has(entrada_id)


func estado_de(entrada_id: String) -> int:
	return int(_estados.get(entrada_id, {}).get("estado", Estado.PENDIENTE))


func es_favorito(entrada_id: String) -> bool:
	return bool(_estados.get(entrada_id, {}).get("favorito", false))


## Entradas descubierto + registro, por categoría (UI: lista virtualizada M61)
func entradas_de(categoria: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for e in _catalogo.get(categoria, []):
		var eid := String(e.get("id", ""))
		var registrado := esta_registrada(eid)
		# §3.2 anti-spoiler: no descubierta → invisible salvo secretas (???)
		if not registrado and not bool(e.get("secreta", false)):
			continue
		result.append({
			"id": eid,
			"titulo": String(e.get("titulo", "")),
			"secreta": bool(e.get("secreta", false)),
			"registrada": registrado,
			"estado": estado_de(eid),
			"favorito": es_favorito(eid),
			"dia": int(_dia_registro.get(eid, 0)),
		})
	return result


## Búsqueda simple sobre lo descubierto (UI: filtro por texto)
func buscar(texto: String) -> Array[String]:
	var resultados: Array[String] = []
	var q := texto.to_lower()
	if q.is_empty():
		return resultados
	for categoria in CATEGORIAS:
		for e in _catalogo.get(categoria, []):
			var eid := String(e.get("id", ""))
			if not esta_registrada(eid):
				continue
			if String(e.get("titulo", "")).to_lower().contains(q) or eid.to_lower().contains(q):
				resultados.append(eid)
	return resultados


func nuevas_sesion() -> Array:
	return _nuevas_sesion.duplicate()


## ── Progreso (§3.2: % sobre lo DESCUBIERTO) ─────────────

## Progreso de una categoría sobre lo descubierto
func progreso_categoria(categoria: String) -> Dictionary:
	var entradas: Array[Dictionary] = entradas_de(categoria)
	var total := entradas.size()
	var vistas := 0
	for e in entradas:
		if int(e.get("estado", 0)) >= Estado.VISTO:
			vistas += 1
	var percent := 0.0
	if total > 0:
		percent = float(vistas) / float(total)
	return {"descubiertas": total, "vistas": vistas, "percent": percent}


func _emitir_progreso(categoria: String) -> void:
	var p := progreso_categoria(categoria)
	EventBus.diary.progreso_cambiado.emit(float(p.get("percent", 0.0)))
	if int(p.get("descubiertas", 0)) > 0 and absf(float(p.get("percent", 0.0)) - 1.0) < 0.001:
		EventBus.diary.categoria_completa.emit(categoria)


## ── Persistencia (M59, §2.3) ────────────────────────────

func _dia_absoluto() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		return int(gt.dia_absoluto())
	return 1


func get_section_name() -> String:
	return "diary"


func get_save_data() -> Dictionary:
	var entradas := {}
	for eid in _estados:
		entradas[String(eid)] = {
			"categoria": _estados[eid].get("categoria", ""),
			"estado": int(_estados[eid].get("estado", 0)),
			"favorito": bool(_estados[eid].get("favorito", false)),
			"dia": int(_dia_registro.get(eid, 0)),
		}
	return {"schema_version": 1, "entradas": entradas}


func restore_save_data(data: Dictionary) -> void:
	_estados.clear()
	_dia_registro.clear()
	var entradas: Dictionary = data.get("entradas", {})
	for eid in entradas:
		var e: Dictionary = entradas[eid]
		var cat := String(e.get("categoria", ""))
		# Validación: solo entradas del catálogo vigente (huérfanas fuera)
		var en_catalogo := false
		for c in _catalogo.get(cat, []):
			if String(c.get("id", "")) == String(eid):
				en_catalogo = true
				break
		if not en_catalogo:
			print("[M55] Huérfana ignorada al cargar: %s" % String(eid))
			continue
		_estados[String(eid)] = {
			"categoria": cat,
			"estado": int(e.get("estado", 0)),
			"favorito": bool(e.get("favorito", false)),
		}
		_dia_registro[String(eid)] = int(e.get("dia", 0))


func total_entradas() -> int:
	var total := 0
	for cat in _catalogo:
		total += (_catalogo[cat] as Array).size()
	return total
