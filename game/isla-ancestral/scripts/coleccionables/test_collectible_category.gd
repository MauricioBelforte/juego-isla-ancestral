# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M73: Test de CollectibleCategory (resource de metadatos de categoría).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/coleccionables/test_collectible_category.gd

extends SceneTree

var _fallos: int = 0
var _cat: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_cat = root.get_node_or_null("coleccionables")
	_check(_cat != null, "ColeccionablesManager autoload presente")
	if _cat == null:
		print("=== TEST M73 COLLECTIBLE_CATEGORY: 1+ fallo(s) ===")
		quit(1)
		return
	_test_constructor()
	_test_static_cargar_desde_json()
	_test_static_crear_catalogo_fallback()
	_test_metodos_instancia()
	print("=== TEST M73 COLLECTIBLE_CATEGORY: " + str(_fallos) + " fallo(s) ===")
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_constructor() -> void:
	# Instanciar sin parámetros → valores por defecto
	var cat := CollectibleCategory.new()
	_check(cat.id == &"", "constructor: id vacío por defecto")
	_check(cat.total_esperado == 0, "constructor: total_esperado = 0")
	_check(cat.orden_exposicion == 0, "constructor: orden_exposicion = 0")
	_check(cat.tags.is_empty(), "constructor: tags vacío")
	cat.free()


func _test_static_cargar_desde_json() -> void:
	var datos := {
		"categorias": [
			{
				"id": "animales",
				"nombre_es": "Animales",
				"descripcion": "Especies avistadas",
				"total_esperado": 4,
				"recompensa_item": "moneda_ancestral",
				"recompensa_cantidad": 300,
				"orden_exposicion": 2,
				"tags": ["fauna", "naturaleza"],
			},
		],
	}
	var cats := CollectibleCategory.cargar_desde_json(datos)
	_check(cats is Array, "cargar_desde_json retorna Array")
	_check(cats.size() == 1, "cargar_desde_json: 1 categoría parseada (%d)" % cats.size())
	if cats.size() > 0:
		var c := cats[0]
		_check(c.id == &"animales", "cargar_desde_json: id correcto")
		_check(c.nombre_es == "Animales", "cargar_desde_json: nombre_es correcto")
		_check(c.total_esperado == 4, "cargar_desde_json: total_esperado = 4")
		_check(c.recompensa_cantidad == 300, "cargar_desde_json: recompensa_cantidad = 300")
		_check(c.tags.size() == 2, "cargar_desde_json: 2 tags (%d)" % c.tags.size())


func _test_static_crear_catalogo_fallback() -> void:
	var datos := CollectibleCategory.crear_catalogo_fallback()
	_check(datos.has("categorias"), "crear_catalogo_fallback tiene key 'categorias'")
	var cats := CollectibleCategory.cargar_desde_json(datos)
	_check(cats.size() >= 4, "crear_catalogo_fallback: al menos 4 categorías (%d)" % cats.size())
	# Verificar que minerales existe
	var ids := []
	for c in cats:
		ids.append(String(c.id))
	_check(ids.has("minerales"), "fallback incluye 'minerales'")
	_check(ids.has("animales"), "fallback incluye 'animales'")
	_check(ids.has("reliquias"), "fallback incluye 'reliquias'")


func _test_metodos_instancia() -> void:
	var cat := CollectibleCategory.new()
	cat.id = &"minerales"
	cat.total_esperado = 5

	# esta_completa
	_check(not cat.esta_completa(3), "esta_completa(3) = false cuando total=5")
	_check(cat.esta_completa(5), "esta_completa(5) = true cuando total=5")
	_check(cat.esta_completa(10), "esta_completa(10) = true si collected > total")

	# total_esperado=0 → nunca completa (infinito/dinámico)
	cat.total_esperado = 0
	_check(not cat.esta_completa(999), "esta_completa con total=0 siempre false")

	# progreso
	_check(absf(cat.progreso(0) - 0.0) < 0.001, "progreso(0) = 0")
	cat.total_esperado = 5
	_check(absf(cat.progreso(3) - 0.6) < 0.001, "progreso(3) con total=5 = 0.6")
	_check(absf(cat.progreso(5) - 1.0) < 0.001, "progreso(5) con total=5 = 1.0")

	# to_dict
	var d := cat.to_dict()
	_check(d.has("id"), "to_dict tiene key 'id'")
	_check(d.has("total_esperado"), "to_dict tiene key 'total_esperado'")
	_check(String(d["id"]) == "minerales", "to_dict: id correcto")
	_check(int(d["total_esperado"]) == 5, "to_dict: total_esperado correcto")

	cat.free()
