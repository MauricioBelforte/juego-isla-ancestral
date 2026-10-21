# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-10-24
#
# M72 t3: test RF13 -- cada desbloqueo se registra en analytics (M104) + log (M103).
# Verifica que AchievementService.desbloquear() llama a AnalyticsDirector.registrar_evento().
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/logros/test_logros_rf13_m72.gd

extends SceneTree

var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("[OK] " + msg)
	else:
		_fallos += 1
		print("[FAIL] " + msg)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== M72 t3: test_logros_rf13_m72 (RF13 analytics M104) ===")
	var ach = root.get_node_or_null("Achievements")
	var an = root.get_node_or_null("AnalyticsDirector")
	_check(ach != null, "Achievements autoload presente (M72)")
	_check(an != null, "AnalyticsDirector autoload presente (M104)")
	if ach == null or an == null:
		print("=== M72 RF13: %d fallos ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return

	# Antes: contar eventos pendientes del buffer M104.
	var antes: int = int(an.eventos_pendientes())
	# Desbloquear un logro (uno que no tenga deps para que pase el gate).
	var ok: bool = ach.desbloquear("logro_primer_sello")
	_check(ok == true, "desbloquear(logro_primer_sello) devuelve true")
	# RF13: el evento 'logro_desbloqueado' debio agregarse al buffer (antes o +1).
	var despues: int = int(an.eventos_pendientes())
	_check(despues >= antes + 1, "RF13: M104 registro evento logro_desbloqueado (pendientes antes=%d despues=%d)" % [antes, despues])

	print("=== M72 RF13: %d checks, %d fallos ===" % [3, _fallos])
	quit(_fallos)
