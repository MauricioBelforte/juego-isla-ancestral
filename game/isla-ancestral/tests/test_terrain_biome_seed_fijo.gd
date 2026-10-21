extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-21
#
# M112 (Testing Automatico) — item "[?] Testear biome y terreno con seed fijo".
# ADJUDICADO por Ling-3.1-Flash (R3, 2026-10-13) como deferral real: "0 tests con seed|SEED en
# todo tests/". Este suite lo cierra: verificacion determinista del generador de terreno y de
# bioma con SEMILLA FIJA.
#
# QUE MIDE (y por que no es un falso verde):
#   1. Con la MISMA semilla, dos generadores independientes dan alturas, bloques y biomas
#      IDENTICOS en N coordenadas -> el resultado es reproducible.
#   2. Con OTRA semilla, al menos una coordenada DIFERIE -> la semilla manda de verdad
#      (si el generador ignorara la semilla, este check FALLARIA y el test no seria verde).
#   3. La altura es estable dentro de un mismo generador (get_height es puro).
#   4. La cadena de ruido deriva de la semilla (+0/+1000/+2000/+3000) y el catalogo se puede
#      reconstruir -> el determinismo no depende de estado global.
#   5. get_block_at responde en aire, superficie y subsuelo sin crashear y devuelve ids validos.
#   6. get_debug_color responde para cualquier coordenada.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_terrain_biome_seed_fijo.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M112 terreno y biome con seed fijo"
const SEED := 1234
const SEED_ALT := 987
const MUESTRAS := 24
const CHECKS_MINIMOS := 12

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


