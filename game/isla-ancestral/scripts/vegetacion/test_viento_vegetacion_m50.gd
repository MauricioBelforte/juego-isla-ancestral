# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-24
#
# M50 - suite headless del modelo de viento determinista (item L176).
#
# Verifica lo que el item pide y que un shader NO puede demostrar en CI:
#   A tablas completas para todos los biomas del config y los climas del reloj
#   B determinismo (mismo tick -> mismo valor, sin importar orden ni corrida)
#   C cotas (|desplazamiento| <= amplitud <= techo del shader)
#   D amplitud por bioma (montana > playa > pradera > bosque)
#   E amplitud por clima (tormenta > lluvia > nublado > despejado > niebla)
#   F la base no se mueve (uv_y=0) y la cima se mueve mas que el medio
#   G multiplicador por preset (ultra > alta > media > baja) y techo respetado
#   H fallback determinista para bioma/clima desconocido + validar_tablas
#   I el viento AVANZA con el tick y no acumula estado entre llamadas
#
# Guardian de 3 capas (skill isla-ancestral-ciclo-modulo):
#   1) _fin("X") por bloque + BLOQUES para nombrar el que no corrio
#   2) CHECKS_MINIMOS medido en verde (no estimado)
#   3) _summary() en call_deferred APARTE de _run() -> si _run() aborta, igual corre
#
# Uso:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/vegetacion/test_viento_vegetacion_m50.gd

extends SceneTree

const V = preload("res://scripts/vegetacion/viento_vegetacion.gd")

const MODULO := "M50-VIENTO"
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
const CHECKS_MINIMOS := 35

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _terminado := false


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _check(ok: bool, desc: String) -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALLO] %s" % desc)
	else:
		print("  [OK] %s" % desc)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("[FIN] bloque %s (+%d checks)" % [bloque, _checks])


func _run() -> void:
	print("=== %s: modelo de viento determinista ===" % MODULO)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	_bloque_h()
	_bloque_i()
	_terminado = true


func _bloque_a() -> void:
	print("-- A: tablas completas")
	var biomas: Array = ["playa", "pradera", "bosque", "montana", "ribera", "humedal", "cercanias", "cercanias_spawn"]
	var climas: Array = ["despejado", "nublado", "lluvia", "tormenta", "niebla", "nieve"]
	var faltan: Array = V.validar_tablas(biomas, climas)
	_check(faltan.is_empty(), "A1 tablas cubren los 8 biomas del plan y 6 climas (faltan %s)" % str(faltan))
	_check(V.validar_tablas(["bioma_inventado"], []).size() == 1, "A2 validar_tablas detecta un bioma ausente")
	_check(V.validar_tablas([], ["clima_inventado"]).size() == 1, "A3 validar_tablas detecta un clima ausente")
	var mult_ok := true
	for k in V.MULT_PRESET:
		var m: float = float(V.MULT_PRESET[k])
		if m <= 0.0 or m > 1.0:
			mult_ok = false
	_check(mult_ok, "A4 multiplicadores de preset en (0, 1]")
	_fin("A")


func _bloque_b() -> void:
	print("-- B: determinismo")
	var pos := Vector3(412.5, 3.2, -880.75)
	var a1: Vector3 = V.desplazamiento(1234, pos, "bosque", "lluvia", 1.0, 0.7)
	var a2: Vector3 = V.desplazamiento(1234, pos, "bosque", "lluvia", 1.0, 0.7)
	_check(a1 == a2, "B1 mismo tick + misma entrada = mismo desplazamiento (%s)" % str(a1))
	# Ruido entre medio: 5000 llamadas con otros argumentos no deben cambiar el resultado.
	for i in range(5000):
		var _d: Vector3 = V.desplazamiento(i, Vector3(float(i), 0.0, float(i % 97)), "montana", "tormenta", 1.0, 0.0)
	var a3: Vector3 = V.desplazamiento(1234, pos, "bosque", "lluvia", 1.0, 0.7)
	_check(a3 == a1, "B2 no acumula estado: tras 5000 llamadas el valor es identico")
	# Orden invertido de una muestra de 200 ticks: los valores deben coincidir 1:1.
	var directo: Array = []
	for t in range(200):
		directo.append(V.desplazamiento(t, pos, "playa", "despejado", 1.0, 0.3))
	var inverso: Array = []
	for t in range(199, -1, -1):
		inverso.append(V.desplazamiento(t, pos, "playa", "despejado", 1.0, 0.3))
	inverso.reverse()
	var iguales := 0
	for i in range(200):
		if directo[i] == inverso[i]:
			iguales += 1
	_check(iguales == 200, "B3 el orden de las llamadas no altera el resultado (%d/200)" % iguales)
	var u1: Dictionary = V.uniformes("bosque", "lluvia", "alta", 1.1)
	var u2: Dictionary = V.uniformes("bosque", "lluvia", "alta", 1.1)
	_check(u1 == u2, "B4 uniformes() es determinista")
	_fin("B")


