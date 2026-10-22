# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M16: Crafting — CraftingService (autoload "Crafting").
# Registro global de recetas (data-driven desde M93 crafting.json), conocimiento
# (RF4), fabricación instantánea 1x/N (RF6/RF7/RF8), experimentación sin consumo
# (invariante §1.3.2) y persistencia (RF17/M59).
# Regla RF11: los materiales SOLO se consumen si la receta completa está disponible
# y la entrega del resultado está garantizada (remover/agregar todo-o-nada en M14).
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).

extends Node

signal receta_descubierta(recipe: CraftingRecipe)
signal receta_aprendida(recipe: CraftingRecipe)
signal crafting_completed(recipe: CraftingRecipe, cantidad: int)
signal crafting_failed(recipe: CraftingRecipe, motivo: String)
signal experimento_fallido(estacion: int)
signal pergamino_consumido(rec_id: String, aprendido: bool)  # false = ya conocida, no consume
signal receta_bloqueada_estacion(rec_id: String)  # RF5: conocida pero fuera de temporada
# RF-MR6 (N.1): señales de mejora/reparación — solo en éxito.
signal herramienta_mejorada(item_id: String, nivel: int)
signal herramienta_reparada(item_id: String, durabilidad: int)

const SECCION_SAVE := "crafting"

var _recetas: Dictionary = {}      # id -> CraftingRecipe
var _conocidas: Array = []         # ids de recetas conocidas (persistente)
var _experimentos_fallidos: int = 0
var _gt: Node = null
var _estacion_actual: int = 0
var _estacion_cache_valida: bool = false

var _cache_iconos: Dictionary = {}  # M16 item [20]: pool ligero icono de recetas (item_id -> Texture2D)

## RF-MR (N.1): mejora/reparación de herramientas. Schema data-driven desde
## data/crafting/mejora_herramienta.json (tabla por tipo + curvas de balance).
var _mejora_cfg: Dictionary = {}
## RF-MR7: nivel de mejora por item_id (persistencia aditiva en M59).
var _niveles_mejora: Dictionary = {}

## false = instancia de test: no registra provider (evita colisión de sección
## "crafting" con el autoload del boot). Setear ANTES de add_child.
var registra_en_save: bool = true


func _ready() -> void:
	_gt = get_node_or_null("/root/GameTime")
	if _gt != null and _gt.has_signal("estacion_cambio"):
		_gt.estacion_cambio.connect(_on_estacion_cambio)
	# M16 RF17 (glm-5.3-flash, iter. 5): M14 emite item_usado para pergaminos →
	# flujo completo: usar item → aprender receta → consumir pergamino.
	var inv := get_node_or_null("/root/Inventario")
	if inv != null and inv.has_signal("item_usado"):
		inv.item_usado.connect(_on_item_usado)
		print("[M16] RF17: use_item de M14 conectado (pergaminos)")
	_refrescar_estacion_actual()
	_cargar_recetas()
	_cargar_mejora_cfg()
	if registra_en_save:
		_registrar_proveedor_guardado()
	# Feedback procedural (SFX/VFX) como hijo del servicio (autoload)
	var fb_script := load("res://scripts/crafting/crafting_feedback.gd")
	if fb_script != null:
		var fb = fb_script.new()
		fb.name = "CraftingFeedback"
		add_child(fb)

func _on_estacion_cambio(est: int) -> void:
	_estacion_actual = est
	_estacion_cache_valida = true

func _refrescar_estacion_actual() -> void:
	# Lee de M29 (fuente de verdad). Desde el item 4 del plan, SOLO lo invocan el
	# arranque y los paths de ENFORCEMENT (craft / max_craftable / get_estacion_actual):
	# el FILTRO de recetas usa la cache mantenida por la señal estacion_cambio
	# (cero re-lecturas por consulta). La re-lectura se conserva aquí para
	# soportar tests/manipulación directa de GameTime._mes (correctness).
	if _gt != null and _gt.has_method("get_estacion"):
		_estacion_actual = int(_gt.get_estacion())
		_estacion_cache_valida = true

## ── Carga data-driven (M93 crafting.json) ───────────────

