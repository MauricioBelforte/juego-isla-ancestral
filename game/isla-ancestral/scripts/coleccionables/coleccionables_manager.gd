# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M73: Coleccionables - ColeccionablesManager (autoload "coleccionables").
# Servicio central de descubrimientos y coleccionables. API idempotente:
# registrar(id) es no-op si ya esta. Emite senales para UI/M55/M72.
# Conecta automaticamente con:
#   - fauna_registry.especie_avistada (M36) -> registra el animal
#   - (futuro) M35 mineria -> registra el mineral
# Persistencia M59 con set de ids collected (compacto).
#
# Pitfalls respetados (07-GUIA-GODOT):
#   - Sin class_name (autoload, seccion 9.17)
#   - snake_case en senales
#   - Duck-typing en M36 fauna_registry
#   - Tolerante a fallos: no rompe si M36 no esta

extends Node

signal item_collected(id_global: StringName, item)
signal categoria_completed(categoria: StringName, recompensa: StringName, cantidad: int)
signal categoria_progress_changed(categoria: StringName, collected: int, total: int)

const CatalogRef = preload("res://scripts/coleccionables/coleccionables_catalog.gd")
const SECCION_SAVE := "coleccionables"
const VERSION := 1

var catalog = null
## Set de StringName (ids globales) ya descubiertos (idempotencia)
var _collected: Dictionary = {}  # StringName -> true
## Cache de categoria -> total esperado (para progreso)
var _categoria_total: Dictionary = {}
## Cache de categoria -> collected count
var _categoria_collected: Dictionary = {}

func _ready() -> void:
	catalog = CatalogRef.new()
	catalog.cargar()
	# Inicializar cache de totales
	for cat in catalog.todas_las_categorias():
		_categoria_total[cat] = catalog.cantidad_por_categoria(cat)
		_categoria_collected[cat] = 0
	print("[M73] ColeccionablesManager ready: %d items, %d categorias" % [catalog.cantidad_total(), _categoria_total.size()])
	# Conectar a M36 fauna_registry (M35 mineria en iter futura)
	_conectar_a_fuentes()

func _conectar_a_fuentes() -> void:
	var fauna_reg := _get_fauna_registry()
	if fauna_reg != null and fauna_reg.has_signal("especie_avistada"):
		fauna_reg.especie_avistada.connect(_on_especie_avistada)
	# M35 mineria: por ahora no conecta directo (no hay senal publica estable);
	# la integracion se hara cuando M35 exponga una senal explicita de mineral extraido.
	# (El consumidor deberia llamar registrar_por_fuente("mineria", "minerales_001") cuando extrae.)

## ── API publica ─────────────────────────────────────────────

## Registra un item por id global. Idempotente.
## Devuelve true si es un descubrimiento nuevo, false si ya estaba.
func registrar(id_global: StringName) -> bool:
	if id_global == &"":
		return false
	if _collected.has(id_global):
		return false  # idempotente
	_collected[id_global] = true
	# Calcular categoria del item
	var it: Resource = null
	if catalog != null:
		it = catalog.obtener(id_global)
	var cat: StringName = id_global.split("_")[0] if id_global.contains("_") else &""
	if it != null:
		cat = it.categoria
	_categoria_collected[cat] = int(_categoria_collected.get(cat, 0)) + 1
	item_collected.emit(id_global, it)
	# Verificar si la categoria se completo
	if _categoria_completa(cat):
		_on_categoria_completa(cat)
	return true

## Registra un item por categoria + id_local. Conveniente para fuentes que no
## conocen el id global.
func registrar_por_local(categoria: StringName, id_local: StringName) -> bool:
	var items: Array = []
	if catalog != null:
		items = catalog.obtener_por_categoria(categoria)
	for item in items:
		if item.id_local == id_local:
			return registrar(item.id_global())
	return false

## Registra un item por id_local + fuente (busca la categoria adecuada segun la fuente).
## Usado por M35 (mineria), M33 (cosecha), M34 (pesca) para registrar sin saber la categoria.
## Si la fuente es "mineria" busca en categoria "minerales", etc.
func registrar_por_fuente(fuente: StringName, id_local: StringName) -> bool:
	if catalog == null:
		return false
	var cat_destino: StringName = _categoria_para_fuente(fuente)
	if cat_destino == &"":
		return false
	return registrar_por_local(cat_destino, id_local)

