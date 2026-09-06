# Modelo: Hy3 / WorkBuddy
# Fecha: 2026-09-04
# M162 (T-M162-003, Log 665): test headless de robustez de ContextualDialogueManager.seleccionar.
# Verifica que contextos vacios / con claves faltantes / NPC inexistente NO crashean
# y resuelven via fallback (o devuelven ok=false controlado).

extends SceneTree

var _fallos := 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("[OK]   " + msg)
	else:
		_fallos += 1
		printerr("[FAIL] " + msg)

func _init() -> void:
	# 1) Contexto VACIO -> fallback al grafo base (sin condiciones) para RIZ-001 SALUDO.
	var r1 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "SALUDO", {})
	_check(r1.get("ok", false), "contexto vacio: seleccionar devuelve ok=true (fallback base)")
	_check(r1.get("graph", {}).size() > 0, "contexto vacio: grafo base no vacio")

	# 2) Contexto con claves FALTANTES (no todas las del registry) -> no crashea,
	#    aplica prioridad+fallback normalmente.
	var r2 := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO", {"es_noche": false})
	_check(r2.get("ok", false) == true, "claves faltantes (solo es_noche): ok=true, sin crash")

	# 3) NPC INEXISTENTE -> ok=false controlado, sin exception.
	var r3 := ContextualDialogueManager.seleccionar("NPC-NO-EXISTE", "SALUDO", {})
	_check(r3.get("ok", false) == false, "NPC inexistente: ok=false (controlado, no crash)")
	_check(r3.get("error", "") != "", "NPC inexistente: trae mensaje de error")

	# 4) TIPO inexistente para un NPC valido -> ok=false controlado.
	var r4 := ContextualDialogueManager.seleccionar("NPC-RIZ-001", "TIPO_INEXISTENTE_XYZ", {})
	_check(r4.get("ok", false) == false, "tipo inexistente: ok=false (controlado)")

	# 5) Regresion dia/noche aur_005 (Log 608) sigue intacta tras el hardening.
	var r_n := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO", {"flag_capitulo": 0, "es_noche": true})
	var r_d := ContextualDialogueManager.seleccionar("NPC-AUR-005", "SALUDO", {"flag_capitulo": 0, "es_noche": false})
	var txt_n: String = ""
	var txt_d: String = ""
	if r_n.get("graph", {}).has("nodes"):
		txt_n = str(r_n["graph"]["nodes"].get("n0", {}).get("text_key", ""))
	if r_d.get("graph", {}).has("nodes"):
		txt_d = str(r_d["graph"]["nodes"].get("n0", {}).get("text_key", ""))
	_check(txt_n.contains("Solo aparezco de noche"), "aur_005 noche: texto de NOCHE intacto")
	_check(txt_d.contains("No estoy aquí durante el día"), "aur_005 dia: texto de DIA intacto")

	print("\n=== test_m162_robustez: %d fallo(s) ===" % _fallos)
	quit(0 if _fallos == 0 else 1)
