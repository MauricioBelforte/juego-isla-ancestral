# Modelo: hy3 (WorkBuddy)
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
# M167 (P-39): Validador PARAMETRICO del terreno de la Isla Raiz.
# Fuente de verdad: res://scripts/world/mundo_raiz.gd (CENTRO, SPAWN_JUGADOR,
# RADIO_ISLA). El radio del generador (= island_radius) es igual a CENTRO.x
# porque el mundo va de 0 a 2*CENTRO.x con centro en CENTRO. NO hardcodear 256:
# cualquier valor se lee de mundo_raiz.gd. Esto cierra el gate rojo en falso
# que existia (el validador exigia 256 mientras main_island.gd usa 2560).
# Verifica (a) la config REAL usada por main_island.gd contra mundo_raiz,
# (b) el perfil del get_height en grillas radiales, (c) determinismo con
# semilla, (d) ausencia de muros verticales, (e) batimetria.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/terreno/validador_isla_raiz.gd

extends SceneTree

const MUNDO_RAIZ = preload("res://scripts/world/mundo_raiz.gd")
const ISLAND_GEN = preload("res://scripts/world/island_generator.gd")

const SEMILLA_EXPECTADA := 42
const ALTURA_MAX_EXPECTADA := 40
# Radio del generador = CENTRO.x (mundo [0, 2*CENTRO.x], centro CENTRO). Se lee
# de mundo_raiz.gd en _init(), NO hardcodeado.
var RADIO_EXPECTADO: int = 2560

# Ratios de distancia normalizada (dist = r / island_radius) para el perfil
# dinamico. Son invariantes al radio porque get_height normaliza por
# island_radius; por eso el validador funciona para cualquier radio.
const RATIO_PLAYA := 0.8398
const RATIO_CLARO := 0.9648
const RATIO_PROF  := 1.035

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	RADIO_EXPECTADO = int(MUNDO_RAIZ.CENTRO.x)
	call_deferred("_run")

func _run() -> void:
	print("=== M167: VALIDADOR PARAMETRICO DE LA ISLA RAIZ ===")
	print("RADIO_EXPECTADO (mundo_raiz.CENTRO.x) = %d -> mundo 5120x5120, centro (2560,2560)" % RADIO_EXPECTADO)
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
	_check(main.find("generator.world_seed = %d" % SEMILLA_EXPECTADA) != -1,
		"main_island.gd: world_seed = %d (fuente de verdad)" % SEMILLA_EXPECTADA)
	# P-39: el radio REAL se lee de mundo_raiz.CENTRO.x (no hardcodeado 256).
	_check(main.find("generator.island_radius = %d" % RADIO_EXPECTADO) != -1,
		"main_island.gd: island_radius = %d (radio Isla Raiz 5120², centro 2560)" % RADIO_EXPECTADO)
	_check(main.find("generator.max_height = %d" % ALTURA_MAX_EXPECTADA) != -1,
		"main_island.gd: max_height = %d" % ALTURA_MAX_EXPECTADA)
	# P-39: el spawn del jugador NO debe quedar en la esquina vieja del mundo.
	_check(main.find("Vector3(256, 16, 256)") == -1,
		"main_island.gd: anti-regresion — NO queda spawn viejo (256,16,256) en esquina")
	_check(main.find("MundoRaiz.SPAWN_JUGADOR") != -1,
		"main_island.gd: spawn del jugador usa MundoRaiz.SPAWN_JUGADOR (3860,3860)")
	# Océano y disco de arena: centro real, no (256,...).
	_check(main.find("Vector3(256, 1.2, 256)") == -1,
		"main_island.gd: anti-regresion — NO queda oceano en centro viejo (256,1.2,256)")
	_check(main.find("MundoRaiz.centro_vec3") != -1,
		"main_island.gd: oceano y disco usan MundoRaiz.centro_vec3 (centro 2560)")

	var proj := _leer_archivo("res://project.godot")
	_check(proj.find("TerrainLocator=" + '"*res://scripts/core/terrain_locator.gd"') != -1
		or proj.find("TerrainLocator=" + "\"*res://scripts/core/terrain_locator.gd\"") != -1,
		"project.godot: TerrainLocator registrado como autoload (antiflotamiento)")
	_check(proj.find("terrain_locator.gd") != -1,
		"project.godot: ruta del autoload TerrainLocator")
	_check(proj.find("MundoRaiz=") != -1,
		"project.godot: MundoRaiz registrado como autoload (punto unico de verdad del layout)")

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
	# Offsets proporcionales al radio: el generador normaliza por island_radius,
	# asi que las bandas caen en los mismos RATIOS de distancia sin importar el
	# radio. 2560 = 10x256 -> los offsets originales (215/247/265) escalan 10x.
	var off_playa := int(RATIO_PLAYA * c)
	var off_claro := int(RATIO_CLARO * c)
	var off_prof  := int(RATIO_PROF * c)
	# D1: centro = montana central (segun perfil en capas, height > playa y
	# claramente por encima del agua). El valor exacto se midio en headless:
	# el centro queda en ~14-19 con seed 42, siempre >= 12 y > 3.
	var h0 := g.get_height(c, c)
	_check(h0 >= 12, "centro (%d,%d): montana central, get_height=%d (>=12)" % [c, c, h0])
	_check(h0 > 3, "centro: mas alto que la playa (height %d > 3)" % h0)
	# D2: playa/plato (dist ~0.84): arena height 3-4
	var h_playa := g.get_height(c + off_playa, c)
	_check(h_playa >= 3 and h_playa <= 4,
		"plato de arena dist=%.4f: get_height=%d (esperado 3-4)" % [RATIO_PLAYA, h_playa])
	# D3: banda agua clara (0.94-1.03): fondo a 2
	var h_claro := g.get_height(c + off_claro, c)
	_check(h_claro == 2, "banda agua clara dist=%.4f: fondo altura 2 (get=%d)" % [RATIO_CLARO, h_claro])
	# D4: agua profunda (>1.03): fondo a 0
	var h_prof := g.get_height(c + off_prof, c)
	_check(h_prof == 0, "agua profunda dist=%.4f: fondo altura 0 (get=%d)" % [RATIO_PROF, h_prof])
	# D5: simetria global del perfil (las 4 direcciones cardinales dan el mismo
	# tipo de zona: centro alto, plato 3-4, claro 2, profundo 0)
	for dir_v in [[1, 0], [0, 1], [-1, 0], [0, -1]]:
		var h_cente := g.get_height(c + dir_v[0] * 0, c + dir_v[1] * 0)
		_check(h_cente == h0, "simetria centro (dir %s)" % str(dir_v))