## Devuelve true si el item esta collected.
func es_collected(id_global: StringName) -> bool:
	return _collected.has(id_global)

## Devuelve el total collected de una categoria.
func collected_count(categoria: StringName) -> int:
	return int(_categoria_collected.get(categoria, 0))

## Devuelve el total esperado de una categoria.
func total_count(categoria: StringName) -> int:
	return int(_categoria_total.get(categoria, 0))

## Porcentaje 0..1 de descubrimiento de una categoria.
func porcentaje_categoria(categoria: StringName) -> float:
	var total: int = total_count(categoria)
	if total <= 0:
		return 0.0
	return float(collected_count(categoria)) / float(total)

## Porcentaje total 0..1 (suma de todas las categorias).
func porcentaje_total() -> float:
	var total: int = 0
	var collected: int = 0
	for cat in _categoria_total.keys():
		total += int(_categoria_total[cat])
		collected += collected_count(cat)
	if total <= 0:
		return 0.0
	return float(collected) / float(total)

## Devuelve el array de ids collected (para UI M55).
func obtener_collected_ids() -> Array:
	return _collected.keys()

## Devuelve el array de categorias (para UI).
func obtener_categorias() -> Array:
	return _categoria_total.keys()

## ── Persistencia M59 ────────────────────────────────────────

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	# Convertir keys StringName a String para JSON
	var collected_s: Dictionary = {}
	for k in _collected.keys():
		collected_s[String(k)] = true
	return {
		"version": VERSION,
		"collected": collected_s,
		"categoria_collected": _categoria_collected.duplicate(),
	}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < VERSION:
		return
	_collected.clear()
	var collected_s: Dictionary = data.get("collected", {})
	for k in collected_s.keys():
		_collected[StringName(k)] = true
	# categoria_collected se recalculara al recargar el catalogo, pero
	# respetamos lo persistido si esta
	var cat_collected: Dictionary = data.get("categoria_collected", {})
	for k in cat_collected.keys():
		_categoria_collected[k] = int(cat_collected[k])

## ── Callbacks internos ──────────────────────────────────────

func _on_especie_avistada(especie_id: StringName, _contexto: Dictionary) -> void:
	# Mapear especie_id (de M36) a id_local de la categoria "animales"
	# Convencion: M36 especie_id como "conejo_pradera" -> coleccionables animales 001
	# Iter 1: hard-coded map; iter 2: propiedad explicita en FaunaSpecies
	var mapa: Dictionary = {
		&"conejo_pradera": &"001",
		&"gaviota_playera": &"002",
		&"nutria_ribera": &"003",
		&"salamandra_ancestral": &"004",
		&"lechuza_bosque": &"003",  # tambien
		&"cangrejo_humedal": &"001",  # marisco
		&"halcon_montana": &"003",
	}
	var id_local: StringName = mapa.get(especie_id, &"")
	if id_local != &"":
		registrar_por_local(&"animales", id_local)

func _on_categoria_completa(categoria: StringName) -> void:
	# Buscar un item de la categoria para obtener su recompensa
	if catalog == null:
		return
	var items: Array = catalog.obtener_por_categoria(categoria)
	if items.is_empty():
		return
	# Usar la recompensa del primer item (consistente con el diseno)
	var it: Resource = items[0]
	if it.recompensa_item != &"":
		# Por ahora solo emitimos la senal. M14/M38 daran el item cuando lo consuman.
		categoria_completed.emit(categoria, it.recompensa_item, it.recompensa_cantidad)

func _categoria_completa(categoria: StringName) -> bool:
	var total: int = total_count(categoria)
	var collected: int = collected_count(categoria)
	return total > 0 and collected >= total

## ── Helpers ────────────────────────────────────────────────

func _categoria_para_fuente(fuente: StringName) -> StringName:
	match fuente:
		&"mineria": return &"minerales"
		&"fauna": return &"animales"
		&"playa": return &"conchas"
		&"ruinas", &"templo": return &"reliquias"
		&"cosecha", &"agricultura": return &"plantas"
		&"pesca": return &"peces"
		_: return &""

func _get_fauna_registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("fauna_registry")
