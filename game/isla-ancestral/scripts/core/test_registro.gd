# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M05: Test headless de la utilidad Registro
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/test_registro.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	Registro.reiniciar_contadores()
	Registro.info("TEST", "mensaje informativo")
	Registro.aviso("TEST", "mensaje de aviso")
	Registro.error("TEST", "mensaje de error")
	_check(Registro.avisos == 1, "contador de avisos")
	_check(Registro.errores == 1, "contador de errores")
	_check(Registro.verificar(true, "TEST", "no debe fallar"), "verificar(true) devuelve true")
	_check(Registro.errores == 1, "verificar(true) no incrementa errores")
	_check(not Registro.verificar(false, "TEST", "debe fallar"), "verificar(false) devuelve false")
	_check(Registro.errores == 2, "verificar(false) incrementa errores")
	Registro.reiniciar_contadores()
	_check(Registro.errores == 0 and Registro.avisos == 0, "reiniciar_contadores")
	_check(Registro.verificar_no_nulo(self, "TEST", "objeto valido"), "verificar_no_nulo con objeto")
	_check(not Registro.verificar_no_nulo(null, "TEST", "nulo"), "verificar_no_nulo con null")
	print("=== TEST REGISTRO M05: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)