func _bloque_c() -> void:
	print("-- C: cotas")
	var max_err := 0.0
	var max_amp := 0.0
	for t in range(300):
		for bioma in ["playa", "pradera", "bosque", "montana", "ribera", "humedal", "cercanias"]:
			for clima in ["despejado", "nublado", "lluvia", "tormenta", "niebla", "nieve"]:
				var amp: float = V.amplitud(String(bioma), String(clima), "ultra")
				var d: Vector3 = V.desplazamiento(t, Vector3(float(t) * 3.0, 1.0, float(t) * -2.0), String(bioma), String(clima), 1.0, 0.5, "ultra")
				max_amp = maxf(max_amp, amp)
				max_err = maxf(max_err, d.length() - amp)
	_check(max_err <= 0.0001, "C1 |desplazamiento| <= amplitud en 12600 muestras (exceso max %.6f)" % max_err)
	_check(max_amp <= V.AMPLITUD_MAX, "C2 amplitud maxima %.3f <= techo del shader %.1f" % [max_amp, V.AMPLITUD_MAX])
	_check(V.amplitud("montana", "tormenta", "ultra") > 0.0, "C3 la amplitud nunca es 0 en el peor caso")
	_fin("C")


func _bloque_d() -> void:
	print("-- D: amplitud por bioma")
	var m: float = V.amplitud("montana", "despejado", "ultra")
	var p: float = V.amplitud("playa", "despejado", "ultra")
	var pr: float = V.amplitud("pradera", "despejado", "ultra")
	var b: float = V.amplitud("bosque", "despejado", "ultra")
	_check(m > p, "D1 montana (%.3f) > playa (%.3f)" % [m, p])
	_check(p > pr, "D2 playa (%.3f) > pradera (%.3f)" % [p, pr])
	_check(pr > b, "D3 pradera (%.3f) > bosque (%.3f)" % [pr, b])
	_check(V.amplitud("humedal", "despejado", "ultra") < b, "D4 humedal (el mas quieto) < bosque")
	_fin("D")


func _bloque_e() -> void:
	print("-- E: amplitud por clima")
	var t: float = V.amplitud("pradera", "tormenta", "ultra")
	var ll: float = V.amplitud("pradera", "lluvia", "ultra")
	var n: float = V.amplitud("pradera", "nublado", "ultra")
	var d: float = V.amplitud("pradera", "despejado", "ultra")
	var ni: float = V.amplitud("pradera", "niebla", "ultra")
	_check(t > ll, "E1 tormenta (%.3f) > lluvia (%.3f)" % [t, ll])
	_check(ll > n, "E2 lluvia (%.3f) > nublado (%.3f)" % [ll, n])
	_check(n > d, "E3 nublado (%.3f) > despejado (%.3f)" % [n, d])
	_check(d > ni, "E4 despejado (%.3f) > niebla (%.3f)" % [d, ni])
	_fin("E")


func _bloque_f() -> void:
	print("-- F: la base no se mueve, la cima se mueve mas")
	var pos := Vector3(100.0, 2.0, 50.0)
	var base: Vector3 = V.desplazamiento(77, pos, "montana", "tormenta", 0.0, 0.0, "ultra")
	_check(base == Vector3.ZERO, "F1 uv_y=0 -> desplazamiento nulo (la base queda clavada)")
	var medio: Vector3 = V.desplazamiento(77, pos, "montana", "tormenta", 0.5, 0.0, "ultra")
	var cima: Vector3 = V.desplazamiento(77, pos, "montana", "tormenta", 1.0, 0.0, "ultra")
	_check(cima.length() > medio.length(), "F2 la cima (%.4f) se mueve mas que el medio (%.4f)" % [cima.length(), medio.length()])
	_check(absf(medio.length() * 2.0 - cima.length()) <= 0.0001, "F3 el perfil es lineal en uv_y (medio = cima/2)")
	_fin("F")


