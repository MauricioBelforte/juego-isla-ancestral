# M49 Iluminación iter. 2 — LightPool (pool de luces dinámicas).
# Modelo: stepfun-step-5-Preview (Kilo Code)
# Fecha: 2026-10-12
#
# Verifica 03-Diseno.md §1 (dynamic/light_pool.gd) y §3.2:
#   * MAX_DINAMICAS = 20, MAX_CONT_SOMBRA = 6, RADIO_DESCARTE = 30 m
#   * flicker determinista (fase + semilla), <= 2 Hz y <= 15 %
#   * nunca deja la escena sin luz activa
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/world/test_light_pool_m49.gd

extends SceneTree

const CHECKS_MINIMOS: int = 34
const LP = preload("res://scripts/world/light_pool.gd")

var _checks: int = 0
var _fallos: int = 0
var _cerrados: int = 0
var _abiertos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var pool = LP.new()
	root.add_child(pool)
	_test_limites(pool)
	_test_reutilizacion(pool)
	_test_topes(pool)
	_test_descarte(pool)
	_test_flicker(pool)
	_test_catalogo(pool)
	print("")
	print("=== RESUMEN M49 LIGHT POOL: %d checks, %d fallos ===" % [_checks, _fallos])
	print("Bloques cerrados: %d / abiertos: %d (minimo %d)" % [_cerrados, _abiertos, CHECKS_MINIMOS])
	if _fallos == 0 and _checks >= CHECKS_MINIMOS and _abiertos == 0:
		print("RESULTADO: PASS")
		quit(0)
	else:
		print("RESULTADO: FAIL")
		quit(1)

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _bloque(desc: String) -> void:
	_cerrados += 1
	print("-- %s" % desc)

# ── pruebas ──────────────────────────────────────────────────────────────

func _test_limites(pool) -> void:
	_bloque("1. Límites del diseño (§3.2)")
	_ok(LP.MAX_DINAMICAS == 20, "MAX_DINAMICAS = 20")
	_ok(LP.MAX_CONT_SOMBRA == 6, "MAX_CONT_SOMBRA = 6")
	_ok(LP.RADIO_DESCARTE == 30.0, "RADIO_DESCARTE = 30 m")
	_ok(LP.FLICKER_HZ_MAX == 2.0, "flicker <= 2 Hz")
	_ok(LP.FLICKER_AMPLITUD_MAX == 0.15, "flicker amplitud <= 15 %")
	var cat: Dictionary = LP.TIPOS
	_ok(cat.size() >= 4, "catálogo con >= 4 tipos (%d)" % cat.size())
	_ok(cat.has("luz_farol") and cat.has("luz_fuego"), "tipos de luz definidos")
	_ok(cat.has("luz_cristal") and cat.has("linterna"), "linterna definida")

func _test_reutilizacion(pool) -> void:
	_bloque("2. Reutilización de entradas")
	var a = pool.obtener("luz_farol", Vector3(0, 0, 0))
	_ok(a != null, "primera luz creada")
	_ok(int(pool.stats()["creadas"]) == 1, "1 creada (dio %d)" % int(pool.stats()["creadas"]))
	pool.liberar(a)
	var st: Dictionary = pool.stats()
	_ok(int(st["libres"]) == 1, "queda libre tras liberar")
	_ok(int(st["activas"]) == 0, "ninguna activa")
	var b = pool.obtener("luz_farol", Vector3(5, 0, 0))
	_ok(b == a, "reutiliza la misma entrada (no crea otra)")
	_ok(int(pool.stats()["creadas"]) == 1, "sigue habiendo 1 creada")
	_ok(int(b.usos) == 2, "contador de usos incrementado (%d)" % int(b.usos))
	pool.vaciar()

func _test_topes(pool) -> void:
	_bloque("3. Topes: 20 totales / 6 con sombra")
	for i in range(LP.MAX_DINAMICAS):
		var e = pool.obtener("luz_cristal", Vector3(i, 0, 0))
		if e == null:
			_ok(false, "cristal %d creada" % i)
			return
	var st: Dictionary = pool.stats()
	_ok(int(st["activas"]) == LP.MAX_DINAMICAS, "20 activas exactas (dio %d)" % int(st["activas"]))
	# La 21 se rechaza: NO se roba una activa.
	var extra = pool.obtener("luz_cristal", Vector3(99, 0, 0))
	_ok(extra == null, "la 21 se rechaza (no roba activas)")
	_ok(int(pool.stats()["rechazos_tope"]) == 1,
		"rechazo contado (dio %d)" % int(pool.stats()["rechazos_tope"]))
	# Tope de sombra: 6 con sombra, el resto degrada sin sombra.
	pool.vaciar()
	var con_sombra: int = 0
	var sin_sombra: int = 0
	for i in range(12):
		var e = pool.obtener("luz_fuego", Vector3(i * 2, 0, 0))
		if e == null:
			continue
		if e.con_sombra:
			con_sombra += 1
		else:
			sin_sombra += 1
	_ok(con_sombra == LP.MAX_CONT_SOMBRA, "solo %d con sombra (dio %d)" % [LP.MAX_CONT_SOMBRA, con_sombra])
	_ok(sin_sombra == 6, "las demás degradan sin sombra (dio %d)" % sin_sombra)
	_ok(int(pool.stats()["con_sombra"]) <= LP.MAX_CONT_SOMBRA, "nunca se pasa el tope de sombra")
	pool.vaciar()

