# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-02
#
# M63: Cargas y Streaming — Suite de la iter. 6 (Log 1193)
# Cubre lo añadido en esta iteración (§6: consejos rotando + fundido).
# NO reemplaza a las suites previas (test_stream.gd, test_stream_m63.gd,
# test_stream_m63_iter5.gd, test_pausa_cargas.gd, test_pantalla_carga.gd,
# test_rf2_threaded.gd).
#
# Guardián anti-falso-verde de 3 capas (skill §2, trampas 11/28/61/63/119):
#   1. marcadores `_fin("X")` por bloque → nombra el bloque que no corrió;
#   2. piso `CHECKS_MINIMOS` MEDIDO en verde → caza el aborto en un helper;
#   3. `_summary()` en un `call_deferred` APARTE → si `_run()` aborta por un
#      SCRIPT ERROR, la cola diferida sigue y el resumen igual se imprime.
#
# Qué cierra (checklist §G, L98/L99):
#   A. ConsejosCarga.parsear: comentarios/blancos/orden (§6)
#   B. ConsejosCarga.indice_inicial: determinismo y rango por semilla (M29)
#   C. ConsejosCarga.consejo: rotación con wrap
#   D. ConsejosCarga.cargar: tips.txt real + degradación sin archivo
#   E. FundidoCarga: máquina de estados del fade (§6)
#   F. Integración PantallaCarga: consejos + fundido sobre el autoload
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/stream/test_stream_m63_iter6.gd

extends SceneTree

const MODULO := "M63-iter6"
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F"]
## Piso MEDIDO en verde (42 checks, Log 1193), NO copiado. Bajar el conteo
## (bloque abortado por SCRIPT ERROR o borrado) dispara el FAIL del piso.
const CHECKS_MINIMOS := 42

const Consejos := preload("res://scripts/stream/consejos_carga.gd")
const Fundido := preload("res://scripts/stream/fundido_carga.gd")
const RUTA_TIPS := "res://data/stream/tips.txt"

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== [M63] Suite iter. 6 (Log 1193) ===")
	_bloque_a_parsear()
	_bloque_b_indice()
	_bloque_c_consejo()
	_bloque_d_cargar()
	_bloque_e_fundido()
	_bloque_f_integracion()


## ── A. ConsejosCarga.parsear (§6) ────────────────────────────────────────
func _bloque_a_parsear() -> void:
	print("--- A. Consejos: parseo de tips.txt ---")
	var texto := "# cabecera\n\n  Frase uno  \nFrase dos\n   \n# nota\nFrase tres\n"
	var tips: PackedStringArray = Consejos.parsear(texto)
	_check("se ignoran comentarios y lineas en blanco (quedan 3)", tips.size() == 3,
		"n=%d" % tips.size())
	_check("el ORDEN se preserva", tips.size() == 3 and tips[0] == "Frase uno" and tips[1] == "Frase dos" and tips[2] == "Frase tres",
		"%s" % str(tips))
	_check("se recortan los espacios de cada frase", tips.size() > 0 and tips[0] == "Frase uno",
		"0='%s'" % (tips[0] if tips.size() > 0 else ""))
	_check("texto vacio -> 0 consejos", Consejos.parsear("").size() == 0)
	_check("solo comentarios -> 0 consejos", Consejos.parsear("# a\n# b\n").size() == 0)
	_fin("A")


## ── B. ConsejosCarga.indice_inicial (§6, semilla M29) ────────────────────
func _bloque_b_indice() -> void:
	print("--- B. Consejos: indice por semilla (M29) ---")
	var i_a: int = Consejos.indice_inicial(12345, 10)
	var i_b: int = Consejos.indice_inicial(12345, 10)
	_check("misma semilla -> mismo indice (determinista)", i_a == i_b, "%d vs %d" % [i_a, i_b])
	_check("el indice cae en [0, n-1]", i_a >= 0 and i_a < 10, "i=%d" % i_a)
	_check("n <= 0 -> indice 0", Consejos.indice_inicial(12345, 0) == 0
		and Consejos.indice_inicial(12345, -3) == 0)
	# El mezclado NO es constante: 20 semillas contiguas deben repartirse.
	var distintos := {}
	for s in range(1, 21):
		distintos[Consejos.indice_inicial(s, 10)] = true
	_check("semillas contiguas se reparten (>= 5 indices distintos de 20)",
		distintos.size() >= 5, "distintos=%d" % distintos.size())
	# Y no es el trivial 'semilla % n' (que daria indices contiguos 1,2,3...).
	var trivial := true
	for s in range(0, 10):
		if Consejos.indice_inicial(s, 10) != s:
			trivial = false
	_check("el indice NO es el trivial 'semilla % n'", trivial == false)
	_fin("B")


## ── C. ConsejosCarga.consejo (rotación) ──────────────────────────────────
func _bloque_c_consejo() -> void:
	print("--- C. Consejos: rotacion ---")
	var tips := PackedStringArray(["A", "B", "C", "D"])
	_check("tick 0 da un consejo", Consejos.consejo(tips, 7, 0) != "")
	_check("el consejo pertenece a la lista",
		["A", "B", "C", "D"].has(Consejos.consejo(tips, 7, 0)))
	_check("tick avanza al siguiente (rota)",
		Consejos.consejo(tips, 7, 0) != Consejos.consejo(tips, 7, 1))
	_check("la rotacion da la vuelta (tick n == tick 0)",
		Consejos.consejo(tips, 7, 4) == Consejos.consejo(tips, 7, 0),
		"%s vs %s" % [Consejos.consejo(tips, 7, 4), Consejos.consejo(tips, 7, 0)])
	_check("lista vacia -> consejo vacio", Consejos.consejo(PackedStringArray(), 7, 0) == "")
	_fin("C")


