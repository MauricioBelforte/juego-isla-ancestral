# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M24: Test headless del framework de puzzles (validacion de no-arbitrariedad).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzles.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	_test_puzzle_presion_valido()
	_test_puzzle_arbitrario_invalido()
	_test_transiciones_y_completado()
	_test_emisor_inexistente()
	_test_integracion_emisor_puerta()  # M24 QA cruzado Hy3/WorkBuddy iter 1
	print("=== TEST PUZZLES M24: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

## Puzzle valido: 2 placas (emisores 0,1) — la puerta abierta requiere ambas ON.
## Y un emisor debe poder estar OFF: aqui claramente hay solucion unica (ambas ON).
func _test_puzzle_presion_valido() -> void:
	var sala := PuzzleRoom.new([0, 1])
	sala.add_regla([0, 1], "puerta")
	_check(sala.validar().is_empty(), "puzzle de presion valido (sin errores)")
	sala.set_emisor(0, true)
	var activos := sala.recalcular()
	_check(activos.is_empty(), "con 1 emisor ON no se completa (aun no es objetivo)")
	_check(not sala.completada, "no completada con 1 emisor ON")
	sala.set_emisor(1, true)
	sala.recalcular()
	_check(sala.completada, "con ambos ON la sala se completa")
	_check("puerta" in sala.recalcular(), "receptor puerta activo al completar")
	_check(sala.progreso() == 1, "progreso = 1 regla cumplida")

## Puzzle arbitrario: sin reglas o reglas con emisores inexistentes -> invalido
func _test_puzzle_arbitrario_invalido() -> void:
	var vacio := PuzzleRoom.new([3])
	_check(not vacio.validar().is_empty(), "sala sin reglas es invalida (arbitraria)")
	var mal := PuzzleRoom.new([0])
	mal.add_regla([99], "puerta")
	_check(not mal.validar().is_empty(), "regla con emisor inexistente es invalida")
	var conj_vacio := PuzzleRoom.new([0])
	conj_vacio.add_regla([], "puerta")
	_check(not conj_vacio.validar().is_empty(), "regla con conjunto vacio es invalida")

func _test_transiciones_y_completado() -> void:
	var sala := PuzzleRoom.new([0])
	sala.add_regla([0], "altar")
	sala.set_emisor(0, false)
	_check(not sala.completada, "estado inicial no completado")
	sala.toggle_emisor(0)
	sala.recalcular()
	_check(sala.completada, "toggle a ON completa el puzzle")
	sala.toggle_emisor(0)
	sala.recalcular()
	_check(not sala.completada, "toggle a OFF revierte el estado")

func _test_emisor_inexistente() -> void:
	var sala := PuzzleRoom.new([0, 1])
	sala.set_emisor(5, true)
	_check(sala.emisores.size() == 2, "set_emisor con id inexistente no amplia la sala")

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

## M24 (QA cruzado Hy3/WorkBuddy, iter 1): integracion emisor->receptor.
## Verifica que activar emisores dispare el recalculo y abra la puerta via callback.
## Antes de este fix el framework estaba desconectado: set_emisor no recalculaba ni
## notificaba, asi que la puerta nunca se enteraba de los cambios.
func _test_integracion_emisor_puerta() -> void:
	var sala := PuzzleRoom.new([0, 1])
	sala.add_regla([0, 1], "puerta_norte")
	var puerta := PuzzlePuerta.new()
	puerta.nombre_receptor = "puerta_norte"
	# Conectar el callback de la sala a la puerta.
	sala.al_cambiar = func(activos: Array): puerta.evaluar(activos)
	_check(not puerta.abierta, "puerta arranca cerrada")
	# Activar emisor 0 solo -> no debe abrir (falta el 1).
	sala.set_emisor(0, true)
	_check(not puerta.abierta, "con 1 emisor ON la puerta sigue cerrada")
	# Activar emisor 1 -> ambos ON -> regla cumple -> callback abre la puerta.
	sala.set_emisor(1, true)
	_check(puerta.abierta, "con ambos emisores ON la puerta se ABRE automaticamente")
	# Desactivar uno -> la sala ya no cumple; la puerta no se cierra sola (diseno:
	# abrir es permanente hasta cerrar() explicito), pero el test verifica el disparo.
	sala.set_emisor(0, false)
	_check(puerta.abierta, "puerta permanece abierta tras desactivar (abierta es latch)")
	puerta.cerrar()
	_check(not puerta.abierta, "cerrar() resella la puerta")
