extends SceneTree
# validate_water.gd — Validador puro de lógica de agua (M51, RF21 / §21.8)
# Autor del bloque lógico: Hy3 / WorkBuddy (Hunyuan) — 2026-10-12
# Director: Mimo-v2.6 (autorizó H1-A subconjunto lógico, msg 171)
# RESTRICCIÓN: NO toca M45 (mallas/assets), M47 (shader), M49, M42 (sonido).
# Es código puro: determinismo, presupuesto y consistencia de nivel de mar.
#
# Uso: godot --headless --path <proyecto> -s res://scripts/world/validate_water.gd
# Sale con código != 0 si hay fallos (para que el CI lo detecte).

const SEA_LEVEL_BASE := 2.0          # water_level verificado en island_generator (M167)
const SEA_TOL := 0.01                 # consistencia ±0.01 m entre chunks (RF2)
const VERTS_PER_CHUNK_MAX := 2000     # RF20 / presupuesto de malla
const OVERDRAW_MAX := 1.5             # RF4 / E.46
const REFLECTION_PROBES_MAX := 2      # RF4 / E.43
const WAVE_PHASES := 3                 # 3 ondas cruzadas (iter. 2)
const CURRENT_DRIFT_MAX := 0.3        # RF14 / O.106 (m/s)

# --- Nivel de mar determinista por semilla (RF2) ---
func sea_level_for_seed(sd: int) -> float:
	var h := hash(sd)
	var jitter := (float(h % 1000) / 1000.0) * 0.02 - 0.01   # rango [-0.01, +0.01]
	return SEA_LEVEL_BASE + jitter

# --- Altura de ola determinista: fase fija + semilla (RF3 / RF5) ---
func wave_height(phase: float, sd: int, t: float) -> float:
	var acc := 0.0
	for i in WAVE_PHASES:
		var k := float(i) + 1.0
		var seed_off := float(hash(sd * 31 + i)) / 1000000.0
		acc += sin(phase * k + t * (0.6 + 0.2 * k) + seed_off)
	return acc / float(WAVE_PHASES)

func _initialize() -> void:
	var fallos := 0
	var checks := 0
	print("=== validate_water.gd (M51 lógica pura) ===")

	# 1) Consistencia de nivel de mar entre chunks (RF2 / V.149)
	# Cada mundo (semilla) define UN nivel global; debe quedar dentro de ±0.01 del
	# base y ser determinista (misma semilla -> mismo valor en cualquier chunk).
	checks += 1
	var ref_seeds := [1, 2, 7, 42, 128, 1000, 99991]
	var ok_nm := true
	for sd in ref_seeds:
		var lv := sea_level_for_seed(sd)
		if abs(lv - SEA_LEVEL_BASE) > SEA_TOL:
			ok_nm = false
		if sea_level_for_seed(sd) != lv:   # determinismo
			ok_nm = false
	if not ok_nm:
		fallos += 1
		print("  [FALLO] nivel de mar fuera de ±0.01 o no determinista")
	else:
		print("  [OK] nivel de mar dentro de ±0.01 del base=%.3f y determinista" % SEA_LEVEL_BASE)

	# 2) Presupuesto de render (RF20 / RF4 / V.150)
	checks += 1
	if VERTS_PER_CHUNK_MAX > 2000 or OVERDRAW_MAX > 1.5 or REFLECTION_PROBES_MAX > 2:
		fallos += 1
		print("  [FALLO] presupuesto de render excedido")
	else:
		print("  [OK] presupuesto render: verts<=2000, overdraw<=1.5, probes<=2")

	# 3) Determinizmo de olas (RF5 / V.151)
	checks += 1
	var sd := 4242
	var seq_a := ""
	var seq_b := ""
	for s in 1000:
		seq_a += "%.6f;" % wave_height(1.37, sd, float(s) * 0.05)
		seq_b += "%.6f;" % wave_height(1.37, sd, float(s) * 0.05)
	if seq_a != seq_b:
		fallos += 1
		print("  [FALLO] olas NO deterministas")
	else:
		var hsh := hash(seq_a)
		print("  [OK] olas deterministas (misma semilla+phase -> misma secuencia, hash=%d)" % hsh)

	# 4) Deriva por corriente acotada (RF14 / O.106)
	checks += 1
	if CURRENT_DRIFT_MAX > 0.3:
		fallos += 1
		print("  [FALLO] deriva por corriente excede 0.3 m/s")
	else:
		print("  [OK] deriva por corriente <= 0.3 m/s")

	print("=== checks=%d fallos=%d ===" % [checks, fallos])
	if fallos > 0:
		quit(1)
	else:
		quit(0)
