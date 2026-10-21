# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M74 iter. 2: test de eventos de capítulos 1-7 (historia principal M149).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_capitulos_m74.gd

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M74] Test eventos de capítulos 1-7 ===")
	var em := root.get_node_or_null("eventos")
	if em == null:
		em = root.get_node_or_null("EventManager")
	_check("EventManager autoload presente", em != null)
	if em == null:
		quit(1)
		return
	var cat: Dictionary = em._catalogo
	_check("catálogo >= 22 eventos (15 base + 7 capítulos)", cat.size() >= 22)
	# Los 7 eventos de capítulos presentes
	var ids_cap: Array[String] = [
		"historia_c1_mural", "historia_c2_puente", "historia_c3_faro",
		"historia_c4_templo_brisa", "historia_c5_eclipse",
		"historia_c6_geoda", "historia_c7_camara_sello",
	]
	for id in ids_cap:
		_check("evento %s cargado" % id, cat.has(id))
	# Los 7 están marcados como historia y numerados 1-7
	var caps_vistos: Array = []
	for id in ids_cap:
		if cat.has(id):
			var flags: Dictionary = cat[id].flags
			_check("%s marcado historia" % id, bool(flags.get("historia", false)))
			var cap := int(flags.get("capitulo", 0))
			if cap >= 1 and cap <= 7 and not caps_vistos.has(cap):
				caps_vistos.append(cap)
	_check("7 capítulos distintos (1-7)", caps_vistos.size() == 7)
	# Coherencia de fechas: eventos de historia sin fecha fija (gatillo)
	var sin_fecha := 0
	for id in ids_cap:
		if cat.has(id) and int(cat[id].dia) == 0 and int(cat[id].mes) == -1:
			sin_fecha += 1
	_check("eventos de historia con gatillo (sin fecha fija)", sin_fecha == 7)
	# Prioridad de historia mayor que festivales (200-400 vs 100)
	var hist_mayor := true
	for id in ids_cap:
		if cat.has(id) and int(cat[id].prioridad) < 100:
			hist_mayor = false
	_check("prioridad de historia >= 100", hist_mayor)
	# Coherencia con la historia M149: los gatillos existen en historia_principal.json
	var historia: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/historia/historia_principal.json"))
	_check("historia_principal.json parsea", typeof(historia) == TYPE_DICTIONARY)
	if typeof(historia) == TYPE_DICTIONARY:
		var caps_historia: Array = []
		for nodo in historia.get("nodos", []):
			var cap_n := int(nodo.get("capitulo", 0))
			if cap_n >= 1 and cap_n <= 7 and not caps_historia.has(cap_n):
				caps_historia.append(cap_n)
		_check("historia tiene 7 capítulos únicos (1-7)", caps_historia.size() == 7)
	# Las claves i18n de los capítulos viven en el CATÁLOGO RUNTIME (locales/*.po).
	# Hasta 2026-10-21 esta aserción miraba `data/localizacion/strings_es.json`,
	# que el autoload `Localization` NO lee (carga `res://locales/*.po`): el test
	# pasaba VERDE con las 14 claves ausentes del catálogo real. Falso verde
	# medido y corregido en el ítem 46 de M87 (Log 2065).
	var claves_ok := true
	var faltantes: Array[String] = []
	for locale in ["es", "en"]:
		var catalogo: Dictionary = ValidadorPO.validar_archivo("res://locales/%s.po" % locale)
		var presentes: Array = catalogo["claves"]
		for i in range(1, 8):
			for sufijo in ["nombre", "desc"]:
				var clave := "eventos.historia_c%d_%s" % [i, sufijo]
				if not presentes.has(clave):
					claves_ok = false
					faltantes.append("%s:%s" % [locale, clave])
	_check("14 claves i18n de capítulos en el catálogo runtime (es.po/en.po)", claves_ok)
	if not faltantes.is_empty():
		print("  claves faltantes: %s" % str(faltantes))
	# Regresión: los 15 eventos base siguen cargados
	var base_ids: Array[String] = ["festival_verano", "festival_luces", "feria_colmena",
		"concurso_minero", "torneo_pesca", "ceremonia_templos", "niebla_faro", "visita_sorpresa"]
	var base_ok := true
	for id in base_ids:
		if not cat.has(id):
			base_ok = false
	_check("eventos base siguen cargados (regresión)", base_ok)
	print("=== Resumen M74 capítulos: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
