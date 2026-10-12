# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M19: Test del catálogo de vecinos — valida los 14 perfiles .tres
# (10 activos + 4 rotación, diseño §C), ids únicos, campos obligatorios,
# rutinas coherentes y la API nueva de detección de duplicados.
# Exit code != 0 si falla.
#
# Ejecutar:
# Godot --headless --path game/isla-ancestral --script res://scripts/npc/test_catalogo_m19_atria.gd

extends SceneTree

const RUTA_DIR := "res://data/villagers"
const POBLACION_MAX_ESPERADA := 10
const CATALOGO_ESPERADO := 14

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M19] Test del catálogo de vecinos (atria) ===")
	_test_catorce_perfiles()
	_test_ids_unicos()
	_test_campos_obligatorios()
	_test_rutinas()
	_test_api_manager()
	_fin()

func _fin() -> void:
	print("=== TEST M19 CATÁLOGO (atria): %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s %s" % [nombre, detalle])

func _listar_tres() -> Array:
	var out: Array = []
	var dir := DirAccess.open(RUTA_DIR)
	if dir == null:
		return out
	for a in dir.get_files():
		if a.ends_with(".tres"):
			out.append(a)
	out.sort()
	return out

## Deben existir exactamente 14 perfiles (10 activos + 4 rotación, diseño §C).
func _test_catorce_perfiles() -> void:
	var archivos := _listar_tres()
	print("--- Cantidad de perfiles ---")
	_check("14 perfiles en data/villagers/", archivos.size() == CATALOGO_ESPERADO,
		"encontrados=%d (esperados=%d)" % [archivos.size(), CATALOGO_ESPERADO])
	_check("catálogo > población máxima (rotación posible)", archivos.size() > POBLACION_MAX_ESPERADA,
		"%d <= %d" % [archivos.size(), POBLACION_MAX_ESPERADA])
	print("  archivos: %s" % str(archivos))

## Un id por perfil, sin duplicados (FIX Log NNNN).
func _test_ids_unicos() -> void:
	print("--- Ids únicos ---")
	var vistos: Dictionary = {}
	var duplicados: Array = []
	var archivos := _listar_tres()
	for a in archivos:
		var p = load(RUTA_DIR + "/" + a)
		if p == null:
			_check("perfil cargable: %s" % a, false, "load() == null")
			continue
		var pid: String = str(p.get("id", ""))
		if pid == "":
			_check("perfil con id no vacío: %s" % a, false)
			continue
		if vistos.has(pid):
			duplicados.append(pid)
		vistos[pid] = a
	_check("sin ids duplicados", duplicados.is_empty(), "duplicados=%s" % str(duplicados))
	_check("cada .tres aporta 1 id distinto", vistos.size() == archivos.size(),
		"ids=%d archivos=%d" % [vistos.size(), archivos.size()])

## Campos obligatorios del schema villager_profile.gd.
func _test_campos_obligatorios() -> void:
	print("--- Campos obligatorios ---")
	var campos := ["id", "nombre", "especie", "personalidad", "profesion", "hogar_deseado"]
	var lineas := ["linea_saludo", "linea_despedida", "linea_sueno"]
	for a in _listar_tres():
		var p = load(RUTA_DIR + "/" + a)
		if p == null:
			continue
		var pid: String = str(p.get("id", "?"))
		for c in campos:
			var v = p.get(c, null)
			_check("%s: %s no vacío" % [pid, c], v != null and str(v) != "", "valor=%s" % str(v))
		for l in lineas:
			var s = p.get(l, null)
			_check("%s: %s no vacía" % [pid, l], s != null and str(s) != "")
		# gustos/disgustos no vacíos (al menos 1 gusto)
		var gustos = p.get("gustos", [])
		_check("%s: al menos 1 gusto" % pid, gustos != null and gustos.size() >= 1)
		# cumpleaños en rango del calendario Aurora (mes 1-12, dia 1-28)
		var mes: int = int(p.get("cumpleanos_mes", 0))
		var dia: int = int(p.get("cumpleanos_dia", 0))
		_check("%s: cumpleaños en rango (mes %d, dia %d)" % [pid, mes, dia],
			(mes >= 1 and mes <= 12 and dia >= 1 and dia <= 28) or (mes == 0 and dia == 0))

## Cada perfil debe tener rutina con al menos 4 franjas y franja de dormir.
func _test_rutinas() -> void:
	print("--- Rutinas diarias ---")
	for a in _listar_tres():
		var p = load(RUTA_DIR + "/" + a)
		if p == null:
			continue
		var pid: String = str(p.get("id", "?"))
		var r = p.get("rutina_diaria", {})
		_check("%s: rutina >= 4 franjas" % pid, r != null and r.size() >= 4, "size=%d" % (r.size() if r != null else -1))
		if r != null and r.size() > 0:
			var tiene_dormir: bool = false
			for k in r:
				if str(r[k]) == "dormir":
					tiene_dormir = true
			_check("%s: rutina incluye 'dormir'" % pid, tiene_dormir)

## El manager carga el catálogo y reporta duplicados sin crashear.
func _test_api_manager() -> void:
	print("--- VillagerManager: catálogo + duplicados ---")
	var vm = load("res://scripts/npc/villager_manager.gd").new()
	root.add_child(vm)
	await process_frame
	_check("manager: catálogo_count == 14", vm.catalogo_count() == CATALOGO_ESPERADO,
		"count=%d" % vm.catalogo_count())
	_check("manager: 0 duplicados en catálogo limpio", vm._duplicados_catalogo == 0,
		"duplicados=%d" % vm._duplicados_catalogo)
	# perfil_obtenible por id de los nuevos
	var p = vm.obtener_perfil("teo_conejo")
	_check("manager: obtener_perfil('teo_conejo') no es null", p != null)
	if p != null:
		_check("manager: teo_conejo.especie == 'conejo'", str(p.get("especie", "")) == "conejo")
	vm.free()
