# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M110 (Debug Menu) - suite de la CAPTURA DE ENTORNO del diagnostico
# (seccion J del 05-Checklist): seed de generacion, posicion del jugador,
# hora / estacion / clima y specs de video.
#
# Contexto: los 4 items de la seccion J estaban marcados `[x]` citando
# `_build_metadata()` como evidencia, pero esa funcion NO capturaba ninguno
# de los cuatro. Esta suite prueba la captura REAL (fail-closed cuando la
# fuente no existe) y el guardia EN ROJO por inyeccion.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/debug/test_debug_menu_entorno_m110.gd
#
# Guardas anti-falso-verde (3 capas, skill isla-ancestral-ciclo-modulo):
#   1. `_fin(bloque)` al FINAL del cuerpo de cada bloque (NO en el runner).
#   2. `CHECKS_MINIMOS` = piso MEDIDO en verde (nunca estimado).
#   3. `_summary()` en un `call_deferred` SEPARADO: si `_run()` aborta por un
#      SCRIPT ERROR, el resumen corre igual, nombra los bloques faltantes y
#      sale con EXIT 1 en vez de colgarse.
#
# La suite NO agrega el menu al arbol: instancia el script y usa los hooks
# `_inyectar_generador()` / `_inyectar_player()`.

extends SceneTree

const MODULO := "M110"
const MENU := preload("res://scripts/debug/debug_menu.gd")
const RUTA_SCRIPT := "res://scripts/debug/debug_menu.gd"

## Bloques esperados (los nombres que usa `_fin`)
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F"]

## Piso MEDIDO en verde. Re-medir si la suite crece; nunca estimar.
const CHECKS_MINIMOS: int = 61

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _menu: Node = null
var _texto_script: String = ""


## Generador falso: `world_seed` SIN tipo para poder inyectar int, float y
## String (un literal mal tipado seria PARSE ERROR estatico y no probaria el
## guardia de runtime).
class FakeGen extends Node:
	var world_seed: Variant = 0