func _cargar_recetas() -> void:
	var bal = get_node_or_null("/root/Balance")
	if bal == null or not bal.has_method("get_crafting"):
		push_warning("[M16] BalanceService no disponible; sin recetas")
		return
	var recetas: Dictionary = bal.get_crafting().get("recetas", {})
	for rec_id in recetas:
		var datos: Dictionary = recetas[rec_id]
		var receta := _recipe_desde_datos(str(rec_id), datos)
		if receta != null:
			_recetas[receta.id] = receta
	# Recetas iniciales: conocidas de base
	for rec_id in recetas:
		if str(recetas[rec_id].get("origen", "")) == "inicial":
			_conocer(str(rec_id), false)
	_precargar_iconos()

func _recipe_desde_datos(rec_id: String, datos: Dictionary) -> CraftingRecipe:
	var receta := CraftingRecipe.new()
	receta.id = rec_id
	receta.nombre = str(datos.get("nombre", rec_id))
	receta.categoria = CraftingRecipe.CATEGORIAS_TEXTO.get(str(datos.get("categoria", "estructura")), CraftingRecipe.Categoria.ESTRUCTURA)
	receta.nivel = int(datos.get("nivel", 1))
	receta.estacion = CraftingRecipe.ESTACIONES_TEXTO.get(str(datos.get("estacion", "mesa_trabajo")), CraftingRecipe.Estacion.MESA_TRABAJO)
	receta.materiales = datos.get("coste_recursos", {}).duplicate()
	receta.coste_ao = int(datos.get("coste_ao", 0))
	receta.resultado_id = str(datos.get("resultado", ""))
	receta.resultado_cantidad = int(datos.get("resultado_cantidad", 1))
	receta.origen = CraftingRecipe.ORIGENES_TEXTO.get(str(datos.get("origen", "inicial")), CraftingRecipe.Origen.INICIAL)
	receta.precio_pergamino = int(datos.get("precio_pergamino", 0))
	var tags: Array = datos.get("tags", [])
	for t in tags:
		receta.tags.append(str(t))
	# RF5: temporadas (vacío = siempre; ["primavera","verano"] = solo esas)
	var temps: Array = datos.get("temporadas", [])
	for t in temps:
		receta.temporadas.append(str(t))
	return receta

## ── Consulta ─────────────────────────────────────────────

func obtener_receta(rec_id: String) -> CraftingRecipe:
	return _recetas.get(rec_id, null)

func recetas_por_estacion(estacion: int) -> Array:
	var out: Array = []
	# M16 item 4: el FILTRO usa la estación cacheada que mantiene `estacion_cambio`
	# (recalculo SOLO ante la señal — cero re-lecturas de GameTime por consulta).
	# Los enforcement (craft / max_craftable) conservan su re-lectura propia.
	for receta in _recetas.values():
		if receta.estacion != estacion:
			continue
		if receta.id not in _conocidas:
			continue
		# RF5: filtrar por temporada actual
		if not receta.es_fabricable_ahora(_estacion_actual):
			continue
		out.append(receta)
	return out

## Devuelve TODAS las recetas conocidas de la estación, incluyendo las fuera de
## temporada (RF5: temporada cerrada oculta pero no borra conocimiento).
func recetas_conocidas_estacion(estacion: int) -> Array:
	var out: Array = []
	for receta in _recetas.values():
		if receta.estacion == estacion and receta.id in _conocidas:
			out.append(receta)
	return out

## Devuelve la receta si está conocida pero bloqueada por temporada (RF5).
func receta_bloqueada(rec_id: String) -> bool:
	var r: CraftingRecipe = _recetas.get(rec_id, null)
	if r == null or rec_id not in _conocidas:
		return false
	return not r.es_fabricable_ahora(_estacion_actual)

func recetas_conocidas() -> Array:
	return _conocidas.duplicate()

func es_conocida(rec_id: String) -> bool:
	return rec_id in _conocidas

## ── Conocimiento (RF4) ───────────────────────────────────

## Conoce una receta. `emitir` controla si se emite señal (carga inicial no emite).
func _conocer(rec_id: String, emitir: bool = true) -> void:
	if rec_id in _conocidas:
		return
	_conocidas.append(rec_id)
	if emitir:
		var receta: CraftingRecipe = _recetas.get(rec_id, null)
		if receta:
			if receta.origen == CraftingRecipe.Origen.EXPERIMENTACION:
				receta_descubierta.emit(receta)
			else:
				receta_aprendida.emit(receta)

