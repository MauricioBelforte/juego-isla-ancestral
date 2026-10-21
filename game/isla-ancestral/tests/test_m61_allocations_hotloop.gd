# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-21
#
# M61 — "Validar cero allocations en lazo caliente" (RF25 / item X390).
#
# El camino caliente del mundo voxel es `IslandGenerator.get_block_at()` -> `_has_ore()`.
# El Log 1755 (atria) detecto que `_has_ore` hacia `FastNoiseLite.new()` **en cada bloque
# subterraneo** y lo arreglo preconstruyendo el ruido una sola vez en `_setup_noises()`.
#
# ⚠️ LIMITACION HONESTA (importante): Godot 4 NO expone un contador de allocations, asi que
# "cero allocations" NO se puede medir directamente en headless. Y comparar TIEMPOS entre
# dos bucles con trabajo DISTINTO no sirve (medido: el lazo real del generador tarda mas
# que un lazo que solo asigna un FastNoiseLite, porque hace altura + bioma + mineral).
# Por eso este probe mide lo que SI es verificable de forma determinista:
#
#   (1) ESTRUCTURAL: el cuerpo de las funciones del camino caliente NO puede construir
#       objetos (`.new(`) — si alguien reintroduce la regresion, el probe se pone ROJO.
#   (2) ANTI-FALSO-VERDE: el MISMO detector, aplicado a una version SINTETICA y
#       regresionada del codigo, tiene que detectarla. Si el detector no ve la regresion
#       sintetica, el probe FALLA (metodo ciego).
#   (3) FUNCIONAL: el lazo real produce bloques validos (no es un no-op).
#   (4) El tiempo del lazo se imprime como DATO, no como aserto (no comparable).
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m61_allocations_hotloop.gd
# Exit: 0 = verde medido | 1 = fallos

extends SceneTree

const MODULO := "M61 allocations en lazo caliente"
const RUTA_GENERADOR := "res://scripts/world/island_generator.gd"
const ITERACIONES := 2000
const CHECKS_MINIMOS := 8

var _checks := 0
var _fallos := 0


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Extrae el cuerpo de una funcion del fuente (por indentacion) como texto plano.
func _cuerpo_fuente(nombre_funcion: String) -> String:
	var s := FileAccess.get_file_as_string(RUTA_GENERADOR)
	var ls := s.split("\n")
	var out: Array[String] = []
	var dentro := false
	for l in ls:
		if not dentro:
			if l.lstrip(" \t").begins_with("func %s(" % nombre_funcion):
				dentro = true
			continue
		if l.lstrip(" \t").begins_with("func "):
			break
		out.append(l)
	return "\n".join(out)


## EL DETECTOR: una funcion del camino caliente asigna objetos por llamada si su cuerpo
## construye objetos (`.new(`). Este es el unico criterio verificable sin contador de
## allocations; el anti-falso-verde de mas abajo prueba que el detector NO es ciego.
func _detecta_asignacion_por_llamada(cuerpo: String) -> bool:
	return cuerpo.contains(".new(")


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ── (1) ESTRUCTURAL sobre el codigo REAL ──
	var f_has_ore := _cuerpo_fuente("_has_ore")
	var f_get_block := _cuerpo_fuente("get_block_at")
	var f_setup := _cuerpo_fuente("_setup_noises")
	_check("el generador tiene _has_ore", f_has_ore.strip_edges() != "")
	_check("el camino caliente NO asigna por llamada (_has_ore sin '.new(')",
		not _detecta_asignacion_por_llamada(f_has_ore),
		"'.new(' encontrados: %d" % f_has_ore.count(".new("))
	_check("el camino caliente NO asigna por llamada (get_block_at sin '.new(')",
		not _detecta_asignacion_por_llamada(f_get_block),
		"'.new(' encontrados: %d" % f_get_block.count(".new("))
	_check("el ruido de mineral se PRECONSTRUYE una sola vez (_setup_noises)",
		f_setup.contains("FastNoiseLite.new()") and f_setup.contains("_ore_noise"),
		"_setup_noises construye _ore_noise: %s" % str(f_setup.contains("_ore_noise")))
	_check("_has_ore USA el ruido preconstruido (no vuelve a crearlo)",
		f_has_ore.contains("_ore_noise") and not f_has_ore.contains("FastNoiseLite"),
		"usa _ore_noise: %s" % str(f_has_ore.contains("_ore_noise")))

	# ── (2) ANTI-FALSO-VERDE: el detector DEBE ver una regresion sintetica ──
	var regresado := f_has_ore.replace("return", "var _ruido = FastNoiseLite.new()\n\treturn")
	_check("el detector VE la regresion sintetica (metodo NO es ciego)",
		_detecta_asignacion_por_llamada(regresado),
		"la version regresada inyecta %d '.new('" % regresado.count(".new("))
	var regresado_2 := f_get_block.replace("return", "var _r2 = FastNoiseLite.new()\n\treturn")
	_check("el detector VE la regresion sintetica en get_block_at",
		_detecta_asignacion_por_llamada(regresado_2),
		"la version regresada inyecta %d '.new('" % regresado_2.count(".new("))

	# ── (3) FUNCIONAL: el lazo real hace trabajo de verdad ──
	var cat := BlockCatalog.new()
	var gen := IslandGenerator.new(cat, 42)
	for i in 40:
		gen.get_block_at(i, 5, i)
	var suma := 0
	var t0 := Time.get_ticks_usec()
	for i in ITERACIONES:
		var x := (i * 7) % 512 - 256
		var z := (i * 13) % 512 - 256
		# y = -1 es roca madre (id 4) segun el analisis de M62; se barre un pequeño
		# rango de alturas para que el lazo toque aire, suelo y subsuelo.
		for y in [-1, 0, 1, 2, 3, 4]:
			suma += gen.get_block_at(x, y, z)
	var t_real := Time.get_ticks_usec() - t0
	print("   lazo real: %d us / %d iteraciones (%.2f us/llamada) — DATO, no aserto"
		% [t_real, ITERACIONES, float(t_real) / float(ITERACIONES)])
	_check("el lazo real produjo bloques validos (no es un no-op)", suma != 0,
		"suma=%d" % suma)

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — el lazo caliente no asigna objetos por llamada" % MODULO)
		quit(0)
