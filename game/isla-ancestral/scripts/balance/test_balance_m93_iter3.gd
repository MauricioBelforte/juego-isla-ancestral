# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M93: Test iteración 3 — coherencia de tablas completadas (friendship/quests/
# puzzles/unlocks/meta) contra BalanceService y M20/M22 reales.
# Complementa test_balance.gd y validate_balance.gd (núcleo Deepseek) — no los reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/balance/test_balance_m93_iter3.gd

extends SceneTree

var _fallos: int = 0
var _bal: Node = null
var _fs: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_bal = root.get_node_or_null("Balance")
	_fs = root.get_node_or_null("Friendship")
	_check(_bal != null, "Balance autoload presente")
	if _bal == null:
		print("=== TEST M93 ITER3: 1 fallo(s) ===")
		quit(1)
		return
	_test_version()
	_test_friendship()
	_test_quests()
	_test_puzzles()
	_test_unlocks()
	_test_rareza_pity()
	print("=== TEST M93 ITER3: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_version() -> void:
	var meta: Dictionary = _bal.obtener_meta()
	_check(str(meta.get("balance_version", "")) == "1.1.0",
		"balance_version 1.1.0 (%s)" % str(meta.get("balance_version")))
	_check(meta.has("rareza") and meta.has("rendimiento"), "meta con rareza/rendimiento/viajes")

func _test_friendship() -> void:
	var fr: Dictionary = _bal.get_friendship()
	_check(fr.has("generosidad_favorito"), "friendship: generosidad_favorito presente")
	var mult: float = float(fr.get("generosidad_favorito", {}).get("multiplicador", 0))
	_check(absf(mult - 3.0) < 0.01, "favorito x3 (checklist 82)")
	_check(fr.get("sin_decaimiento_por_ausencia", false) == true, "sin decaimiento por ausencia (M94, checklist 81)")
	var ben: Dictionary = fr.get("beneficios_por_nivel", {})
	_check(ben.has("2") and ben.has("4"), "beneficios por nivel presentes (checklist 80)")
	_check((ben.get("4", []) as Array).has("oferta_trueque_especial"), "nivel 4 = trueque especial (ligado a M38 RF8)")
	# Umbrales ascendentes
	var um: Dictionary = fr.get("umbrales", {})
	var orden: Array = [um.get("nivel_2", 0), um.get("nivel_3", 0), um.get("nivel_4", 0), um.get("nivel_5", 0), um.get("nivel_8", 0)]
	var ascendente := true
	for i in range(1, orden.size()):
		if int(orden[i]) <= int(orden[i - 1]):
			ascendente = false
	_check(ascendente, "umbrales ascendentes (0/30/70/120/150/260)")
	# Coherencia M20: el servicio de amistad sube nivel con 30 puntos (checklist)
	if _fs != null:
		_fs.registrar_vecino("test_balance_vecino")
		var antes: int = int(_fs.get_nivel("test_balance_vecino"))
		_fs._vecino("test_balance_vecino").aplicar_puntos(30, {})
		var despues: int = int(_fs.get_nivel("test_balance_vecino"))
		_check(despues == antes + 1, "M20: 30 puntos = +1 nivel (umbral nivel_2=30 real)")

func _test_quests() -> void:
	var q: Dictionary = _bal.get_quests_balance()
	var misiones: Dictionary = q.get("misiones", {})
	_check(misiones.has("mision_secundaria_inicial") and misiones.has("mision_principal_acto1"),
		"misiones secundaria+principal presentes")
	# Regla: secundaria AO entre 5-15% del desbloqueo siguiente (taller 150)
	var ao_sec: int = int(misiones.get("mision_secundaria_inicial", {}).get("recompensa_ao", 0))
	var unlocks: Dictionary = _bal.get_tabla("unlocks")
	var coste_taller: int = int(unlocks.get("desbloqueos", {}).get("taller_crafting", {}).get("coste_ao", 0))
	var ratio := float(ao_sec) / float(coste_taller)
	_check(ratio >= 0.05 and ratio <= 0.15,
		"secundaria %.0f AO = %.0f%% de taller (%d) en [5%%,15%%]" % [ao_sec, ratio * 100, coste_taller])
	# Ítems exclusivos no monetizables
	_check(q.get("reglas", {}).get("items_exclusivos_no_monetizables", false),
		"ítems exclusivos no monetizables (checklist 88)")
	_check(q.get("reglas", {}).get("misiones_siempre_completables", false),
		"misiones siempre completables (checklist 89, M66)")
	_check(q.has("bonus_eventos_temporada"), "bonus eventos temporada (checklist 90)")

func _test_puzzles() -> void:
	var p: Dictionary = _bal.get_puzzles()
	var puzzles: Dictionary = p.get("puzzles", {})
	_check(puzzles.size() >= 2, "2 puzzles con tiempos")
	for id in puzzles:
		var pz: Dictionary = puzzles[id]
		_check(int(pz.get("tiempo_max_con_ayuda_min", 99)) <= 20, "%s: ayuda ≤20 min (checklist 95)" % id)
		_check(int(pz.get("tiempo_max_sin_ayuda_min", 99)) <= 45, "%s: sin ayuda ≤45 min (checklist 95)" % id)
	_check(p.get("recompensa_templo", {}).get("item_unico", false) == true,
		"recompensa templo herramienta única (checklist 96)")
	_check(p.get("recompensa_templo", {}).get("monetizable", true) == false,
		"templo no monetizable")
	_check(p.get("recompensa_ruinas", {}).get("lore", false) == true,
		"ruinas dan lore (checklist 98)")
	_check(p.get("reglas", {}).get("resoluble_con_herramientas_del_momento", false) == true,
		"resoluble con herramientas del momento (checklist 97)")
	# Coherencia M22: puzzles de templos existen en el grafo de historia
	var hist: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/historia/historia_principal.json"))
	var hay_templos := false
	for nodo in hist.get("nodos", []):
		if String(nodo.get("tipo", "")) == "templo":
			hay_templos = true
	_check(hay_templos, "M22 tiene nodos templo (gating sellos coherente con puzzles)")

func _test_unlocks() -> void:
	var u: Dictionary = _bal.get_tabla("unlocks")
	var orden: Array = u.get("orden_global", [])
	_check(orden.size() >= 3, "orden_global presente (checklist 103)")
	# El orden respeta los "orden" individuales ascendentes
	var desbloqueos: Dictionary = u.get("desbloqueos", {})
	var ultimo := -1
	var coherente := true
	for id in orden:
		var o: int = int(desbloqueos.get(id, {}).get("orden", 0))
		if o <= ultimo:
			coherente = false
		ultimo = o
	_check(coherente, "orden individuales ascendentes y consistentes con orden_global")
	_check(u.get("reglas", {}).get("historia_sin_coste_monetario", false) == true,
		"historia sin coste monetario (checklist 104)")
	var cosmeticos: Dictionary = u.get("reglas", {}).get("cosmeticos_sink_ao", {})
	_check(cosmeticos.has("rango_coste_ao"), "cosméticos como sink AO (checklist 105)")
	_check(u.get("reglas", {}).get("museo_records_no_monetarios", false) == true,
		"récords museo no monetarios (checklist 106)")
	# Cada desbloqueo AO tiene condición declarada
	for id in desbloqueos:
		var d: Dictionary = desbloqueos[id]
		_check(String(d.get("condicion", "")) != "", "%s con condición" % id)

func _test_rareza_pity() -> void:
	var meta: Dictionary = _bal.obtener_meta()
	var r: Dictionary = meta.get("rareza", {})
	_check(float(r.get("probabilidad_raro_max", 1.0)) <= 0.05, "raro tope 5% (checklist 41)")
	var pity: Dictionary = r.get("pity", {})
	_check(float(pity.get("incremento_por_fallo", 0)) > 0.0, "pity con incremento (checklist 42)")
	_check(pity.get("reset_al_conseguir", false) == true, "pity se resetea (M34 ya lo implementa)")
	_check(meta.get("rendimiento", {}).get("nodos_activos_max_por_chunk", 0) > 0,
		"límite nodos por chunk (checklist 57, M61)")
	_check(meta.get("viajes", {}).get("recompensa_descubrir_ruta_ao", 0) > 0,
		"recompensa por rutas nuevas (checklist 66, M28)")
