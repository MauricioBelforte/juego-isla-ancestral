# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-24
#
# M50 - BACKLOG-11 D8, bloque 50-Vegetacion: medidor del PLAN de vegetacion.
#
# Herramienta de SOLO LECTURA (no escribe ni instancia nada): genera el plan
# con VegetationPlan.generar_plan() y publica el censo medido en JSON para que
# el auditor de presupuesto (scripts/vegetacion/auditar_presupuesto_m50.py)
# calcule triangulos, draw calls y VRAM sobre CIFRAS REALES y no estimadas.
#
# Uso:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/vegetacion/medir_plan_m50.gd -- --json
#   (sin --json imprime un informe legible)
#
# Codigos de salida:
#   0 = plan medido
#   1 = inconsistencia (tipo fuera de su bioma, o GLB ausente para un tipo)
#   3 = MEDIDOR CIEGO (plan vacio, o el plan no trae los campos esperados)

extends SceneTree

const PLAN = preload("res://scripts/vegetacion/vegetation_plan.gd")
const VM = preload("res://scripts/vegetacion/vegetation_manager.gd")

const RADIO_DEF := 1200.0
const SEMILLA_DEF := 42
const CENTRO_DEF := Vector2(320.0, 320.0)
const DIR_MEDIA := "res://assets/3d/media/"

var _json := false
var _centro := CENTRO_DEF
var _radio := RADIO_DEF
var _semilla := SEMILLA_DEF
var _salida := {}
var _codigo := 0
var _terminado := false


func _init() -> void:
	_leer_args()
	call_deferred("_run")
	call_deferred("_cerrar")


func _leer_args() -> void:
	for a in OS.get_cmdline_user_args():
		var s := String(a)
		if s == "--json":
			_json = true
		elif s.begins_with("--centro="):
			var partes := s.trim_prefix("--centro=").split(",")
			if partes.size() == 2:
				_centro = Vector2(float(partes[0]), float(partes[1]))
		elif s.begins_with("--radio="):
			_radio = float(s.trim_prefix("--radio="))
		elif s.begins_with("--semilla="):
			_semilla = int(s.trim_prefix("--semilla="))


func _run() -> void:
	var plan: Array = PLAN.generar_plan(_centro, _radio, _semilla)
	var total := plan.size()
	if total == 0:
		_salida = {"ciego": true, "motivo": "el plan generado tiene 0 items"}
		_codigo = 3
		_terminado = true
		return

	var por_bioma: Dictionary = {}
	var por_tipo: Dictionary = {}
	var sin_tipo := 0
	var sin_posicion := 0
	var fuera_anillo := 0
	var inconsistencia: Array = []
	var r_min := INF
	var r_max := -INF
	var r_suma := 0.0
	var distancias: Array = []

	for item in plan:
		if typeof(item) != TYPE_DICTIONARY:
			sin_posicion += 1
			continue
		var d: Dictionary = item
		if not d.has("tipo") or String(d.get("tipo", "")) == "":
			sin_tipo += 1
			continue
		var tipo := String(d.get("tipo"))
		var bioma := String(d.get("bioma", "?"))
		por_tipo[tipo] = int(por_tipo.get(tipo, 0)) + 1
		por_bioma[bioma] = int(por_bioma.get(bioma, 0)) + 1
		# El tipo debe estar declarado en la config de SU bioma (integridad de datos).
		if bioma != "cercanias_spawn":
			var tipos_bioma: Array = VM.tipos_para_bioma(bioma)
			if not tipos_bioma.has(tipo):
				inconsistencia.append({"bioma": bioma, "tipo": tipo})
		if not FileAccess.file_exists(DIR_MEDIA + tipo + ".glb"):
			inconsistencia.append({"bioma": bioma, "tipo": tipo, "motivo": "glb_ausente"})
		var pos: Variant = d.get("posicion", null)
		if typeof(pos) != TYPE_DICTIONARY:
			sin_posicion += 1
			continue
		var pd: Dictionary = pos
		var p := Vector2(float(pd.get("x", 0.0)), float(pd.get("z", 0.0)))
		var dist := p.distance_to(_centro)
		r_min = minf(r_min, dist)
		r_max = maxf(r_max, dist)
		r_suma += dist
		distancias.append(snappedf(dist, 0.01))
		# Clamp geometrico: ningun item del plan debe caer fuera del anillo de
		# tierra declarado (playa 0.93 * radio es el anillo mas externo).
		if dist > _radio * 0.93 + 0.001:
			fuera_anillo += 1

	if sin_tipo > 0 or sin_posicion > 0:
		_salida = {"ciego": true, "motivo": "items sin tipo o sin posicion", "sin_tipo": sin_tipo, "sin_posicion": sin_posicion}
		_codigo = 3
		_terminado = true
		return

	distancias.sort()
	var mediana: float = float(distancias[distancias.size() / 2]) if distancias.size() > 0 else 0.0

	_salida = {
		"centro": [_centro.x, _centro.y],
		"radio": _radio,
		"semilla": _semilla,
		"total": total,
		"biomas": por_bioma.size(),
		"por_bioma": por_bioma,
		"tipos_distintos": por_tipo.size(),
		"por_tipo": por_tipo,
		"radio_min": snappedf(r_min, 0.01),
		"radio_max": snappedf(r_max, 0.01),
		"radio_medio": snappedf(r_suma / float(total), 0.01),
		"radio_mediana": mediana,
		"fuera_anillo": fuera_anillo,
		"limite_anillo": snappedf(_radio * 0.93, 0.01),
		"inconsistencias": inconsistencia,
		"ciego": false,
	}
	if inconsistencia.size() > 0:
		_codigo = 1
	_terminado = true


func _cerrar() -> void:
	if not _terminado:
		# El medidor no llego a terminar: se publica ciego y con exit propio.
		_salida = {"ciego": true, "motivo": "la medicion no termino (posible SCRIPT ERROR)"}
		_codigo = 3
	if _json:
		print(JSON.stringify(_salida, "", false))
	else:
		_informe()
	quit(_codigo)


func _informe() -> void:
	if bool(_salida.get("ciego", false)):
		print("[M50-PLAN] CIEGO: %s" % String(_salida.get("motivo", "")))
		return
	print("[M50-PLAN] total=%d biomas=%d tipos=%d" % [int(_salida["total"]), int(_salida["biomas"]), int(_salida["tipos_distintos"])])
	var pb: Dictionary = _salida["por_bioma"]
	var claves: Array = pb.keys()
	claves.sort()
	for b in claves:
		print("  bioma %-18s %d" % [String(b), int(pb[b])])
	var pt: Dictionary = _salida["por_tipo"]
	var tipos: Array = pt.keys()
	tipos.sort()
	for t in tipos:
		print("  tipo  %-34s %d" % [String(t), int(pt[t])])
	print("  radio  min=%.2f max=%.2f medio=%.2f mediana=%.2f limite_anillo=%.2f" % [
		float(_salida["radio_min"]), float(_salida["radio_max"]),
		float(_salida["radio_medio"]), float(_salida["radio_mediana"]),
		float(_salida["limite_anillo"])])
	print("  fuera_anillo=%d  inconsistencias=%d" % [int(_salida["fuera_anillo"]), (_salida["inconsistencias"] as Array).size()])