## ── D. ConsejosCarga.cargar (tips.txt real + degradación) ────────────────
func _bloque_d_cargar() -> void:
	print("--- D. Consejos: carga de tips.txt ---")
	var tips: PackedStringArray = Consejos.cargar(RUTA_TIPS)
	_check("tips.txt real carga consejos (n > 0)", tips.size() > 0, "n=%d" % tips.size())
	var todas_ok := tips.size() > 0
	for t in tips:
		if t.strip_edges() == "" or t.begins_with("#"):
			todas_ok = false
	_check("ninguna entrada es vacia ni comentario", todas_ok)
	_check("archivo inexistente -> vacio (degradacion)",
		Consejos.cargar("res://data/stream/no_existe_%d.txt" % Time.get_ticks_usec()).size() == 0)
	_check("ruta vacia -> vacio", Consejos.cargar("").size() == 0)
	_fin("D")


## ── E. FundidoCarga (máquina de estados del fade, §6) ────────────────────
func _bloque_e_fundido() -> void:
	print("--- E. Fundido: maquina de estados ---")
	var f := Fundido.new()
	_check("recien creado: INACTIVO", f.estado() == Fundido.Estado.INACTIVO)
	_check("INACTIVO -> alpha 1.0 (opaco)", is_equal_approx(f.alpha(), 1.0), "a=%.3f" % f.alpha())
	f.iniciar(0.4)
	_check("iniciar() -> FUNDIENDO", f.estado() == Fundido.Estado.FUNDIENDO)
	_check("al iniciar, alpha sigue 1.0", is_equal_approx(f.alpha(), 1.0), "a=%.3f" % f.alpha())
	f.avanzar(0.2)
	_check("a mitad, alpha ~ 0.5", absf(f.alpha() - 0.5) < 0.01, "a=%.3f" % f.alpha())
	# Monotonía: alpha nunca sube.
	var prev := f.alpha()
	var monotono := true
	for i in range(5):
		f.avanzar(0.05)
		if f.alpha() > prev + 0.0001:
			monotono = false
		prev = f.alpha()
	_check("alpha es monotonamente decreciente", monotono)
	_check("al completar -> TERMINADO", f.terminado() == true, "estado=%d" % f.estado())
	_check("TERMINADO -> alpha 0.0", is_equal_approx(f.alpha(), 0.0), "a=%.3f" % f.alpha())
	_check("progreso() en [0,1]", f.progreso() >= 0.0 and f.progreso() <= 1.0, "p=%.3f" % f.progreso())
	# delta negativo no retrocede
	var f2 := Fundido.new()
	f2.iniciar(0.4)
	f2.avanzar(0.2)
	var a1 := f2.alpha()
	f2.avanzar(-1.0)
	_check("delta negativo NO retrocede el fundido", is_equal_approx(f2.alpha(), a1),
		"%.3f -> %.3f" % [a1, f2.alpha()])
	# idempotencia: re-iniciar reinicia el reloj
	f2.iniciar(0.4)
	_check("re-iniciar reinicia el reloj (alpha vuelve a 1.0)", is_equal_approx(f2.alpha(), 1.0),
		"a=%.3f" % f2.alpha())
	# duracion <= 0 -> terminado inmediato
	var f3 := Fundido.new()
	f3.iniciar(0.0)
	_check("duracion 0 -> TERMINADO inmediato", f3.terminado() == true and is_equal_approx(f3.alpha(), 0.0))
	# acotar_duracion respeta el tope §6 (2 s)
	_check("acotar_duracion(5.0) = DURACION_MAX (2 s)",
		is_equal_approx(Fundido.acotar_duracion(5.0), Fundido.DURACION_MAX),
		"%.3f" % Fundido.acotar_duracion(5.0))
	_check("acotar_duracion(-1.0) = 0", is_equal_approx(Fundido.acotar_duracion(-1.0), 0.0))
	_fin("E")


## ── F. Integración sobre el autoload PantallaCarga ───────────────────────
func _bloque_f_integracion() -> void:
	print("--- F. Integracion: PantallaCarga (consejos + fundido) ---")
	var pc := root.get_node_or_null("PantallaCarga")
	_check("autoload PantallaCarga presente", pc != null)
	if pc == null:
		_fin("F")
		return
	_check("el nodo Consejos existe", pc.get_node_or_null("Consejos") != null)
	pc.configurar_seed(123)
	var c1: String = pc.consejo_actual()
	_check("configurar_seed() muestra un consejo no vacio", c1 != "", "c='%s'" % c1)
	pc.configurar_seed(999)
	pc.configurar_seed(123)
	_check("el consejo es determinista por semilla", pc.consejo_actual() == c1,
		"'%s' vs '%s'" % [pc.consejo_actual(), c1])
	# Fundido: mostrar -> fundir -> avanzar -> oculta.
	pc.mostrar()
	_check("mostrar() deja la pantalla visible", pc.visible == true)
	pc.fundir(0.2)
	_check("fundir(0.2) arranca el fundido", pc.fundiendo() == true)
	pc._process(0.1)
	_check("a mitad del fundido sigue visible", pc.visible == true, "alpha=%.3f" % pc.alpha_actual())
	pc._process(0.15)
	_check("al completarse el fundido, la pantalla se oculta", pc.visible == false)
	_check("el fundido quedo TERMINADO", pc.fundiendo() == false)
	_fin("F")


## ── Utilidades ───────────────────────────────────────────────────────────

func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


## Capa 3: corre SIEMPRE, aunque `_run()` haya abortado por un SCRIPT ERROR.
func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecutó (posible SCRIPT ERROR que abortó la función)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (mínimo medido en verde: %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con código 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — los %d checks pasaron" % [MODULO, _checks])
		quit(0)
