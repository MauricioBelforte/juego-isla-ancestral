# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M58: Test headless del AccesibilityManager (RF1 daltonismo, RF19 presets,
# señales profile_loaded/changed/reset, persistencia M59/M57 pattern).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/accesibilidad/test_accesibilidad_manager.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var am := root.get_node_or_null("AccesibilityManager")
	_check(am != null, "AccesibilityManager autoload presente")
	if am == null:
		print("=== TEST M58 MANAGER: 1 fallo(s) ===")
		quit(1)
		return
	# RF1: perfiles de daltonismo
	_check(bool(am.aplicar_perfil("protanopia")), "aplicar_perfil(protanopia) OK")
	_check(String(am.get_campo("daltonismo")) == "protanopia", "daltonismo=protanopia")
	_check(bool(am.aplicar_perfil("deuteranopia")), "aplicar_perfil(deuteranopia) OK")
	_check(String(am.get_campo("daltonismo")) == "deuteranopia", "daltonismo=deuteranopia")
	_check(bool(am.aplicar_perfil("tritanopia")), "aplicar_perfil(tritanopia) OK")
	_check(String(am.get_campo("daltonismo")) == "tritanopia", "daltonismo=tritanopia")
	# Perfil inexistente rechazado
	_check(not bool(am.aplicar_perfil("inexistente")), "perfil inexistente rechazado")
	# RF19: presets de dificultad
	_check(bool(am.aplicar_perfil("sereno")), "aplicar_perfil(sereno) OK")
	_check(String(am.get_campo("dificultad")) == "sereno", "dificultad=sereno")
	# RF21: texto grande en sereno
	_check(bool(am.get_campo("texto_grande")), "texto_grande=true en sereno")
	# Señales
	var cambios: Array = [0]
	am.profile_changed.connect(func(_n: String): cambios[0] += 1)
	am.aplicar_perfil("alto_contraste")
	_check(int(cambios[0]) >= 1, "profile_changed emitida")
	# Persistencia round-trip
	am.aplicar_perfil("protanopia")
	am.set_campo("texto_grande", true)
	# Simular recarga (el _cargar_perfil es privado, usamos get_perfil)
	var saved: Dictionary = am.get_perfil()
	_check(String(saved.get("daltonismo", "")) == "protanopia", "get_perfil round-trip")
	# Reset
	am.reset_perfil()
	_check(String(am.get_campo("dificultad")) == "estandar", "reset restaura estandar")
	print("=== TEST M58 MANAGER: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
