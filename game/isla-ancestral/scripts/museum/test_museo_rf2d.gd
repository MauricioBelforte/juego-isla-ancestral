# M37: test del slice RF2d (DeepSeek-V4.1-Flash, 2026-10-09) — versionado + migracion
# del bloque de guardado del museo (03-Diseno sec.8: "Versionado del bloque para
# migraciones futuras"). Cubre: version presente, round-trip 50% y 100%, migracion del
# bloque legado (v0 sin "version"), guardia contra un bloque de version FUTURA (no degradar)
# y purga de exposicion huerfana. Guardian de 3 capas: contador + piso CHECKS_MINIMOS
# (MEDIDO) + marcadores por bloque, con watchdog como diagnostico.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/test_museo_rf2d.gd
extends SceneTree

const MODULO := "M37-RF2d"
const CHECKS_MINIMOS := 28   # MEDIDO en verde (28 checks reales); nunca estimado
const FRAMES_MAX := 600

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _resumido := false
var _frames := 0

const BLOQUES := ["A", "B", "C", "D", "E", "F", "G"]

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _process(_delta: float) -> bool:
	_frames += 1
	if not _resumido and _frames > FRAMES_MAX:
		print("!! WATCHDOG: _run() no termino en %d frames (posible SCRIPT ERROR que aborto la funcion)" % FRAMES_MAX)
		_summary()
	return false

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _summary() -> void:
	if _resumido:
		return
	_resumido = true
	for n in BLOQUES:
		if not _vistos.has(n):
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
			_fallos += 1
	if _checks < CHECKS_MINIMOS:
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
		_fallos += 1
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _run() -> void:
	var reg = root.get_node_or_null("CollectionRegistry")
	_check(reg != null, "autoload CollectionRegistry presente")
	if reg == null:
		return
	reg.restore_save_data({})
	var V: int = int((reg.get_save_data() as Dictionary).get("version", 0))

	# ── A. Versionado presente en el bloque guardado ──
	reg.restore_save_data({})
	reg.register_item("flora", "baya_roja")
	var save: Dictionary = reg.get_save_data()
	_check(save.has("version"), "A: get_save_data incluye 'version'")
	_check(int(save.get("version", 0)) == V and V >= 1, "A: version == VERSION_GUARDADO (llego %d)" % V)
	_check(save.has("piezas") and save.has("recompensas"), "A: bloque conserva piezas + recompensas")
	_fin("A")

	# ── B. Round-trip al 50% de una exposicion (flora: 4 items -> 2 donados) ──
	reg.restore_save_data({})
	reg.register_item("flora", "baya_roja")
	reg.register_item("flora", "fibra_algodon")
	var save_b: Dictionary = reg.get_save_data()
	reg.restore_save_data({})                      # simula "partida nueva"
	_check(reg.get_registered("flora").is_empty(), "B: reset deja el registro vacio")
	reg.restore_save_data(save_b)                  # simula "cargar partida"
	var r_b: Array = reg.get_registered("flora")
	_check(r_b.size() == 2, "B: round-trip conserva 2 piezas (llego %d)" % r_b.size())
	_check(reg.is_registered("flora", "baya_roja") and reg.is_registered("flora", "fibra_algodon"), "B: las 2 piezas exactas")
	_check(not reg.is_registered("flora", "madera_roble"), "B: lo no donado sigue sin registrar")
	var p_b: Dictionary = reg.get_exhibition_progress("flora")
	_check(int(p_b.get("registered", -1)) == 2 and int(p_b.get("total", -1)) == 4, "B: progreso 2/4")
	_fin("B")

	# ── C. Round-trip al 100% de una exposicion + recompensa reclamada (fosiles: 1 item) ──
	reg.restore_save_data({})
	reg.register_item("fosiles", "fragmento_ancestral")
	_check(reg.is_exhibition_completed("fosiles"), "C: exposicion completada al registrar la ultima pieza")
	var recompensa: String = reg.otorgar_recompensa("fosiles")
	_check(recompensa != "", "C: otorgar_recompensa devuelve el item (%s)" % recompensa)
	_check(reg.is_reward_claimed("fosiles"), "C: recompensa marcada como reclamada")
	var save_c: Dictionary = reg.get_save_data()
	reg.restore_save_data({})
	reg.restore_save_data(save_c)
	_check(reg.is_exhibition_completed("fosiles"), "C: round-trip conserva la exposicion completa")
	_check(reg.is_reward_claimed("fosiles"), "C: round-trip conserva la recompensa reclamada")
	_fin("C")

	# ── D. Migracion del bloque LEGADO (v0: sin campo "version") ──
	reg.restore_save_data({})
	reg.restore_save_data({"piezas": {"flora": ["baya_roja"]}, "recompensas": ["peces"]})
	_check(reg.is_registered("flora", "baya_roja"), "D: bloque legado v0 migra y carga la pieza")
	_check(reg.is_reward_claimed("peces"), "D: bloque legado v0 migra y carga la recompensa")
	var save_d: Dictionary = reg.get_save_data()
	_check(int(save_d.get("version", 0)) == V, "D: tras migrar, el bloque sale con version actual")
	reg.restore_save_data({"recompensas": "no-es-array"})
	_check(reg.get_registered("flora").is_empty(), "D: v0 con 'recompensas' invalido se normaliza sin crash")
	_fin("D")

	# ── E. Guardia: un bloque de version FUTURA no degrada el estado actual ──
	reg.restore_save_data({})
	reg.register_item("flora", "baya_roja")
	reg.restore_save_data({"version": V + 1, "piezas": {"fauna": ["gaviota_playera"]}, "recompensas": []})
	_check(reg.is_registered("flora", "baya_roja"), "E: bloque de version futura NO degrada el estado actual")
	_check(not reg.is_registered("fauna", "gaviota_playera"), "E: bloque de version futura se ignora (no carga)")
	_fin("E")

	# ── F. Purga de exposicion huerfana (fuera del catalogo) ──
	reg.restore_save_data({})
	reg.restore_save_data({"version": V, "piezas": {"EXPO_FANTASMA": ["x"], "flora": ["baya_roja"]}, "recompensas": []})
	_check(reg.get_registered("EXPO_FANTASMA").is_empty(), "F: exposicion huerfana ignorada (sin crash)")
	_check(reg.is_registered("flora", "baya_roja"), "F: la exposicion valida del mismo bloque si carga")
	_fin("F")

	# ── G. Museo al 50% y al 100% (K.172) ──
	reg.restore_save_data({})
	# 50%: 8 de 16 piezas (peces 2/4, fosiles 1/1, flora 2/4, fauna 3/7).
	for it in ["trucha_cascada", "bacalao_nube"]:
		reg.register_item("peces", String(it))
	reg.register_item("fosiles", "fragmento_ancestral")
	for it in ["baya_roja", "fibra_algodon"]:
		reg.register_item("flora", String(it))
	for it in ["gaviota_playera", "conejo_pradera", "nutria_ribera"]:
		reg.register_item("fauna", String(it))
	var p50: float = reg.get_total_progress()
	_check(is_equal_approx(p50, 0.5), "G: museo al 50%% (llego %.3f)" % p50)
	# 100%: todas las piezas del catalogo.
	var todas := {
		"peces": ["trucha_cascada", "bacalao_nube", "gobio_mar", "anguila_brisa"],
		"fosiles": ["fragmento_ancestral"],
		"flora": ["baya_roja", "fibra_algodon", "madera_roble", "mineral_cobre"],
		"fauna": ["gaviota_playera", "conejo_pradera", "nutria_ribera", "lechuza_bosque", "salamandra_ancestral", "cangrejo_humedal", "halcon_montana"],
	}
	for exid in todas:
		for it in todas[exid]:
			reg.register_item(String(exid), String(it))
	var p100: float = reg.get_total_progress()
	_check(is_equal_approx(p100, 1.0), "G: museo al 100%% (llego %.3f)" % p100)
	_check(reg.exposiciones_completas_count() == 4, "G: 4 exposiciones completas (llego %d)" % reg.exposiciones_completas_count())
	# Round-trip del 100%: guardar -> reset -> cargar conserva el 100%.
	var save_g: Dictionary = reg.get_save_data()
	reg.restore_save_data({})
	_check(is_equal_approx(reg.get_total_progress(), 0.0), "G: reset baja el progreso a 0")
	reg.restore_save_data(save_g)
	_check(is_equal_approx(reg.get_total_progress(), 1.0), "G: round-trip 100%% conserva el progreso")
	_check(reg.exposiciones_completas_count() == 4, "G: round-trip conserva las 4 completas")
	_fin("G")