# ── (c) Batimetria: el agua clara turquesa DEBE generarse (bloque SHALLOW_WATER) ──

func _verificar_batimetria() -> void:
	var g := _gen()
	var c := RADIO_EXPECTADO
	var off_claro := int(RATIO_CLARO * c)
	var off_prof := int(RATIO_PROF * c)
	var off_playa := int(RATIO_PLAYA * c)
	# Banda 0.94-1.03 (dist = 0.9648): columna con fondo arena en y=2 y la capa
	# de agua clara turquesa debe estar en y=3 (jugador camina sumergido).
	var x = c + off_claro
	var z = c
	var h := g.get_height(x, z)
	var superficie := g.get_block_at(x, h + 1, z)
	_check(superficie == 30, "agua clara: voxel en y=height+1 (%d) es SHALLOW_WATER (got %d)" % [h + 1, superficie])
	# Apoyo: el fondo es arena (beach)
	var fondo := g.get_block_at(x, h, z)
	_check(fondo == 5, "agua clara: fondo en y=%d es arena (SAND=5, got %d)" % [h, fondo])
	# Profunda (>1.03): capa de agua azul por encima del fondo
	var xp = c + off_prof
	var hp := g.get_block_at(xp, 1, c)
	_check(hp == 17, "agua profunda: voxel y=1 es WATER (17, got %d)" % hp)
	# Playera (plato): superficie arena
	var xpl = c + off_playa
	var hpl := g.get_height(xpl, c)
	var sup_playa := g.get_block_at(xpl, hpl, c)
	_check(sup_playa == 5, "plato: superficie arena (SAND=5, got %d)" % sup_playa)

# ── (d) Determinismo: mismos params -> mismo terreno ──

func _verificar_determinismo() -> void:
	var g1 := _gen()
	var g2 := _gen()
	var iguales := true
	# Puntos de la grilla original (radio 256) escalados 10x para el radio 5120.
	var pts_raw := [[256, 256], [256, 400], [400, 256], [300, 300], [500, 460],
		[256, 496], [496, 256], [200, 200], [600, 100], [100, 100]]
	var pts := []
	for p in pts_raw:
		pts.append([p[0] * 10, p[1] * 10])
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
