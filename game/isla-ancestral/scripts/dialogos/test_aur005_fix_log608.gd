# Modelo: Hy3
# Plataforma: WorkBuddy
# Fecha: 2026-09-04
#
# M162: Verificacion RUNTIME del FIX de Log 608 (iter 3b, Hy3 / WorkBuddy)
# para el Viajero Misterioso (aur_005).
#
# El fallback DIURNO (prioridad 0, es_noche == False) del Viajero Misterioso
# debe devolver el grafo de DIA ("No estoy aqui durante el dia..."), NO el
# grafo de NOCHE ("...Solo aparezco de noche..."). Antes del fix, la entrada
# DLG-AUR_005-CAP0-SALUDO-DIA apuntaba al mismo grafo que la noche.
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#           --script res://scripts/dialogos/test_aur005_fix_log608.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	_test_fix_aur005_dia()
	print("=== TEST AUR005 FIX LOG 608: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

func _texto_n0(grafo: Dictionary) -> String:
	if grafo.has("nodes"):
		var n0 = grafo["nodes"].get("n0", {})
		return str(n0.get("text_key", ""))
	return ""

func _test_fix_aur005_dia() -> void:
	# --- Seleccion NOCTURNA (es_noche == true) -> grafo de noche ---
	var r_noche := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO",
		{"flag_capitulo": 0, "es_noche": true})
	_check(r_noche.ok, "Viajero seleccionado de noche")
	var t_noche := _texto_n0(r_noche.graph)
	_check(t_noche.contains("Solo aparezco de noche"),
		"NOCHE devuelve texto de noche (baseline): '%s'" % t_noche)

	# --- Seleccion DIURNA (es_noche == false) -> fallback prioridad 0 ---
	var r_dia := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO",
		{"flag_capitulo": 0, "es_noche": false})
	_check(r_dia.ok, "Viajero fallback diurno ok")
	_check(r_dia.entry.get("prioridad", 0) == 0, "Viajero diurno es fallback (prioridad 0)")
	var t_dia := _texto_n0(r_dia.graph)
	_check(t_dia.contains("No estoy aquí durante el día"),
		"FIX Log 608: DIA devuelve TEXTO DE DIA: '%s'" % t_dia)
	_check(not t_dia.contains("Solo aparezco de noche"),
		"FIX Log 608: DIA NO devuelve texto de noche")