## Aprende una receta desde pergamino (flujo 2.3): no consume si ya se conoce.
func aprender_desde_pergamino(rec_id: String) -> bool:
	var receta: CraftingRecipe = _recetas.get(rec_id, null)
	if receta == null:
		pergamino_consumido.emit(rec_id, false)
		return false
	if es_conocida(rec_id):
		pergamino_consumido.emit(rec_id, false)  # ya conocida: NO consume el pergamino (honesto)
		return false
	_conocer(rec_id)
	pergamino_consumido.emit(rec_id, true)
	return true

## Helper M14: usa un item de tipo "pergamino_rec_<rec_id>" desde el inventario.
## Convención: "pergamino_rec_tela_lino" → strip "pergamino_" → "rec_tela_lino"
## (glm-5.3-flash FIX: el prefijo anterior "pergamino_rec_" recortaba el "rec_"
## del rec_id y la receta nunca se encontraba). Devuelve { aprendido, rec_id }.
## NO descuenta el item del inventario; eso lo hace M14 al recibir el evento use_item.
func usar_pergamino(item_id: String) -> Dictionary:
	var id_limpio: String = str(item_id).strip_edges()
	const PREFIJO := "pergamino_"
	if not id_limpio.begins_with(PREFIJO):
		pergamino_consumido.emit(id_limpio, false)
		return {"aprendido": false, "rec_id": ""}
	var rec_id: String = id_limpio.substr(PREFIJO.length())
	var ok: bool = aprender_desde_pergamino(rec_id)
	return {"aprendido": ok, "rec_id": rec_id}

## RF17 (glm-5.3-flash): handler de item_usado de M14 — flujo completo.
## Un pergamino usado aprende la receta y se retira del inventario (consume).
## Si la receta ya se conoce, el pergamino NO se retira (honesto, cozy).
func _on_item_usado(item_id: String, _contexto: String) -> void:
	if not str(item_id).begins_with("pergamino_rec_"):
		return
	var inv := get_node_or_null("/root/Inventario")
	var res := usar_pergamino(item_id)
	if bool(res.get("aprendido", false)) and inv != null:
		inv.remover_items({item_id: 1})

## ── Validación y fabricación (RF6/RF7/RF8/RF11) ─────────

## Calcula cuántas unidades puede fabricar con los materiales actuales (RF8).
## RF5: devuelve 0 si la receta está fuera de temporada.
func max_craftable(rec_id: String) -> int:
	var receta: CraftingRecipe = _recetas.get(rec_id, null)
	if receta == null:
		return 0
	_refrescar_estacion_actual()
	if not receta.es_fabricable_ahora(_estacion_actual):
		return 0
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return 0
	# D8 (decisión de dueño, G-5.3-Flash-Agente 2026-10-21): tope QoL de lote por craft.
	# Evita accidentes de UI de múltiple-craft masivos (clamps el resultado a 30 máximo).
	var max_n: int = 9999
	for item_id in receta.materiales:
		var necesario: int = int(receta.materiales[item_id])
		var disponible: int = int(inv.count_item(str(item_id), true))
		if disponible < necesario:
			return 0
		max_n = mini(max_n, int(disponible / maxf(float(necesario), 1.0)))
	return maxi(0, mini(max_n, 30))

## ¿Se puede fabricar 1 unidad?
func puede_craft(rec_id: String) -> bool:
	return max_craftable(rec_id) >= 1

## Estacion actual cacheada (M29).
func get_estacion_actual() -> int:
	_refrescar_estacion_actual()
	return _estacion_actual

## Fabrica `cantidad` unidades (RF7/RF8). Instantáneo (RF6).
## RF11: consume SOLO si todo puede completarse; si el resultado no entra,
## hace rollback completo (no se pierde material).
## RF5: si la receta está fuera de temporada, falla sin consumir.

## K.5 (plan): buffer reutilizado para el hot path de fabricación — evita una
## asignación de Dictionary por cada craft (M14 iterá el dict sincrónicamente,
## no retiene la referencia; verificado en inventario_service.remover_items).
var _materiales_total: Dictionary = {}

