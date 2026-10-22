# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M33: QA de pausas del ciclo del cultivo + P25 decorativos (turno 2-BIS).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/farm/qa_farm_pausas_m33.gd
# Cobertura (items [S] del 05-Checklist):
#   1. "Cultivo en DORMANTE al pasar a estacion apta: retoma sin perdida"
#      - datos medibles: grown_days confluye desde donde quedo (no reinicia),
#        prev_stage preservado, doble pausa DORMANTE->SIN_AGUA->retoma.
#   2. "Sequia prolongada: pausa indefinida sin muerte"
#      - 45 ticks sin agua: SIN_AGUA estable, dias congelados, tile vivo,
#        calidad COMUN (A7), riego reanuda.
#   3. "P25: agricultura decorativa — helecho ornamental sin rendimiento"
#      - decorative_only=true -> calcular_rendimiento() devuelve [] siempre.
#   4. "Arbol frutal en invierno: entra en DORMANTE y conserva cooldown"
#      - is_tree con fruit_cooldown: estacion no apta -> DORMANTE con
#        cooldown INTACTO; estacion apta -> retoma y cuenta dias de fruta.

extends SceneTree

const CHECKS_MINIMOS := 17
const _WB_BLOQUES: Array[String] = ["_test_dormante_retoma", "_test_doble_pausa", "_test_sequia_sin_muerte", "_test_decorative_only", "_test_arbol_invierno"]
var _checks: int = 0
var _fallos: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _farm: Node = null

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
	print("=== Resumen QA pausas M33: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _run() -> void:
	_farm = root.get_node_or_null("Farm")
	_check(_farm != null, "Farm autoload presente")
	if _farm == null:
		return
	_test_dormante_retoma()
	_wb_vistos["_test_dormante_retoma"] = true
	_test_doble_pausa()
	_wb_vistos["_test_doble_pausa"] = true
	_test_sequia_sin_muerte()
	_wb_vistos["_test_sequia_sin_muerte"] = true
	_test_decorative_only()
	_wb_vistos["_test_decorative_only"] = true
	_test_arbol_invierno()
	_wb_vistos["_test_arbol_invierno"] = true

## 1. DORMANTE retoma sin perdida (datos medibles sobre grown_days).
func _test_dormante_retoma() -> void:
	var pos := Vector3i(310, 12, 310)
	root.get_node("/root/Inventario").agregar_items({"calabaza": 5})
	_farm.till_tile(pos)
	_farm.plant(_farm.obtener_def(&"calabaza"), pos)  # solo otonio (2)
	var tile: CropTile = _farm.get_tile(pos)
	_check(tile != null, "retoma: tile sembrado")
	if tile == null:
		return
	# Dia 1: otonio apto, con agua -> crece 1 dia
	_farm.water(pos)
	tile.apply_daily_tick(2, false)
	var dias_base := tile.grown_days
	_check(dias_base >= 1, "retoma: crece en estacion apta (%d dias)" % dias_base)
	_check(tile.prev_stage == tile.stage, "retoma: prev_stage espejo fuera de pausa")
	# Invierno (3): no apta -> DORMANTE conservando dias
	tile.apply_daily_tick(3, false)
	_check(tile.stage == CropTile.GrowthStage.DORMANTE, "retoma: invierno -> DORMANTE")
	_check(tile.grown_days == dias_base, "retoma: DORMANTE no pierde dias")
	_check(tile.prev_stage != CropTile.GrowthStage.DORMANTE, "retoma: prev_stage preserva etapa activa")
	# Otonio de nuevo: apta -> retoma desde donde quedo (no reinicia).
	# El jugador riega al volver la estacion (calabaza water_need=2: sin
	# re-riego entraria SIN_AGUA; esa mecanica se prueba en bloque 1b).
	var stage_previo: int = tile.prev_stage
	_farm.water(pos)
	tile.apply_daily_tick(2, false)
	_check(not tile.is_paused(), "retoma: estacion apta despierta el cultivo")
	_check(tile.stage == stage_previo or tile.grown_days > dias_base,
		"retoma: retoma en etapa previa o avanza nunca reinicia")
	_check(tile.grown_days >= dias_base + 1, "retoma: grown_days sigue desde %d (no reinicia a 0)" % dias_base)

## 1b. Doble pausa: DORMANTE (estacion) -> SIN_AGUA (estacion apta, sin agua)
##     -> retoma unica: prev_stage NUNCA guarda una pausa (solo etapas activas).
func _test_doble_pausa() -> void:
	var pos := Vector3i(312, 12, 312)
	root.get_node("/root/Inventario").agregar_items({"calabaza": 5})
	_farm.till_tile(pos)
	_farm.plant(_farm.obtener_def(&"calabaza"), pos)
	var tile: CropTile = _farm.get_tile(pos)
	if tile == null:
		_check(false, "doble pausa: tile sembrado")
		return
	# Otonio apto con agua: crece
	_farm.water(pos)
	tile.apply_daily_tick(2, false)
	var dias_base := tile.grown_days
	var etapa_base := tile.stage
	# Invierno: DORMANTE
	tile.apply_daily_tick(3, false)
	_check(tile.stage == CropTile.GrowthStage.DORMANTE, "doble pausa: entra DORMANTE")
	# Otonio apto pero SIN agua: SIN_AGUA (prev_stage NO debe pisarse con DORMANTE)
	tile.apply_daily_tick(2, false)
	_check(tile.stage == CropTile.GrowthStage.SIN_AGUA, "doble pausa: apta sin agua -> SIN_AGUA")
	_check(tile.prev_stage == etapa_base, "doble pausa: prev_stage conserva etapa activa (%d)" % etapa_base)
	# Riego + otonio: retoma UNICA vez a la etapa activa
	_farm.water(pos)
	tile.apply_daily_tick(2, false)
	_check(not tile.is_paused(), "doble pausa: retoma tras riego")
	_check(tile.stage == etapa_base or tile.grown_days > dias_base, "doble pausa: vuelve a etapa activa")
	_check(tile.grown_days >= dias_base + 1, "doble pausa: dias aumentan sin reinicio (%d >= %d)" % [tile.grown_days, dias_base])

## 2. Sequia prolongada: 45 dias sin agua, pausa indefinida, nunca muerte.
func _test_sequia_sin_muerte() -> void:
	var pos := Vector3i(314, 12, 314)
	root.get_node("/root/Inventario").agregar_items({"zanahoria": 5})
	_farm.till_tile(pos)
	_farm.plant(_farm.obtener_def(&"zanahoria"), pos)
	var tile: CropTile = _farm.get_tile(pos)
	if tile == null:
		_check(false, "sequia: tile sembrado")
		return
	var i: int = 0
	while i < 45:
		tile.apply_daily_tick(0, false)  # primavera apta, sin agua
		i += 1
	_check(tile.stage == CropTile.GrowthStage.SIN_AGUA, "sequia: 45 dias -> SIN_AGUA estable")
	_check(tile.grown_days == 0, "sequia: dias congelados en 0")
	_check(_farm.get_tile(pos) != null, "sequia: tile vivo (no hay muerte)")
	_check(tile.is_paused(), "sequia: pausa indefinida hasta riego")
	_check(tile.calcular_calidad() == 0, "sequia A7: calidad COMUN si no se fertaliza")
	# Riego: reanuda SIN perdida
	_farm.water(pos)
	tile.apply_daily_tick(0, false)
	_check(not tile.is_paused(), "sequia: riego reanuda")
	_check(tile.grown_days >= 1, "sequia: avanza tras reanudar")

## 3. P25: decorative_only nunca rinde (helecho ornamental).
func _test_decorative_only() -> void:
	var def := CropDefinition.new()
	def.crop_id = &"helecho_ornamental"
	def.display_name = "Helecho ornamental"
	def.seasons = [0, 1, 2, 3]
	def.grow_days = 2
	def.stage_count = 2
	def.water_need = 1
	def.yield_item_id = &"hoja_helecho"
	def.decorative_only = true
	var tile := CropTile.new()
	tile.crop_def = def
	_check(tile.calcular_rendimiento().is_empty(), "P25: rendimiento vacio de semilla")
	# Llega a LISTA (crece normal) y sigue sin rendir: decorativo no da items
	var j: int = 0
	while j < 3:
		tile.water_level = 2
		tile.apply_daily_tick(0, false)
		j += 1
	_check(tile.is_ready(), "P25: crece hasta LISTA (solo estetica)")
	var r: Array = tile.calcular_rendimiento()
	_check(r.is_empty(), "P25: LISTA -> calcular_rendimiento() devuelve [] (%s)" % str(r))
	_check(tile.crop_def.decorative_only, "P25: flag persiste")
	# Sin flag (control): mismo path rinde (guardia anti-falso-verde)
	var def2 := CropDefinition.new()
	def2.crop_id = &"control_sin_decor"
	def2.seasons = [0]
	def2.grow_days = 1
	def2.yield_item_id = &"fruta_control"
	var t2 := CropTile.new()
	t2.crop_def = def2
	t2.water_level = 2
	t2.apply_daily_tick(0, false)
	var r2: Array = t2.calcular_rendimiento()
	_check(not r2.is_empty(), "control: sin decorative_only si rinde (%s)" % str(r2))

## 4. Arbol frutal en invierno: DORMANTE conserva cooldown (item [S] K).
func _test_arbol_invierno() -> void:
	var def := CropDefinition.new()
	def.crop_id = &"manzano_test"
	def.seasons = [0, 1, 2]  # todo menos invierno (3)
	def.grow_days = 4
	def.stage_count = 3
	def.water_need = 1
	def.is_tree = true
	def.yield_item_id = &"manzana"
	var tile := CropTile.new()
	tile.crop_def = def
	tile.fruit_cooldown = 2  # en periodo frutal (simula cosecha previa)
	var inv_antes: int = tile.fruit_cooldown
	# Invierno (3): no apto -> DORMANTE y cooldown INTACTO
	tile.water_level = 2
	var cambio: bool = tile.apply_daily_tick(3, false)
	_check(tile.stage == CropTile.GrowthStage.DORMANTE, "arbol: invierno -> DORMANTE")
	_check(tile.fruit_cooldown == inv_antes, "arbol: DORMANTE conserva cooldown | %d" % tile.fruit_cooldown)
	_check(cambio, "arbol: entrar en DORMANTE es cambio de etapa (evento/senal legible)")
	# Primavera (0) apta con agua: retoma y cuenta dias de fruta
	tile.apply_daily_tick(0, false)
	_check(not tile.is_paused(), "arbol: retoma en primavera")
	_check(tile.fruit_cooldown == inv_antes - 1, "arbol: cooldown decrementa en tick activo | %d" % tile.fruit_cooldown)
	_check(tile.grown_days == 0, "arbol: en cooldown NO avanza grown_days | %d" % tile.grown_days)
	# Otra vez invierno: DORMANTE de nuevo, cooldown preservado
	var c1: int = tile.fruit_cooldown
	tile.apply_daily_tick(3, false)
	_check(tile.stage == CropTile.GrowthStage.DORMANTE and tile.fruit_cooldown == c1, "arbol: re-pausa conserva cooldown")
