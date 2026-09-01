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
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

signal receta_descubierta(recipe: CraftingRecipe)
signal receta_aprendida(recipe: CraftingRecipe)
signal crafting_completed(recipe: CraftingRecipe, cantidad: int)
signal crafting_failed(recipe: CraftingRecipe, motivo: String)
signal experimento_fallido(estacion: int)
signal pergamino_consumido(rec_id: String, aprendido: bool)  # false = ya conocida, no consume
signal receta_bloqueada_estacion(rec_id: String)  # RF5: conocida pero fuera de temporada

const SECCION_SAVE := "crafting"

var _recetas: Dictionary = {}      # id -> CraftingRecipe
var _conocidas: Array = []         # ids de recetas conocidas (persistente)
var _experimentos_fallidos: int = 0
var _gt: Node = null
var _estacion_actual: int = 0
var _estacion_cache_valida: bool = false

func _ready() -> void:
	_gt = get_node_or_null("/root/GameTime")
	if _gt != null and _gt.has_signal("estacion_cambio"):
		_gt.estacion_cambio.connect(_on_estacion_cambio)
	_refrescar_estacion_actual()
	_cargar_recetas()
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
	# Lee siempre de M29 (fuente de verdad). La señal estacion_cambio mantiene
	# el cache caliente, pero cada consulta re-lee para soportar tests/manipulación
	# directa de GameTime._mes y para correctness ante cualquier cambio externo.
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
	_refrescar_estacion_actual()
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
## Convención de nombre del item: "pergamino_rec_tela_lino" -> rec_id "rec_tela_lino".
## Devuelve { aprendido: bool, rec_id: String }. NO descuenta el item del inventario;
## eso lo hace M14 al recibir el evento use_item.
func usar_pergamino(item_id: String) -> Dictionary:
	var id_limpio: String = str(item_id).strip_edges()
	const PREFIJO := "pergamino_rec_"
	if not id_limpio.begins_with(PREFIJO):
		pergamino_consumido.emit(id_limpio, false)
		return {"aprendido": false, "rec_id": ""}
	var rec_id: String = id_limpio.substr(PREFIJO.length())
	var ok: bool = aprender_desde_pergamino(rec_id)
	return {"aprendido": ok, "rec_id": rec_id}

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
	var max_n: int = 9999
	for item_id in receta.materiales:
		var necesario: int = int(receta.materiales[item_id])
		var disponible: int = int(inv.count_item(str(item_id), true))
		if disponible < necesario:
			return 0
		max_n = mini(max_n, int(disponible / maxf(float(necesario), 1.0)))
	return maxi(0, max_n)

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
	var materiales_total: Dictionary = {}
	for item_id in receta.materiales:
		materiales_total[str(item_id)] = int(receta.materiales[item_id]) * cantidad
	if not inv.remover_items(materiales_total):
		crafting_failed.emit(receta, "materiales_insuficientes")
		return false
	# Entrega del resultado (con fallback bolsa->casa en M14)
	var sobrante: int = inv.add_item(receta.resultado_id, receta.resultado_cantidad * cantidad)
	if sobrante > 0:
		# ROLLBACK completo (invariante §1.3.3): reembolsar materiales
		inv.agregar_items(materiales_total)
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

## ── Persistencia (RF17 / M59) ────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {"recetas_conocidas": _conocidas.duplicate()}

func restore_save_data(data: Dictionary) -> void:
	_conocidas.clear()
	for rec_id in data.get("recetas_conocidas", []):
		_conocidas.append(str(rec_id))