func craft(rec_id: String, cantidad: int = 1) -> bool:

	var receta: CraftingRecipe = _recetas.get(rec_id, null)
	if receta == null or cantidad < 1:
		crafting_failed.emit(receta, "receta_invalida")
		return false
	if not es_conocida(rec_id):
		crafting_failed.emit(receta, "receta_desconocida")
		return false
	# RF5: temporada cerrada -> oculta, no consume
	_refrescar_estacion_actual()
	if not receta.es_fabricable_ahora(_estacion_actual):
		receta_bloqueada_estacion.emit(rec_id)
		crafting_failed.emit(receta, "temporada_cerrada")
		return false
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		crafting_failed.emit(receta, "sin_inventario")
		return false
	# Consumo de coste_ao (M38) si corresponde
	if receta.coste_ao > 0:
		var eco = get_node_or_null("/root/EconomyManager")
		if eco == null or not eco.has_method("retirar_monedas"):
			crafting_failed.emit(receta, "sin_economia")
			return false
		if not eco.puede_pagar(receta.coste_ao * cantidad) or not eco.retirar_monedas(receta.coste_ao * cantidad):
			crafting_failed.emit(receta, "ao_insuficiente")
			return false
	# Consumo de materiales (todo-o-nada por unidad, multiplicado)
	# K.5: buffer reutilizado (sin asignación nueva por llamada).
	_materiales_total.clear()
	for item_id in receta.materiales:
		_materiales_total[str(item_id)] = int(receta.materiales[item_id]) * cantidad
	if not inv.remover_items(_materiales_total):
		crafting_failed.emit(receta, "materiales_insuficientes")
		return false
	# Entrega del resultado (con fallback bolsa->casa en M14)
	var sobrante: int = inv.add_item(receta.resultado_id, receta.resultado_cantidad * cantidad)
	if sobrante > 0:
		# ROLLBACK completo (invariante §1.3.3): reembolsar materiales
		inv.agregar_items(_materiales_total)
		crafting_failed.emit(receta, "inventario_lleno")
		return false
	crafting_completed.emit(receta, cantidad)
	return true

## ── Experimentación (invariante §1.3.2: nunca consume) ───

## Busca una receta de experimentación que coincida con la combinación
## (Diccionario item_id → cantidad 1) en la estación dada.
func experimentar(estacion: int, combinacion: Dictionary) -> CraftingRecipe:
	var claves := combinacion.keys()
	claves.sort()
	for receta in _recetas.values():
		if receta.origen != CraftingRecipe.Origen.EXPERIMENTACION:
			continue
		if receta.estacion != estacion:
			continue
		if es_conocida(receta.id):
			continue
		var claves_receta: Array = receta.materiales.keys()
		claves_receta.sort()
		if str(claves_receta) == str(claves):
			# Comparar cantidades también (todas 1 en experimentación)
			var coincide := true
			for item_id in receta.materiales:
				if int(combinacion.get(item_id, 0)) != int(receta.materiales[item_id]):
					coincide = false
					break
			if coincide:
				_conocer(receta.id)
				return receta
	experimento_fallido.emit(estacion)
	_experimentos_fallidos += 1
	return null

## ── RF-MR: mejora y reparación de herramientas (N.1) ─────

## RF-MR3: carga el schema data/crafting/mejora_herramienta.json (data-driven).
func _cargar_mejora_cfg() -> void:
	var ruta := "res://data/crafting/mejora_herramienta.json"
	if not FileAccess.file_exists(ruta):
		push_warning("[M16] MR3: schema de mejora de herramientas ausente")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parsed) == TYPE_DICTIONARY:
		_mejora_cfg = parsed

## Tipo de herramienta ('hacha'/'martillo'/'azada'/'machete') desde el id del
## item (convención de prefijo; M13 define la marca definitiva — MR10 pendiente).
func _tipo_de(item_id: String) -> String:
	for tipo in _mejora_cfg.get("tipos", {}):
		if String(item_id).begins_with(String(tipo) + "_"):
			return String(tipo)
	return ""

## RF-MR4: durabilidad máxima por tipo y nivel (curva aditiva).
func durabilidad_maxima(tipo: String, nivel: int) -> int:
	var base: int = int(_mejora_cfg.get("duracion_base", {}).get(tipo, 0))
	var pasos: int = int(_mejora_cfg.get("duracion_por_nivel", 0))
	return base + pasos * maxi(0, nivel)

## RF-MR4: factor de efectividad por tipo y nivel (M13 escala con esto, MR15).
func efectividad(tipo: String, nivel: int) -> float:
	var paso: float = float(_mejora_cfg.get("efectividad_por_nivel", 0.15))
	return 1.0 + paso * maxi(0, nivel)

func _nivel_de(item_id: String) -> int:
	return int(_niveles_mejora.get(item_id, 0))

