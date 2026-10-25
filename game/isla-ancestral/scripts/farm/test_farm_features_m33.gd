# Modelo: Step-5-WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-10-25
#
# M33: Features propias — P11 (especiales), P13 (flores), P15 (híbridos),
#      P23 (rareza reproducible + desbloqueo por progresión), P24 (isleños)
#      y L188 (sin procesamiento por frame en estados pausados).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/farm/test_farm_features_m33.gd
# Cobertura: catálogo extendido, flores decorativas, cruce determinista
#            (tabla explícita, sin RNG), rareza con desbloqueo de progresión,
#            ausencia de _process/_physics_process en FarmService (fuente).

extends SceneTree

# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
# (39 en verde, corrida 2026-10-25; piso en rojo por inyección verificado)
const CHECKS_MINIMOS := 39
const _WB_BLOQUES: Array[String] = [
	"_test_catalogo_especiales",
	"_test_flores_decorativas",
	"_test_cruce_determinista",
	"_test_rareza_reproducible",
	"_test_desbloqueo_progresion",
	"_test_sin_procesamiento_frame",
]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _fallos: int = 0

var _farm: Node = null
var _inv: Node = null
var _cal: Node = null

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true

func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M33 features: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_farm = root.get_node_or_null("Farm")
	_inv = root.get_node_or_null("Inventario")
	_cal = root.get_node_or_null("TimeCalendar")
	_check(_farm != null, "Farm autoload presente")
	if _farm == null:
		_summary()
		return
	_test_catalogo_especiales()
	_fin("_test_catalogo_especiales")
	_test_flores_decorativas()
	_fin("_test_flores_decorativas")
	_test_cruce_determinista()
	_fin("_test_cruce_determinista")
	_test_rareza_reproducible()
	_fin("_test_rareza_reproducible")
	_test_desbloqueo_progresion()
	_fin("_test_desbloqueo_progresion")
	_test_sin_procesamiento_frame()
	_fin("_test_sin_procesamiento_frame")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Llevar un cultivo del catálogo a LISTA regando en su estación apta.
func _cultivar(crop_id: StringName, pos: Vector3i, season: int) -> CropTile:
	var def: CropDefinition = _farm.obtener_def(crop_id)
	if def == null:
		return null
	_inv.agregar_items({String(crop_id): 5})
	_farm.till_tile(pos)
	if not _farm.plant(def, pos):
		return null
	var tile: CropTile = _farm.get_tile(pos)
	var d: int = 0
	while tile != null and not tile.is_ready() and d < 20:
		_farm.water(pos)
		tile.apply_daily_tick(season, false)
		d += 1
	return tile

## P11/P13/P24: catálogo extendido con las bandas deterministas.
func _test_catalogo_especiales() -> void:
	_check(_farm.definiciones_count() >= 13, "catálogo con al menos 13 cultivos (%d)" % _farm.definiciones_count())
	var trigo: CropDefinition = _farm.obtener_def(&"trigo_invernal")
	_check(trigo != null, "P11: trigo_invernal en catálogo")
	if trigo != null:
		_check(trigo.seasons == [3], "P11: trigo_invernal solo en invierno (estación 3)")
		_check(trigo.grow_days == 5, "P11: trigo_invernal crece en 5 días")
	var higo: CropDefinition = _farm.obtener_def(&"higo")
	_check(higo != null and higo.is_tree, "P11: higo es perenne (is_tree)")
	var maiz: CropDefinition = _farm.obtener_def(&"maiz_ancestral")
	_check(maiz != null and maiz.is_ancestral, "P11: maiz_ancestral con bandera ancestral (M22)")
	if maiz != null:
		_check(maiz.unlock_min_days == 20, "P11: maiz_ancestral se desbloquea a los 20 días")
	var palma: CropDefinition = _farm.obtener_def(&"palma_coco")
	_check(palma != null and palma.is_tree and palma.island_exclusive, "P24: palma_coco perenne y exclusiva de la isla")
	var coral: CropDefinition = _farm.obtener_def(&"flor_coral")
	_check(coral != null and coral.is_flower and coral.island_exclusive, "P24: flor_coral floral y exclusiva de la isla")
	var lirio: CropDefinition = _farm.obtener_def(&"lirio_estelar")
	_check(lirio != null and lirio.is_flower, "P15: lirio_estelar es flor híbrida")
	if lirio != null:
		_check(lirio.hybrid_of.size() == 2, "P15: lirio_estelar declara sus 2 padres (regla legible)")

