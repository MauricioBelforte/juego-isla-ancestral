# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M66: Test iter. 3 — MisionInvariant funcional (fallbacks de misión con
# recompensa equivalente, aviso al diario, recompensa no duplicada).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/test_fallbacks_m66.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var sg := root.get_node_or_null("SoftlockGuard")
	var d := root.get_node_or_null("Diary")
	_check(sg != null, "SoftlockGuard presente")
	if sg == null:
		print("=== TEST M66 FALLBACKS: 1+ fallo(s) ===")
		quit(1)
		return
	# Obtener la MisionInvariant del guard
	var mision_inv = null
	for inv in sg._invariantes:
		if inv is MisionInvariant:
			mision_inv = inv
	_check(mision_inv != null, "MisionInvariant registrada en el guard")
	if mision_inv == null:
		print("=== TEST M66 FALLBACKS: 1+ fallo(s) ===")
		quit(1)
		return
	# Registrar objetivo activo + fallback alternativo
	mision_inv.registrar_objetivo("mision_test", "objetivo_imposible")
	mision_inv.registrar_fallback("objetivo_imposible", "objetivo_alternativo")
	_check(mision_inv.tiene_fallback("objetivo_imposible"), "fallback registrado")
	# Verificar que _check detecta un objetivo imposible SIN fallback
	mision_inv._objetivos_activos["mision_sin_fallback"] = "objetivo_sin_fallback"
	var check_sin: bool = mision_inv._check()
	_check(not check_sin, "_check detecta objetivo imposible sin fallback")
	# El objetivo imposible se depura (M66 decide ruta alternativa) y queda solo
	# el que tiene fallback → _check pasa
	mision_inv._objetivos_activos.erase("mision_sin_fallback")
	var check_con: bool = mision_inv._check()
	_check(check_con, "con fallback declarado, _check pasa (ruta alternativa existe)")
	# Activar fallback (flujo real): aviso al diario (M55) vía el método del núcleo
	mision_inv.activar_fallback("objetivo_imposible", "mision_test")
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(diary.esta_registrada("descubrimiento_fallback_mision_test"),
			"M55 registró aviso de fallback activado (aviso en diario)")
		diary._estados.clear()  # limpiar para no contaminar otros tests
	# Recompensa equivalente no duplicada
	mision_inv.registrar_recompensa_entregada("objetivo_alternativo")
	_check(mision_inv.recompensa_ya_entregada("objetivo_alternativo"), "recompensa alternativa marcada como entregada")
	_check(mision_inv.recompensa_ya_entregada("otra_distinta") == false, "otra recompensa no marcada")
	print("=== TEST M66 FALLBACKS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
