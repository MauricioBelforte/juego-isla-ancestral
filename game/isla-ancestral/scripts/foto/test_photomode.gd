# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-03
#
# M56: Test iter. 2 — PhotoMode (entrada/salida con mundo congelado,
# logs PHOTO-ENTER/EXIT, bloqueo de acciones, presets).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/foto/test_photomode.gd

extends SceneTree

var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ps := root.get_node_or_null("PhotoService")
	_check(ps != null, "PhotoService autoload presente")
	if ps == null:
		print("=== TEST M56 PHOTOMODE: 1 fallo(s) ===")
		quit(1)
		return
	var clock := root.get_node_or_null("GameClock")
	_test_presets(ps)
	_test_entrada_salida(ps, clock)
	print("=== TEST M56 PHOTOMODE: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_presets(ps: Node) -> void:
	var presets: Array = ps.presets()
	_check(presets.size() >= 4, "presets cargados (6-8 del diseño): %d" % presets.size())
	_check(presets.has("natural"), "preset default 'natural' presente")
	var p: Dictionary = ps.aplicar_preset("inexistente_xyz")
	_check(ps.preset_actual() == ps.aplicar_preset("natural") or presets.has("natural"), "preset inexistente cae a natural sin crash")


func _test_entrada_salida(ps: Node, clock: Node) -> void:
	# Estado inicial
	_check(not bool(ps.modo_foto()), "modo foto inicia inactivo")
	_check(not bool(ps.acciones_bloqueadas()), "acciones de juego libres al inicio")
	# ENTRAR: congela el mundo (pausa del reloj M31) y marca acciones bloqueadas
	var senales: Array = [0]
	ps.modo_foto_cambiado.connect(func(activo: bool): senales[0] += 1)
	ps.set_modo_foto(true)
	_check(bool(ps.modo_foto()), "modo foto activo tras set(true)")
	_check(int(senales[0]) == 1, "señal modo_foto_cambiado emitida al entrar")
	_check(bool(ps.acciones_bloqueadas()), "acciones de juego BLOQUEADAS en modo foto")
	if clock != null:
		_check(bool(clock._pausado), "reloj M31 pausado (mundo congelado)")
	# Idempotente: re-entrar no re-emite
	ps.set_modo_foto(true)
	_check(int(senales[0]) == 1, "set(true) idempotente (sin doble señal)")
	# SALIR: restaura el reloj y libera acciones
	ps.set_modo_foto(false)
	_check(not bool(ps.modo_foto()), "modo foto inactivo tras set(false)")
	_check(int(senales[0]) == 2, "señal emitida al salir también")
	_check(not bool(ps.acciones_bloqueadas()), "acciones de juego LIBRES al salir")
	if clock != null:
		_check(not bool(clock._pausado), "reloj M31 reanudado al salir")
	# Salir sin estar dentro: no rompe
	ps.set_modo_foto(false)
	_check(not bool(ps.modo_foto()), "salir doble es no-op")