class FakePlayer extends Node3D:
	pass


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")  # corre aunque _run() aborte (SCRIPT ERROR)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("[FIN] bloque %s (acumulado %d checks)" % [bloque, _checks])


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_checks += 1
		_fallos += 1
		print("[FALLO] solo %d checks ejecutados (minimo medido %d)"
			% [_checks - 1, CHECKS_MINIMOS])
	print("=== Resumen %s entorno: %d checks, %d fallo(s) ==="
		% [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _run() -> void:
	_menu = MENU.new()
	_texto_script = FileAccess.get_file_as_string(RUTA_SCRIPT)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	if _menu != null:
		_menu.free()
		_menu = null


func _gen(valor: Variant) -> Node:
	var g := FakeGen.new()
	g.world_seed = valor
	return g


func _player_en(x: float, y: float, z: float) -> Node3D:
	var p := FakePlayer.new()
	p.global_position = Vector3(x, y, z)
	return p


func _usa_en_codigo(fragmento: String) -> bool:
	## Ignora lineas de comentario: el nombre del API removido aparece en la
	## nota que documenta el fix, y eso NO es un uso.
	for linea in _texto_script.split("\n"):
		var l := linea.strip_edges()
		if l.begins_with("#"):
			continue
		if l.contains(fragmento):
			return true
	return false


## ── A. Fail-closed: sin fuentes en el arbol ────────────────────────────────
## En `--script` no hay escena de mundo ni autoloads: toda fuente falta.
## La captura debe devolver el CENTINELA, no ceros inventados.
func _bloque_a() -> void:
	_check(_menu.seed_generacion() == -1,
		"A1 sin generador, seed_generacion() devuelve el centinela -1")
	_check(_menu.posicion_jugador().is_empty(),
		"A2 sin jugador, posicion_jugador() devuelve {} (no ceros)")
	_check(_menu.hora_actual() == -1, "A3 sin GameTime, hora_actual() = -1")
	_check(_menu.estacion_actual() == -1, "A4 sin GameTime, estacion_actual() = -1")
	_check(_menu.clima_actual().is_empty(), "A5 sin Weather, clima_actual() = {}")
	var specs: Dictionary = _menu.specs_video()
	_check(typeof(specs.get("gpu")) == TYPE_STRING,
		"A6 specs_video() trae 'gpu' como String")
	_check(typeof(specs.get("gpu_vendor")) == TYPE_STRING,
		"A7 specs_video() trae 'gpu_vendor' como String")
	var disp: Dictionary = _menu.entorno_disponible()
	_check(disp.get("generador") == false, "A8 entorno_disponible().generador false")
	_check(disp.get("jugador") == false, "A9 entorno_disponible().jugador false")
	_check(disp.get("reloj") == false, "A10 entorno_disponible().reloj false")
	_check(disp.get("clima") == false, "A11 entorno_disponible().clima false")
	var ent: Dictionary = _menu._capturar_entorno()
	_check(ent.size() >= 9, "A12 _capturar_entorno() devuelve 9 claves (medido %d)"
		% ent.size())
	_fin("A")


## ── B. Seed de generacion (L-J1) ───────────────────────────────────────────
func _bloque_b() -> void:
	_menu._inyectar_generador(_gen(12345))
	_check(_menu.seed_generacion() == 12345,
		"B1 lee world_seed del generador (12345)")
	## Valor DINAMICO: si la captura fuera una constante, este check falla.
	(_menu._generador_inyectado as FakeGen).world_seed = 54321
	_check(_menu.seed_generacion() == 54321,
		"B2 relee en vivo: cambiar world_seed cambia la captura (54321)")
	_menu._inyectar_generador(_gen(777.0))
	_check(_menu.seed_generacion() == 777,
		"B3 un world_seed float se convierte a int (777)")
	_menu._inyectar_generador(_gen("no-es-un-seed"))
	_check(_menu.seed_generacion() == -1,
		"B4 un world_seed String cae al centinela (fail-closed por tipo)")
	_menu._inyectar_generador(Node.new())
	_check(_menu.seed_generacion() == -1,
		"B5 un nodo SIN world_seed cae al centinela")
	_menu._inyectar_generador(_gen(4242))
	_check(_menu.entorno_disponible().get("generador") == true,
		"B6 con generador inyectado, entorno_disponible().generador true")
	_menu._inyectar_generador(null)
	_check(_menu.seed_generacion() == -1,
		"B7 _inyectar_generador(null) vuelve al descubrimiento real (sin fuente)")
	_fin("B")


## ── C. Posicion del jugador (L-J2) ─────────────────────────────────────────
## OJO (medido 2026-10-28): `global_position` de un Node3D FUERA del arbol
## devuelve Transform3D() con un ERROR de engine, o sea (0,0,0). Por eso el
## camino real se prueba con el nodo DENTRO del arbol, y el caso fuera del
## arbol se prueba como fail-closed.
func _bloque_c() -> void:
	var p1 := _player_en(1.5, 2.5, -3.5)
	root.add_child(p1)
	_menu._inyectar_player(p1)
	var pos: Dictionary = _menu.posicion_jugador()
	_check(is_equal_approx(float(pos.get("x", 0.0)), 1.5), "C1 posicion.x = 1.5")
	_check(is_equal_approx(float(pos.get("y", 0.0)), 2.5), "C2 posicion.y = 2.5")
	_check(is_equal_approx(float(pos.get("z", 0.0)), -3.5), "C3 posicion.z = -3.5")
	_check(pos.size() == 3, "C4 el diccionario trae exactamente x/y/z")
	## Fail-closed: fuera del arbol `global_position` MIENTE con ceros.
	_menu._inyectar_player(_player_en(9.0, 9.0, 9.0))
	_check(_menu.posicion_jugador().is_empty(),
		"C5 un Node3D FUERA del arbol devuelve {} (no ceros inventados)")
	_menu._inyectar_player(Node.new())
	_check(_menu.posicion_jugador().is_empty(),
		"C6 un nodo SIN global_position devuelve {}")
	## Vector3.ZERO real, DENTRO del arbol: no se confunde con 'sin jugador'.
	var pz := _player_en(0.0, 0.0, 0.0)
	root.add_child(pz)
	_menu._inyectar_player(pz)
	var cero: Dictionary = _menu.posicion_jugador()
	_check(cero.size() == 3 and is_equal_approx(float(cero.get("x", 9.0)), 0.0),
		"C7 un Vector3.ZERO real (en arbol) SI se distingue de 'sin jugador'")
	_check(_menu.entorno_disponible().get("jugador") == true,
		"C8 con jugador inyectado, entorno_disponible().jugador true")
	_menu._inyectar_player(null)
	_check(_menu.posicion_jugador().is_empty(), "C9 reset: vuelve a {}")
	root.remove_child(p1)
	p1.free()
	root.remove_child(pz)
	pz.free()
	_fin("C")


## ── D. Integracion: la metadata del diagnostico lleva el entorno ───────────
func _bloque_d() -> void:
	_menu._inyectar_generador(_gen(98765))
	var pj := _player_en(4.0, 5.0, 6.0)
	root.add_child(pj)
	_menu._inyectar_player(pj)
	var meta: Dictionary = _menu._build_metadata()
	for clave in ["seed_generacion", "posicion_jugador", "hora", "estacion",
			"clima", "clima_nombre", "gpu", "gpu_vendor", "entorno_disponible"]:
		_check(meta.has(clave), "D1 la metadata incluye la clave '%s'" % clave)
	## Conexion REAL: no basta que la clave exista, tiene que llevar el valor.
	_check(int(meta.get("seed_generacion", 0)) == 98765,
		"D2 meta.seed_generacion lleva el seed inyectado (98765)")
	var mp: Dictionary = meta.get("posicion_jugador", {})
	_check(is_equal_approx(float(mp.get("y", -1.0)), 5.0),
		"D3 meta.posicion_jugador lleva la posicion inyectada (y=5)")
	_check(meta.get("hora") == -1 and meta.get("estacion") == -1,
		"D4 sin GameTime, hora y estacion van al centinela (no a 0)")
	_check(meta.get("clima") == -1,
		"D5 sin Weather, el clima va al centinela")
	## No rompio la metadata previa (regresion sobre lo que ya funcionaba).
	for clave in ["version_juego", "plataforma", "comandos_ejecutados", "resolucion"]:
		_check(meta.has(clave), "D6 conserva la clave previa '%s'" % clave)
	_menu._inyectar_generador(null)
	_menu._inyectar_player(null)
	root.remove_child(pj)
	pj.free()
	_fin("D")


## ── E. El guardia EN ROJO (no tautologico) ─────────────────────────────────
func _bloque_e() -> void:
	_menu._inyectar_generador(_gen(1))
	var v1: int = _menu.seed_generacion()
	(_menu._generador_inyectado as FakeGen).world_seed = 2
	var v2: int = _menu.seed_generacion()
	_check(v1 != v2,
		"E1 ROJO: dos seeds distintos dan capturas distintas (%d != %d)" % [v1, v2])
	_check(v2 != -1,
		"E2 con generador presente el seed NO es el centinela (captura no vacia)")
	## Un seed real -1 colisiona con el centinela: lo que desambigua es el flag.
	(_menu._generador_inyectado as FakeGen).world_seed = -1
	_check(_menu.seed_generacion() == -1
			and _menu.entorno_disponible().get("generador") == true,
		"E3 seed real -1: el centinela se desambigua con entorno_disponible()")
	_check(typeof(_menu._capturar_entorno().get("entorno_disponible")) == TYPE_DICTIONARY,
		"E4 _capturar_entorno() embebe el mapa de disponibilidad (auditable)")
	_menu._inyectar_generador(null)
	_fin("E")


## ── F. Guardas ESTATICAS del archivo ───────────────────────────────────────
func _bloque_f() -> void:
	_check(_texto_script.length() > 0, "F1 se pudo leer el script")
	_check(_texto_script.contains("_capturar_entorno()"),
		"F2 _build_metadata() llama a _capturar_entorno()")
	_check(not _usa_en_codigo("OS.get_video_adapter_name"),
		"F3 NO usa OS.get_video_adapter_name en CODIGO (removido en Godot 4)")
	_check(_texto_script.contains("RenderingServer.get_video_adapter_name"),
		"F4 usa RenderingServer.get_video_adapter_name")
	for nombre in ["func seed_generacion()", "func posicion_jugador()",
			"func hora_actual()", "func estacion_actual()",
			"func clima_actual()", "func specs_video()",
			"func entorno_disponible()"]:
		_check(_texto_script.contains(nombre), "F5 API presente: %s" % nombre)
	var i_cap := _texto_script.find("func _capturar_entorno()")
	var i_meta := _texto_script.find("func _build_metadata()")
	_check(i_cap > 0 and i_meta > i_cap,
		"F6 _capturar_entorno() se define antes de _build_metadata()")
	_fin("F")