## RF-MR1: mejorar una herramienta un nivel (consume materiales, retorno honesto).
func mejorar_herramienta(item_id: String) -> Dictionary:
	var tipo := _tipo_de(item_id)
	if tipo == "" or not _mejora_cfg.get("tipos", {}).has(tipo):
		return {"ok": false, "motivo": "no_es_herramienta", "nivel_anterior": -1, "nivel_nuevo": -1}
	var nivel_anterior := _nivel_de(item_id)
	var cfg: Dictionary = _mejora_cfg["tipos"][tipo]
	if nivel_anterior >= int(cfg.get("nivel_maximo", 0)):
		return {"ok": false, "motivo": "nivel_maximo", "nivel_anterior": nivel_anterior, "nivel_nuevo": nivel_anterior}
	var costes: Array = cfg.get("coste_nivel", [])
	var idx := nivel_anterior
	if idx < 0 or idx >= costes.size():
		return {"ok": false, "motivo": "coste_ausente", "nivel_anterior": nivel_anterior, "nivel_nuevo": nivel_anterior}
	var coste: Dictionary = costes[idx]
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return {"ok": false, "motivo": "sin_inventario", "nivel_anterior": nivel_anterior, "nivel_nuevo": nivel_anterior}
	# RF-MR5: consumo todo-o-nada vía InventoryService (sin consumo parcial).
	if not inv.remover_items(coste):
		return {"ok": false, "motivo": "materiales_insuficientes", "nivel_anterior": nivel_anterior, "nivel_nuevo": nivel_anterior}
	var nivel_nuevo := nivel_anterior + 1
	_niveles_mejora[item_id] = nivel_nuevo
	herramienta_mejorada.emit(item_id, nivel_nuevo)  # RF-MR6, solo en éxito
	return {"ok": true, "motivo": "", "nivel_anterior": nivel_anterior, "nivel_nuevo": nivel_nuevo}

## RF-MR2: reparar restaurando la durabilidad objetivo al máximo del nivel actual.
## El estado de durabilidad actual lo aplica M13 (techo MR16); aquí se valida,
## se consume el coste de reparación y se emite la durabilidad objetivo.
func reparar_herramienta(item_id: String) -> Dictionary:
	var tipo := _tipo_de(item_id)
	if tipo == "" or not _mejora_cfg.get("tipos", {}).has(tipo):
		return {"ok": false, "motivo": "no_es_herramienta"}
	var cfg: Dictionary = _mejora_cfg["tipos"][tipo]
	var coste: Dictionary = cfg.get("coste_reparacion", {})
	var inv = get_node_or_null("/root/Inventario")
	if inv == null or coste.is_empty():
		return {"ok": false, "motivo": "sin_inventario"}
	if not inv.remover_items(coste):
		return {"ok": false, "motivo": "materiales_insuficientes"}
	var durabilidad: int = durabilidad_maxima(tipo, _nivel_de(item_id))
	herramienta_reparada.emit(item_id, durabilidad)  # RF-MR6, solo en éxito
	return {"ok": true, "motivo": "", "_durabilidad": durabilidad}

## ── Persistencia (RF17 / M59) ────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {"recetas_conocidas": _conocidas.duplicate(), "niveles_mejora": _niveles_mejora.duplicate()}

func restore_save_data(data: Dictionary) -> void:
	_conocidas.clear()
	for rec_id in data.get("recetas_conocidas", []):
		_conocidas.append(str(rec_id))
	# RF-MR7: campo ADITIVO — saves viejos sin 'niveles_mejora' no se rompen.
	var niveles: Variant = data.get("niveles_mejora", {})
	if typeof(niveles) == TYPE_DICTIONARY:
		_niveles_mejora = niveles.duplicate()

## M16 item [20]: pool ligero de iconos de recetas. Key = rec_id; el icono
## proviene del ITEM resultado (ItemData.icono vía ItemDatabase, M159).
## El cache guarda también null (evita re-buscar items sin icono).
func _precargar_iconos() -> void:
	var db := get_node_or_null("/root/ItemDatabase")
	if db == null or not db.has_method("get_item"):
		return
	for rec_id in _recetas:
		if _cache_iconos.has(rec_id):
			continue
		var rec: CraftingRecipe = _recetas[rec_id]
		var item = db.get_item(String(rec.resultado_id))
		_cache_iconos[rec_id] = item.icono if item != null else null


func icono_de_receta(rec_id: String) -> Texture2D:
	if not _cache_iconos.has(rec_id):
		_precargar_iconos()
	return _cache_iconos.get(rec_id, null)