func _test_descarte(pool) -> void:
	_bloque("4. Descarte por distancia 30 m (M61)")
	for i in range(5):
		pool.obtener("luz_cristal", Vector3(i * 60, 0, 0))
	var apagadas_a: int = pool.desactivar_lejanas(Vector3.ZERO, LP.RADIO_DESCARTE)
	_ok(apagadas_a == 4, "apaga las 4 fuera de radio (dio %d)" % apagadas_a)
	_ok(int(pool.stats()["activas"]) == 1, "queda 1 activa (la cercana)")
	_ok(int(pool.stats()["descartes"]) == apagadas_a, "descartes contados")
	# Todas fuera de radio -> NO apaga nada (regla anti-oscuridad).
	pool.vaciar()
	for i in range(3):
		pool.obtener("luz_cristal", Vector3(1000 + i * 60, 0, 0))
	var apagadas_b: int = pool.desactivar_lejanas(Vector3.ZERO, LP.RADIO_DESCARTE)
	_ok(apagadas_b == 0, "con todas fuera no apaga ninguna (dio %d)" % apagadas_b)
	_ok(int(pool.stats()["activas"]) == 3, "las 3 siguen activas")
	# La cámara se acerca: las otras dos quedan fuera de radio.
	var apagadas_c: int = pool.desactivar_lejanas(Vector3(1000, 0, 0), LP.RADIO_DESCARTE)
	_ok(apagadas_c == 2, "con la cámara cerca, apaga las 2 lejanas (dio %d)" % apagadas_c)
	_ok(int(pool.stats()["activas"]) == 1, "queda solo la cercana")
	pool.vaciar()

func _test_flicker(pool) -> void:
	_bloque("5. G56/H63: flicker determinista")
	pool.set_semilla(777)
	var a = pool.obtener("luz_fuego", Vector3(3, 0, 3))
	var b = pool.obtener("luz_fuego", Vector3(3, 0, 3))
	_ok(a.fase == b.fase, "misma posición -> misma fase")
	var c = pool.obtener("luz_fuego", Vector3(9, 0, 9))
	_ok(c.fase != a.fase, "distinta posición -> distinta fase")
	var p2 = LP.new()
	root.add_child(p2)
	p2.set_semilla(777)
	var d = p2.obtener("luz_fuego", Vector3(3, 0, 3))
	_ok(d.fase == a.fase, "misma semilla -> mismo flicker (determinista)")
	p2.free()
	# Amplitud acotada.
	var f_min: float = 1.0
	var f_max: float = 1.0
	for i in range(200):
		var f: float = pool.flicker(a, float(i) * 0.05)
		f_min = minf(f_min, f)
		f_max = maxf(f_max, f)
	_ok(f_min >= 1.0 - LP.FLICKER_AMPLITUD_MAX - 0.001, "amplitud mínima >= 1-15%% (%.4f)" % f_min)
	_ok(f_max <= 1.0 + LP.FLICKER_AMPLITUD_MAX + 0.001, "amplitud máxima <= 1+15%% (%.4f)" % f_max)
	# Luz sin flicker y entrada nula.
	var l = pool.obtener("linterna", Vector3(0, 0, 0))
	_ok(pool.flicker(l, 1.23) == 1.0, "linterna (sin flicker) devuelve 1.0")
	_ok(pool.flicker(null, 1.0) == 1.0, "entrada nula -> 1.0 (no crashea)")
	pool.vaciar()

func _test_catalogo(pool) -> void:
	_bloque("6. Catálogo de tipos")
	for tipo in ["luz_farol", "luz_fuego", "luz_cristal", "linterna"]:
		var e = pool.obtener(tipo, Vector3.ZERO)
		_ok(e != null, "tipo %s obtenible" % tipo)
	var cfg_hz: Dictionary = LP.TIPOS["luz_fuego"]
	_ok(float(cfg_hz["hz"]) <= LP.FLICKER_HZ_MAX, "luz_fuego respeta 2 Hz")
	_ok(float(cfg_hz["amplitud"]) <= LP.FLICKER_AMPLITUD_MAX, "luz_fuego respeta 15 %")
	_ok(bool(LP.TIPOS["luz_cristal"]["sombra"]) == false, "luz_cristal no lleva sombra")
	_ok(bool(LP.TIPOS["luz_farol"]["sombra"]) == true, "luz_farol lleva sombra")
	_ok(pool.contar_con_sombra_publico() >= 0, "contador de sombra público disponible")
	pool.vaciar()