func _initialize() -> void:
	# Watchdog: si el script se cuelga (error de runtime antes del quit), el proceso no se queda
	# vivo indefinidamente (el runner tiene timeout, pero un proceso huerfano rompe el CI).
	var w := Timer.new()
	w.wait_time = 120.0
	w.one_shot = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: el suite excedio 120 s -> salida forzada con codigo 1")
		quit(1))
	root.add_child(w)
	w.start()
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Coordenadas de muestreo deterministas, en ANILLOS alrededor del centro real de la isla
## (el centro es `island_radius` en X y Z — ver get_height: dist = |(x,z)-centro|/radio).
## Se recorren 4 angulos x 6 radios (0.20..0.98) para tocar montana, llanura, playa y
## agua clara; fuera de ese circulo el terreno es oceano profundo (height 0) y no informa.
func _coordenadas(radio: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var radios := [0.20, 0.40, 0.60, 0.78, 0.90, 0.98]
	for r_i in radios.size():
		var r := float(radios[r_i]) * float(radio)
		for a_i in 4:
			var ang := float(a_i) * TAU / 4.0 + float(r_i) * 0.11
			out.append(Vector2i(radio + int(cos(ang) * r), radio + int(sin(ang) * r)))
	return out


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var cat := BlockCatalog.new()
	var gen_a := IslandGenerator.new(cat, SEED)
	var gen_b := IslandGenerator.new(cat, SEED)
	var gen_c := IslandGenerator.new(cat, SEED_ALT)
	var coords := _coordenadas(gen_a.island_radius)

	# ── 1) MISMA SEMILLA -> alturas identicas ──
	var alturas_iguales := true
	var detalle_altura := ""
	for c in coords:
		var ha := gen_a.get_height(c.x, c.y)
		var hb := gen_b.get_height(c.x, c.y)
		if ha != hb:
			alturas_iguales = false
			detalle_altura = "(%d,%d): %d != %d" % [c.x, c.y, ha, hb]
			break
	_check("misma semilla -> alturas IDENTICAS en %d coordenadas" % MUESTRAS,
		alturas_iguales, detalle_altura)

	# ── 2) MISMA SEMILLA -> bloques (aire, superficie y subsuelo) identicos ──
	var bloques_iguales := true
	var detalle_bloque := ""
	for c in coords:
		for y in [-1, 0, 1, 2, 3, 4, 6, 10]:
			var ba := gen_a.get_block_at(c.x, y, c.y)
			var bb := gen_b.get_block_at(c.x, y, c.y)
			if ba != bb:
				bloques_iguales = false
				detalle_bloque = "(%d,%d,%d): %d != %d" % [c.x, y, c.y, ba, bb]
				break
		if not bloques_iguales:
			break
	_check("misma semilla -> bloques IDENTICOS (aire/suelo/subsuelo)", bloques_iguales, detalle_bloque)

	# ── 3) MISMA SEMILLA -> biomas identicos ──
	var biomas_iguales := true
	var detalle_bioma := ""
	for c in coords:
		var bia := gen_a._get_biome(c.x, c.y)
		var bib := gen_b._get_biome(c.x, c.y)
		if bia != bib:
			biomas_iguales = false
			detalle_bioma = "(%d,%d): %s != %s" % [c.x, c.y, bia, bib]
			break
	_check("misma semilla -> biomas IDENTICOS", biomas_iguales, detalle_bioma)

	# ── 4) ANTI-FALSO-VERDE: otra semilla produce terreno DISTINTO ──
	var difiere := false
	var detalle_dif := ""
	for c in coords:
		if gen_a.get_height(c.x, c.y) != gen_c.get_height(c.x, c.y):
			difiere = true
			detalle_dif = "(%d,%d): %d != %d" % [c.x, c.y,
				gen_a.get_height(c.x, c.y), gen_c.get_height(c.x, c.y)]
			break
	_check("otra semilla -> el terreno DIFIERE (la semilla manda de verdad)", difiere, detalle_dif)

	var bioma_difiere := false
	for c in coords:
		if gen_a._get_biome(c.x, c.y) != gen_c._get_biome(c.x, c.y):
			bioma_difiere = true
			break
	_check("otra semilla -> el BIOMA difiere en alguna coordenada", bioma_difiere)

	# ── 5) get_height es puro (estable dentro del mismo generador) ──
	var estable := true
	for c in coords:
		var h1 := gen_a.get_height(c.x, c.y)
		var h2 := gen_a.get_height(c.x, c.y)
		if h1 != h2:
			estable = false
			break
	_check("get_height es estable en la misma coordenada (funcion pura)", estable)

	# ── 6) la semilla del generador es la que se le dio ──
	_check("el generador guarda la semilla recibida", gen_a.seed_value == SEED,
		"seed_value=%d" % gen_a.seed_value)
	_check("otro generador guarda su propia semilla", gen_c.seed_value == SEED_ALT,
		"seed_value=%d" % gen_c.seed_value)

	# ── 7) alturas dentro de rango sensato (el terreno no es plano ni infinito) ──
	var min_h := 9999
	var max_h := -9999
	for c in coords:
		var h := gen_a.get_height(c.x, c.y)
		min_h = mini(min_h, h)
		max_h = maxi(max_h, h)
	_check("las alturas varied (no es un plano)", max_h > min_h, "min=%d max=%d" % [min_h, max_h])
	_check("las alturas estan en rango util (0..max_height)", min_h >= 0 and max_h <= gen_a.max_height,
		"min=%d max=%d max_height=%d" % [min_h, max_h, gen_a.max_height])

	# ── 8) get_block_at responde en toda la columna sin crashear ──
	var ids_validos := true
	var id_max := 0
	for c in coords:
		for y in [-1, 0, 2, 4, 8, 16]:
			var b := gen_a.get_block_at(c.x, y, c.y)
			if b < 0:
				ids_validos = false
			id_max = maxi(id_max, b)
	_check("get_block_at devuelve ids NO NEGATIVOS en toda la columna", ids_validos)
	_check("los ids de bloque estan dentro del catalogo", id_max <= cat.get_model_count(),
		"id_max=%d catalogo=%d" % [id_max, cat.get_model_count()])

	# ── 9) get_debug_color responde (contrato de M08) ──
	var color_ok := true
	for c in coords:
		var col := gen_a.get_debug_color(c.x, gen_a.get_height(c.x, c.y), c.y)
		if col.r < 0.0 or col.r > 1.0:
			color_ok = false
			break
	_check("get_debug_color responde un color valido", color_ok)

	# ── 10) el catalogo se puede reconstruir (el determinismo no depende de estado global) ──
	var cat2 := BlockCatalog.new()
	var gen_d := IslandGenerator.new(cat2, SEED)
	var cat_iguales := true
	for c in coords:
		if gen_d.get_height(c.x, c.y) != gen_a.get_height(c.x, c.y):
			cat_iguales = false
			break
	_check("un catalogo reconstruido + misma semilla -> mismo terreno", cat_iguales)

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST %s FALLIDO (checks=%d, minimo=%d)" % [MODULO, _checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST %s OK — el terreno y el biome son reproducibles con seed fijo" % MODULO)
		quit(0)
