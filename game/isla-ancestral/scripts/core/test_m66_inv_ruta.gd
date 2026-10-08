# M66 (test helper, agnes-3-flash 2026-10-08): invariante ROTA de control.
# Inyectada en SoftlockGuard._invariantes para probar la cascada de recovery rota
# (estado_invalido_detectado + consulta del handler). Ahora viable: el fix de BUG-123
# en softlock_guard.gd:133 (get de 1 arg) evita el error de runtime que antes
# abortaba _check_and_recover cuando una invariante estaba rota.
class_name M66InvRuta
extends InvariantBase

func _init() -> void:
	categoria = 0
	ultima_razon = ""

## Control: siempre rota → forzar_chequeo emite estado_invalido_detectado.
func _check() -> bool:
	return false

func _razon_fallo() -> String:
	return "M66 invariante rota de control (test)"