func _bloque_g() -> void:
	print("-- G: multiplicador por preset")
	var u: float = V.amplitud("bosque", "lluvia", "ultra")
	var a: float = V.amplitud("bosque", "lluvia", "alta")
	var m: float = V.amplitud("bosque", "lluvia", "media")
	var b: float = V.amplitud("bosque", "lluvia", "baja")
	_check(u > a and a > m and m > b, "G1 ultra (%.3f) > alta (%.3f) > media (%.3f) > baja (%.3f)" % [u, a, m, b])
	_check(absf(m - u * 0.45) <= 0.0001, "G2 media = 45%% de ultra (tabla de budgets.json)")
	_check(absf(b - u * 0.2) <= 0.0001, "G3 baja = 20%% de ultra (tabla de budgets.json)")
	_check(V.amplitud("montana", "tormenta", "ultra") <= V.AMPLITUD_MAX, "G4 ni el preset mas alto rompe el techo")
	_fin("G")


func _bloque_h() -> void:
	print("-- H: fallback y contrato de uniforms")
	var d1: Vector3 = V.desplazamiento(10, Vector3.ZERO, "bioma_que_no_existe", "clima_que_no_existe", 1.0, 0.0)
	var d2: Vector3 = V.desplazamiento(10, Vector3.ZERO, V.BIOMA_DEF, V.CLIMA_DEF, 1.0, 0.0, V.PRESET_DEF)
	_check(d1 == d2, "H1 bioma/clima desconocido cae al default determinista")
	var u: Dictionary = V.uniformes("playa", "tormenta", "ultra", 2.5)
	var claves_ok := u.has("amplitud") and u.has("frecuencia") and u.has("direccion_viento") and u.has("fase") and u.has("capa_mask")
	_check(claves_ok, "H2 uniformes() declara los 5 uniforms del shader (amplitud/frecuencia/direccion_viento/fase/capa_mask)")
	var fr: float = float(u["frecuencia"])
	_check(fr >= 0.1 and fr <= 5.0, "H3 frecuencia %.3f dentro del hint_range(0.1, 5.0) del shader" % fr)
	var dir: Vector3 = u["direccion_viento"]
	_check(absf(dir.length() - 1.0) <= 0.001, "H4 direccion_viento normalizada (len=%.4f)" % dir.length())
	_check(absf(float(u["fase"]) - 2.5) <= 0.0001, "H5 la fase pedida se respeta")
	_check(absf(V.fase_de_item(0) - 0.0) <= 0.0001 and V.fase_de_item(7) > 0.0 and V.fase_de_item(7) < TAU,
		"H6 fase_de_item(seed) cae en [0, TAU) y es determinista por semilla")
	_fin("H")


func _bloque_i() -> void:
	print("-- I: el viento avanza con el tick")
	var pos := Vector3(0.0, 1.0, 0.0)
	var t0: Vector3 = V.desplazamiento(0, pos, "pradera", "despejado", 1.0, 0.0, "ultra")
	var t1: Vector3 = V.desplazamiento(1, pos, "pradera", "despejado", 1.0, 0.0, "ultra")
	var t0b: Vector3 = V.desplazamiento(0, pos, "pradera", "despejado", 1.0, 0.0, "ultra")
	_check(t0 != t1, "I1 tick 0 y tick 1 dan viento distinto (el viento se mueve)")
	_check(t0 == t0b, "I2 volver al tick 0 reproduce el valor original (no hay estado)")
	# 20 ticks = 1 s: la fase debe haber avanzado frecuencia * 1 s.
	var t20: Vector3 = V.desplazamiento(20, pos, "pradera", "despejado", 1.0, 0.0, "ultra")
	var esperado := sin(1.0 * V.frecuencia("pradera")) * V.amplitud("pradera", "despejado", "ultra")
	_check(absf(t20.length() - absf(esperado)) <= 0.0001, "I3 20 ticks = 1 s de fase (|d|=%.5f, esperado %.5f)" % [t20.length(), absf(esperado)])
	_fin("I")


func _summary() -> void:
	if not _terminado:
		_fallos += 1
		print("!! _run() no termino (posible SCRIPT ERROR que aborto la funcion)")
	var faltan: Array = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltan.append(b)
	if not faltan.is_empty():
		_fallos += 1
		print("!! bloques NO ejecutados: %s" % str(faltan))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("!! solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	print("TEST %s" % ("OK" if _fallos == 0 else "FALLIDO"))
	quit(0 if _fallos == 0 else 1)
