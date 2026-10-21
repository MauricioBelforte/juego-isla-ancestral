# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-10-24
#
# M72 t2: test del gate RF2 (depende_de) de AchievementService.
# Verifica: un logro con depende_de solo se desbloquea cuando TODAS sus
# dependencias ya estan desbloqueadas; luego es idempotente.
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/logros/test_logros_depende_de_m72.gd

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
	print("=== M72: test_logros_depende_de_m72 (gate RF2) ===")
	var ach = root.get_node_or_null("Achievements")
	_check(ach != null, "Achievements autoload presente (M72)")
	if ach == null:
		print("=== M72 depende_de: %d checks, %d fallos ===" % [1, _fallos])
		quit(1 if _fallos > 0 else 0)
		return

	# Estado inicial (proceso fresco): ninguno desbloqueado.
	_check(not ach.esta_desbloqueado("logro_primer_sello"), "primer_sello no desbloqueado al inicio")
	_check(not ach.esta_desbloqueado("logro_siete_sellos"), "siete_sellos no desbloqueado al inicio")

	# Gate negativo: siete_sellos depende de primer_sello (aun no cumplida) -> NO desbloquea.
	var neg: bool = ach.desbloquear("logro_siete_sellos")
	_check(neg == false, "GATE RF2: siete_sellos NO se desbloquea si su dep (primer_sello) falta")
	_check(not ach.esta_desbloqueado("logro_siete_sellos"), "siete_sellos sigue bloqueado tras el intento con dep pendiente")

	# Cumplir la dep: primer_sello (no tiene deps propias) -> desbloquea.
	var pos_dep: bool = ach.desbloquear("logro_primer_sello")
	_check(pos_dep == true, "primer_sello se desbloquea (sin deps pendientes)")

	# Gate positivo: ahora la dep esta cumplida -> siete_sellos SI desbloquea.
	var pos: bool = ach.desbloquear("logro_siete_sellos")
	_check(pos == true, "GATE RF2: siete_sellos SI se desbloquea con la dep cumplida")

	# Idempotencia: repetir -> false.
	var rep: bool = ach.desbloquear("logro_siete_sellos")
	_check(rep == false, "siete_sellos es idempotente (2do desbloquear = false)")

	print("=== M72: 6 checks, %d fallos ===" % _fallos)
	quit(_fallos)
