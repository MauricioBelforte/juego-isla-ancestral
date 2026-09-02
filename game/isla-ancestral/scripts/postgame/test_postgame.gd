# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M75: Test de PostgameManager (activación vía M22, actividades data-driven,
# sugerencias rotativas sin FOMO, epílogo, persistencia M59).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/postgame/test_postgame.gd

extends SceneTree

var _fallos: int = 0
var _pg: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_pg = root.get_node_or_null("Postgame")
	_check(_pg != null, "PostgameManager autoload presente")
	if _pg == null:
		print("=== TEST M75 POSTGAME: 1 fallo(s) ===")
		quit(1)
		return
	_test_catalogo()
	_test_no_activo_al_inicio()
	_test_activacion_por_sellos()
	_test_actividades_disponibles()
	_test_sugerencias_rotativas()
	_test_epilogo()
	_test_persistencia()
	print("=== TEST M75 POSTGAME: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_catalogo() -> void:
	_check(_pg.get_section_name() == "postgame", "sección 'postgame' (M59)")
	var acts: Array = _pg.actividades_disponibles()
	_check(acts.size() == 7, "7 actividades del catálogo: %d" % acts.size())
	# IDs del diseño (RF2/RF3/RF4/RF5/RF6/RF7)
	var ids := {}
	for a in acts:
		ids[String(a.id)] = true
	for esperado in ["postgame_isla_este", "postgame_isla_flotante", "postgame_ruina_final",
			"postgame_vecinos_nuevos", "postgame_hibridacion", "postgame_especies_raras",
			"postgame_muebles_evento"]:
		_check(ids.has(esperado), "actividad esperada presente: %s" % esperado)


func _test_no_activo_al_inicio() -> void:
	# La historia no está terminada en el save limpio del test
	_pg.activo = false
	_check(not bool(_pg.activo), "postgame inactivo antes del final")


func _test_activacion_por_sellos() -> void:
	# M22 es la fuente de verdad §2.2: marcar 7 sellos → prereq_met → activación
	var h := root.get_node_or_null("Historia")
	_check(h != null, "Historia presente (M22)")
	if h == null:
		return
	var senales: Array = [0]
	var cb := func() -> void:
		senales[0] += 1
	_pg.postgame_activado.connect(cb)
	# Re-chequear estado actual de sellos (puede venir de tests previos)
	var ya := int(h.sellos_count())
	if ya < int(h.sellos_totales()):
		for s in ["sello_ceniza_sala1", "sello_ceniza_sala2", "sello_mar_intermedia",
				"sello_mar_sala1", "sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]:
			if not bool(h.sello_marcado(s)):
				h.marcar_sello(s)
	_pg._checar_activacion()
	_check(bool(_pg.activo), "postgame activado al completar sellos (fuente M22)")
	_check(int(senales[0]) == 1, "señal postgame_activado una sola vez: %d" % int(senales[0]))
	# Re-activación idempotente
	_pg.activar_postgame()
	_check(int(senales[0]) == 1, "activar_postgame idempotente")
	_pg.postgame_activado.disconnect(cb)


func _test_actividades_disponibles() -> void:
	var acts: Array = _pg.actividades_disponibles()
	_check(acts.size() == 7, "7 actividades en postgame")
	# Registrar una repetible 2 veces y una no-repetible
	_check(bool(_pg.registrar_actividad("postgame_vecinos_nuevos")), "registrar repetible OK")
	_check(bool(_pg.registrar_actividad("postgame_vecinos_nuevos")), "registrar repetible 2ª vez OK")
	_check(bool(_pg.registrar_actividad("postgame_ruina_final")), "registrar ruina OK")
	_check(not bool(_pg.registrar_actividad("inexistente")), "actividad desconocida rechazada")
	for a in acts:
		if String(a.id) == "postgame_vecinos_nuevos":
			_check(int(a.veces) == 2, "contador repetible = 2: %d" % int(a.veces))
		if String(a.id) == "postgame_ruina_final":
			_check(bool(a.hecha), "ruina marcada hecha (no repite)")


func _test_sugerencias_rotativas() -> void:
	var s1: Array = _pg.sugerir_que_sigue(3)
	_check(s1.size() == 3, "3 sugerencias: %d" % s1.size())
	# Determinista: misma llamada → mismo resultado (sin rand)
	var s2: Array = _pg.sugerir_que_sigue(3)
	_check(str(s1) == str(s2), "sugerencias deterministas (M94: sin FOMO)")
	# La señal emite las sugerencias
	var recibidas: Array = []
	var cb := func(arr: Array) -> void:
		recibidas = arr
	_pg.sugerencias_postgame.connect(cb)
	_pg.pedir_sugerencias()
	_check(recibidas.size() == 3, "señal sugerencias_postgame emitida")
	_pg.sugerencias_postgame.disconnect(cb)
	# No incluye la ruina ya hecha (no repite)
	var ids := {}
	for s in s1:
		ids[String(s.id)] = true
	_check(not ids.has("postgame_ruina_final"), "no sugiere actividad no-repetible ya hecha")


func _test_epilogo() -> void:
	_check(not bool(_pg.epilogo_visto), "epílogo no visto al inicio")
	_pg.marcar_epilogo_visto()
	_check(bool(_pg.epilogo_visto), "epílogo marcado visto (RF1/M92)")
	# Idempotente
	_pg.marcar_epilogo_visto()
	_check(bool(_pg.epilogo_visto), "marcar epílogo idempotente")


func _test_persistencia() -> void:
	var data: Dictionary = _pg.get_save_data()
	_check(int(data.get("version", 0)) == 1, "save_data versionado")
	_check(bool(data.get("activo", false)), "estado activo persistido")
	_check(bool(data.get("epilogo_visto", false)), "epílogo persistido")
	var hechas: Dictionary = data.get("actividades_hechas", {})
	_check(int(hechas.get("postgame_vecinos_nuevos", 0)) == 2, "contadores persistidos")
	# Round-trip sin re-emisión de señal
	var senales: Array = [0]
	var cb := func() -> void:
		senales[0] += 1
	_pg.postgame_activado.connect(cb)
	_pg.restore_save_data({})
	_check(not bool(_pg.activo), "restore vacío limpia")
	_pg.restore_save_data(data)
	_check(bool(_pg.activo), "round-trip restaura activo")
	_check(bool(_pg.epilogo_visto), "round-trip restaura epílogo")
	_check(int(senales[0]) == 0, "restore NO re-emite postgame_activado (§2.3)")
	_check(int(_pg._hechas.get("postgame_vecinos_nuevos", 0)) == 2, "round-trip restaura contadores")
	_pg.postgame_activado.disconnect(cb)