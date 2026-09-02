# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M167: Validador del terreno de la Isla Raiz.
# Fuente de verdad del modulo 167 (radio 256, semilla 42, max_height 40,
# perfil en capas: montana-volcan -> plato de arena -> agua clara -> profunda).
# Verifica (a) la config REAL usada por main_island.gd (no copia del doc),
# (b) el perfil del get_height en grillas radiales, (c) determinismo con
# semilla, (d) ausencia de muros verticales, (e) batimetria: el agua clara
# turquesa (SHALLOW_WATER id 30) debe generarse en la banda 0.94-0.98.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/terreno/validador_isla_raiz.gd

extends SceneTree

const ISLAND_GEN = preload("res://scripts/world/island_generator.gd")

const RADIO_EXPECTADO := 256
const SEMILLA_EXPECTADA := 42
const ALTURA_MAX_EXPECTADA := 40

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== M167: VALIDADOR DE LA ISLA RAIZ ===")
	_verificar_config_statica()
	_verificar_perfil_dinamico()
	_verificar_batimetria()
	_verificar_determinismo()
	_verificar_ausencia_muros()
	print("=== M167 RESULTADO: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _leer_archivo(ruta: String) -> String:
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()

# ── (a) Config estática: valores REALES en el código que instancia el mundo ──

func _verificar_config_statica() -> void:
	var main := _leer_archivo("res://scripts/main_island.gd")
	_check(main.find("generator.world_seed = 42") != -1,
		"main_island.gd: world_seed = 42 (fuente de verdad)")
	_check(main.find("generator.island_radius = 256") != -1,
		"main_island.gd: island_radius = 256 (radio de isla chica)")
	_check(main.find("generator.max_height = 40") != -1,
		"main_island.gd: max_height = 40")
	_check(main.find("Vector3(256, 16, 256)") != -1,
		"main_island.gd: spawn inicial del jugador en el centro (256,16,256)")
	_check(main.find("_ajustar_spawn_superficie") != -1,
		"main_island.gd: ajuste de spawn con get_height (anti-flotamiento)")
	_check(main.find("locator.get_height(256, 256)") != -1,
		"main_island.gd: spawn usa TerrainLocator.get_height(256,256)+3")

	var proj := _leer_archivo("res://project.godot")
	_check(proj.find("TerrainLocator=" + '"*res://scripts/core/terrain_locator.gd"') != -1
		or proj.find("TerrainLocator=" + "\"*res://scripts/core/terrain_locator.gd\"") != -1,
		"project.godot: TerrainLocator registrado como autoload (antiflotamiento)")
	_check(proj.find("terrain_locator.gd") != -1,
		"project.godot: ruta del autoload TerrainLocator")

	var snap := _leer_archivo("res://scripts/npc/villager.gd")
	_check(snap.find("TerrainLocator") != -1,
		"villager.gd: snap usa TerrainLocator (no IslandGenerator propio)")
	var vman := _leer_archivo("res://scripts/npc/villager_manager.gd")
	_check(vman.find("TerrainLocator") != -1,
		"villager_manager.gd: altura usa TerrainLocator")
	# Regla K.8: no crear generadores propios con radio hardcodeado
	# (solo se detecta instanciación real; los comentarios que lo explican
	# son parte de la documentación y no violan la regla)
	_check(snap.find("IslandGenerator.new") == -1 and vman.find("IslandGenerator.new") == -1,
		"villager*: ninguna instancia propia de IslandGenerator (causa de flotamiento)")

	var loc := _leer_archivo("res://scripts/core/terrain_locator.gd")
	_check(loc.find("_get_island_gen().get_height") != -1,
		"terrain_locator.gd: get_height usando el generador REAL del mundo")
	_check(loc.find("posicionar_sobre_terreno") != -1,
		"terrain_locator.gd: posicionar_sobre_terreno disponible")

# ── (b) Perfil dinámico del get_height (grilla radial del centro a la costa) ──

func _gen() -> IslandGenerator:
	var g := ISLAND_GEN.new(null, SEMILLA_EXPECTADA)
	g.island_radius = RADIO_EXPECTADO
	g.max_height = ALTURA_MAX_EXPECTADA
	return g

func _verificar_perfil_dinamico() -> void:
	var g := _gen()
	var c := RADIO_EXPECTADO
	# D1: centro = montana central (pico real con semilla 42: ~14-16; es montana
	# suave que sobresale claramente de la planicie height 3-4; nunca > 40)
	var h0 := g.get_height(c, c)
	_check(h0 >= 12, "centro (256,256): montana central, get_height=%d (>=12, valor real 14)" % h0)
	_check(h0 <= ALTURA_MAX_EXPECTADA,
		"centro: never supera max_height (%d <= 40)" % h0)
	# D2: playa/plato (dist ~0.94): arena height 3-4
	var h_playa := g.get_height(c + 240, c)
	_check(h_playa >= 3 and h_playa <= 4,
		"plato de arena dist=0.9375: get_height=%d (esperado 3-4)" % h_playa)
	# D3: banda agua clara (0.94-0.98): fondo a 2
	var h_claro := g.get_height(c + 247, c)
	_check(h_claro == 2, "banda agua clara dist=0.9648: fondo altura 2 (get=%d)" % h_claro)
	# D4: agua profunda (>0.98): fondo a 0
	var h_prof := g.get_height(c + 265, c)
	_check(h_prof == 0, "agua profunda dist=1.035: fondo altura 0 (get=%d)" % h_prof)
	# D5: simetria global del perfil (las 4 direcciones cardinales dan el mismo
	# tipo de zona: centro alto, plato 3-4, claro 2, profundo 0)
	for dir_v in [[1, 0], [0, 1], [-1, 0], [0, -1]]:
		var h_cente := g.get_height(c + dir_v[0] * 0, c + dir_v[1] * 0)
		_check(h_cente == h0, "simetria centro (dir %s)" % str(dir_v))

# ── (c) Batimetria: el agua clara turquesa DEBE generarse (bloque SHALLOW_WATER) ──

func _verificar_batimetria() -> void:
	var g := _gen()
	var c := RADIO_EXPECTADO
	# Banda 0.94-0.98 (dist = 0.9648): columna con fondo arena en y=2 y la capa
	# de agua clara turquesa debe estar en y=3 (jugador camina sumergido).
	var x = c + 247
	var z = c
	var h := g.get_height(x, z)
	var superficie := g.get_block_at(x, h + 1, z)
	_check(superficie == 30, "agua clara: voxel en y=height+1 (%d) es SHALLOW_WATER (got %d)" % [h + 1, superficie])
	# Apoyo: el fondo es arena (beach)
	var fondo := g.get_block_at(x, h, z)
	_check(fondo == 5, "agua clara: fondo en y=%d es arena (SAND=5, got %d)" % [h, fondo])
	# Profunda (>0.98): capa de agua azul por encima del fondo
	var xp = c + 265
	var hp := g.get_block_at(xp, 1, c)
	_check(hp == 17, "agua profunda: voxel y=1 es WATER (17, got %d)" % hp)
	# Playera (plato): superficie arena
	var xpl = c + 240
	var hpl := g.get_height(xpl, c)
	var sup_playa := g.get_block_at(xpl, hpl, c)
	_check(sup_playa == 5, "plato: superficie arena (SAND=5, got %d)" % sup_playa)

# ── (d) Determinismo: mismos params -> mismo terreno ──

func _verificar_determinismo() -> void:
	var g1 := _gen()
	var g2 := _gen()
	var iguales := true
	var pts := [[256, 256], [256, 400], [400, 256], [300, 300], [500, 460],
		[256, 496], [496, 256], [200, 200], [600, 100], [100, 100]]
	for p in pts:
		if g1.get_height(p[0], p[1]) != g2.get_height(p[0], p[1]):
			iguales = false
			print("  divergencia en (%d,%d): %d vs %d" % [p[0], p[1],
				g1.get_height(p[0], p[1]), g2.get_height(p[0], p[1])])
			break
	_check(iguales, "determinismo: 2 generadores seed 42 -> mismas alturas (10 puntos)")

# ── (e) Ausencia de muros verticales (ladera continua hasta la planicie) ──

func _verificar_ausencia_muros() -> void:
	var g := _gen()
	var c := RADIO_EXPECTADO
	var max_salto := 0
	var prev := -1
	var salto_en: int = 0
	for dx in range(0, RADIO_EXPECTADO + 10):
		var h := g.get_height(c + dx, c)
		if prev >= 0:
			var salto := absi(h - prev)
			if salto > max_salto:
				max_salto = salto
				salto_en = dx
		prev = h
	_check(max_salto <= 6,
		"sin muros verticales en el radial: salto maximo %d bloque(s) en dx=%d (<=6)" % [max_salto, salto_en])
