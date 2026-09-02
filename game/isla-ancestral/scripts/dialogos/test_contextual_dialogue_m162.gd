# Modelo: Hy3
# Plataforma: WorkBuddy
# Fecha: 2026-09-01
#
# M162: Test headless de diálogos contextuales.
# 1) Valida cada grafo generado con DialogGraphValidator (mismas reglas de M21).
# 2) Prueba el selector de prioridad + fallback de ContextualDialogueManager.
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_contextual_dialogue_m162.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	_test_validacion_grafos()
	_test_seleccion_prioridad()
	_test_seleccion_viajero_noche()
	_test_seleccion_fallback()
	print("=== TEST M162 DIALOGOS CONTEXTUALES: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

func _test_validacion_grafos() -> void:
	var reg := ContextualDialogueManager._cargar_registry()
	_check(not reg.is_empty(), "registry cargado")
	var ok := 0
	var total := 0
	for e in reg.get("entries", []):
		total += 1
		var path := "res://data/dialogues/contextual/" + str(e.get("graph", ""))
		var res := DialogGraphValidator.validar_archivo(path)
		if res.ok:
			ok += 1
		else:
			_check(false, "grafo invalido %s: %s" % [path, res.get("problemas", [])])
	print("  grafos validados: %d/%d OK" % [ok, total])
	_check(ok == total and total > 0, "todos los grafos validos")

func _test_seleccion_prioridad() -> void:
	# Mayor cap0, PRIMAVERA, primera vez -> variante primavera (prioridad 3)
	var ctx_prim := {"flag_capitulo": 0, "flag_riz_001_visitado": false, "estacion": "PRIMAVERA"}
	var r1 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "SALUDO", ctx_prim)
	_check(r1.ok, "seleccion Mayor primavera ok")
	_check(str(r1.entry.get("id", "")).ends_with("CAP0-SALUDO"), "es SALUDO cap0")
	_check(r1.entry.get("prioridad", 0) == 3, "prioridad 3 (variante primavera)")

	# Mayor cap0, VERANO, primera vez -> primera vez (prioridad 2, primavera no aplica)
	var ctx_verano := {"flag_capitulo": 0, "flag_riz_001_visitado": false, "estacion": "VERANO"}
	var r2 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "SALUDO", ctx_verano)
	_check(r2.entry.get("prioridad", 0) == 2, "prioridad 2 (primera vez, primavera no aplica)")

	# Mayor cap0, ya visitado -> repetido (prioridad 1; primera vez falla por flag)
	var ctx_repeat := {"flag_capitulo": 0, "flag_riz_001_visitado": true}
	var r3 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "SALUDO", ctx_repeat)
	_check(r3.ok, "seleccion Mayor repetido ok")
	_check(r3.entry.get("prioridad", 0) == 1, "prioridad 1 (repetido, fallback de primera vez)")

func _test_seleccion_viajero_noche() -> void:
	# Viajero Misterioso solo de noche
	var ctx_noche := {"flag_capitulo": 0, "es_noche": true}
	var r := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO", ctx_noche)
	_check(r.ok, "Viajero seleccionado de noche")
	_check(str(r.entry.get("id", "")).ends_with("CAP0-SALUDO"), "Viajero SALUDO cap0")

	var ctx_dia := {"flag_capitulo": 0, "es_noche": false}
	var r2 := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO", ctx_dia)
	_check(r2.ok, "Viajero fallback diurno ok")
	_check(r2.entry.get("prioridad", 0) == 0, "Viajero diurno es fallback (prioridad 0)")

func _test_seleccion_fallback() -> void:
	# NPC secundario solo tiene SALUDO cap0 -> lo devuelve aunque pidamos HISTORIA
	var reg := ContextualDialogueManager._cargar_registry()
	var r := ContextualDialogueManager.seleccionar("NPC-COR-001", "SALUDO",
		{"flag_capitulo": 0})
	_check(r.ok, "Herrero COR SALUDO cap0 disponible")
	_check(r.graph.get("id", "") != "", "grafo con id devuelto")

	# Iter 2: el contenido de capítulos 1-7 (y HISTORIA/MISION/AMBIENTE de cap0) ya
	# se generó para todos los NPCs. COR-001 AHORA tiene HISTORIA cap0.
	var r2 := ContextualDialogueManager.seleccionar("NPC-COR-001", "HISTORIA",
		{"flag_capitulo": 0})
	_check(r2.ok, "Herrero COR HISTORIA cap0 disponible (iter 2)")
	_check(r2.graph.get("id", "") != "", "grafo HISTORIA con id devuelto")

	# Las variantes por amistad/estacion/hora siguen pendientes ([?]): un HISTORIA con
	# amistad alta debe seguir resolviendo a la variante base (prioridad 1), no a una
	# variante especifica que no existe.
	var r3 := ContextualDialogueManager.seleccionar("NPC-COR-001", "HISTORIA",
		{"flag_capitulo": 0, "amistad_cor_001": 95})
	_check(r3.ok, "Herrero COR HISTORIA con amistad alta resuelve a base")
	_check(r3.entry.get("prioridad", 0) == 1, "sin variante de amistad aun (prioridad base 1)")
