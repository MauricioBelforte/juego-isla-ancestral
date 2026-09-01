# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M22: Test de HistoriaService (gating, sellos, completado, finales, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/historia/test_historia.gd

extends SceneTree

var _fallos: int = 0
var _h: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_h = root.get_node_or_null("Historia")
	_check(_h != null, "Historia autoload presente")
	if _h == null:
		print("=== TEST M22 HISTORIA: 1 fallo(s) ===")
		quit(1)
		return
	_test_carga_grafo()
	_test_progresion_lineal()
	_test_gating_sellos()
	_test_flags_worldstate()
	_test_finales()
	_test_persistencia()
	print("=== TEST M22 HISTORIA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_carga_grafo() -> void:
	_check(_h.nodos_count() == 12, "12 nodos cargados: %d" % _h.nodos_count())
	_check(not _h.get_nodo("prologo").is_empty(), "nodo prologo existe")
	_check(_h.get_nodo("inexistente").is_empty(), "nodo inexistente = {}")
	_check(_h.capitulo_actual() == 0, "capítulo actual inicial = 0 (prólogo)")

func _test_progresion_lineal() -> void:
	# prologo → c1 → c2 → c3 requieren solo capítulos previos
	for paso in ["prologo", "c1", "c2", "c3"]:
		var res: Dictionary = _h.completar_nodo(paso)
		_check(bool(res.ok), "completar %s OK" % paso)
	_check(_h.capitulo_actual() == 4, "tras C3 el actual es 4 (C4 bloqueado por sellos)")
	# c4 con requisitos pendientes → rechazo con motivos
	var res4: Dictionary = _h.completar_nodo("c4")
	_check(not bool(res4.ok), "c4 rechazado sin sellos/templo")
	_check((res4.motivos as Array).size() >= 2, "motivos listados: %s" % str(res4.motivos))
	_check(not _h.esta_completado("c4"), "c4 no completado")

func _test_gating_sellos() -> void:
	_check(_h.sellos_totales() == 7, "7 sellos declarados")
	# sello desconocido rechazado
	_check(not _h.marcar_sello("sello_falso"), "sello inexistente rechazado")
	_check(not _h.marcar_sello(""), "sello vacío rechazado")
	# marcar los 7 reales (duplicado idempotente)
	for s in ["sello_ceniza_sala1", "sello_ceniza_sala2", "sello_mar_intermedia",
			"sello_mar_sala1", "sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]:
		_check(_h.marcar_sello(s), "sello marcado: %s" % s)
	_check(_h.marcar_sello("sello_ceniza_sala1"), "sello duplicado idempotente")
	_check(_h.sellos_count() == 7, "7 sellos contados (sin duplicados)")
	# c4 aún requiere flag de templo abierto
	var res: Dictionary = _h.completar_nodo("c4")
	_check(not bool(res.ok), "c4 aún bloqueado sin flag templo")

func _test_flags_worldstate() -> void:
	var ws := root.get_node_or_null("WorldState")
	_check(ws != null, "WorldState presente (M21)")
	if ws == null:
		return
	ws.set_flag("templo_brisa_abierto", true)
	_check(bool(_h.completar_nodo("c4").ok), "c4 abre con sellos + flag templo")
	for paso in ["c5", "c6", "c7"]:
		_check(bool(_h.completar_nodo(paso).ok), "completar %s OK" % paso)
	# finales: principal/regresar/guardian accesibles; secreto requiere flag
	var disp: Array = _h.siguientes_disponibles("c7")
	_check(disp.has("final_principal") and disp.has("final_regresar") and disp.has("final_guardian"),
		"3 finales base disponibles: %s" % str(disp))
	_check(not disp.has("final_secreto"), "final secreto bloqueado sin flag pistas")
	ws.set_flag("pistas_secreto_completas", true)
	_check(_h.siguientes_disponibles("c7").has("final_secreto"), "final secreto abre con flag pistas")

func _test_finales() -> void:
	var al_elegir: String = ""
	_check(bool(_h.completar_nodo("final_principal").ok), "elegir final principal OK")
	al_elegir = _h.final_elegido()
	_check(al_elegir == "principal", "final_elegido = principal (%s)" % al_elegir)
	_check(_h.capitulo_actual() == 7, "capítulo actual queda en 7 (fin)")

func _test_persistencia() -> void:
	var data: Dictionary = _h.get_save_data()
	_check(data.has("completados") and data.has("sellos") and data.has("final_elegido"),
		"save_data completo")
	_check(_h.get_section_name() == "historia", "sección 'historia'")
	# round-trip con servicio "fresco" simulado (restore tolerante)
	_h.restore_save_data({})
	_check(_h.sellos_count() == 0, "restore vacío resetea sellos")
	_h.restore_save_data(data)
	_check(_h.sellos_count() == 7 and _h.final_elegido() == "principal", "round-trip restaura estado")