## P13: flores decorativas no rinden ítems (decorative_only).
func _test_flores_decorativas() -> void:
	var tulipan: CropDefinition = _farm.obtener_def(&"flor_tulipan")
	var lavanda: CropDefinition = _farm.obtener_def(&"flor_lavanda")
	_check(tulipan != null and tulipan.decorative_only and tulipan.is_flower, "P13: flor_tulipan es decorativa")
	_check(lavanda != null and lavanda.decorative_only and lavanda.is_flower, "P13: flor_lavanda es decorativa")
	if tulipan != null:
		var tile := CropTile.new()
		tile.crop_def = tulipan
		_check(tile.calcular_rendimiento().is_empty(), "P13: flor decorativa no rinde ítems")
	var lirio: CropDefinition = _farm.obtener_def(&"lirio_estelar")
	if lirio != null:
		var tile2 := CropTile.new()
		tile2.crop_def = lirio
		_check(not tile2.calcular_rendimiento().is_empty(), "P15: el híbrido SÍ rinde (no es decorativo)")

## P15: cruce determinista — tabla explícita, sin RNG oculto.
func _test_cruce_determinista() -> void:
	var pos_a := Vector3i(420, 12, 420)
	var pos_b := Vector3i(421, 12, 420)
	var ta: CropTile = _cultivar(&"flor_tulipan", pos_a, 0)   # primavera
	var tb: CropTile = _cultivar(&"flor_lavanda", pos_b, 1)   # verano
	_check(ta != null and ta.is_ready(), "P15: flor_tulipan LISTA para el cruce")
	_check(tb != null and tb.is_ready(), "P15: flor_lavanda LISTA para el cruce")
	if ta == null or tb == null:
		return
	var hibrido: StringName = _farm.cruce_flores(pos_a, pos_b)
	_check(hibrido == &"lirio_estelar", "P15: tulipán + lavanda -> lirio_estelar (%s)" % hibrido)
	_check(_farm.get_tile(pos_a) == null and _farm.get_tile(pos_b) == null, "P15: las flores padres se consumen")
	# Determinismo: mismas entradas -> mismo híbrido (nunca azar)
	var resultados_iguales := true
	var i: int = 0
	while i < 25:
		var pa := Vector3i(430 + i, 12, 430)
		var pb := Vector3i(430 + i, 12, 431)
		var fa: CropTile = _cultivar(&"flor_tulipan", pa, 0)
		var fb: CropTile = _cultivar(&"flor_lavanda", pb, 1)
		if fa == null or fb == null or not fa.is_ready() or not fb.is_ready():
			resultados_iguales = false
			break
		if _farm.cruce_flores(pa, pb) != &"lirio_estelar":
			resultados_iguales = false
		i += 1
	_check(resultados_iguales, "P15: 25 cruces idénticos -> mismo híbrido (sin RNG)")
	# Pares no elegibles: &"" (regla legible, nunca azar)
	var pos_c := Vector3i(450, 12, 450)
	var tc: CropTile = _cultivar(&"flor_tulipan", pos_c, 0)
	var pos_d := Vector3i(451, 12, 450)
	var td: CropTile = _cultivar(&"flor_tulipan", pos_d, 0)
	_check(tc != null and td != null and tc.is_ready() and td.is_ready(), "P15: dos tulipanes LISTOS para par no elegible")
	if tc != null and td != null:
		_check(_farm.cruce_flores(pos_c, pos_d) == &"", "P15: misma flor dos veces -> sin cruce")
	var pos_e := Vector3i(460, 12, 460)
	var te: CropTile = _cultivar(&"tomate", pos_e, 1)  # verano
	_check(te != null and te.is_ready(), "P15: tomate LISTO para par no elegible")
	if te != null and tc != null:
		_check(_farm.cruce_flores(pos_e, pos_c) == &"", "P15: no-flor + flor -> sin cruce")

