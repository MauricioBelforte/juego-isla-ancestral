# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M58: Test headless del AccesibilityManager.
# iter 1: RF1 daltonismo, RF19 presets, señales, persistencia M59/M57 pattern.
# iter 2: RF8 subtítulos por defecto, RF13 perfiles de control, RF18 pausa instantánea.
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
	# ═══ Iter. 2 ═══
	# RF8: subtítulos por defecto (activados, mediano, con fondo)
	var sub: Dictionary = am.get_subtitulos()
	_check(bool(sub.get("activado", false)), "RF8 subtítulos activados por defecto")
	_check(String(sub.get("tamano", "")) == "mediano", "RF8 tamaño mediano por defecto")
	_check(bool(sub.get("fondo", false)), "RF8 fondo activado por defecto")
	var sub_signal: Array = [false]
	am.subtitulos_changed.connect(func(_a: bool, _t: String, _f: bool): sub_signal[0] = true)
	_check(bool(am.set_subtitulos_tamano("grande")), "RF8 set_subtitulos_tamano(grande) OK")
	_check(String(am.get_subtitulos().get("tamano", "")) == "grande", "RF8 tamaño aplicado")
	_check(sub_signal[0], "RF8 subtitulos_changed emitida")
	_check(not bool(am.set_subtitulos_tamano("gigante")), "RF8 tamaño inválido rechazado")
	am.set_subtitulos(false, "pequeno", false)
	_check(not bool(am.get_subtitulos().get("activado", true)), "RF8 set_subtitulos(false) aplicado")
	am.reset_perfil()
	# RF13: perfiles de control
	_check(not bool(am.aplicar_perfil_control("inexistente")), "RF13 preset inexistente rechazado")
	_check(bool(am.aplicar_perfil_control("single_hand")), "RF13 aplicar single_hand OK")
	_check(not am.get_remap_control().is_empty(), "RF13 single_hand tiene remap")
	_check(bool(am.mantener_automatico()), "RF13 single_hand mantiene automático")
	_check(is_equal_approx(am.tiempo_mantener_multiplicador(), 1.5), "RF13 single_hand multiplicador 1.5")
	_check(bool(am.aplicar_perfil_control("low_mobility")), "RF13 aplicar low_mobility OK")
	_check(is_equal_approx(am.tiempo_mantener_multiplicador(), 2.0), "RF13 low_mobility multiplicador 2.0")
	_check(bool(am.aplicar_perfil_control("estandar")), "RF13 volver a estandar OK")
	_check(am.get_remap_control().is_empty(), "RF13 estandar sin remap")
	_check(not am.mantener_automatico(), "RF13 estandar sin mantener automático")
	_check(is_equal_approx(am.tiempo_mantener_multiplicador(), 1.0), "RF13 estandar multiplicador 1.0")
	# RF18: pausa instantánea
	_check(not bool(am.esta_pausado()), "RF18 juego no pausado al inicio")
	_check(bool(am.pausar_instantaneo()), "RF18 pausar_instantaneo OK")
	_check(bool(am.esta_pausado()), "RF18 árbol pausado")
	_check(bool(am.pausar_instantaneo()), "RF18 pausa idempotente")
	_check(bool(am.reanudar()), "RF18 reanudar OK")
	_check(not bool(am.esta_pausado()), "RF18 árbol reanudado")
	print("=== TEST M58 MANAGER: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
