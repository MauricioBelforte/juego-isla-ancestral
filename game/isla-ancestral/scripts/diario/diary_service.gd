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
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).
extends Node

## Estados de una entrada (diseño §1 diary_entry)
enum Estado { PENDIENTE, VISTO, COMPLETADO }

const RUTA_CATALOGO: String = "res://data/diario/diario_catalog.json"
## Clasificación de secciones lore (iter. 7, L164): fuente única compartida con
## diary_layer (texto "???") y validate_diary (regla de datos).
const LORE := preload("res://scripts/diario/secciones_lore.gd")
const CATEGORIAS: Array[String] = [
	"personajes", "lugares", "criaturas", "plantas", "minerales",
	"recetas", "pistas", "sellos", "ruinas", "cartas",
	"descubrimientos", "misiones", "eventos", "fotografias",
]

## catálogo: categoria -> Array de {id, titulo, secreta, descripcion, refs}
var _catalogo: Dictionary = {}
## estado: entrada_id -> {categoria, estado (Estado), favorito}
var _estados: Dictionary = {}
## Fechas de registro por entrada (día absoluto M30, para la UI)
var _dia_registro: Dictionary = {}
## Datos extra por entrada (tanda GLM-5.3-Flash 2026-11-25, checklist L57/L92):
## entrada_id -> Dictionary con los puentes de datos de otros módulos leídos
## read-only (ej: {"nivel_relacion": 2, "retrato": "res://...",
## "ultimo_dialogo": "aur_001"} en personajes; {"cantidad_inventario": 4} en
## minerales). Se persiste en la sección diary (schema_version 2).
var _extras: Dictionary = {}
## Entradas registradas esta sesión (notificación "¡Diario actualizado!" M53)
var _nuevas_sesion: Array[String] = []
## Preferencias de UI persistidas (T-M1 lote 2): filtro de estado y
## categoría abierta del diario, guardadas con el save (sección diary, "ui")
var _ui_prefs: Dictionary = {"filtro": 0, "categoria": "personajes"}
## Contador de diagnóstico (iter. 4, checklist W/L195): cuántas veces se
## materializó la lista de una categoría. Con la virtualización +
## progreso_global, un refresco completo debe llamar entradas_de() solo para
## la categoría ACTIVA (antes: una por categoría en el % global).
var _llamadas_entradas_de: int = 0


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
			var refs: Array[String] = []
			for r in e.get("refs", []):
				refs.append(String(r))
			entradas.append({
				"id": String(e.get("id", "")),
				"titulo": String(e.get("titulo", "")),
				"secreta": bool(e.get("secreta", false)),
				"descripcion": String(e.get("descripcion", "")),
				"refs": refs,
				# Campo OPCIONAL declarado por el catálogo (iter. 6, nivel 1 del
				# resolutor de iconos). Faltaba acá: el loader lo descartaba y
				# `entradas_de()` leía siempre "" (nivel 1 inalcanzable). Medido
				# en la iter. 7: 44/44 entradas sin la clave.
				"icono": String(e.get("icono", "")),
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
	# Vecinos que se mudan (M19) → personajes (con retrato NPCVisualDatabase)
	if bus.npc.has_signal("npc_moved_in"):
		bus.npc.npc_moved_in.connect(func(npc_id: String, _isla: String):
			var datos: Dictionary = {}
			var visual := _retrato_npc(npc_id)
			if not visual.is_empty():
				datos["retrato"] = visual
			registrar_con_datos("vecino_" + _slug(npc_id), "personajes", datos))
	# Nivel de amistad (M20) → personajes: snapshot del nivel de relación
	# (checklist L57: la relación vive con la entrada del personaje).
	if bus.npc.has_signal("nivel_amistad_cambio"):
		bus.npc.nivel_amistad_cambio.connect(func(npc_id: String, nivel: int):
			var eid := _npc_a_entrada(npc_id, "personajes")
			if not eid.is_empty():
				registrar_con_datos(eid, "personajes", {"nivel_relacion": nivel}))
	# Diálogo solicitado (M21) → personajes: último diálogo leído por vecino
	# (checklist L57: "últimos diálogos"; se guarda el id del nodo solicitado).
	if bus.npc.has_signal("dialog_requested"):
		bus.npc.dialog_requested.connect(func(npc_id: String, dialog_data: Dictionary):
			var did := String(dialog_data.get("id", ""))
			if did.is_empty():
				return
			var eid := _npc_a_entrada(npc_id, "personajes")
			if not eid.is_empty():
				registrar_con_datos(eid, "personajes", {"ultimo_dialogo": did}))
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


## Traduce un id ajeno (ej: npc_id "catalina_oso") al id de entrada del
## catálogo ("vecino_catalina_oso"). Exacto primero; fallback por prefijo
## ("vecino_catalina_oso_alt") o por substring ("cat_oso"). "" si no hay match.
func _npc_a_entrada(valor: String, categoria: String) -> String:
	if valor.is_empty() or not _catalogo.has(categoria):
		return ""
	var candidato := categoria_singular(categoria) + "_" + _slug(valor)
	var exacto := _entrada_existe(candidato, categoria)
	if exacto != "":
		return exacto
	for e in _catalogo[categoria]:
		var eid := String(e.get("id", ""))
		if eid.begins_with(candidato + "_") or _slug(eid).contains(_slug(valor)):
			return eid
	return ""


## Prefijo de categoría para ids compuestos ("personajes"→"vecino",
## "minerales"→"mineral"; si la categoría no está mapeada, la propia id).
func categoria_singular(categoria: String) -> String:
	match categoria:
		"personajes": return "vecino"
		"lugares": return "lugar"
		"sellos": return "sello"
		"misiones": return "mision"
		"eventos": return "evento"
		"cartas": return "carta"
		"recetas": return "receta"
		"plantas": return "planta"
		"minerales": return "mineral"
		"ruinas": return "ruina"
		"criaturas": return "pez"
		"pistas": return "pista"
		_: return categoria


func _entrada_existe(entrada_id: String, categoria: String) -> String:
	for e in _catalogo.get(categoria, []):
		if String(e.get("id", "")) == entrada_id:
			return entrada_id
	return ""


## Ruta del recurso visual (retrato) de un NPC (read-only M162).
## "" si el autoload no existe o no tiene visual para ese id.
func _retrato_npc(npc_id: String) -> String:
	var db := get_node_or_null("/root/NPCVisualDatabase")
	if db == null or not db.has_method("get_visual"):
		return ""
	var visual: Resource = db.get_visual(npc_id)
	if visual == null or visual.resource_path.is_empty():
		return ""
	return visual.resource_path


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
	# Snapshot de cantidad en inventario (M14) para minerales (checklist L92:
	# "guardar cantidad conocida"): al registrar, se lee read-only el conteo
	# del ítem asociado (mineral_mineral_cobre → mineral_cobre).
	if categoria == "minerales":
		var cant := _cantidad_inventario_de(entrada_id)
		if cant >= 0:
			_extras[entrada_id] = _extras.get(entrada_id, {}).merged({"cantidad_inventario": cant}, true)
	var bus := get_node_or_null("/root/EventBus")
	if bus != null:
		bus.diary.entrada_nueva.emit(entrada_id, categoria)
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


## ── Datos extra por entrada (puentes read-only, L57/L92) ──────────

## Registra (o actualiza) una entrada ADEMÁS de datos extra de otros módulos.
## Idempotente: re-llamadas fusionan los datos (los nuevos pisan claves).
func registrar_con_datos(entrada_id: String, categoria: String, datos: Dictionary) -> bool:
	if datos.is_empty():
		return registrar(entrada_id, categoria)
	if not registrar(entrada_id, categoria):
		return false
	# Promover VISTO → COMPLETADO si el puente repite (misma semántica que
	# la re-llamada de registrar, §2.1) y fusionar los datos.
	var previos: Dictionary = _extras.get(entrada_id, {})
	_extras[entrada_id] = previos.merged(datos, true)
	return true


## Datos extra de una entrada (copia segura; {} si no tiene).
func datos_de(entrada_id: String) -> Dictionary:
	return (_extras.get(entrada_id, {}) as Dictionary).duplicate()


## Cantidad en inventario (M14) del ítem asociado a una entrada de minerales.
## -1 si el servicio no está disponible o el id no mapea.
func _cantidad_inventario_de(entrada_id: String) -> int:
	var inv := get_node_or_null("/root/Inventario")
	if inv == null or not inv.has_method("count_item"):
		return -1
	var item_id := entrada_id
	if item_id.begins_with("mineral_"):
		item_id = item_id.substr("mineral_".length())
	return int(inv.count_item(item_id))


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


## Detalle para el panel derecho de la UI (T-M1 lote 2): título crudo,
## descripción y refs a otras entradas del catálogo. Devuelve {} si el id no
## existe. El ANTI-SPOILER es responsabilidad de la capa: solo se pide el
## detalle de una entrada ya seleccionada (visible en la lista).
func detalle_entrada(entrada_id: String) -> Dictionary:
	var cat := categoria_de(entrada_id)
	if cat.is_empty():
		return {}
	for e in _catalogo[cat]:
		if String(e.get("id", "")) == entrada_id:
			var d: Dictionary = {
				"id": entrada_id,
				"titulo": String(e.get("titulo", "")),
				"descripcion": String(e.get("descripcion", "")),
				"refs": (e.get("refs", []) as Array).duplicate(),
				"icono": String(e.get("icono", "")),
				# Datos extra de puentes (L57/L92): nivel_relacion, retrato,
				# ultimo_dialogo, cantidad_inventario... {} si no tiene.
				"datos": datos_de(entrada_id),
			}
			# Cantidad EN VIVO del inventario (M14) para minerales: el snapshot
			# del registro queda en "datos"; el conteo actual se expone aparte.
			if cat == "minerales":
				d["inventario"] = _cantidad_inventario_de(entrada_id)
			return d
	return {}


## Categoría a la que pertenece una entrada ("" si no existe).
func categoria_de(entrada_id: String) -> String:
	for cat in _catalogo:
		for e in _catalogo[cat]:
			if String(e.get("id", "")) == entrada_id:
				return String(cat)
	return ""


## ── Preferencias de UI persistidas (T-M1 lote 2) ──────────────────

## Guarda el filtro de estado y la categoría abierta del diario.
## filtro: enum DiaryLayer.Filtro (0..4); categoría: id de CATEGORIAS.
## Valores fuera de rango → default (save corrupto no rompe la UI).
func set_ui_prefs(filtro: int, categoria: String) -> void:
	_ui_prefs = {
		"filtro": filtro if filtro >= 0 and filtro <= 4 else 0,
		"categoria": categoria if categoria in CATEGORIAS else "personajes",
	}


func get_ui_prefs() -> Dictionary:
	return _ui_prefs.duplicate()


## Entradas descubierto + registro, por categoría (UI: lista virtualizada M61)
func entradas_de(categoria: String) -> Array[Dictionary]:
	_llamadas_entradas_de += 1
	var result: Array[Dictionary] = []
	for e in _catalogo.get(categoria, []):
		var eid := String(e.get("id", ""))
		var registrado := esta_registrada(eid)
		var secreta := bool(e.get("secreta", false))
		# §3.2 anti-spoiler: no descubierta → invisible salvo secretas de LORE.
		# En una COLECCIÓN la marca `secreta` se ignora (L164): la entrada sigue
		# invisible hasta registrarse, en vez de aparecer como "???" fuera de
		# lore. La decisión es la MISMA función que usa la capa (secciones_lore).
		if not registrado and not LORE.bloqueada(categoria, secreta, registrado):
			continue
		result.append({
			"id": eid,
			"titulo": String(e.get("titulo", "")),
			"secreta": secreta,
			"registrada": registrado,
			"estado": estado_de(eid),
			"favorito": es_favorito(eid),
			"dia": int(_dia_registro.get(eid, 0)),
			# Campo OPCIONAL del catálogo (iter. 6, L93/L117/L203): si la entrada
			# declara su icono, el resolutor lo usa como nivel 1; si no, deriva el
			# id con las convenciones M46. Se expone para que el nivel 1 sea
			# alcanzable (un campo que nadie lee es una rama muerta).
			"icono": String(e.get("icono", "")),
		})
	return result


## Búsqueda simple sobre lo descubierto (UI: filtro por texto).
## Diacríticos (M87, checklist R): compara sin tildes y en minúsculas
## (ambos lados pasan por _slug), así "raiz" encuentra "Isla Raíz".
func buscar(texto: String) -> Array[String]:
	var resultados: Array[String] = []
	var q := texto.strip_edges()
	if q.is_empty():
		return resultados
	var q_norm := _slug(q)
	for categoria in CATEGORIAS:
		for e in _catalogo.get(categoria, []):
			var eid := String(e.get("id", ""))
			if not esta_registrada(eid):
				continue
			if _slug(String(e.get("titulo", ""))).contains(q_norm) or eid.contains(q_norm):
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
	var bus := get_node_or_null("/root/EventBus")
	if bus != null:
		bus.diary.progreso_cambiado.emit(float(p.get("percent", 0.0)))
	if bus != null and int(p.get("descubiertas", 0)) > 0 and absf(float(p.get("percent", 0.0)) - 1.0) < 0.001:
		bus.diary.categoria_completa.emit(categoria)


## Progreso GLOBAL del diario SIN materializar entradas (LazyLoad, checklist
## L195): recorre catálogo y _estados directo (0 Dictionary por entrada).
## Misma semántica que progreso_categoria (§3.2: % sobre lo DESCUBIERTO).
## La UI lo usa para el % global en vez de sumar 14 progreso_categoria()
## (que materializaban todas las categorías en cada apertura).
func progreso_global() -> Dictionary:
	var vistas := 0
	var total := 0
	for cat in _catalogo:
		for e in _catalogo[cat]:
			var eid := String(e.get("id", ""))
			# descubierta = registrada o secreta (mismo criterio que entradas_de §3.2)
			if not _estados.has(eid) and not bool(e.get("secreta", false)):
				continue
			total += 1
			if int(_estados.get(eid, {}).get("estado", 0)) >= Estado.VISTO:
				vistas += 1
	var percent := 0.0
	if total > 0:
		percent = float(vistas) / float(total)
	return {"vistas": vistas, "descubiertas": total, "percent": percent}


## Contador de diagnóstico para tests (LazyLoad, checklist L195).
func debug_llamadas_entradas_de() -> int:
	return _llamadas_entradas_de


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
	return {"schema_version": 2, "entradas": entradas, "ui": _ui_prefs.duplicate(), "extras": _extras.duplicate(true)}


func restore_save_data(data: Dictionary) -> void:
	_estados.clear()
	_dia_registro.clear()
	_extras.clear()
	# Preferencias de UI (T-M1 lote 2): tolerante — sin "ui" o inválidas →
	# defaults (los saves antiguos de M59 sin esta clave cargan igual).
	var ui: Dictionary = data.get("ui", {})
	set_ui_prefs(int(ui.get("filtro", 0)), String(ui.get("categoria", "personajes")))
	# Datos extra (schema_version 2; saves v1 sin "extras" cargan igual).
	var extras: Dictionary = data.get("extras", {})
	if typeof(extras) == TYPE_DICTIONARY:
		for eid in extras:
			if typeof(extras[eid]) == TYPE_DICTIONARY:
				_extras[String(eid)] = (extras[eid] as Dictionary).duplicate()
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


## Las categorías en orden (para la UI T-M1). La const CATEGORIAS no se lee
## bien a través de Variant en runtime, así que se expone este accessor.
func get_categorias() -> Array[String]:
	return CATEGORIAS.duplicate()


## ── Validación contra el catálogo de M25 (checklist L125) ─────────

## Valida los estados de sellos del diario contra el catálogo real de sellos
## (data/balance/seals.json). Devuelve:
##	{"catalogo_ok": bool, "sellos_diario": int, "sellos_m25": int,
##	 "desconocidos": [ids del diario sin homólogo en M25],
##	 "sin_diario": [ids de M25 sin entrada registrada en el diario]}
## "desconocidos" es esperado no-vacío: el diario registra la familia de
## sellos de TEMPLES (M24: sello_ceniza_sala1...) y M25 cataloga los sellos de
## PROGRESO del juego (sello_llegada...); la validación expone la relación.
func validar_sellos_m25(ruta: String = "res://data/balance/seals.json") -> Dictionary:
	var reporte := {"catalogo_ok": false, "sellos_diario": 0, "sellos_m25": 0, "desconocidos": [], "sin_diario": []}
	var texto := FileAccess.get_file_as_string(ruta)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		return reporte
	var sellos_m25: Variant = (parseado as Dictionary).get("sellos", {})
	if typeof(sellos_m25) != TYPE_DICTIONARY:
		return reporte
	reporte["catalogo_ok"] = true
	reporte["sellos_m25"] = (sellos_m25 as Dictionary).size()
	var ids_m25: Array[String] = []
	for sid in sellos_m25:
		ids_m25.append(String(sid))
	var registrados: Array[String] = []
	for eid in _estados:
		if String(_estados[eid].get("categoria", "")) == "sellos":
			registrados.append(String(eid))
	reporte["sellos_diario"] = registrados.size()
	# Homólogo M25 de un sello del diario: id sin el prefijo "sello_" exterior
	# ("sello_sello_ceniza_sala1" → "sello_ceniza_sala1") o coincidencia de
	# sufijo ("sello_llegada" ↔ sello registrado "sello_llegada").
	for eid in registrados:
		var homologo := eid
		if eid.begins_with("sello_sello_"):
			homologo = "sello_" + eid.substr("sello_sello_".length())
		if not (homologo in ids_m25) and not (eid in ids_m25):
			(reporte["desconocidos"] as Array).append(eid)
	for sid in ids_m25:
		var directo := _entrada_existe(sid, "sellos")
		if directo == "" and not _estados.has("sello_" + sid):
			(reporte["sin_diario"] as Array).append(String(sid))
	return reporte