## P23: rareza reproducible — la cosecha devuelve semillas (x2).
func _test_rareza_reproducible() -> void:
	var def: CropDefinition = _farm.obtener_def(&"trigo_estelar")
	_check(def != null and def.rare, "P23: trigo_estelar es raro")
	if def == null:
		return
	_check(def.unlock_min_days == 30, "P23: trigo_estelar se desbloquea a los 30 días")
	_check(def.yield_seed_amount == 2, "P23: reproducible (2 semillas por cosecha)")
	var tile := CropTile.new()
	tile.crop_def = def
	var rendimiento: Array = tile.calcular_rendimiento()
	var semillas := 0
	for e in rendimiento:
		if String(e["item_id"]) == "trigo_estelar":
			semillas = int(e["cantidad"])
	_check(semillas == 2, "P23: la cosecha del raro devuelve 2 semillas (%d)" % semillas)

## P23/P11: desbloqueo por progresión — plantar sin días NO consume semilla.
func _test_desbloqueo_progresion() -> void:
	var dia_hoy: int = 0
	if _cal != null and _cal.has_method("get_dia_absoluto"):
		dia_hoy = int(_cal.get_dia_absoluto())
	# Bloqueado: maiz_ancestral (unlock 20) con el día actual de headless
	var pos := Vector3i(470, 12, 470)
	_inv.agregar_items({"maiz_ancestral": 1})
	_farm.till_tile(pos)
	var ok_bloqueado: bool = _farm.plant(_farm.obtener_def(&"maiz_ancestral"), pos)
	_check(not ok_bloqueado, "P23: cultivo con desbloqueo pendiente no se planta (día %d < 20)" % dia_hoy)
	if _inv.has_method("count_item"):
		_check(int(_inv.count_item("maiz_ancestral")) == 1, "P23: la semilla NO se consume si el desbloqueo falla")
	_check(_farm.get_tile(pos) == null, "P23: no queda tile tras el plant fallido")
	# Desbloqueado: def custom con umbral <= día actual
	var def_libre := CropDefinition.new()
	def_libre.crop_id = &"cultivo_prueba_libre"
	def_libre.grow_days = 2
	def_libre.unlock_min_days = dia_hoy
	_check(_farm.puede_desbloquear(def_libre), "P23: umbral == día actual queda desbloqueado")
	_inv.agregar_items({"cultivo_prueba_libre": 1})
	var pos2 := Vector3i(471, 12, 470)
	_farm.till_tile(pos2)
	var ok_libre: bool = _farm.plant(def_libre, pos2)
	_check(ok_libre, "P23: cultivo desbloqueado se planta")
	_check(_farm.get_tile(pos2) != null, "P23: tile creado para el cultivo desbloqueado")

## L188: sin procesamiento por frame en FarmService (ni en pausa ni activo).
## Guardia de FUENTE: se eliminan comentarios antes de buscar (una guardia
## que lee el fuente también lee sus comentarios — trampa documentada).
func _test_sin_procesamiento_frame() -> void:
	var f := FileAccess.open("res://scripts/farm/farm_service.gd", FileAccess.READ)
	_check(f != null, "L188: se pudo leer farm_service.gd")
	if f == null:
		return
	var src: String = f.get_as_text()
	var codigo := _solo_codigo(src)
	_check(codigo.find("func _process(") == -1, "L188: FarmService no define _process")
	_check(codigo.find("func _physics_process(") == -1, "L188: FarmService no define _physics_process")
	_check(codigo.find("set_process(") == -1, "L188: FarmService no activa procesamiento por frame")

## Elimina comentarios respetando cadenas (no romper \"#RRGGBB\" ni escapes).
func _solo_codigo(src: String) -> String:
	var out := ""
	var en_cadena := false
	var i := 0
	while i < src.length():
		var c := src[i]
		if en_cadena:
			out += c
			if c == "\\":
				if i + 1 < src.length():
					out += src[i + 1]
					i += 2
					continue
			elif c == "\"":
				en_cadena = false
			i += 1
			continue
		if c == "\"":
			en_cadena = true
			out += c
			i += 1
			continue
		if c == "#":
			while i < src.length() and src[i] != "\n":
				i += 1
			continue
		out += c
		i += 1
	return out
